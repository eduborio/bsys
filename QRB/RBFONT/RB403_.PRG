/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: ENVIO DE DOCUMENTOS PARA O BANCO
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: OUTUBRO 2008
// OBS........:
// ALTERACOES.:

//#include "inkey.ch"
//#include "setcurs.ch"
function rb403

fu_abre_cli1()

CCUSTO->(Dbsetorder(4))
BANCO->(Dbsetorder(3))

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private dDATA_VENC := ctod("")
private aEDICAO1 := {}
private dDATA_INI  := ctod("")
private dDATA_FIN  := ctod("")
private nNUMERO
private nN_NUM := 900000
private nBANES := 0
private nCALCULO
private nTOT_VAL := 0
private cDT_EMIS   := space(1)
private dDATA_EM1  := ctod("")
private dDATA_EM2  := ctod("")
private cDT_VCTO   := space(1)
private dDATA_VC1  := ctod("")
private dDATA_VC2  := ctod("")
private cSITUA     := space(1)
private cSIT_COD   := space(2)
private cCLIENTE   := space(1)
private cCLI_COD   := space(5)
private cBANCO     := space(1)
private cBCO_COD   := space(5)
private fCOD_LAYOUT:= space(4)

// VIEW INICIAL _____________________________________________________________

//RECEBER->(dbSetFilter({|| empty(Receber->Cod_Banco) }))

RECEBER->(qview({{"Data_venc/Vcto"             ,2},;
                 {"Data_emiss/Emissao"         ,4},;
                 {"left(Cliente,15)/Cliente"   ,8},;
                 {"left(Fatura,9)/Fatura"      ,11},;
                 {"f_403()/  Valor"           , 0},;
                 {"fBoleto403()/Tipo"         , 0},;
                 {"Marcar/M"                  , 0},;
                 {"f403bank()/Banco"          , 0}},"P",;
                 {NIL,"f403a",NIL,NIL},;
                  NIL,"ESC/ALT-P/ALT-O/<C>on/<E>nvia/<M>arca ou desmarca"))


//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_403b
   CLI1->(dbseek(RECEBER->Cod_cli))
return left(CLI1->Razao,30)

function fboleto403
local cRET := "     "

   FAT->(dbsetorder(9))
   if  FAT->(dbseek(left(RECEBER->Fatura,6)+"55"))
       do while ! FAT->(eof()) .and. (FAT->num_fatura == left(RECEBER->Fatura,6) )
	      
		  if FAT->Dt_emissao == RECEBER->data_emiss   .and. FAT->Es =="S"
		     cRet := qabrev(FAT->Boleto,"123456789", {"Boleto","Vist Bol","Vist Dep","Antecip","Nulo","Plano Mkt","Abater Cr","Segurar","Praz Dep"})
		  endif	 
	   
	      FAT->(dbskip())
	   enddo
       
   else
       if FAT->(dbseek(left(RECEBER->Fatura,6)+"01"))
          cRet := qabrev(FAT->Boleto,"123456789", {"Boleto","Vist Bol","Vist Dep","Antecip","Nulo","Plano Mkt","Abater Cr","Segurar","Praz Dep"})
       else
          cRet := "         "
       endif
   endif
return cRet //qabrev(FAT->Boleto,"123456789", {"Boleto","Vist Bol","Vist Dep","Antecip","Nulo","Plano Mkt","Abater Cr","Segurar","Praz Dep"})

function f403bank
local cRet := "    "
   if BANCO->(dbseek(RECEBER->Cod_Banco))
      cRet := rtrim(BANCO->Banco)

      if cRet == "0356"
         cRET := "REAL"
      endif
	  
	  if cRet == "0033"
         cRET := "SANT"
      endif

      if cRet == "0001"
         cRET := "BB"
      endif

      if cRet == "0341"
         cRET := "ITAU"
      endif
	  
	  if cRet == "0399"
         cRET := "HSBC"
      endif

   else
      cRet := "    "
   endif

return cRet

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_403
return(transform(RECEBER->Valor_liq,"@E 9999999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f403a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(05,02,"B403A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_consulta()
   endif

   if cOPCAO == "M" ; i_marca()  ; return ; endif

   if cOPCAO == "F"
      i_filtra()
   endif

   if cOPCAO == "T"
      i_totaliza()
   endif

   if cOPCAO == "E"

      RECEBER->(dbsetfilter(marcar == "*"))
      RECEBER->(dbgotop())

      aEDICAO2   := {}
      XNIVEL     := 1
      XFLAG      := .T.
      fBANCO     := space(5)
      fCOD_LAYOUT := space(4)
      fFORM_PGTO := space(5)
      fNUM_LOTE  := space(5)
      bESCAPE    := {||lastkey()==27}
      lCONF      := .F.

      qlbloc(10,05,"B403C","QBLOC.GLO",1)

      aadd(aEDICAO2,{{ || NIL }                                         ,"NUM_LOTE"  })
      aadd(aEDICAO2,{{ || view_banco(-1,0,@fBANCO                   ) } ,"BANCO"     })
      aadd(aEDICAO2,{{ || NIL                                         } ,NIL         })
      aadd(aEDICAO2,{{ || view_layout(-1,0,@fCOD_LAYOUT             ) } ,"COD_LAYOUT" })
      aadd(aEDICAO2,{{ || NIL                                         } ,NIL         })

      aadd(aEDICAO2,{{ || lCONF := qconf("Confirma Envio ?") },NIL})

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO2)
         eval ( aEDICAO2 [XNIVEL,1] )
         if eval ( bESCAPE ) ; RECEBER->(qreleasefields()) ; return ; endif
         if ! i_crit2( aEDICAO2[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ;  return ; endif

      qmensa("Aguarde ... Gerando Lote de Cobran‡a...")  // grava o numero do lote nos lacamentos filtrados ...

      do while ! RECEBER->(eof())

         if RECEBER->Marcar == "*"
            if RECEBER->(qrlock())
               replace RECEBER->Cod_banco with fBANCO
               RECEBER->(qunlock())
            else
               qmensa("N„o foi possivel Travar o Registro - Tente Novamente ... ","B")
               return
            endif
         endif

         RECEBER->(dbskip())

      enddo

      RECEBER->(Dbgotop())

      qmensa("Aguarde... Criando arquivo CNAB ...")

      if i_gera_arq()
        qmensa("Arquivo CNAB Gerado com Sucesso !!", "B")
      else
        qmensa("N„o foi possovel Gerar Arquivo CNAB... Verifique !!", "B")
      endif

      qmensa()

   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A CONSULTA NA TELA _________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

      XNIVEL := 1
      qrsay ( XNIVEL++ , RECEBER->Codigo       )
      qrsay ( XNIVEL++ , RECEBER->Data_lanc    )
      qrsay ( XNIVEL++ , RECEBER->Cod_cli      ) ; CLI1->(dbseek(RECEBER->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))
      qrsay ( XNIVEL++ , RECEBER->Centro       ) ; CCUSTO->(dbseek(RECEBER->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , RECEBER->Filial       ) ; FILIAL->(dbseek(RECEBER->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , RECEBER->Data_emiss   )
      qrsay ( XNIVEL++ , RECEBER->Especie      ) ; ESPECIE->(dbseek(RECEBER->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , RECEBER->Serie        ) ; SERIE->(dbseek(RECEBER->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , RECEBER->Tipo_sub     ) ; TIPOCONT->(dbseek(RECEBER->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(RECEBER->Historico,60))
      qrsay ( XNIVEL++ , RECEBER->Data_venc    )
      qrsay ( XNIVEL++ , RECEBER->Data_prorr   )
      qrsay ( XNIVEL++ , transform(RECEBER->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , RECEBER->Tipo_doc     ) ; TIPO_DOC->(dbseek(RECEBER->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , RECEBER->Fatura       )
      qrsay ( XNIVEL++ , RECEBER->Duplicata    )
      qrsay ( XNIVEL++ , RECEBER->Cgm          ) ; CGM->(dbseek(RECEBER->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , RECEBER->Cod_Banco    ) ; BANCO->(Dbseek(RECEBER->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , RECEBER->Situacao     ) ; SITUA->(dbseek(RECEBER->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , RECEBER->Data_cont    )
      qrsay ( XNIVEL++ , RECEBER->Vendedor     ) //; FUN->(dbseek(RECEBER->Vendedor))
      //qrsay ( XNIVEL++ , left(FUN->Nome,40)    )
      qrsay ( XNIVEL++ ,  "       "   )
      qrsay ( XNIVEL++ , left(RECEBER->Observacao,59))

      qwait()

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit1 ( cCAMPO )

do case

      case cCAMPO == "DATA_VC2"
           if ! empty(cDT_VCTO)
              if dDATA_VC2 < dDATA_VC1
                 qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "BCO_COD"

           if ! empty(cBCO_COD)
              qrsay(17,24,cBCO_COD)

              if ! BANCO->(dbseek(cBCO_COD))
                 qmensa("Banco n„o Encontrado !","B")
                 return .F.
              else
                 qsay(17,32,left(BANCO->Descricao,20))
              endif
           endif


endcase


return .T.

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

do case

      case cCAMPO == "BANCO"
           qrsay(XNIVEL,fBANCO)

           if ! BANCO->(dbseek(fBANCO:=strzero(val(fBANCO),5)))
              qmensa("Banco n„o Encontrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(BANCO->Descricao,30))
           endif

      case cCAMPO == "COD_LAYOUT"

           if ! empty(fCOD_LAYOUT)
              qrsay(XNIVEL,fCOD_LAYOUT)

              if ! LAYOUT->(dbseek(fCOD_LAYOUT))
                 qmensa("Layout n„o Encontrado !","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(LAYOUT->Descricao,30))
              endif
           endif


endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB ___________________________________________

static function i_gera_arq

     local nBANCO := space(4)

     BANCO->(dbsetorder(3))
     BANCO->(dbseek(fBANCO))
     nBANCO := BANCO->Banco

     do case
        case BANCO->Banco == "0356"
          i_Real()
        case BANCO->Banco == "0341"
          i_itau()
        case BANCO->Banco == "0353"
          i_geralcom()
        case BANCO->Banco == "0291"
          i_crednac()
        case BANCO->Banco == "0033"
          i_santander()
        case BANCO->Banco == "0001"
          i_Banco_do_Brasil()
		case BANCO->Banco == "0399"
          i_hsbc()
        otherwise
          qmensa("Layout de Banco nao encontrado!","B")
          return .F.
     endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (BANESTADO) ______________________________

static function i_real

   local nSEQ  := 1 , cINTEG := "" , nVALOR := 0 , nTOT_VAL := 0
   local cNOMEARQ := ""
  // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_RB,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   // MONTA REGISTRO TIPO 0 (HEADER) ________________________________________

   LAYOUT->(Dbseek(fCOD_LAYOUT))


   cINTEG := "01REMESSA01COBRANCA       "+"0"
   cINTEG += left(LAYOUT->Ag_cede,4) +"0"
   cINTEG += left(LAYOUT->Conta_cede,7) + space(7)
   cINTEG += left(XRAZAO,30)+"356"
   cINTEG += "Banco Real     "
   cINTEG += ConvData(date(),2) + "01600BPI" + space(286) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // MONTA REGISTROS TIPO 1  _______________________________________________

   RECEBER->(dbgotop())

   do while ! RECEBER->(eof())

      qgirabarra()

      if RECEBER->Marcar != "*"
         RECEBER->(dbskip())
         loop
      endif

      nSEQ++

      cINTEG := "102" + qtiraponto(XCGCCPF) + "0"
      cINTEG += LAYOUT->Ag_cede +"0"
      cINTEG += LAYOUT->Conta_cede + space(7)
      cINTEG += space(25)+"00"
      cINTEG += "0000000"
      cINTEG += "0"    //Incidencia de Multa Sobre o Valor do titulo
      cINTEG += "00"   //Dias Pra Multa - apos Vencimento.
      cINTEG += "1"    //tipo De Multa-  Taxa
      cINTEG += convValor(LAYOUT->Perc_multa)+space(7)+space(9)+" "
      cINTEG += LAYOUT->Carteira+"5"+"01"
      cINTEG += left(RECEBER->Fatura,10)
      cINTEG += convData(RECEBER->Data_venc,2)
      cINTEG += convValor(RECEBER->Valor_liq)+"356"
      cINTEG += left(LAYOUT->Ag_cob,5)+"01"+"N"
      cINTEG += convData(RECEBER->Data_emiss,2)+LAYOUT->Dias_prot+"  "
      cINTEG += "1" //Tipo de Juros - Taxa
      cINTEG += convValor(LAYOUT->Perc_juros,12)+"      "+replicate("0",39)

      nVALOR += RECEBER->Valor_liq

      CLI1->(Dbseek(RECEBER->Cod_cli))

      if len(CLI1->Cgccpf) == 14
         cCGCCPF := "02"
      else
         cCGCCPF := "01"
      endif

      cINTEG += cCGCCPF

      if cCGCCPF == "02"
         cINTEG += CLI1->CgcCpf
      else
         cINTEG += left(CLI1->CgcCpf,9)+"000"+substr(CLI1->cgcCpf,10,2)
      endif

      cINTEG += left(CLI1->Razao,40)
      cINTEG += left(CLI1->End_cob,40)
      cINTEG += left(CLI1->Bairro_cob,12)
      cINTEG += left(CLI1->Cep_cob,8)

      CGM->(dbseek(CLI1->Cgm_cob))

      cINTEG += left(CGM->Municipio,15)
      cINTEG += left(CGM->Estado,2)+space(40)+"0"+"07"+strzero(nSEQ,6)


      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      //MENSAGEM DE PROTESTO NO BOLETO

      nSEQ++

      cINTEG := "8"
      cINTEG += "1"
      cINTEG += "0"
      cINTEG += LAYOUT->Ag_cede
      cINTEG += "0"
      cINTEG += LAYOUT->Conta_cede
      cINTEG += left(RECEBER->Fatura,10)
      cINTEG += LAYOUT->Msg_prot + space(29)
      cINTEG += "1"
      cINTEG += space(69)
      cINTEG += " "
      cINTEG += space(69)
      cINTEG += " "
      cINTEG += space(69)
      cINTEG += " "
      cINTEG += space(69)
      cINTEG += " "
      cINTEG += space(19)
      cINTEG +=strzero(nSEQ,6)

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      if RECEBER->(qrlock())
         replace RECEBER->Marcar with " "
         RECEBER->(Qunlock())
      endif


      RECEBER->(dbskip())

   enddo

   // MONTA REGISTRO TIPO 9 (TRAILLER) ______________________________________

   nSEQ++

   cINTEG := "9" + strzero(nSEQ-2,6) + convValor(nValor)
   cINTEG += space(374) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   qmensa("Aguarde...Gravando arquivo...","B")

   cNOMEARQ := "C:\QsysTxT\" + "B_Real.TXT"


   geraTxT(cNomeArq)

   //INTEGRA->(dbgotop())

   //INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   select RECEBER
   RECEBER->(dbgotop())

   nVALOR := 0

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (SAFRA) ______________________________

static function i_safra

   local nSEQ  := 1 , cINTEG := "" , nTOT_VAL := 0

   // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_RB,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   LAY_OUT->(Dbseek(BANCO->Banco))

   // MONTA REGISTRO TIPO 0 _________________________________________________

   cINTEG += "01REMESSA01COBRANCA       "+LAY_OUT->Insc_banco + space(6) + left(XRAZAO,30) + "422" + "BANCO SAFRA    " + qtiraponto(dtoc(XDATASYS))
   cINTEG += space(291) + "001" + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   RECEBER->(dbsetfilter())
   RECEBER->(dbgotop())

   RECEBER->(Dbsetorder(6)) // numero do lote
   RECEBER->(Dbseek(fNUM_LOTE))

   do while ! RECEBER->(eof()) .and. RECEBER->Num_lote == fNUM_LOTE

      nSEQ++

      FILIAL->(Dbseek(RECEBER->Filial))
      cCGCCPF := FILIAL->CGCCPF

      cINTEG := "1" + iif(len(cCGCCPF) == 14, "02" , "01" )  + strzero(val(cCGCCPF),14,0) + left(XRAZAO,14) + space(6) + space(25)
      cINTEG += left(RECEBER->Num_titulo,9) + space(30) + "0" + "00 00" + LAY_OUT->Carteira

      do case
         case LAY_OUT->Ocorrencia == "A"
              cOCORRENCIA := "01"
         case LAY_OUT->Ocorrencia == "B"
              cOCORRENCIA := "02"
         case LAY_OUT->Ocorrencia == "C"
              cOCORRENCIA := "03"
         case LAY_OUT->Ocorrencia == "D"
              cOCORRENCIA := "04"
         case LAY_OUT->Ocorrencia == "E"
              cOCORRENCIA := "05"
         case LAY_OUT->Ocorrencia == "F"
              cOCORRENCIA := "06"
         case LAY_OUT->Ocorrencia == "G"
              cOCORRENCIA := "07"
         case LAY_OUT->Ocorrencia == "H"
              cOCORRENCIA := "08"
         case LAY_OUT->Ocorrencia == "I"
              cOCORRENCIA := "09"
         case LAY_OUT->Ocorrencia == "J"
              cOCORRENCIA := "10"
         case LAY_OUT->Ocorrencia == "K"
              cOCORRENCIA := "11"
         case LAY_OUT->Ocorrencia == "L"
              cOCORRENCIA := "15"
         case LAY_OUT->Ocorrencia == "M"
              cOCORRENCIA := "16"
      endcase

      cINTEG += cOCORRENCIA + left(RECEBER->Num_titulo,10) + qtiraponto(dtoc(RECEBER->Data_venc)) + strzero(val(qtiraponto(str(RECEBER->Valor,12,2))),13)
      cINTEG += "422" + strzero(val(BANCO->Agencia),5,0) + strzero(val(LAY_OUT->Especie),2,0) + LAY_OUT->Aceito + qtiraponto(dtoc(RECEBER->Data_emiss))

      cINTEG +=  strzero(val(LAY_OUT->Instrucao),2,0) + strzero(val(LAY_OUT->Instrucao),2,0) + "0000000000000" + qtiraponto(dtoc(RECEBER->Data_venc))
      cINTEG += iif( RECEBER->Valor_1 <> 0, strzero( val(transform( RECEBER->Valor_1, "@e 9999999999999")),13) , "0000000000000") + strzero(val(transform(LAY_OUT->IOF, "@E 9999999999999")),13)
      cINTEG += "0000000000000"

      CLI1->(Dbseek(RECEBER->Cod_cli))

      iif ( len(CLI1->CGCCPF) == 14,  cINTEG += "02" , cINTEG += "01" )

      if CGM->(Dbseek(CLI1->Cgm_cob))
         cMUNICIPIO := left(CGM->Municipio,15)
         cUF := CGM->Estado
      else
         cMUNICIPIO := space(15)
         cUF := space(2)
      endif

      cINTEG += strzero(val(CLI1->Cgccpf),14,0) +  left(CLI1->Razao,40) + left(CLI1->End_cob,40) + space(10) + space(2) + CLI1->Cep_cob + cMUNICIPIO + cUF + space(30)
      cINTEG += "0000000" + space(3) +  "001" + strzero(nSEQ,6)

      nTOT_VAL := nTOT_VAL + RECEBER->Valor

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      RECEBER->(dbskip())

   enddo

   // MONTA REGISTRO TIPO 9 _________________________________________________

   nSEQ++

   cINTEG += "9" + space(367) + strzero((nSEQ-1),8) + strzero(nTOT_VAL,15) + "001" + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")

   cNOMARQ := alltrim(BANCO->Caminho) + "SAFRA" + strzero(day(date()),2) + ".TXT"

   INTEGRA->(dbgotop())

   INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   select RECEBER
   RECEBER->(dbgotop())
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (BANCO GERAL DO COMERCIO) ________________

static function i_geralcom

      local nSEQ  := 1 , cINTEG := "" , nTOT_VAL := 0

      // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

      if ! quse(XDRV_RB,"INTEGRA",NIL,"E")
         qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
         return
      endif

      INTEGRA->(__dbzap())

      LAY_OUT->(Dbseek(BANCO->Banco))

      // MONTA REGISTRO TIPO 0 _________________________________________________

      cINTEG := "01REMESSA01COBRANCA       "
      cINTEG += LAY_OUT->Agen_ceden + CONFIG->Conta_mov + CONFIG->Conta_cob + left(XRAZAO,30) + "353BANGERAL       " + qtiraponto(dtoc(XDATASYS))
      cINTEG += replicate("0",16) + space(275) + "001000001"

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      RECEBER->(dbsetfilter())
      RECEBER->(dbgotop())

      RECEBER->(Dbsetorder(6)) // numero do lote
      RECEBER->(Dbseek(fNUM_LOTE))

      do while ! RECEBER->(eof()) .and. RECEBER->Num_lote == fNUM_LOTE

         nSEQ++

         FILIAL->(Dbseek(RECEBER->Filial))
         cCGCCPF := FILIAL->CGCCPF

         cINTEG := "1" + iif(len(cCGCCPF) == 14, "02" , "01" )  + strzero(val(cCGCCPF),14,0) + LAY_OUT->Agen_ceden + CONFIG->Conta_mov + CONFIG->Conta_cob + space(25)

         nN_NUM++

         if LAY_OUT->CARTEIRA == "5"

            nNUMERO := left(LAY_OUT->Agen_ceden,3) + left(CONFIG->Conta_mov,6) + str(nN_NUM,6)

            i_calc_dig()

            cINTEG += nCALCULO

         else

           cINTEG += "00000000"

         endif

         cINTEG += "000000 4" + strzero(val(transform(RECEBER->Multa_per, "@R 9999")),4) + "000000000000000    000000"

         do case
            case LAY_OUT->Ocorrencia == "1"
               cOCORRENCIA := "01"
            case LAY_OUT->Ocorrencia == "2"
               cOCORRENCIA := "02"
            case LAY_OUT->Ocorrencia == "3"
               cOCORRENCIA := "04"
            case LAY_OUT->Ocorrencia == "4"
               cOCORRENCIA := "05"
            case LAY_OUT->Ocorrencia == "5"
               cOCORRENCIA := "06"
            case LAY_OUT->Ocorrencia == "6"
               cOCORRENCIA := "07"
            case LAY_OUT->Ocorrencia == "7"
               cOCORRENCIA := "08"
            case LAY_OUT->Ocorrencia == "8"
               cOCORRENCIA := "09"
            case LAY_OUT->Ocorrencia == "9"
               cOCORRENCIA := "18"
         endcase

         cINTEG += LAY_OUT->Carteira + cOCORRENCIA + left(LAY_OUT->Insc_banco,10) + qtiraponto(dtoc(RECEBER->Data_venc)) + strzero(val(transform(RECEBER->Valor, "9999999999999")),13)
         cINTEG += "353"

         if LAY_OUT->Carteira == "5"
            cINTEG += strzero(val(BANCO->Agencia),5,0)
         else
            cINTEG += "00000"
         endif

         do case
            case LAY_OUT->Especie == "1"
               cESPECIE := "01"
            case LAY_OUT->Especie == "2"
               cESPECIE := "02"
            case LAY_OUT->Especie == "3"
               cESPECIE := "03"
            case LAY_OUT->Especie == "4"
               cESPECIE := "05"
            case LAY_OUT->Especie == "5"
               cESPECIE := "06"
         endcase

         cINTEG += cESPECIE + "N" + qtiraponto(dtoc(RECEBER->Data_emiss))

         do case
            case LAY_OUT->Instrucao == "1"
               cINSTRUCAO := "00"
            case LAY_OUT->Instrucao == "2"
               cINSTRUCAO := "02"
            case LAY_OUT->Instrucao == "3"
               cINSTRUCAO := "03"
            case LAY_OUT->Instrucao == "4"
               cINSTRUCAO := "04"
            case LAY_OUT->Instrucao == "5"
               cINSTRUCAO := "06"
            case LAY_OUT->Instrucao == "6"
               cINSTRUCAO := "07"
            case LAY_OUT->Instrucao == "7"
               cINSTRUCAO := "08"
         endcase

         cINTEG +=  cINSTRUCAO + cINSTRUCAO + "0000000000000" + qtiraponto(dtoc(RECEBER->Data_venc))
         cINTEG += iif( RECEBER->Valor_1 <> 0, strzero( val(transform( RECEBER->Valor_1, "@e 9999999999999")),13) , "0000000000000") + strzero(val(transform(LAY_OUT->IOF, "@E 9999999999999")),13)
         cINTEG += "0000000000000"

         CLI1->(Dbseek(RECEBER->Cod_cli))

         if len(CLI1->CGCCPF) == 14
            cINTEG += "02"+CLI1->CGCCPF
         else
            cINTEG += "01"+ strzero(val(CLI1->CGCCPF),14,0)
            cINTEG += left(CLI1->Cgccpf,9) + "000" + right(CLI1->Cgccpf,2)
         endif

         if CGM->(Dbseek(CLI1->Cgm_cob))
            cMUNICIPIO := left(CGM->Municipio,15)
            cUF := CGM->Estado
         else
            cMUNICIPIO := space(15)
            cUF := space(2)
         endif

         cINTEG += iif(  CLI1->(Dbseek(RECEBER->Cod_cli))     ,    left(CLI1->Razao,40) + left(CLI1->End_cob,40) + space(12) + CLI1->Cep_cob + cMUNICIPIO + cUF  , space(117) )
         cINTEG += space(30) + space(10) + iif( cINSTRUCAO == "06" , LAY_OUT->Dias_multa , "00" ) + " " + strzero(nSEQ,6)

         nTOT_VAL := nTOT_VAL + RECEBER->Valor

         INTEGRA->(qappend())
         INTEGRA->Linha := cINTEG
         cINTEG := ""

         RECEBER->(dbskip())

      enddo

      // MONTA REGISTRO TIPO 9 _________________________________________________

      nSEQ++

      cINTEG += "9" + strzero(nSEQ,6) + strzero(nTOT_VAL,13) + replicate("0",374) + strzero(nSEQ,6)

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      // GRAVA ARQUIVO NO DISQUETE _____________________________________________

      qmensa("Aguarde...Gravando arquivo...","B")

      cNOMARQ := alltrim(BANCO->Caminho) + "GERCOM" + strzero(day(date()),2) + ".TXT"

      INTEGRA->(dbgotop())

      INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

      select RECEBER
      RECEBER->(dbgotop())

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (BANCO DE CREDITO NACIONAL) _______________

static function i_crednac

   local nSEQ  := 1 , cINTEG := "" , nVALOR := 0 , nTOT_VAL := 0

   // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_RB,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   // MONTA REGISTRO TIPO 0 (HEADER) ________________________________________

   LAY_OUT->(Dbseek(BANCO->Banco))

   cINTEG = "01REMESSA01COBRANCA       " + space(10) + left(BANCO->Agencia,3) + left(BANCO->Conta,6) + right(BANCO->Conta,1) + left(XRAZAO,30)
   cINTEG += "291B.C.N.         " + qtiraponto(dtoc(XDATASYS)) + "01600BPI" + space(280) + strzero(nSEQ,6) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // MONTA REGISTROS TIPO 1  _______________________________________________

   RECEBER->(dbsetfilter())
   RECEBER->(dbgotop())

   RECEBER->(Dbsetorder(6)) // numero do lote
   RECEBER->(Dbseek(fNUM_LOTE))

   do while ! RECEBER->(eof()) .and. RECEBER->Num_lote == fNUM_LOTE

      qgirabarra()

      nSEQ++

      cINTEG := "102" + qtiraponto(XCGCCPF) + space(10) + left(BANCO->Agencia,3) + left(BANCO->Conta,6) + right(BANCO->Conta,1) + space(25)
      cINTEG += space(12)

      nNUMERO := LAY_OUT->Noss_num

      i_noss_num()

      cINTEG += nCALCULO + space(25) + LAY_OUT->Carteira

      do case
         case LAY_OUT->Ocorrencia == "1"
              cOCORRENCIA := "01"
         case LAY_OUT->Ocorrencia == "2"
              cOCORRENCIA := "02"
         case LAY_OUT->Ocorrencia == "3"
              cOCORRENCIA := "04"
         case LAY_OUT->Ocorrencia == "4"
              cOCORRENCIA := "05"
         case LAY_OUT->Ocorrencia == "5"
              cOCORRENCIA := "06"
         case LAY_OUT->Ocorrencia == "6"
              cOCORRENCIA := "09"
         case LAY_OUT->Ocorrencia == "7"
              cOCORRENCIA := "18"
      endcase

      cINTEG += cOCORRENCIA + left(RECEBER->Num_titulo,10) + qtiraponto(dtoc(RECEBER->Data_venc)) + strzero(val(qtiraponto(str(RECEBER->Valor,12,2))),13)
      cINTEG += "29100000"

      do case
         case LAY_OUT->Especie == "1"
              cESPECIE := "01"
         case LAY_OUT->Especie == "2"
              cESPECIE := "02"
         case LAY_OUT->Especie == "3"
              cESPECIE := "03"
         case LAY_OUT->Especie == "4"
              cESPECIE := "05"
         case LAY_OUT->Especie == "5"
              cESPECIE := "99"
      endcase

      cINTEG += cESPECIE + LAY_OUT->Aceito + qtiraponto(dtoc(RECEBER->Data_emiss)) + "0000" + "0000000000000" + qtiraponto(dtoc(RECEBER->Data_venc))
      cINTEG += iif( RECEBER->Valor_1 <> 0, strzero( val(transform( RECEBER->Valor_1, "@e 9999999999999")),13) , "0000000000000")
      cINTEG += strzero(val(transform(LAY_OUT->Iof, "@E 9999999999999")),13) + "0000000000000"

      CLI1->(Dbseek(RECEBER->Cod_cli))

      if len(CLI1->Cgccpf) == 14
         cCGCCPF := "02"
      else
         cCGCCPF := "01"
      endif

      cINTEG += cCGCCPF + strzero(val(CLI1->Cgccpf),14,0) + left(CLI1->Razao,40)

      CGM->(Dbseek(CLI1->Cgm_cob))

      cINTEG += left(CLI1->End_cob,40) + space(12) + CLI1->Cep_cob + left(CGM->Municipio,15) + CGM->Estado + space(43) + strzero(nSEQ,6)

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      RECEBER->(dbskip())

   enddo

   // MONTA REGISTRO TIPO 9 (TRAILLER) ______________________________________

   nSEQ++

   cINTEG := "9" + space(393) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   qmensa("Aguarde...Gravando arquivo...","B")

   cNOMARQ := alltrim(BANCO->Caminho) + "CREDNA" + strzero(day(date()),2) + ".TXT"

   INTEGRA->(dbgotop())

   INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   select RECEBER
   RECEBER->(dbgotop())

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (BANCO BANESPA ) __________________________

static function i_santander

    local nLin  := 1  
    local cIntegra := ""
    local nFile := 0
    
	local cCarteira := ""
	local cConta    := ""
	local cAgencia   := ""
	local cFilename  := ""
	
	local nReg := 0
	local nTotal := 0
  

   // MONTA REGISTRO TIPO 0 (HEADER) ________________________________________

  

   cIntegra := "01REMESSA01COBRANCA" +space(7) + "45240447058301300042" + left(FILIAL->Razao,30)
   cIntegra += "033SANTANDER" + space(6) + dtSantander(date()) + replicate("0",16) + space(275) + "000" + strzero(nLin,6) + chr(13)+chr(10)

   // MONTA REGISTROS TIPO 1  _______________________________________________

     ///////////////////////////////////////////////////
     // Registro 1_____________________________________

     RECEBER->(dbgotop())
     do while ! RECEBER->(eof())

        qgirabarra()

        if RECEBER->Marcar != "*"
           RECEBER->(dbskip())
           loop
        endif

      nLin++

      cIntegra += "102" + qtiraponto(FILIAL->Cgccpf) + "45240447058301300042" + left(RECEBER->Fatura,10) + space(15) + replicate("0",8) + replicate("0",6) + " " +"40200" //Termina em multa 78- 79 a 82 perc da multa
	  
	  cIntegra += "00" + replicate("0",13) + "    " + replicate("0",6) + "1" + "01" + left(RECEBER->Fatura,10) + dtSantander(RECEBER->Data_venc) + convValor(RECEBER->Valor_liq,13) + "033" //Termina em codigo do banco 140 a 142
	  
	  nTotal += RECEBER->Valor_liq 
	  cIntegra += "00000" + "01" + "N" + dtSantander(RECEBER->Data_emiss) + "06" + "00"  
	  
	  cIntegra +=  convValor(RECEBER->Valor_liq * 0.0033,13) + replicate("0",6) + replicate("0",13) + replicate("0",13) + replicate("0",13) 

            
	  CLI1->(Dbseek(RECEBER->Cod_cli))

      if len(alltrim(CLI1->Cgccpf)) == 14
         cCGCCPF := "02"
      else
         cCGCCPF := "01"
      endif

      cIntegra += cCgcCpf

      if cCgccpf == "02"
         cIntegra += CLI1->Cgccpf
      else
         cIntegra += "000"+left(CLI1->Cgccpf,11)
      endif

	  cIntegra += left(CLI1->Razao,40) 
	  
	  cIntegra += left(CLI1->End_cob,30) + CLI1->Num_cob + space(3)

	  cIntegra += left(Cli1->Bairro_cob,12)

	  cIntegra += Cli1->cep_cob

	  CGM->(dbseek(CLI1->Cgm_cob))

	  cIntegra += left(CGM->Municipio,15)

	  cIntegra += CGM->Estado
	                                          //Protesto 
	  cIntegra += space(31) + "I09" + space(6) + "05" + " " + strzero(nLin,6) + chr(13) + chr(10)
	  
	  if RECEBER->(qrlock())
         replace RECEBER->Marcar with " "
         RECEBER->(Qunlock())
       endif
         

       RECEBER->(dbskip())

   enddo
   
   nLin++
  
   cIntegra += "9" + strzero(nLin,6) + convValor(nTotal,13) + replicate("0",374) + strzero(nLin,6) + chr(13)+chr(10)

   cFileName := "Remessa Santander - "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".txt"

   nFile := fcreate("C:\qsystxt\"+cFileName,0)

   fwrite(nFile,cIntegra,len(cIntegra))

   fClose(nFile)
   
   RECEBER->(dbgoto(nReg))

   
   
return

///////////////////////////////////////////////////////////////////////////////////////
function i_calc_dig

   local nCONT := 1
   local nVAR  := 2
   local nDIG1 := 0
   local nSOMA := 0

   for nCONT := 15 to 1 step -1

       if nVAR = 10
          nVAR := 2
       endif

       nSOMA := nSOMA + val(substr(nNUMERO,nCONT,1)) * nVAR
       nVAR++

   next

   nDIG1 := mod((nSOMA * 10),11)
   nDIG1 := alltrim(str(nDIG1))

   nNUMERO := nNUMERO + left(nDIG1,1)

   // inicializa as variaveis controladoras

   nCONT := 1
   nVAR  := 2
   nSOMA := 0

   for nCONT := 16 to 1 step -1

       if nVAR = 10
          nVAR := 2
       endif

       nSOMA := nSOMA + val(substr(nNUMERO,nCONT,1)) * nVAR
       nVAR++

   next

   nDIG2 := mod((nSOMA * 10),11)
   nDIG2 := alltrim(str(nDIG2))

   nCALCULO := str(nN_NUM,6) + left(nDIG1,1) + left(nDIG2,1)

return

///////////////////////////////////////////////////////////////////////////////////////
//
function i_calc

   local nCONT := 1
   local nVAR  := 9
   local nDIG1 := 0
   local nSOMA := 0

   for nCONT := 9 to 1 step -1

       if nVAR = 5
          nVAR := 9
       endif

       nSOMA := nSOMA + val(substr(str(nBANES,9),nCONT,1)) * nVAR
       nVAR--

   next

   nDIG1 := mod((nSOMA),11)
   nDIG1 := alltrim(str(nDIG1))

   if left(nDIG1,2) == "10"
      nBANES += 1
      i_calc()
   endif

   nCALCULO := strzero(val(transform(nBANES, "@R 999999999")),9) + left(nDIG1,1)

return

//////////////////////////////////////////////////////////////////
// calculo do digito do nosso numero do banco de credito nacional
function i_noss_num

   local nCONT := 1
   local nVAR  := 8
   local nDIG1 := 0
   local nSOMA := 0

   for nCONT := 1 to 7 

       if nVAR = 1
          nVAR := 8
       endif

       nSOMA := nSOMA + val(substr(nNUMERO,nCONT,1)) * (nVAR*10)
       nVAR--

   next

   nDIG1 := mod((nSOMA),11)
   nDIG1 := alltrim(str(nDIG1))

   if nDIG1 == "10"
      nDIG1 := 0
   endif

   nCALCULO := strzero(val(transform(nNUMERO, "@R 9999999")),7) + left(nDIG1,1)

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A MARCACAO PARA LIBERACAO ______________________________

static function i_marca
   if RECEBER->(qrlock())
      if RECEBER->Marcar == "*"
         replace RECEBER->Marcar with " "
      else
         replace RECEBER->Marcar with "*"
      endif
   endif
return

static function i_filtra
      aEDICAO1   := {}
      XNIVEL     := 1
      XFLAG      := .T.

      bESCAPE    := {||lastkey()==27}
      lCONF      := .F.

      qlbloc(10,13,"B403B","QBLOC.GLO",1)

      aadd(aEDICAO1,{{ || qgetx(13,15,@dDATA_EM1 , "@D"                    )},"DATA_EM1"  })
      aadd(aEDICAO1,{{ || qgetx(13,28,@dDATA_EM2 , "@D"                    )},"DATA_EM2"  })
      aadd(aEDICAO1,{{ || qgetx(13,41,@dDATA_VC1 , "@D"                    )},"DATA_VC1"  })
      aadd(aEDICAO1,{{ || qgetx(13,54,@dDATA_VC2 , "@D"                    )},"DATA_VC2"  })
      aadd(aEDICAO1,{{ || view_situa(15,25,@cSIT_COD, "99"                 )} ,"SIT_COD"  })
      aadd(aEDICAO1,{{ || NIL                                               } ,NIL        })
      aadd(aEDICAO1,{{ || view_cli(16,24,@cCLI_COD, "99999"                )} ,"CLI_COD"  })
      aadd(aEDICAO1,{{ || NIL                                               } ,NIL        })
      aadd(aEDICAO1,{{ || view_banco(17,24,@cBCO_COD, "99999"              )} ,"BCO_COD"  })
      aadd(aEDICAO1,{{ || NIL                                               } ,NIL        })

      aadd(aEDICAO1,{{ || lCONF := qconf("Confirma Filtro ?") },NIL})

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
         eval ( aEDICAO1 [XNIVEL,1] )
         if eval ( bESCAPE ) ; RECEBER->(qreleasefields()) ; return ; endif
         if ! i_crit1( aEDICAO1[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ;  return ; endif

      RECEBER->(Dbsetfilter())

      do case

         case ! empty(dDATA_EM1) .and. ! empty(dDATA_EM2)
              RECEBER->(dbSetFilter({|| Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2}, 'Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2'))
              RECEBER->(dbgotop())

         case ! empty(dDATA_EM1) .and. ! empty(dDATA_EM2) .and. ! empty(cSIT_COD)
              RECEBER->(dbSetFilter({|| Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Situacao == cSIT_COD}, 'Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Situacao == cSIT_COD'))
              RECEBER->(dbgotop())

         case ! empty(dDATA_EM1) .and. ! empty(dDATA_EM2) .and. ! empty(cCLI_COD)
              RECEBER->(dbSetFilter({|| Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Cod_cli == cCLI_COD}, 'Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Cod_cli == cCLI_COD'))
              RECEBER->(dbgotop())

         case ! empty(dDATA_EM1) .and. ! empty(dDATA_EM2) .and. ! empty(cBCO_COD)
              RECEBER->(dbSetFilter({|| Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Codbanco == cBCO_COD}, 'Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Codbanco == cBCO_COD'))
              RECEBER->(dbgotop())

         case ! empty(cCLI_COD) .and. ! empty(cBCO_COD) .and. ! empty(cSIT_COD)
              RECEBER->(dbSetFilter({|| Cod_cli == cCLI_COD .and. Codbanco == cBCO_COD .and. Situacao == cSIT_COD}, 'Cod_cli === cCLI_COD .and. Codbanco == cBCO_COD .and. Situacao == cSIT_COD'))
              RECEBER->(dbgotop())

         case ! empty(dDATA_VC1) .and. ! empty(dDATA_VC2)
              RECEBER->(dbSetFilter({|| Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2}, 'Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2'))
              RECEBER->(dbgotop())

         case ! empty(dDATA_VC1) .and. ! empty(dDATA_VC2) .and. ! empty(cSIT_COD)
              RECEBER->(dbSetFilter({|| Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Situacao == cSIT_COD}, 'Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Situacao == cSIT_COD'))
              RECEBER->(dbgotop())

         case ! empty(dDATA_VC1) .and. ! empty(dDATA_VC2) .and. ! empty(cCLI_COD)
              RECEBER->(dbSetFilter({|| Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Cod_cli == cCLI_COD}, 'Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Cod_cli == cCLI_COD'))
              RECEBER->(dbgotop())

         case ! empty(dDATA_VC1) .and. ! empty(dDATA_VC2) .and. ! empty(cBCO_COD)
              RECEBER->(dbSetFilter({|| Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Codbanco == cBCO_COD}, 'Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Codbanco == cBCO_COD'))
              RECEBER->(dbgotop())

         case ! empty(cSIT_COD)
              RECEBER->(dbSetFilter({|| Situacao == cSIT_COD}, 'Situacao == cSIT_COD'))
              RECEBER->(dbgotop())

         case ! empty(cCLI_COD)
              RECEBER->(dbSetFilter({|| Cod_cli == cCLI_COD}, 'Cod_cli == cCLI_COD'))
              RECEBER->(dbgotop())

         case ! empty(cBCO_COD)
              RECEBER->(dbSetFilter({|| Cod_banco == cBCO_COD}, 'Cod_banco == cBCO_COD'))
              RECEBER->(dbgotop())

      endcase

return

static function i_totaliza
      XNIVEL   := 1
      nTOT_BRU := nTOT_LIQ := nTOT_GER := 0
      lSAI     := .F.

      cCOD := RECEBER->Codigo

      qmensa("Aguarde... totalizando...")

      RECEBER->(dbgotop())

      do while ! RECEBER->(eof())

         if RECEBER->Codigo == cCOD
            lSAI := .T.
         endif

         if ! empty(RECEBER->Valor_1)
            nTOT_LIQ += ( RECEBER->Valor - RECEBER->Valor_1)
            nTOT_GER += ( RECEBER->Valor - RECEBER->Valor_1)
         else
            nTOT_BRU += RECEBER->Valor
            nTOT_GER += RECEBER->Valor
         endif

         if lSAI
            exit
         endif

         RECEBER->(Dbskip())

      enddo

      qlbloc(10,13,"B403D","QBLOC.GLO",1)
      qrsay(XNIVEL  ,transform(nTOT_BRU, "@R 999,999,999.99"))
      qrsay(XNIVEL+1,transform(nTOT_LIQ, "@R 999,999,999.99"))
      qrsay(XNIVEL+2,transform(nTOT_GER, "@R 999,999,999.99"))
      qwait()
      RECEBER->(dbgotop())
      nTOT_LIQ := nTOT_BRU := nTOT_GER := 0



return

static function i_Banco_do_Brasil
local cNOSSO_NUMERO := ""
local cCONTROLE := ""
local nSEQ := 0

   // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_RB,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   // MONTA REGISTRO TIPO 0 (HEADER) ________________________________________

   cINTEG := "00"
   cINTEG += "02"
   cINTEG += FILIAL->Cgccpf
   cINTEG += left(FILIAL->Razao,30)
   cINTEG += replicate("0",452)
   nSEQ++

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // MONTA REGISTROS TIPO 1  _______________________________________________

   RECEBER->(Dbgotop())

   cNOSSO_NUMERO  := replicate("0",20)
   cCONTROLE      := replicate(" ",25)

   do while ! RECEBER->(eof())

      qgirabarra()

      if RECEBER->Marcar != "*"
         RECEBER->(dbskip())
         loop
      endif

      cINTEG := "01"
      cINTEG += "      "           // 6  chr (preencher com zeros a esquerda se necessario)
      cINTEG += LAYOUT->Carteira   // 2  chr                      ""
      cINTEG += LAYOUT->Variacao   // 3  chr                      ""
      cINTEG += left(RECEBER->fatura,10)    // 10 chr (alinhar a esquerda com brancos ao final)
      cINTEG += cNOSSO_NUMERO      // Ver Layout permite 20 zeros
      cINTEG += cCONTROLE          // 25  chr permite brancos
      cINTEG += LAYOUT->Sigla      // 5   chr "DM" - Duplicata Mercantil - brancos no final
      cINTEG += convData(RECEBER->Data_emiss) // 8 chr Data de Emissao
      cINTEG += convData(RECEBER->Data_venc)  // 8 chr Data de Vencimento
      cINTEG += convValor(RECEBER->Valor_liq) // 13 chr 13,2
      cINTEG += "09   "       // 5 "09" pra reais
      cINTEG += "0000000000000"  // 13 qtde de moedas p real informar zeros
      cINTEG += "N"           // 1  chr  S/N
      cINTEG += convValor(RECEBER->Valor_liq * (LAYOUT->Juros_dia/100))  // 13 chr  13,2

      if LAYOUT->Lim_desc > 0
         cINTEG += convData(RECEBER->Data_venc - LAYOUT->Lim_desc)  // 8 chr
      else
         cINTEG += space(8)  // 8 chr
      endif

      if LAYOUT->Perc_desc > 0
         cINTEG += convValor(RECEBER->Valor_liq * (LAYOUT->Perc_desc/100)) // 13 chr 13,2
      else
         cINTEG += space(13)
      endif

      if LAYOUT->Perc_abat > 0
         cINTEG += convValor(RECEBER->Valor_liq * (LAYOUT->Perc_abat/100)) // 13 chr 13,2
      else
         cINTEG += space(13)
      endif

      cINTEG += LAYOUT->Dias_prot                                       // chr 2
      cINTEG += LAYOUT->Mensagem                                        // 40 chr, 1a linha da mensagem
      cINTEG += +"00"+LAYOUT->Convenio        // 7 chr se a posicao for de 7 pos, senao informar no campo convevio
      cINTEG += LAYOUT->Cod_multa      // Cod Multa 1-valor  2 -percentual
      cINTEG += convData(RECEBER->Data_venc + LAYOUT->Dias_multa)   // 8
      cINTEG += convValor(LAYOUT->Perc_multa) // 13,2
      cINTEG += "000000000"             // 9 filler
      cINTEG += replicate(" ",02)       // Tipo Insc chr 2
      cINTEG += replicate(" ",14)       // Avalista CNPJ/CPF 14 chr
      cINTEG += replicate(" ",37)      // Nome Avalista 37
      cINTEG += LAYOUT->Imp_local      //  1 chr Pendente de  imp local
                                       //  "S" - Para tit a serem impresso pelo bb cobranca
                                       //  "N" - Para tit. ja impressos(neste caso podera ser impresso em menu taltal)
                                       //  Utililizado para as carteiras 15 16 17 18 com impressao local
                                       // preencher com brancos para titulos das demais carteiras com impressao pelo BB


      CLI1->(Dbseek(RECEBER->Cod_cli))

      if len(CLI1->Cgccpf) == 14
         cCGCCPF := "02"
      else
         cCGCCPF := "01"
      endif

      cINTEG += cCGCCPF
      cINTEG += CLI1->Cgccpf
      cINTEG += left(CLI1->Razao,37)
      cINTEG += left(CLI1->End_cob,29) + ", " + left(CLI1->Num_cob,6)
      cINTEG += CLI1->Cep_cob

      CGM->(Dbseek(CLI1->Cgm_cob))
      cINTEG += left(CGM->Municipio,15)
      cINTEG += left(CGM->Estado,2)
      ESTADO->(dbseek(CGM->Estado))
      cINTEG += left(ESTADO->Est_desc,20) + space(20)
      cINTEG += "        " //Data Pagto
      cINTEG += "             " //Valor Pago
      cINTEG += LAYOUT->Modalidade   // 2 chr 01 p cart 11 ou 7 pra cart 17
      cINTEG += "00" // state 2 chr "00" tem muitas opcoes
      cINTEG += replicate(" ",14)
      nSEQ++

      if !empty(cINTEG)
         INTEGRA->(qappend())
         INTEGRA->Linha := cINTEG
      endif

      cINTEG := ""

      if RECEBER->(qrlock())
         replace RECEBER->Marcar with " "
         RECEBER->(Qunlock())
      endif

      RECEBER->(dbskip())
   enddo

   // MONTA REGISTRO TIPO 9 (TRAILLER) ______________________________________

   cINTEG := "99" + strzero(nSEQ,6) + replicate("0",492)

   INTEGRA->(qappend())
   INTEGRA->Linha := left(cINTEG,500)
   cINTEG := ""

   qmensa("Aguarde...Gravando arquivo...","B")

   cNOMARQ := "C:\QsysTxT\" + "B_Brasil.TXT"

   //INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   geraTxT(cNOMARQ)

   select RECEBER
   RECEBER->(dbgotop())

return


static function convData(date,cDig)
  local cDATA,cDIA,cMES,cANO :=""

  cDIA := right(dtos(date),2)
  cMES := strzero(month(date),2)

  if cDig != NIL
     cANO := right(strzero(year(date),4),2)
     cDATA := cDIA + cMES + cANO
  else
     cANO := strzero(year(date),4)
     cDATA := cDIA + cMES + cANO
  endif


return cDATA


static function convValor(Valor,cDig)
   local cRET := ""
   if cDIG == NIL
      cRET := strzero(val(qtiraponto(str(Valor,13,2))),13)
   else
      cRET := strzero(val(qtiraponto(str(Valor,cDIG,2))),cDIG)
   endif
return cRET

static function geraTxT(cDESTINO)
local cTEXTO := ""

   set printer to (cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)

   INTEGRA->(dbgotop())
   while ! INTEGRA->(eof())

       if BANCO->Banco == "0356"

          if INTEGRA->(recno()) == 1
              @ prow() ,00 say left(INTEGRA->Linha,400)
          else
              @ prow()+1,00 say left(INTEGRA->Linha,400)
          endif
       else
          if INTEGRA->(recno()) == 1
              @ prow() ,00 say INTEGRA->Linha
          else
              @ prow()+1,00 say INTEGRA->Linha
          endif
       endif

       INTEGRA->(dbskip())
   enddo
   set printer to
   set device to screen

return


static function i_Itau
local cIntegra := ""
local nLin := 0
local cCarteira := ""
local cConta    := ""
local cAgencia   := ""
local cFilename  := ""
local nFile := 0
local nReg := 0

      LAYOUT->(dbseek(fCod_layout))
      cAgencia := LAYOUT->Ag_cede
      cConta := left(LAYOUT->Conta_cede,6)
      cCarteira := LAYOUT->Carteira
      nREG := RECEBER->(recno())

     ////////////////////////////////////////////////////
     // Registro Tipo 0__________________________________

     nLIN++
     cIntegra += "0"
     cIntegra += "1"
     cIntegra += "REMESSA"
     cIntegra += "01"
     cIntegra += "COBRANCA"+space(7)
     cIntegra += cAgencia  //4 digitos
     cIntegra += "00"
     cIntegra += cConta    //6 digitos
     cIntegra += space(8)
     cIntegra += left(FILIAL->Razao,30)
     cIntegra += "341"
     cIntegra += "BANCO ITAU SA  "
     cIntegra += dtItau(date())
     cIntegra += space(294)
     cIntegra += strzero(nLIN,6)+Chr(13)+chr(10)

     ///////////////////////////////////////////////////
     // Registro 1_____________________________________

     RECEBER->(dbgotop())
     do while ! RECEBER->(eof())

        qgirabarra()

        if RECEBER->Marcar != "*"
           RECEBER->(dbskip())
           loop
        endif


         cIntegra += "1"
         cIntegra += "02"   //Cnpj da Empresa
         cIntegra += FILIAL->Cgccpf  //Cnpj da Empresa
         cIntegra += cAgencia
         cIntegra += "00"
         cIntegra += cConta
         cIntegra += space(4)
         cIntegra += "0000"
         cIntegra += RECEBER->Fatura+space(12)
         cIntegra += "00000000"
         cIntegra += "0000000000000"
         cIntegra += "1"+cCarteira // 3 Digitos
         cIntegra += space(21)
         cIntegra += "I" // 1 letra
         cIntegra += "01"
         cIntegra += left(RECEBER->Fatura,10)
         cIntegra += dtItau(RECEBER->Data_venc)
         cIntegra += convValor(RECEBER->VAlor_liq,13)
         cIntegra += "341"
         cIntegra += "00000"
         cIntegra += "01"
         cIntegra += "N"
         cIntegra +=  dtItau(RECEBER->Data_emiss)
         cIntegra += "81"
         cIntegra += "98"
         cIntegra +=  convValor(RECEBER->Valor_liq*0.0033,13)
         cIntegra += dtItau(RECEBER->Data_venc)
         cIntegra += replicate("0",39)

         CLI1->(Dbseek(RECEBER->Cod_cli))

         if len(CLI1->Cgccpf) == 14
            cCGCCPF := "02"
         else
            cCGCCPF := "01"
         endif

         cIntegra += cCgcCpf
         if cCgccpf == "02"
            cIntegra += CLI1->Cgccpf
         else
            cIntegra += "000"+left(CLI1->Cgccpf,11)
         endif

         cIntegra += left(CLI1->Razao,30)

         cIntegra += space(10)

         cIntegra += left(CLI1->End_cob,30) + CLI1->Numero + space(3)

         cIntegra += left(Cli1->Bairro_cob,12)

         cIntegra += Cli1->cep_cob

         CGM->(dbseek(CLI1->Cgm_cob))
         cIntegra += left(CGM->Municipio,15)

         cIntegra += CGM->Estado

         cIntegra += space(34)

         cIntegra += dtItau(Receber->Data_venc)

         cIntegra += "05"// prazo

         cIntegra += " "

         nLin ++

         cIntegra += strzero(nLin,6)+chr(13)+chr(10)


         cFileName := "Remessa Itau - "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".txt"


         if RECEBER->(qrlock())
            replace RECEBER->Marcar with " "
            RECEBER->(Qunlock())
         endif



         RECEBER->(dbskip())


     enddo

     nLin++
     cIntegra += "9"+space(393)+strzero(nLin,6)+chr(13)+chr(10)

     RECEBER->(dbgoto(nReg))

     cFileName := "Remessa Itau - "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".txt"

     nFile := fcreate("C:\qsystxt\"+cFileName,0)

     fwrite(nFile,cIntegra,len(cIntegra))

     fClose(nFile)




return



static function dtItau(dData)
return strzero(day(dData),2)+strzero(month(dData),2)+right(strzero(year(dData),4),2)

static function dtSantander(dData)
return strzero(day(dData),2)+strzero(month(dData),2)+right(strzero(year(dData),4),2)

static function i_hsbc
local cIntegra := ""
local nLin := 0
local cCarteira := ""
local cConta    := ""
local cAgencia   := ""
local cFilename  := ""
local nFile := 0
local nReg := 0

      LAYOUT->(dbseek(fCod_layout))
      cAgencia := LAYOUT->Ag_cede
      cConta := left(LAYOUT->Conta_cede,7)
      cCarteira := LAYOUT->Carteira
      nREG := RECEBER->(recno())

     ////////////////////////////////////////////////////
     // Registro Tipo 0__________________________________

     nLIN++
     cIntegra += "0"
     cIntegra += "1"
     cIntegra += "REMESSA"
     cIntegra += "01"
     cIntegra += "COBRANCA"+space(7)
	 cIntegra += "0"
     cIntegra += cAgencia  //4 digitos
     cIntegra += "55"
     cIntegra += cAgencia + cConta    //11 digitos
     cIntegra += space(2)
     cIntegra += left(FILIAL->Razao,30)
     cIntegra += "399"
     cIntegra += "HSBC           "
     cIntegra += dtItau(date())
	 cIntegra += "01600"
	 cIntegra += "BPI"
	 cIntegra += space(2)
	 cIntegra += "LANCV08"
     cIntegra += space(277)
     cIntegra += strzero(nLIN,6)+Chr(13)+chr(10)

     ///////////////////////////////////////////////////
     // Registro 1_____________________________________

     RECEBER->(dbgotop())
     do while ! RECEBER->(eof())

        qgirabarra()

        if RECEBER->Marcar != "*"
           RECEBER->(dbskip())
           loop
        endif


         cIntegra += "1"
         cIntegra += "02"   //Cnpj da Empresa
         cIntegra += FILIAL->Cgccpf  //Cnpj da Empresa
		 cIntegra += "0"
         cIntegra += cAgencia
         cIntegra += "55"
         cIntegra += cAgencia + cConta // 11 Digitos
         cIntegra += space(2)
         cIntegra += RECEBER->Fatura+space(12)
         cIntegra += replicate("0",11) // Nsoo Numero
         cIntegra += "000000"
         cIntegra += "00000000000"
		 cIntegra += "000000"
         cIntegra += "00000000000"
		 cIntegra += "1"  //Cobranca Simples
		 cIntegra += "01" //Remessa
		 cIntegra += left(RECEBER->Fatura,10)
         cIntegra += dtItau(RECEBER->Data_venc)
         cIntegra += convValor(RECEBER->VAlor_liq,13)
         cIntegra += "399"
         cIntegra += "00000"
		 cIntegra += "01" // Duplicata MErcantil - verificar
         cIntegra += "N"
         cIntegra +=  dtItau(RECEBER->Data_emiss)
         
		 
		 cIntegra += "24" //1a Instrucao de Cob 
		                  //15 =  206 a 211 ddmmaa e 212 215 taxa com 2 decimais 216 a 218 brancos - Multa de 2% apos data tal
		                  //24 =  206 a 215 valor da multa - 216 a 218 brancos - multa de valor x apos data vencimento
						  //77 = protestar apos x dias do venc usar colunas 392 a 393 para os dias 05 por exemplo
         cIntegra += "77"
         cIntegra +=  convValor(RECEBER->Valor_liq*0.0033,13)
         cIntegra += "000000" //Data de Desconto
		 cIntegra += replicate("0",13) //Valor do Desconto
		 cIntegra += replicate("0",13) //Valor do IOF
		 cIntegra += convValor(RECEBER->Valor_liq*0.02,10)//Multa
		 cIntegra += "000"

         CLI1->(Dbseek(RECEBER->Cod_cli))

         if len(CLI1->Cgccpf) == 14
            cCGCCPF := "02"
         else
            cCGCCPF := "01"
         endif

         cIntegra += cCgcCpf
         if cCgccpf == "02"
            cIntegra += CLI1->Cgccpf
         else
            cIntegra += "000"+left(CLI1->Cgccpf,11)
         endif

         cIntegra += left(CLI1->Razao,40)

		 cIntegra += left(CLI1->End_cob,30) + ", " + left(CLI1->Num_cob,6)
         //cIntegra += left(CLI1->End_cob,38) //+ CLI1->Numero + space(1)
		 
		 cIntegra += "  "

         cIntegra += left(Cli1->Bairro_cob,12)

         cIntegra += Cli1->cep_cob

         CGM->(dbseek(CLI1->Cgm_cob))
         cIntegra += left(CGM->Municipio,15)

         cIntegra += CGM->Estado

         cIntegra += space(39)
		 
		 cIntegra += space(1)
		 
		 cIntegra += "05"// Dias para protesto

         cIntegra += "9"

         nLin ++

         cIntegra += strzero(nLin,6)+chr(13)+chr(10)

         if RECEBER->(qrlock())
            replace RECEBER->Marcar with " "
            RECEBER->(Qunlock())
         endif

         RECEBER->(dbskip())


     enddo

     nLin++
     cIntegra += "9"+space(393)+strzero(nLin,6)+chr(13)+chr(10)

     RECEBER->(dbgoto(nReg))

     cFileName := "Remessa Hsbc - "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".txt"

     nFile := fcreate("C:\qsystxt\"+cFileName,0)

     fwrite(nFile,cIntegra,len(cIntegra))

     fClose(nFile)

return


