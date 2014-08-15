/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: AGRUPAMENTO DE PAGAMENTOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: DEZEMBRO DE 1996
// OBS........:
// ALTERACOES.:

//#include "inkey.ch"

function pg202

private cAGRUPADO := space(3)
private cAGRUPA   := space(3)
private nVALOR    := 0
private nVAL_TOT  := 0

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS AGRUPAMENTOS _____________________________________________

AGRUPA->(qview({{"Codigo/N£mero"        ,1},;
                {"Num_fatura/Fatura"    ,2},;
                 {"Data_venc/Vencimento",3}},"P",;
                 {NIL,"i_202a",NIL,NIL},;
                  NIL,q_msg_acesso_usr()))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_202a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(5,2,"B202A","QBLOC.GLO")
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fNUM_FATURA).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,13 , AGRUPA->Codigo           )
      qsay ( 06,40 , AGRUPA->Num_fatura       )
      qsay ( 06,67 , dtoc(AGRUPA->Data_venc)  )

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; i_consulta() ; PAGAR->(Dbsetfilter()) ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || NIL }                                               ,NIL          })
   aadd(aEDICAO,{{ || qgetx(6,40,@fNUM_FATURA ,"@!",                   )} ,"NUM_FATURA" })
   aadd(aEDICAO,{{ || qgetx(6,67,@fDATA_VENC ,"@D",                    )} ,"DATA_VENC"  })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      AGRUPA->(qpublicfields())

      iif(cOPCAO=="I", AGRUPA->(qinitfields()), AGRUPA->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );AGRUPA->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock()) .and. AGRUPA->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AQUI INCREMENTA CODIGO DO AGRUPAMENTO _______________________________

         if cOPCAO == "I"
            replace CONFIG->Cod_agru with CONFIG->Cod_agru + 1
            qsay ( 06,13 , fCODIGO := strzero(CONFIG->Cod_agru,5) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         AGRUPA->(qreplacefields())

      else

         iif(cOPCAO=="I",qm1(),qm2())

      endif

      dbunlockall()

      PAGAR->(DbSetorder(6))
      PAGAR->(Dbgotop())

      i_proc_lanc()

      keyboard chr(27)

   enddo

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DATA_VENC"
           if empty(fDATA_VENC) ; return .F. ; endif

      case cCAMPO == "NUM_FATURA"
           if empty(fNUM_FATURA) ; return .F. ; endif
   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR AGRUPAMENTO ______________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Agrupamento ?")
      PAGAR->(dbsetorder(6))
      if AGRUPA->(qrlock()) .and. PAGAR->(qflock())
         if PAGAR->(dbseek(AGRUPA->Codigo))
            do while ! PAGAR->(eof()) .and. PAGAR->Agrupado == AGRUPA->Codigo
               replace PAGAR->Agrupado with space(5)
               PAGAR->(dbskip())
            enddo
         endif
         AGRUPA->(dbdelete())
         AGRUPA->(qunlock())
         PAGAR->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS LANCAMENTOS ___________________________

function i_proc_lanc

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PAGAR->(qview({{"Codigo/C¢digo"             ,1},;
               {"Data_venc/Vencimento"      ,2},;
               {"f_202b()/Fornecedor"       ,3},;
               {"f_202c()/   Valor"         ,4},;
               {"Num_titulo/N£m. Doc."      ,5},;
               {"f_202e()/Agrup."           ,0}},;
               "08042074S",;
               {NIL,"f202d",NIL,NIL},;
               NIL,"ESC/ALT-P/ALT-O/<A>grupamento"))

return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_202c
return(transform(PAGAR->Valor,"@E 9,999,999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM SE AGRUPADO OU NAO __________________________________

function f_202e

   local cSITUACAO:=space(3)

   if ! empty(PAGAR->Agrupado)
      cSITUACAO := "SIM"
   else
      cSITUACAO := "NAO"
   endif

return cSITUACAO

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_202b
   FORN->(dbseek(PAGAR->Cod_forn))
return left(FORN->Razao,10)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f202d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO = "A"
      if ! empty(PAGAR->Agrupado)
         if qconf("Lan‡amento j  Agrupado, Deseja Reverter ?")
            if PAGAR->(qflock())
               replace PAGAR->Agrupado with space(5)
               nVAL_TOT = nVAL_TOT - PAGAR->Valor
            endif
            PAGAR->(qunlock())
         endif
      else
         i_processa_acao()
      endif
   endif

   qsay(22,16,transform(nVAL_TOT, "@e 99,999,999.99"))

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO QUE GRAVA OS LANCAMENTOS AGRUPADOS  ______________________________

function i_processa_acao

    if PAGAR->(qflock())
       replace PAGAR->Agrupado with fCODIGO
    endif

    nVAL_TOT += PAGAR->Valor

    PAGAR->(qunlock())

return

//////////////////////////////////////////////////////////////////////////////////
// PARA CONSULTAR AGRUPAMENTO ___________________________________________________

static function i_consulta
   local nTECLA, nCONT
   local nVALOR := 0

   qsay ( 06,13 , AGRUPA->Codigo           )
   qsay ( 06,40 , AGRUPA->Num_fatura       )
   qsay ( 06,67 , dtoc(AGRUPA->Data_venc)  )

   PAGAR->(DbSetorder(6))
   PAGAR->(dbSetFilter({|| Agrupado == AGRUPA->Codigo}, 'Agrupado == AGRUPA->Codigo'))
   PAGAR->(Dbgotop())

   do while ! PAGAR->(eof())
      nVALOR += PAGAR->Valor
      PAGAR->(Dbskip())
   enddo

   PAGAR->(Dbgotop())

   qsay(22,16,transform(nVALOR, "@e 99,999,999.99"))

   PAGAR->(qview({{"Codigo/C¢digo"             ,1},;
                  {"Data_venc/Vencimento"      ,2},;
                  {"f_202b()/Fornecedor"       ,3},;
                  {"f_202c()/   Valor"         ,4},;
                  {"Num_titulo/N£m. Doc."      ,5},;
                  {"f_202c()/Agrup."           ,0}},;
                  "08042074S",;
                  {NIL,NIL,NIL,NIL},;
                  NIL,"ESC - Retorna"))

return
