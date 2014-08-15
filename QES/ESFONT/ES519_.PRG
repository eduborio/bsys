/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: RELATORIO DE RESUMO DE COMPRAS
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JULHO DE 1999
// OBS........:
// ALTERACOES.:

function es519

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private cTITULO                               // titulo do relatorio

private cTIPO := " "
private aEDICAO := {}                         // vetor para os campos de entrada de dados
private dINI := ctod("")
private dFIM := ctod("")
private sBLOC1 := qlbloc("B519B","QBLOC.GLO")
private aMov := {}
private XDRV_HB := "C:\QSYSTXT\"
private cAM := ""

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI     ,"@D"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM     ,"@D"     ,NIL,NIL) } ,"DATA_FIM"})
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOC1                 )} ,"TIPO" })


do while .T.

   qlbloc(5,0,"B519A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cTIPO := " "

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
           if empty(dINI) ; return .F. ; endif
           dFIM := qfimmes(dINI)
           qrsay(XNIVEL+1,dFIM)

      case cCAMPO == "DATA_FIM"
           if empty(dFIM) ; return .F. ; endif
           if dINI > dFIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO," 123456", {"Todos","Produto Acabado","Matria prima","Material","Embalagens","Vazios","Outros"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RESUMO DE MOVIMENTO MENSAL POR PRODUTO: " + dtoc(dINI) + " ATE " + dtoc(dFIM)
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   PROD->(dbsetorder(4))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________



static function i_impressao
local cPROD      := ""
local nCONT      := ""
local nTotal     := 0
local ncompras   := 0
local nSaldo_final := 0
local nPreco_cust  := 0
local nVendas    := 0
local nPerdas    := 0
local nBaixas    := 0
local nSaidaOP   := 0 //Materia Prima
local nEntradaOP := 0 //Produto acabado
local cPIC  := "@E 9,999,999.99"
local cPICQ := "@R 999999.99"
local nGeral := 0

   cAM := strzero(year(dINI),4)+strzero(month(dINI),2)

   criaProduto()

   aMov := {}

   getCompras()
   getSaiOPs()
   getPerdas()
   getBaixas()

   getEntOPs()
   getVendas()

   //classifica a matriz por descricao do produto
   aMov := asort(aMov,,,{|x,y| x[1] < y[1] })
   if len (aMov) > 0
       cPROD := aMov[1,1]

       nCONT := 1
       do while  nCONT <= len(aMov)

           nCompras   += aMov[nCONT,2]
           nSaidaOP   += aMov[nCONT,3]
           nPerdas    += aMov[nCONT,4]

           nEntradaOP += aMov[nCONT,5]
           nVendas    += aMov[nCONT,6]
           nBaixas    += aMov[nCONT,7]

           nCONT++
           if nCONT > len(aMov)
              nCONT := len(aMov)
              exit
           endif

           if aMov[nCONT,1] != cPROD
              if PRODUTO->(qappend())
                 replace PRODUTO->Cod_prod  with cPROD
                 replace PRODUTO->Saldo_ini with getSaldo(cPROD)
                 replace PRODUTO->Compra    with nCompras
                 replace PRODUTO->SaiOP     with nSaidaOP
                 replace PRODUTO->EntOP     with nEntradaOP
                 replace PRODUTO->Venda     with nVendas
                 replace PRODUTO->Perda     with nPerdas
                 replace PRODUTO->Baixa     with nBaixas
              endif

              cPROD :=aMov[nCONT,1]

              nCompras   := 0
              nSaidaOP   := 0
              nEntradaOP := 0
              nVendas    := 0
              nPerdas    := 0
              nBaixas    := 0
              nTotal     := 0

           endif
       enddo

       nTotal := nCompras + nSaidaOP + nEntradaOP + nVendas + nPerdas + nBaixas

       if nTotal > 0
          if PRODUTO->(qappend())
             replace PRODUTO->Cod_prod  with cPROD
             replace PRODUTO->Saldo_ini with getSaldo(cPROD)
             replace PRODUTO->Compra    with nCompras
             replace PRODUTO->SaiOP     with nSaidaOP
             replace PRODUTO->EntOP     with nEntradaOP
             replace PRODUTO->Venda     with nVendas
             replace PRODUTO->Perda     with nPerdas
             replace PRODUTO->Baixa     with nBaixas
          endif
       endif

       nCompras   := 0
       nSaidaOP   := 0
       nEntradaOP := 0
       nVendas    := 0
       nPerdas    := 0
       ntotal     := 0

   endif


   nTOTAL := 0


   qinitprn()

   getSemMov()

   PRODUTO->(dbgotop())
   do while ! PRODUTO->(eof())

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,134,,qabrev(cTIPO," 123456", {"Todos","Produto Acabado","Materia prima","Material","Embalagens","Vazios","Outros"}))
         if cTIPO == "2"
            @ prow()+1,0 say "Cod.  Descricao                                     Saldo Inicio    Compras     Bx. OP      Perda  Sld Final       Custo        Total"
         else
            @ prow()+1,0 say "Cod.  Descricao                                     Saldo Inicio    Ent. OP     Vendas      Baixa  Sld Final       Custo        Total"
         endif
         @ prow()+1,0 say replicate("-",134)
      endif

      nSaldo_final := 0
      nPreco_cust  := 0

      PROD->(dbseek(PRODUTO->Cod_prod))

      if PROD->Tipo != cTIPO
         PRODUTO->(dbskip())
         loop
      endif

      @ prow()+1,00  say right(PROD->Codigo,5)
      @ prow()  ,07  say left(PROD->Descricao,45)
      @ prow()  ,55  say transf(PRODUTO->Saldo_ini,cPICQ)


      if cTipo == "2"
         @ prow()  ,66  say transf(PRODUTO->Compra   ,cPICQ)
         @ prow()  ,77  say transf(PRODUTO->SaiOP    ,cPICQ)
         @ prow()  ,88  say transf(PRODUTO->Perda    ,cPICQ)
         nSaldo_final := (PRODUTO->Saldo_ini + PRODUTO->Compra) - (PRODUTO->SaiOP + PRODUTO->Perda)

         @ prow()  ,99  say transf(nSaldo_final      ,cPICQ)
         @ prow()  ,111 say transf(PROD->Preco_cust  ,"@E 99,999.9999")
         @ prow()  ,123 say transf(nSaldo_final*PROD->Preco_cust,cPIC)

         nTOTAL += (nSALDO_FINAL * PROD->Preco_cust)
      else
         @ prow()  ,66  say transf(PRODUTO->EntOP    ,cPICQ)
         @ prow()  ,77  say transf(PRODUTO->Venda    ,cPICQ)
         @ prow()  ,88  say transf(PRODUTO->Baixa    ,cPICQ)

         nSaldo_final := (PRODUTO->Saldo_ini + PRODUTO->EntOP) - (PRODUTO->Venda + PRODUTO->Baixa)
         @ prow()  ,99  say transf(nSaldo_final      ,cPICQ)

         if cTIPO == "1"
            nPreco_cust := PROD->Preco_cust
         else
           nPreco_cust  := PROD->Preco_cust
         endif

         @ prow()  ,111 say transf(nPreco_cust  ,"@E 99,999.9999")
         @ prow()  ,123 say transf(nSaldo_final*nPreco_cust,cPIC)
         nTOTAL += (nSALDO_FINAL * nPRECO_CUST)


      endif

      PRODUTO->(dbskip())
   enddo

   @ prow()+1  ,00  say "Total Geral .: "
   @ prow()    ,121 say transf(nTOTAL,"@E 999,999,999.99")

   nTOTAL := 0


   delProduto()

   qstopprn(.F.)

return


static function getCompras

   PEDIDO->(dbsetorder(6)) // data_ped
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(dbseek(dtos(dINI)))
   set softseek off

   do while ! PEDIDO->(eof())

      qgirabarra()

      if PEDIDO->Data_ped < dINI .or. PEDIDO->Data_ped > dFIM
         PEDIDO->(dbskip())
         loop
      endif


      LANC->(dbseek(PEDIDO->Codigo))
      do while ! LANC->(eof()) .and. LANC->Cod_ped == PEDIDO->Codigo

         aadd(aMov,{LANC->Cod_prod,LANC->Quant,0,0,0,0,0})
         LANC->(dbskip())

      enddo

      PEDIDO->(dbskip())

   enddo
return



static function getSaiOPs

   ENT_ACA->(dbgotop())
   set softseek on
   ENT_ACA->(dbseek(dtos(dINI)))
   set softseek off

   do while ! ENT_ACA->(eof())

      qgirabarra()

      if ENT_ACA->Data < dINI .or. ENT_ACA->Data > dFIM
         ENT_ACA->(dbskip())
         loop
      endif


      ITEN_ACA->(dbseek(ENT_ACA->Cod_prod))
      do while ! ITEN_ACA->(eof()) .and. ITEN_ACA->Cod_aca == ENT_ACA->Cod_prod

         aadd(aMov,{right(ITEN_ACA->produto,5),0,ENT_ACA->Quantidade * ITEN_ACA->Quantidade,0,0,0,0})

         ITEN_ACA->(dbskip())

      enddo

      ENT_ACA->(dbskip())

   enddo

return


static function getPerdas

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   PROD->(dbsetorder(4))

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,4) $ "5927-6927"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_prod))
          if PROD->Tipo  == "2"
             aadd(aMov,{ITEN_FAT->Cod_prod,0,0,ITEN_FAT->Quantidade,0,0,0})
          endif

          ITEN_FAT->(Dbskip())

      enddo
      FAT->(dbskip())
   enddo


return

static function getBaixas

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   PROD->(dbsetorder(4))

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,4) $ "5927-6927"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_prod))
          if PROD->Tipo == "1"
             aadd(aMov,{ITEN_FAT->Cod_prod,0,0,0,0,0,ITEN_FAT->Quantidade})
          endif

          ITEN_FAT->(Dbskip())

      enddo
      FAT->(dbskip())
   enddo


return



static function getEntOPs

   ENT_ACA->(dbgotop())
   set softseek on
   ENT_ACA->(dbseek(dtos(dINI)))
   set softseek off

   do while ! ENT_ACA->(eof())

      qgirabarra()

      if ENT_ACA->Data < dINI .or. ENT_ACA->Data > dFIM
         ENT_ACA->(dbskip())
         loop
      endif

      aadd(aMov,{ENT_ACA->Cod_prod,0,0,0,ENT_ACA->Quantidade,0,0})

      ENT_ACA->(dbskip())

   enddo

return





static function getVendas

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   PROD->(dbsetorder(4))

   do while ! FAT->(eof())


      if FAT->dt_emissao < dINI .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif


      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if left(FAT->Cod_cfop,4) $ "5927-6927"
         FAT->(dbskip())
         loop
      endif


      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          if FAT->Es ==  "S"
             aadd(aMov,{ITEN_FAT->Cod_prod,0,0,0,0,ITEN_FAT->Quantidade,0})
          endif

          ITEN_FAT->(Dbskip())

      enddo
      FAT->(dbskip())
   enddo




return



static function criaProduto
  local aStruct := {}

  aStruct := { ;
             {"COD_PROD"  ,"C",5 ,0},;
             {"SALDO_INI" ,"N",15,4},;
             {"COMPRA"    ,"N",15,4},;
             {"SAIOP"     ,"N",15,4},;
             {"PERDA"     ,"N",15,4},;
             {"ENTOP"     ,"N",15,4},;
             {"BAIXA"     ,"N",15,4},;
             {"VENDA"     ,"N",15,4} ;
             }

   dbCreate(XDRV_HB+"PRODUTO.DBF",aStruct)

   if ! Quse(XDRV_HB,"PRODUTO",{""},,"PRODUTO")
      qmensa("Erro ao criar arquivo temporario de Produto!","BL")
      return .F.
   endif

   index on COD_PROD tag UM
   dbsetindex(XDRV_HB+"PRODUTO.CDX")


return

static function delProduto

   PRODUTO->(dbclosearea())

   if file(XDRV_HB+"PRODUTO.DBF")
      erase(XDRV_HB+"PRODUTO.DBF")
   endif

   if file(XDRV_HB+"PRODUTO.CDX")
      erase(XDRV_HB+"PRODUTO.CDX")
   endif


return

static function getCusto(cPROD)
local nCusto := 0

   ITEN_ACA->(dbgotop())
   ITEN_ACA->(dbseek(cPROD))

   do while ! ITEN_ACA->(eof()) .and. ITEN_ACA->cod_aca == cPROD
      PROD->(dbseek(right(ITEN_ACA->Produto,5)))
      nCusto += round(PROD->Preco_cust * ITEN_ACA->Quantidade,2)

      ITEN_ACA->(dbskip())
   enddo

return nCusto

static function getSaldo(cPROD)
local cANOMES := strzero(year(dINI),4)+strzero(month(dINI),2)
local nResult := 0

   MOVIMES->(dbsetorder(4))
   if MOVIMES->(dbseek(cPROD+cANOMES))
      nResult := MOVIMES->Saldo_ini
   else
      nResult := 0
   endif

return nResult

static function getSemMov
local nReg   := 0
local nIndex := 0

local nReg2   := 0
local nIndex2 := 0


   nReg   := MOVIMES->(recno())
   nIndex := MOVIMES->(IndexOrd())

   MOVIMES->(dbsetorder(1))
   MOVIMES->(dbgotop())
   MOVIMES->(dbseek(cAM))


   do while ! MOVIMES->(eof()) .and. MOVIMES->Anomes == cAM
      if ! PRODUTO->(dbseek(MOVIMES->Cod_prod))
         if PRODUTO->(Qappend())

            nReg2   := MOVIMES->(recno())
            nIndex2 := MOVIMES->(IndexOrd())

            replace PRODUTO->Saldo_ini with getSaldo(MOVIMES->Cod_prod)

            MOVIMES->(dbsetorder(nIndex2))
            MOVIMES->(dbgoto(nReg2))

            replace PRODUTO->cod_prod with MOVIMES->Cod_prod

            PROD->(dbsetorder(4))
            PROD->(dbseek(MOVIMES->Cod_prod))


         endif
      endif

      MOVIMES->(dbskip())
   enddo


   MOVIMES->(dbsetorder(nIndex))
   MOVIMES->(dbgoto(nReg))





return



