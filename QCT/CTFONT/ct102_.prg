/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE HISTORICOS PADROES
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:
function ct102

qview({{"Codigo/C¢digo"      ,1},;
       {"Descricao/Descri‡„o",2}},"P",;
       {NIL,"c102a",NIL,NIL},;
       NIL,q_msg_acesso_usr())
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c102a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(11,08,"B102A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fDESCRICAO) .and. XNIVEL==2 .and. !XFLAG .or. !empty(fDESCRICAO) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,HIST->Codigo)
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{||qgetx(-1,0,@fCODIGO       ,"@!",NIL,cOPCAO=="I") },"CODIGO"    })
   aadd(aEDICAO,{{||qgetx(-1,0,@fDESCRICAO    ,"@!","!empty(@)",.T.) },"DESCRICAO" })
   aadd(aEDICAO,{{||lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   HIST->(qpublicfields())
   iif(cOPCAO=="I",HIST->(qinitfields()),HIST->(qcopyfields()))
   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; HIST->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________


   if ! lCONF ; return ; endif

   if HIST->(iif(cOPCAO=="I",qappend(),qrlock()))
      HIST->(qreplacefields())
      HIST->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           if HIST->(dbseek(fCODIGO))
              qmensa("Hist¢rico j  cadastrado !","B")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR HISTORICO ____________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste hist¢rico ?")
      if HIST->(qrlock())
         HIST->(dbdelete())
         HIST->(qunlock())
      else
         qm3()
      endif
   endif
return

