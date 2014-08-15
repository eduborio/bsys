/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE SETORES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDo BORIO
// INICIO.....: MAIO DE 2009
// OBS........:
// ALTERACOES.:
function cl132
MOTBAI->(qview({{"Codigo/Codigo"               ,1},;
             {"Descricao/Descricao"           ,2}},"P",;
             {NIL,"c132a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c132a

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
      qrsay ( XNIVEL++ , MOTBAI->Codigo     )
      qrsay ( XNIVEL++ , MOTBAI->Descricao  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")                        },"DESCRICAO"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MOTBAI->(qpublicfields())
   iif(cOPCAO=="I",MOTBAI->(qinitfields()),MOTBAI->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; MOTBAI->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. MOTBAI->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_motbai with CONFIG->Cod_motbai + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_motbai,2) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      fCODIGO:=strzero(val(fCODIGO),2)

      MOTBAI->(qreplacefields())

   else

      if empty(MOTBAI->Codigo) .and. empty(MOTBAI->Descricao)
         MOTBAI->(dbdelete())
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
   if qconf("Confirma exclus„o deste(a) Motivo de Baixa ?")
      if MOTBAI->(qrlock())
         MOTBAI->(dbdelete())
         MOTBAI->(qunlock())
      else
         qm3()
      endif
   endif
return
