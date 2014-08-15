/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Exportar Dados p/ Mysql
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: Agosto de 2009
// OBS........:
// ALTERACOES.:

#include "inkey.ch"
#include "dbinfo.ch"
#include "error.ch"
#include "hbrddsql.ch"

function cl440
//REQUEST SDDMY, SQLMIX
//ANNOUNCE RDDSYS
//FIELD RESIDENTS

 if ! qconf("Deseja buscar dados dos pedidos do sistema Web ?")
    return .F.
  endif
  
  if ! empty(CONFIG->QSysoff)
     qmensa("Opção desabilidata!!","BL")
   	 return .F.
  endif

  i_importa()

return


static function i_importa

   local oServer, oRow
   local oQuery
   local ncont
   
   PROD->(dbsetorder(4))
   
   oServer := TMySQLServer():New(XSERVER, "root", "borios")
   if oServer:NetErr()
      Alert(oServer:Error())
   endif

   oServer:SelectDB("comercial")
   
   cQuery := "SELECT p.*, c.codigo_contabil as subtipo  from pedido_venda as p " 
   cQuery += "left outer join cfops as c on c.id = p.cfop_id where p.exportado_pro_qsys = 0 and status_id = 2"
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      oRow := oQuery:getRow(nCont)
	  
	  PEND->(qpublicfields())
	  PEND->(Qinitfields())
	  
	  if CONFIG->(qrlock())
         replace CONFIG->Cod_pend with CONFIG->Cod_Pend + 1
         fCODIGO := strzero(CONFIG->Cod_pend,5)
		 CONFIG->(qunlock())
      endif
	  
	  cCodigo     := fCodigo
	  nPedidoId   := oRow:fieldget('id')
	  fCod_cli    := strzero(oRow:fieldget('id_cliente'),5)
	  fDt_emissao := dTimeToDate(oRow:fieldget('data_pedido'))
	  
	  //fDt_emissao := oRow:fieldget('data_pedido')
	  fData_lanc  := fDt_emissao
	  fData_ped   := fDt_emissao
	  dData_emissao := fDt_emissao
	  
	  fFilial     := "0001"
	  fC_Custo    := "0005"
	  fCod_cfop   := str(oRow:fieldget('cfop_id'))
	  fDesc_SN    := "N"
	  fNum_fatura := ""
	  fObs        := "PED.: "+rtrim(oRow:fieldget('ordem_de_compra')) +" " 
	  fObs        += rtrim(oRow:fieldget('observacoes'))
	  
	  fTipoSub    := oRow:fieldget('subtipo')
	  
	  //alert(oRow:fieldget('observacoes'))
	  	  
	  if fCod_cfop $ "6910-5910"
	  	 fTipoSub := "010001"   
	  endif
	  
	  if fCod_cfop $ "6916-5916"
	  	 fTipoSub := "010003"   
	  endif
	  
	  cCfop := fCod_cfop
	  
	  CLI1->(dbseek(fCod_cli))
	  fCOD_VENDED :=  CLI1->Cod_vend
	  fCod_transp   := strzero(oRow:fieldget(oRow:fieldpos('transportadora_id')),5)
	  fCliente    := CLI1->Razao
	  fEs := "S"
	  fVezes := buscaQtdeDeParcelas(oServer,nPedidoId)
	  fBoleto     := strzero(oRow:fieldget('informacao_boleto') + 1,1)
	  fPedido     := oRow:fieldget('ordem_de_compra')
	  fFrete      := strzero(oRow:fieldget('tipo_frete') + 1,1)
	  fCod_repres := strzero(oRow:fieldget('representante_id'),5)
	  fCod_resp   := strzero(oRow:fieldget('responsavel_id'),5)
	  
	  if PEND->(Qappend())
	     PEND->(QreplaceFields())
	  endif
	  PEND->(qreleasefields())
	  
	  preencheItens(oServer,cCodigo,nPedidoId,dData_emissao,Cli1->Comis_repr,cCfop)
	  preencheParcelas(oServer,cCodigo,nPedidoId,dData_emissao)
	  
	  

	  nCont++
	  
   enddo
   
  // atualizaProdutos(oServer)
   
   PEND->(dbCommit())
   
   setaSqlComoExportado(oServer)
return

static function preencheItens(oSv,cCodigo,nPedidoId,dt_emissao,nComissao,cCfop)
  local nCont := 1
  local query, row
  local cQuery := "select i.*, p.aliquota_ipi as ipi from item_pedido_venda as i " 
        cQuery += "left outer join produtos p on p.id = i.produto_id where i.pedido_id =" + alltrim(str(nPedidoId)) 

  query := oSv:Query(cQuery)
  if query:NetErr()
      Alert(query:Error())
   endif
  
  nCont := 1
   
  do while nCont <= query:LastRec() 	
     row := query:getRow(nCont)
	 
	 ITEM_PEN->(qpublicfields())
	 ITEM_PEN->(qinitfields())
	 
	 fCod_pend := cCodigo
	 fData    := dt_emissao
	 fCod_prod :=  strzero(row:fieldget('produto_id'),5)
	 fQuantidade := row:fieldget('quantidade')
	 fQuant_ped  := row:fieldget('quantidade')
	 fPreco_vend := row:fieldget('preco_tabela')
	 fDesc_prod  := row:fieldget('desconto')
	 
	 if fDesc_prod >= 100
	    fDesc_prod := 99.99  
	 endif
	 
	 if fDesc_prod > 0
		fVlr_Desc   := round(fPRECO_VEND * (fDESC_PROD/100),2)
		fVl_unitar := round(fPRECO_VEND - fVLR_DESC,2)
	 else
	    fvlr_desc  := 0
		fVl_unitar := round(row:fieldget('valor_unitario'),2)
	 endif	
		   
	 fCalc_desc  := "N"
	 fIcms_subst := "N"
	 fNum_lote   := replicate("0",10)
	 fProd_ser := "1"
	 fComi_repre := nComissao
	 fCod_sit := "100"
	 
	 PROD->(dbseek(fCod_prod))
	 fPreco_cust := PROD->Preco_cust
	 fPontos     := PROD->Pontos
	
	 fIpi        := row:fieldget('ipi')
	 fIcms       := pegaAliquotaDeIcms(cCfop)
	 
	 if ITEM_PEN->(Qappend())
	     ITEM_PEN->(QreplaceFields())
	  endif
	  ITEM_PEN->(qreleasefields())
	 
	 nCont ++
  
  enddo
  
  ITEM_PEN->(dbCommit())

return

static function preencheParcelas(oSv,cCodigo,nPedidoId,data_emissao)
  local nCont := 1
  local query, row
  local cQuery := "select * from parcelas_pedido as p where p.pedido_id =" +alltrim(str(nPedidoId))

  query := oSv:Query(cQuery)
  if query:NetErr()
      Alert(query:Error())
   endif
  
  nCont := 1
   
  do while nCont <= query:LastRec() 	
     row := query:getRow(nCont)
	 
	 DUP_PEN->(qpublicfields())
	 DUP_PEN->(qinitfields())
	 
	 fNum_pen   := cCodigo+strzero(nCont,2)
	 fDias      :=  row:fieldget('dias')
	 fData_venc :=  data_emissao + fDias
	 fValor     :=  row:fieldget('valor')
	 
	 if DUP_PEN->(Qappend())
	     DUP_PEN->(QreplaceFields())
	  endif
	  DUP_PEN->(qreleasefields())
	 
	 nCont ++
  
  enddo
  
  DUP_PEN->(dbCommit())

return

static function buscaQtdeDeParcelas(oSv,pedidoId)
local nCont := 1
local nVezes := 0
local oQuery, oRow
local cQuery := "select count(id) as vezes from parcelas_pedido as p where p.pedido_id =" + alltrim(str(pedidoId))

  oQuery := oSv:Query(cQuery)
  oRow := oQuery:getRow(1)
  nVezes := oRow:fieldget('vezes')
  
return nVezes

static function pegaAliquotaDeIcms(cCfop)
    local nIcms := 0
    
    CGM->(Dbseek(CLI1->Cgm_ent))
    ESTADO->(Dbseek(CGM->Estado))
    nICMS := ESTADO->Aliq_dest

	if ! empty(CLI1->Inscricao) .and. left(upper(CLI1->Inscricao),5) != "ISENT"
       if left(cCfop ,1) == "6"
	      nIcms := 4.00
       endif
    endif

    if CLi1->Isento == "N" 
       nICMS := 18
    endif
	
return nIcms	

static function setaSqlComoExportado(oSv)
local cQuery := "update pedido_venda set exportado_pro_qsys = 1 where exportado_pro_qsys = 0 and status_id = 2"
local query
    
   query := oSv:Query(cQuery)
   if query:NetErr()
      Alert(query:Error())
   endif


return


static function atualizaProdutos(oServer)

local cQuery := ""
local oQuery
local row
local nCont := 1
local cFim := ""
local cFora := ""

   PROD->(dbsetorder(4))

   cQuery := "SELECT p.id, ifnull(p.fim_de_vida,0) as fim, ifnull(p.fora_de_linha,0) as fora from produtos as p " 
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   do while nCont <= oQuery:LastRec() 	
      row := oQuery:getRow(nCont)
	 
	  if PROD->(dbseek( strzero(row:fieldGet('id'),5) ) )
	     
	 	 if row:fieldGet('fim') == 1
		    cFim := "S"
		 else
			cFim := "N"
		 endif
		
		 if row:fieldGet('fora') == 1
		    cFora := "S"
		 else
		    cFora := "N"
		 endif
		 
		 if PROD->(qrlock())
			if PROD->Fimdevida != cFim 
				replace PROD->FimDeVida with cFim
			endif	
			
			if PROD->Fora_linha != cFora 
				replace PROD->Fora_linha with cFora
			endif
			
			PROD->(qunlock())
		 endif	
		 
	 endif
	 
	 
	 nCont ++
  
  enddo
  
  PROD->(dbcommit())

return

static function dTimeToDate(cDateTime)
  local cAno := left(cDatetime,4)
  local cMes := substr(cDatetime,6,2)
  local cDia := substr(cDatetime,9,2)
  
  dData = ctod(cDia + "/" + cMes + "/" + cAno)
  
  //alert(dtoc(dData))

return dData



