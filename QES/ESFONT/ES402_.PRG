/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: COMPOSICAO DE UM PRODUTO ACABADO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 2002
// OBS........:
// ALTERACOES.:
function es402

#include "inkey.ch"

PROD->(dbsetorder(1))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DA COMPOSICAO DE PRODUTO ACABADO ______________________________

ACABADO->(qview({{"Codigo/C¢digo"       ,1},;
                 {"Prod_acab/Produto"   ,0},;
                 {"left(Desc_acab,40)/Descricao" ,0},;
                 {"Total402()/Total"         ,0}},"P",;
                 {NIL,"i_402c",NIL,NIL},;
                 NIL,q_msg_acesso_usr()))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_402c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B402A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

   ACABADO->(dbgotop())

return ""

function total402
local nTOTAL := 0

     ITEN_ACA->(dbseek(ACABADO->Codigo))
     do while ! ITEN_ACA->(eof()) .and. ITEN_ACA->Cod_aca == ACABADO->Codigo
        nTOTAL += ITEN_ACA->Quantidade * ITEN_ACA->Preco
        ITEN_ACA->(dbskip())
     enddo

return transform(nTOTAL,"@E  999,999.99")

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fPROD_ACAB).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,21 , ACABADO->Codigo           )
      qsay ( 07,21 , ACABADO->Prod_acab        )
      qsay ( 07,34 , left(ACABADO->Desc_acab,30))

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
   aadd(aEDICAO,{{ || view_proda(7,21,@fPROD_ACAB                       )} ,"PROD_ACAB"})
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto acabado

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.

      qgirabarra()

      ACABADO->(qpublicfields())

      iif(cOPCAO=="I", ACABADO->(qinitfields()), ACABADO->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );ACABADO->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock()) .and. ACABADO->(iif(cOPCAO=="I",qappend(),qrlock()))

//         if cOPCAO == "I"
//            replace CONFIG->Cod_acab with CONFIG->Cod_acab+1
//            qsay ( 6,21, strzero(CONFIG->Cod_acab,5))
//            qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_acab,5),"B")
//            fCODIGO := strzero(fCOD_ACAB,5)
//         endif

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         ACABADO->(qreplacefields())

      endif

      dbunlockall()

      i_proca()
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

      case cCAMPO == "PROD_ACAB"

           if right(fPROD_ACAB,5) == "     "
              qmensa("Informe um Produto, n„o Grupo ou Sub-Grupo !")
              return .F.
           endif
           if cOPCAO == "I"
              if ACABADO->(dbseek(right(fPROD_ACAB,5)))
                 qmensa("Produto acabado j  Cadastrado !","B")
                 return .F.
              endif
           endif
           if ! PROD->(dbseek(fPROD_ACAB))
              qmensa("Produto n„o Cadastrado !","B")
              return .F.
           else
              fDESC_ACAB := PROD->Descricao
              qsay(07,34,left(PROD->Descricao,40))
              if cOPCAO == "I"
                 fCODIGO := right(fPROD_ACAB,5)
                 qsay ( 6,21, fCODIGO)
                 qmensa("C¢digo Gerado: "+fCODIGO,"B")
              endif
           endif

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR COMPOSICAO DE PRODUTO ACABADO _____________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Composi‡„o ?")
      if ITEN_ACA->(qflock()) .and. ACABADO->(qrlock())
         ITEN_ACA->(dbseek(ACABADO->Codigo))
         do while ! ITEN_ACA->(eof()) .and. ITEN_ACA->Cod_aca == ACABADO->Codigo
            ITEN_ACA->(dbdelete())
            ITEN_ACA->(dbskip())
         enddo
         ACABADO->(dbdelete())
         ACABADO->(qunlock())
         ITEN_ACA->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proca

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PROD->(Dbsetorder(1))

ITEN_ACA->(qview({{"right(Produto,5)/C¢digo"                              ,0},;
                  {"f402b()/Produto"                                      ,0},;
                  {"transform(Quantidade,'@E 9999999.999')/Quantidade"    ,0},;
                  {"transform(Preco,'@E 999,999.999')/Preco"           ,0},;
                  {"transform(Preco*Quantidade,'@E 999,999.999')/Total"           ,0}},;
                  "08002379S",;
                  {NIL,"f402d",NIL,NIL},;
                  {"ITEN_ACA->Cod_aca == ACABADO->Codigo",{||f402top()},{||f402bot()}},;
                  "<ESC> para sair/<I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f402top
   ITEN_ACA->(dbsetorder(1))
   ITEN_ACA->(dbseek(ACABADO->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f402bot
   ITEN_ACA->(dbsetorder(1))
   ITEN_ACA->(qseekn(ACABADO->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO ______________________________

function f402b
   local cDESCRICAO := space(35)
   PROD->(Dbsetorder(1))
   if ! empty(ITEN_ACA->Produto)
      PROD->(dbseek(ITEN_ACA->Produto))
      cDESCRICAO := left(PROD->Descricao,25)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f402d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B402B","QBLOC.GLO",1)
      i_procaessa_acao()
   endif

   setcursor(nCURSOR)

   select ITEN_ACA

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
      qrsay ( XNIVEL++ , ITEN_ACA->Produto                  ) ; PROD->(dbseek(ITEN_ACA->Produto))
      qrsay ( XNIVEL++ , left(PROD->Descricao,35)           )
      qrsay ( XNIVEL++ , ITEN_ACA->Quantidade ,"@E 9999999.999"  )
      qrsay ( XNIVEL++ , ITEN_ACA->Preco      ,"@E 99,999,999.99"  )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()          ; return ; endif
   if cOPCAO == "E" ; i_exc_ITEN_ACA() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_proda(-1,0,@fPRODUTO              ) } ,"PRODUTO"  })
   aadd(aEDICAO,{{ || NIL                                      } ,NIL        })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 9999999.999"  ) } ,"QUANTIDADE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO      , "@E 99,999,999.99"  ) } ,"PRECO"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_ACA->(qpublicfields())

   iif(cOPCAO=="I",ITEN_ACA->(qinitfields()),ITEN_ACA->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_ACA->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if ACABADO->(qrlock()) .and. ITEN_ACA->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fCOD_ACA := fCODIGO
      endif

      ITEN_ACA->(qreplacefields())
      ITEN_ACA->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   ACABADO->(dbseek(fCODIGO))

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "PRODUTO"

           if cOPCAO == "I"
              if ACABADO->(dbseek(fPRODUTO))
                 qmensa("Produto j  Cadastrado !","B")
                 return .F.
              endif
           endif
           if ! PROD->(dbseek(fPRODUTO))
              qmensa("Produto n„o Cadastrado !","B")
              return .F.
           else
              fDESC_ACAB := PROD->Descricao
              qrsay(XNIVEL+1,left(PROD->Descricao,30))
           endif
      case cCAMPO == "QUANTIDADE"
           fPRECO := PROD->Preco_cust

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITEN DE PRODUTO ACABADO _____________________________

static function i_exc_iten_aca

   if qconf("Confirma exclus„o do Produto ?")
      if ITEN_ACA->(qrlock())
         ITEN_ACA->(dbdelete())
         ITEN_ACA->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_lanc

setcolor("W/B")

ITEN_ACA->(qview({{"Produto/C¢digo"                                      ,1},;
                  {"f402b()/Produto"                                     ,0},;
                  {"transform(Quantidade,'@E 9999999.999')/Quantidade"    ,0},;
                  {"transform(Preco,'@E 999,999.999')/Preco"              ,0},;
                  {"transform(Preco*Quantidade,'@E 999,999.999')/Total"             ,0}},;
                  "08002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_ACA->Cod_aca == ACABADO->Codigo",{||f402top()},{||f402bot()}},;
                  "<ESC> para sair"))

return ""
