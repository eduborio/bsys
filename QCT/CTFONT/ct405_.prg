/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CAIXA
// OBJETIVO...: INCLUIR O DIGITO VERIFICADOR
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL 1997
// OBS........:
// ALTERACOES.:
function ct405

// INICIALIZACOES ___________________________________________________________

#include "inkey.ch"

private cCODIGO // CODIGO DA CONTA

if ! qconf("Confirma coloca‡„o de d¡gito verificador ?") ; return ; endif

// TRAVA OS ARQUIVOS ________________________________________________________

if ! LANC->(eof())
   qmensa("Existem Lan‡amentos...n„o ser  poss¡vel a renumera‡„o !","B")
   return
endif

if ! PLAN->(flock())
   qmensa("N„o foi possivel travar arquivos, tente novamente...","B")
   return
endif

// LOOP DE RENUMERACAO ______________________________________________________

PLAN->(dbsetorder(1))

do while ! PLAN->(eof())

   XNIVEL := 1

   qrsay(XNIVEL++,left(PLAN->Descricao,31))

   if len(alltrim(PLAN->Codigo)) == 11 .or. len(alltrim(PLAN->Codigo)) == 12
      cCODIGO := left(PLAN->Codigo,11) + qdigito(left(PLAN->Codigo,11)+" ")
      replace PLAN->Codigo with cCODIGO
   endif

   PLAN->(dbskip())

enddo

dbunlockall()

qwait()

return

