
// DESCRICAO: MODULO PRINCIPAL DO SISTEMA DE FATURAMENTO USIMIX

// INICIALIZACAO DO SISTEMA _________________________________________________

//FreeTSlice()

//function main()

//REQUEST DBFCDX
//RDDSETDEFAULT("DBFCDX")

SETMODE(25,80)
qlbloc(0,0,"BQSYS","QBLOC.GLO")
SetColor("R*/B")
@ 24,0 say "                      Aguarde..., Inicializando Sistema!                        "

inkey(0.2)


Set Century on
qinit_sist()     // inicializacao padrao

qinit_var("CL") // inicializacao de variaveis

qselect_emp()    // seleciona a primeira empresa

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

   // ATUALIZA VARIAVEIS PUBLICAS EM CONFIG _________________________________

   if quse(XDRV_CL,"CONFIG")
      public XPATHCONTA := alltrim(CONFIG->Pathconta)
      public XPATHFOLHA := alltrim(CONFIG->Pathfolha)
      public XPATHTESO  := alltrim(CONFIG->Pathteso)
      public XPATHIREC  := alltrim(CONFIG->Pathirec)
      public XPATHRECEB := alltrim(CONFIG->Pathreceb)
      public XPATHFATU  := alltrim(CONFIG->Pathfatu)
      public XANOREF    := CONFIG->Ano_ref
      CONFIG->(dbclosearea())
   endif

   // TRAZ TELA BASICA ______________________________________________________

   qlbloc(0,0,"INICIO",XDRV_SH+"QSBLOC.GLO")

   qsay ( 01 , 18 , XRAZAO )
   qsay ( 03 , 18 , "Sistema de Faturamento do Com‚rcio")
   qsay ( 01 , 06 , date() )
   qsay ( 02 , 06 , time() )
   
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

