/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MODULO PRINCIPAL DO SISTEMA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: 1994
// OBS........:
// ALTERACOES.:

// DESCRICAO: MODULO PRINCIPAL DO SISTEMA DE FOLHA DE PAGAMENTO

// INICIALIZACAO DO SISTEMA _________________________________________________
qlbloc(0,0,"BQSYS","QBLOC.GLO")
SetColor("R*/B")
@ 24,0 say "                      Aguarde..., Inicializando Sistema!                        "
inkey(1.0)

Set Century on

qinit_sist()     // inicializacao padrao
qinit_var("RH3") // inicializacao de variaveis
qselect_emp()    // seleciona a primeira empresa

// LOOP DE CHAMADA DOS MODULOS DO SISTEMA ___________________________________

do while .T.
   i_atua_tela()
   begin sequence
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

static functio i_atua_tela

   // ATUALIZA VARIAVEIS PUBLICAS EM CONFIG _________________________________

   if quse(XDRV_RH,"CONFIG")
      public XPATHCONTA := alltrim(CONFIG->Pathconta)
      public XPATHSHARE := alltrim(CONFIG->Pathshare)
      public XDATA_ATUAL := CONFIG->Data_atual

      XDATASYS := CONFIG->Datasys
      XANOMES  := qanomes(XDATASYS)
      CONFIG->(dbclosearea())
   endif

   // TRAZ TELA BASICA ______________________________________________________

   qlbloc(0,0,"INICIO",XDRV_SH+"QSBLOC.GLO")

   qsay(03,18,"Sistema de Recursos Humanos - Folha/Pagamento")
   qsay(01,06,date())
   qsay(02,06,time())
   qsay(03,01,"Mˆs/Ano:" + right(XANOMES,2) + "/" + left(XANOMES,4))

   setcursor(1)

   if empty(XDATASYS)
      alert("A data inicial do sistema n„o Informado !;;Utilize a op‡„o <801>",{"OK"})
   endif

   if quse(XDRV_RH,"GRPS")
      GRPS->(dbSetFilter({|| Anomes == XANOMES}, 'Anomes == XANOMES'))
      if GRPS->(eof())
         alert("Cadastre o G.R.P.S. !;;Utilize a op‡„o <106>",{"OK"})
      endif
//    GRPS->(dbclearFilter())
   endif

   if quse(XDRV_CT,"FILIAL")
      if FILIAL->(eof())
         alert("Cadastre a Filial/Matriz !;;Utilize o sistema QCT",{"OK"})
      endif
   endif

   if quse(XDRV_CT,"CCUSTO")
      if CCUSTO->(eof())
         alert("Cadastre o Centro de Custo !;;Utilize o sistema QCT",{"OK"})
      endif
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

