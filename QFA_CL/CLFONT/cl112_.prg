/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE VENDEDORES
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:

function cl112
CLI_PR->(qview({{"Codigo/Codigo"               ,1},;
             {"left(Cliente,40)/Razao"         ,3},;
             {"fgrupo()/Grupo"                 ,0}},"P",;
             {NIL,"c112a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))
             
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c112a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(5,0,"B112A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , CLI_PR->Codigo     )
      qrsay ( XNIVEL++ , CLI_PR->Cod_cli    );CLI1->(Dbseek(CLI_PR->Cod_Cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,35))
      qrsay ( XNIVEL++ , CLI_PR->Cod_grupo );GRUPO_PR->(Dbseek(CLI_PR->Cod_grupo))
      qrsay ( XNIVEL++ , left(GRUPO_PR->Descricao,35))

      if cOPCAO == "C"
         i_proc_item()
         keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"  })
   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_CLI,"@!")                       },"COD_CLI"    })
   aadd(aEDICAO,{{ || NIL                                                 },"RAZAO"  })
   aadd(aEDICAO,{{ || view_grupo(-1,0,@fCOD_GRUPO,"@!")                   },"GRUPO"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL  })



   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CLI_PR->(qpublicfields())
   iif(cOPCAO=="I",CLI_PR->(qinitfields()),CLI_PR->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CLI_PR->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. CLI_PR->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_prec with CONFIG->Cod_prec + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_prec,5))
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      CLI_PR->(qreplacefields())

   else

      if empty(CLI_PR->Codigo) .and. empty(CLI_PR->Cod_cli)
         CLI_PR->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   //if cOPCAO == "I" ; keyboard "I" ; endif

   i_proc_item()
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREG,nINDEX := 0

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "COD_CLI"

         if empty(fCOD_CLI) ; return .F. ; endif
         qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))

         nREG := CLI_PR->(Recno())
         nINDEX := CLI_PR->(Indexord())
         CLI_PR->(Dbsetorder(2))

         if cOPCAO == "I"
            if CLI_PR->(dbseek(fCOD_CLI))
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

         CLI_PR->(Dbgoto(nREG))
         CLI_PR->(Dbsetorder(nINDEX))

      case cCAMPO == "COD_GRUPO"

         if empty(fCOD_GRUPO) ; return .F. ; endif
         qrsay(XNIVEL,fCOD_GRUPO:=strzero(val(fCOD_GRUPO),5))


         if ! GRUPO_PR->(dbseek(fCOD_GRUPO))
            qmensa("Grupo n„o encontrado !","B")
            return .F.
         endif

         qrsay(XNIVEL+1,left(GRUPO_PR->Descricao,40))

   endcase

return .T.



static function i_exclusao
   if qconf("Confirma exclus„o dest(a) Tabela de Precos ?")

      if CLI_PR->(qrlock())
         CLI_PR->(dbdelete())
         CLI_PR->(qunlock())
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
 ITEN_GP->(qview({{"Cod_prod/Cod."                                        ,1},;
                  {"f112a()/Descri‡„o"                                    ,0},;
                  {"transform(Valor, '@E 999,999.99999')/Preco"    ,0}},;
                  "11002179S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_GP->Cod_grupo == CLI_PR->Cod_grupo",{||f112top()},{||f112bot()}},;
                  "..."))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f112top
   ITEN_GP->(dbsetorder(1))
   ITEN_GP->(dbseek(CLI_PR->Cod_grupo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f112bot
   ITEN_GP->(dbsetorder(1))
   ITEN_GP->(qseekn(CLI_PR->Cod_grupo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f112a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_GP->Cod_prod)
      PROD->(dbseek(left(ITEN_GP->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,30)
   endif
return cDESCRICAO


function fgrupo
   local cDESCRICAO := space(30)
   GRUPO_PR->(Dbsetorder(1))
   GRUPO_PR->(dbseek(left(CLI_PR->Cod_grupo,5)))
   cDESCRICAO := left(GRUPO_PR->Descricao,30)

return cDESCRICAO


