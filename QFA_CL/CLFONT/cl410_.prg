/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO COMERCIAL
// OBJETIVO...: SINTEGRA EM DISQUETE
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JULHO DE 2002
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

// #include "ef.ch"
function cl410
private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1   := qlbloc("B410D","QBLOC.GLO")
private sBLOCO2   := qlbloc("B410E","QBLOC.GLO")
private sBLOCO3   := qlbloc("B410F","QBLOC.GLO")

private lCONF      // variavel  para confirmacoes
private cCONVENIO  // codigo do convenio
private nBUREAU    // numero da empresa bureau
private cMESANO    // mes e ano de competencia
private cDRIVE     // drive para gravacao
private cDATAI     // Data Inicial
private cDATAF     // Data Final
private cRESP      // Responsavel



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
private nTOT90     // Total de registros tipo 90
private nTOT_GER   // Total de registros GERAL
private nCONT      // Total de registros GERAL
private nRESTO

private bENT_FILTRO                 // code block de filtro entradas
private bSAI_FILTRO                 // code block de filtro saidas
private bSAI1_FILTRO                // code block de filtro saidas
private bENT1_FILTRO                // code block de filtro entrada
private bISS1_FILTRO                // code block de filtro servicos


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

private cSINTEGRA

// ABRE ARQUIVO GIA.DBF E ZERA ______________________________________________

if ! quse(XDRV_CLX,"SINTEGRA",NIL,"E")
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

qlbloc(5,0,"B410A","QBLOC.GLO")

do while ! QINST->(eof())
   qgirabarra()

   if "CL" $ QINST->Sistemas

      qmensa("Montando Empresa: " + QINST->Razao)

      if ! quse(QINST->Drv_cl,"CONFIG",NIL,"R")
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
                 {"f410a()/Emite",0}},"P",;
                 {NIL,"f410b",NIL,NIL},;
                  NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))
return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE EMITE CAGED OU NAO ______________________________

function f410a
return(iif(CFGDISQ->Sintegra=="S","SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f410b
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

   qlbloc(5,6,"B410B","QBLOC.GLO")

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
                   {NIL,"f410c",NIL,NIL},;
                    NIL,"<ESC> Encerra / <A>ltera / <C>onsulta"))

   FILIAL->(dbclosearea())

return ""

/////////////////////////////////////////////////////////////////////////////
// EDICAO DADOS DAS FILIAIS _________________________________________________

function f410c
   local aEDICAO2 := {}

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   qlbloc(10,6,"B410G","QBLOC.GLO")

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

   cPATH := "\QSYS_G\QCL\E" + fEMPRESA + "\"


   
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
   aadd(aEDICAO2,{{ || qesco(-1,0,@cDRIVE    ,SBLOCO3               ) } , "DRIVE"})
   aadd(aEDICAO2,{{ || lCONF := qconf("Confirma emiss„o do SINTEGRA ?") } , NIL    })

   do while .T.

      qlbloc(5,0,"B410C","QBLOC.GLO")
      XNIVEL    := 1
      XFLAG     := .T.
      cDRIVE    := "A"
      nLINHA    :=  0
      cDATAI    := ctod("")
      cDATAF    := ctod("")
      cRESP     := space(28)
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
           qrsay(XNIVEL,qabrev(cDRIVE,"AB",{"A:","B:"}))
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

      do while ! FILIAL->(eof())

         cPATH  := "\QSYS_G\QFA_CL\E" + CFGDISQ->Empresa + "\"
         cPATH2 := "\QSYS_G\QCP\E" + CFGDISQ->Empresa + "\"

         qsay(14,30,CFGDISQ->Empresa)
         qsay(14,36,left(CFGDISQ->Razao,35))

         if ! quse(cPATH,"CONFIG",NIL,"R")
            qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH,"FAT",{"FAT"},"E")
            qmensa("N„o foi poss¡vel abrir arquivo IMP.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH,"ITEN_FAT",{"ITEN_FAT"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo ITEN_FAT.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(cPATH,"CLI1",{"CLI_COD"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
            return .F.
         endif

         if ! quse(XDRV_SH,"CGM",{"CGM_COD"},"R")
            qmensa("N„o foi poss¡vel abrir arquivo CGM.DBF !! Tente novamente.")
            return .F.
         endif

         // VERIFICA SE FOI EXECUTADOS AS APURACOES ATNTES DE EMITIR ESTA OPCAO _____

         dDATA_INI := cDATAI


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

         if ( i_inicializacao() , i_impressao() , NIL )

         qmensa("")

         nLINHA := 0   // QUANTIDADE DE LINHA DO REGISTRO 2

         ///////////////////////////////////////////////////////////////////////////////////////
         // GRAVA OS DADOS NO ARQUIVO SINTEGRA.DBF __________________________________________________

         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 10 __________________________________________________

         cSINTEGRA := "10" + alltrim(FILIAL->Cgccpf)+left(FILIAL->Insc_estad,14)+left(FILIAL->Razao,35)
         CGM->(Dbseek(FILIAL->Cgm))
         cSINTEGRA += CGM->Municipio + CGM->Estado + strzero(val(qtiraponto(left(FILIAL->Fax,10))),10) +dtos(cDATAI)+dtos(cDATAF)+"1"+"3"+"1"
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

         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 50 __________________________________________________
       //  if ENT->Serie $ "01*03*06*22"
            dDATA_INI := cDATAI
            dDATA_FIM := cDATAF
            ENT->(dbsetfilter({|| Data_emis >= dDATA_INI .and. Data_emis <= dDATA_FIM},'Data_emis >= dDATA_INI .and. Data_emis <= dDATA_FIM'))
            ENT->(dbsetorder(2))
            ENT->(dbgotop())
            do while ! ENT->(eof())
               nTOT50++
               FORN->(dbseek(ENT->Cod_forn))
               CGM->(dbseek(FORN->Cgm_ent))
               nRESTO := 14 - len(qtiraponto(FORN->Inscricao))

               cSINTEGRA := "50" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_emis) + CGM->Estado + "01" + "   " + "  " +ENT->Num_nf
               cSINTEGRA += ENT->Cod_fisc + strzero(val(qtiraponto(str(ENT->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(ENT->Icm_base,13,2))),13)
               cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(ENT->Icm_isen,13,2))),13)
               cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_out,13,2))),13)+strzero(val(qtiraponto(str(ENT->Icm_aliq,4,2))),4)+"N"
               SINTEGRA->(qappend())
               SINTEGRA->Linha := cSINTEGRA
               cSINTEGRA := ""
               OUTENT->(dbsetorder(1))
               OUTENT->(dbgotop())
               nCONT := 0
               if OUTENT->(dbseek(dtos(ENT->Data_emis)+ENT->Num_nf+ENT->Serie+ENT->Filial))
                  for nCONT = 1 to 3
                       nTOT50++
                       cSINTEGRA := "50" + iif(FORN->Cgccpf=="              ",replicate("0",14),FORN->Cgccpf) + iif(empty(FORN->Inscricao),"ISENTO        ",qtiraponto(FORN->Inscricao))+space(nRESTO) + qdata_sin(ENT->Data_emis) + CGM->Estado + "01" + "   " + "  " +ENT->Num_nf
                       cSINTEGRA += ENT->Cod_fisc + strzero(val(qtiraponto(str(ENT->Vlr_cont,13,2))),13) + strzero(val(qtiraponto(str(OUTENT->Icm_base,13,2))),13)
                       cSINTEGRA += strzero(val(qtiraponto(str(OUTENT->Icm_Vlr,13,2))),13)+ strzero(val(qtiraponto(str(ENT->Icm_isen,13,2))),13)
                       cSINTEGRA += strzero(val(qtiraponto(str(ENT->Icm_out,13,2))),13)+strzero(val(qtiraponto(str(OUTENT->Icm_aliq,4,2))),4)+"N"
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
               nRESTO := 0
               ENT->(dbskip())
            enddo
         //endif
         ///////////////////////////////////////////////////////////////////////
         // REGISTRO TIPO 90 __________________________________________________
         nTOT_GER := nTOT10+nTOT11+nTOT50+1
         cSINTEGRA := "90" + alltrim(FILIAL->Cgccpf)+left(FILIAL->Insc_estad,14) + "50" + strzero(nTOT50,8) +"99" +strzero(nTOT_GER,8)+space(75) + "1"
         SINTEGRA->(qappend())
         SINTEGRA->Linha := cSINTEGRA
//       cSINTEGRA := ""

         CONFIG->(dbclosearea())
         IMP->(dbclosearea())
         OUTENT->(dbclosearea())
         OUTSAI->(dbclosearea())
         ENT->(dbclosearea())
         SAI->(dbclosearea())
         ISS->(dbclosearea())
         FORN->(dbclosearea())
         CGM->(dbclosearea())

         FILIAL->(Dbskip())

      enddo

      FILIAL->(Dbclosearea())

      CFGDISQ->(dbskip())

   enddo

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")
   
   cNOMARQ := cDRIVE + ":ARQ.TXT"
   SINTEGRA->(dbgotop())

   SINTEGRA->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

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

   SAI->(dbSetFilter({|| alltrim(Filial) $ FILIAL->Codigo}, 'alltrim(Filial) $ FILIAL->Codigo'))
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

   // INICIALIZA PROCESSO DE IMPRESSAO _____________________________________

   // CONDICAO PRINCIPAL DE LOOP ___________________________________________


//   do while !ENT->(eof()) //and. eval(bENT_FILTRO)

 //     if eval(bENT_FILTRO)
         qmensa(strzero(nTOT50,5))
//         inkey(0)
//         qmensa("Aguarde! Somando Nota: "+ENT->Num_Nf +" / Serie : "+ENT->Serie)

//         if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
//            for nCONT = 1 to 3
//                 aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
//                 aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
//                 aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr
//                 OUTENT->(dbskip())
//                 if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
//                    exit
//                 endif
//            next
//         endif

         // CODIGOS DE ICMS (ICM_COD) PARA ENTRADA OU SAIDA.
         //     1- Operacoes com Credito do Imposto.
         //     2- Oper. sem Credito do Imposto-Isentas
         //     3- Oper. sem Credito do Imposto-Outras.
         //     4- Oper. com deferimento
         //     5- Isentas com substituicao tributaria
         //     7- Cigarros


         // EXCLUSAO PARA ICMS (NORMAL) ____________________________________


//      ENT->(dbskip())

//   enddo

   // CONDICAO PRINCIPAL DE LOOP____________________________________________

   do while !SAI->(eof()) //.and. eval(bSAI_FILTRO)

     // if eval(bSAI_FILTRO)
         qmensa("Aguarde! Somando Nota: "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
         if OUTSAI->(dbseek(SAI->NUM_NF + SAI->SERIE + SAI->Filial))
            for nCONT = 1 to 3
                 aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
                 aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
                 aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr
                 // BASE DAS OUTRAS ALIQUOTAS DE ICMS
                // fOUT_BASES += OUTSAI->ICM_BASE
                 OUTSAI->(dbskip())
                 if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                    exit
                 endif
            next
         endif


      SAI->(dbskip())

   enddo


return

function qdata_sin(dDATA)
 local dRET,cANO,cMES,cDIA
 cANO := strzero(year(dDATA),4)
 cMES := strzero(month(dDATA),2)
 cDIA := strzero(day(dDATA),2)
 dRET := cANO + cMES + cDIA
return  dRET
//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR SALDO CREDOR ANTERIOR DE ICMS ___________________________

//function i_icm_s_anter
//
//  local dINI_ANTER, dFIM_ANTER, cMES_ANTERIOR, cANO_ANTERIOR, nREC
//
//   fICM_TRANSP   := 0
//   cMES_ANTERIOR := nMES - 1
//   cANO_ANTERIOR := year(dDATA_INI)
//
//   if cMES_ANTERIOR == 0
//      cMES_ANTERIOR := 12
//      cANO_ANTERIOR--
//   endif
//
//   cMES_ANTERIOR := strzero(cMES_ANTERIOR,2)
//   cANO_ANTERIOR := strzero(cANO_ANTERIOR,4)
//
//   dINI_ANTER := ctod("01/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR)
//   dFIM_ANTER := qfimmes(ctod("01/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR))
//
//   nREC := IMP->(recno())
//
//// TRAZ SALDO CREDOR, PASSANDO PARA VALOR POSITIVO ____________________________

//   IMP->(dbseek(K_ICM + dtos(dINI_ANTER) + dtos(dFIM_ANTER)+alltrim(FILIAL->Codigo)))

//   if IMP->Codigo == K_ICM .and. IMP->Data_ini == dINI_ANTER .and. IMP->Data_fim == dFIM_ANTER .and. IMP->Filial == FILIAL->Codigo
//      if IMP->IMP_VALOR < 0
//         fICM_TRANSP := (IMP->IMP_VALOR * -1)
//      endif
//   else
//      alert("SALDO ANTERIOR COM PROBLEMAS !;SE FOR PRIMEIRO MES DE LANCAMENTO DESTA EMPRESA, CONTINUE.;SE NAO, VERIFIQUE SE FOI APURADO OS MESES ANTERIORES.",{"OK"})
//   endif

//   IMP->(dbgoto(nREC))

//return fICM_TRANSP

