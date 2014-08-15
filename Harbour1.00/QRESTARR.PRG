
static nHANDLE

function qrestarray ( cNOME )
   local aVET
   nHANDLE := fopen(cNOME)
   freadstr(nHANDLE,1)
   aVET := rest_array()
   fclose(nHANDLE)
return aVET

static function rest_array
   local nLEN, cTIPO, nCONT, aVET

   nLEN := val(freadstr(nHANDLE,4))
   aVET := array(nLEN)

   for nCONT := 1 to nLEN
       cTIPO := freadstr(nHANDLE,1)
       do case
          case cTIPO == "A" ; aVET[nCONT] := rest_array()
          case cTIPO == "D" ; aVET[nCONT] := ctod(freadstr(nHANDLE,8))
          case cTIPO == "L" ; aVET[nCONT] := freadstr(nHANDLE,1) == "T"
          case cTIPO == "C"
               nTMP := val(freadstr(nHANDLE,4))
               aVET[nCONT] := freadstr(nHANDLE,nTMP)
          case cTIPO == "N"
               nTMP := val(freadstr(nHANDLE,2))
               aVET[nCONT] := val(freadstr(nHANDLE,nTMP))
       endcase
   next
return aVET

