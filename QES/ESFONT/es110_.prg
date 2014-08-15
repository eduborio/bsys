/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: COMPOSICAO DE UM PRODUTO ACABADO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 2002
// OBS........:
// ALTERACOES.:
function es110

#include "inkey.ch"

PROD->(dbsetorder(4))
if ! quse(XDRV_CP,"CONFIG",{},"E","PROV")
   qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF  !! Tente novamente.")
   return .F.
endif

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DA COMPOSICAO DE PRODUTO ACABADO ______________________________

ORD_PROD->(qview({{"Codigo/C¢digo"       ,1},;
                 {"f110h()/Produto"      ,0},;
                 {"Cod_cor/C.Cor  "      ,0},;
                 {"f110a()/Cliente" ,0}},"P",;
                 {NIL,"i_110c",NIL,NIL},;
                 NIL,q_msg_acesso_usr()+" Ca<R>rega em estoque/ Im<P>rime"))
return




//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR PRODUTO ACABADO______________________________________

function f110h
   local cDESCRICAO := space(35)
   if ! empty(ORD_PROD->Cod_comp)
      COMPOSIC->(dbseek(ORD_PROD->Cod_comp))
      cDESCRICAO := left(COMPOSIC->Descricao,20)
   endif

return cDESCRICAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR RAZAO DO ClIENTE_______________________________________

function f110a
   local cDESCRICAO := space(35)
   if ! empty(ORD_PROD->Cod_cli)
      CLI1->(dbseek(ORD_PROD->Cod_cli))
      cDESCRICAO := left(CLI1->Razao,35)
   endif

return cDESCRICAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_110c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "I*A*E*C*R*P"
      qlbloc(5,0,"B110A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)

   ORD_PROD->(dbgotop())

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,21 , ORD_PROD->Codigo           )
      qsay ( 06,49 , ORD_PROD->Data            )
      qsay ( 07,21 , ORD_PROD->Cod_cli         ) ;CLI1->(dbseek(ORD_PROD->Cod_cli))
      qsay ( 07,29 , left(CLI1->Razao,49)  )
      qsay ( 08,21 , ORD_PROD->Cod_comp        ) ;COMPOSIC->(dbseek(ORD_PROD->Cod_comp))
      qsay ( 08,29 , COMPOSIC->Descricao  )
      qsay ( 09,21 , transf(ORD_PROD->Quantidade,"@R 99999999.999"))
      qsay ( 10,21 , ORD_PROD->Cod_cor)
      qsay ( 11,21 , ORD_PROD->Cor)

      if cOPCAO == "C"
        i_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait()        ; return ; endif
   if cOPCAO == "E" ; i_exclusao()   ; return ; endif
   if cOPCAO == "R" ; i_carrega()    ; return ; endif
   if cOPCAO == "P" ; i_imp_ordem()  ; return ; endif
   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(6,21,@fCODIGO     ,"99999",NIL         )} ,"CODIGO"     })
   aadd(aEDICAO,{{ || qgetx(6,49,@fDATA ,"@D"                      )} ,"DATA"       })
   aadd(aEDICAO,{{ || view_cli(7,21,@fCOD_CLI                      )} ,"COD_CLI"    })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL          })
   aadd(aEDICAO,{{ || view_comp(8,21,@fCOD_COMP                    )} ,"COD_COMP"   })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL          })
   aadd(aEDICAO,{{ || qgetx(9,21,@fQUANTIDADE ,"@R 99999999.999"  )} ,"QUANTIDADE" })
   aadd(aEDICAO,{{ || qgetx(10,21,@fCOD_COR                        )} ,"COD_COR"    })
   aadd(aEDICAO,{{ || qgetx(11,21,@fCOR ,"@!"                      )} ,"COR"        })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.

      qgirabarra()

      ORD_PROD->(qpublicfields())

      iif(cOPCAO=="I", ORD_PROD->(qinitfields()), ORD_PROD->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );ORD_PROD->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock()) .and. ORD_PROD->(iif(cOPCAO=="I",qappend(),qrlock()))

         if cOPCAO == "I"
            replace CONFIG->cod_ord with CONFIG->cod_ord+1
            qsay ( 6,21, strzero(CONFIG->cod_ord,5))
            qmensa("C¢digo Gerado: "+strzero(CONFIG->cod_ord,5),"B")
            fCODIGO := strzero(CONFIG->cod_ord,5)
         endif

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         ORD_PROD->(qreplacefields())

         if cOPCAO == "I"
            if ITN_ORD->(qrlock())
               COMPOSIC->(dbseek(ORD_PROD->Cod_comp))
               ITEN_CMP->(dbseek(COMPOSIC->Codigo))
               do while ! ITEN_CMP->(eof()) .and. ITEN_CMP->Cod_Comp == COMPOSIC->Codigo
                  ITN_ORD->(qappend())
                  replace ITN_ORD->Cod_ord with ORD_PROD->Codigo
                  replace ITN_ORD->Cod_Prod with ITEN_CMP->Cod_prod
                  ITEN_CMP->(dbskip())
               enddo
               ITN_ORD->(dbcommit())
               ITN_ORD->(qunlock())
            else
               qm3()
            endif
         endif

      endif

      dbunlockall()

      i_procc()
      keyboard chr(27)

   enddo


return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI) ; return .F. ; endif
           qsay(7,21,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif
           qsay(7,29,left(CLI1->Razao,39))



      case cCAMPO == "COD_COMP"

           if empty(fCOD_COMP) ; return .F. ; endif
           qsay(8,21,fCOD_COMP:=strzero(val(fCOD_COMP),5))
           if ! COMPOSIC->(dbseek(fCOD_COMP))
              qmensa("Produto Acabado n„o Cadastrado !","B")
              return .F.
           else
              qsay(8,29,left(COMPOSIC->Descricao,49))
           endif



   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR COMPOSICAO DE PRODUTO ACABADO _____________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Ordem de Producao ?")
      if ITN_ORD->(qflock()) .and. ORD_PROD->(qrlock())
         ITN_ORD->(dbseek(ORD_PROD->Codigo))
         do while ! ITN_ORD->(eof()) .and. ITN_ORD->cod_ord == ORD_PROD->Codigo
            ITN_ORD->(dbdelete())
            ITN_ORD->(dbskip())
         enddo
         ORD_PROD->(dbdelete())
         ORD_PROD->(qunlock())
         ITN_ORD->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_procc

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PROD->(Dbsetorder(4))

ITN_ORD->(qview({{"Cod_prod/C¢digo"                                   ,0},;
                 {"f110b()/Produto"                                   ,0},;
                 {"transf(Quantidade,'@R 99999999.999')/Quantidade"  ,0}},;
                 "12002379S",;
                 {NIL,"f110d",NIL,NIL},;
                 {"ITN_ORD->cod_ord == ORD_PROD->Codigo",{||f110top()},{||f110bot()}},;
                 "<ESC> para sair/<I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f110top
   ITN_ORD->(dbsetorder(1))
   ITN_ORD->(dbseek(ORD_PROD->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f110bot
   ITN_ORD->(dbsetorder(1))
   ITN_ORD->(qseekn(ORD_PROD->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO ______________________________

function f110b
   local cDESCRICAO := space(35)
   PROD->(Dbsetorder(4))
   if ! empty(ITN_ORD->Cod_prod)
      PROD->(dbseek(ITN_ORD->Cod_prod))
      cDESCRICAO := left(PROD->Descricao,35)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f110d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B110B","QBLOC.GLO",1)
      i_procaessa_acao()
   endif

   setcursor(nCURSOR)

   select ITN_ORD

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_procaessa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITN_ORD->Cod_prod                ) ; PROD->(dbseek(ITN_ORD->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,35)           )
      qrsay ( XNIVEL++ , ITN_ORD->Quantidade,"@R 99999999.999")

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()          ; return ; endif
   if cOPCAO == "E" ; i_exc_ITEN_ACA() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD              ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                      } ,NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE,"@R 99999999.999")} ,"QUANTIDADE"})


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITN_ORD->(qpublicfields())

   iif(cOPCAO=="I",ITN_ORD->(qinitfields()),ITN_ORD->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITN_ORD->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if ORD_PROD->(qrlock()) .and. ITN_ORD->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fCOD_ORD := fCODIGO
      endif

      ITN_ORD->(qreplacefields())
      ITN_ORD->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   ORD_PROD->(dbseek(fCODIGO))

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "COD_PROD"

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(PROD->Descricao,30))
              fCOD_ORD := fCODIGO
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITEN DE PRODUTO ACABADO _____________________________

static function i_exc_iten_aca

   if qconf("Confirma exclus„o do Produto ?")
      if ITN_ORD->(qrlock())
         ITN_ORD->(dbdelete())
         ITN_ORD->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_lanc

setcolor("W/B")
ITN_ORD->(qview({{"Cod_prod/C¢digo"                                   ,2},;
                 {"f110b()/Produto"                                   ,0},;
                 {"transf(Quantidade,'@R 99999999.999')/Quantidade"  ,0}},;
                 "12002379S",;
                 {NIL,NIL,NIL,NIL},;
                 {"ITN_ORD->cod_ord == ORD_PROD->Codigo",{||f110top()},{||f110bot()}},;
                 "<ESC> para sair"))

return ""

static function i_carrega
   if ORD_PROD->Carregado == .T.
      qmensa("Ordem de producao ja carregada em estoque !","B")
      return .F.
   endif

   ITN_ORD->(dbsetorder(1))
   ITN_ORD->(dbgotop())
   ITN_ORD->(dbseek(ORD_PROD->Codigo))

   do while ! ITN_ORD->(eof()) .and. ITN_ORD->Cod_ord == ORD_PROD->Codigo

      if INVENT->(Dbseek("0001"+right(ITN_ORD->Cod_Prod,5)+"0000000000")) .and. INVENT->(qrlock())
         replace INVENT->Quant_atu    with ( INVENT->Quant_atu  - ITN_ORD->Quantidade)
      endif

      INVENT->(qunlock())

      ITN_ORD->(dbskip())

   enddo

   dbunlockall()

   PROD->(dbsetorder(8))
   if PROD->(dbseek(ORD_PROD->Cod_cor+ORD_PROD->Cod_comp))
      if INVENT->(dbseek("0001"+right(PROD->Codigo,5)+"0000000000"))
         if INVENT->(qrlock())
            replace INVENT->Quant_atu with INVENT->Quant_atu + ORD_PROD->Quantidade
            INVENT->(qunlock())
         endif
      else
         INVENT->(qrlock())
         INVENT->(qappend())
         replace INVENT->Data        with ORD_PROD->Data
         replace INVENT->Filial      with "0001"
         replace INVENT->Cod_prod    with right(PROD->Codigo)
         replace INVENT->Quantidade  with ORD_PROD->Quantidade
         replace INVENT->Quant_atu   with ORD_PROD->Quantidade
         replace INVENT->Preco_uni   with 1
         replace INVENT->Lote        with "0000000000"
         INVENT->(qunlock())

      endif
   else
      //PROD->(dbsetorder(1))
      if PROD->(qflock()) .and. PROV->(qrlock())
         PROD->(qappend())
         replace PROD->Codigo        with "0102" + strzero(PROV->Cod_prod + 1,5)
         replace PROD->Cod_ass       with ORD_PROD->Cod_cor
         replace PROD->Composic      with ORD_PROD->Cod_comp
         COMPOSIC->(dbseek(ORD_PROD->Cod_comp))
         replace PROD->Descricao     with  rtrim(COMPOSIC->Descricao) + " - " + ORD_PROD->Cod_cor
         replace PROD->Unidade       with "003"
         replace PROD->Prod_iss      with "N"
         replace PROV->cod_prod    with PROV->Cod_prod +1
         PROD->(qunlock())
         PROV->(qunlock())
      endif

      INVENT->(qrlock())
      INVENT->(qappend())
      replace INVENT->Data        with ORD_PROD->Data
      replace INVENT->Filial      with "0001"
      replace INVENT->Cod_prod    with strzero(PROV->Cod_prod,5)
      replace INVENT->Quantidade  with ORD_PROD->Quantidade
      replace INVENT->Quant_atu   with ORD_PROD->Quantidade
      replace INVENT->Preco_uni   with 1
      replace INVENT->Lote        with "0000000000"
      INVENT->(qunlock())

   endif
   if ORD_PROD->(qrlock())
      replace ORD_PROD->Carregado with .T.
      ORD_PROD->(qunlock())
   endif
return

static function i_imp_ordem
   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0

   cTITULO := "ORDEM DE PRODUCAO No."+ORD_PROD->Codigo+"   Data.: "+dtoc(ORD_PROD->Data)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,80)
      CLI1->(Dbseek(ORD_PROD->Cod_cli))
      COMPOSIC->(dbseek(ORD_PROD->Cod_comp))
      @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + CLI1->Razao
      @ prow()+1,0 say "Fantasia: "+CLI1->Fantasia
      @ prow()+1,0 say "Endereco: "+ CLI1->End_cob
      @ prow()+1,0 say "Produto.: "+ COMPOSIC->Descricao
      @ prow()+1,0 say "Quantidade a Produzir: "+transf(ORD_PROD->Quantidade,"@E 9999999.99")
      @ prow()+1,0 say "Codigo da Cor: "+ORD_PROD->Cod_cor + "  Cor.: " + ORD_PROD->Cor + "Telefone: "+ CLI1->Fone1

      @ prow()+1,0 say replicate("-",80)
   endif

   @ prow()+1,0 say "Produto                                                        Quantidade"
   @ prow()+1,0 say replicate("-",80)

   ITN_ORD->(Dbseek(ORD_PROD->Codigo))

   do while ! ITN_ORD->(eof()) .and. ITN_ORD->Cod_ord == ORD_PROD->Codigo

      PROD->(Dbseek(ITN_ORD->Cod_prod))
      @ prow()+1,0   say PROD->Descricao
      @ prow()  ,60  say transform(ITN_ORD->Quantidade, "@E 999999.999")

      ITN_ORD->(Dbskip())

   enddo

   @ prow()+1,0 say replicate("-",80)

   qstopprn()
return
