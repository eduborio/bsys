
function qtiraponto ( cSTRING )

   if valtype(cSTRING) == "D"
      cSTRING := strtran(dtoc(cSTRING),"/","")
   else
      cSTRING := strtran(cSTRING,".","")
      cSTRING := strtran(cSTRING,",","")
      cSTRING := strtran(cSTRING,";","")
      cSTRING := strtran(cSTRING,"-","")
      cSTRING := strtran(cSTRING,"/","")
      cSTRING := strtran(cSTRING,"\","")
      cSTRING := strtran(cSTRING,":","")
   endif

return cSTRING

