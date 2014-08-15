/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RECIBO DE ENTREGA DE VALES VALE MERCADO
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MAIO DE 1998
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cTIPOREL)}

private sBLOCO1 := qlbloc("B560A","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B560B","QBLOC.GLO") // ambiente escolhido
private sBLOCO3 := qlbloc("B560C","QBLOC.GLO") // ordem de impressao

private cTIPOREL                // tipo de relatorio (mensal ou 13o.)
private cORDEM     := "M"       // ordem de impressao (matricula/nome)
private cMATRICULA := space(6)  // matricula do funcionario
private aEDICAO := {}           // vetor para os campos de entrada de dados
private aBENEF  := {}           // vetor para os campos de beneficios
private nTOT_VAL := 0
private nQTD_VAL := 0
private cANOMES := qanomes(CONFIG->Datasys)
private nFLAG    := 1

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO2)} , "TIPOREL"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM   ,sBLOCO3)} , "ORDEM"    })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA ,"999999")} , "MATRICULA"})
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario

do while .T.

   qlbloc(5,0,"B564A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.
   nFLAG    := 1
   cTIPOREL := " "
   cMATRICULA := space(6)

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
           if empty(cTIPOREL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOREL,"MADF",{"Mˆs Corrente","Adiantamento","D‚cimo Terceiro","F‚rias"}))
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matr¡cula","Nome"}))
      case cCAMPO == "MATRICULA"
           if empty(cMATRICULA)
              qrsay(XNIVEL+1,"Todas as Matriculas...")
           else
              if ! FUN->(dbseek(cMATRICULA:=strzero(val(cMATRICULA),6)))
                 qmensa("Matricula n„o Encontrada...","B")
                 return .F.
              else
                 if FUN->Situacao <> "T"
                    qmensa("Funcion rio n„o est  trabalhando...","B")
                    return .F.
                 endif
                 qrsay(XNIVEL+1,left(FUN->Nome,30))
              endif
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   cTIPOREL := qabrev(cTIPOREL,"MAD",{"MS","AD","DT"})

   SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

   do case
      case cORDEM == "M" ; FUN->(dbsetorder(01)) // matricula
      case cORDEM == "N" ; FUN->(dbsetorder(02)) // nome
   endcase

   qmensa()

   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   nTOT_VAL  := 0
   nQTD_VAL  := 0
   aBENEF    := {}

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! empty(cMATRICULA)
      FUN->(Dbsetorder(1))
      FUN->(Dbseek(cMATRICULA))
      if cORDEM == "N"
         FUN->(dbsetorder(2))
      endif
   endif
   nFLAG := 1
   do while ! FUN->(eof()) .and. qcontprn()

//      if ! empty(cMATRICULA) .and. FUN->Matricula <> cMATRICULA
//         exit
//      endif

      qgirabarra()

      if FUN->Situacao <> "T"
         FUN->(dbskip())
         loop
      endif

      if ! qlineprn() ; return ; endif

      FUN->(dbSetRelation("LANC",{|| cANOMES+FUN->Matricula+cTIPOREL+'458'},"cANOMES+FUN->Matricula+cTIPOREL+'458'}"))


      nTOT_VAL := LANC->Valor
      nQTD_VAL := LANC->Fracao

      nMATRICULA := FUN->Matricula
      nNOME      := FUN->Nome

      SITUA->(dbseek(FUN->Matricula))

      nSALARIO   := iif(SITUA->Categoria=="5",SITUA->Salario*FUN->Hor_trab,SITUA->Salario)

      if nTOT_VAL <> 0 .or. nQTD_VAL <> 0
         @ prow()+1,00 say "+" + replicate("-",78) + "+"
         @ prow()+1,00 say "|" + space(20) + XAEXPAN + "RECIBO DE ENTREGA DE" + space(8) +XDEXPAN+space(2)+ "|"
         @ prow()+1,00 say "|" +XAEXPAN+ space(10) + "   TICKET REFEICAO  " + XDEXPAN + space(18) + "|"
         @ prow()+1,00 say "|" + space(78) + "|"
         @ prow()+1,00 say "|" + space(10) + "Recebi de " + XRAZAO + space(8) + "|"
         @ prow()+1,00 say "| o total de " + transform(nQTD_VAL,"@R 999") + " tickets refeicao no valor de R$  "+ transform(nTOT_VAL,"@R 9,999,999.99") + space(17) + "|"
         nLIN := len(qextenso(nTOT_VAL))
         @ prow()+1,00 say "| (" + qextenso(nTOT_VAL) + ")" + space(75-nLIN) + "|"
         @ prow()+1,00 say "|" + space(78) + "|"
         @ prow()+1,00 say "| que farei uso no periodo de  01 de " + qnomemes(CONFIG->Data_atual) + " a " + strzero(day(CONFIG->Data_atual),2) + " de " + qnomemes(qfimmes(CONFIG->Data_atual)) + "               |"
         @ prow()+1,00 say "|" + space(78) + "|"
         @ prow()+1,00 say "| ______________________, _____ , _______   __________________________________ |"
         @ prow()+1,00 say "|"
         @ prow()  ,49 say left(nNOME,28) + "  |"
         @ prow()+1,00 say "|"
         @ prow()  ,49 say "Assinatura do Empregado       |"
         @ prow()+1,00 say "|" + space(78) + "|"
         @ prow()+1,00 say "|"+space(25)+"DEMONSTRATIVO DOS VALORES"+SPACE(28)+"|"
         @ prow()+1,00 say "|" + space(78) + "|"
         @ prow()+1,00 say "| SALARIO BASICO R$ "+transform(nSALARIO,"999,999.99")+ space(49)+ "|"
         @ prow()+1,00 say "|" + space(78) + "|"
         nFLAG++
         if nFLAG == 4
            eject
            nFLAG :=1 // para impressao de 2 recibos p/ pagina
         endif
      endif
      if ! empty(cMATRICULA)
           exit
      endif
      FUN->(dbskip())
      nTOT_VAL  := 0
      nQTD_VAL  := 0

   enddo

   qstopprn()

return .t.
