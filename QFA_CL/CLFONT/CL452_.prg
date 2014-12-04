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

function cl452

 if ! qconf("Grava Icms da NFe na escrita ?")
    return .F.
  endif

  i_verifica()

return

static function abreArquivos
  
   if ! quse(XDRV_EF,"SAI",{})
	 qmensa("Nao foi possivel abrir SAI do Fiscal!","BL")
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
   local nKey := 0 
   
   
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
	cQuery += "		sum(item.valor_icms) as valor_icms, "
	cQuery += "		ifnull(sum((item.valor_unitario * item.quantidade) + item.valor_ipi + item.valor_icmsst),0) as valor_cont "
	cQuery += "	from item_nota_fiscal as item "
	cQuery += "	left join nota_fiscal as nf on nf.id = item.nota_fiscal_id "
	cQuery += "	where nf.data_emissao between '2014-02-01' and '2014-10-31' "
	cQuery += "	and nf.tipo_nota = 1 and nf.cfop_id in (5403,5102) and cancelada = 0"
	cQuery += "	group by nota_fiscal_id "
	cQuery += "	order by numero_nota "
   
    
    oQuery := oServer:Query(cQuery)
   
	if oQuery:NetErr()
	  Alert(oQuery:Error())
	endif
   
    nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      row := oQuery:getRow(nCont)
	  
	  aadd(aFiscal,{  val(get(row,'numero')) , get(row,'valor_icms') })
	  nCont++
	  
   enddo	  
   
   select SAI
   
   set softseek on
   
   SAI->(dbsetorder(2))
   SAI->(dbgotop())
   SAI->(dbseek("20140201"))
   set softseek off
   
   aFiscal := asort(aFiscal,,,{|x,y| x[1] < y[1]})
   
   do while ! SAI->(eof()) .and. SAI->Data_lanc <= ctod("31/10/2014")
   
   
        if ! SAI->Cfop $ "5403-5102"
		   SAI->(dbskip())
           loop
        endif		   
		
		nKey := ascan(aFiscal,{|ckey| cKey[1] == val(SAI->Num_nf)})
					
		if nKey > 0
			if SAI->(qrlock())
				replace SAI->Icm_vlr with aFiscal[nKey,2]
				replace SAI->Icm_red with 0
				SAI->(qunlock())
			endif
		endif	
		
		SAI->(dbskip())
   enddo
   
return

static function get(row,campo)
return  row:fieldget(campo)