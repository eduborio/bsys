/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: setembro 2010
// OBS........:
// ALTERACOES.:

function cl584
#define K_MAX_LIN 57
#include "fileio.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI).or. lastkey()== 27 }

private cTITULO                   // titulo do relatorio
private XDRV_HB := "C:\QSYSTXT\"
private cFILE   := alltrim(left(XUSRIDT,7))
private dINI := ctod("01/01/2010")
private dFIM := qfimmes(date())
private nLIM := 0
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aAnoMes := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })


do while .T.

   qlbloc(5,0,"B584A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   //dINI := dFIM := ctod("")

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
           if dFIM < dINI
             return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "Variacao Mensal de Venda x Custo - 584 - Faturamento"

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->dt_emissao <= dFIM .and.  ! FAT->Cancelado .and. ( ! left(Cod_cfop,4) $ "5905-6905-1906-2906-1905-2905-5906-6906" ) .and. empty(num_fatura) .and. No_nf == .F. }))
   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))

return .T.


static function i_impressao

   i_impre_prn()

return

static function i_impre_prn
local aPED   := {}
local aDatas := {}
local aChina := {}
local aProd  := {}
local asPED  := {}
local aIds   := {}
local aLeft  := {}
local aResumo:= {}
local lTEM   := .F.
local cPROD  := "     "
local nQUANT := 0
local nCONT  := 0
local cINVOICE := ""
local lStartNewProduto := .F.
local uPosicao := 0
local nFile    := 0
local nPedido  := 0
local nEntregue:= 0
local cStyle := ""

   ////////////////////////////////////////////////////////////////////////////
   //PROCESSA PEDIDOS PENDENDES________________________________________________
   do while ! FAT->(eof())

      //qmensa("Aguarde... Processando ...")
      qgirabarra()

      if FAT->cancelado
         FAT->(dbskip())
         loop
      endif

      ITEN_FAT->(Dbseek(PED_FABR->Codigo))
      do while ITEN_FAT->Cod_ped == PED_FABR->Codigo .and. ! ITEN_FAT->(eof())
         if FAT->Es == "S"
            if left(FAT->Cod_Cfop,4) $ "5102-6102"
               aadd(aPED,{ITEN_FAT->Cod_prod,FAT->Dt_emissao,ITEN_FAT->Quantidade,0,0,0,ITEN_FAT->Vl_unitar,ITEN_FAT->Preco_cust})
            else
               aadd(aPED,{ITEN_FAT->Cod_prod,FAT->Dt_emissao,0,ITEN_FAT->Quantidade,0,0,ITEN_FAT->Vl_unitar,ITEN_FAT->Preco_cust})
            endif
         else
            if left(FAT->Cod_Cfop,4) $ "1202-2202"
               aadd(aPED,{ITEN_FAT->Cod_prod,FAT->Dt_emissao,0,0,ITEN_FAT->Quantidade,0,ITEN_FAT->Vl_unitar,ITEN_FAT->Preco_cust})
            else
               aadd(aPED,{ITEN_FAT->Cod_prod,FAT->Dt_emissao,0,0,0,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,ITEN_FAT->Preco_cust})
            endif
         endif
         ITEN_FAT->(Dbskip())
      enddo

      FAT->(dbskip())
   enddo

   //classifica a matriz por descricao do produto
   asPED := asort(aPED,,,{|x,y| x[1] + x[2] < y[1] + y[2]})
   aPED := {}

   if len(asPED) > 0
      cPROD := asPED[1,1]
      cDATA := asPED[1,2]

      nCONT := 1
      do while  nCONT <= len(asPED)
      
         qgirabarra()

         nQUANT += asPED[nCONT,3]

         nCONT++
         if nCONT > len(asPED)
            nCONT := len(asPED)
            exit
         endif

         if asPED[nCONT,1] + asPED[nCONT,2] != cPROD + cDATA
            aadd(aChina,{cPROD,cDATA,nQUANT})
            cPROD := asPED[nCONT,1]
            cDATA := asPED[nCONT,2]

            nQUANT := 0
         endif
      enddo

      if nQUANT > 0
         if asPED[nCONT,1] + asPED[nCONT,2] != cPROD + cDATA
            aadd(aChina,{cPROD,cDATA,nQUANT})
            cPROD := asPED[nCONT,1]
            cDATA := asPED[nCONT,2]
            nQUANT := 0
         endif
      endif

      nQUANT := 0
   endif

   //classifica a matriz por descricao do produto
   aChina := asort(aChina,,,{|x,y| x[1] + x[2] < y[1] + y[2]})

   PROD->(dbsetorder(4))

   if len(aChina) > 0
      nfile := fCreate("C:\Qsystxt\Vendas.xml",FC_NORMAL)
      xmlAbre(nFile)
      xmlCabecStyle(nFile,"Cabec")
      xmlFechaStyles(nfile)
      xmlAbrePasta(nFile,"Vendas")
      
      xmlAbreLinha(nFile)
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String",cTITULO,"Cabec")
      xmlFechaLinha(nFile)
      
      xmlAbreLinha(nFile)
        xmlCell(nFile,"String","Ref1","Cabec")
        xmlCell(nFile,"String","Ref2","Cabec")
        xmlCell(nFile,"String","Descricao","Cabec")
        GeraCabec(aAnomes,nFile)
        xmlCell(nFile,"String","Total","Cabec")
      xmlFechaLinha(nFile)

      nQUANT := 0
      cPROD := aChina[1,1]
      lStartNewProduto := .T.
      uPosicao := 0

      nCONT := 1
      do while  nCONT <= len(aChina)

         if lStartNewProduto
            PROD->(dbseek(cPROD))
            xmlAbreLinha(nFile)
            xmlCell(nFile,"String",left(PROD->cod_fabr,6))
            xmlCell(nFile,"String",PROD->cod_ass)
            xmlCell(nFile,"String",rtrim(PROD->Descricao))
            lStartNewProduto := .F.
         endif
         
         qgirabarra()

         nQUANT += aChina[nCONT,3]

         Escolhecoluna(aAnomes,aChina[nCont,2],@uPosicao,nFile)
         
         xmlCell(nFile,"Number",alltrim(transform(aChina[nCont,3],"@R 99999999")))
         
         nCONT++
         if nCONT > len(aChina)
            nCONT := len(aChina)
            exit
         endif

         if cPROD != aChina[nCONT,1]
            PreencheResto(aDatas,@uPosicao,nFile)
            xmlCell(nFile,"Number",alltrim(transform(nQUANT,"@R 9999999")))
            xmlFechaLinha(nFile)
            cPROD := aChina[nCONT,1]
            nQUANT := 0
            lStartNewProduto := .T.
            uPosicao := 0
         endif

      enddo

      PreencheResto(aDatas,@uPosicao,nFile)
      xmlCell(nFile,"Number",alltrim(transform(nQUANT,"@R 9999999")))
      xmlFechaLinha(nFile)
      xmlFechaPasta(nFile)
      xmlFecha(nFile)
      nQUANT := 0
      lStartNewProduto := .T.
      uPosicao := 0

   endif

return

static function EscolheColuna(aAnomes,sDATA,nPos,nFile)
local nCONT    := 0
local nIndexOf := 0
local nDif     := 0

   nIndexOf := ascan(aAnomes,sData)

   nDif := nIndexOf - nPos

   for nCONT := 1 to (nDIF-1)
       //@ prow(), pcol() say chr(9)+"     "
       xmlCell(nFile,"String","")
   next

   nPos := nIndexOf
return

static function PreencheResto(aAnomes,nPos,nFile)
local nCONT    := 0
local nResto   := 0

   nResto := len(aAnomes) - nPos

   for nCONT := 1 to nResto
       //@ prow(), pcol() say chr(9)+"     "
       xmlCell(nFile,"String","")
   next

return

static function xmlAbre(nfile)
local cXml := ""

	cXml := '<?xml version="1.0"?>'+chr(13)+chr(10)
	cXml += '<?mso-application progid="Excel.Sheet"?>'+chr(13)+chr(10)
	cXml += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+chr(13)+chr(10)
	cXml += 'xmlns:o="urn:schemas-microsoft-com:office:office"'+chr(13)+chr(10)
	cXml += 'xmlns:x="urn:schemas-microsoft-com:office:excel"'+chr(13)+chr(10)
	cXml += 'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+chr(13)+chr(10)
	cXml += 'xmlns:html="http://www.w3.org/TR/REC-html40">'+chr(13)+chr(10)
   fWrite(nFile,cXml,len(cXml))
   cXml := ""
   cXml := '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+chr(13)+chr(10)
   cXml += '<Author>Sistema Compras - Relatorio 525</Author>'+chr(13)+chr(10)
   cXml += '<LastAuthor>Sistema Compras - Relatorio 525</LastAuthor>'+chr(13)+chr(10)
   cXml += '<Created>'+ strzero(year(date()),4)+'-'+strzero(month(date()),2)+'-'+strzero(day(date()),2)+'T01:29:55Z</Created>'+chr(13)+chr(10)
   cXml += '<Company>EPB Informatica Ltda</Company>'+chr(13)+chr(10)
   cXml += '<Version>11.9999</Version>'+chr(13)+chr(10)
   cXml += '</DocumentProperties>'+chr(13)+chr(10)
   fWrite(nFile,cXml,len(cXml))
   cXml := ""
   cXml := '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
   cXml += '<WindowHeight>9240</WindowHeight>'+chr(13)+chr(10)
   cXml += '<WindowWidth>18195</WindowWidth>'+chr(13)+chr(10)
   cXml += '<WindowTopX>480</WindowTopX>'+chr(13)+chr(10)
   cXml += '<WindowTopY>120</WindowTopY>'+chr(13)+chr(10)
   cXml += '<ProtectStructure>False</ProtectStructure>'  +chr(13)+chr(10)
   cXml += '<ProtectWindows>False</ProtectWindows>'+chr(13)+chr(10)
   cXml += '</ExcelWorkbook>'+chr(13)+chr(10)
   cXml += '<Styles>'+chr(13)+chr(10)
   cXml += '<Style ss:ID="Default" ss:Name="Normal">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   cXml += '<Borders/>'+chr(13)+chr(10)
   cXml += '<Font/>'+chr(13)+chr(10)
   cXml += '<Interior/>'+chr(13)+chr(10)
   cXml += '<NumberFormat/>'+chr(13)+chr(10)
   cXml += '<Protection/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fWrite(nFile,cXml,len(cXml))
     

return

static function xmlAbrePasta(nFile,cNome)
local cXml := ""

    cXml := '<Worksheet ss:Name="'+cNome+'">'+chr(13)+chr(10)
    cXml += '<Table>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))

return

static function xmlFechaPasta(nFile,cNome)
local cXml := ""

    cXml := '</Table>'+chr(13)+chr(10)
    cXml += '</Worksheet>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))

return

static function xmlFecha(nFile)
local cXml := ""

    cXml := '</Workbook>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))
    fClose(nFile)
    
return

static function xmlAbreLinha(nFile)
local cXml := ""

	 cXml := '<Row>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlFechaLinha(nFile)
local cXml := ""

	 cXml := '</Row>' +chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlFechaStyles(nFile)
local cXml := ""

	 cXml := '</Styles>' +chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlCell(nFile,cTipo,cValor,cStyleID)
local cXml := ""
	 if cStyleID == NIL
	    cXml := '<Cell><Data ss:Type="'+cTipo+'">'+cValor+'</Data></Cell>'+chr(13)+chr(10)
	 else
	    cXml := '<Cell ss:StyleID="'+cStyleID+'"><Data ss:Type="'+cTipo+'">'+cValor+'</Data></Cell>'+chr(13)+chr(10)
	 endif   
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlCabecStyle(nFile,cNome)
local cXml := ""
	 cXml := '<Style ss:ID="Cabec">'+chr(13)+chr(10)
	 cXml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
	 cXml += '<Borders>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '</Borders>'+chr(13)+chr(10)
	 cXml += '<Font ss:Size="12" ss:Bold="1"/>'+chr(13)+chr(10)
	 cXml += '<Interior ss:Color="#AAAAAA" ss:Pattern="Solid"/>'+chr(13)+chr(10)
	 cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
	 cXml := ""
	 cXml := '<Style ss:ID="par">'+chr(13)+chr(10)
	 cXml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
    cXml += '<Borders/>'+chr(13)+chr(10)
    cXml += '<Font/>'+chr(13)+chr(10)
    cXml += '<Interior ss:Color="#DDDDDD" ss:Pattern="Solid"/>'+chr(13)+chr(10)
    cXml += '<NumberFormat/>'+chr(13)+chr(10)
    cXml += '<Protection/>'+chr(13)+chr(10)
    cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
	 cXml := ""
	 cXml := '<Style ss:ID="total">'+chr(13)+chr(10)
	 cXml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
    cXml += '<Borders/>'+chr(13)+chr(10)
    cXml += '<Font ss:Bold="1"/>'+chr(13)+chr(10)
    cXml += '<Interior/>'+chr(13)+chr(10)
    cXml += '<NumberFormat/>'+chr(13)+chr(10)
    cXml += '<Protection/>'+chr(13)+chr(10)
    cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function geraCabec(dINICIAL,dFINAL)
local nMESES  := 0
local intCONT   := 0
local cANOMES := 0
local nANOMES_INI := 0
local nANOMES_FIM := 0
local lFIRST := .T.
local cResult := ""
local lFisrt := .F.

cANOMES := strzero(year(dINICIAL),4)+strzero(month(dINICIAL),2)
nANOMES_INI := val(cANOMES)

cANOMES := strzero(year(dFINAL),4)+strzero(month(dFINAL),2)
nANOMES_FIM := val(cANOMES)

aAnomes := {}

lFirst := .T.

For intCONT := nANOMES_INI To nANOMES_FIM

    @ prow(),pcol() say  chr(9)+right(strzero(intCont,6),2)+"/"+left(strzero(intCont,6),4)

    aadd(aAnomes,strzero(intCONT,6))

    if right(strzero(intCONT),2) == "12"
       intCONT += 88
    endif

    nMESES++


next

return


