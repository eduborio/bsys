/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: REQUISICAO DE COMPRA ANTECIPADA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JUNHO DE 1997
// OBS........:
// ALTERACOES.: LUCIANO DA SILVA GORSKI
function es206

#include "inkey.ch"

private nTMP

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS REQUISICOES DE COMPRA ANTECIPADAS __________________________

ANTECIPA->(qview({{"Codigo/Codigo"          ,1},;
                 {"Data/Data"               ,0},;
                 {"i_206b()/Chegou da Loja" ,0},;
                 {"Nota/Chegou pela Nota"   ,0}},"P",;
                 {NIL,"i_206a",NIL,NIL},;
                  NIL,q_msg_acesso_usr()+"/Con<F>irma Chegada"))
return



//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_206b
  FILIAL->(Dbseek(ANTECIPA->Loja))
return left(FILIAL->Razao,41)


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_206a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      if (! empty(ANTECIPA->Nota))  .and. cOPCAO $ "AE"
         qmensa("Chegada da compra antecipada ja confirmada !!!","B")
         return .F.
      endif

      qlbloc(5,0,"B206A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   if cOPCAO == "F"

      if ! empty(ANTECIPA->Nota)
         qmensa("Chegada da compra antecipada ja confirmada !!!","B")
         return .F.
      endif

      qlbloc(7,2,"B206C","QBLOC.GLO",1)
      i_edi_1()

   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}
   Private cFILIAL:= Space(4)


// MONTA DADOS NA TELA ___________________________________________________________

    if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,21 , ANTECIPA->Codigo           )
      qsay ( 06,41 , ANTECIPA->LOJA             )
      qsay ( 06,68 , dtoc(ANTECIPA->Data)       )

      if cOPCAO == "C" .or. cOPCAO == "E"
        if cOPCAO == "E"
           keyboard chr(27)
           i_at_lanc()
           keyboard chr(27)
        else
          i_at_lanc()
          keyboard chr(27)
        endif
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(6,20,@fCODIGO     ,"@R 99999",NIL          )} ,"CODIGO"       })
   aadd(aEDICAO,{{ || view_filial(6,41,@fLOJA,"@R 9999"              )} ,"FILIAL"       })
   aadd(aEDICAO,{{ || qgetx(6,68,@fDATA       ,"@D",                   )} ,"DATA"         })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      ANTECIPA->(qpublicfields())

      iif(cOPCAO=="I", ANTECIPA->(qinitfields()), ANTECIPA->(qcopyfields()))

      XNIVEL := 1
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );ANTECIPA->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if ANTECIPA->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         ANTECIPA->(qreplacefields())

      endif

      dbunlockall()

      i_lanc()
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
           qsay(6,20,fCODIGO :=strzero(val(fCODIGO),5))
           if cOPCAO == "I"
              if ANTECIPA->(dbseek(fCODIGO))
                 qmensa("Requisi‡„o j  Cadastrada !","B")
                 return .F.
              endif
           else
              if ! ANTECIPA->(dbseek(fCODIGO))
                 qmensa("Requisi‡„o n„o Cadastrada !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "FILIAL"
           if empty(fLOJA) ; return .F. ; endif
           qsay(06,41,left(fLOJA,4))
           if ! FILIAL->(dbseek(fLOJA))
              qmensa("Filial (Loja) n„o encontrado !","B")
              return .F.
           endif
           Return .t.

      case cCAMPO == "DATA"
           if empty(fDATA) ; return .F. ; endif

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR REQUISICAO DE MATERIAL ___________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Requisi‡„o de Compra Antecipada ?")
      if ITEN_ANT->(qflock()) .and. ANTECIPA->(qrlock())
         ITEN_ANT->(dbseek(ANTECIPA->Codigo))
         do while ! ITEN_ANT->(eof()) .and. ITEN_ANT->Cod_ante == ANTECIPA->Codigo

            PROD->(Dbsetorder(4))
            PROD->(Dbseek(ITEN_ANT->Cod_prod))

//          if PROD->(qrlock())
//             replace PROD->Qtn_estoq with (PROD->Qtn_estoq - ITEN_ANT->Quantidade)
//             PROD->(qunlock())
//          endif

            if INVENT->(Dbseek(ANTECIPA->Loja+ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock()) .and. ITEN_ANT->(qrlock())
               replace INVENT->Quant_atu    with ( INVENT->Quant_atu  - ITEN_ANT->Quantidade )

               if LOTES->(dbseek(ITEN_ANT->Cod_prod+ANTECIPA->Loja+ITEN_ANT->Lote)) .and. LOTES->(qrlock())
                  Replace LOTES->Quantidade With (LOTES->Quantidade - ITEN_ANT->Quantidade)
                  LOTES->(qunlock())
               Endif
            endif

            ITEN_ANT->(dbdelete())
            INVENT->(qunlock())
            LOTES->(qunlock())
            ITEN_ANT->(dbskip())
         enddo

         ANTECIPA->(dbdelete())
         ANTECIPA->(qunlock())
         ITEN_ANT->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_lanc

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PROD->(Dbsetorder(4))

ITEN_ANT->(qview({{"Cod_Prod/Cod."                                        ,2},;
                  {"f206a()/Descri‡„o"                                    ,0},;
                  {"Cod_forn/Fornecedor"                                  ,0},;
                  {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                  {"lote/N£mero do Lote"                                  ,0}},;
                  "07002379S",;
                  {NIL,"f206d",NIL,NIL},;
                  {"ITEN_ANT->Cod_ante == ANTECIPA->Codigo",{||f206top()},{||f206bot()}},;
                  "<I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f206top
   ITEN_ANT->(dbsetorder(1))
   ITEN_ANT->(dbseek(ANTECIPA->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f206bot
   ITEN_ANT->(dbsetorder(1))
   ITEN_ANT->(qseekn(ANTECIPA->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f206a

   local cDESCRICAO := space(35)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_ANT->Cod_prod)
      PROD->(dbseek(left(ITEN_ANT->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,35)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f206b
   PROD->(dbseek(left(ITEN_ANT->Cod_produt,5)))
   UNIDADE->(dbseek(PROD->Unidade))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f206d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B206B","QBLOC.GLO",1)
      i_processa_acao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_ANT->Cod_prod            , "@R 99999"     ) ; PROD->(dbseek(left(ITEN_ANT->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                       ) ; FORN->(Dbseek(ITEN_ANT->Cod_forn))
      qrsay ( XNIVEL++ , PROD->Cod_fornec                               )
      qrsay ( XNIVEL++ , left(FORN->Razao,30)                           )
      INVENT->(Dbsetorder(4))
      INVENT->(dbseek("0001" + ITEN_ANT->Cod_prod))
      qrsay ( XNIVEL++ , INVENT->Quant_atu, "@R 999,999.99"               )
      qrsay ( XNIVEL++ , ITEN_ANT->Lote, "@R 9999999999"                )
      qrsay ( XNIVEL++ , ITEN_ANT->Quantidade, "@R 9999.99999"          )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_ITEN_ANT() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })

   aadd(aEDICAO,{{ || NIL                                            } ,"COD_FORN"})
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fLOTE, "@E 9999999999"       ) } ,"LOTE"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 9999.99999"    ) } ,"QUANTIDADE"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_ANT->(qpublicfields())

   iif(cOPCAO=="I",ITEN_ANT->(qinitfields()),ITEN_ANT->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_ANT->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if ANTECIPA->(qrlock()) .and. ITEN_ANT->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_ANTE := fCODIGO
      endif
      ITEN_ANT->(qreplacefields())
      ITEN_ANT->(qunlock())

      if INVENT->(Dbseek(fLOJA+fCOD_PROD+fLOTE)) .and. INVENT->(qrlock())

         replace INVENT->Quant_atu    with ( INVENT->Quant_atu  + ITEN_ANT->Quantidade )

         if LOTES->(dbseek(fCOD_PROD+fLOJA+fLOTE)) .and. LOTES->(qrlock())
            Replace LOTES->Quantidade With (LOTES->Quantidade + fQUANTIDADE)
            LOTES->(qunlock())
         Endif

      else
        qmensa("Produto n„o possui Inventario nesta Filial... Verifique...","B")
        return
      endif

      PROD->(Dbsetorder(4))
      PROD->(Dbseek(ITEN_ANT->Cod_prod))

//    if PROD->(qrlock())
//
//       replace PROD->Qtn_estoq with (PROD->Qtn_estoq + ITEN_ANT->Quantidade)
//       PROD->(qunlock())
//
//    endif

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

      case cCAMPO == "COD_PROD"

           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif
           LOTES->(dbSetFilter({|| Produto == fCOD_PROD .and. Filial == fLOJA }, 'Produto == fCOD_PROD .and. Filial == fLOJA'))

           qrsay ( XNIVEL+1 , left(PROD->Descricao,40) )

           fCOD_FORN := PROD->Cod_fornec

      case cCAMPO == "LOTE"
           LOTES->(dbSetFilter({|| Produto == fCOD_PROD .and. Filial == fLOJA }, 'Produto == fCOD_PROD .and. Filial == fLOJA'))

           if empty(fLOTE); return .t.; endif

           if ! LOTES->(dbseek(fCOD_PROD+fLOJA+fLOTE))
              qmensa("N£mero de Lote deste Produto nÆo encontrado...","B")
              fLOTE := "          "
              return .F.
           endif

      case cCAMPO == "QUANTIDADE"
           qrsay(XNIVEL+1,transform(PROD->Preco_unit*fQUANTIDADE, "@e 99,999,999.9999"))

      case cCAMPO == "COD_FORN"
           qrsay(XNIVEL,fCOD_FORN)
           qrsay(XNIVEL+1,left(FORN->Razao,30))
           INVENT->(dbsetorder(4))
           INVENT->(dbseek("0001"+fCOD_PROD))
           qrsay(XNIVEL+2,transform(INVENT->Quant_atu,"@e 999,999.99"))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITEN_ANTAMENTOS DO ANTECIPA ________________________________

static function i_exc_iten_ant

   if qconf("Confirma exclus„o do Produto ?")

      if ITEN_ANT->(qrlock())

         PROD->(Dbsetorder(4))
         PROD->(Dbseek(ITEN_ANT->Cod_prod))
//       if PROD->(qrlock())
//          replace PROD->Qtn_estoq with (PROD->Qtn_estoq - ITEN_ANT->Quantidade)
//          PROD->(qunlock())
//       endif

         if INVENT->(Dbseek(ANTECIPA->Loja+ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock()) .and. ITEN_ANT->(qrlock())
            replace INVENT->Quant_atu    with ( INVENT->Quant_atu  - ITEN_ANT->Quantidade )
            replace INVENT->Preco_uni    with ( INVENT->Preco_uni  - ITEN_ANT->Val_uni    ) / 2

            if LOTES->(dbseek(ITEN_ANT->Cod_prod+ANTECIPA->Loja+ITEN_ANT->Lote)) .and. LOTES->(qrlock())
               Replace LOTES->Quantidade With (LOTES->Quantidade - ITEN_ANT->Quantidade)
               LOTES->(qunlock())
            Endif
         endif

         ITEN_ANT->(dbdelete())
         INVENT->(qunlock())
         LOTES->(qunlock())
         ITEN_ANT->(qunlock())

      else
         qm3()
      endif

   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_at_lanc

setcolor("W/B")

ITEN_ANT->(qview({{"Cod_Prod/Cod."                                        ,2},;
                  {"f206a()/Descri‡„o"                                    ,0},;
                  {"Cod_forn/Fornecedor"                                  ,0},;
                  {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                  {"lote/N£mero do Lote"                                  ,0}},;
                  "07002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_ANT->Cod_ante == ANTECIPA->Codigo",{||f206top()},{||f206bot()}},;
                 "<ESC> para sair" ))

return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR ANTECIPAAO ___________________________________________

function i_comp

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := 0

   cTITULO := "EMISSAO DE COMPRA ANTECIPADA DE MATERIAIS No."+transform(CODIGO, "@R 999999")+"   Data Emissao: "+dtoc(ANTECIPA->Dt_requisi)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif


   qpageprn()
   qcabecprn(cTITULO,80)
   @ prow(),pcol() say XCOND1
   @ prow()+1,0 say "ITEN     UN.  QUANT.   PRODUTO  FORNECEDOR  DESCRICAO DO PRODUTO                            UNITARIO                 TOTAL"
   @ prow()+1,0 say ""

   ITEN_ANT->(Dbseek(ANTECIPA->Codigo))

   nCONT := 1

   do while ! ITEN_ANT->(eof()) .and. ITEN_ANT->Cod_req == ANTECIPA->Codigo

      PROD->(Dbseek(ITEN_ANT->Cod_produt))
      @ prow()+1,0  say strzero(nCONT,2)
      UNIDADE->(Dbseek(PROD->Unidade))
      @ prow()  ,09  say UNIDADE->Sigla
      @ prow()  ,14  say transform(ITEN_ANT->Quantidade, "@E 999.99")
      @ prow()  ,23  say PROD->Cod_ass
      @ prow()  ,32  say PROD->Cod_fornec
      @ prow()  ,44  say left(PROD->Descricao,40)
      @ prow()  ,90  say transform(ITEN_ANT->Vl_unitari, "@E 999,999.99")
      @ prow()  ,110 say transform((ITEN_ANT->Quantidade * ITEN_ANT->Vl_unitari), "@E 999,999.99")
      nTOT_PROD  := nTOT_PROD +  (ITEN_ANT->Quantidade * ITEN_ANT->Vl_unitari)

      nCONT++

      ITEN_ANT->(Dbskip())

   enddo

   @ prow(),pcol() say XCOND0

   @ prow()+1,0 say replicate("-",80)
   @ prow()+1,41 say " Total ..........> "+transform(nTOT_PROD, "@E 99,999,999.99")
   @ prow()+1,0 say replicate("-",80)

   @ prow()+1,0 say "Observacao: "+ANTECIPA->Observacao
   @ prow()+1,0 say replicate("-",80)

   @ prow()+4,0  say "Requisitado por: "+iif( FUN->(Dbseek(ANTECIPA->Recebedor)) , FUN->Nome,)
   @ prow()  ,45 say "Autorizado por: "+iif( FUN->(Dbseek(ANTECIPA->Autorizado)) , FUN->Nome,)
   @ prow()+2,0 say XDENFAT+"________________________________                 _______________________________"
   @ prow()+1,0 say "             Assinatura                                        Assinatura"

   nCONT += 14

   qstopprn()

return


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edi_1

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||lastkey()==27}

   XNIVEL := 1

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@fLOJA    ,"@r 9999",NIL           )} ,"LOJA"         })
   aadd(aEDICAO,{{ || NIL        } , NIL                               }) // descricao da filial

   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOTA       ,"999999",               )} ,"NOTA"         })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Chegada dos Produtos ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   qgirabarra()

   ANTECIPA->(qpublicfields())

   iif(cOPCAO=="I", ANTECIPA->(qinitfields()), ANTECIPA->(qcopyfields()))

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE );ANTECIPA->(qreleasefields());return;endif
      if ! i_crit_1( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      qmensa("")
   enddo

   if ! lCONF ; return ; endif

   ITEN_ANT->(Dbseek(ANTECIPA->Codigo))
   do while ! ITEN_ANT->(eof()) .and. ITEN_ANT->Cod_ante == ANTECIPA->Codigo
      if ITEN_ANT->(qrlock())
         replace ITEN_ANT->Baixa with .T.
         ITEN_ANT->(qunlock())
      endif
      ITEN_ANT->(Dbskip())
   enddo
   if ANTECIPA->(qrlock())
      replace ANTECIPA->Loja  with fLOJA
      replace ANTECIPA->Nota  with fNOTA
      ANTECIPA->(qunlock())
   endif

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_crit_1 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "LOJA"
           if empty(fLOJA) ; return .F. ; endif
           qrsay(XNIVEL,left(fLOJA,5))
           if ! FILIAL->(dbseek(fLOJA))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL := 2,left(FILIAL->Razao,30))

      case cCAMPO == "NOTA"

           if empty(fNOTA) ; return .F. ; endif
           qrsay(XNIVEL,fNOTA)
           Return .t.

   endcase

return .T.

