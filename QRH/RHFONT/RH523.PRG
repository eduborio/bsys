/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: NOTAS E MOEDAS PARA PAGAMENTO EM DINHEIRO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cTIPOREL)}

private sBLOCO1 := qlbloc("B501B","QBLOC.GLO") // tipo de relatorio
private sBLOCO2 := qlbloc("B523B","QBLOC.GLO") // SUBTOT (nao/centro/filial)

private aNOTAS1 := array(11)   // vetor com quant. de notas e moedas (SUBTOT)
private aNOTAS2 := array(11)   // vetor com quant. de notas e moedas (TOTAL)
private cTIPOREL               // tipo de relatorio (mensal ou 13o.)
private cSUBTOT                // subtotal (centro/local)
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cANOMES := qanomes(XDATASYS)
private cTIPO

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL,sBLOCO1)}    , "TIPOREL"   })
aadd(aEDICAO,{{ || qesco(-1,0,@cSUBTOT ,sBLOCO2)}    , "SUBTOT"    })

do while .T.

   qlbloc(5,0,"B523A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cCENTRO := cLOCAL := space(10)
   cSUBTOT := cTIPOREL := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "TIPOREL"
           qrsay(XNIVEL,qabrev(cTIPOREL,"MAD",{"Mes Corrente","Adiantamento","Decimo Terceiro"}))
      case cCAMPO == "SUBTOT"
           qrsay(XNIVEL,qabrev(cSUBTOT,"TCF",{"Total","Centro","Filial"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   do case
//    case cSUBTOT == "C" ; FUN->(dbsetorder(07)) // centro + matricula
      case cSUBTOT == "C" ; FUN->(dbsetorder(01)) //  matricula
      case cSUBTOT == "F" ; FUN->(dbsetorder(05)) // filial + matricula
   endcase
   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select FUN
   set relation to Matricula+cANOMES into BASE

   SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

   FUN->(dbgotop())

   cTIPOREL := qabrev(cTIPOREL,"MAD",{"MS","AD","DT"})

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nCONT, cMACROP, cMACROD
   local cMACRO := iif(cSUBTOT=="C","CENTRO",iif(cSUBTOT=="F","FILIAL","FILIAL"))
   local cCTRL  := FUN->(&cMACRO.)

   afill(aNOTAS1,0)
   afill(aNOTAS2,0)

   cMACROP := "BASE->Prov_" + cTIPOREL
   cMACROD := "BASE->Desc_" + cTIPOREL

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while .T. .and. qcontprn()
      qgirabarra()

      SITUA->(dbseek(FUN->Matricula))

      if FUN->Data_adm > qfimmes(XDATASYS) .or. FUN->Situacao $ "DH"
         FUN->(dbskip())
         loop
      endif
      
      do case
         case cSUBTOT $ "T"
              qmensa("Calculando Matr¡cula: "+FUN->Matricula)
              cTIPO := "GERAL "
         case cSUBTOT $ "C"
//            qmensa("Calculando Centro: "+transform(FUN->Centro,"@R 99.99.9999"))
              qmensa("Calculando Centro: "+transform(SITUA->Ccusto,"@R 99.99.9999"))
              cTIPO := "CENTRO"
         case cSUBTOT $ "F"
              qmensa("Calculando Filial: "+FUN->Filial)
              cTIPO := "FILIAL"
      endcase

      if ! qlineprn() ; return ; endif

      if cSUBTOT == "T" .and. FUN->(eof()) ; exit ; endif

      if (FUN->(&cMACRO.) <> cCTRL .and. cSUBTOT <> "T") .or. FUN->(eof())
         if ! EMPTY(cCTRL)
            @ prow()+1,1      say iif(cSUBTOT=="C",transform(cCTRL,"@R 99.99.9999"),iif(cSUBTOT=="F",cCTRL+space(6),cCTRL))
            @ prow(),pcol()+2 say transform(aNOTAS1[11],"@E 99,999,999.99")
            for nCONT := 1 to 10
                @ prow(),pcol()+1 say aNOTAS1[nCONT] picture "9999"
            next
         endif
         cCTRL := FUN->(&cMACRO.)
         afill(aNOTAS1,0)
         if FUN->(eof()) ; exit ; endif
      endif

      if FUN->Situacao $ "TF"   // revisar no futuro
         i_calc_notas(&cMACROP.-&cMACROD.)
      endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn("RELACAO DE NOTAS E MOEDAS",80)
         @ prow()+1,0 say cTIPO + "               TOTAL  100   50   10    5    1  ,50  ,25  ,10  ,05  ,01"
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,0 say ""
      endif

      FUN->(dbskip())

   enddo

   @ prow()+2,13 say transform(aNOTAS2[11],"@E 99,999,999.99")

   for nCONT := 1 to 10
       @ prow(),pcol()+1 say aNOTAS2[nCONT] picture "9999"
   next

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// CALCULO DAS NOTAS E ATUALIZACAO DOS VETORES ANOTAS1 E ANOTAS2 ____________

static function i_calc_notas ( nVALOR )
   local nCONT, nTMP, aVAL := {100,50,10,5,1,.50,.25,.10,.05,.01}

   aNOTAS1[11] += nVALOR
   aNOTAS2[11] += nVALOR

   for nCONT := 1 to 10
       nVALOR := nVALOR / aVAL[nCONT]
       nTMP   := int(val(str(nVALOR)))
       nVALOR := (nVALOR - nTMP) * aVAL[nCONT]
       aNOTAS1[nCONT] += nTMP
       aNOTAS2[nCONT] += nTMP
   next

return
