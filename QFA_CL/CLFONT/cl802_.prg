
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO USIMIX
// OBJETIVO...: CONFIGURACAO DE NUMERACAO DE PEDIDOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:

function cl802
NUM_PEDI->(qview({{"Filial"           ,1},;
              {"i_802x()/Descri‡„o"   ,0},;
              {"Pedido"               ,0},;
              {"Previsao"             ,0}},"P",;
              {NIL,"c802a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

function i_802x
   FILIAL->(dbseek(NUM_PEDI->Filial))
return left(FILIAL->Razao,40)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c802a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,12,"B802A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fFILIAL).or.(XNIVEL==1.and.!XFLAG).or.!empty(fFILIAL).and.Lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , NUM_PEDI->Filial ) ; FILIAL->(dbseek(NUM_PEDI->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40) )
      qrsay ( XNIVEL++ , NUM_PEDI->Pedido   , "99999" )
      qrsay ( XNIVEL++ , NUM_PEDI->Previsao , "99999" )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)     },"FILIAL"   })
   aadd(aEDICAO,{{ || NIL                            },NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPEDIDO,"99999")   },"PEDIDO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPREVISAO,"99999") },"PREVISAO" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   NUM_PEDI->(qpublicfields())
   iif(cOPCAO=="I",NUM_PEDI->(qinitfields()),NUM_PEDI->(qcopyfields()))
   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; NUM_PEDI->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if NUM_PEDI->(iif(cOPCAO=="I",qappend(),qrlock()))
      NUM_PEDI->(qreplacefields())
      NUM_PEDI->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "FILIAL"

           if FILIAL->(dbseek(fFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,40))
           else
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           if cOPCAO == "I" .and. NUM_PEDI->(dbseek(fFILIAL))
              qmensa("Config. da Filial j  cadastrado !","B")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR FILIAL _______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Filial ?")
      if NUM_PEDI->(qrlock())
         NUM_PEDI->(dbdelete())
         NUM_PEDI->(qunlock())
      else
         qm3()
      endif
   endif
return

