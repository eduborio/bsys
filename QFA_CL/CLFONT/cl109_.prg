/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE IDENTIFICACAO FISCAL
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREREIRO DE 2001
// OBS........:
// ALTERACOES.:

function cl109
IDENT->(qview({{"Codigo/Codigo"        ,1},;
              {"left(Nome,30)/Nome"    ,2},;
              {"Aliq/Aliquota"         ,0},;
              {"Aliq_ded/Deducao"      ,0}},"P",;
              {NIL,"c109a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c109a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(10,2,"B109A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao()

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , IDENT->Codigo    )
      qrsay ( XNIVEL++ , IDENT->Nome      )
      qrsay ( XNIVEL++ , IDENT->Aliq      )
      qrsay ( XNIVEL++ , IDENT->Aliq_ded  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO,"@R 9999")                      },"CODIGO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOME,"@!")                             },"NOME"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ,"@E 99.99")                       },"ALIQ"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_DED,"@E 999.99")                   },"ALIQ_DED"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   IDENT->(qpublicfields())
   iif(cOPCAO=="I",IDENT->(qinitfields()),IDENT->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; IDENT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   IDENT->(iif(cOPCAO=="I",qappend(),qrlock()))

   IDENT->(qreplacefields())


   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO"
           if empty(fCODIGO) ; return .F. ; endif
   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR IDENTIFICACAO_________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Identificacao ?")
      if IDENT->(qrlock())
         IDENT->(dbdelete())
         IDENT->(qunlock())
      else
         qm3()
      endif
   endif
return
