
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CAIXA
// OBJETIVO...: RENUMERACAO DE CODIGO REDUZIDO
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL 1997
// OBS........:
// ALTERACOES.:
function ct403

// INICIALIZACOES ___________________________________________________________

#include "inkey.ch"

private nREDUZIDO // INCREMENTO
private cREDUZIDO // CODIGO REDUZIDO

if ! qconf("Confirma renumeracao de c¢digo reduzido ?") ; return ; endif

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

nREDUZIDO := 1

do while ! PLAN->(eof())

   XNIVEL := 1

   qrsay(XNIVEL++,PLAN->Codigo,"@R 9.99.99.99.9999-9")
   qrsay(XNIVEL++,left(PLAN->Descricao,31))

   if len(alltrim(PLAN->Codigo)) == 12

      cREDUZIDO := strzero(nREDUZIDO,5)
      cREDUZIDO := cREDUZIDO + qdigito(cREDUZIDO)

      replace PLAN->Reduzido with cREDUZIDO

      nREDUZIDO++

   endif

   PLAN->(dbskip())

enddo

dbunlockall()

qwait()

return

