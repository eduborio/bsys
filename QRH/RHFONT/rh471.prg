////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RAIS EM DISQUETE
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1996
// OBS........:
// ALTERACOES.:

#include "rh.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO2   := qlbloc("B470E","QBLOC.GLO")
private sBLOCO3   := qlbloc("B470F","QBLOC.GLO")
private sBLOCO4   := qlbloc("B470G","QBLOC.GLO")
private sBLOCO5   := qlbloc("B470H","QBLOC.GLO")
private sBLOCO6   := qlbloc("B470I","QBLOC.GLO")

private cANOMES                  // ano e mes de competencia
private aEDICAO   := {}          // vetor para entrada de dados
private aEMPR     := {}          // vetor de dados das empresas do QINST
private lCONF                    // variavel  para confirmacoes
private cANOBASE                 // ano base para emissao
private cDRIVE                   // drive para gravacao
private cCORRESP                 // tipo de correspondencia
private cRESP     := space(40)   // nome do responsavel
private cENDRESP  := space(40)   // endereco do responsavel
private cCOMPL    := space(21)   // complemento do endereco
private nNUMERO   := 0           // numero do endereco
private cBAIRRO   := space(19)   // bairro do responsavel
private cCGM                     // municipio do responsavel
private cTP_ENT                  // tipo de entrega
private cTP_DEC                  // tipo de declaracao
private dDT_RET:= ctod("00/00/00") // data da retificacao
private cRAIS                    // string de montagem de cada linha
private nTOTFUN                  // total de funcionarios
private nTOTEMP                  // total de empresas
private nVALOR                   // acumulador de proventos incidentes p/ RAIS
private cNACIONAL                // nacionalidade
private cCGCCEI                  // ultimo CGC/CEI do arquivo
private cFONE  := space(10)      // fone/fax do responsavel

// ABRE ARQUIVO RAIS.DBF E ZERA _____________________________________________

if ! quse(XDRV_RH,"RAIS",NIL,"E")
   qmensa("NÑo foi poss°vel abrir arquivo RAIS.DBF !! Tente novamente.")
   return
endif

// ABRE ARQUIVO QINST.DBF, FILTRA E ALIMENTA ARQUIVO CFGDISQ.DBF ____________

if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")
   qmensa("NÑo foi poss°vel abrir arquivo QINST.DBF !! Tente novamente.")
   return
endif

QINST->(dbSetFilter({|| Empresa <> "000"}, 'Empresa <> "000"'))

QINST->(dbgotop())

qlbloc(5,0,"B470A","QBLOC.GLO")

do while ! QINST->(eof())

   qgirabarra()

   if "RH" $ QINST->Sistemas

      qmensa("Processando Empresa: " + QINST->Razao)

      if ! quse(QINST->Drv_rh,"CONFIG",NIL,"R")
         qmensa("NÑo foi poss°vel abrir arquivo CONFIG.DBF !! Tente novamente.")
         return .F.
      endif

      CGM->(dbseek(QINST->Cgm))

      if CFGDISQ->(dbseek(QINST->Empresa))
         if CFGDISQ->(qrlock())
            replace CFGDISQ->Razao      with QINST->Razao
            replace CFGDISQ->Cgccei     with qtiraponto(QINST->Cgccpf)
         endif
      else
         if CFGDISQ->(qappend())
            replace CFGDISQ->Empresa    with QINST->Empresa
            replace CFGDISQ->Razao      with QINST->Razao
            replace CFGDISQ->Cgccei     with qtiraponto(QINST->Cgccpf)
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

CFGDISQ->(dbgotop())

CFGDISQ->(qview({{"Empresa/Emp"  ,1},;
                 {"Razao/RazÑo"  ,0},;
                 {"f471a()/Emite",0}},"P",;
                 {NIL,"f471b",NIL,NIL},;
                  NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))
return

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE EMITE RAIS OU NAO _______________________________

function f471a
return(iif(CFGDISQ->Rais=="S","SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f471b
   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   do case
      case cOPCAO $ "AC"
           i_edicao()
           select CFGDISQ
      case cOPCAO == "P"
           alert("AtenáÑo!, ao preencher os campos a seguir.;;Caracteres nÑo permitidos pelo sistema da RAIS <+-.*^#@&$> nem acentuaáÑo!;;Qualquer duvida entrar em contato com a QSYS INFORMATICA.",{"OK"})
           i_processa()
   endcase

   setcursor(nCURSOR)

return ""
   
/////////////////////////////////////////////////////////////////////////////
// EDICAO DOS DADOS INFORMATIVOS POR EMPRESA ________________________________

static function i_edicao
   local aEDICAO1 := {}

   qlbloc(9,7,"B470B","QBLOC.GLO")

   CFGDISQ->(qpublicfields())
   CFGDISQ->(qinitfields())
   CFGDISQ->(qcopyfields())

   qsay(10,21,CFGDISQ->Empresa)
   qsay(10,27,left(CFGDISQ->Razao,44))
   qsay(12,33,fCGCCEI)

   XNIVEL := 1
   qrsay(XNIVEL++,qabrev(fRAIS,"SN",{"Sim","NÑo"}))
        
   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO1,{{ || qesco(-1,0,@fRAIS,XSN)},"RAIS"})

   XNIVEL := 1
   XFLAG  := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
      eval ( aEDICAO1 [XNIVEL,1] )
      if eval ( bESCAPE ) ; CFGDISQ->(qreleasefields()) ; return ; endif
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

   if fRAIS == "N"
      return
   endif

   // EDICAO DAS FILIAIS ____________________________________________________
   
   cPATH := "\QSYS_G\QCT\E" + CFGDISQ->Empresa + "\"
   
   // ABRE ARQUIVO DE FILIAIS _______________________________________________

   if ! quse(cPATH,"FILIAL",{"FI_CGCCP"})
      qmensa("NÑo foi poss°vel abrir arquivo FILIAL.DBF !! Tente novamente.")
      return .F.
   endif

   FILIAL->(qview({{"left(Razao,30)/Filial",1},;
                   {"Codigo/C¢digo"        ,2}},"16002379",;
                   {NIL,"f471c",NIL,NIL},;
                    NIL,"<ESC> Encerra / <A>ltera / <C>onsulta"))

   FILIAL->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// EDICAO DADOS DAS FILIAIS _________________________________________________

function f471c
   local aEDICAO2 := {}

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   qlbloc(7,7,"B470J","QBLOC.GLO")

   FILIAL->(qpublicfields())
   FILIAL->(qinitfields())
   FILIAL->(qcopyfields())

   if(empty(fMUDOU_INSC),fMUDOU_INSC := "N",fMUDOU_INSC)
   if(empty(fMUDOU_END ),fMUDOU_END  := "N",fMUDOU_END )

   XNIVEL := 1

   qsay(08,21,FILIAL->Codigo)
   qsay(08,28,left(FILIAL->Razao,43))
   qsay(10,28,qabrev(fTIPO_INSC,"12",{"CGC","CEI"}))
   qsay(10,57,fCGCCPF)
   qsay(12,26,qabrev(fMUDOU_INSC,"SN",{"Sim","NÑo"}))
   qsay(12,44,qabrev(fCAUSA_ALTE,"123456",{"FusÑo","IncorporaáÑo","CisÑo","Mudanáa de CEI para CGC","Encerramento das Atividades","CEI vinculada ao CGC"}))
   qsay(14,29,fINSC_ANTE)
   qsay(14,68,qabrev(fMUDOU_END,"SN",{"Sim","NÑo"}))
   qsay(16,37,fMES_DTBASE)
   qsay(16,66,fNATU_JURID)
   qsay(18,27,qabrev(fPART_PAT,"SN",{"Sim","Nao"}))
   qsay(18,60,qabrev(fMICRO_EMP,"SN",{"Sim","Nao"}))
   qsay(20,35,qabrev(fPEQ_PORTE,"SN",{"Sim","Nao"}))
   qsay(20,68,qabrev(fOP_SIMPLES,"SN",{"Sim","Nao"}))
   qsay(22,34,fPROPRIET)
        
   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return "" ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO2,{{ || qesco(-1,0,@fMUDOU_INSC,XSN         )} , "MUDOU_INSC" })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCAUSA_ALTE,SBLOCO2     )} , "CAUSA_ALTE" })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fINSC_ANTE              )} , "INSC_ANTE"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fMUDOU_END ,XSN         )} , "MUDOU_END"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fMES_DTBASE,"99"        )} , "MES_DTBASE" })
   aadd(aEDICAO2,{{ || view_natu(-1,0,@fNATU_JURID,"999-9" )} , "NATU_JURID" })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fPART_PAT,XSN           )} , "PART_PAT"   })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fMICRO_EMP,XSN          )} , "MICRO_EMP"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fPEQ_PORTE,XSN          )} , "PEQ_PORTE"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fOP_SIMPLES,XSN         )} , "OP_SIMPLES" })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fPROPRIET  ,"99"        )} , "PROPRIET"   })
   
   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.
   
   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO2)
      eval ( aEDICAO2 [XNIVEL,1] )
      if eval ( bESCAPE ) ; FILIAL->(qreleasefields()) ; return "EXIT" ; endif
      if ! i_critica1( aEDICAO2[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO DO CFGDISQ ___________________________________________________

   if cOPCAO == "A"
      if FILIAL->(qrlock())
         FILIAL->(qreplacefields())
         FILIAL->(qunlock())
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
      case cCAMPO == "MUDOU_INSC"
           qrsay(XNIVEL , qabrev(fMUDOU_INSC,"SN",{"Sim","NÑo"}))
           if fMUDOU_INSC == "N"
              qsay(12,44,space(27))
              qsay(14,29,space(14))
              fCAUSA_ALTE := space(1)
              fINSC_ANTE  := space(14)
              XNIVEL+=2
           endif
      case cCAMPO == "CAUSA_ALTE"
           if fMUDOU_INSC == "S"
              qrsay(XNIVEL , qabrev(fCAUSA_ALTE,"123456",{"FusÑo","IncorporaáÑo","CisÑo","Mudanáa de CEI para CGC","Encerramento das Atividades","CEI vinculada ao CGC"}))
           endif
      case cCAMPO == "MUDOU_END"
           qrsay(XNIVEL , qabrev(fMUDOU_END,"SN",{"Sim","NÑo"}))
      case cCAMPO == "MES_DTBASE"
           if empty(qtiraponto(fMES_DTBASE))
              qmensa("Campo MES DA DATA BASE Ç obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "PROPRIET"
           qrsay(XNIVEL , fPROPRIET := strzero(val(fPROPRIET),2))
      case cCAMPO == "NATU_JURID"
           if empty(fNATU_JURID)
              qmensa("Campo NATUREZA JURIDICA Ç obrigat¢rio !  Pressione <F9>","B")
              return .F.
           endif
           if ! NAT_JUR->(dbseek(fNATU_JURID))
              qmensa("Campo NATUREZA JURIDICA n∆o encontrado!  Pressione <F9>","B")
              return .F.
           Endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZACAO DO PROCESSO DE GERACAO DA RAIS EM DISQUETE ________________

static function i_processa
   local aEDICAO3 := {}

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO3,{{ || qgetx(-1,0,@cANOBASE ,"9999"          )} , "ANOBASE" })
   aadd(aEDICAO3,{{ || qesco(-1,0,@cDRIVE   ,SBLOCO3         )} , "DRIVE"   })
   aadd(aEDICAO3,{{ || qesco(-1,0,@cCORRESP ,SBLOCO4         )} , "CORRESP" })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@cRESP    ,"@!"            )} , "RESP"    })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@cENDRESP ,"@!"            )} , "ENDRESP" })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@nNUMERO ,"99999"          )} , "NUMERO"  })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@cCOMPL ,"@!"              )} , "COMPL"   })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@cBAIRRO  ,"@!"            )} , "BAIRRO"  })
   aadd(aEDICAO3,{{ || view_cgm(-1,0,@cCGM                   )} , "CGM"     })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@cFONE,"@r 9999999999"   )} , "FONE"    })
   aadd(aEDICAO3,{{ || qesco(-1,0,@cTP_ENT  ,SBLOCO5         )} , "TP_ENT"  })
   aadd(aEDICAO3,{{ || qesco(-1,0,@cTP_DEC  ,SBLOCO6         )} , "TP_DEC"  })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@dDT_RET  ,"@d"            )} , "DT_RET"  })
   aadd(aEDICAO3,{{ || lCONF := qconf("Confirma emissÑo da RAIS ?") },NIL})

   do while .T.

      qlbloc(5,0,"B470C","QBLOC.GLO")
      XNIVEL   := 1
      XFLAG    := .T.
      cRAIS    := ""
      cANOBASE := "    "
      cDRIVE   := "A"
      cCORRESP := "1"
      cRESP    := space(40)
      cENDRESP := space(40)
      nNUMERO  := 0
      cCOMPL   := space(21)
      cBAIRRO  := space(19)
      cCGM     := space(6)
      cTP_ENT  := "2"
      cTP_DEC  := "1"
      dDT_RET  := ctod("00/00/00")
//      cANOMES  := right(cANOBASE,4) + "01"
      cANOMES  := cANOBASE + "01"
      cFONE    := space(10)

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO3)
         eval ( aEDICAO3 [XNIVEL,1] )
         if eval ( bESCAPE ) ; CFGDISQ->(qreleasefields()) ; return ; endif
         if ! i_critica2( aEDICAO3[XNIVEL,2] ) ; loop ; endif
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
      case cCAMPO == "ANOBASE"
           if empty(qtiraponto(cANOBASE))
              qmensa("Campo ANO BASE Ç obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "DRIVE"
           qrsay(XNIVEL,qabrev(cDRIVE,"AB",{"A:","B:"}))
      case cCAMPO == "CORRESP"
           qrsay(XNIVEL,qabrev(cCORRESP,"12",{"Recibo para o Respons†vel","Recibo para o Estabelecimento"}))
           if cCORRESP == "2"
              XNIVEL += 5
           endif
      case cCAMPO == "RESP"
           if empty(cRESP)
              qmensa("Campo RESPONSAVEL Ç obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "ENDRESP"
           if empty(cENDRESP)
              qmensa("Campo ENDEREÄO DO RESPONSAVEL Ç obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "BAIRRO"
           if empty(cBAIRRO)
              qmensa("Campo BAIRRO DO RESPONSAVEL Ç obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "CGM"
           if empty(cCGM)
              qmensa("Campo CGM DO MUNICIPIO DO RESPONSAVEL Ç obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "TP_ENT"
           qrsay(XNIVEL,qabrev(cTP_ENT,"12",{"Antecipada","NÑo Antecipada"}))
      case cCAMPO == "TP_DEC"
           qrsay(XNIVEL,qabrev(cTP_DEC,"12",{"Original","Retificada"}))
           if cTP_DEC == "1"
              XNIVEL++
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE GRAVACAO __________________________________________

static function i_gravacao
   local nCONT , lCONF , nSEQ := 1 , cPATH1 , cPATH2, cNOMARQ , nTOTEMP := 0
   local nNEG , cTIPO , cAFAST , nCONTA , cTROCADO , nTOTFUN := 0
   local nVDT_ADT := cMDT_ADT := nVDT_FIM := 0 , lPRIM := .T.

   RAIS->(__dbzap())

//   cANOMES  := right(cANOBASE,4) + "01"
   cANOMES  := cANOBASE + "01"
   
   // COLOCA ARQUIVO CFGDISQ.DBF EM ORDEM DE CGCCEI _________________________

   CFGDISQ->(dbsetorder(2))
   CFGDISQ->(dbgotop())

   do while ! CFGDISQ->(eof())
       qgirabarra()

       if CFGDISQ->Rais $ "N "
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
          qmensa("NÑo foi poss°vel abrir arquivo CONFIG.DBF !! Tente novamente.")
          return .F.
       endif

       qsay(19,28,CFGDISQ->Empresa)
       qsay(19,34,left(CFGDISQ->Razao,38))

       if ! quse(cPATH1,"FUN",NIL,"R")
          qmensa("NÑo foi poss°vel abrir arquivo FUN.DBF !! Tente novamente.")
          return .F.
       else
          qmensa("Aguarde...")
          FUN->(dbCreateIndex( cPATH1 + "TMP", "Filial + Pis_num", {|| Filial + Pis_num}, if( .F., .T., NIL ) ))
          qmensa()
       endif

       FUN->(dbSetFilter({|| ! empty(Filial)},"! empty(Filial)"))

       if ! quse(cPATH1,"SITUA",{"SI_MATRI"},"R")
          qmensa("NÑo foi poss°vel abrir arquivo SITUA.DBF !! Tente novamente.")
          return .F.
       endif

       SITUA->(dbSetFilter({|| Anomes >= '199901' .and. Anomes <= '199912'},"Anomes >= '199901' .and. Anomes <= '199912'"))

       if ! quse(cPATH1,"LANC",{"LA_MATRI"},"R")
          qmensa("NÑo foi poss°vel abrir arquivo LANC.DBF !! Tente novamente.")
          return .F.
       endif

       if ! quse(cPATH2,"FILIAL",{"FI_CGCCP"},"R")
          qmensa("NÑo foi poss°vel abrir arquivo FILIAL.DBF !! Tente novamente.")
          return .F.
       endif
       
       if ! quse(XDRV_RHX,"AFAST",{"AF_CODIG"},"R")
          qmensa("NÑo foi poss°vel abrir arquivo AFAST.DBF !! Tente novamente.")
          return .F.
       endif

       FILIAL->(dbgotop())
          
       do while ! FILIAL->(eof())
          qgirabarra()

          // VERIFICA SE RAIS E OU NAO NEGATIVA (SE HOUVE MOVIMENTACAO NO ANO) _

          nNEG := "1"

//          FUN->(dbseek(FILIAL->Codigo))
          FUN->(dbgotop())

          do while ! FUN->(eof()) .and. FUN->Filial == FILIAL->Codigo
             qgirabarra()

             SITUA->(qseekn(FUN->Matricula))

             if SITUA->Vinculo == K_DIRETOR .or. year(FUN->Data_adm) > val(cANOBASE)
                FUN->(dbskip())
                loop
             endif

             if year(FUN->Data_adm) == val(cANOBASE) .and. SITUA->Transf == "S" .and. ;
                (! empty(SITUA->Data_transf) .and. year(SITUA->Data_transf) > val(cANOBASE))
                FUN->(dbskip())
                loop
             endif

             if FUN->Situacao == "H" .and. SITUA->Af_cod != "40" .and. year(SITUA->Af_ini) < val(cANOBASE)
                FUN->(dbskip())
                loop
             endif

             if SITUA->Af_cod == "40" .and. year(SITUA->Af_ini) != val(cANOBASE)
                FUN->(dbskip())
                loop
             endif

             if SITUA->Af_cod $ "03-04-05-06"
                FUN->(dbskip())
                loop
             endif

             if SITUA->Categoria $ "89"
                FUN->(dbskip())
                loop
             endif

             LANC->(dbgotop())
             for nMES = 1 to 12
                 LANC->(dbseek(left(cANOMES,4)+strzero(nMES,2)+FUN->Matricula))
                 if ! LANC->(eof())
                    nNEG := "0"
                    exit
                 endif
             next
             FUN->(dbskip())
          enddo

          CGM->(dbseek(FILIAL->Cgm))

          qsay(20,28,FILIAL->Codigo)
          qsay(20,35,left(FILIAL->Razao,37))

          if lPRIM
             // MONTA REGISTRO TIPO 0 _________________________________________________

             cRAIS += strzero(nSEQ,6) + FILIAL->Cgccpf + "000" + iif(cCORRESP=="1","X"," ") + cRESP + cENDRESP + strzero(nNUMERO,6) + cCOMPL + cBAIRRO
             cRAIS += CGM->Cep + CGM->Cod_rais + CGM->Municipio + CGM->Estado + cFONE + iif(cTP_ENT=="1","X"," ") + iif(cTP_DEC=="2","X"," ")
             cRAIS += qtiraponto(dtoc(dDT_RET)) + qtiraponto(dtoc(Date())) + space(54)

             RAIS->(qappend())
             RAIS->Linha := cRAIS
             cRAIS := ""
             lPRIM := .F.
          endif

          // MONTA REGISTRO TIPO 1 _____________________________________________

          nSEQ++
          cRAIS := strzero(nSEQ,6) + FILIAL->Cgccpf + "001"
          cRAIS += i_trocachr(left(FILIAL->Razao,52)) + i_trocachr(FILIAL->Endereco) + strzero(FILIAL->Numero,6) + FILIAL->Compl + left(FILIAL->Bairro,19)
          cRAIS += FILIAL->Cep + strzero(val(qtiraponto(CGM->Cod_rais)),7) + left(CGM->Municipio,31)
          cRAIS += CGM->Estado + cFONE + strzero(val(qtiraponto(CONFIG->Cnae)),5) + strzero(val(qtiraponto(FILIAL->Natu_jurid)),4)
          cRAIS += strzero(val(FILIAL->Propriet),2) + strzero(val(FILIAL->Mes_dtbase),2) + FILIAL->Tipo_insc + nNEG
          cRAIS += iif(FILIAL->Mudou_insc == "N","0","1") + iif(FILIAL->Mudou_insc == "N","0","1")
//          cRAIS += iif(FILIAL->Mudou_end == "N","0","2") + strzero(val(FILIAL->Insc_ante),12)
          cRAIS += strzero(val(FILIAL->Insc_ante),12)
          cRAIS += cANOBASE  +  iif(FILIAL->Part_pat == "S","X"," ") + iif(FILIAL->Micro_emp == "S","X"," ")
          cRAIS += iif(FILIAL->Peq_porte == "S","X"," ") + iif(FILIAL->Op_simples == "S","X"," ")
          cRAIS += replicate(space(1),25)

          RAIS->(qappend())
          RAIS->Linha := cRAIS
          cRAIS := ""

          nTOTEMP++

          if nNEG == "0"

             // MONTA REGISTROS TIPO 2 ____________________________________________

             FUN->(dbseek(FILIAL->Codigo))

             do while ! FUN->(eof()) .and. FUN->Filial == FILIAL->Codigo
                qgirabarra()

                SITUA->(qseekn(FUN->Matricula))

                if SITUA->Vinculo = K_DIRETOR .or. year(FUN->Data_adm) > val(cANOBASE)
                   FUN->(dbskip())
                   loop
                endif

                if year(FUN->Data_adm) == val(cANOBASE) .and. SITUA->Transf == "S" .and. ;
                (! empty(SITUA->Data_transf) .and. year(SITUA->Data_transf) > val(cANOBASE))
                   FUN->(dbskip())
                   loop
                endif

                if FUN->Situacao == "H" .and. SITUA->Af_cod != "40" .and. year(SITUA->Af_ini) < val(cANOBASE)
                   FUN->(dbskip())
                   loop
                endif

                if SITUA->Af_cod == "40" .and. year(SITUA->Af_ini) != val(cANOBASE)
                   FUN->(dbskip())
                   loop
                endif

                if SITUA->Af_cod $ "03-04-05-06"
                   FUN->(dbskip())
                   loop
                endif

                if SITUA->Categoria $ "89"
                   FUN->(dbskip())
                   loop
                endif

                qsay(21,28,FUN->Matricula)
                qsay(21,37,FUN->Nome)

                nSEQ++

                cRAIS := strzero(nSEQ,6) + FILIAL->Cgccpf + "002"

                cRAIS += FUN->Pis_num + i_trocachr(FUN->Nome) + left(qtiraponto(dtoc(FUN->Data_nasc)),4) + str(year(FUN->Data_nasc),4)
                // qtiraponto(dtoc(FUN->(Data_nasc)))

                do case
                   case FUN->Nacional == "A"
                        cNACIONAL := "10"
                   case FUN->Nacional == "B"
                        cNACIONAL := "20"
                   case FUN->Nacional == "C"
                        cNACIONAL := "21"
                   case FUN->Nacional == "D"
                        cNACIONAL := "22"
                   case FUN->Nacional == "E"
                        cNACIONAL := "23"
                   case FUN->Nacional == "F"
                        cNACIONAL := "24"
                   case FUN->Nacional == "G"
                        cNACIONAL := "25"
                   case FUN->Nacional == "H"
                        cNACIONAL := "30"
                   case FUN->Nacional == "I"
                        cNACIONAL := "31"
                   case FUN->Nacional == "J"
                        cNACIONAL := "32"
                   case FUN->Nacional == "K"
                        cNACIONAL := "34"
                   case FUN->Nacional == "L"
                        cNACIONAL := "35"
                   case FUN->Nacional == "M"
                        cNACIONAL := "36"
                   case FUN->Nacional == "N"
                        cNACIONAL := "37"
                   case FUN->Nacional == "O"
                        cNACIONAL := "38"
                   case FUN->Nacional == "P"
                        cNACIONAL := "39"
                   case FUN->Nacional == "Q"
                        cNACIONAL := "41"
                   case FUN->Nacional == "R"
                        cNACIONAL := "42"
                   case FUN->Nacional == "S"
                        cNACIONAL := "43"
                   case FUN->Nacional == "T"
                        cNACIONAL := "45"
                   case FUN->Nacional == "U"
                        cNACIONAL := "48"
                   case FUN->Nacional == "V"
                        cNACIONAL := "49"
                   case FUN->Nacional == "X"
                        cNACIONAL := "50"
                endcase

                cRAIS += cNACIONAL + iif( empty(FUN->Nc_dat),"0000" , str(year(FUN->Nc_dat),4)) + FUN->Instrucao // + space(1)
                cRAIS += strzero(val(FUN->Cpf_num),11) + strzero(val(qtiraponto(FUN->Cp_num)),6)
                cRAIS += strzero(val(qtiraponto(FUN->Cp_serie)),5)
//              cRAIS += qtiraponto(dtoc(FUN->Data_adm))
                cRAIS += left(qtiraponto(dtoc(FUN->Data_adm)),4) + str(year(FUN->Data_adm),4)

                if FUN->Prim_adm = "S"
                   if SITUA->Transf = "S"
                      cTIPO := "3"
                   endif
                   cTIPO := "1"
                else
                   cTIPO := "2"
                endif

// PEDACO DE QDEU CERTO PARA OS OUTROS CLIENTES....

                if SITUA->Salario == 0
                   if BASE->(dbseek(SITUA->Matricula+SITUA->Anomes))
                      cRAIS += cTIPO + strzero(val(qtiraponto(str( (BASE->B_fgtsms+BASE->B_fgtsfr) ,9,2))),9)
                   else
                      cRAIS += cTIPO + strzero(val(qtiraponto(str(SITUA->Salario,9,2))),9)
                   Endif
                Else
                   cRAIS += cTIPO + strzero(val(qtiraponto(str(SITUA->Salario,9,2))),9)
                endif

// alteracao para a sidelma 24/03/99 NAO DEU CERTO
//                if SITUA->Salario == 0
//                   if BASE->(dbseek(SITUA->Matricula+SITUA->Anomes))
//                      cRAIS += cTIPO + strzero(val(qtiraponto(str( (BASE->B_fgtsms+BASE->B_fgtsfr) ,9,2))),9)
//                   else
//                      cRAIS += cTIPO + strzero(val(qtiraponto(str(SITUA->Salario,9,2))),9)
//                   Endif
//                Else
//                   nREG:=SITUA->(recno())
//                   nORD:=SITUA->(dbsetorder())
//                   SITUA->(dbsetorder(4))
//                   nVALOR_CONT := 0

//                   for nCONTA:= 1 to 12
//                       SITUA->(dbgotop())
//                       SITUA->(dbseek(cANOBASE + Strzero(nCONTA,2) + FUN->Matricula ))
//                       lTESTA := .F.
//                       if SITUA->Situacao == "D"
//                          lTESTA := .T.
//                          LANC->(dbgotop())
//                          LANC->(dbseek(cANOBASE + strzero(nCONTA,2) + FUN->Matricula))
//                          do while LANC->Anomes == cANOBASE + strzero(nCONTA,2) .and. LANC->Matricula == FUN->Matricula
//                             if LANC->Ambiente == "MS" .and. LANC->Evento $ "100*134*135*136*137*138*139*140*142*143*145*146*147*149*153*154"
//                                nVALOR_CONT += LANC->Valor
//                             Endif
//                             if LANC->Ambiente == "FR" .and. LANC->Evento $ "180*181*134*135*136*137*138*139*140*142*143*145*146*147*149*153*154"
//                                nVALOR_CONT += LANC->Valor
//                             endif
//                             LANC->(dbskip())
//                          Enddo
//                          exit
//                       Endif

//                   Next
//                   if ! lTESTA
//                      LANC->(dbgotop())
//                      LANC->(dbseek(cANOBASE + "12" + FUN->Matricula))
//                      do while LANC->Anomes == cANOBASE + "12" .and. LANC->Matricula == FUN->Matricula
//                         if LANC->Ambiente == "MS" .and. LANC->Evento $ "100*134*135*136*137*138*139*140*142*143*145*146*147*149*153*154"
//                            nVALOR_CONT += LANC->Valor
//                         Endif
//                         if LANC->Ambiente == "FR" .and. LANC->Evento $ "180*181*134*135*136*137*138*139*140*142*143*145*146*147*149*153*154"
//                            nVALOR_CONT += LANC->Valor
//                         endif
//                         LANC->(dbskip())
//                      Enddo
//                   Endif

//                   SITUA->(dbsetorder(nORD))
//                   SITUA->(dbgoto(nREG))

//                   cRAIS += cTIPO + strzero(val(qtiraponto(str(SITUA->Salario+nVALOR_CONT,9,2))),9)
//                endif

// fim da alteracao...

                if val(SITUA->Categoria) <= 6
                   cRAIS += SITUA->Categoria
                else
                   cRAIS += "7"
                endif

                cRAIS += strzero(FUN->Hor_sema,2) + qtiraponto(SITUA->Cbo)

                do case
                   case SITUA->Vinculo == "A"
                        cRAIS += "10"
                   case SITUA->Vinculo == "B"
                        cRAIS += "15"
                   case SITUA->Vinculo == "C"
                        cRAIS += "20"
                   case SITUA->Vinculo == "D"
                        cRAIS += "25"
                   case SITUA->Vinculo == "E"
                        cRAIS += "30"
                   case SITUA->Vinculo == "F"
                        cRAIS += "35"
                   case SITUA->Vinculo == "G"
                        cRAIS += "40"
                   case SITUA->Vinculo == "H"
                        cRAIS += "50"
                   case SITUA->Vinculo == "I"
                        cRAIS += "60"
                   case SITUA->Vinculo == "J"
                        cRAIS += "65"
                   case SITUA->Vinculo == "K"
                        cRAIS += "70"
                   case SITUA->Vinculo == "L"
                        cRAIS += "75"
                   case SITUA->Vinculo == "M"
                        cRAIS += "80"
                   case SITUA->Vinculo == "N"
                        cRAIS += "90"
                endcase

//              cRAIS += "1" + right(qanomes(FUN->Fgts_dat),2) + left(qanomes(FUN->Fgts_dat),2)

                cAFAST := "00"

                if (year(SITUA->Af_ini) == val(cANOBASE) .and. FUN->Situacao != "F")
                   if ! empty(SITUA->Af_cod)
                      AFAST->(dbseek(SITUA->Af_cod))
                      cAFAST := AFAST->Cod_rais
                   endif

                   cRAIS += cAFAST + strzero(day(SITUA->Af_ini),2) + strzero(month(SITUA->Af_ini),2)
                else
                   cRAIS += "000000"
                endif

                nVALOR := nVDT_ADT := nVDT_FIM := 0
                BASE->(dbsetorder(2))
                BASE->(dbgotop())
                LANC->(dbgotop())
                for nCONTA = 1 to 12
                    BASE->(dbseek(left(cANOMES,4) + strzero(nCONTA,2) + FUN->Matricula))
                    LANC->(dbseek(left(cANOMES,4) + strzero(nCONTA,2) + FUN->Matricula))
                    if LANC->(eof())
                       cRAIS += "000000000"
                    else
                       if BASE->Anomes == left(cANOMES,4) + strzero(nCONTA,2) .and. BASE->Matricula == FUN->Matricula
                          nVALOR := BASE->B_inssms + BASE->B_inssfr
                       endif
                       do while LANC->Anomes == left(cANOMES,4) + strzero(nCONTA,2) .and. LANC->Matricula == FUN->Matricula
                          do case
                             case LANC->Ambiente == "MS" .or. LANC->Ambiente == "FR"
                                  EVENT->(dbseek(LANC->Evento))
                                  if EVENT->Finalidade == "P" .and. EVENT->Rais == "S" .and. ! LANC->Evento $ "813-814"
                                   //nVALOR += LANC->Valor
                                   //  nVALOR := BASE->B_inssms
                                  endif
                                  if EVENT->Finalidade == "P" .and. EVENT->Rais == "S" .and. LANC->Evento $ "813-814"
                                     nVDT_FIM += LANC->Valor
                                     cMDT_FIM := strzero(month(SITUA->Af_ini),2)
                                  endif
                             case LANC->Ambiente == "DT" .and. right(LANC->Anomes,2) != "12"
                                  EVENT->(dbseek(LANC->Evento))
                                  if EVENT->Finalidade == "P" .and. EVENT->Rais == "S"
                                     if cAFAST == "00"
                                        nVDT_ADT += LANC->Valor
                                        cMDT_ADT := right(LANC->Anomes,2)
                                     else
                                        if ! LANC->Evento $ "182_183"
                                           nVDT_FIM += LANC->Valor
                                        endif
                                        cMDT_FIM := right(LANC->Anomes,2)
                                     endif
                                  endif
                             case LANC->Ambiente == "DT" .and. right(LANC->Anomes,2) == "12"
                                  EVENT->(dbseek(LANC->Evento))
                                  if EVENT->Finalidade == "P" .and. EVENT->Rais == "S"
                                     nVDT_FIM += LANC->Valor
                                     cMDT_FIM := "12"
                                  endif
                          endcase

                          LANC->(dbskip())

                       enddo
                       BASE->(dbskip())
                       cRAIS += strzero(val(qtiraponto(str(nVALOR,9,2))),9)

                       nVALOR := 0

                    endif
                next

                if ! empty(nVDT_ADT)
                   cRAIS += strzero(val(qtiraponto(str(nVDT_ADT,9,2))),9)
                   cRAIS += cMDT_ADT
                else
                   cRAIS += "00000000000"
                endif

                if ! empty(nVDT_FIM)
                   nVDT_FIM -= nVDT_ADT
                   cRAIS += strzero(val(qtiraponto(str(nVDT_FIM,9,2))),9)
                   cRAIS += cMDT_FIM
                else
                   if cAFAST == "31"
                      cRAIS += "00000000112"
                   else
                      cRAIS += "00000000000"
                   endif
                endif
                cRAIS += "2"    //Raca/cor
                cRAIS += replicate(space(1),14)

                RAIS->(qappend())
                RAIS->Linha := cRAIS
                cRAIS := ""

                nTOTFUN++

                FUN->(dbskip())

             enddo

          endif

          cCGCCEI := FILIAL->Cgccpf

          FILIAL->(dbskip())

       enddo

       qmensa()

       CONFIG->(dbclosearea())

       AFAST->(dbclosearea())

       FUN->(dbclosearea())

       LANC->(dbclosearea())

       FILIAL->(dbclosearea())

       SITUA->(dbclosearea())

       CFGDISQ->(dbskip())

   enddo

   // MONTA REGISTRO TIPO 9 _________________________________________________

   nSEQ++

   cRAIS := strzero(nSEQ,6) + cCGCCEI + "009"
   cRAIS += strzero(nTOTEMP,6) + strzero(nTOTFUN,6)
   cRAIS += replicate(space(1),245)

   RAIS->(qappend())
   RAIS->Linha := cRAIS
   cRAIS := ""

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")

   cNOMARQ := cDRIVE + ":RAIS2000."

   RAIS->(dbgotop())

   RAIS->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   qmensa()

   select CFGDISQ

   CFGDISQ->(dbgotop())

return

/////////////////////////////////////////////////////////////////////////////
// SUBSTITUI CARACTERES INVALIDOS PARA O ANALISADOR _________________________

static function i_trocachr(cTROCADO)

   cTROCADO := strtran(cTROCADO,"'"," ")
   cTROCADO := strtran(cTROCADO,"Ä","C")
   cTROCADO := strtran(cTROCADO,"á","c")
   cTROCADO := strtran(cTROCADO,"ß",".")
   cTROCADO := strtran(cTROCADO,"¶","a")
   cTROCADO := strtran(cTROCADO,"Ç","e")
   cTROCADO := strtran(cTROCADO,"É","a")
   cTROCADO := strtran(cTROCADO,"Ñ","a")
   cTROCADO := strtran(cTROCADO,"Ö","a")
   cTROCADO := strtran(cTROCADO,"Ü","a")
   cTROCADO := strtran(cTROCADO,"à","e")
   cTROCADO := strtran(cTROCADO,"â","e")
   cTROCADO := strtran(cTROCADO,"ä","e")
   cTROCADO := strtran(cTROCADO,"ã","i")
   cTROCADO := strtran(cTROCADO,"å","i")
   cTROCADO := strtran(cTROCADO,"ç","i")
   cTROCADO := strtran(cTROCADO,"ì","o")
   cTROCADO := strtran(cTROCADO,"é","A")
   cTROCADO := strtran(cTROCADO,"è","A")
   cTROCADO := strtran(cTROCADO,"ê","E")
   cTROCADO := strtran(cTROCADO,"ì","o")
   cTROCADO := strtran(cTROCADO,"î","o")
   cTROCADO := strtran(cTROCADO,"ï","o")
   cTROCADO := strtran(cTROCADO,"ñ","u")
   cTROCADO := strtran(cTROCADO,"ó","u")
   cTROCADO := strtran(cTROCADO,"ô","o")
   cTROCADO := strtran(cTROCADO,"ö","U")
   cTROCADO := strtran(cTROCADO,"†","a")
   cTROCADO := strtran(cTROCADO,"°","i")
   cTROCADO := strtran(cTROCADO,"¢","o")
   cTROCADO := strtran(cTROCADO,"£","u")
   cTROCADO := strtran(cTROCADO,"§","n")
   cTROCADO := strtran(cTROCADO,"&","e")
   cTROCADO := strtran(cTROCADO,"-"," ")
   cTROCADO := strtran(cTROCADO,"="," ")
   cTROCADO := strtran(cTROCADO,"_"," ")
   cTROCADO := strtran(cTROCADO,"¯",".")

return(cTROCADO)

