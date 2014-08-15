/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DO CODIGO DE PAGAMENTO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM WIECZORKOVSKI
// PROGRAMADOR: A MESMA
// INICIO.....: JUNHO DE 1999
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE CODIGO DE PAGAMENTO ________________________________________

COD_PAGT->(qview({{"Codigo/C¢digo"                  ,1},;
                  {"left(Descricao,68)/Descri‡„o"   ,2}},"P",;
                  {NIL,"c110a",NIL,NIL},;
                  NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c110a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,5,"B110A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
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
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , COD_PAGT->Codigo    )
      qrsay ( XNIVEL++ , left(COD_PAGT->Descricao,50) )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO    ,"9999",NIL,cOPCAO=="I") }        ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!@S50"     ,NIL,.T.) }            ,"DESCRICAO"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   COD_PAGT->(qpublicfields())
   iif(cOPCAO=="I",COD_PAGT->(qinitfields()),COD_PAGT->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; COD_PAGT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if COD_PAGT->(iif(cOPCAO=="I",qappend(),qrlock()))
      COD_PAGT->(qreplacefields())
      COD_PAGT->(qunlock())
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
           if COD_PAGT->(dbseek(fCODIGO))
              qmensa("C¢digo de Pagamento j  cadastrado !","B")
              return .F.
           endif
      case cCAMPO == "DESCRICAO"
           if empty(fDESCRICAO)
              return .F.
           endif

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CODIGO DE PAGAMENTO __________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste C¢digo de Pagamento ?")
      if COD_PAGT->(qrlock())
         COD_PAGT->(dbdelete())
         COD_PAGT->(qunlock())
      else
         qm3()
      endif
   endif
return
