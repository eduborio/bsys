
function qintchr ( cSTRING , cCHAR )
   local nCONT, cRET := ""

   if valtype(cCHAR) <> "C"
      cCHAR := " "
   endif

   for nCONT := 1 to len(cSTRING)
       cRET += subs(cSTRING,nCONT,1) + cCHAR
   next

return left(cRET,len(cRET)-1)

