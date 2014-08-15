/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: SEFIP DO FGTS EM DISQUETE
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JUNHO DE 1999
// OBS........:
// ALTERACOES.:

#include "rh.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1   := qlbloc("B480D","QBLOC.GLO")
private sBLOCO2   := qlbloc("B480E","QBLOC.GLO")
private sBLOCO3   := qlbloc("B480F","QBLOC.GLO")
private sBLOCO4   := qlbloc("B480G","QBLOC.GLO")
private sBLOCO5   := qlbloc("B480H","QBLOC.GLO")

private cINDICA   := " "     // indica se o recolhimento do fgts sera realizado no prazo ou em atrazo
private cINSS     := " "     // indica se o recolhimento do fgts sera realizado no prazo ou em atrazo
private cCATEGORIA:= "  "    // categoria do trabalhador pela tabela informada no lay-out
private aEDICAO   := {}      // vetor para entrada de dados
private aEMPR     := {}      // vetor de dados das empresas do QINST
private lCONF                // variavel  para confirmacoes
private nBUREAU              // numero da empresa bureau
private cMESANO              // mes e ano de competencia
private cANOMES              // auxiliar para busca em arquivos
private cREFGTS              // string de montagem de cada linha
private dQUITA               // data da quitacao da GRE
private nPROCESSO := 0       // numero do processo se houver
private cCOMP13   := 0       //Indica se Competencia 13
private nVARA     := 0
private dINICIO   := ctod("")// data de inicio do processo
private dFIM      := ctod("")// data de final do processo
private cANOBASE             // ano base
private cARQUIVO             // auxiliar para macro que trabalha com 2 arquivos
private nTIPO1EM  := 0       // numero de registros tipo 1 por empresa (tipo multiplo)
private nTIPO1GM  := 0       // numero de registros tipo 1 geral (tipo multiplo)
private nTIPO2EM  := 0       // numero de registros tipo 2 por empresa (tipo multiplo)
private nTIPO2GM  := 0       // numero de registros tipo 2 geral (tipo multiplo)
private nTIPO4EM  := 0       // numero de registros tipo 4 por empresa (tipo multiplo)
private nTIPO4GM  := 0       // numero de registros tipo 4 geral (tipo multiplo)
private nTIPO8GM  := 0       // numero de registros tipo 8 geral (tipo multiplo)
private nTTS13EM  := 0       // total de depositos sem 13. na empresa (tipo multiplo)
private nTTS13GM  := 0       // total de depositos sem 13. geral (tipo multiplo)
private nTTC13EM  := 0       // total de depositos com 13. na empresa (tipo multiplo)
private nTTC13GM  := 0       // total de depositos com 13. geral (tipo multiplo)
private nTIPO1EU  := 0       // numero de registros tipo 1 por empresa (tipo unico)
private nTIPO1GU  := 0       // numero de registros tipo 1 geral (tipo unico)
private nTIPO2EU  := 0       // numero de registros tipo 2 por empresa (tipo unico)
private nTIPO2GU  := 0       // numero de registros tipo 2 geral (tipo unico)
private nTIPO4EU  := 0       // numero de registros tipo 4 por empresa (tipo unico)
private nTIPO4GU  := 0       // numero de registros tipo 4 geral (tipo unico)
private nTIPO8GU  := 0       // numero de registros tipo 8 geral (tipo unico)
private nTTS13EU  := 0       // total de depositos sem 13. na empresa (tipo unico)
private nTTS13GU  := 0       // total de depositos sem 13. geral (tipo unico)
private nTTC13EU  := 0       // total de depositos com 13. na empresa (tipo unico)
private nTTC13GU  := 0       // total de depositos com 13. geral (tipo unico)
private fCLASSE              // CODIGO DA CLASSE (UNICA/MATRIZ/MULTIPLA)
private cCLASSE              // CONTEUDO QUE VAI NO STRING
private cCLASSE1             // CONTEUDO QUE VAI NO STRING
private nSAL_FAMILIA         // VALOR DO SALARIO FAMILIA DE CADA EMPREGADO SE HOUVER
private nSAL_MAT             // VALOR DO SALARIO MATERNIDADE

// ABRE ARQUIVO REFGTSM.DBF E REFGTSU.DBF E ZERA ____________________________

if ! quse(XDRV_RHX,"REFGTSM",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo REFGTSM.DBF !! Tente novamente.")
   return
endif

REFGTSM->(__dbzap())

if ! quse(XDRV_RHX,"REFGTSU",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo REFGTSU.DBF !! Tente novamente.")
   return
endif

REFGTSU->(__dbzap())

// ABRE ARQUIVO QINST.DBF, FILTRA E ALIMENTA ARQUIVO CFGDISQ.DBF ___________

if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")
   qmensa("N„o foi poss¡vel abrir arquivo QINST.DBF !! Tente novamente.")
   return
endif

QINST->(dbSetFilter({|| Empresa <> "000"},'Empresa <> "000"'))

QINST->(dbgotop())

qlbloc(5,0,"B480A","QBLOC.GLO")

do while ! QINST->(eof())

   if "RH" $ QINST->Sistemas

      qmensa("Processando Empresa: " + QINST->Razao)

      if ! quse(QINST->Drv_rh,"CONFIG",NIL,"R")
         qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
         return .F.
      endif

      CGM->(dbseek(QINST->Cgm))

      if CFGDISQ->(dbseek(QINST->Empresa))
         if CFGDISQ->(qrlock())
            replace CFGDISQ->Razao     with QINST->Razao
            replace CFGDISQ->Cgccei    with qtiraponto(QINST->Cgccpf)
         endif
      else
         if CFGDISQ->(qappend())
            replace CFGDISQ->Empresa   with QINST->Empresa
            replace CFGDISQ->Razao     with QINST->Razao
            replace CFGDISQ->Cgccei    with qtiraponto(QINST->Cgccpf)
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

//QINST->(dbclosearea())


CFGDISQ->(dbgotop())

CFGDISQ->(qview({{"Empresa/Emp"  ,1},;
                 {"Razao/Raz„o"  ,0},;
                 {"f480a()/Emite",0}},"P",;
                 {NIL,"f480b",NIL,NIL},;
                 NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))
return

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE EMITE REFGTS OU NAO _____________________________

function f480a
return(iif(CFGDISQ->Refgts=="S","SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f480b
   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   do case
      case cOPCAO $ "AC"
           i_edicao()
           select CFGDISQ
      case cOPCAO == "P"
           i_processa()
   endcase

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// EDICAO DOS DADOS INFORMATIVOS POR EMPRESA ________________________________

static function i_edicao
   local aEDICAO1 := {}

   qlbloc(9,7,"B480B","QBLOC.GLO")

   CFGDISQ->(qpublicfields())
   CFGDISQ->(qinitfields())
   CFGDISQ->(qcopyfields())

   qsay(10,21,CFGDISQ->Empresa)
   qsay(10,27,left(CFGDISQ->Razao,44))
   qsay(12,33,fCGCCEI)
   qsay(14,36,qabrev(fTIPO_INSC,"12",{"CGC","CEI"}))
   qsay(16,36,qabrev(fREFGTS,"SN",{"Sim","N„o"}))
   qsay(16,58,qabrev(fCLASSE,"123",{"Unica","Matriz/Filial","M£ltipla"}))
   qsay(18,18,fCONTATO)
   qsay(18,61,fTELEFONE)
   qsay(20,16,fTELEX)
   qsay(20,61,fFAX)

   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO1,{{ || qesco(-1,0,@fTIPO_INSC,sBLOCO5)},"TIPO_INSC"  })
   aadd(aEDICAO1,{{ || qesco(-1,0,@fREFGTS,XSN       )},"REFGTS"  })
   aadd(aEDICAO1,{{ || qesco(-1,0,@fCLASSE,SBLOCO2   )},"CLASSE"  })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCONTATO          )},"CONTATO" })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fTELEFONE         )},"TELEFONE"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fTELEX            )},"TELEX"   })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fFAX              )},"FAX"     })

   XNIVEL := 1
   XFLAG  := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
      eval ( aEDICAO1 [XNIVEL,1] )
      if eval ( bESCAPE ) ; QINST->(qreleasefields()) ; return ; endif
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

if cOPCAO <> "A"
   QINST->(dbclosearea())
Endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA 1 ___________________________________________

static function i_critica1 ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "REFGTS"
           if empty(fREFGTS)
              qmensa("Campo deve ser informado !","B")
              return .F.
           endif
           qrsay ( XNIVEL , qabrev(fREFGTS,"SN",{"Sim","N„o"}) )

      case cCAMPO == "CLASSE"
           qrsay ( XNIVEL , qabrev(fCLASSE,"123",{"Unica","Matriz/Filial","M£ltipla"}))

      case cCAMPO == "TIPO_INSC"
           qrsay ( XNIVEL , qabrev(fTIPO_INSC,"12",{"CGC","CEI"}) )

      case cCAMPO == "CONTATO"
           if empty(fCONTATO)
              qmensa("Campo CONTATO ‚ obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "TELEFONE"
           if empty(fTELEFONE)
              qmensa("Campo TELEFONE ‚ obrigat¢rio !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZACAO DO PROCESSO DE GERACAO DA REFGTS EM DISQUETE ______________

static function i_processa
   local aEDICAO2 := {}

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO2,{{ || view_disq(-1,0,@nBUREAU               )} , "BUREAU"   })
   aadd(aEDICAO2,{{ || NIL },NIL})    // razao da empresa
   aadd(aEDICAO2,{{ || qgetx(-1,0,@cMESANO   , "99/9999"     )} , "MESANO"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@dQUITA                    )} , "QUITA"   })
   aadd(aEDICAO2,{{ || qesco(-1,0,@cDRIVE    ,SBLOCO3        )} , "DRIVE"   })
   aadd(aEDICAO2,{{ || view_gfip(-1,0,@cCOD_REC              )} , "COD_REC" })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@cINDICA                   )} , "INDICA"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@nPROCESSO,"999999999999999")} , "PROCESSO"})
   aadd(aEDICAO2,{{ || qgetx(-1,0,@nVARA,"99999"             )} , "VARA"    })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@dINICIO,"@D"              )} , "INICIO"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@dFIM,"@D"                 )} , "FIM"     })
   aadd(aEDICAO2,{{ || lCONF := qconf("Confirma emiss„o da GFIP em Disquete ?") },NIL})

   do while .T.

      qlbloc(5,0,"B480C","QBLOC.GLO")
      XNIVEL   := 1
      XFLAG    := .T.
      nBUREAU  := space(3)
      cREFGTS  := ""
      cMESANO  := "  /    "
      dQUITA   := ctod("")
      cANOBASE := "    "
      cDRIVE   := ""
      cANOMES  := right(cANOBASE,4) + "01"
      cCOD_REC := "115"
      xFINAL   := 0
      cINDICA  := " "
      cINSS    := " "
      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO2)
         eval ( aEDICAO2 [XNIVEL,1] )
         if eval ( bESCAPE ) ; CFGDISQ->(qreleasefields()) ; return ; endif
         if ! i_critica2( aEDICAO2[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      iif ( lCONF == .t. , i_gravacao() , xFINAL := 1 )

      if xFINAL == 1; Exit; Endif

   enddo

return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA 2 ___________________________________________

static function i_critica2 ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "BUREAU"
           if CFGDISQ->(dbseek(nBUREAU:=strzero(val(nBUREAU),3)))
              qrsay(XNIVEL,nBUREAU)
              qrsay(++XNIVEL,left(CFGDISQ->Razao,30))
           else
              qmensa("Empresa n„o cadastrada !","B")
              return .F.
           endif
      case cCAMPO == "MESANO"
           if empty(qtiraponto(cMESANO))
              qmensa("Campo MES/ANO ‚ obrigat¢rio !","B")
              return .F.
           endif
           cANOBASE := right(cMESANO,4)
      case cCAMPO == "QUITA"
           //if empty(dQUITA)
           //   qmensa("Campo DATA DA QUITA€ŽO ‚ obrigat¢rio !","B")
           //   return .F.
           //endif
      case cCAMPO == "DRIVE"
           qrsay(XNIVEL,qabrev(cDRIVE,"ACFD",{"A:","C:","F:","Desktop"}))
      case cCAMPO == "COD_REC"
           if empty(cCOD_REC)
              qmensa("C¢digo do recolhimento ‚ obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "INDICA"
           cINSS := cINDICA
           if cINDICA $ "123 "
              if Left(cMESANO,2) == "13"
                 if cINDICA <> " "
                    qmensa("C¢digo do indicador de recolhimento deve estar em branco !","B")
                    return .F.
                 endif
              else
                 if cCOD_REC == "640"
                    if cINDICA <> "2"
                       qmensa("C¢digo do indicador de recolhimento deve ser do tipo (2) !","B")
                       return .F.
                    endif
                    return .T.
                 Endif
                 if cCOD_REC $ "904*905*906"
                    cINDICA := " "
                    cINSS := "1"

                    //if cINDICA <> " "
                    //   qmensa("C¢digo do indicador de recolhimento n„o deve ser Informado !","B")
                    //   return .F.
                    //endif
                    //return .T.
                 endif
                 if val(left(cMESANO,2)) < 10 .and. val(right(cMESANO,4)) < 1998 //    val(cMESANO) < 101998
                    if cINDICA <> "3"
                       qmensa("C¢digo do indicador de recolhimento deve ser igual a (3) !","B")
                       return .F.
                    Endif
                    Return .T.
                 else
                    if cCOD_REC $ "130*640*650*660*904"
                       if cINDICA <> "3"
                          qmensa("C¢digo do indicador de recolhimento deve ser igual (3) !","B")
                          return .F.
                       endif
                    endif
                    return .T.
                 endif
              endif
           else
              qmensa("C¢digo do indicador de recolhimento deve ser igual (1)(2)(3) !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE GRAVACAO __________________________________________

static function i_gravacao
   local nCONT , lCONF , cPATH1 , cPATH2 , cNOMARQ , lPRIM := .T. , cMULTIPLO := .F.
   local cAFAST , dAFAST , lACHOU , nSEQM := 1 , nSEQU := 1, nDECTER := 0

   local cCENT     // PROVISORIO, MUDAR DEPOIS DE ALGUMA FORMA

   cANOMES  := right(cMESANO,4) + left(cMESANO,2)

   cPATH1 := "\QSYS_G\QRH\E" + CFGDISQ->Empresa + "\"
   cPATH2 := "\QSYS_G\QCT\E" + CFGDISQ->Empresa + "\"

   if ! quse(cPATH2,"FILIAL",{"FI_CGCCP"})
      qmensa("N„o foi poss¡vel abrir arquivo FILIAL.DBF !! Tente novamente.")
      return .F.
   endif

   if ! quse(cPATH1,"CONFIG",NIL)
      qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
      CONFIG->(dbclosearea())
      FILIAL->(dbclosearea())
      return .F.
   endif

   //if ! FILIAL->(dbseek(CFGDISQ->Cgccei))
   //   qmensa("Filial n„o cadastrada no arquivo FILIAL.DBF !!","B")
   //   CONFIG->(dbclosearea())
   //   FILIAL->(dbclosearea())
   //   select CFGDISQ
   //   return .F.
   //endif                                                                                  // INCLUIR TELEX E FAX
                                                                                          // NO REGISTRO TIPO 0
///////////////////////////////////////////////////////////////////////////
// MONTA REGISTRO TIPO 0 _________________________________________________
   CGM->(dbseek(FILIAL->Cgm))

   nENDERECO := len(rtrim(FILIAL->Endereco))
   nNUMERO   := len(ltrim(str(FILIAL->Numero)))
   cENDERECO := rtrim(FILIAL->Endereco)
   cNUMERO   := ltrim(str(FILIAL->Numero))
   nRESTO    := 50 - (nENDERECO + nNUMERO + 14)
   cREFGTS :="00" + space(51) +"1"+ FILIAL->Tipo_insc + FILIAL->Cgccpf + Left(FILIAL->Razao,30) + CFGDISQ->Contato
 //  cREFGTS += left(FILIAL->Endereco,30) + " " + strzero(FILIAL->Numero,6) + " " + left(FILIAL->Compl,12) + Left(FILIAL->Bairro,20)
   cREFGTS += cENDERECO + " " + cNUMERO + " " + left(FILIAL->Compl,12) + space(nRESTO) + Left(FILIAL->Bairro,20)
   cREFGTS += FILIAL->Cep + left(CGM->Municipio,20) + CGM->Estado + right(CFGDISQ->Telefone,12) + Space(60)

   if cINDICA == " "
      cCOMP13 := "13"
   else
      cCOMP13 := "  "
   endif

   if cINDICA $ "12"
      cREFGTS += Right(cMESANO,4) + Left(cMESANO,2) + cCOD_REC + cINDICA + iif(cINDICA == " ","1"," ")//->Campo 18
   else
      cREFGTS += Right(cMESANO,4) + "13" + cCOD_REC + cINDICA + iif(cINDICA == " ","1"," ")//->Campo 18
   endif

   if cINDICA $ "2"  .and. dQUITA > ctod("07/"+cMESANO)
      cREFGTS += qtiraponto(dtoc(dQUITA))
   else
      cREFGTS += space(8)
   endif
   if cCOMP13 == "13"
      if ! empty(dQUITA)
         cINSS := "2"
      else
         cINSS := "1"
      endif
   endif
   cREFGTS += cINSS + iif(cINDICA $ "2 ",qtiraponto(dtoc(dQUITA)),space(8))
   cREFGTS += "       "  // indice de recolhimento em atraso ??
   cREFGTS += "1" //Tipo de Inscricao do Fornecedor de Folha de Pagamento
   cREFGTS += "00501162000103" // Inscricao do Fornecedor de Folha de Pagamento (CGC da QSYS Inform tica)
   cREFGTS += space(18) + "*"

   REFGTSM->(qappend())
   REFGTSM->Linha := cREFGTS
   
   FILIAL->(dbclosearea())
   CONFIG->(dbclosearea())
   cREFGTS := ""

   lPRIM := .F.

   // COLOCA ARQUIVO CFGDISQ.DBF EM ORDEM DE CGCCEI _________________________

   CFGDISQ->(dbsetorder(3))
   CFGDISQ->(dbgotop())

   do while ! CFGDISQ->(eof())
       if CFGDISQ->Refgts $ "N "
          CFGDISQ->(dbskip())
          loop
       endif

       cPATH1 := "\QSYS_G\QRH\E" + CFGDISQ->Empresa + "\"
       cPATH2 := "\QSYS_G\QCT\E" + CFGDISQ->Empresa + "\"
             
       if ! file(cPATH1 + "CONFIG.DBF")
          qmensa("Empresa sem arquivo CONFIG.DBF !!! Verifique com a Q-SYS...","B")
          CFGDISQ->(dbskip())
          loop
       endif

       if ! quse(cPATH1,"CONFIG",NIL,"R")
          qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
          return .F.
       endif

       qsay(18,30,CFGDISQ->Empresa)
       qsay(18,36,left(CFGDISQ->Razao,35))

       if ! quse(cPATH1,"FUN",NIL,"R")
          qmensa("N„o foi poss¡vel abrir arquivo FUN.DBF !! Tente novamente.")
          return .F.
       else
          qmensa("Aguarde...")
          FUN->(dbCreateIndex( cPATH1 + "TMP", "Filial+Pis_num", {|| Filial+Pis_num}, if( .F., .T., NIL ) ))
          qmensa()
       endif

       FUN->(dbSetFilter({|| ! empty(Filial)},'!empty(Filial)'))

       FUN->(dbgotop())
       
       if ! quse(cPATH1,"SITUA",{"SI_MATRI"},"R")
          qmensa("N„o foi poss¡vel abrir arquivo SITUA.DBF !! Tente novamente.")
          return .F.
       endif

       if ! quse(cPATH1,"LANC",{"LA_MATRI"},"R")
          qmensa("N„o foi poss¡vel abrir arquivo LANC.DBF !! Tente novamente.")
          return .F.
       endif
       
       SITUA->(dbSetFilter({|| Anomes == cANOMES},"Anomes == cANOMES"))
       LANC->(dbSetFilter({|| Anomes == cANOMES},"Anomes == cANOMES"))
       
       if ! quse(cPATH1,"BASE",{"BA_MATRI"},"R")
          qmensa("N„o foi poss¡vel abrir arquivo BASE.DBF !! Tente novamente.")
          return .F.
       endif

       if ! quse(cPATH2,"FILIAL",{"FI_CODIG"},"R")
          qmensa("N„o foi poss¡vel abrir arquivo BASE.DBF !! Tente novamente.")
          return .F.
       endif

       if ! quse(cPATH1,"GRPS",{"GR_CODIG"},"R")
          qmensa("N„o foi poss¡vel abrir arquivo GRPS.DBF !! Tente novamente.")
          return .F.
       else
          GRPS->(dbgotop())
       endif
              
       if ! quse(XDRV_RHX,"AFAST",{"AF_CODIG"},"R")
          qmensa("N„o foi poss¡vel abrir arquivo AFAST.DBF !! Tente novamente.")
          return .F.
       endif

       FILIAL->(dbgotop())


       do while ! FILIAL->(eof())
          FUN->(dbsetorder(3))

          if FUN->(dbseek(FILIAL->Codigo))

 ///////////////////////////////////////////////////////////////////////
 // MONTA REGISTRO TIPO 10 _____________________________________________

             CGM->(dbseek(FILIAL->Cgm))

             if FILIAL->Codigo == "0001"     //
                cCENT := "1"                 //   MUDAR DEPOIS DE
             else                            //   ALGUMA FORMA
                cCENT := "2"                 //   JA ARRUMEI ASS.: DUDU   (Seus Toperas)
             endif

             if CFGDISQ->CLASSE == "1"
                cCENT := "0"
             endif

             nSAL_FAMILIA := 0
             nSAL_MAT     := 0

             LANC->(dbgotop())
             GRPS->(dbseek(cANOMES))

             while !LANC->(eof())
                if LANC->Evento == "901" .and. LANC->Ambiente == "MS"
                   nSAL_FAMILIA += LANC->Valor
                endif

                if LANC->Evento == "161" .and. LANC->Ambiente == "MS"
                   nSAL_MAT += LANC->Valor
                endif

                LANC->(dbskip())
             enddo

             if cCOMP13 == "13"
                nSAL_FAMILIA := 0
                nSAL_MAT     := 0
             endif


             nENDERECO := 0
             nNUMERO   := 0
             cENDERECO := ""
             cNUMERO   := ""
             nRESTO    := 0

             nENDERECO := len(rtrim(FILIAL->Endereco))
             nNUMERO   := len(ltrim(str(FILIAL->Numero)))
             cENDERECO := rtrim(FILIAL->Endereco)
             cNUMERO   := ltrim(str(FILIAL->Numero))
             nRESTO    := 50 - (nENDERECO + nNUMERO + 14)

             cREFGTS := "10" + FILIAL->Tipo_insc + FILIAL->Cgccpf + replicate("0",36)
             cREFGTS += left(FILIAL->Razao,40) + cENDERECO + " " + cNUMERO + " " + left(FILIAL->Compl,12) + space(nRESTO)
             cREFGTS += Left(FILIAL->Bairro,20) + FILIAL->Cep + left(CGM->Municipio,20) + CGM->Estado +  CFGDISQ->Telefone
             cREFGTS += iif(cCOMP13 == "13","N",CFGDISQ->Refgts) + strzero(val(qtiraponto(CONFIG->Cnae)),7) + "N" + iif(CONFIG->Gr_Simples =="S","00",strzero(val(qtiraponto(GRPS->Cod_sat)),2)) + cCENT
             cREFGTS += iif(CONFIG->Gr_Simples="S","2","1") + GRPS->Cod_fpas + GRPS->Cod_terc + GRPS->Cod_gps + strzero(val(qtiraponto(str(GRPS->Perc_filan,6,2))),5)
             cREFGTS += iif(left(cCOMP13,2)<>"13",strzero(val(qtiraponto(str(nSAL_FAMILIA,15,2))),15),replicate("0",15))
             cREFGTS += strzero(val(qtiraponto(str(nSAL_MAT,15,2))),15)+replicate("0",30) + space(16) + replicate("0",45) + space(4)
             cREFGTS += "*"
             nSAL_FAMILIA := 0
             nSAL_MAT     := 0
             REFGTSM->(qappend())
             REFGTSM->Linha := cREFGTS

             cREFGTS := ""
          else
             FILIAL->(dbskip())
             loop
          endif
             
          lACHOU := .F.

          do while ! FUN->(eof()) .and. FUN->Filial == FILIAL->Codigo
             SITUA->(dbseek(FUN->Matricula))

             if SITUA->Situacao $ " H" .or.;
                (SITUA->Categoria == "9" .and. SITUA->Vinculo == "H") .or. ;
                FUN->Data_adm > qfimmes(XDATASYS) .or. ;
                SITUA->Vinculo == "G"

                lACHOU := .F.

             else
                lACHOU := .T.
             endif

             if ! lACHOU
                FUN->(dbskip())
                loop
             endif

             qsay(20,22,FUN->Matricula)
             qsay(20,31,left(FUN->Nome,35))


 //////////////////////////////////////////////////////////////////////
 // MONTA REGISTROS TIPO 12 ___________________________________________

             if cCOD_REC $ "650*660*904"

                cREFGTS := "12" + FILIAL->Tipo_insc + FILIAL->Cgccpf + repl("0",34)

//              cREFGTS += strzero(nDED_LIC_MAT,17) + repl("0",17) + " " + repl("0",17)  // como deduzir 13o. sal. maternidade??

                cREFGTS += repl("0",17) + repl("0",17) + " " + repl("0",17)
                cREFGTS += repl("0",17) + space(70) + str(nPROCESSO,15) + str(nVARA,5) + qtiraponto(qanomes(dINICIO)) + qtiraponto(qanomes(dFIM))
                cREFGTS += replicate("0",17) + space(12) + replicate("0",17) + replicate("0",17)  // verificar GRPS
                cREFGTS += replicate("0",17) + replicate("0",17) + space(12) + space(28) + "*"

                REFGTSM->(qappend())
                REFGTSM->Linha := cREFGTS

                cREFGTS := ""

             endif
////////////////////////////////////////////////////////////////////
//MONTA REGISTROS TIPO 14 ____________________________________________
              do case
                case SITUA->Vinculo == "F"
                     cCATEGORIA := "13"

                case SITUA->Vinculo == "F"
                     cCATEGORIA := "13"

                case SITUA->Vinculo == "G"
                     cCATEGORIA := "02"
                case SITUA->Vinculo == "O"
                     cCATEGORIA := "07"
                case SITUA->Vinculo == "M"
                     cCATEGORIA := "05"
                case SITUA->Vinculo == "N"
                     cCATEGORIA := "11"
                case SITUA->Vinculo $ "I*J*K*L"
                     cCATEGORIA := "04"
                otherwise
                     cCATEGORIA := "01"
             endcase

             if left(SITUA->CBO,4) == "5121"
                cCATEGORIA := "06"
             endif

//             cREFGTS := "14" + FILIAL->Tipo_insc + FILIAL->Cgccpf + replicate("0",36)
//             cREFGTS += FUN->Pis_num + qtiraponto(dtoc(FUN->Data_adm)) + cCATEGORIA
//             cREFGTS += FUN->Nome + space(40)
//             cREFGTS += iif(cCATEGORIA $ "01*02*03*04*06",strzero(val(FUN->Cp_num),7)  ,space(7))
//             cREFGTS += iif(cCATEGORIA $ "01*02*03*04",strzero(val(qtiraponto(FUN->Cp_serie)),5),space(5))
//             cREFGTS += FUN->Endereco + space(5) + FUN->Bairro + FUN->Cep
//             CGM->(dbseek(FUN->Resid_cgm))
//             cREFGTS += left(CGM->Municipio,20) + CGM->Estado
//             cREFGTS += space(103) + "*"

//             REFGTSM->(qappend())
//             REFGTSM->Linha := cREFGTS

//             cREFGTS := ""

 ////////////////////////////////////////////////////////////////////
 //MONTA REGISTROS TIPO 30 ____________________________________________


             cREFGTS := "30" + FILIAL->Tipo_insc + FILIAL->Cgccpf
             cREFGTS += iif(cCOD_REC $ "130*150*155*608",FILIAL->Tipo_insc," ")
             cREFGTS += iif(cCOD_REC $ "130*150*155*608",FILIAL->Cgccpf,space(14))
             cREFGTS += FUN->Pis_num + qtiraponto(dtoc(FUN->Data_adm)) + cCATEGORIA
             cREFGTS += FUN->Nome +iif(cCATEGORIA != "13", iif(cCATEGORIA == "06",space(11),"00000"+FUN->Matricula),space(11))
             cREFGTS += iif(cCATEGORIA $ "01*02*03*04*06",strzero(val(FUN->Cp_num),7)  ,space(7))
             cREFGTS += iif(cCATEGORIA $ "01*02*03*04*06",strzero(val(qtiraponto(FUN->Cp_serie)),5),space(5))
             cREFGTS += iif(cCATEGORIA $ "01*03*04*05*06",qtiraponto(dtoc(FUN->Data_adm)),space(8))
             cREFGTS += iif(cCATEGORIA $ "01*02*03*04*05*06*12",qtiraponto(dtoc(FUN->Data_nasc)),space(8))
             cREFGTS += "0"+left(qtiraponto(SITUA->Cbo),4)


             BASE->(dbseek(FUN->Matricula+cANOMES))

             if cCATEGORIA == "11"
                 LANC->(dbgotop())
                 LANC->(dbseek(cANOMES+FUN->Matricula+"MS"+"105"))  // Evento Pro-Labore
                 nCAM_15 :=  strzero(val(qtiraponto(str(LANC->Valor,15,2))),15)
             elseif cCATEGORIA == "13"
                 nCAM_15 :=  strzero(val(qtiraponto(str(BASE->B_Inssms,15,2))),15)
             else
                if empty(SITUA->Codsaqfgts)
                   nCAM_15 := strzero(val(qtiraponto(str(BASE->B_fgtsms+BASE->B_fgtsfr,15,2))),15) // remuneracao sem 13o.
                else
                   nCAM_15 := strzero(val(qtiraponto(str(BASE->B_Sfipms,15,2))),15) // remuneracao sem 13o.
                endif
             endif

             if empty(SITUA->Codsaqfgts)
                nCAM_16 := strzero(val(qtiraponto(str(BASE->B_fgtsdt+BASE->B_fgts13,15,2))),15) // remuneracao sobre 13o.
             else
                nCAM_16 := strzero(val(qtiraponto(str(BASE->B_Sfipdt,15,2))),15) // remuneracao sobre 13o.
             endif

             if left(cCOMP13,2) == "13" // competencia 13 nao informa nenhum valor
                cREFGTS += replicate("0",30)
             else
                if cCATEGORIA $ "05*11*13*14*15*16"
                   cREFGTS += nCAM_15 + replicate("0",15)
                else
                   if cCATEGORIA $ "01*02*03*04*12*06"
                      cREFGTS += nCAM_15 + nCAM_16
                   else
                      cREFGTS += replicate("0",30)
                   endif
                endif
             endif

             cREFGTS += "  " +iif(!empty(FUN->Especifica),iif(FUN->Especifica == "0","  ","0"+FUN->Especifica),"  ") + iif(LANC->(dbseek(cANOMES+FUN->Matricula+"MS103")).or.FUN->Especifica=="5",strzero(val(qtiraponto(str(BASE->V_INSSMS+BASE->V_INSSFR,15,2))),15),replicate("0",15))
             cREFGTS += iif(left(cMESANO,2) == "13",qtiraponto(strzero(BASE->Prov_dt,15)),replicate("0",15) )
             cREFGTS += iif(left(cCOMP13,2) == "13",strzero(val(qtiraponto(str(BASE->Prov_dt ,15,2))),15),iif(!empty(SITUA->Af_cod) .and. SITUA->Af_cod <> "FR",strzero(val(qtiraponto(str(BASE->B_inssdt+BASE->B_inss13,15,2))),15),replicate("0",15) ))// remuneracao sobre 13o. INSS )
             cREFGTS += iif(left(cMESANO,2) == "13",strzero(val(qtiraponto(str(BASE->B_INSS13,15,2))),15),replicate("0",15) )
             cREFGTS += space(98) + "*"

             REFGTSM->(qappend())
             REFGTSM->Linha := cREFGTS

             cREFGTS := ""


 ////////////////////////////////////////////////////////////////////
 //MONTA REGISTROS TIPO 32 ____________________________________________
             if cCOMP13 != "13"
             if left(cMESANO,2) <> "13" .and. cCATEGORIA $ "01*06*02*03*04*05*11*12"  .and. !empty(SITUA->Af_cod) //.and. SITUA->Af_cod <> "FR"
                LANC->(dbgotop())
                if SITUA->Af_cod == "FR" .and. ! LANC->(dbseek(cANOMES+FUN->Matricula+"MS"+"103"))
                   FUN->(dbskip())
                   loop
                endif
                cREFGTS := "32" + FILIAL->Tipo_insc + FILIAL->Cgccpf
                cREFGTS += iif(cCOD_REC $ "130*150*155*608",FILIAL->Tipo_insc," ")
                cREFGTS += iif(cCOD_REC $ "130*150*155*608",FILIAL->Cgccpf,space(14))
                cREFGTS += FUN->Pis_num + iif( cCATEGORIA $ "01*06*03*04*05*12*13" , qtiraponto(dtoc(FUN->Data_adm)),space(8))
                do case
                   case empty(SITUA->Af_cod)
                        cMOVIM := "  "
                   case SITUA->Af_cod == "25"
                        cMOVIM := " H"
                   case SITUA->Af_cod == "22"
                        cMOVIM := "I1"
                   case SITUA->Af_cod == "32"
                        cMOVIM := "I3"
                   case SITUA->Af_cod == "21"
                        cMOVIM := " J"
                   case SITUA->Af_cod == "04"
                        cMOVIM := "P1"
                   case SITUA->Af_cod == "05"
                        cMOVIM := "O1"
                   case SITUA->Af_cod == "06"
                        cMOVIM := " R"
                   case SITUA->Af_cod $ "10*31"
                        cMOVIM := " L"
                   case SITUA->Af_cod == "03"
                        if month(SITUA->Af_ret) == val(left(cMESANO,2)) .and. year(SITUA->Af_ret) == val(right(cMESANO,4))
                            cMOVIM := "Z1"
                        else
                            cMOVIM := "Q1"
                        endif
                   case SITUA->Af_cod == "40*42"
                        cMOVIM := " N"
                   case SITUA->Af_Cod == "FR"
                        LANC->(dbgotop())
                        if LANC->(dbseek(cANOMES+FUN->Matricula+"MS"+"103"))  // Evento Maternidade
                           cMOVIM := "Z1"
                        endif
                   otherwise
                        cMOVIM := " H"
                endcase

                cREFGTS += cCATEGORIA + FUN->Nome  + cMOVIM + iif(month(SITUA->Af_ret) == val(left(cMESANO,2)) .and. year(SITUA->Af_ret) == val(right(cMESANO,4)),qtiraponto(dtoc(SITUA->Af_ret)), qtiraponto(dtoc(iif(SITUA->Af_cod $ "03*04*05*41",SITUA->Af_ini-1,SITUA->Af_ini))))

               if (cMOVIM <> " I" .or. cMOVIM <> " L") .and. left(cMESANO,2) == "13"
                  cREFGTS += " "
               else
                 if cMOVIM == "I1" .or. cMOVIM == "I3" .or. cMOVIM == " L"
                      cREFGTS +=  "S"  //iif(!empty(SITUA->Codsaqfgts),"S","N")
                 else
                       cREFGTS += " "
                 endif
               endif

                cREFGTS += space(225) + "*"

                REFGTSM->(qappend())
                REFGTSM->Linha := cREFGTS
                cREFGTS := ""

                if cMOVIM == "Z1"
                   cREFGTS := "32" + FILIAL->Tipo_insc + FILIAL->Cgccpf
                   cREFGTS += iif(cCOD_REC $ "130*150*155*608",FILIAL->Tipo_insc," ")
                   cREFGTS += iif(cCOD_REC $ "130*150*155*608",FILIAL->Cgccpf,space(14))
                   cREFGTS += FUN->Pis_num + iif( cCATEGORIA $ "01*06*03*04*05*12*13" , qtiraponto(dtoc(FUN->Data_adm)),space(8))
                   cREFGTS += cCATEGORIA + FUN->Nome  + "Q1" + qtiraponto(dtoc(SITUA->Af_ini))
                   cREFGTS += space(226) + "*"

                   REFGTSM->(qappend())
                   REFGTSM->Linha := cREFGTS
                   cREFGTS := ""
                endif
             endif
             Endif
             FUN->(dbskip())

          enddo

          FILIAL->(dbskip())

       enddo

       qmensa()

       CONFIG->(dbclosearea())

       AFAST->(dbclosearea())

       FUN->(dbclosearea())

       SITUA->(dbclosearea())

       LANC->(dbclosearea())

       BASE->(dbclosearea())

       GRPS->(dbclosearea())

       FILIAL->(dbclosearea())

       CFGDISQ->(dbskip())

       lACHOU := .F.

   enddo

// MONTA REGISTRO TIPO 90 PARA MULTIPLA ___________________________________

   cREFGTS := "90" + Replicate("9",51) + Space(306) + "*"

   REFGTSM->(qappend())
   REFGTSM->Linha := cREFGTS
   cREFGTS := ""


//////////////////////////////////////////////////////////////////////////
// GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")

   do case
      case cDRIVE == "A"
           cDRIVE := "A:"

      case cDRIVE == "C"
           cDRIVE := "C:\"

      case cDRIVE == "F"
           cDRIVE := "F:\"

      case cDRIVE == "D"
           cDRIVE := "C:\Docume~1\AllUse~1\Desktop\"
   endcase



   cNOMARQ := cDRIVE + "SEFIP.RE"

   REFGTSM->(dbgotop())

   REFGTSM->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   qmensa()

   select CFGDISQ

   CFGDISQ->(dbgotop())

   if REFGTSM->(qflock())
      REFGTSM->(__dbzap())
   endif
return
