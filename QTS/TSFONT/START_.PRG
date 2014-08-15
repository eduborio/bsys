
// DESCRICAO: MODULO PRINCIPAL DO SISTEMA DE FACTORING

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
qinit_var("TS1") // inicializacao de variaveis
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

   if ! quse(XDRV_TS,"CONFIG") ; return ; endif
   public XPATHCONTA := alltrim(CONFIG->Pathconta)
   public XPATHTESO  := alltrim(CONFIG->Pathteso)
   public XDATA

   // TRAZ TELA BASICA ______________________________________________________

   qlbloc(0,0,"INICIO",XDRV_SH+"QSBLOC.GLO")

   qsay ( 01 , 18 , XRAZAO )
   qsay ( 03 , 18 , "Sistema de Controle da Tesouraria")
   qsay ( 01 , 06 , date() )
   qsay ( 02 , 06 , time() )

   if CONFIG->Data_ant == CONFIG->Data_atual
      qsay ( 03 , 01 ,"Data:"+dtoc(CONFIG->Data_atual))
      XDATA := CONFIG->Data_atual
   else
      @ 03,01 say "Data:"
      setcolor("B*/W")
      @ 03,06 say dtoc(CONFIG->Data_ant)
      XDATA := CONFIG->Data_ant
   endif

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
