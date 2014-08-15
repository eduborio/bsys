///////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: SINTEGRA EM DISQUETE
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2000
// OBS........:
// ALTERACOES.:
function ef430

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

#include "ef.ch"
private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1   := qlbloc("B430D","QBLOC.GLO")
private sBLOCO2   := qlbloc("B430E","QBLOC.GLO")
private sBLOCO3   := qlbloc("B430F","QBLOC.GLO")
private sBLOCO4   := qlbloc("B430H","QBLOC.GLO")


private lCONF      // variavel  para confirmacoes
private cCONVENIO  // codigo do convenio
private nBUREAU    // numero da empresa bureau
private cMESANO    // mes e ano de competencia
private cDRIVE     // drive para gravacao
private cDATAI     // Data Inicial
private cDATAF     // Data Final
private cRESP      // Responsavel
private cCLI       // Responsavel
private cCONV      // Convenio
private cFINAL     //finalidade
private c74



private nTOT10     // Total de registros tipo 10
private nTOT11     // Total de registros tipo 11
private nTOT50     // Total de registros tipo 50
private nTOT51     // Total de registros tipo 51
private nTOT53     // Total de registros tipo 53
private nTOT54     // Total de registros tipo 54
private nTOT55     // Total de registros tipo 55
private nTOT60     // Total de registros tipo 60
private nTOT61     // Total de registros tipo 61
private nTOT70     // Total de registros tipo 70
private nTOT71     // Total de registros tipo 71
private nTOT75     // Total de registros tipo 75
private nTOT74     // Total de registros tipo 75
private nTOT76     // Total de registros tipo 75
private nTOT85     // Total de registros tipo 90
private nTOT86     // Total de registros tipo 90
private nTOT88     // Total de registros tipo 90
private nTOT90     // Total de registros tipo 90
private nTOT_GER   // Total de registros GERAL
private nCONT      // Total de registros GERAL
private nRESTO

private bENT_FILTRO                 // code block de filtro entradas
private bSAI_FILTRO                 // code block de filtro saidas
private bSAI1_FILTRO                // code block de filtro saidas
private bENT1_FILTRO                // code block de filtro entrada
private bISS1_FILTRO                // code block de filtro servicos
private bISS1_FILTRO                // code block de filtro servicos
private aSAIDAS := {}
private dDATA_EMIS      := ctod("")
private cORDEM_INI      := space(6)
private cORDEM_FIM      := space(6)
private cORDEM_ATU      := space(6)
private nTOTAL_DIA      := 0
private nBC_ICMS        := 0
private nICMS           := 0
private nISENTAS        := 0
private nOUTRAS         := 0
private cALIQ           := space(4)

private nBASE                       // Base de calculo ajustada para maquina registradora


private dDATA_INI   := cDATAI
private dDATA_FIM   := cDATAF
private dDATA_EMIS                  // Data de emissao
private dDATA_VENC                  // Data de vencimento

private bISS_FILTRO
private nVAL_ICMS                   // Valor do icms p/ reg. simles

private dDATA1_INI                  // Data inicial do ICMS dentro do ano
private dDATA1_FIM                  // Data final do ICMS ate  o mes corrente


private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0}}

private aTipo75  := {}

private cSINTEGRA

// ABRE ARQUIVO GIA.DBF E ZERA ______________________________________________

if ! quse(XDRV_EFX,"SINTEGRA",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo SINTEGRA.DBF !! Tente novamente.")
   return
endif

SINTEGRA->(__dbzap())

// ABRE ARQUIVO QINST.DBF, FILTRA E ALIMENTA ARQUIVO CFGDISQ.DBF ____________

if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")
   qmensa("N„o foi poss¡vel abrir arquivo QINST.DBF !! Tente novamente.")
   return
endif

if ! quse("","QCONFIG") ; return ; endif

QINST->(dbSetFilter({|| Empresa <> "000"}, 'Empresa <> "000"'))

QINST->(dbgotop())

qlbloc(5,0,"B430A","QBLOC.GLO")

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
                 {"f430a()/Emite",0}},"P",;
                 {NIL,"f430b",NIL,NIL},;
                  NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))
return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE EMITE CAGED OU NAO ______________________________

function f430a
return(iif(CFGDISQ->Sintegra=="S","SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f430b
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

   qlbloc(5,6,"B430B","QBLOC.GLO")

   CFGDISQ->(qpublicfields())
   CFGDISQ->(qinitfields())
   CFGDISQ->(qcopyfields())
   qsay(06,20,CFGDISQ->Empresa)
   qsay(06,26,left(CFGDISQ->Razao,44))

   XNIVEL := 1
   qrsay ( XNIVEL++ , qabrev(fSINTEGRA,"SN",{"Sim","N„o"}     ) )
   qrsay ( XNIVEL++ , fCRC_CONTAB , "@R !!-999999/!-9")
        
   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________
   
   aadd(aEDICAO1,{{ || qesco(-1,0,@fSINTEGRA        ,SBLOCO1             )} , "SINTEGRA"  })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCRC_CONTAB ,"@R !!-999999/!-9"       )} , "CRC_CONTAB"})

   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.

   if(empty(fSINTEGRA),fSINTEGRA := "S",fSINTEGRA)

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
                   {NIL,"f430c",NIL,NIL},;
                    NIL,"<ESC> Encerra / <A>ltera / <C>onsulta"))

   FILIAL->(dbclosearea())

return ""

/////////////////////////////////////////////////////////////////////////////
// EDICAO DADOS DAS FILIAIS _________________________________________________

function f430c
   local aEDICAO2 := {}

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   qlbloc(10,6,"B430G","QBLOC.GLO")

   FILIAL->(qpublicfields())
   FILIAL->(qinitfields())
   FILIAL->(qcopyfields())

   XNIVEL := 1

   qsay(11,28,FILIAL->Codigo)
   qsay(11,35,left(FILIAL->Razao,20))
   qsay(13,28,transform(FILIAL->Insc_estad,"@R 99999999-99"))

   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return "" ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO2,{{ || NIL                                        } ,"FILIAL"     })
   aadd(aEDICAO2,{{ || NIL                                        } ,NIL          })
   aadd(aEDICAO2,{{ || qgetx(13,28,@fINSC_ESTAD   ,"@R 99999999-99")} , "INSC_ESTAD"  })
   
   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.

   cPATH := "\QSYS_G\QEF\E" + fEMPRESA + "\"


   
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
      case cCAMPO == "SINTEGRA"
           if empty(fSINTEGRA) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fSINTEGRA,"SN",{"SIm","N„o"}) )

      case cCAMPO == "TIPO_GIA"
           qrsAy ( XNIVEL , qabrev(fTIPO_GIA,"12",{"1","2"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZACAO DO PROCESSO DE GERACAO DO CAGED EM DISQUETE ________________

static function i_processa
   local aEDICAO2 := {}

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO2,{{ || qgetx(-1,0,@cDATAI,"@D"                      ) } , "DATAI"})
   aadd(aEDICAO2,{{ || qgetx(-1,0,@cDATAF,"@D"                      ) } , "DATAF"})
   aadd(aEDICAO2,{{ || qgetx(-1,0,@cRESP,"@!"                       ) } , "RESP"})
   aadd(aEDICAO2,{{ || qesco(-1,0,@cFINAL    ,SBLOCO4               ) } , "FINAL"})
   aadd(aEDICAO2,{{ || qesco(-1,0,@c74       ,XSN                   ) } , "74"})
   aadd(aEDICAO2,{{ || qesco(-1,0,@cDRIVE    ,SBLOCO3               ) } , "DRIVE"})
   aadd(aEDICAO2,{{ || lCONF := qconf("Confirma emiss„o do SINTEGRA ?") } , NIL    })

   do while .T.

      qlbloc(5,0,"B430C","QBLOC.GLO")
      XNIVEL    := 1
      XFLAG     := .T.
      cDRIVE    := ""
      cCONV     := " "
      nLINHA    :=  0
      cDATAI    := ctod("")
      cDATAF    := ctod("")
      c75       := "N"
      cRESP     := space(28)
      cCLI      := space(5)
      nTOT10    := 0             // Total de registros tipo 10
      nTOT11    := 0             // Total de registros tipo 11
      nTOT50    := 0             // Total de registros tipo 50
      nTOT51    := 0             // Total de registros tipo 51
      nTOT53    := 0             // Total de registros tipo 53
      nTOT54    := 0             // Total de registros tipo 54
      nTOT55    := 0             // Total de registros tipo 55
      nTOT60    := 0             // Total de registros tipo 60
      nTOT61    := 0             // Total de registros tipo 61
      nTOT70    := 0             // Total de registros tipo 70
      nTOT71    := 0             // Total de registros tipo 71
      nTOT75    := 0             // Total de registros tipo 75
      nTOT76    := 0             // Total de registros tipo 75
      nTOT74    := 0             // Total de registros tipo 75
      nTOT85    := 0             // Total de registros tipo 90
      nTOT86    := 0             // Total de registros tipo 90
      nTOT88    := 0             // Total de registros tipo 90
      nTOT90    := 0             // Total de registros tipo 90
      nTOT_GER  := 0
      nCONT     := 0
      nRESTO    := 0
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
           qrsay(XNIVEL,qabrev(cDRIVE,"ACDEFGHI",{"A:","C:\","D:","E:","F:","C:\WINDOWS\DESKTOP\","C:\Docume~1\Alluse~1\Desktop\","C:\users\alluse~1\desktop\"}))

      case cCAMPO == "FINAL"
           if empty(cFINAL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cFINAL,"123",{"1 - Normal","2 - Retificacao Completa","3 - Retificacao Aditiva"}))


      case cCAMPO == "74"
           if empty(c74) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(c74,"SN",{"Sim","Nao"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE GRAVACAO __________________________________________

static function i_gravacao

   CFGDISQ->(dbgotop())

   do while ! CFGDISQ->(eof())

      if CFGDISQ->SINTEGRA $ "N "
         CFGDISQ->(dbskip())
         loop
      endif

      cPATH1:= "\QSYS_G\QCT\E" + CFGDISQ->Empresa + "\"

      if ! quse(cPATH1,"FILIAL",{"FI_CGCCP"},"R")
         qmensa("N„o foi poss¡vel abrir arquivo FILIAL.DBF !! Tente novamente.")
         return .F.
      endif

      SINTEGRA->(__dbzap())

      FILIAL->(Dbgotop())
      do while ! FILIAL->(eof())

         cPATH  := "\QSYS_G\QEF\E" + CFGDISQ->Empresa + "\"
         cPATH2 := "\QSYS_G\QCP\E" + CFGDISQ->Empresa + "\"
         cPATH4 := "\QSYS_G\QCP\E001\"
         cPATH3 := "\QSYS_G\QFA_CL\E" + CFGDISQ->Empresa + "\"

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

         if ! quse(cPATH,"SAI",{"SAI_NUM","SAI_LANC","NUMNFTX"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo SAI.DBF !! Tente novamente.")
            return .F.
         endif

         if CONFIG->Sint_prod

            qmensa("Com itens de NF...","BL")

            if ! quse(cPATH3,"FAT",{"FATDTEMI"},"R")
               qmensa("N„o foi poss¡vel abrir arquivo SAI.DBF !! Tente novamente.")
               return .F.
            endif


            if ! quse(cPATH3,"ITEN_FAT",{"ITEN_NUM"},"R")
               qmensa("N„o foi poss¡vel abrir arquivo SAI.DBF !! Tente novamente.")
               return .F.
            endif

            if ! quse(cPATH2,"PROD",{"PR_CODRD"})
               qmensa("N„o foi poss¡vel abrir arquivo SAI.DBF !! Tente novamente.")
               return .F.
            endif

            if ! quse(cPATH2,"INVENT",{""})
               qmensa("N„o foi poss¡vel abrir arquivo INVENT.DBF !! Tente novamente.")
               return .F.
            endif


            if ! quse(cPATH4,"UNIDADE",{"UNI_COD"},"R")
               qmensa("N„o foi poss¡vel abrir arquivo SAI.DBF !! Tente novamente.")
               return .F.
            endif
			
			if ! quse(XDRV_ES,"MOVIMENT",{"MOVIMENT"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo MOV.DBF !! Tente novamente.")
            return .F.
         endif


         if ! quse(XDRV_ES,"AVARIADO",{"AVARIADO"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo ava.DBF !! Tente novamente.")
            return .F.
         endif


         if ! quse(XDRV_ES,"SHOWROOM",{"SHOWROOM"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo SHOW.DBF !! Tente novamente.")
            return .F.
         endif
         endif

         if ! quse(cPATH,"ISS",{"ISS_LANC"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo ISS.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH2,"FORN",{"FORN_COD"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo FORN.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH2,"PEDIDO",{"PEDIDO"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo FORN.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH2,"LANC",{"LANC"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo FORN.DBF !! Tente novamente.")
            return .F.
         endif



         if ! quse(XDRV_SH,"CGM",{"CGM_COD"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo ISS.DBF !! Tente novamente.")
            return .F.
         endif

         



         // VERIFICA SE FOI EXECUTADOS AS APURACOES ATNTES DE EMITIR ESTA OPCAO _____

         dDATA_INI := cDATAI
         IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(qfimmes(dDATA_INI))+alltrim(FILIAL->Codigo)))

   //      if IMP->Apurado_e == .F. .or. IMP->Apurado_s == .F.
   //         alert("Existem os lan‡amentos n„o Apuradas.; Por favor execute as apura‡”es !")
   //         return
   //      endif

         if val(CONFIG->Anomes) > 200212
            cCONV := "3"
         else
            cCONV := "1"
         endif

         dDATA_EMIS  := date()
         dDATA_VENC  := ctod("")
         dDATA_INVE  := ctod("")
         dDATA_INI   := cDATAI
         dDATA_FIM   := cDATAF

         nMES        := month(dDATA_INI)

         nBASE       := 0             // Base de calculo ajustada para maquina registradora
         dDATA1_INI  := cDATAI
         dDATA1_FIM  := cDATAF

         cSINTEGRA := ""
         nTOT_10:= 0
         nTOT_11 := 0
         nTOT_50 := 0
         nTOT_GER := 0
         if ( i_inicializacao() , i_impressao() , NIL )

         qmensa("")

         nLINHA := 0   // QUANTIDADE DE LINHA DO REGISTRO 2

         ///////////////////////////////////////////////////////////////////////////////////////
         // GRAVA OS DADOS NO ARQUIVO SINTEGRA.DBF __________________________________________________

         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 10 __________________________________________________

         cSINTEGRA := "10" + alltrim(FILIAL->Cgccpf)+left(FILIAL->Insc_estad,14)+left(FILIAL->Razao,35)
         CGM->(Dbseek(FILIAL->Cgm))
         cSINTEGRA += CGM->Municipio + CGM->Estado + strzero(val(qtiraponto(left(FILIAL->Fax,10))),10) +dtos(cDATAI)+dtos(cDATAF)+iif(val(CONFIG->Anomes) < 200301,"1","3")+"3"+cFINAL
         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
         cSINTEGRA := ""
         nTOT10++
         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 11 __________________________________________________

         cSINTEGRA := "11" + left(FILIAL->Endereco,34)+strzero(FILIAL->Numero,5)+left(FILIAL->Compl,21)+" "
         cSINTEGRA += left(FILIAL->Bairro,15) + strzero(val(FILIAL->Cep),8) + cRESP + strzero(val(alltrim(FILIAL->Telefone)),12)
         nLINHA ++
         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
         cSINTEGRA := ""
         nTOT11++

        // if ENT->Cfop != "1353"
         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 50 __________________________________________________
            dDATA_INI := cDATAI
            dDATA_FIM := cDATAF
            ENT->(dbsetfilter({|| Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM},'Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM'))
            ENT->(dbsetorder(2))
            ENT->(dbgotop())
            do while ! ENT->(eof())

               if alltrim(ENT->Filial) != alltrim(FILIAL->codigo)
                  ENT->(dbskip())
                  loop
               endif

               if ENT->Cfop $ "1351-1352-1353-1354-1355-2351-2352-2353-2354-2355"
                  ENT->(Dbskip())
                  loop
               endif

               nTOT50++
               FORN->(dbseek(ENT->Cod_forn))
               CGM->(dbseek(FORN->Cgm_ent))
               nRESTO := 14 - len(qtiraponto(FORN->Inscricao))
               if val(left(CONFIG->Anomes,4)) < 2003
                  cSINTEGRA := "50" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + ENT->Modelo + ENT->Serie +" " +"  " +ENT->Num_nf
                  cSINTEGRA += ENT->Cod_fisc + strzero(val(qtiraponto(str(ENT->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(ENT->Icm_base,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(ENT->Icm_isen,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_out,13,2))),13)+strzero(val(qtiraponto(str(ENT->Icm_aliq,4,2))),4)+"N"
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  OUTENT->(dbsetorder(1))
                  OUTENT->(dbgotop())
                  nCONT := 0
                  if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
                     for nCONT = 1 to 5
                          nTOT50++
                          cSINTEGRA := "50" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + ENT->Modelo + ENT->Serie + " " + "  " +ENT->Num_nf
                          cSINTEGRA += ENT->Cod_fisc + strzero(val(qtiraponto(str(0,13,2))),13) + strzero(val(qtiraponto(str(OUTENT->Icm_base,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(OUTENT->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(0,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+strzero(val(qtiraponto(str(OUTENT->Icm_aliq,6,2))),4)+"N"
                          SINTEGRA->(qappend())
                          SINTEGRA->Linha := cSINTEGRA
                          cSINTEGRA := ""

                          OUTENT->(dbskip())
                          if OUTENT->Icm_base == 0
                             exit
                          endif
                          if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                             exit
                          endif
                     next
                  endif
               else
                  cSINTEGRA := "50" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + iif(empty(ENT->Modelo),"01",ENT->Modelo) + ENT->Serie + " " +ENT->Num_nf
                  cSINTEGRA += ENT->Cfop + "P"+ strzero(val(qtiraponto(str(ENT->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(ENT->Icm_base,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(ENT->Icm_isen,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_out,13,2))),13)+strzero(val(qtiraponto(str(ENT->Icm_aliq,4,2))),4)+iif(ENT->Vlr_cont>0,"N","S")
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  OUTENT->(dbsetorder(1))
                  OUTENT->(dbgotop())
                  nCONT := 0
                  if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
                     for nCONT = 1 to 5
                          nTOT50++
                          cSINTEGRA := "50" + iif(FORN->Cgccpf=="              ",replicate("",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + ENT->Modelo + ENT->Serie + " " +ENT->Num_nf
                          cSINTEGRA += ENT->Cfop + "P" + strzero(val(qtiraponto(str(0,13,2))),13) + strzero(val(qtiraponto(str(OUTENT->Icm_base,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(OUTENT->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(0,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+strzero(val(qtiraponto(str(OUTENT->Icm_aliq,6,2))),4)+"N"
                          SINTEGRA->(qappend())
                          SINTEGRA->Linha := cSINTEGRA
                          cSINTEGRA := ""

                          OUTENT->(dbskip())
                          if OUTENT->Icm_base == 0
                             exit
                          endif
                          if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                             exit
                          endif
                     next
                  endif


               endif
               nRESTO := 0
               ENT->(dbskip())
               qmensa("Aguarde! Somando Entradas: "+ENT->Num_Nf +" / Serie : "+ENT->Serie+" Emissao: " +dtoc(ENT->Data_emis))

            enddo

            i_tipo_50()
            i_tipo_5085()



         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 50 __________________________________________________
            dDATA_INI := cDATAI
            dDATA_FIM := cDATAF
            SAI->(dbclearfilter())
            SAI->(dbsetfilter({|| Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM}))
            SAI->(dbsetorder(2))
            SAI->(dbgotop())
            do while ! SAI->(eof())


               if alltrim(SAI->Filial) != alltrim(FILIAL->Codigo)
                  SAI->(dbskip())
                  loop
               endif

               if left(SAI->Cfop,3) $ "535-635"
                  SAI->(Dbskip())
                  loop
               endif

               if empty(SAI->Cod_cli)
                  SAI->(Dbskip())
                  loop
               endif

               nTOT50++
               CLI1->(dbseek(SAI->Cod_Cli))
               CGM->(dbseek(CLI1->Cgm_ent))
               nRESTO := 14 - len(qtiraponto(left(CLI1->Inscricao,14) ))
               if val(left(CONFIG->Anomes,4)) < 2003
                  cSINTEGRA := "50" + iif(CLI1->Cgccpf=="              ",replicate("0",14),CLI1->Cgccpf) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14) ))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + iif(!empty(CGM->Estado),CGM->Estado,SAI->Estado) + SAI->Modelo + SAI->Serie +" " +"  " +SAI->Num_nf
                  cSINTEGRA += SAI->Cod_fisc + strzero(val(qtiraponto(str(SAI->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(SAI->Icm_base,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(SAI->Icm_isen,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_out,13,2))),13)+strzero(val(qtiraponto(str(SAI->Icm_aliq,4,2))),4)+"N"
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  OUTSAI->(dbsetorder(1))
                  OUTSAI->(dbgotop())
                  nCONT := 0
                  if OUTSAI->(dbseek(dtos(SAI->Data_lanc)+SAI->Num_nf+SAI->Serie+SAI->Filial))
                     for nCONT = 1 to 5
                          nTOT50++
                          cSINTEGRA := "50" + iif(CLI1->Cgccpf=="              ",replicate("0",14),CLI1->Cgccpf) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14)))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + iif(!empty(CGM->Estado),CGM->Estado,SAI->Estado) + SAI->Modelo + SAI->Serie + " " + "  " +SAI->Num_nf
                          cSINTEGRA += SAI->Cod_fisc + strzero(val(qtiraponto(str(0,13,2))),13) + strzero(val(qtiraponto(str(OUTSAI->Icm_base,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(OUTSAI->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(0,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+strzero(val(qtiraponto(str(OUTSAI->Icm_aliq,6,2))),4)+"N"
                          SINTEGRA->(qappend())
                          SINTEGRA->Linha := cSINTEGRA
                          cSINTEGRA := ""

                          OUTSAI->(dbskip())
                          if OUTSAI->Icm_base == 0
                             exit
                          endif
                          if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                             exit
                          endif
                     next
                  endif
               else
                  cSINTEGRA := "50" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14) ))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + iif(!empty(CGM->Estado),CGM->Estado,SAI->Estado) + iif(empty(SAI->Modelo),"55",SAI->Modelo) + SAI->Serie +" " +SAI->Num_nf
                  cSINTEGRA += SAI->Cfop + "P"+ strzero(val(qtiraponto(str(SAI->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(SAI->Icm_base,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(SAI->Icm_isen,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_out,13,2))),13)+strzero(val(qtiraponto(str(SAI->Icm_aliq,4,2))),4)+iif(SAI->Vlr_cont>0,"N","S")
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  OUTSAI->(dbsetorder(1))
                  OUTSAI->(dbgotop())
                  nCONT := 0
                  if OUTSAI->(dbseek(dtos(SAI->Data_lanc)+SAI->Num_nf+SAI->Serie+SAI->Filial))
                     for nCONT = 1 to 5
                          nTOT50++
                          cSINTEGRA := "50" + iif(CLI1->Cgccpf=="              ",replicate("",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14) ))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + iif(!empty(CGM->Estado),CGM->Estado,SAI->Estado) + SAI->Modelo + SAI->Serie + " " +SAI->Num_nf
                          cSINTEGRA += SAI->Cfop + "P" + strzero(val(qtiraponto(str(0,13,2))),13) + strzero(val(qtiraponto(str(OUTSAI->Icm_base,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(OUTSAI->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(0,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+strzero(val(qtiraponto(str(15,6,2))),4)+"N"
                          SINTEGRA->(qappend())
                          SINTEGRA->Linha := cSINTEGRA
                          cSINTEGRA := ""

                          OUTSAI->(dbskip())
                          if OUTSAI->Icm_base == 0
                             exit
                          endif
                          if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                             exit
                          endif
                     next
                  endif


               endif


               nRESTO := 0
               SAI->(dbskip())
               qmensa("Aguarde! Somando Entradas: "+SAI->Num_Nf +" / Serie : "+SAI->Serie+" Emissao: " +dtoc(SAI->Data_emis))

            enddo
         if CONFIG->Tipoemp $ "4*7*5*0"
         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 51 __________________________________________________
            dDATA_INI := cDATAI
            dDATA_FIM := cDATAF
            ENT->(dbsetfilter({|| Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM},'Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM'))
            ENT->(dbsetorder(2))
            ENT->(dbgotop())
            do while ! ENT->(eof())
               if alltrim(FILIAL->Codigo) != alltrim(ENT->Filial)
                  ENT->(dbskip())
                  loop
               endif

               if ENT->Cfop $ "1351-1352-1353-1354-1355-2351-2352-2353-2354-2355"
                  ENT->(Dbskip())
                  loop
               endif

               nTOT51++
               FORN->(dbseek(ENT->Cod_forn))
               CGM->(dbseek(FORN->Cgm_ent))
               nRESTO := 14 - len(qtiraponto(FORN->Inscricao))
               cSINTEGRA := "51" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + ENT->Serie + " " +ENT->Num_nf
               cSINTEGRA += ENT->Cfop + strzero(val(qtiraponto(str(ENT->Vlr_cont,13,2))),13) //+ strzero(val(qtiraponto(str(ENT->Icm_base,13,2))),13)
               cSINTEGRA += strzero(val(qtiraponto(str(ENT->Ipi_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(ENT->Ipi_isen,13,2))),13)
               cSINTEGRA += strzero(val(qtiraponto(str(ENT->Ipi_out,13,2))),13)+replicate(" ",20)+iif(ENT->Vlr_cont > 0,"N","S")
               SINTEGRA->(qappend())
               SINTEGRA->Linha := cSINTEGRA
               cSINTEGRA := ""
               OUTENT->(dbsetorder(1))
               OUTENT->(dbgotop())
               nCONT := 0
               nRESTO := 0
               ENT->(dbskip())
               qmensa("Aguarde! Somando Entradas: "+ENT->Num_Nf +" / Serie : "+ENT->Serie+" Emissao: " +dtoc(ENT->Data_emis))

            enddo


         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 51 __________________________________________________
            dDATA_INI := cDATAI
            dDATA_FIM := cDATAF
            SAI->(dbclearfilter())
            SAI->(dbsetfilter({|| (SAI->Filial $ FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM}))
            SAI->(dbsetorder(2))
            SAI->(dbgotop())
            do while ! SAI->(eof())
               if alltrim(FILIAL->Codigo) != alltrim(SAI->Filial)
                  SAI->(dbskip())
                  loop
               endif

               if left(SAI->Cfop,3) $ "535-635"
                  SAI->(Dbskip())
                  loop
               endif

               if empty(SAI->Cod_cli)
                  SAI->(Dbskip())
                  loop
               endif

               nTOT51++
               CLI1->(dbseek(SAI->Cod_Cli))
               CGM->(dbseek(CLI1->Cgm_ent))
               nRESTO := 14 - len(qtiraponto(left(CLI1->Inscricao,14) ))
               if val(left(CONFIG->Anomes,4)) < 2003
                  cSINTEGRA := "51" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14) ))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + CGM->Estado + SAi->Modelo + SAI->Serie +" " +SAI->Num_nf
                  cSINTEGRA += SAI->Cod_fisc + strzero(val(qtiraponto(str(SAI->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(SAI->Icm_base,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(SAI->Icm_isen,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_out,13,2))),13)+strzero(val(qtiraponto(str(SAI->Icm_aliq,4,2))),4)+iif(SAI->Vlr_cont>0,"N","S")
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  OUTSAI->(dbsetorder(1))
                  OUTSAI->(dbgotop())
                  nCONT := 0
                  if OUTSAI->(dbseek(dtos(SAI->Data_lanc)+SAI->Num_nf+SAI->Serie+SAI->Filial))
                     for nCONT = 1 to 5
                          nTOT51++
                          cSINTEGRA := "51" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14)))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + CGM->Estado + SAI->Modelo + SAI->Serie + " " + "  " +SAI->Num_nf
                          cSINTEGRA += SAI->Cod_fisc + strzero(val(qtiraponto(str(0,13,2))),13) + strzero(val(qtiraponto(str(OUTSAI->Icm_base,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(OUTSAI->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(0,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+strzero(val(qtiraponto(str(OUTSAI->Icm_aliq,6,2))),4)+"N"
                          SINTEGRA->(qappend())
                          SINTEGRA->Linha := cSINTEGRA
                          cSINTEGRA := ""

                          OUTSAI->(dbskip())
                          if OUTSAI->Icm_base == 0
                             exit
                          endif
                          if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                             exit
                          endif
                     next
                  endif
               else
                  cSINTEGRA := "51" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14) ))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + iif(!empty(CGM->Estado),CGM->Estado,SAI->Estado) + SAI->Serie +" "+SAI->Num_nf
                  cSINTEGRA += SAI->Cfop + strzero(val(qtiraponto(str(SAI->Vlr_cont,13,2))),13)// + strzero(val(qtiraponto(str(SAI->Ipi_base,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Ipi_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(SAI->Ipi_isen,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Ipi_out,13,2))),13)+replicate(" ",20)+iif(SAI->Vlr_cont>0,"N","S")
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  OUTSAI->(dbsetorder(1))
                  OUTSAI->(dbgotop())
                  nCONT := 0
                  if OUTSAI->(dbseek(dtos(SAI->Data_lanc)+SAI->Num_nf+SAI->Serie+SAI->Filial))
                     for nCONT = 1 to 5
                          nTOT51++
                          cSINTEGRA := "51" + iif(CLI1->Cgccpf=="              ",replicate("",14),strzero(val(FORN->Cgccpf),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(CLI1->Inscricao))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + iif(!empty(CGM->Estado),CGM->Estado,SAI->Estado) + SAI->Modelo + SAI->Serie + " " +SAI->Num_nf
                          cSINTEGRA += SAI->Cfop + "P" + strzero(val(qtiraponto(str(0,13,2))),13) + strzero(val(qtiraponto(str(OUTSAI->Icm_base,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(OUTSAI->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(0,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+strzero(val(qtiraponto(str(15,6,2))),4)+"N"
                          SINTEGRA->(qappend())
                          SINTEGRA->Linha := cSINTEGRA
                          cSINTEGRA := ""

                          OUTSAI->(dbskip())
                          if OUTSAI->Icm_base == 0
                             exit
                          endif
                          if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                             exit
                          endif
                     next
                  endif


               endif


               nRESTO := 0
               SAI->(dbskip())
               qmensa("Aguarde! Somando Entradas: "+SAI->Num_Nf +" / Serie : "+SAI->Serie+" Emissao: " +dtoc(SAI->Data_emis))

            enddo

           endif

           i_tipo_53()

           aTipo75 := {}


           if CONFIG->Sint_prod

              if cCOnv == "3"

              PROD->(Dbgotop())


                 ///////////////////////////////////////////////////////////////////////
                 // REGISTRO TIPO 54 __________________________________________________

                 dDATA_INI := cDATAI
                 dDATA_FIM := cDATAF

                 SAI->(dbclearfilter())
                 SAI->(dbsetfilter({|| (FILIAL == FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM}))

                 SAI->(Dbsetorder(1))
                 SAI->(Dbgotop())

                 FAT->(Dbsetfilter({|| Dt_emissao >= dDATA_INI .and. dt_emissao <= dDATA_FIM .and. ES == "S" }))
                 FAT->(dbsetorder(9))
                 FAT->(Dbgotop())
                 ITEN_FAT->(dbsetorder(2))

                 do while ! SAI->(Eof())

                    if ! FAT->(dbseek(SAI->Num_nf+SAI->Modelo))
                       SAI->(dbskip())
                       loop
                    endif

                    CLI1->(Dbseek(SAI->Cod_cli))
                    ITEN_FAT->(Dbseek(FAT->Codigo))
                    nCONT := 0
                    nIPI  := 0

                    do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
                       nCONT++
                       nTOT54++
                       cSINTEGRA := "54" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(FAT->Modelo),"55",FAT->Modelo) + "01" + " "+FAT->Num_fatura
                       PROD->(dbsetorder(4))
                       PROD->(dbseek(ITEN_FAT->Cod_prod))

                       if ITEN_FAT->Icms == 0
                          nIPI  := 0
                       else
                          nIPI  := (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (PROD->Ipi/100)
                       endif

                       if SAI->Icm_base  == 0
                          nBASE := 0
                       else
                          nBASE := ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
                       endif


                       cSINTEGRA += left(SAI->Cfop,4) + ITEN_FAT->Cod_Sit+strzero(nCONT,3)+strzero(val(ITEN_FAT->Cod_prod),14)+ strzero(val(qtiraponto(str(ITEN_FAT->Quantidade,11,3))),11) + strzero(val(qtiraponto(str( (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar),12,2))),12)


                       nOUTRAS := 0
                       nDESC    := 0

                       cSINTEGRA += strzero(val(qtiraponto(str(nDESC,12,2))),12)+ strzero(val(qtiraponto(str(nBASE,12,2))),12)
                       cSINTEGRA += strzero(val(qtiraponto(str(nOUTRAS,12,2))),12)+strzero(val(qtiraponto(str(nIPI,12,2))),12)+strzero(val(qtiraponto(str(iif(SAI->Icm_aliq == 0,0,SAI->Icm_aliq),4,2))),4)

                       SINTEGRA->(qappend())
                       SINTEGRA->Linha := cSINTEGRA
                       cSINTEGRA := ""
                       nIPI := 0

                       aadd(aTipo75,{ITEN_FAT->Cod_prod})
                       ITEN_FAT->(Dbskip())
                    enddo
                    SAI->(Dbskip())
                 enddo
                 FAT->(Dbclearfilter())

                 i_tipo_54()
                 i_tipo_5485()

              else  //Convenio Tipo 1 - 69/02

                SAI->(Dbclearfilter())
                SAI->(dbsetfilter({|| (SAI->Filial $ FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM},'Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM'))
                SAI->(Dbsetorder(3))
                SAI->(Dbgotop())

                SAI->(dbsetorder(3))
                SAI->(dbgotop())
                PROD->(Dbgotop())


                 ///////////////////////////////////////////////////////////////////////
                 // REGISTRO TIPO 54 __________________________________________________

                 FAT->(Dbsetfilter({|| Dt_emissao >= dDATA_INI .and. dt_emissao <= dDATA_FIM }))

                 FAT->(Dbgotop())
                 do while ! FAT->(Eof())

                    if Empty(FAT->Num_fatura)
                       FAT->(Dbskip())
                       loop
                    endif

                    if  left(FAT->Cod_cfop,1) $ "1*2*3"
                       FAT->(DbSkip())
                       loop
                    endif

                    if ! SAI->(dbseek(FAT->Num_fatura))
                       FAT->(dbskip())
                       loop
                    endif

                    if FAT->Cancelado
                       FAT->(DbSkip())
                       loop
                    endif


                    CLI1->(Dbseek(FAT->Cod_cli))
                    ITEN_FAT->(Dbseek(FAT->Codigo))
                    nCONT := 0

                    do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
                       nCONT++
                       nTOT54++
                       cSINTEGRA := "54" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + "01" + "01" + " " +"  "+FAT->Num_fatura
                       cSINTEGRA += left(FAT->Cod_fisc,3) +strzero(nCONT,3)+strzero(val(ITEN_FAT->Cod_prod),14)+ strzero(val(qtiraponto(str(ITEN_FAT->Quantidade,13,3))),13) + strzero(val(qtiraponto(str(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,12,2))),12)
                       PROD->(Dbseek(ITEN_FAT->Cod_prod))
                       nBASE := ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
                       nIPI  := (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (PROD->Ipi/100)
                       nOUTRAS := 0
                       nDESC    := 0

                       cSINTEGRA += strzero(val(qtiraponto(str(nDESC,12,2))),12)+ strzero(val(qtiraponto(str(nBASE,12,2))),12)
                       cSINTEGRA += strzero(val(qtiraponto(str(nOUTRAS,12,2))),12)+strzero(val(qtiraponto(str(nIPI,12,2))),12)+strzero(val(qtiraponto(str(ITEN_FAT->Icms,4,2))),4)
                       SINTEGRA->(qappend())
                       SINTEGRA->Linha := cSINTEGRA
                       cSINTEGRA := ""
                       ITEN_FAT->(Dbskip())
                    enddo
                    FAT->(Dbskip())
                 enddo
                 FAT->(Dbclearfilter())
              endif
           endif


           // REGISTRO TIPO 61 ________________________________________________________
           ////////////////////////////////////////////////////////////////////////////
            SAI->(dbgotop())
            SAI->(dbclearfilter())
            OUTSAI->(dbclearfilter())
            SAI->(dbsetfilter({|| alltrim(SAI->Filial) == alltrim(FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM}))
            OUTSAI->(dbsetfilter({|| OUTSAI->Filial == FILIAL->Codigo}))
            SAI->(dbsetorder(2))
            SAI->(dbgotop())
            dDATA_EMIS := SAI->Data_emis
            cORDEM_INI := SAI->Num_nf
            cORDEM_ATU := SAI->Num_nf
            do while ! SAI->(eof())

               cCLI := strzero(val(SAI->Cod_cli),5)

               if left(SAI->Cfop,3) $ "535-635"
                  SAI->(Dbskip())
                  loop
               endif

               if cCLI != "00000"
                  SAI->(dbskip())
                  loop
               endif


               nTOTAL_DIA += SAI->Vlr_cont
               nBC_ICMS   += SAI->Icm_base
               nICMS      += SAI->Icm_vlr
               nISENTAS   += SAI->Icm_isen
               nOUTRAS    += SAI->Icm_out
               cORDEM_ATU := SAI->Num_nf

               OUTSAI->(dbsetorder(1))
               OUTSAI->(dbgotop())
               nCONT := 0
               if OUTSAI->(dbseek(dtos(SAI->Data_lanc)+SAI->Num_nf+SAI->Serie+SAI->Filial))
                  for nCONT = 1 to 5
                      nBC_ICMS   += OUTSAI->Icm_base
                      nICMS      += OUTSAI->Icm_vlr

                      OUTSAI->(dbskip())
                      if OUTSAI->Icm_base == 0
                         exit
                      endif
                      if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                         exit
                      endif
                  next
               endif


               SAI->(dbskip())


               if SAI->Data_emis != dDATA_EMIS
                  aadd(aSAIDAS,{dDATA_EMIS,cORDEM_INI,cORDEM_ATU,nTOTAL_DIA,nBC_ICMS,nICMS,nISENTAS,nOUTRAS,SAI->Serie})
                  dDATA_EMIS := SAI->Data_emis
                  cORDEM_INI := SAI->Num_nf
                  cORDEM_ATU := SAI->Num_nf
                  nTOTAL_DIA := 0
                  nBC_ICMS   := 0
                  nICMS      := 0
                  nISENTAS   := 0
                  nOUTRAS    := 0
               endif



            enddo

            if nTOTAL_DIA <> 0
               aadd(aSAIDAS,{dDATA_EMIS,cORDEM_INI,cORDEM_ATU,nTOTAL_DIA,nBC_ICMS,nICMS,nISENTAS,nOUTRAS,SAI->Serie})
               dDATA_EMIS := SAI->Data_emis
               cORDEM_INI := SAI->Num_nf
               cORDEM_ATU := SAI->Num_nf
               nTOTAL_DIA := 0
               nBC_ICMS   := 0
               nICMS      := 0
               nISENTAS   := 0
               nOUTRAS    := 0
            endif


            //if lTEM
            //    cPROD := asFAT[1,1]
            //    cCGM  := asFAT[1,4]
                nCONT := 1
                do while  nCONT <= len(aSAIDAS)
                   nTOT61 ++
                   cSINTEGRA := "61" + replicate(" ",28) + qdata_sin(aSAIDAS[nCONT,1]) + "02" + "D  1 " + aSAIDAS[nCONT,2]
                   cSINTEGRA += aSAIDAS[nCONT,3]
                   cSINTEGRA += strzero(val(qtiraponto(str(aSAIDAS[nCONT,4],13,2))),13)
                   cSINTEGRA += strzero(val(qtiraponto(str(aSAIDAS[nCONT,5],13,2))),13)
                   cSINTEGRA += strzero(val(qtiraponto(str(aSAIDAS[nCONT,6],12,2))),12)
                   cSINTEGRA += strzero(val(qtiraponto(str(aSAIDAS[nCONT,7],13,2))),13)
                   cSINTEGRA += strzero(val(qtiraponto(str(aSAIDAS[nCONT,8],13,2))),13) + "0000"
                   nCONT++

                   SINTEGRA->(qappend())
                   SINTEGRA->Linha := cSINTEGRA
                   cSINTEGRA := ""
                   if nCONT > len(aSAIDAS)
                      nCONT := len(aSAIDAS)
                      exit
                   endif
                enddo
            //endif


         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 70 __________________________________________________
            dDATA_INI := cDATAI
            dDATA_FIM := cDATAF
            ENT->(dbsetfilter({|| Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM},'Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM'))
            ENT->(dbsetorder(2))
            ENT->(dbgotop())
            do while ! ENT->(eof())
               if alltrim(FILIAL->Codigo) != alltrim(ENT->Filial)
                  ENT->(dbskip())
                  loop
               endif

               if ! ENT->Cfop $ "1351-1352-1353-1354-1355-2351-2352-2353-2354-2355"
                  ENT->(Dbskip())
                  loop
               endif

               nTOT70++
               FORN->(dbseek(ENT->Cod_forn))
               CGM->(dbseek(FORN->Cgm_ent))
               nRESTO := 14 - len(qtiraponto(FORN->Inscricao))
               if val(left(CONFIG->Anomes,4)) < 2003
                  cSINTEGRA := "70" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + "07" + ENT->Serie +" " +"  " +ENT->Num_nf
                  cSINTEGRA += ENT->Cod_fisc + strzero(val(qtiraponto(str(ENT->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(ENT->Icm_base,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_Vlr,12,2))),12)+ strzero(val(qtiraponto(str(ENT->Icm_isen,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_out,13,2))),13)+strzero(val(qtiraponto(str(ENT->Icm_aliq,4,2))),4)+" "
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  OUTENT->(dbsetorder(1))
                  OUTENT->(dbgotop())
                  nCONT := 0
                  if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
                     for nCONT = 1 to 5
                          nTOT70++
                          cSINTEGRA := "70" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + "07" + ENT->Serie +" " +"  " +ENT->Num_nf
                          cSINTEGRA += ENT->Cod_fisc + strzero(val(qtiraponto(str(0,13,2))),13) + strzero(val(qtiraponto(str(OUTENT->Icm_base,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(OUTENT->Icm_Vlr,12,2))),12)+ strzero(val(qtiraponto(str(0,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+strzero(val(qtiraponto(str(OUTENT->Icm_aliq,6,2))),4)+" "
                          SINTEGRA->(qappend())
                          SINTEGRA->Linha := cSINTEGRA
                          cSINTEGRA := ""

                          OUTENT->(dbskip())
                          if OUTENT->Icm_base == 0
                             exit
                          endif
                          if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                             exit
                          endif
                     next
                  endif
               else
                  cSINTEGRA := "70" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + "07" + "U" +"  " +ENT->Num_nf
                  cSINTEGRA += ENT->Cfop + strzero(val(qtiraponto(str(ENT->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(ENT->Icm_base,14,2))),14)
                  cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_Vlr,14,2))),14)+ strzero(val(qtiraponto(str(ENT->Icm_isen,14,2))),14)
                  cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_out,14,2))),14)+"1N"
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  OUTENT->(dbsetorder(1))
                  OUTENT->(dbgotop())
                  nCONT := 0
                  if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
                     for nCONT = 1 to 5
                          nTOT70++
                          cSINTEGRA := "70" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + "07" + "U" +"  " +ENT->Num_nf
                          cSINTEGRA += ENT->Cfop + strzero(val(qtiraponto(str(0,13,2))),13) + strzero(val(qtiraponto(str(OUTENT->Icm_base,14,2))),14)
                          cSINTEGRA += strzero(val(qtiraponto(str(OUTENT->Icm_Vlr,14,2))),14)+ strzero(val(qtiraponto(str(0,14,2))),14)
                          cSINTEGRA += strzero(val(qtiraponto(str(0,14,2))),14)+strzero(val(qtiraponto(str(OUTENT->Icm_aliq,6,2))),4)+"N"
                          SINTEGRA->(qappend())
                          SINTEGRA->Linha := cSINTEGRA
                          cSINTEGRA := ""

                          OUTENT->(dbskip())
                          if OUTENT->Icm_base == 0
                             exit
                          endif
                          if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                             exit
                          endif
                     next
                  endif


               endif
               nRESTO := 0
               ENT->(dbskip())
               qmensa("Aguarde! Somando Entradas: "+ENT->Num_Nf +" / Serie : "+ENT->Serie+" Emissao: " +dtoc(ENT->Data_emis))

            enddo

         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 70 __________________________________________________
            dDATA_INI := cDATAI
            dDATA_FIM := cDATAF
            SAI->(dbclearfilter())
            SAI->(dbsetfilter({|| (SAI->Filial $ FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM},'Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM'))
            SAI->(dbsetorder(2))
            SAI->(dbgotop())
            do while ! SAI->(eof())

               if alltrim(FILIAL->Codigo) != alltrim(SAI->Filial)
                  SAI->(dbskip())
                  loop
               endif

               if ! left(SAI->Cfop,3) $ "535-635"
                  SAI->(Dbskip())
                  loop
               endif

               nTOT70++
               CLI1->(dbseek(SAI->Cod_Cli))
               CGM->(dbseek(CLI1->Cgm_ent))
               nRESTO := 14 - len(qtiraponto(left(CLI1->Inscricao,14) ))
               if val(left(CONFIG->Anomes,4)) < 2003
                  cSINTEGRA := "70" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(left(CLI1->Cgccpf,14)),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14)))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + SAI->Estado + "07" + SAI->Serie +" " +"  " +SAI->Num_nf
                  cSINTEGRA += SAI->Cod_fisc + strzero(val(qtiraponto(str(SAI->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(SAI->Icm_base,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_Vlr,12,2))),12)+ strzero(val(qtiraponto(str(SAI->Icm_isen,13,2))),13)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_out,13,2))),13)+strzero(val(qtiraponto(str(SAI->Icm_aliq,4,2))),4)+" "
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  OUTSAI->(dbsetorder(1))
                  OUTSAI->(dbgotop())
                  nCONT := 0
                  if OUTSAI->(dbseek(dtos(SAI->Data_lanc)+SAI->Num_nf+SAI->Serie+SAI->Filial))
                     for nCONT = 1 to 5
                          nTOT70++
                          cSINTEGRA := "70" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(left(CLI1->Inscricao,14)),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14)))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + SAI->Estado + "07" + SAI->Serie +" " +"  " +SAI->Num_nf
                          cSINTEGRA += SAI->Cod_fisc + strzero(val(qtiraponto(str(0,13,2))),13) + strzero(val(qtiraponto(str(OUTSAI->Icm_base,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(OUTSAI->Icm_Vlr,12,2))),12)+ strzero(val(qtiraponto(str(0,13,2))),13)
                          cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+strzero(val(qtiraponto(str(OUTSAI->Icm_aliq,6,2))),4)+" "
                          SINTEGRA->(qappend())
                          SINTEGRA->Linha := cSINTEGRA
                          cSINTEGRA := ""

                          OUTSAI->(dbskip())
                          if OUTSAI->Icm_base == 0
                             exit
                          endif
                          if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                             exit
                          endif
                     next
                  endif
               else
                  cSINTEGRA := "70" + iif(CLI1->Cgccpf=="              ",replicate("0",14),CLI1->Cgccpf) + iif(empty(left(CLI1->Inscricao,14)),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14)))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + CGM->Estado + "07" + "U" +"  " +SAI->Num_nf
                  cSINTEGRA += SAI->Cfop + strzero(val(qtiraponto(str(SAI->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(SAI->Icm_base,14,2))),14)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_Vlr,14,2))),14)+ strzero(val(qtiraponto(str(SAI->Icm_isen,14,2))),14)
                  cSINTEGRA += strzero(val(qtiraponto(str(SAI->Icm_out,14,2))),14)+"1N"
                  SINTEGRA->(qappend())
                  SINTEGRA->Linha := cSINTEGRA
                  cSINTEGRA := ""
                  nCONT := 0
               endif
               nRESTO := 0
               SAI->(dbskip())
               qmensa("Aguarde! Somando Entradas: "+SAI->Num_Nf +" / Serie : "+SAI->Serie+" Emissao: " +dtoc(SAI->Data_emis))

            enddo

         i_tipo_71()
         if c74 == "S"
            i_tipo74_mantra()
         endif
         i_tipo_75()
         i_tipo_76()
         i_tipo_85()
         i_tipo_86()
         i_tipo_88()

         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 90 __________________________________________________
            nTOT_GER := nTOT10+nTOT11+nTOT50+nTOT61+nTOT70+nTOT51+nTOT71+nTOT53+nTOT54+nTOT75+nTOT74+nTOT76+nTOT88+nTOT85+nTOT86+3
         cSINTEGRA := "90" + alltrim(FILIAL->Cgccpf)+left(FILIAL->Insc_estad,14) + "50" + strzero(nTOT50,8)+"51"+Strzero(nTOT51,8)+"53"+Strzero(nTOT53,8)+"54"+Strzero(nTOT54,8) +"61"+Strzero(nTOT61,8)+"70"+Strzero(nTOT70,8)+"74"+Strzero(nTOT74,8)+"75"+Strzero(nTOT75,8)+space(15) + "3"

         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
         cSINTEGRA := ""

         cSINTEGRA := "90" + alltrim(FILIAL->Cgccpf)+left(FILIAL->Insc_estad,14) + "71" +Strzero(nTOT71,8)+"76" +Strzero(nTOT76,8)+"85" +Strzero(nTOT85,8)+"86" +Strzero(nTOT86,8)+"88" +Strzero(nTOT88,8)+space(45) + "3"
         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
         cSINTEGRA := ""

         cSINTEGRA := "90" + alltrim(FILIAL->Cgccpf)+left(FILIAL->Insc_estad,14) + "99" +strzero(nTOT_GER,8)+space(85) + "3"
         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
         cSINTEGRA := ""


         nTOT_GER := nTOT10:=nTOT11:=nTOT50:=nTOT70 :=nTOT54 := nTOT75 := nTOT74:= nTOT61 := nTOT88 := nTOT53 :=  0
         nTOT76 := 0
         nTOT71 := 0
         nTOT88 := 0


         CONFIG->(dbclosearea())
         IMP->(dbclosearea())
         OUTENT->(dbclosearea())
         OUTSAI->(dbclosearea())
         ENT->(dbclosearea())
         SAI->(dbclosearea())
         ISS->(dbclosearea())
         FORN->(dbclosearea())
         CGM->(dbclosearea())
         //CLI1->(dbclosearea())

         do case
            case cDRIVE == "A"
                 cDRIVE := "A:"

            case cDRIVE == "C"
                 cDRIVE := "C:\qsystxt\"

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

         cNOMARQ := cDRIVE+"E"+CFGDISQ->Empresa+"F"+right(FILIAL->Codigo,3)+".Txt"

         SINTEGRA->(dbgotop())
         SINTEGRA->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )



         if SINTEGRA->(qflock())
            SINTEGRA->(__dbzap())
         endif

         aSAIDAS := {}
         FILIAL->(Dbskip())

      enddo

      FILIAL->(Dbclosearea())

      CFGDISQ->(dbskip())

   enddo

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")
   
//   cNOMARQ := cDRIVE + ":ARQ.TXT"
//   SINTEGRA->(dbgotop())

//   SINTEGRA->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

   qmensa()

   select CFGDISQ

   CFGDISQ->(dbgotop())

   if SINTEGRA->(qflock())
      SINTEGRA->(__dbzap())
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

//   SAI->(dbSetFilter({|| alltrim(Filial) $ FILIAL->Codigo}, 'alltrim(Filial) $ FILIAL->Codigo'))
   ENT->(dbSetFilter({|| alltrim(Filial) $ FILIAL->Codigo}, 'alltrim(Filial) $ FILIAL->Codigo'))
   ISS->(dbSetFilter({|| alltrim(Filial) $ FILIAL->Codigo}, 'alltrim(Filial) $ FILIAL->Codigo'))

   // ESTABELECE RELACOES ENTRE ARQUIVOS ___________________________________

   set softseek on

   select IMP
   IMP->(dbgotop())

  // select OUTENT
  // OUTENT->(dbseek(dtos(dDATA_INI)))

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

         qmensa("Aguarde! Somando Nota: "+ENT->Num_Nf +" / Serie : "+ENT->Serie)


return

static function qdata_sin(dDATA)
 local dRET,cANO,cMES,cDIA
 cANO := strzero(year(dDATA),4)
 cMES := strzero(month(dDATA),2)
 cDIA := strzero(day(dDATA),2)
 dRET := cANO + cMES + cDIA
return  dRET

static function i_tipo_53

//       if !empty(CONFIG->Valida)

         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 53 __________________________________________________
            dDATA_INI := cDATAI
            dDATA_FIM := cDATAF
            ENT->(dbsetfilter({|| Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM},'Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM'))
            ENT->(dbsetorder(2))
            ENT->(dbgotop())
            do while ! ENT->(eof())

               if alltrim(FILIAL->Codigo) != alltrim(ENT->Filial)
                  ENT->(dbskip())
                  loop
               endif

               if ENT->Icm_subst == 0
                  ENT->(dbskip())
                  loop
               endif

               //if ! ENT->Cfop $ "1401-1403-2401-2403"
               //   ENT->(Dbskip())
               //   loop
               //endif

               nTOT53++
               FORN->(dbseek(ENT->Cod_forn))
               CGM->(dbseek(FORN->Cgm_ent))
               nRESTO := 14 - len(qtiraponto(FORN->Inscricao))
               cSINTEGRA := "53" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_lanc) + CGM->Estado + iif(empty(ENT->Modelo),"01",ENT->Modelo) + ENT->Serie + " " +ENT->Num_nf
               cSINTEGRA += ENT->Cfop +"P"+ strzero(val(qtiraponto(str(ENT->ICM_BC_S,13,2))),13) + strzero(val(qtiraponto(str(ENT->Icm_subst,13,2))),13)
               cSINTEGRA += replicate("0",13)//strzero(val(qtiraponto(str(0,13,2))),13)//despesas acessorias
               cSINTEGRA += iif(ENT->Vlr_cont > 0,"N","S")  //situacao
               cSINTEGRA += " " //Codigo do tipo de subst de 1 a 6 ou branco
               cSINTEGRA += replicate(" ",29)
               SINTEGRA->(qappend())
               SINTEGRA->Linha := cSINTEGRA
               cSINTEGRA := ""
               nCONT := 0
               nRESTO := 0
               ENT->(dbskip())

            enddo


         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 53 __________________________________________________
            dDATA_INI := cDATAI
            dDATA_FIM := cDATAF
            SAI->(dbclearfilter())
            SAI->(dbsetfilter({|| (SAI->Filial $ FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM}))
            SAI->(dbsetorder(2))
            SAI->(dbgotop())
            do while ! SAI->(eof())
               if alltrim(FILIAL->Codigo) != alltrim(SAI->Filial)
                  SAI->(dbskip())
                  loop
               endif

               //if ! SAI->ICM_BC_S > 0
               //   SAI->(dbskip())
               //   loop
               //endif

               if SAI->ICM_subst == 0
                  SAI->(dbskip())
                  loop
               endif

               //if left(SAI->Cfop,4) $ "5304-5301-6301-6304"
               //   SAI->(Dbskip())
               //   loop
               //endif

               if empty(SAI->Cod_cli)
                  SAI->(Dbskip())
                  loop
               endif

               nTOT53++
               CLI1->(dbseek(SAI->Cod_Cli))
               CGM->(dbseek(CLI1->Cgm_ent))
               nRESTO := 14 - len(qtiraponto(left(CLI1->Inscricao,14) ))
               cSINTEGRA := "53" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + iif(empty(CLI1->Inscricao),"ISENTO        ",qtiraponto(left(CLI1->Inscricao,14) ))+space(nRESTO) + qdata_sin(SAI->Data_lanc) + CGM->Estado + iif(empty(SAI->Modelo),"55",SAI->Modelo)+SAI->Serie +" "+SAI->Num_nf
               cSINTEGRA += SAI->Cfop +"P"+ strzero(val(qtiraponto(str(SAI->ICM_BC_S,13,2))),13) + strzero(val(qtiraponto(str(SAI->Icm_subst,13,2))),13)
               cSINTEGRA += replicate("0",13)//strzero(val(qtiraponto(str(0,13,2))),13)//despesas acessorias
               cSINTEGRA += iif(SAI->Vlr_cont > 0,"N","S")  //situacao
               cSINTEGRA += " " //Codigo do tipo de subst de 1 a 6 ou branco
               cSINTEGRA += replicate(" ",29)
               SINTEGRA->(qappend())
               SINTEGRA->Linha := cSINTEGRA
               cSINTEGRA := ""

               nRESTO := 0
               SAI->(dbskip())

            enddo


  //     endif



return

static function i_tipo_74

  if !empty(CONFIG->Valida)

  INVENT->(dbsetorder(4))
  PROD->(dbgotop())
  do while ! PROD->(eof())

     if right(PROD->Codigo,5)== "     "
        PROD->(dbskip())
        loop
     endif

     nTOT74++

     INVENT->(dbseek(right(PROD->Codigo,5)))
     cSINTEGRA := "74"+qdata_sin(cDATAF)+strzero(val(right(PROD->Codigo,5)),14)
     cSINTEGRA += strzero(val(qtiraponto(str(INVENT->Quant_atu,13,3))),13)
     cSINTEGRA += strzero(val(qtiraponto(str(PROD->Preco_cust*INVENT->Quant_atu,13,2))),13)
     cSINTEGRA += "1"
     cSINTEGRA += "00000000000000"
     cSINTEGRA += space(14)
     cSINTEGRA += "PR"
     cSINTEGRA += replicate(" ",45)

     SINTEGRA->(qappend())
     SINTEGRA->Linha := cSINTEGRA
     cSINTEGRA := ""

    PROD->(dbskip())
  enddo

  endif

return


static function i_tipo_75
local nCONT    := 1
local cPROD    := ""
local asTipo75 := {}
local cDESC    := ""

  asTipo75 := asort(aTipo75,,,{|x,y| x[1] < y[1] })

  if len(asTipo75) > 0
     cPROD  :=  asTipo75[nCONT,1]
     do while  nCONT <= len(asTipo75)

         nCONT++
         if nCONT > len(asTipo75)
            nCONT := len(asTipo75)
            exit
         endif

         if asTipo75[nCONT,1] != cPROD
            PROD->(dbsetorder(4))
            if PROD->(dbseek(cPROD))
               cDesc := PROD->Descricao
            else
               cDesc := "PRODUTO SEM DESCRICAO"+space(29)
            endif

            nTOT75++
            cSINTEGRA := "75" + qdata_sin(dDATA_INI)+qdata_sin(dDATA_FIM)+strzero(val(cPROD),14)
            cSINTEGRA += replicate("0",8)+cDesc+"   "
            UNIDADE->(DbSeek(PROD->Unidade))
            cSINTEGRA += UNIDADE->Sigla+ "   " + replicate("0",27)
            SINTEGRA->(qappend())
            SINTEGRA->Linha := cSINTEGRA
            cSINTEGRA := ""

            qmensa(cPROD)

            cPROD := asTipo75[nCONT,1]
         endif
     enddo

     PROD->(dbseek(cPROD))
     nTOT75++
     cSINTEGRA := "75" + qdata_sin(dDATA_INI)+qdata_sin(dDATA_FIM)+strzero(val(right(PROD->Codigo,5)),14)
     cSINTEGRA += replicate("0",8)+PROD->Descricao+"   "
     UNIDADE->(DbSeek(PROD->Unidade))
     cSINTEGRA += UNIDADE->Sigla+ "   " + replicate("0",27)
     SINTEGRA->(qappend())
     SINTEGRA->Linha := cSINTEGRA
     cSINTEGRA := ""

  endif

return

static function i_tipo_71

 if ! empty(CONFIG->VAlida)

    dDATA_INI := cDATAI
    dDATA_FIM := cDATAF
    SAI->(dbclearfilter())
    SAI->(dbsetfilter({|| (SAI->Filial $ FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM},'Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM'))
    SAI->(dbsetorder(2))
    SAI->(dbgotop())
    do while ! SAI->(eof())

       if alltrim(FILIAL->Codigo) != alltrim(SAI->Filial)
          SAI->(dbskip())
          loop
       endif

       if ! left(SAI->Cfop,3) $ "535-635"
          SAI->(Dbskip())
          loop
       endif

       nTOT71++
       CLI1->(dbseek(SAI->Cod_Cli))
       CGM->(dbseek(CLI1->Cgm_ent))

       nRESTO := 14 - len(qtiraponto(left(CLI1->Inscricao,14) ))//len(qtiraponto(CLI1->Inscricao))

       cSINTEGRA := "71" + CLI1->Cgccpf + left(CLI1->Inscricao,14) + qdata_sin(SAI->Data_lanc) + CGM->Estado + "07" + "U" +"  " +SAI->Num_nf
       cSINTEGRA += "PR" + "00501162000103" + "ISENTO        " + qdata_sin(SAI->Data_lanc) + "01" + "01 " +strzero(nTOT71,6)
       cSINTEGRA += strzero(val(qtiraponto(str(round( (SAI->Vlr_cont/3)*100,2),14,2))),14)
       cSINTEGRA += replicate(" ",12)
       SINTEGRA->(qappend())
       SINTEGRA->Linha := cSINTEGRA
       cSINTEGRA := ""
       nCONT := 0
       nRESTO := 0
       SAI->(dbskip())

    enddo

 endif



return


static function i_tipo_76

 if ! empty(CONFIG->VAlida)

    dDATA_INI := cDATAI
    dDATA_FIM := cDATAF
    ENT->(dbclearfilter())
    ENT->(dbsetfilter({|| (ENT->Filial $ FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM},'Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM'))
    ENT->(dbsetorder(2))
    ENT->(dbgotop())
    do while ! ENT->(eof())

       if alltrim(FILIAL->Codigo) != alltrim(ENT->Filial)
          ENT->(dbskip())
          loop
       endif

       if ! left(ENT->Cfop,3) $ "130-230"
          ENT->(Dbskip())
          loop
       endif

       nTOT76++
       FORN->(dbseek(ENT->Cod_forn))
       CGM->(dbseek(FORN->Cgm_ent))

       nRESTO := 14 - len(qtiraponto(left(FORN->Inscricao,14) ))//len(qtiraponto(FORN->Inscricao))

       cSINTEGRA := "76" + FORN->Cgccpf + left(FORN->Inscricao,14) + "22"+"01"+"  "+strzero(val(ENT->Num_nf),10) +ENT->Cfop+"1"+qdata_sin(ENT->Data_lanc) + CGM->Estado
       cSINTEGRA += strzero(val(qtiraponto(str(ENT->Vlr_cont,13,2))),13)+strzero(val(qtiraponto(str(ENT->Icm_base,13,2))),13)
       cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_Vlr,12,2))),12)+strzero(val(qtiraponto(str(ENT->Icm_isen,12,2))),12)
       cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_out,12,2))),12)+strzero(val(qtiraponto(str(ENT->Icm_aliq,2))),2)
       cSINTEGRA += iif(ENT->Vlr_cont > 0,"N","S")  //situacao
       SINTEGRA->(qappend())
       SINTEGRA->Linha := cSINTEGRA
       cSINTEGRA := ""
       nCONT := 0
       nRESTO := 0
       ENT->(dbskip())

    enddo

 endif



return


static function i_tipo_88

 if ! empty(CONFIG->VAlida)


    for nCONT := 1 to 114

       nTOT88++

       cSINTEGRA := "88" +"ECF"+ "00501162000103" + "01"+"01 "+strzero(nCONT,6) +"5102"+"000"
       cSINTEGRA += "001"+"00000000000465"+"112233445566778899"+strzero(nCONT,2)+replicate(" ",52)

       SINTEGRA->(qappend())
       SINTEGRA->Linha := cSINTEGRA
       cSINTEGRA := ""

    next



 endif


return

static function i_tipo_54

 if ! empty(CONFIG->VAlida)

    for ncONT := 1 to 114
       nTOT54++
       cSINTEGRA := "54" + "00501162000103" + "01" + "01" + " "+strzero(nCONT,6)
       cSINTEGRA += "5102" + "000"+"001"+"00000000000465" + "00000001000" + "000000075000"
       nBASE    := 0
       nIPI     := 0
       nOUTRAS  := 0
       nDESC    := 0
       cSINTEGRA += strzero(val(qtiraponto(str(nDESC,12,2))),12)+ strzero(val(qtiraponto(str(nBASE,12,2))),12)
       cSINTEGRA += strzero(val(qtiraponto(str(750,12,2))),12)+strzero(val(qtiraponto(str(nIPI,12,2))),12)+strzero(val(qtiraponto(str(0,4,2))),4)
       SINTEGRA->(qappend())
       SINTEGRA->Linha := cSINTEGRA
       cSINTEGRA := ""
    next



 endif


return

static function i_tipo_50

 if ! empty(CONFIG->VAlida)



    for nCONT := 1 to 114
       nTOT50++
       cSINTEGRA := "50" + "00501162000103" + "ISENTO        " + qdata_sin(ctod("30/09/2009")) + "PR" + "01" + "01" + " " +strzero(nCONT,6)
       cSINTEGRA += "5102" + "P"+ strzero(val(qtiraponto(str(750,13,2))),13) + strzero(val(qtiraponto(str(0,13,2))),13)
       cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+ strzero(val(qtiraponto(str(0,13,2))),13)
       cSINTEGRA += strzero(val(qtiraponto(str(750,13,2))),13)+strzero(val(qtiraponto(str(0,4,2))),4)+iif(ENT->Vlr_cont>0,"N","S")
       SINTEGRA->(qappend())
       SINTEGRA->Linha := cSINTEGRA
       cSINTEGRA := ""
    next



 endif



return

static function i_tipo_5485

 if ! empty(CONFIG->VAlida)



    for ncONT := 130 to 304
       nTOT54++
       cSINTEGRA := "54" + "00501162000103" + "01" + "01" + " "+strzero(nCONT,6)
       cSINTEGRA += "5102" + "000"+"001"+"00000000000465" + "00000001000" + "000000075000"
       nBASE    := 0
       nIPI     := 0
       nOUTRAS  := 0
       nDESC    := 0
       cSINTEGRA += strzero(val(qtiraponto(str(nDESC,12,2))),12)+ strzero(val(qtiraponto(str(nBASE,12,2))),12)
       cSINTEGRA += strzero(val(qtiraponto(str(750,12,2))),12)+strzero(val(qtiraponto(str(nIPI,12,2))),12)+strzero(val(qtiraponto(str(0,4,2))),4)
       SINTEGRA->(qappend())
       SINTEGRA->Linha := cSINTEGRA
       cSINTEGRA := ""
    next



 endif


return

static function i_tipo_5085

 if ! empty(CONFIG->VAlida)



    for nCONT := 130 to 304
       nTOT50++
       cSINTEGRA := "50" + "00501162000103" + "ISENTO        " + qdata_sin(ctod("30/09/2009")) + "PR" + "01" + "01" + " " +strzero(nCONT,6)
       cSINTEGRA += "5102" + "P"+ strzero(val(qtiraponto(str(750,13,2))),13) + strzero(val(qtiraponto(str(0,13,2))),13)
       cSINTEGRA += strzero(val(qtiraponto(str(0,13,2))),13)+ strzero(val(qtiraponto(str(0,13,2))),13)
       cSINTEGRA += strzero(val(qtiraponto(str(750,13,2))),13)+strzero(val(qtiraponto(str(0,4,2))),4)+iif(ENT->Vlr_cont>0,"N","S")
       SINTEGRA->(qappend())
       SINTEGRA->Linha := cSINTEGRA
       cSINTEGRA := ""
    next



 endif



return

static function i_tipo_85

 if ! empty(CONFIG->VAlida)



    for nCONT := 130 to 304
       nTOT85++
       cSINTEGRA := "85" +strzero(nCONT+12345678901,11)+qdata_sin(ctod("30/09/2009"))+"1"+strzero(nCONT+12345678901,12)+qdata_sin(ctod("30/09/2009"))
       cSINTEGRA += "PROPRIO         "+qdata_sin(ctod("30/09/2009"))+"99"+"2496"+"        "+qdata_sin(ctod("30/09/2009"))
       cSINTEGRA += strzero(nCONT,6) + qdata_sin(ctod("30/09/2009"))+"01"+"01 "+replicate(" ",19)
       SINTEGRA->(qappend())
       SINTEGRA->Linha := cSINTEGRA
       cSINTEGRA := ""
    next



 endif



return

static function i_tipo_86

 if ! empty(CONFIG->VAlida)



    for nCONT := 130 to 304
       nTOT86++
       cSINTEGRA := "86" +strzero(nCONT+12345678901,12)+qdata_sin(ctod("30/09/2009"))
       cSINTEGRA += "00501162000103"+"ISENTO        "+"PR"+strzero(nCONT,6)+qdata_sin(ctod("30/09/2009"))
       cSINTEGRA +=  "01"+ "01 "+"00000000000465"+"00000001000"+"000000075000"+"000000075000"+"0"+"     "
       SINTEGRA->(qappend())
       SINTEGRA->Linha := cSINTEGRA
       cSINTEGRA := ""
    next



 endif



return

static function tipo54

    if CONFIG->Sint_prod

       if cCOnv == "3"

       PROD->(Dbgotop())


          ///////////////////////////////////////////////////////////////////////
          // REGISTRO TIPO 54 __________________________________________________

          dDATA_INI := cDATAI
          dDATA_FIM := cDATAF

          SAI->(dbclearfilter())
          SAI->(dbsetfilter({|| (FILIAL == FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM}))

          SAI->(Dbsetorder(1))
          SAI->(Dbgotop())

          FAT->(Dbsetfilter({|| Dt_emissao >= dDATA_INI .and. dt_emissao <= dDATA_FIM }))
          FAT->(dbsetorder(2))
          FAT->(Dbgotop())
          ITEN_FAT->(dbsetorder(2))

          do while ! FAT->(Eof())

             if Empty(FAT->Num_fatura)
                FAT->(Dbskip())
                loop
             endif

             if left(FAT->Cod_cfop,1) $ "1*2*3"
                FAT->(DbSkip())
                loop
             endif

             if FAT->Cancelado
                FAT->(DbSkip())
                loop
             endif

             if ! SAI->(dbseek(FAT->Num_fatura))
                FAT->(dbskip())
                loop
             endif

             CLI1->(Dbseek(FAT->Cod_cli))
             ITEN_FAT->(Dbseek(FAT->Codigo))
             nCONT := 0

             do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
                nCONT++
                nTOT54++
                cSINTEGRA := "54" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + "01" + "01" + " "+FAT->Num_fatura
                PROD->(dbsetorder(4))
                PROD->(dbseek(ITEN_FAT->Cod_prod))
                if ITEN_FAT->Icms == 0
                   nIPI  := 0
                else
                   nIPI  := (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (PROD->Ipi/100)
                endif

                cSINTEGRA += left(FAT->Cod_Cfop,4) + ITEN_FAT->Cod_Sit+strzero(nCONT,3)+strzero(val(ITEN_FAT->Cod_prod),14)+ strzero(val(qtiraponto(str(ITEN_FAT->Quantidade,11,3))),11) + strzero(val(qtiraponto(str( (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar)+nIPI,12,2))),12)

                if SAI->Icm_base  == 0
                   nBASE := 0
                else
                   nBASE := ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
                endif

                nOUTRAS := 0
                nDESC    := 0

                cSINTEGRA += strzero(val(qtiraponto(str(nDESC,12,2))),12)+ strzero(val(qtiraponto(str(nBASE,12,2))),12)
                cSINTEGRA += strzero(val(qtiraponto(str(nOUTRAS,12,2))),12)+strzero(val(qtiraponto(str(nIPI,12,2))),12)+strzero(val(qtiraponto(str(ITEN_FAT->Icms,4,2))),4)

                SINTEGRA->(qappend())
                SINTEGRA->Linha := cSINTEGRA
                cSINTEGRA := ""

                aadd(aTipo75,{ITEN_FAT->Cod_prod})
                ITEN_FAT->(Dbskip())
             enddo
             FAT->(Dbskip())
          enddo
          FAT->(Dbclearfilter())

          i_tipo_54()
          i_tipo_5485()

       else  //Convenio Tipo 1 - 69/02

         SAI->(Dbclearfilter())
         SAI->(dbsetfilter({|| (SAI->Filial $ FILIAL->Codigo) .and. Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM},'Data_lanc >= dDATA_INI .and. Data_lanc <= dDATA_FIM'))
         SAI->(Dbsetorder(3))
         SAI->(Dbgotop())

         SAI->(dbsetorder(3))
         SAI->(dbgotop())
         PROD->(Dbgotop())


          ///////////////////////////////////////////////////////////////////////
          // REGISTRO TIPO 54 __________________________________________________

          FAT->(Dbsetfilter({|| Dt_emissao >= dDATA_INI .and. dt_emissao <= dDATA_FIM }))

          FAT->(Dbgotop())
          do while ! FAT->(Eof())

             if Empty(FAT->Num_fatura)
                FAT->(Dbskip())
                loop
             endif

             if  left(FAT->Cod_cfop,1) $ "1*2*3"
                FAT->(DbSkip())
                loop
             endif

             if ! SAI->(dbseek(FAT->Num_fatura))
                FAT->(dbskip())
                loop
             endif

             if FAT->Cancelado
                FAT->(DbSkip())
                loop
             endif


             CLI1->(Dbseek(FAT->Cod_cli))
             ITEN_FAT->(Dbseek(FAT->Codigo))
             nCONT := 0

             do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
                nCONT++
                nTOT54++
                cSINTEGRA := "54" + iif(CLI1->Cgccpf=="              ",replicate("0",14),strzero(val(CLI1->Cgccpf),14)) + "01" + "01" + " " +"  "+FAT->Num_fatura
                cSINTEGRA += left(FAT->Cod_fisc,3) +strzero(nCONT,3)+strzero(val(ITEN_FAT->Cod_prod),14)+ strzero(val(qtiraponto(str(ITEN_FAT->Quantidade,13,3))),13) + strzero(val(qtiraponto(str(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,12,2))),12)
                PROD->(Dbseek(ITEN_FAT->Cod_prod))
                nBASE := ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
                nIPI  := (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (PROD->Ipi/100)
                nOUTRAS := 0
                nDESC    := 0

                cSINTEGRA += strzero(val(qtiraponto(str(nDESC,12,2))),12)+ strzero(val(qtiraponto(str(nBASE,12,2))),12)
                cSINTEGRA += strzero(val(qtiraponto(str(nOUTRAS,12,2))),12)+strzero(val(qtiraponto(str(nIPI,12,2))),12)+strzero(val(qtiraponto(str(ITEN_FAT->Icms,4,2))),4)
                SINTEGRA->(qappend())
                SINTEGRA->Linha := cSINTEGRA
                cSINTEGRA := ""
                ITEN_FAT->(Dbskip())
             enddo
             FAT->(Dbskip())
          enddo
          FAT->(Dbclearfilter())
       endif
    endif



return

static function i_tipo74_Mantra

  if ! quse(XDRV_ES,"ESTOQUE",{"ESTOQUE"},"E")
     qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
     return
  endif

  if ! quse(XDRV_ES,"ESTMP",{"ESTMP"},"E")
     qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
     return
  endif



      i_74details()
      ESTMP->(Dbclosearea())
      ESTOQUE->(dbclosearea())


return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_74Details
    local nTOTAL     := 0
    local nSALDO_COR := 0
    local nSALDO_TER := 0
    local nSALDO_AVA := 0
    local nSALDO_RES := 0
    local nSALDO_RT  := 0
    local nSALDO_SHOW := 0

    local nCUSTO     := 0

    ESTOQUE->(__dbzap())
    ESTMP->(__dbzap())

    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

    qmensa("Aguarde... Processando ...")
   FAT->(dbclearfilter())
   FAT->(dbsetfilter({|| dt_emissao <= cDATAF}))
   FAT->(dbgotop())
   do while ! FAT->(eof())

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          if empty(FAT->Num_fatura) .and. FAT->Es == "S"
             if ITEN_FAT->Marcado != "*"
                ITEn_FAT->(dbskip())
                loop
              endif


              if ITEN_FAT->Terceiros > 0
                 PROD->(dbsetorder(4))
                 PROD->(dbseek(ITEN_FAT->Cod_prod))

                 Qmensa("Aviso! Produto.: "+Prod->Cod_fabr+" "+left(PROD->Marca,15)+" Aguardando pecas de Terceiros!","B")
                 qinkey(2)
              endif

          endif

          if ESTMP->(qappend())
             replace ESTMP->Fat_cod    with FAT->Codigo
             replace ESTMP->Data       with FAT->Dt_emissao
             replace ESTMP->Produto    with ITEN_FAT->Cod_prod
             replace ESTMP->Nota       with FAT->Num_fatura
             replace ESTMP->Cfop       with alltrim(FAT->Cod_cfop)
             replace ESTMP->Quantidade with ITEN_FAT->Quantidade

             if empty(FAT->Num_fatura) .and. FAT->Es == "S"
                if left(FAT->Cod_cfop,4) $ "1906-2906-5905-6905"
                   replace ESTMP->Es         with FAT->Es
                else
                   replace ESTMP->Es         with "R"
                endif
             else
                replace ESTMP->Es         with FAT->Es
             endif

             replace ESTMP->Cod_fc     with FAT->Cod_cli
          endif

          ITEN_FAT->(Dbskip())
      enddo
      FAT->(dbskip())
   enddo
//   ESTMP->(DbCommit())



   MOVIMENT->(dbsetfilter({|| DAta <= cDATAF}))
   MOVIMENT->(dbsetorder(2)) // data de emissao
   MOVIMENT->(dbgotop())

   do while ! MOVIMENT->(eof())

      if MOVIMENT->Contabil
         MOVIMENT->(dbSkip())
         Loop
      endif

      if MOVIMENT->Tipo == "E"
         cDESCRICAO := "ENTRA"
      else
         cDESCRICAO := "SAIDA"
      endif

      if ESTMP->(qappend())
         replace ESTMP->Data       with MOVIMENT->Data
         replace ESTMP->Produto    with MOVIMENT->Cod_prod
         replace ESTMP->Nota       with ""
         replace ESTMP->Cfop       with left(cDESCRICAO,4)
         replace ESTMP->Quantidade with MOVIMENT->Quantidade
         if MOVIMENT->Tipo == "B"
            replace ESTMP->Es         with "T"
         else
            replace ESTMP->Es         with MOVIMENT->Tipo
         endif
         replace ESTMP->Cod_fc     with cDESCRICAO
      endif

      MOVIMENT->(dbskip())

   enddo

//   ESTMP->(dbcommit())
   AVARIADO->(dbsetfilter({|| Data <= cDATAF}))
   AVARIADO->(dbsetorder(2)) // data de emissao
   AVARIADO->(dbgotop())

   do while ! AVARIADO->(eof())

      if ESTMP->(qappend())
         replace ESTMP->Data       with AVARIADO->Data
         replace ESTMP->Produto    with AVARIADO->Cod_prod
         replace ESTMP->Nota       with ""
         replace ESTMP->Cfop       with "AVAR"
         replace ESTMP->Quantidade with AVARIADO->Quantidade
         replace ESTMP->Es         with "V"
      endif

      AVARIADO->(dbskip())

   enddo

   SHOWROOM->(dbsetfilter({|| Data <= cDATAF}))
   SHOWROOM->(dbsetorder(2)) // data de emissao
   SHOWROOM->(dbgotop())

   do while ! SHOWROOM->(eof())

      if ESTMP->(qappend())
         replace ESTMP->Data       with SHOWROOM->Data
         replace ESTMP->Produto    with SHOWROOM->Cod_prod
         replace ESTMP->Nota       with ""
         replace ESTMP->Cfop       with "ROOM"
         replace ESTMP->Quantidade with SHOWROOM->Quantidade
         replace ESTMP->Es         with "H"
      endif

      SHOWROOM->(dbskip())

   enddo

//   ESTMP->(dbcommit())

   PEDIDO->(dbsetfilter({|| DAta_ped <= cDataF}))

   do while ! PEDIDO->(eof()) 

         if ! PEDIDO->Interface
            PEDIDO->(Dbskip())
            loop
         endif

         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

            if ESTMP->(qappend())
               replace ESTMP->Data        with PEDIDO->Data_ped
               replace ESTMP->Produto     with LANC->Cod_prod
               replace ESTMP->Nota        with PEDIDO->Numero_nf
               replace ESTMP->Cfop        with PEDIDO->Cfop
               replace ESTMP->Quantidade  with LANC->Quant
               replace ESTMP->Preco_cust  with LANC->Preco
               replace ESTMP->Es          with "C"
               replace ESTMP->Cod_fc      with PEDIDO->Cod_forn
            endif

            LANC->(Dbskip())
         enddo
         PEDIDO->(dbskip())
   enddo
   ESTMP->(Dbcommit())

   ESTMP->(Dbgotop())
   ESTMP->(Dbsetorder(1))

   cPROD := ESTMP->Produto
   nSALDO_COR := 0
   nCUSTO := 0
   nSALDO_TER := 0
   nSALDO_AVA := 0
   nSALDO_RES := 0
   nSALDO_RT  := 0
   nSALDO_SHOW := 0

   do while ! ESTMP->(eof())

       if ESTMP->Es $ "S*R*T*V*H"  // Se for Saida soma as quantidades senao diminui

          if ESTOQUE->(qappend())
             replace ESTOQUE->Cod_prod    with ESTMP->Produto
             replace ESTOQUE->Data        with ESTMP->Data
             replace ESTOQUE->Fat_cod     with ESTMP->Fat_cod
             replace ESTOQUE->Cfop        with ESTMP->Cfop
             replace ESTOQUE->Num_nf      with ESTMP->Nota
             replace ESTOQUE->Cod_fc      with ESTMP->Cod_fc

             do case
                case ESTMP->Es == "S"
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

                     replace ESTOQUE->Ter_ant     with nSALDO_TER

                     if ESTMP->Cfop $ "5905-6905"
                        replace ESTOQUE->Ent_ter  with ESTMP->Quantidade
                        replace ESTOQUE->Ter_atu  with (nSALDO_TER + ESTMP->Quantidade)
                        nSALDO_TER := nSALDO_TER + ESTMP->Quantidade
                     else
                        replace ESTOQUE->Ter_atu  with nSALDO_TER
                     endif

                     replace ESTOQUE->Ava_ant     with nSALDO_AVA
                     replace ESTOQUE->Ava_atu     with nSALDO_AVA

                     replace ESTOQUE->Res_ant    with nSALDO_RES
                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     replace ESTOQUE->Res_atu    with nSALDO_RES
                     replace ESTOQUE->RT_atu     with nSALDO_RT

                     //OK

                case ESTMP->Es == "T"
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

                     replace ESTOQUE->Ter_ant     with nSALDO_TER
                     replace ESTOQUE->Ter_atu     with nSALDO_TER

                     replace ESTOQUE->Ava_ant     with nSALDO_AVA
                     replace ESTOQUE->Ava_atu     with nSALDO_AVA

                     replace ESTOQUE->Res_ant    with nSALDO_RES
                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     replace ESTOQUE->Res_atu    with nSALDO_RES
                     replace ESTOQUE->RT_atu     with nSALDO_RT

                     //OK

                case ESTMP->Es == "V"
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

                     replace ESTOQUE->Ava_ant with nSALDO_AVA
                     replace ESTOQUE->Ava_ent with ESTMP->Quantidade
                     replace ESTOQUE->Ava_atu with (nSALDO_AVA + ESTMP->Quantidade)
                     nSALDO_AVA := nSALDO_AVA + ESTMP->Quantidade

                     replace ESTOQUE->Ter_ant    with nSALDO_TER
                     replace ESTOQUE->Ter_atu    with nSALDO_TER

                     replace ESTOQUE->Res_ant    with nSALDO_RES
                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     replace ESTOQUE->Res_atu    with nSALDO_RES
                     replace ESTOQUE->RT_atu     with nSALDO_RT

                case ESTMP->Es == "H" //ShowRoom
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

                     replace ESTOQUE->show_ant with nSALDO_show
                     replace ESTOQUE->show_ent with ESTMP->Quantidade
                     replace ESTOQUE->show_atu with (nSALDO_show + ESTMP->Quantidade)
                     nSALDO_show := nSALDO_show + ESTMP->Quantidade

                     replace ESTOQUE->Ter_ant    with nSALDO_TER
                     replace ESTOQUE->Ter_atu    with nSALDO_TER

                     replace ESTOQUE->Res_ant    with nSALDO_RES
                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     replace ESTOQUE->Res_atu    with nSALDO_RES
                     replace ESTOQUE->RT_atu     with nSALDO_RT


                     //OK

                case ESTMP->Es == "R"

                     replace ESTOQUE->Saldo_ant  with nSALDO_COR

                     replace ESTOQUE->Ter_ant    with nSALDO_TER
                     replace ESTOQUE->Ter_atu     with nSALDO_TER

                     replace ESTOQUE->Ava_ant    with nSALDO_AVA
                     replace ESTOQUE->Ava_atu    with nSALDO_AVA

                     replace ESTOQUE->Res_ant    with nSALDO_RES

                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     if ESTMP->Quantidade <= nSALDO_COR
                        replace ESTOQUE->Saida   with ESTMP->Quantidade
                        replace ESTOQUE->Res_ent with ESTMP->Quantidade
                        nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
                        nSALDO_RES := nSALDO_RES + ESTMP->Quantidade

                        replace ESTOQUE->Res_atu   with nSALDO_RES
                        replace ESTOQUE->Saldo_atu with nSALDO_COR
                        replace ESTOQUE->RT_atu    with nSALDO_RT
                        //OK
                     else
                        if ESTMP->Quantidade <= (nSALDO_COR+(nSALDO_TER-nSALDO_RT))
                           replace ESTOQUE->Saida     with nSALDO_COR
                           replace ESTOQUE->Res_ent   with nSALDO_COR
                           replace ESTOQUE->Saldo_atu with 0
                           replace ESTOQUE->RT_ent    with (ESTMP->Quantidade - nSALDO_COR)

                           ITEN_FAT->(dbsetorder(1))
                           if ITEN_FAT->(dbseek(ESTMP->Fat_cod+ESTMP->produto))

                              if ITEN_FAT->(qrlock())
                                 replace ITEN_FAT->Local     with nSALDO_COR
                                 replace ITEN_FAT->Terceiros with (ESTMP->quantidade - nSALDO_COR)
                                 ITEN_FAT->(qunlock())
                               endif

                           endif

                           nSALDO_RT  := nSALDO_RT  + (ESTMP->Quantidade  - nSALDO_COR)
                           nSALDO_RES := nSALDO_RES + nSALDO_COR
                           nSALDO_COR := 0
                           replace ESTOQUE->RT_atu     with nSALDO_RT
                           replace ESTOQUE->Res_atu    with nSALDO_RES

                        endif
                     endif

             endcase

          endif

       else
          if ESTMP->ES $ "E-C"
             if ESTMP->ES == "C"
                nCUSTO := ( (nSALDO_COR * nCUSTO) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
                nCUSTO := round(nCUSTO,2)
             endif

          if ESTOQUE->(qappend())
             replace ESTOQUE->Cod_prod    with ESTMP->Produto
             replace ESTOQUE->Data        with ESTMP->Data
             replace ESTOQUE->Cfop        with ESTMP->Cfop
             replace ESTOQUE->Num_nf      with ESTMP->Nota
             replace ESTOQUE->Saldo_ant   with nSALDO_COR
             replace ESTOQUE->Entrada     with ESTMP->Quantidade
             replace ESTOQUE->Saldo_atu   with (nSALDO_COR + ESTMP->Quantidade)
             replace ESTOQUE->Cod_fc      with ESTMP->Cod_fc


             nSALDO_COR := nSALDO_COR + ESTMP->Quantidade

             replace ESTOQUE->Ter_ant     with nSALDO_TER

             if ESTMP->Cfop $ "1906-2906"
                replace ESTOQUE->Sai_ter  with ESTMP->Quantidade
                replace ESTOQUE->Ter_atu  with (nSALDO_TER - ESTMP->Quantidade)
                nSALDO_TER := nSALDO_TER - ESTMP->Quantidade
             else
                replace ESTOQUE->Ter_atu  with nSALDO_TER
             endif
          endif

       endif
       endif

       if ESTMP->Produto == "01136"
          qmensa("Nota.: "+estmp->nota+"  Cfop.: "+estmp->cfop+"   saldo.: "+transf(nsaldo_cor,"@R 9999999"))
          qinkey(0)
       endif

       ESTMP->(dbskip())

       if ESTMP->Produto != cPROD

            //    replace INVENT->Quant_atu  with nSALDO_COR
            //    replace INVENT->Quant_ter  with nSALDO_TER
            //    replace INVENT->Quant_res  with nSALDO_RT
            //    replace INVENT->Quant_defe with nSALDO_AVA
            //    replace INVENT->Quant_show with nSALDO_SHOW

          nTOTAL := nSALDO_COR + (nSALDO_TER - nSALDO_RT) + nSALDO_AVA + nSALDO_SHOW

          aadd(aTipo75,{cPROD})

          nTOT74++

          cSINTEGRA := "74"+qdata_sin(cDATAF)+strzero(val(cProd),14)
          cSINTEGRA += strzero(val(qtiraponto(str(nTOTAL,13,3))),13)
          cSINTEGRA += strzero(val(qtiraponto(str(nCUSTO*nTOTAL,13,2))),13)
          cSINTEGRA += "1"
          cSINTEGRA += "00000000000000"
          cSINTEGRA += space(14)
          cSINTEGRA += "PR"
          cSINTEGRA += replicate(" ",45)

          SINTEGRA->(qappend())
          SINTEGRA->Linha := cSINTEGRA
          cSINTEGRA := ""


          cPROD := ESTMP->Produto


          nSALDO_COR := 0
          nSALDO_TER := 0
          nSALDO_AVA := 0
          nSALDO_SHOW:= 0
          nSALDO_RES := 0
          nSALDO_RT  := 0
          nCUSTO     := 0
          nTOTAL     := 0

       endif

   enddo

   //ESTOQUE->(dbcommit())

return




return







