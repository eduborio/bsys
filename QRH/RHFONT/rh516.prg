/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DA GUIA DE PIS (DARF)
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: ABRIL DE 1996
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE    := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO  := {}        // vetor para entrada de dados
private nTOTAL   := 0         // total da base de calculo da folha
private nDED     := 0         // total da base de calculo da folha
private lACHOU   := .F.       // flag verificador de existencia de dados
private dDT_VENC := ctod("")  // data de vencimento
private cTIPOREL               // define tipo de funcionario
private sBLOCO1    := qlbloc("B516B","QBLOC.GLO")

// POSICIONA ARQUIVO CGM EM RELACAO A CIDADE DA EMPRESA _____________________

CGM->(dbseek(XCGM))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO1              )} , "TIPOREL"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_VENC )},"DT_VENC" })

do while .T.

   qlbloc(5,0,"B516A","QBLOC.GLO")
   qmensa()
   XNIVEL   := 1
   XFLAG    := .T.
   dDT_VENC := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if cTIPOREL == "1"
      if i_inicializacao()
         if lACHOU
            i_impressao()
         endif
      endif
   else
      if i_inicializacao()
         if lACHOU
            i_imp2()
         endif
      endif
   endif


enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "TIPOREL"
           qrsay(XNIVEL,qabrev(cTIPOREL,"12",{"Formul�rio Cont�nuo",;
                          "GUIA DARF"}))

      case cCAMPO == "DT_VENC"
           if empty(dDT_VENC)
              qmensa("Campo DATA DE VENCIMENTO � obrigat�rio !","B")
              qmensa("")
              return .F.
           endif
         //  XNIVEL+=5
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
   cANOMES := right(dtoc(XDATASYS),4) + subs(dtoc(XDATASYS),4,2)

   // TOTALIZACAO DE PROVENTOS DE FUNCIONARIOS ______________________________

   qmensa("Totalizando INSS de funcion�rios...")

   LANC->(dbseek(cANOMES))

   do while ! LANC->(eof()) .and. LANC->Anomes == cANOMES
      if LANC->Anomes != cANOMES
         LANC->(dbskip())
         loop
      endif

      if SITUA->(dbseek(LANC->Matricula+cANOMES))
         if SITUA->Vinculo == "G"
            LANC->(dbskip())
            loop
         endif
      endif

      if EVENT->(dbseek(LANC->Evento))
         if LANC->Ambiente $ "MS-FR-DT" .and. EVENT->Finalidade == "P"// .and. (EVENT->Inssms == "S" .or. EVENT->Inssfr == "S")
            nTOTAL += LANC->Valor
            lACHOU := .T.
         endif
      endif

      if EVENT->(dbseek(LANC->Evento))
         if LANC->Ambiente $ "MS-FR-DT" .and. EVENT->Finalidade == "D" .and. (EVENT->Inssms == "S" .or. EVENT->Inssfr == "S")
            nDED += LANC->Valor
         endif
      endif

      LANC->(dbskip())
   enddo
   
return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE IMPRESSAO _________________________________________

static function i_impressao
   if ! qinitprn() ; return ; endif
   if ! qlineprn() ; return ; endif
   @ prow(),pcol() say XCOND0

   @ prow()+1,00 say "|"+replicate("-",78)+"|"
   @ prow()+1,00 say "|"+"      MINISTERIO DA FAZENDA            "+"|"+"02 PERIODO DE APURACAO  |" +dtoc(XDATASYS) +"   |"
   @ prow()+1,00 say "|"+"  SECRETARIA DA RECEITA FEDERAL        "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"  Documento de Arrecadacao de Receitas "+"|"+"03 NUMERO DO CPF ou CGC |" +XCOND1+XCGCCPF+" "+XCOND0+" |"
   @ prow()+1,00 say "|"+"  Federais                             "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"  DARF                                 "+"|"+"04 CODIGO DA RECEITA    |    8301     |"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"01 NOME/TELEFONE                       "+"|"+"05 NUMEROS DE REFERENCIA|             |"
   @ prow()+1,00 say "|"+XCOND1 + XRAZAO + space(1) + XTELEFONE + XCOND0+"   |"+"-------------------------------------|"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"06 DATA DO VENCIMENTO   |"+dtoc(dDT_VENC)+"   |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"07 VALOR DO PRINCIPAL   |"+XCOND1+transf((nTOTAL-nDED)*0.01,"@E 999,999,999.99")+XCOND0+"     |"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"08 VALOR DA MULTA       |             |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"09 VALOR DOS JUROS      |             |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"10 VALOR TOTAL          |"+XCOND1+transf((nTOTAL-nDED)*0.01,"@E 999,999,999.99")+XCOND0+"     |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"11 AUTENTICACAO BANCARIA              |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"                                      |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"                                      |"
   @ prow()+1,00 say "|"+replicate("-",78)+"|"

   @ prow()+1,00 say " "
   @ prow()+1,00 say "|"+replicate("-",78)+"|"
   @ prow()+1,00 say "|"+"      MINISTERIO DA FAZENDA            "+"|"+"02 PERIODO DE APURACAO  |" +dtoc(qfimmes(dDT_VENC)) +"   |"
   @ prow()+1,00 say "|"+"  SECRETARIA DA RECEITA FEDERAL        "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"  Documento de Arrecadacao de Receitas "+"|"+"03 NUMERO DO CPF ou CGC |" +XCOND1+XCGCCPF+" "+XCOND0+" |"
   @ prow()+1,00 say "|"+"  Federais                             "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"  DARF                                 "+"|"+"04 CODIGO DA RECEITA    |    8301     |"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"01 NOME/TELEFONE                       "+"|"+"05 NUMEROS DE REFERENCIA|             |"
   @ prow()+1,00 say "|"+XCOND1 + XRAZAO + space(1) + XTELEFONE + XCOND0+"   |"+"-------------------------------------|"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"06 DATA DO VENCIMENTO   |"+dtoc(dDT_VENC)+"   |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"07 VALOR DO PRINCIPAL   |"+XCOND1+transf((nTOTAL-nDED)*0.01,"@E 999,999,999.99")+XCOND0+"     |"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"08 VALOR DA MULTA       |             |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"09 VALOR DOS JUROS      |             |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"10 VALOR TOTAL          |"+XCOND1+transf((nTOTAL-nDED)*0.01,"@E 999,999,999.99")+XCOND0+"     |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"11 AUTENTICACAO BANCARIA              |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"                                      |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"                                      |"
   @ prow()+1,00 say "|"+replicate("-",78)+"|"

   qstopprn()
return

static function i_imp2

   if ! qinitprn()
      qmensa("Nao foi possivel Inicializar Impressaora!","B")
      return .F.
   endif
   @ prow(),pcol() say XCOND0

   @ prow()  ,67 say dtoc(XDATASYS)
   @ prow()+2,58 say XCGCCPF
   @ prow()+2,60 say "8301"

   @ prow()+4,01 say XCOND1 + XRAZAO + space(1) + XTELEFONE + XCOND0
   @ prow()  ,60 say dtoc(dDT_VENC)

   // IMPRESSAO COM VALOR, INDIVIDUAL OU GERAL ___________________________________

   @ prow()+2,60 say (nTOTAL-nDED) * 0.01 picture "@E 999,999,999.99"

   // IMPRIME MULTA E JUROS, CASO EXISTAM _____________________________________

     @ prow()+4,00 say ""

   // IMPRIME O TOTAL, CASO EXISTAM MULTA E JUROS ________________________________

   @ prow()+2,60 say (nTOTAL-nDED) * 0.01 picture "@E 999,999,999.99"

   @ prow()+8 ,000 say ""

   qstopprn(.F.)
return

