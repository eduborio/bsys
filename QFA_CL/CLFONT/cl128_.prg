/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE VENDEDORES
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:

function cl128
CT_CONV->(qview({{"Codigo/Codigo"                      ,1},;
                {"Cliente/Cliente"                     ,2},;
                {"transf(Limite,'@E 999,999.99')/Credito",0}},"P",;
             {NIL,"c128a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c128a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(10,2,"B128A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCOD_CLI).or.(XNIVEL==2.and.!XFLAG).or.!empty(fCOD_CLI).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , CT_CONV->Codigo     )
      qrsay ( XNIVEL++ , CT_CONV->Cod_cli    );CLI1->(dbseek(CT_CONV->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->razao,50))
      qrsay ( XNIVEL++ , CT_CONV->Limite,"@E 999,999.99")
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"  })
   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_CLI,"@!")                       },"COD_CLI" })
   aadd(aEDICAO,{{ || NIL                                                 },NIL })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLimite,"@E 999,999.99")                },"LIMITE"   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CT_CONV->(qpublicfields())
   iif(cOPCAO=="I",CT_CONV->(qinitfields()),CT_CONV->(qcopyfields()))

   if cOPCAO == "I"
      XNIVEL  := 2
   endif

   if cOPCAO == "A"
      XNIVEL := 3
   endif

   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CT_CONV->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CT_CONV->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      if cOPCAO == "I"
         qrsay ( 1 , fCODIGO := fCOD_CLI )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif
      fCODIGO:=strzero(val(fCODIGO),5)

      CT_CONV->(qreplacefields())

   else

      if empty(CT_CONV->Codigo) .and. empty(CT_CONV->cod_cli)
         CT_CONV->(dbdelete())
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
   local nREG := 0
   local nINDEX := 0

   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "COD_CLI"

         if empty(fCOD_CLI) ; return .F. ; endif
         qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))

         nREG   := CT_CONV->(Recno())
         nINDEX := CT_CONV->(Indexord())

         if cOPCAO == "I"
            if CT_CONV->(dbseek(fCOD_CLI))
               qmensa("Cliente ja cadastrado !","B")
               return .F.
            endif
         endif


         if ! CLI1->(dbseek(fCOD_CLI))
            qmensa("Cliente n„o encontrado !","B")
            return .F.
         endif

         qrsay(XNIVEL+1,left(CLI1->Razao,40))

         fCLIENTE := CLI1->Razao

         CT_CONV->(Dbgoto(nREG))
         CT_CONV->(Dbsetorder(nINDEX))


   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR VENDEDORA  ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Conta Convenio ?")
      if CT_CONV->(qrlock())
         CT_CONV->(dbdelete())
         CT_CONV->(qunlock())
      else
         qm3()
      endif
   endif
return
