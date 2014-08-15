
function qarray
return

/*
function qsarray ( aVET , cNOME )
   local nCONT              // contador para os elementos
   local nQUANT             // numero dos elementos
   local cSTRING            // string para colocar os elementos
   local nTAMANHO           // tamanho do elemento caracter
   local cTIPO              // tipo do elemento
   nQUANT  := len(aVET)
   cSTRING := Str(nQUANT,4)      // inicia com a quant. de elem.
   for nCONT := 1 to nQUANT
       cTIPO := valtype(aVET[nCONT])   // verifica tipo do elemento
       cSTRING := cSTRING + cTIPO      // adiciona tipo na string
       do case
          case cTIPO = "C"
               // para caracter inclui tamanho + elemento caracter....
               nTAMANHO := len(aVET[nCONT])
               cSTRING  := cSTRING + str(nTAMANHO,4)
               cSTRING  := cSTRING + aVET[nCONT]
          case cTIPO = "N"
               // para numericos inclui tamanho + str(numero).........
               nTAMANHO := len(alltrim(str(aVET[nCONT])))
               cSTRING  := cSTRING + str(nTAMANHO,4)
               cSTRING  := cSTRING + alltrim(str(aVET[nCONT]))
          case cTIPO = "D"
               // para data inclui data convertida p/ caracter........
               cSTRING := cSTRING + str(8,4)
               cSTRING := cSTRING + dtoc( aVET[nCONT] )
          case cTIPO = "L"
               // para logicos inclui "T" ou "F"......................
               cSTRING = cSTRING + Str(1,4)
               cSTRING = cSTRING + if( aVET[nCONT] , "T" , "F" )
       endcase
   next
   memowrit(cNOME,cSTRING)   // grava string...
return .T.

function qrarray ( aVET , cNOME )
   local nCONT                // contador para os elementos
   local cSTRING              // string lida do arquivo .MEM
   local nQUANT               // numero de elementos
   local nTAMANHO             // tamanho do elemento
   local cTIPO                // tipo do elemento
   local nINDICE              // nINDICE para encontrar os elem.
   cSTRING := memoread(cNOME)
   nQUANT  := val(left(cSTRING,4))     // quant. de elementos
   nINDICE := 5    // nINDICE comeca apos quantidade de elementos
   for nCONT := 1 to nQUANT
       cTIPO := substr(cSTRING,nINDICE,1)         // tipo do elemento
       nINDICE++                                  // pula 1 = tipo
       nTAMANHO := val(substr(cSTRING,nINDICE,4)) // tam. do elem.
       nINDICE += 4                               // pula 4 = tamanho
       do case
          case cTIPO = "C"
               aadd(aVET,substr(cSTRING,nINDICE,nTAMANHO))
          case cTIPO = "N"
               aadd(aVET,val(substr(cSTRING,nINDICE,nTAMANHO)))
          case cTIPO = "L"
               aadd(aVET,iif(substr(cSTRING,nINDICE,nTAMANHO)=="T",.T.,.F.))
          case cTIPO ="D"
               aadd(aVET,ctod(substr(cSTRING,nINDICE,nTAMANHO)))
       endcase
       nINDICE += nTAMANHO          // pula tamanho para indicar
   next                             // proximo elemento...
return .T.
*/

