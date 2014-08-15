////////////////////////////////////////////////////////////////////////////
// SISTEMA....: CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE MNEUMONICOS
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MAIO DE 1994
// OBS........:
// ALTERACOES.:
function ct107

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE CODIGOS FISCAIS_____________________________________________

MNEUMO->(qview({{"Codigo/C¢digo"     ,1} ,;
              {"Descricao/Descri‡„o" ,2}},"P",;
              {NIL,"i_102a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_102a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(9,10,"B102A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.(XNIVEL==1.and.lastkey()==27).or.;
                       (!empty(fDESCRICAO) .and. XNIVEL==2 .and. !XFLAG .or. !empty(fDESCRICAO) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , MNEUMO->Codigo   , "@!" )
      qrsay ( XNIVEL++ , MNEUMO->Descricao, "@!" )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO     ,"@!",NIL,cOPCAO=="I") } ,"CODIGO"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDescricao  ,"@!"                ) } ,"Descricao"  })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MNEUMO->(qpublicfields())

   iif(cOPCAO=="I",MNEUMO->(qinitfields()),MNEUMO->(qcopyfields()))

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; MNEUMO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if MNEUMO->(iif(cOPCAO=="I",qappend(),qrlock()))
      MNEUMO->(qreplacefields())
      MNEUMO->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

//   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           if MNEUMO->(dbseek(fCODIGO))
              qmensa("Mneum“nico j  cadastrado !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CODIGOS FISCAIS_______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o do Codigo Fiscal ?")
      if MNEUMO->(qrlock())
         MNEUMO->(dbdelete())
         MNEUMO->(qunlock())
      else
         qm3()
      endif
   endif

return
