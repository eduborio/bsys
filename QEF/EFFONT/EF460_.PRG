/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Exportar arquivo p/ Sinco Fiscal - (Romero)
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO DE  2006
// OBS........:
// ALTERACOES.:

function ef460

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cICMS   := space(7)
private cIPI    := space(7)
private cEMP    := space(7)
private cTIPO   := space(2)
private cDRIVE  := space(2)
private cSISTEMA:= space(2)
private sBLOC1  := qlbloc("B460B","QBLOC.GLO")
private sBLOC2  := qlbloc("B430F","QBLOC.GLO")

if ! quse(XDRV_EF,"DOMINIO",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo DOMINIO.DBF !! Tente novamente.")
   return
endif

DOMINIO->(__dbzap())

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOC1)    } , "TIPO" })
aadd(aEDICAO,{{ || qesco(-1,0,@cDRIVE,sBLOC2)   } , "DRIVE"})


aadd(aEDICAO,{{ || lCONF := qconf("Confirma Exportacao de Arquivo Sinco Fiscal ?") },NIL})



do while .T.

   qlbloc(5,0,"B460A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI    := ctod("")
   dFIM    := ctod("")
   cICMS   := space(7)
   cIPI    := space(7)
   cEMP    := space(7)
   cTIPO   := space(2)
   cSISTEMA:= space(2)
   cDRIVE := ""

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_gravacao() , NIL )

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

      case cCAMPO == "TIPO"
           if empty(cTIPO) ;  return .F. ; Endif
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"1 - Entrada","2 - Saida"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := ""

   qmensa("")

   ENT->(dbsetorder(2))
   set SoftSeek On
   ENT->(dbseek(dINI))
   set SoftSeek off

   SAI->(dbsetorder(2))
   set SoftSeek On
   SAI->(dbseek(dINI))
   set SoftSeek off

return .T.


static function i_gravacao
   local   cDOMINIO :=  ""

   cDOMINIO := ""

   do case
      case cDRIVE == "A"
           cDRIVE := "A:"

      case cDRIVE == "C"
           cDRIVE := "C:\"

      case cDRIVE == "D"
           cDRIVE := "D:\"

      case cDRIVE == "E"
           cDRIVE := "E:\"

      case cDRIVE == "F"
           cDRIVE := "F:\"

      case cDRIVE == "G"
           cDRIVE := "C:\Windows\Desktop\"

      case cDRIVE == "H"
           cDRIVE := "C:\Docume~1\AllUse~1\Desktop\"

      case cDRIVE == "I"
           cDRIVE := "C:\users\AllUse~1\Desktop\"

   endcase

   if cTIPO == "1"
      i_entradas()
      cNOMARQ := cDRIVE+"Entradas.TxT"
      geraTxT(cNomArq)
   else
      i_saidas()
      cNOMARQ := cDRIVE+"Saidas.TxT"
      geraTxT(cNomArq)

   endif

   qmensa("Operacao Concluida!","BL")

return

static function i_entradas //Sinco Layout Simplificado
local nCONT := 1
local cCFOPS := ""

   cCFOPS := "1101-1102-1111-1113-1116-1117-1118-1120-1121-1122-1124-1125-1126"
   cCFOPS += "2101-2102-2111-2113-2116-2117-2118-2120-2121-2122-2124-2125-2126"
   cCFOPS += "1251-1252-1253-1254-1255-1256-1257"
   cCFOPS += "2251-2252-2253-2254-2255-2256-2257"
   cCFOPS += "1401-1403-1406-1407-1551-1556"
   cCFOPS += "2401-2403-2406-2407-2551-2556"

   do While ! ENT->(Eof()) .and. ENT->Data_lanc >= dINI .and. ENT->data_lanc <= dFIM


      if ! left(ENT->Cfop,4) $ cCFOPS
         ENT->(dbskip())
         loop
      endif

      if FORN->(dbseek(ENT->Cod_forn))
         cCNPJ := alltrim(FORN->cgcCpf)
         cCNPJ := iif(len(cCNPJ) == 11,cCNPJ + "   ",cCNPJ)
      else
         cCNPJ := space(14)
      endif

      cDOMINIO := cCNPJ
      cDOMINIO += strzero(Val(ENT->Serie),5)
      cDOMINIO += ENT->Num_nf
      cDOMINIO += qdata_sinco(ENT->Data_Emis)
      cDOMINIO += i_Valida(ENT->Vlr_cont,17)
      cDOMINIO += iif(ENT->cod_cont == "000001","1","2")
      cDOMINIO += space(45)
      cDOMINIO += left(ENT->Cfop,4)

      DOMINIO->(qappend())
      DOMINIO->Linha := cDOMINIO
      cDOMINIO := ""

      ENT->(dbskip())

      qmensa("Nota Fiscal.:"+ENT->Num_nf)

   enddo

return


static function i_saidas //Sinco Layout Simplificado
local nCONT := 1
local cCFOPS := ""

   cCFOPS := "5251-5252-5253-5254-5255-5256-5257"
   cCFOPS += "6251-6252-6253-6254-6255-6256-6257"
   cCFOPS += "5301-5302-5303-5304-5305-5306"
   cCFOPS += "5351-5352-5353-5354-5355-5356"
   cCFOPS += "6301-6302-6303-6304-6305-6306"
   cCFOPS += "6351-6352-6353-6354-6355-6356"
   cCFOPS += "5401-5402-5403-5405-5551"
   cCFOPS += "6401-6402-6403-6404-6551"

   do While ! SAI->(Eof()) .and. SAI->Data_lanc >= dINI .and. SAI->data_lanc <= dFIM


      if ! left(SAI->Cfop,3) $ "510-511-512-610-611-612" .and. ! left(ENT->Cfop,4) $ cCFOPS
         SAI->(dbskip())
         loop
      endif

      if CLI1->(dbseek(SAI->Cod_cli))
         cCNPJ := alltrim(CLI1->cgcCpf)
         cCNPJ := iif(len(cCNPJ) == 11,cCNPJ + "   ",cCNPJ)
      else
         cCNPJ := space(14)
      endif

      cCNPJ := ""

      if empty(cCNPJ) .or. cCNPJ == "              "
         if CNPJ->(dbseek(SAI->Num_nf))
            cCNPJ := CNPJ->Cnpj
            qmensa(cCnpj)
         else
            cCNPJ := space(14)
            alert("Falta CNPJ p/ NF.: "+SAI->Num_Nf)
         endif
      endif


      cDOMINIO := cCNPJ
      cDOMINIO += strzero(Val(SAI->Serie),5)
      cDOMINIO += SAI->Num_nf
      cDOMINIO += qdata_sinco(SAI->Data_Emis)
      cDOMINIO += i_Valida(SAI->Vlr_cont,17)
      cDOMINIO += iif(SAI->cod_cont == "000003","1","2")
      cDOMINIO += space(45)
      cDOMINIO += left(SAI->Cfop,4)

      DOMINIO->(qappend())
      DOMINIO->Linha := cDOMINIO
      cDOMINIO := ""

      SAI->(dbskip())

      qmensa("Nota Fiscal.:"+SAI->Num_nf)

   enddo

return

static Function i_valida(nVALOR,nNUM)
local cValor := ""
   cVALOR := strzero(val(qtiraponto(str(nVALOR,nNUM,2))),nNUM)

return cVALOR

static function qdata_sinco(dDATA)
 local dRET,cANO,cMES,cDIA
 cANO := strzero(year(dDATA),4)
 cMES := strzero(month(dDATA),2)
 cDIA := strzero(day(dDATA),2)
 dRET := cDIA +cMES + cANO
return  dRET

static function geraTxT(cDESTINO)
local cTEXTO := ""

   set printer to (cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)

   DOMINIO->(dbgotop())
   while ! DOMINIO->(eof())


          if DOMINIO->(recno()) == 1
              @ prow()  ,00 say left(DOMINIO->Linha,100)
          else
              @ prow()+1,00 say left(DOMINIO->Linha,100)
          endif

       DOMINIO->(dbskip())
   enddo
   set printer to
   set device to screen

return

