/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CAGED EM DISQUETE
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1995
// OBS........:
// ALTERACOES.:

#include "rh.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO2   := qlbloc("B450E","QBLOC.GLO")
private sBLOCO3   := qlbloc("B450F","QBLOC.GLO")

private lCONF      // variavel  para confirmacoes
private cCONVENIO  // codigo do convenio
private nBUREAU    // numero da empresa bureau
private cMESANO    // mes e ano de competencia
private cDRIVE     // drive para gravacao
private cCAGED     // string de montagem de cada linha
private cMICRO := space(1)
private nTOTFUN := nFUNGERAL := nTOTFIL := 0

// ABRE ARQUIVO CAGED.DBF E ZERA ____________________________________________

if ! quse(XDRV_RHX,"CAGED",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo CAGED.DBF !! Tente novamente.")
   return
endif

CAGED->(__dbzap())

// ABRE ARQUIVO QINST.DBF, FILTRA E ALIMENTA ARQUIVO CFGDISQ.DBF ____________

if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")
   qmensa("N„o foi poss¡vel abrir arquivo QINST.DBF !! Tente novamente.")
   return
endif

QINST->(dbSetFilter({|| Empresa <> "000"}, 'Empresa <> "000"'))

QINST->(dbgotop())

qlbloc(5,0,"B450A","QBLOC.GLO")

do while ! QINST->(eof())

   if "RH" $ QINST->Sistemas

      qmensa("Processando Empresa: " + QINST->Razao)

      if ! quse(QINST->Drv_rh,"CONFIG",NIL,"R")
         qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF! ")
         qmensa("Verifique no F5 se a empresa possui base de dados...","B")
         inkey(4)
         return .F.
      endif

      CGM->(dbseek(QINST->Cgm))

      if CFGDISQ->(dbseek(QINST->Empresa))
         if CFGDISQ->(qrlock())
            replace CFGDISQ->Razao   with QINST->Razao
            replace CFGDISQ->Cgccei  with strzero(val(qtiraponto(QINST->Cgccpf)),14)
         endif
      else
         if CFGDISQ->(qappend())
            replace CFGDISQ->Empresa with QINST->Empresa
            replace CFGDISQ->Razao   with QINST->Razao
            replace CFGDISQ->Cgccei  with strzero(val(qtiraponto(QINST->Cgccpf)),14)
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
                 {"Razao/Raz„o"  ,0},;
                 {"f450a()/Emite",0}},"P",;
                 {NIL,"f450b",NIL,NIL},;
                  NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))
return

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE EMITE CAGED OU NAO ______________________________

function f450a
return(iif(CFGDISQ->Caged=="S","SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO 1 ______________________________

function f450b
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
// EDICAO DOS DADOS INFORMATIVOS POR EMPRESA E FILIAIS ______________________

static function i_edicao
   local aEDICAO1 := {}

   qlbloc(9,7,"B450B","QBLOC.GLO")

   CFGDISQ->(qpublicfields())
   CFGDISQ->(qinitfields())
   CFGDISQ->(qcopyfields())

   qsay(10,21,CFGDISQ->Empresa)
   qsay(10,27,left(CFGDISQ->Razao,44))
   qsay(12,33,fCGCCEI)
   qsay(14,34,qabrev(fCAGED,"SN",{"Sim","N„o"}))
        
   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________
   
   aadd(aEDICAO1,{{ || qesco(-1,0,@fCAGED,XSN)},"CAGED" })

   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
      eval ( aEDICAO1 [XNIVEL,1] )
      if eval ( bESCAPE ) ; CFGDISQ->(qreleasefields()) ; return "" ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO DO CFGDISQ ___________________________________________________

   if cOPCAO == "A"
      if CFGDISQ->(qrlock())
         CFGDISQ->(qreplacefields())
         CFGDISQ->(qunlock())
      else
         qm2()
      endif
   endif

   if fCAGED == "N"
      return
   endif

   // EDICAO DAS FILIAIS ____________________________________________________
   
   cPATH := "\QSYS_G\QCT\E" + CFGDISQ->Empresa + "\"
   
   // ABRE ARQUIVO DE FILIAIS _______________________________________________

   if ! quse(cPATH,"FILIAL",{"FI_CGCCP"})
      qmensa("N„o foi poss¡vel abrir arquivo FILIAL.DBF !! Tente novamente.")
      return .F.
   endif

   FILIAL->(qview({{"left(Razao,30)/Filial",1},;
                   {"Codigo/C¢digo"        ,2}},"16002379",;
                   {NIL,"f450c",NIL,NIL},;
                    NIL,"<ESC> Encerra / <A>ltera / <C>onsulta"))

   FILIAL->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// EDICAO DADOS DAS FILIAIS _________________________________________________

function f450c
   local aEDICAO2 := {}

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   qlbloc(9,7,"B450G","QBLOC.GLO")

   FILIAL->(qpublicfields())
   FILIAL->(qinitfields())
   FILIAL->(qcopyfields())

   if(empty(fENCER_ATIV),fENCER_ATIV := "2",fENCER_ATIV)
   if(empty(fPRIM_DECLA),fPRIM_DECLA := "N",fPRIM_DECLA)
   if(empty(fMUDOU_END ),fMUDOU_END  := "N",fMUDOU_END )
   if(empty(fMUDOU_ATIV),fMUDOU_ATIV := "N",fMUDOU_ATIV)

   XNIVEL := 1

   qsay(10,21,FILIAL->Codigo)
   qsay(10,28,left(FILIAL->Razao,43))
   qsay(12,32,qabrev(fTIPO_INSC,"12",{"CGC","CEI"}))
   qsay(12,57,fCGCCPF)
   qsay(14,32,qabrev(fENCER_ATIV,"123",{"Neste mˆs/ano de competˆncia","Continua em Atividade","T‚rmino do Convˆnio Magn‚tico"}))
   qsay(16,38,qabrev(fPRIM_DECLA,"SN",{"Sim","N„o"}))
   qsay(16,68,qabrev(fMUDOU_END,"SN",{"Sim","N„o"}))
   qsay(18,36,qabrev(fMUDOU_ATIV,"SN",{"Sim","N„o"}))
        
   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return "" ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________
   
   aadd(aEDICAO2,{{ || qesco(-1,0,@fENCER_ATIV,SBLOCO2 )} , "ENCER_ATIV" })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fPRIM_DECLA,XSN     )} , "PRIM_DECLA" })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fMUDOU_END ,XSN     )} , "MUDOU_END"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fMUDOU_ATIV,XSN     )} , "MUDOU_ATIV" })

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
      case cCAMPO == "ENCER_ATIV"
           qrsay ( XNIVEL , qabrev(fENCER_ATIV,"123",{"Neste mˆs/ano de competˆncia","Continua em Atividade","T‚rmino do Convˆnio Magn‚tico"}))
      case cCAMPO == "PRIM_DECLA"
           qrsay ( XNIVEL , qabrev(fPRIM_DECLA,"SN",{"Sim","N„o"}))
      case cCAMPO == "MUDOU_END"
           qrsay ( XNIVEL , qabrev(fMUDOU_END,"SN",{"Sim","N„o"}))
      case cCAMPO == "MUDOU_ATIV"
           qrsay ( XNIVEL , qabrev(fMUDOU_ATIV,"SN",{"Sim","N„o"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZACAO DO PROCESSO DE GERACAO DO CAGED EM DISQUETE ________________

static function i_processa
   local AEDICAO3 := {}

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(AEDICAO3,{{ || qgetx(-1,0,@cCONVENIO ,"999999-9"          )} , "CONVENIO" })
   aadd(AEDICAO3,{{ || view_disq(-1,0,@nBUREAU                    )} , "BUREAU"   })
   aadd(AEDICAO3,{{ || NIL },NIL}) // razao da empresa bureau
   aadd(AEDICAO3,{{ || NIL },NIL}) // mes/ano de competencia
   aadd(AEDICAO3,{{ || qesco(-1,0,@cDRIVE,SBLOCO3                 )} , "DRIVE"    })
   aadd(AEDICAO3,{{ || lCONF := qconf("Confirma emiss„o do CAGED ?") },NIL})

   do while .T.

      qlbloc(5,0,"B450C","QBLOC.GLO")
      XNIVEL    := 1
      XFLAG     := .T.
      cCAGED    := ""
      cMICRO    := space(1)
      cCONVENIO := "      - "
      nBUREAU   := space(3)
      cMESANO   := right(qanomes(XDATASYS),2) + "/" + substr(left(qanomes(XDATASYS),6),1,4)
      cDRIVE    := "A"

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(AEDICAO3)
         eval ( AEDICAO3 [XNIVEL,1] )
         if eval ( bESCAPE ) ; CFGDISQ->(qreleasefields()) ; return ; endif
         if ! i_critica2( AEDICAO3[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      iif ( lCONF , i_gravacao() , NIL )

   enddo

return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA 3 ___________________________________________

static function i_critica2 ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "CONVENIO"
           if empty(qtiraponto(cCONVENIO))
              qmensa("Campo CONVENIO ‚ obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "BUREAU"
           if CFGDISQ->(dbseek(nBUREAU:=strzero(val(nBUREAU),3)))
              qrsay(XNIVEL,nBUREAU)
              qrsay(XNIVEL+1,left(CFGDISQ->Razao,30))
           else
              qmensa("Empresa n„o cadastrada !","B")
              return .F.
           endif
           qrsay(XNIVEL+2,cMESANO)
      case cCAMPO == "DRIVE"
           qrsay(XNIVEL,qabrev(cDRIVE,"AB",{"A:","B:"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE GRAVACAO __________________________________________

static function i_gravacao
   local nCONT , lCONF , nSEQ := 1 , cPATH1 , cPATH2
   local cCOD_NOVO , lNOVO := .F. , cNOMARQ
   local nCONT20 := nCONT30  := nCONT40 := 0
   local nTOTFUN := nFUNGERAL := nTOTFIL := 0
   local cCNAE :=""

   cPATH2 := "\QSYS_G\QCT\E" + CFGDISQ->Empresa + "\"

   if ! quse(cPATH2,"FILIAL",{"FI_CGCCP"},"R")
      qmensa("N„o foi poss¡vel abrir arquivo FILIAL.DBF !! Tente novamente.")
      return .F.
   endif

   if ! FILIAL->(dbseek(CFGDISQ->Cgccei))
      qmensa("Filial n„o cadastrada no arquivo FILIAL.DBF !!","B")
      return .F.
   endif

   CGM->(dbseek(FILIAL->Cgm))

   // MONTA REGISTRO TIPO 10 ________________________________________________

   cCAGED := "A2" + qtiraponto(cCONVENIO) + qtiraponto(cMESANO) + "1" + strzero(nSEQ,5) + FILIAL->Tipo_insc + FILIAL->Cgccpf
   cCAGED += left(FILIAL->Razao,35) + ( left(FILIAL->Endereco,25) + str(FILIAL->Numero,5) + left(FILIAL->Compl,10) )
   cCAGED += FILIAL->Cep + CGM->Estado + FILIAL->Telefone // total de estabelecimentos // total de movimento

   FILIAL->(dbclosearea())

   CAGED->(qappend())
   CAGED->Linha := cCAGED
   cCAGED := ""

   CFGDISQ->(dbgotop())
   
   do while ! CFGDISQ->(eof())
      qgirabarra()

      if CFGDISQ->Caged $ "N "
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

      qsay(17,30,CFGDISQ->Empresa)
      qsay(17,36,left(CFGDISQ->Razao,35))

      if ! quse(cPATH1,"FUN",{"FU_FILMA"},"R")
         qmensa("N„o foi poss¡vel abrir arquivo FUN.DBF !! Tente novamente.")
         return .F.
      endif

      if ! quse(cPATH1,"SITUA",{"SI_MATRI"},"R")
         qmensa("N„o foi poss¡vel abrir arquivo SITUA.DBF !! Tente novamente.")
         return .F.
      endif

      SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

      if ! quse(XDRV_RHX,"AFAST",{"AF_CODIG"},"R")
         qmensa("N„o foi poss¡vel abrir arquivo AFAST.DBF !! Tente novamente.")
         return .F.
      endif

      if ! quse(cPATH2,"FILIAL",{"FI_CODIG"},"R")
         qmensa("N„o foi poss¡vel abrir arquivo FILIAL.DBF !! Tente novamente.")
         return .F.
      endif

      FILIAL->(dbgotop())

      do while ! FILIAL->(eof())

         qgirabarra()

         qsay(18,30,FILIAL->Codigo)
         qsay(18,37,left(FILIAL->Razao,34))
         
         // MONTA REGISTRO TIPO 20 ____________________________________________

         CGM->(dbseek(FILIAL->Cgm))
         
         nSEQ++
         cCAGED := "B" + FILIAL->Tipo_insc + FILIAL->Cgccpf
         cCAGED += strzero(nSEQ,5) + iif(FILIAL->Prim_decla=="S","1","2") + "1"
         cCAGED += FILIAL->Cep + left(qtiraponto(CONFIG->Cnae),5)
         cCAGED += left(FILIAL->Razao,40) + ( left(FILIAL->Endereco,25) + str(FILIAL->Numero,5) + left(FILIAL->Compl,10) )
         cCAGED += FILIAL->Bairro + CGM->Estado // total de empregados
         cMICRO := FILIAL->Micro_emp
         cCNAE  := right(qtiraponto(CONFIG->Cnae),2)

         CAGED->(qappend())
         CAGED->Linha := cCAGED
         cCAGED := ""

         nCONT20++

         nTOTFFF := 0

         // MONTA REGISTROS TIPO 30 ___________________________________________

         SITUA->(dbsetrelation("AFAST",{||SITUA->Af_cod},"SITUA->Af_cod"))

         FUN->(dbseek(FILIAL->Codigo))

         do while ! FUN->(eof()) .and. FUN->Filial == FILIAL->Codigo
            qgirabarra()

            SITUA->(dbseek(FUN->Matricula))

            if FUN->Data_adm > qfimmes(XDATASYS)
               FUN->(dbskip())
               loop
            endif

            if SITUA->Af_ini > qfimmes(XDATASYS)
               FUN->(dbskip())
               loop
            endif

            if SITUA->Categoria == "9" .and. SITUA->Vinculo = "H"
               FUN->(dbskip())
               loop
            endif

            if SITUA->Vinculo = K_DIRETOR .or. FUN->Situacao $ "H"
               FUN->(dbskip())
               loop
            endif

            if ! empty(SITUA->Af_ini)
               if SITUA->Af_ini < qinimes(XDATASYS)
                  FUN->(dbskip())
                  loop
               endif
            endif

       //     if empty(SITUA->Af_ini) .and. FUN->Data_adm < qinimes(XDATASYS) .or. !empty(SITUA->Af_ini) .and. FUN->Data_adm < qinimes(XDATASYS)
       //        nTOTFFF++
       //     Endif

            if empty(SITUA->Af_ini) .and. FUN->Data_adm < qinimes(XDATASYS) .or. SITUA->Situacao$"AF" .and. FUN->Data_adm < qinimes(XDATASYS)
               nTOTFFF++
            Endif

            if empty(SITUA->Af_ini) .and. FUN->Data_adm < qinimes(XDATASYS)
               FUN->(dbskip())
               loop
            endif

            if ! empty(SITUA->Af_ini) .and. ! AFAST->Cod_caged $ "31-32-40-45-50-60-70-80"
               FUN->(dbskip())
               loop
            endif

            if FUN->Data_adm >= qinimes(XDATASYS)
               lNOVO := .T.
               if SITUA->Transf != "S"
                  if FUN->Prim_adm == "S"
                     cCOD_NOVO := "10"
                  else
                     cCOD_NOVO := "20"
                  endif
               else
                  if qanomes(SITUA->Data_trans) == qanomes(XDATASYS)
                     cCOD_NOVO := "70"
                  endif
               endif
               nTOTFFF--
            endif

            if SITUA->Vinculo = "G"   // funcionario avulso.........
               FUN->(dbskip())
               loop
            endif



            qsay(19,30,FUN->Matricula)
            qsay(19,39,left(FUN->Nome,30))


            nSEQ++
            cCAGED := "C" + FILIAL->Tipo_insc + FILIAL->Cgccpf
            cCAGED += strzero(nSEQ,5) + FUN->Pis_num
            cCAGED += iif(FUN->Sexo=="M","1","2") + qtiraponto(dtoc(FUN->Data_nasc))
            cCAGED += FUN->Instrucao + "0"+ left(qtiraponto(SITUA->Cbo),4)
            if SITUA->Categoria == "1"
               cCAGED += strzero(val(qtiraponto(str(SITUA->Salario,9,2))),8)
            else
               cCAGED += strzero(val(qtiraponto(str((SITUA->Salario*FUN->Hor_trab),9,2))),8)
            endif
            cCAGED += strzero(int(FUN->Hor_sema),2) + qtiraponto(dtoc(FUN->Data_adm))
            cCAGED += iif(lNOVO,cCOD_NOVO,AFAST->Cod_caged)
            cCAGED += iif(lNOVO,"  ",left(dtoc(SITUA->Af_ini),2)) + left(FUN->Nome,30)
            cCAGED += space(10) + strzero(val(qtiraponto(FUN->Cp_num)),8)
            cCAGED += strzero(val(FUN->Cp_serie),4)
            CGM->(dbseek(FUN->Cp_cgm))
            cCAGED += "       9" + "2"+qtiraponto(SITUA->Cbo)+"2"
            cCAGED += CGM->Estado+" "+FUN->Cpf_num+FUN->Cep

            CAGED->(qappend())
            CAGED->Linha := cCAGED
            cCAGED := ""

            if  FUN->Data_Adm >= qinimes(XDATASYS) .and. FUN->Data_adm <= qfimmes(XDATASYS) .and. !empty(SITUA->Af_ini)
                nSEQ++
                cCAGED := "C" + FILIAL->Tipo_insc + FILIAL->Cgccpf
                cCAGED += strzero(nSEQ,5) + FUN->Pis_num
                cCAGED += iif(FUN->Sexo=="M","1","2") + qtiraponto(dtoc(FUN->Data_nasc))
                cCAGED += FUN->Instrucao + "0" + left(qtiraponto(SITUA->Cbo),4)
                if SITUA->Categoria == "1"
                   cCAGED += strzero(val(qtiraponto(str(SITUA->Salario,9,2))),8)
                else
                   cCAGED += strzero(val(qtiraponto(str((SITUA->Salario*FUN->Hor_trab),9,2))),8)
                endif
                cCAGED += strzero(int(FUN->Hor_sema),2) + qtiraponto(dtoc(FUN->Data_adm))
                cCAGED += AFAST->Cod_caged
                cCAGED += left(dtoc(SITUA->Af_ini),2) + left(FUN->Nome,30)
                cCAGED += space(10) + strzero(val(qtiraponto(FUN->Cp_num)),8)
                cCAGED += strzero(val(FUN->Cp_serie),4)
                CGM->(dbseek(FUN->Cp_cgm))
                cCAGED += "       9" + "2" + qtiraponto(SITUA->Cbo)+"2"
                cCAGED += CGM->Estado


                CAGED->(qappend())
                CAGED->Linha := cCAGED
                cCAGED := ""
//                 nTOTFFF++
                nTOTFUN++
                nFUNGERAL++

            endif
            nTOTFFF++
            nTOTFUN++
            nFUNGERAL++
            lNOVO := .F.

            FUN->(dbskip())

         enddo

         nTOTFIL++

         FILIAL->(dbskip())

         // rotina que grava a quantidade de funcionarios da filial no registro da FILIAL _______
           nPOINTER := CAGED->(Recno())
           CAGED->(Dbgoto(nPOINTER-(nTOTFUN)))
           cLINHA := rtrim(CAGED->Linha)

           cLINHA += strzero(nTOTFFF,5) + iif(cMICRO == "S","1","2")+cCNAE
           replace CAGED->Linha with cLINHA
           CAGED->(Dbgobottom())
           nTOTFFF := 0
           nTOTFUN := 0
         // __ fim da rotina que grava funcionarios da filial

      enddo

      CONFIG->(dbclosearea())

      AFAST->(dbclosearea())

      FUN->(dbclosearea())

      SITUA->(dbclosearea())

      FILIAL->(dbclosearea())

      CFGDISQ->(dbskip())
      
   enddo

   // Rotina que grava a quantidade total de funcionarios e total de filiais no primeiro registro do arquivo___
      CAGED->(Dbgoto(1))
//      cLINHA := alltrim(CAGED->Linha)

      cLINHA := rtrim(CAGED->Linha)

      nRESTO := 0

      if len(rtrim(CAGED->Linha)) < 138
         nRESTO := 138 - len(rtrim(CAGED->Linha))
      else
         nRESTO := 0
      endif

      cLINHA += space(nRESTO) + strzero(nTOTFIL,5) + strzero(nFUNGERAL,5) + "  "

      replace CAGED->Linha with cLINHA
      cLINHA := ""
      CAGED->(Dbgobottom())
   // __ fim da rotina de totalizacao

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")
   
   cNOMARQ := cDRIVE + ":C" + qtiraponto(cCONVENIO) + ".001"

   CAGED->(dbgotop())

   CAGED->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

   qmensa()

   select CFGDISQ

   CFGDISQ->(dbgotop())

   if CAGED->(qflock())
      CAGED->(__dbzap())
   endif

return
