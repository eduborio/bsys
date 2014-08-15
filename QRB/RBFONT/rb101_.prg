/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: MANUTENCAO DE AGENCIAS CEDENTES
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:

function rb101

AGE_CED->(qview({{"Codigo/C¢digo"                ,1},;
                  {"Descricao/Descri‡„o"         ,2}},"P",;
                  {NIL,"c101a",NIL,NIL},;
                   NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c101a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(12,15,"B101A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , AGE_CED->Codigo     )
      qrsay ( XNIVEL++ , AGE_CED->Descricao  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"@!")                    },"CODIGO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    ,"@!")                    },"DESCRICAO"  })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   AGE_CED->(qpublicfields())
   iif(cOPCAO=="I",AGE_CED->(qinitfields()),AGE_CED->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; AGE_CED->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

   if AGE_CED->(iif(cOPCAO=="I",qappend(),qrlock()))

      AGE_CED->(qreplacefields())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DESCRICAO"

          if empty(fDESCRICAO) ; return .F. ; endif

   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR AGENCIAS CEDENTES ___________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Agˆncia Cedente ?")
      if AGE_CED->(qrlock())
         AGE_CED->(dbdelete())
         AGE_CED->(qunlock())
      else
         qm3()
      endif
   endif
return

