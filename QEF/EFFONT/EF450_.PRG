/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: GI EM DISQUETE
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: ABRIL DE 2002
// OBS........:
// ALTERACOES.:
function ef450

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

#include "ef.ch"
private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1   := qlbloc("B450D","QBLOC.GLO")
private sBLOCO2   := qlbloc("B450E","QBLOC.GLO")
private sBLOCO3   := qlbloc("B450F","QBLOC.GLO")

private lCONF      // variavel  para confirmacoes
private cCONVENIO  // codigo do convenio
private nBUREAU    // numero da empresa bureau
private cMESANO    // mes e ano de competencia
private cDRIVE     // drive para gravacao
private cCAGED     // string de montagem de cada linha

private dDATA_INI   := ctod("01/01/2014")
private dDATA_FIM   := ctod("31/12/2014")
private dDATA_EMIS                  // Data de emissao
private dDATA_VENC                  // Data de vencimento
private bSAI_FILTRO
private bENT_FILTRO

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
private fOUT_BASES
private cDFCGI

private nGI301
private nGI3011
private nGI3012
private nGI3013
private nGI302
private nGI3021
private nGI3022
private nGI3023
private nGI303
private nGI3031
private nGI3032
private nGI3033
private nGI304
private nGI3041
private nGI3042
private nGI3043
private nGI305
private nGI3051
private nGI3052
private nGI3053
private nGI306
private nGI3061
private nGI3062
private nGI3063
private nGI307
private nGI3071
private nGI3072
private nGI3073
private nGI308
private nGI3081
private nGI3082
private nGI3083
private nGI310
private nGI3101
private nGI3102
private nGI3103
private nGI312
private nGI3121
private nGI3122
private nGI3123
private nGI313
private nGI3131
private nGI3132
private nGI3133
private nGI314
private nGI3141
private nGI3142
private nGI3143
private nGI315
private nGI3151
private nGI3152
private nGI3153
private nGI316
private nGI3161
private nGI3162
private nGI3163
private nGI318
private nGI3181
private nGI3182
private nGI3183
private nGI319
private nGI3191
private nGI3192
private nGI3193
private nGI320
private nGI3201
private nGI3202
private nGI3203
private nGI321
private nGI3211
private nGI3212
private nGI3213
private nGI322
private nGI3221
private nGI3222
private nGI3223
private nGI323
private nGI3231
private nGI3232
private nGI3233
private nGI324
private nGI3241
private nGI3242
private nGI3243
private nGI325
private nGI3251
private nGI3252
private nGI3253
private nGI326
private nGI3261
private nGI3262
private nGI3263
private nGI327
private nGI3271
private nGI3272
private nGI3273
private nGI328
private nGI3281
private nGI3282
private nGI3283
private nGI329
private nGI3291
private nGI3292
private nGI3293

private nGI501
private nGI5011
private nGI5012
private nGI5013
private nGI5014
private nGI5015
private nGI5016
private nGI502
private nGI5021
private nGI5022
private nGI5023
private nGI5024
private nGI5025
private nGI5026
private nGI503
private nGI5031
private nGI5032
private nGI5033
private nGI5034
private nGI5035
private nGI5036
private nGI504
private nGI5041
private nGI5042
private nGI5043
private nGI5044
private nGI5045
private nGI5046
private nGI505
private nGI5051
private nGI5052
private nGI5053
private nGI5054
private nGI5055
private nGI5056
private nGI506
private nGI5061
private nGI5062
private nGI5063
private nGI5064
private nGI5065
private nGI5066
private nGI507
private nGI5071
private nGI5072
private nGI5073
private nGI5074
private nGI5075
private nGI5076
private nGI508
private nGI5081
private nGI5082
private nGI5083
private nGI5084
private nGI5085
private nGI5086
private nGI510
private nGI5101
private nGI5102
private nGI5103
private nGI5104
private nGI5105
private nGI5106
private nGI512
private nGI5121
private nGI5122
private nGI5123
private nGI5124
private nGI5125
private nGI5126
private nGI513
private nGI5131
private nGI5132
private nGI5133
private nGI5134
private nGI5135
private nGI5136
private nGI514
private nGI5141
private nGI5142
private nGI5143
private nGI5144
private nGI5145
private nGI5146
private nGI515
private nGI5151
private nGI5152
private nGI5153
private nGI5154
private nGI5155
private nGI5156
private nGI516
private nGI5161
private nGI5162
private nGI5163
private nGI5164
private nGI5165
private nGI5166
private nGI518
private nGI5181
private nGI5182
private nGI5183
private nGI5184
private nGI5185
private nGI5186
private nGI519
private nGI5191
private nGI5192
private nGI5193
private nGI5194
private nGI5195
private nGI5196
private nGI520
private nGI5201
private nGI5202
private nGI5203
private nGI5204
private nGI5205
private nGI5206
private nGI521
private nGI5211
private nGI5212
private nGI5213
private nGI5214
private nGI5215
private nGI5216
private nGI522
private nGI5221
private nGI5222
private nGI5223
private nGI5224
private nGI5225
private nGI5226
private nGI523
private nGI5231
private nGI5232
private nGI5233
private nGI5234
private nGI5235
private nGI5236
private nGI524
private nGI5241
private nGI5242
private nGI5243
private nGI5244
private nGI5245
private nGI5246
private nGI525
private nGI5251
private nGI5252
private nGI5253
private nGI5254
private nGI5255
private nGI5256
private nGI526
private nGI5261
private nGI5262
private nGI5263
private nGI5264
private nGI5265
private nGI5266
private nGI527
private nGI5271
private nGI5272
private nGI5273
private nGI5274
private nGI5275
private nGI5276
private nGI528
private nGI5281
private nGI5282
private nGI5283
private nGI5284
private nGI5285
private nGI5286
private nGI529
private nGI5291
private nGI5292
private nGI5293
private nGI5294
private nGI5295
private nGI5296


private nLINHA

// ABRE ARQUIVO DFCGI.DBF E ZERA ______________________________________________

if ! quse(XDRV_EFX,"GI",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo GI.DBF !! Tente novamente.")
   return
endif

GI->(__dbzap())

// ABRE ARQUIVO QINST.DBF, FILTRA E ALIMENTA ARQUIVO CFGDISQ.DBF ____________

if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")
   qmensa("N„o foi poss¡vel abrir arquivo QINST.DBF !! Tente novamente.")
   return
endif

if ! quse("","QCONFIG") ; return ; endif

QINST->(dbSetFilter({|| Empresa <> "000"}, 'Empresa <> "000"'))

QINST->(dbgotop())

qlbloc(5,0,"B450A","QBLOC.GLO")

do while ! QINST->(eof())
   qgirabarra()

   if "EF" $ QINST->Sistemas

      qmensa("Montando Empresa: " + QINST->Razao)

      if ! quse(QINST->Drv_efx,"CONFIG",NIL,"R")
         qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
         return .F.
      endif

      if CFGDISQ->(dbseek(QINST->Empresa))
         if CFGDISQ->(qrlock())
            replace CFGDISQ->Razao      with QINST->Razao
            replace CFGDISQ->Cad_icms   with qtiraponto(alltrim(QINST->Inscr_est))
            replace CFGDISQ->Crc_contab with qtiraponto(alltrim(QCONFIG->Cont_crc))
         endif
      else
         if CFGDISQ->(qappend())
            replace CFGDISQ->Empresa    with QINST->Empresa
            replace CFGDISQ->Razao      with QINST->Razao
            replace CFGDISQ->Dfc        with CONFIG->Dfc
            replace CFGDISQ->Cad_icms   with qtiraponto(alltrim(QINST->Inscr_est))
            replace CFGDISQ->Crc_contab with qtiraponto(alltrim(QCONFIG->Cont_crc))
         endif
      endif

      CONFIG->(dbclosearea())

   else

      if CFGDISQ->(dbseek(QINST->Empresa))
         if CFGDISQ->(qrlock())
            CFGDISQ->(dbdelete())
         endif
      endif

   endif

   QINST->(dbskip())

enddo

qmensa()

QINST->(dbclosearea())
QCONFIG->(dbclosearea())

CFGDISQ->(dbgotop())

CFGDISQ->(qview({{"Empresa/Emp"  ,1},;
                 {"Razao/Raz„o"  ,0},;
                 {"f450a()/Emite",0}},"P",;
                 {NIL,"f450b",NIL,NIL},;
                  NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))
return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE EMITE CAGED OU NAO ______________________________

function f450a
return(iif(CFGDISQ->Dfc=="S","SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f450b
   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   do case
      case cOPCAO $ "AC"
           i_edicao()
      case cOPCAO == "P"
           i_processa()
   endcase

   setcursor(nCURSOR)

   select CFGDISQ

return ""
   
/////////////////////////////////////////////////////////////////////////////
// EDICAO DOS DADOS INFORMATIVOS POR EMPRESA ________________________________

static function i_edicao

   local aEDICAO1 := {}

   qlbloc(5,6,"B450B","QBLOC.GLO")

   CFGDISQ->(qpublicfields())
   CFGDISQ->(qinitfields())
   CFGDISQ->(qcopyfields())
   qsay(06,20,CFGDISQ->Empresa)
   qsay(06,26,left(CFGDISQ->Razao,44))

   XNIVEL := 1
   qrsay ( XNIVEL++ , qabrev(fDFC,"SN",{"Sim","N„o"}     ) )
   qrsay ( XNIVEL++ , qabrev(fTIPO_GIA,"12",{"1","2"} ) )
   qrsay ( XNIVEL++ , fCRC_CONTAB , "@R !!-999999/!-9")
        
   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________
   
   aadd(aEDICAO1,{{ || qesco(-1,0,@fDFC        ,SBLOCO1                  )} , "DFC"       })
   aadd(aEDICAO1,{{ || qesco(09,54,@fTIPO_GIA  ,SBLOCO2                  )} , "TIPO_GIA"  })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCRC_CONTAB ,"@R !!-999999/!-9"       )} , "CRC_CONTAB"})

   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.

   if(empty(fDFC),fDFC := "S",fDFC)
   if(empty(fTIPO_GIA),fTIPO_GIA := "1",fTIPO_GIA)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
      eval ( aEDICAO1 [XNIVEL,1] )
      if eval ( bESCAPE ) ; CFGDISQ->(qreleasefields()) ; return ; endif
      if ! i_critica1( aEDICAO1[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if cOPCAO == "A"
      if CFGDISQ->(qrlock())
         CFGDISQ->(qreplacefields())
         CFGDISQ->(qunlock())
      else
         qm2()
      endif
   endif

   // EDICAO DAS FILIAIS ____________________________________________________
   
   cPATH1 := "\QSYS_G\QCT\E" + CFGDISQ->Empresa + "\"
   // ABRE ARQUIVO DE FILIAIS _______________________________________________

   if ! quse(cPATH1,"FILIAL",{"FI_CGCCP"})
      qmensa("N„o foi poss¡vel abrir arquivo FILIAL.DBF !! Tente novamente.")
      return .F.
   endif

   FILIAL->(qview({{"left(Razao,30)/Filial",0},;
                   {"Codigo/C¢digo"        ,0}},"12062372",;
                   {NIL,"f450c",NIL,NIL},;
                    NIL,"<ESC> Encerra / <A>ltera / <C>onsulta"))

   FILIAL->(dbclosearea())

return ""

/////////////////////////////////////////////////////////////////////////////
// EDICAO DADOS DAS FILIAIS _________________________________________________

function f450c
   local aEDICAO2 := {}

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   qlbloc(10,6,"B450G","QBLOC.GLO")

   FILIAL->(qpublicfields())
   FILIAL->(qinitfields())
   FILIAL->(qcopyfields())

   XNIVEL := 1

   qsay(11,28,FILIAL->Codigo)
   qsay(11,35,left(FILIAL->Razao,20))
   qsay(13,28,transform(FILIAL->Insc_estad,"@R 99999999-99"))
   qsay(13,60,transform(FILIAL->Campo_02  , "@E 999,999.99"))
   qsay(15,28,transform(FILIAL->Campo_04  , "@E 999,999.99"))
   qsay(15,60,transform(FILIAL->Campo_06  , "@E 999,999.99"))
   qsay(17,28,transform(FILIAL->Estoque   , "@E 9,999,999,999.99"))
   qsay(17,64,transform(FILIAL->Num_func  , "@E 99.999"))
   qsay(19,28,transform(FILIAL->Folha_pgto, "@E 9,999,999,999.99"))

   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return "" ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO2,{{ || NIL                                        } ,"FILIAL"     })
   aadd(aEDICAO2,{{ || NIL                                        } ,NIL          })
   aadd(aEDICAO2,{{ || qgetx(13,28,@fINSC_ESTAD   ,"@R 99999999-99")} , "INSC_ESTAD"  })
   aadd(aEDICAO2,{{ || qgetx(13,60,@fCAMPO_02   ,"@E 999,999.99"          )} , "CAMPO_02"  })
   aadd(aEDICAO2,{{ || qgetx(15,28,@fCAMPO_04   ,"@E 999,999.99"          )} , "CAMPO_04"  })
   aadd(aEDICAO2,{{ || qgetx(15,60,@fCAMPO_06   ,"@E 999,999.99"          )} , "CAMPO_06"  })
   aadd(aEDICAO2,{{ || qgetx(17,28,@fESTOQUE,"@E 9,999,999,999.99"        )} , "ESTOQUE"   })
   aadd(aEDICAO2,{{ || qgetx(17,64,@fNUM_FUNC,"@E 99.999"                 )} , "NUM_FUNC"  })
   aadd(aEDICAO2,{{ || qgetx(19,28,@fFOLHA_PGTO,"@E 9,999,999,999.99"     )} , "FOLHA_PGTO"})
   
   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.

   cPATH := "\QSYS_G\QEF\E" + fEMPRESA + "\"
   cPATH2 := "\QSYS_G\QCP\E" + fEMPRESA + "\"


   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO2)
      eval ( aEDICAO2 [XNIVEL,1] )
      if eval ( bESCAPE ) ; FILIAL->(qreleasefields()) ; return "EXIT" ; endif
      if ! i_critica3( aEDICAO2[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO DA FILIAL ___________________________________________________

   if cOPCAO == "A"
      if FILIAL->(qrlock())
         FILIAL->(qreplacefields())
         FILIAL->(qunlock())
      else
         qm2()
      endif
   endif

   select FILIAL

return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA 2 ___________________________________________

static function i_critica3 ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "FILIAL"
           qsay(11,28,FILIAL->Codigo)
           qsay(11,35,left(FILIAL->Razao,20))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA 1 ___________________________________________

static function i_critica1 ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "DFC"
           if empty(fDFC) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fDFC,"SN",{"SIm","N„o"}) )

      case cCAMPO == "TIPO_GIA"
           qrsAy ( XNIVEL , qabrev(fTIPO_GIA,"12",{"1","2"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZACAO DO PROCESSO DE GERACAO DO CAGED EM DISQUETE ________________

static function i_processa
   local aEDICAO2 := {}

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO2,{{ || qesco(-1,0,@cDRIVE    ,SBLOCO3               ) } , "DRIVE"})
   aadd(aEDICAO2,{{ || lCONF := qconf("Confirma emiss„o do G.I.A. ?") } , NIL    })

   do while .T.

      qlbloc(5,0,"B450C","QBLOC.GLO")
      XNIVEL    := 1
      XFLAG     := .T.
      cDRIVE    := "A"

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO2)
         eval ( aEDICAO2 [XNIVEL,1] )
         if eval ( bESCAPE ) ; CFGDISQ->(qreleasefields()) ; return ; endif
         if ! i_critica2( aEDICAO2[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      iif ( lCONF , i_gravacao() , NIL )
      
   enddo

return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA 2 ___________________________________________

static function i_critica2 ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "DRIVE"
           qrsay(XNIVEL,qabrev(cDRIVE,"AB",{"A:","B:"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE GRAVACAO __________________________________________

static function i_gravacao

   CFGDISQ->(dbgotop())

   do while ! CFGDISQ->(eof())

      if CFGDISQ->DFC $ "N "
         CFGDISQ->(dbskip())
         loop
      endif

      cPATH1:= "\QSYS_G\QCT\E" + CFGDISQ->Empresa + "\"

      if ! quse(cPATH1,"FILIAL",{"FI_CGCCP"},"R")
         qmensa("N„o foi poss¡vel abrir arquivo FILIAL.DBF !! Tente novamente.")
         return .F.
      endif

      do while ! FILIAL->(eof())

         cPATH := "\QSYS_G\QEF\E" + CFGDISQ->Empresa + "\"
         cPATH2 := "\QSYS_G\QCP\E" + CFGDISQ->Empresa + "\"

         qsay(14,30,CFGDISQ->Empresa)
         qsay(14,36,left(CFGDISQ->Razao,35))

         if ! quse(cPATH,"CONFIG",NIL,"R")
            qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH,"IMP",{"IMP_DATA"},"E")
            qmensa("N„o foi poss¡vel abrir arquivo IMP.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH,"OUTENT",{"OUTENT"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo OUTENT.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH,"OUTSAI",{"OUTSAI"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo OUTSAI.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH,"ENT",{"ENT_LANC"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo ENT.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH,"SAI",{"SAI_LANC"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo SAI.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH2,"FORN",{"FORN_COD"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo FORN.DBF !! Tente novamente.")
            return .F.
         endif

         // VERIFICA SE FOI EXECUTADOS AS APURACOES ATNTES DE EMITIR ESTA OPCAO _____

         dDATA_INI := ctod("01/01/2014")

         dDATA_EMIS  := date()
         nVAL_EST    := 0
         dDATA_VENC  := ctod("")
         dDATA_INVE  := ctod("")
         dDATA_INI   := ctod("01/01/2014")
         dDATA_FIM   := ctod("31/12/2014")

         dDATA1_INI  := ctod("01/01/2014")
         dDATA1_FIM  := ctod("31/12/2014")

         fOUT_BASES := 0
         cDFCGI := ""

         nGI301     := 0
         nGI3011    := 0
         nGI3012    := 0
         nGI3013    := 0
         nGI302     := 0
         nGI3021    := 0
         nGI3022    := 0
         nGI3023    := 0
         nGI303     := 0
         nGI3031    := 0
         nGI3032    := 0
         nGI3033    := 0
         nGI304     := 0
         nGI3041    := 0
         nGI3042    := 0
         nGI3043    := 0
         nGI305     := 0
         nGI3051    := 0
         nGI3052    := 0
         nGI3053    := 0
         nGI306     := 0
         nGI3061    := 0
         nGI3062    := 0
         nGI3063    := 0
         nGI307     := 0
         nGI3071    := 0
         nGI3072    := 0
         nGI3073    := 0
         nGI308     := 0
         nGI3081    := 0
         nGI3082    := 0
         nGI3083    := 0
         nGI310     := 0
         nGI3101    := 0
         nGI3102    := 0
         nGI3103    := 0
         nGI312     := 0
         nGI3121    := 0
         nGI3122    := 0
         nGI3123    := 0
         nGI313     := 0
         nGI3131    := 0
         nGI3132    := 0
         nGI3133    := 0
         nGI314     := 0
         nGI3141    := 0
         nGI3142    := 0
         nGI3143    := 0
         nGI315     := 0
         nGI3151    := 0
         nGI3152    := 0
         nGI3153    := 0
         nGI316     := 0
         nGI3161    := 0
         nGI3162    := 0
         nGI3163    := 0
         nGI318     := 0
         nGI3181    := 0
         nGI3182    := 0
         nGI3183    := 0
         nGI319     := 0
         nGI3191    := 0
         nGI3192    := 0
         nGI3193    := 0
         nGI320     := 0
         nGI3201    := 0
         nGI3202    := 0
         nGI3203    := 0
         nGI321     := 0
         nGI3211    := 0
         nGI3212    := 0
         nGI3213    := 0
         nGI322     := 0
         nGI3221    := 0
         nGI3222    := 0
         nGI3223    := 0
         nGI323     := 0
         nGI3231    := 0
         nGI3232    := 0
         nGI3233    := 0
         nGI324     := 0
         nGI3241    := 0
         nGI3242    := 0
         nGI3243    := 0
         nGI325     := 0
         nGI3251    := 0
         nGI3252    := 0
         nGI3253    := 0
         nGI326     := 0
         nGI3261    := 0
         nGI3262    := 0
         nGI3263    := 0
         nGI327     := 0
         nGI3271    := 0
         nGI3272    := 0
         nGI3273    := 0
         nGI328     := 0
         nGI3281    := 0
         nGI3282    := 0
         nGI3283    := 0
         nGI329     := 0
         nGI3291    := 0
         nGI3292    := 0
         nGI3293    := 0

        nGI501      := 0
        nGI5011     := 0
        nGI5012     := 0
        nGI5013     := 0
        nGI5014     := 0
        nGI5015     := 0
        nGI5016     := 0
        nGI502      := 0
        nGI5021     := 0
        nGI5022     := 0
        nGI5023     := 0
        nGI5024     := 0
        nGI5025     := 0
        nGI5026     := 0
        nGI503      := 0
        nGI5031     := 0
        nGI5032     := 0
        nGI5033     := 0
        nGI5034     := 0
        nGI5035     := 0
        nGI5036     := 0
        nGI504      := 0
        nGI5041     := 0
        nGI5042     := 0
        nGI5043     := 0
        nGI5044     := 0
        nGI5045     := 0
        nGI5046     := 0
        nGI505      := 0
        nGI5051     := 0
        nGI5052     := 0
        nGI5053     := 0
        nGI5054     := 0
        nGI5055     := 0
        nGI5056     := 0
        nGI506      := 0
        nGI5061     := 0
        nGI5062     := 0
        nGI5063     := 0
        nGI5064     := 0
        nGI5065     := 0
        nGI5066     := 0
        nGI507      := 0
        nGI5071     := 0
        nGI5072     := 0
        nGI5073     := 0
        nGI5074     := 0
        nGI5075     := 0
        nGI5076     := 0
        nGI508      := 0
        nGI5081     := 0
        nGI5082     := 0
        nGI5083     := 0
        nGI5084     := 0
        nGI5085     := 0
        nGI5086     := 0
        nGI510      := 0
        nGI5101     := 0
        nGI5102     := 0
        nGI5103     := 0
        nGI5104     := 0
        nGI5105     := 0
        nGI5106     := 0
        nGI512      := 0
        nGI5121     := 0
        nGI5122     := 0
        nGI5123     := 0
        nGI5124     := 0
        nGI5125     := 0
        nGI5126     := 0
        nGI513      := 0
        nGI5131     := 0
        nGI5132     := 0
        nGI5133     := 0
        nGI5134     := 0
        nGI5135     := 0
        nGI5136     := 0
        nGI514      := 0
        nGI5141     := 0
        nGI5142     := 0
        nGI5143     := 0
        nGI5144     := 0
        nGI5145     := 0
        nGI5146     := 0
        nGI515      := 0
        nGI5151     := 0
        nGI5152     := 0
        nGI5153     := 0
        nGI5154     := 0
        nGI5155     := 0
        nGI5156     := 0
        nGI516      := 0
        nGI5161     := 0
        nGI5162     := 0
        nGI5163     := 0
        nGI5164     := 0
        nGI5165     := 0
        nGI5166     := 0
        nGI518      := 0
        nGI5181     := 0
        nGI5182     := 0
        nGI5183     := 0
        nGI5184     := 0
        nGI5185     := 0
        nGI5186     := 0
        nGI519      := 0
        nGI5191     := 0
        nGI5192     := 0
        nGI5193     := 0
        nGI5194     := 0
        nGI5195     := 0
        nGI5196     := 0
        nGI520      := 0
        nGI5201     := 0
        nGI5202     := 0
        nGI5203     := 0
        nGI5204     := 0
        nGI5205     := 0
        nGI5206     := 0
        nGI521      := 0
        nGI5211     := 0
        nGI5212     := 0
        nGI5213     := 0
        nGI5214     := 0
        nGI5215     := 0
        nGI5216     := 0
        nGI522      := 0
        nGI5221     := 0
        nGI5222     := 0
        nGI5223     := 0
        nGI5224     := 0
        nGI5225     := 0
        nGI5226     := 0
        nGI523      := 0
        nGI5231     := 0
        nGI5232     := 0
        nGI5233     := 0
        nGI5234     := 0
        nGI5235     := 0
        nGI5236     := 0
        nGI524      := 0
        nGI5241     := 0
        nGI5242     := 0
        nGI5243     := 0
        nGI5244     := 0
        nGI5245     := 0
        nGI5246     := 0
        nGI525      := 0
        nGI5251     := 0
        nGI5252     := 0
        nGI5253     := 0
        nGI5254     := 0
        nGI5255     := 0
        nGI5256     := 0
        nGI526      := 0
        nGI5261     := 0
        nGI5262     := 0
        nGI5263     := 0
        nGI5264     := 0
        nGI5265     := 0
        nGI5266     := 0
        nGI527      := 0
        nGI5271     := 0
        nGI5272     := 0
        nGI5273     := 0
        nGI5274     := 0
        nGI5275     := 0
        nGI5276     := 0
        nGI528      := 0
        nGI5281     := 0
        nGI5282     := 0
        nGI5283     := 0
        nGI5284     := 0
        nGI5285     := 0
        nGI5286     := 0
        nGI529      := 0
        nGI5291     := 0
        nGI5292     := 0
        nGI5293     := 0
        nGI5294     := 0
        nGI5295     := 0
        nGI5296     := 0



         if ( i_inicializacao() , i_impressao() , NIL )

         qmensa("")

         nLINHA := 0   // QUANTIDADE DE LINHA DO REGISTRO 2


         if nGI301  <>  0 ; nLINHA++;endif
         if nGI3011 <>  0 ; nLINHA++;endif
         if nGI3012 <>  0 ; nLINHA++;endif
         if nGI3013 <>  0 ; nLINHA++;endif
         if nGI302  <>  0 ; nLINHA++;endif
         if nGI3021 <>  0 ; nLINHA++;endif
         if nGI3022 <>  0 ; nLINHA++;endif
         if nGI3023 <>  0 ; nLINHA++;endif
         if nGI303  <>  0 ; nLINHA++;endif
         if nGI3031 <>  0 ; nLINHA++;endif
         if nGI3032 <>  0 ; nLINHA++;endif
         if nGI3033 <>  0 ; nLINHA++;endif
         if nGI304  <>  0 ; nLINHA++;endif
         if nGI3041 <>  0 ; nLINHA++;endif
         if nGI3042 <>  0 ; nLINHA++;endif
         if nGI3043 <>  0 ; nLINHA++;endif
         if nGI305  <>  0 ; nLINHA++;endif
         if nGI3051 <>  0 ; nLINHA++;endif
         if nGI3052 <>  0 ; nLINHA++;endif
         if nGI3053 <>  0 ; nLINHA++;endif
         if nGI306  <>  0 ; nLINHA++;endif
         if nGI3061 <>  0 ; nLINHA++;endif
         if nGI3062 <>  0 ; nLINHA++;endif
         if nGI3063 <>  0 ; nLINHA++;endif
         if nGI307  <>  0 ; nLINHA++;endif
         if nGI3071 <>  0 ; nLINHA++;endif
         if nGI3072 <>  0 ; nLINHA++;endif
         if nGI3073 <>  0 ; nLINHA++;endif
         if nGI308  <>  0 ; nLINHA++;endif
         if nGI3081 <>  0 ; nLINHA++;endif
         if nGI3082 <>  0 ; nLINHA++;endif
         if nGI3083 <>  0 ; nLINHA++;endif
         if nGI310  <>  0 ; nLINHA++;endif
         if nGI3101 <>  0 ; nLINHA++;endif
         if nGI3102 <>  0 ; nLINHA++;endif
         if nGI3103 <>  0 ; nLINHA++;endif
         if nGI312  <>  0 ; nLINHA++;endif
         if nGI3121 <>  0 ; nLINHA++;endif
         if nGI3122 <>  0 ; nLINHA++;endif
         if nGI3123 <>  0 ; nLINHA++;endif
         if nGI313  <>  0 ; nLINHA++;endif
         if nGI3131 <>  0 ; nLINHA++;endif
         if nGI3132 <>  0 ; nLINHA++;endif
         if nGI3133 <>  0 ; nLINHA++;endif
         if nGI314  <>  0 ; nLINHA++;endif
         if nGI3141 <>  0 ; nLINHA++;endif
         if nGI3142 <>  0 ; nLINHA++;endif
         if nGI3143 <>  0 ; nLINHA++;endif
         if nGI315  <>  0 ; nLINHA++;endif
         if nGI3151 <>  0 ; nLINHA++;endif
         if nGI3152 <>  0 ; nLINHA++;endif
         if nGI3153 <>  0 ; nLINHA++;endif
         if nGI316  <>  0 ; nLINHA++;endif
         if nGI3161 <>  0 ; nLINHA++;endif
         if nGI3162 <>  0 ; nLINHA++;endif
         if nGI3163 <>  0 ; nLINHA++;endif
         if nGI318  <>  0 ; nLINHA++;endif
         if nGI3181 <>  0 ; nLINHA++;endif
         if nGI3182 <>  0 ; nLINHA++;endif
         if nGI3183 <>  0 ; nLINHA++;endif
         if nGI319  <>  0 ; nLINHA++;endif
         if nGI3191 <>  0 ; nLINHA++;endif
         if nGI3192 <>  0 ; nLINHA++;endif
         if nGI3193 <>  0 ; nLINHA++;endif
         if nGI320  <>  0 ; nLINHA++;endif
         if nGI3201  <> 0 ; nLINHA++;endif
         if nGI3202  <> 0 ; nLINHA++;endif
         if nGI3203  <> 0 ; nLINHA++;endif
         if nGI321   <> 0 ; nLINHA++;endif
         if nGI3211  <> 0 ; nLINHA++;endif
         if nGI3212  <> 0 ; nLINHA++;endif
         if nGI3213  <> 0 ; nLINHA++;endif
         if nGI322   <> 0 ; nLINHA++;endif
         if nGI3221  <> 0 ; nLINHA++;endif
         if nGI3222  <> 0 ; nLINHA++;endif
         if nGI3223  <> 0 ; nLINHA++;endif
         if nGI323   <> 0 ; nLINHA++;endif
         if nGI3231  <> 0 ; nLINHA++;endif
         if nGI3232  <> 0 ; nLINHA++;endif
         if nGI3233  <> 0 ; nLINHA++;endif
         if nGI324   <> 0 ; nLINHA++;endif
         if nGI3241  <> 0 ; nLINHA++;endif
         if nGI3242  <> 0 ; nLINHA++;endif
         if nGI3243  <> 0 ; nLINHA++;endif
         if nGI325   <> 0 ; nLINHA++;endif
         if nGI3251  <> 0 ; nLINHA++;endif
         if nGI3252  <> 0 ; nLINHA++;endif
         if nGI3253  <> 0 ; nLINHA++;endif
         if nGI326   <> 0 ; nLINHA++;endif
         if nGI3261  <> 0 ; nLINHA++;endif
         if nGI3262  <> 0 ; nLINHA++;endif
         if nGI3263  <> 0 ; nLINHA++;endif
         if nGI327   <> 0 ; nLINHA++;endif
         if nGI3271  <> 0 ; nLINHA++;endif
         if nGI3272  <> 0 ; nLINHA++;endif
         if nGI3273  <> 0 ; nLINHA++;endif
         if nGI328   <> 0 ; nLINHA++;endif
         if nGI3281  <> 0 ; nLINHA++;endif
         if nGI3282  <> 0 ; nLINHA++;endif
         if nGI3283  <> 0 ; nLINHA++;endif
         if nGI329   <> 0 ; nLINHA++;endif
         if nGI3291  <> 0 ; nLINHA++;endif
         if nGI3292  <> 0 ; nLINHA++;endif
         if nGI3293  <> 0 ; nLINHA++;endif

         if nGI501   <> 0 ; nLINHA++;endif
         if nGI5011  <> 0 ; nLINHA++;endif
         if nGI5012  <> 0 ; nLINHA++;endif
         if nGI5013  <> 0 ; nLINHA++;endif
         if nGI5014  <> 0 ; nLINHA++;endif
         if nGI5015  <> 0 ; nLINHA++;endif
         if nGI5016  <> 0 ; nLINHA++;endif
         if nGI502   <> 0 ; nLINHA++;endif
         if nGI5021  <> 0 ; nLINHA++;endif
         if nGI5022  <> 0 ; nLINHA++;endif
         if nGI5023  <> 0 ; nLINHA++;endif
         if nGI5024  <> 0 ; nLINHA++;endif
         if nGI5025  <> 0 ; nLINHA++;endif
         if nGI5026  <> 0 ; nLINHA++;endif
         if nGI503   <> 0 ; nLINHA++;endif
         if nGI5031  <> 0 ; nLINHA++;endif
         if nGI5032  <> 0 ; nLINHA++;endif
         if nGI5033  <> 0 ; nLINHA++;endif
         if nGI5034  <> 0 ; nLINHA++;endif
         if nGI5035  <> 0 ; nLINHA++;endif
         if nGI5036  <> 0 ; nLINHA++;endif
         if nGI504   <> 0 ; nLINHA++;endif
         if nGI5041  <> 0 ; nLINHA++;endif
         if nGI5042  <> 0 ; nLINHA++;endif
         if nGI5043  <> 0 ; nLINHA++;endif
         if nGI5044  <> 0 ; nLINHA++;endif
         if nGI5045  <> 0 ; nLINHA++;endif
         if nGI5046  <> 0 ; nLINHA++;endif
         if nGI505   <> 0 ; nLINHA++;endif
         if nGI5051  <> 0 ; nLINHA++;endif
         if nGI5052  <> 0 ; nLINHA++;endif
         if nGI5053  <> 0 ; nLINHA++;endif
         if nGI5054  <> 0 ; nLINHA++;endif
         if nGI5055  <> 0 ; nLINHA++;endif
         if nGI5056  <> 0 ; nLINHA++;endif
         if nGI506   <> 0 ; nLINHA++;endif
         if nGI5061  <> 0 ; nLINHA++;endif
         if nGI5062  <> 0 ; nLINHA++;endif
         if nGI5063  <> 0 ; nLINHA++;endif
         if nGI5064  <> 0 ; nLINHA++;endif
         if nGI5065  <> 0 ; nLINHA++;endif
         if nGI5066  <> 0 ; nLINHA++;endif
         if nGI507   <> 0 ; nLINHA++;endif
         if nGI5071  <> 0 ; nLINHA++;endif
         if nGI5072  <> 0 ; nLINHA++;endif
         if nGI5073  <> 0 ; nLINHA++;endif
         if nGI5074  <> 0 ; nLINHA++;endif
         if nGI5075  <> 0 ; nLINHA++;endif
         if nGI5076  <> 0 ; nLINHA++;endif
         if nGI508   <> 0 ; nLINHA++;endif
         if nGI5081  <> 0 ; nLINHA++;endif
         if nGI5082  <> 0 ; nLINHA++;endif
         if nGI5083  <> 0 ; nLINHA++;endif
         if nGI5084  <> 0 ; nLINHA++;endif
         if nGI5085  <> 0 ; nLINHA++;endif
         if nGI5086  <> 0 ; nLINHA++;endif
         if nGI510   <> 0 ; nLINHA++;endif
         if nGI5101  <> 0 ; nLINHA++;endif
         if nGI5102  <> 0 ; nLINHA++;endif
         if nGI5103  <> 0 ; nLINHA++;endif
         if nGI5104  <> 0 ; nLINHA++;endif
         if nGI5105  <> 0 ; nLINHA++;endif
         if nGI5106  <> 0 ; nLINHA++;endif
         if nGI512   <> 0 ; nLINHA++;endif
         if nGI5121  <> 0 ; nLINHA++;endif
         if nGI5122  <> 0 ; nLINHA++;endif
         if nGI5123  <> 0 ; nLINHA++;endif
         if nGI5124  <> 0 ; nLINHA++;endif
         if nGI5125  <> 0 ; nLINHA++;endif
         if nGI5126  <> 0 ; nLINHA++;endif
         if nGI513   <> 0 ; nLINHA++;endif
         if nGI5131  <> 0 ; nLINHA++;endif
         if nGI5132  <> 0 ; nLINHA++;endif
         if nGI5133  <> 0 ; nLINHA++;endif
         if nGI5134  <> 0 ; nLINHA++;endif
         if nGI5135  <> 0 ; nLINHA++;endif
         if nGI5136  <> 0 ; nLINHA++;endif
         if nGI514   <> 0 ; nLINHA++;endif
         if nGI5141  <> 0 ; nLINHA++;endif
         if nGI5142  <> 0 ; nLINHA++;endif
         if nGI5143  <> 0 ; nLINHA++;endif
         if nGI5144  <> 0 ; nLINHA++;endif
         if nGI5145  <> 0 ; nLINHA++;endif
         if nGI5146  <> 0 ; nLINHA++;endif
         if nGI515   <> 0 ; nLINHA++;endif
         if nGI5151  <> 0 ; nLINHA++;endif
         if nGI5152  <> 0 ; nLINHA++;endif
         if nGI5153  <> 0 ; nLINHA++;endif
         if nGI5154  <> 0 ; nLINHA++;endif
         if nGI5155  <> 0 ; nLINHA++;endif
         if nGI5156  <> 0 ; nLINHA++;endif
         if nGI516   <> 0 ; nLINHA++;endif
         if nGI5161  <> 0 ; nLINHA++;endif
         if nGI5162  <> 0 ; nLINHA++;endif
         if nGI5163  <> 0 ; nLINHA++;endif
         if nGI5164  <> 0 ; nLINHA++;endif
         if nGI5165  <> 0 ; nLINHA++;endif
         if nGI5166  <> 0 ; nLINHA++;endif
         if nGI518   <> 0 ; nLINHA++;endif
         if nGI5181  <> 0 ; nLINHA++;endif
         if nGI5182  <> 0 ; nLINHA++;endif
         if nGI5183  <> 0 ; nLINHA++;endif
         if nGI5184  <> 0 ; nLINHA++;endif
         if nGI5185  <> 0 ; nLINHA++;endif
         if nGI5186  <> 0 ; nLINHA++;endif
         if nGI519   <> 0 ; nLINHA++;endif
         if nGI5191  <> 0 ; nLINHA++;endif
         if nGI5192  <> 0 ; nLINHA++;endif
         if nGI5193  <> 0 ; nLINHA++;endif
         if nGI5194  <> 0 ; nLINHA++;endif
         if nGI5195  <> 0 ; nLINHA++;endif
         if nGI5196  <> 0 ; nLINHA++;endif
         if nGI520   <> 0 ; nLINHA++;endif
         if nGI5201  <> 0 ; nLINHA++;endif
         if nGI5202  <> 0 ; nLINHA++;endif
         if nGI5203  <> 0 ; nLINHA++;endif
         if nGI5204  <> 0 ; nLINHA++;endif
         if nGI5205  <> 0 ; nLINHA++;endif
         if nGI5206  <> 0 ; nLINHA++;endif
         if nGI521   <> 0 ; nLINHA++;endif
         if nGI5211  <> 0 ; nLINHA++;endif
         if nGI5212  <> 0 ; nLINHA++;endif
         if nGI5213  <> 0 ; nLINHA++;endif
         if nGI5214  <> 0 ; nLINHA++;endif
         if nGI5215  <> 0 ; nLINHA++;endif
         if nGI5216  <> 0 ; nLINHA++;endif
         if nGI522   <> 0 ; nLINHA++;endif
         if nGI5221  <> 0 ; nLINHA++;endif
         if nGI5222  <> 0 ; nLINHA++;endif
         if nGI5223  <> 0 ; nLINHA++;endif
         if nGI5224  <> 0 ; nLINHA++;endif
         if nGI5225  <> 0 ; nLINHA++;endif
         if nGI5226  <> 0 ; nLINHA++;endif
         if nGI523   <> 0 ; nLINHA++;endif
         if nGI5231  <> 0 ; nLINHA++;endif
         if nGI5232  <> 0 ; nLINHA++;endif
         if nGI5233  <> 0 ; nLINHA++;endif
         if nGI5234  <> 0 ; nLINHA++;endif
         if nGI5235  <> 0 ; nLINHA++;endif
         if nGI5236  <> 0 ; nLINHA++;endif
         if nGI524   <> 0 ; nLINHA++;endif
         if nGI5241  <> 0 ; nLINHA++;endif
         if nGI5242  <> 0 ; nLINHA++;endif
         if nGI5243  <> 0 ; nLINHA++;endif
         if nGI5244  <> 0 ; nLINHA++;endif
         if nGI5245  <> 0 ; nLINHA++;endif
         if nGI5246  <> 0 ; nLINHA++;endif
         if nGI525   <> 0 ; nLINHA++;endif
         if nGI5251  <> 0 ; nLINHA++;endif
         if nGI5252  <> 0 ; nLINHA++;endif
         if nGI5253  <> 0 ; nLINHA++;endif
         if nGI5254  <> 0 ; nLINHA++;endif
         if nGI5255  <> 0 ; nLINHA++;endif
         if nGI5256  <> 0 ; nLINHA++;endif
         if nGI526   <> 0 ; nLINHA++;endif
         if nGI5261  <> 0 ; nLINHA++;endif
         if nGI5262  <> 0 ; nLINHA++;endif
         if nGI5263  <> 0 ; nLINHA++;endif
         if nGI5264  <> 0 ; nLINHA++;endif
         if nGI5265  <> 0 ; nLINHA++;endif
         if nGI5266  <> 0 ; nLINHA++;endif
         if nGI527   <> 0 ; nLINHA++;endif
         if nGI5271  <> 0 ; nLINHA++;endif
         if nGI5272  <> 0 ; nLINHA++;endif
         if nGI5273  <> 0 ; nLINHA++;endif
         if nGI5274  <> 0 ; nLINHA++;endif
         if nGI5275  <> 0 ; nLINHA++;endif
         if nGI5276  <> 0 ; nLINHA++;endif
         if nGI528   <> 0 ; nLINHA++;endif
         if nGI5281  <> 0 ; nLINHA++;endif
         if nGI5282  <> 0 ; nLINHA++;endif
         if nGI5283  <> 0 ; nLINHA++;endif
         if nGI5284  <> 0 ; nLINHA++;endif
         if nGI5285  <> 0 ; nLINHA++;endif
         if nGI5286  <> 0 ; nLINHA++;endif
         if nGI529   <> 0 ; nLINHA++;endif
         if nGI5291  <> 0 ; nLINHA++;endif
         if nGI5292  <> 0 ; nLINHA++;endif
         if nGI5293  <> 0 ; nLINHA++;endif
         if nGI5294  <> 0 ; nLINHA++;endif
         if nGI5295  <> 0 ; nLINHA++;endif
         if nGI5296  <> 0 ; nLINHA++;endif


         //REGISTRO TIPO 1

         cDFCGI := "1" + "31" + left(FILIAL->Insc_estad,10) + FILIAL->Cgccpf+ "201412"+ "C"
         cDFCGI += CFGDISQ->Crc_contab +"     " +" " + space(59)
         cDFCGI += strzero(nLINHA,3)
         nLINHA := 0
         GI->(qappend())
         GI->Linha := cDFCGI
         cDFCGI := ""

         if nGI3011 <> 0
            cDFCGI := "2" + "3011" + strzero(nGI3011,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3012 <> 0
            cDFCGI := "2" + "3012" + strzero(nGI3012,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3013 <> 0
            cDFCGI := "2" + "3013" + strzero(nGI3013,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3021 <> 0
            cDFCGI := "2" + "3021" + strzero(nGI3021,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3022 <> 0
            cDFCGI := "2" + "3022" + strzero(nGI3022,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3023 <> 0
            cDFCGI := "2" + "3023" + strzero(nGI3023,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3031 <> 0
            cDFCGI := "2" + "3031" + strzero(nGI3031,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3032 <> 0
            cDFCGI := "2" + "3032" + strzero(nGI3032,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif


         if nGI3033 <> 0
            cDFCGI := "2" + "3033" + strzero(nGI3033,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3041 <> 0
            cDFCGI := "2" + "3041" + strzero(nGI3041,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3042 <> 0
            cDFCGI := "2" + "3042" + strzero(nGI3042,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3043 <> 0
            cDFCGI := "2" + "3043" + strzero(nGI3043,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3051 <> 0
            cDFCGI := "2" + "3051" + strzero(nGI3051,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3052 <> 0
            cDFCGI := "2" + "3052" + strzero(nGI3052,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3053 <> 0
            cDFCGI := "2" + "3053" + strzero(nGI3053,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3061 <> 0
            cDFCGI := "2" + "3061" + strzero(nGI3061,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3062 <> 0
            cDFCGI := "2" + "3062" + strzero(nGI3062,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3063 <> 0
            cDFCGI := "2" + "3063" + strzero(nGI3063,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3071 <> 0
            cDFCGI := "2" + "3071" + strzero(nGI3071,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3072 <> 0
            cDFCGI := "2" + "3072" + strzero(nGI3072,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3073 <> 0
            cDFCGI := "2" + "3073" + strzero(nGI3073,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3081 <> 0
            cDFCGI := "2" + "3081" + strzero(nGI3081,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3082 <> 0
            cDFCGI := "2" + "3082" + strzero(nGI3082,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3083 <> 0
            cDFCGI := "2" + "3083" + strzero(nGI3083,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3101 <> 0
            cDFCGI := "2" + "3101" + strzero(nGI3101,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3102 <> 0
            cDFCGI := "2" + "3102" + strzero(nGI3102,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3103 <> 0
            cDFCGI := "2" + "3103" + strzero(nGI3103,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI3121 <> 0
            cDFCGI := "2" + "3121" + strzero(nGI3121,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3122 <> 0
            cDFCGI := "2" + "3122" + strzero(nGI3122,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3123 <> 0
            cDFCGI := "2" + "3123" + strzero(nGI3123,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3131 <> 0
            cDFCGI := "2" + "3131" + strzero(nGI3131,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3132 <> 0
            cDFCGI := "2" + "3132" + strzero(nGI3132,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3133 <> 0
            cDFCGI := "2" + "3133" + strzero(nGI3133,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3141 <> 0
            cDFCGI := "2" + "3141" + strzero(nGI3141,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3142 <> 0
            cDFCGI := "2" + "3142" + strzero(nGI3142,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3143 <> 0
            cDFCGI := "2" + "3143" + strzero(nGI3143,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3151 <> 0
            cDFCGI := "2" + "3151" + strzero(nGI3151,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3152 <> 0
            cDFCGI := "2" + "3152" + strzero(nGI3152,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3153 <> 0
            cDFCGI := "2" + "3153" + strzero(nGI3153,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3161 <> 0
            cDFCGI := "2" + "3161" + strzero(nGI3161,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3162 <> 0
            cDFCGI := "2" + "3162" + strzero(nGI3162,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3163 <> 0
            cDFCGI := "2" + "3163" + strzero(nGI3163,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3181 <> 0
            cDFCGI := "2" + "3181" + strzero(nGI3181,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3182 <> 0
            cDFCGI := "2" + "3182" + strzero(nGI3182,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3183 <> 0
            cDFCGI := "2" + "3183" + strzero(nGI3183,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3191 <> 0
            cDFCGI := "2" + "3191" + strzero(nGI3191,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3192 <> 0
            cDFCGI := "2" + "3192" + strzero(nGI3192,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3193 <> 0
            cDFCGI := "2" + "3193" + strzero(nGI3193,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3201 <> 0
            cDFCGI := "2" + "3201" + strzero(nGI3201,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3202 <> 0
            cDFCGI := "2" + "3202" + strzero(nGI3202,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3203 <> 0
            cDFCGI := "2" + "3203" + strzero(nGI3203,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3211 <> 0
            cDFCGI := "2" + "3211" + strzero(nGI3211,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3212 <> 0
            cDFCGI := "2" + "3212" + strzero(nGI3212,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3213 <> 0
            cDFCGI := "2" + "3213" + strzero(nGI3213,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3221 <> 0
            cDFCGI := "2" + "3221" + strzero(nGI3221,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3222 <> 0
            cDFCGI := "2" + "3222" + strzero(nGI3222,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3223 <> 0
            cDFCGI := "2" + "3223" + strzero(nGI3223,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3231 <> 0
            cDFCGI := "2" + "3231" + strzero(nGI3231,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3232 <> 0
            cDFCGI := "2" + "3232" + strzero(nGI3232,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3233 <> 0
            cDFCGI := "2" + "3233" + strzero(nGI3233,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3241 <> 0
            cDFCGI := "2" + "3241" + strzero(nGI3241,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3242 <> 0
            cDFCGI := "2" + "3242" + strzero(nGI3242,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3243 <> 0
            cDFCGI := "2" + "3243" + strzero(nGI3243,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3251 <> 0
            cDFCGI := "2" + "3251" + strzero(nGI3251,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3252 <> 0
            cDFCGI := "2" + "3252" + strzero(nGI3252,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3253 <> 0
            cDFCGI := "2" + "3253" + strzero(nGI3253,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3261 <> 0
            cDFCGI := "2" + "3261" + strzero(nGI3261,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3262 <> 0
            cDFCGI := "2" + "3262" + strzero(nGI3262,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3263 <> 0
            cDFCGI := "2" + "3263" + strzero(nGI3263,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3271 <> 0
            cDFCGI := "2" + "3271" + strzero(nGI3271,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3272 <> 0
            cDFCGI := "2" + "3272" + strzero(nGI3272,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3273 <> 0
            cDFCGI := "2" + "3273" + strzero(nGI3273,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3281 <> 0
            cDFCGI := "2" + "3281" + strzero(nGI3281,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3282 <> 0
            cDFCGI := "2" + "3282" + strzero(nGI3282,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3283 <> 0
            cDFCGI := "2" + "3283" + strzero(nGI3283,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3291 <> 0
            cDFCGI := "2" + "3291" + strzero(nGI3291,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3292 <> 0
            cDFCGI := "2" + "3292" + strzero(nGI3292,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI3293 <> 0
            cDFCGI := "2" + "3293" + strzero(nGI3293,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5011 <> 0
            cDFCGI := "2" + "5011" + strzero(nGI5011,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5012 <> 0
            cDFCGI := "2" + "5012" + strzero(nGI5012,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5013 <> 0
            cDFCGI := "2" + "5013" + strzero(nGI5013,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5014 <> 0
            cDFCGI := "2" + "5014" + strzero(nGI5014,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5015 <> 0
            cDFCGI := "2" + "5015" + strzero(nGI5015,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5016 <> 0
            cDFCGI := "2" + "5016" + strzero(nGI5016,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5021 <> 0
            cDFCGI := "2" + "5021" + strzero(nGI5021,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5022 <> 0
            cDFCGI := "2" + "5022" + strzero(nGI5022,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5023 <> 0
            cDFCGI := "2" + "5023" + strzero(nGI5023,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5024 <> 0
            cDFCGI := "2" + "5024" + strzero(nGI5024,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5025 <> 0
            cDFCGI := "2" + "5025" + strzero(nGI5025,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5026 <> 0
            cDFCGI := "2" + "5026" + strzero(nGI5026,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5031 <> 0
            cDFCGI := "2" + "5031" + strzero(nGI5031,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5032 <> 0
            cDFCGI := "2" + "5032" + strzero(nGI5032,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5033 <> 0
            cDFCGI := "2" + "5033" + strzero(nGI5033,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5034 <> 0
            cDFCGI := "2" + "5034" + strzero(nGI5034,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5035 <> 0
            cDFCGI := "2" + "5035" + strzero(nGI5035,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5036 <> 0
            cDFCGI := "2" + "5036" + strzero(nGI5036,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5041 <> 0
            cDFCGI := "2" + "5041" + strzero(nGI5041,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5042 <> 0
            cDFCGI := "2" + "5042" + strzero(nGI5042,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5043 <> 0
            cDFCGI := "2" + "5043" + strzero(nGI5043,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5044 <> 0
            cDFCGI := "2" + "5044" + strzero(nGI5044,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5045 <> 0
            cDFCGI := "2" + "5045" + strzero(nGI5045,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5046 <> 0
            cDFCGI := "2" + "5046" + strzero(nGI5046,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5051 <> 0
            cDFCGI := "2" + "5051" + strzero(nGI5051,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5052 <> 0
            cDFCGI := "2" + "5052" + strzero(nGI5052,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5053 <> 0
            cDFCGI := "2" + "5053" + strzero(nGI5053,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5054 <> 0
            cDFCGI := "2" + "5054" + strzero(nGI5054,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5055 <> 0
            cDFCGI := "2" + "5055" + strzero(nGI5055,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5056 <> 0
            cDFCGI := "2" + "5056" + strzero(nGI5056,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5061 <> 0
            cDFCGI := "2" + "5061" + strzero(nGI5061,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5062 <> 0
            cDFCGI := "2" + "5062" + strzero(nGI5062,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5063 <> 0
            cDFCGI := "2" + "5063" + strzero(nGI5063,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5064 <> 0
            cDFCGI := "2" + "5064" + strzero(nGI5064,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5065 <> 0
            cDFCGI := "2" + "5065" + strzero(nGI5065,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5066 <> 0
            cDFCGI := "2" + "5066" + strzero(nGI5066,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5071 <> 0
            cDFCGI := "2" + "5071" + strzero(nGI5071,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5072 <> 0
            cDFCGI := "2" + "5072" + strzero(nGI5072,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5073 <> 0
            cDFCGI := "2" + "5073" + strzero(nGI5073,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5074 <> 0
            cDFCGI := "2" + "5074" + strzero(nGI5074,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5075 <> 0
            cDFCGI := "2" + "5075" + strzero(nGI5075,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5076 <> 0
            cDFCGI := "2" + "5076" + strzero(nGI5076,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5081 <> 0
            cDFCGI := "2" + "5081" + strzero(nGI5081,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5082 <> 0
            cDFCGI := "2" + "5082" + strzero(nGI5082,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5083 <> 0
            cDFCGI := "2" + "5083" + strzero(nGI5083,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5084 <> 0
            cDFCGI := "2" + "5084" + strzero(nGI5084,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5085 <> 0
            cDFCGI := "2" + "5085" + strzero(nGI5085,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5086 <> 0
            cDFCGI := "2" + "5086" + strzero(nGI5086,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5101 <> 0
            cDFCGI := "2" + "5101" + strzero(nGI5101,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5102 <> 0
            cDFCGI := "2" + "5102" + strzero(nGI5102,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5103 <> 0
            cDFCGI := "2" + "5103" + strzero(nGI5103,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5104 <> 0
            cDFCGI := "2" + "5104" + strzero(nGI5104,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5105 <> 0
            cDFCGI := "2" + "5105" + strzero(nGI5105,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5106 <> 0
            cDFCGI := "2" + "5106" + strzero(nGI5106,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5121 <> 0
            cDFCGI := "2" + "5121" + strzero(nGI5121,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5122 <> 0
            cDFCGI := "2" + "5122" + strzero(nGI5122,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5123 <> 0
            cDFCGI := "2" + "5123" + strzero(nGI5123,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5124 <> 0
            cDFCGI := "2" + "5124" + strzero(nGI5124,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5125 <> 0
            cDFCGI := "2" + "5125" + strzero(nGI5125,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5126 <> 0
            cDFCGI := "2" + "5126" + strzero(nGI5126,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5131 <> 0
            cDFCGI := "2" + "5131" + strzero(nGI5131,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5132 <> 0
            cDFCGI := "2" + "5132" + strzero(nGI5132,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5133 <> 0
            cDFCGI := "2" + "5133" + strzero(nGI5133,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5134 <> 0
            cDFCGI := "2" + "5134" + strzero(nGI5134,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5135 <> 0
            cDFCGI := "2" + "5135" + strzero(nGI5135,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5136 <> 0
            cDFCGI := "2" + "5136" + strzero(nGI5136,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5141 <> 0
            cDFCGI := "2" + "5141" + strzero(nGI5141,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5142 <> 0
            cDFCGI := "2" + "5142" + strzero(nGI5142,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5143 <> 0
            cDFCGI := "2" + "5143" + strzero(nGI5143,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5144 <> 0
            cDFCGI := "2" + "5144" + strzero(nGI5144,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5145 <> 0
            cDFCGI := "2" + "5145" + strzero(nGI5145,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5146 <> 0
            cDFCGI := "2" + "5146" + strzero(nGI5146,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5151 <> 0
            cDFCGI := "2" + "5151" + strzero(nGI5151,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5152 <> 0
            cDFCGI := "2" + "5152" + strzero(nGI5152,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5153 <> 0
            cDFCGI := "2" + "5153" + strzero(nGI5153,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5154 <> 0
            cDFCGI := "2" + "5154" + strzero(nGI5154,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5155 <> 0
            cDFCGI := "2" + "5155" + strzero(nGI5155,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5156 <> 0
            cDFCGI := "2" + "5156" + strzero(nGI5156,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5161 <> 0
            cDFCGI := "2" + "5161" + strzero(nGI5161,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5162 <> 0
            cDFCGI := "2" + "5162" + strzero(nGI5162,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5163 <> 0
            cDFCGI := "2" + "5163" + strzero(nGI5163,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5164 <> 0
            cDFCGI := "2" + "5164" + strzero(nGI5164,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5165 <> 0
            cDFCGI := "2" + "5165" + strzero(nGI5165,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5166 <> 0
            cDFCGI := "2" + "5166" + strzero(nGI5166,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5181 <> 0
            cDFCGI := "2" + "5181" + strzero(nGI5181,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5182 <> 0
            cDFCGI := "2" + "5182" + strzero(nGI5182,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5183 <> 0
            cDFCGI := "2" + "5183" + strzero(nGI5183,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5184 <> 0
            cDFCGI := "2" + "5184" + strzero(nGI5184,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5185 <> 0
            cDFCGI := "2" + "5185" + strzero(nGI5185,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5191 <> 0
            cDFCGI := "2" + "5191" + strzero(nGI5191,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5192 <> 0
            cDFCGI := "2" + "5192" + strzero(nGI5192,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5193 <> 0
            cDFCGI := "2" + "5193" + strzero(nGI5193,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5194 <> 0
            cDFCGI := "2" + "5194" + strzero(nGI5194,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5195 <> 0
            cDFCGI := "2" + "5195" + strzero(nGI5195,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5196 <> 0
            cDFCGI := "2" + "5196" + strzero(nGI5196,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5201 <> 0
            cDFCGI := "2" + "5201" + strzero(nGI5201,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5202 <> 0
            cDFCGI := "2" + "5202" + strzero(nGI5202,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5203 <> 0
            cDFCGI := "2" + "5203" + strzero(nGI5203,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5204 <> 0
            cDFCGI := "2" + "5204" + strzero(nGI5204,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5205 <> 0
            cDFCGI := "2" + "5205" + strzero(nGI5205,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5206 <> 0
            cDFCGI := "2" + "5206" + strzero(nGI5206,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5211 <> 0
            cDFCGI := "2" + "5211" + strzero(nGI5211,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5212 <> 0
            cDFCGI := "2" + "5212" + strzero(nGI5212,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5213 <> 0
            cDFCGI := "2" + "5213" + strzero(nGI5213,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5214 <> 0
            cDFCGI := "2" + "5214" + strzero(nGI5214,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5215 <> 0
            cDFCGI := "2" + "5215" + strzero(nGI5215,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5216 <> 0
            cDFCGI := "2" + "5216" + strzero(nGI5216,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5221 <> 0
            cDFCGI := "2" + "5221" + strzero(nGI5221,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5222 <> 0
            cDFCGI := "2" + "5222" + strzero(nGI5222,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5223 <> 0
            cDFCGI := "2" + "5223" + strzero(nGI5223,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5224 <> 0
            cDFCGI := "2" + "5224" + strzero(nGI5224,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5225 <> 0
            cDFCGI := "2" + "5225" + strzero(nGI5225,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5226 <> 0
            cDFCGI := "2" + "5226" + strzero(nGI5226,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5231 <> 0
            cDFCGI := "2" + "5231" + strzero(nGI5231,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5232 <> 0
            cDFCGI := "2" + "5232" + strzero(nGI5232,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5233 <> 0
            cDFCGI := "2" + "5233" + strzero(nGI5233,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5234 <> 0
            cDFCGI := "2" + "5234" + strzero(nGI5234,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5235 <> 0
            cDFCGI := "2" + "5235" + strzero(nGI5235,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5236 <> 0
            cDFCGI := "2" + "5236" + strzero(nGI5236,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5241 <> 0
            cDFCGI := "2" + "5241" + strzero(nGI5241,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5242 <> 0
            cDFCGI := "2" + "5242" + strzero(nGI5242,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5243 <> 0
            cDFCGI := "2" + "5243" + strzero(nGI5243,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5244 <> 0
            cDFCGI := "2" + "5244" + strzero(nGI5244,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5245 <> 0
            cDFCGI := "2" + "5245" + strzero(nGI5245,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5246 <> 0
            cDFCGI := "2" + "5246" + strzero(nGI5246,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5251 <> 0
            cDFCGI := "2" + "5251" + strzero(nGI5251,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5252 <> 0
            cDFCGI := "2" + "5252" + strzero(nGI5252,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5253 <> 0
            cDFCGI := "2" + "5253" + strzero(nGI5253,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5254 <> 0
            cDFCGI := "2" + "5254" + strzero(nGI5254,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5255 <> 0
            cDFCGI := "2" + "5255" + strzero(nGI5255,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5256 <> 0
            cDFCGI := "2" + "5256" + strzero(nGI5256,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5261 <> 0
            cDFCGI := "2" + "5261" + strzero(nGI5261,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5262 <> 0
            cDFCGI := "2" + "5262" + strzero(nGI5262,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5263 <> 0
            cDFCGI := "2" + "5263" + strzero(nGI5263,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5264 <> 0
            cDFCGI := "2" + "5264" + strzero(nGI5264,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5265 <> 0
            cDFCGI := "2" + "5265" + strzero(nGI5265,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5266 <> 0
            cDFCGI := "2" + "5266" + strzero(nGI5266,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5271 <> 0
            cDFCGI := "2" + "5271" + strzero(nGI5271,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5272 <> 0
            cDFCGI := "2" + "5272" + strzero(nGI5272,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5273 <> 0
            cDFCGI := "2" + "5273" + strzero(nGI5273,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5274 <> 0
            cDFCGI := "2" + "5274" + strzero(nGI5274,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5275 <> 0
            cDFCGI := "2" + "5275" + strzero(nGI5275,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5276 <> 0
            cDFCGI := "2" + "5276" + strzero(nGI5276,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5281 <> 0
            cDFCGI := "2" + "5281" + strzero(nGI5281,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5282 <> 0
            cDFCGI := "2" + "5282" + strzero(nGI5282,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5283 <> 0
            cDFCGI := "2" + "5283" + strzero(nGI5283,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5284 <> 0
            cDFCGI := "2" + "5284" + strzero(nGI5284,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5285 <> 0
            cDFCGI := "2" + "5285" + strzero(nGI5285,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5286 <> 0
            cDFCGI := "2" + "5286" + strzero(nGI5286,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         if nGI5291 <> 0
            cDFCGI := "2" + "5291" + strzero(nGI5291,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5292 <> 0
            cDFCGI := "2" + "5292" + strzero(nGI5292,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5293 <> 0
            cDFCGI := "2" + "5293" + strzero(nGI5293,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5294 <> 0
            cDFCGI := "2" + "5294" + strzero(nGI5294,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5295 <> 0
            cDFCGI := "2" + "5295" + strzero(nGI5295,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif
         if nGI5296 <> 0
            cDFCGI := "2" + "5296" + strzero(nGI5296,15)
            GI->(qappend())
            GI->Linha := cDFCGI
            cDFCGI := ""
         endif

         CONFIG->(dbclosearea())
         IMP->(dbclosearea())
         OUTENT->(dbclosearea())
         OUTSAI->(dbclosearea())
         ENT->(dbclosearea())
         SAI->(dbclosearea())
         FORN->(dbclosearea())

         FILIAL->(Dbskip())

      enddo

      FILIAL->(Dbclosearea())

      CFGDISQ->(dbskip())

   enddo

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")
   
   cNOMARQ :=  "c:\qsystxt\GI_QSYS.TXT"
   GI->(dbgotop())

   GI->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

   qmensa()

   select CFGDISQ

   CFGDISQ->(dbgotop())

   if GI->(qflock())
      GI->(__dbzap())
   endif

return

////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO __________________________

static function i_inicializacao

   // CRIA MACRO DE FILTRO _________________________________________________

   //SAI->(dbSetFilter({|| alltrim(Filial) $ FILIAL->Codigo}, 'alltrim(Filial) $ FILIAL->Codigo'))
   //ENT->(dbSetFilter({|| alltrim(Filial) $ FILIAL->Codigo}, 'alltrim(Filial) $ FILIAL->Codigo'))
   bENT_FILTRO  := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO  := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ___________________________________

   set softseek on

   select IMP
   IMP->(dbgotop())

   select OUTENT
   OUTENT->(dbseek(dtos(dDATA_INI)))

   select OUTSAI
   OUTSAI->(dbgotop())

   select ENT
   set softseek on
   ENT->(dbsetorder(2))
   ENT->(dbseek(dtos(dDATA_INI)))
   set softseek off

   select SAI
   set softseek on
   SAI->(dbsetorder(2))
   SAI->(dbseek(dtos(dDATA_INI)))
   set softseek off

return .T.

////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _________________________

static function i_impressao
    local cMUN := space(2)

   // CONDICAO PRINCIPAL DE LOOP ___________________________________________


   do while !ENT->(eof()) .and. eval(bENT_FILTRO)


         qmensa("Aguarde! Somando Nota: "+ENT->Num_Nf +" / Serie : "+ENT->Serie)

         if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
            for nCONT = 1 to 5
                 aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
                 aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
                 aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr
                 // BASE DAS OUTRAS ALIQUOTAS DE ICMS
                 fOUT_BASES += OUTENT->ICM_BASE
                 OUTENT->(dbskip())
                 if ENT->Num_nf + ENT->Serie + ENT->Filial+dtoc(ENT->Data_lanc) <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial+Dtoc(OUTENT->Data_lanc)
                    exit
                 endif
            next
         endif
         FORN->(dbseek(ENT->Cod_forn))
         CGM->(Dbseek(FORN->Cgm_ent))
         cMUN := CGM->Estado
         do case
            case cMUN == "PR"

            case cMUN == "AC"
                 nGI3011 += ENT->Vlr_cont
                 nGI3012 += ENT->Icm_base + fOUT_BASES
                 nGI3013 += ENT->Icm_out

            case cMUN == "AL"
                 nGI3021 += ENT->Vlr_cont
                 nGI3022 += ENT->Icm_base + fOUT_BASES
                 nGI3023 += ENT->Icm_out
            case cMUN == "AP"
                 nGI3031 += ENT->Vlr_cont
                 nGI3032 += ENT->Icm_base + fOUT_BASES
                 nGI3033 += ENT->Icm_out
            case cMUN == "AM"
                 nGI3041 += ENT->Vlr_cont
                 nGI3042 += ENT->Icm_base + fOUT_BASES
                 nGI3043 += ENT->Icm_out
            case cMUN == "BA"
                 nGI3051 += ENT->Vlr_cont
                 nGI3052 += ENT->Icm_base + fOUT_BASES
                 nGI3053 += ENT->Icm_out
            case cMUN == "CE"
                 nGI3061 += ENT->Vlr_cont
                 nGI3062 += ENT->Icm_base + fOUT_BASES
                 nGI3063 += ENT->Icm_out
            case cMUN == "DF"
                 nGI3071 += ENT->Vlr_cont
                 nGI3072 += ENT->Icm_base + fOUT_BASES
                 nGI3073 += ENT->Icm_out
            case cMUN == "ES"
                 nGI3081 += ENT->Vlr_cont
                 nGI3082 += ENT->Icm_base + fOUT_BASES
                 nGI3083 += ENT->Icm_out
            case cMUN == "GO"
                 nGI3101 += ENT->Vlr_cont
                 nGI3102 += ENT->Icm_base + fOUT_BASES
                 nGI3103 += ENT->Icm_out
            case cMUN == "MA"
                 nGI3121 += ENT->Vlr_cont
                 nGI3122 += ENT->Icm_base + fOUT_BASES
                 nGI3123 += ENT->Icm_out
            case cMUN == "MT"
                 nGI3131 += ENT->Vlr_cont
                 nGI3132 += ENT->Icm_base + fOUT_BASES
                 nGI3133 += ENT->Icm_out
            case cMUN == "MG"
                 nGI3141 += ENT->Vlr_cont
                 nGI3142 += ENT->Icm_base + fOUT_BASES
                 nGI3143 += ENT->Icm_out
            case cMUN == "PA"
                 nGI3151 += ENT->Vlr_cont
                 nGI3152 += ENT->Icm_base + fOUT_BASES
                 nGI3153 += ENT->Icm_out
            case cMUN == "PB"
                 nGI3161 += ENT->Vlr_cont
                 nGI3162 += ENT->Icm_base + fOUT_BASES
                 nGI3163 += ENT->Icm_out
            case cMUN == "PE"
                 nGI3181 += ENT->Vlr_cont
                 nGI3182 += ENT->Icm_base + fOUT_BASES
                 nGI3183 += ENT->Icm_out
            case cMUN == "PI"
                 nGI3191 += ENT->Vlr_cont
                 nGI3192 += ENT->Icm_base + fOUT_BASES
                 nGI3193 += ENT->Icm_out
            case cMUN == "RN"
                 nGI3201 += ENT->Vlr_cont
                 nGI3202 += ENT->Icm_base + fOUT_BASES
                 nGI3203 += ENT->Icm_out
            case cMUN == "RS"
                 nGI3211 += ENT->Vlr_cont
                 nGI3212 += ENT->Icm_base + fOUT_BASES
                 nGI3213 += ENT->Icm_out
            case cMUN == "RJ"
                 nGI3221 += ENT->Vlr_cont
                 nGI3222 += ENT->Icm_base + fOUT_BASES
                 nGI3223 += ENT->Icm_out
            case cMUN == "RO"
                 nGI3231 += ENT->Vlr_cont
                 nGI3232 += ENT->Icm_base + fOUT_BASES
                 nGI3233 += ENT->Icm_out
            case cMUN == "RR"
                 nGI3241 += ENT->Vlr_cont
                 nGI3242 += ENT->Icm_base + fOUT_BASES
                 nGI3243 += ENT->Icm_out
            case cMUN == "SC"
                 nGI3251 += ENT->Vlr_cont
                 nGI3252 += ENT->Icm_base + fOUT_BASES
                 nGI3253 += ENT->Icm_out
            case cMUN == "SP"
                 nGI3261 += ENT->Vlr_cont
                 nGI3262 += ENT->Icm_base + fOUT_BASES
                 nGI3263 += ENT->Icm_out
            case cMUN == "SE"
                 nGI3271 += ENT->Vlr_cont
                 nGI3272 += ENT->Icm_base + fOUT_BASES
                 nGI3273 += ENT->Icm_out
            case cMUN == "MS"
                 nGI3281 += ENT->Vlr_cont
                 nGI3282 += ENT->Icm_base + fOUT_BASES
                 nGI3283 += ENT->Icm_out
            case cMUN == "TO"
                 nGI3291 += ENT->Vlr_cont
                 nGI3292 += ENT->Icm_base + fOUT_BASES
                 nGI3293 += ENT->Icm_out

         endcase


      ENT->(dbskip())
      fOUT_BASES := 0
      cMUN := space(2)
   enddo

   // CONDICAO PRINCIPAL DE LOOP____________________________________________

   do while !SAI->(eof()) .and. eval(bSAI_FILTRO)

         qmensa("Aguarde! Somando Nota: "+SAI->Num_Nf +" / Serie : "+SAI->Serie + "data" + dtoc(SAI->data_lanc))
         if OUTSAI->(dbseek(SAI->NUM_NF + SAI->SERIE + SAI->Filial))
            for nCONT = 1 to 5
                 aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
                 aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
                 aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr
                 // BASE DAS OUTRAS ALIQUOTAS DE ICMS
                 fOUT_BASES += OUTSAI->ICM_BASE
                 OUTSAI->(dbskip())
                 if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                    exit
                 endif
            next
         endif

         do case
            case SAI->Estado == "PR"

            case SAI->Estado == "AC"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5011 += SAI->Vlr_cont
                    nGI5013 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5012 += SAI->Vlr_cont
                    nGI5014 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5015 += SAI->Icm_out
                 nGI5016 += SAI->Icm_subst

            case SAI->Estado == "AL"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5021 += SAI->Vlr_cont
                    nGI5023 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5022 += SAI->Vlr_cont
                    nGI5024 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5025 += SAI->Icm_out
                 nGI5026 += SAI->Icm_subst
            case SAI->Estado == "AP"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5031 += SAI->Vlr_cont
                    nGI5033 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5032 += SAI->Vlr_cont
                    nGI5034 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5035 += SAI->Icm_out
                 nGI5036 += SAI->Icm_subst

            case SAI->Estado == "AM"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5041 += SAI->Vlr_cont
                    nGI5043 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5042 += SAI->Vlr_cont
                    nGI5044 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5045 += SAI->Icm_out
                 nGI5046 += SAI->Icm_subst


            case SAI->Estado == "BA"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5051 += SAI->Vlr_cont
                    nGI5053 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5052 += SAI->Vlr_cont
                    nGI5054 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5055 += SAI->Icm_out
                 nGI5056 += SAI->Icm_subst

            case SAI->Estado == "CE"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5061 += SAI->Vlr_cont
                    nGI5063 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5062 += SAI->Vlr_cont
                    nGI5064 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5065 += SAI->Icm_out
                 nGI5066 += SAI->Icm_subst

            case SAI->Estado == "DF"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5071 += SAI->Vlr_cont
                    nGI5073 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5072 += SAI->Vlr_cont
                    nGI5074 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5075 += SAI->Icm_out
                 nGI5076 += SAI->Icm_subst

            case SAI->Estado == "ES"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5081 += SAI->Vlr_cont
                    nGI5083 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5082 += SAI->Vlr_cont
                    nGI5084 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5085 += SAI->Icm_out
                 nGI5086 += SAI->Icm_subst
            case SAI->Estado == "GO"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5101 += SAI->Vlr_cont
                    nGI5103 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5102 += SAI->Vlr_cont
                    nGI5104 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5105 += SAI->Icm_out
                 nGI5106 += SAI->Icm_subst
            case SAI->Estado == "MA"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5121 += SAI->Vlr_cont
                    nGI5123 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5122 += SAI->Vlr_cont
                    nGI5124 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5125 += SAI->Icm_out
                 nGI5126 += SAI->Icm_subst
            case SAI->Estado == "MT"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5131 += SAI->Vlr_cont
                    nGI5133 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5132 += SAI->Vlr_cont
                    nGI5134 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5135 += SAI->Icm_out
                 nGI5136 += SAI->Icm_subst
            case SAI->Estado == "MG"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5141 += SAI->Vlr_cont
                    nGI5143 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5142 += SAI->Vlr_cont
                    nGI5144 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5145 += SAI->Icm_out
                 nGI5146 += SAI->Icm_subst
            case SAI->Estado == "PA"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5151 += SAI->Vlr_cont
                    nGI5153 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5152 += SAI->Vlr_cont
                    nGI5154 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5155 += SAI->Icm_out
                 nGI5156 += SAI->Icm_subst
            case SAI->Estado == "PB"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5161 += SAI->Vlr_cont
                    nGI5163 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5162 += SAI->Vlr_cont
                    nGI5164 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5165 += SAI->Icm_out
                 nGI5166 += SAI->Icm_subst
            case SAI->Estado == "PE"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5181 += SAI->Vlr_cont
                    nGI5183 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5182 += SAI->Vlr_cont
                    nGI5184 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5185 += SAI->Icm_out
                 nGI5186 += SAI->Icm_subst
            case SAI->Estado == "PI"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5191 += SAI->Vlr_cont
                    nGI5193 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5192 += SAI->Vlr_cont
                    nGI5194 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5195 += SAI->Icm_out
                 nGI5196 += SAI->Icm_subst
            case SAI->Estado == "RN"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5201 += SAI->Vlr_cont
                    nGI5203 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5202 += SAI->Vlr_cont
                    nGI5204 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5205 += SAI->Icm_out
                 nGI5206 += SAI->Icm_subst
            case SAI->Estado == "RS"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5211 += SAI->Vlr_cont
                    nGI5213 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5212 += SAI->Vlr_cont
                    nGI5214 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5215 += SAI->Icm_out
                 nGI5216 += SAI->Icm_subst
            case SAI->Estado == "RJ"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5221 += SAI->Vlr_cont
                    nGI5223 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5222 += SAI->Vlr_cont
                    nGI5224 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5225 += SAI->Icm_out
                 nGI5226 += SAI->Icm_subst
            case SAI->Estado == "RO"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5231 += SAI->Vlr_cont
                    nGI5233 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5232 += SAI->Vlr_cont
                    nGI5234 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5235 += SAI->Icm_out
                 nGI5236 += SAI->Icm_subst
            case SAI->Estado == "RR"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5241 += SAI->Vlr_cont
                    nGI5243 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5242 += SAI->Vlr_cont
                    nGI5244 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5245 += SAI->Icm_out
                 nGI5246 += SAI->Icm_subst
            case SAI->Estado == "SC"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5251 += SAI->Vlr_cont
                    nGI5253 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5252 += SAI->Vlr_cont
                    nGI5254 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5255 += SAI->Icm_out
                 nGI5256 += SAI->Icm_subst
            case SAI->Estado == "SP"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5261 += SAI->Vlr_cont
                    nGI5263 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5262 += SAI->Vlr_cont
                    nGI5264 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5265 += SAI->Icm_out
                 nGI5266 += SAI->Icm_subst
            case SAI->Estado == "SE"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5271 += SAI->Vlr_cont
                    nGI5273 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5272 += SAI->Vlr_cont
                    nGI5274 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5275 += SAI->Icm_out
                 nGI5276 += SAI->Icm_subst
            case SAI->Estado == "MS"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5281 += SAI->Vlr_cont
                    nGI5283 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5282 += SAI->Vlr_cont
                    nGI5284 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5285 += SAI->Icm_out
                 nGI5286 += SAI->Icm_subst
            case SAI->Estado == "TO"
                 if SAI->Cfop $ "618-619-645-653-663"
                    nGI5291 += SAI->Vlr_cont
                    nGI5293 += SAI->Icm_base + fOUT_BASES
                 else
                    nGI5292 += SAI->Vlr_cont
                    nGI5294 += SAI->Icm_base + fOUT_BASES
                 endif
                 nGI5295 += SAI->Icm_out
                 nGI5296 += SAI->Icm_subst

         endcase


      SAI->(dbskip())
      fOUT_BASES := 0
   enddo

return


