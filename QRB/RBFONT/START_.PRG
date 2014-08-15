// DESCRICAO: MODULO PRINCIPAL DO SISTEMA DE CONTAS A RECEBER E PAGAR

// INICIALIZACAO DO SISTEMA _________________________________________________

function main()

REQUEST DBFCDX
RDDSETDEFAULT("DBFCDX")
DBSETDRIVER("DBFCDX")
SETMODE(25,80)

qlbloc(0,0,"BQSYS","QBLOC.GLO")
SetColor("R*/B")
@ 24,0 say "                      Aguarde..., Inicializando Sistema!                        "
inkey(0.8)

Set Century on

qinit_sist()     // inicializacao padrao
qinit_var("RB") // inicializacao de variaveis
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
//   if quse(XDRV_RB,"CONFIG")
//      CONFIG->(dbclosearea())
//   endif

   if ! quse(XDRV_RB,"CONFIG") ; return ; endif
   public XPATHCONTA  := alltrim(CONFIG->Pathconta)
   public XPATHTESO   := alltrim(CONFIG->Pathteso)
   public XPATHCT1    := alltrim(CONFIG->Pathct1)
   public XPATHREC    := alltrim(CONFIG->Pathrec)
   public XPATHFATU   := alltrim(CONFIG->Pathfatu)
   CONFIG->(dbclosearea())

   // TRAZ TELA BASICA ______________________________________________________

   qlbloc(0,0,"INICIO",XDRV_SH+"QSBLOC.GLO")

   qsay ( 01 , 18 , XRAZAO )
   qsay ( 03 , 18 , "Sistema de Controle do Contas a Receber")
   qsay ( 01 , 06 , date() )
   qsay ( 02 , 06 , time() )
   qsay ( 03 , 06 , "" )

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

