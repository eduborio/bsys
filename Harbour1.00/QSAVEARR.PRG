
static nHANDLE

function qsavearray ( aVET , cNOME )
   nHANDLE := fcreate(cNOME)
   save_array(aVET)
   fclose(nHANDLE)
return

static function save_array ( aVET )
   local nLEN, cTIPO, nCONT

   nLEN := len(aVET)
   fwrite(nHANDLE,"A"+str(nLEN,4))

   for nCONT := 1 to nLEN
       cTIPO := valtype(aVET[nCONT])
       do case
          case cTIPO == "A" ; save_array(aVET[nCONT])
          case cTIPO == "C" ; fwrite(nHANDLE,"C"+str(len(aVET[nCONT]),4)+aVET[nCONT])
          case cTIPO == "D" ; fwrite(nHANDLE,"D"+dtoc(aVET[nCONT]))
          case cTIPO == "L" ; fwrite(nHANDLE,"L"+iif(aVET[nCONT],"T","F"))
          case cTIPO == "N" ; fwrite(nHANDLE,"N"+str(len(str(aVET[nCONT])),2)+str(aVET[nCONT]))
       endcase
   next
return

