/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE BAIXAS SEM CONTABILIZACAO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1999
// OBS........:
// ALTERACOES.:
function es114

private cANOMES := "       "
private dINI    := dFIM := ctod("")
private cAM     := ""
private XDRV_HB := "C:\QSYSTXT\"

PROD->(dbsetorder(4))

MOVIMES->(qview({ {"c114a()/MesAno"              ,1},;
                  {"Cod_prod/Cod."                ,2},;
                  {"Produto/Produto"              ,3},;
                  {"Saldo_ini/Saldo Inicial"      ,0}},"P",;
                  {NIL,"c114c",NIL,NIL},;
                   NIL,"<I>ncluir / <C>onsultar / <A>lterar / <F>echa Mes"))


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO _______________________________

function c114a
return right(MOVIMES->Anomes,2)+"/"+left(MOVIMES->Anomes,4)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c114c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "ICAE"
      qlbloc(11,6,"B114A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   if cOPCAO == "F"
      if qconf("Fecha Mes?","BL")
         i_FechaMes()
      endif

   endif


   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||Lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , right(MOVIMES->Anomes,2)+"/"+left(MOVIMES->Anomes,4)     )
      qrsay ( XNIVEL++ , MOVIMES->Cod_prod   ) ; PROD->(dbseek(MOVIMES->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40))
      qrsay ( XNIVEL++ , MOVIMES->Saldo_ini )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   cANOMES := "       "


   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@cANOMES    ,"99/9999")                  },"ANOMES"      })
   aadd(aEDICAO,{{ || view_prod1(-1,0,@fCOD_PROD)                          },"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSALDO_INI    ,"99999999.999")           },"QUANTIDADE"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MOVIMES->(qpublicfields())
   iif(cOPCAO=="I",MOVIMES->(qinitfields()),MOVIMES->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; MOVIMES->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if MOVIMES->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      cANOMES := alltrim(qtiraponto(cANOMES))

      fANOMES := right(cANOMES,4)+left(cANOMES,2)

      MOVIMES->(qreplacefields())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP
   local nREG   := 0
   local nINDEX := 0
   local cAM := ""


   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "ANOMES"


      case cCAMPO == "COD_PROD"

           if empty(fCOD_PROD) ; return .F. ; endif

           qrsay(XNIVEL,fCOD_PROD := strzero(val(fCOD_PROD),5))

           if ! PROD->(dbseek(fCOD_PROD:=strzero(val(fCOD_PROD),5)))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif


           nREG    := MOVIMES->(recno())
           nINDEX  := MOVIMES->(indexOrd())
           cAM := right(cANOMES,4)+left(cANOMES,2)

           MOVIMES->(dbsetorder(4))

           if MOVIMES->(dbseek(fCOD_PROD+cAM))
              qmensa("Saldo ja incluido!","BL")
              MOVIMES->(dbsetorder(nINDEX))
              return .F.
           endif


           qrsay(XNIVEL+1,left(PROD->Descricao,40) )
           fPRODUTO := PROD->Descricao

           MOVIMES->(dbgoto(nREG))
           MOVIMES->(dbsetorder(nINDEX))


      case cCAMPO == "QUANTIDADE"
           if empty(fSALDO_INI) ; return .F. ; endif


   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR BAIXA ________________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Movimes ?")
      if MOVIMES->(qrlock())
         MOVIMES->(dbdelete())
         MOVIMES->(qunlock())
      else
         qm3()
      endif
   endif
return



static function i_FechaMes
local cPROD      := ""
local nCONT      := ""
local nTotal     := 0
local ncompras   := 0
local nSaldo_final := 0
local nPreco_cust  := 0
local nVendas    := 0
local nPerdas    := 0
local nSaidaOP   := 0 //Materia Prima
local nEntradaOP := 0 //Produto acabado
local cPIC  := "@E 9,999,999.99"
local cPICQ := "@R 999999.99"
local nGeral := 0

   dINI := qinimes(  ctod("01/"+right(MOVIMES->Anomes,2)+"/"+left(MOVIMES->Anomes,4) ) )
   dFIM := qfimmes(dINI)
   cAM := inc(MOVIMES->Anomes)

   criaProduto()

   aMov := {}

   getCompras()
   getSaiOPs()
   getPerdas()

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
              endif

              cPROD :=aMov[nCONT,1]

              nCompras   := 0
              nSaidaOP   := 0
              nEntradaOP := 0
              nVendas    := 0
              nPerdas    := 0
              nTotal     := 0

           endif
       enddo

       nTotal := nCompras + nSaidaOP + nEntradaOP + nVendas + nPerdas

       if nTotal > 0
          if PRODUTO->(qappend())
             replace PRODUTO->Cod_prod  with cPROD
             replace PRODUTO->Saldo_ini with getSaldo(cPROD)
             replace PRODUTO->Compra    with nCompras
             replace PRODUTO->SaiOP     with nSaidaOP
             replace PRODUTO->EntOP     with nEntradaOP
             replace PRODUTO->Venda     with nVendas
             replace PRODUTO->Perda     with nPerdas
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

   PRODUTO->(dbgotop())
   do while ! PRODUTO->(eof())

      nSaldo_final := 0
      nPreco_cust  := 0

      PROD->(dbseek(PRODUTO->Cod_prod))

      if PROD->Tipo == "2"
         nSaldo_final := (PRODUTO->Saldo_ini + PRODUTO->Compra) - (PRODUTO->SaiOP + PRODUTO->Perda)
      else
         nSaldo_final := (PRODUTO->Saldo_ini + PRODUTO->EntOP) - (PRODUTO->Venda)
      endif

      MOVIMES->(dbsetorder(4))
      if MOVIMES->(dbseek(PRODUTO->Cod_prod+cAM))
         if MOVIMES->(qrlock())
            replace MOVIMES->Saldo_ini with nSaldo_final
            MOVIMES->(qunlock())
         endif
      else
         if MOVIMES->(qappend())
            replace MOVIMES->Saldo_ini with nSaldo_final
            replace MOVIMES->Anomes    with cAM
            replace MOVIMES->cod_prod  with PRODUTO->Cod_Prod
            replace MOVIMES->Produto   with PROD->Descricao
         endif

      endif

      PRODUTO->(dbskip())
   enddo

   delProduto()

   select MOVIMES

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

         aadd(aMov,{LANC->Cod_prod,LANC->Quant,0,0,0,0})
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

         aadd(aMov,{right(ITEN_ACA->produto,5),0,ENT_ACA->Quantidade * ITEN_ACA->Quantidade,0,0,0})

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

          aadd(aMov,{ITEN_FAT->Cod_prod,0,0,ITEN_FAT->Quantidade,0,0})

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

      aadd(aMov,{ENT_ACA->Cod_prod,0,0,0,ENT_ACA->Quantidade,0})

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
             aadd(aMov,{ITEN_FAT->Cod_prod,0,0,0,0,ITEN_FAT->Quantidade})
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


static function inc(cANOMES)
  local cResult := ""
  local nMES   := 0

  nMES := val( right(ANOMES,2) ) + 1

  cResult := left(cANOMES,4)+strzero(nMES,2)


return cResult

