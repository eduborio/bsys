
/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXPANDIR ABREVIACOES DE ESCOLHA ______________________________

function qabrev ( cVAR , cOPCOES , aVETOR )
   local nCONT, nMAXIMO := 0
   for nCONT := 1 to len(aVETOR)
       if nMAXIMO < len(aVETOR[nCONT])
          nMAXIMO := len(aVETOR[nCONT])
       endif
   next
   for nCONT := 1 to len(aVETOR)
       aVETOR[nCONT] := left(aVETOR[nCONT]+space(nMAXIMO),nMAXIMO)
   next
   cVAR := at ( cVAR , cOPCOES )
   cVAR := iif ( cVAR == 0 , space(nMAXIMO) , aVETOR[cVAR] )
return cVAR

