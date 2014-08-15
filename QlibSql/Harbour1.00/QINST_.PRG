
function qinstcrc
   local cSTRING := j_ret_string()
return qcrc(cSTRING)

function j_ret_string
   local nCONT, cSTRING := strzero(QINST->(recno()),4)

   for nCONT := 2 to fcount()
       if fieldname(nCONT) $ "EMPRESA_RAZAO_ENDERECO_CGCCPF" .or. "DRV_" $ fieldname(nCONT)
          cSTRING += &(fieldname(nCONT))
       endif
   next
return cSTRING






////// cTYPE := upper(valtype(&(fieldname(nCONT))))
////// do case
//////    case cTYPE == "C" ; cSTRING += &(fieldname(nCONT))
//////    case cTYPE == "D" ; cSTRING += dtoc(&(fieldname(nCONT)))
//////    case cTYPE == "N" ; cSTRING += str(&(fieldname(nCONT)))
////// endcase

