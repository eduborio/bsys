
// CONTROLES DO ADMIN
// MANUTENCAO DE USUARIOS

function qad_manu

select QUSERS

qview({{"ymanu1()/Identif."  ,1},;
       {"Usrnum/N§"          ,2},;
       {"Amb_Orig/Orig."     ,0},;
       {"Amb_Trab/Trab."     ,0},;
       {"Prog/C¢d.Prog."     ,0},;
       {"Empresa/Emp"        ,0},;
       {"Datalog/Data"       ,0},;
       {"Inicio/Inicio Ativ.",0}},"C",;
       {NIL,"ymanuw",NIL,NIL},;
       NIL,"<B>loqueio, <D>esbloqueio, <I>ncluir, <A>lterar, <E>xcluir")

return

function ymanu1
return substr(qdecri(QUSERS->Identific),11,10)

function ymanuw ( nTECLA )
   nTECLA := upper(chr(nTECLA))
   do case
      case nTECLA == "B" ; ymanub()
      case nTECLA == "D" ; ymanud()
      case nTECLA == "I" ; ymanui()
      case nTECLA == "A" ; ymanua()
      case nTECLA == "E" ; ymanue()
   endcase
return

function ymanub
   local cIDT := qdecri(QUSERS->Identific)
   qlbloc(19,00,"PW_USER",XDRV_SH+"QSBLOC.GLO")
   qsay(20,17,subs(cIDT,11,10))
   qsay(22,17,right(cIDT,30))
   if qconf("Confirma bloqueio deste usuario ?")
      if QUSERS->(qrlock())
         replace QUSERS->Prog    with "ADM"
         replace QUSERS->Empresa with ""
         replace QUSERS->Datalog with date()
         replace QUSERS->Inicio  with time()
         QUSERS->(qunlock())
      endif
   endif
return

function ymanud
   local cIDT := qdecri(QUSERS->Identific)
   qlbloc(19,00,"PW_USER",XDRV_SH+"QSBLOC.GLO")
   qsay(20,17,subs(cIDT,11,10))
   qsay(22,17,right(cIDT,30))
   if qconf("Confirma desbloqueio deste usuario ?")
      if QUSERS->(qrlock())
         replace QUSERS->Prog    with ""
         replace QUSERS->Empresa with ""
         replace QUSERS->Datalog with ctod("")
         replace QUSERS->Inicio  with ""
         QUSERS->(qunlock())
      endif
   endif
return

function ymanui
   local cIDENT  := space(10)
   local cSENHA  := space(10)
   local cNOME   := space(30)
   local cUSRNUM
   QUSERS->(dbgoto(lastrec()))
   cUSRNUM := strzero(val(QUSERS->Usrnum)+1,3)
   qlbloc(19,00,"PW_USER",XDRV_SH+"QSBLOC.GLO")
   qmensa("Entre com os dados para incluir usuario...")
   qgetx(20,17,@cIDENT,"@!","qad_chk_idt(@,0)")
   qgetx(21,17,@cSENHA,"@!","qad_chk_sen(@,0)")
   qgetx(22,17,@cNOME ,"@!","!empty(@)")
   if qconf("Confirma inclus„o deste usuario ?")
      if QUSERS->(qappend())
         replace QUSERS->Identific with qencri(cSENHA+cIDENT+cNOME)
         replace QUSERS->Usrnum    with cUSRNUM
         QUSERS->(qunlock())
      endif
   endif
return

function ymanua
   local cIDT   := qdecri(QUSERS->Identific)
   local cIDENT := substr(cIDT,11,10)
   local cSENHA := left(cIDT,10)
   local cNOME  := right(cIDT,30)
   qlbloc(19,00,"PW_USER",XDRV_SH+"QSBLOC.GLO")
   qsay(21,17,cSENHA)
   qsay(22,17,cNOME)
   qmensa("Realize as altera‡”es necessarias...")
   qgetx(20,17,@cIDENT,"@!","qad_chk_idt(@,recno())")
   qgetx(21,17,@cSENHA,"@!","qad_chk_sen(@,recno())")
   qgetx(22,17,@cNOME ,"@!","!empty(@)")
   if qconf("Confirma altera‡„o deste usuario ?")
      if QUSERS->(qrlock())
         replace QUSERS->Identific with qencri(cSENHA+cIDENT+cNOME)
         QUSERS->(qunlock())
      endif
   endif
return

function ymanue
   local cIDT := qdecri(QUSERS->Identific)
   qlbloc(19,00,"PW_USER",XDRV_SH+"QSBLOC.GLO")
   qsay(20,17,subs(cIDT,11,10))
   qsay(22,17,right(cIDT,30))
   if alert("CONFIRMA EXCLUSŽO DESTE USUARIO ?",{"NŽO","SIM"}) <> 2
      return
   endif
   if qconf("Favor reconfirmar a exclus„o deste usuario ?")
      if QUSERS->(qrlock())
         replace QUSERS->Prog with "@@@"
         QUSERS->(dbdelete())
         QUSERS->(qunlock())
      endif
   endif
return

function qad_chk_idt ( cIDENT , nRECNO )
   local nREC := recno() , nRET := .T.
   if empty(cIDENT) ; return .F. ; endif
   dbgotop()
   locate for subs(qdecri(QUSERS->Identific),11,10) == cIDENT
   if ! QUSERS->(eof()) .and. nRECNO <> QUSERS->(recno())
      qmensa("Identifica‡„o j  utilizada por outro usuario...","B")
      nRET := .F.
   endif
   QUSERS->(dbgoto(nREC))
return nRET

function qad_chk_sen ( cSENHA , nRECNO )
   local nREC := recno() , nRET := .T.
   if empty(cSENHA) ; return .F. ; endif
   dbgotop()
   locate for left(qdecri(QUSERS->Identific),10) == cSENHA
   if ! QUSERS->(eof()) .and. nRECNO <> QUSERS->(recno())
      qmensa("Senha j  utilizada por outro usuario...","B")
      nRET := .F.
   endif
   QUSERS->(dbgoto(nREC))
return nRET

