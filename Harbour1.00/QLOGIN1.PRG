
function qlogin

   local cIDENTIDADE := space(10)
   local sTELA := qsbloc(0,0,24,79)
   local nROW := row()
   local nCOL := col()
   local cSENHA  := ""
   local cSENCRI := ""
   local cTECLA := ""
   local lSWAIT := XWAIT

   if ! XWAIT ; return .F. ; endif

   XWAIT := .F.

   set key -2 to

   if ! quse("","QCONFIG") ; return .F. ; endif
   if ! quse(XDRV_SH,"QUSERS",{"QUSERS1","QUSERS2"}) ; return .F. ; endif


   qsay(03,68,"Login...")
   qlbloc(04,56,"PW_IDENT",XDRV_SH+"QSBLOC.GLO")

   setpos(05,58)
   setcolor(atcsc_sl(row(),col()))
   do while .T.
      cTECLA := upper(chr(qinkey(0)))
      if lastkey() == 13 .or. lastkey() == 27 ; exit ; endif
      if (lastkey() == 8 .or. lastkey() == 19) .and. len(cSENHA) > 0
         cSENHA := left(cSENHA,len(cSENHA)-1)
         qsay(05,col()-1," ")
         setpos(05,col()-1)
      elseif len(cSENHA) < 10 .and. asc(cTECLA) > 32
         cSENHA += cTECLA
         ?? "*"
      endif
   enddo

   cSENHA := pad(cSENHA,10)

   if lastkey() == 13 .and. empty(cSENHA) .and. ! empty(XUSRIDT)
      i_logout()
   endif

   if i_e_senha_admin(cSENHA)
      qsay(03,68,"ADMIN...")
      ctrl_admin()        //   <---- no qlogin2.prg      //
   else
      i_check_user(cSENHA)
   endif

   qrbloc(0,0,sTELA)

   setpos(24,76)

   set key -2 to qlogin

   XWAIT := lSWAIT

   QCONFIG->(dbclosearea())
   QUSERS->(dbclosearea())

return .T.

/////////////////////////////////////////////////////////////////////////////
// VERIFICA SE E' SENHA DO ADMINISTRADOR ____________________________________

static function i_e_senha_admin ( cSENHA )

   if left(QCONFIG->Id_admin,1) == "D"
      if ! QCONFIG->(qrlock())
         qmensa("Erro no controle do ADMIN...","B")
         return .F.
      else
         replace QCONFIG->Id_admin with qencri("QSYS      ")
         QCONFIG->(qunlock())
      endif
   endif

   if cSENHA == qdecri(QCONFIG->Id_admin) ; return .T. ; endif
return .F.

/////////////////////////////////////////////////////////////////////////////
// CHECA SENHA DO USUARIO ___________________________________________________

static function i_check_user ( cSENHA )
//local zTMP := space(10)


   //zTMP := left(qdecri(QUSERS->Identific),10)

   //clear
   //@ 10,10 say left(QUSERS->Identific,10)
   //@ 11,10 say zTMP
   //@ 13,10 say qdecri("zTMP")
   //qinkey(0)

   locate for left(qdecri(QUSERS->Identific),10) == cSENHA
   if ! eof()
      if ! empty(QUSERS->Prog) .and. XTIPOSENHA == "T"
         qmensa("Usuario j  est  ativo em outra esta‡„o !","B")
         return .F.
      endif
      if QUSERS->(qrlock())
         replace QUSERS->Prog    with "LOG"
         replace QUSERS->Empresa with XEMPRESA
         QUSERS->(qunlock())
         zTMP := qdecri(QUSERS->Identific)

         XUSRIDT := zTMP
         XUSRIDT := substr(XUSRIDT,11,10)
         XUSRNUM := QUSERS->Usrnum
         return .T.
      endif
   endif
return .F.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR LOGOUT COMANDADO PELO USUARIO _______________________

static function i_logout
   if QUSERS->(dbseek(XUSRIDT))
      if QUSERS->(qrlock())
         replace QUSERS->Prog    with ""
         replace QUSERS->Empresa with ""
         QUSERS->(qunlock())
         XUSRIDT := space(10)
         XUSRNUM := "000"
      endif
   endif
return

