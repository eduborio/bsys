
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DO PLANO DE CONTAS
// ANALISTA...: LUIS ANTONIO
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: NOVEMBRO DE 1994
// OBS........:
// ALTERACOES.:

function ef103

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE CODIGOS CONTABEIS __________________________________________

CONTA->(qview({{"Codigo/C�digo"     ,1} ,;
              {"Descricao/Descri��o" ,2}},"P",;
              {NIL,"i_103a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_103a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(9,10,"B103A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus�o... <ESC - Cancela>","Altera��o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , CONTA->Codigo  , "@R 999999" )
      qrsay ( XNIVEL++ , CONTA->Descricao             )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO    ,"@R 999999",NIL,cOPCAO=="I") } ,"CODIGO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO ,"@!"                       ) } ,"DESCRICAO"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus�o","altera��o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CONTA->(qpublicfields())

   iif(cOPCAO=="I",CONTA->(qinitfields()),CONTA->(qcopyfields()))

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CONTA->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONTA->(iif(cOPCAO=="I",qappend(),qrlock()))
      CONTA->(qreplacefields())
      CONTA->(qunlock())
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
           qrsay(XNIVEL,fCODIGO:=strzero(val(fCODIGO),6))
           if CONTA->(dbseek(fCODIGO))
              qmensa("Codigo Contabil j� cadastrado !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CODIGOS FISCAIS_______________________________________

static function i_exclusao

   if qconf("Confirma exclus�o do Codigo Fiscal ?")
      if CONTA->(qrlock())
         CONTA->(dbdelete())
         CONTA->(qunlock())
      else
         qm3()
      endif
   endif

return
