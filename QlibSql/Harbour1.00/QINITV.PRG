

// INICIALIZAO DE VARIAVEIS PUBLICAS DE USO GERAL ___________________________

#include "inkey.ch"

function qinit_var ( cSIGLA )

   local lUSA_MOUSE
   local RDD := "DBFCDX"

   // DECLARACAO DAS VARIAVEIS PUBLICAS _____________________________________

   public XSIGLA := cSIGLA    // sigla do sistema
   public XPROG  := ""        // numero do programa selecionado
   public XWAIT  := .T.       // estado de espera, fora de qualquer programa
   public XTIMEU              // tentativas para quse()
   public XTIMER              // tentativas para qrlock()
   public XTIMEF              // tentativas para qflock()
   public XTIMEA              // tentativas para qappend()
   public XDATASYS := date()  // data em que o sistema se encontra
   public XDATA_ATUAL         // ultima data de movimentacao
   public XANOMES             // ano/mes do sistema
   public XVIEWCOLOR          // cor padrao para o view
   public XPASSWORD := .F.    // para passar sem senha...
   public XNIVEL              // nivel de edicao e controle dos caracteres 255
   public XFLAG               // flag de direcao (descida ou subida)
   public XREFRESH            // refresh para o view
   public XUSRIDT := ""       // identificacao do usuario
   public XUSRNUM := "000"    // numeracao do usuario
   public XUSRA := ""         // codigos de acesso do usuario
   public XUSRD := ""         // dias de acesso
   public XUSRH := ""         // horario de acesso
   public XMOUSEOK := .F.     // flag indicativo do mouse instalado
   public XSN                 // bloco screen lib com SIM/NAO
   public XHELP := ""         // indica ponto em que se encontra p/ ctrl.help
   public XSISTEMA            // nome do sistema, executavel e diretorio
   public XDRV_SY             // path para a base do sistema
   public XDRV_SH             // path para diretorio qsh
   public XLOGOUT             // tempo de logout
   public XSCRSAVER           // tempo de ativacao do screen saver
   public XTIPOSENHA          // tipo de senha utilizada
   public XCOD_PRN            // configuracao de impressora
   public XREALTIME           // tempo de ativacao da interface real-time
   public XCOR_MENSA := 74    // cor para as mensagens da linha 24
   public XADMIN
   public XSERVER
   public XUSERSQL
   public XPW
   public XCONN := NIL

   if val(getenv("COR_MENSA")) <> 0 ; XCOR_MENSA := val(getenv("COR_MENSA")) ; endif

   // INICIALIZACAO DO ARQUIVO DE CONFIGURACAO ______________________________

   if ! quse("","QCONFIG") ; quit ; endif

   XSISTEMA   := alltrim(QCONFIG->Sistema)
   XDRV_SH    := alltrim(QCONFIG->Drv_sh)
   XLOGOUT    := QCONFIG->Logout
   XSCRSAVER  := QCONFIG->Scrsaver
   XTIPOSENHA := right(qdecri(QCONFIG->Tiposenha),1)
   XCOD_PRN   := QCONFIG->Cod_prn
   XREFRESH   := QCONFIG->Refresh
   XVIEWCOLOR := QCONFIG->Viewcolor
   XREALTIME  := QCONFIG->Realtime
   XADMIN     := QCONFIG->Id_Admin
   lUSA_MOUSE := QCONFIG->Usa_mouse
   XSERVER    := alltrim(QCONFIG->server)
   XUSERSQL   := alltrim(QCONFIG->usersql)
   XPW        := alltrim(QCONFIG->Pw)

   XTIMEU     := 2 * QCONFIG->Fator_net
   XTIMER     := 7 * QCONFIG->Fator_net
   XTIMEF     := 5 * QCONFIG->Fator_net
   XTIMEA     := 9 * QCONFIG->Fator_net

   i_aciona_macros()

   QCONFIG->(dbclosearea())

   // SE VARIAVEL DE AMBIENTE "QPRN" ENTAO ATUALIZA XCOD_PRN ________________

   if val(getenv("QPRN")) <> 0
      XCOD_PRN := strzero(val(getenv("QPRN")),2)
   endif

   // VERIFICA INTEGRIDADE NO DIRETORIO SHARE _______________________________

   i_chk_file(XDRV_SH+"QUSERS.DBF")
   i_chk_file(XDRV_SH+"QUSERS.DBT")
   i_chk_file(XDRV_SH+"QINST.DBF")
   i_chk_file(XDRV_SH+"QSBLOC.GLO")

   // VERIFICA INDICES OBRIGATORIOS DO DIRETORIO SHARE ______________________

   if RDD == "SIXCDX" .or. RDD == "DBFCDX"

      if ! file(XDRV_SH+"QUSERS.CDX") .or. ;
         ! file(XDRV_SH+"QINST.CDX")  .or. ;
         ! file("QLOGIN.CDX")  .or. ;
         ! file("QACESS.CDX")  .or. ;
         ! file("QPROGS.CDX") .or. ;
         ! file("QHELP.CDX")
         qindexcontrol()
      endif

   endif

   if RDD == "SIXNSX"

      if ! file(XDRV_SH+"QUSERS.NSX") .or. ;
         ! file(XDRV_SH+"QINST.NSX")
         qindexcontrol()
      endif

   endif


   if RDD == "SIXNTX" .or. RDD == "DBFNTX" .or. RDD == "SDF"

      if ! file(XDRV_SH+"QUSERS1.NTX") .or. ;
         ! file(XDRV_SH+"QUSERS2.NTX") .or. ;
         ! file(XDRV_SH+"QINST1.NTX")  .or. ;
         ! file(XDRV_SH+"QINST2.NTX")

         qindexcontrol()
      endif

   endif


   // VERIFICA O DESBLOQUEIO DAS SENHAS _____________________________________

   if chr(255) $ getenv("QPASSWORD") ; XPASSWORD := .T. ; endif


   // VERIFICA EXISTENCIA DO MOUSE __________________________________________

   //if qmouseok() .and. lUSA_MOUSE ; XMOUSEOK := .T. ; endif

   // INICIALIZA BLOCO SIM/NAO ______________________________________________

   XSN := qlbloc("SIMNAO",XDRV_SH+"QSBLOC.GLO")

   // VERIFICA SE ESTA EM DIA PAGAMENTO

   //i_vencido()

return


function i_aciona_macros

   if empty(QCONFIG->Macro1)
      release XMACRO1
      set key K_ALT_F1 to
   else
      public XMACRO1 := alltrim(QCONFIG->Macro1)
      set key K_ALT_F1 to f_macro1
   endif

   if empty(QCONFIG->Macro2)
      release XMACRO2
      set key K_ALT_F2 to
   else
      public XMACRO2 := alltrim(QCONFIG->Macro2)
      set key K_ALT_F2 to f_macro2
   endif

   if empty(QCONFIG->Macro3)
      release XMACRO3
      set key K_ALT_F3 to
   else
      public XMACRO3 := alltrim(QCONFIG->Macro3)
      set key K_ALT_F3 to f_macro3
   endif

   if empty(QCONFIG->Macro4)
      release XMACRO4
      set key K_ALT_F4 to
   else
      public XMACRO4 := alltrim(QCONFIG->Macro4)
      set key K_ALT_F4 to f_macro4
   endif

   if empty(QCONFIG->Macro5)
      release XMACRO5
      set key K_ALT_F5 to
   else
      public XMACRO5 := alltrim(QCONFIG->Macro5)
      set key K_ALT_F5 to f_macro5
   endif

   if empty(QCONFIG->Macro6)
      release XMACRO6
      set key K_ALT_F6 to
   else
      public XMACRO6 := alltrim(QCONFIG->Macro6)
      set key K_ALT_F6 to f_macro6
   endif

   if empty(QCONFIG->Macro7)
      release XMACRO7
      set key K_ALT_F7 to
   else
      public XMACRO7 := alltrim(QCONFIG->Macro7)
      set key K_ALT_F7 to f_macro7
   endif

return


function f_macro1 ; keyboard XMACRO1 ; return

function f_macro2 ; keyboard XMACRO2 ; return

function f_macro3 ; keyboard XMACRO3 ; return

function f_macro4 ; keyboard XMACRO4 ; return

function f_macro5 ; keyboard XMACRO5 ; return

function f_macro6 ; keyboard XMACRO6 ; return

function f_macro7 ; keyboard XMACRO7 ; return




/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// CHAMADAS DE VENCIMENTO EM 60 DIAS DE USO  ________________________________________________

static Function i_vencido
   local cSENHA
   local cSENHA_ATUAL
   local dDATA_COMP
   local dDATA_GRAVA
   local cSOMA_MESANO
   local cMES1
   local cMES2
   local cDIA1
   local cDIA2
   local cNOVE_DIA
   local cNOVE_MES

   if ! file("\QSYS_G\ROCKO.000")
      dDATA_INI:= dtoc(date())
      Save to \QSYS_G\ROCKO.000 all like dDATA_INI
   else
      private dDATA_INI
      Restore from \QSYS_G\ROCKO.000 additive
   endif

   if ! file("\QSYS_G\TORKSYS.001")
      cTRAVA := "0"
      Save to \QSYS_G\TORKSYS.001 all like cTRAVA
   else
      private cTRAVA
      Restore from \QSYS_G\TORKSYS.001 additive
   endif

   dDATA_GRAVA  := ctod(dDATA_INI)
   dDATA_COMP   := ctod(dDATA_INI) + 60


   cSOMA_MESDIA := Strzero(Month(date())+Day(Date()),2)
   cMES1 := Left(Strzero(Month(date()),2),1)
   cMES2 := Right(Strzero(Month(date()),2),1)
   cDIA1 := Left(Strzero(Day(date()),2),1)
   cDIA2 := Right(Strzero(Day(date()),2),1)
   cNOVE_DIA    := strzero(9 - val(cDIA2),1)
   cNOVE_MES    := strzero(9 - val(cMES2),1)

   cSENHA_ATUAL := cSOMA_MESDIA + cMES1 + cNOVE_DIA + cMES2 + cDIA1 + cNOVE_MES + cDIA2

   if dDATA_COMP < date() .or. cTRAVA == "1"

     qlbloc(5,5,"BALERTAR","\QSYS_G\QSHARE\QSBLOC.GLO",1)
     cTRAVA := "1"
     Save to \QSYS_G\TORKSYS.001 all like cTRAVA

     if cTRAVA == "1"
        if (date() - dDATA_GRAVA) < 60
           Qmensa("Data invalida,Verifique em Configurac-Painel de Controle-Data/Hora !","B")
           Qmensa("Data invalida,Verifique em Configurac-Painel de Controle-Data/Hora !","B")
           Qmensa("Data invalida,Verifique em Configurac-Painel de Controle-Data/Hora !","B")
           qinkey(0.5)
           Qmensa(" ","B")
           Setcolor("W/N")
           clear
           quit

        endif
     endif

     do while .t.
        cSENHA:= space(8)
        @ 18,46 get cSENHA  pict "99999999" valid cSENHA <> space(8)
        read

        if lastkey() == 27 ; Setcolor("W/N"); clear; quit; endif

        if cSENHA_ATUAL <> cSENHA
           qmensa("Entre em contato com a Q-SYS !","B")
           qmensa("")
           loop
        else
           cTRAVA := "0"
           Save to \QSYS_G\TORKSYS.001 all like cTRAVA

           qmensa("Senha aceita com sucesso,  Obrigado!","B")
           dDATA_INI:= dtoc(date())
           Save to \QSYS_G\ROCKO.000 all like dDATA_INI
           exit
        Endif
     enddo
   endif
return .T.

