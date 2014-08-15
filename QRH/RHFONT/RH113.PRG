/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE NATUREZAS JURIDICAS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:

NAT_JUR->(qview({{"Codigo/C¢digo"    ,1},;
               {"Descricao/Descri‡„o",2}},"P",;
               {NIL,"c113a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c113a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   private nRECNO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,1,"B113A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fCODIGO) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , NAT_JUR->Codigo    )
      qrsay ( XNIVEL++ , NAT_JUR->Descricao )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!",NIL,cOPCAO=="I") }         ,"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!"     ,NIL,.T.) }            ,"DESCRICAO" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   NAT_JUR->(qpublicfields())
   iif(cOPCAO=="I",NAT_JUR->(qinitfields()),NAT_JUR->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; NAT_JUR->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if NAT_JUR->(iif(cOPCAO=="I",qappend(),qrlock()))
      NAT_JUR->(qreplacefields())
      NAT_JUR->(qunlock())
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
           if NAT_JUR->(dbseek(fCODIGO))
              qmensa("Natureza Jur¡dica j  cadastrada !","B")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR NAT_JUR ________________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Natureza Jur¡dica ?")
      if NAT_JUR->(qrlock())
         NAT_JUR->(dbdelete())
         NAT_JUR->(qunlock())
      else
         qm3()
      endif
   endif
return

