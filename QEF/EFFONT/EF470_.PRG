/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE Escrita Fiscal
// OBJETIVO...: Exportar arquivo p/ SPED Fiscal
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO 2011
// OBS........:
// ALTERACOES.:

function ef470

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
private nTOT_0005 := 0
private nTOT_0100 := 0
private nTOT_0150 := 0
private nTOT_0190 := 0
private nTOT_0200 := 0
private nTOT_0400 := 0
private nTOT_0990 := 0
private nTOT_C    := 0
private nTOT_D    := 0
private nTOT_E    := 0
private nTOT_G    := 0
private nTOT_H    := 0
private nTOT_H005 := 0
private nTOT_H010 := 0
private nTOT_1    := 0
private nTOT_9    := 0
private nTOT_99   := 0
private nTOT_K    := 0
private nTOT_C100 := 0
private nTOT_C170 := 0
private nTOT_C190 := 0
private nTOT_D100 := 0
private nTOT_D190 := 0
private nTOT_E510 := 0
private nTOT_E520 := 0
private aDados := {}
private aIpi   := {}
private aIpiEntradas   := {}


private nFile   := 0
private cBuffer := ""


private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma Exportacao de Arquivo SPED Fiscal ?") },NIL})

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
   
   aDados := {}
   aIpi   := {}
   aIpiEntradas  := {}

return .T.


static function i_sped
local cEFD := ""
      nFile := fcreate("c:\Qsystxt\Qsys_efd.txt",0)
      open_files()
      aDados := produtosNf()

      i_registro_0000(nFILE)

      i_registro_0001(nFile)    //Abertura do bloco 0
      i_registro_0005(nFile)
      i_registro_0100(nFile)
      i_registro_0150(nFile)
      i_registro_0190(nFile)
      i_registro_0200(nFile,aDados)
//      i_registro_0400(nFile,aDados[2])
      i_registro_0990(nFile)    //Fecha Bloco 0

      i_registro_C001(nFile)    //Abre Bloco C
      i_registro_C100(nFile)
      i_registro_C990(nFile)

      i_registro_D001(nFile)    //Abre Bloco D
	  i_registro_D100(nFile)
      i_registro_D990(nFile)

      i_registro_E001(nFile)    //Abre Bloco E
	  i_registro_E500(nFile)   //Ipi
	  i_registro_E510(nFile)   //Ipi po Cfop
	  i_registro_E520(nFile)   //total do IPi
      i_registro_E990(nFile)

      i_registro_G001(nFile)    //Abre Bloco H
      i_registro_G990(nFile)

      i_registro_H001(nFile)    //Abre Bloco H
	  
	  if month(dIni) == 2
		 i_registro_H005(nFile)
		 i_registro_H010(nFile)
	  endif	
	  
      i_registro_H990(nFile)
	  
	  i_registro_K001(nFile)
	  i_registro_K990(nFile)
	  
	  i_registro_1001(nFile)
	  i_registro_1010(nFile)
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
      cEFD += "|010"
      cEFD += "|0"
      cEFD += "|"+dtoSped(dINI)
      cEFD += "|"+dtoSped(dFIM)
      cEFD += "|"+rtrim(FILIAL->Razao)
      cEFD += "|"+FILIAL->Cgccpf
      cEFD += "|"
      CGM->(dbseek(FILIAL->Cgm))

      cEFD += "|"+rtrim(Cgm->Estado)
      cEFD += "|"+rtrim(FILIAL->Insc_estad)
      cEFD += "|"+getMunicipioId(CGM->Cod_rais,CGM->Municipio)
      cEFD += "|"
      cEFD += "|"
      cEFD += "|A"
      cEFD += "|0"
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



      fwrite(nFile,cEFD,len(cEFD))

return

static function i_registro_0005(nFile)
local cEFD := ""

      cEFD := "|0005"
      cEFD += "|"+rtrim(FILIAL->Fantasia)
      cEFD += "|"+rtrim(FILIAL->Cep)
      cEFD += "|"+rtrim(FILIAL->Endereco)
      cEFD += "|"+alltrim(str(FILIAL->Numero))
      cEFD += "|"+rtrim(FILIAL->Compl)
      cEFD += "|"+rtrim(FILIAL->Bairro)
      cEFD += "|41"+rtrim(qtiraponto(FILIAL->Telefone))
      cEFD += "|41"+rtrim(qtiraponto(FILIAL->Telefone))
      cEFD += "|contato@mantraco.com.br"
      cEFD += "|"+chr(13)+chr(10)
      nTot_lin++
      nTot_0000++



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



      fwrite(nFile,cEFD,len(cEFD))

return


static function i_registro_0200(nFile,aProd)
local cEFD := ""
local nCont := 0
      PROD->(dbsetorder(4))

      for nCont := 1 to len(aPROD)

         if PROD->(dbseek(aPROD[nCONT]))
			 cEFD := "|0200"
			 //if empty(PROD->cod_fabr) .and. empty(PROD->cod_ass)
			 cEFD += "|"+ltrim(rtrim(PROD->cod_fabr))
			 //else
			 //   cEFD += "|"+alltrim(qtiraponto(PROD->Cod_fabr))
			 //endif
			 cEFD += "|"+strtran(ltrim(rtrim(PROD->Descricao)),"|","")
			 cEFD += "|"+alltrim(PROD->cod_barras)
			 cEFD += "|"
			 cEFD += "|000001"
			 cEFD += "|00"
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


static function i_registro_C100(nFile)

    saidasNfe()
    entradasNfe()
	entradasNfeImport()
	entradasNf()
	
	
	

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
            cEFD += "|"+strtran(rtrim(PROD->Descricao),"|"," ")
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
            cEFD += "|"+alltrim(transform(ENT->icm_bc_s,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(ENT->icm_subst,"@E 9999999999.99"))
            cEFD += "|0,00"
            cEFD += "|"+alltrim(transform(ENT->ipi_vlr,"@E 9999999999.99"))
            cEFD += "|"
            cEFD += "|"+chr(13)+chr(10)

            fwrite(nFile,cEFD,len(cEFD))
            ntot_lin++
            nTot_C++
            nTot_C190++


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
            cEFD += "|"+alltrim(transform(SAI->icm_bc_s,"@E 9999999999.99"))
            cEFD += "|"+alltrim(transform(SAI->icm_subst,"@E 9999999999.99"))
            cEFD += "|0,00"
            cEFD += "|"+alltrim(transform(SAI->ipi_vlr,"@E 9999999999.99"))
            cEFD += "|"
            cEFD += "|"+chr(13)+chr(10)

            fwrite(nFile,cEFD,len(cEFD))
            ntot_lin++
            nTot_C++
            nTot_C190++


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
            nTot_D190++
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


static function i_registro_E001(nFile)
local cEFD := ""

         ntot_lin++
         nTot_E++

         cEFD := "|E001"
         cEFD += "|0"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_E500(nFile)
local cEFD := ""

         ntot_lin++
         nTot_E++

         cEFD := "|E500"
         cEFD += "|0" //0 - Mensal ou 1 - Decendial
         cEFD += "|"+dtoSped(dINI) 
         cEFD += "|"+dtoSped(dFIM) 
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_E510(nFile)
local cEFD := ""
local nCont := 0

         for nCont := 1 to len(aIpi)
			 if aIpi[nCont,5] > 0
				 ntot_lin++
				 nTot_E++
				 nTot_E510++

				 cEFD += "|E510"
				 cEFD += "|"+aIpi[nCont,1] 
				 cEFD += "|"+aIpi[nCont,2]
				 cEFD += "|"+alltrim(transform(aIpi[nCont,3],"@E 999999999.99"))
				 cEFD += "|"+alltrim(transform(aIpi[nCont,4],"@E 999999999.99"))
				 cEFD += "|"+alltrim(transform(aIpi[nCont,5],"@E 999999999.99"))
				 cEFD += "|"+chr(13)+chr(10)
			 endif 	 
		 next 	 
		 
		 for nCont := 1 to len(aIpiEntradas)
			 if aIpiEntradas[nCont,5] > 0
				 ntot_lin++
				 nTot_E++
				 nTot_E510++

				 cEFD += "|E510"
				 cEFD += "|"+aIpiEntradas[nCont,1] 
				 cEFD += "|"+aIpiEntradas[nCont,2]
				 cEFD += "|"+alltrim(transform(aIpiEntradas[nCont,3],"@E 999999999.99"))
				 cEFD += "|"+alltrim(transform(aIpiEntradas[nCont,4],"@E 999999999.99"))
				 cEFD += "|"+alltrim(transform(aIpiEntradas[nCont,5],"@E 999999999.99"))
				 cEFD += "|"+chr(13)+chr(10)
			 endif 	 
		 next 	 

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_E520(nFile)
local cEFD := ""
local nCont := 0
local nTotalDoIpiSaidas   := 0
local nTotalDoIpiEntradas := 0
local isSaldoCredor := .F.
local nSaldoCredor := 0
local nSaldoDevedor := 0

         for nCont := 1 to len(aIpi)
			 if aIpi[nCont,5] > 0
				nTotalDoIpiSaidas += aIpi[nCont,5]
			 endif 	 
		 next 	

		for nCont := 1 to len(aIpiEntradas)
			 if aIpiEntradas[nCont,5] > 0
				nTotalDoIpiEntradas += aIpiEntradas[nCont,5]
			 endif 	 
		 next 			 
		 
		 ntot_lin++
		 nTot_E++
		 nTot_E520++
		 
		 if nTotalDoIpiEntradas >= nTotalDoIpiSaidas
			nSaldoCredor := nTotalDoIpiEntradas - nTotalDoIpiSaidas
		 else
			nSaldoDevedor := nTotalDoIpiSaidas - nTotalDoIpiEntradas
		 endif
		 
		 cEFD += "|E520"
		 cEFD += "|0,00" //Saldo Credor Anterior
		 cEFD += "|"+alltrim(transform(nTotalDoIpiSaidas,"@E 999999999.99"))
		 cEFD += "|"+alltrim(transform(nTotalDoIpiEntradas,"@E 999999999.99"))
		 cEFD += "|0,00" //Outros Debitos
		 cEFD += "|0,00" //Outros Creditos
		 cEFD += "|"+alltrim(transform(nSaldoCredor,"@E 999999999.99")) 
		 cEFD += "|"+alltrim(transform(nSaldoDevedor,"@E 999999999.99")) 
		 cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_E990(nFile)
local cEFD := ""


         ntot_lin++
         nTot_E++

         cEFD := "|E990"
         cEFD += "|"+alltrim(str(nTOT_E))
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_G001(nFile)
local cEFD := ""


         ntot_lin++
         nTot_G++

         cEFD := "|G001"
         cEFD += "|1"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return


static function i_registro_G990(nFile)
local cEFD := ""


         ntot_lin++
         nTot_G++

         cEFD := "|G990"
         cEFD += "|"+alltrim(str(nTOT_G))
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return


static function i_registro_H001(nFile)
local cEFD := ""

         ntot_lin++
         nTot_H++

         cEFD := "|H001"
		 
		 if month(dIni) == 2
			cEFD += "|0"
		 else
			cEFD += "|1"
		 endif	
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_H005(nFile)
local cEFD := ""
local oServer, oQuery, row
local nTotalEstoque := 0

         ntot_lin++
         nTot_H++
         nTot_H005++
		 
			oServer := TMySQLServer():New(XSERVER, "root", "borios")
			 if oServer:NetErr()
				Alert(oServer:Error())
			 endif

			 oServer:SelectDB("comercial")
			 
			 cQuery := "SELECT sum(quantidade * i.preco_custo) as total from invent i "
			 cQuery += " join produtos prod on prod.id = i.produto_id "
			 cQuery += " where quantidade > 0 "
             cQuery += " and prod.referencia_brasil not like 'PEX%' " 
			 cQuery += " and prod.referencia_brasil != 'CAT' " 			 
			 oQuery := oServer:Query(cQuery)
	   
			 if oQuery:NetErr()
				Alert(oQuery:Error())
			 endif
	   
			 nCont := 1
	   
			 do while nCont <= oQuery:LastRec() 	 
				row := oQuery:getRow(nCont)
				nTotalEstoque+= get(row,'total') 
				nCont++
			 enddo 	
			 
			 oServer:close()

         cEFD := "|H005"
		 cEFD += "|"+"31122015"
		 cEFD += "|"+alltrim(transform(nTotalEstoque,"@E 9999999999.99"))
		 cEFD += "|"+"01"
         cEFD += "|"+chr(13)+chr(10)
         fwrite(nFile,cEFD,len(cEFD))
         cEFD := ""

return

static function i_registro_H010(nFile)
local cEFD := ""
local oServer, oQuery, row
local nTotalEstoque := 0

         
		 
			oServer := TMySQLServer():New(XSERVER, "root", "borios")
			 if oServer:NetErr()
				Alert(oServer:Error())
			 endif

			 oServer:SelectDB("comercial")
			 
			 cQuery := "SELECT prod.referencia_brasil as referencia, i.* from invent i" 
			 cQuery += " left outer join produtos prod on prod.id = i.produto_id " 
			 cQuery += " where quantidade > 0 " 
			 cQuery += " and prod.referencia_brasil not like 'PEX%' " 
			 cQuery += " and prod.referencia_brasil != 'CAT' " 		
			 oQuery := oServer:Query(cQuery)
	   
			 if oQuery:NetErr()
				Alert(oQuery:Error())
			 endif
	   
			 nCont := 1
	   
			 do while nCont <= oQuery:LastRec() 	 
				row := oQuery:getRow(nCont)
				
				cEFD := "|H010"
				cEFD += "|"+alltrim(get(row,'referencia'))
				cEFD += "|"+"000001"
				cEFD += "|"+alltrim(transform(get(row,'quantidade'),"@E 9999999999.999"))
				cEFD += "|"+alltrim(transform(get(row,'preco_custo'),"@E 9999999999.999999"))
				cEFD += "|"+alltrim(transform(get(row,'preco_custo')*get(row,'quantidade'),"@E 9999999999.99"))
				cEFD += "|"+"0"
				cEFD += "|"
				cEFD += "|"
				cEFD += "|101060100021"
				cEFD += "|"
				cEFD += "|"+chr(13)+chr(10)
				fwrite(nFile,cEFD,len(cEFD))
				cEFD := ""
				
				ntot_lin++
				nTot_H++
				nTot_H010++
				nCont++
			 enddo 	
			 
		oServer:close()

         

return


static function i_registro_H990(nFile)
local cEFD := ""

         ntot_lin++
         nTot_H++

         cEFD := "|H990"
         cEFD += "|"+alltrim(str(nTOT_H))
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_1001(nFile)
local cEFD := ""

         ntot_lin++
         nTot_1++

         cEFD := "|1001"
         cEFD += "|0" //Com dados
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return



static function i_registro_1010(nFile)
local cEFD := ""

         ntot_lin++
         nTot_1++

         cEFD := "|1010"
         cEFD += "|N|N|N|N|N|N|N|N|N"
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_1990(nFile)
local cEFD := ""


         ntot_lin++
         nTot_1++

         cEFD := "|1990"
         cEFD += "|"+alltrim(str(nTOT_1))
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_K001(nFile)
local cEFD := ""

         ntot_lin++
		 ntot_K++

         cEFD := "|K001"
         cEFD += "|1" //Com dados
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_K990(nFile)
local cEFD := ""

         ntot_lin++
         nTot_K++

         cEFD := "|K990"
         cEFD += "|"+alltrim(str(nTOT_K))
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_9001(nFile)
local cEFD := ""

         ntot_lin++
         nTot_9++

         cEFD := "|9001"
         cEFD += "|0" //Com dados
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_9900(nFile)
local cEFD := ""

         ntot_lin++
         nTot_9++
         nTot_99++
         cEFD := "|9900|0000|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|0001|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|0005|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|0100|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|0150|"+ alltrim(str(nTOT_0150)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|0190|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|0200|"+ alltrim(str(nTOT_0200)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|0990|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|1001|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|1010|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|1990|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|9001|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|9990|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|9999|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|C001|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|C100|"+ alltrim(str(nTOT_C100)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|C170|"+ alltrim(str(nTOT_C170)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|C190|"+ alltrim(str(nTOT_C190)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|C990|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|D001|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|D100|"+ alltrim(str(nTOT_D100)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|D190|"+ alltrim(str(nTOT_D190)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|D990|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|E001|1|"+chr(13)+chr(10)
		 //cEFD += "|9900|E100|1|"+chr(13)+chr(10)
		 //cEFD += "|9900|E110|1|"+chr(13)+chr(10)
		 //cEFD += "|9900|E111|1|"+chr(13)+chr(10)
		 //cEFD += "|9900|E116|1|"+chr(13)+chr(10)
		 
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|E500|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|E510|"+ alltrim(str(nTOT_E510)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|E520|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|E990|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|G001|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|G990|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|H001|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|H005|"+ alltrim(str(nTOT_H005)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|H010|"+ alltrim(str(nTOT_H010)) +"|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|H990|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|K001|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|K990|1|"+chr(13)+chr(10)
		 
		 ntot_lin++
         nTot_9++
         nTot_99++
		 cEFD += "|9900|9900|"+ alltrim(str(nTOT_99))+"|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_9990(nFile)
local cEFD := ""

         ntot_lin++
         nTot_9++
         nTot_9++

         cEFD := "|9990"
         cEFD += "|"+alltrim(str(nTOT_9))
         cEFD += "|"+chr(13)+chr(10)

         fwrite(nFile,cEFD,len(cEFD))

         cEFD := ""

return

static function i_registro_9999(nFile)
local cEFD := ""

         ntot_lin++

         cEFD := "|9999"
         cEFD += "|"+alltrim(str(nTOT_lin))
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
         cEFD += "|"+ltrim(rtrim(CLI1->Razao))
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
         cEFD += "|"+ltrim(rtrim(CLI1->End_ent))
         cEFD += "|"+alltrim(CLI1->numero)
         cEFD += "|"+ltrim(rtrim(qtiraponto(CLI1->compl)))
         cEFD += "|"+ltrim(rtrim(qtiraponto(CLI1->Bairro_ent)))
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
         cEFD += "|"+ltrim(rtrim(FORN->End_ent))
         cEFD += "|"+alltrim(FORN->numero)
         cEFD += "|"+ltrim(rtrim(qtiraponto(FORN->compl)))
         cEFD += "|"+ltrim(rtrim(qtiraponto(FORN->Bairro_ent)))
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
local oServer, oQuery, row


         FAT->(dbclearfilter())
         FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. dt_emissao <= dFIM .and. ES == "E" .and. empty(NFe) }))
         FAT->(dbsetorder(9))
         FAT->(Dbgotop())

         ITEN_FAT->(dbsetorder(2))

         ENT->(dbclearfilter())
		 ENT->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM .and. (!left(cfop,2) $ cCfops)})) // nao puxar fretes e importação
         ENT->(dbsetorder(2))
         ENT->(dbgotop())


         do while ! ENT->(Eof())
		 		 
            if empty(ENT->Modelo)
               cModelo := "  "
			else
               cModelo := ENT->Modelo			
            endif
			

            if ! FAT->(dbseek(ENT->Num_nf+cModelo))
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
		 
		 if month(dFim) == 2
			 oServer := TMySQLServer():New(XSERVER, "root", "borios")
			 if oServer:NetErr()
				Alert(oServer:Error())
			 endif

			 oServer:SelectDB("comercial")
			 
			 cQuery := " SELECT lpad(prod.id,5,'0') as codigo, i.* from invent i " 
			 cQuery += " join produtos prod on prod.id = i.produto_id where quantidade > 0 " 
			 cQuery += " and prod.referencia_brasil not like 'PEX%' " 
			 cQuery += " and prod.referencia_brasil != 'CAT' " 
			 oQuery := oServer:Query(cQuery)
	   
			 if oQuery:NetErr()
				Alert(oQuery:Error())
			 endif
	   
			 nCont := 1
	   
			 do while nCont <= oQuery:LastRec() 	 
				row := oQuery:getRow(nCont)
				aadd(aPROD,get(row,'codigo'))
				nCont++
			 enddo 	
			 
			 oServer:close()
		 endif
		 
		 
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


         FAT->(dbclearfilter())
         FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. dt_emissao <= dFIM .and. ES == "S" .and. ! empty(NFe) }))
         FAT->(dbsetorder(9))
         FAT->(Dbgotop())

         ITEN_FAT->(dbsetorder(2))

         SAI->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM}))
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

                ITEN_FAT->(dbseek(FAT->Codigo))
                Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                   nTotal_prod += ITEN_FAT->quantidade * ITEN_FAT->vl_unitar


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
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)
				
				//if SAI->Ipi_vlr > 0
				    nKey := ascan(aIpi,{|ckey| cKey[1] == SAI->Cfop})
					
					if nKey > 0
						aIpi[nKey,3] := aIpi[nKey,3] + SAI->Vlr_cont
						aIpi[nKey,4] := aIpi[nKey,4] + SAI->ipi_base
						aIpi[nKey,5] := aIpi[nKey,5] + SAI->ipi_vlr
					else
						aadd(aIpi,{SAI->cfop,"50",SAI->Vlr_cont,SAI->Ipi_base,SAI->Ipi_vlr})
					endif
				//endif	

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
                nTot_C100++

                i_registro_c190_Saidas(nFile)
            else
                cEFD := "|C100"
                cEFD += "|1|0"
                cEFD += "|"
                cEFD += "|55"

                cEFD += "|02"

                cEFD += "|1" //Serie
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
                nTot_C100++

            endif

            SAI->(dbskip())

         enddo


         cEFD := ""



return

static function entradasNfe
local cEFD := ""
local nTotal_prod := 0
local cModelo := ""
local cCFOPS := "13-23-31"

         FAT->(dbclearfilter())
         FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. dt_emissao <= dFIM .and. ES == "E" .and. ! empty(NFe) }))
         FAT->(dbsetorder(9))
         FAT->(Dbgotop())

         ITEN_FAT->(dbsetorder(2))

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

                ITEN_FAT->(dbseek(FAT->Codigo))
                Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                   nTotal_prod += ITEN_FAT->quantidade * ITEN_FAT->vl_unitar


                   ITEN_FAT->(dbskip())
                enddo

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
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)
				
				 nKey := ascan(aIpiEntradas,{|ckey| cKey[1] == ENT->Cfop})
					
					if nKey > 0
						aIpiEntradas[nKey,3] := aIpiEntradas[nKey,3] + ENT->Vlr_cont
						aIpiEntradas[nKey,4] := aIpiEntradas[nKey,4] + ENT->ipi_base
						aIpiEntradas[nKey,5] := aIpiEntradas[nKey,5] + ENT->ipi_vlr
					else
						aadd(aIpiEntradas,{ENT->cfop,"00",ENT->Vlr_cont,ENT->Ipi_base,ENT->Ipi_vlr})
					endif

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
				nTot_C100++

                i_registro_c190_entradas(nFile)
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
local nTotal_prod := 0
local cModelo := ""
local cCFOPS := "31"

         IMPORT->(dbsetorder(4)) 

         ENT->(dbclearfilter())
         ENT->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM .and. (left(ENT->cfop,2) == cCfops)})) // somente importacao
         ENT->(dbsetorder(2))
         ENT->(dbgotop())


         do while ! ENT->(Eof())
		 
		 
		 
            if ! IMPORT->(dbseek(ENT->Num_nf))
               ENT->(dbskip())
               loop
            endif

            if ! IMPORT->Cancelado

                cEFD := "|C100"
                cEFD += "|0|0"//0 - Entrada 1 - Saida|  0 - Emissao propria 1 - Terceiros
                cEFD += "|F"+ENT->Cod_forn
                cEFD += "|55"

                cEFD += "|00"

                cEFD += "|1" //Serie
                cEFD += "|000"+ENT->Num_nf
                cEFD += "|"+IMPORT->NFe
                cEFD += "|"+dtosped(ENT->Data_emis)
                cEFD += "|"+dtosped(ENT->Data_emis)
                cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 999999999.99"))

                //if DUP_FAT->(dbseek(FAT->codigo+"01"))
                //   cEFD += "|1"
                //else
                   cEFD += "|1"
                //endif

                cEFD += "|"
                cEFD += "|"

                nTotal_prod := 0

                ITEN_IMP->(dbseek(IMPORT->Codigo))
                Do while ! ITEN_IMP->(eof()) .and. ITEN_IMP->Cod_ped == IMPORT->Codigo

                   nTotal_prod += ITEN_IMP->quant * ITEN_IMP->preco


                   ITEN_IMP->(dbskip())
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
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)
				
				nKey := ascan(aIpiEntradas,{|ckey| cKey[1] == ENT->Cfop})
					
					if nKey > 0
						aIpiEntradas[nKey,3] := aIpiEntradas[nKey,3] + ENT->Vlr_cont
						aIpiEntradas[nKey,4] := aIpiEntradas[nKey,4] + ENT->ipi_base
						aIpiEntradas[nKey,5] := aIpiEntradas[nKey,5] + ENT->ipi_vlr
					else
						aadd(aIpiEntradas,{ENT->cfop,"00",ENT->Vlr_cont,ENT->Ipi_base,ENT->Ipi_vlr})
					endif

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
				nTot_C100++

                i_registro_c190_entradas(nFile)
            else
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

            ENT->(dbskip())

         enddo


         cEFD := ""



return

static function entradasNf
local cEFD := ""
local nTotal_prod := 0
local cModelo := ""
local cCFOPS := "13-23-31"

         FAT->(dbclearfilter())
         FAT->(Dbsetfilter({|| Dt_emissao >= dINI-150 .and. dt_emissao <= dFIM .and. ES == "E" }))
		 //FAT->(Dbsetfilter({|| ES == "E" .and. empty(NFe) }))
         FAT->(dbsetorder(3))
         FAT->(Dbgotop())

         ITEN_FAT->(dbsetorder(2))

         ENT->(dbclearfilter())
		 ENT->(dbsetfilter({|| Data_lanc >= dINI .and. Data_lanc <= dFIM .and. (!left(cfop,2) $ cCfops)})) // nao puxar fretes e importação
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
                
				if FAT->(dbseek(ENT->Num_nf + CLI1->Codigo))
                   ITEN_FAT->(dbseek(FAT->Codigo))
                   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                      nTotal_prod += ITEN_FAT->quantidade * ITEN_FAT->vl_unitar


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
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)
				
				nKey := ascan(aIpiEntradas,{|ckey| cKey[1] == ENT->Cfop})
					
					if nKey > 0
						aIpiEntradas[nKey,3] := aIpiEntradas[nKey,3] + ENT->Vlr_cont
						aIpiEntradas[nKey,4] := aIpiEntradas[nKey,4] + ENT->ipi_base
						aIpiEntradas[nKey,5] := aIpiEntradas[nKey,5] + ENT->ipi_vlr
					else
						aadd(aIpiEntradas,{ENT->cfop,"00",ENT->Vlr_cont,ENT->Ipi_base,ENT->Ipi_vlr})
					endif

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_C++
			    nTot_C100++
				
				if FAT->(dbseek(ENT->Num_nf + CLI1->Codigo))
                   i_registro_c170(nFile)
				endif   
                i_registro_c190_entradas(nFile)
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
                

                cEFD += "|2" //Tipo  do Frete
				cEFD += "|"+alltrim(transform(ENT->Vlr_cont,"@E 999999999.99"))
                
                cEFD += "|"+alltrim(transform(ENT->Icm_base,"@E 99999999999.99"))
                cEFD += "|"+alltrim(transform(ENT->Icm_vlr,"@E 99999999999.99"))
				cEFD += "|0"//+alltrim(transform(ENT->Icm_out,"@E 99999999999.99"))
              
                cEFD += "|"
                cEFD += "|"
                cEFD += "|"+chr(13)+chr(10)
				
				nKey := ascan(aIpiEntradas,{|ckey| cKey[1] == ENT->Cfop})
					
					if nKey > 0
						aIpiEntradas[nKey,3] := aIpiEntradas[nKey,3] + ENT->Vlr_cont
						aIpiEntradas[nKey,4] := aIpiEntradas[nKey,4] + ENT->ipi_base
						aIpiEntradas[nKey,5] := aIpiEntradas[nKey,5] + ENT->ipi_vlr
					else
						aadd(aIpiEntradas,{ENT->cfop,"00",ENT->Vlr_cont,ENT->Ipi_base,ENT->Ipi_vlr})
					endif

                fwrite(nFile,cEFD,len(cEFD))
                ntot_lin++
                nTot_D++
                nTot_D100++
				
				i_registro_d190(nFile)
                
           
            endif

            ENT->(dbskip())

         enddo


         cEFD := ""



return

static function get(row,campo)
return  row:fieldget(campo)



