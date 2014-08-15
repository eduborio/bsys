
function qgetx (nLIN,nCOL,zVAR,cPIC,cVALID,lWHEN,zCOLOR)
   local nSETCURSOR := setcursor(1)
   local getlist := {}
   local APoint  := {}

   XFLAG := .T.

   iif ( lWHEN == NIL , lWHEN := .T. , nil )

   if ! lWHEN ; return zVAR ; endif

   iif ( cPIC == NIL , cPIC := "@X" , nil )

   if nLIN < 0
      aPoint := seekb_sl(chr(255),XNIVEL,"S")
      nLIN := APoint[1,1]
      nCOL := APoint[1,2]
      nCOL++
   endif

   iif ( zCOLOR == NIL , zCOLOR := atcsc_sl(nLIN,nCOL) , NIL )

   iif ( cVALID == NIL , cVALID := ".T." , NIL )

   @ nLIN, nCOL get zVAR picture (cPIC) valid getval(zVAR,cVALID) color (zCOLOR)
   read

   setcursor(nSETCURSOR)

   //i_prot_adic()

return zVAR

function getval
   parameters zVAL, cVALID
   cVALID := strtran(cVALID,"@","zVAL")
return &cVALID.

