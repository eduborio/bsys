/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: DEMONSTRACAO DO RESULTADO DO EXERCICIO C/BASE PLANO DE CONTAS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MAIO DE 2000
// OBS........:
// ALTERACOES.:
function ct514

#include "inkey.ch"
#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO  := {}      // vetor para os campos
private cTITULO1            // titulo 1 do relatorio
private cTITULO2            // titulo 2 do relatorio
private cDEB     := "    "  // variavel auxiliar p/ macro
private cCRE     := "    "  // variavel auxiliar p/ macro
private cMESI    := "  "    // mes inicial
private cMESF    := "  "    // mes final
private nPAG     := 0       // pagina inicial para impressao
private nNIVEL   := 0       // nivel da conta
private nSALDATU := 0       // saldo atual da conta
private nCTA     := 0       // conta atual
private cSINAL   := 0       // sinal para a conta (+ ou -)
private nCONTA   := 0       // contador auxiliar
private nRB      := 0       // receita bruta
private nRVMI    := 0       // receita com venda no mercado interno
private nRVME    := 0       // receita com venda no mercado externo
private nRPS     := 0       // receita com prestacao de servicos
private nDR      := 0       // deducoes da receita
private nDA      := 0       // devolucoes e abatimentos
private nIIR     := 0       // impostos incidentes sobre receitas
private nRL      := 0       // receita liquida
private nCT      := 0       // custos
private nCPV     := 0       // custo dos produtos vendidos
private nCSP     := 0       // custo dos servicos prestados
private nLB      := 0       // lucro bruto
private nRDO     := 0       // receitas /despesas operacionais
private nRF      := 0       // receitas financeiras
private nDF      := 0       // despesas financeiras
private nDC      := 0       // despesas comerciais
private nDGA     := 0       // despesas gerais e administrativas
private nRA      := 0       // remuneracao aos administradores
private nRAI     := 0       // resultado da avaliacao de investimentos
private nOPO     := 0       // outras receitas operacionais
private nODO     := 0       // outras despesas operacionais
private nRAEI    := 0       // resultado operacional antes dos efeitos inflacionarios
private nEI      := 0       // efeitos inflacionarios
private nVCM     := 0       // variacoes e correcoes monetarias
private nCMB     := 0       // correcao monetaria do balanco
private nRDEI    := 0       // resultado operacional apos dos efeitos inflacionarios
private nRDNO    := 0       // receitas e despesas nao operacionais
private nRNO     := 0       // receitas nao operacionais
private nDNO     := 0       // despesas nao operacionais
private nRAIR    := 0       // resultado antes do imposto de renda
private nPCS     := 0       // provisao para contribuicao social
private nPIR     := 0       // provisao para imposto de renda
private nLLE     := 0       // lucro liquido do exercicio
private nPEL     := 0       // participacao dos empregados no lucro
private nLPLIQ   := 0       // lucro/prejuizo liquido
private nLPE     := 0       // lucro prejuizo do exercicio
private nLPAP    := 0       //
private cCOMBINA            // combinacao de contas reduzidas
private cDIA                // ultimo dia do mes da data de impressao

private nREC_OPER  := 0
private nDEDUCOES  := 0

private nREC_LIQ   := 0
private nCUST_OPER := 0

private nLUC_BRUTO := 0
private nDESP_PESS := 0
private nDESP_ADM  := 0
private nDESP_GER  := 0
private nDESP_FIN  := 0

private nLUC_LIQ   := 0

private nREC_DESP  := 0

private nRESULTADO := 0

private nPROV_DIV  := 0

private nLUCRO     := 0


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(06,17,@cMESI ,"99"   )},"MESI"  })
aadd(aEDICAO,{{ || qgetx(06,42,@cMESF ,"99"   )},"MESF"  })
aadd(aEDICAO,{{ || qgetx(06,72,@nPAG  ,"9999" )},"PAG"   })

do while .T.

   qlbloc(05,00,"B520A","QBLOC.GLO")
   qmensa()
   XNIVEL := 1
   XFLAG  := .T.
   lACHOU := .F.
   cMESI  := "  "
   cMESF  := "  "
   nPAG   := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif ( i_inicializacao() , iif ( i_plotagem() , i_impressao() , NIL )  , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "MESI"
           if val(cMESI) = 0 .OR. val(cMESI) > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           qrsay(XNIVEL,cMESI := strzero(val(cMESI),2))
      case cCAMPO == "MESF"
           if val(cMESF) = 0 .OR. val(cMESF) > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           qrsay(XNIVEL,cMESF := strzero(val(cMESF),2))
      case cCAMPO == "PAG"
           if empty(nPAG)
              qmensa("Campo PAGINA n„o pode ser igual a zero !","B")
              return .F.
           endif
           qsay(06,72,strzero(nPAG,4))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZACAO ________________________________________________

static function i_inicializacao
   local dDATA , cDIA

   dDATA := qfimmes(ctod("01/"+cMESF+"/"+CONFIG->Exercicio))
   cDIA  := day(dDATA)

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO1 := "DEMONSTRACAO DO RESULTADO DO EXERCICIO EM " + ;
   strzero(cDIA,2) + " DE " + ltrim(qnomemes(cMESF)) + " DE " + CONFIG->Exercicio

   cTITULO2 := "C.N.P.J. " + XCGCCPF

   PLAN->(dbsetorder(03))   // codigo reduzido

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A PLOTAGEM DOS DADOS EM TELA ___________________________

static function i_plotagem

   RESULT->(dbgotop())

   do while ! RESULT->(eof())

      qgirabarra()

      cCOMBINA := ""

      do case
         case RESULT->(recno()) = 1                   // RECEITA BRUTA
              do while RESULT->(recno()) < 5
                 cCOMBINA += alltrim(RESULT->Combina2)
                 do case
                    case RESULT->(recno()) = 2
                         nRVMI := i_maismenos()       // RECEITA COM VENDA NO MERCADO INTERNO
                    case RESULT->(recno()) = 3
                         nRVME := i_maismenos()       // RECEITA COM VENDA NO MERCADO EXTERNO
                    case RESULT->(recno()) = 4
                         nRPS  := i_maismenos()       // RECEITA COM PRESTACAO DE SERVICOS
                 endcase
                 RESULT->(dbskip())
                 cCOMBINA := ""
              enddo
              nRB := nRVMI + nRVME + nRPS
         case RESULT->(recno()) = 5                   // DEDUCOES DA RECEITA BRUTA
              do while RESULT->(recno()) < 8
                 cCOMBINA += alltrim(RESULT->Combina2)
                 do case
                    case RESULT->(recno()) = 6
                         nDA  := i_maismenos()        // DEVOLUCOES E ABATIMENTOS
                    case RESULT->(recno()) = 7
                         nIIR := i_maismenos()        // IMPOSTOS INCIDENTES SOBRE RECEITAS
                 endcase
                 RESULT->(dbskip())
                 cCOMBINA := ""
              enddo
              nDR := nDA + nIIR
         case RESULT->(recno()) = 8                   // CUSTO
              do while RESULT->(recno()) < 11
                 cCOMBINA += alltrim(RESULT->Combina2)
                 do case
                    case RESULT->(recno()) = 9
                         nCPV := i_maismenos()        // CUSTO DOS PRODUTOS VENDIDOS
                    case RESULT->(recno()) = 10
                         nCSP := i_maismenos()        // CUSTO DOS SERVICOS PRESTADOS
                 endcase
                 RESULT->(dbskip())
                 cCOMBINA := ""
              enddo
              nCT := nCPV + nCSP
         case RESULT->(recno()) = 11                  // RECEITAS/DESPESAS OPERACIONAIS
              do while RESULT->(recno()) < 20
                 cCOMBINA += alltrim(RESULT->Combina2)
                 do case
                    case RESULT->(recno()) = 12
                         nRF  := i_maismenos()        // RECEITAS FINANCEIRAS
                    case RESULT->(recno()) = 13
                         nDF  := i_maismenos()        // DESPESAS FINANCEIRAS
                    case RESULT->(recno()) = 14
                         nDC  := i_maismenos()        // DESPESAS COMERCIAIS
                    case RESULT->(recno()) = 15
                         nDGA := i_maismenos()        // DESPESAS GERAIS E ADMINISTRATIVAS
                    case RESULT->(recno()) = 16
                         nRA  := i_maismenos()        // REMUNERACAO AOS ADMINISTRADORES
                    case RESULT->(recno()) = 17
                         nRAI := i_maismenos()        // RESULTADO DA AVALIACAO DE INVESTIMENTOS
                    case RESULT->(recno()) = 18
                         nOPO := i_maismenos()        // OUTRAS RECEITAS OPERACIONAIS
                    case RESULT->(recno()) = 19
                         nODO := i_maismenos()        // OUTRAS DESPESAS OPERACIONAIS
                 endcase
                 RESULT->(dbskip())
                 cCOMBINA := ""
              enddo
              nRDO := nRF + nDF + nDC + nDGA + nRA + nRAI + nOPO + nODO
         case RESULT->(recno()) = 20                  // EFEITOS INFLACIONARIOS
              do while RESULT->(recno()) < 23
                 cCOMBINA += alltrim(RESULT->Combina2)
                 do case
                    case RESULT->(recno()) = 21
                         nVCM := i_maismenos()        // VARIACOES E CORRECOES MONETARIAS
                    case RESULT->(recno()) = 22
                         nCMB := i_maismenos()        // CORRECAO MONETARIA DO BALANCO
                 endcase
                 RESULT->(dbskip())
                 cCOMBINA := ""
              enddo
              nEI := nVCM + nCMB
         case RESULT->(recno()) = 23                  // RECEITAS/DESPESAS NAO OPERACIONAIS
              do while RESULT->(recno()) < 26
                 cCOMBINA += alltrim(RESULT->Combina2)
                 do case
                    case RESULT->(recno()) = 24
                         nRNO := i_maismenos()        // RECEITAS NAO OPERACIONAIS
                    case RESULT->(recno()) = 25
                         nDNO := i_maismenos()        // DESPESAS NAO OPERACIONAIS
                 endcase
                 RESULT->(dbskip())
                 cCOMBINA := ""
              enddo
              nRDNO := nRNO + nDNO
         case RESULT->(recno()) = 26                  // PROVISOES
              do while RESULT->(recno()) <= 29
                 cCOMBINA += alltrim(RESULT->Combina2)
                 do case
                    case RESULT->(recno()) = 27
                         nPCS := abs(i_maismenos())   // PROVISAO PARA CONTRIBUICAO SOCIAL
                    case RESULT->(recno()) = 28
                         nPIR := abs(i_maismenos())   // PROVISAO PARA IMPOSTO DE RENDA
                 endcase
                 RESULT->(dbskip())
                 cCOMBINA := ""
              enddo
              nLPLIQ := nRDNO + nPCS + nPIR
         case RESULT->(recno()) = 30                  // PARTICIPACOES
              do while RESULT->(recno()) <= 30
                 cCOMBINA += alltrim(RESULT->Combina2)
                 do case
                    case RESULT->(recno()) = 30
                         nPEL := abs(i_maismenos())   // PARTICIPACOES DOS EMPREGADOS NOS LUCROS
                 endcase
                 RESULT->(dbskip())
                 cCOMBINA := ""
              enddo
              nLPE := nLPLIQ - nPEL

              RESULT->(dbskip())
      endcase

   enddo

   // PLOTA EM TELA E PEDE CONFIRMACAO DE PROVISAO PARA IR E CONT. SOCIAL ______

   qsay (09,60,transform(abs(nRB)  ,"@E 9,999,999,999.99"))
   qsay (10,41,transform(abs(nDR)  ,"@E 9,999,999,999.99"))
   nRL := nRB + nDR
   qsay (11,60,transform(abs(nRL)  ,"@E 9,999,999,999.99"))
   qsay (12,41,transform(abs(nCT)  ,"@E 9,999,999,999.99"))
   nLB := nRL + nCT
   qsay (13,60,transform(abs(nLB)  ,"@E 9,999,999,999.99"))
   qsay (14,41,transform(abs(nRDO) ,"@E 9,999,999,999.99"))
   nRAEI := nLB + nRDO
   qsay (15,60,transform(abs(nRAEI),"@E 9,999,999,999.99"))
   qsay (16,41,transform(abs(nEI)  ,"@E 9,999,999,999.99"))
   nRDEI := nRAEI + nEI
   qsay (17,60,transform(abs(nRDEI),"@E 9,999,999,999.99"))
   qsay (18,41,transform(abs(nRDNO),"@E 9,999,999,999.99"))
   nRAIR := nRDEI + nRDNO
   qsay (19,60,transform(abs(nRAIR),"@E 9,999,999,999.99"))
   qgetx(20,41,@nPCS               ,"@E 9,999,999,999.99")
   qgetx(21,41,@nPIR               ,"@E 9,999,999,999.99")
   nLPAP := nRAIR - nPCS - nPIR // lucro/prejuizo antes das participacoes
   qgetx(22,41,@nPEL               ,"@E 9,999,999,999.99")
   nLPE := nLPAP - nPEL
   nLLE := nRAIR - nPIR - nPCS - nPEL
   qsay (23,60,transform(abs(nLLE) ,"@E 9,999,999,999.99"))

   cCOMBINA := ""
   RESULTAD->(dbgotop())
   RESULTAD->(dbsetorder(1))
   do while ! RESULTAD->(eof())

      qgirabarra()
      if left(RESULTAD->Codigo,1) == "1" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nREC_OPER := nREC_OPER + i_maismenos()
      endif

      if left(RESULTAD->Codigo,1) == "2" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDEDUCOES += i_maismenos()
      endif

      if left(RESULTAD->Codigo,1) == "3" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nCUST_OPER += i_maismenos()
      endif

      if left(RESULTAD->Codigo,1) == "4" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDESP_PESS += i_maismenos()
      endif

      if left(RESULTAD->Codigo,1) == "5" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDESP_ADM += i_maismenos()
      endif

      if left(RESULTAD->Codigo,1) == "6" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDESP_GER += i_maismenos()
      endif

      if left(RESULTAD->Codigo,1) == "7" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDESP_FIN += i_maismenos()
      endif

      if left(RESULTAD->Codigo,1) == "8" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nREC_DESP += i_maismenos()
      endif

      if left(RESULTAD->Codigo,1) == "9" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nPROV_DIV += i_maismenos()
      endif

      RESULTAD->(dbskip())
      cCOMBINA := ""

   enddo
   nREC_LIQ := nREC_OPER + nDEDUCOES
   nLUC_BRUTO := nREC_LIQ + nCUST_OPER
   nLUC_LIQ  := nLUC_BRUTO + (nDESP_PESS + nDESP_ADM + nDESP_GER + nDESP_FIN)
   nRESULTADO := nLUC_LIQ + nREC_DESP
   nLUCRO := nRESULTADO + nPROV_DIV
return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_impressao
   local nCOL1 , nCOL2 , nCOL3 , nCOL4 , nCOL5 , nCOL6 , lIMP := .T.
   
   nCOL1 :=   4
   nCOL2 :=   9
   nCOL3 :=  90
   nCOL4 := 108
   nCOL5 :=  20
   nCOL6 :=  72
   
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return .F. ; endif

   @ prow(),pcol() say XCOND1

   RESULTAD->(dbgotop())
   RESULTAD->(dbsetorder(1))

   if ! qlineprn() ; return .F. ; endif

   // LOOP __________________________________________________________________
   cCOMBINA := ""
   do while ! RESULTAD->(eof()) .and. qcontprn()


      // CABECALHO SE NECESSARIO ____________________________________________

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         if XPAGINA == 0
            if nPAG <= 0
               XPAGINA := 1
            else
               XPAGINA := --nPAG
            endif
         endif

         qpageprn()

         qcabecprn(cTITULO1,132,.F.,cTITULO2)
         @ prow()+1,00 say ""

      endif

      // DADOS DE UMA LINHA _________________________________________________

      if RESULTAD->Codigo == "1  "
         @ prow()+1,03 say "RECEITAS"
      endif


      if RESULTAD->Tipo == "1"

         if RESULTAD->Codigo == "1  "
            @ prow()+1,nCOL1 say RESULTAD->Titulo
            @ prow()  ,nCOL4 say transform(abs(nREC_OPER),"@E 9,999,999,999.99")
			
         elseif RESULTAD->Codigo == "2  "
            @ prow()+1,nCOL1 say RESULTAD->Titulo
            @ prow()  ,nCOL4 say transform(abs(nDEDUCOES),"@E 9,999,999,999.99")

         elseif RESULTAD->Codigo == "3  "
            @ prow()+1,03 say "(=)RECEITA LIQUIDA.................................................................."
            @ prow()  ,nCOL4 say transform(nREC_LIQ ,"@E@) 9,999,999,999.99")
            @ prow()+1,03 say "(-)CUSTOS"
            @ prow()+1,nCOL1 say RESULTAD->Titulo

            @ prow()  ,nCOL4 say transform(abs(nCUST_OPER),"@E 9,999,999,999.99")

         elseif RESULTAD->Codigo == "4  "
            @ prow()+1,03 say "(=)LUCRO BRUTO......................................................................"
            @ prow()  ,nCOL4 say transform(nLUC_BRUTO     ,"@E@) 9,999,999,999.99")
            @ prow()+1,03 say "DESPESAS"
            @ prow()+1,nCOL1 say RESULTAD->Titulo

            @ prow()  ,nCOL4 say transform(abs(nDESP_PESS),"@E 9,999,999,999.99")

         elseif RESULTAD->Codigo == "5  "
            @ prow()+1,nCOL1 say RESULTAD->Titulo
            @ prow()  ,nCOL4 say transform(abs(nDESP_ADM),"@E 9,999,999,999.99")

         elseif RESULTAD->Codigo == "6  "
            @ prow()+1,nCOL1 say RESULTAD->Titulo
            @ prow()  ,nCOL4 say transform(abs(nDESP_GER),"@E 9,999,999,999.99")

         elseif RESULTAD->Codigo == "7  "
            @ prow()+1,nCOL1 say RESULTAD->Titulo
            @ prow()  ,nCOL4 say transform(abs(nDESP_FIN),"@E 9,999,999,999.99")

         elseif RESULTAD->Codigo == "8  "
            @ prow()+1,03 say "(=)LUCRO LIQUIDO....................................................................."
            @ prow(),nCOL4 say transform(nLUC_LIQ ,"@E@) 9,999,999,999.99")

            @ prow()+1,nCOL1 say RESULTAD->Titulo
            @ prow()  ,nCOL4 say transform(abs(nREC_DESP),"@E 9,999,999,999.99")

         elseif RESULTAD->Codigo == "9  "
            @ prow()+1,03 say "(=)RESULTADO ANTES DAS PROVISOES/DIVIDENDOS............................................"
            @ prow(),nCOL4 say transform(nRESULTADO ,"@E@) 9,999,999,999.99")
            @ prow()+1,nCOL1 say RESULTAD->Titulo
            @ prow()  ,nCOL4 say transform(abs(nPROV_DIV),"@E 9,999,999,999.99")
         endif

      else
         i_compact()

      endif


      RESULTAD->(dbskip())
      cCOMBINA := ""

   enddo

   @ prow()+1,03 say "(=) LUCRO /PREJUIZO DO EXERCICIO........................................................."
   @ prow()  ,nCOL4 say transform(nLUCRO ,"@E@) 9,999,999,999.99")

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FAZ MAIS E MENOS DAS CONTAS DO COMBINA ___________________________________

static function i_maismenos
   local zTMP := 0

   for nCONTA = 1 to len(cCOMBINA) step 7
       cSINAL := subs(cCOMBINA,nCONTA,1)
       nCTA   := subs(cCOMBINA,nCONTA+1,6)
       if PLAN->(dbseek(nCTA))
          nSALDATU := PLAN->Saldo_dre
          iif( cSINAL == "+" , zTMP += nSALDATU * -1 , zTMP -= nSALDATU * -1 )
       endif
      // if prow() > K_MAX_LIN
      //    qpageprn()
      //    qcabecprn(cTITULO1,132,.F.,cTITULO2)
      //    @ prow()+1,00 say ""
      // endif
   next

return zTMP

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DAS CONTAS E SALDOS QUANDO ANALITICA ___________________________

static function i_impctas
   local nCONT , nSALDO , cREDUZ

   for nCONT = 1 to len(alltrim(RESULTAD->Combina2)) step 7

       if prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO1,132,.F.,cTITULO2)
          @ prow()+1,00 say ""
       endif

       cREDUZ := subs(RESULTAD->Combina2,nCONT+1,6)

       if PLAN->(dbseek(cREDUZ)) .and. ( nSALDO := PLAN->Saldo_dre * -1 ) <> 0

          if right(PLAN->Codigo,5) != " "
             @ prow()+1,020 say PLAN->Descricao

//           if PLAN->Redutora == "S"
//              nSALDO := abs(nSALDO) * -1
//              @ prow(),072 say transform(nSALDO,"@E@) 9,999,999,999.99")
//           else
                @ prow(),072 say transform(abs(nSALDO),"@E 9,999,999,999.99")
//           endif

          else
             @ prow()+1,018 say PLAN->Descricao
          endif

       endif

   next

return



static function iTipo2

   if left(RESULTAD->Codigo,1) == "1"

     @ prow()+1,nCOL2 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,nCOL3 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")

    elseif left(RESULTAD->Codigo,1) == "2"
     @ prow()+1,nCOL2 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,nCOL3 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")

   elseif left(RESULTAD->Codigo,1) == "3"
     //cCOMBINA += RESULTAD->Combina2
     //@ prow()+1,9 say RESULTAD->Titulo + space(31)+ transform(abs(i_maismenos()),"@E 9,999,999,999.99")

     @ prow()+1,nCOL2 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,nCOL3 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")


   elseif left(RESULTAD->Codigo,1) == "4"
     //cCOMBINA += RESULTAD->Combina2
     //@ prow()+1,9 say RESULTAD->Titulo+ space(31)+ transform(abs(i_maismenos()),"@E 9,999,999,999.99")

     @ prow()+1,nCOL2 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,nCOL3 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")


   elseif left(RESULTAD->Codigo,1) == "5"
     @ prow()+1,nCOL2 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,nCOL3 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")

   elseif left(RESULTAD->Codigo,1) == "6"
     @ prow()+1,nCOL2 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,nCOL3 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")

   elseif left(RESULTAD->Codigo,1) == "7"
     @ prow()+1,nCOL2 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,nCOL3 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")

   elseif left(RESULTAD->Codigo,1) == "8"
     @ prow()+1,nCOL2 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,nCOL3 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")

   elseif left(RESULTAD->Codigo,1) == "9"
     @ prow()+1,nCOL2 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,nCOL3 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")
   endif




return


static function i_compact

     @ prow()+1,9 say RESULTAD->Titulo
     cCOMBINA += RESULTAD->Combina2
     @ prow()  ,90 say transform(abs(i_maismenos()),"@E 9,999,999,999.99")


return
