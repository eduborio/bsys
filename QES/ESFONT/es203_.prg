/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: BAIXA - NOTA FISCAL DE TRANSFERENCIA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JUNHO DE 1997
// OBS........:
// ALTERACOES.: LUCIANO DA SILVA GORSKI

//#include "inkey.ch"
function es203

CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS NOTAS FISCAIS DE TRANSFERENCIA ___________________________

NFTRANSF->(qview({{"Codigo/N£mero"       ,1},;
                 {"Dt_lancto/Data "      ,0},;
                 {"i_203a()/Filial"      ,0},;
                 {"i_203b()/Centro Custo",0},;
                 {"i_203d()/Baixado"     ,0}},"P",;
                 {NIL,"i_203c",NIL,NIL},;
                  NIL,q_msg_acesso_usr()+"/<B>aixa do Estoque"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DA FILIAL _______________________________________________

function i_203a
   FILIAL->(dbseek(NFTRANSF->Filial))
return left(FILIAL->Razao,23)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function i_203b
   CCUSTO->(dbseek(NFTRANSF->C_custo))
return left(CCUSTO->Descricao,25)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM SE FOI BAIXADO  _________________________________________

function i_203d
   local cSIMNAO := "  NŽO"
   if NFTRANSF->Bx_estoque
      cSIMNAO := "  SIM"
   endif
return cSIMNAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_203c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "AE" .and. NFTRANSF->Bx_estoque
      qmensa("Nota Fiscal Baixada... Acesso Proibido !!","B")
      return ""
   endif

   if cOPCAO == "B"
      if NFTRANSF->Bx_estoque
         qmensa("Esta Nota Fiscal ja foi dado Baixa!!","B")
         return ""
      else
        i_baixa_estoque()
      endif
   endif

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B203A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
      CCUSTO->(dbSetFilter())
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

      qsay ( 06,21 , NFTRANSF->Codigo           )
      qsay ( 06,68 , dtoc(NFTRANSF->Dt_lancto) )
      qsay ( 07,21 , NFTRANSF->Filial           ) ; FILIAL->(dbseek(NFTRANSF->Filial))
      qsay ( 07,34 , left(FILIAL->Razao,30)      )
      qsay ( 08,21 , NFTRANSF->C_custo          ) ; CCUSTO->(dbseek(NFTRANSF->C_custo))
      qsay ( 08,34 , left(CCUSTO->Descricao,30)      )
      qsay ( 09,11 , NFTRANSF->Cod_veic         ) ; VEICULOS->(dbseek(NFTRANSF->Cod_veic))
      qsay ( 09,17 , VEICULOS->Descricao        )
      qsay ( 09,48 , NFTRANSF->Cod_equi         ) ; EQUIPTO->(dbseek(NFTRANSF->Cod_equi))
      qsay ( 09,54 , left(EQUIPTO->Descricao,24))
      qsay ( 10,21 , NFTRANSF->Tipo             ) ; TIPOCONT->(dbseek(NFTRANSF->Tipo) )
      qsay ( 10,30, alltrim(TIPOCONT->Descricao)    )
      qsay ( 11,14 , NFTRANSF->Autorizado       ) ; FUN->(dbseek(NFTRANSF->Autorizado))
      qsay ( 11,23 , FUN->Nome                  )
      qsay ( 12,14 , dtoc(NFTRANSF->Dt_lancto))
      qsay ( 13,14 , NFTRANSF->Recebedor        ) ; FUN->(dbseek(NFTRANSF->Recebedor))
      qsay ( 13,23 , FUN->Nome                  )
      qsay ( 14,14 , NFTRANSF->Observacao       )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(6,21,@fCODIGO     ,"99999",NIL             )} ,"CODIGO"       })
   aadd(aEDICAO,{{ || qgetx(6,68,@fDT_LANCTO ,"@D",                   )} ,"DT_LANCTO"     })
   aadd(aEDICAO,{{ || view_filial(7,21,@fFILIAL                        )} ,"FILIAL"       })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   aadd(aEDICAO,{{ || view_ccusto(8,21,@fC_CUSTO                       )} ,"C_CUSTO"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do centro
   aadd(aEDICAO,{{ || view_veic(9,11,@fCOD_VEIC                        )} ,"COD_VEIC"     })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da veiculos
   aadd(aEDICAO,{{ || view_equip(9,48,@fCOD_EQUI                       )}  ,"COD_EQUI"    })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da equipamentos
   aadd(aEDICAO,{{ || view_tipocont(10,21,@fTIPO                         )}  ,"TIPO"        })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do tipo
   aadd(aEDICAO,{{ || view_fun(11,14,@fAUTORIZADO                      )}   ,"AUTORIZADO" })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do funcionario que autorizou
   aadd(aEDICAO,{{ || qgetx(12,14,@fDT_ENTREGA ,"@D",NIL               )}   ,"DT_ENTREGA" })
   aadd(aEDICAO,{{ || view_fun(13,14,@fRECEBEDOR                       )}   ,"RECEBEDOR"  })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do funcionario que recebeu
   aadd(aEDICAO,{{ || qgetx(14,14,@fOBSERVACAO  ,"@!",NIL              )}   ,"OBSERVACAO" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      NFTRANSF->(qpublicfields())

      iif(cOPCAO=="I", NFTRANSF->(qinitfields()), NFTRANSF->(qcopyfields()))

      XNIVEL := 1
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );NFTRANSF->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if NFTRANSF->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         NFTRANSF->(qreplacefields())

      endif

      dbunlockall()

      i_proc_2()
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
              if NFTRANSF->(dbseek(fCODIGO))
                 qmensa("Nota Fiscal j  Cadastrada !","B")
                 return .F.
              endif
           else
              if ! NFTRANSF->(dbseek(fCODIGO))
                 qmensa("Nota Fiscal n„o Cadastrada !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "DT_LANCTO"
           if empty(fDT_LANCTO) ; return .F. ; endif

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(7,21,fFILIAL)
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(7,34,left(FILIAL->Razao,40))

           if fFILIAL != "0001"
              CCUSTO->(dbSetFilter({|| val(left(Codigo,2)) == val(fFILIAL) }, 'val(left(Codigo,2)) == val(fFILIAL)'))
           endif

      case cCAMPO == "C_CUSTO"
           if empty(fC_CUSTO) ; return .F. ; endif
           qsay(8,21,fC_CUSTO)
           CCUSTO->(dbsetorder(4))
           if ! CCUSTO->(dbseek(fC_CUSTO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif
           qsay(8,34,CCUSTO->Descricao)

      case cCAMPO == "COD_VEIC"
           if ! empty(fCOD_VEIC)
              qsay(9,11,fCOD_VEIC:=strzero(val(fCOD_VEIC),5))
              if ! VEICULOS->(dbseek(fCOD_VEIC))
                 qmensa("Veiculo n„o encontrado !","B")
                 return .F.
              endif
              qsay(9,17,VEICULOS->Descricao)
           endif

      case cCAMPO == "COD_EQUI"
           if ! empty(fCOD_EQUI)
              qsay(9,48,fCOD_EQUI:=strzero(val(fCOD_EQUI),5))
              if ! EQUIPTO->(dbseek(fCOD_EQUI))
                 qmensa("Equipamento n„o encontrado !","B")
                 return .F.
              endif
              qsay(9,54,left(EQUIPTO->Descricao,24))
           endif

      case cCAMPO == "TIPO"
           if empty(fTIPO) ; return .F. ; endif
           qsay(10,21,fTIPO:=strzero(val(fTIPO),6))
           if ! TIPOCONT->(dbseek(fTIPO))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif
           qsay(10,30,alltrim(TIPOCONT->Descricao))

      case cCAMPO == "AUTORIZADO"
           if empty(fAUTORIZADO) ; return .F. ; endif
           qsay(11,14,fAUTORIZADO:=strzero(val(fAUTORIZADO),6))
           if ! FUN->(dbseek(fAUTORIZADO))
              qmensa("Funcion rio n„o encontrado !","B")
              return .F.
           endif
           qsay(11,23,left(FUN->Nome,30))

      case cCAMPO == "RECEBEDOR"
           if empty(fRECEBEDOR) ; return .F. ; endif
           qsay(13,14,fRECEBEDOR:=strzero(val(fRECEBEDOR),6))
           if ! FUN->(dbseek(fRECEBEDOR))
              qmensa("Funcion rio n„o encontrado !","B")
              return .F.
           endif
           qsay(13,23,left(FUN->Nome,30))

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR NF TRANSFERNCIA __________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Nota Fiscal de Transferencia ?")
      if ITENS_NF->(qflock()) .and. NFTRANSF->(qrlock())
         ITENS_NF->(dbseek(NFTRANSF->Codigo))
         do while ! ITENS_NF->(eof()) .and. ITENS_NF->num_nf == NFTRANSF->Codigo
            ITENS_NF->(dbdelete())
            ITENS_NF->(dbskip())
         enddo
         NFTRANSF->(dbdelete())
         NFTRANSF->(qunlock())
         ITENS_NF->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc_2

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PROD->(Dbsetorder(4))

ITENS_NF->(qview({{"Cod_Produt/Cod."                                      ,2},;
                  {"f203a()/Descri‡„o"                                    ,0},;
                  {"transform(Vl_unitari, '@E 999,999,999.99999')/Vl.Unit."  ,0},;
                  {"transform(Quantidade,'@E 9999.99999')/Quant."         ,0},;
                  {"f203b()/Un."                                          ,0},;
                  {"f203c()/Val. Total"                                   ,0}},;
                  "15002379S",;
                  {NIL,"f203d",NIL,NIL},;
                  {"ITENS_NF->Num_nf == NFTRANSF->Codigo",{||f203top()},{||f203bot()}},;
                  "<I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f203top
   ITENS_NF->(dbsetorder(1))
   ITENS_NF->(dbseek(NFTRANSF->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f203bot
   ITENS_NF->(dbsetorder(1))
   ITENS_NF->(qseekn(NFTRANSF->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f203a

   local cDESCRICAO := space(25)
   PROD->(Dbsetorder(4))
   if ! empty(ITENS_NF->Cod_produt)
      PROD->(dbseek(left(ITENS_NF->Cod_produt,5)))
      cDESCRICAO := left(PROD->Descricao,15)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f203b
   PROD->(dbseek(left(ITENS_NF->Cod_produt,5)))
   UNIDADE->(dbseek(PROD->Unidade))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f203c
return transform(ITENS_NF->Vl_unitari * ITENS_NF->Quantidade,"@E 9,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f203d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B203B","QBLOC.GLO",1)
      i_processa_acao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PRODUT).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITENS_NF->Cod_produt         , "@R 99999"     ) ; PROD->(dbseek(left(ITENS_NF->Cod_produt,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                      )
      qrsay ( XNIVEL++ , ITENS_NF->Vl_unitari, "@E 99,999,999.99999"   )
      qrsay ( XNIVEL++ , ITENS_NF->Lote, "@R 9999999999"               )
      qrsay ( XNIVEL++ , ITENS_NF->Quantidade, "@R 9999.99999"         )
      qrsay ( XNIVEL++ , ITENS_NF->Vl_unitari * ITENS_NF->Quantidade, "@E 99,999,999.99" )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_ITENS_NF() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PRODUT                   ) } ,"COD_PRODUT"})
   aadd(aEDICAO,{{ || NIL                                             } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVL_UNITARI ,"@E 99,999,999.99999") } ,"VL_UNITARI"})
   aadd(aEDICAO,{{ || view_lote(-1,0,@fLOTE , "@E 9999999999"       ) } ,"LOTE"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 9999.99999"     ) } ,"QUANTIDADE"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITENS_NF->(qpublicfields())

   iif(cOPCAO=="I",ITENS_NF->(qinitfields()),ITENS_NF->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITENS_NF->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if NFTRANSF->(qrlock()) .and. ITENS_NF->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fNUM_NF := fCODIGO
      endif
      ITENS_NF->(qreplacefields())
      ITENS_NF->(qunlock())

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

      case cCAMPO == "COD_PRODUT"

           qrsay(XNIVEL,fCOD_PRODUT:=strzero(val(fCOD_PRODUT),5))

           if ! PROD->(dbseek(fCOD_PRODUT))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

//         if PROD->Qtn_estoq <= 0
//            qmensa("Produto n„o possui em estoque !","B")
//            return .F.
//         endif

           if ! INVENT->(dbseek(fFILIAL+fCOD_PRODUT))
              qmensa("N„o Existe Invent rio para este Produto !","B")
              return .F.
           endif

           if INVENT->Quant_atu <= 0  // inclusao feito pelo chang, foi retirado para verificar do INVENT.DBF a quantidade atual no estoque no dia 14/08/97
              qmensa("Produto n„o possui em estoque !","B")
              return .F.
           endif

           LOTES->(dbSetFilter({|| Produto == fCOD_PRODUT .and. Filial == NFTRANSF->FILIAL }, 'Produto == fCOD_PRODUT .and. Filial == NFTRANSF->FILIAL'))
           qrsay ( XNIVEL+1 , left(PROD->Descricao,40) )

           fVL_UNITARI := INVENT->Preco_uni

      case cCAMPO == "LOTE"
           LOTES->(dbSetFilter({|| Produto == fCOD_PRODUT .and. Filial == NFTRANSF->FILIAL }, 'Produto == fCOD_PRODUT .and. Filial == NFTRANSF->FILIAL'))

           if empty(fLOTE); return .t.; endif

           if LOTES->(dbseek(fCOD_PRODUT+fFILIAL+fLOTE))
              if LOTES->Quantidade > 0
                 Return .t.
              Else
                 qmensa("Lote deste Produto, nÆo ha Quantidade suficiente em Estoque...","B")
                 fLOTE := "          "
                 return .F.
              Endif
           Else
              qmensa("N£mero de Lote deste Produto nÆo encontrado...","B")
              fLOTE := "          "
              return .F.
           endif

      case cCAMPO == "QUANTIDADE"

           if empty(fQUANTIDADE); return .f.; endif
           qrsay(XNIVEL+1,transform(INVENT->Preco_uni*fQUANTIDADE, "@e 99,999,999.99"))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DA NOTA FISCAL DE TRANSFERENCIA ________________

static function i_exc_itens_nf

   if qconf("Confirma exclus„o do Produto ?")
      if ITENS_NF->(qrlock())
         ITENS_NF->(dbdelete())
         ITENS_NF->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc

setcolor("W/B")

ITENS_NF->(qview({{"Cod_Produt/Cod."                                      ,2},;
                  {"f203a()/Descri‡„o"                                    ,0},;
                  {"transform(Vl_unitari, '@E 999,999,999.99999')/Vl.Unit."  ,0},;
                  {"transform(Quantidade,'@E 9999.99999')/Quant."         ,0},;
                  {"f203b()/Un."                                          ,0},;
                  {"f203c()/Val. Total"                                   ,0}},;
                  "15002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITENS_NF->Num_nf == NFTRANSF->Codigo",{||f203top()},{||f203bot()}},;
                 "<ESC> para sair" ))

return ""

/////////////////////////////////////////////////////////////////
// BAIXA DO PRODUTO - NF TRANSFERENCIA __________________________

static function i_baixa_estoque

   local lCONF
   local cFATOR    := 1
   local cPRIMEIRO := .T.
   local cSAL_ANT  := 0

   lCONF := qconf("Confirma Baixa em estoque ?")

   if ! lCONF ; return .F. ; endif

   qmensa("Aguarde... baixando estoque....")

   PROD->(Dbsetorder(4))

   if NFTRANSF->(qrlock())

      if ITENS_NF->(dbseek(NFTRANSF->Codigo))

         do while ITENS_NF->Num_nf == NFTRANSF->Codigo .and. ! ITENS_NF->(eof())

//          if PROD->(dbseek(left(ITENS_NF->Cod_produt,5)))
            if INVENT->(dbseek(NFTRANSF->Filial+left(ITENS_NF->Cod_produt,5)))

               if cPRIMEIRO

//                if PROD->Qtn_estoq <= 0 .or. PROD->Qtn_estoq < ITENS_NF->Quantidade
//                   qmensa("N„o Existe estoque deste produto...","B")
//                   return .F.
//                endif

                  if INVENT->Quant_atu <= 0 .or. INVENT->Quant_atu < ITENS_NF->Quantidade
                     qmensa("N„o Existe estoque deste produto...","B")
                     return .F.
                  endif

                  cPRIMEIRO := .F.

               endif

//             iif (UNIDADE->(Dbseek(PROD->Unidade)), cFATOR:=UNIDADE->Fator ,)  // fator multiplicador da unidade *****
//
//             cSAL_ANT := PROD->Qtn_estoq
//
//             if PROD->(qrlock())
//                replace PROD->Qtn_estoq  with ( PROD->Qtn_estoq - (ITENS_NF->Quantidade * cFATOR ) )
//             endif
//
//             replace NFTRANSF->Bx_estoque with .T.
//
//             if MOVIMENT->(qrlock()) .and. MOVIMENT->(qappend())
//
//                replace MOVIMENT->Data       with NFTRANSF->Dt_lancto
//                replace MOVIMENT->Filial     with NFTRANSF->Filial
//                replace MOVIMENT->Cod_prod   with right(PROD->Codigo,5)
//                replace MOVIMENT->Quantidade with ITENS_NF->Quantidade
//                replace MOVIMENT->Val_uni    with PROD->Preco_unit
//                replace MOVIMENT->Saldo_ant  with cSAL_ANT
//                replace MOVIMENT->Tipo       with "S"
//                replace MOVIMENT->Contabil   with .T.
//
//             endif

               cSAL_ANT := INVENT->Quant_atu

               if INVENT->(qrlock())
                  replace INVENT->Quant_atu  with ( INVENT->Quant_atu - ITENS_NF->Quantidade )
               endif

               if LOTES->(dbseek(ITENS_NF->Cod_produt+NFTRANSF->Filial+ITENS_NF->Lote)) .and. LOTES->(qrlock())
                  replace LOTES->Quantidade with (LOTES->Quantidade - ITENS_NF->Quantidade)
                  LOTES->(qunlock())
               endif

               replace NFTRANSF->Bx_estoque with .T.

               if MOVIMENT->(qrlock()) .and. MOVIMENT->(qappend())

                  replace MOVIMENT->Data       with NFTRANSF->Dt_lancto
                  replace MOVIMENT->Filial     with NFTRANSF->Filial
                  replace MOVIMENT->Cod_prod   with right(PROD->Codigo,5)
                  replace MOVIMENT->Quantidade with ITENS_NF->Quantidade
                  replace MOVIMENT->Val_uni    with INVENT->Preco_uni
                  replace MOVIMENT->Saldo_ant  with cSAL_ANT
                  replace MOVIMENT->Tipo       with "S"
                  replace MOVIMENT->Contabil   with .T.

               endif
            endif

            ITENS_NF->(dbskip())

         enddo

      endif
   endif

   dbunlockall()

return
