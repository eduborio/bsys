/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: FICHA CADASTRAL EM DISQUETE
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JULHO DE 1998
// OBS........:
// ALTERACOES.:

#include "rh.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO2   := qlbloc("B490E","QBLOC.GLO")
private sBLOCO3   := qlbloc("B490F","QBLOC.GLO")

private lCONF      // variavel  para confirmacoes
private cMESANO    // mes e ano de competencia
private cDRIVE     // drive para gravacao
private cFICHA     // string de montagem de cada linha
private nTOTFUN := nFUNGERAL := nTOTFIL := 0

// ABRE ARQUIVO FICHACAD.DBF E ZERA ____________________________________________

if ! quse(XDRV_RHX,"FICHACAD",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo FICHACAD.DBF !! Tente novamente.")
   return
endif

FICHACAD->(__dbzap())

// ABRE ARQUIVO QINST.DBF, FILTRA E ALIMENTA ARQUIVO CFGDISQ.DBF ____________

if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")
   qmensa("N„o foi poss¡vel abrir arquivo QINST.DBF !! Tente novamente.")
   return
endif

QINST->(dbSetFilter({|| Empresa <> "000"}, 'Empresa <> "000"'))

QINST->(dbgotop())

qlbloc(5,0,"B490A","QBLOC.GLO")

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
                 {"f490a()/Emite",0}},"P",;
                 {NIL,"f490b",NIL,NIL},;
                  NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))
return

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE EMITE CAGED OU NAO ______________________________

function f490a
return(iif(CFGDISQ->Ficha=="S","SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO 1 ______________________________

function f490b
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

   qlbloc(9,7,"B490B","QBLOC.GLO")

   CFGDISQ->(qpublicfields())
   CFGDISQ->(qinitfields())
   CFGDISQ->(qcopyfields())

   qsay(10,21,CFGDISQ->Empresa)
   qsay(10,27,left(CFGDISQ->Razao,44))
   qsay(12,33,fCGCCEI)
   qsay(14,34,qabrev(fFICHA,"SN",{"Sim","N„o"}))
        
   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________
   
   aadd(aEDICAO1,{{ || qesco(-1,0,@fFICHA,XSN)},"FICHA" })

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

   if fFICHA == "N"
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
                   {NIL,"f490c",NIL,NIL},;
                    NIL,"<ESC> Encerra / <C>onsulta"))

   FILIAL->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// EDICAO DADOS DAS FILIAIS _________________________________________________

function f490c
   local aEDICAO2 := {}

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   qlbloc(9,7,"B490G","QBLOC.GLO")

   FILIAL->(qpublicfields())
   FILIAL->(qinitfields())
   FILIAL->(qcopyfields())

   XNIVEL := 1

   qsay(10,21,FILIAL->Codigo)
   qsay(10,28,left(FILIAL->Razao,43))
   qsay(12,57,fCGCCPF)
        
   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return "" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// INICIALIZACAO DO PROCESSO DE GERACAO DA FICHA CADASTRAL EM DISQUETE ______

static function i_processa
   local AEDICAO3 := {}

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(AEDICAO3,{{ || qesco(-1,0,@cDRIVE,SBLOCO3                 )} , "DRIVE"    })
   aadd(AEDICAO3,{{ || lCONF := qconf("Confirma emiss„o do CAGED ?") },NIL})

   do while .T.

      qlbloc(5,0,"B490C","QBLOC.GLO")
      XNIVEL    := 1
      XFLAG     := .T.
      cFICHA    := ""
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

   // MONTA REGISTRO TIPO 1 ________________________________________________

   cFICHA := "1" + strzero(nSEQ,5) + FILIAL->Tipo_insc + FILIAL->Cgccpf + left(FILIAL->Razao,35) + left(FILIAL->Endereco,30) + strzero(FILIAL->Numero,5) + FILIAL->Bairro
   cFICHA += FILIAL->Cep + CGM->Estado + FILIAL->Telefone

   FILIAL->(dbclosearea())

   FICHACAD->(qappend())
   FICHACAD->Linha := cFICHA
   cFICHA := ""

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
         
         // MONTA REGISTRO TIPO 2 ____________________________________________

         CGM->(dbseek(FILIAL->Cgm))
         
         nSEQ++
         cFICHA := "2" + strzero(nSEQ,5) + FILIAL->Tipo_insc + FILIAL->Cgccpf + left(FILIAL->Razao,35) + left(FILIAL->Endereco,30) + strzero(FILIAL->Numero,5) + FILIAL->Bairro
         cFICHA += FILIAL->Cep + CGM->Estado + FILIAL->Telefone + qtiraponto(CONFIG->Cnae)

         FICHACAD->(qappend())
         FICHACAD->Linha := cFICHA
         cFICHA := ""

         // MONTA REGISTROS TIPO 3 ___________________________________________

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

            if empty(SITUA->Af_ini) .and. FUN->Data_adm < qinimes(XDATASYS)
               FUN->(dbskip())
               loop
            endif

            if ! empty(SITUA->Af_ini) .and. ! AFAST->Cod_caged $ "31-32-40-45-50-60-70-80"
               FUN->(dbskip())
               loop
            endif

            qsay(19,30,FUN->Matricula)
            qsay(19,39,FUN->Nome)

            nSEQ++
            cFICHA := "3" + strzero(nSEQ,5)
            cFICHA += left(FUN->Nome,20) + left(FUN->Nome_pai,20) + left(FUN->Nome_mae,20) + qtiraponto(dtoc(FUN->Data_nasc))
            CGM->(dbseek(FUN->Nat_cgm))
            cFICHA += left(CGM->Municipio,20) + CGM->Estado + FUN->Nacional + FUN->Sexo
            cFICHA += left(FUN->Endereco,25) + FUN->Bairro
            CGM->(dbseek(FUN->Resid_cgm))
            cFICHA += left(CGM->Municipio,20) + CGM->Estado + FUN->Cep + FUN->Cpf_num + FUN->Idt_num
            CGM->(dbseek(FUN->Idt_cgm))
            cFICHA += FUN->Idt_emi + CGM->Estado + qtiraponto(dtoc(FUN->Idt_dat))
            cFICHA += strzero(val(qtiraponto(FUN->Cp_num)),7) + strzero(val(FUN->Cp_serie),3) + qtiraponto(dtoc(FUN->Cp_emis))
            cFICHA += qtiraponto(dtoc(FUN->Data_adm)) + qtiraponto(dtoc(SITUA->Af_ini))
            CARGO->(dbseek(SITUA->Cargo))
            CBO->(dbseek(SITUA->Cbo))
            cFICHA += left(CARGO->Descricao,20) + left(CBO->Descricao,20) + FUN->Pis_num + qtiraponto(dtoc(FUN->Pis_dat))
            cFICHA += FUN->Instrucao + FUN->Hab_num
            if SITUA->Categoria == "1"
               cFICHA += strzero(val(qtiraponto(str(SITUA->Salario,9,2))),8)
            else
               cFICHA += strzero(val(qtiraponto(str((SITUA->Salario*FUN->Hor_trab),9,2))),8)
            endif
//          CCUSTO->(dbseek(FUN->Centro))
            CCUSTO->(dbseek(SITUA->Ccusto))
            cFICHA += SITUA->Categoria + left(CCUSTO->Descricao,20) + strzero(int(FUN->Hor_trab),3) + SITUA->Descanso

            FICHACAD->(qappend())
            FICHACAD->Linha := cFICHA
            cFICHA := ""

            nTOTFUN++
            nFUNGERAL++

            lNOVO := .F.

            FUN->(dbskip())

         enddo

         nTOTFIL++
         FILIAL->(dbskip())

      enddo

      CONFIG->(dbclosearea())

      AFAST->(dbclosearea())

      FUN->(dbclosearea())

      SITUA->(dbclosearea())

      FILIAL->(dbclosearea())

      CFGDISQ->(dbskip())
      
   enddo

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")
   
   cNOMARQ := cDRIVE + ":FICHA.TXT"

   FICHACAD->(dbgotop())

   FICHACAD->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

   qmensa()

   select CFGDISQ

   CFGDISQ->(dbgotop())

   if FICHACAD->(qflock())
      FICHACAD->(__dbzap())
   endif

return
