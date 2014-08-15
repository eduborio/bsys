/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: DEMONSTRACAO DO RESULTADO DO EXERCICIO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:
function ct520

#include "inkey.ch"
#define K_MAX_LIN 52

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

   if !empty(CONFIG->Inst_S_F)
      cTITULO1 := "DEMONSTRACAO DO SUPERAVIT/DEFICIT DO EXERCICIO EM " + ;
      strzero(cDIA,2) + " DE " + ltrim(qnomemes(cMESF)) + " DE " + CONFIG->Exercicio
   else
      cTITULO1 := "DEMONSTRACAO DO RESULTADO DO EXERCICIO EM " + ;
      strzero(cDIA,2) + " DE " + ltrim(qnomemes(cMESF)) + " DE " + CONFIG->Exercicio

   endif

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

   RESULT->(dbgotop())

   // LOOP __________________________________________________________________

   do while ! RESULT->(eof()) .and. qcontprn()

      if ! qlineprn() ; return .F. ; endif

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
         qcabecprn(cTITULO1,134,.F.,cTITULO2)
         @ prow()+1,00 say ""
      endif

      // DADOS DE UMA LINHA _________________________________________________

      if RESULT->Tipo == "1"
         @ prow()+1,nCOL1 say RESULT->Titulo
      else
         @ prow()+1,nCOL2 say RESULT->Titulo
      endif

      do case
         case RESULT->(recno()) = 2
              @ prow()  ,nCOL3 say transform(abs(nRVMI),"@E 9,999,999,999.99")
         case RESULT->(recno()) = 3
              @ prow()  ,nCOL3 say transform(abs(nRVME),"@E 9,999,999,999.99")
         case RESULT->(recno()) = 4
              @ prow()  ,nCOL3 say transform(abs(nRPS) ,"@E 9,999,999,999.99")
              @ prow()  ,nCOL4 say transform(abs(nRB)  ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 6
              @ prow()  ,nCOL3 say transform(abs(nDA)  ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 7
              @ prow()  ,nCOL3 say transform(abs(nIIR) ,"@E 9,999,999,999.99")
              @ prow()  ,nCOL4 say transform(abs(nDR)  ,"@E 9,999,999,999.99")
              lIMP := .F.
              if ! empty(RESULT->Combina2)
                 i_impctas()
              endif
              @ prow()+1,010 say "(=) RECEITA LIQUIDA"
              @ prow()  ,nCOL4 say transform(nRL       ,"@E@) 9,999,999,999.99")
         case RESULT->(recno()) = 9
              @ prow()  ,nCOL3 say transform(abs(nCPV) ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 10
              @ prow()  ,nCOL3 say transform(abs(nCSP) ,"@E 9,999,999,999.99")
              @ prow()  ,nCOL4 say transform(abs(nCT)  ,"@E 9,999,999,999.99")
              lIMP := .F.
              if ! empty(RESULT->Combina2)
                 i_impctas()
              endif
              @ prow()+1,010 say "(=) LUCRO BRUTO"
              @ prow()  ,nCOL4 say transform(nLB       ,"@E@) 9,999,999,999.99")
         case RESULT->(recno()) = 12
              @ prow()  ,nCOL3 say transform(abs(nRF)  ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 13
              @ prow()  ,nCOL3 say transform(abs(nDF)  ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 14
              @ prow()  ,nCOL3 say transform(abs(nDC)  ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 15
              @ prow()  ,nCOL3 say transform(abs(nDGA) ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 16
              @ prow()  ,nCOL3 say transform(abs(nRA)  ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 17
              @ prow()  ,nCOL3 say transform(abs(nRAI) ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 18
              @ prow()  ,nCOL3 say transform(abs(nOPO) ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 19
              @ prow()  ,nCOL3 say transform(abs(nODO) ,"@E 9,999,999,999.99")
              @ prow()  ,nCOL4 say transform(abs(nRDO) ,"@E 9,999,999,999.99")
              lIMP := .F.
              if ! empty(RESULT->Combina2)
                 i_impctas()
              endif
              @ prow()+1,010 say "(=) RESULTADO OPERACIONAL ANTES DOS EFEITOS INFLACIONARIOS"
              @ prow()  ,nCOL4 say transform(nRAEI     ,"@E@) 9,999,999,999.99")
         case RESULT->(recno()) = 21
              @ prow()  ,nCOL3 say transform(abs(nVCM) ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 22
              @ prow()  ,nCOL3 say transform(abs(nCMB) ,"@E 9,999,999,999.99")
              @ prow()  ,nCOL4 say transform(abs(nEI)  ,"@E 9,999,999,999.99")
              lIMP := .F.
              if ! empty(RESULT->Combina2)
                 i_impctas()
              endif
              @ prow()+1,010 say "(=) RESULTADO OPERACIONAL APOS OS EFEITOS INFLACIONARIOS"
              @ prow()  ,nCOL4 say transform(nRDEI     ,"@E@) 9,999,999,999.99")
         case RESULT->(recno()) = 24
              @ prow()  ,nCOL3 say transform(abs(nRNO) ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 25
              @ prow()  ,nCOL3 say transform(abs(nDNO) ,"@E 9,999,999,999.99")
              @ prow()  ,nCOL4 say transform(abs(nRDNO),"@E 9,999,999,999.99")
              lIMP := .F.
              if ! empty(RESULT->Combina2)
                 i_impctas()
              endif
              if ! empty(CONFIG->Inst_S_F)
                 @ prow()+1,010 say "(=) SUPERAVIT/DEFICIT ANTES DO IMPOSTO DE RENDA"
              else
                 @ prow()+1,010 say "(=) LUCRO/PREJUIZO ANTES DO IMPOSTO DE RENDA"
              endif
              @ prow()  ,nCOL4 say transform(nRAIR     ,"@E@) 9,999,999,999.99")
         case RESULT->(recno()) = 27
              @ prow()  ,nCOL3 say transform(abs(nPCS) ,"@E 9,999,999,999.99")
         case RESULT->(recno()) = 28
              @ prow()  ,nCOL3 say transform(abs(nPIR) ,"@E 9,999,999,999.99")
              lIMP := .F.
              if ! empty(RESULT->Combina2)
                 i_impctas()
              endif
              @ prow()  ,nCOL4 say transform(nPCS+nPIR,"@E 9,999,999,999.99")

              if ! empty(CONFIG->Inst_S_F)
                 @ prow()+1,010 say "(=) SUPERAVIT/DEFICIT ANTES DAS PARTICIPACOES"
              else
                 @ prow()+1,010 say "(=) LUCRO/PREJUIZO ANTES DAS PARTICIPACOES"
              endif
              @ prow()  ,nCOL4 say transform(nLPAP     ,"@E@) 9,999,999,999.99")

         case RESULT->(recno()) = 30
              @ prow()  ,nCOL4 say transform(abs(nPEL) ,"@E 9,999,999,999.99")
              lIMP := .F.
              if ! empty(RESULT->Combina2)
                 i_impctas()
              endif

              if ! empty(CONFIG->Inst_S_F)
                 @ prow()+1,010 say "(=) SUPERAVIT/DEFICT DO EXERCICIO"
              else
                 @ prow()+1,010 say "(=) LUCRO /PREJUIZO DO EXERCICIO"
              endif

              @ prow()  ,nCOL4 say transform(nLPE      ,"@E@) 9,999,999,999.99")

      endcase

      if lIMP
         if ! empty(RESULT->Combina2)
            i_impctas()
         endif
      endif

      RESULT->(dbskip())

      lIMP := .T.

   enddo
   @ prow()+3,011 say "___________________________________                                     ____________________________________"
   @ prow()+1,015 say FILIAL->Contador
   @ prow()  ,090 say CONFIG->Diretor
   @ prow()+1,015 say FILIAL->Crc
   @ prow()  ,090 say CONFIG->Cpf_Direto

   qstopprn()

return .T.

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
       if prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO1,134,.F.,cTITULO2)
          @ prow()+1,00 say ""
       endif
   next

return zTMP

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DAS CONTAS E SALDOS QUANDO ANALITICA ___________________________

static function i_impctas
   local nCONT , nSALDO , cREDUZ

   for nCONT = 1 to len(alltrim(RESULT->Combina2)) step 7

       if prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO1,134,.F.,cTITULO2)
          @ prow()+1,00 say ""
       endif

       cREDUZ := subs(RESULT->Combina2,nCONT+1,6)

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
