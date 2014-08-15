/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA COMPRAS
// OBJETIVO...: MODULO PRINCIPAL DO SISTEMA
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: 23/10/96
// OBS........:
// ALTERACOES.:

// INICIALIZACAO DO SISTEMA _________________________________________________
qlbloc(0,0,"BQSYS","QBLOC.GLO")
SetColor("R*/B")
@ 24,0 say "                      Aguarde..., Inicializando Sistema!                        "
inkey(0.8)

Set Century on

qinit_sist()      // inicializacao padrao
qinit_var("CP1")  // inicializacao de variaveis
qselect_emp()     // inicializacao da primeira empresa

// LOOP DE CHAMADA DOS MODULOS DO SISTEMA ___________________________________

do while .T.
   begin sequence
      i_atua_tela()
      XPROG := qgetprog()
      qcall()
   recover
      qlogout()
   end sequence
   dbcloseall()
enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZACAO DA TELA BASE DO SISTEMA __________________________

static function i_atua_tela

   if quse(XDRV_CP,"CONFIG")
      public XPATHCONTA  := alltrim(CONFIG->Pathconta)
      public XPATHTESO   := alltrim(CONFIG->Pathteso)
      public XPATHPAG    := alltrim(CONFIG->Pathpag)
      public XPATHCOMP   := alltrim(CONFIG->Pathcomp)
      public XPATHTESO   := alltrim(CONFIG->Pathteso)
      public XPATHFISC   := alltrim(CONFIG->Pathfisc)
      CONFIG->(dbclosearea())
   endif

   qlbloc(0,0,"INICIO",XDRV_SH+"QSBLOC.GLO")

   qsay ( 01 , 18 , XRAZAO )
   qsay ( 03 , 18 , "Sistema  de  Compras")
   qsay ( 01 , 06 , date() )
   qsay ( 02 , 06 , time() )
//   qsay ( 03 , 02 , "Mˆs/Ano:")
//   qsay ( 03 , 10 , right(XANOMES,2)+"/" )
//   qsay ( 03 , 13 , left(XANOMES,2)  )

   setcursor(1)

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO Q_ONLINE __________________________________________________________

function q_online
   // online() // ver online.prg
return

/////////////////////////////////////////////////////////////////////////////
// CHAMADA DE FUNCOES APENAS PARA LINK ______________________________________

padl()
padr()
padc()

