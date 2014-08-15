/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: REQUISICAO DE COMPRA ANTECIPADA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: AGOSTO DE 1997
// OBS........:
// ALTERACOES.:

//#include "inkey.ch"

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS REQUISICOES DE COMPRA ANTECIPADAS __________________________

function cp206

ANTECIPA->(qview({{"Codigo/Codigo"       ,1},;
                 {"Data/Data"            ,0}},"P",;
                 {NIL,"i_206a",NIL,NIL},;
                 NIL,q_msg_acesso_usr()))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_206a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B204A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
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

// MONTA DADOS NA TELA ___________________________________________________________

    if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,21 , ANTECIPA->Codigo           )
      qsay ( 06,68 , dtoc(ANTECIPA->Data)       )

      if cOPCAO == "C"
        i_at_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(6,21,@fCODIGO     ,"99999",NIL             )} ,"CODIGO"       })
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

      i_lanc1()

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
           qsay(6,21,fCODIGO :=strzero(val(fCODIGO),5))
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
            ITEN_ANT->(dbdelete())
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

function i_lanc1

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PROD->(Dbsetorder(3))

ITEN_ANT->(qview({{"Cod_Prod/Cod."                                        ,2},;
                  {"f206a()/Descri‡„o"                                    ,0},;
                  {"Cod_forn/Fornecedor"                                  ,0},;
                  {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                  {"Lote/N.Lote"                                          ,0},;
                  {"f206c()/Bx."                                          ,0}},;
                  "07002379S",;
                  {NIL,"f206d",NIL,NIL},;
                  {"ITEN_ANT->Cod_ante == ANTECIPA->Codigo",{||f206top()},{||f206bot()}},;
                  "<I>nc./<A>lt./<C>on.<E>xc./<B>aixa"))

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

   local cDESCRICAO := space(40)
   PROD->(Dbsetorder(3))
   if ! empty(ITEN_ANT->Cod_prod)
      PROD->(dbseek(ITEN_ANT->Cod_prod))
      cDESCRICAO := left(PROD->Descricao,30)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// RETORNA SE O ITEN FOI BAIXADO OU NAO _____________________________________

function f206c
  if ITEN_ANT->Baixa
     return "SIM"
  else
     return "NAO"
  endif
return ""

/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f206b
   PROD->(dbseek(ITEN_ANT->Cod_prod))
   UNIDADE->(dbseek(PROD->Unidade))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f206d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B204B","QBLOC.GLO",1)
      i_processa_acao()
   endif

   if cOPCAO == "B"
      if ! ITEN_ANT->Baixa
         ANTECIPA->(qpublicfields())
         ANTECIPA->(qinitfields())
         i_baixa()
      else
         qmensa("Neste iten ja foi efetuada baixa....","B")
         return .F.
      endif
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
      qrsay ( XNIVEL++ , ITEN_ANT->Cod_prod            , "@!"   ) ; PROD->(Dbsetorder(3)) ; PROD->(dbseek(ITEN_ANT->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)               ) ; FORN->(Dbseek(ITEN_ANT->Cod_forn))
      qrsay ( XNIVEL++ , ITEN_ANT->Cod_forn                     )
      qrsay ( XNIVEL++ , left(FORN->Razao,30)                   )
      qrsay ( XNIVEL++ , ITEN_ANT->Loja, "@r 9999"              ) ; FILIAL->(dbseek(ITEN_ANT->Loja))
      qrsay ( XNIVEL++ , Left(FILIAL->Razao,25), "@!"           )
      qrsay ( XNIVEL++ , ITEN_ANT->Quantidade, "@E 9999.99999"  )
      qrsay ( XNIVEL++ , ITEN_ANT->Lote , "@R 9999999999"       )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_ITEN_ANT() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod1(-1,0,@fCOD_PROD                  ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL         })

   aadd(aEDICAO,{{ || view_prfor(-1,0,@fCOD_FORN                  ) } ,"COD_FORN"  })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL         })

   aadd(aEDICAO,{{ || view_filial(-1,0,@fLOJA , "@R 9999"         ) } ,"LOJA"      })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 9999.99999"   ) } ,"QUANTIDADE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLOTE , "@R 9999999999"         ) } ,"LOTE"      })

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

      if INVENT->(Dbseek(fLOJA+ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock())
         replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_ANT->Quantidade)
         INVENT->(qunlock())
      endif

      if PROD_FOR->(qrlock())
         replace PROD_FOR->Quant_atu with (PROD_FOR->Quant_atu + ITEN_ANT->Quantidade)
         PROD->(qunlock())
      endif

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "COD_PROD"

           qrsay(XNIVEL,fCOD_PROD)

           PROD->(Dbsetorder(3))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(PROD->Descricao,40) )


      case cCAMPO == "COD_FORN"

           if empty(fCOD_FORN) ; return .F. ; endif

           qrsay(XNIVEL,fCOD_FORN:=strzero(val(fCOD_FORN),5))

           PROD_FOR->(Dbsetorder(3))

           if ! PROD_FOR->(Dbseek(fCOD_PROD+fCOD_FORN))
              qmensa("Fornecedor n„o encontrado para este produto !","B")
              return .F.
           endif

           FORN->(dbseek(fCOD_FORN))
           qrsay(XNIVEL+1,left(FORN->Razao,30))

      case cCAMPO == "LOJA"

           if ! empty(fLOJA)
              if ! FILIAL->(Dbseek(fLOJA))
                 qmensa("Loja n„o Encontrada !")
                 return .F.
              endif
              qrsay(XNIVEL,fLOJA)
              qrsay(XNIVEL+1,left(FILIAL->Razao,25))
           endif

      case cCAMPO == "QUANTIDADE"
           if empty(fQUANTIDADE); Return .f.; endif
           qrsay(XNIVEL,transform(fQUANTIDADE, "@E 9999.99999"))

      case cCAMPO == "LOTE"

           if empty(fLOTE) ; fLOTE := "0000000000"; return .T. ; endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITEN_ANTAMENTOS DO ANTECIPA ________________________________

static function i_exc_iten_ant

   if qconf("Confirma exclus„o do Produto ?")

      if ITEN_ANT->(qrlock())

         if INVENT->(Dbseek(fLOJA+ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock())
            replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_ANT->Quantidade)
            INVENT->(qunlock())
            if PROD_FOR->(qrlock())
               PROD_FOR->(Dbsetorder(3))
               PROD_FOR->(Dbseek(ITEN_ANT->Cod_prod+ITEN_ANT->Cod_forn))
               replace PROD_FOR->Quant_atu with (PROD_FOR->Quant_atu + ITEN_ATU->Quantidade )
               PROD_FOR->(qunlock())
            endif
         endif

         ITEN_ANT->(dbdelete())
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
                  {"Lote/N.Lote"                                          ,0}},;
                  "07002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_ANT->Cod_ante == ANTECIPA->Codigo",{||f206top()},{||f206bot()}},;
                 "<ESC> para sair" ))

return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR ANTECIPACAO __________________________________________

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

      PROD->(Dbsetorder(3))
      PROD->(Dbseek(ITEN_ANT->Cod_produt))
      @ prow()+1,0  say strzero(nCONT,2)
      UNIDADE->(Dbseek(PROD->Unidade))
      @ prow()  ,09  say UNIDADE->Sigla
      @ prow()  ,14  say transform(ITEN_ANT->Quantidade, "@E 999.99")
      @ prow()  ,23  say PROD->Cod_ass
      @ prow()  ,32  say ITEN_ANT->Cod_forn
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

//////////////////////////////////////////////////////////////////
// funcao utilizada para baixar os itens da compra ______________
function i_baixa()

  qlbloc(10,5,"B204C","QBLOC.GLO",1)
  i_edicao1()

return

//////////////////////////////////////////////////////////////////
// funcao utilizada para editar os itens da compra _______________

static function i_edicao1

   local lCONF
   local nQUANT  := 0
   local aEDICAO := {}
   local bESCAPE := {||lastkey()==27}

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@fLOJA  ,"9999",NIL             )} ,"LOJA"  })
   aadd(aEDICAO,{{ || NIL             } ,NIL })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOTA   ,"999999",                   )} ,"NOTA"  })
   aadd(aEDICAO,{{ || NIL                          } ,"QTDE_COMP" }) // Quantidade Comprada
   aadd(aEDICAO,{{ || qgetx(-1,0,@nQUANT   ,"999999",                  )} ,"QUANT" })
   aadd(aEDICAO,{{ || NIL             } ,NIL }) // Resto

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   qgirabarra()

   ANTECIPA->(qcopyfields())

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE );ANTECIPA->(qreleasefields());return;endif
      if ! i_crit( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      qmensa("")
   enddo

   if ! lCONF ; return ; endif

   ITEN_ANT->(Dbseek(ANTECIPA->Codigo))

   if ITEN_ANT->Resto <> 0

      if nQUANT > ITEN_ANT->Resto

         qmensa("Quantidade ultrapassou o restante....","B")
         return .F.

      else

         if nQUANT = int(ITEN_ANT->Resto)

//            if INVENT->(Dbseek("0001" + ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock())
            if INVENT->(Dbseek(fLOJA+ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock())
               replace INVENT->Quant_atu with (INVENT->Quant_atu + nQUANT)
               PROD->(qunlock())
            endif

            PROD_FOR->(dbsetorder(3))

            if PROD_FOR->(Dbseek(ITEN_ANT->Cod_prod+ITEN_ANT->Cod_forn+ITEN_ANT->Lote)) .and. PROD_FOR->(qrlock())
               replace PROD_FOR->Quant_atu with (PROD_FOR->Quant_atu + nQUANT)
               PROD_FOR->(qunlock())
            endif

            if LOTES->(dbseek(ITEN_ANT->Cod_prod+fLOJA+ITEN_ANT->Lote)) .and. LOTES->(qrlock())
               Replace LOTES->Quantidade With (LOTES->Quantidade + nQUANT)
               LOTES->(qunlock())
            endif

            if ITEN_ANT->(qrlock())
               replace ITEN_ANT->Baixa with .T.
            endif

         elseif nQUANT < ITEN_ANT->Resto

//            if INVENT->(Dbseek("0001" + ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock())
            if INVENT->(Dbseek(fLOJA+ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock())
               replace INVENT->Quant_atu with (INVENT->Quant_atu + (ITEN_ANT->Resto - nQUANT) )
               INVENT->(qunlock())
            endif

            PROD_FOR->(dbsetorder(3))

            if PROD_FOR->(Dbseek(ITEN_ANT->Cod_prod+ITEN_ANT->Cod_forn+ITEN_ANT->Lote)) .and. PROD_FOR->(qrlock())
               replace PROD_FOR->Quant_atu with (PROD_FOR->Quant_atu + (ITEN_ANT->Resto - nQUANT) )
               PROD_FOR->(qunlock())
            endif

            if LOTES->(dbseek(ITEN_ANT->Cod_prod+fLOJA+ITEN_ANT->Lote)) .and. LOTES->(qrlock())
               Replace LOTES->Quantidade With (LOTES->Quantidade - nQUANT)
               LOTES->(qunlock())
            endif

         endif

      endif

   endif

   if nQUANT > ITEN_ANT->Quantidade .and. ITEN_ANT->Resto == 0

//      if INVENT->(Dbseek("0001" + ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock())
      if INVENT->(Dbseek(fLOJA+ITEN_ANT->Cod_prod+ITEN_ANT->Lote)) .and. INVENT->(qrlock())
         replace INVENT->Quant_atu with (INVENT->Quant_atu + (nQUANT - ITEN_ANT->Quantidade))
         PROD->(qunlock())
      endif

      PROD_FOR->(dbsetorder(3))

      if PROD_FOR->(Dbseek(ITEN_ANT->Cod_prod+ITEN_ANT->Cod_forn+ITEN_ANT->Lote)) .and. PROD_FOR->(qrlock())
         replace PROD_FOR->Quant_atu with (PROD_FOR->Quant_atu + (nQUANT - ITEN_ANT->Quantidade))
         PROD_FOR->(qunlock())
      endif

      if LOTES->(dbseek(ITEN_ANT->Cod_prod+fLOJA+ITEN_ANT->Lote)) .and. LOTES->(qrlock())
         Replace LOTES->Quantidade With (LOTES->Quantidade - nQUANT)
         LOTES->(qunlock())
      endif

   else

     if nQUANT < ITEN_ANT->Quantidade .and. ITEN_ANT->Resto == 0

        if ITEN_ANT->(qrlock())
           replace ITEN_ANT->Resto with (ITEN_ANT->Quantidade - nQUANT)
           ITEN_ANT->(qunlock())
        endif

     else

       if ITEN_ANT->(qrlock()) .and. ITEN_ANT->Resto == 0

          replace ITEN_ANT->Baixa with .T.

       endif

     endif

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "LOJA"

           if ! empty(fLOJA)

              if ! FILIAL->(Dbseek(fLOJA))
                 qmensa("Loja n„o Encontrada !")
                 return .F.
              endif

              qrsay(XNIVEL+1,left(FILIAL->Razao,25))

           endif

      case cCAMPO == "QTDE_COMP"
           qrsay(XNIVEL,transform(ITEN_ANT->Quantidade,"@R 99999.99"))
           qrsay(XNIVEL+2,transform(ITEN_ANT->Resto,"@R 99999.99"))

   endcase

return .T.
