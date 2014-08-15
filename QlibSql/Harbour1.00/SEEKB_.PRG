
function seekb_sl(cSTR,XNIVEL,cSTR2)
   static caNivel
   local nCONT   := 0
   local aRET := {}
   local nNIVEL := 0
   iif(caNIVEL == NIL        ,caNivel := {},)
   if cSTR == "L"
      caNivel := {}
   else
      if len(caNivel) == 0
         for nLIN := 0 to 24
             for nCOL := 0 to 79
                 if chrsc_sl(nLIN,nCOL,"S") == cSTR
                    nNIVEL++
                    aadd(caNivel,{nNIVEL,nLIN,nCOL})
                 endif
             next
             nCOL := 0
         next
      endif
      if len(caNivel) > 0
         aadd(aRET,{caNivel[XNIVEL,2],caNivel[XNIVEL,3]})
      endif
      iif(XNIVEL >= len(caNivel),caNivel := {},)
   endif
return aRET



