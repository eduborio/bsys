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

function cl450

 if ! qconf("Deseja Importar dados do sistema web ?")
    return .F.
  endif

  if ! quse(XDRV_CP,"CONFIG",{},,"CFGCP")
	 qmensa("Nao foi possivel abrir config do compras!","BL")
	 return .F.
  endif
  
  i_importa()
  dbcommitAll()
  
  CFGCP->(dbCloseArea())

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
   
   //corrigeModelos()
   
   qmensa(" atualizando clientes...")
   processaClientes(oServer)
   
   qmensa(" atualizando produtos...")
   processaProdutos(oServer)
   
   qmensa(" atualizando responsaveis...")
   processaResponsaveis(oServer)
   
   qmensa(" atualizando representantes...")
   processaRepresentantes(oServer)
   
   qmensa(" atualizando transportadoras...")
   processaTransportadoras(oServer)
   
   qmensa(" atualizando fornecedores...")
   processaFornecedores(oServer)
   
   qmensa(" importando Notas Fiscais...")
   processaNotasFiscais(oServer)
   
   qmensa(" importando Notas Fiscais de Importacao.")
   processaCompras(oServer)
   
   qmensa(" sincronizando cancelamentos de Notas Fiscais")
   sincronizaNFsQueForamCanceladasDepoisDaPrimeiraImportacao(oServer)
   
   qmensa(" sincronizando ajustes...")
   processaMoviment(oServer)
   
return

static function processaClientes(oServer)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
	
   cQuery := "SELECT * from clientes as cli " 
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  id := strzero(get(row,'id'),5)
	  
	  if CLI1->(dbseek(id))
		 atualizaCliente(row)
	  else
	     criaCliente(row,oServer)
	  endif
	  
	  nCont++

   enddo 	  
return

static function atualizaCliente(row)
	 if CLI1->(qrlock())
		replaceClientes(row)
	    CLI1->(qunlock())
     endif
	 
	 //CLI1->(dbcommit())
return


static function criaCliente(row,oServer)
local id := ""
local conta_contabil := ""

	 if CLI1->(qappend())
	    id := strzero(get(row,'id'),5)
		conta_contabil := Gera_Plano(id,get(row,'nome'))
		
		replace CLI1->Codigo   with id
		replaceClientes(row)
		replace CLI1->Conta_cont with conta_contabil
     endif
	 
	 CLI1->(dbcommit())
	 atualizaContaContabilNaWeb(oServer,get(row,'id'),conta_contabil)
	 
return

static function dTimeToDate(cDateTime)
  local cAno := left(cDatetime,4)
  local cMes := substr(cDatetime,6,2)
  local cDia := substr(cDatetime,9,2)
  
  dData = ctod(cDia + "/" + cMes + "/" + cAno)
  
  //alert(dtoc(dData))

return dData

static function get(row,campo)
return  row:fieldget(campo)

static function replaceClientes(row)
local final
local regime_tributario := 0
local area := ""
	    
		replace CLI1->razao        with get(row,'nome')
		replace CLI1->cgccpf       with get(row,'cnpj')
		replace CLI1->Inscricao    with get(row,'inscricao_estadual')
		replace CLI1->Rg           with get(row,'rg')
        replace CLI1->End_cob      with get(row,'logradouro_cobranca')		
        replace CLI1->num_cob      with get(row,'numero_cobranca')		
        replace CLI1->compl_cob    with get(row,'complemento_cobranca')		
        replace CLI1->Cgm_cob      with strzero(get(row,'id_municipio_cobranca'),6)
        replace CLI1->Cep_cob      with get(row,'cep_cobranca')		
        replace CLI1->Fone1		   with get(row,'telefone_entrega') 
        replace CLI1->Fone2        with get(row,'telefone_cobranca') 
        replace CLI1->Fax          with get(row,'fax')
        replace CLI1->Contato_c    with get(row,'contato_comercial')
        replace CLI1->Contato_f    with get(row,'contato_financeiro')
        replace CLI1->Fantasia     with get(row,'fantasia')
        replace CLI1->End_ent      with get(row,'logradouro_entrega')
        replace CLI1->Cgm_ent      with strzero(get(row,'id_municipio_entrega'),6)
        replace CLI1->Cep_ent      with get(row,'cep_entrega')
        replace CLI1->Filial       with "0001"
        replace CLI1->Bairro_cob   with get(row,'bairro_cobranca')
        replace CLI1->Bairro_ent   with get(row,'bairro_entrega') 
        replace CLI1->Cod_repres   with strzero(get(row,'representante_id'),5)
		//replace CLI1->Conta_cont   with get(row,'conta_contabil')
		replace CLI1->comis_repr   with get(row,'comissao_representante')
		replace CLI1->Email        with get(row,'email')
		replace CLI1->Dt_aniver    with get(row,'dia_mes_aniversario')
		replace CLI1->Voltagem     with get(row,'voltagem')
		
		final := get(row,'consumidor_final')
		
		replace CLI1->Isento       with iif(final,"N","S")
		replace CLI1->Numero       with get(row,'numero_entrega')
		//replace CLI1->Numero_cob   with get(row,'numero_cobranca')
		replace CLI1->Compl        with get(row,'complemento_entrega')
		//replace CLI1->Compl_cob    with get(row,'complemento_cobranca')
		
		replace CLI1->Cod_resp      with strzero(get(row,'responsavel_id'),5)
		
		regime_tributario := get(row,'regime_tributario')
		
  	    regime_tributario++
		
		replace CLI1->Final         with iif(final,"S","N")
		
		replace CLI1->Tributacao    with strzero(regime_tributario,1)
		
		replace CLI1->email_cp      with get(row,'email_compras')
		replace CLI1->email_fi      with get(row,'email_financeiro')	
        replace CLI1->msg_recife    with iif(get(row,'tributacao_recife'),"S","N")		
		
		area := get(row,'area_id')
		
		if area != NIL
			area := strzero(area,5)
		endif	
		
		replace CLI1->Cod_exc       with iif(area == "00000" , "" , area)

return

static function gera_plano(id,nome)

local fULTCLI := space(4)
local myCODIGO := space(12)
local fREDUZIDO

PLAN->(qseekn("1010201"))
fULTCLI := strzero(val(id),4)

myCODIGO := "1010201"+fULTCLI

myCODIGO := alltrim(myCODIGO) + qdigito(myCODIGO)

PLAN->(dbsetorder(3))
PLAN->(Dbgobottom())
fREDUZIDO := fREDUZIDO := strzero(val(left(PLAN->Reduzido,5))+1,5)
fREDUZIDO := fREDUZIDO + qdigito(fREDUZIDO)

if PLAN->(Qappend())
   replace PLAN->Codigo     with myCODIGO
   replace PLAN->Reduzido   with fREDUZIDO
   replace PLAN->Descricao  with nome
   replace PLAN->Nat_cont   with "AT"
   replace PLAN->Bloq_tecla with "N"
   replace PLAN->Cent_custo with "N"
   replace PLAN->Lanc_index with "N"
   replace PLAN->Mat_filial with "S"
endif
PLAN->(DbCommit())

return fREDUZIDO

static function atualizaContaContabilNaWeb(oSv,id,conta_contabil)
local cQuery := "update clientes set conta_contabil = '" + conta_contabil + "' where id =" + alltrim(str(id))
local query
    
   query := oSv:Query(cQuery)
   if query:NetErr()
      Alert(query:Error())
   endif
return

static function processaProdutos(oServer)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   PROD->(dbsetorder(4))
	
   cQuery := "SELECT * from produtos as prod " 
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  id := strzero(get(row,'id'),5)
	  
	  if PROD->(dbseek(id))
		 atualizaProduto(row)
	  else
	     criaProduto(row)
	  endif
	  
	  nCont++

   enddo 	  
return

static function atualizaProduto(row)
	 if PROD->(qrlock())
		replaceProduto(row)
	    PROD->(qunlock())
     endif
	 
	 //PROD->(dbcommit())
return


static function criaProduto(row)
local id := ""

	 if PROD->(qappend())
	    id := strzero(get(row,'id'),5)
		replace PROD->Codigo   with "0101" + id
		replaceProduto(row)
		replace PROD->Tipo        with "1"
     endif
	 
	 //PROD->(dbcommit())
return

static function replaceProduto(row)
local fabricante := ""
local designer    := ""
     
	replace PROD->Descricao   with get(row,'descricao')  
	replace PROD->preco_cons  with get(row,'preco')  
	replace PROD->preco_cust  with get(row,'preco_custo')  
	replace PROD->Cod_fabr    with get(row,'referencia_brasil')
	replace PROD->cod_ass     with get(row,'referencia_espanha')  
	replace PROD->Marca       with get(row,'colecao')  
	replace PROD->Cod_barras  with get(row,'codigo_barras') 
    replace PROD->Unidade     with "001"	
	replace PROD->Ipi         with get(row,'aliquota_ipi')
	replace PROD->Prod_Iss    with "N"
	
	replace PROD->Corredor    with get(row,'corredor')
	replace PROD->Estante     with get(row,'estante')
	replace PROD->Prateleira  with get(row,'prateleira')
	
	replace PROD->Corredor2   with get(row,'corredor2')
	replace PROD->Estante2    with get(row,'estante2')
	replace PROD->Prateleir2  with get(row,'prateleira2')
	
	replace PROD->Tributa     with "S"
	
	replace PROD->Cod_class   with strzero(get(row,'classificacao_fiscal_id'),2)
	
	replace PROD->Peso_bruto  with get(row,'peso_bruto')
	replace PROD->Peso        with get(row,'peso_liquido')
	replace PROD->Pontos      with get(row,'pontos')
	
	fabricante := strzero(get(row,'fabricante_id'),5)
	
	replace PROD->Fabr        with iif( fabricante == "00000","",fabricante)
	
	replace PROD->Cust_dolar  with get(row,'preco_custo_dolar')
	replace PROD->Cust_ren    with get(row,'preco_custo_rmb')
	
	replace PROD->Cubagem     with get(row,'cubagem')
	
	replace PROD->Fora_linha  with iif(get(row,'fora_de_linha'),"S","N")
	replace PROD->Fimdevida   with iif(get(row,'fim_de_vida'),"S","N")
	replace PROD->Inspecao    with iif(get(row,'requer_inspecao'),"S","N")
	
	designer := strzero(get(row,'designer_id'),3)
	replace PROD->Designer    with iif( designer == "000","",designer)
	    
return

static function processaResponsaveis(oServer)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   cQuery := "SELECT * from responsavel as resp " 
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  id := strzero(get(row,'id'),5)
	  
	  if RESP_REP->(dbseek(id))
		 atualizaResponsavel(row)
	  else
	     criaResponsavel(row)
	  endif
	  
	  nCont++

   enddo 	  
return

static function atualizaResponsavel(row)
	 if RESP_REP->(qrlock())
		replaceResponsavel(row)
	    RESP_REP->(qunlock())
     endif
	 
	 //RESP_REP->(dbcommit())
return


static function criaResponsavel(row)
local id := ""

	 if RESP_REP->(qappend())
	    id := strzero(get(row,'id'),5)
		replace RESP_REP->Codigo   with id
		replaceResponsavel(row)
     endif
	 
	 //RESP_REP->(dbcommit())
return

static function replaceResponsavel(row)
     
	replace RESP_REP->Nome   with get(row,'nome')  
	    
return

static function processaRepresentantes(oServer)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   cQuery := "SELECT * from representantes as rep " 
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  id := strzero(get(row,'id'),5)
	  
	  if REPRES->(dbseek(id))
		 atualizaRepresentante(row)
	  else
	     criaRepresentante(row)
	  endif
	  
	  nCont++

   enddo 	  
return

static function atualizaRepresentante(row)
	 if REPRES->(qrlock())
		replaceRepresentante(row)
	    REPRES->(qunlock())
     endif
	 
	 //REPRES->(dbcommit())
return


static function criaRepresentante(row)
local id := ""

	 if REPRES->(qappend())
	    id := strzero(get(row,'id'),5)
		replace REPRES->Codigo   with id
		replaceRepresentante(row)
     endif
	 
	 //REPRES->(dbcommit())
return

static function replaceRepresentante(row)
     
	replace REPRES->Razao      with get(row,'nome')
	replace REPRES->cgccpf     with get(row,'cnpj')
	replace REPRES->inscricao  with get(row,'inscricao_estadual')
	replace REPRES->End_cob    with get(row,'logradouro_cobranca')
	replace REPRES->Cgm_cob    with strzero(get(row,'id_municipio_cobranca'),6)
	replace REPRES->Cep_cob    with get(row,'cep_cobranca')
	replace REPRES->Fone1      with get(row,'telefone_entrega')
	replace REPRES->Fone2      with get(row,'telefone_cobranca')
	replace REPRES->Foner      with get(row,'fone_residencial')
	replace REPRES->Fax        with get(row,'fax')
	replace REPRES->Contato_c  with get(row,'contato_comercial')
	replace REPRES->Contato_f  with get(row,'contato_financeiro')
	replace REPRES->Fantasia   with get(row,'fantasia')

	replace REPRES->End_ent    with get(row,'logradouro_entrega')
	replace REPRES->Cgm_ent    with strzero(get(row,'id_municipio_entrega'),6)
	replace REPRES->Cep_ent    with get(row,'cep_entrega')
	
	replace REPRES->Cod_resp   with strzero(get(row,'responsavel_id'),5)
	    
return

static function processaTransportadoras(oServer)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   cQuery := "SELECT * from transportadoras as transp " 
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  id := strzero(get(row,'id'),5)
	  
	  if TRANSP->(dbseek(id))
		 atualizaTransportadora(row)
	  else
	     criaTransportadora(row)
	  endif
	  
	  nCont++

   enddo 	  
return

static function atualizaTransportadora(row)
	 if TRANSP->(qrlock())
		replaceTransportadora(row)
	    TRANSP->(qunlock())
     endif
	 
	 //TRANSP->(dbcommit())
return


static function criaTransportadora(row)
local id := ""

	 if TRANSP->(qappend())
	    id := strzero(get(row,'id'),5)
		replace TRANSP->Codigo   with id
		replaceTransportadora(row)
     endif
	 
	 //TRANSP->(dbcommit())
return

static function replaceTransportadora(row)
     
	replace TRANSP->Razao      with get(row,'nome')
	replace TRANSP->cgccpf     with get(row,'cnpj')
	replace TRANSP->inscricao  with get(row,'inscricao_estadual')
	replace TRANSP->Endereco   with get(row,'logradouro')
	replace TRANSP->Cgm        with strzero(get(row,'id_municipio'),6)
	replace TRANSP->Cep        with get(row,'cep')
	replace TRANSP->Fone1      with get(row,'telefone')
	replace TRANSP->Fone2      with get(row,'telefone2')
	replace TRANSP->Fax        with get(row,'fax')
	replace TRANSP->Contato_c  with get(row,'contato_comercial')
	replace TRANSP->Contato_f  with get(row,'contato_financeiro')
	replace TRANSP->Fantasia   with get(row,'fantasia')
	replace TRANSP->Email      with get(row,'email')
	    
return

static function processaFornecedores(oServer)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   cQuery := "SELECT * from fornecedores as forn " 
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  id := strzero(get(row,'id'),5)
	  
	  if FORN->(dbseek(id))
		 atualizaFornecedor(row)
	  else
	     criaFornecedor(row)
	  endif
	  
	  nCont++

   enddo 	  
return

static function atualizaFornecedor(row)
	 if FORN->(qrlock())
		replaceFornecedor(row)
	    FORN->(qunlock())
     endif
	 
	 //FORN->(dbcommit())
return


static function criaFornecedor(row)
local id := ""

	 if FORN->(qappend())
	    id := strzero(get(row,'id'),5)
		replace FORN->Codigo   with id
		replaceFornecedor(row)
     endif
	 
	 //FORN->(dbcommit())
return

static function replaceFornecedor(row)
     
	replace FORN->Razao      with get(row,'nome')
	replace FORN->cgccpf     with get(row,'cnpj')
	replace FORN->inscricao  with get(row,'inscricao_estadual')
	replace FORN->End_cob    with get(row,'logradouro_cobranca')
	replace FORN->Cgm_cob    with strzero(get(row,'id_municipio_cobranca'),6)
	replace FORN->Cep_cob    with get(row,'cep_cobranca')
	replace FORN->Bairro_cob with get(row,'bairro_cobranca')
	
	replace FORN->Fone1      with get(row,'telefone_entrega')
	replace FORN->Fone2      with get(row,'telefone_cobranca')
	
	replace FORN->End_ent    with get(row,'logradouro_entrega')
	replace FORN->Cgm_ent    with strzero(get(row,'id_municipio_entrega'),6)
	replace FORN->Cep_ent    with get(row,'cep_entrega')
	replace FORN->Bairro_ent with get(row,'bairro_entrega')
	    
return

static function processaNotasFiscais(oServer)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   cQuery := "SELECT nf.*, c.codigo_contabil as subtipo, cli.nome as cliente from nota_fiscal as nf "
   cQuery += "left outer join clientes as cli on cli.id = nf.cliente_id "
   cQuery += "left outer join cfops as c on c.id = nf.cfop_id "
   cQuery += "where exportado_pro_qsys = 0 " 
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  
      criaNotaFiscal(row,oServer)
	  
	  nCont++

   enddo 	  
return

static function criaNotaFiscal(row,oSv)
local fCodigo := ""
local nNotaFiscalId := 0

	if NUM_PEDI->(qrlock())
       replace NUM_PEDI->Pedido with NUM_PEDI->Pedido + 1
	   fCODIGO := strzero(NUM_PEDI->Pedido,6)
	   NUM_PEDI->(qunlock())
	endif	 
	  
	nNotaFiscalId  := get(row,'id')

	if FAT->(qappend())
	   replace FAT->Codigo   with fCodigo
	   replaceNotaFiscal(row)
    endif
	 
	//FAT->(dbcommit())
	
	processaItemNotaFiscal(oSv,nNotaFiscalId,fCodigo)
	preencheParcelas(oSv,fCodigo,nNotaFiscalId,get(row,'data_emissao'))
	marcaNotaComoExportada(oSv,nNotaFiscalId)
	
return

static function replaceNotaFiscal(row)
local fCod_cfop :=  ""
local numero_nf := ""
local transportadora := ""
local representante  := ""
local responsavel    := ""
local cEntradaOuSaida := ""
local nFile := 0
local xmlNfe := ""


	replace FAT->Cod_cli     with strzero(get(row,'cliente_id'),5)
    replace FAT->Dt_emissao  with get(row,'data_emissao')
	replace FAT->Filial      with "0001"
	replace FAT->C_custo     with "0005"
	
	fCod_cfop   := strzero(get(row,'cfop_id'),4)
	replace FAT->Cod_cfop    with fCod_cfop
	replace FAT->Desc_sn     with "N"
	
	numero_nf := get(row,'numero_nota')
	
	if( len(alltrim(numero_nf)) > 6 )
	   numero_nf  := right(numero_nf,6)
	else
       numero_nf  := strzero(val(numero_nf),6)
	endif
	
	replace FAT->Num_fatura  with numero_nf

	CFOP->(dbseek(fCod_cfop))
    replace FAT->TipoSub     with CFOP->Tipo_cont
	
	replace FAT->Obs         with left(rtrim(get(row,'dados_adicionais')),256)
	
	replace FAT->Cancelado   with iif(get(row,'cancelada') == 1,.T.,.F.)
	replace FAT->Contabil    with .F.
	replace FAT->Fiscal      with .F.
	replace FAT->Interface   with .F.
	
	replace FAT->Cliente     with left(get(row,'cliente'),65)
	
	trasnportadora := strzero(get(row,'transportadora_id'),5)
	replace FAT->cod_transp  with iif(transportadora == "00000","",transportadora)
	
	replace FAT->cod_repres  with strzero(get(row,'representante_id'),5)
	replace FAT->cod_resp    with strzero(get(row,'responsavel_id'),5)
	
	cEntradaOuSaida := iif(get(row,'tipo_nota') == 1,"S","E")
	
	replace FAT->Es        with cEntradaOuSaida
	
	replace FAT->Frete     with strzero(get(row,'tipo_frete') + 1,1)
	
	replace FAT->Fechado   with .T.
	replace FAT->Gerada    with .T.
	
	replace FAT->Boleto    with strzero(get(row,'informacao_boleto') + 1,1)
	
	replace FAT->NFe       with get(row,'chave_nfe')
	
	if !empty(get(row,'chave_nfe') )
		replace FAT->Modelo    with "55"
	else
		replace FAT->Modelo    with "  "
	endif	
	
	replace FAT->Status    with "100"
	
	replace FAT->Basest    with get(row,'base_st')
	replace FAT->St        with get(row,'valor_st')
	
	replace FAT->NfWeb_id  with get(row,'id')
	
	
	xmlNfe := get(row,'xml_nfe')
	
	nFile := fcreate(CONFIG->Unidade + ":\qsys_g\qfa_cl\nfe\autorizadas\"+get(row,'chave_nfe')+"-nfe.xml",0)
    
    fwrite(nfile,xmlNfe,len(xmlNfe))
   
    fclose(nFile)
	
	    
return

static function processaItemNotaFiscal(oServer,id,fCodigo)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   
   cQuery := "select item.*, nf.data_emissao from item_nota_fiscal as item "
   cQuery += " left outer join nota_fiscal as nf on nf.id = item.nota_fiscal_id " 
   cQuery += " where item.nota_fiscal_id =" + alltrim(str(id))
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  
      criaItemNotaFiscal(row,fCodigo)
	  
	  nCont++

   enddo 	  
return

static function criaItemNotaFiscal(row,fCodigo)

	if ITEN_FAT->(qappend())
	   replace ITEN_FAT->Num_fat         with fCodigo
	   replaceItemNotaFiscal(row)
    endif
	 
	//ITEN_FAT->(dbcommit())
return

static function replaceItemNotaFiscal(row)

     replace ITEN_FAT->Cod_prod     with strzero(get(row,'produto_id'),5)
	 replace ITEN_FAT->quantidade   with get(row,'quantidade')
	 replace ITEN_FAT->Vl_unitar    with get(row,'valor_unitario')
	 replace ITEN_FAT->Icms         with get(row,'aliquota_icms')
	 replace ITEN_FAT->Comi_repre   with get(row,'comissao_representante')
	 replace ITEN_FAT->Calc_desc    with "N"
	 replace ITEN_FAT->icms_subst   with "N"
	 replace ITEN_FAT->Num_lote     with "0000000000"
	 replace ITEN_FAT->Prod_ser     with "1"
	 replace ITEN_FAT->Vlr_ii       with 0
	 replace ITEN_FAT->Cod_sit      with "000"
	 replace ITEN_FAT->Data         with get(row,'data_emissao')
	 replace ITEN_FAT->Marcado      with "*"
	 replace ITEN_FAT->Desc_prod    with get(row,'desconto')
	 replace ITEN_FAT->Vlr_desc     with get(row,'valor_desconto')
	 replace ITEN_FAT->Preco_vend   with get(row,'preco_tabela')
	 replace ITEN_FAT->Quant_ped    with get(row,'quantidade')
	 replace ITEN_FAT->Quant_pen    with 0
	 replace ITEN_FAT->Preco_cust   with get(row,'preco_custo')
	 replace ITEN_FAT->Pontos       with 1
	 replace ITEN_FAT->Ipi          with get(row,'aliquota_ipi')
	    
return

static function preencheParcelas(oSv,cNumeroPedidoQsys,nNotaFiscalId,data_emissao)
  local nCont := 1
  local oQuery, row
  local cQuery := "select * from parcelas_nota_fiscal as p where p.nota_fiscal_id =" +alltrim(str(nNotaFiscalId))

  oQuery := oSv:Query(cQuery)
  if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
  
  nCont := 1
   
  do while nCont <= oQuery:LastRec() 	
     row := oQuery:getRow(nCont)
	 
	 if right(alltrim(row:fieldget('numero')),2) == "ST"
	    nCont++
		loop
	 endif
	 
	 DUP_FAT->(qpublicfields())
	 DUP_FAT->(qinitfields())
	 
	 fNum_fat   := cNumeroPedidoQsys+strzero(nCont,2)
	 fDias      :=  row:fieldget('dias')
	 fData_venc :=  data_emissao + fDias
	 fValor     :=  row:fieldget('valor')
	 
	 if DUP_FAT->(Qappend())
	     DUP_FAT->(QreplaceFields())
	  endif
	  DUP_FAT->(qreleasefields())
	 
	 nCont ++
  
  enddo
  
  //DUP_FAT->(dbCommit())

return


static function marcaNotaComoExportada(oServer,id)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   
   cQuery := " update nota_fiscal set exportado_pro_qsys = 1 "
   cQuery += " where id =" + alltrim(str(id))
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
return

static function processaCompras(oServer)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   cQuery := "SELECT ped.*, forn.nome as fornecedor from compras as ped "
   cQuery += "left outer join fornecedores as forn on forn.id = ped.fornecedor_id "
   cQuery += "left outer join cfops as c on c.id = ped.cfop_id "
   cQuery += "where exportado_pro_qsys = 0 " 
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  
      criaCompra(row,oServer)
	  
	  nCont++

   enddo 	  
return

static function criaCompra(row,oSv)
local fCodigo := ""
local nNotaFiscalId := 0

    if CFGCP->(qrlock())
	   replace CFGCP->Cod_pedido with CFGCP->Cod_pedido+1
       fCODIGO := strzero(CFGCP->Cod_pedido,5)+left(dtos(date()),4)
	   CFGCP->(qunlock())
	endif	 
	  
	nNotaFiscalId  := get(row,'id')

	if PEDIDO->(qappend())
	   replace PEDIDO->Codigo   with fCodigo
	   replaceCompra(row)
    endif
	 
	processaItemCompra(oSv,nNotaFiscalId,fCodigo)
	marcaCompraComoExportada(oSv,nNotaFiscalId)
	
return

static function replaceCompra(row)
local fCod_cfop :=  ""
local numero_nf := ""
local transportadora := ""
local representante  := ""
local responsavel    := ""
local cEntradaOuSaida := ""
local nFile := 0
local xmlNfe := ""

	replace PEDIDO->Cod_forn with strzero(get(row,'fornecedor_id'),5)
    replace PEDIDO->Data_ped    with get(row,'data_emissao')
    replace PEDIDO->Data_entre  with get(row,'data_emissao')
    replace PEDIDO->Data_baixa  with get(row,'data_emissao')
    replace PEDIDO->Data_emiss  with get(row,'data_emissao')
	replace PEDIDO->Filial      with "0001"
	replace PEDIDO->Centro      with "0005"
	replace PEDIDO->Numero_nf   with get(row,'numero_nota')
	
	fCod_cfop   := strzero(get(row,'cfop_id'),4)
	replace PEDIDO->Cfop        with fCod_cfop
	
    replace PEDIDO->Tipo        with "020005"
    replace PEDIDO->Comprador   with "00001"
    replace PEDIDO->Serie       with "01"
    replace PEDIDO->Especie     with "01"
    replace PEDIDO->Despesa     with "N"
    replace PEDIDO->Interface   with .T.
	
	replace PEDIDO->Observacao  with left(rtrim(get(row,'observacao')),80)
	replace PEDIDO->Fornecedor  with left(get(row,'fornecedor'),65)
	
return

static function processaItemCompra(oServer,id,fCodigo)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   
   cQuery := "select item.*, cp.data_emissao from item_compra as item "
   cQuery += " left outer join compras as cp on cp.id = item.compra_id " 
   cQuery += " where item.compra_id =" + alltrim(str(id))
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  
      criaItemCompra(row,fCodigo)
	  
	  nCont++

   enddo 	  
return

static function criaItemCompra(row,fCodigo)

	if LANC->(qappend())
	   replace LANC->Cod_ped         with fCodigo
	   replaceItemCompra(row)
    endif
	 
return

static function replaceItemCompra(row)
     replace LANC->Cod_prod     with strzero(get(row,'produto_id'),5)
	 replace LANC->quant        with get(row,'quantidade')
	 replace LANC->preco        with get(row,'valor_unitario')
	 replace LANC->Centro       with "0005"
	 replace LANC->Lote         with "0000000000"
	 replace LANC->Fator        with 1	    
return

static function marcaCompraComoExportada(oServer,id)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   
   cQuery := " update compras set exportado_pro_qsys = 1 "
   cQuery += " where id =" + alltrim(str(id))
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
return

static function corrigeModelos
    local dINI := ctod("01/08/2013")
	local dFIM := ctod("30/09/2013")


    FAT->(dbclearfilter())
    FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. dt_emissao <= dFIM .and. ES == "E" .and. empty(NFe) }))
    FAT->(dbsetorder(9))
    FAT->(Dbgotop())
	
	do while ! FAT->(eof()) 
		if FAT->(qrlock())
		  replace FAT->Modelo with "  "  
          FAT->(qunlock())
        endif  		
	    
	   FAT->(dbskip())
	enddo
	

return

static function sincronizaNFsQueForamCanceladasDepoisDaPrimeiraImportacao(oServer)

   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   if ! quse(XDRV_EF,"SAI",{})
	 qmensa("Nao foi possivel abrir SAI do Fiscal!","BL")
	 return .F.
  endif
  
  if ! quse(XDRV_EF,"ENT",{})
	 qmensa("Nao foi possivel abrir SAI do Fiscal!","BL")
	 return .F.
  endif
  
  if ! quse(XDRV_RB,"RECEBER",{})
	 qmensa("Nao foi possivel abrir RECEBER do Contas a Receber!","BL")
	 return .F.
  endif
   
   cQuery := "SELECT nf.id, nf.cancelada from nota_fiscal as nf "
   cQuery += "where exportado_pro_qsys = 1 and nf.cancelada = 1 and nf.data_emissao between 20140718 and 20181231" 
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   FAT->(dbsetorder(4))
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  
	  if FAT->(dbseek(get(row,'id')))
		
		
		if FAT->(qrlock() .and. ! FAT->Cancelado)
		   replace FAT->Cancelado with .T.
           replace FAT->Obs      with "### NOTA FISCAL CANCELADA ###"		   
		   FAT->(qunlock())	
		endif
		
		if FAT->Es == "S"
			SAI->(dbsetorder(4))
			if SAI->(dbseek(FAT->Num_fatura + "55")) .and. SAI->(Qrlock())
			   replace SAI->Vlr_cont with 0
			   replace SAI->Icm_base with 0
			   replace SAI->Icm_aliq with 0
			   replace SAI->Icm_vlr  with 0
			   replace SAI->Icm_out  with 0
			   replace SAI->Icm_red  with 0
			   replace SAI->Ipi_base with 0
			   replace SAI->Ipi_out  with 0
			   replace SAI->Ipi_vlr  with 0
			   replace SAI->Icm_bc_s   with 0
			   replace SAI->Icm_subst  with 0
			   replace SAI->Obs      with "### NOTA FISCAL CANCELADA ###"
			   SAI->(qunlock())
			endif
			
			RECEBER->(dbsetorder(11))
             if  RECEBER->(dbseek(FAT->Num_fatura))
                  while ! RECEBER->(Eof()) .and. left(RECEBER->Fatura,6) == FAT->Num_fatura

                    if RECEBER->(qrlock())
                       RECEBER->(Dbdelete())
                       RECEBER->(Qunlock())
                    endif
                    RECEBER->(dbskip())
                 enddo
             endif
		 endif	
		 
		 if FAT->Es == "E"
			ENT->(dbsetorder(10))
			if ENT->(dbseek(FAT->Num_fatura + left(FAT->Cod_cfop,4))) .and. ENT->(Qrlock())
			
			   if FAT->dt_emissao == ENT->data_lanc
				   replace ENT->Vlr_cont with 0
				   replace ENT->Icm_base with 0
				   replace ENT->Icm_aliq with 0
				   replace ENT->Icm_vlr  with 0
				   replace ENT->Icm_out  with 0
				   replace ENT->Icm_red  with 0
				   replace ENT->Ipi_base with 0
				   replace ENT->Ipi_out  with 0
				   replace ENT->Ipi_vlr  with 0
				   replace ENT->Icm_bc_s   with 0
				   replace ENT->Icm_subst  with 0
				   replace ENT->Obs      with "### NOTA FISCAL CANCELADA ###"
				   ENT->(qunlock())
			   endif	   
			endif
		 endif
			
	  endif
	  
	  nCont++

   enddo 

   SAI->(dbclosearea())
   ENT->(dbclosearea())
   RECEBER->(dbcloseArea())

return

static function processaMoviment(oServer)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   if ! quse(XDRV_ES,"MOVIMENT",{})
	 qmensa("Nao foi possivel abrir moviment!","BL")
	 return .F.
  endif
   
   cQuery := "SELECT mov.*, prod.preco_custo from ajuste_saldo_estoque as mov "
   cQuery += "left outer join produtos prod on prod.id = mov.produto_id " 
   cQuery += "where exportado_pro_qsys = 0 " 
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  
      criaMoviment(row,oServer)
	  
	  nCont++

   enddo 	  
   
   MOVIMENT->(dbclosearea())
   
   
return

static function criaMoviment(row,oSv)
local fCodigo := ""
local nAjusteId := 0

	nAjusteId  := get(row,'id')

	if MOVIMENT->(qappend()) 
       replace MOVIMENT->Data       with get(row,'data')
	   replace MOVIMENT->Filial     with "0001"
	   replace MOVIMENT->Cod_prod   with strzero(get(row,'produto_id'),5)
	   replace MOVIMENT->quantidade with get(row,'quantidade')
	   replace MOVIMENT->val_uni    with get(row,'preco_custo')
	   replace MOVIMENT->Tipo       with get(row,'tipo')
	   replace MOVIMENT->Contabil   with .F.
	   replace MOVIMENT->Lote       with "0000000000"
	   replace MOVIMENT->Obs        with get(row,'observacoes')
    endif
	 
	marcaMovimentComoExportado(oSv,nAjusteId)
	
return

static function marcaMovimentComoExportado(oServer,id)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   
   cQuery := " update ajuste_saldo_estoque set exportado_pro_qsys = 1 "
   cQuery += " where id =" + alltrim(str(id))
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
return



