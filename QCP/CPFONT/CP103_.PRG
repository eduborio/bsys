/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE COMPRADORES
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function cp103

CAD_COMP->(qview({{"Codigo/C¢digo"        ,1},;
                  {"Nome/Nome"            ,3},;
                  {"transform(Limite,'@E 99,999,999.99')/Limite"        ,0}},"P",;
                  {NIL,"c103a",NIL,NIL       },;
                  NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c103a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,13,"B103A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF   := .F.
   local cNome
   local aEDICAO := {}
   local bESCAPE := {||Lastkey()==27.or.(XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , CAD_COMP->Codigo     )
      qrsay ( XNIVEL++ , CAD_COMP->Nome )
      qrsay ( XNIVEL++ , transform(CAD_COMP->Limite,"@E 99,999,999.99") )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOME         ,"@!")                    },"NOME"         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLIMITE       ,"@E 99,999,999.99")      },"LIMITE"       })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CAD_COMP->(qpublicfields())
   iif(cOPCAO=="I",CAD_COMP->(qinitfields()),CAD_COMP->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CAD_COMP->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

     // AGORA INCREMENTA CODIGO DO COMPRADOR ________________________________

   if CONFIG->(qrlock()) .and. CAD_COMP->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         replace CONFIG->Cod_comp with CONFIG->Cod_comp + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_comp,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      CAD_COMP->(qreplacefields())
      CAD_COMP->(dbgotop())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREC

   if ! XFLAG ; return .T. ; endif

   qmensa()

   do case

      case cCAMPO == "LIMITE"
           if fLIMITE <= 0 ; return .F. ; endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR COMPRADOR ____________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Comprador ?")
      if CAD_COMP->(qrlock())
         CAD_COMP->(dbdelete())
         CAD_COMP->(qunlock())
      else
         qm3()
      endif
   endif
return

