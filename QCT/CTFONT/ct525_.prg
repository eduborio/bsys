/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: CONFERENCIA DE LANCAMENTOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 1995
// OBS........:
// ALTERACOES.:
function ct525

#include "inkey.ch"
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cTIPOR) .or. lastkey() = 27}

private sBLOCO1 := qlbloc("B524B","QBLOC.GLO") // bloco de opcao
private aEDICAO := {}                          // vetor para os campos
private cHIST                                  // historico
private cTIPOR                                 // tipo de totalizacao
private cTITULO                                // titulo do relatorio
private dINI    := dFIM := CTOD("")            // datas inicio e final

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOR,sBLOCO1) } , "ORDEM" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)           } , "INI"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)           } , "FIM"   })

do while .T.

   qlbloc(5,0,"B525A","QBLOC.GLO")
   XNIVEL  := 1
   XFLAG   := .T.
   cTIPOR  := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cTIPOR,"ES",{"Emitir sub-totais p/ data","Somente Total Geral"}))
      case cCAMPO == "INI"
           if empty(dINI)
              return .F.
           endif
           dFIM := dINI
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "CONFERENCIA DE LANCAMENTOS    "
   cTITULO += "( Periodo: " + dtoc(dINI) + " a " + dtoc(dFIM) + " )"

   // SELECIONA ORDEM DO ARQUIVO PLAN _______________________________________

   PLAN->(dbsetorder(03)) // reduzido

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   // INICIALIZACOES DIVERSAS _______________________________________________

   local dDATALANC
   private nTOTSUB := nTOTGER := 0.00

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   LANC->(dbseek(dINI,.T.))
   dDATALANC := LANC->Data_lanc

   // LOOP __________________________________________________________________

   do while ! LANC->(eof()) .and. LANC->Data_lanc <= dFIM .and. qcontprn()

      qmensa("Imprimindo Lancamento: "+LANC->Num_lanc)

      if ! qlineprn() ; return ; endif

      // CABECALHO SE NECESSARIO ____________________________________________

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,132)
         @ prow()+1,0 say "  Data        Ct.Db.    Descricao da Conta Deb.                    Documento          Valor"
         @ prow()+1,0 say "  Lanc        Ct.Cr.    Descricao da Conta Cred.                   Historico"
         @ prow()+1,0 say replicate("-",132)
      endif

      // DADOS DE UMA LINHA _________________________________________________

      @ prow()+1,1      say dtoc(LANC->Data_lanc)
      PLAN->(dbseek(LANC->Cont_db))
      @ prow(),pcol()+3 say ct_convcod(LANC->Cont_db) + "   " + iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(38))
      @ prow(),pcol()+3 say LANC->Num_doc + "     " + transform(LANC->Valor,"@E 9,999,999,999.99")
      PLAN->(dbseek(LANC->Cont_cr))
      @ prow()+1,2     say LANC->Num_lanc + "       " + ct_convcod(LANC->Cont_cr) + "   " + iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(38)) + "   " + i_historico()

      nTOTSUB += LANC->Valor
      nTOTGER += LANC->Valor

      LANC->(dbskip())

      if LANC->data_lanc != dDATALANC .and. cTIPOR == "E"
         @ prow()+2,58       say "Total do Dia:     "
         @ prow()  ,pcol()+2 say transform(nTOTSUB,"@E 9,999,999,999.99")
         @ prow()+1,pcol()   say ""
         dDATALANC := LANC->Data_lanc
         nTOTSUB := 0.00
      endif
   enddo

   @ prow()+2,57     say "Total do Periodo: "
   @ prow()  ,pcol() say transform(nTOTGER,"@E 999,999,999,999.99")

   // FINALIZA ______________________________________________________________

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FORMATA O HISTORICO DO LANCAMENTO PARA O RELATORIO _______________________

static function i_historico
   cHIST := ""
   if (HIST->(dbseek(LANC->Hp1)),cHIST := rtrim(HIST->Descricao),NIL)
   if (HIST->(dbseek(LANC->Hp2)),cHIST += rtrim(HIST->Descricao),NIL)
   if (HIST->(dbseek(LANC->Hp3)),cHIST += rtrim(HIST->Descricao),NIL)
   cHIST += rtrim(LANC->Hist_comp)
return left(cHIST,65)

