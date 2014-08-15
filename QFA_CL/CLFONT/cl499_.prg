function cl499
local  virgula := ","
local nFile := 0
local zero := 0

private eol := chr(13) + chr(10)
private aProdutos := {}
private aPed      := {}
private aPeds     := {}
private cQuote    := '"'
private cCaminho := "c://dev//dados//"
private cPath := "c:\dev\dados\"
private nContItem := 0

   if ! qconf("Gerar arquivos para o sistema Web ?")
      return .F.
   endif
   
   aProdutos := {}
   aPed      := {}
   aPeds     := {}
   
   cSQL := "use comercial;" + eol
   
   cSQL += "delete from parcelas_pedido;" + eol
   cSQL += "alter table parcelas_pedido auto_increment = 0;" + eol
   
   cSQL += "delete from item_importacao;" + eol
   cSQL += "alter table item_importacao auto_increment = 0;" + eol
   
   cSQL += "delete from adicao_importacao;" + eol
   cSQL += "alter table adicao_importacao auto_increment = 0;" + eol
   
   cSQL += "delete from declaracao_importacao;" + eol
   cSQL += "alter table declaracao_importacao auto_increment = 0;" + eol
   
   cSQL += "delete from parcelas_nota_fiscal;" + eol
   cSQL += "alter table parcelas_nota_fiscal auto_increment = 0;" + eol
   
   cSQL += "delete from parcelas_expedicao;" + eol
   cSQL += "alter table parcelas_expedicao auto_increment = 0;" + eol
   
   cSQL += "delete from movimentacoes;" + eol
   cSQL += "alter table movimentacoes auto_increment = 0;" + eol
   
   cSQL += "delete from reservas;" + eol
   cSQL += "alter table reservas auto_increment = 0;" + eol
   
   cSQL += "delete from expedicoes;" + eol
   cSQL += "alter table expedicoes auto_increment = 0;" + eol
   
   cSQL += "delete from cancelamentos;" + eol
   cSQL += "alter table cancelamentos auto_increment = 0;" + eol
   
   cSQL += "delete from item_entrada;" + eol
   cSQL += "alter table item_entrada auto_increment = 0;" + eol
   
   cSQL += "delete from entradas;" + eol
   cSQL += "alter table entradas auto_increment = 0;" + eol
   
   cSQL += "delete from item_nota_fiscal;" + eol
   cSQL += "alter table item_nota_fiscal auto_increment = 0;" + eol
   
   cSQL += "delete from item_compra;" + eol
   cSQL += "alter table item_compra auto_increment = 0;" + eol
   
   cSQL += "delete from nota_fiscal;" + eol
   cSQL += "alter table nota_fiscal auto_increment = 0;" + eol
   
   cSQL += "delete from compras;" + eol
   cSQL += "alter table compras auto_increment = 0;" + eol
   
   cSQL += "delete from item_pedido_venda;"+ eol
   cSQL += "alter table item_pedido_venda auto_increment = 0;" + eol
   
   cSQL += "delete from item_pedido_china;"+ eol
   cSQL += "alter table item_pedido_china auto_increment = 0;" + eol
   
   cSQL += "delete from item_invoice;"+ eol
   cSQL += "alter table item_invoice auto_increment = 0;" + eol
      
   cSQL += "delete from pedido_venda;"+ eol
   cSQL += "alter table pedido_venda auto_increment = 0;" + eol
   
   cSQL += "delete from pedido_china;"+ eol
   cSQL += "alter table pedido_china auto_increment = 0;" + eol
   
   cSQL += "delete from invoice;"+ eol
   cSQL += "alter table invoice auto_increment = 0;" + eol
   
   cSQL += "delete from comissao;"+ eol
   cSQL += "alter table comissao auto_increment = 0;" + eol
   
   cSQL += "delete from empresa;"+ eol
   cSQL += "alter table empresa auto_increment = 0;" + eol
   
   cSQL += "delete from transportadoras;"+ eol
   cSQL += "alter table transportadoras auto_increment = 0;" + eol
   
   cSQL += "delete from restricoes;"+ eol
   cSQL += "alter table restricoes auto_increment = 0;" + eol
   
   cSQL += "delete from exclusividades;"+ eol
   cSQL += "alter table exclusividades auto_increment = 0;" + eol
   
   cSQL += "delete from clientes;"+ eol
   cSQL += "alter table clientes auto_increment = 0;" + eol
   
   cSQL += "delete from area_exclusividade;"+ eol
   cSQL += "alter table area_exclusividade auto_increment = 0;" + eol
   
   cSQL += "delete from fornecedores;"+ eol
   cSQL += "alter table fornecedores auto_increment = 0;" + eol
   
   cSQL += "delete from representantes;"+ eol
   cSQL += "alter table representantes auto_increment = 0;" + eol
   
   cSQL += "delete from responsavel;"+ eol
   cSQL += "alter table responsavel auto_increment = 0;" + eol
   
   cSQL += "delete from municipios;" + eol
   cSQL += "alter table municipios auto_increment = 0;" + eol
   
   cSQL += "delete from estados;" + eol
   cSQL += "alter table estados auto_increment = 0;" + eol
   
   cSQL += "delete from inventarios;" + eol
   cSQL += "alter table inventarios auto_increment = 0;" + eol
   
   cSQL += "delete from avarias;" + eol
   cSQL += "alter table avarias auto_increment = 0;" + eol
      
   cSQL += "delete from show_room;" + eol
   cSQL += "alter table show_room auto_increment = 0;" + eol
   
   cSQL += "delete from ajuste_saldo_estoque;" + eol
   cSQL += "alter table ajuste_saldo_estoque auto_increment = 0;" + eol
      
   cSQL += "delete from produtos;" + eol
   cSQL += "alter table produtos auto_increment = 0;" + eol
   
   cSQL += "delete from item_classificacao_fiscal;" + eol
   cSQL += "alter table item_classificacao_fiscal auto_increment = 0;" + eol
   
   cSQL += "delete from classificacao_fiscal;" + eol
   cSQL += "alter table classificacao_fiscal auto_increment = 0;" + eol
   
   cSQL += "delete from fabricantes;" + eol
   cSQL += "alter table fabricantes auto_increment = 0;" + eol
   
   cSQL += "delete from designers;" + eol
   cSQL += "alter table designers auto_increment = 0;" + eol
   
   cSQL += "delete from vendedores;" + eol
   cSQL += "alter table vendedores auto_increment = 0;" + eol
   
   cSQL += "delete from cfops;" + eol
   cSQL += "alter table cfops auto_increment = 0;" + eol
   
   cSQL += eol
   cSQL += eol
   
   cSQL += "SET foreign_key_checks = 0;"+eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '" + cCaminho + "cfops.txt' INTO TABLE cfops " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" +cquote+ "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '" + cCaminho + "estados.txt' INTO TABLE estados " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" +cquote+ "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "municipios.txt' INTO TABLE municipios " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "responsaveis.txt' INTO TABLE responsavel " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "representantes.txt' INTO TABLE representantes " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "transportadoras.txt' INTO TABLE transportadoras " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "areas.txt' INTO TABLE area_exclusividade " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
     
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "clientes.txt' INTO TABLE clientes " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "cl_fiscal.txt' INTO TABLE classificacao_fiscal " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "designers.txt' INTO TABLE designers " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "fabricantes.txt' INTO TABLE fabricantes " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "produtos.txt' INTO TABLE produtos " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol +eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "exclusividades.txt' INTO TABLE exclusividades " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol +eol
     
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "avarias.txt' INTO TABLE avarias " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "moviment.txt' INTO TABLE ajuste_saldo_estoque " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol
   
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "showroom.txt' INTO TABLE show_room " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
  
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "inventarios.txt' INTO TABLE inventarios " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
  
     
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "fornecedores.txt' INTO TABLE fornecedores " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
      
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "nfs.txt' INTO TABLE nota_fiscal " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol +eol
    
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "itens_nfs.txt' INTO TABLE item_nota_fiscal " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol +eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "compras.txt' INTO TABLE compras " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
    
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "itens_compras.txt' INTO TABLE item_compra " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
    
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "pendencias.txt' INTO TABLE pedido_venda " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
    
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "itens_pendencias.txt' INTO TABLE item_pedido_venda " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "pedido_com_reserva.txt' INTO TABLE pedido_venda " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
    
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "itens_pedido_reserva.txt' INTO TABLE item_pedido_venda " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "vendas.txt' INTO TABLE expedicoes " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "reservas.txt' INTO TABLE movimentacoes " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "restricoes.txt' INTO TABLE restricoes " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "invoices.txt' INTO TABLE invoice " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "itens_invoice.txt' INTO TABLE item_invoice " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "pedido_china.txt' INTO TABLE pedido_china " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "itens_china.txt' INTO TABLE item_pedido_china " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "parcelas_pendencias.txt' INTO TABLE parcelas_pedido " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "parcela_pedido.txt' INTO TABLE parcelas_pedido " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "parcela_expedicao.txt' INTO TABLE parcelas_expedicao " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "SET foreign_key_checks = 1;"+eol+eol
      
   nFile := fcreate("c:\Borius\vendas\vendas\WebContent\sqls\util\qsys2borio.sql",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)
   
   notaFiscal()
   estados()
   designers()
   fabricantes()
   municipios()
   compras()
   pendencias()
   reservas()
   clientes()
   responsaveis()
   fornecedores()
   produtos()
   avarias()
   moviment()
   show_room()
   inventarios()
   representantes()
   transportadoras()
   classificacao_fiscal()
   cfops()
   areas()
   exclusividades()
   //usuarios()
   restricoes()
   invoices()
   itens_invoice()
   pedido_china()
   itens_china()
   atualizaPrecos()
     
   alert("arquivo gerado com sucesso!! ")


return

static function tiraEspacoDoFone(cSTR)
  cSTR := strtran(cSTR," ","")
return (cSTR)

static function cfops
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local estado_id := 0

   CFOP->(dbgotop())
   do while ! CFOP->(eof())
      
	  cSQL += CFOP->nat_cod + "," 
	  cSQL += quote(CFOP->nat_desc) + ","  
	  cSQL += quote(CFOP->Tipo_cont) + eol
	  
      CFOP->(dbskip())  
	  
   enddo
   
   nFile := fcreate(cPath + "cfops.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return

static function classificacao_fiscal
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local estado_id := 0

   CLASSIF->(dbgotop())
   do while ! CLASSIF->(eof())
      
	  cSQL += CLASSIF->codigo + "," 
	  cSQL += quote(qtiraponto(strReplace(CLASSIF->Descricao))) + ","
	  cSQL += "0" + ","
	  cSQL += "0" + ","
	  cSQL += "0" + ","
	  cSQL += "0" + ","
	  cSQL += "0" + ","
	  cSQL += "0" + eol
	  
      CLASSIF->(dbskip())  
	  
   enddo
    
   nFile := fcreate(cPath + "cl_fiscal.txt",0)
   fwrite(nfile,cSQl,len(cSQL))
   fclose(nFile)
   
return

static function designers
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local estado_id := 0

   if ! quse(XDRV_CL,"DESIGNER",{})
      qmensa("Nao abriu designer.dbf")
	  return .f. 
   endif

   DESIGNER->(dbgotop())
   do while ! DESIGNER->(eof())
      
	  cSQL += DESIGNER->codigo + "," 
	  cSQL += quote(qtiraponto(strReplace(DESIGNER->Nome))) + eol
	  
      DESIGNER->(dbskip())  
	  
   enddo
   
   nFile := fcreate(cPath + "designers.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return

static function estados
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local estado_id := 0
local nCont := 1

   ESTADO->(dbgotop())
   do while ! ESTADO->(eof())
   
       
      if ESTADO->(qrlock())
	     replace ESTADO->Id with nCONT
      endif  	  
       
	  cSQL += numero(nCont) + "," 
	  cSQL += quote(strReplace(rtrim(ESTADO->Est_sig))) + ","
	  cSQL += quote(strReplace(rtrim(ESTADO->Est_desc))) + "," 
	  cSQL += numero(ESTADO->Aliq_orig) + "," 
	  cSQL += numero(ESTADO->Aliq_dest) + "," 
	  cSQL += numero0(ESTADO->Aliq_inter) + eol
	  nCont++
	  
      ESTADO->(dbskip())  
	  
   enddo
   
   ESTADO->(dbcommit())
   
   nFile := fcreate(cPath + "estados.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)
   
return

static function municipios
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local estado_id := 0

   CGM->(dbgotop())
   do while ! CGM->(eof())
      
	  if ESTADO->(dbseek(CGM->Estado))
	     cSQL += CGM->Codigo + "," 
	     cSQL += quote(strReplace(rtrim(CGM->municipio))) + "," 
	     cSQL += quote(CGM->Codigo) + "," 
	     cSQL += quote(CGM->Cod_rais) + ","
         cSQL += "NULL" +","
         cSQL += iif(! CGM->Estado $ "EX",quote("BRASIL"),"NULL") +","
		 cSQL += iif(! CGM->Estado $ "EX",quote("1058"),"NULL") +","
         estado_id = ESTADO->Id
		 cSQL += iif(estado_id > 0,numero(estado_id),"NULL") + eol
	  else 
	      alert("cod. cgm:"+ CGM->Codigo + " "+CGM->Municipio +" "+CGM->Estado)
	  endif	 
	     
	  
	  //cSQL += iif(estado_id > 0,numero(estado_id),"null") + eol
	  
      CGM->(dbskip())  
	  estado_id := 0
	  
   enddo
   
   nFile := fcreate(cPath + "municipios.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return

static function clientes
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local cOBS := ""
local cCategoria := ""
local lCgmEnt:= .T.
local lCgmCob:= .T.
local lRepres:= .T.
local lResp:= .T.
   
   CLI1->(dbgotop())
   LastCli := ""
   LastCli := CLI1->Codigo
   lDuplicado := .F.
   
   do while ! CLI1->(eof())
   
      if ! CGM->(dbseek(CLI1->cgm_ent)) .and. ! empty(CLi1->cgm_ent)
	     alert("problema na constraint:;" + " cliente.id: "+CLI1->codigo + " id_mun_entrega: " + CLI1->Cgm_ent)
		 lCgmEnt := .F. 
	  endif
	  
	  if ! CGM->(dbseek(CLI1->cgm_cob)) .and. ! empty(CLi1->cgm_cob)
	     alert("problema na constraint:;" + " cliente.id: "+CLI1->codigo + " id_mun_cobranca: " + CLI1->Cgm_cob)
		 lCgmCob := .F. 
	  endif
	  
	  if ! RESP_REP->(dbseek(CLI1->cod_resp)) .and. ! empty(CLI1->cod_resp)
	     alert("problema na constraint:;" + " cliente.id: "+CLI1->codigo + " responsavel_id: " + CLI1->cod_resp)
		 lResp := .F.
	  endif
	  
	  if ! REPRES->(dbseek(CLI1->cod_repres)) .and. ! empty(CLI1->cod_repres)
	     alert("problema na constraint:;" + " cliente.id: "+CLI1->codigo + " representante_id: " + CLI1->cod_repres)
		 lRepres := .F.
	  endif
   
      if ! lDuplicado .and. ! empty(CLI1->Codigo)
   
	     cSQL += rtrim(CLI1->Codigo)  + ","
         cSQL += quote(strReplace(left(CLI1->razao,45))) + ","	  
	     cSQL += quote(CLI1->cgccpf)                     + "," 
	     cSQL += quote(qtiraponto(strReplace(left(CLI1->inscricao,15))))   + ","
	     cSQL += "NULL"                                               + ","
	     cSQL += quote(strReplace(left(CLI1->fantasia,20)))          +  ","
	  
	     cSQL += quote(strReplace(left(CLI1->end_ent,55)))      + ","
	     cSQL += quote(strReplace(CLI1->numero))                + ","
	     cSQL += quote(strReplace(CLI1->bairro_ent))            + ","
	     cSQL += quote(strReplace(CLI1->cep_ent))               + ","
	     cSQL += quote(strReplace(CLI1->compl))                 + ","
	     cSQL += quote(CLI1->fone1)                             + ","
		 
		 if lCgmEnt
		    cSQL += null(CLI1->cgm_ent)                         + ","
		 else
            cSQL += "NULL"                                      + ","  
			lCgmEnt := .T.
         endif		 
	  
	     cSQL += quote(strReplace(left(CLI1->end_cob,55)))      + ","
	     cSQL += quote(strReplace(CLI1->numero))                + ","
	     cSQL += quote(strReplace(CLI1->bairro_cob))            + ","
	     cSQL += quote(strReplace(CLI1->cep_cob))               + ","
	     cSQL += quote(strReplace(CLI1->compl))                 + ","
	     cSQL += quote(CLI1->fone2)                             + ","
		 
		 if lCgmCob
		    cSQL += null(CLI1->cgm_cob)                         + ","
		 else
            cSQL += "NULL"                                      + ","  
			lCgmCob := .T.
         endif
		 
		 if lResp
            cSQL +=  null(CLI1->cod_resp)                           + ","
		 else
            cSQL += "NULL"                                          + ","  
			lResp := .T.
         endif 		 
		
         if lRepres		
		    cSQL +=  null(CLI1->cod_repres)                         + ","
		 else
            cSQL +=  "NULL"                                         + ","
			lRepres := .T.
			 
         endif		  
		 
		 cSQL +=  quote(strReplace(CLI1->email))                 + ","
		 cSQL +=  quote(strReplace(CLI1->contato_c))             + ","
		 cSQL +=  quote(strReplace(CLI1->fax))                   + ","
		 cSQL +=  quote(strReplace(CLI1->fone2))                 + ","
		 cSQL +=  "NULL"                                         + ","
		 cSQL +=  quote(strReplace(CLI1->dt_aniver))             + ","
		 cSQL +=  quote(strReplace(CLI1->voltagem))              + ","
		 cSQL +=  quote(strReplace(CLI1->rg))                    + ","
		 cSQL +=  null(dtos(CLI1->data_ent))                     + ","
		 cSQL += iif(CLI1->Isento =="N","1","0")                 + "," // Consumidor Final
		 cSQL += transf(CLI1->Comis_repr,"@R 99.99")             + "," 
		 cSQL += quote(strReplace(CLI1->contato_f))              + ","
		 cSQL += quote(strReplace(CLI1->email_cp))               + ","
		 cSQL += quote(strReplace(CLI1->email_fi))                 + ","
		 cSQL += iif(CLI1->msg_recife=="S","1","0")              + ","
		 
		 cOBS := iif(!empty(CLI1->Obs1),strReplace(rtrim(CLI1->Obs1))+"","")
		 cOBS += iif(!empty(CLI1->Obs2),strReplace(rtrim(CLI1->Obs2))+"","")
		 cOBS += iif(!empty(CLI1->Obs3),strReplace(rtrim(CLI1->Obs3))+"","")
		 cOBS += iif(!empty(CLI1->Obs4),strReplace(rtrim(CLI1->Obs4))+"","")
		 cOBS += iif(!empty(CLI1->Obs5),strReplace(rtrim(CLI1->Obs5))     ,"")
		 
		 cSQL +=  quote(cOBS) +","
		 cSQL +=  iif(empty(CLI1->Tributacao),"NULL",alltrim(str(val(CLI1->Tributacao)-1)))  +","
		 cSQL +=  quote(CLI1->conta_cont)          +","
		 
		 cCategoria := converteCategoria(Cli1->Categoria)
		 cSQL += null(cCategoria) +","
		 cSQL += null(CLI1->Cod_exc) +eol
	  endif	 

	  lDuplicado := .F.
	  
	  if mod(CLI1->(Recno()),500) == 0
	     qmensa("Copiando clientes... " + CLI1->Razao) 
	  endif
   
      CLI1->(dbskip())
	  
	  if CLI1->Codigo == LastCli
	     //alert("Cliente Duplicado verifique "+ CLI1->Codigo)
		 lDuplicado := .T.
	  endif 
	  
	  lastCli := CLI1->Codigo
	  
   enddo
   
   nFile := fcreate(cPath + "clientes.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)


return


static function fornecedores
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local lCgmEnt := .T.
local lCgmCob := .T.

        
   FORN->(dbgotop())
   cLast := ""
   cLast := FORN->Codigo
   lDuplicado := .F.
   
   do while ! FORN->(eof())
   
   
      if ! CGM->(dbseek(FORN->cgm_ent))
	     alert("problema na constraint:;" + " fornecedor.id: "+FORN->codigo + " id_mun_entrega: " + FORN->Cgm_ent)
	     lCgmEnt := .F. 
	  endif
	  
	  if ! CGM->(dbseek(FORN->cgm_cob))
	     alert("problema na constraint:;" + " fornecedor.id: "+FORN->codigo + " id_mun_Cobrnca: " + FORN->Cgm_cob)
	     lCgmCob := .F. 
	  endif
   
      if ! lDuplicado .and. ! empty(FORN->Codigo)
   
	     cSQL += strReplace(rtrim(FORN->Codigo))               + ","
         cSQL += quote(strReplace(left(FORN->razao,45)))        + ","	  
	     cSQL += quote(strReplace(left(FORN->cgccpf,14)))        + "," 
		 cSQL += quote(strReplace(left(FORN->fantasia,20)))     + ","
	     cSQL += quoteSemRTrim(qtiraponto(strReplace(left(FORN->inscricao,15))))   + ","
		 cSQL += "NULL"   + ","
	     
	  
	     cSQL += quote(strReplace(left(FORN->end_ent,55)))      + ","
		 cSQL += "NULL"                                         + ","
		 cSQL += quote(strReplace(left(FORN->bairro_ent,20)))   + ","
		 cSQL += quote(strReplace(FORN->cep_ent))               + ","
		 cSQL += "NULL"                                         + ","
	     cSQL += quote(FORN->fone1)                             + ","
	     cSQL += null(FORN->cgm_ent,lCgmEnt)                           + ","
	  
	     cSQL += quote(strReplace(left(FORN->end_cob,55)))      + ","
		 cSQL += "NULL"                                         + ","
		 cSQL += quote(strReplace(left(FORN->bairro_cob,20)))   + ","
	     cSQL += quote(strReplace(FORN->cep_cob))               + ","
		 cSQL += "NULL"                                         + ","
		 cSQL += quote(FORN->fone2)                             + ","
	     cSQL += null(FORN->cgm_cob,lCgmCob)                    + ","+eol
		 lCgmEnt := .T. 
		 lCgmCob := .T. 

  	  endif

	  lDuplicado := .F.
	  
	  if mod(FORN->(Recno()),500) == 0
	     qmensa("Copiando fornecedores... " + FORN->Razao) 
	  endif
   
      FORN->(dbskip())
	  
	  if FORN->Codigo == cLast
	     //alert("Cliente Duplicado verifique "+ FORN->Codigo)
		 lDuplicado := .T.
	  endif 
	  
	  cLast := FORN->Codigo
	  
   enddo
   
   nFile := fcreate(cPath + "fornecedores.txt",0)
    
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)


return

static function produtos
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0


   PROD->(dbsetfilter({|| right(codigo,5) != "     "}))  
   PROD->(dbsetorder(4))
   PROD->(dbgotop())
   
   PROD->(dbgotop())
   do while ! PROD->(eof())
   
      UNIDADE->(dbseek(PROD->Unidade))
	  CLASSIF->(dbseek(PROD->Cod_class))
	  cNCM := qtiraponto(alltrim(CLASSIF->Descricao))
	    	
      id := alltrim(str(val(right(PROD->Codigo,5))))
      cSQL += id        + ","
	  cSQL += quote(strReplace(PROD->Descricao)) + ","
	  cSQL += alltrim(transf(PROD->preco_cons,"@R 99999999.99"))     + ","
	  cSQL += alltrim(transf(PROD->preco_cust  ,"@R 999999999.99"))  + ","
	  cSQL += quote(PROD->Cod_fabr)   + "," 
	  cSQL += quote(PROD->Cod_ass)    + ","  
	  cSQL += quote(PROD->marca)      + ","  
	  cSQL += quote(PROD->cod_barras) + ","
	  cSQL += "NULL"                  + "," 
	  cSQL += quote(UNIDADE->Sigla)   + ","
	  cSQL += alltrim(transf(PROD->ipi  ,"@R 99.99"))  + ","
	  cSQL += null(PROD->Cod_class)   + ","
	  cSQL += alltrim(transf(PROD->cust_dolar  ,"@R 999999999.99"))  + ","
	  cSQL += alltrim(transf(PROD->cust_ren    ,"@R 999999999.99"))  + ","
	  cSQL += alltrim(transf(PROD->peso_bruto  ,"@R 99999999.999"))  + ","
	  cSQL += alltrim(transf(PROD->peso        ,"@R 99999999.999"))  + ","
	  cSQL += alltrim(transf(PROD->cubagem     ,"@R 99999999.999"))  + ","
	  cSQL += iif(PROD->fabr == "00000","NULL",null(PROD->fabr)) +","
	  cSQL += iif(PROD->Designer == "000","NULL",null(PROD->Designer)) +","
	  cSQL += iif(PROD->Fora_linha == "S","1","0") + ","
	  cSQL += iif(PROD->FimDeVida  == "S","1","0") + ","
	  cSQL += iif(PROD->Inspecao   == "S","1","0") + ","
	  cSQL += alltrim(str(PROD->Pontos)) + ","
	  cSQL += strTiraBarra(quote(PROD->Corredor))      + ","
	  cSQL += strTiraBarra(quote(PROD->Estante))       + ","
	  cSQL += strTiraBarra(quote(PROD->Prateleira))    + ","
	  cSQL += strTiraBarra(quote(PROD->Corredor2))      + ","
	  cSQL += strTiraBarra(quote(PROD->Estante2))       + ","
	  cSQL += strTiraBarra(quote(PROD->Prateleir2))     + "," 
      cSQL += "NULL"                                    + ","	  //Obs
	  cSQL += "NULL"                                    + eol     //forn Viamundi
 	  
	  if mod(PROD->(Recno()),400) == 0
	     qmensa("Copiando produtos... " + PROD->cod_ass + PROD->Descricao) 
	  endif
	  
	 
	  PROD->(dbskip())
   enddo
   
   nFile := fcreate(cPath + "produtos.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)


return

static function inventarios
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile  := 0
local nAtu   := 0
local nRes   := 0
local nAva   := 0
local nShow  := 0
local cPROD  := ""
local aQuants := {}
local sData  := ""


   i_reserva()


   PROD->(dbsetfilter({|| right(codigo,5) != "     "}))  
   PROD->(dbsetorder(4))
   PROD->(dbgotop())
   
   INVENT->(dbsetorder(4))
   
   PROD->(dbgotop())
   do while ! PROD->(eof())

      cPROD := right(PROD->Codigo,5)
	  nRes  := 0
	  nAva  := 0
	  nShow := 0
	  nAtu  := 0
	  
	  if INVENT->(dbseek(cPROD))
	     sData := dtos(INVENT->Data)
	  
    	 do while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
            nAtu  += INVENT->Quant_atu
            INVENT->(dbskip())
         enddo
	  
	     aQuants := buscaProduto(cPROD)
	     nRes  := aQuants[2]
	     nAva  := aQuants[3]
	     nShow := aQuants[4]
	  
	     nAtu := nAtu + nRes + nAva + nShow
		 
		 if nAtu < 0
		    nAtu := 0
		 endif
	  
	     id := alltrim(str(val(right(PROD->Codigo,5))))
         cSQL += id + ","  
		 cSQL += alltrim(transf(nAtu,"@R 9999999999")) + ","
	     cSQL += null(sData) + eol
	  
	  endif

      
	  
	  if mod(PROD->(Recno()),500) == 0
	     qmensa("Copiando inventario... " + PROD->cod_ass + PROD->Descricao) 
	  endif
	  
	 
	  PROD->(dbskip())
   enddo
   
   nFile := fcreate(cPath + "inventarios.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)


return

static function responsaveis
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0

   RESP_REP->(dbgotop())
   do while ! RESP_REP->(eof())
      
	  cSQL += RESP_REP->Codigo + "," + quote(strReplace(RESP_REP->nome)) +",NULL" + eol
	  
      RESP_REP->(dbskip())  
   enddo
   
   nFile := fcreate(cPath + "responsaveis.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)


return

static function fabricantes
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0

   if ! quse(XDRV_CP,"FABRICA",{})
      qmensa("Nao abriu fabricas.dbf","BL")
	  return .f.
   endif

   FABRICA->(dbgotop())
   do while ! FABRICA->(eof())
      
	  cSQL += FABRICA->Codigo + "," + quote(strReplace(FABRICA->razao)) + eol
	  
      FABRICA->(dbskip())  
   enddo
   
   nFile := fcreate(cPath + "fabricantes.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)
   
   FABRICA->(dbclosearea())


return

static function representantes
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local lCgmEnt := .T.
local lCgmCob := .T.
local lResp   := .T.

   
   REPRES->(dbgotop())
   cLast := ""
   cLast := REPRES->Codigo
   lDuplicado := .F.
   
   do while ! REPRES->(eof())
   
   
      if ! CGM->(dbseek(REPRES->cgm_ent))
	     alert("problema na constraint:;" + " representante.id: "+REPRES->codigo + " id_mun_entrega: " + REPRES->Cgm_ent)
	     lCgmEnt:= .F.
	  endif
	  
	  if ! CGM->(dbseek(REPRES->cgm_cob))
	     alert("problema na constraint:;" + " representante.id: "+REPRES->codigo + " id_mun_entrega: " + REPRES->Cgm_cob)
	     lCgmCob := .F.
	  endif
	  
	  if ! RESP_REP->(dbseek(REPRES->cod_resp))
	     alert("problema na constraint:;" + " representante.id: "+REPRES->codigo + " responsavel: " + REPRES->cod_resp)
	     lResp := .F.
	  endif
   
      if ! lDuplicado .and. ! empty(REPRES->Codigo)
   
	     cSQL += strReplace(rtrim(REPRES->Codigo))                 + ","
         cSQL += quote(strReplace(left(REPRES->razao,45)))         + ","	  
	     cSQL += quote(strReplace(left(REPRES->cgccpf,14)))        + "," 
		 cSQL +=  quote(strReplace(left(REPRES->fantasia,20)))     + ","
		 cSQL += quoteSemRTrim(qtiraponto(strReplace(left(REPRES->inscricao,15))))   + ","
		 cSQL +=  "NULL"                                           + ","
	    
	  
	     cSQL += quote(strReplace(left(REPRES->end_ent,55)))      + ","
		 cSQL +=  "NULL"                                          + ","
		 cSQL +=  "NULL"                                          + ","
	     cSQL += quote(strReplace(REPRES->cep_ent))               + ","
		 cSQL +=  "NULL"                                          + ","
	     cSQL += quote(REPRES->fone1)                             + ","
	     cSQL += null(REPRES->cgm_ent,lCgmEnt)                    + ","
		 lCgmEnt := .T.
	  
	     cSQL += quote(strReplace(left(REPRES->end_cob,55)))      + ","
		 cSQL +=  "NULL"                                          + ","
		 cSQL +=  "NULL"                                          + ","
	     cSQL += quote(strReplace(REPRES->cep_cob))               + ","
		 cSQL +=  "NULL"                                          + ","
		 cSQL += quote(REPRES->fone2)                             + ","
	     cSQL += null(REPRES->cgm_cob,lCgmCob)                            + ","
		 lCgmCob := .T.
		 cSQL += null(REPRES->cod_resp,lResp)                           + ","
		 lResp := .T.
		 
		 cSQL += quote(REPRES->fax)                               + ","
		 cSQL += quote(REPRES->foner)                             + ","
		 cSQL += quote(REPRES->contato_c)                         + ","
		 cSQL += quote(REPRES->contato_f)                         + ","
		 cSQL += "10.0"                                           + eol
	  endif

	  lDuplicado := .F.
	  
	  if mod(REPRES->(Recno()),15) == 0
	     qmensa("Copiando representantes... " + REPRES->Razao) 
	  endif
   
      REPRES->(dbskip())
	  
	  if REPRES->Codigo == cLast
	     //alert("Cliente Duplicado verifique "+ REPRES->Codigo)
		 lDuplicado := .T.
	  endif 
	  
	  cLast := REPRES->Codigo
	  
   enddo
   
   nFile := fcreate(cPath+"representantes.txt",0)
    
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)


return

static function transportadoras
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local lCgm := .T.

   //cSQL := "LOCK TABLES transportadoras WRITE;" + eol
   
   //cSQL += "INSERT INTO transportadoras (id,nome,cnpj,inscricao_estadual,inscricao_municipal,fantasia"
   //cSQL += ",logradouro,numero,bairro,cep,complemento,telefone,id_municipio,telefone2,fax,contato_comercial,contato_financeiro) VALUES" + eol

   TRANSP->(dbgotop())
   cLast := ""
   cLast := TRANSP->Codigo
   lDuplicado := .F.
   
   do while ! TRANSP->(eof())
   
   
      if ! CGM->(dbseek(TRANSP->cgm))
	     alert("problema na constraint:;" + " trasnportadora.id: "+TRANSP->codigo + " id_mun_entrega: " + TRANSP->Cgm)
	     lCgm := .F.
	  endif
   
      if ! lDuplicado .and. ! empty(TRANSP->Codigo)
   
	     cSQL += strReplace(TRANSP->Codigo)                             + ","
         cSQL += quote(strReplace(left(TRANSP->razao,45)))              + ","	  
	     cSQL += quote(strReplace(left(TRANSP->cgccpf,14)))             + "," 
		 cSQL += quote(strReplace(left(TRANSP->fantasia,20)))           + ","
	     cSQL += quote(qtiraponto(strReplace(left(TRANSP->inscricao,15))))  + ","
	     cSQL += "NULL"                                                 + ","
	     
	     cSQL += quote(strReplace(left(TRANSP->endereco,55)))           + ","
		 cSQL += "NULL"                                                 + ","  
         cSQL += "NULL"		                                            + "," 
	     cSQL += quote(strReplace(TRANSP->cep))                         + ","
		 cSQL += "NULL"                                                 + ","
	     cSQL += quote(TRANSP->fone1)                                   + ","
	     cSQL += null(TRANSP->cgm,lCgm)                                 + ","
		 lCgm := .T.
		 cSQL += quote(TRANSP->fone2)                                   + ","
		 cSQL += quote(TRANSP->fax)                                     + ","
		 cSQL += quote(TRANSP->Contato_c)                               + ","
		 cSQL += quote(TRANSP->Contato_f)                               + eol
	  
	  endif

	  lDuplicado := .F.
	  
	  if mod(TRANSP->(Recno()),15) == 0
	     qmensa("Copiando transportadoras... " + TRANSP->Razao) 
	  endif
   
      TRANSP->(dbskip())
	  
	  if TRANSP->Codigo == cLast
		 lDuplicado := .T.
	  endif 
	  
	  cLast := TRANSP->Codigo
	  
   enddo
   
   nFile := fcreate(cPath+"transportadoras.txt",0)
    
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)


return

static function moviment
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local nCont := 0
local lProd := .T.

   if ! quse(XDRV_ES,"MOVIMENT",{})
      qmensa("Nao abriu moviment.dbf")
	  return .f. 
   endif

   nCont := 1     
   MOVIMENT->(dbgotop())
   
   do while ! MOVIMENT->(eof())
   
       
      if MOVIMENT->Contabil
	     MOVIMENT->(dbskip())
		 loop
	  endif
   
      if ! PROD->(dbseek(MOVIMENT->cod_prod))
	     //alert("problema na constraint:;" + " avariado.recno: "+str(MOVIMENT->(recno())) + " Produto.id: " + MOVIMENT->cod_prod)
		 //lProd := .F.
		 MOVIMENT->(dbskip())
		 loop
	  endif
   
         cSQL += alltrim(str(nCont))         + ","   
	     cSQL += MOVIMENT->cod_prod          + ","	  
		 cSQL += alltrim(transf(MOVIMENT->quantidade,"@R 99999999"))   + ","
		 cSQL += dtos(MOVIMENT->data)        + ","
		 cSQL += quote(MOVIMENT->Tipo)       + eol
	  
	  if mod(MOVIMENT->(Recno()),200) == 0
	     qmensa("Copiando estoque nao contabilizado.. " + dtoc(MOVIMENT->data)) 
	  endif
	  
	  nCont++
   
      MOVIMENT->(dbskip())
	  
   enddo
   
   nFile := fcreate(cPath + "moviment.txt",0)
    
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)
   
   MOVIMENT->(dbclosearea())


return


static function avarias
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local nCont := 0

   
   nCont := 1     
   AVARIADO->(dbgotop())
   
   do while ! AVARIADO->(eof())
   
   
      if ! PROD->(dbseek(AVARIADO->cod_prod))
	     //alert("problema na constraint:;" + " avariado.recno: "+str(AVARIADO->(recno())) + " Produto.id: " + AVARIADO->cod_prod)
		 AVARIADO->(dbskip())
		 loop
	  endif
   
   
         cSQL += alltrim(str(nCont))         + ","   
	     cSQL += AVARIADO->cod_prod          + ","	  
		 cSQL += dtos(AVARIADO->data)        + ","
		 cSQL += alltrim(transf(AVARIADO->quantidade,"@R 99999999"))   + ","
		 cSQL += quote(AVARIADO->Obs)              + eol
		 
		 aadd(aPed,{AVARIADO->Cod_prod,0,AVARIADO->Quantidade,0})
	  
	  if mod(AVARIADO->(Recno()),300) == 0
	     qmensa("Copiando avarias... " + AVARIADO->Ref) 
	  endif
	  
	  nCont++
   
      AVARIADO->(dbskip())
	  
   enddo
   
   nFile := fcreate(cPath + "avarias.txt",0)
    
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)


return

static function show_room
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local nCont := 1

   
   SHOWROOM->(dbgotop())
   
   do while ! SHOWROOM->(eof())
   
   
      if ! PROD->(dbseek(SHOWROOM->cod_prod))
	     //alert("problema na constraint:;" + " showrrom.recno: "+ str(SHOWROOM->(recno())) + " Produto.id: " + SHOWROOM->cod_prod)
		 SHOWROOM->(dbskip())
		 loop
	  endif
   
         cSQL += alltrim(str(nCont))          + "," 
	     cSQL += SHOWROOM->Cod_prod          + ","
		 cSQL += dtos(SHOWROOM->data)              + ","
		 cSQL += alltrim(transf(SHOWROOM->quantidade,"@R 99999999"))   + ","
		 cSQL += quote(SHOWROOM->Obs)              + eol
	  
	  if mod(SHOWROOM->(Recno()),15) == 0
	     qmensa("Copiando show room... " + SHOWROOM->Ref) 
	  endif
	  
	  aadd(aPed,{SHOWROOM->Cod_prod,0,0,SHOWROOM->Quantidade})
	  
	  nCont++
   
      SHOWROOM->(dbskip())
	  
   enddo
   
   nFile := fcreate(cPath + "showroom.txt",0)
    
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)


return

static function i_reserva
local lTEM := .F.
local cLOTE   := space(10)
local cFILIAL := space(4)
local nQTY    := 0
local cPROD   := space(5)
local nCONT   := 1

ITEN_FAT->(dbsetorder(2))
FAT->(dbsetorder(11))
FAT->(dbgotop())

aProdutos := {}


Do while ! FAT->(eof()) .and. empty(FAT->Num_fatura)
   
   if FAT->es != "S"
      FAT->(dbskip())
	  loop
   endif
   
   if left(FAT->Cod_cfop,4) $ "5905-6905"
      FAT->(dbskip())
	  loop
   endif

   ITEN_FAT->(Dbseek(FAT->Codigo))

   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      aadd(aPED,{ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,0,0})
      lTEM := .T.
      ITEN_FAT->(dbskip())
   enddo


   FAT->(Dbskip())
enddo

asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

if lTEM
    cPROD   := asPED[1,1]
    nReserva  := 0
	nAvaria   := 0 
	nShowRoom := 0

    nCONT := 1
    do while  nCONT <= len(asPED)

        nReserva  += asPED[nCONT,2]
		nAvaria   += asPED[nCONT,3]
		nShowRoom += asPED[nCONT,4]

        nCONT++
        if nCONT > len(asPED)
           nCONT := len(asPED)
           exit
        endif

        if asPED[nCONT,1] != cPROD
		   aadd(aProdutos,{cPROD,nReserva,nAvaria,nShowRoom}) 

           cPROD   := asPED[nCONT,1]
           nReserva    := 0
		   nAvaria     := 0
		   nShowRoom   := 0
        endif
    enddo
	
	aadd(aProdutos,{cPROD,nReserva,nAvaria,nShowRoom})

endif

aPED := {}
asPED := {}
return

static function buscaProduto(cPROD)
local nKey := 0

       nKey := ascan(aProdutos,{|ckey| cKey[1] == cPROD})
	   if nKey > 0
	      return aProdutos[nKey]
       endif  
	   
return {"",0,0,0}


static function quote(cField)
return iif(empty(cField),"NULL",'"'+rtrim(cField)+'"')

static function quoteSemRTrim(cField)
return iif(empty(cField),"NULL",'"'+cField+'"')

static function numero(cField)
return iif(cField == 0,"NULL",alltrim(str(cField)))

static function numero0(cField)
return alltrim(str(cField))

static function converteCategoria(cCat)
    do case
	   case cCAT == "V"
	      return "0";
		  
	   case cCAT == "P"
	      return "1";	
		  
	   case cCAT == "N"
	      return "2";
		  
	   case cCAT == "F"
	      return "3";
	   
	   case cCAT == "C"
	      return "3";	  

 	   otherwise
	      return ""
    endcase	   


return

static function notaFiscal
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local cItem := ""
local lCli    := .T.
local lRepres := .T.
local lResp   := .T.
local lVend   := .T.
local lPROD   := .T.
local lTransp := .T.
local nCont := 1

    PROD->(dbsetorder(4))
    FAT->(dbsetorder(2))
	FAT->(dbgotop())
	
	alert(dtoc(FAT->dt_emissao))
	
   cLast := ""
   cLast := FAT->Codigo
   lDuplicado := .F.
	
	do while ! FAT->(eof())
	
	   if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_Fatura) .and. FAT->Es == "S"
         FAT->(DbSkip())
         loop
      endif

      if left(FAT->Cod_cfop,4) $ "5905-6905-1906-2906-5906-6906-1905-2905-    "
         FAT->(DbSkip())
         loop
      endif

	   if ! CLI1->(dbseek(FAT->Cod_cli)) .and. !empty(FAT->Cod_cli)
	      //alert("Problema na constraint pedido.cliente.id no pedido: "+FAT->Codigo + " cliente.id: " +FAT->Cod_cli,"BL")
		  lCli := .F.
	   endif
	   
	   if ! REPRES->(dbseek(FAT->Cod_repres)) .and. !empty(FAT->Cod_repres)
	      //alert("Problema na constraint pedido.representante.id no pedido: "+FAT->Codigo + " repres.id: " +FAT->Cod_repres,"BL")
		  lRepres := .F.
	   endif
	   
	   if ! RESP_REP->(dbseek(FAT->Cod_resp)) .and. !empty(FAT->Cod_resp)
	      //alert("Problema na constraint pedido.responsavel.id no pedido: "+FAT->Codigo + " responsavel.id: " +FAT->Cod_resp,"BL")
		  lResp := .F.
	   endif
	   
	   if ! TRANSP->(dbseek(FAT->Cod_transp)) .and. !empty(FAT->Cod_transp)
	      //alert("Problema na constraint pedido.responsavel.id no pedido: "+FAT->Codigo + " responsavel.id: " +FAT->Cod_resp,"BL")
		  lTransp := .F.
	   endif
	   
	   cSQL += alltrim(str(nCont)) + ","
	   cSQL += dtos(FAT->dt_emissao) + ","
	   cSQL += "NULL" + ","
	   cSQL += quote(FAT->Num_fatura) + ","
	   cSQL += null(FAT->Cod_cli,lCli) + ","
	   cSQL += quote(iif(val(FAT->num_fatura) < 1000 .and. FAT->dt_emissao > ctod("01/10/2012"),"900","1")) + ","
	   cSQL += quote(FAT->Modelo) + ","
	   cSQL += null(FAT->cod_repres,lRepres) + ","
	   cSQL += null(FAT->cod_resp,lResp) + ","
	   cSQL += "NULL" + ","
	   cSQL += iif(FAT->Es == "S","1","0") + ","
	   cSQL += "0" + ","
	   cSQL += null(FAT->cod_transp,lTransp) + ","
	   cSQL += alltrim(FAT->cod_cfop)+"," 
	   cSQL += alltrim(FAT->Nfe)+"," 
	   cSQL += "NULL" + ","  //Xml da NFe
	   cSQL += "NULL" + ","  //Expedicao_id
	   cSQL += "0" + ","     //Cancelada
	   cSQl += quote(strReplace(ltrim(rtrim(left(FAT->Obs,80))),',','.')) + ","
	   cSQL += quote("0") + ","
	   cSQL += quote("CX") + ","
	   cSQL += "0" + ","
	   cSQL += "0" + ","
	   
	    nTipoFrete := val(FAT->Frete) -1
	   
	   if(nTipoFrete < 0)
	     nTipoFrete := 0
	   endif	 
	   
	   cSQL +=  numero0(nTipoFrete) + ","
	   cSQL += "0" + ","
	   cSQL += alltrim(transf(FAT->basest,"@R 9999999999.99")) + ","
	   cSQL += alltrim(transf(FAT->st,"@R 9999999999.99")) + ","
	   cSQL += "1" + eol //Exportado pro qsys
	   
	   lCli    := .T.
	   lResp   := .T.
	   lRepres := .T.
	   lVend   := .T.
	   lTransp := .T.
	   
	   ITEN_FAT->(dbseek(FAT->Codigo))
	   
	   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->num_fat == FAT->Codigo
	   
	      if ! PROD->(dbseek(ITEN_FAT->Cod_prod))
	          //alert("Problema na constraint iten.produto.id no pedido: "+FAT->Codigo + " produto.id: " +ITEN_FAT->Cod_prod)
			  lPROD := .F.
	      endif
	      
		  cItem += "NULL" + ","
		  cItem += alltrim(str(nCont)) +","
		  cItem += null(ITEN_FAT->Cod_prod) +","
		  cItem += numero(ITEN_FAT->Quantidade) + ","
		  cItem += alltrim(transf(ITEN_FAT->vl_unitar,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->preco_cust,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->preco_vend,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->desc_prod,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->vlr_desc,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->icms,"@R 99.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->ipi,"@R 99.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->pontos,"@R 99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->comi_repre,"@R 99")) + ","
		  cItem += "0" + ","
		  cItem += "0" + ","
		  cItem += "0" + ","
		  cItem += "0" + ","
		  cItem += "0" + ","
		  cItem += "0" + ","
		  cItem += "0" + ","
		  cItem += "0" + eol
		  
		  lPROD := .T.
	   
	      ITEN_FAT->(dbskip())
	   enddo
	   
	   nCont++
	   
	   //qmensa(FAT->Codigo)
	   
	   FAT->(dbskip())
	   
	   if FAT->Codigo == cLast
	      alert("Pedido Duplicado verifique "+ FAT->Codigo +" "+ dtoc(FAT->Dt_emissao) +" "+ FAT->Num_fatura)
		  lDuplicado := .T.
		  //cLast := FAT->Codigo
	   endi
	   

    enddo
	
   nFile := fcreate(cPath + "nfs.txt",0)
    
   fwrite(nfile,cSQL,len(cSQL))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "itens_nfs.txt",0)
    
   fwrite(nfile,cItem,len(cItem))
   
   fclose(nFile)

return

static function compras
local dINI := ctod("01/01/2005")
local dFIM := ctod("31/12/2013")
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local cItem := ""
local lForn := .T.
local lProd := .T.
   
   PEDIDO->(dbgotop())
   do while ! PEDIDO->(eof()) 

      if ! PEDIDO->Interface
         PEDIDO->(Dbskip())
         loop
      endif
	 
	  if ! FORN->(dbseek(PEDIDO->Cod_forn)) .and. !empty(PEDIDO->Cod_forn)
	     //alert("Problema na constraint pedidoDeCompra.forn.id no pedido: "+PEDIDO->Codigo + " forn.id: " +PEDIDO->Cod_forn,"BL")
		 lForn := .F.
	  endif
	   
	   cSQL += left(PEDIDO->Codigo,5) + ","
	   cSQL += dtos(PEDIDO->data_emiss) + ","
	   cSQL += null(PEDIDO->Cod_forn,lForn) + ","
	   cSQL += quote(strReplace(PEDIDO->observacao)) + ","
	   cSQL += quote(strReplace(PEDIDO->numero_nf)) + ","
	   cSQL += quote("1") + ","
	   cSQL += iif(PEDIDO->data_emiss < ctod("01/01/2010"), quote("01"),quote("55")) + ","
	   cSQL += alltrim(PEDIDO->Cfop) +eol
	   lForn := .T.

       LANC->(Dbseek(PEDIDO->Codigo))
       do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())
	   
	      if ! PROD->(dbseek(LANC->Cod_prod))
	          //alert("Problema na constraint itenCompra.produto.id no pedido: "+PEDIDO->Codigo + " produto.id: " +LANC->Cod_prod)
			  lProd := .T.
	      endif
		  
          cItem += "NULL" + ","
		  cItem += left(LANC->Cod_ped,5) +","
		  cItem += null(LANC->Cod_prod,lProd) +","
		  cItem += numero(LANC->Quant) + ","
		  cItem += alltrim(transf(LANC->preco,"@R 9999999999.99")) + eol
		  lPROD := .T.

          LANC->(Dbskip())
       enddo
       PEDIDO->(dbskip())
   enddo
   
   nFile := fcreate(cPath + "compras.txt",0)
    
   fwrite(nfile,cSQL,len(cSQL))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "itens_compras.txt",0)
    
   fwrite(nfile,cItem,len(cItem))
   
   fclose(nFile)


return

static function pendencias
local dINI := ctod("01/01/2005")
local dFIM := ctod("31/12/2013")
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local cItem := ""
local cOBS  := ""
local nTipoFrete := 0
local lCli    := .T.
local lRepres := .T.
local lResp   := .T.
local lProd   := .T.
local lTransp := .T.
local cDuplicata := ""

    nContItem := 0

    if ! quse(XDRV_CL,"OBSERVP",{})
      qmensa("Nao abriu observp.dbf ----- > observacao de pendencias")
	  return .f. 
    endif 

    PROD->(dbsetorder(4))

    
    PEND->(dbsetorder(2))
	PEND->(dbgotop())
	set softseek on
	PEND->(dbseek(dtos(dINI)))
	set softseek off
	
	alert(dtoc(PEND->dt_emissao))
	
	PEND->(dbgotop())
	
   cLast := ""
   cLast := PEND->Codigo
   lDuplicado := .F.
	
	do while ! PEND->(eof())
	
	   //qmensa(PEND->dt_emissao)
	
	   if left(PEND->Cod_cfop,4) $ "5905-6905-1906-2906"
          PEND->(dbskip())
	      loop
       endif

       if PEND->Dt_emissao < dINI .or. PEND->Dt_emissao > dFIM
          PEND->(dbskip())
          loop
       endif
	   
	   if ! CLI1->(dbseek(PEND->Cod_cli)) .and. !empty(PEND->Cod_cli)
	      //alert("Problema na constraint pendecia.cliente.id no pendecia: "+PEND->Codigo + " pendecia.id: " +PEND->Cod_cli,"BL")
		  lCli := .F.
	   endif
	   
	   if ! TRANSP->(dbseek(PEND->Cod_transp)) .and. !empty(PEND->Cod_transp)
	      //alert("Problema na constraint pendecia.cliente.id no pendecia: "+PEND->Codigo + " pendecia.id: " +PEND->Cod_cli,"BL")
		  ltransp := .F.
	   endif
	   
	   cSQL += PEND->Codigo + ","
	   cSQL += null(PEND->Cod_cli,lCli) + ","
	   cSQL += dtos(PEND->dt_emissao) + ","
	   cSQL += dtos(PEND->dt_emissao) + ","
	   cSQL += "NULL" + ","

	   cOBS := iif(!empty(PEND->Obs),strReplace(rtrim(PEND->Obs))+"","")
	   
	   if OBSERVP->(dbseek(PEND->Codigo))
	      cOBS += iif(!empty(OBSERVP->Obs1),strReplace(rtrim(OBSERVP->Obs1))+"","")
	      cOBS += iif(!empty(OBSERVP->Obs2),strReplace(rtrim(OBSERVP->Obs2))+"","")
	      cOBS += iif(!empty(OBSERVP->Obs3),strReplace(rtrim(OBSERVP->Obs3))+"","")
	      cOBS += iif(!empty(OBSERVP->Obs4),strReplace(rtrim(OBSERVP->Obs4))+"","")
	      cOBS += iif(!empty(OBSERVP->Obs5),strReplace(rtrim(OBSERVP->Obs5))     ,"")
	   endif	  
	   
	   cOBS := strReplace(cOBS,',','.')
	   
	   cSQL += quote(ltrim(cOBS))+ ","
	   
	   cSQL += null(PEND->Cod_transp,lTransp) + ","
	   
	   nTipoFrete := val(PEND->Frete) -1
	   
	   if(nTipoFrete < 0)
	     nTipoFrete := 0
	   endif	 
	   
	   cSQL +=  numero0(nTipoFrete) + ","
	   
	   nInfoBoleto := val(PEND->Boleto) -1
	   cSQL +=  numero0(nInfoBoleto) + ","
	   cSQL +=  numero(PEND->Vezes) + ","
	   cSQL +=  quote(PEND->Pedido) + ","
	   cSQL += alltrim(PEND->cod_cfop) + ","
	   cSQL += quote(PEND->Pedido)+","  
	   cSQL += null(PEND->cod_repres) + ","
	   cSQL += null(PEND->cod_resp) + ","
	   cSQL += "2" + ","
	   cSQL += ""  + ","
	   cSQL += ""  + ","
	   cSQL += ""  + ","
	   cSQL += "1" + "," //Exportado
	   cSQL += "" + eol
	   
	   lCLi    := .T.
	   lTransp := .T.
	   
	   ITEM_PEN->(dbseek(PEND->Codigo))
	   
	   do while ! ITEM_PEN->(eof()) .and. ITEM_PEN->cod_pend == PEND->Codigo
	   
	      if ! PROD->(dbseek(ITEM_PEN->Cod_prod))
	          alert("Problema na constraint iten.produto.id no pedido: "+PEND->Codigo + " produto.id: " +ITEM_PEN->Cod_prod)
			  lProd := .F.
	      endif
	      
		  nContItem++
		  cItem += numero(nContItem) + ","
		  cItem += ITEM_PEN->cod_pend +","
		  cItem += null(ITEM_PEN->Cod_prod) +","
		  cItem += numero0(ITEM_PEN->Quantidade) + ","
		  cItem += alltrim(transf(ITEM_PEN->preco_vend,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEM_PEN->desc_prod,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEM_PEN->vlr_desc,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEM_PEN->vl_unitar,"@R 9999999999.99")) + ","
		  cItem += "0" + ","
		  cItem += "0" + eol
		  lPROD := .T.
	   
	      ITEM_PEN->(dbskip())
	   enddo
	   
	   
        if DUP_PEN->(Dbseek(PEND->Codigo+"01"))

           Do While ! DUP_PEN->(Eof()) .and. left(DUP_PEN->Num_pen,5) == PEND->Codigo

    		  cDuplicata += "NULL" + ","
			  cDuplicata += PEND->Codigo + ","
			  cDuplicata += alltrim(str(DUP_PEN->Dias)) + ","
			  cDuplicata += alltrim(transf(DUP_PEN->Valor,"@R 9999999999.99")) + eol

              DUP_PEN->(Dbskip())

           enddo

        endif
	   
	   
	   //qmensa("pendencias" + PEND->Codigo)
	   
	   PEND->(dbskip())
	   
	   if PEND->Codigo == cLast
	      alert("Pendencia Duplicado verifique "+ PEND->Codigo)
		  lDuplicado := .T.
	   endif

    enddo
	
   nFile := fcreate(cPath + "pendencias.txt",0)
    
   fwrite(nfile,cSQL,len(cSQL))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "itens_pendencias.txt",0)
    
   fwrite(nfile,cItem,len(cItem))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "parcelas_pendencias.txt",0)
    
   fwrite(nfile,cDuplicata,len(cDuplicata))
   
   fclose(nFile)
   
   OBSERVP->(dbclosearea())

return


static function reservas
local dINI := ctod("01/01/2005")
local dFIM := ctod("31/12/2013")
local cSQL := ""
local nLastRec   := 0
local cLast      := ""
local lDuplicado := .F.
local nFile      := 0
local cItem      := ""
local cOBS       := ""
local nTipoFrete := 0
local cReserva   := ""
local cVenda     := ""
local nVendaID   := 0
local lCLI       := .T.
local lPRod      := .T.
local lTransp    := .T.
local lRepres    := .T.
local lResp      := .T.
local eol        := chr(13) + chr(10)
local cParcPed := ""
local cParcExp := ""

    if ! quse(XDRV_CL,"OBSERVAC",{})
      qmensa("Nao abriu observac.dbf ----- > observacao de pedido")
	  return .f. 
    endif 

    PROD->(dbsetorder(4))

   ITEN_FAT->(dbsetorder(2))
   FAT->(dbsetorder(11))
   FAT->(dbgotop())

   Do while ! FAT->(eof()) .and. empty(FAT->Num_fatura)

      if empty(FAT->codigo)
         FAT->(dbskip())
	     loop
      endif
   
      if FAT->es != "S"
         FAT->(dbskip())
	     loop
      endif
   
      if left(FAT->Cod_cfop,4) $ "5905-6905"
         FAT->(dbskip())
   	     loop
      endif
	  
	  if ! CLI1->(dbseek(FAT->Cod_cli)) .and. !empty(FAT->Cod_cli)
		  lCli := .F.
	   endif
	   
	   if ! TRANSP->(dbseek(FAT->Cod_transp)) .and. !empty(FAT->Cod_transp)
		  ltransp := .F.
	   endif
	   
	   if ! REPRES->(dbseek(FAT->Cod_repres)) .and. !empty(FAT->Cod_repres)
		  lRepres := .F.
	   endif
	   
	   if ! RESP_REP->(dbseek(FAT->Cod_resp)) .and. !empty(FAT->Cod_resp)
		  lResp := .F.
	   endif
   
       cSQL += FAT->Codigo + ","
	   cSQL += null(FAT->Cod_cli,lCli) + ","
	   cSQL += dtos(FAT->dt_emissao) + ","
	   cSQL += dtos(FAT->dt_emissao) + ","
	   cSQL += "NULL" + ","
	   

	   cOBS := iif(!empty(FAT->Obs),strReplace(rtrim(FAT->Obs))+"","")
	   
	   if OBSERVAC->(dbseek(FAT->Codigo))
	      cOBS += iif(!empty(OBSERVAC->Obs1),strReplace(rtrim(OBSERVAC->Obs1))+"","")
	      cOBS += iif(!empty(OBSERVAC->Obs2),strReplace(rtrim(OBSERVAC->Obs2))+"","")
	      cOBS += iif(!empty(OBSERVAC->Obs3),strReplace(rtrim(OBSERVAC->Obs3))+"","")
	      cOBS += iif(!empty(OBSERVAC->Obs4),strReplace(rtrim(OBSERVAC->Obs4))+"","")
	      cOBS += iif(!empty(OBSERVAC->Obs5),strReplace(rtrim(OBSERVAC->Obs5))   ,"")
	   endif	  
	   
	   cOBS := strReplace(cOBS,',','.')
	   
	   cSQL += quote(ltrim(cOBS))+ ","
	   cSQL += null(FAT->Cod_transp,lTransp) + ","
	  
	   
	   nTipoFrete := val(FAT->Frete) -1
	   if(nTipoFrete < 0)
	      nTipoFrete := 0
	   endif	  
	   
	   cSQL +=  numero0(nTipoFrete) + ","
	   
	   nInfoBoleto := val(FAT->Boleto) -1
	   cSQL +=  numero0(nInfoBoleto) + ","
	   cSQL +=  numero(FAT->Vezes) + ","
	   cSQL +=  quote(FAT->Pedido) + ","
       cSQL += alltrim(FAT->cod_cfop) + ","
	   cSQL += "" +","  
	   cSQL += null(FAT->cod_repres) + ","
	   cSQL += null(FAT->cod_resp) + ","
	   cSQL += "2" + ","
	   cSQL += ""  + ","
	   cSQL += ""  + ","
	   cSQL += ""  + ","
	   cSQL += "1" + "," //Exportado
	   cSQL += "" + eol
	   nVendaID ++

       ITEN_FAT->(Dbseek(FAT->Codigo))

       Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
	      if ! PROD->(dbseek(ITEN_FAT->Cod_prod))
	          //alert("Problema na constraint itenreserva.produto.id no pedido: "+FAT->Codigo + " produto.id: " +ITEN_FAT->Cod_prod)
			  lPROD := .F.
	      endif
	      
		  nContItem++
		  cItem += numero(nContItem) + ","
		  cItem += ITEN_FAT->num_fat +","
		  cItem += null(ITEN_FAT->Cod_prod) +","
		  cItem += numero0(ITEN_FAT->Quantidade) + ","
		  cItem += alltrim(transf(ITEN_FAT->preco_vend,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->desc_prod,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->vlr_desc,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->vl_unitar,"@R 9999999999.99")) + ","
		  cItem += "0" + ","
		  cItem += "0" + eol
		  lPROD := .T.
		  
		  
		  cReserva += "NULL" + ","
		  cReserva += numero(nContItem) + ","
		  cReserva += numero0(ITEN_FAT->Quantidade) + ","
		  cReserva += numero(nVendaID) + ","
		  cReserva += "1" + ","    // Expedicao Sub classe
		  cReserva += "NULL" + "," // Reserva
		  cReserva += "NULL" + eol // Cancelamento

          ITEN_FAT->(dbskip())
       enddo
	   
	   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))
          do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
             
			  cParcPed += "NULL" + ","
			  cParcPed += FAT->Codigo + ","
			  cParcPed += alltrim(str(DUP_FAT->Dias)) + ","
			  cParcPed += alltrim(transf(DUP_FAT->Valor,"@R 9999999999.99")) + eol
			  
			  cParcExp += "NULL" + ","
			  cParcExp += numero(nVendaID) + ","
			  cParcExp += alltrim(str(DUP_FAT->Dias)) + ","
			  cParcExp += alltrim(transf(DUP_FAT->Valor,"@R 9999999999.99")) + eol
			 
			 
			 DUP_FAT->(Dbskip())
          enddo
      endif
	   
	   cVenda += numero(nVendaID) + ","
	   cVenda += null(FAT->Cod_cli) + ","
	   cVenda += "NULL" + ","
	   cVenda += null(FAT->Cod_transp,lTransp) + ","
	   cVenda += alltrim(FAT->Cod_cfop) + ","
	   cVenda += "NULL" + "," //nota_fiscal_id
	   cVenda += "NULL" + "," //data entrada
	   cVenda += "NULL" + "," //data coneferencia
	   cVenda += "NULL" + "," //volume
	   cVenda += "NULL" + "," //especie
	   cVenda += "NULL" + "," //marca
	   cVenda += "0" + "," //Peso l
	   cVenda += "0" + "," //Peso b
	   cVenda += numero0(nTipoFrete) + "," 
	   cVenda += cOBS + "," //Observacoes
	   cVenda += "0"  + "," //Aguradar para faturar
	   cVenda += "NULL" + "," //Motivo de aguardar
	   cVenda += "NULL" + "," //Numero da Nota
	   cVenda += "NULL" + "," //Chave
	   cVenda += "0"  + "," //EM Processamento
	   cVenda += numero0(nInfoBoleto) + eol //Info do Boleto
	   
       lTransp := .T.
	   lCli := .T.
	   lRepres    := .T.
       lResp      := .T.

       FAT->(Dbskip())
    enddo
	
	OBSERVAC->(dbclosearea())
	
   nFile := fcreate(cPath + "pedido_com_reserva.txt",0)
    
   fwrite(nfile,cSQL,len(cSQL))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "itens_pedido_reserva.txt",0)
    
   fwrite(nfile,cItem,len(cItem))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "reservas.txt",0)
    
   fwrite(nfile,cReserva,len(cReserva))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "vendas.txt",0)
    
   fwrite(nfile,cVenda,len(cVenda))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "parcela_pedido.txt",0)
    
   fwrite(nfile,cParcPed,len(cParcPed))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "parcela_expedicao.txt",0)
    
   fwrite(nfile,cParcExp,len(cParcExp))
   
   fclose(nFile)


return

static function areas
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local estado_id := 0

   AREA_EXC->(dbgotop())
   do while ! AREA_EXC->(eof())
      
	  cSQL += AREA_EXC->Codigo + "," 
	  cSQL += quote(AREA_EXC->Descricao) + ","  
	  cSQL += null(AREA_EXC->cidade) + eol
	  
      AREA_EXC->(dbskip())  
	  
   enddo
   
   nFile := fcreate(cPath + "areas.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return

static function exclusividades
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local estado_id := 0

   EXCLUSIV->(dbgotop())
   do while ! EXCLUSIV->(eof())
      
	  cSQL += "," 
	  cSQL += null(EXCLUSIV->Cod_cli) + ","  
	  cSQL += null(EXCLUSIV->Cod_prod) + ","  
	  cSQL += null(EXCLUSIV->cidade) + ","  
	  cSQL += null(EXCLUSIV->cod_exc) + eol
	  
      EXCLUSIV->(dbskip())  
	  
   enddo
   
   nFile := fcreate(cPath + "exclusividades.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return

static function usuarios
local cSQL := ""
local nFile := 0
   
   if ! quse(XDRV_SH,"QUSERS",{"QUSERS1","QUSERS2"}) ; return .F. ; endif
   
   QUSERS->(dbgotop())
   do while ! QUSERS->(eof())
      
	  cSQL += "," 
	  cSQL += quote(lower(qdecri(substr(QUSERS->Identific,21,30)))) + ","  
	  cSQL += quote(lower(qdecri(substr(QUSERS->Identific,11,10)))) + ","  
	  cSQL += quote(lower(qdecri(left(QUSERS->Identific,10)))) + ","  
	  cSQL += "1" +","
	  cSQL += "NULL" + eol
	  
      QUSERS->(dbskip())  
	  
   enddo
   
   nFile := fcreate(cPath + "usuarios.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)
   
   QUSERS->(dbclosearea())

return

static function restricoes
local cSQL := ""
local nFile := 0
local cOBS := ""
local nCont := 1
   
   if ! quse(XDRV_CL,"RESTRI",{"",""}) ; return .F. ; endif
   
   RESTRI->(dbgotop())
   do while ! RESTRI->(eof())
   
      cOBS := ""
   
	  cOBS += iif(!empty(RESTRI->Obs),strReplace(rtrim(RESTRI->Obs))+"","")
	  cOBS += iif(!empty(RESTRI->Obs2),strReplace(rtrim(RESTRI->Obs2))+"","")
	  cOBS += iif(!empty(RESTRI->Obs3),strReplace(rtrim(RESTRI->Obs3))+"","")
	  cOBS += iif(!empty(RESTRI->Obs4),strReplace(rtrim(RESTRI->Obs4))+"","")
	  cOBS += iif(!empty(RESTRI->Obs5),strReplace(rtrim(RESTRI->Obs5))   ,"")
      
	  cSQL += alltrim(str(nCont)) + "," 
	  cSQL += null(RESTRI->Cod_cli) + ","  
	  cSQL += cOBS + eol
	  
	  nCont ++
	  
      RESTRI->(dbskip())  
	  
	  cOBS := ""
	  
   enddo
   
   nFile := fcreate(cPath + "restricoes.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)
   
   RESTRI->(dbclosearea())

return

static function invoices
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0

   INVOICE->(dbgotop())
   do while ! INVOICE->(eof())
      
	  cSQL += INVOICE->Codigo + "," 
	  cSQL += dtos(INVOICE->data_ped) + ","  
	  cSQL += null(dtos(INVOICE->dt_chegada)) + ","
	  cSQL += null(INVOICE->cod_forn) + ","
	  cSQL += quote(left(INVOICE->invoice,15)) + "," 
	  cSQL += quote(rtrim(left(INVOICE->obs,50))) + eol
	  
      INVOICE->(dbskip())  
	  
   enddo
   
   nFile := fcreate(cPath + "invoices.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return

static function itens_invoice
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local nCont := 1

   ITEN_INV->(dbgotop())
   do while ! ITEN_INV->(eof())
      
	  cSQL += alltrim(str(nCont)) + "," 
	  cSQL += ITEN_INV->Cod_inv + "," 
	  cSQL += ITEN_INV->Cod_prod + "," 
	  cSQL += numero0(ITEN_INV->Quantidade) + ","  
	  cSQL += alltrim(transf(ITEN_INV->Valor,"@R 9999999999.9999")) + ","
	  cSQL += numero(0) + eol
	  
	  nCont++
	  
      ITEN_INV->(dbskip())  
	  
   enddo
   
   nFile := fcreate(cPath + "itens_invoice.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return

static function pedido_china
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0

   PED_FABR->(dbgotop())
   do while ! PED_FABR->(eof())
      
	  cSQL += PED_FABR->Codigo + "," 
	  cSQL += dtos(PED_FABR->data_ped) + ","  
	  cSQL += null(PED_FABR->cod_forn) + ","
	  cSQL += quote(rtrim(left(PED_FABR->obs,50))) + eol
	  
      PED_FABR->(dbskip())  
	  
   enddo
   
   nFile := fcreate(cPath + "pedido_china.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return

static function itens_china
local cSQL := ""
local nLastRec := 0
local cLast := ""
local lDuplicado := .F.
local nFile := 0
local nCont := 1

   ITEN_PED->(dbgotop())
   do while ! ITEN_PED->(eof())
      
	  cSQL += alltrim(str(nCont)) + "," 
	  cSQL += ITEN_PED->Cod_ped + "," 
	  cSQL += ITEN_PED->Cod_prod + "," 
	  cSQL += numero0(ITEN_PED->Quantidade) + ","  
	  cSQL += numero0(0) + eol
	  
	  nCont++
	  
      ITEN_PED->(dbskip())  
	  
   enddo
   
   nFile := fcreate(cPath + "itens_china.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return

static function atualizaPrecos
local cSQL := ""
local nFile := 0
local cOBS := ""
   
   PROD->(dbsetfilter({|| right(codigo,5) != "     "}))  
   PROD->(dbsetorder(4))
   PROD->(dbgotop())
   
   PROD->(dbgotop())
   do while ! PROD->(eof())
   
      id := alltrim(str(val(right(PROD->Codigo,5))))
	  
	  cSQL += " update comercial.produtos set tipo =" +  PROD->TIPO   + " where id =" + id +";" + eol
 	  
	  PROD->(dbskip())
   enddo
   
   nFile := fcreate(cPath + "atualizaPrecos.txt",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)

return
