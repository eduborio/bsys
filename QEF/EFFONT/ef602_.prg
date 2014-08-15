/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: INTERFACE P/ CONTABILIDADE POR CENTRO DE CUSTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2000
// OBS........:
// ALTERACOES.:
function ef602

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := { || ( XNIVEL==1 .and. !XFLAG ) .or. ( XNIVEL==1 .and. lastkey()==27 ) }

private dINI          // periodo inicial
private dFIM          // periodo final
private nVAL    := 0
private aEDICAO := {} // vetor para os campos de entrada de dados
private lCONF
private nNUM_LANC
private nCONTADOR := 0

if ! quse("","QCONFIG")  // abre o arquivo QCONFIG para ler a sigla do sistema
   qmensa("N�o foi possivel abrir QCONFIG.DBF... Tente Novamente...","B")
   return
endif

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)}          , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)}          , "FIM"    })
aadd(aEDICAO,{{ || lCONF := qconf("Confirma interface com a Contabilidade ?") },NIL})

qlbloc(5,0,"B602A","QBLOC.GLO")
XNIVEL := 1
XFLAG  := .T.
dINI   := ctod("")
dFIM   := ctod("")

// SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
   eval ( aEDICAO [XNIVEL,1] )
   if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
   if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
   iif ( XFLAG , XNIVEL++ , XNIVEL-- )
enddo

if ! lCONF ; return ; endif

i_interface2()

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "INI"
           if empty(dINI) ; return .F. ; endif
      case cCAMPO == "FIM"
           if dFIM < dINI ; return .F. ; endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// LOOP DE INTERFACE ________________________________________________________

static function i_interface2


   ENT->(dbsetorder(6)) // cod_cont + dtos(dt_emissao)

   ENT->(dbgotop())

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   if ! quse(XDRV_CT,"CONFIG")
      qmensa("N�o foi poss�vel abrir o arquivo CONFIG.DBF da contabilidade ...","B")
      QCONFIG->(dbclosearea())
      return
   endif

   nNUM_LANC  := CONFIG->Num_lanc
   nHISTORICO := space(3)

   CONFIG->(dbclosearea())

   do while ! ENT->(eof())

      qgirabarra()

      if ! ( ENT->Data_lanc >= dINI .and. ENT->Data_lanc <= dFIM )
         ENT->(dbskip())
         loop
      endif

      if ENT->Interface
         ENT->(Dbskip())
         loop
      endif
      qmensa("Aguarde... Interfaceando Entradas com a Contabilidade...")


      if empty(ENT->Tipo_cont)
         qmensa("Nota de Entrada sem o T.P.O, Verifique a nota -> "+ENT->Num_nf,"B")
         ENT->(dbskip())
         loop
      else
         TIPOCONT->(Dbseek(ENT->Tipo_cont))
      endif


      if ENTCUST->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
         do while ! ENTCUST->(eof()) .and. ENTCUST->Data_lanc == ENT->Data_lanc .and. ENTCUST->Num_nf == ENT->Num_nf .and. ENTCUST->Serie == ENT->Serie  .and. ENTCUST->Filial == ENT->Filial

            if SH_EFCON->(qappend())

               replace SH_EFCON->Data_lanc   with  ENTCUST->Data_lanc

               if TIPOCONT->Regime_ope == "2" // Regime de competencia

                  nHISTORICO := TIPOCONT->Hist_l_pr

                  if TIPOCONT->Cont_pr_dv == "1"
                     replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_p_dv
                  else
                     FORN->(dbseek(ENT->Cod_forn))
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                  endif

                  if TIPOCONT->Cont_pr_cr == "1"
                     replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_p_cr
                  else
                     FORN->(dbseek(ENT->Cod_forn))
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                  endif

               else // regime de caixa

                  nHISTORICO := TIPOCONT->Hist_l_pr

                  if TIPOCONT->Conta_liq == "1"
                     replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_liq
                  else
                     FORN->(dbseek(ENT->Cod_forn))
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                  endif
                  if TIPOCONT->Conta_l2 == "1"
                     replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_l2
                  else
                     FORN->(dbseek(ENT->Cod_forn))
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                  endif

               endif
               if ! quse(XDRV_EF,"CONFIG")
                  qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
                  QCONFIG->(Dbclosearea())
                  return
               endif
               replace SH_EFCON->Filial     with  ENTCUST->Filial
               replace SH_EFCON->Valor      with  ENTCUST->Icm_base
               replace SH_EFCON->Num_doc    with  ENTCUST->Num_nf
               replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
               CONFIG->(dbclosearea())
               replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
               replace SH_EFCON->Cod_hist   with  nHISTORICO
               replace SH_EFCON->Centro     with  ENTCUST->Centro

               i_monta_hist("ENTCUST",nHISTORICO)

            endif

            if ! quse(XDRV_EF,"CONFIG")
               qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
               QCONFIG->(Dbclosearea())
               return
            endif

            for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
                bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
                if ! empty(&bHIST) .and. &bHIST $ ( HIST_IMP->His_icms + "*" + HIST_IMP->His_ipi + "*" + HIST_IMP->His_irrf )
                   i_centro_compl(bHIST,alltrim(str(nCONTADOR)),"ENTCUST")
                endif
            next

            CONFIG->(dbclosearea())

            if ENT->(qrlock())
               replace ENT->Interface with .T.
               ENT->(qunlock())
            endif

            if ENTCUST->(qrlock())
               replace ENTCUST->Interface with .T.
               ENTCUST->(qunlock())
            endif
            ENTCUST->(dbskip())
         enddo
         ENT->(Dbskip())

      else
         if SH_EFCON->(qappend())

            replace SH_EFCON->Data_lanc   with  ENT->Data_lanc

            if TIPOCONT->Regime_ope == "2" // Regime de competencia

               nHISTORICO := TIPOCONT->Hist_l_pr

               if TIPOCONT->Cont_pr_dv == "1"
                  replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_p_dv
               else
                  FORN->(dbseek(ENT->Cod_forn))
                  replace SH_EFCON->Cont_db with FORN->Conta_cont
               endif

               if TIPOCONT->Cont_pr_cr == "1"
                  replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_p_cr
               else
                  FORN->(dbseek(ENT->Cod_forn))
                  replace SH_EFCON->Cont_cr with FORN->Conta_cont
               endif

            else // regime de caixa

               nHISTORICO := TIPOCONT->Hist_l_pr

               if TIPOCONT->Conta_liq == "1"
                  replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_liq
               else
                  FORN->(dbseek(ENT->Cod_forn))
                  replace SH_EFCON->Cont_db with FORN->Conta_cont
               endif
               if TIPOCONT->Conta_l2 == "1"
                  replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_l2
               else
                  FORN->(dbseek(ENT->Cod_forn))
                  replace SH_EFCON->Cont_cr with FORN->Conta_cont
               endif

            endif
            if ! quse(XDRV_EF,"CONFIG")
               qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
               QCONFIG->(Dbclosearea())
               return
            endif

            replace SH_EFCON->Filial     with  ENT->Filial
            replace SH_EFCON->Valor      with  ENT->Vlr_cont
            replace SH_EFCON->Num_doc    with  ENT->Num_nf
            replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
            CONFIG->(dbclosearea())
            replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
            replace SH_EFCON->Cod_hist   with  nHISTORICO

            i_monta_hist("ENT",nHISTORICO)

         endif

         if ! quse(XDRV_EF,"CONFIG")
            qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
            QCONFIG->(Dbclosearea())
            return
         endif

         for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
             bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
             if ! empty(&bHIST) .and. &bHIST $ ( HIST_IMP->His_icms + "*" + HIST_IMP->His_ipi + "*" + HIST_IMP->His_irrf )
                i_complementares(bHIST,alltrim(str(nCONTADOR)),"ENT")
             endif
         next

         if OUTENT->(Dbseek(dtos(ENT->Data_lanc) + ENT->Num_nf + ENT->Serie + ENT->Filial ))

            while ! OUTENT->(eof()) .and. OUTENT->Data_lanc == ENT->Data_lanc .and. OUTENT->Num_nf == ENT->Num_nf .and. OUTENT->Serie == ENT->Serie  .and. OUTENT->Filial == ENT->Filial

               for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
                   bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
                   if ! empty(&bHIST) .and. &bHIST == HIST_IMP->His_icms
                      i_compl_outent(bHIST,alltrim(str(nCONTADOR)),"ENT")
                   endif
               next

               OUTENT->(Dbskip())

            enddo

         endif

         CONFIG->(dbclosearea())

         if ENT->(qrlock())
            replace ENT->Interface with .T.
            ENT->(qunlock())
         endif

         ENT->(Dbskip())
      endif
   enddo

   nHISTORICO := space(3)

   SAI->(dbsetorder(6)) // cod_cont + dtos(dt_emissao)

   SAI->(dbgotop())

   do while ! SAI->(eof())

      qgirabarra()

      if ! ( SAI->Data_lanc >= dINI .and. SAI->Data_lanc <= dFIM )
         SAI->(dbskip())
         loop
      endif

      qgirabarra()

      if SAI->Interface
         SAI->(Dbskip())
         loop
      endif

      qmensa("Aguarde... Interfaceando Saidas com a Contabilidade...")

      if empty(SAI->Tipo_cont)
         qmensa("Nota de Saida sem o T.P.O., Verifique a nota -> "+SAI->Num_nf,"B")
         SAI->(dbskip())
         loop
      else
         TIPOCONT->(Dbseek(SAI->Tipo_cont))
      endif

   //   if ! quse(XDRV_EF,"CONFIG")
   //      qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
   //      QCONFIG->(Dbclosearea())
   //      return
   //   endif

      if SAICUST->(dbseek(dtos(SAI->Data_lanc)+SAI->Num_nf+SAI->Serie+SAI->Filial))
         do while ! SAICUST->(eof()) .and. SAICUST->Data_lanc == SAI->Data_lanc .and. SAICUST->Num_nf == SAI->Num_nf .and. SAICUST->Serie == SAI->Serie  .and. SAICUST->Filial == SAI->Filial
            if SH_EFCON->(qappend())

               replace SH_EFCON->Data_lanc   with  SAICUST->Data_lanc

               if TIPOCONT->Regime_ope == "2" // Regime de competencia

                   nHISTORICO := TIPOCONT->Hist_l_pr

                  if TIPOCONT->Cont_pr_dv == "1"
                     replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_p_dv
                  endif

                  if TIPOCONT->Cont_pr_cr == "1"
                     replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_p_cr
                  endif

               else // regime de caixa

                   nHISTORICO := TIPOCONT->Hist_l_pr

                  if TIPOCONT->Conta_liq == "1"
                     replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_liq
                  endif
                  if TIPOCONT->Conta_l2 == "1"
                     replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_l2
                  endif

               endif

               if ! quse(XDRV_EF,"CONFIG")
                  qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
                  QCONFIG->(Dbclosearea())
                  return
               endif

               replace SH_EFCON->Filial     with  SAICUST->Filial
               replace SH_EFCON->Valor      with  SAICUST->Icm_base
               replace SH_EFCON->Num_doc    with  SAICUST->Num_nf
               replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
               CONFIG->(dbclosearea())
               replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := (nNUM_LANC+1),8)
               replace SH_EFCON->Cod_hist   with nHISTORICO
               replace SH_EFCON->Centro     with SAICUST->Centro

               i_monta_hist("SAICUST",nHISTORICO)

            endif


            if ! quse(XDRV_EF,"CONFIG")
               qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
               QCONFIG->(Dbclosearea())
               return
            endif

            for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
                bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
                if &bHIST $ ( HIST_IMP->His_icms + "*" + HIST_IMP->His_ipi + "*" + HIST_IMP->His_irrf )
                   i_centro_compl(bHIST,alltrim(str(nCONTADOR)),"SAICUST")
                endif
            next

            CONFIG->(Dbclosearea())

            if SAI->(qrlock())
               replace SAI->Interface with .T.
               SAI->(qunlock())
            endif

            if SAICUST->(qrlock())
               replace SAICUST->Interface with .T.
               SAICUST->(qunlock())
            endif
            SAICUST->(dbskip())
         enddo
         SAI->(Dbskip())
      else
            if SH_EFCON->(qappend())

               replace SH_EFCON->Data_lanc   with  SAI->Data_lanc

               if TIPOCONT->Regime_ope == "2" // Regime de competencia

                   nHISTORICO := TIPOCONT->Hist_l_pr

                  if TIPOCONT->Cont_pr_dv == "1"
                     replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_p_dv
                  endif

                  if TIPOCONT->Cont_pr_cr == "1"
                     replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_p_cr
                  endif

               else // regime de caixa

                   nHISTORICO := TIPOCONT->Hist_l_pr

                  if TIPOCONT->Conta_liq == "1"
                     replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_liq
                  endif
                  if TIPOCONT->Conta_l2 == "1"
                     replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_l2
                  endif

               endif

               if ! quse(XDRV_EF,"CONFIG")
                  qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
                  QCONFIG->(Dbclosearea())
                  return
               endif

               replace SH_EFCON->Filial     with  SAI->Filial
               replace SH_EFCON->Valor      with  SAI->Vlr_cont
               replace SH_EFCON->Num_doc    with  SAI->Num_nf
               replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
               CONFIG->(dbclosearea())
               replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := (nNUM_LANC+1),8)
               replace SH_EFCON->Cod_hist   with nHISTORICO

               i_monta_hist("SAI",nHISTORICO)

            endif


            if ! quse(XDRV_EF,"CONFIG")
               qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
               QCONFIG->(Dbclosearea())
               return
            endif

            for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
                bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
                if &bHIST $ ( HIST_IMP->His_icms + "*" + HIST_IMP->His_ipi + "*" + HIST_IMP->His_irrf )
                   i_complementares(bHIST,alltrim(str(nCONTADOR)),"SAI")
                endif
            next

            if OUTSAI->(Dbseek(dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial))

               while ! OUTSAI->(eof()) .and. dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial == dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial

                  for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
                      bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
                      if ! empty(&bHIST) .and. &bHIST ==  HIST_IMP->His_icms
                         i__compl_outsai(bHIST,alltrim(str(nCONTADOR)),"SAI")
                      endif
                  next

                  OUTSAI->(Dbskip())

               enddo

            endif

            CONFIG->(Dbclosearea())

            if SAI->(qrlock())
               replace SAI->Interface with .T.
               SAI->(qunlock())
            endif

            SAI->(Dbskip())
      endif
   enddo

   nHISTORICO := space(3)

   ISS->(dbsetorder(4)) //Tipo Contabil + dtos(data_lanc) + dtos(dt_emissao)

   ISS->(dbgotop())

   do while ! ISS->(eof())

      qgirabarra()

      if ! ( ISS->Data_lanc >= dINI .and. ISS->Data_lanc <= dFIM )
         ISS->(dbskip())
         loop
      endif

      qgirabarra()

      if ISS->Interface
         ISS->(Dbskip())
         loop
      endif

      qmensa("Aguarde... Interfaceando Servicos com a Contabilidade...")

   //   if ! quse(XDRV_EF,"CONFIG")
   //      qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
   //      QCONFIG->(Dbclosearea())
   //      return
   //   endif

      if empty(ISS->Tiposub)
         qmensa("Nota de Servicos sem o T.P.O, Verifique a nota -> "+ISS->Num_nf,"B")
         ISS->(dbskip())
         loop
      else
         TIPOCONT->(Dbseek(ISS->Tiposub))
      endif

      if ISS_CUST->(dbseek(ISS->Num_nf+ISS->Serie+alltrim(ISS->Filial)))
         do while ! ISS_CUST->(eof()) .and. ISS_CUST->Num_nf==ISS->Num_nf .and. ISS_CUST->Serie == ISS->Serie .and. alltrim(ISS_CUST->Filial) == alltrim(ISS->Filial)
            if SH_EFCON->(qappend())

               replace SH_EFCON->Data_lanc   with  ISS->Data_lanc

               if TIPOCONT->Regime_ope == "2" // Regime de competencia

                  nHISTORICO := TIPOCONT->Hist_l_pr

                  if TIPOCONT->Cont_pr_dv == "1"
                     replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_p_dv
                  endif

                  if TIPOCONT->Cont_pr_cr == "1"
                     replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_p_cr
                  endif

               else // regime de caixa

                  nHISTORICO := TIPOCONT->Hist_l_pr

                  if TIPOCONT->Conta_liq == "1"
                     replace SH_EFCON->Cont_db with TIPOCONT->Ct_ct_liq
                  endif
                  if TIPOCONT->Conta_l2 == "1"
                     replace SH_EFCON->Cont_cr with TIPOCONT->Ct_ct_l2
                  endif

               endif
               if ! quse(XDRV_EF,"CONFIG")
                  qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
                  QCONFIG->(Dbclosearea())
                  return
               endif

               replace SH_EFCON->Filial     with  ISS_CUST->Filial
               replace SH_EFCON->Valor      with  ISS_CUST->Iss_base
               replace SH_EFCON->Num_doc    with  ISS_CUST->Num_nf
               replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
               CONFIG->(dbclosearea())
               replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := (nNUM_LANC+1),8)
               replace SH_EFCON->Cod_hist   with nHISTORICO
               replace SH_EFCON->Centro     with ISS_CUST->Centro

               i_monta_hist("ISS_CUST",nHISTORICO)

            endif

            if ! quse(XDRV_EF,"CONFIG")
               qmensa("N�o foi possivel abrir CONFIG.DBF... ","B")
               QCONFIG->(Dbclosearea())
               return
            endif

            for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares dos Servicos
                bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
                if ! empty(&bHIST) .and. &bHIST $ ( HIST_IMP->His_icms + "*" + HIST_IMP->His_ipi + "*" + HIST_IMP->His_irrf + "*" + HIST_IMP->His_iss )
                   i_centro_compl(bHIST,alltrim(str(nCONTADOR)),"ISS_CUST")
                endif
            next

            CONFIG->(dbclosearea())

            if ISS->(qrlock())
               replace ISS->Interface with .T.
               ISS->(qunlock())
            endif

          //  ISS->(Dbskip())
            ISS_CUST->(dbskip())
         enddo
      endif
      ISS->(dbskip())
   enddo

   if ! quse(XDRV_CT,"CONFIG")
      qmensa("N�o foi poss�vel abrir o arquivo CONFIG.DBF da contabilidade ...","B")
      QCONFIG->(dbclosearea())
      return
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Num_lanc with nNUM_LANC
      CONFIG->(qunlock())
   endif

   CONFIG->(dbclosearea())

   if ! quse(XDRV_EF,"CONFIG")
      qmensa("N�o foi poss�vel abrir o arquivo CONFIG.DBF ...","B")
      QCONFIG->(dbclosearea())
      return
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Num_lote with CONFIG->Num_lote + 1
      CONFIG->(qunlock())
   endif

   Dbcloseall()

return


////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
static function i_monta_hist(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       FORN->(dbgotop())
       do case
          case substr(nHIST,nPOS,2) == "CA"
               if (cARQ) == "ENT"
                  FORN->(Dbseek((cARQ)->Cod_forn))
                  replace SH_EFCON->Ca with left(FORN->Razao,40)
               endif
          case substr(nHIST,nPOS,3) == "CGC"
               if (cARQ) == "ENT"
                  FORN->(Dbseek((cARQ)->Cod_forn))
                  replace SH_EFCON->Cgc with FORN->Cgccpf
               endif
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_EFCON->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_EFCON->Dp with (cARQ)->Num_nf
               replace SH_EFCON->Fa with (cARQ)->Num_nf
               replace SH_EFCON->Nf with (cARQ)->Num_nf
          case substr(nHIST,nPOS,2) == "EP"
               ESPECIE->(Dbseek((cARQ)->Especie))
               replace SH_EFCON->Ep with ESPECIE->Descricao
          case substr(nHIST,nPOS,2) == "SE"
               SERIE->(Dbseek((cARQ)->Serie))
               replace SH_EFCON->Se with SERIE->Descricao
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONTABILIZAR LANCAMENTOS COMPLEMENTARES ______________________
static function i_complementares (nCAMPO,nNUM,cARQ)  // nCAMPO == codigo do historio / nNUM = numero do campo / cARQ = arquivo a ser contabilizado

    if TIPOCONT->Motivo == "1" // recebimento

       if SH_EFCON->(qappend())

          replace SH_EFCON->Data_lanc   with  (cARQ)->Data_lanc

          nCONTA := "TIPOCONT->Ct_liq_" + nNUM

          if &nCONTA == "1"

             nCONTA := "TIPOCONT->Ct_comp" + nNUM

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with &nCONTA
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with &nCONTA
                otherwise
                     replace SH_EFCON->Cont_db with &nCONTA
             endcase

          else

             FORN->(dbseek(ENT->Cod_forn))

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                otherwise
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
             endcase

          endif

          replace SH_EFCON->Filial     with  (cARQ)->Filial
          replace SH_EFCON->Num_doc    with  (cARQ)->Num_nf

          do case
             case &nCAMPO == HIST_IMP->His_icms
                  replace SH_EFCON->Valor      with  (cARQ)->Icm_vlr
             case &nCAMPO == HIST_IMP->His_ipi
                  replace SH_EFCON->Valor      with  (cARQ)->Ipi_vlr
             case &nCAMPO == HIST_IMP->His_iss
                  replace SH_EFCON->Valor      with  (cARQ)->Iss_vlr

          endcase
          replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
          replace SH_EFCON->Cod_hist   with  &nCAMPO

          i_monta_hist((cARQ),nHISTORICO)

       endif

    endif

    if TIPOCONT->Motivo == "2" // pagamento

       if SH_EFCON->(qappend())

          replace SH_EFCON->Data_lanc   with  (cARQ)->Data_lanc

          nCONTA := "TIPOCONT->Ct_liq_" + nNUM
          if &nCONTA == "1"
             nCONTA := "TIPOCONT->Ct_comp" + nNUM
             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with &nCONTA
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with &nCONTA
                otherwise
                     replace SH_EFCON->Cont_cr with &nCONTA
             endcase

          else
             FORN->(dbseek(ENT->Cod_forn))

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                otherwise
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
             endcase

          endif
          do case
             case &nCAMPO == HIST_IMP->His_icms
                  replace SH_EFCON->Valor      with  (cARQ)->Icm_vlr
             case &nCAMPO == HIST_IMP->His_ipi
                  replace SH_EFCON->Valor      with  (cARQ)->Ipi_vlr
          endcase
          replace SH_EFCON->Filial     with  (cARQ)->Filial
          replace SH_EFCON->Num_doc    with  (cARQ)->Num_nf
          replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
          replace SH_EFCON->Cod_hist   with  &nCAMPO

          i_monta_hist((cARQ),nHISTORICO)

       endif

    endif

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONTABILIZAR LANCAMENTOS COMPLEMENTARES DE OUTRAS ENTRADAS ___
static function i_compl_outent (nCAMPO,nNUM,cARQ)  // nCAMPO == codigo do historio / nNUM = numero do campo / cARQ = arquivo a ser contabilizado

    if TIPOCONT->Motivo == "1" // recebimento

       if SH_EFCON->(qappend())

          replace SH_EFCON->Data_lanc   with  (cARQ)->Data_lanc

          nCONTA := "TIPOCONT->Ct_liq_" + nNUM

          if &nCONTA == "1"

             nCONTA := "TIPOCONT->Ct_comp" + nNUM

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with &nCONTA
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with &nCONTA
                otherwise
                     replace SH_EFCON->Cont_db with &nCONTA
             endcase

          else

             FORN->(dbseek(ENT->Cod_forn))

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                otherwise
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
             endcase

          endif

          replace SH_EFCON->Filial     with  (cARQ)->Filial
          replace SH_EFCON->Num_doc    with  (cARQ)->Num_nf

          if &nCAMPO == HIST_IMP->His_icms
             replace SH_EFCON->Valor      with  OUTENT->Icm_vlr
          endif

          replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
          replace SH_EFCON->Cod_hist   with  &nCAMPO

          i_monta_hist((cARQ),nHISTORICO)

       endif

    endif

    if TIPOCONT->Motivo == "2" // pagamento

       if SH_EFCON->(qappend())

          replace SH_EFCON->Data_lanc   with  (cARQ)->Data_lanc

          nCONTA := "TIPOCONT->Ct_liq_" + nNUM
          if &nCONTA == "1"
             nCONTA := "TIPOCONT->Ct_comp" + nNUM
             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with &nCONTA
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with &nCONTA
                otherwise
                     replace SH_EFCON->Cont_cr with &nCONTA
             endcase

          else
             FORN->(dbseek(ENT->Cod_forn))

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                otherwise
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
             endcase

          endif
          if &nCAMPO == HIST_IMP->His_icms
             replace SH_EFCON->Valor      with  OUTENT->Icm_vlr
          endif
          replace SH_EFCON->Filial     with  (cARQ)->Filial
          replace SH_EFCON->Num_doc    with  (cARQ)->Num_nf
          replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
          replace SH_EFCON->Cod_hist   with  &nCAMPO

          i_monta_hist((cARQ),nHISTORICO)

       endif

    endif

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONTABILIZAR LANCAMENTOS COMPLEMENTARES DE OUTRAS SAIDAS _____
 function I__compl_outsai (nCAMPO,nNUM,cARQ)  // nCAMPO == codigo do historio / nNUM = numero do campo / cARQ = arquivo a ser contabilizado
    if TIPOCONT->Motivo == "1" // recebimento

       if SH_EFCON->(qappend())
          replace SH_EFCON->Data_lanc   with  (cARQ)->Data_lanc
          nCONTA := "TIPOCONT->Ct_liq_" + nNUM

          if &nCONTA == "1"

             nCONTA := "TIPOCONT->Ct_comp" + nNUM

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with &nCONTA
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with &nCONTA
                otherwise
                     replace SH_EFCON->Cont_db with &nCONTA
             endcase

          else

             FORN->(dbseek(ENT->Cod_forn))

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                otherwise
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
             endcase

          endif

          replace SH_EFCON->Filial     with  (cARQ)->Filial
          replace SH_EFCON->Num_doc    with  (cARQ)->Num_nf

          if &nCAMPO == HIST_IMP->His_icms
             replace SH_EFCON->Valor      with  OUTSAI->Icm_vlr
          endif

          replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
          replace SH_EFCON->Cod_hist   with  &nCAMPO

          i_monta_hist((cARQ),nHISTORICO)

       endif

    endif

    if TIPOCONT->Motivo == "2" // pagamento

       if SH_EFCON->(qappend())

          replace SH_EFCON->Data_lanc   with  (cARQ)->Data_lanc

          nCONTA := "TIPOCONT->Ct_liq_" + nNUM
          if &nCONTA == "1"
             nCONTA := "TIPOCONT->Ct_comp" + nNUM
             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with &nCONTA
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with &nCONTA
                otherwise
                     replace SH_EFCON->Cont_cr with &nCONTA
             endcase

          else
             FORN->(dbseek(ENT->Cod_forn))

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                otherwise
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
             endcase

          endif
          if &nCAMPO == HIST_IMP->His_icms
             replace SH_EFCON->Valor      with  OUTSAI->Icm_vlr
          endif
          replace SH_EFCON->Filial     with  (cARQ)->Filial
          replace SH_EFCON->Num_doc    with  (cARQ)->Num_nf
          replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
          replace SH_EFCON->Cod_hist   with  &nCAMPO

          i_monta_hist((cARQ),nHISTORICO)

       endif
    endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONTABILIZAR LANCAMENTOS COMPLEMENTARES ______________________
static function i_centro_compl (nCAMPO,nNUM,cARQ)  // nCAMPO == codigo do historio / nNUM = numero do campo / cARQ = arquivo a ser contabilizado

    if TIPOCONT->Motivo == "1" // recebimento

       if SH_EFCON->(qappend())

          replace SH_EFCON->Data_lanc   with  (cARQ)->Data_lanc
          replace SH_EFCON->Centro      with  (cARQ)->Centro

          nCONTA := "TIPOCONT->Ct_liq_" + nNUM

          if &nCONTA == "1"

             nCONTA := "TIPOCONT->Ct_comp" + nNUM

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with &nCONTA
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with &nCONTA
                otherwise
                     replace SH_EFCON->Cont_db with &nCONTA
             endcase

          else

             FORN->(dbseek(ENT->Cod_forn))

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                otherwise
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
             endcase

          endif

          replace SH_EFCON->Filial     with  (cARQ)->Filial
          replace SH_EFCON->Num_doc    with  (cARQ)->Num_nf

          do case
             case &nCAMPO == HIST_IMP->His_icms
                  replace SH_EFCON->Valor      with  (cARQ)->Icm_vlr
             case &nCAMPO == HIST_IMP->His_ipi
                  replace SH_EFCON->Valor      with  (cARQ)->Ipi_vlr
             case &nCAMPO == HIST_IMP->His_iss
                  replace SH_EFCON->Valor      with  (cARQ)->Iss_vlr
          endcase
          replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
          replace SH_EFCON->Cod_hist   with  &nCAMPO

          i_monta_hist((cARQ),nHISTORICO)

       endif

    endif

    if TIPOCONT->Motivo == "2" // pagamento

       if SH_EFCON->(qappend())

          replace SH_EFCON->Data_lanc   with  (cARQ)->Data_lanc
          replace SH_EFCON->Centro      with  (cARQ)->Centro

          nCONTA := "TIPOCONT->Ct_liq_" + nNUM
          if &nCONTA == "1"
             nCONTA := "TIPOCONT->Ct_comp" + nNUM
             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with &nCONTA
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with &nCONTA
                otherwise
                     replace SH_EFCON->Cont_cr with &nCONTA
             endcase

          else
             FORN->(dbseek(ENT->Cod_forn))

             do case
                case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_EFCON->Cont_db with FORN->Conta_cont
                case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
                otherwise
                     replace SH_EFCON->Cont_cr with FORN->Conta_cont
             endcase

          endif
          do case
             case &nCAMPO == HIST_IMP->His_icms
                  replace SH_EFCON->Valor      with  (cARQ)->Icm_vlr
             case &nCAMPO == HIST_IMP->His_iss                     //   Alteracao feita em 26/04/2000
                replace SH_EFCON->Valor      with  (cARQ)->Iss_vlr
          endcase
          replace SH_EFCON->Filial     with  (cARQ)->Filial
          replace SH_EFCON->Num_doc    with  (cARQ)->Num_nf
          replace SH_EFCON->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_EFCON->Num_lanc   with  strzero(nNUM_LANC := nNUM_LANC+1,8)
          replace SH_EFCON->Cod_hist   with  &nCAMPO

          i_monta_hist((cARQ),nHISTORICO)

       endif

    endif

return

