/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE Escrita Fiscal
// OBJETIVO...: Exportar arquivo p/ SPED Fiscal
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO 2011
// OBS........:
// ALTERACOES.:

function ef480

#define K_MAX_LIN 57
#include "fileio.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cDRIVE  := space(2)
private nTOT_LIN := 0

private nTOT_0000 := 0
private nTOT_0001 := 0
private nTOT_0100 := 0
private nTOT_0110 := 0
private nTOT_0140 := 0
private nTOT_0150 := 0
private nTOT_0190 := 0
private nTOT_0200 := 0
private nTOT_0400 := 0
private nTOT_0990 := 0
private nTOT_9 := 0
private nTOT_9900 := 0
private nTOT_C    := 0
private nTOT_D    := 0
private nTOT_E    := 0
private nTOT_G    := 0
private nTOT_H    := 0
private nTOT_1    := 0
private nTOT_C100 := 0
private nTOT_C120 := 0
private nTOT_C170 := 0
private nTOT_D100 := 0
private nTOT_D010 := 0
private nTOT_D101 := 0
private nTOT_D105 := 0
private aDados := {}


private nFile   := 0
private cBuffer := ""


private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma Exportacao de Arquivo SPED Contribuicoes ?") },NIL})

do while .T.

   qlbloc(5,0,"B470A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI    := ctod("")
   dFIM    := ctod("")
   cDRIVE := ""

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_sped() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "INI"
           dFIM := qfimmes(dINI)
           qrsay(XNIVEL+1,dtoc(dFIM))

      case cCAMPO == "FIM"
           if dFIM < dINI
             qmensa("Data Final nÆo pode ser Inferior a Data Inicial !","B")
             return .F.
             qmensa("")
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := ""

   qmensa("")

return .T.


static function i_sped
local cEFD := ""
      nFile := fcreate("c:\Qsystxt\Qsys-Sped-Contribuicoes.txt",0)
      open_files()
      aDados := produtosNf()

      i_registro_0000(nFILE)

      i_registro_0001(nFile)    //Abertura do bloco 0
     		  
	  i_registro_0100(nFile) //Dados do Contabilista
	  
	  i_registro_0110(nFile) //Regime de incidencia
	  
	  i_registro_0140(nFile) //Estabelecimentos da Empresa
    	  
	  i_registro_0150(nFile)
      i_registro_0190(nFile)
      i_registro_0200(nFile,aDados)
//      i_registro_0400(nFile,aDados[2])
      i_registro_0990(nFile)    //Fecha Bloco 0

      i_registro_C001(nFile)    //Abre Bloco C
	  i_registro_C010(nFile)
      i_registro_C100(nFile)
      i_registro_C990(nFile)

      i_registro_D001(nFile)    //Abre Bloco D
      i_registro_D010(nFile)    
  	  i_registro_D100(nFile)
      i_registro_D990(nFile)
  
      i_registro_F001(nFile)
      i_registro_F990(nFile)
	  
	  i_registro_M001(nFile)
      i_registro_M990(nFile)
	  
	  i_registro_1001(nFile)
      i_registro_1990(nFile)
	  
	  i_registro_9001(nFile)
	  i_registro_9900(nFile)
	  i_registro_9990(nFile)
	  i_registro_9999(nFile)


      FAT->(dbclosearea())
      ITEN_FAT->(dbclosearea())
      DUP_FAT->(dbclosearea())

      CLASSIF->(dbclosearea())
      PROD->(dbclosearea())
	  
	  IMPORT->(dbclosearea())
      ITEN_IMP->(dbclosearea())
	  
	  

      fclose(nFile)
return


static function i_registro_0000(nFile)
local cEFD := ""

      cEFD := "|0000"
      cEFD += "|003"
      cEFD += "|0"
	  cEFD += "|" // Indicador de Situacao esp
	  cEFD += "|" //No do Recibo de for retificadora
      cEFD += "|"+dtoSped(dINI)
      cEFD += "|"+dtoSped(dFIM)
      cEFD += "|"+rtrim(FILIAL->Razao)
      cEFD += "|"+FILIAL->Cgccpf

      CGM->(dbseek(FILIAL->Cgm))

      cEFD += "|"+rtrim(Cgm->Estado)
      cEFD += "|"+getMunicipioId(CGM->Cod_rais,CGM->Municipio)
      cEFD += "|" //Suframa
      cEFD += "|00" //PEssoa Juridica
      cEFD += "|0" //Tipo de atividade preponderante 2 - Comercio
      cEFD += "|"+chr(13)+chr(10)
      nTot_lin++
      nTot_0000++
	  
      fwrite(nFile,cEFD,len(cEFD))

return

static function i_registro_0001(nFile)
local cEFD := ""

      cEFD := "|0001"
      cEFD += "|0|"+chr(13)+chr(10)
      nTot_lin++
      nTot_0000++
	  nTot_0001++

      fwrite(nFile,cEFD,len(cEFD))

return



static function i_registro_0100(nFile)
local cEFD := ""

      cEFD := "|0100"
      cEFD += "|"+rtrim(FILIAL->Contador)
      cEFD += "|"+rtrim(FILIAL->Cpf_Contad)
      cEFD += "|"+rtrim(qtiraponto(FILIAL->Crc))
      cEFD += "|"+rtrim(FILIAL->Cnpj_cont)
      cEFD += "|"+FILIAL->Cep_cont
      cEFD += "|"+rtrim(FILIAL->End_cont)
      cEFD += "|"+rtrim(FILIAL->num_cont)
      cEFD += "|"+rtrim(FILIAL->compl_cont)
      cEFD += "|"+rtrim(FILIAL->bair_cont)
      cEFD += "|41"+rtrim(FILIAL->fone_cont)
      cEFD += "|41"+rtrim(FILIAL->fax_cont)
      cEFD += "|"+rtrim(FILIAL->email_cont)
      CGM->(dbseek(FILIAL->Cgm_cont))
      cEFD += "|"+getMunicipioId(CGM->cod_rais,CGM->Municipio)
      cEFD += "|"+chr(13)+chr(10)
      nTot_lin++
      nTot_0000++
	  nTot_0100++

      fwrite(nFile,cEFD,len(cEFD))

return

static function i_registro_0110(nFile)
local cEFD := ""

      cEFD := "|0110"
	  cEFD += "|"+"1" // Somente cumulativo
	  cEFD += "|"+"1"  //Somente para não cumulativo
	  cEFD += "|"+"1" // Somente aliq basica
	  cEFD += "|"+"" // 9 - detalahado  2 - consolidado
      cEFD += "|"+chr(13)+chr(10)
      nTot_lin++
      nTot_0000++
	  nTot_0110++

      fwrite(nFile,cEFD,len(cEFD))

return

static function i_registro_0140(nFile)
local cEFD := ""

      cEFD := "|0140"
      cEFD += "|"+"0001"
      cEFD += "|"+FILIAL->Razao
	  cEFD += "|"+FILIAL->Cgccpf
      cEFD += "|"+"PR"
      cEFD += "|"+rtrim(qtiraponto(FILIAL->Insc_estad))
      cEFD += "|"+"4106902"
      cEFD += "|"+"" //IMun
	  cEFD += "|"+""  //Suframa
      cEFD += "|"+chr(13)+chr(10)
      nTot_lin++
      nTot_0000++
	  nTot_0140++

      fwrite(nFile,cEFD,len(cEFD))

return


static function i_registro_0150(nFile,aCli)
local cEFD := ""
local nCONT := 0

      cadClientes()
      cadFornecedores()	  
      

return



static function i_registro_0190(nFile)
local cEFD := ""

      cEFD := "|0190"
      cEFD += "|000001"
      cEFD += "|Unidade"
      cEFD += "|"+chr(13)+chr(10)
      nTot_lin++
      nTot_0000++
	  nTot_0190++



      fwrite(nFile,cEFD,len(cEFD))

return


static function i_registro_0200(nFile,aProd)
local cEFD := ""
local nCont := 0
      PROD->(dbsetorder(4))

      for nCont := 1 to len(aPROD)

         if PROD->(dbseek(aPROD[nCONT]))


         cEFD := "|0200"
         if empty(PROD->cod_fabr) .and. empty(PROD->cod_ass)
            cEFD += "|"+alltrim(qtiraponto(right(PROD->Codigo,5)))
         else
            cEFD += "|"+alltrim(qtiraponto(PROD->Cod_fabr))
         endif
         cEFD += "|"+rtrim(PROD->Descricao)
         cEFD += "|"+alltrim(PROD->cod_barras)
         cEFD += "|"
         cEFD += "|000001"
		 if alltrim(PROD->Cod_ass) == "ComplST"
			cEFD += "|99"
		 else
			cEFD += "|00"
		 endif	
         CLASSIF->(dbseek(PROD->cod_class))
         cEFD += "|"+alltrim(qtiraponto(CLASSIF->Descricao))
         cEFD += "|"
         cEFD += "|"+alltrim(qtiraponto(left(CLASSIF->Descricao,2)))
         cEFD += "|"
         cEFD += "|18,00"
         cEFD += "|"+chr(13)+chr(10)
         fwrite(nFile,cEFD,len(cEFD))
         cEFD := ""
         nTot_lin++
         nTot_0000++
		 nTot_0200++
         endif


        next
//      PROD->(dbclosearea())
//      CLASSIF->(dbclosearea())

return


static function i_registro_0400(nFile,aTPO)
local cEFD := ""
local nCONT := 0

      for nCONT := 1 to len(aTPO)
         if TIPOCONT->(dbseek(aTPO[nCONT]))
         cEFD := "|0400"
         cEFD += "|"+alltrim(TIPOCONT->codigo)
         cEFD += "|"+rtrim(TIPOCONT->Descricao)
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""
         ntot_lin++
         nTot_0000++
		 nTot_0400++
        endif

      next

return

static function i_registro_0990(nFile)
local cEFD := ""


         ntot_lin++
         nTot_0000++

         cEFD := "|0990"
         cEFD += "|"+alltrim(str(nTOT_0000))
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return


static function i_registro_C001(nFile)
local cEFD := ""


         ntot_lin++
         nTot_C++

         cEFD := "|C001"
         cEFD += "|0"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_C010(nFile)
local cEFD := ""


         ntot_lin++
         nTot_C++

         cEFD := "|C010"
         cEFD += "|07069809000119"
         cEFD += "|2"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return


static function i_registro_C100(nFile)

    saidasNfe()
    entradasNfe()
	entradasNfeImport()
	entradasNf()
	
	
	

return

static function i_registro_C170_nfe(nFile,oServer,id)
local cEFD := ""
local nTotal_prod := 0
local cQuery := ""
local oQuery
local row
local nCont := 1
         
		 cQuery := "    SELECT prod.referencia_brasil as referencia  , "
		 cQuery += " 		   prod.descricao as descricao,	"
		 cQuery += " 		   nf.cfop_id as cfop,	"
		 cQuery += "			   item.*, "
		 cQuery += "			   item.base_icms     as base_icms,	 "
		 cQuery += "			   item.aliquota_icms as aliquota_icms,	 "
		 cQuery += "			   item.valor_icms as valor_icms,	 "
		 cQuery += "			   item.base_ipi     as base_ipi,	 "
		 cQuery += "			   item.aliquota_ipi as aliquota_ipi,	 "
		 cQuery += "			   item.valor_ipi as valor_ipi,	 "
		 cQuery += "			   item.base_pis     as base_pis,	 "
		 cQuery += "			   item.aliquota_pis as aliquota_pis,	 "
		 cQuery += "			   item.base_cofins     as base_cofins,	 "
		 cQuery += "			   item.aliquota_cofins as aliquota_cofins,	 "
		 cQuery += "			   item.valor_icmsst as valor_st,	 "
		 cQuery += "			   round(item.quantidade * item.valor_unitario,2) as valor_produtos	 "
		 cQuery += "		FROM item_nota_fiscal item "
		 cQuery += "		JOIN nota_fiscal nf on nf.id = item.nota_fiscal_id "
		 cQuery += "		join produtos prod on prod.id = item.produto_id "
		 cQuery += " where item.nota_fiscal_id =" + alltrim(str(id)) 

         oQuery := oServer:Query(cQuery)
   
		 if oQuery:NetErr()
		    Alert(oQuery:Error())
		 endif
		   
		 nCont := 1
		   
		 do while nCont <= oQuery:LastRec() 	 
		    row := oQuery:getRow(nCont)

            cEFD := "|C170"
            cEFD += "|"+strzero(nCont,3)
            cEFD += "|"+alltrim(get(row,'referencia'))
            cEFD += "|"+rtrim(get(row,'descricao'))
            cEFD += "|"+alltrim(transform(get(row,'quantidade'),"@R 999999999"))
            cEFD += "|000001"
            cEFD += "|"+alltrim(transform(get(row,'valor_produtos'),"@E 99999999999.99"))
            cEFD += "|" // Desconto
            cEFD += "|0"
            cEFD += "|100"
            cEFD += "|"+alltrim(str(get(row,'cfop')))
            cEFD += "|"
            cEFD += "|"+alltrim(transform(get(row,'base_icms'),"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(get(row,'aliquota_icms'),"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(get(row,'valor_icms') ,"@E 9999999999.99"))
            cEFD += "|"
            cEFD += "|"
            cEFD += "|"
            cEFD += "|0"
            cEFD += "|00"//+right(ITEN_FAT->cod_sit,2)
            cEFD += "|"
            cEFD += "|"+alltrim(transform(get(row,'base_ipi'),"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(get(row,'aliquota_ipi'),"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(get(row,'valor_ipi'),"@E 9999999999.99"))
			
			if alltrim(str(get(row,'cfop'))) $ "1910-2910-2202-1202-2411-1411"
				cEFD += "|"+"50" // CST PIS
				nBasePis := (get(row,'base_pis') - get(row,'valor_st')) 
				nValorPis := nBasePis * (get(row,'aliquota_pis')/100)
				nValorCofins := nBasePis * (get(row,'aliquota_cofins')/100)
				cEFD += "|"+alltrim(transform(nBasePis,"@E 9999999999.99")) // Base do Pis
				cEFD += "|"+alltrim(transform(get(row,'aliquota_pis'),"@E 9999999999.99")) //  aliq do Pis
				cEFD += "|"
				cEFD += "|"
				cEFD += "|"+alltrim(transform(nValorPis,"@E 9999999999.99")) // Vlr do Pis
				
				cEFD += "|"+"50" // CST COFINS
				cEFD += "|"+alltrim(transform(nBasePis,"@E 9999999999.99")) // Base do Cofins
				cEFD += "|"+alltrim(transform(get(row,'aliquota_cofins'),"@E 9999999999.99")) //  aliq do Cofins
				cEFD += "|"
				cEFD += "|"
				cEFD += "|"+alltrim(transform(nValorCofins,"@E 9999999999.99")) // Vlr do Cofins
			else	
				cEFD += "|"+"98" // CST PIS
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) // Base do Pis
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) //  aliq do Pis
				cEFD += "|"
				cEFD += "|"
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) // Vlr do Pis
				cEFD += "|98" // CST COFINS
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) // Base do Cofins
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) //  aliq do Cofins
				cEFD += "|"
				cEFD += "|"
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) // Vlr do Cofins
			endif
			

            cEFD += "|"
            cEFD += "|"+chr(13)+chr(10)

            fwrite(nFile,cEFD,len(cEFD))
            ntot_lin++
            nTot_C++
            nTot_C170++
            nCONT++

         enddo


		 oServer:close()
         cEFD := ""

return

static function i_registro_C170(nFile)
local cEFD := ""
local nTotal_prod := 0
local nCont := 1
         
		 
		 PROD->(dbsetorder(4))

         ITEN_FAT->(dbseek(FAT->Codigo))
         do while ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

            PROD->(dbseek(ITEN_FAT->(cod_prod)))

            cEFD := "|C170"
            cEFD += "|"+strzero(nCont,3)
            cEFD += "|"+alltrim(qtiraponto(PROD->Cod_fabr))
            cEFD += "|"+rtrim(PROD->Descricao)
            cEFD += "|"+alltrim(transform(ITEN_FAT->Quantidade,"@R 999999999"))
            cEFD += "|000001"
            cEFD += "|"+alltrim(transform(ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar,"@E 99999999999.99"))
            cEFD += "|" // Desconto
            cEFD += "|0"
            cEFD += "|100"//+ITEN_FAT->cod_sit
            cEFD += "|"+alltrim(FAT->cod_cfop)
            cEFD += "|"//+alltrim(FAT->Tiposub)

            nICM_BASE := 0
            nIPI_BASE := 0
            nICM_VLR  := 0
            nIPI_VLR  := 0
            nICM_ALIQ := 0
            nIPI_ALIQ := 0
			nCONTR_BASE:= 0
			
			nCONTR_BASE := (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)

            if PROD->ipi > 0 .and. ITEN_FAT->ICMS > 0

               
               nICM_BASE := (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
               nIPI_BASE := (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
               nICM_VLR  := ((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Icms/100))
               nIPI_VLR  := ((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (PROD->Ipi/100))
               nICM_ALIQ := ITEN_FAT->Icms
               nIPI_ALIQ := PROD->Ipi

            endif
			
			iif(ENT->Icm_base == 0,nICM_BASE := 0,)
			iif(ENT->Icm_aliq == 0,nICM_ALIQ := 0,)
			iif(ENT->Icm_vlr  == 0,nICM_Vlr  := 0,)
			
			iif(ENT->Ipi_base == 0,nIPI_BASE := 0,)
			iif(ENT->Ipi_vlr  == 0,nIPI_ALIQ := 0,)
			iif(ENT->Ipi_vlr  == 0,nIPI_Vlr  := 0,)
			
            cEFD += "|"+alltrim(transform(nICM_BASE,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(nICM_ALIQ,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(nICM_Vlr,"@E 9999999999.99"))
            cEFD += "|"
            cEFD += "|"
            cEFD += "|"
            cEFD += "|0"
            cEFD += "|00"//+right(ITEN_FAT->cod_sit,2)
            cEFD += "|"
            cEFD += "|"+alltrim(transform(nIPI_BASE,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(nIPI_ALIQ,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(nIPI_Vlr,"@E 9999999999.99"))
			
			if left(FAT->Cod_Cfop,4) $ "1910-2910-5910-6910-5102-6102-2202-1202-2411-1411-5403-6403-5110-6110"
			
				cEFD += "|"+iif(FAT->ES=="S","01","50") // CST PIS
				cEFD += "|"+alltrim(transform(nCONTR_BASE,"@E 9999999999.99")) // Base do Pis
				cEFD += "|"+alltrim(transform(1.65,"@E 9999999999.99")) //  aliq do Pis
				cEFD += "|"
				cEFD += "|"
				cEFD += "|"+alltrim(transform((nCONTR_BASE * 0.0165),"@E 9999999999.99")) // Vlr do Pis
				cEFD += "|"+iif(FAT->ES=="S","01","50") // CST COFINS
				cEFD += "|"+alltrim(transform(nCONTR_BASE,"@E 9999999999.99")) // Base do Cofins
				cEFD += "|"+alltrim(transform(7.60,"@E 9999999999.99")) //  aliq do Cofins
				cEFD += "|"
				cEFD += "|"
				cEFD += "|"+alltrim(transform((nCONTR_BASE * 0.076),"@E 9999999999.99")) // Vlr do Cofins
			else
				cEFD += "|"+iif(FAT->ES=="S","49","98") // CST PIS
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) // Base do Pis
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) //  aliq do Pis
				cEFD += "|"
				cEFD += "|"
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) // Vlr do Pis
				cEFD += "|"+iif(FAT->ES=="S","49","98") // CST COFINS
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) // Base do Cofins
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) //  aliq do Cofins
				cEFD += "|"
				cEFD += "|"
				cEFD += "|"+alltrim(transform(0,"@E 9999999999.99")) // Vlr do Cofins

			endif	
            cEFD += "|"
            cEFD += "|"+chr(13)+chr(10)

            fwrite(nFile,cEFD,len(cEFD))
            ntot_lin++
            nTot_C++
            nTot_C170++
            nCONT++

            ITEN_FAT->(dbskip())

         enddo


         cEFD := ""


return

static function i_registro_C190_Entradas(nFile)
local cEFD := ""
local nTotal_prod := 0

            
            cEFD := "|C190"
            cEFD += "|100"
            cEFD += "|"+alltrim(ENT->cfop)
            cEFD += "|"+alltrim(transform(ENT->Icm_aliq,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(ENT->icm_base,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(ENT->icm_vlr,"@E 9999999999.99"))
            cEFD += "|0,00"
            cEFD += "|0,00"
            cEFD += "|0,00"
            cEFD += "|"+alltrim(transform(ENT->ipi_vlr,"@E 9999999999.99"))
            cEFD += "|"
            cEFD += "|"+chr(13)+chr(10)

            fwrite(nFile,cEFD,len(cEFD))
            ntot_lin++
            nTot_C++


            cEFD := ""


return

static function i_registro_C190_Saidas(nFile)
local cEFD := ""
local nTotal_prod := 0

            

            cEFD := "|C190"
            cEFD += "|100"
            cEFD += "|"+alltrim(SAI->cfop)
            cEFD += "|"+alltrim(transform(SAI->Icm_aliq,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(SAI->Vlr_cont,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(SAI->icm_base,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(SAI->icm_vlr,"@E 9999999999.99"))
            cEFD += "|0,00"
            cEFD += "|0,00"
            cEFD += "|0,00"
            cEFD += "|"+alltrim(transform(SAI->ipi_vlr,"@E 9999999999.99"))
            cEFD += "|"
            cEFD += "|"+chr(13)+chr(10)

            fwrite(nFile,cEFD,len(cEFD))
            ntot_lin++
            nTot_C++


            cEFD := ""


return




static function i_registro_C990(nFile)
local cEFD := ""


         ntot_lin++
         nTot_C++

         cEFD := "|C990"
         cEFD += "|"+alltrim(str(nTOT_C))
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_D001(nFile)
local cEFD := ""


         ntot_lin++
         nTot_D++

         cEFD := "|D001"
         cEFD += "|0"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_D010(nFile)
local cEFD := ""


         ntot_lin++
         nTot_D++

         cEFD := "|D010"
         cEFD += "|"+FILIAL->Cgccpf
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_D100(nFile)

    entradasFrete()


return


static function i_registro_D190(nFile)
local cEFD := ""
local nTotal_prod := 0

            
            cEFD := "|D190"
            cEFD += "|000"
            cEFD += "|"+alltrim(ENT->cfop)
            cEFD += "|"+alltrim(transform(ENT->Icm_aliq,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(ENT->icm_base,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(ENT->icm_vlr,"@E 9999999999.99"))
            cEFD += "|0,00"
            cEFD += "|"
            cEFD += "|"+chr(13)+chr(10)

            fwrite(nFile,cEFD,len(cEFD))
            ntot_lin++
            nTot_D++


            cEFD := ""


return


static function i_registro_D990(nFile)
local cEFD := ""


         ntot_lin++
         nTot_D++

         cEFD := "|D990"
         cEFD += "|"+alltrim(str(nTOT_D))
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return


static function i_registro_M001(nFile)
local cEFD := ""


         ntot_lin++

         cEFD := "|M001"
         cEFD += "|1"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_M990(nFile)
local cEFD := ""


         ntot_lin++

         cEFD := "|M990"
         cEFD += "|2"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_F001(nFile)
local cEFD := ""


         ntot_lin++

         cEFD := "|F001"
         cEFD += "|1"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_F990(nFile)
local cEFD := ""


         ntot_lin++

         cEFD := "|F990"
         cEFD += "|2"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_1001(nFile)
local cEFD := ""


         ntot_lin++

         cEFD := "|1001"
         cEFD += "|1"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_1990(nFile)
local cEFD := ""


         ntot_lin++

         cEFD := "|1990"
         cEFD += "|2"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function cadClientes
local cEFD := ""
local nCONT := 0

      FAT->(dbclearfilter())
      FAT->(dbsetfilter({|| ES == "S" .and. dt_emissao >= dINI .and. dt_emissao <= dFIM .and. !empty(NFe) .and. !Cancelado} ))
      FAT->(dbsetorder(6))
      FAT->(dbgotop())

      CLI1->(dbsetorder(1))
      CLI1->(dbgotop())

      do while ! CLI1->(eof())

         if ! FAT->(dbseek(CLI1->Codigo))
            CLI1->(dbskip())
            cEFD := ""
            loop
         endif
		 	 
		 cEFD := "|0150"
         cEFD += "|C"+CLI1->Codigo
         cEFD += "|"+rtrim(CLI1->Razao)
         cEFD += "|1058"

         if len(alltrim(CLI1->Cgccpf)) == 14
            cEFD += "|"+alltrim(CLI1->cgccpf)
            cEFD += "|"
         else
            cEFD += "|"
            cEFD += "|"+alltrim(CLI1->cgccpf)
         endif
         if alltrim(CLI1->Inscricao) == "ISENTO"
            cEFD += "|"
         else
            cEFD += "|"+alltrim(qtiraponto(CLI1->Inscricao))
         endif

         CGM->(dbseek(CLI1->Cgm_ent))
         cEFD += "|"+getMunicipioId(CGM->Cod_rais,CGM->Municipio)
         cEFD += "|"
         cEFD += "|"+rtrim(CLI1->End_ent)
         cEFD += "|"+alltrim(CLI1->numero)
         cEFD += "|"+rtrim(qtiraponto(CLI1->compl))
         cEFD += "|"+rtrim(qtiraponto(CLI1->Bairro_ent))
         cEFD += "|"+chr(13)+chr(10)
         nTot_lin++
         nTot_0000++
		 nTot_0150++
         fwrite(nFile,cEFD,len(cEFD))
         cEFD := ""

         CLI1->(dbskip())

     enddo




return


static function cadFornecedores
local cEFD := ""
local nCONT := 0
local aForn := {}
local cCNPJ := ""

    aForn := selectForns() 

    for nCont := 1 to len(aForn)
        
         FORN->(dbseek(aForn[nCont]))		
          	 
		 cEFD := "|0150"
         cEFD += "|F"+Forn->Codigo
         cEFD += "|"+rtrim(FORN->Razao)
		 
		 CGM->(dbseek(FORN->Cgm_ent))
		 if FORN->Cgccpf == "00000000000000" .and. CGM->Estado == "EX"
		    cCNPJ := " "
            cEFD += "|1600"
		 else
		    cCNPJ := FORN->Cgccpf
            cEFD += "|1058"
         endif		 

         if len(alltrim(FORN->Cgccpf)) == 14
            cEFD += "|"+alltrim(cCNPJ)
            cEFD += "|"
         else
            cEFD += "|"
            cEFD += "|"+alltrim(FORN->cgccpf)
         endif
         if alltrim(FORN->Inscricao) == "ISENTO"
            cEFD += "|"
         else
            cEFD += "|"+alltrim(qtiraponto(FORN->Inscricao))
         endif

         //CGM->(dbseek(FORN->Cgm_ent))
         cEFD += "|"+getMunicipioId(CGM->Cod_rais,CGM->Municipio)
         cEFD += "|"
         cEFD += "|"+rtrim(FORN->End_ent)
         cEFD += "|"+alltrim(FORN->numero)
         cEFD += "|"+rtrim(qtiraponto(FORN->compl))
         cEFD += "|"+rtrim(qtiraponto(FORN->Bairro_ent))
         cEFD += "|"+chr(13)+chr(10)
         nTot_lin++
         nTot_0000++
		 nTot_0150++
         fwrite(nFile,cEFD,len(cEFD))
         cEFD := ""
    next




return

static function dtosped(dData)
local cData := ""

      cData := strzero(day(dData),2)
      cData += strzero(month(dData),2)
      cData += strzero(year(dData),4)

return cData

static function getMunicipioId(cCodIbge,cMunic)
local cCodMunic := ""
   if ! empty(cCodIbge)
      MUNIC->(dbsetorder(1))
      if MUNIC->(dbseek(cCodIbge))
         cCodMunic := MUNIC->Codigo
      endif
   else
      MUNIC->(dbsetorder(2))
     if MUNIC->(dbseek(rtrim(cMunic)))
        cCodMunic := MUNIC->Codigo
     endif
   endif
        
return  cCodMunic

static function open_files

      if ! quse(XDRV_CP,"PROD",{""})
         qmensa("Nao foi possivel abrir Prod.dbf","BL")
         return .F.
      endif

      if ! quse(XDRV_CL,"CLASSIF",{""})
         qmensa("Nao foi possivel abrir Classif.dbf","BL")
         return .F.
      endif

      if ! quse(XDRV_CL,"FAT",{""})
         qmensa("Nao foi possivel abrir Fat.dbf","BL")
         return .F.
      endif
	  
	  if ! quse(XDRV_CP,"IMPORT",{""})
         qmensa("Nao foi possivel abrir Import.dbf","BL")
         return .F.
      endif

      if ! quse(XDRV_CL,"ITEN_FAT",{""})
         qmensa("Nao foi possivel abrir item Fat.dbf","BL")
         return .F.
      endif
	  
	  if ! quse(XDRV_CP,"ITEN_IMP",{""})
         qmensa("Nao foi possivel abrir item Import.dbf","BL")
         return .F.
      endif


      if ! quse(XDRV_CL,"DUP_FAT",{""})
         qmensa("Nao foi possivel abrir dup Fat.dbf","BL")
         return .F.
      endif


      if ! quse(XDRV_CT,"TIPOCONT",{""})
         qmensa("Nao foi possivel abrir tipocont.dbf","BL")
         return .F.
      endif

return

static function selectForns
local aForn := {}
local aRet := {}
local cForn := ""
local nCont := 0

    ENT->(dbclearfilter()) 
    ENT->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM}))
    ENT->(dbsetorder(2))
    ENT->(dbgotop())
	
    do while ! ENT->(eof())
	   aadd(aForn,ENT->Cod_forn)
	   ENT->(dbskip())
	enddo
	
	aForn := asort(aForn,,,{|x,y| x < y})

    cForn := aForn[1]

    nCONT := 1
    do while  nCONT <= len(aForn)


       nCONT++
       if nCONT > len(aForn)
          nCONT := len(aForn)
          exit
       endif

       if aForn[nCONT] != cForn
          aadd(aRet,cForn)
          cForn := aForn[nCONT]
       endif


    enddo

    aadd(aRet,cForn)


return aRet


static function getDados
local aPROD := aCLI := aTPO := aDados := {}
local aPROD2 := aCLI2 := aTPO2 := {}
local cCli  := ""
local cTPo  := ""
local cProd := ""
local nCont := 0



	 FAT->(dbclearfilter())
     FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. dt_emissao <= dFIM .and. ES == "E" .and. empty(NFe) }))
     FAT->(dbsetorder(2))
     FAT->(Dbgotop())

     aCLI := {}
     aTPO := {}
     aPROD := {}


     do while ! FAT->(eof())


        aadd(aCLI,FAT->Cod_cli)
        aadd(aTPO,FAT->Tiposub)


        ITEN_FAT->(dbseek(FAT->Codigo))
        do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->num_fat == FAT->Codigo

           aadd(aPROD,ITEN_FAT->Cod_prod)


           ITEN_FAT->(dbskip())
        enddo


        FAT->(dbskip())


     enddo

     aCLI := asort(aCLI,,,{|x,y| x < y})

     cCLI := aCli[1]

     nCONT := 1
     do while  nCONT <= len(aCLI)


        nCONT++
        if nCONT > len(aCLI)
           nCONT := len(aCLI)
           exit
        endif

        if aCLI[nCONT] != cCLI
           aadd(aCLI2,cCLI)
           cCLI := aCLI[nCONT]
        endif


     enddo

     aadd(aCLI2,cCLI)



     aTPO := asort(aTPO)

     cTPO := aTPO[1]

     nCONT := 1
     do while  nCONT <= len(aTPO)


        nCONT++
        if nCONT > len(aTPO)
           nCONT := len(aTPO)
           exit
        endif

        if aTPO[nCONT] != cTPO
           aadd(aTPO2,cTPO)
           cTPO := aTPO[nCONT]

        endif


     enddo

     aadd(aTPO2,cTPO)

     aPROD := asort(aPROD,,,{|x,y| x < y})

     cPROD := aPROD[1]

     nCONT := 1
     do while  nCONT <= len(aPROD)


        nCONT++
        if nCONT > len(aPROD)
           nCONT := len(aPROD)
           exit
        endif

        if aPROD[nCONT] != cPROD
           aadd(aPROD2,cPROD)
           cPROD := aPROD[nCONT]

        endif


     enddo



return {aCLI2,aTPO2,aPROD2}


static function produtosNf
local cEFD := ""
local nTotal_prod := 0
local cModelo := ""
local cCFOPS := "13-23-31"
local aPROD := {}
local aRet  := {}
local cPROD := ""
local nCont := 0

local oServer, oRow
local oQuery



         FAT->(dbclearfilter())
         FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. dt_emissao <= dFIM }))
         FAT->(dbsetorder(9))
         FAT->(Dbgotop())

         ITEN_FAT->(dbsetorder(2))

         ENT->(dbclearfilter())
		 ENT->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM .and. (!left(cfop,2) $ cCfops) })) // nao puxar fretes e importação
         ENT->(dbsetorder(2))
         ENT->(dbgotop())


         do while ! ENT->(Eof())
		 		 
            if empty(ENT->Modelo)
               cModelo := "  "
			else
               cModelo := ENT->Modelo			
            endif
			

            if ! FAT->(dbseek(ENT->Num_nf))
                 ENT->(dbskip())
                 loop
            endif
			
			if ENT->Vlr_cont == 0
			   ENT->(dbskip())
			   loop
    		endif

            
            ITEN_FAT->(dbseek(FAT->Codigo))
            Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                aadd(aPROD,ITEN_FAT->Cod_prod)
                ITEN_FAT->(dbskip())
            enddo

            ENT->(dbskip())

         enddo
		 
		 FAT->(dbclearfilter())
         FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. dt_emissao <= dFIM .and. ES == "S" .and. ! empty(NFe) }))
         FAT->(dbsetorder(9))
         FAT->(Dbgotop())

         ITEN_FAT->(dbsetorder(2))

         SAI->(dbclearfilter())
		 SAI->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM .and. left(cfop,3) $ "510-610-540-640-591-691-591-691-594-694"})) 
         SAI->(dbsetorder(2))
         SAI->(dbgotop())


         do while ! SAI->(Eof())
		 
            if ! FAT->(dbseek(SAI->Num_nf+"55"))
                 SAI->(dbskip())
                 loop
            endif
			
			if SAI->Vlr_cont == 0
			   SAI->(dbskip())
			   loop
    		endif

            
            ITEN_FAT->(dbseek(FAT->Codigo))
            Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                aadd(aPROD,ITEN_FAT->Cod_prod)
                ITEN_FAT->(dbskip())
            enddo

            SAI->(dbskip())

         enddo
		 
		 //////////////////////////////////////////////////////////
		 // Busca Importados_______________________________________
   
		 oServer := TMySQLServer():New(XSERVER, "root", "borios")
		 if oServer:NetErr()
			Alert(oServer:Error())
		 endif

		 oServer:SelectDB("comercial")
		 
		 //cQuery := "SELECT * from clientes as cli " 
		 cQuery := " select lpad(item.produto_id,5,'0') as codigo from item_importacao item "
		 cQuery += " join importacao imp on imp.id = item.importacao_id "
		 cQuery += " where imp.data_emissao between "+ dtos(dIni) + " and " + dtos(dFim)
		 cQuery += " group by item.produto_id; "
		 
		 
         oQuery := oServer:Query(cQuery)
   
	     if oQuery:NetErr()
		    Alert(oQuery:Error())
	     endif
   
         nCont := 1
   
  	     do while nCont <= oQuery:LastRec() 	 
		    row := oQuery:getRow(nCont)
		    aadd(aPROD,get(row,'codigo'))
			qmensa(get(row,'codigo'),"L")
		    nCont++
	     enddo 	
		 
		 oServer:close()
		 
		 //////////////////////////////////////////////////////////
		 // Ordena e Agrupa________________________________________
         aPROD := asort(aPROD,,,{|x,y| x < y})

         cPROD := aPROD[1]

         nCONT := 1
         do while nCONT <= len(aPROD)


            nCONT++
            if nCONT > len(aPROD)
               nCONT := len(aPROD)
               exit
            endif

            if aPROD[nCONT] != cPROD
               aadd(aRet,cPROD)
               cPROD := aPROD[nCONT]
            endif

         enddo
	 
	     aadd(aRet,cPROD)


return aRet



static function saidasNfe
local cEFD := ""
local nTotal_prod := 0
local cModelo := ""
local nPis := 0
local nCofins := 0


         FAT->(dbclearfilter())
         FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. dt_emissao <= dFIM .and. ES == "S" .and. ! empty(NFe) }))
         FAT->(dbsetorder(9))
         FAT->(Dbgotop())

         ITEN_FAT->(dbsetorder(2))

         SAI->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM }))
         SAI->(dbsetorder(2))
         SAI->(dbgotop())


         do while ! SAI->(Eof())
		 
		 
            if empty(SAI->Modelo)
               cModelo := "55"
			else
               cModelo := SAI->Modelo			
            endif
			

            if ! FAT->(dbseek(SAI->Num_nf+cModelo))
               SAI->(dbskip())
               loop
            endif

            if ! FAT->Cancelado

                cEFD := "|C100"
                cEFD += "|1|0"
                cEFD += "|C"+SAI->Cod_cli
                cEFD += "|55"

                if FAT->Cancelado
                   cEFD += "|02"
                else
                   cEFD += "|00"
                endif

                cEFD += "|1" //Serie
                cEFD += "|000"+SAI->Num_nf
                cEFD += "|"+FAT->NFe
                cEFD += "|"+dtosped(FAT->Dt_emissao)
                cEFD += "|"+dtosped(FAT->Dt_emissao)
                cEFD += "|"+alltrim(transform(SAI->Vlr_cont,"@E 999999999.99"))

                if DUP_FAT->(dbseek(FAT->codigo+"01"))
                   cEFD += "|1"
                else
                   cEFD += "|2"
                endif

                cEFD += "|"
                cEFD += "|"

                nTotal_prod := 0
				nPis        := 0
				nCofins     := 0

                ITEN_FAT->(dbseek(FAT->Codigo))
                Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                   nTotal_prod += ITEN_FAT->quantidade * ITEN_FAT->vl_unitar
				   nPis    += round(((ITEN_FAT->quantidade * ITEN_FAT->vl_unitar) * 0.0165),2)
				   nCofins += round(((ITEN_FAT->quantidade * ITEN_FAT->vl_unitar) * 0.076) ,2)


                   ITEN_FAT->(dbskip())
                enddo

                cEFD += "|"+alltrim(transform(round(nTotal_prod,2),"@E 99999999999.99"))
                cEFD += "|"+FAT->Frete
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"+alltrim(transform(SAI->Icm_base,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(SAI->Icm_vlr,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(SAI->Icm_bc_s,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(SAI->Icm_subst,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(SAI->Ipi_vlr,"@E 99999999999.99"))
				
				if left(SAI->Cfop,4) $ "5910-6910-5102-6102-5403-6403-6110-5110"
					cEFD += "|"+alltrim(transform(round(nPis,2),"@E 99999999999.99")) // PIS
					cEFD += "|"+alltrim(transform(round(nCofins,2),"@E 99999999999.99")) // COFINS
				else
					cEFD += "|"+alltrim(transform(0,"@E 99999999999.99")) // PIS
					cEFD += "|"+alltrim(transform(0,"@E 99999999999.99")) // COFINS
				endif	
               
			   cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
                nTot_C100++
				
				if FAT->(dbseek(SAI->Num_nf + "55"))
                   i_registro_c170(nFile)
				endif

                //i_registro_c190_Saidas(nFile)
            else
                cEFD := "|C100"
                cEFD += "|1|0"
                cEFD += "|"
                cEFD += "|55"

                cEFD += "|02"

                cEFD += "|" //Serie
                cEFD += "|000"+SAI->Num_nf
                cEFD += "|"+FAT->NFe
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"

                cEFD += "|"
                cEFD += "|"

                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
				nTot_c100++

            endif

            SAI->(dbskip())

         enddo


         cEFD := ""



return

static function entradasNfe
local cEFD := ""
local nTotal_prod,nPis,nCofins := 0
local cModelo := ""
local cCFOPS := "13-23-31"
local oServer, oRow
local oQuery
local nCont := 0
local cQuery :=  ""

		 oServer := TMySQLServer():New(XSERVER, "root", "borios")
		 if oServer:NetErr()
			Alert(oServer:Error())
		 endif

		 oServer:SelectDB("comercial")	

         FAT->(dbclearfilter())
         FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. dt_emissao <= dFIM .and. ES == "E" .and. ! empty(NFe) }))
         FAT->(dbsetorder(9))
         FAT->(Dbgotop())

         ITEN_FAT->(dbsetorder(2))

         ENT->(dbclearfilter())
		 ENT->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM .and. !left(cfop,2) $ cCfops })) // nao puxar fretes e importação
         ENT->(dbsetorder(2))
         ENT->(dbgotop())


         do while ! ENT->(Eof())
		 
		 
            if empty(ENT->Modelo)
               cModelo := "55"
			else
               cModelo := ENT->Modelo			
            endif
			
            if ! FAT->(dbseek(ENT->Num_nf+cModelo))
               ENT->(dbskip())
               loop
            endif

            if ! FAT->Cancelado

                cEFD := "|C100"
                cEFD += "|0|0"//0 - Entrada 1 - Saida|  0 - Emissao propria 1 - Terceiros
                cEFD += "|F"+ENT->Cod_forn
                cEFD += "|55"

                if FAT->Cancelado
                   cEFD += "|02"
                else
                   cEFD += "|00"
                endif

                cEFD += "|1" //Serie
                cEFD += "|000"+ENT->Num_nf
                cEFD += "|"+FAT->NFe
                cEFD += "|"+dtosped(FAT->Dt_emissao)
                cEFD += "|"+dtosped(FAT->Dt_emissao)
                cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 999999999.99"))

                //if DUP_FAT->(dbseek(FAT->codigo+"01"))
                //   cEFD += "|1"
                //else
                   cEFD += "|2"
                //endif

                cEFD += "|"
                cEFD += "|"

                nTotal_prod := 0
				nPis := 0
				nCofins := 0

				ITEN_FAT->(dbseek(FAT->Codigo))
                Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                   nTotal_prod += ITEN_FAT->quantidade * ITEN_FAT->vl_unitar
				   nPis    += round(((ITEN_FAT->quantidade * ITEN_FAT->vl_unitar) * 0.0165),2)
				   nCofins += round(((ITEN_FAT->quantidade * ITEN_FAT->vl_unitar) * 0.076) ,2)


                   ITEN_FAT->(dbskip())
                enddo
                cEFD += "|"+alltrim(transform(round(nTotal_prod,2),"@E 99999999999.99"))
                cEFD += "|0"//+FAT->Frete
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"+alltrim(transform(ENT->Icm_base,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(ENT->Icm_vlr,"@E 99999999999.99"))
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+alltrim(transform(ENT->Ipi_vlr,"@E 99999999999.99"))
                
				if left(ENT->Cfop,3) $ "191-291-194-294"
					cEFD += "|"+alltrim(transform(0,"@E 99999999999.99")) // PIS
					cEFD += "|"+alltrim(transform(0,"@E 99999999999.99")) // COFINS
				else
					if(left(ENT->Cfop,4) $ "2202-1202-2411-1411")
						cEFD += "|"+alltrim(transform(round( (ENT->Icm_base - ENT->Icm_subst) * 0.0165,2),"@E 99999999999.99")) // PIS
						cEFD += "|"+alltrim(transform(round((ENT->Icm_base - ENT->Icm_subst) * 0.0760,2),"@E 99999999999.99")) // COFINS
					else	
						cEFD += "|"+alltrim(transform(round( nPis,2),"@E 99999999999.99")) // PIS
						cEFD += "|"+alltrim(transform(round( nCofins,2),"@E 99999999999.99")) // COFINS
					endif	
				endif	
				
                
				cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
                nTot_C100++
				
				if FAT->(dbseek(ENT->Num_nf + "55"))
                   i_registro_c170_nfe(nFile,oServer,FAT->NFWeb_id)
				endif  

                //i_registro_c190_entradas(nFile)
            else
                cEFD := "|C100"
                cEFD += "|0|0"
                cEFD += "|"
                cEFD += "|55"

                cEFD += "|02"

                cEFD += "|" //Serie
                cEFD += "|000"+ENT->Num_nf
                cEFD += "|"+FAT->NFe
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"

                cEFD += "|"
                cEFD += "|"

                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
                nTot_C100++

            endif

            ENT->(dbskip())

         enddo


         cEFD := ""



return

static function entradasNfeImport
local cEFD := ""
local nTotProd := 0
local nIpi := 0
local cModelo := ""
local cCFOPS := "31"
local oServer, oRow
local oQuery
local nCont := 0
local cQuery :=  ""

		 oServer := TMySQLServer():New(XSERVER, "root", "borios")
		 if oServer:NetErr()
			Alert(oServer:Error())
		 endif

		 oServer:SelectDB("comercial")	
		 
		 cQuery := " select imp.* , "
		 cQuery +=  "	   sum(round (quantidade * valor_unitario,2)) as produtos, "
		 cQuery +=  "	   sum(round(base_ipi * (aliquota_ipi/100),2)) as valor_ipi,  "
		 cQuery +=  "	   sum(round(base_icms,2)) as base_icms,  "
		 cQuery +=  "	   sum(round(base_ipi * (aliquota_icms/100),2)) as valor_icms,  "
		 cQuery +=  "	   sum(round(base_pis * (aliquota_pis/100),2)) as valor_pis,  "
		 cQuery +=  "	   sum(round(base_cofins * (aliquota_cofins/100),2)) as valor_cofins  "
		 cQuery +=  " from importacao imp "
		 cQuery +=  " join item_importacao item on item.importacao_id = imp.id "
		 cQuery +=  " where data_emissao between " + dtos(dINI) + " and " + dtos(dFIM) 
		 cQuery +=  " group by imp.id; "
		 
		 oQuery := oServer:Query(cQuery)
   
	     if oQuery:NetErr()
		    Alert(oQuery:Error())
	     endif
   
         nCont := 1
   
  	     do while nCont <= oQuery:LastRec() 	
				row := oQuery:getRow(nCont)
                
				cEFD := "|C100"
                cEFD += "|0|0"//0 - Entrada 1 - Saida|  0 - Emissao propria 1 - Terceiros
                cEFD += "|F"+strzero(get(row,'fornecedor_id'),5)
                cEFD += "|55"

               // if FAT->Cancelado
               //    cEFD += "|02"
               // else
                   cEFD += "|00"
               // endif

                cEFD += "|1" //Serie
                cEFD += "|"+alltrim(get(row,'numero_nota'))
                cEFD += "|"+get(row,'chave_nfe')
                cEFD += "|"+dtosped(get(row,'data_emissao'))
                cEFD += "|"+dtosped(get(row,'data_emissao'))
				
				nTotProd := get(row,'produtos') 
				nIpi     := get(row,'valor_ipi')
				nValorContabil := nTotProd + nIpi
				
                cEFD += "|"+alltrim(transform(nValorContabil,"@E 999999999.99"))

                //if DUP_FAT->(dbseek(FAT->codigo+"01"))
                //   cEFD += "|1"
                //else
                   cEFD += "|1"
                //endif

                cEFD += "|"
                cEFD += "|"

                cEFD += "|"+alltrim(transform(get(row,'produtos'),"@E 99999999999.99"))
                cEFD += "|0"//+FAT->Frete
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"+alltrim(transform(get(row,'base_icms'),"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(get(row,'valor_icms'),"@E 99999999999.99"))
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+alltrim(transform(get(row,'valor_ipi'),"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(get(row,'valor_pis'),"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(get(row,'valor_cofins'),"@E 99999999999.99"))
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
                nTot_C100++
				
				i_registro_C120(nFile,row)
				i_registro_C170_import(nFile,oServer,get(row,'id'))

               // i_registro_c190_entradas(nFile)
            /*else
                cEFD := "|C100"
                cEFD += "|0|0"
                cEFD += "|"
                cEFD += "|55"

                cEFD += "|02"

                cEFD += "|" //Serie
                cEFD += "|000"+ENT->Num_nf
                cEFD += "|"+IMPORT->NFe
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"

                cEFD += "|"
                cEFD += "|"

                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
                nTot_C100++

            endif
			*/

             nCont++

         enddo


         cEFD := ""
		 oServer:close()



return

static function i_registro_C120(nFile,row)

local cEFD := ""

         ntot_lin++
		 ntot_C++
		 ntot_C120++

         cEFD := "|C120"
         cEFD += "|0" //Documento de Importacao DI
		 cEFD += "|"+alltrim(str(val(get(row,'numero_di'))))
		 cEFD += "|"+alltrim(transform(get(row,'valor_pis'),"@E 99999999999.99"))
		 cEFD += "|"+alltrim(transform(get(row,'valor_cofins'),"@E 99999999999.99"))
         cEFD += "|"
         cEFD += "|"+chr(13)+chr(10) 

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_C170_Import(nFile,oServer,id)
local cEFD := ""
local nTotal_prod := 0
local cQuery := ""
local oQuery
local row
local nCont := 1
         
		 cQuery := "    SELECT prod.referencia_brasil as referencia  , "
		 cQuery += " 		   prod.descricao as descricao,	"
		 cQuery += "			   item.*, "
		 cQuery += "			   round(item.base_icms * (item.aliquota_icms/100),2) as valor_icms,	 "
		 cQuery += "			   round(item.base_ipi * (item.aliquota_ipi/100),2) as valor_ipi,	"
		 cQuery += "			   round(item.base_pis * (item.aliquota_pis/100),2) as valor_pis,	"
		 cQuery += "			   round(item.base_cofins * (item.aliquota_cofins/100),2) as valor_cofins	"
		 cQuery += "		FROM comercial.item_importacao item "
		 cQuery += "		join produtos prod on prod.id = item.produto_id "
		 cQuery += " where item.importacao_id =" + alltrim(str(id)) 

         oQuery := oServer:Query(cQuery)
   
		 if oQuery:NetErr()
		    Alert(oQuery:Error())
		 endif
		   
		 nCont := 1
		   
		 do while nCont <= oQuery:LastRec() 	 
		    row := oQuery:getRow(nCont)

            cEFD := "|C170"
            cEFD += "|"+strzero(nCont,3)
            cEFD += "|"+alltrim(get(row,'referencia'))
            cEFD += "|"+rtrim(get(row,'descricao'))
            cEFD += "|"+alltrim(transform(get(row,'quantidade'),"@R 999999999"))
            cEFD += "|000001"
            cEFD += "|"+alltrim(transform(round(get(row,'quantidade')*get(row,'valor_unitario'),2),"@E 99999999999.99"))
            cEFD += "|" // Desconto
            cEFD += "|0"
            cEFD += "|100"
            cEFD += "|"+"3102"
            cEFD += "|"
            cEFD += "|"+alltrim(transform(get(row,'base_icms'),"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(get(row,'aliquota_icms'),"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(get(row,'valor_icms') ,"@E 9999999999.99"))
            cEFD += "|"
            cEFD += "|"
            cEFD += "|"
            cEFD += "|0"
            cEFD += "|00"//+right(ITEN_FAT->cod_sit,2)
            cEFD += "|"
            cEFD += "|"+alltrim(transform(get(row,'base_ipi'),"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(get(row,'aliquota_ipi'),"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(get(row,'valor_ipi'),"@E 9999999999.99"))
			
			cEFD += "|"+"50" // CST PIS
			cEFD += "|"+alltrim(transform(get(row,'base_pis'),"@E 9999999999.99")) // Base do Pis
			cEFD += "|"+alltrim(transform(get(row,'aliquota_pis'),"@E 9999999999.99")) //  aliq do Pis
			cEFD += "|"
			cEFD += "|"
			cEFD += "|"+alltrim(transform(get(row,'valor_pis'),"@E 9999999999.99")) // Vlr do Pis
			cEFD += "|"+"50" // CST COFINS
			cEFD += "|"+alltrim(transform(get(row,'base_cofins'),"@E 9999999999.99")) // Base do Cofins
			cEFD += "|"+alltrim(transform(get(row,'aliquota_cofins'),"@E 9999999999.99")) //  aliq do Cofins
			cEFD += "|"
			cEFD += "|"
			cEFD += "|"+alltrim(transform(get(row,'valor_cofins'),"@E 9999999999.99")) // Vlr do Cofins

            cEFD += "|"
            cEFD += "|"+chr(13)+chr(10)

            fwrite(nFile,cEFD,len(cEFD))
            ntot_lin++
            nTot_C++
            nTot_C170++
            nCONT++

         enddo


         cEFD := ""


return

static function entradasNf
local cEFD := ""
local nTotal_prod,nPis,nCofins := 0
local cModelo := ""
local cCFOPS := "13-23-31"

         FAT->(dbclearfilter())
         FAT->(Dbsetfilter({|| Dt_emissao >= dINI-150 .and. dt_emissao <= dFIM .and. ES == "E" }))
		 //FAT->(Dbsetfilter({|| ES == "E" .and. empty(NFe) }))
         FAT->(dbsetorder(3))
         FAT->(Dbgotop())

         ITEN_FAT->(dbsetorder(2))

         ENT->(dbclearfilter())
		 ENT->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM .and. (!left(cfop,2) $ cCfops) })) // nao puxar fretes e importação
         ENT->(dbsetorder(2))
         ENT->(dbgotop())


         do while ! ENT->(Eof())
		 
		 
            FORN->(dbseek(ENT->Cod_forn))		 
            CLI1->(dbsetorder(3))
			CLI1->(dbseek(FORN->cgccpf))
			
			if FAT->(dbseek(ENT->Num_nf + CLI1->Codigo))
               if !empty(FAT->Nfe)
                  ENT->(dbskip())
                  loop
               endif				  
			endif
			           

            if ! ENT->Vlr_Cont == 0

                cEFD := "|C100"
                cEFD += "|0|1"//0 - Entrada 1 - Saida|  0 - Emissao propria 1 - Terceiros
                cEFD += "|F"+ENT->Cod_forn
                cEFD += "|01"

                if ENT->Vlr_cont <= 0
                   cEFD += "|02"
                else
                   cEFD += "|00"
                endif

                cEFD += "|1" //Serie
                cEFD += "|000"+ENT->Num_nf
                cEFD += "|"//+FAT->NFe
                cEFD += "|"+dtosped(ENT->Data_emis)
                cEFD += "|"+dtosped(ENT->Data_lanc)
                cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 999999999.99"))

                //if DUP_FAT->(dbseek(FAT->codigo+"01"))
                //   cEFD += "|1"
                //else
                   cEFD += "|2"
                //endif

                cEFD += "|"
                cEFD += "|"

                nTotal_prod := 0
				nPis := 0
				nCofins := 0
                
				if FAT->(dbseek(ENT->Num_nf + CLI1->Codigo))
                   ITEN_FAT->(dbseek(FAT->Codigo))
                   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                      nTotal_prod += ITEN_FAT->quantidade * ITEN_FAT->vl_unitar
					  nPis    += round(((ITEN_FAT->quantidade * ITEN_FAT->vl_unitar) * 0.0165),2)
				      nCofins += round(((ITEN_FAT->quantidade * ITEN_FAT->vl_unitar) * 0.076) ,2)


                      ITEN_FAT->(dbskip())
                   enddo
				endif   

                cEFD += "|"+alltrim(transform(round(nTotal_prod,2),"@E 99999999999.99"))
                cEFD += "|0"//+FAT->Frete
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"+alltrim(transform(ENT->Icm_base,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(ENT->Icm_vlr,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(ENT->Icm_bc_s,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(ENT->Icm_subst,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(ENT->Ipi_vlr,"@E 99999999999.99"))
				
				if left(SAI->Cfop,3) $ "191-291-194-294"
					cEFD += "|"+alltrim(transform(0,"@E 99999999999.99")) // PIS
					cEFD += "|"+alltrim(transform(0,"@E 99999999999.99")) // COFINS
				else
					cEFD += "|"+alltrim(transform(round(nPis,2),"@E 99999999999.99")) // PIS
					cEFD += "|"+alltrim(transform(round(nCofins,2),"@E 99999999999.99")) // COFINS
				endif	
				
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
                nTot_C100++
				if FAT->(dbseek(ENT->Num_nf + CLI1->Codigo))
                   i_registro_c170(nFile)
				endif   
                //i_registro_c190_entradas(nFile)
            else
                cEFD := "|C100"
                cEFD += "|0|1"
                cEFD += "|"
                cEFD += "|01"

                cEFD += "|02"

                cEFD += "|" //Serie
                cEFD += "|000"+ENT->Num_nf
                cEFD += "|"//+FAT->NFe
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"

                cEFD += "|"
                cEFD += "|"

                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"

                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
                nTot_C100++

            endif

            ENT->(dbskip())

         enddo


         cEFD := ""



return

static function entradasFrete
local cEFD := ""
local nTotal_prod := 0
local cModelo := ""
local cCFOPS := "13-23"

         ENT->(dbclearfilter())
		 ENT->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM .and. (left(cfop,2) $ cCfops)})) // somente fretes
         ENT->(dbsetorder(2))
         ENT->(dbgotop())


         do while ! ENT->(Eof())
		 
		 
           
            if  ENT->Vlr_Cont > 0

                cEFD := "|D100"
                cEFD += "|0|1"//0 - Entrada 1 - Saida|  0 - Emissao propria 1 - Terceiros
                cEFD += "|F"+ENT->Cod_forn
                cEFD += "|08"

                if ENT->Vlr_cont <= 0
                   cEFD += "|02"
                else
                   cEFD += "|00"
                endif

                cEFD += "|" //Serie
				cEFD += "|" //SubSerie
				
                cEFD += "|000"+ENT->Num_nf
                cEFD += "|" //chave CTe
                cEFD += "|"+dtosped(ENT->Data_emis)
                cEFD += "|"+dtosped(ENT->Data_lanc)
				cEFD += "|" //Tipo CTe
				cEFD += "|" //Chave Ref tipo CTe
                cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 999999999.99"))

                cEFD += "|" //Desconto
                

                cEFD += "|0" //Tipo  do Frete
				cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 999999999.99"))
                
                cEFD += "|"+alltrim(transform(ENT->Icm_base,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(ENT->Icm_vlr,"@E 99999999999.99"))
				cEFD += "|0"//+alltrim(transform(ENT->Icm_out,"@E 99999999999.99"))
              
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_D++
                nTot_D100++
				
				//i_registro_d190(nFile)
				i_registro_d101(nFile)
				i_registro_d105(nFile)
                
           
            endif

            ENT->(dbskip())

         enddo


         cEFD := ""



return

static function i_registro_D101(nFile)
local cEFD := ""

         ntot_lin++
		 ntot_D++
		 ntot_D101++

         cEFD := "|D101"
         cEFD += "|0" //Tipo  do Frete
		 cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 99999999999.99"))
		 cEFD += "|50"
		 cEFD += "|14" //Transporte de Cargas
		 cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 99999999999.99"))
         cEFD += "|"+alltrim(transform(1.65,"@E 99999999.99"))
		 cEFD += "|"+alltrim(transform(round(ENT->Vlr_cont * 0.0165,2),"@E 99999999999.99"))
         cEFD += "|"
         cEFD += "|"+chr(13)+chr(10) 

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_D105(nFile)
local cEFD := ""

         ntot_lin++
		 ntot_D++
		 ntot_D105++

         cEFD := "|D105"
         cEFD += "|0" //Tipo  do Frete
		 cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 99999999999.99"))
		 cEFD += "|50"
		 cEFD += "|14" //Transporte de Cargas
		 cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 99999999999.99"))
         cEFD += "|"+alltrim(transform(7.60,"@E 99999999.99"))
		 cEFD += "|"+alltrim(transform(round(ENT->Vlr_cont * 0.076,2),"@E 99999999999.99"))
         cEFD += "|"
         cEFD += "|"+chr(13)+chr(10) 

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_9001(nFile)
local cEFD := ""

         ntot_lin++
		 ntot_9++

         cEFD := "|9001"
         cEFD += "|0"
         cEFD += "|"+chr(13)+chr(10) // Abre Registro 9

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_9900(nFile)
local cEFD := ""
local aTotalRegistros :=  {}
       
    aadd(aTotalRegistros,{"0000",1}) 	 
    aadd(aTotalRegistros,{"0001",1}) 	 
    aadd(aTotalRegistros,{"0100",1}) 	 
    aadd(aTotalRegistros,{"0110",1}) 	 
    aadd(aTotalRegistros,{"0140",1})
    aadd(aTotalRegistros,{"0150",nTot_0150})
    aadd(aTotalRegistros,{"0190",nTot_0190})
    aadd(aTotalRegistros,{"0200",nTot_0200})
	aadd(aTotalRegistros,{"0990",1})
    aadd(aTotalRegistros,{"C001",1})
    aadd(aTotalRegistros,{"C010",1})
    aadd(aTotalRegistros,{"C100",nTot_C100})
    aadd(aTotalRegistros,{"C120",nTot_C120})
    aadd(aTotalRegistros,{"C170",nTot_C170})
    aadd(aTotalRegistros,{"C990",1})
    aadd(aTotalRegistros,{"D001",1})
    aadd(aTotalRegistros,{"D010",1})
    aadd(aTotalRegistros,{"D100",nTot_D100})
    aadd(aTotalRegistros,{"D101",nTot_D101})
    aadd(aTotalRegistros,{"D105",nTot_D105})
    aadd(aTotalRegistros,{"D990",1})
    aadd(aTotalRegistros,{"F001",1})
    aadd(aTotalRegistros,{"F990",1})
    aadd(aTotalRegistros,{"M001",1})
    aadd(aTotalRegistros,{"M990",1})
    aadd(aTotalRegistros,{"1001",1})
    aadd(aTotalRegistros,{"1990",1})
	aadd(aTotalRegistros,{"9001",1})
	aadd(aTotalRegistros,{"9990",1})
	aadd(aTotalRegistros,{"9999",1})
			 
	for nCont := 1 to len(aTotalRegistros)
	    ntot_lin++
	    ntot_9++
	    ntot_9900++
		cEFD += "|9900|" + aTotalRegistros[nCONT,1] + "|" + alltrim(str(aTotalRegistros[nCONT,2])) + "|" + chr(13) + chr(10)
		//
	next
	
	ntot_lin++
	ntot_9++
	ntot_9900++
	cEFD += "|9900|" + "9900" + "|" + alltrim(str(nTot_9900)) + "|" + chr(13) + chr(10)

    fwrite(nFile,cEFD,len(cEFD))

return

static function i_registro_9990(nFile)
local cEFD := ""

         ntot_lin++
		 ntot_9++
		 ntot_9++ // para pegar o ultimo 9999 que vira em seguida

         cEFD := "|9990"
         cEFD += "|" + alltrim(str(nTot_9)) 
         cEFD += "|"+chr(13)+chr(10) // Abre Registro 9

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_9999(nFile)
local cEFD := ""

         ntot_lin++

         cEFD := "|9999"
         cEFD += "|" + alltrim(str(nTot_lin)) 
         cEFD += "|"+chr(13)+chr(10) // Fecha

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function get(row,campo)
return  row:fieldget(campo)



