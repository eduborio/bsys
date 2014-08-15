/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO
// OBJETIVO...: Exportar pra Escrita Fiscal - Clari(Contadores) - LondriSoft
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO DE 2008
// OBS........:
// ALTERACOES.:

function cl420
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

do while .T.

   qlbloc(5,0,"B420A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := qinimes(date())
   dFIM := qfimmes(date())
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

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := ""

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   FAT->(Dbsetfilter({||FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. FAT->Es == "S"},'FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM.and. FAT->Es == "S" ' ))

   PROD->(dbsetorder(4))
   PROD->(Dbgotop())

   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dINI))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

return .T.


static function i_gravacao
local   cLONDSOFT :=  ""
local   nTOTAL    :=  0
local   nCONT     :=  0
local   nBASE     :=  0
local   nOUTRAS   :=  0
local   nISENTOS  :=  0
local   nICMS     :=  0
local   nALIQ_ICM :=  0
local   nDESC     :=  0
local   nIPI      :=  0
local   cNOMEARQ  :=  ""
local   cUSANDOCLI :=  ""
local   cFILE      :=  ""
local   aRET      :=  {}


if QCONF("Confirma Geracao de Arquivo?")


if ! quse(XDRV_CL,"LONDSOFT",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo LONDSOFT.DBF !! Tente novamente.")
   return
endif

cLONDSOFT := ""
LONDSOFT->(__dbzap())


   // REGISTRO TIPO 00 __________________________________________________

   cLONDSOFT := "00"
   cLONDSOFT += "FIS1.00"
   cLONDSOFT += dtoc(date())
   cLONDSOFT += dtoc(dINI)
   cLONDSOFT += dtoc(dFIM)
   cLONDSOFT += left(time(),2)
   cLONDSOFT += subst(time(),4,2)
   cLONDSOFT += left(FILIAL->Razao,40)

   LONDSOFT->(qappend())
   LONDSOFT->Linha := cLONDSOFT
   cLONDSOFT := ""

   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 10 CLIENTES__________________________________________

   CLI1->(dbgotop())

   Do while ! CLI1->(eof())

       qmensa("Gerando Clientes... "+left(CLi1->Razao,30))
       qgirabarra()

       cLONDSOFT := "10"
       cLONDSOFT += Left(CLI1->Razao,40)
       cLONDSOFT += Left(i_TrocaChr(CLI1->End_ent),40)
       CGM->(dbseek(CLI1->Cgm_ent))
       cLONDSOFT += CGM->Municipio+space(10)
       cLONDSOFT += CLI1->Bairro_ent+space(20)
       cLONDSOFT += Left(CGM->Estado,2)

       if len(alltrim(CLI1->cgccpf)) == 14
          cLONDSOFT += "1"
          cLONDSOFT += CLI1->Cgccpf
       else
          cLONDSOFT += "2"
          cLONDSOFT += left(CLI1->Cgccpf,11) +"000"
       endif

       cLONDSOFT += Left(CLI1->Fone1,12)
       cLONDSOFT += Left(CLI1->Fax,12)
       cLONDSOFT += CLI1->Contato_c+space(10)
       cLONDSOFT += CLI1->Inscricao+"   "

       LONDSOFT->(qappend())
       LONDSOFT->Linha := cLONDSOFT
       cLONDSOFT := ""


       CLI1->(dbskip())
   enddo

   CLI2->(dbgotop())

   Do while ! CLI2->(eof())

       qmensa("Gerando Clientes... "+left(CLi2->Razao,30))
       qgirabarra()

       cLONDSOFT := "10"
       cLONDSOFT += Left(CLI2->Razao,40)
       cLONDSOFT += Left(i_TrocaChr(CLI2->End_ent),40)
       CGM->(dbseek(CLI2->Cgm_ent))
       cLONDSOFT += CGM->Municipio+space(10)
       cLONDSOFT += CLI2->Bairro_ent+space(20)
       cLONDSOFT += Left(CGM->Estado,2)

       if len(alltrim(CLI2->cgccpf)) == 14
          cLONDSOFT += "1"
          cLONDSOFT += CLI2->Cgccpf
       else
          cLONDSOFT += "2"
          cLONDSOFT += left(CLI2->Cgccpf,11) +"000"
       endif

       cLONDSOFT += Left(CLI2->Fone1,12)
       cLONDSOFT += Left(CLI2->Fax,12)
       cLONDSOFT += CLI2->Contato_c+space(10)
       cLONDSOFT += CLI2->Inscricao+"   "

       LONDSOFT->(qappend())
       LONDSOFT->Linha := cLONDSOFT
       cLONDSOFT := ""


       CLI2->(dbskip())
   enddo



   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 12 PRODUTOS__________________________________________


   PROD->(dbgotop())

   Do while ! PROD->(eof())

       qmensa("Gerando Produtos... "+left(PROD->Descricao,30))
       qgirabarra()

       if right(PROD->Codigo,5) == "     "
          PROD->(Dbskip())
          loop
       endif

       if ! left(PROD->Tipo,1) $ "1-2-4-5"
          PROD->(Dbskip())
          loop
       endif

       cLONDSOFT := "12"
       cLONDSOFT += strzero(val(right(PROD->Codigo,5)),14)
       cLONDSOFT += Left(PROD->Descricao,50)

       UNIDADE->(Dbseek(PROD->Unidade))
       cLONDSOFT += UNIDADE->Sigla+space(3)
       cLONDSOFT += "000"
       cLONDSOFT += "0000"
       cLONDSOFT += "1800"
       cLONDSOFT += "3333"
       cLONDSOFT += strzero(val(qtiraponto(str(PROD->Bc_subst,14,2))),14)
       cLONDSOFT += space(15)

       LONDSOFT->(qappend())
       LONDSOFT->Linha := cLONDSOFT
       cLONDSOFT := ""


       PROD->(dbskip())
   enddo

   ///////////////////////////////////////////////////////////////////////
   // REGISTRO TIPO 21 NOTA FISCAL CABECALHO_____________________________

   FAT->(dbgotop())

   Do while ! FAT->(eof())


      qmensa("Gerando Notas Fiscais... "+FAT->Num_fatura)
      qgirabarra()


      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura)
         FAT->(dbskip())
         loop
      endif

      if FAT->No_nf == .T.
         FAT->(dbskip())
         loop
      endif

      cLONDSOFT := "21"
      cLONDSOFT += dtoc(FAT->Dt_emissao)
      cLONDSOFT += dtoc(FAT->Dt_emissao)
      cLONDSOFT += FAT->Num_fatura
      cLONDSOFT += "NFF"
      cLONDSOFT += "001"

      if CLI1->(dbseek(FAT->Cod_cli))
         CGM->(dbseek(CLI1->cgm_ent))
         cUSANDOCLI := "1"
      else
         if CLI2->(dbseek(FAT->Cod_cli))
            CGM->(dbseek(CLI2->cgm_ent))
            cUSANDOCLI := "2"
         endif
      endif

      cLONDSOFT += CGM->Estado
      aRET := i_calc_NF()

      cLONDSOFT += strzero(val(qtiraponto(str(aRET[1,1],14,2))),14)
      cLONDSOFT += left(FAT->Cod_cfop,4)
      cLONDSOFT += replicate("0",14)
      cLONDSOFT += replicate("0",14)

      cLONDSOFT += strzero(val(qtiraponto(str(aRET[1,4],14,2))),14)
      cLONDSOFT += strzero(val(qtiraponto(str(aRET[1,5],14,2))),14)
      cLONDSOFT += aRET[1,6]
      cLONDSOFT += replicate("0",14)
      cLONDSOFT += replicate("0",14)
      cLONDSOFT += replicate(" ",60)

      cFILE := "CLI"+cUSANDOCLI

      if len(alltrim((cFILE)->cgccpf)) == 14
         cLONDSOFT += "1"
         cLONDSOFT += (cFILE)->Cgccpf+"1"
      else
         cLONDSOFT += "2"
         cLONDSOFT += left((cFILE)->Cgccpf,11) +"   "+"2"
      endif

      cLONDSOFT += replicate(" ",4)

      cLONDSOFT += left((cFILE)->Inscricao,14)
      cLONDSOFT += "1A"
      cLONDSOFT += FAT->Frete
      cLONDSOFT += space(20)
      cLONDSOFT += space(02)
      cLONDSOFT += space(06)
      cLONDSOFT += space(44)

      if FAT->Cancelado
         cLONDSOFT += "S"
      else
         cLONDSOFT += "N"
      endif


      LONDSOFT->(qappend())
      LONDSOFT->Linha := cLONDSOFT
      cLONDSOFT := ""

      ///////////////////////////////////////////////////////////////////////
      // REGISTRO TIPO 22 ICMS DA NOTA FISCAL _______________________________


      cLONDSOFT := "22"
      cLONDSOFT += FAT->Num_fatura
      cLONDSOFT += "NFF"
      cLONDSOFT += "001"
      cLONDSOFT += strzero(val(qtiraponto(str(aRET[1,2],14,2))),14)
      cLONDSOFT += strzero(val(qtiraponto(str(aRET[1,7],5,2))),4)
      cLONDSOFT += strzero(val(qtiraponto(str(aRET[1,3],14,2))),14)

      LONDSOFT->(qappend())
      LONDSOFT->Linha := cLONDSOFT
      cLONDSOFT := ""

      ///////////////////////////////////////////////////////////////////////
      // REGISTRO TIPO 24 PRODUTOS DA NOTA FISCAL _______________________________

      nCONT := 0

      ITEN_FAT->(dbgotop())
      ITEN_FAT->(dbseek(FAT->Codigo))

      do while ITEN_FAT->Num_Fat == FAT->Codigo
         nCONT++
         cLONDSOFT := "24"
         cLONDSOFT += FAT->Num_fatura
         cLONDSOFT += "NFF"
         cLONDSOFT += "001"
         cLONDSOFT += strzero(nCONT,3)
         cLONDSOFT += strzero(val(ITEN_FAT->Cod_prod),14)
         cLONDSOFT += strzero(val(qtiraponto(str(ITEN_FAT->Quantidade,12,3))),12)
         cLONDSOFT += strzero(val(qtiraponto(str(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,14,2))),14)
         cLONDSOFT += strzero(val(qtiraponto(str(ITEN_FAT->Vlr_Desc,14,2))),14)
         cLONDSOFT += strzero(val(qtiraponto(str(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,14,2))),14)
         cLONDSOFT += strzero(val(qtiraponto(str(ITEN_FAT->Icms,5,2))),4)

         PROD->(dbsetorder(4))
         PROD->(dbseek(ITEN_FAT->Cod_prod))

         if PROD->Bc_subst > 0 .and. CLI1->final != "S"
            cLONDSOFT += strzero(val(qtiraponto(str(ITEN_FAT->Quantidade*PROD->Bc_subst,14,2))),14)
         else
            cLONDSOFT += replicate("0",14)
         endif

         cLONDSOFT += replicate("0",14)
         cLONDSOFT += replicate("0",4)
         cLONDSOFT += replicate("0",14)

         LONDSOFT->(qappend())
         LONDSOFT->Linha := cLONDSOFT
         cLONDSOFT := ""



         ITEN_FAT->(dbskip())

      enddo

      aRET := {}

      FAT->(Dbskip())


   enddo

   cNOMARQ := "C:\QsysTxt\LondSoft.TxT"
   LONDSOFT->(dbgotop())

   LONDSOFT->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

endif
return

static function qdata_sin(dDATA)
 local dRET,cANO,cMES,cDIA
 cANO := strzero(year(dDATA),4)
 cMES := strzero(month(dDATA),2)
 cDIA := strzero(day(dDATA),2)
 dRET := cANO + cMES + cDIA
return  dRET

static function i_grava_clientes


   CLI1->(dbgotop())
   do while ! CLI1->(Eof())




      CLI1->(dbskip())

   enddo

return

static function i_trocachr(cTROCADO)

   cTROCADO := strtran(cTROCADO,"'"," ")
   cTROCADO := strtran(cTROCADO,"€","C")
   cTROCADO := strtran(cTROCADO,"‡","c")
   cTROCADO := strtran(cTROCADO,"§",".")
   cTROCADO := strtran(cTROCADO,"¦","a")
   cTROCADO := strtran(cTROCADO,"‚","e")
   cTROCADO := strtran(cTROCADO,"ƒ","a")
   cTROCADO := strtran(cTROCADO,"„","a")
   cTROCADO := strtran(cTROCADO,"…","a")
   cTROCADO := strtran(cTROCADO,"†","a")
   cTROCADO := strtran(cTROCADO,"ˆ","e")
   cTROCADO := strtran(cTROCADO,"‰","e")
   cTROCADO := strtran(cTROCADO,"Š","e")
   cTROCADO := strtran(cTROCADO,"‹","i")
   cTROCADO := strtran(cTROCADO,"Œ","i")
   cTROCADO := strtran(cTROCADO,"","i")
   cTROCADO := strtran(cTROCADO,"“","o")
   cTROCADO := strtran(cTROCADO,"Ž","A")
   cTROCADO := strtran(cTROCADO,"","A")
   cTROCADO := strtran(cTROCADO,"","E")
   cTROCADO := strtran(cTROCADO,"“","o")
   cTROCADO := strtran(cTROCADO,"”","o")
   cTROCADO := strtran(cTROCADO,"•","o")
   cTROCADO := strtran(cTROCADO,"–","u")
   cTROCADO := strtran(cTROCADO,"—","u")
   cTROCADO := strtran(cTROCADO,"™","o")
   cTROCADO := strtran(cTROCADO,"š","U")
   cTROCADO := strtran(cTROCADO," ","a")
   cTROCADO := strtran(cTROCADO,"¡","i")
   cTROCADO := strtran(cTROCADO,"¢","o")
   cTROCADO := strtran(cTROCADO,"£","u")
   cTROCADO := strtran(cTROCADO,"¤","n")
   cTROCADO := strtran(cTROCADO,"&","e")
   cTROCADO := strtran(cTROCADO,"-"," ")
   cTROCADO := strtran(cTROCADO,"="," ")
   cTROCADO := strtran(cTROCADO,"_"," ")
   cTROCADO := strtran(cTROCADO,"ø",".")

return(cTROCADO)


static function i_calc_NF

   local cMACRO, cEXTENSO, nCONT, nLINHA := 0
   local nRESTO := 12
   local nTOT_DESC := 0
   local nICMS_DIF := 0
   local nICMS_PROPRIO := 0
   local nBC_ST    := 0
   local nICMS_ST  := 0
   local lTemReducao := .F.
   local aST := {}
   local nVLR_CONT := 0
   local aRetorno := {}
   local nOBS := ""
   local nALIQ_ICMS := 0
   local cFILE := ""

   lTemReducao := .F.
   nICMS_PROPRIO := 0

   nVAL_UNI:= nTOT_PROD:= nICMS:= nVALOR:= nVAL:= nDESC := nICM_SUBS:= nEXT := 0

   if CLI1->(dbseek(FAT->Cod_cli))
      cFILE := "CLI1"
   else
      if CLI2->(dbseek(FAT->Cod_cli))
         cFILE := "CLI2"
      else
         cFILE := "CLI1"
      endif

   endif

   CGM->(dbseek(FILIAL->Cgm))

   ITEN_FAT->(Dbgotop())
   ITEN_FAT->(dbseek(FAT->Codigo))

   nICMS     := 0
   nIPI      := 0
   nTOT_SUBS := 0
   nBASE     := 0
   nLINHA    := 0

   do while ITEN_FAT->Num_Fat == FAT->Codigo

      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_FAT->Cod_Prod))

      nALIQ_ICMS := ITEN_FAT->ICMS


      nVAL_UNI := (ITEN_FAT->Vl_unitar)// * nDESC

      nDESC := (FAT->Aliq_Desc/100)

      nIPI  +=  ( ( ITEN_FAT->Quantidade * nVAL_UNI ) * ( ITEN_FAT->Ipi / 100 ) )
      nBASE := nBASE + (ITEN_FAT->Quantidade * nVAL_UNI)

      if PROD->Bc_subst == 0
         //nICMS +=  ( ( ITEN_FAT->Quantidade * nVAL_UNI ) * ( ITEN_FAT->Icms / 100 ) )
         //if left(FAT->Cod_cfop,1) $ "1-5" .and. CLI1->Final != "S"
         //   lTEMReducao := .T.
         //endif
      else
         if FAT->dt_emissao >= ctod("04/02/2009") .and. FAT->dt_emissao <= ctod("10/08/2009")
            nBC_ST   := nBC_ST + (ITEN_FAT->Quantidade*ITEN_FAT->Bc_subst)
            nICMS_ST := nICMS_ST + ( (ITEN_FAT->Quantidade*ITEN_FAT->Bc_subst) * (ITEN_FAT->Icms /100))
            nICMS_PROPRIO +=  ( ( ITEN_FAT->Quantidade * nVAL_UNI ) * ( 7 / 100 ) )
         else
            nBC_ST   := nBC_ST + (ITEN_FAT->Quantidade*ITEN_FAT->Bc_subst)
            nICMS_ST := nICMS_ST + ( (ITEN_FAT->Quantidade*ITEN_FAT->Bc_subst) * (ITEN_FAT->Icms /100))
            nICMS_PROPRIO +=  ( ( ITEN_FAT->Quantidade * nVAL_UNI ) * ( ITEN_FAT->Icms / 100 ) )
         endif
      endif

      nTOT_PROD := nTOT_PROD + ITEN_FAT->Quantidade * nVAL_UNI

      ITEN_FAT->(Dbskip())

      nVAL_UNI := 0

   enddo

   // if left(FAT->Cod_cfop,1) $ "5-1" .and. lTemReducao == .T. .and. CLI1->Final != "S" //aqui esta sendo usado como contribuinte ou nao
   //    nICMS_DIF := (nICMS*0.3333)
   //    nICMS := nICMS-(nICMS*0.3333)
   //    nICMS := nICMS + nICMS_PROPRIO
   // else
   //    nICMS := nICMS + nICMS_PROPRIO
   // endif

    nICMS := 0

    nTOT_DESC:= (nTOT_PROD ) * nDESC

    if nBC_ST > 0 .and. (cFILE)->Final != "S"
       nTOT_GER := ( (nTOT_PROD + nIPI + FAT->Valor_FR )+(nICMS_ST-nICMS_PROPRIO) ) - nTOT_DESC
    else
       nTOT_GER := (nTOT_PROD + nIPI + FAT->Valor_FR ) - nTOT_DESC
    endif

//   if left(FAT->Cod_Cfop,1) $ "5-1" .and. CLI1->Final != "S" .and. lTemReducao == .T.
//      nOBS := "ICMS Diferido Cfe Art. 87-A do RICMS - Dec. No 5141/01.     "
//   else
      nOBS := space(60)
    //   endif

    if alltrim(FAT->Cod_cfop) $ "5151-5152-5153-5154-2152-2151-2153-2154-5917-6917-5915-6915-6910-5910-5911-6911-5912-6912-5408-6408-5908-6908"
       nICMS_ST      := 0
       nICMS_PROPRIO := 0
       nALIQ_ICMS    := 0
       nICMS         := 0
       nBC_ST        := 0
    endif

    if (cFIlE)->Final == "S"
       nICMS_ST      := 0
       nICMS_PROPRIO := 0
       nBC_ST        := 0
    endif

    nICMS := 0 //Agora eh Simples n tem mais icms



   aadd(aRetorno,{nTOT_GER,nBASE,nICMS,nBC_ST,nICMS_ST-nICMS_PROPRIO,nOBS,nALIQ_ICMS})



return aRetorno


