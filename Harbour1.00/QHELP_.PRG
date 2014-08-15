
#include "inkey.ch"

function qhelp
   local sTELA := qsbloc(5,0,24,79)
   local nLIN   := row()
   local nCOL   := col()

   set key 28 to

   do case
      case XHELP == "901"    ; i_help_bloc("H_901")
      otherwise
           if ! empty(XPROG) ; i_help_prog()
           else              ; i_help_bloc("H_INICIO") ; endif
   endcase

   setpos(nLIN,nCOL)

   qrbloc(5,0,sTELA)

   set key 28 to qhelp
return

static function i_help_bloc ( cBLOC )
   qlbloc(5,0,cBLOC,XDRV_SH+"QSBLOC.GLO")
   tone(3000,0.5) ; qwait(0)
return

static function i_help_prog
   local cALIAS := alias()
   local cCOR   := setcolor("W/N")
   local cTEXTO := ""
   local nCURSOR

   @ 05,00 clear to 23,79
   @ 05,00 TO 23,79 double

   if ! quse("","QHELP",{"QHELP"}) ; return .F. ; endif

   if ! QHELP->(dbseek(XPROG))
      if ! QHELP->(qappend())
         qmensa("Erro ao ler arquivo de help's...","B")
         return .F.
      else
         replace QHELP->Prog with XPROG
         replace QHELP->Help with qencri("HELP AINDA NAO DISPONIVEL PARA ESTA OPCAO, DESCULPE-NOS...")
         QHELP->(qunlock())
      endif
   endif

   qmensa("<ESC> retorna, <Setas,PgUp,PgDw,etc>")

   if getenv("ATUAHELP") == "S"
      cTEXTO := qdecri(QHELP->Help)
      nCURSOR := setcursor(1)
      cTEXTO := memoedit(cTEXTO,06,02,22,77,.T.)
      setcursor(nCURSOR)
      if QHELP->(qrlock())
         replace QHELP->Help with qencri(alltrim(cTEXTO))
         QHELP->(qunlock())
      endif
   else
      memoedit(qdecri(QHELP->Help),06,02,22,77,.F.)
   endif

   QHELP->(dbclosearea())
   setcolor(cCOR)
   select(cALIAS)
return

