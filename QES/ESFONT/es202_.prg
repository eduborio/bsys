/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: BAIXA - RELATORIO DE COMBUSTIVEIS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: DEZEMBRO DE 1996
// OBS........:
// ALTERACOES.:

//#include "inkey.ch"
function es202

PROD->(dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS REQUISICOES DE MATERIAIS __________________________________

REL_COMB->(qview({{"Codigo/N£mero"      ,1},;
                {"Dt_relato/Data Rel."  ,0},;
                {"i_202a()/Filial"      ,0},;
                {"i_202b()/Centro Custo",0},;
                {"i_202d()/Baixado"     ,0}},"P",;
                {NIL,"i_202c",NIL,NIL},;
                NIL,q_msg_acesso_usr()+"/<B>aixa do Estoque"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DA FILIAL _______________________________________________

function i_202a
   FILIAL->(dbseek(REL_COMB->Filial))
return left(FILIAL->Razao,25)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function i_202b
   CCUSTO->(dbseek(REL_COMB->C_custo))
return left(CCUSTO->Descricao,23)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM SE FOI BAIXADO  _________________________________________

function i_202d
   local cSIMNAO := "  NŽO"
   if REL_COMB->Bx_estoque
      cSIMNAO := "  SIM"
   endif
return cSIMNAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_202c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO=="B"
      if ! REL_COMB->Bx_estoque
         i_baixa_estoque()
      else
         qmensa("Baixa j  foi realizada !!","B")
         return
      endif
   endif

   if cOPCAO == "A" .and. REL_COMB->Bx_estoque
      qmensa("Foi baixado, altera‡„o proibida !","B")
      return ""
   endif

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B202A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

   REL_COMB->(dbgotop())

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,21 , REL_COMB->Codigo           )
      qsay ( 06,68 , dtoc(REL_COMB->Dt_Relato)  )
      qsay ( 07,21 , REL_COMB->Filial           ) ; FILIAL->(dbseek(REL_COMB->Filial))
      qsay ( 07,34 , left(FILIAL->Razao,30)      )
      qsay ( 08,21 , REL_COMB->C_custo          ) ; CCUSTO->(dbseek(REL_COMB->C_custo))
      qsay ( 08,34 , left(CCUSTO->Descricao,30)      )
      qsay ( 09,21 , REL_COMB->Tipo             ) ; TIPOCONT->(dbseek(REL_COMB->Tipo) )
      qsay ( 09,30 , alltrim(TIPOCONT->Descricao)   )
      qsay ( 10,21 , REL_COMB->Cod_prod         ) ; PROD->(dbseek(REL_COMB->Cod_prod))
      qsay ( 10,30 , left(PROD->Descricao,40)   )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(6,21,@fCODIGO     ,"999999",NIL             )} ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(6,68,@fDT_RELATO ,"@D",                     )} ,"DT_RELATO"})
   aadd(aEDICAO,{{ || view_filial(7,21,@fFILIAL                         )} ,"FILIAL"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   aadd(aEDICAO,{{ || view_ccusto(8,21,@fC_CUSTO                        )} ,"C_CUSTO"  })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do centro
   aadd(aEDICAO,{{ || view_tipocont(09,21,@fTIPO                         )}  ,"TIPO"    })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do tipo
   aadd(aEDICAO,{{ || view_prod(10,21,@fCOD_PROD                        )} ,"COD_PROD" })
   aadd(aEDICAO,{{ || NIL                                                } ,NIL        })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.

      qgirabarra()

      REL_COMB->(qpublicfields())

      iif(cOPCAO=="I", REL_COMB->(qinitfields()), REL_COMB->(qcopyfields()))

      XNIVEL := 1
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );REL_COMB->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if REL_COMB->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         REL_COMB->(qreplacefields())

      endif

      dbunlockall()

      i_proc_prods()
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
      case cCAMPO == "CODIGO"
           qsay(6,21,fCODIGO :=strzero(val(fCODIGO),6))
           if cOPCAO == "I"
              if REL_COMB->(dbseek(fCODIGO))
                 qmensa("Relat¢rio j  Cadastrado !","B")
                 return .F.
              endif
           else
              if ! REL_COMB->(dbseek(fCODIGO))
                 qmensa("Relat¢rio n„o Cadastrado !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "DT_RELATO"
           if empty(fDT_RELATO) ; return .F. ; endif

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(7,21,fFILIAL)
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(7,34,left(FILIAL->Razao,40))

      case cCAMPO == "C_CUSTO"
           if empty(fC_CUSTO) ; return .F. ; endif
           qsay(8,21,fC_CUSTO)
           CCUSTO->(dbsetorder(4))
           if ! CCUSTO->(dbseek(fC_CUSTO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif
           qsay(8,34,CCUSTO->Descricao)

      case cCAMPO == "TIPO"
           if empty(fTIPO) ; return .F. ; endif
           qsay(09,21,fTIPO:=strzero(val(fTIPO),6))
           if ! TIPOCONT->(dbseek(fTIPO))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif
           qsay(09,30,alltrim(TIPOCONT->Descricao))

      case cCAMPO == "COD_PROD"

           qsay(10,21,fCOD_PROD:=strzero(val(fCOD_PROD),5))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif


           qsay ( 10,30 , left(PROD->Descricao,40) )

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR RELATORIO DE COMBUSTIVEL ___________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Relat¢rio de Combust¡vel ?")
      if ITENS_RC->(qflock()) .and. REL_COMB->(qrlock())
         ITENS_RC->(dbseek(REL_COMB->Codigo))
         do while ! ITENS_RC->(eof()) .and. ITENS_RC->Cod_relcom == REL_COMB->Codigo
            ITENS_RC->(dbdelete())
            ITENS_RC->(dbskip())
         enddo
         REL_COMB->(dbdelete())
         REL_COMB->(qunlock())
         ITENS_RC->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc_prods

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

ITENS_RC->(qview({{"f202a()/Ve¡culos"                                    ,0},;
                  {"f202b()/Equipamentos"                                ,0},;
                  {"transform(Quantidade,'@E 9999.99999')/Quantidade"    ,0},;
                  {"f202c()/Valor"                                       ,0}},;
                  "11002379S",;
                  {NIL,"f202d",NIL,NIL},;
                  {"ITENS_RC->Cod_relcom == REL_COMB->Codigo",{||f202top()},{||f202bot()}},;
                  "<ESC> para sair/<I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f202top
   ITENS_RC->(dbsetorder(1))
   ITENS_RC->(dbseek(REL_COMB->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f202bot
   ITENS_RC->(dbsetorder(1))
   ITENS_RC->(qseekn(REL_COMB->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO VEICULO __________________________________________

function f202a
   VEICULOS->(dbseek(ITENS_RC->Cod_veic))
return left(VEICULOS->Descricao,21)

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO EQUIPTO __________________________________________

function f202b
   EQUIPTO->(dbseek(ITENS_RC->Cod_equipt))
return left(EQUIPTO->Descricao,21)

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO ITEM ____________________________________________

function f202c
   INVENT->(dbseek(REL_COMB->Filial+REL_COMB->Cod_prod))
return transform(INVENT->Preco_uni * ITENS_RC->Quantidade,"@E 9,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f202d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B202B","QBLOC.GLO",1)
      i_processa_acao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITENS_RC->Cod_veic         ) ; VEICULOS->(dbseek(ITENS_RC->Cod_veic))
      qrsay ( XNIVEL++ , left(VEICULOS->Descricao,40)           )

      qrsay ( XNIVEL++ , ITENS_RC->Cod_equipt       ) ; EQUIPTO->(dbseek(ITENS_RC->Cod_equipt))
      qrsay ( XNIVEL++ , left(EQUIPTO->Descricao ,40)           )

      qrsay ( XNIVEL++ , ITENS_RC->Quantidade ,"@E 9999.99999"  )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()          ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_rc() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_veic(-1,0,@fCOD_VEIC                    ) } ,"COD_VEIC"})
   aadd(aEDICAO,{{ || NIL                                            } ,NIL       })

   aadd(aEDICAO,{{ || view_equip(-1,0,@fCOD_EQUIPT                 ) } ,"COD_EQUIPT"})
   aadd(aEDICAO,{{ || NIL                                            } ,NIL       })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 9999.99999"         ) } ,"QUANTIDADE"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITENS_RC->(qpublicfields())

   iif(cOPCAO=="I",ITENS_RC->(qinitfields()),ITENS_RC->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   if cOPCAO == "I"
      fUNIDADE := "009"
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITENS_RC->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if REL_COMB->(qrlock()) .and. ITENS_RC->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fCOD_RELCOM := fCODIGO
      endif

      ITENS_RC->(qreplacefields())
      ITENS_RC->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "COD_VEIC"
           if ! empty(fCOD_VEIC)
              qrsay(XNIVEL,fCOD_VEIC:=strzero(val(fCOD_VEIC),5))
              if ! VEICULOS->(dbseek(fCOD_VEIC))
                 qmensa("Veiculo n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,VEICULOS->Descricao)
           endif

      case cCAMPO == "COD_EQUIPT"
           if ! empty(fCOD_EQUIPT)
              qrsay(XNIVEL,fCOD_EQUIPT:=strzero(val(fCOD_EQUIPT),5))
              if ! EQUIPTO->(dbseek(fCOD_EQUIPT))
                 qmensa("Equipamento n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,EQUIPTO->Descricao)
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS_RCAMENTOS DO REL_COMB ________________________________

static function i_exc_itens_rc

   if qconf("Confirma exclus„o do Produto ?")
      if ITENS_RC->(qrlock())
         ITENS_RC->(dbdelete())
         ITENS_RC->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc

setcolor("W/B")

ITENS_RC->(qview({{"f202a()/Ve¡culos"                                    ,0},;
                  {"f202b()/Equipamentos"                                ,0},;
                  {"transform(Quantidade,'@E 9999.99999')/Quant."        ,0},;
                  {"f202c()/Val. Total"                                  ,0}},;
                  "11002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITENS_RC->Cod_relcom == REL_COMB->Codigo",{||f202top()},{||f202bot()}},;
                 "<ESC> para sair" ))

return ""

/////////////////////////////////////////////////////////////////
// BAIXA DO PRODUTO _____________________________________________

static function i_baixa_estoque

   local lCONF
   local  cFATOR     := 1
   local cQUANTIDADE := 0
   local cSAL_ANT    := 0

 //if REL_COMB->(qrlock()) .and. PROD->(qflock())
   if REL_COMB->(qrlock()) .and. INVENT->(qflock())

      if ITENS_RC->(dbseek(REL_COMB->Codigo)) .and. ! REL_COMB->Bx_estoque

         // soma a quantidade de todos os itens para baixar no produto informado no relatorio

         do while ITENS_RC->Cod_relcom == REL_COMB->Codigo .and. ! ITENS_RC->(eof())
            cQUANTIDADE += ITENS_RC->Quantidade
            ITENS_RC->(dbskip())
         enddo

//       if PROD->(dbseek(REL_COMB->Cod_prod))
//
//          if PROD->Qtn_estoq <= 0  .or. PROD->Qtn_estoq < cQUANTIDADE
//
//             lCONF := qconf("N„o Existe estoque deste produto, gera Ordem de Compra ?")
//
//             if ! lCONF
//                return .F.
//             else
//                gera_oc()
//                return
//             endif
//
//          endif
//
//          iif (UNIDADE->(Dbseek(PROD->Unidade)), cFATOR:=UNIDADE->Fator ,)  // fator multiplicador da unidade
//
//          cSAL_ANT := PROD->Qtn_estoq
//
//          replace PROD->Qtn_estoq  with ( PROD->Qtn_estoq - (cQuantidade * cFATOR) )
//
//          replace REL_COMB->Bx_estoque with .T.
//
//          if MOVIMENT->(qrlock()) .and. MOVIMENT->(qappend()) // grava movimentacao do produto
//
//             replace MOVIMENT->Data       with REL_COMB->Dt_relato
//             replace MOVIMENT->Filial     with REL_COMB->Filial
//             replace MOVIMENT->Cod_prod   with PROD->Codigo
//             replace MOVIMENT->Quantidade with cQUANTIDADE
//             replace MOVIMENT->Val_uni    with PROD->Preco_unit
//             replace MOVIMENT->Saldo_ant  with cSAL_ANT
//             replace MOVIMENT->Tipo       with "S"
//             replace MOVIMENT->Contabil   with .T.
//
//          endif
//
//       endif

         if INVENT->(dbseek(REL_COMB->Filial+REL_COMB->Cod_prod))

            if INVENT->Quant_atu <= 0  .or. INVENT->Quant_atu < cQUANTIDADE

               lCONF := qconf("N„o Existe estoque deste produto, gera Ordem de Compra ?")

               if ! lCONF
                  return .F.
               else
                  gera_oc()
                  return
               endif

            endif

            cSAL_ANT := INVENT->Quant_atu

            replace INVENT->Quant_atu with ( INVENT->Quant_atu - cQUANTIDADE )

            replace REL_COMB->Bx_estoque with .T.

            if MOVIMENT->(qrlock()) .and. MOVIMENT->(qappend()) // grava movimentacao do produto

               replace MOVIMENT->Data       with REL_COMB->Dt_relato
               replace MOVIMENT->Filial     with REL_COMB->Filial
               replace MOVIMENT->Cod_prod   with PROD->Codigo
               replace MOVIMENT->Quantidade with cQUANTIDADE
               replace MOVIMENT->Val_uni    with INVENT->Preco_uni
               replace MOVIMENT->Saldo_ant  with cSAL_ANT
               replace MOVIMENT->Tipo       with "S"
               replace MOVIMENT->Contabil   with .T.

            endif

         endif

      endif

   endif

   dbunlockall()

return

////////////////////////////////////////////////////////////////////////////////////
// FUNCAO QUE GERA ORDEM DE COMPRA A PARTIR DA BAIXA DO RELATORIO DE COMBUSTIVEIS___

static function gera_oc

    local cQUANTIDADE := 0

    if REL_COMB->(qrlock()) .and. ORDEM->(qflock()) .and. CONFIG->(qrlock()) .and. ORDEM->(qappend())

       replace ORDEM->Codigo        with strzero(CONFIG->Cod_ordem + 1,5)
       replace ORDEM->Data          with REL_COMB->Dt_relato
       replace ORDEM->Filial        with REL_COMB->Filial

       replace CONFIG->Cod_ordem    with (CONFIG->Cod_ordem + 1)

       ITENS_RC->(Dbseek(REL_COMB->Codigo))

       // soma a quantidade de todos os itens para gerar ordem de compra
       do while ITENS_RC->Cod_relcom == REL_COMB->Codigo .and. ! ITENS_RC->(eof())
          cQUANTIDADE += ITENS_RC->Quantidade
          ITENS_RC->(dbskip())
       enddo

       if ITENS_RC->(qrlock()) .and. ITENS_OC->(qrlock()) .and. ITENS_OC->(qappend())

          replace ITENS_OC->Cod_ord    with ORDEM->Codigo
          replace ITENS_OC->Produto    with REL_COMB->Cod_prod
          replace ITENS_OC->Quantidade with cQUANTIDADE

       endif

       dbunlockall()

    endif

return

