/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: INCLUSAO DE CONTAS A PAGAR
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO 2000
// OBS........:
// ALTERACOES.:

function pg201

#include "inkey.ch"
#include "setcurs.ch"

CCUSTO->(Dbsetorder(4))
BANCO->(dbsetorder(3))

private lCONF1
private lCONF2
private cDESC
public nVAL_LIQ
private cEMPRESA := " "

if ! quse(XDRV_CL,"CONFIG",{},,"FATCFG")
   qmensa("Nao foi possivel abrir CONFIG do FAT!","BL")
   return .F.
endif

cEMPRESA := FATCFG->Modelo_NF //Mayn - Agua mineral

FATCFG->(dbclosearea())

private sBLOC1  := qlbloc("B201D","QBLOC.GLO")

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private dDATA_VENC := ctod("")

// VIEW INICIAL _____________________________________________________________

PAGAR->(qview({{"Data_venc/Vcto"       ,2},;
               {"Cod_forn/Codigo"            ,3},;
               {"left(Fornec,25)/Fornecedor",10},;
               {"f_val3()/Valor Tit."        ,0},;
               {"f_val4()/Valor Liq."        ,0},;
               {"Duplicata/Duplicata"        ,0}},"P",;
               {NIL,"f201a",NIL,NIL},;
               NIL,"ESC/ALT-P/ALT-O/<I>nc/<A>lt/<E>xc/<C>on/<D>uplica/<P>arcial"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR ______________________________________

function f_201b
   FORN->(dbseek(PAGAR->Cod_forn))
return left(FORN->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_val3
return(transform(PAGAR->Valor,"@E 9999999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_val4
return(transform(PAGAR->Valor_liq,"@E 9999999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f201a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      iif(cEMPRESA == "01",qlbloc(06,02,"B201AMAY","QBLOC.GLO",1),qlbloc(05,02,"B201AMAY","QBLOC.GLO",1))
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif

   if cOPCAO = "D" ; i_duplica() ; endif
   if cOPCAO = "P" ; i_parcial() ; endif
   if cOPCAO = "T" ; i_transfere() ; endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local aEDICAO := {}
   local bESCAPE := {||empty(fEnviar).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   fDATA_LANC := XDATASYS

   // MONTA DADOS NA TELA ___________________________________________________

   aEdicao := {}

   if ! cOPCAO $ "I"
      XNIVEL := 1

     // if cEMPRESA == "01"
         sayMayn()
     // else
     //    sayAll()
     // endif

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

      //if cEMPRESA == "01"
         getMayn(aEDICAO)
      //else
      //   getAll(aEDICAO)
      //endif



   // INICIALIZACAO DA EDICAO _______________________________________________

   PAGAR->(qpublicfields())
   iif(cOPCAO=="I",PAGAR->(qinitfields()),PAGAR->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
   lCONF1 := .F.
   lCONF2 := .F.
   fEnviar := "S"
   if cOPCAO == "I"
      fDATA_LANC := date()
   endif

   if cOPCAO == "I"
      fCODIGO := strzero(CONFIG->Cod_pag + 1,7)
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PAGAR->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF2 ; return ; endif

   fVALOR_LIQ := fVALOR

   if PAGAR->(iif(cOPCAO=="I",qappend(),qrlock()))
      PAGAR->(qreplacefields())
      replace PAGAR->Fornec with fFORNEC
      PAGAR->(qunlock())
      if PAGAR->Contabil == .F. .and. PAGAR->Enviar == "S"
         i_contabil()
      endif
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Cod_pag with val(fCODIGO)
      CONFIG->(qunlock())
   endif


return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case

      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           fCODIGO := strzero(val(fCODIGO),7)
           qrsay(XNIVEL,fCODIGO)
           if PAGAR->(dbseek(fCODIGO))
              qmensa("Tipo de Documento j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "COD_FORN"
           qrsay(XNIVEL,fCOD_FORN:=strzero(val(fCOD_FORN),5))
           if ! FORN->(dbseek(fCOD_FORN))
              qmensa("Fornecedor n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(FORN->Razao,40))
              if empty(FORN->Conta_cont)
                 qmensa("Aten‡„o !! Conta Cont bil n„o Informada!","B")
              endif
           endif
           fFORNEC := FORN->Razao

      case cCAMPO == "FIXO"
           if empty(fFIXO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fFIXO,"SN",{"Sim","N„o"}))

      case cCAMPO == "ENVIAR"
           if empty(fEnviar) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fEnviar,"SN",{"Sim","N„o"}))


      case cCAMPO == "DATA_LANC"
           if empty(fDATA_LANC) ; return .F. ; endif

      case cCAMPO == "PREVISAO"
           if empty(fPREVISAO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fPREVISAO,"SN",{"Sim","N„o"}))


      case cCAMPO == "COD_PLAN"
           if ! empty(fCOD_PLAN)
              qrsay(XNIVEL,fCOD_PLAN := strzero(val(fCOD_PLAN),5))
              PLAN_FIN->(dbsetorder(3))
              if ! PLAN_FIN->(dbseek(fCOD_PLAN))
                 qmensa("Conta Financeira n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN_FIN->Descricao,25))
           else
              qmensa("Campo Obrigatorio!!","BL")
              return .F.
           endif

      case cCAMPO == "CONTA_CONT"
           if ! empty(fCONTA_CONT)
              qrsay(XNIVEL,fCONTA_CONT := strzero(val(fCONTA_CONT),6))
              PLAN->(dbsetorder(3))
              if ! PLAN->(dbseek(fCONTA_CONT))
                 qmensa("ZConta Contabil nao encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN->Descricao,25))
           else
              qmensa("Campo Obrigatorio!!","BL")
              return .F.
           endif


      case cCAMPO == "SETOR"

           if empty(fSETOR) ; return .T. ; endif

           qrsay(XNIVEL,fSETOR:=strzero(val(fSETOR),5))
           if ! SETOR->(dbseek(fSETOR))
              qmensa("Setor n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(SETOR->Descricao,25))
           endif

      case cCAMPO == "EVENTO"

           if empty(fEVENTO) ; return .T. ; endif

           qrsay(XNIVEL,fEVENTO:=strzero(val(fEVENTO),5))
           if ! EVENTOS->(dbseek(fEVENTO))
              qmensa("Evento n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(EVENTOS->Nome,35))
           endif
      case cCAMPO == "CENTRO"
           qrsay(XNIVEL,fCENTRO:=strzero(val(fCENTRO),4))
           if ! CCUSTO->(dbseek(fCENTRO))
              qmensa("Centro de Custo n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(CCUSTO->Descricao,40))

           endif
      case cCAMPO == "FILIAL"
           qrsay(XNIVEL,fFILIAL:=strzero(val(fFILIAL),4))
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o Cadastrada !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(FILIAL->Razao,40))
           endif

      case cCAMPO == "DATA_EMISS"
           if fDATA_EMISS == Ctod("00/00/00")
              qmensa("Data de emiss„o deve ser Informada !","B")
              qmensa("")
              Return .F.
          else
              Return .T.
          endif
      case cCAMPO == "DATA_CONT"
           if fDATA_CONT == Ctod("00/00/00")
              qmensa("Data Cont bil deve ser Informada !","B")
              qmensa("")
              fDATA_CONT := fDATA_LANC
              Return .F.
          else
              Return .T.
          endif


      case cCAMPO == "TIPO_SUB"
           if empty(fTIPO_SUB) ; return .F. ; endif
           qrsay(XNIVEL,fTIPO_SUB:=strzero(val(fTIPO_SUB),6))
           if ! TIPOCONT->(dbseek(fTIPO_SUB))
              qmensa("Tipo e Sub-Tipo n„o encontrado !","B")
              return .F.
           endif
           if ! TIPOCONT->Motivo $ "23"
              qmensa("Este Tipo Cont bil n„o ‚ de Pagamento...","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,46))

      case cCAMPO == "SITUACAO"
           qrsay(XNIVEL,fSITUACAO:=strzero(val(fSITUACAO),2))
           if ! SITUA->(dbseek(fSITUACAO))
              qmensa("Situacao n„o Cadastrada !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(SITUA->Descricao,28))
           endif

      case cCAMPO == "FATURA"
           if empty(fFATURA) .and. TIPOCONT->Nota_fisc == "1"
              qmensa("Campo obrigat¢rio...","B")
              return .F.
           endif

      case cCAMPO == "CGM"
           qrsay(XNIVEL,fCGM:=strzero(val(fCGM),6))
           if ! CGM->(dbseek(fCGM))
              qmensa("Praca n„o Cadastrada !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(CGM->Municipio,40))
           endif

      case cCAMPO == "ESPECIE"
           qrsay(XNIVEL,fESPECIE := strzero(val(fESPECIE),2))
           if ! ESPECIE->(dbseek(fESPECIE))
              qmensa("Esp‚cie Inv lida !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(ESPECIE->Descricao,11))
           endif

      case cCAMPO == "TIPO_DOC"
           qrsay(XNIVEL,fTIPO_DOC := strzero(val(fTIPO_DOC),2))
           if ! TIPO_DOC->(dbseek(fTIPO_DOC))
              qmensa("Tipo de Documento inv lido !","B")
              return .F.
           else
              qrsay(XNIVEL+1,TIPO_DOC->Descricao)
           endif

      case cCAMPO == "SERIE"
           if empty(fSERIE) ; return .T. ; endif

           qrsay(XNIVEL,fSERIE := strzero(val(fSERIE),2))
           if ! SERIE->(dbseek(fSERIE))
              qmensa("S‚rie Inv lida !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(SERIE->Descricao,11))
           endif

      case cCAMPO == "VALOR"
           if fVALOR == 0
              qmensa("Valor do lancamento deve ser Informado...","B")
              qmensa("")
              Return .F.
           else
              Return .T.
           endif

      case cCAMPO == "DATA_VENC"

           if fDATA_VENC < fDATA_LANC
              qmensa("Data do Vencimento Inferior a do Lan‡amento !","B")
              return .F.
           endif

      case cCAMPO == "COD_BANCO"

           if ! empty(fCOD_BANCO)
              qrsay(XNIVEL,fCOD_BANCO:=strzero(val(fCOD_BANCO),5) )
              if ! BANCO->(dbseek(fCOD_BANCO))
                 qmensa("Banco n„o Encontrado !","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,BANCO->Descricao)
              endif
           endif

      case cCAMPO == "COMPLEM"
           if lCONF1
              i_tela_2()
              iif(empty(CONFIG->Remoplast),XNIVEL := 40,XNIVEL := 23)
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CONTAS A PAGAR _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Conta … Pagar ?")

      if PAGAR->(qrlock())
         PAGAR->(dbdelete())
         PAGAR->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESDOBRAMENTO DO LANCAMENTO DE CONTAS A PAGAR ________________

function i_desdobra

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private lPRI_LANC  := .T.
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := PAGAR->Valor

   qlbloc(11,02,"B201B","QBLOC.GLO",1)

   do while .T.

      qsay ( 12,17 , PAGAR->Codigo       ) ; FORN->(Dbseek(PAGAR->Cod_forn))
      qsay ( 13,17 , left(FORN->Razao,40))
      qsay ( 15,22 , transform(PAGAR->Valor, "@E 9,999,999.99"))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_1( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif

      if lPRI_LANC

         if PAGAR->(qrlock())
            replace PAGAR->Data_venc    with dDATA_VENC
            replace PAGAR->Valor        with nVALOR
            replace PAGAR->Valor_liq    with nVALOR
         else
            iif(cOPCAO=="I",qm1(),qm2())
         endif

         PAGAR->(qunlock())

         lPRI_LANC := .F.

      else

         PAGAR->(qpublicfields())
         PAGAR->(qcopyfields())

         if CONFIG->(qrlock()) .and. PAGAR->(qflock()) .and. PAGAR->(qappend())

            replace CONFIG->Cod_pag with CONFIG->Cod_pag + 1

            fCODIGO    := strzero(CONFIG->Cod_pag,7)
            fDATA_VENC := dDATA_VENC
            fVALOR     := nVALOR
            fVALOR_LIQ := nVALOR

            PAGAR->(qreplacefields())

            PAGAR->(qunlock())

            qmensa("C¢digo Gerado: "+fCODIGO,"B")

         endif

      endif

      qsay ( 15,50 , transform(nVAL_DES, "@E 9,999,999.99"))

      if nVAL_DES = nVAL_INI
         exit
      endif

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}

   enddo

return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_1 ( cCAMPO )

   do case

      case cCAMPO == "DATA_VENC"

           if dDATA_VENC < PAGAR->Data_venc
              qmensa("Data do Vencimento deve ser Superior !","B")
              return .F.
           endif

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif

           nVAL_DES := nVAL_DES + nVALOR

           if nVAL_DES > nVAL_INI
              qmensa("Valor do desdobramento superou o valor do pagamento !", "B")
              nVAL_DES := nVAL_DES - nVALOR
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESDOBRAMENTO DO LANCAMENTO DE CONTAS A PAGAR ________________

function i_parcial

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := PAGAR->Valor

   qlbloc(11,02,"B201E","QBLOC.GLO",1)

 //  do while .T.

      qsay ( 12,17 , PAGAR->Codigo       ) ; FORN->(Dbseek(PAGAR->Cod_forn))
      qsay ( 13,17 , left(FORN->Razao,40))
  //    qsay ( 15,22 , transform(PAGAR->Valor, "@E 9,999,999.99"))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_2( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif



      if PAGAR->(qrlock())
       //  replace PAGAR->Data_venc    with dDATA_VENC
         replace PAGAR->Valor_liq    with (PAGAR->Valor - nVALOR)
         replace PAGAR->Valor        with (PAGAR->Valor - nVALOR)

      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      PAGAR->(qunlock())


      PAGAR->(qpublicfields())
      PAGAR->(qcopyfields())

      if CONFIG->(qrlock()) .and. PAGAR->(qflock()) .and. PAGAR->(qappend())

         replace CONFIG->Cod_pag with CONFIG->Cod_pag + 1

         fCODIGO    := strzero(CONFIG->Cod_pag,7)
         fDATA_VENC := dDATA_VENC
         fVALOR     := nVALOR
         fVALOR_LIQ := nVALOR
         PAGAR->(qreplacefields())

         PAGAR->(qunlock())

         qmensa("C¢digo Gerado: "+fCODIGO,"B")

      endif



     // qsay ( 15,50 , transform(nVAL_DES, "@E 9,999,999.99"))

//      if nVAL_DES = nVAL_INI
//         exit
//      endif

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}

//   enddo

return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_2 ( cCAMPO )

   do case

      case cCAMPO == "DATA_VENC"

           if dDATA_VENC < PAGAR->Data_venc
              qmensa("Data do Vencimento deve ser Superior !","B")
              return .F.
           endif

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif

           nVAL_DES := nVAL_DES + nVALOR

           if nVAL_DES > nVAL_INI
              qmensa("Valor Parcial superou o valor do pagamento !", "B")
              nVAL_DES := nVAL_DES - nVALOR
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_tela_2

   local aEDICAO2 := {}

   private nNIVEL

   XNIVEL := nNIVEL

   // MONTA DADOS NA TELA ___________________________________________________

   qlbloc(05,02,"B201C","QBLOC.GLO",1)

   TIPOCONT->(dbseek(fTIPO_SUB))

   if ! empty(TIPOCONT->Hi_comp1)
      HIST->(dbseek(TIPOCONT->Hi_comp1))
      cDESC_1 := left(HIST->Descricao,41)
   else
      cDESC_1 := TIPOCONT->Hi_comp1
   endif

   if ! empty(TIPOCONT->Hi_comp2)
      HIST->(dbseek(TIPOCONT->hi_comp2))
      cDESC_2 := left(HIST->Descricao,41)
   else
      cDESC_2 := TIPOCONT->hi_comp2
   endif

   if ! empty(TIPOCONT->Hi_comp3)
      HIST->(dbseek(TIPOCONT->hi_comp3))
      cDESC_3 := left(HIST->Descricao,41)
   else
      cDESC_3 := TIPOCONT->hi_comp3
   endif

   if ! empty(TIPOCONT->Hi_comp4)
      HIST->(dbseek(TIPOCONT->hi_comp4))
      cDESC_4 := left(HIST->Descricao,41)
   else
      cDESC_4 := TIPOCONT->hi_comp4
   endif

   if ! empty(TIPOCONT->Hi_comp5)
      HIST->(dbseek(TIPOCONT->hi_comp5))
      cDESC_5 := left(HIST->Descricao,41)
   else
      cDESC_5 := TIPOCONT->hi_comp5
   endif

   if ! empty(TIPOCONT->Hi_comp6)
      HIST->(dbseek(TIPOCONT->hi_comp6))
      cDESC_6 := left(HIST->Descricao,41)
   else
      cDESC_6 := TIPOCONT->hi_comp6
   endif

   if ! empty(TIPOCONT->Hi_comp7)
      HIST->(dbseek(TIPOCONT->hi_comp7))
      cDESC_7 := left(HIST->Descricao,41)
   else
      cDESC_7 := TIPOCONT->hi_comp7
   endif

   if ! empty(TIPOCONT->Hi_comp8)
      HIST->(dbseek(TIPOCONT->hi_comp8))
      cDESC_8 := left(HIST->Descricao,41)
   else
      cDESC_8 := TIPOCONT->hi_comp8
   endif

   if ! empty(TIPOCONT->Hi_comp9)
      HIST->(dbseek(TIPOCONT->hi_comp9))
      cDESC_9 := left(HIST->Descricao,41)
   else
      cDESC_9 := TIPOCONT->hi_comp9
   endif

   if ! empty(TIPOCONT->Hi_comp10)
      HIST->(dbseek(TIPOCONT->hi_comp10))
      cDESC_10 := left(HIST->Descricao,41)
   else
      cDESC_10 := TIPOCONT->hi_comp10
   endif

   if ! empty(TIPOCONT->Hi_comp11)
      HIST->(dbseek(TIPOCONT->hi_comp11))
      cDESC_11 := left(HIST->Descricao,41)
   else
      cDESC_11 := TIPOCONT->hi_comp11
   endif

   if ! empty(TIPOCONT->Hi_comp12)
      HIST->(dbseek(TIPOCONT->hi_comp12))
      cDESC_12 := left(HIST->Descricao,41)
   else
      cDESC_12 := TIPOCONT->hi_comp12
   endif

   if ! empty(TIPOCONT->Hi_comp13)
      HIST->(dbseek(TIPOCONT->hi_comp13))
      cDESC_13 := left(HIST->Descricao,41)
   else
      cDESC_13 := TIPOCONT->hi_comp13
   endif

   qsay  ( 8 ,15, cDESC_1 )
   qsay  ( 9 ,15, cDESC_2 )
   qsay  ( 10,15, cDESC_3 )
   qsay  ( 11,15, cDESC_4 )
   qsay  ( 12,15, cDESC_5 )
   qsay  ( 13,15, cDESC_6 )
   qsay  ( 14,15, cDESC_7 )
   qsay  ( 15,15, cDESC_8 )
   qsay  ( 16,15, cDESC_9 )
   qsay  ( 17,15, cDESC_10 )
   qsay  ( 18,15, cDESC_11 )
   qsay  ( 19,15, cDESC_12 )
   qsay  ( 20,15, cDESC_13 )

   if cOPCAO <> "I"
      nNIVEL := 1
      qrsay ( nNIVEL++ , PAGAR->Valor_1  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_2  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_3  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_4  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_5  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_6  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_7  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_8  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_9  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_10 , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_11 , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_12 , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , PAGAR->Valor_13 , "@E 9,999,999.99" )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_1 , "@E 9,999,999.99")},"VALOR_1"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_2 , "@E 9,999,999.99")},"VALOR_2"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_3 , "@E 9,999,999.99")},"VALOR_3"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_4 , "@E 9,999,999.99")},"VALOR_4"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_5 , "@E 9,999,999.99")},"VALOR_5"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_6 , "@E 9,999,999.99")},"VALOR_6"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_7 , "@E 9,999,999.99")},"VALOR_7"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_8 , "@E 9,999,999.99")},"VALOR_8"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_9 , "@E 9,999,999.99")},"VALOR_9"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_10 , "@E 9,999,999.99")},"VALOR_10"})
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_11 , "@E 9,999,999.99")},"VALOR_11"})
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_12 , "@E 9,999,999.99")},"VALOR_12"})
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_13 , "@E 9,999,999.99")},"VALOR_13"})

   nNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while nNIVEL >= 1 .and. nNIVEL <= len(aEDICAO2)
      XNIVEL := nNIVEL
      eval ( aEDICAO2[nNIVEL,1] )
      if ! i_crit2( aEDICAO2[nNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , nNIVEL++ , nNIVEL-- )
   enddo

   nVAL_LIQ := fVALOR

   if TIPOCONT->Fu_comp1 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_1
   endif
   if TIPOCONT->Fu_comp1 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_1
   endif

   if TIPOCONT->Fu_comp2 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_2
   endif
   if TIPOCONT->Fu_comp2 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_2
   endif

   if TIPOCONT->Fu_comp3 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_3
   endif
   if TIPOCONT->Fu_comp3 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_3
   endif

   if TIPOCONT->Fu_comp4 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_4
   endif
   if TIPOCONT->Fu_comp4 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_4
   endif

   if TIPOCONT->Fu_comp5 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_5
   endif
   if TIPOCONT->Fu_comp5 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_5
   endif

   if TIPOCONT->Fu_comp6 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_6
   endif
   if TIPOCONT->Fu_comp6 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_6
   endif

   if TIPOCONT->Fu_comp7 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_7
   endif
   if TIPOCONT->Fu_comp7 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_7
   endif

   if TIPOCONT->Fu_comp8 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_8
   endif
   if TIPOCONT->Fu_comp8 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_8
   endif

   if TIPOCONT->Fu_comp9 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_9
   endif
   if TIPOCONT->Fu_comp9 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_9
   endif

   if TIPOCONT->Fu_comp10 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_10
   endif
   if TIPOCONT->Fu_comp10 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_10
   endif

   if TIPOCONT->Fu_comp11 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_11
   endif
   if TIPOCONT->Fu_comp11 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_11
   endif

   if TIPOCONT->Fu_comp12 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_12
   endif
   if TIPOCONT->Fu_comp12 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_12
   endif

   if TIPOCONT->Fu_comp13 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_13
   endif
   if TIPOCONT->Fu_comp13 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_13
   endif

   fVALOR_LIQ := nVAL_LIQ

   qsay  ( 22,65, nVAL_LIQ , "@E 9,999,999.99" )

// inkey(3)

return .T.

///////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CRITICAS LANCAMENTOS COMPLEMENTARES ________________________
static function i_crit2 ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "VALOR_1"
           if empty(cDESC_1) ; nNIVEL := 41 ; endif
//         i_hist("PAGAR","Hi_comp1")
      case cCAMPO == "VALOR_2"
           if empty(cDESC_2) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_3"
           if empty(cDESC_3) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_4"
           if empty(cDESC_4) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_5"
           if empty(cDESC_5) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_6"
           if empty(cDESC_6) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_7"
           if empty(cDESC_7) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_8"
           if empty(cDESC_8) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_9"
           if empty(cDESC_9) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_10"
           if empty(cDESC_10) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_11"
           if empty(cDESC_11) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_12"
           if empty(cDESC_12) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_13"
           if empty(cDESC_13) ; nNIVEL := 41 ; endif
   endcase
return .T.

///////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INCLUIR O LCTO CONTABIL PARA LIQUIDACAO ____________________
static function i_contabil

     if PAGAR->(qrlock())
        replace PAGAR->Contabil with .T.
     endif

     fu_abre_prov()

     if SH_PROCT->(qappend())

        replace SH_PROCT->Data_lanc   with  PAGAR->Data_emiss

        FORN->(dbseek(PAGAR->Cod_forn))
        replace SH_PROCT->Cont_cr with FORN->Conta_cont
        replace SH_PROCT->Cont_db with PAGAR->Conta_cont

        replace SH_PROCT->Filial     with  "0001"
        replace SH_PROCT->Centro     with  "0001"

        replace SH_PROCT->Valor      with  PAGAR->Valor
        replace SH_PROCT->Num_doc    with  PAGAR->Fatura
        replace SH_PROCT->Num_lote   with  "PG" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
        replace SH_PROCT->Historico  with "VR NF "+ left(PAGAR->Fatura,9) + " " + left(FORN->Razao,35)


        if CONFIG->(qrlock())
           replace CONFIG->Num_lote with (CONFIG->Num_lote + 1)
           CONFIG->(qunlock())
        endif

     endif

     SH_PROCT->(dbclosearea())

     select PAGAR


return

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
function monta_hist(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       FORN->(dbgotop())
       do case
          case substr(nHIST,nPOS,2) == "CA"
               FORN->(Dbseek((cARQ)->Cod_forn))
               replace SH_PROCT->Ca with left(FORN->Razao,40)
          case substr(nHIST,nPOS,3) == "CGC"
               FORN->(Dbseek((cARQ)->Cod_forn))
               replace SH_PROCT->Cgc with FORN->Cgccpf
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_PROCT->Dp with (cARQ)->Fatura
               replace SH_PROCT->Fa with (cARQ)->Fatura
               replace SH_PROCT->Nf with (cARQ)->Fatura
          case substr(nHIST,nPOS,2) == "EP"
               ESPECIE->(Dbseek((cARQ)->Especie))
               replace SH_PROCT->Ep with left(ESPECIE->Descricao,3)
          case substr(nHIST,nPOS,2) == "SE"
               SERIE->(Dbseek((cARQ)->Serie))
               replace SH_PROCT->Se with left(SERIE->Descricao,3)
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next

return

/////////////////////////
function Mostra_hist
   local nCONT, cHIST := ""
   local sBLOC := qsbloc(09,04,19,77)

   qlbloc(09,04,"B201E","QBLOC.GLO",1)

   HIST->(dbseek(LANC->Hp1)) ; cHIST += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp2)) ; cHIST += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp3)) ; cHIST += alltrim(HIST->Descricao) + " "

   cHIST += PAGAR->Historico

   for nCONT := 1 to 6
       qsay(nCONT+11,6,subs(cHIST,(nCONT-1)*67+1,67))
   next

   qwait()

   qrbloc(09,04,sBLOC)

return

///////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A MONTAGEM DO HISTORICO PADRAO _______

function i_hist(cARQ,cVARIA)

   TIPOCONT->(dbseek((cARQ)->Tipo_sub))
   HIST->(dbseek(TIPOCONT->&cVARIA))
   nHIST := HIST->Descricao

   nHISTORICO := ""

   for nCONT := 1 to len(nHIST)

       if ( nPOS := at("[",nHIST) )  <> 0

          iif(nPOS <> 1 ,nHISTORICO += substr(nHIST,1,nPOS-1),)

          nPOS += 2  // para ignorar os simbolos [@

          do case

             case substr(nHIST,nPOS,2) == "CA"
                  nHISTORICO += left(FORN->Razao,30) + " "
             case substr(nHIST,nPOS,3) == "CGC"
                  nHISTORICO += transform(FORN->Cgc,"@R 99.999.999/9999-99") + " "
             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO += dtos((cARQ)->Da)    + " "
             case substr(nHIST,nPOS,2) == "DP"
                  nHISTORICO += alltrim((cARQ)->Dp) + " "
             case substr(nHIST,nPOS,2) == "FA"
                  nHISTORICO += alltrim((cARQ)->Fa) + " "
             case substr(nHIST,nPOS,2) == "NF"
                  nHISTORICO += alltrim((cARQ)->Fatura) + " "
             case substr(nHIST,nPOS,2) == "EP"
                  nHISTORICO += alltrim((cARQ)->Ep) + " "
             case substr(nHIST,nPOS,2) == "SE"
                  nHISTORICO += alltrim((cARQ)->Se) + " "
             case substr(nHIST,nPOS,2) == "BC"
                  nHISTORICO += alltrim((cARQ)->Bc) + " "
             case substr(nHIST,nPOS,2) == "CH"
                  nHISTORICO += alltrim((cARQ)->Ch) + " "
             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO += alltrim((cARQ)->Da) + " "
             case substr(nHIST,nPOS,2) == "HO"
                  nHISTORICO += alltrim((cARQ)->Ho) + " "
             case substr(nHIST,nPOS,2) == "HP"
                  nHISTORICO += alltrim((cARQ)->Hp) + " "
             case substr(nHIST,nPOS,2) == "ND"
                  nHISTORICO += alltrim((cARQ)->Nd) + " "
             case substr(nHIST,nPOS,2) == "NT"
                  nHISTORICO += alltrim((cARQ)->Nt) + " "
             case substr(nHIST,nPOS,2) == "PC"
                  nHISTORICO += alltrim((cARQ)->Pc) + " "
          endcase

          nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

       else

         exit

       endif

   next
Mostra_hist()
return

static function i_transfere
   local lCONF

   lCONF := qconf("Confirma Transferencia p/ Arquivo Morto ?")

   if lCONF

      if ! PAGAR->(qflock()) .and. ! PAGAR2->(qflock())
         qmensa("N„o foi Poss¡vel Transferir !","B")
         return
      endif
      PAGAR->(qpublicfields())
      PAGAR->(qcopyfields())
      PAGAR2->(qappend())
      fDATA_PAGTO := date()
      PAGAR2->(qreplacefields())

      PAGAR->(dbdelete())
      PAGAR->(qunlock())
      PAGAR2->(qunlock())

   endif
return

function complementares (nCAMPO,nNUM,cARQ)  // nCAMPO == codigo do historio / nNUM = numero do campo / cARQ = arquivo a ser contabilizado
local zNUM  := 0
local cVALOR := ""

    if TIPOCONT->Motivo == "2" // pagamento

       if SH_PROCT->(qappend())
          cVALOR := "PAGAR->Valor_"+nNUM
          replace SH_PROCT->Data_lanc   with  (cARQ)->Data_lanc
          replace SH_PROCT->Valor       with  &cVALOR

          nCONTA := "TIPOCONT->Ct_liq_" + nNUM
          zNUM := val(nNUM)

          if &nCONTA == "1"

             nCONTA  := "TIPOCONT->Ct_comp" + nNUM
             nCONTA1 := "TIPOCONT->Ct_comp" + alltrim(str(zNUM+1))
             zHIST   := "TIPOCONT->Hi_comp" + nNUM
             zHIST1  := "TIPOCONT->Hi_comp" + alltrim(str(zNUM+1))

             if &zHIST == &zHIST1
                if TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_PROCT->Cont_db with &nCONTA
                     replace SH_PROCT->Cont_cr with &nCONTA1
                     nCONTADOR++
                else
                     replace SH_PROCT->Cont_cr with &nCONTA
                     replace SH_PROCT->Cont_db with &nCONTA1
                     nCONTADOR++
                endif
             else
                do case
                  case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                       replace SH_PROCT->Cont_db with &nCONTA
                  case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                       replace SH_PROCT->Cont_cr with &nCONTA
                  otherwise
                       replace SH_PROCT->Cont_db with &nCONTA
               endcase
            endif

          endif

          replace SH_PROCT->Filial     with  (cARQ)->Filial
          replace SH_PROCT->Num_doc    with  (cARQ)->Fatura

          replace SH_PROCT->Num_lote   with  "PG" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_PROCT->Cod_hist   with  &nCAMPO

          monta_hist((cARQ),nHISTORICO)

       endif

    endif


return

static function i_duplica

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private cHIST      := space(30)
   private cFATURA    := space(8)
   private lPRI_LANC  := .T.
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := PAGAR->Valor

   qlbloc(11,02,"B201E","QBLOC.GLO",1)

  // do while .T.

      qsay ( 12,17 , PAGAR->Codigo       ) ; FORN->(Dbseek(PAGAR->Cod_forn))
      qsay ( 13,17 , left(FORN->Razao,40))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_dup( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif


      PAGAR->(qunlock())


      PAGAR->(qpublicfields())
      PAGAR->(qcopyfields())

      if CONFIG->(qrlock()) .and. PAGAR->(qflock()) .and. PAGAR->(qappend())

         replace CONFIG->Cod_pag with CONFIG->Cod_pag + 1

         fCODIGO    := strzero(CONFIG->Cod_pag,7)
         fDATA_VENC := dDATA_VENC
         fVALOR     := nVALOR
         fVALOR_LIQ := nVALOR
         fHISTORICO := cHIST
         fFATURA    := cFATURA
         fDUPLICATA := cFATURA
         PAGAR->(qreplacefields())

         qmensa("C¢digo Gerado: "+fCODIGO,"B")

      endif

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}


return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_dup ( cCAMPO )

   do case

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif

           nVAL_DES := nVAL_DES + nVALOR

   endcase

return .T.


static function sayAll

    qrsay ( XNIVEL++ , PAGAR->Codigo       )
    qrsay ( XNIVEL++ , qabrev(PAGAR->Fixo,"SN", {"Sim","N„o"}))
    qrsay ( XNIVEL++ , PAGAR->Data_lanc    )
    qrsay ( XNIVEL++ , qabrev(PAGAR->Previsao,"SN", {"Sim","N„o"}))
    qrsay ( XNIVEL++ , PAGAR->Setor     ) ; SETOR->(dbseek(PAGAR->Setor))
    qrsay ( XNIVEL++ , left(SETOR->Descricao,32))
    qrsay ( XNIVEL++ , PAGAR->Cod_forn     ) ; FORN->(dbseek(PAGAR->Cod_forn))
    qrsay ( XNIVEL++ , left(FORN->Razao,40))
    if empty(CONFIG->Remoplast)
       qrsay ( XNIVEL++ , PAGAR->Centro       ) ; CCUSTO->(dbseek(PAGAR->Centro))
       qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
       qrsay ( XNIVEL++ , PAGAR->Filial       ) ; FILIAL->(dbseek(PAGAR->Filial))
       qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
    endif
    qrsay ( XNIVEL++ , PAGAR->Data_emiss   )
    if empty(CONFIG->Remoplast)
       qrsay ( XNIVEL++ , PAGAR->Projet       ) ; PROJET->(dbseek(PAGAR->Projet))
       qrsay ( XNIVEL++ , left(PROJET->Descricao,18))
       qrsay ( XNIVEL++ , PAGAR->Evento       ) ; EVENTOS->(dbseek(PAGAR->Evento))
       qrsay ( XNIVEL++ , left(EVENTOS->Nome,25)  )
       qrsay ( XNIVEL++ , PAGAR->Especie      ) ; ESPECIE->(dbseek(PAGAR->Especie))
       qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
       qrsay ( XNIVEL++ , PAGAR->Serie        ) ; SERIE->(dbseek(PAGAR->Serie))
       qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
       qrsay ( XNIVEL++ , PAGAR->Tipo_sub     ) ; TIPOCONT->(dbseek(PAGAR->Tipo_sub) )
       qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
    endif
    qrsay ( XNIVEL++ , left(PAGAR->Historico,60))
    qrsay ( XNIVEL++ , PAGAR->Data_venc    )
    qrsay ( XNIVEL++ , PAGAR->Data_prorr   )
    qrsay ( XNIVEL++ , transform(PAGAR->Valor,"@E 9,999,999.99"     ))
    qrsay ( XNIVEL++ , PAGAR->Tipo_doc     ) ; TIPO_DOC->(dbseek(PAGAR->Tipo_doc))
    qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
    qrsay ( XNIVEL++ , PAGAR->Fatura       )
    qrsay ( XNIVEL++ , PAGAR->Duplicata    )
    qrsay ( XNIVEL++ , PAGAR->Cgm          ) ; CGM->(dbseek(PAGAR->Cgm))
    qrsay ( XNIVEL++ , left(CGM->Municipio,40))
    qrsay ( XNIVEL++ , PAGAR->Cod_Banco    ) ; BANCO->(Dbseek(PAGAR->Cod_banco))
    qrsay ( XNIVEL++ , BANCO->Descricao      )
    qrsay ( XNIVEL++ , PAGAR->Situacao     ) ; SITUA->(dbseek(PAGAR->Situacao))
    qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
    qrsay ( XNIVEL++ , PAGAR->Data_cont    )
    qrsay ( XNIVEL++ , left(PAGAR->Observacao,59))


return


static function sayMayn

    qrsay ( XNIVEL++ , PAGAR->Codigo       )
    qrsay ( XNIVEL++ , qabrev(PAGAR->Enviar,"SN", {"Sim","Nao"}))
    qrsay ( XNIVEL++ , PAGAR->Data_lanc    )
   // qrsay ( XNIVEL++ , qabrev(PAGAR->Previsao,"SN", {"Sim","N„o"}))
    qrsay ( XNIVEL++ , PAGAR->Cod_forn     ) ; FORN->(dbseek(PAGAR->Cod_forn))
    qrsay ( XNIVEL++ , left(FORN->Razao,40))

    PLAN_FIN->(dbsetorder(3))
    qrsay ( XNIVEL++ , PAGAR->Cod_plan    ) ; PLAN_FIN->(dbseek(PAGAR->Cod_plan))
    qrsay ( XNIVEL++ , left(PLAN_FIN->Descricao,40))

    PLAN->(dbsetorder(3))
    qrsay ( XNIVEL++ , PAGAR->Conta_cont   ) ; PLAN->(dbseek(PAGAR->Conta_cont))
    qrsay ( XNIVEL++ , left(PLAN->Descricao,46))


    qrsay ( XNIVEL++ , PAGAR->Data_emiss   )

   // qrsay ( XNIVEL++ , PAGAR->Especie      ) ; ESPECIE->(dbseek(PAGAR->Especie))
   // qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
   // qrsay ( XNIVEL++ , PAGAR->Serie        ) ; SERIE->(dbseek(PAGAR->Serie))
   // qrsay ( XNIVEL++ , left(SERIE->Descricao,11))

    qrsay ( XNIVEL++ , left(PAGAR->Historico,60))
    qrsay ( XNIVEL++ , PAGAR->Data_venc    )
    qrsay ( XNIVEL++ , transform(PAGAR->Valor,"@E 9,999,999.99"     ))
    qrsay ( XNIVEL++ , PAGAR->Fatura       )
   //qrsay ( XNIVEL++ , PAGAR->Duplicata    )
    qrsay ( XNIVEL++ , left(PAGAR->Observacao,59))

return


static function getAll(aEdicao)

   aadd(aEDICAO,{{ || NIL }                                         ,NIL         })  // codigo nao pode ser editado
   aadd(aEDICAO,{{ || qesco(-1,0,@fFIXO ,sBLOC1                  )} ,"FIXO"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC                    ) } ,"DATA_LANC" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fPREVISAO,sBLOC1              )} ,"PREVISAO"   })
   aadd(aEDICAO,{{ || view_set(-1,0,@fSETOR                     ) } ,"SETOR"     })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || view_forn(-1,0,@fCOD_FORN                 ) } ,"COD_FORN"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   if empty(CONFIG->Remoplast)
      aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO                ) } ,"CENTRO"     })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
      aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL                 ) } ,"FILIAL"    })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   endif
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMISS                   ) } ,"DATA_EMISS"})
   if empty(CONFIG->Remoplast)
      aadd(aEDICAO,{{ || view_proj(-1,0,@fPROJET                 ) } ,"PROJET"  })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
      aadd(aEDICAO,{{ || view_eve(-1,0,@fEVENTO               ) } ,"EVENTO" })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
      aadd(aEDICAO,{{ || view_especie(-1,0,@fESPECIE               ) } ,"ESPECIE"   })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
      aadd(aEDICAO,{{ || view_serie(-1,0,@fSERIE                   ) } ,"SERIE"     })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
      aadd(aEDICAO,{{ || view_tipo(-1,0,@fTIPO_SUB                 ) } ,"TIPO_SUB"  })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   endif
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO,"@!@S60"           ) } ,"HISTORICO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_VENC                    ) } ,"DATA_VENC" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_PRORR                   ) } ,"DATA_PRORR"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    ,"@E 9,999,999.99"  ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || view_doc(-1,0,@fTIPO_DOC                  ) } ,"TIPO_DOC"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFATURA,"@!"                  ) } ,"FATURA"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDUPLICATA,"@!"               ) } ,"DUPLICATA"})
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM                     ) } ,"CGM"     })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_BANCO               ) } ,"COD_BANCO" })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || view_situa(-1,0,@fSITUACAO                ) } ,"SITUACAO"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_CONT                   ) } ,"DATA_CONT"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBSERVACAO,"@!@S59"          ) } ,"OBSERVACAO"})

   aadd(aEDICAO,{{ || lCONF1 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" de Lan‡amentos Complementares ?") },"COMPLEM"})
   aadd(aEDICAO,{{ || lCONF2 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

return


static function getMayn(aEDICAO)

   aadd(aEDICAO,{{ || NIL }                                         ,NIL         })  // codigo nao pode ser editado
   aadd(aEDICAO,{{ || qesco(-1,0,@fENVIAR,sBLOC1                  )} ,"ENVIAR"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC                    ) } ,"DATA_LANC" })
   //aadd(aEDICAO,{{ || qesco(-1,0,@fPREVISAO,sBLOC1              )} ,"PREVISAO" })
   aadd(aEDICAO,{{ || view_forn(-1,0,@fCOD_FORN                 ) } ,"COD_FORN"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })

   aadd(aEDICAO,{{ || view_planfin(-1,0,@fCOD_PLAN              ) } ,"COD_PLAN"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })

   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONT               ) } ,"CONTA_CONT" })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMISS                   ) } ,"DATA_EMISS"})
//   aadd(aEDICAO,{{ || view_especie(-1,0,@fESPECIE               ) } ,"ESPECIE"   })
//   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
//   aadd(aEDICAO,{{ || view_serie(-1,0,@fSERIE                   ) } ,"SERIE"     })
//   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO,"@!@S60"           ) } ,"HISTORICO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_VENC                    ) } ,"DATA_VENC" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    ,"@E 9,999,999.99"  ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFATURA,"@!"                  ) } ,"FATURA"    })
//   aadd(aEDICAO,{{ || qgetx(-1,0,@fDUPLICATA,"@!"               ) } ,"DUPLICATA"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBSERVACAO,"@!@S59"          ) } ,"OBSERVACAO"})

//   aadd(aEDICAO,{{ || lCONF1 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" de Lan‡amentos Complementares ?") },"COMPLEM"})
   aadd(aEDICAO,{{ || lCONF2 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})


return






