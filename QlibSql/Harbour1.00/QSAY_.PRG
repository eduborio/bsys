
function qsay ( nLIN, nCOL, zVAR, cPIC, nATRIB )
   local cTYPE

   if nATRIB == NIL
      nATRIB := atnsc_sl(nLIN,nCOL)
   endif

   if ! empty(cPIC)
      if left(cPIC,1) == "N"
         cPIC := "@E " + right("999,999,999,999,999,999.99",val(subs(cPIC,2)))
      endif
      zVAR := transform(zVAR,cPIC)
   endif

   cTYPE := valtype(zVAR)

   do case
      case cTYPE == "N" ; zVAR := str(zVAR)
      case cTYPE == "D" ; zVAR := dtoc(zVAR)
   endcase

   saysc_sl(nLIN,nCOL,zVAR,nATRIB)

   //i_prot_adic()

return

function qrsay ( nPOS , zVAR , cPIC , nATRIB )
   local aPoint := {}
   local nCOL := 0
   local nLIN := 0
   aPoint := seekb_sl(chr(255),nPOS,"S")
   nLIN := aPoint[1,1]
   nCOL := aPoint[1,2]
   nCOL++
   qsay(nLIN,nCOL,zVAR,cPIC,nATRIB)
return

