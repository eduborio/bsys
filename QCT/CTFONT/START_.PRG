
// DESCRICAO: MODULO PRINCIPAL DO SISTEMA DE CONTABILIDADE

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
qinit_var("CT2") // inicializacao de variaveis
qselect_emp()    // seleciona a primeira empresa

public XCT_DEV

// LOOP DE CHAMADA DOS MODULOS DO SISTEMA ___________________________________

do while .T.
   i_atua_tela()
   begin sequence
      XPROG := qgetprog()
      qcall()
   recover
      qlogout()
   end sequence
enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZACAO DA TELA BASE DO SISTEMA __________________________

static function i_atua_tela
   
   // TRAZ TELA BASICA ______________________________________________________

   qlbloc(0,0,"INICIO",XDRV_SH+"QSBLOC.GLO")

   qsay(01,18,XRAZAO)
   qsay(03,18,"Sistema  de  Contabilidade")
   qsay(01,06,date())
   qsay(02,06,time())

   setcursor(1)

   // ATUALIZA VARIAVEIS PUBLICAS EM CONFIG _________________________________

   if quse(XDRV_CT,"CONFIG")
      if CONFIG->(eof())
         CONFIG->(qappend())
      endif
      if empty(CONFIG->Exercicio) .or. len(alltrim(CONFIG->Exercicio)) < 4
        alert("O sistema esta sem o ano do Exerc¡cio informado !! Execute a op‡„o 801 !")
      endif
      if empty(CONFIG->Ct_dev)
         if CONFIG->(qrlock())
            replace CONFIG->Ct_dev with "13579"
         endif
      endif
      XCT_DEV := CONFIG->Ct_dev
      qsay(03,01,"Exerc¡cio:" + CONFIG->Exercicio)
      CONFIG->(dbclosearea())
   endif

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

