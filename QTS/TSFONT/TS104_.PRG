/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE PRODUTOS
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: MAIO DE 2010
// OBS........:
// ALTERACOES.:

function ts104

private nTIPO := 0

PLAN_FIN->(qview({{"transform(Codigo,'@R 99.99.99999')/C¢digo" ,1},;
              {"c104b()/Descri‡„o"                         ,2}},"P",;
              {NIL,"c104a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESLOCAR EM ARVORE A DESCRICAO DOS PRODUTOS __________________

function c104b
   local cDESCRICAO := PLAN_FIN->Descricao + "    "

   do case
      case len(alltrim(PLAN_FIN->Codigo)) == 2 ; cDESCRICAO := left(PLAN_FIN->Descricao,35)+"    "
      case len(alltrim(PLAN_FIN->Codigo)) == 4 ; cDESCRICAO := "  "+left(PLAN_FIN->Descricao,35)+"  "
      case len(alltrim(PLAN_FIN->Codigo)) == 9 ; cDESCRICAO := "    "+left(PLAN_FIN->Descricao,35)
   endcase

return cDESCRICAO


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c104a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA

      qlbloc(05,00,"B104A","QBLOC.GLO",1)

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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO) .and. Lastkey()==27 .or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}
   local nREC

   private nTIPO := 0

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PLAN_FIN->Codigo , "@R 99.99.99999"                    )
      qrsay ( XNIVEL++ , PLAN_FIN->Descricao                                    )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"@R 99.99")                },"CODIGO"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    )                      },"DESCRICAO"    })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PLAN_FIN->(qpublicfields())
   iif(cOPCAO=="I",PLAN_FIN->(qinitfields()),PLAN_FIN->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PLAN_FIN->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. PLAN_FIN->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO PRODUTO __________________________________

      if cOPCAO == "I"
         if nTIPO == 1
            replace CONFIG->Cod_plan with CONFIG->Cod_plan + 1
            fCODIGO := alltrim(fCODIGO) + strzero(CONFIG->Cod_plan,5)
            qrsay ( 1 , transform(fCODIGO,"@R 99.99.99999") )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif
      endif

      PLAN_FIN->(qreplacefields())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()


return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nReg    := 0
   local nIndex  := 0

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO"

           do case
              case len(alltrim(fCODIGO)) == 2
                   if cOPCAO == "I"
                      nIndex := PLAN_FIN->(IndexOrd())
                      PLAN_FIN->(dbsetorder(1))
                      if PLAN_FIN->(dbseek(fCODIGO))
                         qmensa("Grupo j  cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      PLAN_FIN->(dbsetorder(nIndex))
                   endif



              case len(alltrim(fCODIGO)) == 4

                   if cOPCAO == "I"
                      i_tipo_inc()
                   else
                      nTIPO := 2
                   endif

                   if nTIPO == 1

                      nIndex := PLAN_FIN->(IndexOrd())
                      PLAN_FIN->(dbsetorder(1))
                      if ! PLAN_FIN->(dbseek(left(fCODIGO,4))) .and. cOPCAO == "I"
                         qmensa("Sub-grupo n„o cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      PLAN_FIN->(dbsetorder(nINDEX))
                   else
                      if cOPCAO == "I"
                         nIndex := PLAN_FIN->(IndexOrd())
                         PLAN_FIN->(dbsetorder(1))

                         if PLAN_FIN->(dbseek(fCODIGO))
                            qmensa("Sub-grupo j  cadastrado !","B")
                            fCODIGO := ""
                            return .F.
                         endif
                         if ! PLAN_FIN->(dbseek(left(fCODIGO,2)))
                            qmensa("Grupo n„o cadastrado !","B")
                            fCODIGO := ""
                            return .F.
                         endif
                         PLAN_FIN->(dbsetorder(nIndex))
                      endif
                   endif

                   if nTIPO == 1 //len(alltrim(fCODIGO)) <> 9
                      XNIVEL := 1
                   endif


           endcase



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR PRODUTO ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Conta ?")
      if PLAN_FIN->(qrlock())
         PLAN_FIN->(dbdelete())
         PLAN_FIN->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHER TIPO DE INCLUSAO ____________________________________

function i_tipo_inc
   nTIPO := alert("Voce est  incluindo...",{"CONTA","SUB-TITULO"})
return


