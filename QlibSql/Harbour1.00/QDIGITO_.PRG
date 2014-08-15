
function qdigito ( cSTRING )

  local nSOMA, nRESTO, cDIGITO, nCONT, nCTRL

  nSOMA   := 0
  nRESTO  := 0
  cDIGITO := 0
  nCTRL   := 2

  for nCONT = len(cSTRING) to 1 Step -1
    nSOMA += val(subs(cSTRING,nCONT,1)) * nCTRL

    if nCTRL = 7
       nCTRL = 1
    endif
    nCTRL++
  next


  nRESTO = nSOMA % 11


  if nRESTO = 0 .or. nRESTO = 1
     cDIGITO := 0
  else
     cDIGITO := 11 - nRESTO
  endif

return str(int(cDIGITO),1)

