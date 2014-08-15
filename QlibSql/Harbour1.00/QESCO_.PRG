
function qesco ( nLIN , nCOL , cVAR , sBLOC , nSHADOW )
   local cRET, sSALVA
   local aPoint := {}


   if empty(nSHADOW) ; nSHADOW := 0 ; endif

   XFLAG := .T.
   if nLIN < 0
      aPoint := seekb_sl(chr(255),XNIVEL,"S")
      nLIN := aPoint[1,1]
      nCOL := aPoint[1,2]
      nCOL++

      //nLIN := seekl_sl(chr(255),XNIVEL,"S")
      //nCOL := seekc_sl(chr(255),XNIVEL,"S") + 1
   endif

   sSALVA := qsbloc(nLIN,nCOL,24,79)

   if ! empty(cRET := qachoice(nLIN,nCOL,sBLOC,cVAR,nSHADOW))
      cVAR := cRET // somente atribuicao pois cVAR e' passado por ref.
   endif

   qrbloc(nLIN,nCOL,sSALVA)
return

