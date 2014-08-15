
// CONTROLES DO ADMIN
// CONFIGURACAO DE USO

function qad_conf
local sBLOC1 := qlbloc("TIPOSENH",XDRV_SH+"QSBLOC.GLO")
local sSAVE := qsbloc(9,0,23,46)

qlbloc(9,0,"PARMTEC",XDRV_SH+"QSBLOC.GLO")

QCONFIG->(qpublicfields())
QCONFIG->(qcopyfields())

fUSA_MOUSE := iif(fUSA_MOUSE,"S","N")
fTIPOSENHA := right(qdecri(fTIPOSENHA),1)

qsay(13,34,qabrev(fUSA_MOUSE,"SN",{"SIM","NAO"}))
qsay(14,34,qabrev(fTIPOSENHA,"TRM",{"TOTAL","REGULAR","MINIMO"}))
qsay(16,41,fLOGOUT   ,"999")
qsay(17,41,fSCRSAVER ,"999")
qsay(18,41,fREALTIME ,"999")
qsay(19,41,fREFRESH  ,"99")
qsay(21,41,fFATOR_NET,"9")

qesco(13,34,@fUSA_MOUSE,XSN)
qsay(13,34,qabrev(fUSA_MOUSE,"SN",{"SIM","NAO"}))
qesco(14,34,@fTIPOSENHA,sBLOC1)
qsay(14,34,qabrev(fTIPOSENHA,"TRM",{"TOTAL","REGULAR","MINIMO"}))
qgetx(16,41,@fLOGOUT   ,"999")
qgetx(17,41,@fSCRSAVER ,"999")
qgetx(18,41,@fREALTIME ,"999")
qgetx(19,41,@fREFRESH  ,"99")
qgetx(21,41,@fFATOR_NET,"9")

if qconf("Confirma as altera‡”es ?")
   if ! QCONFIG->(qrlock())
      qm2()
   else
      XLOGOUT    := fLOGOUT
      XSCRSAVER  := fSCRSAVER
      XREALTIME  := fREALTIME
      XREFRESH   := fREFRESH
      XTIPOSENHA := fTIPOSENHA
      fTIPOSENHA := qencri(left(time(),2) + fTIPOSENHA)
      fUSA_MOUSE  := iif(fUSA_MOUSE=="S",.T.,.F.)
      QCONFIG->(qreplacefields())
      QCONFIG->(qunlock())
   endif
endif

QCONFIG->(qreleasefields())

qrbloc(9,0,sSAVE)

return

