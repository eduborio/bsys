/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE FLUXO DE CAIXA (4)
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: FEVEREIRO DE 2011
// OBS........:
function ts525

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}
private cTITULO          // titulo do relatorio
private aEDICAO := {}    // vetor para os campos de entrada de dados
private dINI  := ctod("")
private dDATA_FIN  := ctod("")
private aDatas := {}
private XDRV_HB := "C:\QSYSTXT\"

sBLOC1 :=  qlbloc("B520B","QBLOC.GLO",1)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI                   ) } ,"INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM                   ) } ,"FIM" })

do while .T.

   qlbloc(05,0,"B520A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   dINI  := ctod("")
   dFIM  := ctod("")
   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_imprime() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "INI"
           if empty(dINI) ; return .F. ; endif
           dFIM := qfimmes(dINI)
           qrsay(XNIVEL+1,dFIM)

      case cCAMPO == "FIM"
           if empty(dFIM) ; return .F. ; endif
           if dINI > dFIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif
   endcase

return .T.


// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE FLUXO DE CAIXA  "


   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_imprime

   MontaDados()

return

static function montaDados
local nTotal     := 0
local cDia       := ""
local cPLAN      := ""
local cDATA      := ""
local nFile      := 0


  //delFlux()
  //delFlux2()


  criaFlux()
  criaFlux2()
  getSaldoCaixa()
  getSaldoBB()
  getSaldoReal()
  getEntradasCaixa()
  getSaidasCaixa()
  getEntradasBanco()
  getSaidasBanco()
  getReceber()
  getPagar()

  FLUX->(dbgotop())

  cANOMES := FLUX->Anomes
  cPLAN   := FLUX->Cod_plan
  cDIA    := FLUX->Dia
  nTotal  := 0

  do while ! FLUX->(eof())

     nTotal += FLUX->Valor

     FLUX->(dbskip())
     if (cANOMES + cPLAN + cDIA) != (FLUX->Anomes + FLUX->Cod_plan + FLUX->Dia)
        if FLUX2->(qappend())
           replace FLUX2->Anomes     with cAnomes
           replace FLUX2->Cod_plan   with cPLAN
           replace FLUX2->Dia        with cDIA
           replace FLUX2->Valor      with nTotal
           cANOMES := FLUX->Anomes
           cPLAN   := FLUX->Cod_plan
           cDIA    := FLUX->Dia
           nTotal  := 0
        endif
     endif

  enddo

  //qinitprn()


  nfile := fCreate(XDRV_HB+"Fluxo.xml",0)

  geraXml(nFile)




  //qstopprn(.F.)

  cPLAN  := ""
  cDATA  := ""
  cDIA   := ""
  nTotal := 0



return

static function getSaldoCaixa

   SALD_CAI->(dbgotop())

   do while ! SALD_CAI->(eof())

      if FLUX->(qappend())
         replace FLUX->Anomes      with    dtom(SALD_CAI->Data)
         replace FLUX->Cod_plan    with    "0CX"
         replace FLUX->Dia         with    strzero(day(SALD_CAI->Data),2)
         SALD_CAI->(dbskip())
         replace FLUX->Valor       with SALD_CAI->Saldo
         SALD_CAI->(dbskip(-1))
      endif

      SALD_CAI->(dbskip())
   enddo

return

static function getSaldoBB
   SALD_BAN->(dbsetfilter({|| cod_banco == "00016"}))
   SALD_BAN->(dbgotop())

   do while ! SALD_BAN->(eof())

      if FLUX->(qappend())
         replace FLUX->Anomes      with    dtom(SALD_BAN->Data)
         replace FLUX->Cod_plan    with    "0BB"
         replace FLUX->Dia         with    strzero(day(SALD_BAN->Data),2)
         SALD_BAN->(dbskip())
         replace FLUX->Valor       with SALD_BAN->Saldo
         SALD_BAN->(dbskip(-1))
      endif

      SALD_BAN->(dbskip())
   enddo

   SALD_BAN->(dbclearfilter())

return

static function getSaldoReal
   SALD_BAN->(dbsetfilter({|| cod_banco == "00018"}))
   SALD_BAN->(dbgotop())

   do while ! SALD_BAN->(eof())

      if FLUX->(qappend())
         replace FLUX->Anomes      with    dtom(SALD_BAN->Data)
         replace FLUX->Cod_plan    with    "0RE"
         replace FLUX->Dia         with    strzero(day(SALD_BAN->Data),2)
         SALD_BAN->(dbskip())
         replace FLUX->Valor       with SALD_BAN->Saldo
         SALD_BAN->(dbskip(-1))
      endif

      SALD_BAN->(dbskip())
   enddo

   SALD_BAN->(dbclearfilter())

return

static function getEntradasBanco
   local lDeduzir := .F.
   MOV_BANC->(dbsetfilter({|| Entrada > 0}))
   MOV_BANC->(dbgotop())

   do while ! MOV_BANC->(eof())

      if MOV_BANC->Conta_fin == "00020"
         MOV_BANC->(dbskip())
         loop
      endif

      if MOV_BANC->Conta_fin == "trans"
         MOV_BANC->(dbskip())
         loop
      endif


      if FLUX->(qappend())
         replace FLUX->Anomes      with dtom(MOV_BANC->Data)
         PLAN_FIN->(dbsetorder(3))
         if PLAN_FIN->(dbseek(MOV_BANC->Conta_fin))
            if left(PLAN_FIN->Codigo,2) == "02"
               lDeduzir := .T.
             endif
         endif

         replace FLUX->Cod_plan    with iif(!empty(MOV_BANC->Conta_fin),iif(!lDeduzir,"1","2")+MOV_BANC->Conta_fin,"1EN")
         replace FLUX->Dia         with strzero(day(MOV_BANC->Data),2)

         if lDeduzir
            replace FLUX->Valor       with MOV_BANC->Entrada*(-1)
         else
            replace FLUX->Valor       with MOV_BANC->Entrada
         endif
      endif
      lDeduzir := .F.

      MOV_BANC->(dbskip())
   enddo

   MOV_BANC->(dbclearfilter())

return

static function getSaidasBanco
   MOV_BANC->(dbsetfilter({|| Saida > 0}))
   MOV_BANC->(dbgotop())

   do while ! MOV_BANC->(eof())

      if MOV_BANC->Conta_fin == "00020"
         MOV_BANC->(dbskip())
         loop
      endif

      if MOV_BANC->Conta_fin == "trans"
         MOV_BANC->(dbskip())
         loop
      endif

      if FLUX->(qappend())
         replace FLUX->Anomes      with dtom(MOV_BANC->Data)
         replace FLUX->Cod_plan    with iif(!empty(MOV_BANC->Conta_fin),"2"+MOV_BANC->Conta_fin,"2SD")
         replace FLUX->Dia         with strzero(day(MOV_BANC->Data),2)
         replace FLUX->Valor       with MOV_BANC->Saida
      endif

      MOV_BANC->(dbskip())
   enddo

   MOV_BANC->(dbclearfilter())

return


static function getEntradasCaixa
   MOV_CAIX->(dbsetfilter({|| Entrada > 0}))
   MOV_CAIX->(dbgotop())

   do while ! MOV_CAIX->(eof())

      if MOV_CAIX->Conta_fin == "SAQUE"
         MOV_CAIX->(dbskip())
         loop
      endif

      if MOV_CAIX->Conta_fin == "trans"
         MOV_CAIX->(dbskip())
         loop
      endif


      if FLUX->(qappend())
         replace FLUX->Anomes      with dtom(MOV_CAIX->Data)

         replace FLUX->Cod_plan    with iif(!empty(MOV_CAIX->conta_fin),"1"+MOV_CAIX->conta_fin,"1EN")

         replace FLUX->Dia         with strzero(day(MOV_CAIX->Data),2)
         replace FLUX->Valor       with MOV_CAIX->Entrada
      endif

      MOV_CAIX->(dbskip())
   enddo

   MOV_CAIX->(dbclearfilter())

return

static function getSaidasCaixa
   MOV_CAIX->(dbsetfilter({|| Saida > 0}))
   MOV_CAIX->(dbgotop())

   do while ! MOV_CAIX->(eof())

      if MOV_CAIX->Conta_fin == "SAQUE"
         MOV_CAIX->(dbskip())
         loop
      endif

      if MOV_CAIX->Conta_fin == "trans"
         MOV_CAIX->(dbskip())
         loop
      endif


      if FLUX->(qappend())
         replace FLUX->Anomes      with dtom(MOV_CAIX->Data)
         replace FLUX->Cod_plan    with iif(!empty(MOV_CAIX->conta_fin),"2"+MOV_CAIX->conta_fin,"2SD")
         replace FLUX->Dia         with strzero(day(MOV_CAIX->Data),2)
         replace FLUX->Valor       with MOV_CAIX->Saida
      endif

      MOV_CAIX->(dbskip())
   enddo

   MOV_CAIX->(dbclearfilter())

return

static function getReceber

   RECEBER->(dbgotop())
   RECEBER->(dbsetorder(2))
   set softseek on
   RECEBER->(dbseek(dtos(ctod("01/01/2011"))))
   set softseek off

   do while ! RECEBER->(eof())

      if FLUX->(qappend())
         replace FLUX->Anomes      with    dtom(RECEBER->Data_venc)
         replace FLUX->Cod_plan    with    "1AR"
         replace FLUX->Dia         with    strzero(day(RECEBER->Data_venc),2)
         replace FLUX->Valor       with    RECEBER->Valor_liq
      endif

      RECEBER->(dbskip())
   enddo

return


static function getRecebidos

   RECEBIDO->(dbgotop())
   RECEBIDO->(dbsetorder(2))
   set softseek on
   RECEBIDO->(dbseek(dtos(ctod("01/01/2011"))))
   set softseek off

   do while ! RECEBIDO->(eof())

      if FLUX->(qappend())
         replace FLUX->Anomes      with    dtom(RECEBIDO->Data_venc)
         replace FLUX->Cod_plan    with    "1AR"
         replace FLUX->Dia         with    strzero(day(RECEBIDO->Data_venc),2)
         replace FLUX->Valor       with    RECEBIDO->Valor_liq
      endif

      RECEBIDO->(dbskip())
   enddo

   return

static function getRecebidosEfetivo

   RECEBIDO->(dbgotop())
   RECEBIDO->(dbsetorder(6))
   set softseek on
   RECEBIDO->(dbseek(dtos(ctod("01/01/2011"))))
   set softseek off

   do while ! RECEBIDO->(eof())

      if FLUX->(qappend())
         replace FLUX->Anomes      with    dtom(RECEBIDO->Data_pagto)
         replace FLUX->Cod_plan    with    "1RC"
         replace FLUX->Dia         with    strzero(day(RECEBIDO->Data_pagto),2)
         replace FLUX->Valor       with    RECEBIDO->Valor_liq
      endif

      RECEBIDO->(dbskip())
   enddo

return

static function getPagar

   PAGAR->(dbgotop())

   do while ! PAGAR->(eof())

      if FLUX->(qappend())
         replace FLUX->Anomes      with    dtom(PAGAR->Data_venc)
         replace FLUX->Cod_plan    with    "2PG"//PAGAR->Cod_plan
         replace FLUX->Dia         with    strzero(day(PAGAR->Data_venc),2)
         replace FLUX->Valor       with    PAGAR->Valor_liq
      endif

      PAGAR->(dbskip())
   enddo

return

static function criaFlux
  local aStruct := {}

  aStruct := { ;
             {"ANOMES"    ,"C",6 ,0},;
             {"COD_PLAN"  ,"C",6 ,0},;
             {"DIA"       ,"C",2 ,0},;
             {"VALOR"     ,"N",15,2};
             }

   dbCreate(XDRV_HB+"FLUX.DBF",aStruct)

   if ! Quse(XDRV_HB,"FLUX",{""},,"FLUX")
      qmensa("Erro ao criar arquivo temporario de Fluxo!","BL")
      return .F.
   endif

   index on ANOMES + COD_PLAN + DIA tag UM
   dbsetindex(XDRV_HB+"FLUX.CDX")


return


static function delFlux

   FLUX->(dbclosearea())

   if file(XDRV_HB+"FLUX.DBF")
      erase(XDRV_HB+"FLUX.DBF")
   endif

   if file(XDRV_HB+"FLUX.CDX")
      erase(XDRV_HB+"FLUX.CDX")
   endif

return


static function criaFlux2
  local aStruct := {}

  aStruct := { ;
             {"ANOMES"    ,"C",6 ,0},;
             {"COD_PLAN"  ,"C",6 ,0},;
             {"DIA"       ,"C",2 ,0},;
             {"VALOR"     ,"N",15,2};
             }

   dbCreate(XDRV_HB+"FLUX2.DBF",aStruct)

   if ! Quse(XDRV_HB,"FLUX2",{""},,"FLUX2")
      qmensa("Erro ao criar arquivo temporario de Fluxo!","BL")
      return .F.
   endif

   index on ANOMES + COD_PLAN + DIA tag UM
   dbsetindex(XDRV_HB+"FLUX2.CDX")


return


static function delFlux2

   FLUX2->(dbclosearea())

   if file(XDRV_HB+"FLUX2.DBF")
      erase(XDRV_HB+"FLUX2.DBF")
   endif

   if file(XDRV_HB+"FLUX2.CDX")
      erase(XDRV_HB+"FLUX2.CDX")
   endif

return

static function dtom(dData)
local cRet := ""
      cRet := strzero(year(dData),4)+strzero(month(dData),2)


return cRet

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
   cXml += '<Author>Rescisao de Contrato de Trabalho</Author>'+chr(13)+chr(10)
   cXml += '<LastAuthor>Rescisao de Contrato de Trabalho</LastAuthor>'+chr(13)+chr(10)
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
 //   cXml += '<Table ss:ExpandedColumnCount="35" ss:ExpandedRowCount="43" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="12.75">'+chr(13)+chr(10)
      cXml += '<Table>+chr(13)+chr(10) //ss:ExpandedColumnCount="35" ss:ExpandedRowCount="43" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="12.75">'+chr(13)+chr(10)
//    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="61.5"/>'+chr(13)+chr(10)
//    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="58.5"/>'+chr(13)+chr(10)
//    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="57"/>'+chr(13)+chr(10)
//    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="51"/>'+chr(13)+chr(10)
//    cXml += '<Column ss:Index="6" ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="57"/>'+chr(13)+chr(10)
//    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="55.5"/>'+chr(13)+chr(10)
//    cXml += '<Column ss:Index="9" ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="57"/>'+chr(13)+chr(10)

    fwrite(nFile,cXml,len(cXml))

return

static function xmlFechaPasta(nFile)
local cXml := ""

    cXml := '</Table>'+chr(13)+chr(10)
//    cXml += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
//    cXml += '<PageSetup>'+chr(13)+chr(10)
//    cXml += '<Header x:Margin="1.1811023622047245"/>'+chr(13)+chr(10)
//    cXml += '<Footer x:Margin="0.78740157480314965"/>'+chr(13)+chr(10)
//    cXml += '<PageMargins x:Bottom="0.78740157480314965" x:Left="0.39370078740157483" x:Top="0.98425196850393704" x:Right="0.39370078740157483"/>'+chr(13)+chr(10)
//    cXml += '</PageSetup>'+chr(13)+chr(10)
//    cXml += '<Unsynced/>'+chr(13)+chr(10)
//    cXml += '<Print>'+chr(13)+chr(10)
//    cXml += '<ValidPrinterInfo/>'+chr(13)+chr(10)
//    cXml += '<Scale>95</Scale>'+chr(13)+chr(10)
//    cXml += '<HorizontalResolution>600</HorizontalResolution>'+chr(13)+chr(10)
//    cXml += '<VerticalResolution>600</VerticalResolution>'+chr(13)+chr(10)
//    cXml += '</Print>'+chr(13)+chr(10)
   // cXml += '<ShowPageBreakZoom/>'+chr(13)+chr(10)
//    cXml += '<Selected/>'+chr(13)+chr(10)
//    cXml += '<Panes>'+chr(13)+chr(10)
//    cXml += '<Pane>'+chr(13)+chr(10)
//    cXml += '<Number>3</Number>'+chr(13)+chr(10)
//    cXml += '<RangeSelection>R1C1:R1C9</RangeSelection>'+chr(13)+chr(10)
//    cXml += '</Pane>'+chr(13)+chr(10)
//    cXml += '</Panes>'+chr(13)+chr(10)
//    cXml += '<ProtectObjects>False</ProtectObjects>'+chr(13)+chr(10)
//    cXml += '<ProtectScenarios>False</ProtectScenarios>'+chr(13)+chr(10)
//    cXml += '</WorksheetOptions>'+chr(13)+chr(10)
//    cXml += '<PageBreaks xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
//    cXml += '<RowBreaks>'+chr(13)+chr(10)
//    cXml += '<RowBreak>'+chr(13)+chr(10)
//    cXml += '<Row>39</Row>'+chr(13)+chr(10)
//    cXml += '</RowBreak>'+chr(13)+chr(10)
//    cXml += '</RowBreaks>'+chr(13)+chr(10)
//    cXml += '</PageBreaks>'+chr(13)+chr(10)
    cXml += '</Worksheet>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))

return

static function xmlFecha(nFile)
local cXml := ""

    cXml := '</Workbook>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))
    fClose(nFile)

return

static function xmlAbreLinha(nFile,cAutoFit,cHeight)
local cXml := ""

         if cAutoFit == NIL
            cAutofit := "0"
         endif

         if cHeight == NIL
            cXml := '<Row ss:AutoFitHeight="'+cAutofit+'">'+chr(13)+chr(10)
         else
            cXml := '<Row ss:AutoFitHeight="'+cAutofit+'" ss:Height="'+cHeight+'">'+chr(13)+chr(10)
         endif
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

static function xmlCell(nFile,cValor,cTipo,cStyleID,cMerge)
local cXml := ""

         if cMerge == NIL
            cMerge := "0"
         endif

         if cTipo == NIL
            cTipo := "String"
         endif


	 if cStyleID == NIL
            cXml := '<Cell ss:MergeAcross="'+cMerge+'"><Data ss:Type="'+cTipo+'">'+cValor+'</Data></Cell>'+chr(13)+chr(10)
	 else
            cXml := '<Cell ss:MergeAcross="'+cMerge+'" ss:StyleID="'+cStyleID+'"><Data ss:Type="'+cTipo+'">'+cValor+'</Data></Cell>'+chr(13)+chr(10)
	 endif
	 fwrite(nFile,cXml,len(cXml))
return


static function xmlTituloStyle(nFile)
local cXml := ""
         cXml := '<Style ss:ID="Titulo">'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
	 cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))

         cXml := '<Style ss:ID="SubTitulo">'+chr(13)+chr(10)
         cXml += '<Alignment ss:Horizontal="Right" ss:Vertical="Center"/>'+chr(13)+chr(10)
         cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         //cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Color="#FFFFFF" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#666699" ss:Pattern="Solid"/>'+chr(13)+chr(10)
         cXMl += '</Style>'+chr(13)+chr(10)
         fwrite(nFile,cXml,len(cXml))

         cXml := '<Style ss:ID="SubTituloDesc">'+chr(13)+chr(10)
         cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Center"/>'+chr(13)+chr(10)
         cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         //cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Color="#FFFFFF" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#666699" ss:Pattern="Solid"/>'+chr(13)+chr(10)
         cXMl += '</Style>'+chr(13)+chr(10)
         fwrite(nFile,cXml,len(cXml))

         cXml := '<Style ss:ID="Saldos">'+chr(13)+chr(10)
         cXml += '<Alignment ss:Horizontal="Right" ss:Vertical="Center"/>'+chr(13)+chr(10)
         cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         //cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Color="#000000" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#99CCFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
         cXMl += '</Style>'+chr(13)+chr(10)
         fwrite(nFile,cXml,len(cXml))

         cXml := '<Style ss:ID="SaldosDesc">'+chr(13)+chr(10)
         cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Center"/>'+chr(13)+chr(10)
         cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         //cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Color="#000000" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#99CCFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
         cXMl += '</Style>'+chr(13)+chr(10)
         fwrite(nFile,cXml,len(cXml))

         cXml := '<Style ss:ID="SaldoAtual">'+chr(13)+chr(10)
         cXml += '<Alignment ss:Horizontal="Right" ss:Vertical="Center"/>'+chr(13)+chr(10)
         cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         //cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Color="#000000" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
         cXMl += '</Style>'+chr(13)+chr(10)
         fwrite(nFile,cXml,len(cXml))

         cXml := '<Style ss:ID="SaldoAtualDesc">'+chr(13)+chr(10)
         cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Center"/>'+chr(13)+chr(10)
         cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         //cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Color="#000000" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
         cXMl += '</Style>'+chr(13)+chr(10)
         fwrite(nFile,cXml,len(cXml))

         cXml := '<Style ss:ID="Saida">'+chr(13)+chr(10)
         cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Center"/>'+chr(13)+chr(10)
         cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         //cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Color="#000000" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#CCFFCC" ss:Pattern="Solid"/>'+chr(13)+chr(10)
         cXMl += '</Style>'+chr(13)+chr(10)
         fwrite(nFile,cXml,len(cXml))

         cXml := '<Style ss:ID="ES">'+chr(13)+chr(10)
         cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Center"/>'+chr(13)+chr(10)
         cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         //cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Color="#000000" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#00CCFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
         cXMl += '</Style>'+chr(13)+chr(10)
         fwrite(nFile,cXml,len(cXml))

         cXml := '<Style ss:ID="Final">'+chr(13)+chr(10)
         cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Center"/>'+chr(13)+chr(10)
         cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         //cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Color="#000000" ss:Size="10" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#99CCFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
         cXMl += '</Style>'+chr(13)+chr(10)
         fwrite(nFile,cXml,len(cXml))






return

static function geraXml(nFile)
local cAnomes := ""
local cPlan   := ""
local aDias   := {}
local lStartNewPlano := .F.
local nTotal := 0
local uPosicao := 0
local dData := ctod("")
   local cGRupo := ""

    xmlAbre(nFile)
      xmlTituloStyle(nFile)
      xmlFechaStyles(nFile)
    //xmlAbrePasta(nFile,"")

    //FLUX2->(dbsetfilter(
    FLUX2->(dbgotop())
    FLUX2->(dbskip())

    xmlAbrePasta(nFile,right(FLUX2->Anomes,2)+" "+left(FLUX2->Anomes,4))
      xmlAbreLinha(nFile)
        xmlCell(nFile,"Fluxo de Caixa",,"Titulo")
      xmlFechaLinha(nFile)

      xmlAbreLinha(nFile)
        xmlCell(nFile,"Descricao",,"SubTituloDesc")
        for nCont := 1 to 31
            xmlCell(nFile,alltrim(str(nCont,2))+"/jan",,"SubTitulo")
            aadd(aDias,strzero(nCONT,2))
        next

        xmlCell(nFile,"Total",,"SubTitulo")

      xmlFechaLinha(nFile)

      xmlAbreLinha(nFile)
      xmlFechaLinha(nFile)


      xmlAbreLinha(nFile)
        xmlCell(nFile,"Saldo Anterior",,"SaldosDesc")
        for nCont := 1 to 31
            xmlCell(nFile,"0,00",,"Saldos")
        next

        xmlCell(nFile,"Total",,"SubTitulo")

      xmlFechaLinha(nFile)

      xmlAbreLinha(nFile)
      xmlFechaLinha(nFile)


      xmlAbreLinha(nFile)
        xmlCell(nFile,"Saldo Atual",,"SaldoAtualDesc")
        for nCont := 1 to 31
            xmlCell(nFile,"0,00",,"SaldoAtual")
        next

        xmlCell(nFile,"Total",,"SaldoAtual")

      xmlFechaLinha(nFile)


    lStartNewPlano := .T.
    uPosicao := 0

    cPLAN   := FLUX2->cod_Plan
    cAnomes := FLUX2->Anomes
    PLAN_FIN->(dbsetorder(3))

    do while ! FLUX2->(eof())

       if lStartNewPlano
          xmlAbreLinha(nFile)

          if PLAN_FIN->(dbseek(right(cPLAN,5)))
             xmlCell(nFile,PLAN_FIN->Descricao)
          else
             xmlCell(nFile,getRealNamePlan(cPLAN))
          endif

          lStartNewPlano := .F.
       endif

       nTotal += FLUX2->Valor

       Escolhecoluna(aDias,FLUX2->Dia,@uPosicao,nFile)

       xmlCell(nFile,alltrim(transf(FLUX2->Valor,"@R 999999999.99")))


       FLUX2->(dbskip())
       if (cANOMES + cPLAN) != (FLUX2->Anomes + FLUX2->cod_plan)
           PreencheResto(aDias,@uPosicao,nFile)
           //xmlCell(nFile,alltrim(transform(nTotal,"@E 999,999,999.99")))
           xmlFechaLinha(nFile)
           //cANOMES := FLUX2->Anomes
           cGrupo := left(cPLAN,1)
           if cGrupo != left(FLUX2->Cod_Plan,1)


            do case
               case cGrupo == "0"
                    xmlAbreLinha(nFile)
                    xmlFechaLinha(nFile)


                    xmlAbreLinha(nFile)
                      xmlCell(nFile,"Entradas",,"SaldoAtualDesc")
                      for nCont := 1 to 31
                         xmlCell(nFile,"",,"SaldoAtual")
                      next
                      xmlCell(nFile,"Total",,"SaldoAtualDesc")
                   xmlFechaLinha(nFile)

               case cGrupo == "1"
                    xmlAbreLinha(nFile)
                    xmlFechaLinha(nFile)


                    xmlAbreLinha(nFile)
                      xmlCell(nFile,"2. Total Entradas",,"SaldoAtualDesc")
                      for nCont := 1 to 31
                         xmlCell(nFile,"",,"SaldoAtual")
                      next
                      xmlCell(nFile,"Total",,"SaldoAtualDesc")
                    xmlFechaLinha(nFile)

                    xmlAbreLinha(nFile)
                    xmlFechaLinha(nFile)

                    xmlAbreLinha(nFile)
                      xmlCell(nFile,"Saidas",,"Saida")
                      for nCont := 1 to 31
                         xmlCell(nFile,"",,"Saida")
                      next
                      xmlCell(nFile,"Total",,"Saida")
                    xmlFechaLinha(nFile)


              case cGrupo == "2"
                    xmlAbreLinha(nFile)
                    xmlFechaLinha(nFile)


                    xmlAbreLinha(nFile)
                      xmlCell(nFile,"3. Total das Saidas",,"Saida")
                      for nCont := 1 to 31
                         xmlCell(nFile,"",,"Saida")
                      next
                      xmlCell(nFile,"Total",,"Saida")
                    xmlFechaLinha(nFile)

                    xmlAbreLinha(nFile)
                    xmlFechaLinha(nFile)

                    xmlAbreLinha(nFile)
                      xmlCell(nFile,"4. Entrada - Saidas",,"ES")
                      for nCont := 1 to 31
                         xmlCell(nFile,"",,"ES")
                      next
                      xmlCell(nFile,"Total",,"ES")
                    xmlFechaLinha(nFile)

                    xmlAbreLinha(nFile)
                    xmlFechaLinha(nFile)


                    xmlAbreLinha(nFile)
                      xmlCell(nFile,"5. Saldo Final",,"Final")
                      for nCont := 1 to 31
                         xmlCell(nFile,"",,"Final")
                      next
                      xmlCell(nFile,"Total",,"Final")
                    xmlFechaLinha(nFile)

               endcase

           endif
           cPLAN   := FLUX2->Cod_plan
           nTotal := 0
           lStartNewPlano := .T.
           uPosicao := 0

           if cANOMES  != FLUX2->Anomes
               //PreencheResto(aDias,@uPosicao,nFile)
               //xmlCell(nFile,alltrim(transform(nTotal,"@E 999,999,999.99")))
           //    xmlFechaLinha(nFile)
               xmlFechaPasta(nFile)

               xmlAbrePasta(nFile,FLUX2->Anomes)
               xmlAbreLinha(nFile)
                 xmlCell(nFile,"Fluxo de Caixa",,"Titulo")
               xmlFechaLinha(nFile)

               xmlAbreLinha(nFile)
                 xmlCell(nFile,"Descricao",,"SubTituloDesc")
                 aDias := {}
                 dData := qfimMes(ctod("01/"+right(FLUX2->Anomes,2)+"/"+left(FLUX2->Anomes,4)))
                 nDias := day(dData)

                 for nCont := 1 to nDias
                     xmlCell(nFile,alltrim(str(nCont,2))+"/"+left(lower(qnomemes(dData)),3),,"SubTitulo")
                     aadd(aDias,strzero(nCONT,2))
                 next

                 xmlCell(nFile,"Total",,"SubTitulo")

               xmlFechaLinha(nFile)

               xmlAbreLinha(nFile)
               xmlFechaLinha(nFile)


               xmlAbreLinha(nFile)
                 xmlCell(nFile,"Saldo Anterior",,"SaldosDesc")
                 for nCont := 1 to 31
                   xmlCell(nFile,"0,00",,"Saldos")
                 next
                 xmlCell(nFile,"Total",,"SubTitulo")
               xmlFechaLinha(nFile)

               xmlAbreLinha(nFile)
               xmlFechaLinha(nFile)


               xmlAbreLinha(nFile)
                  xmlCell(nFile,"Saldo Atual",,"SaldoAtualDesc")
                  for nCont := 1 to 31
                    xmlCell(nFile,"0,00",,"SaldoAtual")
                  next
                  xmlCell(nFile,"Total",,"SaldoAtual")
               xmlFechaLinha(nFile)


               cANOMES := FLUX2->Anomes
               cPLAN   := FLUX2->Cod_plan
               nTotal := 0
               lStartNewPlano := .T.
               uPosicao := 0
           endif


       endif



    enddo

    xmlFechaPasta(nFile)
    xmlFecha(nFile)


return

static function EscolheColuna(aDias,cDia,nPos,nFile)
local nCONT    := 0
local nIndexOf := 0
local nDif     := 0

   nIndexOf := ascan(aDias,cDia)

   nDif := nIndexOf - nPos

   for nCONT := 1 to (nDIF-1)
       xmlCell(nFile,"")
   next

   nPos := nIndexOf
return

static function PreencheResto(aDias,nPos,nFile)
local nCONT    := 0
local nResto   := 0

   nResto := len(aDias) - nPos

   for nCONT := 1 to nResto
       xmlCell(nFile,"")
   next

return

static function getRealNamePlan(cPlan)
local cRET := ""
cPLAN := alltrim(cPLAN)

   do case
      case cPlan == "0CX"
           cRET := "Saldo Caixa"

      case cPlan == "0BB"
           cRET := "Saldo Banco do Brasil"

      case cPlan == "0RE"
           cRET := "Saldo Banco Real"

      case cPlan == "1EN"
           cRET := "Recebimentos nao Identificados"

      case cPlan == "2SD"
           cRET := "Pagamentos nao Identificados"

      case cPlan == "1AR"
           cRET := "Clientes a Receber"

           case cPlan == "1RC"
           cRET := "Recebimento de Clientes"

      case cPlan == "2PG"
           cRET := "Contas a Pagar"

      case cPlan == "1ZZ"
           cRET := "Contas a Receber Vencidos"

      case cPlan == "1SAQUE"
           cRET := "Transferencia de Banco pro Caixa - Somente informativo"

      case cPlan == "2Trans"
           cRET := "Transferencia entre bancos - Somente informativo"



      //otherwise
      //     PLAN->(dbsetorder(1))
      //     PLAN_FIN->(dbseek(right(cPLAN,5)))
      //     cRET := PLAN_FIN->Descricao

   endcase


return cRET





