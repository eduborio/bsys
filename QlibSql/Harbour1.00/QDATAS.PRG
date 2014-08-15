
function qfimmes ( zDATA )
   local nANO, nMES
   if valtype(zDATA) == "D"
      nANO := year(zDATA)
      nMES := month(zDATA)+1
   else
      nANO := val(left(zDATA,4))
      nMES := val(right(zDATA,2)) + 1
   endif
   if nMES == 13
      nANO++ ; nMES := 1
   endif
   nANO := str(nANO,4)
   nMES := str(nMES,2)
return ctod(("01/"+nMES+"/"+nANO)) - 1

function qinimes ( zDATA )
   local nRET
   if valtype(zDATA) == "D"
      nRET := zDATA - day(zDATA) + 1
   else
      nRET := ctod("01/"+right(zDATA,2)+"/"+left(zDATA,4))
   endif
return nRET

/*
function qanomes ( zDATA )
   local cRET := ""
   cRET += right(strzero(year(zDATA),4),4)
   cRET += strzero(month(zDATA),2)
return cRET
*/

function qanomes ( dDATAINF , nQUANT )
   local cANO, cMES, nCONT

   cANO := strzero(year(dDATAINF),4)
   cMES := strzero(month(dDATAINF),2)

   if nQUANT != NIL
      for nCONT := 1 to abs(nQUANT)
          if nQUANT < 0
             cMES := strzero(val(cMES)-1,2)
             if cMES == "00"
                cMES := "12"
                cANO := strzero(val(cANO)-1,4)
             endif
          else
             cMES := strzero(val(cMES)+1,2)
             if cMES == "13"
                cMES := "01"
                cANO := strzero(val(cANO)+1,4)
             endif
          endif
      next
   endif

   cANO := right(cANO,4)

return ( cANO + cMES )

function qdataexten ( zDATA )
return strzero(day(zDATA),2) + " de " + alltrim(qnomemes(zDATA)) + " de " + strzero(year(zDATA),4)

