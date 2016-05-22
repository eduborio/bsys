/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: DFCGI EM DISQUETE
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: ABRIL DE 2002
// OBS........:
// ALTERACOES.:
function ef440

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

#include "ef.ch"
private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1   := qlbloc("B440D","QBLOC.GLO")
private sBLOCO2   := qlbloc("B440E","QBLOC.GLO")
private sBLOCO3   := qlbloc("B440F","QBLOC.GLO")

private lCONF      // variavel  para confirmacoes
private cCONVENIO  // codigo do convenio
private nBUREAU    // numero da empresa bureau
private cMESANO    // mes e ano de competencia
private cDRIVE     // drive para gravacao
private cCAGED     // string de montagem de cada linha


private dDATA_INI   := ctod("01/01/2015")
private dINI_SIM    := ctod("01/01/2015")
private dDATA_FIM   := ctod("31/12/2015")
private dDATA_EMIS                  // Data de emissao
private dDATA_VENC                  // Data de vencimento
private bSAI_FILTRO
private bFILTRO_SNAC
private bENT_FILTRO

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
private fOUT_BASES
private cDFCGI


private cDFCGI635
private cDFCGI636
private cDFCGI637
private cDFCGI638
private cDFCGI639
private cDFCGI640
private cDFCGI641
private cDFCGI642
private cDFCGI643
private cDFCGI644
private cDFCGI645
private cDFCGI646
private cDFCGI647



private cDFCGI651
private cDFCGI652
private cDFCGI653
private cDFCGI654
private cDFCGI660

private cDFCGI701
private cDFCGI702
private cDFCGI703
private cDFCGI704
private cDFCGI705
private cDFCGI706
private cDFCGI707
private cDFCGI708
private cDFCGI709
private cDFCGI710
private cDFCGI711
private cDFCGI712
private cDFCGI720
private cDUDUDUDU

private cDFCGI751
private cDFCGI752
private cDFCGI753
private cDFCGI754
private cDFCGI755
private cDFCGI756
private cDFCGI757
private cDFCGI758
private cDFCGI759
private cDFCGI760
private cDFCGI761
private cDFCGI762
private cDFCGI770

private cDFCGI801
private cDFCGI802
private cDFCGI803
private cDFCGI804
private cDFCGI805
private cDFCGI806
private cDFCGI807
private cDFCGI808
private cDFCGI809
private cDFCGI810
private cDFCGI811
private cDFCGI812
private cDFCGI813
private cDFCGI814
private cDFCGI815
private cDFCGI816
private cDFCGI817
private cDFCGI818
private cDFCGI819
private cDFCGI820
private cDFCGI821
private cDFCGI822
private cDFCGI823
private cDFCGI824 // TOTAL

private cDFCGI826
private cDFCGI827
private cDFCGI828
private cDFCGI829
private cDFCGI830
private cDFCGI831
private cDFCGI832
private cDFCGI833
private cDFCGI834
private cDFCGI835
private cDFCGI836
private cDFCGI837
private cDFCGI838
private cDFCGI839
private cDFCGI840
private cDFCGI841
private cDFCGI842
private cDFCGI843
private cDFCGI844
private cDFCGI845
private cDFCGI846
private cDFCGI847
private cDFCGI849  // TOTAL

private cDFCGI851
private cDFCGI852
private cDFCGI853
private cDFCGI854
private cDFCGI855
private cDFCGI856
private cDFCGI857
private cDFCGI858
private cDFCGI859
private cDFCGI860
private cDFCGI861
private cDFCGI862
private cDFCGI863
private cDFCGI864
private cDFCGI865
private cDFCGI866
private cDFCGI867
private cDFCGI868
private cDFCGI869
private cDFCGI870
private cDFCGI871
private cDFCGI872
private cDFCGI874  // TOTAL

private cDFCGI876
private cDFCGI877
private cDFCGI878
private cDFCGI879
private cDFCGI880
private cDFCGI881
private cDFCGI882
private cDFCGI883
private cDFCGI884
private cDFCGI885
private cDFCGI886
private cDFCGI887
private cDFCGI888
private cDFCGI889
private cDFCGI890
private cDFCGI891
private cDFCGI892
private cDFCGI893
private cDFCGI894
private cDFCGI895
private cDFCGI896
private cDFCGI897
private cDFCGI899  // TOTAL

private cDFCGI901
private cDFCGI902
private cDFCGI903
private cDFCGI904
private cDFCGI905
private cDFCGI906
private cDFCGI907
private cDFCGI908
private cDFCGI909
private cDFCGI910
private cDFCGI911
private cDFCGI912
private cDFCGI913
private cDFCGI914
private cDFCGI915
private cDFCGI916
private cDFCGI917
private cDFCGI918
private cDFCGI919
private cDFCGI920
private cDFCGI921
private cDFCGI922
private cDFCGI923
private cDFCGI924 // TOTAL

private cDFCGI926
private cDFCGI927
private cDFCGI928
private cDFCGI929
private cDFCGI930
private cDFCGI931
private cDFCGI932
private cDFCGI933
private cDFCGI934
private cDFCGI935
private cDFCGI936
private cDFCGI937
private cDFCGI938
private cDFCGI939
private cDFCGI940
private cDFCGI941
private cDFCGI942
private cDFCGI943
private cDFCGI944
private cDFCGI945
private cDFCGI946
private cDFCGI947
private cDFCGI949  // TOTAL

private cDFCGI951
private cDFCGI952
private cDFCGI953
private cDFCGI954
private cDFCGI955
private cDFCGI956
private cDFCGI957
private cDFCGI958
private cDFCGI959
private cDFCGI960
private cDFCGI961
private cDFCGI962
private cDFCGI963
private cDFCGI964
private cDFCGI965
private cDFCGI966
private cDFCGI967
private cDFCGI968
private cDFCGI969
private cDFCGI970
private cDFCGI971
private cDFCGI972
private cDFCGI974  // TOTAL

private cDFCGI976
private cDFCGI977
private cDFCGI978
private cDFCGI979
private cDFCGI980
private cDFCGI981
private cDFCGI982
private cDFCGI983
private cDFCGI984
private cDFCGI985
private cDFCGI986
private cDFCGI987
private cDFCGI988
private cDFCGI989
private cDFCGI990
private cDFCGI991
private cDFCGI992
private cDFCGI993
private cDFCGI994
private cDFCGI995
private cDFCGI996
private cDFCGI997
private cDFCGI999  // TOTAL

private nLINHA

// ABRE ARQUIVO DFCGI.DBF E ZERA ______________________________________________

if ! quse(XDRV_EFX,"DFCGI",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo DFCGI.DBF !! Tente novamente.")
   return
endif

DFCGI->(__dbzap())

// ABRE ARQUIVO QINST.DBF, FILTRA E ALIMENTA ARQUIVO CFGDISQ.DBF ____________

if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")
   qmensa("N„o foi poss¡vel abrir arquivo QINST.DBF !! Tente novamente.")
   return
endif

if ! quse("","QCONFIG") ; return ; endif

QINST->(dbSetFilter({|| Empresa <> "000"}, 'Empresa <> "000"'))

QINST->(dbgotop())

qlbloc(5,0,"B440A","QBLOC.GLO")

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
                 {"f440a()/Emite",0}},"P",;
                 {NIL,"f440b",NIL,NIL},;
                  NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))
return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE EMITE CAGED OU NAO ______________________________

function f440a
return(iif(CFGDISQ->Dfc=="S","SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f440b
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

   qlbloc(5,6,"B440B","QBLOC.GLO")

   CFGDISQ->(qpublicfields())
   CFGDISQ->(qinitfields())
   CFGDISQ->(qcopyfields())
   qsay(06,20,CFGDISQ->Empresa)
   qsay(06,26,left(CFGDISQ->Razao,44))

   XNIVEL := 1
   qrsay ( XNIVEL++ , qabrev(fDFC,"SN",{"Sim","N„o"}  ) )
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
                   {NIL,"f440c",NIL,NIL},;
                    NIL,"<ESC> Encerra / <A>ltera / <C>onsulta"))

   FILIAL->(dbclosearea())

return ""

/////////////////////////////////////////////////////////////////////////////
// EDICAO DADOS DAS FILIAIS _________________________________________________

function f440c
   local aEDICAO2 := {}

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   qlbloc(10,6,"B440G","QBLOC.GLO")

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

      qlbloc(5,0,"B440C","QBLOC.GLO")
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


         // VERIFICA SE FOI EXECUTADOS AS APURACOES ATNTES DE EMITIR ESTA OPCAO _____

         dDATA_INI := ctod("01/01/2015")

         dDATA_EMIS  := date()
         nVAL_EST    := 0
         dDATA_VENC  := ctod("")
         dDATA_INVE  := ctod("")

         dDATA_INI   := ctod("01/01/2015")

         dDATA1_INI  := ctod("01/01/2015")

         if CONFIG->Tipo_est == "D"
            dDATA_FIM   := ctod("31/12/2015")
            dDATA1_FIM  := ctod("31/12/2015")
         else
            dDATA_FIM   := ctod("31/12/2015")
            dDATA1_FIM  := ctod("31/12/2015")
         endif

         fOUT_BASES := 0
         cDFCGI := ""

         cDFCGI651  := 0
         cDFCGI652  := 0
         cDFCGI653  := 0
         cDFCGI654  := 0
         cDFCGI660  := 0

         cDFCGI635  := 0
         cDFCGI636  := 0
         cDFCGI637  := 0
         cDFCGI638  := 0
         cDFCGI639  := 0
         cDFCGI640  := 0


         cDFCGI641  := 0
         cDFCGI642  := 0
         cDFCGI643  := 0
         cDFCGI644  := 0
         cDFCGI645  := 0
         cDFCGI646  := 0
         cDFCGI647  := 0


         cDFCGI701  := 0
         cDFCGI702  := 0
         cDFCGI703  := 0
         cDFCGI704  := 0
         cDFCGI705  := 0
         cDFCGI706  := 0
         cDFCGI707  := 0
         cDFCGI708  := 0
         cDFCGI709  := 0
         cDFCGI710  := 0
         cDFCGI711  := 0
         cDFCGI712  := 0
         cDFCGI720  := 0

         cDFCGI751  := 0
         cDFCGI752  := 0
         cDFCGI753  := 0
         cDFCGI754  := 0
         cDFCGI755  := 0
         cDFCGI756  := 0
         cDFCGI757  := 0
         cDFCGI758  := 0
         cDFCGI759  := 0
         cDFCGI760  := 0
         cDFCGI761  := 0
         cDFCGI762  := 0
         cDFCGI770  := 0

         cDFCGI801  := 0
         cDFCGI802  := 0
         cDFCGI803  := 0
         cDFCGI804  := 0
         cDFCGI805  := 0
         cDFCGI806  := 0
         cDFCGI807  := 0
         cDFCGI808  := 0
         cDFCGI809  := 0
         cDFCGI810  := 0
         cDFCGI811  := 0
         cDFCGI812  := 0
         cDFCGI813  := 0
         cDFCGI814  := 0
         cDFCGI815  := 0
         cDFCGI816  := 0
         cDFCGI817  := 0
         cDFCGI818  := 0
         cDFCGI819  := 0
         cDFCGI820  := 0
         cDFCGI821  := 0
         cDFCGI822  := 0
         cDFCGI823  := 0
         cDFCGI824  := 0 // TOTAL

         cDFCGI826  := 0
         cDFCGI827  := 0
         cDFCGI828  := 0
         cDFCGI829  := 0
         cDFCGI830  := 0
         cDFCGI831  := 0
         cDFCGI832  := 0
         cDFCGI833  := 0
         cDFCGI834  := 0
         cDFCGI835  := 0
         cDFCGI836  := 0
         cDFCGI837  := 0
         cDFCGI838  := 0
         cDFCGI839  := 0
         cDFCGI840  := 0
         cDFCGI841  := 0
         cDFCGI842  := 0
         cDFCGI843  := 0
         cDFCGI844  := 0
         cDFCGI845  := 0
         cDFCGI846  := 0
         cDFCGI847  := 0
         cDFCGI849  := 0// TOTAL

         cDFCGI851  := 0
         cDFCGI852  := 0
         cDFCGI853  := 0
         cDFCGI854  := 0
         cDFCGI855  := 0
         cDFCGI856  := 0
         cDFCGI857  := 0
         cDFCGI858  := 0
         cDFCGI859  := 0
         cDFCGI860  := 0
         cDFCGI861  := 0
         cDFCGI862  := 0
         cDFCGI863  := 0
         cDFCGI864  := 0
         cDFCGI865  := 0
         cDFCGI866  := 0
         cDFCGI867  := 0
         cDFCGI868  := 0
         cDFCGI869  := 0
         cDFCGI870  := 0
         cDFCGI871  := 0
         cDFCGI872  := 0
         cDFCGI874  := 0  // TOTAL

         cDFCGI876  := 0
         cDFCGI877  := 0
         cDFCGI878  := 0
         cDFCGI879  := 0
         cDFCGI880  := 0
         cDFCGI881  := 0
         cDFCGI882  := 0
         cDFCGI883  := 0
         cDFCGI884  := 0
         cDFCGI885  := 0
         cDFCGI886  := 0
         cDFCGI887  := 0
         cDFCGI888  := 0
         cDFCGI889  := 0
         cDFCGI890  := 0
         cDFCGI891  := 0
         cDFCGI892  := 0
         cDFCGI893  := 0
         cDFCGI894  := 0
         cDFCGI895  := 0
         cDFCGI896  := 0
         cDFCGI897  := 0
         cDFCGI899  := 0// TOTAL

         cDFCGI901  := 0
         cDFCGI902  := 0
         cDFCGI903  := 0
         cDFCGI904  := 0
         cDFCGI905  := 0
         cDFCGI906  := 0
         cDFCGI907  := 0
         cDFCGI908  := 0
         cDFCGI909  := 0
         cDFCGI910  := 0
         cDFCGI911  := 0
         cDFCGI912  := 0
         cDFCGI913  := 0
         cDFCGI914  := 0
         cDFCGI915  := 0
         cDFCGI916  := 0
         cDFCGI917  := 0
         cDFCGI918  := 0
         cDFCGI919  := 0
         cDFCGI920  := 0
         cDFCGI921  := 0
         cDFCGI922  := 0
         cDFCGI923  := 0
         cDFCGI924  := 0 // TOTAL

         cDFCGI926  := 0
         cDFCGI927  := 0
         cDFCGI928  := 0
         cDFCGI929  := 0
         cDFCGI930  := 0
         cDFCGI931  := 0
         cDFCGI932  := 0
         cDFCGI933  := 0
         cDFCGI934  := 0
         cDFCGI935  := 0
         cDFCGI936  := 0
         cDFCGI937  := 0
         cDFCGI938  := 0
         cDFCGI939  := 0
         cDFCGI940  := 0
         cDFCGI941  := 0
         cDFCGI942  := 0
         cDFCGI943  := 0
         cDFCGI944  := 0
         cDFCGI945  := 0
         cDFCGI946  := 0
         cDFCGI947  := 0
         cDFCGI949  := 0 // TOTAL

         cDFCGI951  := 0
         cDFCGI952  := 0
         cDFCGI953  := 0
         cDFCGI954  := 0
         cDFCGI955  := 0
         cDFCGI956  := 0
         cDFCGI957  := 0
         cDFCGI958  := 0
         cDFCGI959  := 0
         cDFCGI960  := 0
         cDFCGI961  := 0
         cDFCGI962  := 0
         cDFCGI963  := 0
         cDFCGI964  := 0
         cDFCGI965  := 0
         cDFCGI966  := 0
         cDFCGI967  := 0
         cDFCGI968  := 0
         cDFCGI969  := 0
         cDFCGI970  := 0
         cDFCGI971  := 0
         cDFCGI972  := 0
         cDFCGI974  := 0 // TOTAL

         cDFCGI976  := 0
         cDFCGI977  := 0
         cDFCGI978  := 0
         cDFCGI979  := 0
         cDFCGI980  := 0
         cDFCGI981  := 0
         cDFCGI982  := 0
         cDFCGI983  := 0
         cDFCGI984  := 0
         cDFCGI985  := 0
         cDFCGI986  := 0
         cDFCGI987  := 0
         cDFCGI988  := 0
         cDFCGI989  := 0
         cDFCGI990  := 0
         cDFCGI991  := 0
         cDFCGI992  := 0
         cDFCGI993  := 0
         cDFCGI994  := 0
         cDFCGI995  := 0
         cDFCGI996  := 0
         cDFCGI997  := 0
         cDFCGI999  := 0// TOTAL

         if ( i_inicializacao() , i_impressao() , NIL )

         qmensa("")

         nLINHA := 0   // QUANTIDADE DE LINHA DO REGISTRO 2

            if cDFCGI801  <>  0
               nLINHA++
            endif
            if cDFCGI802  <> 0
               nLINHA++
            endif
            if cDFCGI803  <> 0
               nLINHA++
            endif
            if cDFCGI804  <> 0
               nLINHA++
            endif
            if cDFCGI805  <> 0
               nLINHA++
            endif
            if cDFCGI806  <> 0
               nLINHA++
            endif
            if cDFCGI807  <> 0
               nLINHA++
            endif
            if cDFCGI808  <> 0
               nLINHA++
            endif
            if cDFCGI809  <> 0
               nLINHA++
            endif
            if cDFCGI810  <> 0
               nLINHA++
            endif
            if cDFCGI811  <> 0
               nLINHA++
            endif
            if cDFCGI812  <> 0
               nLINHA++
            endif
            if cDFCGI813  <> 0
               nLINHA++
            endif
            if cDFCGI814  <> 0
               nLINHA++
            endif
            if cDFCGI815  <> 0
               nLINHA++
            endif
            if cDFCGI816  <> 0
               nLINHA++
            endif
            if cDFCGI817  <> 0
               nLINHA++
            endif
            if cDFCGI818  <> 0
               nLINHA++
            endif
            if cDFCGI819  <> 0
               nLINHA++
            endif
            if cDFCGI820  <> 0
               nLINHA++
            endif
            if cDFCGI821  <> 0
               nLINHA++
            endif
            if cDFCGI822  <> 0
               nLINHA++
            endif
            if cDFCGI823  <> 0
               nLINHA++
            endif
            if cDFCGI824  <> 0
               nLINHA++
            endif

         if CONFIG->Tipo_est == "D"
            if cDFCGI826  <> 0
               nLINHA++
            endif
            if cDFCGI827  <> 0
               nLINHA++
            endif
            if cDFCGI828  <> 0
               nLINHA++
            endif
            if cDFCGI829  <> 0
               nLINHA++
            endif
            if cDFCGI830  <> 0
               nLINHA++
            endif
            if cDFCGI831  <> 0
               nLINHA++
            endif
            if cDFCGI832  <> 0
               nLINHA++
            endif
            if cDFCGI833  <> 0
               nLINHA++
            endif
            if cDFCGI834  <> 0
               nLINHA++
            endif
            if cDFCGI835  <> 0
               nLINHA++
            endif
            if cDFCGI836  <> 0
               nLINHA++
            endif
            if cDFCGI837  <> 0
               nLINHA++
            endif
            if cDFCGI838  <> 0
               nLINHA++
            endif
            if cDFCGI839  <> 0
               nLINHA++
            endif
            if cDFCGI840  <> 0
               nLINHA++
            endif
            if cDFCGI841  <> 0
               nLINHA++
            endif
            if cDFCGI842  <> 0
               nLINHA++
            endif
            if cDFCGI843  <> 0
               nLINHA++
            endif
            if cDFCGI844  <> 0
               nLINHA++
            endif
            if cDFCGI845  <> 0
               nLINHA++
            endif
            if cDFCGI846  <> 0
               nLINHA++
            endif
            if cDFCGI847  <> 0
               nLINHA++
            endif
            if cDFCGI849  <> 0
               nLINHA++
            endif

            if cDFCGI851  <> 0
               nLINHA++
            endif

            if cDFCGI852  <> 0
               nLINHA++
            endif
            if cDFCGI853  <> 0
               nLINHA++
            endif
            if cDFCGI854  <> 0
               nLINHA++
            endif
            if cDFCGI855  <> 0
               nLINHA++
            endif
            if cDFCGI856  <> 0
               nLINHA++
            endif
            if cDFCGI857  <> 0
               nLINHA++
            endif
            if cDFCGI858  <> 0
               nLINHA++
            endif
            if cDFCGI859  <> 0
               nLINHA++
            endif
            if cDFCGI860  <> 0
               nLINHA++
            endif
            if cDFCGI861  <> 0
               nLINHA++
            endif
            if cDFCGI862  <> 0
               nLINHA++
            endif
            if cDFCGI863  <> 0
               nLINHA++
            endif
            if cDFCGI864  <> 0
               nLINHA++
            endif
            if cDFCGI865  <> 0
               nLINHA++
            endif
            if cDFCGI866  <> 0
               nLINHA++
            endif
            if cDFCGI867  <> 0
               nLINHA++
            endif
            if cDFCGI868  <> 0
               nLINHA++
            endif
            if cDFCGI869  <> 0
               nLINHA++
            endif
            if cDFCGI870  <> 0
               nLINHA++
            endif
            if cDFCGI871  <> 0
               nLINHA++
            endif
            if cDFCGI872  <> 0
               nLINHA++
            endif
            if cDFCGI874  <> 0
               nLINHA++
            endif
            if cDFCGI876  <> 0
               nLINHA++
            endif
            if cDFCGI877  <> 0
               nLINHA++
            endif
            if cDFCGI878  <> 0
               nLINHA++
            endif
            if cDFCGI879  <> 0
               nLINHA++
            endif
            if cDFCGI880  <> 0
               nLINHA++
            endif
            if cDFCGI881  <> 0
               nLINHA++
            endif
            if cDFCGI882  <> 0
               nLINHA++
            endif
            if cDFCGI883  <> 0
               nLINHA++
            endif
            if cDFCGI884  <> 0
               nLINHA++
            endif
            if cDFCGI885  <> 0
               nLINHA++
            endif
            if cDFCGI886  <> 0
               nLINHA++
            endif
            if cDFCGI887  <> 0
               nLINHA++
            endif
            if cDFCGI888  <> 0
               nLINHA++
            endif
            if cDFCGI889  <> 0
               nLINHA++
            endif
            if cDFCGI890  <> 0
               nLINHA++
            endif
            if cDFCGI891  <> 0
               nLINHA++
            endif
            if cDFCGI892  <> 0
               nLINHA++
            endif
            if cDFCGI893  <> 0
               nLINHA++
            endif
            if cDFCGI894  <> 0
               nLINHA++
            endif
            if cDFCGI895  <> 0
               nLINHA++
            endif
            if cDFCGI896  <> 0
               nLINHA++
            endif
            if cDFCGI897  <> 0
               nLINHA++
            endif
            if cDFCGI899  <> 0
               nLINHA++
            endif
         endif

         if cDFCGI652  <>  0
            nLINHA++
         endif

         if cDFCGI660  <>  0
            nLINHA++
         endif

         if cDFCGI901  <>  0
            nLINHA++
         endif
         if cDFCGI902  <> 0
            nLINHA++
         endif
         if cDFCGI903  <> 0
            nLINHA++
         endif
         if cDFCGI904  <> 0
            nLINHA++
         endif
         if cDFCGI905  <> 0
            nLINHA++
         endif
         if cDFCGI906  <> 0
            nLINHA++
         endif
         if cDFCGI907  <> 0
            nLINHA++
         endif
         if cDFCGI908  <> 0
            nLINHA++
         endif
         if cDFCGI909  <> 0
            nLINHA++
         endif
         if cDFCGI910  <> 0
            nLINHA++
         endif
         if cDFCGI911  <> 0
            nLINHA++
         endif
         if cDFCGI912  <> 0
            nLINHA++
         endif
         if cDFCGI913  <> 0
            nLINHA++
         endif
         if cDFCGI914  <> 0
            nLINHA++
         endif
         if cDFCGI915  <> 0
            nLINHA++
         endif
         if cDFCGI916  <> 0
            nLINHA++
         endif
         if cDFCGI917  <> 0
            nLINHA++
         endif
         if cDFCGI918  <> 0
            nLINHA++
         endif
         if cDFCGI919  <> 0
            nLINHA++
         endif
         if cDFCGI920  <> 0
            nLINHA++
         endif
         if cDFCGI921  <> 0
            nLINHA++
         endif
         if cDFCGI924  <> 0
            nLINHA++
         endif

         if CONFIG->Tipo_est == "D"
            if cDFCGI926  <> 0
               nLINHA++
            endif
            if cDFCGI927  <> 0
               nLINHA++
            endif
            if cDFCGI928  <> 0
               nLINHA++
            endif
            if cDFCGI929  <> 0
               nLINHA++
            endif
            if cDFCGI930  <> 0
               nLINHA++
            endif
            if cDFCGI931  <> 0
               nLINHA++
            endif
            if cDFCGI932  <> 0
               nLINHA++
            endif
            if cDFCGI933  <> 0
               nLINHA++
            endif
            if cDFCGI934  <> 0
               nLINHA++
            endif
            if cDFCGI935  <> 0
               nLINHA++
            endif
            if cDFCGI936  <> 0
               nLINHA++
            endif
            if cDFCGI937  <> 0
               nLINHA++
            endif
            if cDFCGI938  <> 0
               nLINHA++
            endif
            if cDFCGI939  <> 0
               nLINHA++
            endif
            if cDFCGI940  <> 0
               nLINHA++
            endif
            if cDFCGI941  <> 0
               nLINHA++
            endif
            if cDFCGI942  <> 0
               nLINHA++
            endif
            if cDFCGI943  <> 0
               nLINHA++
            endif
            if cDFCGI944  <> 0
               nLINHA++
            endif
            if cDFCGI945  <> 0
               nLINHA++
            endif
            if cDFCGI949  <> 0
               nLINHA++
            endif
            if cDFCGI951  <> 0
               nLINHA++
            endif
            if cDFCGI952  <> 0
               nLINHA++
            endif
            if cDFCGI953  <> 0
               nLINHA++
            endif
            if cDFCGI954  <> 0
               nLINHA++
            endif
            if cDFCGI955  <> 0
               nLINHA++
            endif
            if cDFCGI956  <> 0
               nLINHA++
            endif
            if cDFCGI957  <> 0
               nLINHA++
            endif
            if cDFCGI958  <> 0
               nLINHA++
            endif
            if cDFCGI959  <> 0
               nLINHA++
            endif
            if cDFCGI960  <> 0
               nLINHA++
            endif
            if cDFCGI961  <> 0
               nLINHA++
            endif
            if cDFCGI962  <> 0
               nLINHA++
            endif
            if cDFCGI963  <> 0
               nLINHA++
            endif
            if cDFCGI964  <> 0
               nLINHA++
            endif
            if cDFCGI965  <> 0
               nLINHA++
            endif
            if cDFCGI966  <> 0
               nLINHA++
            endif
            if cDFCGI967  <> 0
               nLINHA++
            endif
            if cDFCGI968  <> 0
               nLINHA++
            endif
            if cDFCGI969  <> 0
               nLINHA++
            endif
            if cDFCGI970  <> 0
               nLINHA++
            endif
            if cDFCGI974  <> 0
               nLINHA++
            endif
            if cDFCGI976  <> 0
               nLINHA++
            endif
            if cDFCGI977  <> 0
               nLINHA++
            endif
            if cDFCGI978  <> 0
               nLINHA++
            endif
            if cDFCGI979  <> 0
               nLINHA++
            endif
            if cDFCGI980  <> 0
               nLINHA++
            endif
            if cDFCGI981  <> 0
               nLINHA++
            endif
            if cDFCGI982  <> 0
               nLINHA++
            endif
            if cDFCGI983  <> 0
               nLINHA++
            endif
            if cDFCGI984  <> 0
               nLINHA++
            endif
            if cDFCGI985  <> 0
               nLINHA++
            endif
            if cDFCGI986  <> 0
               nLINHA++
            endif
            if cDFCGI987  <> 0
               nLINHA++
            endif
            if cDFCGI988  <> 0
               nLINHA++
            endif
            if cDFCGI989  <> 0
               nLINHA++
            endif
            if cDFCGI990  <> 0
               nLINHA++
            endif
            if cDFCGI991  <> 0
               nLINHA++
            endif
            if cDFCGI992  <> 0
               nLINHA++
            endif
            if cDFCGI993  <> 0
               nLINHA++
            endif
            if cDFCGI994  <> 0
               nLINHA++
            endif
            if cDFCGI995  <> 0
               nLINHA++
            endif
            if cDFCGI999  <> 0
               nLINHA++
            endif
         endif

         if CONFIG->Tipo_est !="D"

            if cDFCGI635  <> 0
               nLINHA++
            endif


            if cDFCGI636  <> 0
               nLINHA++
            endif


            if cDFCGI637  <> 0
               nLINHA++
            endif

            if cDFCGI638  <> 0
               nLINHA++
            endif


            if cDFCGI639  <> 0
               nLINHA++
            endif

            if cDFCGI640  <> 0
               nLINHA++
            endif

            if cDFCGI641  <> 0
               nLINHA++
            endif
            if cDFCGI642  <> 0
               nLINHA++
            endif
            if cDFCGI643  <> 0
               nLINHA++
            endif
            if cDFCGI644  <> 0
               nLINHA++
            endif
            if cDFCGI645  <> 0
               nLINHA++
            endif
            if cDFCGI646  <> 0
               nLINHA++
            endif
            if cDFCGI647  <> 0
               nLINHA++
            endif

         endif


         ///////////////////////////////////////////////////////////////////////////////////////
         // GRAVA OS DADOS NO ARQUIVO DFCGI.DBF __________________________________________________
         //REGISTRO TIPO 1
         cDFCGI := "1" + "21" + left(FILIAL->Insc_estad,10) + FILIAL->Cgccpf+ "201512"+ "C"
         cDFCGI += CFGDISQ->Crc_contab +"     " +"8" + space(59)
         cDFCGI += strzero(nLINHA,3)
         nLINHA := 0
         DFCGI->(qappend())
         DFCGI->Linha := cDFCGI
         cDFCGI := ""

//TODOS OS TIPOS DE EMPRESA

            if cDFCGI652 <> 0
               cDFCGI := "2" + "6520" + strzero(cDFCGI652,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI660 <> 0
               cDFCGI := "2" + "6600" + strzero(cDFCGI660,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
//FINAL

            if cDFCGI801 <> 0
               cDFCGI := "2" + "8010" + strzero(cDFCGI801,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI802 <> 0
               cDFCGI := "2" + "8020" + strzero(cDFCGI802,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI803 <> 0
               cDFCGI := "2" + "8030" + strzero(cDFCGI803,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI804 <> 0
               cDFCGI := "2" + "8040" + strzero(cDFCGI804,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI805 <> 0
               cDFCGI := "2" + "8050" + strzero(cDFCGI805,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI806 <> 0
               cDFCGI := "2" + "8060" + strzero(cDFCGI806,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI807 <> 0
               cDFCGI := "2" + "8070" + strzero(cDFCGI807,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI808 <> 0
               cDFCGI := "2" + "8080" + strzero(cDFCGI808,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI809 <> 0
               cDFCGI := "2" + "8090" + strzero(cDFCGI809,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI810 <> 0
               cDFCGI := "2" + "8100" + strzero(cDFCGI810,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI811 <> 0
               cDFCGI := "2" + "8110" + strzero(cDFCGI811,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI812 <> 0
               cDFCGI := "2" + "8120" + strzero(cDFCGI812,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI813 <> 0
               cDFCGI := "2" + "8130" + strzero(cDFCGI813,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI814 <> 0
               cDFCGI := "2" + "8140" + strzero(cDFCGI814,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI815 <> 0
               cDFCGI := "2" + "8150" + strzero(cDFCGI815,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI816 <> 0
               cDFCGI := "2" + "8160" + strzero(cDFCGI816,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI817 <> 0
               cDFCGI := "2" + "8170" + strzero(cDFCGI817,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI818 <> 0
               cDFCGI := "2" + "8180" + strzero(cDFCGI818,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI819 <> 0
               cDFCGI := "2" + "8190" + strzero(cDFCGI819,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI820 <> 0
               cDFCGI := "2" + "8200" + strzero(cDFCGI820,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI821 <> 0
               cDFCGI := "2" + "8210" + strzero(cDFCGI821,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI822 <> 0
               cDFCGI := "2" + "8220" + strzero(cDFCGI822,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI823 <> 0
               cDFCGI := "2" + "8230" + strzero(cDFCGI823,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI824 <> 0
               cDFCGI := "2" + "8240" + strzero(cDFCGI824,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI901 <> 0
               cDFCGI := "2" + "9010" + strzero(cDFCGI901,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI902 <> 0
               cDFCGI := "2" + "9020" + strzero(cDFCGI902,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI903 <> 0
               cDFCGI := "2" + "9030" + strzero(cDFCGI903,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI904 <> 0
               cDFCGI := "2" + "9040" + strzero(cDFCGI904,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI905 <> 0
               cDFCGI := "2" + "9050" + strzero(cDFCGI905,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI906 <> 0
               cDFCGI := "2" + "9060" + strzero(cDFCGI906,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI907 <> 0
               cDFCGI := "2" + "9070" + strzero(cDFCGI907,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI908 <> 0
               cDFCGI := "2" + "9080" + strzero(cDFCGI908,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI909 <> 0
               cDFCGI := "2" + "9090" + strzero(cDFCGI909,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI910 <> 0
               cDFCGI := "2" + "9100" + strzero(cDFCGI910,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI911 <> 0
               cDFCGI := "2" + "9110" + strzero(cDFCGI911,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI912 <> 0
               cDFCGI := "2" + "9120" + strzero(cDFCGI912,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI913 <> 0
               cDFCGI := "2" + "9130" + strzero(cDFCGI913,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI914 <> 0
               cDFCGI := "2" + "9140" + strzero(cDFCGI914,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI915 <> 0
               cDFCGI := "2" + "9150" + strzero(cDFCGI915,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI916 <> 0
               cDFCGI := "2" + "9160" + strzero(cDFCGI916,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI917 <> 0
               cDFCGI := "2" + "9170" + strzero(cDFCGI917,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI918 <> 0
               cDFCGI := "2" + "9180" + strzero(cDFCGI918,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI919 <> 0
               cDFCGI := "2" + "9190" + strzero(cDFCGI919,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI920 <> 0
               cDFCGI := "2" + "9200" + strzero(cDFCGI920,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI921 <> 0
               cDFCGI := "2" + "9210" + strzero(cDFCGI921,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI924 <> 0
               cDFCGI := "2" + "9240" + strzero(cDFCGI924,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

         if CONFIG->Tipo_est == "D"
            if cDFCGI826 <> 0
               cDFCGI := "2" + "8260" + strzero(cDFCGI826,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI827 <> 0
               cDFCGI := "2" + "8270" + strzero(cDFCGI827,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI828 <> 0
               cDFCGI := "2" + "8280" + strzero(cDFCGI828,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI829 <> 0
               cDFCGI := "2" + "8290" + strzero(cDFCGI829,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI830 <> 0
               cDFCGI := "2" + "8300" + strzero(cDFCGI830,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI831 <> 0
               cDFCGI := "2" + "8310" + strzero(cDFCGI831,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI832 <> 0
               cDFCGI := "2" + "8320" + strzero(cDFCGI832,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI833 <> 0
               cDFCGI := "2" + "8330" + strzero(cDFCGI833,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI834 <> 0
               cDFCGI := "2" + "8340" + strzero(cDFCGI834,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI835 <> 0
               cDFCGI := "2" + "8350" + strzero(cDFCGI835,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI836 <> 0
               cDFCGI := "2" + "8360" + strzero(cDFCGI836,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI837 <> 0
               cDFCGI := "2" + "8370" + strzero(cDFCGI837,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI838 <> 0
               cDFCGI := "2" + "8380" + strzero(cDFCGI838,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI839 <> 0
               cDFCGI := "2" + "8390" + strzero(cDFCGI839,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI840 <> 0
               cDFCGI := "2" + "8400" + strzero(cDFCGI840,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI841 <> 0
               cDFCGI := "2" + "8410" + strzero(cDFCGI841,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI842 <> 0
               cDFCGI := "2" + "8420" + strzero(cDFCGI842,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI843 <> 0
               cDFCGI := "2" + "8430" + strzero(cDFCGI843,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI844 <> 0
               cDFCGI := "2" + "8440" + strzero(cDFCGI844,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI845 <> 0
               cDFCGI := "2" + "8450" + strzero(cDFCGI845,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI846 <> 0
               cDFCGI := "2" + "8460" + strzero(cDFCGI846,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI847 <> 0
               cDFCGI := "2" + "8470" + strzero(cDFCGI847,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI849 <> 0
               cDFCGI := "2" + "8490" + strzero(cDFCGI849,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI851 <> 0
               cDFCGI := "2" + "8510" + strzero(cDFCGI851,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI852 <> 0
               cDFCGI := "2" + "8520" + strzero(cDFCGI852,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI853 <> 0
               cDFCGI := "2" + "8530" + strzero(cDFCGI853,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI854 <> 0
               cDFCGI := "2" + "8540" + strzero(cDFCGI854,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI855 <> 0
               cDFCGI := "2" + "8550" + strzero(cDFCGI855,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI856 <> 0
               cDFCGI := "2" + "8560" + strzero(cDFCGI856,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI857 <> 0
               cDFCGI := "2" + "8570" + strzero(cDFCGI857,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI858 <> 0
               cDFCGI := "2" + "8580" + strzero(cDFCGI858,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI859 <> 0
               cDFCGI := "2" + "8590" + strzero(cDFCGI859,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI860 <> 0
               cDFCGI := "2" + "8600" + strzero(cDFCGI860,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI861 <> 0
               cDFCGI := "2" + "8610" + strzero(cDFCGI861,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI862 <> 0
               cDFCGI := "2" + "8620" + strzero(cDFCGI862,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI863 <> 0
               cDFCGI := "2" + "8630" + strzero(cDFCGI863,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI864 <> 0
               cDFCGI := "2" + "8640" + strzero(cDFCGI864,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI865 <> 0
               cDFCGI := "2" + "8650" + strzero(cDFCGI865,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI866 <> 0
               cDFCGI := "2" + "8660" + strzero(cDFCGI866,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI867 <> 0
               cDFCGI := "2" + "8670" + strzero(cDFCGI867,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI868 <> 0
               cDFCGI := "2" + "8680" + strzero(cDFCGI868,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI869 <> 0
               cDFCGI := "2" + "8690" + strzero(cDFCGI869,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI870 <> 0
               cDFCGI := "2" + "8700" + strzero(cDFCGI870,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI871 <> 0
               cDFCGI := "2" + "8710" + strzero(cDFCGI871,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI872 <> 0
               cDFCGI := "2" + "8720" + strzero(cDFCGI872,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI874 <> 0
               cDFCGI := "2" + "8740" + strzero(cDFCGI874,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI876 <> 0
               cDFCGI := "2" + "8760" + strzero(cDFCGI876,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI877 <> 0
               cDFCGI := "2" + "8770" + strzero(cDFCGI877,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI878 <> 0
               cDFCGI := "2" + "8780" + strzero(cDFCGI878,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI879 <> 0
               cDFCGI := "2" + "8790" + strzero(cDFCGI879,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI880 <> 0
               cDFCGI := "2" + "8800" + strzero(cDFCGI880,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI881 <> 0
               cDFCGI := "2" + "8810" + strzero(cDFCGI881,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI882 <> 0
               cDFCGI := "2" + "8820" + strzero(cDFCGI882,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI883 <> 0
               cDFCGI := "2" + "8830" + strzero(cDFCGI883,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI884 <> 0
               cDFCGI := "2" + "8840" + strzero(cDFCGI884,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI885 <> 0
               cDFCGI := "2" + "8850" + strzero(cDFCGI885,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI886 <> 0
               cDFCGI := "2" + "8860" + strzero(cDFCGI886,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI887 <> 0
               cDFCGI := "2" + "8870" + strzero(cDFCGI887,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI888 <> 0
               cDFCGI := "2" + "8880" + strzero(cDFCGI888,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI889 <> 0
               cDFCGI := "2" + "8890" + strzero(cDFCGI889,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI890 <> 0
               cDFCGI := "2" + "8900" + strzero(cDFCGI890,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI891 <> 0
               cDFCGI := "2" + "8910" + strzero(cDFCGI891,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI892 <> 0
               cDFCGI := "2" + "8920" + strzero(cDFCGI892,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI893 <> 0
               cDFCGI := "2" + "8930" + strzero(cDFCGI893,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI894 <> 0
               cDFCGI := "2" + "8940" + strzero(cDFCGI894,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI895 <> 0
               cDFCGI := "2" + "8950" + strzero(cDFCGI895,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI896 <> 0
               cDFCGI := "2" + "8960" + strzero(cDFCGI896,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI897 <> 0
               cDFCGI := "2" + "8970" + strzero(cDFCGI897,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI899 <> 0
               cDFCGI := "2" + "8990" + strzero(cDFCGI899,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI926 <> 0
               cDFCGI := "2" + "9260" + strzero(cDFCGI926,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI927 <> 0
               cDFCGI := "2" + "9270" + strzero(cDFCGI927,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI928 <> 0
               cDFCGI := "2" + "9280" + strzero(cDFCGI928,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI929 <> 0
               cDFCGI := "2" + "9290" + strzero(cDFCGI929,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI930 <> 0
               cDFCGI := "2" + "9300" + strzero(cDFCGI930,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI931 <> 0
               cDFCGI := "2" + "9310" + strzero(cDFCGI931,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI932 <> 0
               cDFCGI := "2" + "9320" + strzero(cDFCGI932,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI933 <> 0
               cDFCGI := "2" + "9330" + strzero(cDFCGI933,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI934 <> 0
               cDFCGI := "2" + "9340" + strzero(cDFCGI934,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI935 <> 0
               cDFCGI := "2" + "9350" + strzero(cDFCGI935,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI936 <> 0
               cDFCGI := "2" + "9360" + strzero(cDFCGI936,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI937 <> 0
               cDFCGI := "2" + "9370" + strzero(cDFCGI937,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI938 <> 0
               cDFCGI := "2" + "9380" + strzero(cDFCGI938,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI939 <> 0
               cDFCGI := "2" + "9390" + strzero(cDFCGI939,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI940 <> 0
               cDFCGI := "2" + "9400" + strzero(cDFCGI940,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI941 <> 0
               cDFCGI := "2" + "9410" + strzero(cDFCGI941,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI942 <> 0
               cDFCGI := "2" + "9420" + strzero(cDFCGI942,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI943 <> 0
               cDFCGI := "2" + "9430" + strzero(cDFCGI943,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI944 <> 0
               cDFCGI := "2" + "9440" + strzero(cDFCGI944,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI945 <> 0
               cDFCGI := "2" + "9450" + strzero(cDFCGI945,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI949 <> 0
               cDFCGI := "2" + "9490" + strzero(cDFCGI949,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI951 <> 0
               cDFCGI := "2" + "9510" + strzero(cDFCGI951,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI952 <> 0
               cDFCGI := "2" + "9520" + strzero(cDFCGI952,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI953 <> 0
               cDFCGI := "2" + "9530" + strzero(cDFCGI953,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI954 <> 0
               cDFCGI := "2" + "9540" + strzero(cDFCGI954,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI955 <> 0
               cDFCGI := "2" + "9550" + strzero(cDFCGI955,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI956 <> 0
               cDFCGI := "2" + "9560" + strzero(cDFCGI956,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI957 <> 0
               cDFCGI := "2" + "9570" + strzero(cDFCGI957,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI958 <> 0
               cDFCGI := "2" + "9580" + strzero(cDFCGI958,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI959 <> 0
               cDFCGI := "2" + "9590" + strzero(cDFCGI959,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI960 <> 0
               cDFCGI := "2" + "9600" + strzero(cDFCGI960,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI961 <> 0
               cDFCGI := "2" + "9610" + strzero(cDFCGI961,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI962 <> 0
               cDFCGI := "2" + "9620" + strzero(cDFCGI962,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI963 <> 0
               cDFCGI := "2" + "9630" + strzero(cDFCGI963,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI964 <> 0
               cDFCGI := "2" + "9640" + strzero(cDFCGI964,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI965 <> 0
               cDFCGI := "2" + "9650" + strzero(cDFCGI965,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI966 <> 0
               cDFCGI := "2" + "9660" + strzero(cDFCGI966,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI967 <> 0
               cDFCGI := "2" + "9670" + strzero(cDFCGI967,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI968 <> 0
               cDFCGI := "2" + "9680" + strzero(cDFCGI968,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI969 <> 0
               cDFCGI := "2" + "9690" + strzero(cDFCGI969,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI970 <> 0
               cDFCGI := "2" + "9700" + strzero(cDFCGI970,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI974 <> 0
               cDFCGI := "2" + "9740" + strzero(cDFCGI974,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI976 <> 0
               cDFCGI := "2" + "9760" + strzero(cDFCGI976,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI977 <> 0
               cDFCGI := "2" + "9770" + strzero(cDFCGI977,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI978 <> 0
               cDFCGI := "2" + "9780" + strzero(cDFCGI978,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI979 <> 0
               cDFCGI := "2" + "9790" + strzero(cDFCGI979,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI980 <> 0
               cDFCGI := "2" + "9800" + strzero(cDFCGI980,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI981 <> 0
               cDFCGI := "2" + "9810" + strzero(cDFCGI981,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI982 <> 0
               cDFCGI := "2" + "9820" + strzero(cDFCGI982,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI983 <> 0
               cDFCGI := "2" + "9830" + strzero(cDFCGI983,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI984 <> 0
               cDFCGI := "2" + "9840" + strzero(cDFCGI984,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI985 <> 0
               cDFCGI := "2" + "9850" + strzero(cDFCGI985,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI986 <> 0
               cDFCGI := "2" + "9860" + strzero(cDFCGI986,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI987 <> 0
               cDFCGI := "2" + "9870" + strzero(cDFCGI987,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI988 <> 0
               cDFCGI := "2" + "9880" + strzero(cDFCGI988,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI989 <> 0
               cDFCGI := "2" + "9890" + strzero(cDFCGI989,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI990 <> 0
               cDFCGI := "2" + "9900" + strzero(cDFCGI990,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI991 <> 0
               cDFCGI := "2" + "9910" + strzero(cDFCGI991,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI992 <> 0
               cDFCGI := "2" + "9920" + strzero(cDFCGI992,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI993 <> 0
               cDFCGI := "2" + "9930" + strzero(cDFCGI993,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI994 <> 0
               cDFCGI := "2" + "9940" + strzero(cDFCGI994,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI995 <> 0
               cDFCGI := "2" + "9950" + strzero(cDFCGI995,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI999 <> 0
               cDFCGI := "2" + "9990" + strzero(cDFCGI999,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
         endif


         if CONFIG->Tipo_est != "D"


            if cDFCGI635 <> 0
               cDFCGI := "2" + "6350" + strzero(cDFCGI635,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI636 <> 0
               cDFCGI := "2" + "6360" + strzero(cDFCGI636,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI637 <> 0
               cDFCGI := "2" + "6370" + strzero(cDFCGI637,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI638 <> 0
               cDFCGI := "2" + "6380" + strzero(cDFCGI638,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI639 <> 0
               cDFCGI := "2" + "6390" + strzero(cDFCGI639,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI640 <> 0
               cDFCGI := "2" + "6400" + strzero(cDFCGI640,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI641 <> 0
               cDFCGI := "2" + "6410" + strzero(cDFCGI641,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI642 <> 0
               cDFCGI := "2" + "6420" + strzero(cDFCGI642,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif
            if cDFCGI643 <> 0
               cDFCGI := "2" + "6430" + strzero(cDFCGI643,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI644 <> 0
               cDFCGI := "2" + "6440" + strzero(cDFCGI644,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI645 <> 0
               cDFCGI := "2" + "6450" + strzero(cDFCGI645,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI646 <> 0
               cDFCGI := "2" + "6460" + strzero(cDFCGI646,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

            if cDFCGI647 <> 0
               cDFCGI := "2" + "6470" + strzero(cDFCGI647,15)
               DFCGI->(qappend())
               DFCGI->Linha := cDFCGI
               cDFCGI := ""
            endif

         endif



         CONFIG->(dbclosearea())
         IMP->(dbclosearea())
         OUTENT->(dbclosearea())
         OUTSAI->(dbclosearea())
         ENT->(dbclosearea())
         SAI->(dbclosearea())

         FILIAL->(Dbskip())

      enddo

      FILIAL->(Dbclosearea())

      CFGDISQ->(dbskip())

   enddo

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")
   
   cNOMARQ := "C:\qsystxt\DFC_QSYS.TXT"
   DFCGI->(dbgotop())

   DFCGI->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

   qmensa()

   select CFGDISQ

   CFGDISQ->(dbgotop())

   if DFCGI->(qflock())
      DFCGI->(__dbzap())
   endif

return

////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO __________________________

static function i_inicializacao

   alert("iniciando")

   // CRIA MACRO DE FILTRO _________________________________________________

   //SAI->(dbSetFilter({|| alltrim(Filial) $ FILIAL->Codigo}, 'alltrim(Filial) $ FILIAL->Codigo'))
   //ENT->(dbSetFilter({|| alltrim(Filial) $ FILIAL->Codigo}, 'alltrim(Filial) $ FILIAL->Codigo'))
   bENT_FILTRO  := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO  := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }
   bFILTRO_SNAC := { || SAI->DATA_LANC >= ctod("01/01/2015") .and. SAI->DATA_LANC <= dDATA_FIM }

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


   // CONDICAO PRINCIPAL DE LOOP ___________________________________________


   do while !ENT->(eof()) .and. eval(bENT_FILTRO)


      qmensa("Aguarde! Somando Nota: "+ENT->Num_Nf +" / Serie : "+ENT->Serie + "Emiss:" +dtoc(ENT->Data_lanc) )
	  //qinkey(0)

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

      do case

         case ENT->Cfop $ "1101-1102-1103-1104-1105-1106-1107-1108-1109-1110-1111-1112-1113-1114-1115-1116-1117-1118-1119-1120-1121-1122-1123-1124-1125-1126-1401-1403-1651-1652-1653"
              cDFCGI801 += ENT->Vlr_cont
              cDFCGI826 += ENT->Icm_base + fOUT_BASES
              cDFCGI851 += ENT->Icm_isen
              cDFCGI876 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "1151-1152-1154-1408-1409-1410-1411-1201-1202-1203-1204-1205-1206-1207-1208-1209-1658-1659-1660-1661-1662"
              cDFCGI802 += ENT->Vlr_cont
              cDFCGI827 += ENT->Icm_base + fOUT_BASES
              cDFCGI852 += ENT->Icm_isen
              cDFCGI877 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out


         case ENT->Cfop $ "1251-1257-1153"
              cDFCGI803 += ENT->Vlr_cont
              cDFCGI828 += ENT->Icm_base + fOUT_BASES
              cDFCGI853 += ENT->Icm_isen
              cDFCGI878 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out


         case ENT->Cfop $ "1301-1302-1303-1304-1305-1306"
              cDFCGI804 += ENT->Vlr_cont
              cDFCGI829 += ENT->Icm_base + fOUT_BASES
              cDFCGI854 += ENT->Icm_isen
              cDFCGI879 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "1351-1652-1653-1354-1355-1356"
              cDFCGI805 += ENT->Vlr_cont
              cDFCGI830 += ENT->Icm_base + fOUT_BASES
              cDFCGI855 += ENT->Icm_isen
              cDFCGI880 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "1406-1407-1551-1552-1553-1554-1555-1556-1557"
              cDFCGI806 += ENT->Vlr_cont
              cDFCGI831 += ENT->Icm_base + fOUT_BASES
              cDFCGI856 += ENT->Icm_isen
              cDFCGI881 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "1451-1452-1501-1502-1503-1504-1910-1911"
              cDFCGI807 += ENT->Vlr_cont
              cDFCGI832 += ENT->Icm_base + fOUT_BASES
              cDFCGI857 += ENT->Icm_isen
              cDFCGI882 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "1601-1602-1603-1414-1415-1901-1902-1903-1904-1905-1906-1907-1908-1909-1912-1913-1914-1915-1916-1917-1918-1919-1920-1921-1922-1923-1924-1925-1929-1949-1663-1664"
              cDFCGI808 += ENT->Vlr_cont
              cDFCGI833 += ENT->Icm_base + fOUT_BASES
              cDFCGI858 += ENT->Icm_isen
              cDFCGI883 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case left(ENT->Cfop,3) $ "210-211-212-220"
              cDFCGI809 += ENT->Vlr_cont
              cDFCGI834 += ENT->Icm_base + fOUT_BASES
              cDFCGI859 += ENT->Icm_isen
              cDFCGI884 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "2401-2403-2151-2152-2154-2408-2409-2410-2411-2651-2652-2653-2654-2655-2656-2657-2658-2659-2660-2661-2662"
              cDFCGI809 += ENT->Vlr_cont
              cDFCGI834 += ENT->Icm_base + fOUT_BASES
              cDFCGI859 += ENT->Icm_isen
              cDFCGI884 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out


         case ENT->Cfop $ "2251-2252-2253-2254-2255-2256-2257-2153"
              cDFCGI810 += ENT->Vlr_cont
              cDFCGI835 += ENT->Icm_base + fOUT_BASES
              cDFCGI860 += ENT->Icm_isen
              cDFCGI885 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "2301-2302-2303-2304-2305-2306"
              cDFCGI811 += ENT->Vlr_cont
              cDFCGI836 += ENT->Icm_base + fOUT_BASES
              cDFCGI861 += ENT->Icm_isen
              cDFCGI886 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "2351-2352-2353-2354-2355-2356"
              cDFCGI812 += ENT->Vlr_cont
              cDFCGI837 += ENT->Icm_base + fOUT_BASES
              cDFCGI862 += ENT->Icm_isen
              cDFCGI887 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "2406-2407-2551-2552-2553-2554-2555-2556-2557"
              cDFCGI813 += ENT->Vlr_cont
              cDFCGI838 += ENT->Icm_base + fOUT_BASES
              cDFCGI863 += ENT->Icm_isen
              cDFCGI888 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "2501-2502-2503-2504-2910-2911"
              cDFCGI814 += ENT->Vlr_cont
              cDFCGI839 += ENT->Icm_base + fOUT_BASES
              cDFCGI864 += ENT->Icm_isen
              cDFCGI889 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "2603-2414-2415-2901-2902-2903-2904-2905-2906-2907-2908-2909-2912-2913-2914-2915-2916-2917-2919-2920-2921-2922-2923-2924-2925-2949-2663-2664"
              cDFCGI815 += ENT->Vlr_cont
              cDFCGI840 += ENT->Icm_base + fOUT_BASES
              cDFCGI865 += ENT->Icm_isen
              cDFCGI890 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case left(ENT->Cfop,3) $ "310-311-320-350-365"
              cDFCGI816 += ENT->Vlr_cont
              cDFCGI841 += ENT->Icm_base + fOUT_BASES
              cDFCGI866 += ENT->Icm_isen
              cDFCGI891 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "3120-2121-3122-3123-3124-3125-3126"
              cDFCGI816 += ENT->Vlr_cont
              cDFCGI841 += ENT->Icm_base + fOUT_BASES
              cDFCGI866 += ENT->Icm_isen
              cDFCGI891 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop == "3251"
              cDFCGI817 += ENT->Vlr_cont
              cDFCGI842 += ENT->Icm_base + fOUT_BASES
              cDFCGI867 += ENT->Icm_isen
              cDFCGI892 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop == "3301"
              cDFCGI818 += ENT->Vlr_cont
              cDFCGI843 += ENT->Icm_base + fOUT_BASES
              cDFCGI868 += ENT->Icm_isen
              cDFCGI893 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "3351-3352-3353-3354-3355-3356"
              cDFCGI819 += ENT->Vlr_cont
              cDFCGI844 += ENT->Icm_base + fOUT_BASES
              cDFCGI869 += ENT->Icm_isen
              cDFCGI894 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop $ "3551-3552-3553-3554-3555-3556"
              cDFCGI820 += ENT->Vlr_cont
              cDFCGI845 += ENT->Icm_base + fOUT_BASES
              cDFCGI870 += ENT->Icm_isen
              cDFCGI895 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop == "3127-3211"
              cDFCGI821 += ENT->Vlr_cont
              cDFCGI846 += ENT->Icm_base + fOUT_BASES
              cDFCGI871 += ENT->Icm_isen
              cDFCGI896 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

         case ENT->Cfop == "3930-3949"
              cDFCGI822 += ENT->Vlr_cont
              cDFCGI847 += ENT->Icm_base + fOUT_BASES
              cDFCGI872 += ENT->Icm_isen
              cDFCGI897 += ENT->Icm_out

              cDFCGI824 += ENT->Vlr_cont
              cDFCGI849 += ENT->Icm_base + fOUT_BASES
              cDFCGI874 += ENT->Icm_isen
              cDFCGI899 += ENT->Icm_out

      endcase

      ENT->(dbskip())
      fOUT_BASES := 0
   enddo

   // CONDICAO PRINCIPAL DE LOOP____________________________________________

   do while ! SAI->(eof()) .and. eval(bSAI_FILTRO)

		 qmensa("Aguarde! Somando Nota: "+SAI->Num_Nf +" / Serie : "+SAI->Serie + "Emiss:" +dtoc(SAI->Data_lanc) )
		 //qinkey(0)
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

            case left(SAI->Cfop,3) $ "510-511-512-540-520-521"
                 cDFCGI901 += SAI->Vlr_cont
                 cDFCGI926 += SAI->Icm_base + fOUT_BASES
                 cDFCGI951 += SAI->Icm_isen
                 cDFCGI976 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "5410-5411-5151-5152-5155-5156-5651-5652-5653-5654-5655-5656-5658-5659-5660-5661-5662"
                 cDFCGI901 += SAI->Vlr_cont
                 cDFCGI926 += SAI->Icm_base + fOUT_BASES
                 cDFCGI951 += SAI->Icm_isen
                 cDFCGI976 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "5251-5252-5253-5254-5255-5256-5257-5258-5153"
                 cDFCGI902 += SAI->Vlr_cont
                 cDFCGI927 += SAI->Icm_base + fOUT_BASES
                 cDFCGI952 += SAI->Icm_isen
                 cDFCGI977 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "5301-5302-5303-5304-5305-5306-5307"
                 cDFCGI903 += SAI->Vlr_cont
                 cDFCGI928 += SAI->Icm_base + fOUT_BASES
                 cDFCGI953 += SAI->Icm_isen
                 cDFCGI978 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out


            case SAI->Cfop $ "5351-5352-5353-5354-5355-5356-5357-5931-5932"
                 cDFCGI904 += SAI->Vlr_cont
                 cDFCGI929 += SAI->Icm_base + fOUT_BASES
                 cDFCGI954 += SAI->Icm_isen
                 cDFCGI979 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "5412-513-5551-5552-5553-5554-5555-5556-5557"
                 cDFCGI905 += SAI->Vlr_cont
                 cDFCGI930 += SAI->Icm_base + fOUT_BASES
                 cDFCGI955 += SAI->Icm_isen
                 cDFCGI980 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "5451-5501-5502-5503-5910-5911-5927-5928"
                 cDFCGI906 += SAI->Vlr_cont
                 cDFCGI931 += SAI->Icm_base + fOUT_BASES
                 cDFCGI956 += SAI->Icm_isen
                 cDFCGI981 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "5414-5415-5601-5602-5603-5901-5902-5903-5904-5905-5906-5907-5908-5909-5912-5913-5914-5915-5916-5917-5918-5919-5920-5921-5922-5923-5924-5925-5926-5929-5949-5657-5663-5664-5665-5666"
                 cDFCGI907 += SAI->Vlr_cont
                 cDFCGI932 += SAI->Icm_base + fOUT_BASES
                 cDFCGI957 += SAI->Icm_isen
                 cDFCGI982 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "6101-6102-6103-6104-6105-6106-6107-6108-6109-6110-6111-6112-6113-6114-6115-6116-6117-6118-6119-6120-6121-6122-6123-6124-6125-6401-6402-6403-6404-6405-6406-6407-6408-6409-6410-6411-6151-6152-6155-6156-6201-6202-6203-6204-6205-6206-6207-6208-6209-6210-6651-6652-6653-6654-6655-6656-6658-6659-6660-6661-6662"
                 cDFCGI908 += SAI->Vlr_cont
                 cDFCGI933 += SAI->Icm_base + fOUT_BASES
                 cDFCGI958 += SAI->Icm_isen
                 cDFCGI983 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "6251-6252-6253-6254-6255-6256-6257-6258-6153"
                 cDFCGI909 += SAI->Vlr_cont
                 cDFCGI934 += SAI->Icm_base + fOUT_BASES
                 cDFCGI959 += SAI->Icm_isen
                 cDFCGI984 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "6301-6302-6303-6304-6305-6306-6307"
                 cDFCGI910 += SAI->Vlr_cont
                 cDFCGI935 += SAI->Icm_base + fOUT_BASES
                 cDFCGI960 += SAI->Icm_isen
                 cDFCGI985 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "6351-6352-6353-6354-6355-6356-6357-6931-6932"
                 cDFCGI911 += SAI->Vlr_cont
                 cDFCGI936 += SAI->Icm_base + fOUT_BASES
                 cDFCGI961 += SAI->Icm_isen
                 cDFCGI986 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "6412-6413-6551-6552-6553-6554-6555-6556-6557"
                 cDFCGI912 += SAI->Vlr_cont
                 cDFCGI937 += SAI->Icm_base + fOUT_BASES
                 cDFCGI962 += SAI->Icm_isen
                 cDFCGI987 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "6501-6502-6503-6910-6911"
                 cDFCGI913 += SAI->Vlr_cont
                 cDFCGI938 += SAI->Icm_base + fOUT_BASES
                 cDFCGI963 += SAI->Icm_isen
                 cDFCGI988 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "6603-6901-6902-6903-6904-6905-6906-6907-6908-6909-6414-6415-6912-6913-6914-6915-6916-6917-6918-6919-6920-6921-6922-6923-6924-6925-6926-6927-6928-6929-6949-6657-6663-6664-6665-6666"
                 cDFCGI914 += SAI->Vlr_cont
                 cDFCGI939 += SAI->Icm_base + fOUT_BASES
                 cDFCGI964 += SAI->Icm_isen
                 cDFCGI989 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "7101-7102-7103-7104-7105-7106-7127-7501-7651-7652-7653-7654"
                 cDFCGI915 += SAI->Vlr_cont
                 cDFCGI940 += SAI->Icm_base + fOUT_BASES
                 cDFCGI965 += SAI->Icm_isen
                 cDFCGI990 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop $ "7201-7202-7203-7204-7205-7206-7207-7208-7209-7210-7211"
                 cDFCGI916 += SAI->Vlr_cont
                 cDFCGI941 += SAI->Icm_base + fOUT_BASES
                 cDFCGI966 += SAI->Icm_isen
                 cDFCGI991 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop == "7251"
                 cDFCGI917 += SAI->Vlr_cont
                 cDFCGI942 += SAI->Icm_base + fOUT_BASES
                 cDFCGI967 += SAI->Icm_isen
                 cDFCGI992 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop == "7301"
                 cDFCGI918 += SAI->Vlr_cont
                 cDFCGI943 += SAI->Icm_base + fOUT_BASES
                 cDFCGI968 += SAI->Icm_isen
                 cDFCGI993 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop == "7358"
                 cDFCGI919 += SAI->Vlr_cont
                 cDFCGI944 += SAI->Icm_base + fOUT_BASES
                 cDFCGI969 += SAI->Icm_isen
                 cDFCGI994 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop == "7551-7552-7553-7554-7555-7556-7930-7949"
                 cDFCGI920 += SAI->Vlr_cont
                 cDFCGI945 += SAI->Icm_base + fOUT_BASES
                 cDFCGI970 += SAI->Icm_isen
                 cDFCGI995 += SAI->Icm_out

                 cDFCGI924 += SAI->Vlr_cont
                 cDFCGI949 += SAI->Icm_base + fOUT_BASES
                 cDFCGI974 += SAI->Icm_isen
                 cDFCGI999 += SAI->Icm_out

            case SAI->Cfop == "571-572-573-574-575-576-577-578-579"
                 cDFCGI652 += SAI->Vlr_cont
                 cDFCGI660 += SAI->Vlr_cont

         endcase

      SAI->(dbskip())
      fOUT_BASES := 0
   enddo


   // CONDICAO PRINCIPAL DE LOOP____________________________________________

   if ! CONFIG->Tipo_est == "D"

   select OUTSAI
   OUTSAI->(dbgotop())

   select SAI
   SAI->(dbclearfilter())

   SAI->(dbSetFilter({|| alltrim(Filial) $ FILIAL->Codigo}, 'alltrim(Filial) $ FILIAL->Codigo'))

   SAI->(Dbgotop())

   set softseek on
   SAI->(dbseek(dtos(ctod("01/01/2015"))))
   set softseek off

   do while !SAI->(eof())


         if SAI->Data_lanc < ctod("01/01/2015")
            SAI->(dbskip())
            loop
         endif

         if SAI->Data_lanc > ctod("31/12/2015")
            SAI->(dbskip())
            loop
         endif

         if ! SAI->Cfop $ "5101-5102-6101-6102"
            SAI->(Dbskip())
            loop
         endif


         qmensa("Simples Nacional! Somando Nota: "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
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

            case month(SAI->Data_lanc) == 1
                 cDFCGI635 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

            case month(SAI->Data_lanc) == 2
                 cDFCGI636 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

            case month(SAI->Data_lanc) == 3
                 cDFCGI637 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

            case month(SAI->Data_lanc) == 4
                 cDFCGI638 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

            case month(SAI->Data_lanc) == 5
                 cDFCGI639 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

            case month(SAI->Data_lanc) == 6
                 cDFCGI640 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont


            case month(SAI->Data_lanc) == 7
                 cDFCGI641 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

            case month(SAI->Data_lanc) == 8
                 cDFCGI642 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

            case month(SAI->Data_lanc) == 9
                 cDFCGI643 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

            case month(SAI->Data_lanc) == 10
                 cDFCGI644 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

            case month(SAI->Data_lanc) == 11
                 cDFCGI645 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont


            case month(SAI->Data_lanc) == 12
                 cDFCGI646 += SAI->Vlr_cont
                 cDFCGI647 += SAI->Vlr_cont

         endcase



      SAI->(dbskip())
      fOUT_BASES := 0
   enddo
   endif

return


