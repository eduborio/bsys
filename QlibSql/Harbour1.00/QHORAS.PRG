
function qhoracent ( cHORA )
   local nCENT, nHORA, nMINUTO, nSEGUNDO
   nHORA    := val(left(cHORA,2))
   nMINUTO  := val(subs(cHORA,4,2))
   nSEGUNDO := val(right(cHORA,2))
   nCENT := nHORA + nMINUTO/60 + nSEGUNDO/3600
return nCENT

function qcenthora ( nCENT )
   local cHORA
   cHORA := strzero(int(nCENT),2) + ":"
   nCENT := ( nCENT - int(nCENT) ) * 60
   cHORA += strzero(int(nCENT),2) + ":"
   nCENT := ( nCENT - int(nCENT) ) * 60
   cHORA += strzero(int(nCENT),2)
return cHORA

function qdifhora ( cHORAI , cHORAF )
return tstring( if( cHORAF < cHORAI, 86400, 0) + secs(cHORAF) - secs(cHORAI) )

