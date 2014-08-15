
function qseek ( cCHAVE , lSOFT )




return dbseek(cCHAVE,lSOFT)

function qseekn ( cCHAVE )
   dbseek(qnextchar(cCHAVE),.T.)
   dbskip(-1)
return

function qnextchar ( cSTRING )
   local cCHAR := chr(asc(right(cSTRING,1))+1)
return (left(cSTRING,len(cSTRING)-1) + cCHAR)

