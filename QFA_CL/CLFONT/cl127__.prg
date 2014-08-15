/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE SETORES
// ANALISTA...: Eduardo Borio
// PROGRAMADOR: Eduard Borio
// INICIO.....: Janeiro de 2009
// OBS........:
// ALTERACOES.:

function cl127
ROTA->(qview({{"Codigo/Codigo"               ,1},;
             {"Descricao/Descricao"           ,2}},"P",;
             {NIL,"c127a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c127a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(10,5,"B104A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fDESCRICAO).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDESCRICAO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , ROTA->Codigo     )
      qrsay ( XNIVEL++ , ROTA->Descricao  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")                        },"DESCRICAO"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ROTA->(qpublicfields())
   iif(cOPCAO=="I",ROTA->(qinitfields()),ROTA->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ROTA->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. ROTA->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_rota with CONFIG->Cod_rota + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_rota,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      fCODIGO:=strzero(val(fCODIGO),5)

      ROTA->(qreplacefields())

   else

      if empty(ROTA->Codigo) .and. empty(ROTA->Descricao)
         ROTA->(dbdelete())
      endif

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
// FUNCAO PARA EXCLUIR SETOREDORA  ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Rota ?")
      if ROTA->(qrlock())
         ROTA->(dbdelete())
         ROTA->(qunlock())
      else
         qm3()
      endif
   endif
return
