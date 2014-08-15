/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: LANCAMENTO DE CONTAGEM FISICA DOS MATERIAIS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:

//#include "inkey.ch"
function es205

PROD->(dbsetorder(4))

CONTAGEM->(qview({{"Data/Data"           ,1},;
                 {"i_205a()/Produto"     ,0},;
                 {"i_205c()/Filial"      ,0},;
                 {"Contagem1/1§ Contagem",0},;
                 {"Contagem2/2§ Contagem",0}},"P",;
                 {NIL,"i_205b",NIL,NIL},;
                  NIL,q_msg_acesso_usr()))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DA FILIAL ______________________________________________

function i_205c
  FILIAL->(dbseek(CONTAGEM->Filial))
return left(FILIAL->Razao,18)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO PRODUT ______________________________________________

function i_205a
   PROD->(dbseek(CONTAGEM->Cod_prod))
return left(PROD->Descricao,18)


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_205b

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(10,13,"B205A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , CONTAGEM->Data         )
      qrsay ( XNIVEL++ , CONTAGEM->Cod_prod, "@R 99999" ) ; PROD->(dbseek(CONTAGEM->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,25))
      qrsay ( XNIVEL++ , CONTAGEM->Filial) ;                FILIAL->(dbseek(CONTAGEM->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,25))
      qrsay ( XNIVEL++ , CONTAGEM->Contagem1     )
      qrsay ( XNIVEL++ , CONTAGEM->Contagem2     )

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA     ,"@D",                     )} ,"DATA"     })
   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                        )} ,"COD_PROD" })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL                        )} , "FILIAL"  })
   aadd(aEDICAO,{{ || NIL },NIL }) //razao da filial
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTAGEM1   ,"@e 999999",           )} ,"CONTAGEM1"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTAGEM2   ,"@e 999999",           )} ,"CONTAGEM2"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      CONTAGEM->(qpublicfields())

      iif(cOPCAO=="I", CONTAGEM->(qinitfields()), CONTAGEM->(qcopyfields()))

      XNIVEL := 1
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );CONTAGEM->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONTAGEM->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         CONTAGEM->(qreplacefields())

      endif

      dbunlockall()

   enddo

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "DATA"
           if empty(fDATA) ; return .F. ; endif

      case cCAMPO == "COD_PROD"
           if empty(fCOD_PROD) ; return .F. ; endif

           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5) )

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(PROD->Descricao,25))

      case cCAMPO =="FILIAL"

           if empty(fFILIAL) ; return .F. ; endif
           
           qrsay(XNIVEL,fFILIAL:=strzero(val(fFILIAL),4) )

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,25))


      case cCAMPO == "CONTAGEM1"
           if empty(fCONTAGEM1) ; return .F. ; endif

      case cCAMPO == "CONTAGEM2"
           if empty(fCONTAGEM2) ; return .F. ; endif

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR CONTAGEM DE MATERIAL ______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Contagem ?")
      if CONTAGEM->(qrlock())
         CONTAGEM->(dbdelete())
         CONTAGEM->(qunlock())
      else
         qm3()
      endif
   endif

return

