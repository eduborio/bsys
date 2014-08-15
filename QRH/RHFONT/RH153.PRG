
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE GRUPO DE FUNCIONARIOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 1996
// OBS........:
// ALTERACOES.:

GRUPOC->(qview({{"Codigo/C¢digo"      ,1},;
                {"Descricao/Descri‡„o",2}},"P",;
                {"c153a","c153b",NIL,NIL},;
                NIL,q_msg_acesso_usr()+"<ENTER>"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c153b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(12,17,"B153A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                    (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG).or.lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , GRUPOC->Codigo    )
      qrsay ( XNIVEL++ , GRUPOC->Descricao )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"9999",NIL,cOPCAO=="I") }    ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!"     ,NIL,.T.) }         ,"DESCRICAO"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   GRUPOC->(qpublicfields())
   iif(cOPCAO=="I",GRUPOC->(qinitfields()),GRUPOC->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; GRUPOC->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if GRUPOC->(iif(cOPCAO=="I",qappend(),qrlock()))
      GRUPOC->(qreplacefields())
      GRUPOC->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           if GRUPOC->(dbseek(fCODIGO))
              qmensa("Grupo j  cadastrado !","B")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR GRUPO DE FUNCIONARIO _________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Grupo ?")
      if GRUPOC->(qrlock())
         GRUPOC->(dbdelete())
         GRUPOC->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR AS VINCULACOES DO GRUPO _____________________________

function c153a
   qlbloc(5,0,"B153B","QBLOC.GLO",1)
   qsay(06,11,GRUPOC->Codigo)
   qsay(06,32,GRUPOC->Descricao)
   GRUPOV->(dbseek(GRUPOC->Codigo))
   GRUPOV->(qview({{"Matricula"                    ,1},;
                   {"c153c()/Nome do Funcionario"  ,0}},;
                   "07002379",;
                   {NIL,"c153d",NIL,NIL},;
                   {"GRUPOC->Codigo==GRUPOV->Codigo",;
                   {||GRUPOV->(dbseek(GRUPOC->Codigo))},;
                   {||GRUPOV->(qseekn(GRUPOC->Codigo))}},;
                   q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR NOME DE FUNCIONARIO ___________________________________

function c153c
   select GRUPOV
   GRUPOV->(dbgoto(recno()))
   FUN->(dbseek(GRUPOV->Matricula))
return(left(FUN->Nome,30))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR AS PERMISSOES DE VINCULACAO DO GRUPO _______________

function c153d
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      if cOPCAO $ "IE"
         qlbloc(18,02,"B153C","QBLOC.GLO")
      endif
      qmensa(qabrev(cOPCAO,"I",{"Inclus„o..."}))
      i_vinc_grupo()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INCLUIR/ALTERAR/EXCLUIR A VINCULACAO DO GRUPO ________________

static function i_vinc_grupo
   local cMATRICULA
   if cOPCAO == "E"
      qsay(19,16,GRUPOV->Matricula)
      qsay(20,16,left(FUN->Nome,30))
      qsay(21,16,GRUPOV->Data_ref)
   endif
   do case
      case cOPCAO == "E"
           if qconf("Confirma a exclus„o deste Funcion rio do Grupo ?")
              if GRUPOV->(qrlock())
                 GRUPOV->(dbdelete())
                 GRUPOV->(qunlock())
              else
                 qm3()
              endif
           endif
      case cOPCAO == "I"
           cMATRICULA := space(6)
           view_fun(19,16,@cMATRICULA)
           qsay(19,16,cMATRICULA:=strzero(val(cMATRICULA),6))
           if ! FUN->(dbseek(cMATRICULA))
              qmensa("Matricula n„o encontrada !","B") ; return
           endif
           qsay(20,16,left(FUN->Nome,30))
           if qconf("Confirma a inclus„o ?")
              if GRUPOV->(qappend())
                 replace GRUPOV->Codigo    with GRUPOC->Codigo
                 replace GRUPOV->Matricula with cMATRICULA
                 GRUPOV->(qunlock())
              else
                 qm1()
              endif
           endif
   endcase
return

