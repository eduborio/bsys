
// CONTROLES DO ADMIN
// ALTERA SENHA DO ADMINISTRADOR

function qad_senh
local sBLOC := qsbloc(11,33,14,79)
local cMACRO, cTECLA, cIDT
private cSENHA1 := cSENHA2 := cSENHA3 := ""

qlbloc(11,33,"PW_ADMIN",XDRV_SH+"QSBLOC.GLO")

// SOLICITA NOVA SENHA 3 VEZES ______________________________________________

for nCONT := 1 to 3
   cMACRO := "cSENHA" + str(nCONT,1)
   setpos(13,iif(nCONT==1,38,iif(nCONT==2,51,64)))
   setcolor(atcsc_sl(row(),col()))
   do while .T.
      cTECLA := upper(chr(qinkey(0)))
      if lastkey() == 13 .or. lastkey() == 27 ; exit ; endif
      if (lastkey() == 8 .or. lastkey() == 19) .and. len(&cMACRO.) > 0
         &cMACRO. := left(&cMACRO.,len(&cMACRO)-1)
         qsay(13,col()-1," ")
         setpos(13,col()-1)
      elseif len(&cMACRO.) < 10 .and. asc(cTECLA) > 32
         &cMACRO. += cTECLA
         ?? "*"
      endif
   enddo
   &cMACRO. := pad(&cMACRO.,10)
   if empty(&cMACRO.)
      qrbloc(11,33,sBLOC)
      return .F.
   endif
next

// VERIFICA SE SENHA ENTRADA CORRETAMENTE ___________________________________

if cSENHA1 <> cSENHA2 .or. cSENHA1 <> cSENHA3
   qmensa("Digita‡„o errada, altera‡„o n„o sera efetuada...","B")
   qrbloc(11,33,sBLOC)
   return .F.
endif

// AQUI REALIZA A ALTERACAO DA SENHA DO ADMINISTRADOR _______________________

if ! QCONFIG->(qrlock())
   qmensa("N„o foi possivel travar arquivo, altera‡„o cancelada...","B")
else
   replace QCONFIG->Id_admin with qencri(cSENHA1)
   QUSERS->(qunlock())
   qmensa("ALTERA€ŽO EFETUADA !!!","B")
endif
qrbloc(11,33,sBLOC)

return .T.

