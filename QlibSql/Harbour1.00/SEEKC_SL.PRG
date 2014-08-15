
function seekc_sl(cSTR,XNIVEL,cSTR2)
   static caNivel

   local nCONT   := 0
   local nCOLCOLRET := 0 
   local nNIVEL := 0

   iif(caNIVEL == NIL,caNivel := {},)

   if len(caNivel) == 0
      for nLIN := 0 to 24
          for nCOL := 0 to 79
              if chrsc_sl(nLIN,nCOL,"S") == cSTR
                 nNIVEL++
                 aadd(caNivel,{nNIVEL,nCOL,nLIN})
              endif
          next
          nCOL := 0
      next
   endif

   if len(caNivel) > 0
      for nCONT := 1 to len(caNivel)

          if caNivel[nCONT,1] == XNIVEL
             nCOLRET := caNivel[nCONT,2]

          endif
      next

   endif

return nLINCOLRET

//function seekb_sl(cSTR,XNIVEL,cSTR2)
//   static caNivel
//   local nCONT   := 0
//   local aLINCOLRET := {}
// /  local nNIVEL := 0
//   iif(caNIVEL == NIL,caNivel := {},)
//   if len(caNivel) == 0
//      for nLIN := 0 to 24
//          for nCOL := 0 to 79
// /             if chrsc_sl(nLIN,nCOL,"S") == cSTR
//                 nNIVEL++
//                 aadd(caNivel,{nNIVEL,nCOL,nLIN})
//              endif
//          next
//          nCOL := 0
//      next
//   endif
//   if len(caNivel) > 0
//      for nCONT := 1 to len(caNivel)
//          if caNivel[nCONT,1] == XNIVEL
//             aadd(aLINCOLRET,{caNivel[nCONT,2],caNivel[nCONT,3]})
//          endif
//      next
//   endif
//return aLINCOLRET



