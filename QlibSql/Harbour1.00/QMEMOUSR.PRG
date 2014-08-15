function qmemousr
#include "inkey.ch"

local sBLOC, cCOR, nCURSOR, cALIAS := alias()

if XUSRNUM == "000"
   qmensa("N„o h  usuario ativo !","B")
   return
endif

if ! quse(XDRV_SH,"QUSERS",{"QUSERS2"}) ; return ; endif

if ! QUSERS->(dbseek(XUSRNUM))
   qmensa("Utilize F5 e reindexe os arquivos de controle...")
   return
endif

nCURSOR := setcursor(1)
cCOR := setcolor("W+/BG")
sBLOC := qsbloc(05,00,24,79)
set key -7 to
i_aciona_edicao()
QUSERS->(dbclosearea())
qrbloc(05,00,sBLOC)
setcolor(cCOR)
setcursor(nCURSOR)
set key -7 to qmemousr
if ! empty(cALIAS)
   select (cALIAS)
endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EDITAR AS ANOTACOES __________________________________________

static function i_aciona_edicao
   local cNOTAS := QUSERS->Memo
   qlbloc(6,3,"MEMOUSR",XDRV_SH+"QSBLOC.GLO",1)
   qmensa(alltrim(XUSRIDT)+", escreva suas anota‡”es ! CTRL-W p/ gravar ou <ESC> p/ cancelar...")
   cNOTAS := memoedit(cNOTAS,07,05,17,65)
   if lastkey() == K_CTRL_W
      if QUSERS->(qrlock())
         replace QUSERS->Memo with cNOTAS
         QUSERS->(qunlock())
      else
         qm2()
      endif
   endif
return

