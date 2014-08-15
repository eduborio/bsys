
// CONTROLES DO ADMIN
// PERMISSOES DE ACESSO


function qad_perm
local sMENU := qlbloc("PW_MENUP",XDRV_SH+"QSBLOC.GLO")
private lUSER

if empty(lUSER:=qachoice(07,68,sMENU)) ; return ; endif

iif ( lUSER=="U" , lUSER := .T. , lUSER := .F. )

qad_perm2()
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PROPRIAMENTE DITA PARA CONTROLE DE PERMISSOES _____________________

static function qad_perm2

select QUSERS

if ! quse("","QPROGS",{"QPROGS"})            ; return .F. ; endif
if ! quse("","QACESS",{"QACESS1","QACESS2"}) ; return .F. ; endif

QUSERS->(OrdSetFocus(iif(lUSER,1,2)))
QACESS->(OrdSetFocus(iif(lUSER,1,2)))

if lUSER
   select QUSERS
   dbgotop()
   qview({{"subs(qdecri(Identific),11,10)/Identif."   ,1},;
          {"right(qdecri(Identific),30)/Nome Completo",0}},"C",;
          {"ypermx",NIL,NIL,NIL})
else
   select QPROGS
   dbgotop()
   qview({{"Prog"               ,1},;
          {"Descricao/Descri‡„o",0}},"C",;
          {"ypermx",NIL,NIL,NIL})
endif

QACESS->(dbclosearea())
QPROGS->(dbclosearea())

select QUSERS
set order to tag IDENTIFIC

return

/////////////////////////////////////////////////////////////////////////////
// VIEW DAS PERMISSOES DO USUARIO SELECIONADO _______________________________

function ypermx
   local cCOL1, cCOL2, cFILT
   local cREC := iif(lUSER,QUSERS->(recno()),QPROGS->(recno()))

   private cUSRNUM := QUSERS->Usrnum
   private cPROG   := QPROGS->Prog
   private cMACROLOOP := ;
       iif(lUSER,"XEMPRESA==Empresa.and.QACESS->Usrnum==cUSRNUM",;
                 "XEMPRESA==Empresa.and.QACESS->Prog==cPROG")

   qmensa("Aguarde, verificando permiss”es de acesso...")

   qsay(5,0,space(54))
   qsay(6,0,space(54))
   qsay(7,0,space(54))
   qsay(5,1,"PERMISS™ES DE ACESSO PARA:")
   qsay(6,1,iif(lUSER,ypermidt(),cPROG+"/"+QPROGS->Descricao))

   if lUSER
      QPROGS->(dbgotop())
      do while ! QPROGS->(eof())
         qgirabarra()
         if ! QACESS->(dbseek(XEMPRESA+cUSRNUM+QPROGS->Prog))
            if QACESS->(qappend())
               replace QACESS->Empresa with XEMPRESA
               replace QACESS->Usrnum  with cUSRNUM
               replace QACESS->Prog    with QPROGS->Prog
               QACESS->(qunlock())
            endif
         endif
         QPROGS->(dbskip())
      enddo
   else
      QUSERS->(dbgotop())
      do while ! QUSERS->(eof())
         qgirabarra()
         if ! QACESS->(dbseek(XEMPRESA+cPROG+QUSERS->Usrnum))
            if QACESS->(qappend())
               replace QACESS->Empresa with XEMPRESA
               replace QACESS->Usrnum  with QUSERS->Usrnum
               replace QACESS->Prog    with cPROG
               QACESS->(qunlock())
            endif
         endif
         QUSERS->(dbskip())
      enddo
   endif

   QACESS->(dbclearrel())
   if lUSER
      QACESS->(dbsetrelation("QPROGS",{||Prog},"Prog"))
      QACESS->(dbseek(XEMPRESA+cUSRNUM))
      cCOL1 := "Prog/Opc"
      cCOL2 := "left(QPROGS->Descricao,44)/Descri‡„o"
      cFILT := "XEMPRESA==Empresa .and. cUSRNUM==Usrnum"
   else
      QACESS->(dbsetrelation("QUSERS",{||Usrnum},"Usrnum"))
      QACESS->(dbseek(XEMPRESA+cPROG))
      cCOL1 := "Usrnum/Usr"
      cCOL2 := "ypermidt()/Identifica‡„o"
      cFILT := "XEMPRESA==Empresa .and. cPROG==Prog"
   endif

   QACESS->(;
   qview({{cCOL1    ,QACESS->(indexord())},;
          {cCOL2    ,0},;
          {"Acesso" ,0},;
          {"Dias"   ,0},;
          {"Horario",0}},"C",;
          {NIL,"ypx",NIL,NIL},;
          {cFILT,{||yptop()},{||ypbot()}},;
          "Acessos: X,I,A,C,E,1~7 / <H>orario <L>ibera <B>loqueia <O>utros"))

   QACESS->(dbclearrel())
   iif(lUSER,QUSERS->(dbgoto(cREC)),QPROGS->(dbgoto(cREC)))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR AO VIEW A IDENTIFICACAO DO USUARIO __________________

function ypermidt
   local cIDT := qdecri(QUSERS->Identific)
return subs(cIDT,11,10) + "/" + right(cIDT,30)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA POSICIONAR NO INICIO LOGICO DO ARQUIVO QACESS ________________

function yptop
   if lUSER
      QACESS->(dbseek(XEMPRESA+cUSRNUM))
   else
      QACESS->(dbseek(XEMPRESA+cPROG))
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA POSICIONAR NO FINAL LOGICO DO ARQUIVO QACESS _________________

function ypbot
   if lUSER
      QACESS->(qseekn(XEMPRESA+cUSRNUM))
   else
      QACESS->(qseekn(XEMPRESA+cPROG))
   endif
return

/////////////////////////////////////////////////////////////////////////////
// REALIZA A MANUTENCAO DAS INICIAIS DE ACESSO ______________________________

function ypx ( cTECLA )
   local cACESSO  := alltrim(QACESS->Acesso)
   local cDIAS    := alltrim(QACESS->Dias)
   local cHORARIO := QACESS->Horario

   cTECLA := upper(chr(cTECLA))

   if cTECLA == "O"
      ypo()
      return
   endif

   do case
      case cTECLA $ "1234567" ; cDIAS := ypermdias(cDIAS)
      case cTECLA == "H"      ; cHORARIO := yph(cHORARIO)
      case cTECLA == "X" .and. ! "X" $ cACESSO ; cACESSO += "X"
      case cTECLA == "I" .and. ! "I" $ cACESSO ; cACESSO += "I"
      case cTECLA == "A" .and. ! "A" $ cACESSO ; cACESSO += "A"
      case cTECLA == "C" .and. ! "C" $ cACESSO ; cACESSO += "C"
      case cTECLA == "E" .and. ! "E" $ cACESSO ; cACESSO += "E"
      case cTECLA == "X" .and.   "X" $ cACESSO ; cACESSO := strtran(cACESSO,"X","")
      case cTECLA == "I" .and.   "I" $ cACESSO ; cACESSO := strtran(cACESSO,"I","")
      case cTECLA == "A" .and.   "A" $ cACESSO ; cACESSO := strtran(cACESSO,"A","")
      case cTECLA == "C" .and.   "C" $ cACESSO ; cACESSO := strtran(cACESSO,"C","")
      case cTECLA == "E" .and.   "E" $ cACESSO ; cACESSO := strtran(cACESSO,"E","")
      case cTECLA == "L"
           cACESSO  := "XIACE"
           cDIAS    := "1234567"
           cHORARIO := "00~24"
      case cTECLA == "B"
           cACESSO := cDIAS := cHORARIO := ""
   endcase
   if QACESS->(qrlock())
      replace QACESS->Acesso  with cACESSO
      replace QACESS->Dias    with cDIAS
      replace QACESS->Horario with cHORARIO
      QACESS->(qunlock())
   endif
return

function ypermdias ( cDIAS )
   local nCONT, cTECLA := chr(lastkey())
   local cRETORNO := ""
   if cTECLA $ cDIAS
      cDIAS := strtran(cDIAS,cTECLA,"")
   else
      cDIAS += cTECLA
   endif
   for nCONT := 1 to 7
       if str(nCONT,1) $ cDIAS
          cRETORNO += str(nCONT,1)
       endif
   next
return cRETORNO

function yph ( cHORARIO )
   local sLINHA := qsbloc(24,00,24,79)
   qmensa("Digite o horario de acesso:")
   qgetx(24,39,@cHORARIO,"99~99")
   qrbloc(24,00,sLINHA)
return cHORARIO

/////////////////////////////////////////////////////////////////////////////
// OUTROS CONTROLES DE ACESSO MAIS SOFISTICADOS _____________________________

function ypo
   local cOPCAO, cMENU := qlbloc("PW_CFGAC",XDRV_SH+"QSBLOC.GLO")

   cOPCAO := qachoice(17,61,cMENU)

   do case
      case cOPCAO == "L" ; yptotal("L")        /// liberacao total
      case cOPCAO == "B" ; yptotal("B")        /// bloqueio total
      case cOPCAO == "A" ; ypconfig("A")       /// acesso configuracao
      case cOPCAO == "D" ; ypconfig("D")       /// dias configuracao
      case cOPCAO == "H" ; ypconfig("H")       /// horario configuracao
   endcase

return

/////////////////////////////////////////////////////////////////////////////
// ACESSO OU BLOQUEIO TOTAL _________________________________________________

function yptotal ( cOPCAO )
   local cMENSA := iif(cOPCAO=="L","libera‡„o","bloqueio")
   local cRECNO := QACESS->(recno())
   if qconf("Confirma "+cMENSA+" total ?")
      qmensa("Aguarde, realizando "+cMENSA+" total...")
      yptop()
      do while &cMACROLOOP.
         qgirabarra()
         if QACESS->(qrlock())
            if cOPCAO == "L"
               replace QACESS->Acesso  with "XIACE"
               replace QACESS->Dias    with "1234567"
               replace QACESS->Horario with "00~24"
            else
               replace QACESS->Acesso  with ""
               replace QACESS->Dias    with ""
               replace QACESS->Horario with ""
            endif
            QACESS->(qunlock())
         endif
         QACESS->(dbskip())
      enddo
   endif
   QACESS->(dbgoto(cRECNO))
return

/////////////////////////////////////////////////////////////////////////////
// CONFIGURACAO DE ACESSO, DIAS OU HORARIO __________________________________

function ypconfig ( cOPCAO )
   local cVAR, cRECNO := QACESS->(recno())
   do case
      case cOPCAO == "A"
           cVAR := QACESS->Acesso
           qmensa("Digite o tipo de acesso:")
           qgetx(24,36,@cVAR,"@!")
      case cOPCAO == "D"
           cVAR := QACESS->Dias
           qmensa("Digite os dias de acesso:")
           qgetx(24,37,@cVAR,"@9")
      case cOPCAO == "H"
           cVAR := QACESS->Horario
           qmensa("Digite o horario de acesso:")
           qgetx(24,39,@cVAR,"99~99")
   endcase
   if qconf("Confirma altera‡„o total ?")
      qmensa("Aguarde, realizando altera‡„o total...")
      yptop()
      do while &cMACROLOOP.
         qgirabarra()
         if QACESS->(qrlock())
            do case
               case cOPCAO == "A" ; replace QACESS->Acesso  with cVAR
               case cOPCAO == "D" ; replace QACESS->Dias    with cVAR
               case cOPCAO == "H" ; replace QACESS->Horario with cVAR
            endcase
            QACESS->(qunlock())
         endif
         QACESS->(dbskip())
      enddo
   endif
   QACESS->(dbgoto(cRECNO))
return

