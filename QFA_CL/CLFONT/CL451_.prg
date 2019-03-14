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

function cl451

 if ! qconf("Deseja Realizar verificacao de dados fat/web receber e contabil ?")
    return .F.
  endif

  i_verifica()

return

static function abreArquivos
  
   if ! quse(XDRV_EF,"SAI",{})
	 qmensa("Nao foi possivel abrir SAI do Fiscal!","BL")
	 return .F.
   endif
   if ! quse(XDRV_RB,"RECEBER",{})
	 qmensa("Nao foi possivel abrir RECEBER do Ctas a Receber!","BL")
	 return .F.
   endif
   
   if ! quse(XDRV_EF,"ENT",{})
	 qmensa("Nao foi possivel abrir ENT do Fiscal!","BL")
	 return .F.
   endif
   
   if ! quse(XDRV_CL,"FAT",{})
	 qmensa("Nao foi possivel abrir FAT do comercial!","BL")
	 return .F.
   endif
   
   if ! quse(XDRV_CL,"ITEN_FAT",{})
	 qmensa("Nao foi possivel abrir ITEN_FAT do comercial!","BL")
	 return .F.
   endif

return


static function i_verifica

   local oServer, oRow
   local oQuery
   local ncont
   
   
   oServer := TMySQLServer():New(XSERVER, "root", "borios")
   if oServer:NetErr()
      Alert(oServer:Error())
   endif

   oServer:SelectDB("comercial")
   
   abreArquivos()
   verificaCanceladas(oServer)
   verificaTodasNotasFiscais(oServer)
   dbCloseAll()
   
return

static function verificaTodasNotasFiscais(oServer)

   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   local nFile := 0
   local cBuffer := 0
   local nIcmsWeb  := 0
   local nIcmsQsys := 0
   
   
   local aFiscal := {}
   
    //nFile := fcreate("c:\Qsystxt\Qsys_efd.txt",0)
	//fclose(nfile)
   
	cQuery := "	select "
	cQuery += "		item.id, "
	cQuery += "		item.nota_fiscal_id, "
	cQuery += "		nf.cfop_id as cfop, "
	cQuery += "		nf.data_emissao as data_lanc, "
	cQuery += "		sum(item.valor_unitario * item.quantidade), "
	cQuery += "		nf.numero_nota as numero, "
	cQuery += "		nf.cancelada as cancelada, "
	cQuery += "		sum(item.base_ipi) as base_ipi, "
	cQuery += "		sum(item.base_icms) as base_icms, "
	cQuery += "		sum(item.valor_icms) as valor_icms, "
	cQuery += "		sum(item.valor_ipi) as valor_ipi, "
	cQuery += "		sum(item.valor_icmsst) as valor_st, "
	cQuery += "		sum(item.base_icmsst) as base_st, "
	cQuery += "		ifnull(sum((item.valor_unitario * item.quantidade) + item.valor_ipi + item.valor_icmsst),0) as valor_cont "
	cQuery += "	from item_nota_fiscal as item "
	cQuery += "	left join nota_fiscal as nf on nf.id = item.nota_fiscal_id "
	cQuery += "	where nf.data_emissao between '2014-02-01' and '2014-10-31' "
	cQuery += "	and nf.tipo_nota = 1 and nf.cfop_id in (5403,5102) and nf.empresa_id in (1,2) "
	cQuery += "	group by nota_fiscal_id "
	cQuery += "	order by numero_nota "
   
    
    oQuery := oServer:Query(cQuery)
   
	if oQuery:NetErr()
	  Alert(oQuery:Error())
	endif
   
    nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  
	  aadd(aFiscal,{  val( get(row,'numero') ) ,;
	                  get(row,'base_icms')  , ;
                      get(row,'valor_icms')	, ;
					  get(row,'base_ipi')   , ;
					  get(row,'valor_ipi')  , ;
                      get(row,'base_st')	, ;
					  get(row,'valor_st')	, ;
					  get(row,'valor_cont') , ;
					  "NFE"  , ;
					  iif(get(row,'valor_st') > 0,"5403",strzero(get(row,'cfop'),4)) ,;
					  get(row,'data_lanc'),;
					  get(row,'cancelada')    })
	  nCont++
	  
   enddo	  
   
   select SAI
   
   set softseek on
   
   SAI->(dbsetorder(2))
   SAI->(dbgotop())
   SAI->(dbseek("20140201"))
   set softseek off
   
   do while ! SAI->(eof()) .and. SAI->Data_lanc <= ctod("31/10/2014")
   
   
        if ! SAI->Cfop $ "5403-5102"
		   SAI->(dbskip())
           loop
        endif		   
   
		aadd(aFiscal,{ val(  SAI->Num_nf  ) , ;
	                  SAI->Icm_base  , ;
                      SAI->Icm_vlr	, ;
					  SAI->Ipi_base   , ;
					  SAI->Ipi_vlr  , ;
                      SAI->Icm_bc_s	, ;
					  SAI->Icm_subst	, ;
					  SAI->Vlr_cont , ;
					  "LIVRO" , ;
					  SAI->Cfop , ;
					  SAI->Data_lanc, ;
					  0})
		
		SAI->(dbskip())
   enddo
   
   aFiscal := asort(aFiscal,,,{|x,y| x[1] < y[1]})
   
   nFile := fcreate("c:\Qsystxt\test.java",0)
   
   nCont := 1
   
   cBuffer := "Numero" + chr(9) + "Data emissao" + chr(9) + "Valor Contabil" + chr(9) + "Base Icms" + chr(9) + "Valor Icms" + chr(9) + "Base Ipi" + chr(9)+"Valor ipi" + chr(9) + "Base ST" + chr(9) + "valor ST" + chr(9) + "SYS" + chr(13) + chr(10)
   
   for nCont := 1 to len(aFiscal)
		
		cBuffer += strzero(aFiscal[nCont,1],6) + chr(9)
		cBuffer += dtoc(aFiscal[nCont,11]) + chr(9)
		cBuffer += alltrim(transform(aFiscal[nCont,8],"@E 999999999.99")) + chr(9)
		cBuffer += alltrim(transform(aFiscal[nCont,2],"@E 999999999.99")) + chr(9)
		cBuffer += alltrim(transform(aFiscal[nCont,3],"@E 999999999.99")) + chr(9)
		cBuffer += alltrim(transform(aFiscal[nCont,4],"@E 999999999.99")) + chr(9)
		cBuffer += alltrim(transform(aFiscal[nCont,5],"@E 999999999.99")) + chr(9)
		cBuffer += alltrim(transform(aFiscal[nCont,6],"@E 999999999.99")) + chr(9)
		cBuffer += alltrim(transform(aFiscal[nCont,7],"@E 999999999.99")) + chr(9)
		cBuffer += aFiscal[nCont,10] + chr(9)
		cBuffer += aFiscal[nCont,9] + chr(9)
		
		if aFiscal[nCont,9] == "NFE"
			cBuffer += iif(aFiscal[nCont,12] == 1,"Cancelada","") + chr(13) +chr(10)
		else
			cBuffer += iif(aFiscal[nCont,8]  == 0, "Cancelada","") + chr(13) +chr(10)
		endif
		
		if aFiscal[nCont,9] == "NFE"
		   if aFiscal[nCont,12] == 0
				nIcmsWeb += aFiscal[nCont,3]
		   endif		
		endif
		
		if aFiscal[nCont,9] == "LIVRO"
		   nIcmsQsys += aFiscal[nCont,3]
		endif
		
		if mod(nCont,2) == 0
		   cBuffer += chr(13) + chr(10)
		endif   
		
   next
   
   cBuffer += chr(13) + chr(10)
   cBuffer += chr(13) + chr(10)
   cBuffer += chr(9) + chr(9) + "Icms Livro" + chr(9) +alltrim(transform(nIcmsQsys,"@E 9999999999999.99")) + chr(13) + chr(10)
   cBuffer += chr(9) + chr(9) + "Icms NFes"  + chr(9) +alltrim(transform(nIcmsWeb,"@E 9999999999999.99")) + chr(13) + chr(10)
   cBuffer += chr(9) + chr(9) + "Diferença" +chr(9)  + chr(9)+alltrim(transform(nIcmsWeb-nIcmsQsys,"@E 9999999999999.99"))

   fwrite(nFile,cBuffer,len(cBuffer))   
   fclose(nfile)

return


static function verificaCanceladas(oServer)

   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   cQuery := "SELECT nf.id, nf.cancelada from nota_fiscal as nf "
   cQuery += "where exportado_pro_qsys = 1 and nf.cancelada = 1 and nf.data_emissao between 20140101 and 20221231 and nf.empresa_id in (1,2) " 
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   FAT->(dbsetorder(4))
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  
	  if FAT->(dbseek(get(row,'id')))
		
		if (!FAT->Cancelado)
		   alert("NotFiscal irregular encontrada no Faturamento!! - "+FAT->Codigo + " NF.: " + FAT->Num_fatura)
		endif
		
		if(FAT->Es == "S")
			SAI->(dbsetorder(4))
			if SAI->(dbseek(FAT->Num_fatura + "55"))
			
			   if SAI->Vlr_cont > 0
				 alert("NotFiscal de Saida deveria estar cancelada no Fiscal!! - NF.: " + SAI->Num_nf) 
			   endif	 
			endif
	    endif
		
		if(FAT->Es == "E")
			ENT->(dbsetorder(10))
			if ENT->(dbseek(FAT->Num_fatura + left(FAT->Cod_cfop,4) ))
				if ENT->Vlr_cont > 0 
				   alert("NotFiscal de entrada deveria estar cancelada!! - NF.: " + ENT->Num_nf) 
				endif   
			endif
	    endif
	  endif	
	  
	  nCont++

   enddo 

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


static function verificaEntradas
local cEFD := ""
local nTotal_prod := 0
local cModelo := ""
local cCFOPS := "13-23-31"


         ENT->(dbclearfilter())
		 ENT->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM .and. (!left(cfop,2) $ cCfops)})) // nao puxar fretes e importação
         ENT->(dbsetorder(2))
         ENT->(dbgotop())


         do while ! ENT->(Eof())
		 
		 
            if empty(ENT->Modelo)
               cModelo := "55"
			else
               cModelo := ENT->Modelo			
            endif
			

            if ! FAT->(dbseek(ENT->Num_nf+cModelo))
			   alert("Nao tem no faturamento essa NFe.: "+ENT->Num_nf)
               ENT->(dbskip())
               loop
            endif
			
			
			if ENT->Vlr_cont > 0 .and. FAT->Cancelado
			   alert("NF cancelada no FAT, mas nao na Escrita" + ENT->Num_nf)
			endif

            if ! FAT->Cancelado

                nTotal_prod := 0

            //    ITEN_FAT->(dbseek(FAT->Codigo))
            //    Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
            //       nTotal_prod += ITEN_FAT->quantidade * ITEN_FAT->vl_unitar
            //       ITEN_FAT->(dbskip())
            //   enddo
            endif

            ENT->(dbskip())

         enddo

return

