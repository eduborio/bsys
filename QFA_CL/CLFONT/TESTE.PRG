function main
local oServer

     oServer := TMysqlServer():New("localhost","root","borios")

     if oServer:NetErr()
        alert(oServer:Error())
     else
        alert("Successo na conex!!!")

     endif


return
