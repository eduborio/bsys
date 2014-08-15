/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: MANUTENCAO DE CARTOES DE CREDITO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JUNHO DE 1998
// OBS........:
// ALTERACOES.:

function rb105

CARTAO->(qview({{"Codigo/C¢digo"             ,1},;
                {"Descricao/  Descri‡„o "    ,2},;
                {"Taxa/Taxa"                 ,0}},"P",;
                {NIL,"c105a",NIL,NIL           },;
                NIL,q_msg_acesso_usr() ))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c105a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,7,"B105A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fDESCRICAO).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDESCRICAO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   //   MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , CARTAO->Codigo   )
      qrsay ( XNIVEL++ , left(CARTAO->Descricao,50))
      qrsay ( XNIVEL++ , transform(CARTAO->Taxa,"@R 99.99"))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                               },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!@S50")  },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTAXA,"99.99")        },"TAXA"      })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CARTAO->(qpublicfields())
   iif(cOPCAO=="I",CARTAO->(qinitfields()),CARTAO->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CARTAO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

     // AGORA INCREMENTA CODIGO DA FORMA DE PAGAMENTO _______________________

   if CONFIG->(qrlock()) .and. CARTAO->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         replace CONFIG->Cod_cart with CONFIG->Cod_cart + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_cart,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      CARTAO->(qreplacefields())
      CARTAO->(dbgotop())

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

      case cCAMPO == "DESCRICAO"
           if empty(fDESCRICAO) ; return .F. ; endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR FORMAS DE PAGAMENTO __________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Forma de Pagamento ?")
      if CARTAO->(qrlock())
         CARTAO->(dbdelete())
         CARTAO->(qunlock())
      else
         qm3()
      endif
   endif
return
