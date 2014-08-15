/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: IMPRESSAO DE FATURAS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.: EDUARDO AUGUSTO BORIO

function cp516

#define K_MAX_LIN 52

private cPEDIDOS   := ""
private nVAL       := 0
private lPENDENCIA := .F.
private nDESC     := 0
private nVAL_UNI  := nTOT_PROD := nICMS := nVALOR := nALIQ_ICMS := nICM_SUBS := nTOT_GER := 0
private cFRETE    := " "
private nVALOR_FR := 0
private nOUTRAS   := 0
private cTRANSPOR := Space(23)
private cQUANT    := 0
private cESPECIE  := ""
private cPESOBR   := 0
private cPESOLQ   := 0
private cNUMERO   := ""
private cMARCA    := ""
private cIPI      := space(3)
private nALIQ     := 0
private nFOL      := 0
private dIPI      := 0
private dICMS     := 0
private dBASE     := 0
private dTOT_PROD := 0
private dTOT_GER  := 0
private dTOT_DESC := 0
private dTOT_SUBS := 0
private lPAG      := .F.
private lPRIM     := .F.
private nREGISTRO := 0
private cCLASS    := space(2)
private aCLASS    := {}
private asCLASS   := {}
private afCLASS   := {}
private lPAG      := .F.
private XDRV_NFE  := "C:\ACBrNFeMonitor\"

quse(XDRV_CL,"CONFIG",NIL,NIL,"FATCFG")


private sBLOC1  := qlbloc("B516B","QBLOC.GLO")

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS FATURAS __________________________________________________

IMPORT->(qview({{"i_516p()/CODIGO"       ,2},;
             {"Data_ped/Emissao"         ,0},;
             {"i_516a()/Fornecedor"      ,0},;
             {"Num_fatura/Fatura"        ,0},;
             {"i_516sts()/Status"        ,0}},"P",;
             {NIL,"i_516c",NIL,NIL},;
              NIL,"<N>Fe - envio/ <G>era Numero <C>ancela NFe "))

return
FATCFG->(DbCloseArea())

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function i_516a
local cRAZAO := space(65)

   FORN->(dbseek(IMPORT->Cod_forn))
   cRAZAO := left(FORN->Razao,35)

return cRAZAO

function i_516p
return transform(left(IMPORT->Codigo,5),"@R 99999!")

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_516c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "N"
      qlbloc(12,17,"B516A","QBLOC.GLO",1)
      i_edicao()
   endif

   if cOPCAO == "G"
      i_geraNF()
   endif

   if cOPCAO == "C"
      CancelarNFe("ENT.TXT")
   endif


   if cOPCAO == "P"
      ImprimirDanfe("ENT.TXT")
   endif
   
   if cOPCAO == "L"

         if IMPORT->(qrlock())
            replace IMPORT->Nfe       with getNFe() + qdigNFe(getNFe())
			replace IMPORT->Modelo    with "55"
            IMPORT->(qunlock())
         endif

         ConsultarNFe("ENT.TXT")
         //endif
      endif






   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}
   cQUANT   := 0
   cESPECIE := ""
   cMARCA   := ""
   cNUMERO  := 0
   cPESOBR  := 0
   cPESOLQ  := 0
   cTRANSPOR:= Space(23)
   nVALOR_FR:= 0
   nOUTRAS  := 0
   nIPI     := space(3)
   nALIQ    := 0
   nFOL     := 0
   dIPI      := 0
   dICMS     := 0
   dBASE     := 0
   dTOT_PROD := 0
   dTOT_GER  := 0
   dTOT_DESC := 0
   dICMS_SUBS:= 0
   cADIANTA := 0
   cIRRF := 0
   cISS := 0
   cCPMF := 0
   lPAG  := .F.
   nREGSIDTRO := 0
   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || NIL                                     }, NIL })
   aadd(aEDICAO,{{ || qesco(-1,0,@cFRETE,sBLOC1              )}, "FRETE"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR_FR,"@R 9,999,999.99")}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nOUTRAS ,"@R 9,999,999.99" )}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cTRANSPOR ,"@X!"           )}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cQUANT,"@R 999999.999"          )}, "QUANT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cESPECIE,"@!"              )}, "ESPECIE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cPESOBR, "999999.999"        )}, "PESOBR"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cMARCA, "@!"               )}, "MARCA"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cPESOLQ, "999999.999"        )}, "PESOLQ"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNUMERO, "@!"              )}, "NUMERO"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Impress„o da Nota Fiscal ?") },NIL})

   XNIVEL := 1

   do while .T.

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      //zTMP_PRN := XCOD_PRN
      //XCOD_PRN := "11"

      //if ! qinitprn() ; return ; endif

      iif ( i_inicializacao(), criarNFe("ENT.TXT") , NIL )

      //qstopprn(.F.)
      //XCOD_PRN := zTMP_PRN

      exit

   enddo


return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case

      case cCAMPO == "FRETE"
           if empty(cFRETE) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cFRETE,"12",{"1 - Emitente","2 - Destinatario"}))

      case cCAMPO == "IPI"
           if empty(cIPI) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cIPI,"SN",{"Sim","N„o"}))

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   PROD->(dbsetorder(4))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A SELECAO DO MODELO DE NOTA FISCAL _____________________

static function i_imp

    do case
       case FATCFG->Modelo_fat == "1"
            lPRIM := .F.
            i_impre1() // MANTRACO

    endcase

return .T.

static function i_impre1
   local cMACRO, cEXTENSO, nCONT, nLINHA , nRESTO, nDESCONTO := 0
   local arsCLASS,arCLASS,afCLASS := {}
   local lCLASSIF := .F.
   //local lPAG := .F.

   nVAL_UNI:= nTOT_PROD:= nICMS:= nVALOR:= nVAL:= nDESC := nICM_SUBS:= nEXT := 0
   nALIQ_IPI := 0
   aSERV := {}
   arsCLASS := {}
   arCLASS  := {}
   afCLASS := {}
   sCONT := zLINHA := zCOL := 0
   nDESC := 0
   lSERV := .F.
   lMAIS := .F.
   nISS := 0
   nICMS_ALIQ := 0
   nEXTENSO := 0

   FORN->(dbseek(IMPORT->Cod_forn))

   FILIAL->(dbseek(IMPORT->Filial))


   @ prow()+FATCFG->Ini_nota ,00  say xcond1
   @ prow()+1 ,103 say "XX"
   @ prow()   ,126 say cFATURA

   @ prow()+5 ,01 say iif(CFOP->(Dbseek(IMPORT->Cfop)), left(CFOP->Nat_desc,35) , )
   @ prow()   ,46 say CFOP->Nat_cod
   @ prow()+3 ,01 say FORN->Razao  + space(25) + fu_conv_cgccpf(FORN->Cgccpf) + space(16) + dtoc(IMPORT->Data_ped)
   @ prow()+2 ,01 say FORN->End_ent + space(28) + Left(FORN->Bairro_ent,21) +"     "+ FORN->Cep_ent //+ space(13) //+ dtoc(IMPORT->Data_baixa)

   CGM->(dbseek(FORN->Cgm_ent))
   @ prow()+2,01 say left(CGM->Municipio,30)
   @ prow()  ,55 say FORN->Fone1
   @ prow()  ,85 say CGM->Estado
   @ prow()  ,92 say FORN->Inscricao

   @ prow()+2,00 say ""
   nLINHA    := 0
   nRESTO    := 0
   nCONT     := 1

   @ prow()+2,00 say ""

   @ prow()+6,00 say ""

   if lPAG == .F.
      ITEN_IMP->(Dbgotop())
      ITEN_IMP->(dbseek(IMPORT->Codigo))
   else
      ITEN_IMP->(dbgoto(nREGISTRO))
      lPRIM := .T.
   endif

   nICMS     := 0
   nIPI      := 0
   nTOT_SUBS := 0
   nBASE     := 0
   nLINHA    := 0
   nRESTO    := 0
   nCONT     := 0
   nDESC     := 0

   do while ITEN_IMP->Cod_ped == IMPORT->Codigo


      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_IMP->Cod_Prod))

      @ prow()+1 ,00 say left(PROD->Cod_ass,4) + " "+right(PROD->Cod_ass,3)
      @ prow()   ,10 say left(PROD->Cod_fabr,7)+ "   "+rtrim(PROD->Descricao)+"  "+PROD->Marca
      @ prow()   ,59 say PROD->Cod_class  //Classif. Fiscal
      if CLASSIF->(dbseek(PROD->Cod_class))
         aadd(arCLASS,{PROD->Cod_class,CLASSIF->Descricao})
         lCLASSIF := .T.
      endif

      @ prow()  ,64 say "200"

      @ prow()  ,70 say iif(UNIDADE->(Dbseek(PROD->Unidade)), UNIDADE->Sigla ,)
      @ prow()  ,78 say transform(ITEN_IMP->Quant, "@E 99999")
      nVAL_UNI := (ITEN_IMP->Preco)
      @ prow()  ,85 say transform(nVAL_UNI, "@E 9,999,999.99")
      @ prow()  ,103 say transform(ITEN_IMP->Quant * nVAL_UNI, "@E 9,999,999.99")
      @ prow()  ,117 say transform(ITEN_IMP->Aliq_Icms,"@E 99.99")
      @ prow()  ,123 say transform(ITEN_IMP->Aliq_ipi, "@E 99.99")
      @ prow()  ,129 say transform((ITEN_IMP->Quant * nVAL_UNI) * (ITEN_IMP->Aliq_Ipi / 100),"@E 9,999.99")

      nIPI  +=  ( ( ITEN_IMP->Quant * nVAL_UNI ) * ( ITEN_IMP->Aliq_Ipi / 100 ) )
      nALIQ_IPI := ITEN_IMP->Aliq_Ipi
      nICMS += ( ( ITEN_IMP->Quant * nVAL_UNI  ) * (ITEN_IMP->Aliq_Icms/100) )
      nBASE += (ITEN_IMP->Quant * nVAL_UNI)

      nTOT_PROD := nTOT_PROD + ITEN_IMP->Quant * nVAL_UNI

      nALIQ_ICMS:= ITEN_IMP->Aliq_Icms

      ITEN_IMP->(Dbskip())
      nLINHA++

      if nLINHA == 15 .and. ITEN_IMP->Cod_ped == IMPORT->Codigo
         nREGISTRO := ITEN_IMP->(recno())
         lPAG := .T.
         exit
      else
          lPAG := .F.
      endif

      nVAL_UNI := 0

   enddo

   if nLINHA == 16
      nRESTO := 16 - nLINHA
      for nCONT := 1 to nRESTO
          @ prow()+1,0 say ""
      next
   else
      nRESTO := 16 - nLINHA
      for nCONT := 1 to nRESTO
          @ prow()+1,0 say ""
      next
   endif

   @ prow()+1,00 say ""
   @ prow()+1,00 say ""
   nDESC := 0

   nLINHA := 0
   nCONT  := 0

   if ! lPAG
      @ prow()+3,10 say transform(IMPORT->Base_icm,"@E 999,999.99")
      @ prow()  ,39 say transform(IMPORT->Vlr_icm, "@E 999,999.99")

      @ prow()  ,123 say transform(IMPORT->Val_pedido,"@E 999,999.99")

      nTOT_GER :=  nTOT_PROD

      @ prow()+2  , 10 say " "
      @ prow()    , 60 say transform( IMPORT->Desp_acess  , "@E 9,999,999.99")

      @ prow()    , 84 say transform( IMPORT->Vlr_ipi    , "@E 9,999,999.99")
      @ prow()    ,121 say transform( IMPORT->Val_liq, "@E 9,999,999.99")

      @ prow()+3, 04 say ""//TRANSP->Razao
      @ prow()  , 84 say cFRETE
      @ prow()  , 90 say ""//TRANSP->Placa
      @ prow()  ,116 say ""//TRANSP->Cgccpf

      @ prow()+2,04 say ""//TRANSP->Endereco
      //CGM->(dbseek(TRANSP->Cgm))
      @ prow()  ,75 say ""//CGM->Municipio
      @ prow()  ,108 say ""//CGM->Estado
      @ prow()  ,116 say ""//TRANSP->Inscricao

      @ prow()+2, 00 say iif(cQUANT > 0,transf(cQUANT,"@R 999999"),"  ")
      @ prow()  , 19 say cESPECIE
      @ prow()  , 42 say cMARCA
      @ prow()  , 70 say cNUMERO
      @ prow()  , 105 say transf(cPESOBR,"@E 99999.9")
      @ prow() ,  124 say transf(cPESOLQ,"@E 99999.9")
   else
      @ prow()+12 ,00 say ""
   endif
   setprc()

   if ! lPAG
      @ prow()+4,10 say left(IMPORT->Observacao,70)
   else
      @ prow()+4,10 say "CONTINUA..."
   endif


   nRESTO := 4 - nLINHA
   for nCONT := 1 to nRESTO
       @ prow()+1,0 say " "
   next

   nLINHA := 0

   nRESTO := 2 - nLINHA
   for nCONT := 1 to nRESTO
       @ prow()+1,0 say " "
   next


   @ prow()+04,122 say cFATURA


   @ prow()+FATCFG->Pulo,0 say ""
   if lPAG
      //cFATURA := strzero(val(cFATURA)+1,6)

      if FATCFG->(qrlock())
         replace FATCFG->Cod_fat with val(cFATURA)
         FATCFG->(qunlock())
      endif
      i_impre1()
   endif

return


static function CriarNFe(cDestino)
local cCodMunic    := ""
local nCONT        := 0
local nTotal       := 0
local nICMS        := 0
local nICMS_DIF    := 0
local nII          := 0
local nIPI         := 0
local nICMSST      := 0
local nBASE_ICMSST := 0
local nBASE_ICMS   := 0
local nBASE_IPI    := 0
local nValorSt     := 0
local aST := {}
local nInfAdic := 0



   set printer to (XDRV_NFE+cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)

   @ prow()   ,00 say "NFE.CriarEnviarNFe([Identificacao]"
   CFOP->(dbseek(IMPORT->cfop))
   @ prow()+1 ,03 say "NaturezaOperacao="+i_trocachr(left(CFOP->Nat_desc,20))
   @ prow()+1 ,03 say "Modelo=55"
   @ prow()+1 ,03 say "Serie=1"
   @ prow()+1 ,03 say "Codigo="+IMPORT->Num_fatura
   @ prow()+1 ,03 say "Numero="+IMPORT->Num_fatura
   @ prow()+1 ,03 say "Emissao="+dtoc(date())
   @ prow()+1 ,03 say "Tipo=0"
   @ prow()+1 ,03 say "FormaPag=2"
   @ prow()+1 ,03 say "Finalidade=0"

   @ prow()+1 ,03 say "[Emitente]"
   FILIAL->(dbseek(IMPORT->Filial))
   @ prow()+1 ,03 say "CNPJ="+FILIAL->cgccpf
   @ prow()+1 ,03 say "IE="+qtiraponto(FILIAL->Insc_estad)
   @ prow()+1 ,03 say "Razao="+i_trocachr(rtrim(FILIAL->Razao))
   @ prow()+1 ,03 say "Fantasia="+i_trocachr(rtrim(FILIAL->Fantasia))
   @ prow()+1 ,03 say "Fone="+i_trocachr(FILIAL->Telefone)
   @ prow()+1 ,03 say "CEP="+FILIAL->Cep
   @ prow()+1 ,03 say "Logradouro="+i_trocachr(rtrim(FILIAL->Endereco))
   @ prow()+1 ,03 say "Numero="+strzero(FILIAL->numero,6)
   @ prow()+1 ,03 say "Complemento="+i_trocachr(rtrim(FILIAL->Compl))
   @ prow()+1 ,03 say "Bairro="+i_trocachr(rtrim(FILIAL->Bairro))
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1 ,03 say "CidadeCod="+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio)
   @ prow()+1 ,03 say "Cidade="+rtrim(CGM->Municipio)
   @ prow()+1 ,03 say "UF="+CGM->Estado

   @ prow()+1 ,03 say "[Destinatario]"
   FORN->(dbseek(IMPORT->Cod_forn))
   @ prow()+1 ,03 say "CNPJ="//+FORN->cgccpf
   @ prow()+1 ,03 say "IE="//+qtiraponto(FORN->Inscricao)
   @ prow()+1 ,03 say "NomeRazao="+i_trocachr(rtrim(FORN->Razao))
   @ prow()+1 ,03 say "Fone="+i_trocachr(FORN->Fone1)
   @ prow()+1 ,03 say "CEP="//+FORN->Cep_ent
   @ prow()+1 ,03 say "Logradouro="+i_trocachr(rtrim(FORN->End_cob))
   @ prow()+1 ,00 say "Numero="+alltrim(FORN->Numero)
   @ prow()+1 ,00 say "Complemento="+i_trocachr(alltrim(FORN->Compl))
   @ prow()+1 ,03 say "Bairro="+i_trocachr(rtrim(FORN->Bairro_cob))
   CGM->(dbseek(FORN->Cgm_ent))
   @ prow()+1 ,03 say "CidadeCod=9999999"//+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio)
   @ prow()+1 ,03 say "Cidade=EXTERIOR"//+rtrim(CGM->Municipio)
   @ prow()+1 ,03 say "UF=EX"//+CGM->Estado
   @ prow()+1 ,03 say "PaisCod=1600"//+CGM->Estado
   @ prow()+1 ,03 say "Pais=China"//+CGM->Estado

   nICMS        := 0
   nICMSST      := 0
   nBASE_ICMSST := 0
   nBASE        := 0
   nTOTAL       := 0
   nII          := 0


   ITEN_IMP->(dbseek(IMPORT->Codigo))
   PROD->(dbsetorder(4))
   nCONT := 1
   do while ! ITEN_IMP->(eof()) .and. ITEN_IMP->cod_ped == IMPORT->Codigo

      PROD->(dbseek(ITEN_IMP->Cod_prod))
      @ prow()+1,03 say "[PRODUTO"+strzero(nCONT,3)+"]"
      @ prow()+1,03 say "CFOP="+alltrim(IMPORT->Cfop)
      @ prow()+1,03 say "Codigo="+rtrim(PROD->cod_fabr)
      if CLASSIF->(dbseek(PROD->Cod_class))
         @ prow()+1,03 say "NCM="+alltrim(i_trocachr(CLASSIF->Descricao))
      endif

      @ prow()+1,03 say "Descricao="+rtrim(PROD->Descricao)
      UNIDADE->(dbseek(PROD->Unidade))
      @ prow()+1,03 say "Unidade="+alltrim(UNIDADE->Sigla)
      @ prow()+1,03 say "Quantidade="+alltrim(transf(ITEN_IMP->Quant,"@R 9999999"))
      @ prow()+1,03 say "ValorUnitario="+alltrim(transf(ITEN_IMP->preco,"@R 9999999.99"))
      @ prow()+1,03 say "ValorTotal="+alltrim(transf(ITEN_IMP->Quant*ITEN_IMP->preco,"@R 9999999.99"))
	  @ prow()+1,03 say "vOutro="+alltrim(transf(IMPORT->Desp_Acess,"@R 9999999999.99"))

      @ prow()+1,03 say "[DI"+strzero(nCONT,3)+"001]"
      @ prow()+1,03 say "NumeroDI="+IMPORT->Num_di
      @ prow()+1,03 say "DataRegistroDI="+dtoc(IMPORT->Data_regDi)
      @ prow()+1,03 say "LocalDesembaraco="+IMPORT->Loc_desem
      @ prow()+1,03 say "UFDesembaraco="+IMPORT->Uf_desem
      @ prow()+1,03 say "DataDesembaraco="+dtoc(IMPORT->Data_desem)
      @ prow()+1,03 say "CodigoExportador="+IMPORT->Cod_export


      @ prow()+1,03 say "[LADI"+strzero(nCONT,3)+"001001]"
      @ prow()+1,03 say "NumeroAdicao=1"
      @ prow()+1,03 say "CodigoFabricante="+iif(empty(PROD->Fabr) .or. PROD->Fabr == "00000",IMPORT->Cod_forn,PROD->Fabr)
      //@ prow()+1,03 say "DescontoADI=0"


      
      @ prow()+1,03 say "[ICMS"+strzero(nCONT,3)+"]"
      @ prow()+1,03 say "Origem=2"
      @ prow()+1,03 say "CST=00"

      @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_IMP->Base_icms * ITEN_IMP->Quant,"@R 999999999.99"))
      @ prow()+1,03 say "Aliquota="+alltrim(transf(ITEN_IMP->aliq_Icms,"@R 99.99"))
      @ prow()+1,03 say "Valor="+alltrim(transf((ITEN_IMP->Base_icms * ITEN_IMP->Quant)*(ITEN_IMP->Aliq_Icms/100),"@R 9999999.99"))

      
      @ prow()+1,03 say "[IPI"+strzero(nCONT,3)+"]"
      @ prow()+1,03 say "CST=200"

      @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_IMP->Base_ipi*ITEN_IMP->Quant,"@R 9999999.99"))
      @ prow()+1,03 say "Aliquota="+alltrim(transf(ITEN_IMP->Aliq_ipi,"@R 99.99"))
      @ prow()+1,03 say "Valor="+alltrim(transf((ITEN_IMP->Base_ipi * ITEN_IMP->Quant)*(ITEN_IMP->Aliq_Ipi/100),"@R 9999999.99"))

      @ prow()+1,03 say "[II"+strzero(nCONT,3)+"]"
      @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_IMP->Base_ii*ITEN_IMP->Quant,"@R 9999999.99"))
      @ prow()+1,03 say "ValorDespAduaneiras="
      @ prow()+1,03 say "ValorII="+alltrim(transf((ITEN_IMP->Base_ii*ITEN_IMP->Quant)*(ITEN_IMP->Aliq_Ii/100),"@R 9999999.99"))
      @ prow()+1,03 say "ValorIOF="
	  nII  += ((ITEN_IMP->Base_ii*ITEN_IMP->Quant)*(ITEN_IMP->Aliq_Ii/100))
	  nIPI += ((ITEN_IMP->Base_ipi*ITEN_IMP->Quant)*(ITEN_IMP->Aliq_Ipi/100))

      //@ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_IMP->preco*ITEN_IMP->Quant,"@R 9999999.99"))
      //@ prow()+1,03 say "Aliquota="+alltrim(transf(PROD->IPI,"@R 99.99"))
      //@ prow()+1,03 say "Valor="+alltrim(transf((ITEN_IMP->preco * ITEN_IMP->Quant)*(PROD->Ipi/100),"@R 9999999.99"))


      //nBASE_IPI    += (ITEN_IMP->Quant * ITEN_IMP->preco)
      //nBASE_ICMSST += (ITEN_IMP->Quant * ITEN_IMP->Bc_subst)
      //nICMS        += ((ITEN_IMP->preco * ITEN_IMP->Quant)*(ITEN_IMP->Icms/100))

      //if ITEN_IMP->Icms > 0
      //   nBASE_ICMS   += (ITEN_IMP->Quant * ITEN_IMP->preco)
      //   nIPI         += ((ITEN_IMP->preco * ITEN_IMP->Quant)*(PROD->Ipi/100))
      //endif

      nTotal += (ITEN_IMP->Quant * ITEN_IMP->preco)

      nCONT++
      ITEN_IMP->(dbskip())
   enddo

   @ prow()+1, 03 say "[Total]"

   @ prow()+1, 03 say "BaseICMS="+alltrim(transf(IMPORT->Base_icm,"@R 9999999.99"))
   @ prow()+1, 03 say "ValorICMS="+alltrim(transf(IMPORT->Vlr_icm,"@R 9999999.99"))
   @ prow()+1, 03 say "ValorIPI="+alltrim(transf(nIPI,"@R 9999999.99"))
   @ prow()+1, 03 say "ValorII="+alltrim(transf(nII,"@R 9999999.99"))

   @ prow()+1, 03 say "ValorProduto="+alltrim(transf(IMPORT->val_pedido,"@R 9999999.99"))
   @ prow()+1, 03 say "ValorOutrasDespesas="+alltrim(transf(IMPORT->desp_acess,"@R 9999999.99"))
   @ prow()+1, 03 say "ValorNota="+alltrim(transf(IMPORT->Val_liq,"@R 9999999.99"))

   @ prow()+1, 03 say "[volume001]"
   @ prow()+1, 03 say "Quantidade="+alltrim(transf(cQuant,"@R 999999"))
   @ prow()+1, 03 say "Especie="+cEspecie
   @ prow()+1, 03 say "Marca="+cMarca
//   @ prow()+1, 03 say "Numeracao="+cNumero
   @ prow()+1, 03 say "PesoBruto="+alltrim(transf(cPesobr,"@R 999999.99"))
   @ prow()+1, 03 say "PesoLiquido="+alltrim(transf(cPesolq,"@R 999999.99"))
   
   @ prow()+1, 03 say "[DadosAdicionais]"
   @ prow()+1, 03 say "Complemento="+"DI Nro.: " + IMPORT->Num_di
   
   @ prow()+1, 03 say ",0,1)"


   nCONT := 1

   set printer to
   set device to screen

   readFile(XDRV_NFE+"SAI.TXT","ENVIAR")

return

static function readFile(cFile,cTIPO)
local fileHnd   := 0
local cBuffer   := ""
local nTTLinhas := 0
local nLinha    := 1
local nSize     := 0
local nLastLine := 0
local cEOL  := chr(13)+chr(10)
local nPos := 0
local fileHnd2 := 0
local cNFe := ""
local cStatus := ""
local cMotivo := ""
local nEol := 0

  do while .T.
     fileHnd := fopen(cFile,2)
     if ferror() == 0
        exit
     endif
  enddo

  nSize := fseek(fileHnd,0,2)
  cBuffer := space(nSize)
  fseek(fileHnd,0)
  fRead(fileHnd,@cBuffer,nSize)

  if left(cBuffer,4) == "ERRO"
     alert(i_trocachr(cBuffer))
  endif

  do case
     case cTIPO == "ENVIAR"
          if left(cBuffer,2) == "OK"
             cRetorno := substr(cBuffer,at("[RETORNO]",cBuffer),len(cBuffer))
             cStatus  := right(substr(cRetorno,at("CStat",cRetorno),9),3)
             cNFE     := substr(cRetorno,at("ChNFe",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cNFE)-6
             cNFE     := substr(cNFE,7,nEol-1)

             cMotivo  := substr(cRetorno,at("XMotivo",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cMotivo)-8
             cMotivo  := substr(cMOTIVO,9,nEol-1)

             do case
                case cSTATUS == "100"
                     alert("NFe Autorizada! ;"+cNFE)
                     if IMPORT->(qrlock())
                        replace IMPORT->Nfe       with cNFE
                        replace IMPORT->Modelo    with "55"
                       // replace FAT->Dt_recNFe
                       // replace FAT->autoriz
                       // replace FAT->DigVal
                        IMPORT->(qunlock())
                     endif

                case cSTATUS == "105"
                    //if FAT->(qrlock())
                    //    replace FAT->Nfe     with cNFE
                    //    replace FAT->Modelo  with "55"
                    //    replace FAT->Process with "S"
                    //    FAT->(qunlock())
                    // endif

                     alert(cStatus+";"+cMotivo+";Aguarde um momento e tente novamente!")

                otherwise
                     alert("NFe Nao autorizada! ;"+cStatus+";"+cMotivo)

             endcase

          endif
		  
	case cTIPO == "CONSULTAR"
          if left(cBuffer,2) == "OK"
             cRetorno := substr(cBuffer,at("[CONSULTA]",cBuffer),len(cBuffer))

             cStatus  := right(substr(cRetorno,at("CStat",cRetorno),9),3)

             //cNFE     := substr(cRetorno,at("ChNFe",cRetorno),len(cRetorno))
             //nEol     := at(cEOL,cNFE)-6
             //cNFE     := substr(cNFE,7,nEol-1)

             //cMotivo  := substr(cRetorno,at("XMotivo",cRetorno),len(cRetorno))
             //nEol     := at(cEOL,cMotivo)-8
             //cMotivo    := substr(cMOTIVO,9,nEol-1)

             //cRecibo  := substr(cRetorno,at("NRec",cRetorno),len(cRetorno))
             //nEol     := at(cEOL,cRecibo)-5
             //cRecibo  := substr(cRecibo,6,nEol-1)

             cDataRec := substr(cRetorno,at("DhRecbto",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cDataRec)-9
             cDataRec := substr(cDataRec,10,nEol-1)

             cAutoriz := substr(cRetorno,at("NProt",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cAutoriz)-6
             cAutoriz := substr(cAutoriz,7,nEol-1)

             //cDigVal  := substr(cRetorno,at("DigVal",cRetorno),len(cRetorno))
             //nEol     := at(cEOL,cDigVal)-7
             //cDigVal  := substr(cDigVal,8,nEol-1)

             //alert("Nota.: "+cNfe+ ";Recibo.: "+cRecibo+";Data.: "+cDataRec+";Autorizacao.: "+cAutoriz+";DigVal.: "+cDigVal)

             do case
                case cSTATUS == "100"
                     alert("NFe Autorizada! ;"+cNFE)

             endcase

          endif	  
		  
     case cTIPO == "CANCELAR"
          if left(cBuffer,2) == "OK"
             cRetorno := substr(cBuffer,at("[CANCELAMENTO]",cBuffer),len(cBuffer))
             cStatus  := right(substr(cRetorno,at("CStat",cRetorno),9),3)
             cNFE     := substr(cRetorno,at("ChNFe",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cNFE)-6
             cNFE     := substr(cNFE,7,nEol-1)

             cMotivo  := substr(cRetorno,at("XMotivo",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cMotivo)-8
             cMotivo  := substr(cMOTIVO,9,nEol-1)

             if cStatus == "101"
                alert("Cancelamento de NFe Homologado! ;"+cNFE)
             else
                alert("Cancelamento Nao Homologado ;"+cStatus+";"+cMotivo)
             endif
          endif

     case cTIPO == "INUTILIZAR"
          if left(cBuffer,2) == "OK"
             cRetorno := substr(cBuffer,at("[INUTILIZACAO]",cBuffer),len(cBuffer))
             cStatus  := right(substr(cRetorno,at("CStat",cRetorno),9),3)
             cNFE     := substr(cRetorno,at("ChNFe",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cNFE)-6
             cNFE     := substr(cNFE,7,nEol-1)

             cMotivo  := substr(cRetorno,at("XMotivo",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cMotivo)-8
             cMotivo  := substr(cMOTIVO,9,nEol-1)

             if cStatus == "102"
                alert("Inutilizacao de Numero Homologado!")
             else
                alert("Inutilizacao Nao Homologado ;"+cStatus+";"+cMotivo)
             endif
          endif

   endcase


  fclose(fileHnd)

  if ferase(cFile) == -1
     alert(str(ferror()))
  endif


return

static function i_geraNF
local nNF_ANTER := 0
local nNF_ATUAL := 0
local lCFGOK := .T.
local lFATOK := .T.
local lTESTE := .F.

  if empty(IMPORT->NFe)
     if ! IMPORT->Gerada

        nNF_ANTER := FATCFG->Cod_fat
        nNF_ATUAL := FATCFG->Cod_fat + 1

        if FATCFG->(qrlock())
           replace FATCFG->Cod_fat with nNF_ATUAL
           FATCFG->(qunlock())
           FATCFG->(Dbcommit())
        else
           qmensa("Nao foi possivel gravar Numero da Nota ! Config.DBF","B")
           lCFGOK := .F.
           return .F.
        endif

        if IMPORT->(qrlock())
           replace IMPORT->NUm_fatura with strzero(nNF_ATUAL,6)
           replace IMPORT->dt_emissao with date()
           IMPORT->(qunlock())
           IMPORT->(dbcommit())
        else
           qmensa("Pedido esta sendo usado por outro usuario !","B")
           lFATOK := .F.
           return .F.
        endif

        if lCFGOK .and. lFATOK .and. FATCFG->Cod_fat == (nNF_ANTER + 1) .and. val(IMPORT->Num_fatura) == (nNF_ANTER + 1)
           lTESTE := .T.
        else
           qmensa("Nota nao foi Gerada!","B")
           return .F.
        endif

        if lTESTE
           if IMPORT->(qrlock())
              replace IMPORT->Gerada with .T.
              IMPORT->(qunlock())
           endif

        endif
     else
        qmensa("NF ja foi gerada para este pedido!","B")
        return .F.
     endif
   else
     qmensa("NF Autorizada nao e possivel gerar numero!","B")
     return .F.

   endif



return

function i_516sts
 local cStatus := "          "

 if IMPORT->Cancelado
    cStatus := "Cancelada "
 else
    if ! empty(IMPORT->NFe)
       cStatus := "Autorizada"
    endif
 endif
return cStatus

static function i_trocachr(cTROCADO)

   cTROCADO := strtran(cTROCADO,",","")
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
   cTROCADO := strtran(cTROCADO,"&","E")
   cTROCADO := strtran(cTROCADO,"-","")
   cTROCADO := strtran(cTROCADO,"=","")
   cTROCADO := strtran(cTROCADO,"_","")
   cTROCADO := strtran(cTROCADO,"ø","")

return(cTROCADO)

static function buscaMunicipio(cCodIbge,cMunic)
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

static function CancelarNfe(cDestino)

    if IMPORT->Cancelado
       qmensa("Esta Nota Fiscal ja esta Cancelada!!!","B")
       return .F.
    endif

    if empty(IMPORT->Num_fatura)
       qmensa("Sem No de NF, impossivel Cancelar!!!","B")
       return .F.
    endif

    if qconf("Cofirma cancelamento de Nota Fiscal?")

       set printer to (XDRV_NFE+cDESTINO)
       set device to printer
       set margin to 0
       setprc(0,0)
       @ prow()+1,00 say 'NFE.CancelarNFe("'+IMPORT->NFe+'","Cancelamento de Nota Fiscal Eletronica")'

       set printer to
       set device to screen

       readfile(XDRV_NFE+"SAI.TXT","CANCELAR")

       IMPORT->(qrlock())
       replace IMPORT->Cancelado with .T.
       replace IMPORT->Obs With "### NOTA FISCAL CANCELADA ###"
       IMPORT->(qunlock())

  endif
return


static function ImprimirDanfe(cDestino)
   local cUNIDADE := ""

   quse(XDRV_CL,"CONFIG",NIL,NIL,"CFG")

   cUnidade := CFG->Unidade

   CFG->(dbclosearea())

   set printer to (XDRV_NFE+cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)
   if IMPORT->Cancelado
      @ prow()+1,00 say 'NFE.ImprimirDanfe("'+cUNIDADE+':\Qsys_g\Qfa_cl\Nfe\Canceladas\'+IMPORT->NFe+'-NFe.xml")'
   else
      @ prow()+1,00 say 'NFE.ImprimirDanfe("'+cUNIDADE+':\Qsys_g\Qfa_cl\Nfe\Autorizadas\'+IMPORT->NFe+'-NFe.xml")'
   endif

   set printer to
   set device to screen

   readfile(XDRV_NFE+"SAI.TXT","IMPRIMIR")

   select IMPORT

return

static function getNFe
local cNFE   := ""
   cNFE := "41"
   cNFE += substr(strzero(year(IMPORT->dt_emissao),4),3,2)
   cNFE += strzero(month(IMPORT->dt_emissao),2)
   FILIAL->(dbseek("0001"))
   cNFE += FILIAL->Cgccpf
   cNFE += "55001"
   cNFE += "000"+IMPORT->Num_fatura
   cNFE += "100"+IMPORT->Num_fatura

return cNFE

static function qdigNFe ( cSTRING )

  local nSOMA, nRESTO, cDIGITO, nCONT, nCTRL

  nSOMA   := 0
  nRESTO  := 0
  cDIGITO := 0
  nCTRL   := 2

  for nCONT = len(cSTRING) to 1 Step -1
    nSOMA += val(subs(cSTRING,nCONT,1)) * nCTRL

    if nCTRL = 9
       nCTRL = 1
    endif
    nCTRL++
  next


  nRESTO = nSOMA % 11


  if nRESTO = 0 .or. nRESTO = 1
     cDIGITO := 0
  else
     cDIGITO := 11 - nRESTO
  endif

return str(int(cDIGITO),1)

static function ConsultarNfe(cDestino)

    if IMPORT->Cancelado
       qmensa("Esta Nota Fiscal ja esta Cancelada!!!","B")
       return .F.
    endif

    if qconf("Verificar status da NFe?")

       set printer to (XDRV_NFE+cDESTINO)
       set device to printer
       set margin to 0
       setprc(0,0)
       @ prow()+1,00 say 'NFE.ConsultarNFe("'+IMPORT->NFe+'")'

       set printer to
       set device to screen

       readfile(XDRV_NFE+"SAI.TXT","CONSULTAR")

  endif


return




