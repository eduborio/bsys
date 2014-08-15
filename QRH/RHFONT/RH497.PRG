/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONVERSAO DO CAMPO CENTRO DO FUN PARA CCUSTO DO SITUA
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: OUTUBRO DE 1998
// OBS........:
// ALTERACOES.:

#include "rh.ch"

if ! qconf("Confirma Convers„o dos campos ?")
   return
endif

SITUA->(dbsetorder(1))
SITUA->(dbgotop())

FUN->(dbsetorder(1))
FUN->(dbgotop())

do while ! SITUA->(eof())

   qgirabarra()

   FUN->(dbseek(SITUA->Matricula))

   if SITUA->(qrlock())

      replace SITUA->CCusto with FUN->Centro

   endif

   SITUA->(qunlock())

   SITUA->(dbskip())

enddo

return
