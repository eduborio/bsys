
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE VENDEDORES
// ANALISTA...: LUIS ANTONIO
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: AGOSTO DE 1995
// OBS........:
// ALTERACOES.:
function ef108

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE FORNECEDORES _______________________________________________

VEND->(qview({{"Codigo/C¢digo",1},;
              {"Nome/Nome"    ,2},;
              {"Comissao/Comiss„o",0}},"P",;
              {NIL,"i_108a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_108a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(9,10,"B108A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , VEND->Codigo      , "999"        )
      qrsay ( XNIVEL++ , VEND->Nome        , "@!"         )
      qrsay ( XNIVEL++ , VEND->Comissao    , "@R 99.99"   )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   , "@!", NIL,cOPCAO=="I" ) } ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOME     , "@!"                  ) } ,"NOME"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMISSAO , "@R 99.99"            ) } ,"COMISSAO" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   VEND->(qpublicfields())

   iif(cOPCAO=="I",VEND->(qinitfields()),VEND->(qcopyfields()))

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; VEND->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if VEND->(iif(cOPCAO=="I",qappend(),qrlock()))
      VEND->(qreplacefields())
      VEND->(qunlock())
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
           qrsay(XNIVEL,fCODIGO:=strzero(val(fCODIGO),3))
           if VEND->(dbseek(fCODIGO))
              qmensa("Vendedor j  cadastrado !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR VENDEDOR _____________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o do Vendedor ?")
      if VEND->(qrlock())
         VEND->(dbdelete())
         VEND->(qunlock())
      else
         qm3()
      endif
   endif

return
