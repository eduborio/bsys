
function qtotchr ( cCHAR , cSTRING , lCASE )
   local nCONT, nQUANT := 0
   iif ( lCASE == NIL , lCASE := .F. , NIL )
   if lCASE
      cCHAR   := upper(cCHAR)
      cSTRING := upper(cSTRING)
   endif
   for nCONT := 1 to len(cSTRING)
       iif ( substr(cSTRING,nCONT,1) == cCHAR , nQUANT++ , NIL )
   next
return nQUANT

