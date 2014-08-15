
function qcrc ( cSTRING )
   local nCRC := check_sl(cSTRING)
   iif(nCRC<0,nCRC:=nCRC*(-1),NIL)
   nCRC := int(qrand(nCRC)*10000000000)
return strzero(nCRC,10)

