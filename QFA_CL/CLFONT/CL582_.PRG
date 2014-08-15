//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MARÇO DE 2012
// OBS........:
// ALTERACOES.:

function cl582
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dFIM) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR  := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private XDRV_HB := "C:\QSYSTXT\"
private aFAT    := {}
private asFAT   := {}
private nMantra       := 0
private nTerceiros    := 0
private nVendas       := 0
private nEstoqueChina := 0

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nVENDAS,"9")     } , "VEN"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nMANTRA,"9")     } , "MAN"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nTERCEIROS,"9")  } , "TER"    })

do while .T.

   qlbloc(5,0,"B582A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   nMAntra := 0
   nTerceiros := 0
   nVendas := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FIM"
           
           qrsay(XNIVEL+1,str(nVendas,1) )
           qrsay(XNIVEL+2,str(nMantra    := 1,1) )
           qrsay(XNIVEL+3,str(nTerceiros := (nVendas-1),1) )

      case cCAMPO == "MAN"
	       dINI := dFIM - (nVendas * 30)
           nTerceiros := nVendas
           nTerceiros := nTerceiros - nMantra
           qrsay(XNIVEL+1, str(nTerceiros,1) )

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PRODUTOS FATURADOS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.


static function i_impressao

   //if ! qinitprn() ; return ; endif

   i_reserva()
   criaProduto()

   i_geraArquivo()

   eraseFiles()
   delProduto()



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO EM EXCEL__________________

static function i_GeraArquivo
    local nCONT      := 0
    local nQUANT     := 0
    local nQUANT_ENT := 0
    local cPROD      := ""
    local aEstoque := {}
    local nPedido    := 0
    local nEntregue  := 0
    local nTransito  := 0
    local nProducao  := 0
    local nPendencia := 0
    local nMovTerc   := 0
    local nJITTerc   := 0
    local nJITMantra := 0
    local nSubtraiChina  := 0
    local nSendtoTerc    := 0
    local nBringFromTerc := 0
    local nMESES         := 0
	local nSaidaChina    := 0
	local nEstoqueChina  := 0
	local EmbarqueImediato := 0 
	local nSaldoEstoqueChina := 0
	local nNovoPedido := 0
	local nLeftChina := 0
	local nFile := 0
	local cBuffer := ""

    aFAT := {}
    asFAT := {}
	PROD->(dbsetorder(4))



   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-591-691-120-220"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek(FAT->Cod_cli))

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          if FAT->Es == "S"
             aadd(aFAT,{ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,0,0,0,0,0,0,0})
          else
             aadd(aFAT,{ITEN_FAT->Cod_prod,0,ITEN_FAT->Quantidade,0,0,0,0,0,0})
          endif

          ITEN_FAT->(Dbskip())

      enddo
      FAT->(dbskip())
   enddo


   getProduzindo()
   getPendencia()
   getEstoqueChina()

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if len (asFAT) > 0
       cPROD := asFAT[1,1]

       nCONT := 1
       do while  nCONT <= len(asFAT)

           nQUANT        += asFAT[nCONT,2]
           nQUANT_ENT    += asFAT[nCONT,3]
           nPedido       += asFAT[nCONT,4]
           nEntregue     += asFAT[nCONT,5]
           nTransito     += asFAT[nCONT,6]
           nPendencia    += asFAT[nCONT,7]
		   nEstoqueChina += asFAT[nCont,8]

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cPROD
              if PRODUTO->(qappend())
                 replace PRODUTO->Cod_prod  with cPROD
				 PROD->(dbsetorder(4))
				 PROD->(dbseek(cPROD))
				 replace PRODUTO->Referencia with PROD->Cod_fabr

                 INVENT->(dbsetorder(4))
                 INVENT->(dbseek(cPROD))

                 if INVENT->Data <= dINI
                    nMESES := nVENDAS
                 else
                    nMESES := int((dFIM - INVENT->Data) / 30.5)
                 endif


                 replace PRODUTO->Data      with INVENT->Data
                 replace PRODUTO->Fator     with nMESES
                 replace PRODUTO->Quant4    with (nQUANT - nQUANT_ENT) / nMESES
                 aEstoque := i_CalcEstoque(cPROD)
                 replace PRODUTO->Local     with aEstoque[1,1]
                 replace PRODUTO->Terceiros with nEstoqueChina 
				 
                 replace PRODUTO->Pedido    with nPedido
                 replace PRODUTO->Entregue  with nEntregue
                 replace PRODUTO->Transito  with nTransito
                 replace PRODUTO->Pendencia with nPendencia
				 
                 replace PRODUTO->Producao  with(nPedido - (nEntregue + nTransito) )
              endif

              cPROD := asFAT[nCONT,1]

              nQUANT_ENT := 0
              nQUANT     := 0
              nPedido    := 0
              nEntregue  := 0
              nTransito  := 0
              nProducao  := 0
              nPendencia := 0
			  nEstoqueChina := 0 
		      nSaidaChina   := 0

           endif
       enddo

       if PRODUTO->(qappend()) .and. (nQUANT - nQUANT_ENT) <> 0
          replace PRODUTO->Cod_prod  with cPROD
		  PROD->(dbsetorder(4))
		  PROD->(dbseek(cPROD))
		  replace PRODUTO->Referencia with PROD->Cod_fabr
          INVENT->(dbsetorder(4))
          INVENT->(dbseek(cPROD))

          if INVENT->Data <= dINI
             nMESES := nVENDAS
          else
             nMESES := int((dFIM - INVENT->Data) / 30.5)
          endif

          replace PRODUTO->Data      with INVENT->Data
          replace PRODUTO->Fator     with nMESES

          replace PRODUTO->Quant4    with (nQUANT - nQUANT_ENT) / nMESES
          aEstoque := i_CalcEstoque(cPROD)
          replace PRODUTO->Local     with aEstoque[1,1]
          replace PRODUTO->Terceiros with nEstoqueChina
          replace PRODUTO->Pedido    with nPedido
          replace PRODUTO->Entregue  with nEntregue
          replace PRODUTO->Transito  with nTransito
          replace PRODUTO->Producao  with (nPedido - (nEntregue + nTransito) )
          replace PRODUTO->Pendencia with nPendencia
       endif


       nQUANT     := 0
       nQUANT_ENT := 0
       nPedido    := 0
       nEntregue  := 0
       nTransito  := 0
       nProducao  := 0
       nPendencia := 0
	   nEstoqueChina := 0 
	   nSaidaChina   := 0

   endif

   PROD->(dbgotop())
   do while ! PROD->(eof())

      if right(PROD->Codigo,5) == "     "
         PROD->(dbskip())
         loop
      endif

      if PROD->Fora_linha == "S" .or. PROD->FimdeVida == "S"
         PROD->(dbskip())
         loop
      endif
	  
      PRODUTO->(dbsetorder(1))
      if ! PRODUTO->(dbseek(right(PROD->Codigo,5)))
         if PRODUTO->(qappend())
            replace PRODUTO->Cod_prod  with right(PROD->Codigo,5)
			replace PRODUTO->Referencia with PROD->Cod_Fabr
            INVENT->(dbsetorder(4))
            INVENT->(dbseek(right(PROD->Codigo,5)))

            if INVENT->Data <= dINI
               nMESES := nVENDAS
            else
               nMESES := int((dFIM - INVENT->Data) / 30.5)
            endif

            replace PRODUTO->Data      with INVENT->Data
            replace PRODUTO->Fator     with nMESES

            replace PRODUTO->Quant4    with 0
            aEstoque := i_CalcEstoque(right(PROD->Codigo,5))
            replace PRODUTO->Local     with aEstoque[1,1]
            replace PRODUTO->Terceiros with 0
            replace PRODUTO->Pedido    with 0
            replace PRODUTO->Entregue  with 0
            replace PRODUTO->Transito  with 0
            replace PRODUTO->Producao  with 0
            replace PRODUTO->Pendencia with 0
         endif
      endif


      PROD->(dbskip())
   enddo
   
   cBuffer := ""
   cBuffer += xmlAbre(7560,19980,240,105)
   cBuffer += xmlStyles()
   cBuffer += xmlFechaStyles()
   cBuffer += xmlAbrePasta("Just In Time")
   cBuffer += xmlColunas()
   
   cBuffer += xmlAbreLinha()
      cBuffer += xmlCell("String","Relatorio Just in Time - 582 from "+dtoc(dINI)+" to "+dtoc(dFIM),NIL,2,NIL)
   cBuffer += xmlFechaLinha()
   
   cBuffer += '<Row ss:Height="18.75">'+chr(13)+chr(10)
   cBuffer += '<Cell ss:MergeAcross="7" ss:StyleID="s82"><Data ss:Type="String">Planning area</Data></Cell>'+chr(13)+chr(10)
   cBuffer += '<Cell ss:Index="10" ss:MergeAcross="4" ss:StyleID="s83"><Data ss:Type="String">CHINA WARE HOUSE - ORDER CONTROL</Data></Cell>'+chr(13)+chr(10)
   cBuffer += '<Cell ss:Index="16" ss:MergeAcross="2" ss:StyleID="s84"><Data ss:Type="String">FACTORY AND CHINA WHARE HOUSE CONTROL</Data></Cell>'+chr(13)+chr(10)
   cBuffer += '<Cell ss:Index="20" ss:MergeAcross="1" ss:StyleID="s85"><Data ss:Type="String">NEW ORDER</Data></Cell>'+chr(13)+chr(10)
   cBuffer += '</Row>'+chr(13)+chr(10)
   
   cBuffer += xmlAbreLinha(70,"s63",0)
       cBuffer += xmlCell("String","Ref","s66")
       cBuffer += xmlCell("String","Descriptions","s66") 
	   cBuffer += xmlCell("String","First order","s66")
	   cBuffer += xmlCell("String","Months of sales","s66")
	   cBuffer += xmlCell("String","Average sales. INPUT "+str(nVendas,1)+" Months","s66")
	   cBuffer += xmlCell("String","units needed in Brasil WH"+str(nMantra,1),"s66")
	   cBuffer += xmlCell("String","units needed in China WH"+str(nTerceiros,1),"s66")
	   cBuffer += xmlCell("String","LEFT SALES","s66")
	   cBuffer += xmlCell("String","")
	   cBuffer += xmlCell("String","TOTAL UNITS Brasil WH","s80")
	   cBuffer += xmlCell("String","TOTAL UNITS CHINA WH","s80")
	   cBuffer += xmlCell("String","Brasil ORDER","s80")
	   cBuffer += xmlCell("String","Delivered to Brasil","s80")
	   cBuffer += xmlCell("String","TOTAL UNITS CHINA WH |AD","s80")
	   cBuffer += xmlCell("String","")
	   cBuffer += xmlCell("String","In production","s73")
	   cBuffer += xmlCell("String","FACTORY DELIVERED TO CHINA WAREHOUSE","s73")
	   cBuffer += xmlCell("String","Left China","s73")
	   cBuffer += xmlCell("String","")
	   cBuffer += xmlCell("String","ORDER SYSTEM SUGESTION","s75")
	   cBuffer += xmlCell("String","SPACE FOR FINAL ORDER QTY.","s75")
   cBuffer += xmlFechaLinha()
   
   PRODUTO->(dbsetorder(2))
   PRODUTO->(dbgotop())
   do while ! PRODUTO->(eof())

   PROD->(dbseek(PRODUTO->Cod_prod))
       cBuffer += xmlAbreLinha() 
         cBuffer += xmlCell("String",PROD->Cod_fabr,"s66")
	     cBuffer += xmlCell("String",rtrim(PROD->Descricao),"s66")
	     cBuffer += xmlCell("String",dtoc(PRODUTO->Data),"s66")
	     cBuffer += xmlCell("String",iif(PRODUTO->Data > dINI,transf(PRODUTO->Fator,"@R 9999"),str(nVendas,1)),"s66")
	     cBuffer += xmlCell("Number",alltrim(transf(PRODUTO->Quant4,"@R 99999999")),"s66")
		 cBuffer += xmlCell("Number",alltrim(transf(PRODUTO->Quant4*nMantra,"@R 99999999")),"s66")
		 cBuffer += xmlCell("Number",alltrim(transf(PRODUTO->Quant4*nTerceiros,"@R 99999999")),"s66")
		 cBuffer += xmlCell("Number",alltrim(transf(PRODUTO->Pendencia,"@R 99999999")),"s66")
		 cBuffer += xmlCell("String","")
		 
		 nJITMantra := (PRODUTO->Quant4 * nMantra)
         nJITTerc   := (PRODUTO->Quant4 * nTerceiros)
	  
	     nEmbarqueImediato  := (nJITMantra + PRODUTO->Pendencia) - PRODUTO->Local  
	     nSaldoEstoqueChina := (PRODUTO->Terceiros - PRODUTO->Transito) - nEmbarqueImediato 
	     nLeftChina         := PRODUTO->Producao - PRODUTO->Terceiros //Em Produção - Produzido
	     nNovoPedido := (nJITTerc - nSaldoEstoqueChina) - PRODUTO->Producao
		 
		 cBuffer += xmlCell("Number",alltrim(transf(PRODUTO->local,"@R 99999999")),"s80")
		 cBuffer += xmlCell("Number",alltrim(transf(PRODUTO->terceiros,"@R 99999999")),"s80")
		 cBuffer += xmlCell("Number",alltrim(transf(nEmbarqueImediato,"@R 99999999")),"s80")
		 cBuffer += xmlCell("Number",alltrim(transf(PRODUTO->Transito,"@R 99999999")),"s80")
		 cBuffer += xmlCell("Number",alltrim(transf(nSaldoEstoqueChina,"@R 99999999")),"s80")
		 cBuffer += xmlCell("String","")
		 cBuffer += xmlCell("Number",alltrim(transf(PRODUTO->Producao,"@R 99999999")),"s73")
		 cBuffer += xmlCell("Number",alltrim(transf(PRODUTO->Terceiros,"@R 99999999")),"s73")
		 cBuffer += xmlCell("Number",alltrim(transf(nLeftChina,"@R 99999999")),"s73")
		 cBuffer += xmlCell("String","")
		 cBuffer += xmlCell("Number",alltrim(transf(nNovoPedido,"@R 99999999")),"s75")
		 cBuffer += xmlCell("String","","s75")
	   cBuffer += xmlFechaLinha() 
		 
  
	    

      PRODUTO->(dbskip())
   enddo
   cBuffer += xmlFechaPasta()
   cBuffer += xmlFecha()
   
   cFileName := "Rel 582 - Just In Time "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".xml"
   
   nFile := fCreate("C:\Qsystxt\"+cFileNAme,0)
   fWrite(nFile,cBuffer,len(cBuffer))
   fClose(nFile)
   alert("Arquivo gerado na pasta c:\qsystxt !")


return


static function getProduzindo

   PED_FABR->(dbsetorder(2)) // data de emissao
   PED_FABR->(dbgotop())
   ITEN_PED->(dbsetorder(1))

   do while ! PED_FABR->(eof())  // condicao principal de loop

      qmensa("Aguarde... Processando ...")


      ITEN_PED->(Dbgotop())
      ITEN_PED->(Dbseek(PED_FABR->Codigo))
      do while ITEN_PED->Cod_ped == PED_FABR->Codigo .and. ! ITEN_PED->(eof())
          aadd(aFAT,{ITEN_PED->Cod_prod,0,0,ITEN_PED->Quantidade,0,0,0,0,0})
          ITEN_PED->(Dbskip())
      enddo

      PED_FABR->(dbskip())
   enddo


   INVOICE->(dbsetorder(2)) // data de emissao
   INVOICE->(dbgotop())
   ITEN_INV->(dbsetorder(1))

   do while ! INVOICE->(eof())  // condicao principal de loop

      qmensa("Aguarde... Processando ...")


      ITEN_INV->(Dbgotop())
      ITEN_INV->(Dbseek(INVOICE->Codigo))
      do while ITEN_INV->Cod_inv == INVOICE->Codigo .and. ! ITEN_INV->(eof())
         if ! empty(INVOICE->Dt_chegada)
            aadd(aFAT,{ITEN_INV->Cod_prod,0,0,0,ITEN_INV->Quantidade,0,0,0,0})
         else
            aadd(aFAT,{ITEN_INV->Cod_prod,0,0,0,0,ITEN_INV->Quantidade,0,0,0})
         endif
         ITEN_INV->(Dbskip())
      enddo

      INVOICE->(dbskip())
   enddo


return

static function getEstoqueChina

   WAREHOUS->(dbsetorder(2)) // data de emissao
   WAREHOUS->(dbgotop())
   ITEN_WAR->(dbsetorder(1))

   do while ! WAREHOUS->(eof())  // condicao principal de loop

      qmensa("Aguarde... Processando ...")


      ITEN_WAR->(Dbgotop())
      ITEN_WAR->(Dbseek(WAREHOUS->Codigo))
      do while ITEN_WAR->Cod_ware == WAREHOUS->Codigo .and. ! ITEN_WAR->(eof())
          aadd(aFAT,{ITEN_WAR->Cod_prod,0,0,0,0,0,0,ITEN_WAR->Quantidade,0})
          ITEN_WAR->(Dbskip())
      enddo

      WAREHOUS->(dbskip())
   enddo

return

static function getPendencia

   PEND->(dbsetorder(2)) // data de emissao
   PEND->(dbgotop())
   set softseek on
   PEND->(dbseek(dtos(dINI)))
   set softseek off
   ITEM_PEN->(dbsetorder(2))

   do while ! PEND->(eof())  .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop

      if ! left(PEND->Cod_cfop,3) $ "510-511-512-610-611-612-591-691-120-220"
         PEND->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEM_PEN->(Dbgotop())
      ITEM_PEN->(Dbseek(PEND->Codigo))
      do while ITEM_PEN->cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())

          aadd(aFAT,{ITEM_PEN->Cod_prod,0,0,0,0,0,ITEM_PEN->Quantidade,0,0})

          ITEM_PEN->(Dbskip())

      enddo
      PEND->(dbskip())
   enddo
return

static function i_reserva
local aPED := {}
local aPEDS := {}
local cLOTE   := space(10)
local cFILIAL := space(4)
local nQTY    := 0
local cPROD   := space(5)
local nCONT   := 1

  criaTmpFile()



FAT->(dbsetfilter({|| ( ! left(Cod_cfop,4) $ "5905-6905" ) .and. empty(num_fatura) .and. Es == "S" .and. No_nf == .F. }))
ITEN_FAT->(dbsetorder(2))
FAT->(dbgotop())

Do while ! FAT->(eof())

   ITEN_FAT->(Dbseek(FAT->Codigo))

   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      aadd(aPED,{ITEN_FAT->Cod_prod,FAT->Filial,ITEN_FAT->Num_Lote,ITEN_FAT->Quantidade})
      ITEN_FAT->(dbskip())
   enddo


   FAT->(Dbskip())
enddo

asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

if len(asPED) > 0
    cPROD   := asPED[1,1]
    cFILIAL := asPED[1,2]
    cLOTE   := asPED[1,3]
    nQTY    := 0

    nCONT := 1
    do while  nCONT <= len(asPED)

        nQTY += asPED[nCONT,4]

        nCONT++
        if nCONT > len(asPED)
           nCONT := len(asPED)
           exit
        endif

        if asPED[nCONT,1] != cPROD
           if RESERVA->(qappend())
              replace RESERVA->Cod_prod   with cPROD
              replace RESERVA->Filial     with cFILIAL
              replace RESERVA->Lote       with cLOTE
              replace RESERVA->Quantidade with nQTY
           endif

           cPROD   := asPED[nCONT,1]
           cFILIAL := asPED[nCONT,2]
           cLOTE   := asPED[nCONT,3]
           nQTY    := 0
        endif
    enddo

    if RESERVA->(qappend())
       replace RESERVA->Cod_prod   with cPROD
       replace RESERVA->Filial     with cFILIAL
       replace RESERVA->Lote       with cLOTE
       replace RESERVA->Quantidade with nQTY
    endif

endif

aPED := {}
asPED := {}
FAT->(dbclearfilter())
return



static function criaTmpFile
  local aStruct := {}

  aStruct := { ;
             {"COD_PROD"  ,"C",5 ,0},;
             {"FILIAL"    ,"C",4 ,0},;
             {"LOTE"      ,"C",10,0},;
             {"QUANTIDADE","N",12,2} ;
             }

   dbCreate(XDRV_HB+"RESERVA.DBF",aStruct)

   if ! Quse(XDRV_HB,"RESERVA",{""},,"RESERVA")
      qmensa("Erro ao criar arquivo temporario!","BL")
      return .F.
   endif

   index on COD_PROD tag Um
   dbsetindex(XDRV_HB+"RESERVA.CDX")


return

static function criaProduto
  local aStruct := {}

  aStruct := { ;
             {"COD_PROD"  ,"C",5 ,0},;
			 {"REFERENCIA","C",15 ,0},;
             {"DATA"      ,"D",8 ,0},;
             {"FATOR"     ,"N",12,0},;
             {"QUANT4"    ,"N",12,0},;
             {"PENDENCIA" ,"N",12,0},;
             {"LOCAL"     ,"N",12,0},;
             {"TERCEIROS" ,"N",12,0},;
             {"PEDIDO"    ,"N",12,0},;
             {"ENTREGUE"  ,"N",12,0},;
             {"TRANSITO"  ,"N",12,0},;
             {"PRODUCAO"  ,"N",12,0} ;
             }

   dbCreate(XDRV_HB+"PRODUTO.DBF",aStruct)

   if ! Quse(XDRV_HB,"PRODUTO",{""},,"PRODUTO")
      qmensa("Erro ao criar arquivo temporario de Produto!","BL")
      return .F.
   endif

   index on COD_PROD   tag UM
   index on REFERENCIA tag DOIS
   dbsetindex(XDRV_HB+"PRODUTO.CDX")


return


static function eraseFiles

   RESERVA->(dbclosearea())

   if file(XDRV_HB+"RESERVA.DBF")
      erase(XDRV_HB+"RESERVA.DBF")
   endif

   if file(XDRV_HB+"RESERVA.CDX")
      erase(XDRV_HB+"RESERVA.CDX")
   endif



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


static function i_calcEstoque(Cod_prod)
local nQUANT_RES  := 0  //Avariados
local nQUANT_AVAR := 0  //Avariados
local nQUANT_TER  := 0  //Em Transicao
local nQUANT_RT   := 0  //Em Transicao
local nQUANT_TT   := 0  //Em Transicao
local nQUANT      := 0  //Em Transicao
local aResult := {}

  INVENT->(dbsetorder(4))
  INVENT->(dbseek(Cod_prod))

  do while ! INVENT->(eof()) .and. INVENT->Cod_prod == Cod_Prod
     nQUANT      += INVENT->Quant_atu
     nQUANT_AVAR += INVENT->Quant_defe
     nQUANT_TER  += INVENT->QUANT_TER
     nQUANT_RT   += INVENT->QUANT_RES

     INVENT->(dbskip())
  enddo

  if RESERVA->(dbseek(cod_prod))
     nQUANT_RES := RESERVA->Quantidade
  else
     nQUANT_RES := 0
  endif

  nQUANT_TT   := (nQUANT + nQUANT_RES + nQUANT_TER - nQUANT_RT)

  aadd(aResult,{nQUANT+nQUANT_RES,nQUANT_TER-nQUANT_RT,nQUANT_TT})

return aResult


static function busca_media(dINICIAL,dFINAL)
local nMESES  := 0
local intCONT   := 0
local cANOMES := 0
local nANOMES_INI := 0
local nANOMES_FIM := 0
local lFIRST := .T.

cANOMES := strzero(year(dINICIAL),4)+strzero(month(dINICIAL),2)
nANOMES_INI := val(cANOMES)

cANOMES := strzero(year(dFINAL),4)+strzero(month(dFINAL),2)
nANOMES_FIM := val(cANOMES)

For intCONT :=  nANOMES_INI To nANOMES_FIM

    if right(strzero(intCONT),2) == "12"
       intCONT += 88
    endif

    nMESES++

next

return nMESES

static function xmlStyles
local xml := ""
	 
   xml += '<Style ss:ID="Default" ss:Name="Normal">'+chr(13)+chr(10)
   xml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders/>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior/>'+chr(13)+chr(10)
   xml += '<NumberFormat/>'+chr(13)+chr(10)
   xml += '<Protection/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s62">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s63">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s64">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s66">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s73">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#CCC0DA" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
  
   xml += '<Style ss:ID="s75">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#EBF1DE" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s80">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#F2DCDB" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s81">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#CCC0DA" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s82">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
    xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
    xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
    xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
    xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
    xml += '</Borders>'+chr(13)+chr(10)
    xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="14" ss:Color="#000000"'+chr(13)+chr(10)
    xml += 'ss:Bold="1"/>'+chr(13)+chr(10)
    xml += '<Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>'+chr(13)+chr(10)
	xml += '</Style>'+chr(13)+chr(10)
    
	
    xml += '<Style ss:ID="s83">'+chr(13)+chr(10)
    xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
    xml += '<Borders>'+chr(13)+chr(10)
    xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
    xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
    xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
    xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
    xml += '</Borders>'+chr(13)+chr(10)
    xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"'+chr(13)+chr(10)
    xml += 'ss:Bold="1"/>'+chr(13)+chr(10)
    xml += '<Interior ss:Color="#F2DCDB" ss:Pattern="Solid"/>'+chr(13)+chr(10)
    xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s84">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"'+chr(13)+chr(10)
   xml += 'ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#CCC0DA" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s85">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"'+chr(13)+chr(10)
   xml += 'ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#EBF1DE" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
	 
return xml

static function xmlColunas
local xml := ""
   xml += '<Column ss:StyleID="s62" ss:Width="54.75"/>'+chr(13)+chr(10)
   xml += '<Column ss:AutoFitWidth="0" ss:Width="200.25"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="56.25"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:Width="49.5"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Span="1"/>'+chr(13)+chr(10)
   xml += '<Column ss:Index="7" ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="58.5"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="59.25"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="10.5"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Span="1"/>'+chr(13)+chr(10)
   xml += '<Column ss:Index="12" ss:StyleID="s62" ss:Width="52.5"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="59.25"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:Width="56.25"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="12"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="62.25"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="85.5"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="61.5"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s64" ss:AutoFitWidth="0" ss:Width="13.5"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:Width="57.75"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="90.75"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Span="7"/>'+chr(13)+chr(10)

return xml
