
function qgetprog
   local cTECLA, cPROG := ""
   local cCOR := setcolor("G+/R")

   private cPROG_VIA_MOUSE := ""


   XWAIT := .T.
   qkeyon()
   dbcloseall()
   set deleted on
   XHELP := XPROG := ""

   qmensa("")
   qsay(24,75,"(   )")
   setpos(24,76)

   qsay(1,18,XRAZAO)
   qsay(1,75,XEMPRESA)

   do while .T.

      if empty(XUSRIDT)
         qsay(24,11,"Utilize F3 para LogIn...                    ")
         qsay(03,68,"* LOGOUT *")
      else
         qsay(24,11,"Digite o numero do programa ou F4 p/ menu...")
         qsay(03,68,XUSRIDT)
      endif

      cTECLA := i_getkey()

      if len(cPROG_VIA_MOUSE) == 3
         clear typeahead
         cPROG := cPROG_VIA_MOUSE
         exit
      endif

      if cTECLA $ "0123456789" .and. len(cPROG) < 3
         cPROG += cTECLA
         ?? cTECLA
      endif

      if lastkey() == 13
         exit
      endif

      if lastkey() == 27
         cPROG := ""
         qsay(24,75,"(   )")
         setpos(24,76)
      endif

      if (lastkey() == 8 .or. lastkey() == 19) .and. len(cPROG) > 0
         cPROG := left(cPROG,len(cPROG)-1)
         qsay(24,col()-1," ")
         setpos(24,col()-1)
      endif
   enddo

   XWAIT := .F.
   qmensa("")
   //iif(XMOUSEOK,qmousecu(0),NIL)
   setcolor(cCOR)

return alltrim(cPROG)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESPERAR POR UMA TECLA E CONTROLAR TEMPO DE LOGOUT ____________

static function i_getkey
   local nTECLA, sTELA, nCURSOR, cCOR
   local lSCRSAVER := .F.
   local nINI_SS := seconds()
   local nINI_RT := seconds()
   local nLIN := row()
   local nCOL := col()

   // LOOP PARA ESPERA DE TECLA _____________________________________________

   do while .T.

      nTECLA := qinkey(.15)

      //i_check_mouse()

      setpos(nLIN,nCOL)

      if ! empty(nTECLA) ; exit ; endif

      if val(XUSRNUM) <> 0 .and. int(seconds()-nINI_SS) > XLOGOUT
         qlogout()
      endif

      // VERIFICA TEMPO DE ATIVACAO DO SCREEN SAVER _________________________

      if ! lSCRSAVER .and. int(seconds()-nINI_SS) > XSCRSAVER
         lSCRSAVER := .T.
         sTELA := qsbloc(0,0,24,79)
         nCURSOR := setcursor(0)
         cCOR := setcolor("W/N")
         clear screen
      endif
      iif ( lSCRSAVER , i_exec_scr_saver() , NIL )

      // VERIFICA TEMPO DE ATIVACAO DA INTERFACE REAL-TIME __________________

      if int(seconds()-nINI_RT) > XREALTIME
         nINI_RT := seconds()
         realtime()
      endif

   enddo

   if lSCRSAVER
      qrbloc(0,0,sTELA)
      setcursor(nCURSOR)
      setcolor(cCOR)
   endif

return chr(nTECLA)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONTROLAR O MOUSE NA TELA DE INICIO __________________________

//static function i_check_mouse
// /  local nLIN, nCOL
//
//   if XMOUSEOK
//      qmousecu(1)
//      if qmousebo() == 1
//         qmousecu(0)
//         nLIN := qmouseli()
//         nCOL := qmouseco()
//         do case
//            case nLIN >= 07 .and. nLIN <= 09
//                 do case
//                    case nCOL >= 04 .and. nCOL <= 25 ; qhelp()
//                    case nCOL >= 29 .and. nCOL <= 50 ; qselect_emp()
//                    case nCOL >= 54 .and. nCOL <= 75 ; qlogin()
//                 endcase
//            case nLIN >= 11 .and. nLIN <= 13
//                 do case
//                    case nCOL >= 04 .and. nCOL <= 25 ; qmenu()
//                    case nCOL >= 29 .and. nCOL <= 50 ; qtools()
//                    case nCOL >= 54 .and. nCOL <= 75 ; qcalc()
//                 endcase
//            case nLIN >= 15 .and. nLIN <= 17
//                 do case
//                    case nCOL >= 04 .and. nCOL <= 25 ; qagenda()
//                    case nCOL >= 29 .and. nCOL <= 50 ; qmemousr()
//                    case nCOL >= 54 .and. nCOL <= 75 ; i_view()
//                 endcase
//            case nLIN >= 19 .and. nLIN <= 21
//                 do case
//                    case nCOL >= 04 .and. nCOL <= 25 ; qquit()
//                    case nCOL >= 29 .and. nCOL <= 50 ; qshell()
//                    case nCOL >= 54 .and. nCOL <= 75 ; i_qsys()
//                 endcase
//         endcase
//         if empty(cPROG_VIA_MOUSE)
//            keyboard chr(13)
//         else
//            keyboard (cPROG_VIA_MOUSE+chr(13))
//         endif
//      endif
//   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// MOSTRA EXPLICACOES REFERENTES AO F9 ______________________________________

static function i_view
   qmensa("F9 s¢ ‚ acionado em rotinas especificas !","B")
return

/////////////////////////////////////////////////////////////////////////////
// MOSTRA INFORMACOES DA EMPRESA ____________________________________________

static function i_qsys
   local sBLOC := qsbloc(7,4,21,75)
   qlbloc(7,4,"QSYS1",XDRV_SH+"QSBLOC.GLO")
   qwait()
   qrbloc(7,4,sBLOC)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR O LOGOUT DO SISTEMA _________________________________

function qlogout
   dbcloseall()
   if quse(XDRV_SH,"QUSERS",{"QUSERS2"})
      if QUSERS->(dbseek(XUSRNUM))
         if QUSERS->(qrlock())
            replace QUSERS->Prog    with ""
            replace QUSERS->Empresa with ""
            QUSERS->(dbclosearea())
         endif
      endif
   endif
   XUSRIDT := space(10)
   XUSRNUM := "000"
   qbeep()
   keyboard chr(13)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ENCERRAR O SISTEMA ___________________________________________

function qquit
   local sBLOC := qsbloc(24,11,24,79)
   if XWAIT .and. qconf("Confirma o encerramento do Sistema ?")
      qlogout()
      setcolor("W/N")
      clear screen
//      if file("usamysql.cfg")
//         if XCONN  != NIL
//            dbMySqlClearConnection(XCONN)
//         endif
//      endif
      quit
   endif
   qrbloc(24,11,sBLOC)
return .T.

/////////////////////////////////////////////////////////////////////////////
// EXECUCAO DO SCREEN SAVER _________________________________________________

static function i_exec_scr_saver
   static nSPACE := 0, lCTRL := .T.
   static nLIN := 2, nCOL := 2
   static lLIN := .T., lCOL := .T.
   local nTECLA := qinkey(0.3)
   @ 02,00 clear to 24,79
   qsay(0,0,space(nSPACE)+"Q-SYS INFORMATICA LTDA. ")
   qsay(nLIN,nCOL,time())
   iif ( nLIN ==  2 .and. ! lLIN , lLIN := .T. , NIL )
   iif ( nLIN == 24 .and.   lLIN , lLIN := .F. , NIL )
   iif ( nCOL ==  0 .and. ! lCOL , lCOL := .T. , NIL )
   iif ( nCOL == 72 .and.   lCOL , lCOL := .F. , NIL )
   iif ( lLIN , nLIN++ , nLIN-- )
   iif ( lCOL , nCOL++ , nCOL-- )
   iif ( lCTRL , nSPACE++ , nSPACE-- )
   iif ( nSPACE == 42 .and.  lCTRL , lCTRL := .F. , NIL )
   iif ( nSPACE == 0  .and. !lCTRL , lCTRL := .T. , NIL )
   if ! empty(nTECLA) ; keyboard chr(nTECLA) ; endif
return

