/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: SINTEGRA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2005
// OBS........:
// ALTERACOES.:

function cl430
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cRESP   := space(30)
private cCONV   := space(1)
private cFINAL  := space(1)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private sBLOC2  := qlbloc("B430B","QBLOC.GLO")
private sBLOC1  := qlbloc("B430C","QBLOC.GLO")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cFINAL,sBLOC2 )  } , "FINAL" })
aadd(aEDICAO,{{ || qesco(-1,0,@cCONV,sBLOC1 )   } , "CONV" })

aadd(aEDICAO,{{ || qgetx(-1,0,@cRESP,"@!")      } , "RESP"  })

do while .T.

   qlbloc(5,0,"B430A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := qinimes(date())
   dFIM := qfimmes(date())
   cRESP := space(30)
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
      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

      case cCAMPO == "CONV"
           if empty(cCONV) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cCONV,"123",{"1 - Convenio 69/02","2 - Convenio 142/02","3 - Convenio 76/03"}))

      case cCAMPO == "FINAL"
           if empty(cFINAL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cFINAL,"123",{"1 - Normal","2 - Retificacao Completa","3 - Retificacao Aditiva"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := ""

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PROD->(dbsetorder(4))
   PROD->(Dbgotop())

   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dINI))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   FAT->(Dbsetfilter({||FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. FAT->Es == "S"},'FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM.and. FAT->Es == "S" ' ))
return .T.


static function i_gravacao
local   cSINTEGRA :=  ""
local   nTOTAL    :=  0
local   nBASE     :=  0
local   nOUTRAS   :=  0
local   nISENTOS  :=  0
local   nICMS     :=  0
local   nALIQ_ICM :=  0
local   nDESC     :=  0
local   nIPI      :=  0
local   nTOT10,nTOT50,nTOT54,nTOT70,nTOT75,nTOT61,nTOTGER,nTOT90  := 0


if ! quse(XDRV_CL,"SINTEGRA",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo SINTEGRA.DBF !! Tente novamente.")
   return
endif
cSINTEGRA := ""
SINTEGRA->(__dbzap())
   nTOT10 := 0
   nTOT11 := 0
   nTOT50 := 0
   nTOT54 := 0
   nTOT70 := 0
   nTOT75 := 0
   nTOT61 := 0
   nTOT90 := 0


   // REGISTRO TIPO 10 __________________________________________________

   cSINTEGRA := "10" + alltrim(FILIAL->Cgccpf)+left(FILIAL->Insc_estad,14)+left(FILIAL->Razao,35)
   CGM->(Dbseek(FILIAL->Cgm))
   cSINTEGRA += CGM->Municipio + CGM->Estado + strzero(val(qtiraponto(left(FILIAL->Fax,10))),10) +dtos(dINI)+dtos(dFIM)+"cCONV"+"3"+cFINAL
   SINTEGRA->(qappend())
   SINTEGRA->Linha := cSINTEGRA
   cSINTEGRA := ""
   nTOT10++

   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 11 __________________________________________________

   cSINTEGRA := "11" + left(FILIAL->Endereco,34)+strzero(FILIAL->Numero,5)+left(FILIAL->Compl,21)+" "
   cSINTEGRA += left(FILIAL->Bairro,15) + strzero(val(FILIAL->Cep),8) + left(cRESP,28) + strzero(val(alltrim(FILIAL->Telefone)),12)
   SINTEGRA->(qappend())
   SINTEGRA->Linha := cSINTEGRA
   cSINTEGRA := ""
   nTOT11++


if cCONV == "3"

PROD->(Dbsetorder(4))
PROD->(Dbgotop())

do while ! FAT->(eof())

   if Empty(FAT->Num_fatura)
      FAT->(Dbskip())
      loop
   endif

   CLI1->(Dbseek(FAT->Cod_cli))
   ITEN_FAT->(Dbseek(FAT->Codigo))

   nTOTAL    :=  0
   nBASE     :=  0
   nOUTRAS   :=  0
   nISENTOS  :=  0
   nICMS     :=  0
   nALIQ_ICM :=  0
   nDESC     :=  0

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      nTOTAL += ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
      nALIQ_ICM := ITEN_FAT->Icms
      ITEN_FAT->(Dbskip())
   enddo

   nDESC := nTOTAL - (nTOTAL * (FAT->Aliq_desc /100) )

   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 50 __________________________________________________

      nTOT50++
      CGM->(dbseek(CLI1->Cgm_ent))
      nRESTO := 14 - len(qtiraponto(left(CLI1->Inscricao,14) ))

      cSINTEGRA := "50" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14))) +space(nRESTO) +qdata_sin(FAT->Dt_emissao) + CGM->Estado + "01" + left(CONFIG->Serie,2) + " " +FAT->Num_fatura
      cSINTEGRA += left(FAT->Cod_Cfop,4) + "P"+ strzero(val(qtiraponto(str(nTOTAL,13,2))),13) + strzero(val(qtiraponto(str(nBASE,13,2))),13)
      cSINTEGRA += strzero(val(qtiraponto(str(nICMS,13,2))),13)+ strzero(val(qtiraponto(str(nISENTOS,13,2))),13)
      cSINTEGRA += strzero(val(qtiraponto(str(nOUTRAS,13,2))),13)+strzero(val(qtiraponto(str(nALIQ_ICM,4,2))),4)+iif(FAT->Cancelado,"S","N")
      SINTEGRA->(qappend())
      SINTEGRA->Linha := cSINTEGRA
      cSINTEGRA := ""
      nRESTO := 0

      FAT->(dbskip())

      nTOTAL    :=  0
      nBASE     :=  0
      nOUTRAS   :=  0
      nISENTOS  :=  0
      nICMS     :=  0
      nALIQ_ICM :=  0
      nDESC     :=  0

      qmensa("Gerando Saidas: "+FAT->Num_fatura )
   enddo

   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 54 __________________________________________________


   FAT->(Dbgotop())
   do while ! FAT->(Eof())

      if Empty(FAT->Num_fatura)
         FAT->(Dbskip())
         loop
      endif

      CLI1->(Dbseek(FAT->Cod_cli))
      ITEN_FAT->(Dbseek(FAT->Codigo))
      nCONT := 0

      do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
         nCONT++
         nTOT54++
         cSINTEGRA := "54" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + "01" + left(CONFIG->Serie,2) + " "+FAT->Num_fatura
         cSINTEGRA += left(FAT->Cod_Cfop,4) + ITEN_FAT->Cod_Sit+strzero(nCONT,3)+strzero(val(ITEN_FAT->Cod_prod),14)+ strzero(val(qtiraponto(str(ITEN_FAT->Quantidade,11,3))),11) + strzero(val(qtiraponto(str(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,12,2))),12)
         cSINTEGRA += strzero(val(qtiraponto(str(nDESC,12,2))),12)+ strzero(val(qtiraponto(str(nBASE,12,2))),12)
         cSINTEGRA += strzero(val(qtiraponto(str(nOUTRAS,12,2))),12)+strzero(val(qtiraponto(str(nIPI,12,2))),12)+strzero(val(qtiraponto(str(nIPI,4,2))),4)
         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
         cSINTEGRA := ""
         ITEN_FAT->(Dbskip())
      enddo
      FAT->(Dbskip())
   enddo

   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 75 __________________________________________________

   FAT->(Dbgotop())
   Do While ! FAT->(Eof())

      if empty(FAT->Num_fatura)
         FAT->(DbSkip())
         loop
      endif

      ITEN_FAT->(dbseek(FAT->Codigo))
      do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
         nTOT75++
         cSINTEGRA := "75" + qdata_sin(dINI)+qdata_sin(dFIM)+strzero(val(ITEN_FAT->Cod_Prod),14)
         PROD->(Dbseek(ITEN_FAT->Cod_prod))
         cSINTEGRA += replicate("0",8)+PROD->Descricao+"   "
         UNIDADE->(DbSeek(PROD->Unidade))
         cSINTEGRA += UNIDADE->Sigla + "   " + replicate("0",27)
         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
         cSINTEGRA := ""
         ITEN_FAT->(DbSkip())
      enddo
      FAT->(DbSkip())
   enddo

else  //Convenio Tipo 1 - 69/02

PROD->(Dbsetorder(4))
PROD->(Dbgotop())

do while ! FAT->(eof())

   if Empty(FAT->Num_fatura)
      FAT->(Dbskip())
      loop
   endif

   CLI1->(Dbseek(FAT->Cod_cli))
   ITEN_FAT->(Dbseek(FAT->Codigo))

   nTOTAL    :=  0
   nBASE     :=  0
   nOUTRAS   :=  0
   nISENTOS  :=  0
   nICMS     :=  0
   nALIQ_ICM :=  0
   nDESC     :=  0

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      nTOTAL += ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
      nALIQ_ICM := ITEN_FAT->Icms
      ITEN_FAT->(Dbskip())
   enddo

   nDESC := nTOTAL - (nTOTAL * (FAT->Aliq_desc /100) )




   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 50 __________________________________________________

      nTOT50++
      CGM->(dbseek(CLI1->Cgm_ent))
      nRESTO := 14 - len(qtiraponto(left(CLI1->Inscricao,14) ))

      cSINTEGRA := "50" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14))) +space(nRESTO) +qdata_sin(FAT->Dt_emissao) + CGM->Estado + "01" + left(CONFIG->Serie,2) + " " +"  "+FAT->Num_fatura
      cSINTEGRA += left(FAT->Cod_fisc,3) + strzero(val(qtiraponto(str(nTOTAL,13,2))),13) + strzero(val(qtiraponto(str(nBASE,13,2))),13)
      cSINTEGRA += strzero(val(qtiraponto(str(nICMS,13,2))),13)+ strzero(val(qtiraponto(str(nISENTOS,13,2))),13)
      cSINTEGRA += strzero(val(qtiraponto(str(nOUTRAS,13,2))),13)+strzero(val(qtiraponto(str(nIPI,4,2))),4)+iif(FAT->Cancelado,"S","N")
      SINTEGRA->(qappend())
      SINTEGRA->Linha := cSINTEGRA
      cSINTEGRA := ""
      nRESTO := 0

      FAT->(dbskip())

      nTOTAL    :=  0
      nBASE     :=  0
      nOUTRAS   :=  0
      nISENTOS  :=  0
      nICMS     :=  0
      nALIQ_ICM :=  0
      nDESC     :=  0

      qmensa("Gerando Saidas: "+FAT->Num_fatura )
   enddo

   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 54 __________________________________________________


   FAT->(Dbgotop())
   do while ! FAT->(Eof())

      if Empty(FAT->Num_fatura)
         FAT->(Dbskip())
         loop
      endif

      CLI1->(Dbseek(FAT->Cod_cli))
      ITEN_FAT->(Dbseek(FAT->Codigo))
      nCONT := 0

      do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
         nCONT++
         nTOT54++
         cSINTEGRA := "54" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + "01" + left(CONFIG->Serie,2) + " " +"  "+FAT->Num_fatura
         cSINTEGRA += left(FAT->Cod_fisc,3) +strzero(nCONT,3)+strzero(val(ITEN_FAT->Cod_prod),14)+ strzero(val(qtiraponto(str(ITEN_FAT->Quantidade,13,3))),13) + strzero(val(qtiraponto(str(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,12,2))),12)
         cSINTEGRA += strzero(val(qtiraponto(str(nDESC,12,2))),12)+ strzero(val(qtiraponto(str(nBASE,12,2))),12)
         cSINTEGRA += strzero(val(qtiraponto(str(nOUTRAS,12,2))),12)+strzero(val(qtiraponto(str(nIPI,12,2))),12)+strzero(val(qtiraponto(str(nALIQ_CIM,4,2))),4)
         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
         cSINTEGRA := ""
         ITEN_FAT->(Dbskip())
      enddo
      FAT->(Dbskip())
   enddo

   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 75 __________________________________________________

   FAT->(Dbgotop())
   Do While ! FAT->(Eof())

      if empty(FAT->Num_fatura)
         FAT->(DbSkip())
         loop
      endif

      ITEN_FAT->(dbseek(FAT->Codigo))
      do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
         nTOT75++
         cSINTEGRA := "75" + qdata_sin(dINI)+qdata_sin(dFIM)+strzero(val(ITEN_FAT->Cod_Prod),14)
         PROD->(Dbseek(ITEN_FAT->Cod_prod))
         cSINTEGRA += replicate("0",8)+PROD->Descricao+"   "
         UNIDADE->(DbSeek(PROD->Unidade))
         cSINTEGRA += UNIDADE->Sigla + "   " + ITEN_FAT->Cod_Sit+strzero(val(qtiraponto(str(ITEN_FAT->Ipi,4,2))),4)+strzero(val(qtiraponto(str(PROD->Icms,4,2))),4)
         cSINTEGRA += replicate("0",16)
         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
         cSINTEGRA := ""
         ITEN_FAT->(DbSkip())
      enddo
      FAT->(DbSkip())
    enddo
   endif

   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 90 __________________________________________________
   nTOT_GER := nTOT10+nTOT11+nTOT50+nTOT54+nTOT75+1
   cSINTEGRA := "90" + alltrim(FILIAL->Cgccpf)+left(FILIAL->Insc_estad,14) + "50" + strzero(nTOT50,8)+"54"+Strzero(nTOT54,8) +"61"+Strzero(nTOT61,8)+"75"+Strzero(nTOT75,8)+ "99" +strzero(nTOT_GER,8)+space(45) + "1"
   SINTEGRA->(qappend())
   SINTEGRA->Linha := cSINTEGRA
   cSINTEGRA := ""
   nTOT_GER := nTOT10:=nTOT11:=nTOT50:=nTOT70 := nTOT54 := nTOT75 := 0


    cNOMARQ := "A:Sintegra.TxT"
    SINTEGRA->(dbgotop())

    SINTEGRA->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

    if SINTEGRA->(qflock())
       SINTEGRA->(__dbzap())
    endif


return

static function qdata_sin(dDATA)
 local dRET,cANO,cMES,cDIA
 cANO := strzero(year(dDATA),4)
 cMES := strzero(month(dDATA),2)
 cDIA := strzero(day(dDATA),2)
 dRET := cANO + cMES + cDIA
return  dRET


