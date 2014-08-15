
function qtools

local sSAVE1 := qsbloc(12,00,23,40)
local sBLOC  := qlbloc("MENUTOO2",XDRV_SH+"QSBLOC.GLO")
local nROW := row()
local nCOL := col()
local cOPCAO := "M"
local sSAVE2

if ! XWAIT ; return .F. ; endif

if empty(XUSRIDT) .and. ! XPASSWORD
   qmensa("Identifique-se primeiro ! Utilize F3 !","B")
   return .F.
endif

qkeyoff()

do while .T.
   qmensa("Escolha a Ferramenta ou <ESC> p/ cancelar...")
   qlbloc(13,00,"MENUTOO1",XDRV_SH+"QSBLOC.GLO")
   cOPCAO := qachoice(15,00,sBLOC,cOPCAO)
   if lastkey() == 27 ; exit ; endif
   sSAVE2 := qsbloc(5,0,23,79)
   do case
      case cOPCAO == "M" ; qmanutemp()
      case cOPCAO == "T" ; qmacros()
      case cOPCAO == "E" ; qconfprn()
      case cOPCAO == "B" ; qbackup()
      case cOPCAO == "L" ; qlogerro()
      case cOPCAO == "I" ; q199()
      case cOPCAO == "C" ; q198()
   endcase
   qrbloc(5,0,sSAVE2)
enddo

qrbloc(12,00,sSAVE1)

setpos(nROW,nCOL)

qkeyon()

return

