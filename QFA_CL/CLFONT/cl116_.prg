/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE SITUACAO TRIBUTARIA
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2001
// OBS........:
// ALTERACOES.:

function cl116
SIT_TRIB->(qview({{"Codigo/Codigo"         ,1},;
          {"Descricao/Descricao"           ,0}},"P",;
             {NIL,"c116a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c116a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(7,0,"B116A","QBLOC.GLO",1)
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
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or. Lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , SIT_TRIB->Codigo                     )
      qrsay ( XNIVEL++ , SIT_TRIB->Descricao                  )

   endif
   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"999")       },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")        },"DESCRICAO"    })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   SIT_TRIB->(qpublicfields())
   iif(cOPCAO=="I",SIT_TRIB->(qinitfields()),SIT_TRIB->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; SIT_TRIB->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. SIT_TRIB->(iif(cOPCAO=="I",qappend(),qrlock()))

      SIT_TRIB->(qreplacefields())
      SIT_TRIB->(dbgotop())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO"

           if cOPCAO == "I"
              if SIT_TRIB->(dbseek(fCODIGO))
                 qmensa("Situacao Tributaria ja cadastrada !","B")
                 return .F.
              endif
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR TRANSPORTADORA _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Situacao Tributaria ?")
      if SIT_TRIB->(qrlock())
         SIT_TRIB->(dbdelete())
         SIT_TRIB->(qunlock())
      else
         qm3()
      endif
   endif
return
