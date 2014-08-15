function qmdir(cPATH)
local lCriado := .F.
  if DirMake(cPath) == 0
     lCriado := .T.
  else
     lCriado := .F.
  endif
return lCriado

function qcdir(cPATH)
local lOK := .F.
  if DirChange(cPath) == 0
     lOK := .T.
  else
     lOK := .F.
  endif
return lOK

function qrdir(cPATH)
local lOK := .F.
  if DirRemove(cPath) == 0
     lOK := .T.
  else
     lOK := .F.
  endif
return lOK




