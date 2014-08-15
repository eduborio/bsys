function seekl_sl(cSTR,XNIVEL,cSTR2)
   static laNivel

   local nCONT   := 0
   local nLINRET := 0  //Coluna em que esta o chr255
   local nNIVEL := 0

   iif(laNIVEL == NIL,laNivel := {},)

   if len(laNivel) == 0
      for nLIN := 0 to 24
          for nCOL := 0 to 79
              if chrsc_sl(nLIN,nCOL,"S") == cSTR
                 nNIVEL++
                 aadd(laNivel,{nNIVEL,nLIN})
              endif
          next
          nCOL := 0
      next
   endif

   if len(laNivel) > 0
      for nCONT := 1 to len(laNivel)

          if laNivel[nCONT,1] == XNIVEL
             nLINRET := laNivel[nCONT,2]

          endif
      next

   endif

return nLINRET


