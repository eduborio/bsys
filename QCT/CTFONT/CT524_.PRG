/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: DIARIO AUXILIAR
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:

function ct524

#include "inkey.ch"
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1 := qlbloc("B524B","QBLOC.GLO") // bloco de opcao
private sBLOCO2 := qlbloc("B524C","QBLOC.GLO") // bloco de modelo
private aEDICAO := {}                          // vetor para os campos
private nMESINI                                // mes de inicial da faixa
private nMESFIM                                // mes final da faixa
private dINI    := dFIM := ctod("")            // datas inicial e final da faixa
private nPAG    := 0                           // pagina inicial para impressao
private cTIPOR                                 // tipo de totalizacao
private cMODELO := "1"                         // modelo do relatorio
private cTITULO                                // titulo do relatorio
private nTOT , nTOTG                           // variaveis totalizadoras
private dLANCDATA                              // data de lancamento para imp. total geral

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOR,sBLOCO1) } , "ORDEM"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cMODELO,sBLOCO2)} , "MODELO" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nMESINI,"99")   } , "MESINI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nMESFIM,"99")   } , "MESFIM" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)           } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)           } , "FIM"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nPAG,"9999")    } , "PAG"    })

do while .T.

   qlbloc(5,0,"B524A","QBLOC.GLO")
   XNIVEL  := 1
   nMESINI := 1
   nMESFIM := 12
   nPAG    := 0
   XFLAG   := .T.
   cTIPOR  := " "
   cMODELO := "1"

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      if ! XFLAG  .and. XNIVEL = 2
         qsay(12,62,space(10),NIL,103)
      endif
   enddo

   if ( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cTIPOR,"ES",{"Emitir sub-totais p/ data","Somente Totais Mensais"}))
      case cCAMPO == "MODELO"
           qrsay(XNIVEL,qabrev(cMODELO,"12",{"1 - Normal","2 - Especial"}))
      case cCAMPO == "MESINI"
           if nMESINI = 0 .OR. nMESINI > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           qrsay(XNIVEL,strzero(nMESINI,2))
           dINI := ctod("01/" + strzero(nMESINI,2) + "/" + right(CONFIG->Exercicio,4))
      case cCAMPO == "MESFIM"
           if nMESINI = 0 .OR. nMESINI > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           if nMESFIM < nMESINI
              qmensa("Mes final inferior a mes inicial !","B")
              return .F.
           endif
           qrsay(XNIVEL,strzero(nMESFIM,2))
           dFIM := qfimmes(ctod("15/" + strzero(nMESFIM,2) + "/" + right(CONFIG->Exercicio,4)))
      case cCAMPO == "dINI"
           if month(dINI) != nMESINI
              qmensa("Data inicial n„o pertence a mes inicial informado !","B")
              return .F.
           endif
      case cCAMPO == "dFIM"
           if month(dFIM) != nMESFIM
              qmensa("Data final n„o pertence a mes final informado !","B")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "DIARIO DE " + alltrim(qnomemes(nMESINI)) + " DE " + CONFIG->Exercicio
   cTITULO += " A " + alltrim(qnomemes(nMESFIM)) + " DE " + CONFIG->Exercicio
   cTITULO += "  NO PERIODO DE ( " + dtoc(dINI) + " a " + dtoc(dFIM) + " )"

   // SELECIONA ORDEM DO ARQUIVO PLAN _______________________________________

   PLAN->(dbsetorder(3)) // reduzido

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   // INICIALIZACOES DIVERSAS _______________________________________________

   private cHIST , nMESATU , aHIST := {} , nCONT
   private nTOTD := nTOTC := nTOTGD := NTOTGC := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   LANC->(dbseek(dtos(dINI),.T.))
   dDATALANC := dLANCDATA := LANC->Data_lanc
   nMESATU   := month(LANC->Data_lanc)

   // LOOP __________________________________________________________________

   do while ! LANC->(eof()) .and. LANC->Data_lanc <= dFIM .and. qcontprn()

      //qmensa("Imprimindo Lancamento: "+LANC->Num_lanc+" "+cMODELO)

      //if ! qlineprn() ; return ; endif

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
         qcabecprn(cTITULO,132,.F.)
         if cMODELO == "1"
            @ prow()+1,0 say "DIA| LANC|     DEBITO      |    CREDITO      |                HISTORICO                       |  VALOR A DEBITO  |  VALOR A CREDITO "
         elseif cMODELO == "2"
            @ prow()+1,0 say "DIA|     DEBITO      |    CREDITO      |                HISTORICO                   | ARQ.  |  VALOR A DEBITO  |  VALOR A CREDITO "
         endif
         @ prow()+1,0 say replicate("-",132)
      endif

      // DADOS DE UMA LINHA _________________________________________________

      if cMODELO == "1"    // Modelo 1 do relatorio
        @ prow()+1,001 say strzero(day(LANC->Data_lanc),2)
        @ prow()  ,004 say LANC->Num_lanc

        if ! empty(LANC->Cont_db)
           PLAN->(dbseek(LANC->Cont_db))
           @ prow()  ,010 say ct_convcod(PLAN->Codigo)
        endif

        if ! empty(LANC->Cont_cr)
           PLAN->(dbseek(LANC->Cont_cr))
           @ prow()  ,028 say ct_convcod(PLAN->Codigo)
        endif

        i_historico(aHIST)

        for nCONT = 1 to len(aHIST)
           @ prow()  ,046 say aHIST[nCONT]
           if nCONT < len(aHIST)
              @ prow()+1,0 say ""
           endif
        next

        if ! empty(LANC->Cont_db)
           @ prow()  ,93 say transform(LANC->Valor,"@E 999,999,999,999.99")
           nTOTD  += LANC->Valor
           nTOTGD += LANC->Valor
        endif

        if ! empty(LANC->Cont_cr)
           @ prow()  ,114 say transform(LANC->Valor,"@E 999,999,999,999.99")
           nTOTC  += LANC->Valor
           nTOTGC += LANC->Valor
        endif


      elseif cMODELO == "2"    // Modelo 2 do relatorio

        @ prow()+1,001 say strzero(day(LANC->Data_lanc),2)

        if ! empty(LANC->Cont_db)  // faz verificacao se existe movimento na conta
           PLAN->(dbseek(LANC->Cont_db))
           @ prow()  ,004 say ct_convcod(PLAN->Codigo)
        endif

        if ! empty(LANC->Cont_cr)  // faz verificacao se existe movimento na conta
           PLAN->(dbseek(LANC->Cont_cr))
           @ prow()  ,022 say ct_convcod(PLAN->Codigo)
        endif

        i_historico(aHIST)

        for nCONT = 1 to len(aHIST)
           @ prow()  ,040 say aHIST[nCONT]
           if nCONT < len(aHIST)
              @ prow()+1,0 say ""
           endif
        next

        @ prow(), 86 say LANC->Arq pict "9999"

        if ! empty(LANC->Cont_db)
           @ prow()  ,97  say transform(LANC->Valor,"@E 999,999,999.99")
           nTOTD  += LANC->Valor
           nTOTGD += LANC->Valor
        endif

        if ! empty(LANC->Cont_cr)
           @ prow()  ,118 say transform(LANC->Valor,"@E 999,999,999.99")
           nTOTC  += LANC->Valor
           nTOTGC += LANC->Valor
        endif

      endif


      aHIST := {}

      LANC->(dbskip())

      if LANC->Data_lanc <> dDATALANC
         if cTIPOR == "E"
            @ prow()+1,000 say repl("-",132)
            @ prow()+1,060 say "Totais do Dia " + dtoc(dDATALANC) + ":"
            @ prow()  ,097 say transform(nTOTD,"@E 999,999,999.99")
            @ prow()  ,118 say transform(nTOTC,"@E 999,999,999.99")
            @ prow()+1,000 say repl("-",132)
            nTOTD := nTOTC := 0
            dDATALANC := LANC->Data_lanc
         endif

         if month(LANC->Data_lanc) != nMESATU
            i_totmes()
            dLANCDATA := LANC->Data_lanc
            i_comppag()
            nMESATU   := month(LANC->Data_lanc)
            if nMESATU > nMESFIM
               exit
            endif
         endif
      endif

   enddo

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// COMPLETA A PAGINA COM CARACTERES "*" _____________________________________

static function i_comppag
   if prow() > 0
      nTAM := 132/(66-prow())
      cCOL := 0
      for nCONT = prow() to 62
          @ prow()+1,cCOL say repl("*",nTAM)
          cCOL += nTAM
      next
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FORMATA O HISTORICO DO LANCAMENTO PARA O RELATORIO _______________________

static function i_historico (aHIST)
   local nCONT

   cHIST := ""
   if (HIST->(dbseek(LANC->Hp1)),cHIST := rtrim(HIST->Descricao)+" ",NIL)
   if (HIST->(dbseek(LANC->Hp2)),cHIST += rtrim(HIST->Descricao)+" ",NIL)
   if (HIST->(dbseek(LANC->Hp3)),cHIST += rtrim(HIST->Descricao)+" ",NIL)
   cHIST += rtrim(LANC->Hist_comp)

   if ! empty(CONFIG->Hist_lin)
      aadd(aHIST,left(cHIST,46))
   else
        for nCONT = 1 to 400 step 46
            if empty(subs(cHIST,nCONT,46))
               exit
            endif
            aadd(aHIST,subs(cHIST,nCONT,46))
        next
   endif
return aHIST

/////////////////////////////////////////////////////////////////////////////
// IMPRIME TOTAIS MENSAIS ___________________________________________________

static function i_totmes
   if prow() > K_MAX_LIN
      qpageprn()
      qcabecprn(cTITULO,132,.F.)
      @ prow()+1,0 say "DIA| LANC|     DEBITO    |    CREDITO    |                    HISTORICO                   |   VALOR A DEBITO   |   VALOR A CREDITO  "
      @ prow()+1,0 say replicate("-",132)
   endif
   @ prow()+1,060 say "Totais Gerais de   " + rtrim(qnomemes(dLANCDATA)) + "/" + right(CONFIG->Exercicio,2) + ":"
   @ prow()  ,097 say transform(nTOTGD,"@E 999,999,999.99")
   @ prow()  ,118 say transform(nTOTGC,"@E 999,999,999.99")
   @ prow()+1,000 say repl("-",132)
   nTOTGD := NTOTGC := 0
return

