/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: CONFIGURACAO DA ESTRUTURA DO D.R.E.
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:
function ct806

qview({{"Tipo/Tipo"      ,1},;
       {"Titulo/Titulo",0}},"P",;
       {NIL,"c806a",NIL,NIL},;
       NIL,q_msg_acesso_usr())
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c806a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(11,08,"B806A","QBLOC.GLO",1)
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
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.(!empty(fTITULO) .and. Lastkey()==27)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,LEFT(RESULTAD->Titulo,50))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{||qgetx(-1,0,@fTITULO    ,"@!","!empty(@)",.T.) },"TITULO" })
   aadd(aEDICAO,{{||lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   RESULTAD->(qpublicfields())
   iif(cOPCAO=="I",RESULTAD->(qinitfields()),RESULTAD->(qcopyfields()))
   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; RESULTAD->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________


   if ! lCONF ; return ; endif

   if cOPCAO == "I"
      nREG := RESULTAD->(recno())
      RESULTAD->(dbsetorder(1))
      RESULTAD->(qseekn(left(RESULTAD->Codigo,1)))
      fCODIGO := strzero(val(RESULTAD->Codigo)+1,3)
      RESULTAD->(dbgoto(nREG))
      fTITULO := "   " + fTITULO
   endif


   if RESULTAD->(iif(cOPCAO=="I",qappend(),qrlock()))
      RESULTAD->(qreplacefields())
      RESULTAD->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

static function i_critica ( cCAMPO )
   local nREG := 0
   do case
      case cCAMPO == "TITULO"
           fTIPO := "2"
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR HISTORICO ____________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste hist¢rico ?")
      if RESULTAD->(qrlock())
         RESULTAD->(dbdelete())
         RESULTAD->(qunlock())
      else
         qm3()
      endif
   endif
return

