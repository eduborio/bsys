function qinver(nLIN,nCOL,nQUANT)
local nCONT := 0
    
  //ScreenStr(nLIN,nCOL,nQUANT)
  ColorWin(nLIN,nCOL,nLIN,nCOL+nQUANT-1,InvertAttr(Screenattr(nLIN,nCOL)))



return 
