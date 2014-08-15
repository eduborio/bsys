/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Exportar Dados p/ Mysql
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: Julho de 2013
// OBS........:
// ALTERACOES.:

#include "inkey.ch"
#include "dbinfo.ch"
#include "error.ch"
#include "hbrddsql.ch"

function cl460

 if ! qconf("Deseja Exportar nFs pro sistema web ?")
    return .F.
  endif

  i_importa()

return


static function i_importa

   local oServer, oRow
   local oQuery
   local ncont
   
   processaNFs()
   processaEntradas()
   
return

static function processaNFs()
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   local dINI := ctod("01/07/2013")
   local dFIM := ctod("31/07/2013")
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
   local cCaminho := "c://dev//dados//"
   local cPath := "c:\dev\dados\"
   local eol        := chr(13) + chr(10)
   local nContItem :=  1
   local cQuote    := '"'
   
   
   cSQL += "delete from movimentacoes;"+eol
   cSQL += "alter table movimentacoes auto_increment = 0;"+eol
   
   cSQL += "delete from expedicoes;"+eol
   cSQL += "alter table expedicoes auto_increment = 0;"+eol
   
   cSQL += "delete from item_entrada;"+eol
   cSQL += "alter table item_entrada auto_increment = 0;"+eol
   
   cSQL += "delete from entradas;"+eol
   cSQL += "alter table entradas auto_increment = 0;"+eol
   
   cSQL += "delete from item_pedido_venda;"+eol
   cSQL += "alter table item_pedido_venda auto_increment = 0;"+eol
   
   cSQL += "delete from pedido_venda;"+eol
   cSQL += "alter table pedido_venda auto_increment = 0;"+eol
   
   cSQL += "SET foreign_key_checks = 0;"+eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '" + cCaminho + "pedido.txt' INTO TABLE pedido_venda " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" +cquote+ "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '" + cCaminho + "item_pedido.txt' INTO TABLE item_pedido_venda " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" +cquote+ "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "movimentacoes.txt' INTO TABLE movimentacoes " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "expedicoes.txt' INTO TABLE expedicoes " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "entradas.txt' INTO TABLE entradas " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "LOAD DATA LOCAL INFILE '"+ cCaminho + "item_entrada.txt' INTO TABLE item_entrada " +eol
   cSQL += "     FIELDS TERMINATED BY ',' ENCLOSED BY '" + cQuote + "' LINES TERMINATED BY '\r\n';" +eol
   cSQL += "SHOW WARNINGS LIMIT 10;" +eol+eol
   
   cSQL += "SET foreign_key_checks = 1;"+eol+eol
   
   nFile := fcreate("c:\Borius\vendas\vendas\WebContent\sqls\util\qsys2borio.sql",0)
   
   fwrite(nfile,cSQl,len(cSQL))
   
   fclose(nFile)
   
   cSQL := ""

   PROD->(dbsetorder(4))

   ITEN_FAT->(dbsetorder(2))
   
   FAT->(dbsetorder(2))
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off

   Do while ! FAT->(eof())
   
      if FAT->Dt_emissao < dINI
	  	 FAT->(dbskip())
	     loop
      endif
	  
	  if FAT->Dt_emissao > dFIM
	  	 FAT->(dbskip())
	     loop
      endif

      if empty(FAT->codigo)
         FAT->(dbskip())
	     loop
      endif
	  
	  if empty(FAT->Num_fatura)
         FAT->(dbskip())
	     loop
      endif
   
      if left(FAT->Cod_cfop,4) $ "5905-6905"
         FAT->(dbskip())
   	     loop
      endif
	  
	  if FAT->Es != "S"
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
	   
	   cSQL += quote(cOBS)+ ","
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
		  
		  cReserva += "NULL" + ","
		  cReserva += numero(nContItem) + ","
		  cReserva += numero0(ITEN_FAT->Quantidade) + ","
		  cReserva += numero(nVendaID) + ","
		  cReserva += "1" + ","    // Expedicao Sub classe
		  cReserva += "NULL" + "," // Reserva
		  cReserva += "NULL" + eol // Cancelamento

          ITEN_FAT->(dbskip())
       enddo
	   
	   cVenda += numero(nVendaID) + ","
	   cVenda += null(FAT->Cod_cli) + ","
	   cVenda += "NULL" + ","
	   cVenda += null(FAT->Cod_transp) + ","
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
	   cVenda += FAT->Num_fatura + "," //Numero da Nota
	   cVenda += "NULL" + "," //Chave
	   cVenda += "0"  + "," //EM Processamento
	   cVenda += "0"  + eol //Info Boleto
	   
       FAT->(Dbskip())
    enddo
	
   nFile := fcreate(cPath + "pedido.txt",0)
    
   fwrite(nfile,cSQL,len(cSQL))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "item_pedido.txt",0)
    
   fwrite(nfile,cItem,len(cItem))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "movimentacoes.txt",0)
    
   fwrite(nfile,cReserva,len(cReserva))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "expedicoes.txt",0)
    
   fwrite(nfile,cVenda,len(cVenda))
   
   fclose(nFile)
    
return

static function processaEntradas()
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   local dINI := ctod("01/07/2013")
   local dFIM := ctod("31/07/2013")
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
   local cCaminho := "c://dev//dados//"
   local cPath := "c:\dev\dados\"
   local eol        := chr(13) + chr(10)
   local nContItem :=  1
   local cQuote    := '"'
   
   cSQL  := ""
   cItem := ""

   PROD->(dbsetorder(4))

   ITEN_FAT->(dbsetorder(2))
   
   FAT->(dbsetorder(2))
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off

   Do while ! FAT->(eof())
   
      if FAT->Dt_emissao < dINI
	  	 FAT->(dbskip())
	     loop
      endif
	  
	  if FAT->Dt_emissao > dFIM
	  	 FAT->(dbskip())
	     loop
      endif

      if empty(FAT->codigo)
         FAT->(dbskip())
	     loop
      endif
	  
	  if empty(FAT->Num_fatura)
         FAT->(dbskip())
	     loop
      endif
   
      if left(FAT->Cod_cfop,4) $ "5905-6905"
         FAT->(dbskip())
   	     loop
      endif
	  
	  if FAT->Es != "E"
	     FAT->(dbskip())
		 loop
	  endif
	  
       cSQL += FAT->Codigo + ","
	   cSQL += null(FAT->Cod_cli,lCli) + ","
	   cSQL += alltrim(FAT->cod_cfop) + ","
	   cSQL += dtos(FAT->dt_emissao) + ","
	   cOBS := iif(!empty(FAT->Obs),strReplace(rtrim(FAT->Obs))+"","")
	   cSQL += quote(cOBS)+ ","
	   cSQL += "NULL" + ","
	   cSQL += dtos(FAT->dt_emissao) + ","
	   cSQL += "NULL" + ","
	   cSQL += "NULL" + ","
	   cSQL += FAT->Num_fatura + "," 
	   cSQL += "NULL" + ","
	   cSQL += "0" + ","
	   cSQL += "0" + ","
	   cSQL += "0" + eol
	   
	   ITEN_FAT->(Dbseek(FAT->Codigo))
	   
	   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
	      cItem += "NULL" + ","
	      cItem += FAT->Codigo + ","
	      cItem += ITEN_FAT->cod_prod + ","
		  cItem += numero0(ITEN_FAT->Quantidade) + ","
		  cItem += alltrim(transf(ITEN_FAT->vl_unitar,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->ipi,"@R 9999999999.99")) + ","
		  cItem += alltrim(transf(ITEN_FAT->icms,"@R 9999999999.99")) + ","
		  cItem += "0" + ","
		  cItem += "0" + eol
	   
	      ITEN_FAT->(dbskip())   
	   enddo

       FAT->(Dbskip())
    enddo
	
   nFile := fcreate(cPath + "entradas.txt",0)
    
   fwrite(nfile,cSQL,len(cSQL))
   
   fclose(nFile)
   
   nFile := fcreate(cPath + "item_entrada.txt",0)
    
   fwrite(nfile,cItem,len(cItem))
   
   fclose(nFile)
   
return

static function quote(cField)
return iif(empty(cField),"NULL",'"'+rtrim(cField)+'"')

static function quoteSemRTrim(cField)
return iif(empty(cField),"NULL",'"'+cField+'"')

static function numero(cField)
return iif(cField == 0,"NULL",alltrim(str(cField)))

static function numero0(cField)
return alltrim(str(cField))



