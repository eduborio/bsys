/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE VENDEDORES
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:

function cl125
GRUPO_PR->(qview({{"Codigo/Codigo"               ,1},;
                 {"left(Descricao,40)/Descricao" ,2}},"P",;
                 {NIL,"c125a",NIL,NIL},;
                 NIL,q_msg_acesso_usr()+" /Im<P>rimir"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c125a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))


   if cOPCAO == "P"
      i_imprime()
   endif

   if cOPCAO $ XUSRA

      qlbloc(5,0,"B125A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fDescricao).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDescricao).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , GRUPO_PR->Codigo     )
      qrsay ( XNIVEL++ , GRUPO_PR->Descricao  )
      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")                        },"DESCRICAO"})


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   GRUPO_PR->(qpublicfields())
   iif(cOPCAO=="I",GRUPO_PR->(qinitfields()),GRUPO_PR->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; GRUPO_PR->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. GRUPO_PR->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_grupo with CONFIG->Cod_grupo + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_grupo,5))
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      GRUPO_PR->(qreplacefields())

   else

      if empty(GRUPO_PR->Codigo) .and. empty(GRUPO_PR->Descricao)
         GRUPO_PR->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   //if cOPCAO == "I" ; keyboard "I" ; endif

   i_proc_item()
   keyboard chr(27)



return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREG,nINDEX := 0

   if ! XFLAG ; return .T. ; endif

   do case

   endcase

return .T.



static function i_exclusao
   if qconf("Confirma exclus„o dest(a) Grupo de Tabela de Precos ?")

      if ITEN_GP->(Qflock())

         Do While ! ITEN_GP->(Eof()) .and. ITEN_GP->Cod_grupo == GRUPO_PR->Codigo
            ITEN_GP->(dbdelete())
            ITEN_GP->(dbskip())
         enddo
         ITEN_GP->(qunlock())

      endif

      if GRUPO_PR->(qrlock())
         GRUPO_PR->(dbdelete())
         GRUPO_PR->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

static function i_proc_item


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")


 PROD->(Dbsetorder(4))
 ITEN_GP->(qview({{"f125a()/Descri‡„o"                                    ,0},;
                  {"transform(Valor, '@E 999,999.99999')/Preco"    ,0}},;
                  "10002179S",;
                  {NIL,"f125d",NIL,NIL},;
                  {"ITEN_GP->Cod_grupo == GRUPO_PR->Codigo",{||f125top()},{||f125bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f125top
   ITEN_GP->(dbsetorder(1))
   ITEN_GP->(dbseek(GRUPO_PR->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f125bot
   ITEN_GP->(dbsetorder(1))
   ITEN_GP->(qseekn(GRUPO_PR->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f125a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_GP->Cod_prod)
      PROD->(dbseek(left(ITEN_GP->Cod_prod,5)))
      cDESCRICAO := PROD->Cod_ass + " - " + left(PROD->Descricao,20)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f125d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(05,08,"B125B","QBLOC.GLO",1)
      i_edicao_iten()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_edicao_iten

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}


   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_GP->Cod_prod            , "@R 99999"   ) ; PROD->(dbseek(left(ITEN_GP->Cod_prod,5)))
      qrsay ( XNIVEL++ , PROD->Cod_ass+ " - "+left(PROD->Descricao,33))
      qrsay ( XNIVEL++ , ITEN_GP->Valor,"@E 9,999,999.99")
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_pr() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR,"@E 9,999,999.99"         ) } ,"VALOR"  })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_GP->(qpublicfields())

   iif(cOPCAO=="I",ITEN_GP->(qinitfields()),ITEN_GP->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_GP->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if GRUPO_PR->(qrlock()) .and. ITEN_GP->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_GRUPO := fCODIGO
      endif

      ITEN_GP->(qreplacefields())
      ITEN_GP->(qunlock())

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

      case cCAMPO == "PROD"
           if ! empty(fCOD_PROD)
              if CONFIG->Modelo_fat == "1"
                 PROD->(dbsetorder(5))
                 if PROD->(dbseek(fCOD_PROD))
                    fCOD_PROD := right(PROD->Codigo,5)
                 else
                    PROD->(dbsetorder(3))
                    if PROD->(dbseek(fCOD_PROD))
                       ffCOD_PROD := right(PROD->Codigo,5)
                    endif
                 endif
                 PROD->(dbsetorder(4))
              endif

              if ! empty(fCOD_PROD)
                 qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

                 if ! PROD->(dbseek(fCOD_PROD))
                    qmensa("Produto n„o encontrado !","B")
                    return .F.
                 endif

                 if CONFIG->Modelo_fat == "1"
                    qrsay ( XNIVEL+1 , left(PROD->Descricao,15)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
                 else
                    qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )
                 endif

              endif
           endif



   endcase

return .T.

static function i_exc_itens_pr

   if qconf("Confirma exclus„o do Produto ?")

      if ITEN_GP->(qrlock())
         ITEN_GP->(dbdelete())
         ITEN_GP->(qunlock())
      else
         qm3()
      endif
   endif

return

static function i_atu_lanc
setcolor("W/B")

 PROD->(Dbsetorder(4))
 ITEN_GP->(qview({{"f125a()/Descri‡„o"                              ,0},;
                  {"transform(Valor, '@E 999,999.99999')/Preco"    ,0}},;
                  "10002179S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_GP->Cod_grupo == GRUPO_PR->Codigo",{||f125top()},{||f125bot()}},;
                  "<Esc> para sair."))

return

static function i_imprime

   qinitPrn()

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif


return

static function i_Impre_prn
local cTITULO := "Lista de Precos - "+GRUPO_PR->Descricao

   PROD->(dbsetorder(4))
   ITEN_GP->(dbsetorder(1))
   ITEN_GP->(dbgotop())
   ITEN_GP->(dbseek(GRUPO_PR->Codigo))

   do while ! ITEN_GP->(Eof()) .and. ITEN_GP->Cod_grupo == GRUPO_PR->Codigo

      if XPAGINA == 0 .or. prow() > 57
         @prow()+1,0 say XCOND1
         qpageprn()
         qcabecprn(cTITULO,134)
         @ prow()+1,0 say "Ref.      Produto                        Colecao                                    Preco Unit."
         @ prow()+1,0 say replicate("-",134)
      endif

      PROD->(dbseek(ITEN_GP->Cod_prod))
      @ prow()+1,00  say PROD->Cod_ass
      @ prow()  ,10  say left(PROD->Descricao,25)
      @ prow()  ,41  say left(PROD->Marca,15)
      @ prow()  ,85  say transf(ITEN_GP->Valor,"@E 999,999.99")

      ITEN_GP->(dbskip())

   enddo

   qstopprn(.F.)

return

static function i_impre_xls
local cTITULO := "Lista de Precos - "+GRUPO_PR->Descricao

   PROD->(dbsetorder(4))
   ITEN_GP->(dbsetorder(1))
   ITEN_GP->(dbgotop())
   ITEN_GP->(dbseek(GRUPO_PR->Codigo))

   do while ! ITEN_GP->(Eof()) .and. ITEN_GP->Cod_grupo == GRUPO_PR->Codigo

      if XPAGINA == 0
         qpageprn()
         @ prow()+1,0 say chr(9) + cTITULO + " 125"
         @ prow()+1,0 say "Ref."+chr(9)+"Produto"+Chr(9)+"Colecao"+chr(9)+"Preco Unit."
         @ prow()+1,0 say ""
      endif

      PROD->(dbseek(ITEN_GP->Cod_prod))
      @ prow()+1,00  say PROD->Cod_ass
      @ prow()  ,pcol() say chr(9)+left(PROD->Descricao,25)
      @ prow()  ,pcol() say chr(9)+left(PROD->Marca,15)
      @ prow()  ,pcol() say chr(9)+transf(ITEN_GP->Valor,"@E 999,999.99")

      ITEN_GP->(dbskip())

   enddo

   qstopprn(.F.)

return

