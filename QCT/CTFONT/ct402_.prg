/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CAIXA
// OBJETIVO...: RENUMERACAO DE LANCAMENTOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:
function ct402

// INICIALIZACOES ___________________________________________________________

#include "inkey.ch"

local nLANC := 0

// CONFIRMA PROPAGACAO DE SALDOS ____________________________________________

if ! qconf("Confirma renumeracao dos lan‡amentos ?") ; return ; endif

// TRAVA OS ARQUIVOS ________________________________________________________

if ! LANC->(flock()) .or. ! CONFIG->(qrlock())
   qmensa("N„o foi possivel travar arquivos, tente novamente...","B")
   return
endif

// LOOP DE RENUMERACAO ______________________________________________________

PLAN->(dbsetorder(3))

do while ! LANC->(eof())

   // ATUALIZA TELA E NUMERO DO LANCAMENTO __________________________________

   XNIVEL := 1

   qrsay(XNIVEL++,LANC->Data_lanc)

   PLAN->(dbseek(LANC->Cont_db))
   qrsay(XNIVEL++,PLAN->Reduzido,"@R 99999-9")
   qrsay(XNIVEL++,PLAN->Descricao)

   PLAN->(dbseek(LANC->Cont_cr))
   qrsay(XNIVEL++,PLAN->Reduzido,"@R 99999-9")
   qrsay(XNIVEL++,PLAN->Descricao)

   qrsay(XNIVEL++,++nLANC,"99999")

   replace LANC->Num_lanc with strzero(nLANC,5)

   LANC->(dbskip())

enddo

// ATUALIZA CONFIG __________________________________________________________

replace CONFIG->Num_lanc with nLANC

dbunlockall()

qwait()

return

