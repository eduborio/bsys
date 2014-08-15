/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DE LIQUIDO DE PAGAMENTO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....:
// OBS........: TOTAL / BANCO / CHEQUE / DINHEIRO
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cTIPOREL)}

private sBLOCO1 := qlbloc("B522A","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B522B","QBLOC.GLO") // tipo de relatorio
private sBLOCO3 := qlbloc("B522C","QBLOC.GLO") // ordem de impressao
private sBLOCO4 := qlbloc("B522D","QBLOC.GLO") // abrangencia

private nTOTAL                 // total do liquido a pagar
private cTIPOREL               // tipo de relatorio (mensal ou 13o.)
private cABRANG := "M"         // abrangencia do relatorio(mensal, adt ou 13.)
private cTITULO1               // titulo 1 do contra-cheque
private cTITULO2               // titulo 2 do contra-cheque
private cORDEM  := "1"         // ordem de impressao (matricula/nome)
private cZERADO := "N"         // imprime liquido zerado (sim ou nao)
private cCENTRO                // centro de custo para filtro
private cFILIAL                // filial de filtro
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cANOMES := qanomes(XDATASYS)

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO2)}   , "TIPOREL" })
aadd(aEDICAO,{{ || qesco(-1,0,@cABRANG  ,SBLOCO4)}   , "ABRANG"  })
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO    )}   , "CENTRO"  })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL     )}   , "FILIAL"  })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO3   )}   , "ORDEM"   })
aadd(aEDICAO,{{ || qesco(-1,0,@cZERADO,XSN      )}   , "ZERADO"  })

do while .T.

   qlbloc(5,0,"B522A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.
   cCENTRO  := space(8)
   cFILIAL  := space(4)
   cTIPOREL := " "
   nTOTAL   := 0

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
           qrsay(XNIVEL,qabrev(cTIPOREL,"TBCDO",{"Total","Banco","Cheque","Dinheiro","Outros"}))
      case cCAMPO == "ABRANG"
           qrsay(XNIVEL,qabrev(cABRANG,"FAD",{"Folha Mensal","Adiantamento","D‚cimo Terceiro"}))
      case cCAMPO == "CENTRO"
           if ! empty(cCENTRO)
              if empty(right(cCENTRO,4))
                 qmensa("Centro de Custo n„o Anal¡tico !!","B")
                 return .F.
              endif
              if ! CCUSTO->(dbseek(cCENTRO))
                 qmensa("Centro de Custo n„o Cadastrado !!","B")
                 return .F.
              endif
           endif
           qrsay(XNIVEL+1,iif(CCUSTO->(dbseek(cCENTRO)),CCUSTO->Descricao,"*** Todos os Centros ***"))
      case cCAMPO == "FILIAL"
           qrsay(XNIVEL+1,iif(FILIAL->(dbseek(cFILIAL)),LEFT(FILIAL->Razao,40),"*** Todas as Filiais ***"))
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cORDEM,"123456",{"Matricula","Nome","Centro+Matricula","Centro+Nome","Banco"}))
      case cCAMPO == "ZERADO"
           qrsay(XNIVEL,qabrev(cZERADO,"SN",{"Sim","N„o"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO1" E "cTITULO2" _____________________________

   cTITULO1 := "LIQUIDOS DE PAGAMENTO - "

   do case
      case cTIPOREL == "R" ; cTITULO1 += "RELACAO SINTETICA - "
      case cTIPOREL == "T" ; cTITULO1 += "TOTAL - "
      case cTIPOREL == "B" ; cTITULO1 += "CREDITO BANCARIO - "
      case cTIPOREL == "C" ; cTITULO1 += "CHEQUES - "
      case cTIPOREL == "D" ; cTITULO1 += "DINHEIRO - "
      case cTIPOREL == "O" ; cTITULO1 += "OUTROS - "
   endcase

   do case
      case cABRANG == "F"
           cTITULO1+= "FOLHA MENSAL DE "
      case cABRANG == "A"
           cTITULO1+= "ADIANTAMENTO MENSAL DE "
      case cABRANG == "D"
           cTITULO1+= "DECIMO TERCEIRO DE "
   endcase

   cTITULO1 += " - " + upper(qnomemes(month(XDATASYS))) + "/" + str(year(XDATASYS),4)

   do case
      case ! empty(cFILIAL)
           cTITULO2 := "FILIAL: " + FILIAL->Codigo + " - " + FILIAL->Razao
      case ! empty(cCENTRO)
           cTITULO2 := "CENTRO DE CUSTO: " + CCUSTO->Codigo + " - " + CCUSTO->Descricao
   endcase

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   do case
      case cORDEM == "1" ; FUN->(dbsetorder(01)) // matricula
      case cORDEM == "2" ; FUN->(dbsetorder(02)) // nome
      case cORDEM == "3" ; FUN->(dbsetorder(07)) // centro + matricula
      case cORDEM == "4" ; FUN->(dbsetorder(08)) // centro + nome
      case cORDEM == "5"
           select FUN
           qmensa("Aguarde, indexando por BANCO...")
           index on Csal_ban+Matricula to (XDRV_RH+"TMP")
   endcase

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   SITUA->(dbsetrelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))

   FUN->(dbsetrelation("CCUSTO",{|| Centro},"Centro"))
   
   FUN->(dbsetrelation("FILIAL",{|| Filial},"Filial"))

   FUN->(dbsetrelation("BANCO",{|| Csal_ban},"Csal_ban"))

   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nVALOR

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   @ prow(),pcol() say XCOND0

   do while ! FUN->(eof()) .and. qcontprn()     // condicao principal de loop

      SITUA->(dbseek(FUN->Matricula))

      if FUN->Data_adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         loop
      endif

      if SITUA->Vinculo $ "F-G-H-M-N"
         FUN->(dbskip())
         loop
      endif

      if SITUA->Situacao $ "D-H"
         FUN->(dbskip())
         loop
      endif

      qmensa("Funcionario: "+FUN->Matricula+" / "+left(FUN->Nome,30))

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow(),pcol() say XCOND0
         do case
            case ! empty(cFILIAL)
//               qcabecprn(XAENFAT+cTITULO1+XDENFAT,80,.T.,XAENFAT+cTITULO2+XDENFAT)
                 qcabecprn(XAENFAT+cTITULO1+XDENFAT,80,.T.)
                 if ! empty(cCENTRO)
                    @ prow()+2,0 say padc("CENTRO DE CUSTO: " + CCUSTO->Codigo + " - " + CCUSTO->Descricao,80)
                    @ prow()+1,0 say ""
                 endif
            case ! empty(cCENTRO)
//               qcabecprn(XAENFAT+cTITULO1+XDENFAT,80,.T.,XAENFAT+cTITULO2+XDENFAT)
                 qcabecprn(XAENFAT+cTITULO1+XDENFAT,80,.T.)
            other
                 qcabecprn(XAENFAT+cTITULO1+XDENFAT,80)
         endcase

         do case
            case ! empty(cFILIAL)
               FILIAL->(dbseek(cFILIAL))
               @ prow()+1,0 say "FILIAL.: " + cFILIAL + " " + FILIAL->Razao
            case ! empty(cCENTRO)
               @ prow()+1,0 say "CENTRO DE CUSTO.: " + CCUSTO->Codigo + " " + CCUSTO->Descricao
         endcase

         @ prow()+1,0 say XCOND1 + XAENFAT + "MATRICULA        NOME                                 FILIAL          CENTRO      SITUACAO  DATA ADM             LIQUIDO         TIPO" + XDENFAT
         @ prow()+1,0 say replicate("-",137)

      endif

      if (cTIPOREL == "T" .or. cTIPOREL == SITUA->Tipo_pgto) .and. i_filtro()
         do case
            case cABRANG == "F"
                 nVALOR := BASE->Prov_ms - BASE->Desc_ms
            case cABRANG == "A"
                 nVALOR := BASE->Prov_ad - BASE->Desc_ad
            case cABRANG == "D"
                 nVALOR := BASE->Prov_dt - BASE->Desc_dt
         endcase
         
         if cZERADO = "N" .and. nVALOR <= 0
            FUN->(dbskip())
            loop
         endif

         @ prow()+1,2         say FUN->Matricula
         @ prow()  ,pcol()+9  say left(FUN->Nome,30)
         @ prow()  ,pcol()+7  say FUN->Filial
//       @ prow()  ,pcol()+11 say FUN->Centro
         @ prow()  ,pcol()+11 say SITUA->Ccusto
         @ prow()  ,pcol()+7  say FUN->Situacao
         @ prow()  ,pcol()+7  say dtoc(FUN->Data_Adm)
         @ prow()  ,pcol()+8  say transform(nVALOR,"@E 9,999,999.99")
         @ prow()  ,pcol()+9  say qabrev(SITUA->Tipo_pgto," BCDO",{"","Banc","Cheq","Dinh","Outr"})

         nTOTAL += nVALOR
      endif

      FUN->(dbskip())

   enddo

   @ prow()+1,0 say replicate("-",137)
   @ prow()+2,101 say XAENFAT+"Total: " + transform(nTOTAL,"@E 9,999,999.99")+XDENFAT

   qstopprn()
   qmensa()

return

static function i_filtro
   if FUN->Situacao == "H" ; return .F. ; endif
// if ! empty(cCENTRO) .and. cCENTRO <> FUN->Centro ; return .F. ; endif
   if ! empty(cCENTRO) .and. cCENTRO <> SITUA->Ccusto ; return .F. ; endif
   if ! empty(cFILIAL) .and. cFILIAL <> FUN->Filial ; return .F. ; endif
return .T.
