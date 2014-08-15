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
   dbCloseAll()
   
return


static function verificaCanceladas(oServer)

   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   local id := 0
   
   cQuery := "SELECT nf.id, nf.cancelada from nota_fiscal as nf "
   cQuery += "where exportado_pro_qsys = 1 and nf.cancelada = 1 and nf.data_emissao between 20140101 and 20181231" 
   
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

