
function qappend ( lFLAG )
   local nCONT

   iif ( valtype(lFLAG) <> "L" , lFLAG := .T. , nil )

   for nCONT := 1 to XTIMEA
       dbappend(lFLAG)
       if ! neterr() ; return .T. ; endif
   next

return .F.

