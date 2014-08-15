/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: MODULO PRINCIPAL DO SISTEMA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: 27/05/94: LUIS - INICIO DO PROJETO
// OBS........:
// ALTERACOES.:

// INICIALIZACAO DO SISTEMA _________________________________________________

function main()

REQUEST DBFCDX
RDDSETDEFAULT("DBFCDX")
DBSETDRIVER("DBFCDX")
SETMODE(25,80)

qlbloc(0,0,"BQSYS","QBLOC.GLO")
SetColor("R*/B")
@ 24,0 say "                      Aguarde..., Inicializando Sistema!                        "
inkey(1.0)

Set Century on

qinit_sist()      // inicializacao padrao
qinit_var("EF")  // inicializacao de variaveis
qselect_emp()     // inicializacao da primeira empresa

// LOOP DE CHAMADA DOS MODULOS DO SISTEMA ___________________________________

do while .T.
   i_atua_tela()
   begin sequence
      XWAIT := .T.
      XPROG := qgetprog()
      XWAIT := .F.
      qcall()
   recover
      dbcloseall()
   end sequence
enddo
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZACAO DA TELA BASE DO SISTEMA __________________________

static function i_atua_tela

// PARA DADOS DO CONTADOR INDIVIDUAL POR EMPRESA ____________________________
// VAI SER VERIFICADA UTILIDADE FUTURAMENTE _________________________________
// if ! quse("","QCONFIG") ; return ; endif
// ... depois de abrir config...
// if empty(CONFIG->Contador) .and. ! empty(QCONFIG->Contador)
//    if CONFIG->(qrlock())
//       replace CONFIG->Contador with QCONFIG->Contador
//       ...
//       ...
//    endif
// endif

   if ! quse(XDRV_EF,"CONFIG") ; return ; endif

   if empty(CONFIG->Usa_Vend) .or. empty(CONFIG->Trib_Sinc)
      if CONFIG->(qrlock())
         CONFIG->USA_VEND  := "2"
         CONFIG->TRIB_SINC := "1"
         CONFIG->(qunlock())
      endif
   endif

   public XPATHCONTA  := alltrim(CONFIG->Pathconta)
   public XPATHTESO   := alltrim(CONFIG->Pathteso)
   public XPATHCOMP   := alltrim(CONFIG->Pathcomp)

   public XTIPOEMP    := CONFIG->Tipoemp
   public XNIVEL_EMP  := CONFIG->Nivel_emp
   public XANOMES     := CONFIG->Anomes
   public XTIPOEST    := CONFIG->Tipo_est
   public XUSA_VEND   := CONFIG->Usa_Vend
   public XPAGINA_ENT := CONFIG->Pagina_Ent
   public XPAGINA_SAI := CONFIG->Pagina_Sai
   public XICM_AP_ENT := CONFIG->Icm_Ap_Ent
   public XICM_AP_SAI := CONFIG->Icm_Ap_Sai
   public XIPI_AP_ENT := CONFIG->Ipi_Ap_Ent
   public XIPI_AP_SAI := CONFIG->Ipi_Ap_Sai
   public XPAGINA_ISS := CONFIG->Pagina_Iss

   CONFIG->(dbclosearea())

   qlbloc(0,0,"INICIO",XDRV_SH+"QSBLOC.GLO")

   qsay(01,18,XRAZAO)
   qsay(03,18,"Sistema de Escritura‡„o Fiscal")
   qsay(01,06,date())
   qsay(02,06,time())
   qsay(03,01,"Mˆs/Ano:")
   qsay(03,09,right(XANOMES,2) + "/" + left(XANOMES,4))

   setcursor(1)

   if empty(XANOMES)
      alert("Mˆs e Ano n„o Configurados !;;Utilize a op‡„o <803>",{"OK"})
   endif

   if empty(XTIPOEMP)
      alert("Empresa n„o Configurada !;;Utilize a op‡„o <802>",{"OK"})
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
qanomes()

