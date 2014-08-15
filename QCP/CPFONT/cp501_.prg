/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: RELATORIO DE RESUMO DE COMPRAS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: JULHO DE 1999
// OBS........:
// ALTERACOES.:

function cp501

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private sBLOC1 := qlbloc("B501B","QBLOC.GLO") // ordem de impressao

private cTITULO                               // titulo do relatorio

private bFILTRO                               // code block de filtro
private cDESPESA := ""
private bFILTRO1                              // code block de filtro
private aEDICAO := {}                         // vetor para os campos de entrada de dados
private lFLAG_1 := .F.                        // flag para impressao do total geral por filial
private lFLAG_2 := .F.                        // flag para segundo loop CCUSTO por centro de custo
private sBLOC1 := qlbloc("B501B","QBLOC.GLO")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI     ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM     ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})
aadd(aEDICAO,{{ || qesco(-1,0,@cDESPESA ,sBLOC1                 )} ,"DESPESA" })


do while .T.

   qlbloc(5,0,"B501A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   dDATA_INI  := ctod("01/" + right(qanomes(date()),2) + "/" + left(qanomes(date()),4))
   dDATA_FIM  := qfimmes(dDATA_INI)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "DESPESA"
           if empty(cDESPESA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cDESPESA,"1234",{"1 - Todos","2 - Compras","3 - Transferencia","4 - Despesas"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RESUMO DE COMPRAS DE: " + dtoc(dDATA_INI) + " ATE " + dtoc(dDATA_FIM)
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   do case
      case cDESPESA == "1"
           bFILTRO := { || PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIM }

      case cDESPESA == "2"
           bFILTRO := { || PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIM .and. !PEDIDO->Cfop $ "1151-1152-2151-2152" .and. PEDIDO->Despesa != "S" }

      case cDESPESA == "3"
           bFILTRO := { || PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIM .and. PEDIDO->Cfop $ "1151-1152-2151-2152" }

      case cDESPESA == "4"
           bFILTRO := { || PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIM .and. !PEDIDO->Cfop $ "1151-1152-2151-2152" .and. PEDIDO->Despesa == "S"}

   endcase


   PEDIDO->(dbsetorder(6)) // data_ped
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(dbseek(dtos(dDATA_INI)))
   set softseek off

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local cPIC   := "@E 999,999.99"
   local nTOTAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   qgirabarra()

   do while ! PEDIDO->(eof())

      qgirabarra()

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "Nota Fiscal      Fornecedor                                       Valor da Nota"
         @ prow()+1,0 say replicate("-",80)
      endif

      if eval(bFILTRO)
         @ prow()+1,0  say PEDIDO->Numero_nf ; FORN->(dbseek(PEDIDO->Cod_forn))
         @ prow()  ,17 say left(FORN->Razao,50)
         @ prow()  ,70 say transform(PEDIDO->Val_liq,cPIC)
         nTOTAL += PEDIDO->Val_liq
      endif

      PEDIDO->(dbskip())

   enddo

   @ prow()+1,0  say replicate("-",80)
   @ prow()+1,0  say padr("TOTAL DE COMPRAS DO PERIODO",66,".")
   @ prow()  ,68 say transform(nTOTAL,"@E 9,999,999.99")

   qstopprn()

return
