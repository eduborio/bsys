/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE SITUACAO TRIBUTARIA
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2001
// OBS........:
// ALTERACOES.:

function cl120
CLASSIF->(qview({{"Codigo/Codigo"         ,1},;
          {"Descricao/Descricao"           ,0}},"P",;
             {NIL,"c120a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c120a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(7,0,"B120A","QBLOC.GLO",1)
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

      qrsay ( XNIVEL++ , CLASSIF->Codigo                     )
      qrsay ( XNIVEL++ , CLASSIF->Descricao                  )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif


   endif
   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"99")       },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")        },"DESCRICAO"    })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CLASSIF->(qpublicfields())
   iif(cOPCAO=="I",CLASSIF->(qinitfields()),CLASSIF->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CLASSIF->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. CLASSIF->(iif(cOPCAO=="I",qappend(),qrlock()))

      CLASSIF->(qreplacefields())
      //CLASSIF->(dbgotop())

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
              if CLASSIF->(dbseek(fCODIGO))
                 qmensa("Classificacao Fiscal ja cadastrada !","B")
                 return .F.
              endif
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR TRANSPORTADORA _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Classificacao Fiscal ?")

      if IT_CLASS->(Dbseek(CLASSIF->Codigo)).and. IT_CLASS->(qflock())
         do while ! IT_CLASS->(eof()) .and. IT_CLASS->Id_classif == CLASSIF->Codigo
            IT_CLASS->(dbdelete())
            IT_CLASS->(dbskip())
         enddo
      endif

      if CLASSIF->(qrlock())
         CLASSIF->(dbdelete())
         CLASSIF->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_proc_item


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

 IT_CLASS->(qview({{"uf_sigla/Sigla"                                      ,2},;
                  {"f120a()/Descri‡„o"                                   ,0},;
                  {"transform(Mva, '@E 99.99')/M.V.A."                  ,0}},;
                  "12002179S",;
                  {NIL,"f120d",NIL,NIL},;
                  {"IT_CLASS->Id_classif == CLASSIF->Codigo",{||f120top()},{||f120bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f120top
   IT_CLASS->(dbsetorder(1))
   IT_CLASS->(dbseek(CLASSIF->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f120bot
   IT_CLASS->(dbsetorder(1))
   IT_CLASS->(qseekn(CLASSIF->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f120a

   local cDESCRICAO := space(30)
   UFS->(dbseek(IT_CLASS->uf_sigla))
   cDESCRICAO := left(UFS->Descricao,30)

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f120d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(05,08,"B120B","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , IT_CLASS->Uf_sigla            , "@R 99"                    ) ; UFS->(dbseek(IT_CLASS->uf_sigla))
      qrsay ( XNIVEL++ , left(UFS->Descricao,40)                                      )
      qrsay ( XNIVEL++ , IT_CLASS->Mva,"@E 99.99")

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_cl() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_ufs(-1,0,@fUF_SIGLA                     ) } ,"UF_SIGLA"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMVA,"@E 99.99"                  ) } ,"MVA"  })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   IT_CLASS->(qpublicfields())

   iif(cOPCAO=="I",IT_CLASS->(qinitfields()),IT_CLASS->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; IT_CLASS->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if CLASSIF->(qrlock()) .and. IT_CLASS->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fID_CLASSIF := fCODIGO
      endif

      IT_CLASS->(qreplacefields())
      IT_CLASS->(qunlock())

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

      if IT_CLASS->(qrlock())
         IT_CLASS->(dbdelete())
         IT_CLASS->(qunlock())
      else
         qm3()
      endif
   endif

return

static function i_atu_lanc
setcolor("W/B")

 IT_CLASS->(qview({{"uf_sigla/Sigla"                                     ,2},;
                  {"f120a()/Descri‡„o"                                   ,0},;
                  {"transform(Mva, '@E 99.99')/M.V.A."                  ,0}},;
                  "12002179S",;
                  {NIL,NIL,NIL,NIL},;
                  {"IT_CLASS->Id_classif == CLASSIF->Codigo",{||f120top()},{||f120bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))
return



