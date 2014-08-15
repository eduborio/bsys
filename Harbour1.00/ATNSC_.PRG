function atnsc_sl(nLIN,nCOL)
//local zLIN,zCOL := 0
local zRET := ""
local nCOR := 0
//     zLIN := row()
//     zCOL := col()
     nCOR := ScreenAttr(nLIN,nCOL)
//     setrc(zLIN,zCOL)

     zRET := nToColor(nCOR)

return  zRET
