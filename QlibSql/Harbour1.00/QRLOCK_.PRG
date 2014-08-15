
function qrlock ( nRECNO )
   local nCONT

   for nCONT := 1 to XTIMER
       if empty(nRECNO)
          if dbrlock() ; return .T. ; endif
       else
          if dbrlock(nRECNO) ; return .T. ; endif
       endif
   next

return .F.

function qunlock
   dbrunlock()
   dbgoto(recno())
return .T.

