
function qshell
local sTELA   := qsbloc(0,0,24,79)
local nCURSOR := setcursor(1)
local cCOLOR  := setcolor("W/N")

clear screen

@ 2,0 say "<DOS-SHELL>   digite <EXIT> p/ retornar ao sistema..."
@ 4,0 say ""

run command.com

qrbloc(0,0,sTELA)
setcursor(nCURSOR)
setcolor(cCOLOR)

return

