
function qflock
   local nCONT

   for nCONT := 1 to XTIMEF
       if flock() ; return .T. ; endif
   next

return .F.

