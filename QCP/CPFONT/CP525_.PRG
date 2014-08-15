/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: FLUXO EM EXCELL
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: janeiro DE 2011
// OBS........:
// ALTERACOES.:

function cp525
#define K_MAX_LIN 57
#include "fileio.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI).or. lastkey()== 27 }

private cTITULO                   // titulo do relatorio
private XDRV_HB := "C:\QSYSTXT\"
private cFILE   := alltrim(left(XUSRIDT,7))
private dINI := ctod("01/03/2005")
private dFIM := qfimmes(date())
private nLIM := 0
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })


do while .T.

   qlbloc(5,0,"B520A","QBLOC.GLO")
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


   cTITULO := "Controle de Pedidos de Importacao"

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________


   INVOICE->(dbsetorder(2)) // data de emissao
   INVOICE->(dbgotop())
   ITEN_INV->(dbsetorder(1))


   PED_FABR->(dbsetorder(2)) // data de emissao
   PED_FABR->(dbgotop())
   ITEN_PED->(dbsetorder(1))

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
   PED_FABR->(dbsetorder(2))
   PED_FABR->(dbgotop())
   do while ! PED_FABR->(eof())

      //qmensa("Aguarde... Processando ...")
      qgirabarra()

      if aScan(aDatas,dtos(PED_FABR->Data_ped)) == 0
         aadd(aDatas,dtos(PED_FABR->Data_ped))
      endif

      ITEN_PED->(Dbseek(PED_FABR->Codigo))
      do while ITEN_PED->Cod_ped == PED_FABR->Codigo .and. ! ITEN_PED->(eof())
         aadd(aPED,{ITEN_PED->Cod_prod,dtos(PED_FABR->Data_ped),ITEN_PED->Quantidade})
         ITEN_PED->(Dbskip())
      enddo

      PED_FABR->(dbskip())
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
//         if asPED[nCONT,1] + asPED[nCONT,2] != cPROD + cDATA
            aadd(aChina,{cPROD,cDATA,nQUANT})
            cPROD := asPED[nCONT,1]
            cDATA := asPED[nCONT,2]
            nQUANT := 0
//         endif
      endif

      nQUANT := 0
   endif

   //classifica a matriz por descricao do produto
   aChina := asort(aChina,,,{|x,y| x[1] + x[2] < y[1] + y[2]})

   PROD->(dbsetorder(4))

   cFileName := "Rel 525 - Left "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".xml"


   //qinitprn()

   if len(aChina) > 0
      nfile := fCreate("C:\Qsystxt\"+cFileNAme,FC_NORMAL)
      xmlAbre(nFile)
      xmlCabecStyle(nFile,"Cabec")
      xmlFechaStyles(nfile)
      xmlAbrePasta(nFile,"Pedidos")
      
      xmlAbreLinha(nFile)
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","Controle de Pedidos Mantra Brasil - (525) Compras","Cabec")
      xmlFechaLinha(nFile)
      
      xmlAbreLinha(nFile)
        xmlCell(nFile,"String","Ref1","Cabec")
        xmlCell(nFile,"String","Ref2","Cabec")
        xmlCell(nFile,"String","Descricao","Cabec")
        xmlCell(nFile,"String","Colecao","Cabec")
        xmlCell(nFile,"String","Fabrica","Cabec")
        GeraCabec(aDatas,nFile)
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
            xmlCell(nFile,"String",rtrim(PROD->Marca))
			   FABRICA->(dbseek(PROD->Fabr))
			   xmlCell(nFile,"String",rtrim(Fabrica->Razao))
		      lStartNewProduto := .F.
         endif
         
         qgirabarra()

         nQUANT += aChina[nCONT,3]

         Escolhecoluna(aDatas,aChina[nCont,2],@uPosicao,nFile)
         
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
            aadd(aLeft,{cPROD,nQuant,0,0})
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
      aadd(aLeft,{cPROD,nQuant,0,0})
      //xmlFecha(nFile)
      cPROD := aChina[nCONT,1]
      nQUANT := 0
      lStartNewProduto := .T.
      uPosicao := 0

   endif

   //qstopprn(.F.)

   asPED  := {}
   aPED   := {}
   aDatas := {}
   aInvoice := {}
   
   
   //PROCESSA COMERCIAL INVOICES________________________________________________
   INVOICE->(dbsetorder(2))
   INVOICE->(dbgotop())
   do while ! INVOICE->(eof())

      //qmensa("Aguarde... Processando ...")
      qgirabarra()

      if aScan(aDatas,dtos(INVOICE->Data_ped)) == 0
         aadd(aDatas,dtos(INVOICE->Data_ped))
         aadd(aIDs,INVOICE->Invoice)
      endif

      ITEN_INV->(Dbseek(INVOICE->Codigo))
      do while ITEN_INV->Cod_inv == INVOICE->Codigo .and. ! ITEN_INV->(eof())
         aadd(aPED,{ITEN_INV->Cod_prod,dtos(INVOICE->Data_ped),ITEN_INV->Quantidade,INVOICE->Invoice})
         ITEN_INV->(Dbskip())
      enddo

      INVOICE->(dbskip())
   enddo

   //classifica a matriz por descricao do produto
   asPED := asort(aPED,,,{|x,y| x[1] + x[2] < y[1] + y[2]})
   aPED := {}

   if len(asPED) > 0
      cPROD    := asPED[1,1]
      cINVOICE := asPED[1,2]

      nCONT := 1
      do while  nCONT <= len(asPED)

         nQUANT += asPED[nCONT,3]
         
         qgirabarra()

         nCONT++
         if nCONT > len(asPED)
            nCONT := len(asPED)
            exit
         endif

         if asPED[nCONT,1] + asPED[nCONT,2] != cPROD + cINVOICE
            aadd(aInvoice,{cPROD,cINVOICE,nQUANT})
            cPROD := asPED[nCONT,1]
            cINVOICE := asPED[nCONT,2]

            nQUANT := 0
         endif
      enddo

      if nQUANT > 0
  //       if asPED[nCONT,1] + asPED[nCONT,2] != cPROD + cINVOICE
            aadd(aInvoice,{cPROD,cINVOICE,nQUANT})
            cPROD := asPED[nCONT,1]
            cINVOICE := asPED[nCONT,2]
            nQUANT := 0
//         endif
      endif

      nQUANT := 0
   endif

   //classifica a matriz por descricao do produto
   aInvoice := asort(aInvoice,,,{|x,y| x[1] + x[2] < y[1] + y[2]})

   PROD->(dbsetorder(4))

   //qinitprn()

   if len(aInvoice) > 0
      //nfile := fCreate("C:\Qsystxt\Pedidos.xml",FC_NORMAL)
      //xmlAbre(nFile)
      xmlAbrePasta(nFile,"Comercial Invoices")
      
      xmlAbreLinha(nFile)
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","Controle de Comercial Invoices Mantra Brasil - (525) Compras","Cabec")
      xmlFechaLinha(nFile)
      
      xmlAbreLinha(nFile)
        xmlCell(nFile,"String","Ref1","Cabec")
        xmlCell(nFile,"String","Ref2","Cabec")
        xmlCell(nFile,"String","Descricao","Cabec")
        xmlCell(nFile,"String","Colecao","Cabec")
        xmlCell(nFile,"String","Fabrica","Cabec")
        GeraCabec(aDatas,nFile)
        xmlCell(nFile,"String","Total","Cabec")
      xmlFechaLinha(nFile)
      
      xmlAbreLinha(nFile)
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        GeraCabInvoices(aDatas,nFile,aIDs)
        xmlCell(nFile,"String","","Cabec")
      xmlFechaLinha(nFile)

      nQUANT := 0
      cPROD := aInvoice[1,1]
      lStartNewProduto := .T.
      uPosicao := 0

      nCONT := 1
      do while  nCONT <= len(aInvoice)

         if lStartNewProduto
            PROD->(dbseek(cPROD))
            xmlAbreLinha(nFile)
            xmlCell(nFile,"String",left(PROD->cod_fabr,6))
            xmlCell(nFile,"String",PROD->cod_ass)
            xmlCell(nFile,"String",rtrim(PROD->Descricao))
            xmlCell(nFile,"String",rtrim(PROD->Marca))
			   FABRICA->(dbseek(PROD->Fabr))
			   xmlCell(nFile,"String",rtrim(Fabrica->Razao))
		      lStartNewProduto := .F.
         endif

         qgirabarra()
         
         nQUANT += aInvoice[nCONT,3]

         Escolhecoluna(aDatas,aInvoice[nCont,2],@uPosicao,nFile)
         
         xmlCell(nFile,"Number",alltrim(transform(aInvoice[nCont,3],"@R 99999999")))
         
         nCONT++
         if nCONT > len(aInvoice)
            nCONT := len(aInvoice)
            exit
         endif

         if cPROD != aInvoice[nCONT,1]
            PreencheResto(aDatas,@uPosicao,nFile)
            xmlCell(nFile,"Number",alltrim(transform(nQUANT,"@R 9999999")))
            xmlFechaLinha(nFile)
            aadd(aLeft,{cPROD,0,nQuant,0})
            cPROD := aInvoice[nCONT,1]
            nQUANT := 0
            lStartNewProduto := .T.
            uPosicao := 0
         endif

      enddo

      PreencheResto(aDatas,@uPosicao,nFile)
      xmlCell(nFile,"Number",alltrim(transform(nQUANT,"@R 9999999")))
      xmlFechaLinha(nFile)
      xmlFechaPasta(nFile)
      aadd(aLeft,{cPROD,0,nQuant,0})
            
      cPROD := aInvoice[nCONT,1]
      nQUANT := 0
      lStartNewProduto := .T.
      uPosicao := 0
      
   endif


   if len(aChina) > 0

      nQUANT := 0
      cPROD := aChina[1,1]

      nCONT := 1
      do while  nCONT <= len(aChina)

         if (date() - ctod(formatDate(aChina[nCont,2])) ) <= 60
            nQUANT += aChina[nCONT,3]
         endif


         nCONT++
         if nCONT > len(aChina)
            nCONT := len(aChina)
            exit
         endif

         if cPROD != aChina[nCONT,1]
            aadd(aLeft,{cPROD,0,0,nQuant})
            cPROD := aChina[nCONT,1]
            nQUANT := 0
         endif

      enddo

      aadd(aLeft,{cPROD,0,0,nQuant})
      nQUANT := 0
      lStartNewProduto := .T.
      uPosicao := 0

   endif

   
   asPED  := {}
   aPED   := {}
   aDatas := {}
   aInvoice := {}
   cPROD := ""
   nQuant := 0
   lStartNewProduto := .F.
   
   aLeft := asort(aLeft,,,{|x,y| x[1] < y[1]})
   
   if len(aLeft) > 0
      cPROD    := aLeft[1,1]
      
      nCONT := 1
      do while  nCONT <= len(aLeft)

         nPedido   += aLeft[nCONT,2]
         nEntregue += aLeft[nCont,3]
         nQuant    += aLeft[nCont,4] // Qtde em 60dias pra obter total > 60 dias
         
         qgirabarra()

         nCONT++
         if nCONT > len(aLeft)
            nCONT := len(aLeft)
            exit
         endif

         if aLeft[nCONT,1] != cPROD 
            aadd(aResumo,{cPROD,nPedido,nEntregue,nQuant})
            cPROD := aLeft[nCONT,1]
            nPedido   := 0
            nEntregue := 0
            nQuant    := 0
         endif
      enddo

      if nQUANT > 0
  //       if aLeft[nCONT,1] != cPROD
            aadd(aResumo,{cPROD,nPedido,nEntregue,nQuant})
            cPROD := ""
            nQUANT := 0
 //        endif
      endif

      nQUANT  := 0
      nPedido  := 0
      nEntregue := 0
      aLeft := {}
   endif

   //classifica a matriz por descricao do produto
   aChina := asort(aChina,,,{|x,y| x[1] + x[2] < y[1] + y[2]})

   PROD->(dbsetorder(4))

   
   if len(aResumo) > 0
   
      xmlAbrePasta(nFile,"Left")
      
      xmlAbreLinha(nFile)
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","Controle Pedidos/Invoices/Left - (525) Compras","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
        xmlCell(nFile,"String","","Cabec")
      xmlFechaLinha(nFile)
      
      xmlAbreLinha(nFile)
        xmlCell(nFile,"String","Ref1","Cabec")
        xmlCell(nFile,"String","Ref2","Cabec")
        xmlCell(nFile,"String","Descricao","Cabec")
        xmlCell(nFile,"String","Colecao","Cabec")
        xmlCell(nFile,"String","Fabrica","Cabec")
        xmlCell(nFile,"String","Pedidos","Cabec")
        xmlCell(nFile,"String","Invoices","Cabec")
        xmlCell(nFile,"String","Left","Cabec")
        xmlCell(nFile,"String","Left Com Pedidos Acima de 60 dias","Cabec")
      xmlFechaLinha(nFile)
            
      for nCont := 1 to len(aResumo)
          xmlAbreLinha(nFile)
            PROD->(dbseek(aResumo[nCont,1]))
            if mod(nCont,2) == 0
               cStyle := NIL
            else
               cStyle := NIL
            endif
            
            xmlCell(nFile,"String",left(PROD->cod_fabr,6),cStyle)
            xmlCell(nFile,"String",PROD->cod_ass,cStyle)
            xmlCell(nFile,"String",rtrim(PROD->Descricao),cStyle)
            xmlCell(nFile,"String",rtrim(PROD->Marca),cStyle)
			   FABRICA->(dbseek(PROD->Fabr))
			   xmlCell(nFile,"String",rtrim(Fabrica->Razao),cStyle)
            xmlCell(nFile,"Number",alltrim(transf(aResumo[nCont,2],"@R 99999999")),cStyle)
            xmlCell(nFile,"Number",alltrim(transf(aResumo[nCont,3],"@R 99999999")),cStyle)
            nTotal := aResumo[nCont,2] - aResumo[nCont,3]
            xmlCell(nFile,"Number",alltrim(transf(nTotal,"@R 99999999")),"total")

            nQuant := aResumo[nCont,4]  // Total < 60 Dias

            if nQuant >= nTotal
               nQuant := 0
            else
               nQuant := nTotal - nQuant //Total faltando a entregar menos
                                         //o que foi pedidos a menos de 60 dias
                                         //igual a total pedido faltando com mais de 60 dias
            endif


            xmlCell(nFile,"Number",alltrim(transf(nQuant,"@R 99999999")),cStyle)
            xmlFechaLinha(nFile)
            
          qgirabarra()
                  
      next
      xmlFechaPasta(nFile)
      xmlFecha(nFile)
      alert("Arquivo Gerado!")
      
		nQUANT  := 0
      nPedido  := 0
      nEntregue := 0
      aResumo := {}
   endif



return

static function geraCabec(aDatas,nFile)
local nCont := 1

   for nCONT := 1 to len(aDatas)
       xmlCell(nFile,"String",formatDate(aDatas[nCont]),"Cabec")
   next

return

static function geraCabInvoices(aDatas,nFile,aIds)
local nCont := 1

   for nCONT := 1 to len(aDatas)
       xmlCell(nFile,"String"," No - "+aIds[nCONT],"Cabec")
   next

return

static function formatDate(cData)
local cDia := right(cData,2)
local cMes := substr(cData,5,2)
local cAno := left(cData,4)


return cDia+"/"+cMes+"/"+cAno

static function EscolheColuna(aDatas,sDATA,nPos,nFile)
local nCONT    := 0
local nIndexOf := 0
local nDif     := 0

   nIndexOf := ascan(aDatas,sData)

   nDif := nIndexOf - nPos

   for nCONT := 1 to (nDIF-1)
       //@ prow(), pcol() say chr(9)+"     "
       xmlCell(nFile,"String","")
   next

   nPos := nIndexOf
return

static function PreencheResto(aDatas,nPos,nFile)
local nCONT    := 0
local nResto   := 0

   nResto := len(aDatas) - nPos

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

