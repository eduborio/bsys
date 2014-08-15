function qencri(str)
local nCONT := 0
local cRetorno := ""



   for  nCONT := 1 to len(str)

        if mod(nCONT,2) == 0
           cRetorno +=  chr(NumXor(asc(substr(str,nCont,1))+2,255))
        else
           cRetorno +=  chr(NumXor(asc(substr(str,nCont,1)),255))
        endif

   next

return cRetorno


function qdecri(str)
local nCONT := 0
local cRetorno := ""



   for  nCONT := 1 to len(str)

        if mod(nCONT,2) == 0
           cRetorno +=  chr(NumXor(asc(substr(str,nCont,1)),255)-2)
        else
           cRetorno +=  chr(NumXor(asc(substr(str,nCont,1)),255))
        endif

   next

return cRETORNO
