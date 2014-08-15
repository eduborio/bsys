/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITURA FISCAL
// OBJETIVO...: GIA EM DISQUETE
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: AGOSTO DE 1997
// OBS........:
// ALTERACOES.:
function ef406

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

#include "ef.ch"

private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1   := qlbloc("B410D","QBLOC.GLO")
private sBLOCO2   := qlbloc("B410E","QBLOC.GLO")
private sBLOCO3   := qlbloc("B410F","QBLOC.GLO")

private lCONF      // variavel  para confirmacoes
private cCONVENIO  // codigo do convenio
private nBUREAU    // numero da empresa bureau
private cMESANO    // mes e ano de competencia
private cDRIVE     // drive para gravacao
private cCAGED     // string de montagem de cada linha

private bENT_FILTRO                 // code block de filtro entradas
private bSAI_FILTRO                 // code block de filtro saidas
private bSAI1_FILTRO                // code block de filtro saidas
private bENT1_FILTRO                // code block de filtro entrada
private bISS1_FILTRO                // code block de filtro servicos

private fVLR_CONT                   // total valor contabil
private fICM_BASE                   // total base de icms
private fICM_VLR                    // total imposto creditado
private fICM_ISEN                   // total isentos icms
private fICM_OUT                    // total outras icms
private fOUT_BASES                  // Outras bases de icms

private fICM_TRANSP                 // Saldo credor anterior
private fICM_DEB                    // Imposto debitado
private fICM_CRED                   // Imposto creditado
private fICM_OUT_DB                 // Outros Debitos
private fICM_OUT_CD                 // Outros creditos
private fICM_EST_CD                 // Estornos Creditos
private fICM_EST_DB                 // Estornos debitos
private fTOT_DEB                    // Total debitos  (campo 60)
private fTOT_CRED                   // Total creditos (campo 70)

private fDIF_ALIQ                    // Diferencial de aliquota
private fEST_CR_BEN                  // Estornos de creditos de bens do ativo imobilizado
private fICM_REC_AN                  // ICMS recolhido antecipadamente

private nBASE                       // Base de calculo ajustada para maquina registradora
private nTOTSUBST                   // Total de substituicao tributaria
private nCAMPO_02                   // Valores fiscais campo 02
private nCAMPO_04                   // Valores fiscais campo 04
private nCAMPO_06                   // Valores fiscais campo 06
private nCAMPO_10                   // Total do campos (01 + 02 + 03 + 04 + 05)

private nSOMA_11                    // Valores fiscais campo 11
private nSOMA_13                    // Valores fiscais campo 13
private nSOMA_14                    // Valores fiscais campo 14
private nSOMA_15                    // Valores fiscais campo 15
private nSOMA_16                    // Valores fiscais campo 16
private nSOMA_17                    // Valores fiscais campo 17
private nSOMA_18                    // Valores fiscais campo 18
private nSOMA_19                    // Valores fiscais campo 19

private nSOMA_21                    // Valores fiscais campo 21
private nSOMA_23                    // Valores fiscais campo 23
private nSOMA_24                    // Valores fiscais campo 24
private nSOMA_25                    // Valores fiscais campo 25
private nSOMA_26                    // Valores fiscais campo 26
private nSOMA_27                    // Valores fiscais campo 27
private nSOMA_28                    // Valores fiscais campo 28
private nSOMA_29                    // Valores fiscais campo 29

private nSOMA_31                    // Valores fiscais campo 31
private nSOMA_33                    // Valores fiscais campo 33
private nSOMA_34                    // Valores fiscais campo 34
private nSOMA_35                    // Valores fiscais campo 35
private nSOMA_36                    // Valores fiscais campo 36
private nSOMA_39                    // Valores fiscais campo 39

private nSOMA_41                    // Valores fiscais campo 41
private nSOMA_43                    // Valores fiscais campo 43
private nSOMA_44                    // Valores fiscais campo 44
private nSOMA_45                    // Valores fiscais campo 45
private nSOMA_46                    // Valores fiscais campo 46
private nSOMA_49                    // Valores fiscais campo 49

private nSOMA_20                    // Valores fiscais campo 20
private nSOMA_30                    // Valores fiscais campo 30
private nSOMA_40                    // Valores fiscais campo 40
private nSOMA_50                    // Valores fiscais campo 50

private nSOMA_66                    // Valores fiscais campo 66
private nVAL_EST                    // Valor de estoque

private dDATA_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
private dDATA_FIM   := qfimmes(dDATA_INI)
private dDATA_EMIS                  // Data de emissao
private dDATA_VENC                  // Data de vencimento

private bISS_FILTRO
private nVAL_ICMS                   // Valor do icms p/ reg. simles

private dDATA1_INI                    // Data inicial do ICMS dentro do ano
private dDATA1_FIM                    // Data final do ICMS ate  o mes corrente

private nALIQ_SPL
private cTIPO_EST

private nENTRADA
private nENTRADA1

private nSAIDA
private nSAIDA1

private nSERVICO1

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}

private cGIA
private cGIA02
private cGIA04
private cGIA06
private cGIA10
private cGIA11
private cGIA21
private cGIA31
private cGIA41
private cGIA13
private cGIA23
private cGIA33
private cGIA43
private cGIA14
private cGIA24
private cGIA34
private cGIA44
private cGIA15
private cGIA25
private cGIA35
private cGIA45
private cGIA16
private cGIA26
private cGIA36
private cGIA46
private cGIA17
private cGIA27
private cGIA18
private cGIA28
private cGIA19
private cGIA29
private cGIA39
private cGIA49
private cGIA20
private cGIA30
private cGIA50
private cGIA51
private cGIA61
private cGIA52
private cGIA62
private cGIA53
private cGIA63
private cGIA54
private cGIA64
private cGIA66
private cGIA68
private cGIA60
private cGIA70
private cGIA80
private cGIA90
private nLINHA

// ABRE ARQUIVO GIA.DBF E ZERA ______________________________________________

if ! quse(XDRV_EFX,"GIA",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo GIA.DBF !! Tente novamente.")
   return
endif

GIA->(__dbzap())

// ABRE ARQUIVO QINST.DBF, FILTRA E ALIMENTA ARQUIVO CFGDISQ.DBF ____________

if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")
   qmensa("N„o foi poss¡vel abrir arquivo QINST.DBF !! Tente novamente.")
   return
endif

if ! quse("","QCONFIG") ; return ; endif

QINST->(dbSetFilter({|| Empresa <> "000"}, 'Empresa <> "000"'))

QINST->(dbgotop())

qlbloc(5,0,"B410A","QBLOC.GLO")

do while ! QINST->(eof())
   qgirabarra()

   if "EF" $ QINST->Sistemas

      qmensa("Montando Empresa: " + QINST->Razao)

      if ! quse(QINST->DRV_EF,"CONFIG",NIL,"R")
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
            replace CFGDISQ->Gia        with CONFIG->Gia
            replace CFGDISQ->Cad_icms   with qtiraponto(alltrim(QINST->Inscr_est))
            replace CFGDISQ->Crc_contab with qtiraponto(alltrim(QCONFIG->Cont_crc))
            replace CFGDISQ->Tipo_gia   with "1"
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
                 {"f406a()/Emite",0}},"P",;
                 {NIL,"f406b",NIL,NIL},;
                  NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))
return

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE EMITE CAGED OU NAO ______________________________

function f406a
return(iif(CFGDISQ->Gia=="S","SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f406b
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

   qlbloc(9,7,"B410B","QBLOC.GLO")

   CFGDISQ->(qpublicfields())
   CFGDISQ->(qinitfields())
   CFGDISQ->(qcopyfields())

   qsay(10,21,CFGDISQ->Empresa)
   qsay(10,27,left(CFGDISQ->Razao,44))

   XNIVEL := 1
   qrsay ( XNIVEL++ , qabrev(fGIA,"SN",{"Sim","N„o"}     ) )
   qrsay ( XNIVEL++ , qabrev(fTIPO_GIA,"12",{"1","2"} ) )
   qrsay ( XNIVEL++ , fCAD_ICMS   , "@R 99999999-99")
   qrsay ( XNIVEL++ , fCRC_CONTAB , "@R !!-999999/!-9")
   qrsay ( XNIVEL++ , fESTOQUE    , "@E 9,999,999,999,999.99")
   qrsay ( XNIVEL++ , fNUM_FUNC   , "@E 99,999")
   qrsay ( XNIVEL++ , fFOLHA_PGTO , "@E 9,999,999,999,999.99")
   qrsay ( XNIVEL++ , fCAMPO_02   , "@E 999,999.99")
   qrsay ( XNIVEL++ , fCAMPO_04   , "@E 999,999.99")
   qrsay ( XNIVEL++ , fCAMPO_06   , "@E 999,999.99")
        
   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________
   
   aadd(aEDICAO1,{{ || qesco(-1,0,@fGIA        ,SBLOCO1                  )} , "GIA"       })
   aadd(aEDICAO1,{{ || qesco(13,54,@fTIPO_GIA  ,SBLOCO2                  )} , "TIPO_GIA"  })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCAD_ICMS   ,"@R 99999999-99"         )} , "CAD_ICMS"  })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCRC_CONTAB ,"@R !!-999999/!-9"       )} , "CRC_CONTAB"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fESTOQUE    ,"@E 9,999,999,999,999.99")} , "ESTOQUE"   })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fNUM_FUNC   ,"@E 99,999"              )} , "NUM_FUNC"  })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fFOLHA_PGTO ,"@E 9,999,999,999,999.99")} , "FOLHA_PGTO"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCAMPO_02   ,"@E 999,999.99"          )} , "CAMPO_02"  })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCAMPO_04   ,"@E 999,999.99"          )} , "CAMPO_04"  })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCAMPO_06   ,"@E 999,999.99"          )} , "CAMPO_06"  })

   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.

   cPATH := "\QSYS\QFISCAL\E" + fEMPRESA + "\"

   if ! quse(XDRV_EF,"ISS",{"ISS_LANC"},"R")
      qmensa("N„o foi poss¡vel abrir arquivo ISS.DBF !! Tente novamente.")
      return .F.
   endif

   ISS->(dbgotop())

   fCAMPO_06 := 0

   do while ! ISS->(eof())
      qgirabarra()
      if ISS->DATA_LANC >= dDATA_INI .and. ISS->DATA_LANC <= dDATA_FIM
         fCAMPO_06 += ISS->Vlr_cont
      endif
      ISS->(dbskip())
   enddo

   ISS->(dbclosearea())

   if(empty(fGIA),fGIA := "S",fGIA)
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

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA 1 ___________________________________________

static function i_critica1 ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "GIA"
           if empty(fGIA) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fGIA,"SN",{"Sim","N„o"}) )

      case cCAMPO == "TIPO_GIA"
           qrsay ( XNIVEL , qabrev(fTIPO_GIA,"12",{"1","2"}))

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

      qlbloc(5,0,"B410C","QBLOC.GLO")
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

      if CFGDISQ->GIA $ "N "
         CFGDISQ->(dbskip())
         loop
      endif

      cPATH := "\QSYS\QFISCAL\E" + CFGDISQ->Empresa + "\"

      qsay(14,30,CFGDISQ->Empresa)
      qsay(14,36,left(CFGDISQ->Razao,35))



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
         qmensa("N„o foi poss¡vel Abrir arquivo SAI.DBF !! Tente novamente.")
         return .F.
      endif

      if ! quse(cPATH,"ISS",{"ISS_LANC"},"R")
         qmensa("N„o foi poss¡vel abrir arquivo ISS.DBF !! Tente novamente.")
         return .F.
      endif

      // VERIFICA SE FOI EXECUTADOS AS APURACOES ATNTES DE EMITIR ESTA OPCAO _____

      dDATA_INI := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
      IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(qfimmes(dDATA_INI))))

      if IMP->Apurado_e == .F. .or. IMP->Apurado_s == .F.
         alert("Existem os lan‡amentos n„o Apuradas.; Por favor execute as apura‡”es !")
         return
      endif

      fVLR_CONT   := 0
      fICM_BASE   := 0
      fICM_VLR    := 0
      fICM_ISEN   := 0
      fICM_OUT    := 0
      fOUT_BASES  := 0

      fICM_TRANSP := 0             // Saldo credor anterior
      fICM_DEB    := 0             // Imposto debitado
      fICM_CRED   := 0             // Imposto creditado
      fICM_OUT_DB := 0             // Outros Debitos
      fICM_OUT_CD := 0             // Outros creditos
      fICM_EST_CD := 0             // Estornos Creditos
      fICM_EST_DB := 0             // Estornos debitos
      fTOT_DEB    := 0             // Total debitos  (campo 60)
      fTOT_CRED   := 0             // Total creditos (campo 70)

      fDIF_ALIQ   := 0
      fEST_CR_BEN := 0
      fICM_REC_AN := 0

      dDATA_EMIS  := date()
      nVAL_EST    := 0
      dDATA_VENC  := ctod("")
      dDATA_INVE  := ctod("")
      dDATA_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
      dDATA_FIM   := qfimmes(dDATA_INI)

      nMES        := month(dDATA_INI)
      nFOL_PGTO   := 0             // Valor da folha de pagamento dos funcionarios
      nNUM_FUNC   := 0             // Numero de funcionarios da folha

      cOBS        := space(100)    // Observacao

      nBASE       := 0             // Base de calculo ajustada para maquina registradora
      nTOTSUBST   := 0             // Total da substituicao tributaria

      nCAMPO_02   := 0             // Valores fiscais campo 02
      nCAMPO_04   := 0             // Valores fiscais campo 04
      nCAMPO_06   := 0             // Valores fiscais campo 06
      nCAMPO_10   := 0             // Valores fiscais campo 10

      nSOMA_11    := 0             // Valores fiscais campo 11
      nSOMA_13    := 0             // Valores fiscais campo 13
      nSOMA_14    := 0             // Valores fiscais campo 14
      nSOMA_15    := 0             // Valores fiscais campo 15
      nSOMA_16    := 0             // Valores fiscais campo 16
      nSOMA_17    := 0             // Valores fiscais campo 17
      nSOMA_18    := 0             // Valores fiscais campo 18
      nSOMA_19    := 0             // Valores fiscais campo 19

      nSOMA_21    := 0             // Valores fiscais campo 21
      nSOMA_23    := 0             // Valores fiscais campo 23
      nSOMA_24    := 0             // Valores fiscais campo 24
      nSOMA_25    := 0             // Valores fiscais campo 25
      nSOMA_26    := 0             // Valores fiscais campo 26
      nSOMA_27    := 0             // Valores fiscais campo 27
      nSOMA_28    := 0             // Valores fiscais campo 28
      nSOMA_29    := 0             // Valores fiscais campo 29

      nSOMA_31    := 0             // Valores fiscais campo 31
      nSOMA_33    := 0             // Valores fiscais campo 33
      nSOMA_34    := 0             // Valores fiscais campo 34
      nSOMA_35    := 0             // Valores fiscais campo 35
      nSOMA_36    := 0             // Valores fiscais campo 36
      nSOMA_39    := 0             // Valores fiscais campo 39

      nSOMA_41    := 0             // Valores fiscais campo 41
      nSOMA_43    := 0             // Valores fiscais campo 43
      nSOMA_44    := 0             // Valores fiscais campo 44
      nSOMA_45    := 0             // Valores fiscais campo 45
      nSOMA_46    := 0             // Valores fiscais campo 46
      nSOMA_49    := 0             // Valores fiscais campo 49

      nSOMA_20    := 0             // Valores fiscais campo 20
      nSOMA_30    := 0             // Valores fiscais campo 30
      nSOMA_40    := 0             // Valores fiscais campo 40
      nSOMA_50    := 0             // Valores fiscais campo 50

      nSOMA_66    := 0             // Valores fiscais campo 66

      nVAL_ICMS   := 0             // Valor do icms p/ reg. simles

      nENTRADA    := 0
      nENTRADA1   := 0

      nSAIDA      := 0
      nSAIDA1     := 0

      nSERVICO1   := 0

      nALIQ_SPL   := 0
      cTIPO_EST   := " "

      dDATA1_INI  := ctod("01/01/" + left(XANOMES,4))
      dDATA1_FIM  := qfimmes(ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4)))

      cGIA        := ""
      cGIA02      := ""
      cGIA04      := ""
      cGIA06      := ""
      cGIA10      := ""
      cGIA11      := ""
      cGIA21      := ""
      cGIA31      := ""
      cGIA41      := ""
      cGIA13      := ""
      cGIA23      := ""
      cGIA33      := ""
      cGIA43      := ""
      cGIA14      := ""
      cGIA24      := ""
      cGIA34      := ""
      cGIA44      := ""
      cGIA15      := ""
      cGIA25      := ""
      cGIA35      := ""
      cGIA45      := ""
      cGIA16      := ""
      cGIA26      := ""
      cGIA36      := ""
      cGIA46      := ""
      cGIA17      := ""
      cGIA27      := ""
      cGIA18      := ""
      cGIA28      := ""
      cGIA19      := ""
      cGIA29      := ""
      cGIA39      := ""
      cGIA49      := ""
      cGIA20      := ""
      cGIA30      := ""
      cGIA50      := ""
      cGIA51      := ""
      cGIA61      := ""
      cGIA52      := ""
      cGIA62      := ""
      cGIA53      := ""
      cGIA63      := ""
      cGIA54      := ""
      cGIA64      := ""
      cGIA66      := ""
      cGIA68      := ""
      cGIA60      := ""
      cGIA70      := ""
      cGIA80      := ""
      cGIA90      := ""

      if ( i_inicializacao() , i_impressao() , NIL )

      qmensa("")

      nLINHA := 0   // QUANTIDADE DE LINHA DO REGISTRO 2

      if CFGDISQ->Campo_02 <> 0
         nLINHA++
      endif

      if CFGDISQ->Campo_04 <> 0
         nLINHA++
      endif

      if CFGDISQ->Campo_06 <> 0
         nLINHA++
      endif

      if CFGDISQ->Campo_02+CFGDISQ->Campo_04+CFGDISQ->Campo_06 <> 0
         nLINHA++
      endif

      if nSOMA_11 <> 0
         nLINHA++
      endif

      if nSOMA_21 <> 0
         nLINHA++
      endif

      if nSOMA_31 <> 0
         nLINHA++
      endif

      if XTIPOEMP $ "38"
         if nBASE <> 0
            nLINHA++
         endif
      else
         if nSOMA_41 <> 0
            nLINHA++
         endif
      endif

      if nSOMA_13 <> 0
         nLINHA++
      endif

      if nSOMA_23 <> 0
         nLINHA++
      endif

      if nSOMA_33 <> 0
         nLINHA++
      endif

      if nSOMA_43 <> 0
         nLINHA++
      endif

      if nSOMA_14 <> 0
         nLINHA++
      endif

      if nSOMA_24 <> 0
         nLINHA++
      endif

      if nSOMA_34 <> 0
         nLINHA++
      endif

      if nSOMA_44 <> 0
         nLINHA++
      endif

      if nSOMA_15 <> 0
         nLINHA++
      endif

      if nSOMA_25 <> 0
         nLINHA++
      endif

      if nSOMA_35 <> 0
         nLINHA++
      endif

      if nSOMA_45 <> 0
         nLINHA++
      endif

      if nSOMA_16 <> 0
         nLINHA++
      endif

      if nSOMA_26 <> 0
         nLINHA++
      endif

      if nSOMA_36 <> 0
         nLINHA++
      endif

      if nSOMA_46 <> 0
         nLINHA++
      endif

      if nSOMA_17 <> 0
         nLINHA++
      endif

      if nSOMA_27 <> 0
         nLINHA++
      endif

      if nSOMA_18 <> 0
         nLINHA++
      endif

      if nSOMA_28 <> 0
         nLINHA++
      endif

      if nSOMA_19 <> 0
         nLINHA++
      endif

      if nSOMA_29 <> 0
         nLINHA++
      endif

      if nSOMA_39 <> 0
         nLINHA++
      endif

      if nSOMA_49 <> 0
         nLINHA++
      endif

      if nSOMA_20 <> 0
         nLINHA++
      endif

      if nSOMA_30 <> 0
         nLINHA++
      endif

      if nSOMA_40 <> 0
         nLINHA++
      endif

      if nSOMA_50 <> 0
         nLINHA++
      endif

      if ! empty(cGIA51)
         nLINHA++
      endif

      if ! empty(cGIA61)
         nLINHA++
      endif

      if ! empty(cGIA52)
         nLINHA++
      endif

      if ! empty(cGIA62)
         nLINHA++
      endif

      if ! empty(cGIA53)
         nLINHA++
      endif

      if ! empty(cGIA63)
         nLINHA++
      endif

      if ! empty(cGIA54)
         nLINHA++
      endif

      if ! empty(cGIA64)
         nLINHA++
      endif

      if ! empty(cGIA66)
         nLINHA++
      endif

      if ! empty(cGIA68)
         nLINHA++
      endif

      if ! empty(cGIA60)
         nLINHA++
      endif

      if ! empty(cGIA70)
         nLINHA++
      endif

      if ! empty(cGIA80)
         nLINHA++
      endif

      if ! empty(cGIA90)
         nLINHA++
      endif

      ///////////////////////////////////////////////////////////////////////////////////////
      // GRAVA OS DADOS NO ARQUIVO GIA.DBF __________________________________________________

      cGIA := "1" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
      cGIA += CFGDISQ->Crc_contab + strzero(val(qtiraponto(str(CFGDISQ->Estoque,16,2))),15)
      cGIA += strzero(val(qtiraponto(strzero(CFGDISQ->Num_func,5))),5)
      cGIA += strzero(val(qtiraponto(str(CFGDISQ->Folha_pgto,16,2))),15) + strzero(nLINHA,2)
      nLINHA := 0
      GIA->(qappend())
      GIA->Linha := cGIA
      cGIA := ""

      if CFGDISQ->Campo_02 <> 0
         cGIA02 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA02 += "02" + strzero(val(qtiraponto(str(CFGDISQ->Campo_02,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA02
         cGIA02 := ""
      endif

      if CFGDISQ->Campo_04 <> 0
         cGIA04 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA04 += "04" + strzero(val(qtiraponto(str(CFGDISQ->Campo_04,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA04
         cGIA04 := ""
      endif

      if CFGDISQ->Campo_06 <> 0
         cGIA06 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA06 += "06" + strzero(val(qtiraponto(str(CFGDISQ->Campo_06,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA06
         cGIA06 := ""
      endif

      if CFGDISQ->Campo_02+CFGDISQ->Campo_04+CFGDISQ->Campo_06 <> 0
         cGIA10 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA10 += "10" + strzero(val(qtiraponto(str(CFGDISQ->Campo_02+CFGDISQ->Campo_04+CFGDISQ->Campo_06,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA10
         cGIA10 := ""
      endif

      if nSOMA_11 <> 0
         cGIA11 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA11 += "11" + strzero(val(qtiraponto(str(nSOMA_11,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA11
         cGIA11 := ""
      endif

      if nSOMA_21 <> 0
         cGIA21 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA21 += "21" + strzero(val(qtiraponto(str(nSOMA_21,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA21
         cGIA21 := ""
      endif

      if nSOMA_31 <> 0
         cGIA31 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA31 += "31" + strzero(val(qtiraponto(str(nSOMA_31,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA31
         cGIA31 := ""
      endif

      if XTIPOEMP $ "38"
         if nBASE <> 0
            cGIA41 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
            cGIA41 += "41" + strzero(val(qtiraponto(str(nBASE,16,2))),15)
            GIA->(qappend())
            GIA->Linha := cGIA41
            cGIA41 := ""
         endif
      else
         if nSOMA_41 <> 0
            cGIA41 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
            cGIA41 += "41" + strzero(val(qtiraponto(str(nSOMA_41,16,2))),15)
            GIA->(qappend())
            GIA->Linha := cGIA41
            cGIA41 := ""
         endif
      endif

      if nSOMA_13 <> 0
         cGIA13 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA13 += "13" + strzero(val(qtiraponto(str(nSOMA_13,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA13
         cGIA13 := ""
      endif

      if nSOMA_23 <> 0
         cGIA23 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA23 += "23" + strzero(val(qtiraponto(str(nSOMA_23,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA23
         cGIA23 := ""
      endif

      if nSOMA_33 <> 0
         cGIA33 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA33 += "33" + strzero(val(qtiraponto(str(nSOMA_33,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA33
         cGIA33 := ""
      endif

      if nSOMA_43 <> 0
         cGIA43 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA43 += "43" + strzero(val(qtiraponto(str(nSOMA_43,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA43
         cGIA43 := ""
      endif

      if nSOMA_14 <> 0
         cGIA14 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA14 += "14" + strzero(val(qtiraponto(str(nSOMA_14,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA14
         cGIA14 := ""
      endif

      if nSOMA_24 <> 0
         cGIA24 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA24 += "24" + strzero(val(qtiraponto(str(nSOMA_24,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA24
         cGIA24 := ""
      endif

      if nSOMA_34 <> 0
         cGIA34 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA34 += "34" + strzero(val(qtiraponto(str(nSOMA_34,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA34
         cGIA34 := ""
      endif

      if nSOMA_44 <> 0
         cGIA44 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA44 += "44" + strzero(val(qtiraponto(str(nSOMA_44,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA44
         cGIA44 := ""
      endif

      if nSOMA_15 <> 0
         cGIA15 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA15 += "15" + strzero(val(qtiraponto(str(nSOMA_15,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA15
         cGIA15 := ""
      endif

      if nSOMA_25 <> 0
         cGIA25 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA25 += "25" + strzero(val(qtiraponto(str(nSOMA_25,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA25
         cGIA25 := ""
      endif

      if nSOMA_35 <> 0
         cGIA35 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA35 += "35" + strzero(val(qtiraponto(str(nSOMA_35,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA35
         cGIA35 := ""
      endif

      if nSOMA_45 <> 0
         cGIA45 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA45 += "45" + strzero(val(qtiraponto(str(nSOMA_45,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA45
         cGIA45 := ""
      endif

      if nSOMA_16 <> 0
         cGIA16 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA16 += "16" + strzero(val(qtiraponto(str(nSOMA_16,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA16
         cGIA16 := ""
      endif

      if nSOMA_26 <> 0
         cGIA26 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA26 += "26" + strzero(val(qtiraponto(str(nSOMA_26,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA26
         cGIA26 := ""
      endif

      if nSOMA_36 <> 0
         cGIA36 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA36 += "36" + strzero(val(qtiraponto(str(nSOMA_36,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA36
         cGIA36 := ""
      endif

      if nSOMA_46 <> 0
         cGIA46 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA46 += "46" + strzero(val(qtiraponto(str(nSOMA_46,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA46
         cGIA46 := ""
      endif

      if nSOMA_17 <> 0
         cGIA17 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA17 += "17" + strzero(val(qtiraponto(str(nSOMA_17,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA17
         cGIA17 := ""
      endif

      if nSOMA_27 <> 0
         cGIA27 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA27 += "27" + strzero(val(qtiraponto(str(nSOMA_27,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA27
         cGIA27 := ""
      endif

      if nSOMA_18 <> 0
         cGIA18 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA18 += "18" + strzero(val(qtiraponto(str(nSOMA_18,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA18
         cGIA18 := ""
      endif

      if nSOMA_28 <> 0
         cGIA28 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA28 += "28" + strzero(val(qtiraponto(str(nSOMA_28,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA28
         cGIA28 := ""
      endif

      if nSOMA_19 <> 0
         cGIA19 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA19 += "19" + strzero(val(qtiraponto(str(nSOMA_19,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA19
         cGIA19 := ""
      endif

      if nSOMA_29 <> 0
         cGIA29 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA29 += "29" + strzero(val(qtiraponto(str(nSOMA_29,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA29
         cGIA29 := ""
      endif

      if nSOMA_39 <> 0
         cGIA39 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA39 += "39" + strzero(val(qtiraponto(str(nSOMA_39,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA39
         cGIA39 := ""
      endif

      if nSOMA_49 <> 0
         cGIA49 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA49 += "49" + strzero(val(qtiraponto(str(nSOMA_49,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA49
         cGIA49 := ""
      endif

      if nSOMA_20 <> 0
         cGIA20 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA20 += "20" + strzero(val(qtiraponto(str(nSOMA_20,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA20
         cGIA20 := ""
      endif

      if nSOMA_30 <> 0
         cGIA30 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA30 += "30" + strzero(val(qtiraponto(str(nSOMA_30,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA30
         cGIA30 := ""
      endif

      if nSOMA_40 <> 0
         cGIA40 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA40 += "40" + strzero(val(qtiraponto(str(nSOMA_40,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA40
         cGIA40 := ""
      endif

      if nSOMA_50 <> 0
         cGIA50 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA50 += "50" + strzero(val(qtiraponto(str(nSOMA_50,16,2))),15)
         GIA->(qappend())
         GIA->Linha := cGIA50
         cGIA50 := ""
      endif

      if ! empty(cGIA51)
         GIA->(qappend())
         GIA->Linha := cGIA51
         cGIA51 := ""
      endif

      if ! empty(cGIA61)
         GIA->(qappend())
         GIA->Linha := cGIA61
         cGIA61 := ""
      endif

      if ! empty(cGIA52)
         GIA->(qappend())
         GIA->Linha := cGIA52
         cGIA52 := ""
      endif

      if ! empty(cGIA62)
         GIA->(qappend())
         GIA->Linha := cGIA62
         cGIA62 := ""
      endif

      if ! empty(cGIA53)
         GIA->(qappend())
         GIA->Linha := cGIA53
         cGIA53 := ""
      endif

      if ! empty(cGIA63)
         GIA->(qappend())
         GIA->Linha := cGIA63
         cGIA63 := ""
      endif

      if ! empty(cGIA54)
         GIA->(qappend())
         GIA->Linha := cGIA54
         cGIA54 := ""
      endif

      if ! empty(cGIA64)
         GIA->(qappend())
         GIA->Linha := cGIA64
         cGIA64 := ""
      endif

      if ! empty(cGIA66)
         GIA->(qappend())
         GIA->Linha := cGIA66
         cGIA66 := ""
      endif

      if ! empty(cGIA68)
         GIA->(qappend())
         GIA->Linha := cGIA68
         cGIA68 := ""
      endif

      if ! empty(cGIA60)
         GIA->(qappend())
         GIA->Linha := cGIA60
         cGIA60 := ""
      endif

      if ! empty(cGIA70)
         GIA->(qappend())
         GIA->Linha := cGIA70
         cGIA70 := ""
      endif

      if ! empty(cGIA80)
         GIA->(qappend())
         GIA->Linha := cGIA80
         cGIA80 := ""
      endif

      if ! empty(cGIA90)
         GIA->(qappend())
         GIA->Linha := cGIA90
         cGIA90 := ""
      endif

      CONFIG->(dbclosearea())
      IMP->(dbclosearea())
      OUTENT->(dbclosearea())
      OUTSAI->(dbclosearea())
      ENT->(dbclosearea())
      SAI->(dbclosearea())
      ISS->(dbclosearea())

      CFGDISQ->(dbskip())

   enddo

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")
   
   cNOMARQ := cDRIVE + ":GIA_QSYS.TXT"

   GIA->(dbgotop())

   GIA->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

   qmensa()

   select CFGDISQ

   CFGDISQ->(dbgotop())

   if GIA->(qflock())
      GIA->(__dbzap())
   endif

return

////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO __________________________

static function i_inicializacao

   // CRIA MACRO DE FILTRO _________________________________________________

   bENT_FILTRO  := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO  := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }
   bISS_FILTRO  := { || ISS->DATA_LANC >= dDATA_INI .and. ISS->DATA_LANC <= qfimmes(dDATA_INI) }

   bENT1_FILTRO := { || ENT->DATA_LANC >= dDATA1_INI .and. ENT->DATA_LANC <= dDATA1_FIM }
   bSAI1_FILTRO := { || SAI->DATA_LANC >= dDATA1_INI .and. SAI->DATA_LANC <= dDATA1_FIM }
   bISS1_FILTRO := { || ISS->DATA_LANC >= dDATA1_INI .and. ISS->DATA_LANC <= dDATA1_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ___________________________________

   set softseek on

   select IMP
   IMP->(dbgotop())

   select OUTENT
   OUTENT->(dbseek(dtos(dDATA_INI)))

   select OUTSAI
   OUTSAI->(dbgotop())

   select ENT
   ENT->(dbseek(dtos(dDATA_INI)))

   select SAI
   SAI->(dbseek(dtos(dDATA_INI)))
   set softseek off

return .T.

////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO _____________________________________

   // CONDICAO PRINCIPAL DE LOOP ___________________________________________

   ISS->(dbgotop())

   nCAMPO_06 := CFGDISQ->Campo_06

   do while !ENT->(eof()) .and. eval(bENT_FILTRO) // .and. CFGDISQ->Tp_gia == "1"

      if eval(bENT_FILTRO)

         qmensa("Aguarde! Somando Nota: "+ENT->Num_Nf +" / Serie : "+ENT->Serie)

         if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
            for nCONT = 1 to 5
                 aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
                 aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
                 aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr
                 // BASE DAS OUTRAS ALIQUOTAS DE ICMS
                 fOUT_BASES += OUTENT->ICM_BASE
                 OUTENT->(dbskip())
                 if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                    exit
                 endif
            next
         endif

         // CODIGOS DE ICMS (ICM_COD) PARA ENTRADA OU SAIDA.
         //     1- Operacoes com Credito do Imposto.
         //     2- Oper. sem Credito do Imposto-Isentas
         //     3- Oper. sem Credito do Imposto-Outras.
         //     4- Oper. com deferimento
         //     5- Isentas com substituicao tributaria
         //     7- Cigarros

         do case

            case ENT->Cod_fisc $ "191-291-391"
                 nSOMA_16 += ENT->Vlr_cont
                 nSOMA_26 += ENT->Icm_base + fOUT_BASES
                 nSOMA_66 += ENT->Icm_vlr

            case ENT->Cod_fisc $ "141-142-143-144-241-242-243-244"
                 nSOMA_17 += ENT->Vlr_cont
                 nSOMA_27 += ENT->Icm_base + fOUT_BASES

            case ENT->Cod_fisc $ "151-152-153-154-155-251-252-253-254-255"
                 nSOMA_18 += ENT->Vlr_cont
                 nSOMA_28 += ENT->Icm_base + fOUT_BASES

            case ENT->Cod_fisc $ "199-299-399"
                 nSOMA_19 += ENT->Vlr_cont
                 nSOMA_29 += ENT->Icm_base + fOUT_BASES

            case ENT->ICM_COD $ "0249" .and. left(ENT->COD_FISC,1) $ "1"
                 nSOMA_11 += ENT->VLR_CONT
                 nSOMA_21 += ENT->ICM_BASE + fOUT_BASES

            case ENT->ICM_COD $ "5"
                 nSOMA_11 += ENT->Vlr_cont
                 nSOMA_21 += ENT->ICM_BASE + fOUT_BASES

            case ENT->ICM_COD $ "0249" .and. left(ENT->COD_FISC,1) $ "2"
                 nSOMA_13 += ENT->VLR_CONT
                 nSOMA_23 += ENT->ICM_BASE + fOUT_BASES

            case ENT->ICM_COD $ "0249" .and. left(ENT->COD_FISC,1) $ "3"
                 nSOMA_14 += ENT->VLR_CONT
                 nSOMA_24 += ENT->ICM_BASE + fOUT_BASES

            case ENT->ICM_COD $ "1367"  .and. left(ENT->COD_FISC,1) $ "12"
                 nSOMA_15 += ENT->ICM_OUT
                 if left(ENT->COD_FISC,1) $ "1"
                    nSOMA_11 += ENT->VLR_CONT - ENT->ICM_OUT
                    nSOMA_21 += ENT->ICM_BASE + fOUT_BASES
                 else
                    nSOMA_13 += ENT->VLR_CONT - ENT->ICM_OUT
                    nSOMA_23 += ENT->ICM_BASE + fOUT_BASES
                 endif

         endcase

         // EXCLUSAO PARA ICMS (NORMAL) ____________________________________

//       if ENT->Cod_fisc $ "131-132-133-134-231-232-233-234-321-322-323-324"
//          nENTRADA := nENTRADA + ENT->Vlr_cont
//       endif

         // MAQUINA REGISTRADORA ___________________________________________

         if XTIPOEMP $ "3"

            if val(left(CONFIG->Anomes,4)) = 1995
               if ENT->Icm_Cod $ "75"
                  nTOTSUBST := ENT->Icm_Out
               endif
            else
               if ENT->Icm_Cod $ "1367"
                  nTOTSUBST := ENT->Icm_Out
               endif
            endif

         endif

         fOUT_BASES := 0

      endif

      ENT->(dbskip())

   enddo

   // CONDICAO PRINCIPAL DE LOOP____________________________________________

   do while ! SAI->(eof()) .and. eval(bSAI_FILTRO) // .and. CFGDISQ->TP_GIA == "1"

      if eval(bSAI_FILTRO)
         qmensa("Aguarde! Somando Nota: "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
         if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->Filial))
            for nCONT = 1 to 5
                 aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
                 aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
                 aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr
                 // BASE DAS OUTRAS ALIQUOTAS DE ICMS
                 fOUT_BASES += OUTSAI->ICM_BASE
                 OUTSAI->(dbskip())
                 if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                    exit
                 endif
            next
         endif

         if val(left(CONFIG->Anomes,4)) = 1995

            do case

               case SAI->ICM_COD $ "123" .and. left(SAI->COD_FISC,1) $ "5"
                    nSOMA_31 += SAI->VLR_CONT
                    nSOMA_41 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "4"
                    nSOMA_31 += SAI->VLR_CONT - SAI->ICM_ISEN
                    nSOMA_41 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "123" .and. left(SAI->COD_FISC,1) $ "6"
                    nSOMA_33 += SAI->VLR_CONT
                    nSOMA_43 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "123" .and. left(SAI->COD_FISC,1) $ "7"
                    nSOMA_34 += SAI->VLR_CONT
                    nSOMA_44 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "57"  .and. left(SAI->COD_FISC,1) $ "56"
                    nSOMA_35 += SAI->ICM_OUT
                    if left(SAI->COD_FISC,1) $ "5"
                       nSOMA_31 += SAI->VLR_CONT - SAI->ICM_OUT
                       nSOMA_41 += SAI->ICM_BASE + fOUT_BASES
                    else
                       nSOMA_33 += SAI->VLR_CONT - SAI->ICM_OUT
                       nSOMA_43 += SAI->ICM_BASE + fOUT_BASES
                    endif

            endcase

         else

            do case

               case SAI->Cod_fisc $ "591-691"
                    nSOMA_36 += SAI->VLR_CONT
                    nSOMA_46 += SAI->ICM_BASE + fOUT_BASES

               case SAI->Cod_fisc $ "599-699-799"
                    nSOMA_39 += SAI->VLR_CONT
                    nSOMA_49 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "0249" .and. left(SAI->COD_FISC,1) $ "5"
                    nSOMA_31 += SAI->VLR_CONT
                    nSOMA_41 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "5"
                    nSOMA_31 += SAI->VLR_CONT
                    nSOMA_41 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "0249" .and. left(SAI->COD_FISC,1) $ "6"
                    nSOMA_33 += SAI->VLR_CONT
                    nSOMA_43 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "0249" .and. left(SAI->COD_FISC,1) $ "7"
                    nSOMA_34 += SAI->VLR_CONT
                    nSOMA_44 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "1367" .and. left(SAI->COD_FISC,1) $ "56"
                    nSOMA_35 += SAI->ICM_OUT
//                  if XTIPOEMP $ "13467890"
                       if left(SAI->COD_FISC,1) $ "5"
                          nSOMA_31 += SAI->VLR_CONT - SAI->ICM_OUT
                          nSOMA_41 += SAI->ICM_BASE + fOUT_BASES
                       else
                          nSOMA_33 += SAI->VLR_CONT - SAI->ICM_OUT
                          nSOMA_43 += SAI->ICM_BASE + fOUT_BASES
                       endif
//                  endif

            endcase

         endif

         // SOMA PARA ICMS (NORMAL) ________________________________________

         if SAI->Cod_fisc $ "511-512-513-514-515-516-517-596-696-611-612-613-614-615-616-617-618-619-711-712-716-717"  .and. SAI->Icm_cod <> "1"
            nSAIDA := nSAIDA + SAI->Vlr_cont
         endif

         // MAQUINA REGISTRADORA ___________________________________________

         if XTIPOEMP $ "3"  //  "38"
            if SAI->Cod_Fisc $ "532_632"
               nBASE += SAI->Icm_Base
            endif
         endif

         fOUT_BASES := 0

      endif

      SAI->(dbskip())

   enddo

   do while !SAI->(eof()) .and. eval(bSAI_FILTRO) // .and. CFGDISQ->TP_GIA == "2"  // Para impressao de GIA com Substituicao Tributaria

      if eval(bSAI_FILTRO)
         qmensa("Aguarde! Somando Nota: "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
         if val(left(CONFIG->Anomes,4)) >= 1996
            do case
               case SAI->ICM_COD $ "1367" .and. left(SAI->COD_FISC,1) $ "56"
                    nSOMA_35 += SAI->VLR_CONT
                    nSOMA_45 += SAI->Icm_bc_s
                    fICM_DEB += SAI->Icm_subst
            endcase
         endif
      endif

      SAI->(dbskip())

   enddo

   if XTIPOEMP $ "38"

      // PARA SOMAR SUBST. NO CAMPO 35 E SUBTRAIR NO CAMPO 31 ______________

      if XTIPOEMP $ "3"
         nSOMA_35 += nTOTSUBST
         nSOMA_31 -= nTOTSUBST
      endif

      // SOMA BASE DOS CODIGOS "532 E 632" 'A BASE AJUSTADA ________________
      // ICM_BASE E' O VALOR FINAL DO IMPOSTO COM BASE AJUSTADA PARA MAQ.REG
      // E' GRAVADO NA EF509 LINHA 207, COM DOC N. @@ANOMES ________________

      SAI->(dbsetorder(1))

      if SAI->(dbseek("@@" + left(XANOMES,4) + right(XANOMES,2)))
         nBASE += (SAI->Icm_Base)
      endif

   endif

   // VALORES ACUMULADOS DO ANO ____________________________________________

// ENT->(dbgotop())
//
// do while ! ENT->(eof())   // condicao principal de loop
//
//    if eval(bENT1_FILTRO)
//       qmensa("Entrada: Somando Nota "+ENT->Num_Nf +" / Serie : "+ENT->Serie)
//       if ENT->Cod_fisc $ "131-132-133-134-231-232-233-234-321-322-323-324"
//          nENTRADA1 += ENT->VLR_CONT - ENT->Ipi_Vlr
//       endif
//    endif
//
//    ENT->(dbskip())
//
// enddo

   SAI->(dbgotop())

   do while ! SAI->(eof())   // condicao principal de loop

      if eval(bSAI1_FILTRO)
         qmensa("Sa¡da: Somando Nota "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
         // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 5.1X 5.6X 6.1X 6.6X 7.1X
         if SAI->Cod_fisc $ "596*696"  .and. SAI->Icm_cod <> "1"
            nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
         endif
         if left(SAI->COD_FISC,2) $ "51*61*71"  .and. SAI->Icm_cod <> "1"
            nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
         endif
      endif

      SAI->(dbskip())

   enddo

   ISS->(dbgotop())

   do while ! ISS->(eof())   // condicao principal de loop

      if eval(bISS1_FILTRO)
         qmensa("Servi‡os: Somando Nota "+ISS->Num_Nf +" / Serie : "+ISS->Serie)
         nSERVICO1 += ISS->VLR_CONT
      endif

      ISS->(dbskip())

   enddo

   if CONFIG->Tipo_est $ "ABC"
//    nSOMA_19 := nSOMA_11 + nSOMA_13 + nSOMA_14 + nSOMA_15 + nSOMA_16 + nSOMA_17 + nSOMA_18 + nSOMA_19
//    nSOMA_11 := nSOMA_13 := nSOMA_14 := nSOMA_15 := nSOMA_16 := nSOMA_17 := nSOMA_18 := 0
      nSOMA_19 := nSOMA_11 + nSOMA_13 + nSOMA_14 + nSOMA_16 + nSOMA_17 + nSOMA_18 + nSOMA_19  // foi retirada a nSOMA_15
      nSOMA_11 := nSOMA_13 := nSOMA_14 := nSOMA_16 := nSOMA_17 := nSOMA_18 := 0               // no dia 10/09/1997
      nSOMA_21 := nSOMA_23 := nSOMA_24 := nSOMA_25 := nSOMA_26 := nSOMA_27 := nSOMA_28 := nSOMA_29 := 0
//    nSOMA_39 := nSOMA_31 + nSOMA_33 + nSOMA_34 + nSOMA_35 + nSOMA_36 + nSOMA_39 + nCAMPO_06
//    nSOMA_31 := nSOMA_33 := nSOMA_34 := nSOMA_35 := nSOMA_36 := 0
      nSOMA_39 := nSOMA_31 + nSOMA_33 + nSOMA_34 + nSOMA_36 + nSOMA_39 + nCAMPO_06  // foi retirada a nSOMA_35
      nSOMA_31 := nSOMA_33 := nSOMA_34 := nSOMA_36 := 0                             // no dia 10/09/1997
      nSOMA_41 := nSOMA_43 := nSOMA_44 := nSOMA_45 := nSOMA_46 := nSOMA_49 := 0
      nSOMA_49 := nSAIDA+nCAMPO_06-nENTRADA
   endif

   nSOMA_20 := nSOMA_11 + nSOMA_13 + nSOMA_14 + nSOMA_15 + nSOMA_16 + nSOMA_17 + nSOMA_18 + nSOMA_19
   nSOMA_30 := nSOMA_21 + nSOMA_23 + nSOMA_24 + nSOMA_25 + nSOMA_26 + nSOMA_27 + nSOMA_28 + nSOMA_29
   nSOMA_40 := nSOMA_31 + nSOMA_33 + nSOMA_34 + nSOMA_35 + nSOMA_36 + nSOMA_39
   nSOMA_50 := nSOMA_41 + nSOMA_43 + nSOMA_44 + nSOMA_45 + nSOMA_46 + nSOMA_49

   nSAIDA1 := nSAIDA1 + nSERVICO1 - nENTRADA1         // ACUMULADOS DO ANO

   do case
      case CONFIG->Tipo_est == "A"
           do case
              case nSAIDA1 >=  53643.73 .and. nSAIDA1 <= 128732.88
                   qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa B","B")
                   return .F.

              case nSAIDA1 >= 128732.89 .and. nSAIDA1 <= 772306.92
                   qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa C","B")
                   return .F.

              case nSAIDA1 >= 772306.93
                   qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa D","B")
                   return .F.
           endcase

           qmensa("N„o ‚ Necess ria a Impress„o da G.I.A. - I.C.M.S.","B")
           return .F.

      case CONFIG->Tipo_est == "B"
           do case
              case nSAIDA1 >= 128732.89 .and. nSAIDA1 <= 772306.92
                   qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa C","B")
                   return .F.

              case nSAIDA1 >= 772306.92
                   qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa D","B")
                   return .F.
           endcase

           if CONFIG->Iss == "1"
              nALIQ_SPL := 0.005
           else
              nALIQ_SPL := 0.01
           endif

      case CONFIG->Tipo_est == "C"
           do case
              case nSAIDA1 >= 772306.92
                   qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa D","B")
                   return .F.
           endcase

           if CONFIG->Iss == "1"
              nALIQ_SPL := 0.02
           else
              nALIQ_SPL := 0.025
           endif

   endcase

   nVAL_ICMS := (nSAIDA+nCAMPO_06-nENTRADA) * nALIQ_SPL

   // BASE AJUSTADA PARA MAQUINA REGISTRADORA ______________________________

   if XTIPOEMP $ "38"
      nSOMA_50 := nBASE + nSOMA_43 + nSOMA_44 + nSOMA_45
   endif

   // IMPRESSSAO CABECALHO DA GIAR _________________________________________

   if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(dDATA_FIM))) .and. CONFIG->Tipo_est $ "D " // .and. CFGDISQ->TP_GIA == "1"
      fICM_DEB    := IMP->ICM_DEB         // Campo 51
      fICM_OUT_DB := IMP->ICM_OUT_DB      // Campo 52
      fICM_EST_CD := IMP->ICM_EST_CD      // Campo 53
      fDIF_ALIQ   := IMP->Dif_aliq        // Campo 54
      fEST_CR_BEN := IMP->Est_cr_ben      // Campo 56

      fICM_CRED   := IMP->ICM_CRED        // Campo 62
      fICM_OUT_CD := IMP->ICM_OUT_CD      // Campo 63
      fICM_EST_DB := IMP->ICM_EST_DB      // Campo 64
      fICM_REC_AN := IMP->Icm_rec_an      // Campo 68
   else
      fICM_REC_AN := IMP->Icm_rec_an      // Campo 68
   endif

   /////////////////////////////////////////////////////////////////////////////////
   // BUSCA SALDO CREDOR ANTERIOR __________________________________________________

// if CFGDISQ->TP_GIA == "1"
      i_icm_sald_anter(nMES) // PROGRAMA EF521.PRG
// endif

   if CONFIG->Tipo_est $ "ABC"
      if nVAL_ICMS <> 0
         cGIA51 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA51 += "51" + strzero(val(qtiraponto(str(nVAL_ICMS,16,2))),15)
      endif
   else
      if fICM_DEB <> 0
         cGIA51 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA51 += "51" + strzero(val(qtiraponto(str(fICM_DEB,16,2))),15)
      endif

      if fICM_TRANSP <> 0
         cGIA61 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA61 += "61" + strzero(val(qtiraponto(str(fICM_TRANSP,16,2))),15)
      endif

      if fICM_OUT_DB <> 0
         cGIA52 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA52 += "52" + strzero(val(qtiraponto(str(fICM_OUT_DB,16,2))),15)
      endif

      if fICM_CRED+nSOMA_66 <> 0
         cGIA62 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA62 += "62" + strzero(val(qtiraponto(str(fICM_CRED-nSOMA_66,16,2))),15)
      endif

      if fICM_EST_CD <> 0
         cGIA53 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA53 += "53" + strzero(val(qtiraponto(str(fICM_EST_CD,16,2))),15)
      endif

      if fICM_OUT_CD <> 0
         cGIA63 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA63 += "63" + strzero(val(qtiraponto(str(fICM_OUT_CD,16,2))),15)
      endif

      if fDIF_ALIQ <> 0
         cGIA54 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA54 += "54" + strzero(val(qtiraponto(str(fDIF_ALIQ,16,2))),15)
      endif

      if fICM_EST_DB <> 0
         cGIA64 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA64 += "64" + strzero(val(qtiraponto(str(fICM_EST_DB,16,2))),15)
      endif

      if fEST_CR_BEN <> 0
         cGIA56 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA56 += "56" + strzero(val(qtiraponto(str(fEST_CR_BEN,16,2))),15)
      endif

      if nSOMA_66 <> 0
         cGIA66 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA66 += "66" + strzero(val(qtiraponto(str(nSOMA_66,16,2))),15)
      endif

      if fICM_REC_AN <> 0
         cGIA68 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA68 += "68" + strzero(val(qtiraponto(str(fICM_REC_AN,16,2))),15)
      endif
   endif

   fTOT_DEB  := fICM_DEB  + fICM_OUT_DB + fICM_EST_CD + fDIF_ALIQ   + fEST_CR_BEN
   fTOT_CRED := fICM_CRED + fICM_EST_DB + fICM_OUT_CD + fICM_TRANSP + fICM_REC_AN

   if CONFIG->Tipo_est $ "ABC"
      if nVAL_ICMS <> 0
         cGIA60 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA60 += "60" + strzero(val(qtiraponto(str(nVAL_ICMS,16,2))),15)
      endif
   else
      if fTOT_DEB <> 0
         cGIA60 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA60 += "60" + strzero(val(qtiraponto(str(fTOT_DEB,16,2))),15)
      endif

      if fTOT_CRED <> 0
         cGIA70 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA70 += "70" + strzero(val(qtiraponto(str(fTOT_CRED,16,2))),15)
      endif
   endif

   // IMPRESSSAO QUADRO 10 DA GIA __________________________________________

   if CONFIG->Tipo_est $ "ABC"
      if nVAL_ICMS <> 0
         cGIA90 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA90 += "90" + strzero(val(qtiraponto(str(nVAL_ICMS,16,2))),15)
      endif
   else
      if (fTOT_CRED - fTOT_DEB) >= 0
         cGIA80 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA80 += "80" + strzero(val(qtiraponto(str(fTOT_CRED - fTOT_DEB,16,2))),15)
      else
         cGIA90 := "2" + CFGDISQ->Cad_icms + XANOMES + iif(CFGDISQ->Tipo_gia=="1","43","51")
         cGIA90 += "90" + strzero(val(qtiraponto(str(fTOT_DEB - fTOT_CRED,16,2))),15)
      endif
   endif

   if CONFIG->Tipo_est $ "ABC"
      if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(dDATA_FIM))) .and. IMP->(qrlock())
         replace IMP->Gr_pr    with nVAL_ICMS
         replace IMP->Val_base with (nSAIDA+nCAMPO_06-nENTRADA)  // Valor faturado no mes
         replace IMP->Aliq_spl with nALIQ_SPL                    // Aliquota de regime simples
         IMP->(qunlock())
      endif
   else
      if (fTOT_DEB - fTOT_CRED) >= 0 // Grava para o GR-PR
         if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(dDATA_FIM))) .and. IMP->(qrlock())
            replace IMP->Val_base with 0  // Valor faturado no mes
            replace IMP->Aliq_spl with 0  // Aliquota de regime simples
            replace IMP->Gr_pr with fTOT_DEB - fTOT_CRED
            IMP->(qunlock())
         endif
      endif
   endif

return

