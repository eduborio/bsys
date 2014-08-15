
function qpededata ( cMENSAGEM , dDATA )
   local sBLOC := qsbloc(13,12,16,70)
   local nCURSOR := setcursor(1)
   qlbloc(13,12,"PEDEDATA",XDRV_SH+"QSBLOC.GLO")
   qsay(14,15,pad(cMENSAGEM,40,"."))
   qgetx(14,57,@dDATA,NIL,NIL,.T.)
   setcursor(nCURSOR)
   qrbloc(13,12,sBLOC)
return dDATA

