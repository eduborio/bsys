/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: BAIXA - NOTA FISCAL DE VENDA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JULHO DE 1998
// OBS........:
// ALTERACOES.: LUCIANO DA SILVA GORSKI

//#include "inkey.ch"
function es207

private fTOTAL  // variavel para totalizar as vendas

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS VENDAS ___________________________________________________

VENDAS->(qview({{"Codigo/C¢digo"         ,1},;
                 {"Data/Data"            ,1},;
                 {"i_207a()/Vendedor"    ,0},;
                 {"i_207b()/Filial"      ,0},;
                 {"Nt_fiscal/Nota"       ,0},;
                 {"i_207d()/Baixa"       ,0}},"P",;
                 {NIL,"i_207c",NIL,NIL},;
                  NIL,"<ESC>/ALT-P/ALT-O/<I>nc/<A>lt/<C>on/<E>xc/<B>aixar Estoque"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DA FILIAL _______________________________________________

function i_207b
   FILIAL->(dbseek(VENDAS->Filial))
return left(FILIAL->Razao,18)


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM O CAMPO BAIXA ___________________________________________

function i_207d
   if VENDAS->Baixa
      return "SIM"
   else
      return "NAO"
   endif
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO VENDEDOR  ___________________________________________

function i_207a
   VEND->(dbseek(VENDAS->Vendedor))
return left(VEND->Nome,25)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_207c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "B" .and. ! VENDAS->Baixa
      i_baixa()
   endif

   if cOPCAO $ "AE"
      if VENDAS->Baixa
         qmensa("J  foi efeuada baixa... acesso proibido...","B")
         return .F.
      endif
   endif

   if cOPCAO $ XUSRA
      qlbloc(7,2,"B207A","QBLOC.GLO")
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||lastkey()==27}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 08,14 , VENDAS->Codigo           )
      qsay ( 08,37 , VENDAS->Nt_fiscal        )
      qsay ( 08,58 , VENDAS->Data             )
      qsay ( 09,14 , VENDAS->Filial           ) ; FILIAL->(dbseek(VENDAS->Filial))
      qsay ( 09,21 , left(FILIAL->Razao,30)   )
      qsay ( 10,14 , VENDAS->Vendedor         ) ; VEND->(dbseek(VENDAS->Vendedor))
      qsay ( 10,20 , left(VEND->Nome,30)      )

      if cOPCAO == "C" .or. cOPCAO == "E"
        if cOPCAO == "E"
           keyboard chr(27)
           i_totaliza_pedido()
           i_atu_lanc()
           keyboard chr(27)
        else
          i_totaliza_pedido()
          i_atu_lanc()
          keyboard chr(27)
        endif
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO"       })
   aadd(aEDICAO,{{ || qgetx(8,37,@fNT_FISCAL ,"999999",                )} ,"NT_FISCAL"    })
   aadd(aEDICAO,{{ || qgetx(8,58,@fDATA ,"@D",                         )} ,"DATA"         })
   aadd(aEDICAO,{{ || view_filial(9,14,@fFILIAL                        )} ,"FILIAL"       })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   aadd(aEDICAO,{{ || view_vend(10,14,@fVENDEDOR                        )} ,"VENDEDOR"     })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      VENDAS->(qpublicfields())

      iif(cOPCAO=="I", VENDAS->(qinitfields()), VENDAS->(qcopyfields()))

      XNIVEL := 1
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );VENDAS->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock()) .and. VENDAS->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AQUI INCREMENTA CODIGO DAS VENDAS  _________________________

         if cOPCAO == "I"
            replace CONFIG->Cod_vendas with CONFIG->Cod_vendas + 1
            qsay ( 08,14 , fCODIGO := strzero(CONFIG->Cod_vendas,5) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")

         endif

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         VENDAS->(qreplacefields())

      else

         if empty(VENDAS->Codigo)
            VENDAS->(dbdelete())
         endif

         iif(cOPCAO=="I",qm1(),qm2())

      endif

      dbunlockall()

      i_totaliza_pedido()

      i_proc()

   enddo

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

//   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DATA"
           if empty(fDATA) ; return .F. ; endif

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(9,14,fFILIAL)
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(9,21,left(FILIAL->Razao,40))

      case cCAMPO == "VENDEDOR"
           if empty(fVENDEDOR) ; return .F. ; endif
           qsay(10,14,fVENDEDOR)
           if ! VEND->(dbseek(fVENDEDOR))
              qmensa("Vendedor n„o encontrado !","B")
              return .F.
           endif
           qsay(10,20,left(VEND->Nome,30))

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR VENDAS ____________________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Venda ?")
      if ITEN_VEN->(qflock()) .and. VENDAS->(qrlock())
         ITEN_VEN->(dbseek(VENDAS->Codigo))
         do while ! ITEN_VEN->(eof()) .and. ITEN_VEN->Cod_venda == VENDAS->Codigo
            ITEN_VEN->(dbdelete())
            ITEN_VEN->(dbskip())
         enddo
         VENDAS->(dbdelete())
         VENDAS->(qunlock())
         ITEN_VEN->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PROD->(Dbsetorder(4))

ITEN_VEN->(qview({{"Cod_Prod/Cod."                                      ,2},;
                  {"f207a()/Descri‡„o"                                  ,0},;
                  {"transform(Valor_unit, '@E 9,999.99')/Vl.Unit."       ,0},;
                  {"transform(Quantidade,'@E 9,999.99')/Quant."           ,0},;
                  {"f207c()/Val. Total"                                 ,0}},;
                  "11022077S",;
                  {NIL,"f207d",NIL,NIL},;
                  {"ITEN_VEN->Cod_venda == VENDAS->Codigo",{||f207top()},{||f207bot()}},;
                  "<I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f207top
   ITEN_VEN->(dbsetorder(1))
   ITEN_VEN->(dbseek(VENDAS->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f207bot
   ITEN_VEN->(dbsetorder(1))
   ITEN_VEN->(qseekn(VENDAS->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f207a

   local cDESCRICAO := space(32)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_VEN->Cod_prod)
      PROD->(dbseek(left(ITEN_VEN->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,32)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f207c
return transform(ITEN_VEN->Valor_unit * ITEN_VEN->Quantidade,"@E 9,999.99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f207d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B207B","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , ITEN_VEN->Cod_prod          , "@R 99999"     ) ; PROD->(dbseek(left(ITEN_VEN->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                     )
      qrsay ( XNIVEL++ , ITEN_VEN->Valor_unit, "@E 9,999.99"          )
      qrsay ( XNIVEL++ , ITEN_VEN->Lote, "@R 9999999999"              )
      qrsay ( XNIVEL++ , ITEN_VEN->Quantidade, "@E 9,999.99"          )
      qrsay ( XNIVEL++ , ITEN_VEN->Valor_unit * ITEN_VEN->Quantidade, "@E 999,999.99" )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_iten_ven() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"})
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_UNIT , "@E 9,999.99"      ) } ,"VALOR_UNIT"})
   aadd(aEDICAO,{{ || view_lote(-1,0,@fLOTE , "@R 9999999999"      ) } ,"LOTE"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 9,999.99"      ) } ,"QUANTIDADE"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_VEN->(qpublicfields())

   iif(cOPCAO=="I",ITEN_VEN->(qinitfields()),ITEN_VEN->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_VEN->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if VENDAS->(qrlock()) .and. ITEN_VEN->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_VENDA := VENDAS->Codigo
      endif
      ITEN_VEN->(qreplacefields())
      ITEN_VEN->(qunlock())

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


//         if PROD->Qtn_estoq <= 0
//            qmensa("Produto n„o possui em estoque !","B")
//            return .F.
//         endif

           if ! INVENT->(dbseek(fFILIAL+fCOD_PROD))
              qmensa("N„o Existe Invent rio para este Produto !","B")
              return .F.
           endif

           if INVENT->Quant_atu <= 0  // inclusao feito pelo chang, foi retirado para verificar do INVENT.DBF a quantidade atual no estoque no dia 14/08/97
              qmensa("Produto n„o possui em estoque !","B")
              return .F.
           endif

           LOTES->(dbSetFilter({|| Produto == fCOD_PROD .and. Filial == VENDAS->FILIAL }, 'Produto == fCOD_PROD .and. Filial == VENDAS->FILIAL'))
           qrsay ( XNIVEL+1 , left(PROD->Descricao,40) )

           fVALOR_UNIT := INVENT->Preco_uni

      case cCAMPO == "LOTE"

           LOTES->(dbSetFilter({|| Produto == fCOD_PROD .and. Filial == VENDAS->FILIAL }, 'Produto == fCOD_PROD .and. Filial == VENDAS->FILIAL'))

           if empty(fLOTE); return .t.; endif

           if LOTES->(dbseek(fCOD_PROD+fFILIAL+fLOTE))
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
           if empty(fQUANTIDADE) ; return .F. ; endif
           qrsay(XNIVEL+1,transform(fVALOR_UNIT*fQUANTIDADE, "@e 999,999.99"))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DAS VENDAS _____________________________________

static function i_exc_iten_ven

   if qconf("Confirma exclus„o do Produto ?")
      if ITEN_VEN->(qrlock())
         ITEN_VEN->(dbdelete())
         ITEN_VEN->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc

setcolor("W/B")

ITEN_VEN->(qview({{"Cod_Prod/Cod."                                      ,2},;
                  {"f207a()/Descri‡„o"                                  ,0},;
                  {"transform(Valor_unit, '@E 9,999.99')/Vl.Unit."      ,0},;
                  {"transform(Quantidade, '@E 9,999.99')/Quant."        ,0},;
                  {"f207c()/Val. Total"                                 ,0}},;
                  "11022077S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_VEN->Cod_venda == VENDAS->Codigo",{||f207top()},{||f207bot()}},;
                 "<ESC> para sair" ))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR VARIAVEIS DO PEDIDO ________________________________

static function i_totaliza_pedido

   fTOTAL := 0

   ITEN_VEN->(dbgotop())
   ITEN_VEN->(dbseek(VENDAS->Codigo))

   do while ! ITEN_VEN->(eof()) .and. ITEN_VEN->Cod_venda == VENDAS->Codigo
      fTOTAL    := fTOTAL + (ITEN_VEN->Quantidade*ITEN_VEN->Valor_unit)
      ITEN_VEN->(Dbskip())
   enddo
   qsay(21,63,transform(fTOTAL,"@e 9,999,999.99"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR VARIAVEIS DO PEDIDO ________________________________

static function i_baixa

   lCONF := qconf("Confirma Baixa em estoque ?")

   if ! lCONF ; return .F. ; endif

   qmensa("Aguarde... baixando estoque....")

   ITEN_VEN->(dbseek(VENDAS->Codigo))

   do while ! ITEN_VEN->(eof()) .and. ITEN_VEN->Cod_venda == VENDAS->Codigo

    PROD->(dbsetorder(4))
    PROD->(dbseek(ITEN_VEN->Cod_prod))

//  if PROD->(qrlock())
//
//     replace PROD->Qtn_estoq with (PROD->Qtn_estoq - ITEN_VEN->Quantidade)
//
//     PROD->(qunlock())
//
//  endif

      if INVENT->(dbseek(VENDAS->Filial+ITEN_VEN->Cod_prod)) .and. INVENT->(qrlock())

         replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_VEN->Quantidade)

         INVENT->(qunlock())

      endif

      if LOTES->(dbseek(ITEN_VEN->Cod_prod+VENDAS->Filial+ITEN_VEN->Lote)) .and. LOTES->(qrlock())
         replace LOTES->Quantidade with (LOTES->Quantidade - ITEN_VEN->Quantidade)
         LOTES->(qunlock())
      endif

      ITEN_VEN->(dbskip())

   enddo

   if VENDAS->(qrlock())
      replace VENDAS->Baixa with .T.
      VENDAS->(qunlock())
   endif

   qmensa("")

return
