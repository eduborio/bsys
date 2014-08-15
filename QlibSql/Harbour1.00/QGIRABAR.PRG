
function qgirabarra()
   static cBARRA := "/"
   do case
      case cBARRA == "/" ; cBARRA := "-"
      case cBARRA == "-" ; cBARRA := "\"
      case cBARRA == "\" ; cBARRA := "|"
      case cBARRA == "|" ; cBARRA := "/"
   endcase

   qsay(24,79,cBARRA)

return .T.

