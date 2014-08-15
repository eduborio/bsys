/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: COMPOSICAO DE UM PRODUTO ACABADO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 2002
// OBS........:
// ALTERACOES.:
function es404

#include "inkey.ch"

PROD->(dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DA COMPOSICAO DE PRODUTO ACABADO ______________________________

COMPOSIC->(qview({{"Codigo/C¢digo"       ,1},;
                 {"Descricao/Descricao" ,2}},"P",;
                 {NIL,"i_404c",NIL,NIL},;
                 NIL,q_msg_acesso_usr()))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_404c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B404A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

   COMPOSIC->(dbgotop())

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDESCRICAO).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,21 , COMPOSIC->Codigo           )
      qsay ( 07,21 , COMPOSIC->Descricao        )

      if cOPCAO == "C"
        i_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(6,21,@fCODIGO     ,"99999",NIL              )} ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(7,21,@fDESCRICAO ,"@!"                      )} ,"DESCRICAO"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.

      qgirabarra()

      COMPOSIC->(qpublicfields())

      iif(cOPCAO=="I", COMPOSIC->(qinitfields()), COMPOSIC->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );COMPOSIC->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock()) .and. COMPOSIC->(iif(cOPCAO=="I",qappend(),qrlock()))

         if cOPCAO == "I"
            replace CONFIG->Cod_comp with CONFIG->Cod_comp+1
            qsay ( 6,21, strzero(CONFIG->Cod_comp,5))
            qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_comp,5),"B")
            fCODIGO := strzero(CONFIG->Cod_comp,5)
         endif

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         COMPOSIC->(qreplacefields())

      endif

      dbunlockall()

      i_procb()
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
      case cCAMPO == "DESCRICAO"
//              if cOPCAO == "I"
//                 fCODIGO := right(fPROD_ACAB,5)
//                 qsay ( 6,21, fCODIGO)
//                 qmensa("C¢digo Gerado: "+fCODIGO,"B")
//              endif

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR COMPOSICAO DE PRODUTO ACABADO _____________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Composi‡„o ?")
      if ITEN_CMP->(qflock()) .and. COMPOSIC->(qrlock())
         ITEN_CMP->(dbseek(COMPOSIC->Codigo))
         do while ! ITEN_CMP->(eof()) .and. ITEN_CMP->Cod_comp == COMPOSIC->Codigo
            ITEN_CMP->(dbdelete())
            ITEN_CMP->(dbskip())
         enddo
         COMPOSIC->(dbdelete())
         COMPOSIC->(qunlock())
         ITEN_CMP->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_procb

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PROD->(Dbsetorder(4))

ITEN_CMP->(qview({{"Cod_comp/Item"                                       ,1},;
                  {"Cod_prod/C¢digo"                                    ,0},;
                  {"f404b()/Produto"                                     ,0}},;
                  "08002379S",;
                  {NIL,"f404d",NIL,NIL},;
                  {"ITEN_CMP->Cod_comp == COMPOSIC->Codigo",{||f404top()},{||f404bot()}},;
                  "<ESC> para sair/<I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f404top
   ITEN_CMP->(dbsetorder(1))
   ITEN_CMP->(dbseek(COMPOSIC->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f404bot
   ITEN_CMP->(dbsetorder(1))
   ITEN_CMP->(qseekn(COMPOSIC->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO ______________________________

function f404b
   local cDESCRICAO := space(35)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_CMP->Cod_prod)
      PROD->(dbseek(ITEN_CMP->Cod_prod))
      cDESCRICAO := left(PROD->Descricao,35)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f404d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B404B","QBLOC.GLO",1)
      i_procaessa_acao()
   endif

   setcursor(nCURSOR)

   select ITEN_CMP

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_procaessa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_CMP->Cod_prod                ) ; PROD->(dbseek(ITEN_CMP->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,35)           )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()          ; return ; endif
   if cOPCAO == "E" ; i_exc_ITEN_ACA() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD              ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                      } ,NIL        })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_CMP->(qpublicfields())

   iif(cOPCAO=="I",ITEN_CMP->(qinitfields()),ITEN_CMP->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_CMP->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if COMPOSIC->(qrlock()) .and. ITEN_CMP->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fCOD_CMP := fCODIGO
      endif

      ITEN_CMP->(qreplacefields())
      ITEN_CMP->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   COMPOSIC->(dbseek(fCODIGO))

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "COD_PROD"

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(PROD->Descricao,30))
              fCOD_COMP := fCODIGO
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITEN DE PRODUTO ACABADO _____________________________

static function i_exc_iten_aca

   if qconf("Confirma exclus„o do Produto ?")
      if ITEN_CMP->(qrlock())
         ITEN_CMP->(dbdelete())
         ITEN_CMP->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_lanc

setcolor("W/B")
ITEN_CMP->(qview({{"Cod_comp/Item"                                       ,1},;
                  {"Cod_prod/C¢digo"                                    ,0},;
                  {"f404b()/Produto"                                     ,0}},;
                  "08002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_CMP->Cod_comp == COMPOSIC->Codigo",{||f404top()},{||f404bot()}},;
                  "<ESC> para sair"))

return ""
