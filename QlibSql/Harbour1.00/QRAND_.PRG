
function qrand ( nINIC )
   static nSEED
   static lFIRST := .T.
   iif ( empty(nINIC) , nINIC := 0 , NIL )
   iif ( nINIC <> 0 , lFIRST := .T. , NIL )
   if lFIRST
      nSEED := nINIC
      lFIRST := .F.
   endif
   nSEED := ( ( nSEED * 125 ) % 2796203 ) / 2796203
return nSEED

