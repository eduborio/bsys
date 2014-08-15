/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE SITUACAO TRIBUTARIA
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2001
// OBS........:
// ALTERACOES.:

function cl133
PROD_ST->(qview({{"Codigo/Codigo"         ,1},;
          {"Descricao/Descricao"          ,2}},"P",;
             {NIL,"c133a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c133a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(7,0,"B133A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or. Lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , PROD_ST->Codigo                     )
      qrsay ( XNIVEL++ , PROD_ST->Descricao                  )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif


   endif
   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCODIGO   ,"99999")       },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")        },"DESCRICAO"    })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PROD_ST->(qpublicfields())
   iif(cOPCAO=="I",PROD_ST->(qinitfields()),PROD_ST->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PROD_ST->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. PROD_ST->(iif(cOPCAO=="I",qappend(),qrlock()))

      PROD_ST->(qreplacefields())
      //PROD_ST->(dbgotop())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   //if cOPCAO == "I" ; keyboard "I" ; endif

   i_proc_item()


return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO"

           if cOPCAO == "I"
              if PROD_ST->(dbseek(fCODIGO))
                 qmensa("Base de Calculo pra este Produto ja cadastrada !","B")
                 return .F.
              endif
           endif

           PROD->(dbsetorder(4))
           if PROD->(dbseek(fCODIGO))
              qrsay(XNIVEL+1,fDESCRICAO := PROD->Descricao)
           else
              qmensa("Produto nao encontrado!","BL")
              return .F.
           endif



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR TRANSPORTADORA _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta BC subst Tributaria ?")

      if IT_PROD->(Dbseek(PROD_ST->Codigo)).and. IT_PROD->(qflock())
         do while ! IT_PROD->(eof()) .and. IT_PROD->Id_prodst == PROD_ST->Codigo
            IT_PROD->(dbdelete())
            IT_PROD->(dbskip())
         enddo
      endif

      if PROD_ST->(qrlock())
         PROD_ST->(dbdelete())
         PROD_ST->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_proc_item


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

 IT_PROD->(qview({{"uf_sigla/Sigla"                                      ,2},;
                  {"f133a()/Descri‡„o"                                   ,0},;
                  {"transform(Pauta, '@E 99.99')/PAUTA"                  ,0}},;
                  "12002179S",;
                  {NIL,"f133d",NIL,NIL},;
                  {"IT_PROD->Id_prodst == PROD_ST->Codigo",{||f133top()},{||f133bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f133top
   IT_PROD->(dbsetorder(1))
   IT_PROD->(dbseek(PROD_ST->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f133bot
   IT_PROD->(dbsetorder(1))
   IT_PROD->(qseekn(PROD_ST->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f133a

   local cDESCRICAO := space(30)
   UFS->(dbseek(IT_PROD->uf_sigla))
   cDESCRICAO := left(UFS->Descricao,30)

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f133d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(05,08,"B133B","QBLOC.GLO",1)
      i_edicao_iten()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_edicao_iten

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fUF_SIGLA).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}


   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , IT_PROD->Uf_sigla            , "@R 99999"                    ) ; UFS->(dbseek(IT_PROD->uf_sigla))
      qrsay ( XNIVEL++ , left(UFS->Descricao,40)                                      )
      qrsay ( XNIVEL++ , IT_PROD->Pauta,"@E 99.99")

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_cl() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_ufs(-1,0,@fUF_SIGLA                     ) } ,"UF_SIGLA"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPauta,"@E 99.99"                  ) } ,"Pauta"  })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   IT_PROD->(qpublicfields())

   iif(cOPCAO=="I",IT_PROD->(qinitfields()),IT_PROD->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; IT_PROD->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if PROD_ST->(qrlock()) .and. IT_PROD->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fID_PRODST := fCODIGO
      endif

      IT_PROD->(qreplacefields())
      IT_PROD->(qunlock())

   else
      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "UF_SIGLA"
           qrsay(XNIVEL,fUF_SIGLA)

           if ! UFS->(dbseek(fUF_SIGLA))
              qmensa("Estado n„o encontrado !","B")
              return .F.
           endif

           qrsay ( XNIVEL+1 , left(UFS->Descricao,38) )



   endcase

return .T.

static function i_exc_itens_cl

   if qconf("Confirma exclus„o do Estado ?")

      if IT_PROD->(qrlock())
         IT_PROD->(dbdelete())
         IT_PROD->(qunlock())
      else
         qm3()
      endif
   endif

return

static function i_atu_lanc
setcolor("W/B")

 IT_PROD->(qview({{"uf_sigla/Sigla"                                     ,2},;
                  {"f133a()/Descri‡„o"                                   ,0},;
                  {"transform(Pauta, '@E 99.99')/PAUTA"                  ,0}},;
                  "12002179S",;
                  {NIL,NIL,NIL,NIL},;
                  {"IT_PROD->Id_prodst == PROD_ST->Codigo",{||f133top()},{||f133bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))
return



