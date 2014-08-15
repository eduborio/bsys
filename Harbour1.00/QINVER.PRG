function qinver3(nLIN,nCOL,nQUANT)
local nCONT := 0
    
    for nCONT := 1 to nQUANT
        InvertAttr(ScreenAttr(nLIN,nCOL,1))
        nCOL++  
    next


return 