/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: BLOQUEIO DE MESES PARA LANCAMENTO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: 1994
// OBS........:
// ALTERACOES.:
function ct804

#include "inkey.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

qlbloc(5,0,"B804A","QBLOC.GLO")

private aEDICAO := {}   // vetor para os campos
private lCONF           // confirmacao
private nCONT           // contador auxiliar

// PLOTAGEM EM TELA DA CONFIGURACAO JA CADASTRADOS __________________________

XNIVEL := 1

qrsay(XNIVEL++ , qabrev(CONFIG->Trav_01,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_02,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_03,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_04,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_05,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_06,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_07,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_08,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_09,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_10,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_11,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++ , qabrev(CONFIG->Trav_12,"SN",{"Sim","N„o"}))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_01,XSN) },"TRAV_01" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_02,XSN) },"TRAV_02" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_03,XSN) },"TRAV_03" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_04,XSN) },"TRAV_04" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_05,XSN) },"TRAV_05" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_06,XSN) },"TRAV_06" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_07,XSN) },"TRAV_07" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_08,XSN) },"TRAV_08" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_09,XSN) },"TRAV_09" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_10,XSN) },"TRAV_10" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_11,XSN) },"TRAV_11" })
aadd(aEDICAO,{{ || qesco(-1,0,@fTRAV_12,XSN) },"TRAV_12" })
aadd(aEDICAO,{{ || lCONF := qconf("Confirma bloqueios/desbloqueios ?") },NIL})

do while .T.
   // PLOTAGEM EM TELA O ANO DO EXERCICIO ___________________________________

   for nCONT = 9 to 19 step 2
       qsay(nCONT,28,CONFIG->Exercicio)
       qsay(nCONT,65,CONFIG->Exercicio)
   next
   
   CONFIG->(qpublicfields())
   CONFIG->(qcopyfields())

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS DADOS ___________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock())
      CONFIG->(qreplacefields())
      CONFIG->(qunlock())
      exit
   else
      qm2()
   endif

enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "TRAV_01"
           qrsay( XNIVEL , qabrev(fTRAV_01,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_02"
           qrsay( XNIVEL , qabrev(fTRAV_02,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_03"
           qrsay( XNIVEL , qabrev(fTRAV_03,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_04"
           qrsay( XNIVEL , qabrev(fTRAV_04,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_05"
           qrsay( XNIVEL , qabrev(fTRAV_05,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_06"
           qrsay( XNIVEL , qabrev(fTRAV_06,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_07"
           qrsay( XNIVEL , qabrev(fTRAV_07,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_08"
           qrsay( XNIVEL , qabrev(fTRAV_08,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_09"
           qrsay( XNIVEL , qabrev(fTRAV_09,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_10"
           qrsay( XNIVEL , qabrev(fTRAV_10,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_11"
           qrsay( XNIVEL , qabrev(fTRAV_11,"SN",{"Sim","N„o"}))
      case cCAMPO == "TRAV_12"
           qrsay( XNIVEL , qabrev(fTRAV_12,"SN",{"Sim","N„o"}))
   endcase

return .T.

