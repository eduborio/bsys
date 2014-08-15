
function qmenu

   local sBLOC  := qsbloc(05,00,24,79)
   local lSWAIT := XWAIT

   if ! XWAIT ; return .F. ; endif
   set key -3 to
   XWAIT := .F.

   if ! quse("","QPROGS",{"QPROGS"})            ; return .F. ; endif
   if ! quse("","QACESS",{"QACESS1","QACESS2"}) ; return .F. ; endif

   i_call_menu()

   QPROGS->(dbclosearea())
   QACESS->(dbclosearea())

   qrbloc(5,0,sBLOC)
   set key -3 to qmenu
   XWAIT := lSWAIT

return

/////////////////////////////////////////////////////////////////////////////
// MOSTRA O MENU PRINCIPAL NA TELA E REALIZA A ESCOLHA ______________________

static function i_call_menu
   local sMENU := qlbloc("MENUESCO",XDRV_SH+"QSBLOC.GLO")
   private cOPCAO := "1"
   private cPROGX := ""

   do while .T.
      qlbloc(5,0,"MENUPRIN",XDRV_SH+"QSBLOC.GLO")
      if empty(cOPCAO := qachoice(5,0,sMENU,cOPCAO)) ; exit ; endif
      qsay(17,13,"a op‡„o")
      qsay(19,06,"ao lado --->")
      QPROGS->(i_menu_parcial())
      if ! empty(cPROGX)
         cPROG_VIA_MOUSE := cPROGX
         keyboard cPROGX
         exit
      endif
   enddo
return .T.

/////////////////////////////////////////////////////////////////////////////
// REALIZA O MENU PARCIAL JA PRE-SELECIONADO ________________________________

static function i_menu_parcial
   local cFILTRO

   if cOPCAO <> "0"
      if ! dbseek(cOPCAO) ; return .F. ; endif
      cFILTRO := "left(Prog,1)==cOPCAO"
   else
      cFILTRO := ".T."
   endif

   qview({{"Descricao/Descri‡„o",1},;
          {"gprogperm()/Prog"   ,0}},;
          "05222379",;
          {"gprogescol",NIL,NIL,NIL},;
          {cFILTRO,{||dbseek(cOPCAO)},{||qseekn(cOPCAO)}})

return .T.

/////////////////////////////////////////////////////////////////////////////
// MOSTRA QUANDO TIVER PERMISSAO O NUMERO DA OPCAO __________________________

function gprogperm
   if XTIPOSENHA == "M" .or. QACESS->(dbseek(XEMPRESA+XUSRNUM+QPROGS->Prog))
      return "("+QPROGS->Prog+")"
   endif
return "(***)"

/////////////////////////////////////////////////////////////////////////////
// QUANDO PRESSIONAR ENTER VERIFICA SE TEM PERMISSAO E RETORNA ______________

function gprogescol
   if XTIPOSENHA <> "M" .and. ! QACESS->(dbseek(XEMPRESA+XUSRNUM+QPROGS->Prog))
      qbeep()
   else
      cPROGX := QPROGS->Prog
      return "EXIT"
   endif
return ""

