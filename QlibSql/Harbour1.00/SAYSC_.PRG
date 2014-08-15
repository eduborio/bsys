function saysc_sl(nLIN,nCOL,cVAR,nATRIB)
local zVAR  := ""
local zLIN,zCOL := 0
local zRET := ""
     zLIN := row()
     zCOL := col()
     zVAR := replicate(chr(ColorToN(nATRIB)),len(cVAR))
     zRET := ScreenMix(cVAR,zVAR,nLIN,nCOL)
  //   zRET := SayScreen(cVAR,nLIN,nCOL)
   //    setrc(zLIN,zCOL)
   //    setrc(zLIN,zCOL)
return zRET


