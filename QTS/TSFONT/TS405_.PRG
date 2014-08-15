/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: ENCERRAMENTO DO DIA
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1998
// OBS........:
// ALTERACOES.:
function ts405

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO   := {}
local lCONF     := .F.


private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1)}

private cDATA   := CONFIG->Data_atual

private dDATA_CONT := CONFIG->Data_atual

fu_abre_cli1()

if CONFIG->Data_atual <> CONFIG->Data_ant
   qmensa("O Fechamento s¢ ‚ permitido no dia corrente...","B")
   return
endif

// verificacao do final de semana

if qnomesemana(cDATA) $ "SEXTA  " .and. CONFIG->Sabado == "2" .and. CONFIG->Domingo == "2"
   cDATA := (cDATA+3)
else
   if qnomesemana(cDATA) $ "SEXTA  "
      if CONFIG->Sabado == "1"
         cDATA := (cDATA + 1)  // muda para sabado
      endif
   elseif qnomesemana(cDATA) $ "SABADO "
      if CONFIG->Domingo == "1"
         cDATA := (cDATA + 1)  // muda para domingo
      else
         cDATA := (cDATA + 2)  // muda para segunda
      endif
   else
      cDATA := (cDATA + 1) // dia normal - somente adiciona
   endif
endif

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B405A","QBLOC.GLO",1)

aadd(aEDICAO,{{ NIL },"DATA" })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma encerramento do dia ?") },"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

XNIVEL := 1

qrsay ( XNIVEL++ , cDATA )

XNIVEL := 2
XFLAG  := .T.

// LOOP PARA ENTRADA DOS DADOS ______________________________________________

do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
   eval ( aEDICAO [XNIVEL,1] )
   if eval ( bESCAPE ) ; return ; endif
   if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
   iif ( XFLAG , XNIVEL++ , XNIVEL-- )
enddo

// GRAVACAO _________________________________________________________________

if lCONF

   BANCO->(Dbsetorder(3)) // codigo  - rotina para verificar saldo atual dos bancos
   BANCO->(Dbgotop())

   do while ! BANCO->(eof())

      SALD_BAN->(Dbsetorder(1))
      SALD_BAN->(Dbgotop())

      if SALD_BAN->(dbseek(dtos(CONFIG->Data_atual)+BANCO->Codigo))
         nSALDO_ATU := SALD_BAN->Saldo
      else
         SALD_BAN->(Dbskip(-1))
         nSALDO_ATU := SALD_BAN->Saldo
      endif

      MOV_BANC->(Dbsetorder(1))
      MOV_BANC->(Dbgotop())
      set softseek on
      MOV_BANC->(Dbseek(CONFIG->Data_atual))
      set softseek off

      do while ! MOV_BANC->(eof()) .and. MOV_BANC->Data = CONFIG->Data_atual

         if MOV_BANC->Cod_banco <> BANCO->Codigo
            MOV_BANC->(Dbskip())
            loop
         endif

         if ! empty(MOV_BANC->Entrada)
            nSALDO_ATU += MOV_BANC->Entrada
         endif

         if ! empty(MOV_BANC->Saida)
            nSALDO_ATU -= MOV_BANC->Saida
         endif

         MOV_BANC->(Dbskip())

      enddo

      if SALD_BAN->(Dbseek(dtos(cDATA)+BANCO->Codigo))
         if SALD_BAN->(qrlock())
            replace SALD_BAN->Saldo  with nSALDO_ATU
            SALD_BAN->(qunlock())
         endif
      else
         if SALD_BAN->(qrlock()) .and. SALD_BAN->(qappend())
            replace SALD_BAN->Data      with cDATA
            replace SALD_BAN->Cod_banco with BANCO->Codigo
            replace SALD_BAN->Saldo     with nSALDO_ATU
            SALD_BAN->(qunlock())
         endif
      endif
      BANCO->(Dbskip())

   enddo

   nSALD_ATU := 0

   INSTITU->(Dbsetorder(1)) // codigo  - rotina para verificar saldo atual dos bancos
   INSTITU->(Dbgotop())

   do while ! INSTITU->(eof())

      SALD_FIN->(Dbsetorder(1))
      SALD_FIN->(Dbgotop())

      if SALD_FIN->(dbseek(dtos(CONFIG->Data_atual)+INSTITU->Codigo))
         nSALDO_ATU := SALD_FIN->Saldo
      else
         SALD_FIN->(Dbskip(-1))
         nSALDO_ATU := SALD_FIN->Saldo
      endif

      MOV_FIN->(Dbsetorder(1))
      MOV_FIN->(Dbgotop())
      set softseek on
      MOV_FIN->(Dbseek(CONFIG->Data_atual))
      set softseek off

      do while ! MOV_FIN->(eof()) .and. MOV_FIN->Data = CONFIG->Data_atual

         if MOV_FIN->Cod_inst <> INSTITU->Codigo
            MOV_FIN->(Dbskip())
            loop
         endif

         if ! empty(MOV_FIN->Entrada)
            nSALDO_ATU += MOV_FIN->Entrada
         endif

         if ! empty(MOV_FIN->Saida)
            nSALDO_ATU -= MOV_FIN->Saida
         endif

         MOV_FIN->(Dbskip())

      enddo

      if SALD_FIN->(qrlock()) .and. SALD_FIN->(qappend())
         replace SALD_FIN->Data      with cDATA
         replace SALD_FIN->Cod_inst  with INSTITU->Codigo
         replace SALD_FIN->Saldo     with nSALDO_ATU
         SALD_FIN->(qunlock())
      endif

      INSTITU->(Dbskip())

   enddo


   nSALDO_ATU := 0

   SALD_CAI->(Dbsetorder(1))
   SALD_CAI->(Dbgotop())

   if SALD_CAI->(dbseek(CONFIG->Data_atual)) // ROTINA PARA VERFICAR SALDO ATUAL DO CAIXA
      nSALDO_ATU := SALD_CAI->Saldo
   endif

   MOV_CAIX->(Dbsetorder(1))
   MOV_CAIX->(Dbgotop())
   set softseek on
   MOV_CAIX->(Dbseek(CONFIG->Data_atual))
   set softseek off

   do while ! MOV_CAIX->(eof()) .and. MOV_CAIX->Data = CONFIG->Data_atual

      if ! empty(MOV_CAIX->Entrada)
          nSALDO_ATU += MOV_CAIX->Entrada
      endif

      if ! empty(MOV_CAIX->Saida)
         nSALDO_ATU -= MOV_CAIX->Saida
      endif

      MOV_CAIX->(Dbskip())

   enddo
   if SALD_CAI->(Dbseek(cDATA))
      if SALD_CAI->(qrlock())
         replace SALD_CAI->Saldo     with nSALDO_ATU
         SALD_CAI->(qunlock())
      endif
   else
      if SALD_CAI->(qrlock()) .and. SALD_CAI->(qappend())
         replace SALD_CAI->Data      with cDATA
         replace SALD_CAI->Saldo     with nSALDO_ATU
         SALD_CAI->(qunlock())
      endif
   endif

   if ! i_contabil()
      qmensa("N„o foi possivel contabilizar ... Verifique...")
      return
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Data_atual with cDATA
      replace CONFIG->Data_ant   with cDATA
      CONFIG->(qunlock())
   else
      qmensa("N„o foi poss¡vel alterar a configura‡„o, tente novamente","B")
   endif

endif

CONFIG->(dbclosearea())

//return  ÿ

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   local sBLOC := qsbloc(11,37,11,47)

   do case
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA CONTABILIZAR OS LCTOS DA TESOURARIA ________________

function i_contabil

   fu_abre_prov()

   quse(XDRV_CL,"CONFIG",{},,"FATCFG")

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   REF_CAIX->(Dbsetorder(2)) // data do lancamento
   REF_CAIX->(Dbgotop())
   set softseek on
   REF_CAIX->(dbseek(dDATA_CONT))
   set softseek off

   do while REF_CAIX->Data >= dDATA_CONT .and. REF_CAIX->Data <= dDATA_CONT

      qgirabarra()

      if REF_CAIX->Contabil
         REF_CAIX->(dbskip())
         loop
      endif

      qmensa("Aguarde... Interfaceando Reforco de Caixa com a Contabilidade...")
   
      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc  with dDATA_CONT
         BANCO->(dbseek(REF_CAIX->Cod_caixa))
         replace SH_PROCT->Cont_db    with BANCO->Conta_cont
         BANCO->(dbseek(REF_CAIX->Cod_banco))
         replace SH_PROCT->Cont_cr    with BANCO->Conta_cont
         replace SH_PROCT->Filial     with  "0001"
         replace SH_PROCT->Valor      with  REF_CAIX->Valor
         replace SH_PROCT->Num_doc    with  REF_CAIX->Docto
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with  "REFORCO DE CAIXA"

      endif

      setContabil("REF_CAIX")

      REF_CAIX->(dbskip())

   enddo

   DEPOSITO->(Dbsetorder(2))
   DEPOSITO->(Dbgotop())
   set softseek on
   DEPOSITO->(dbseek(dDATA_CONT))
   set softseek off

   do while DEPOSITO->Data >= dDATA_CONT .and. DEPOSITO->Data <= dDATA_CONT

      qgirabarra()

      if DEPOSITO->Contabil
         DEPOSITO->(dbskip())
         loop
      endif

      qmensa("Aguarde... Interfaceando Depositos com a Contabilidade...")
   
      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with dDATA_CONT
         BANCO->(dbseek(DEPOSITO->Cod_caixa))
         replace SH_PROCT->Cont_cr     with BANCO->Conta_cont
         BANCO->(dbseek(DEPOSITO->Banco))
         replace SH_PROCT->Cont_db     with BANCO->Conta_cont
         replace SH_PROCT->Filial     with  "0001"
         replace SH_PROCT->Valor      with  (DEPOSITO->Valor_ch1 + DEPOSITO->Valor_ch2 + DEPOSITO->Valor_es1 + DEPOSITO->Valor_es2)
         replace SH_PROCT->Num_doc    with  DEPOSITO->Docto
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with  "DEPOSITO"

      endif

      setContabil("DEPOSITO")


      DEPOSITO->(dbskip())

   enddo


   DEP_NIDT->(Dbsetorder(2))
   DEP_NIDT->(Dbgotop())
   set softseek on
   DEP_NIDT->(dbseek(dDATA_CONT))
   set softseek off

   do while DEP_NIDT->Data >= dDATA_CONT .and. DEP_NIDT->Data <= dDATA_CONT

      qgirabarra()

      if DEP_NIDT->Contabil
         DEP_NIDT->(dbskip())
         loop
      endif

      qmensa("Aguarde... Interfaceando Depositos Nao Identificados com a Contabilidade...")
   
      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with dDATA_CONT
         replace SH_PROCT->Cont_cr     with "001392"
         BANCO->(dbseek(DEP_NIDT->Banco))
         replace SH_PROCT->Cont_db     with BANCO->Conta_cont
         replace SH_PROCT->Filial     with  "0001"
         replace SH_PROCT->Valor      with  DEP_NIDT->Valor
         replace SH_PROCT->Num_doc    with  DEP_NIDT->Docto
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with  DEP_NIDT->Historico

      endif

      setContabil("DEP_NIDT")


      DEP_NIDT->(dbskip())

   enddo


   CHEQ_DEV->(Dbsetorder(2))
   CHEQ_DEV->(Dbgotop())
   set softseek on
   CHEQ_DEV->(dbseek(dDATA_CONT))
   set softseek off

   do while CHEQ_DEV->Data >= dDATA_CONT .and. CHEQ_DEV->Data <= dDATA_CONT

      qgirabarra()

      if CHEQ_DEV->Contabil
         CHEQ_DEV->(dbskip())
         loop
      endif

      qmensa("Aguarde... Interfaceando Cheques Devolvidos com a Contabilidade...")
   
      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with dDATA_CONT
         BANCO->(dbseek(CHEQ_DEV->Cod_caixa))
         replace SH_PROCT->Cont_cr     with BANCO->Conta_cont
         BANCO->(dbseek(CHEQ_DEV->Banco))
         replace SH_PROCT->Cont_db     with BANCO->Conta_cont
         replace SH_PROCT->Filial     with  "0001"
         replace SH_PROCT->Valor      with  CHEQ_DEV->Valor_ch1
         replace SH_PROCT->Num_doc    with  CHEQ_DEV->Docto
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with  "CHEQUE DEVOLVIDO "+CHEQ_DEV->Docto

      endif

      setcontabil("CHEQ_DEV")

      CHEQ_DEV->(dbskip())

   enddo

   ESTORNO->(Dbsetorder(2))
   ESTORNO->(Dbgotop())
   set softseek on
   ESTORNO->(dbseek(dDATA_CONT))
   set softseek off

   do while ESTORNO->Data >= dDATA_CONT .and. ESTORNO->Data <= dDATA_CONT

      qgirabarra()

      if ESTORNO->Contabil
         ESTORNO->(dbskip())
         loop
      endif


      qmensa("Aguarde... Interfaceando Estornos de Depositos com a Contabilidade...")
   
      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with dDATA_CONT
         BANCO->(dbseek(ESTORNO->Cod_caixa))
         replace SH_PROCT->Cont_cr     with BANCO->Conta_cont
         BANCO->(dbseek(ESTORNO->Banco))
         replace SH_PROCT->Cont_db     with BANCO->Conta_cont
         replace SH_PROCT->Filial     with  "0001"
         replace SH_PROCT->Valor      with  ESTORNO->Valor_ch1
         replace SH_PROCT->Num_doc    with  ESTORNO->Docto
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with  "ESTORNO DE DEPOSITO "+ESTORNO->Docto

      endif

      setContabil("ESTORNO")

      ESTORNO->(dbskip())

   enddo

   AVIS_BAN->(Dbsetorder(2))
   AVIS_BAN->(Dbgotop())
   set softseek on
   AVIS_BAN->(dbseek(dDATA_CONT))
   set softseek off

   do while AVIS_BAN->Data_cont >= dDATA_CONT .and. AVIS_BAN->Data_cont <= dDATA_CONT

      qgirabarra()

      if AVIS_BAN->Contabil
         AVIS_BAN->(dbskip())
         loop
      endif


      qmensa("Aguarde... Interfaceando Avisos Bancarios com a Contabilidade...")

      TIPOCONT->(Dbseek(AVIS_BAN->Tipocont))

      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  dDATA_CONT


            if AVIS_BAN->Ent_sai == "E"
               BANCO->(Dbsetorder(3))
               BANCO->(dbseek(AVIS_BAN->Banco))
               replace SH_PROCT->Cont_db with BANCO->Conta_cont
               replace SH_PROCT->Cont_cr with AVIS_BAN->Conta_cont
            else
               BANCO->(Dbsetorder(3))
               BANCO->(dbseek(AVIS_BAN->Banco))
               replace SH_PROCT->Cont_cr with BANCO->Conta_cont
               replace SH_PROCT->Cont_db with AVIS_BAN->Conta_cont
            endif

         replace SH_PROCT->Filial     with  "0001"
         replace SH_PROCT->Centro     with  AVIS_BAN->Centro
         replace SH_PROCT->Valor      with  AVIS_BAN->Valor
         replace SH_PROCT->Num_doc    with  AVIS_BAN->Docto
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with  rtrim(AVIS_BAN->Historico)+" "+AVIS_BAN->Docto

      endif

      setContabil("AVIS_BAN")

      AVIS_BAN->(dbskip())

   enddo

   TRAN_BCO->(Dbsetorder(2))
   TRAN_BCO->(Dbgotop())
   set softseek on
   TRAN_BCO->(dbseek(dDATA_CONT))
   set softseek off

   do while TRAN_BCO->Data >= dDATA_CONT .and. TRAN_BCO->Data <= dDATA_CONT

      qgirabarra()

      if TRAN_BCO->Contabil
         TRAN_BCO->(dbskip())
         loop
      endif


      qmensa("Aguarde... Interfaceando Transferencia Bancaria com a Contabilidade...")

      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  dDATA_CONT

         BANCO->(dbseek(TRAN_BCO->Banco_orig))  // credito no banco de origem
         replace SH_PROCT->Cont_cr with BANCO->Conta_cont

         BANCO->(dbseek(TRAN_BCO->Banco_dest)) // debito no banco de destino
         replace SH_PROCT->Cont_db with BANCO->Conta_cont

         replace SH_PROCT->Filial     with  "0001"
         replace SH_PROCT->Valor      with  TRAN_BCO->Valor
         replace SH_PROCT->Num_doc    with  TRAN_BCO->Docto
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with "TRANSFERENCIA ENTRE BANCOS" + iif(! empty(TRAN_BCO->NR_CHEQUE), " CH. NR. " + TRAN_BCO->NR_CHEQUE, "")

      endif

      setContabil("TRAN_BCO")

      TRAN_BCO->(dbskip())

   enddo

   PAG_VIST->(Dbsetorder(2))
   PAG_VIST->(Dbgotop())
   set softseek on
   PAG_VIST->(dbseek(dDATA_CONT))
   set softseek off

   do while PAG_VIST->Data >= dDATA_CONT .and. PAG_VIST->Data <= dDATA_CONT

      qgirabarra()

      if PAG_VIST->Contabil
         PAG_VIST->(dbskip())
         loop
      endif


      qmensa("Aguarde... Interfaceando Pagamentos a Vista com a Contabilidade...")

      TIPOCONT->(Dbseek(PAG_VIST->Tipocont))

      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  dDATA_CONT

         replace SH_PROCT->Cont_db with PAG_VIST->Conta_cont
         BANCO->(dbseek(PAG_VIST->Banco))
         replace SH_PROCT->Cont_cr with BANCO->Conta_cont

         replace SH_PROCT->Filial     with  PAG_VIST->Filial
         replace SH_PROCT->Valor      with  PAG_VIST->Valor
         replace SH_PROCT->Centro     with  PAG_VIST->Centro
         replace SH_PROCT->Num_doc    with  left(PAG_VIST->Duplicata,8)
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with  PAG_VIST->Historico

      endif

      setContabil("PAG_VIST")

      PAG_VIST->(dbskip())

   enddo

   REC_VIST->(Dbsetorder(2))
   REC_VIST->(Dbgotop())
   set softseek on
   REC_VIST->(dbseek(dDATA_CONT))
   set softseek off

   do while REC_VIST->Data >= dDATA_CONT .and. REC_VIST->Data <= dDATA_CONT

      qgirabarra()

      if REC_VIST->Contabil
         REC_VIST->(dbskip())
         loop
      endif


      qmensa("Aguarde... Interfaceando Recebimentos a Vista com a Contabilidade...")

      TIPOCONT->(Dbseek(REC_VIST->Tipocont))

      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  dDATA_CONT



         replace SH_PROCT->Cont_cr with REC_VIST->Conta_cont
         BANCO->(Dbsetorder(3))
         BANCO->(Dbseek(CONFIG->Caixa))
         replace SH_PROCT->Cont_db with BANCO->Conta_Cont


         replace SH_PROCT->Filial     with  REC_VIST->Filial
         replace SH_PROCT->Centro     with  REC_VIST->Centro
         replace SH_PROCT->Valor      with  REC_VIST->Valor
         replace SH_PROCT->Num_doc    with  left(REC_VIST->Duplicata,8)
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with  REC_VIST->Historico

         //monta_r_vist("REC_VIST",nHISTORICO)  // funcao para montar o historico padrao

      endif

      setContabil("REC_VIST")

      REC_VIST->(dbskip())

   enddo

   PAGOS->(Dbsetorder(5))  // DATA_PAGTO
   PAGOS->(Dbgotop())
   set softseek on
   PAGOS->(dbseek(dtos(dDATA_CONT)))
   set softseek off

   do while PAGOS->Data_Pagto >= dDATA_CONT .and. PAGOS->Data_pagto <= dDATA_CONT

      qgirabarra()

      if PAGOS->Contabil
         PAGOS->(dbskip())
         loop
      endif

      qmensa("Aguarde... Interfaceando Contas a Pagar com a Contabilidade...")


      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  PAGOS->Data_pagto

         if empty(PAGOS->Conta_cont)
            if TIPOCONT->Regime_ope == "2" // Regime de competencia

               nHISTORICO := TIPOCONT->Hist_l_1

               if TIPOCONT->Cont_pr_cr == "1"
                  replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_cr
               else
                  FORN->(dbseek(PAGOS->Cod_forn))
                  replace SH_PROCT->Cont_db with FORN->Conta_cont
               endif

               BANCO->(dbseek(PAGOS->Cod_banco))
               replace SH_PROCT->Cont_cr with BANCO->Conta_cont

            else // regime de caixa

               nHISTORICO := TIPOCONT->Hi_l_liq1

               if TIPOCONT->Conta_liq == "1"
                  replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
               else
                  FORN->(dbseek(PAGOS->Cod_forn))
                  replace SH_PROCT->Cont_db with FORN->Conta_cont
               endif

               if TIPOCONT->Conta_l2 == "1"
                  replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
               else
                  FORN->(dbseek(PAGOS->Cod_forn))
                  replace SH_PROCT->Cont_cr with FORN->Conta_cont
               endif

            endif
         else
            BANCO->(dbsetorder(3))
            BANCO->(dbseek(PAGOS->cod_banco))
            replace SH_PROCT->Cont_cr with BANCO->Conta_cont
            FORN->(dbseek(PAGOS->Cod_forn))
            replace SH_PROCT->Cont_db with FORN->Conta_cont
         endif

         replace SH_PROCT->Filial     with  PAGOS->Filial
         replace SH_PROCT->Centro     with  PAGOS->Centro
         replace SH_PROCT->Valor      with  PAGOS->Valor
         replace SH_PROCT->Num_doc    with  left(PAGOS->Fatura,8)
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
//         replace SH_PROCT->Cod_hist   with  nHISTORICO

         if empty(PAGOS->Conta_cont)
//            monta_pag("PAGOS",nHISTORICO)  // funcao para montar o historico padrao
         else
   //         nHIstorico :=
            replace SH_PROCT->Historico with  "PAGTO NF "+left(PAGOS->Fatura,9)+ " " +left(FORN->razao,35)
         endif

      endif

      setcontabil("PAGOS")

      PAGOS->(dbskip())

   enddo

   RECEBIDO->(Dbsetorder(6))  // DT_PAGTO
   RECEBIDO->(Dbgotop())
   set softseek on
   RECEBIDO->(Dbseek(dtos(dDATA_CONT)))
   set softseek off

   do while RECEBIDO->Data_pagto >= dDATA_CONT .and. RECEBIDO->Data_pagto <= dDATA_CONT

      qmensa("Aguarde... Interfaceando Contas a Receber com a Contabilidade...")

      if RECEBIDO->Contabil
         RECEBIDO->(dbskip())
         loop
      endif


      TIPOCONT->(Dbseek(RECEBIDO->Tipo_sub))

      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  RECEBIDO->Data_pagto

         if TIPOCONT->Regime_ope == "2" // Regime de competencia

            nHISTORICO := TIPOCONT->Hist_l_2

            if TIPOCONT->Cont_pr_dv == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_dv
            else
               CLI1->(dbseek(RECEBIDO->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

            if RECEBIDO->Tipo == "7"
               //BANCO->(Dbseek(RECEBIDO->Cod_banco))
               replace SH_PROCT->Cont_db with "001392"
            else
               BANCO->(Dbseek(RECEBIDO->Cod_banco))
               replace SH_PROCT->Cont_db with BANCO->Conta_cont
            endif

         else // regime de caixa

            nHISTORICO := TIPOCONT->Hi_l_liq2

            if TIPOCONT->Conta_liq == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_liq
            else
               CLI1->(dbseek(RECEBIDO->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

            if RECEBIDO->Tipo == "7"
               //BANCO->(Dbseek(RECEBIDO->Cod_banco))
               replace SH_PROCT->Cont_db with "001392"
            else
               BANCO->(Dbseek(RECEBIDO->Cod_banco))
               replace SH_PROCT->Cont_db with BANCO->Conta_cont
            endif

         endif

         replace SH_PROCT->Filial     with  RECEBIDO->Filial
         replace SH_PROCT->Centro     with  RECEBIDO->Centro
         replace SH_PROCT->Valor      with  RECEBIDO->Valor
         replace SH_PROCT->Num_doc    with  left(RECEBIDO->Fatura,8)
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Cod_hist   with  nHISTORICO

         monta_rec("RECEBIDO",nHISTORICO)

      endif

      if SH_PROCT->(qappend()) .and. RECEBIDO->Juros > 0

         replace SH_PROCT->Data_lanc   with  RECEBIDO->Data_pagto

         replace SH_PROCT->Cont_cr with "032190"

         if RECEBIDO->Tipo == "7"
            //BANCO->(Dbseek(RECEBIDO->Cod_banco))
            replace SH_PROCT->Cont_db with "001392"
         else
            BANCO->(Dbseek(RECEBIDO->Cod_banco))
            replace SH_PROCT->Cont_db with BANCO->Conta_cont
         endif

         replace SH_PROCT->Filial     with  RECEBIDO->Filial
         replace SH_PROCT->Centro     with  RECEBIDO->Centro
         replace SH_PROCT->Valor      with  RECEBIDO->Juros
         replace SH_PROCT->Num_doc    with  left(RECEBIDO->Fatura,8)
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         CLI1->(dbseek(RECEBIDO->Cod_cli))
         replace SH_PROCT->Historico  with "REC JUROS NF "+RECEBIDO->Fatura + left(CLI1->Razao,30)

      endif
	  
	  if SH_PROCT->(qappend()) .and. RECEBIDO->Desconto > 0

         replace SH_PROCT->Data_lanc   with  RECEBIDO->Data_pagto

		 CLI1->(dbseek(RECEBIDO->Cod_cli))
         replace SH_PROCT->Cont_cr with CLI1->Conta_cont
         replace SH_PROCT->Cont_db with "006602"

         replace SH_PROCT->Filial     with  RECEBIDO->Filial
         replace SH_PROCT->Centro     with  RECEBIDO->Centro
         replace SH_PROCT->Valor      with  RECEBIDO->Desconto
         replace SH_PROCT->Num_doc    with  left(RECEBIDO->Fatura,8)
         replace SH_PROCT->Num_lote   with  "TS" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Historico  with "DESC. NF "+RECEBIDO->Fatura + left(CLI1->Razao,30)

      endif


      setContabil("RECEBIDO")

      RECEBIDO->(Dbskip())

   enddo

   if CONFIG->(qrlock())
      replace CONFIG->Num_lote with ( CONFIG->Num_lote + 1 )
      CONFIG->(qunlock())
   endif

   FATCFG->(dbclosearea())

return .T.

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
function monta_pag(cARQ,cHIST)

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
          case substr(nHIST,nPOS,2) == "CH"
               replace SH_PROCT->Ch with (cARQ)->Nr_cheque
          case substr(nHIST,nPOS,2) == "BC"
               BANCO->(dbsetorder(3)) // codigo do banco
               BANCO->(Dbseek((cARQ)->Cod_banco))
               replace SH_PROCT->Bc  with BANCO->Descricao
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next
return

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
function monta_p_vist(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       FORN->(dbgotop())
       do case
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_PROCT->Dp with (cARQ)->Duplicata
               replace SH_PROCT->Fa with (cARQ)->Duplicata
               replace SH_PROCT->Nf with (cARQ)->Duplicata
          case substr(nHIST,nPOS,2) == "EP"
               ESPECIE->(Dbseek((cARQ)->Especie))
               replace SH_PROCT->Ep with left(ESPECIE->Descricao,10)
          case substr(nHIST,nPOS,2) == "SE"
               SERIE->(Dbseek((cARQ)->Serie))
               replace SH_PROCT->Se with left(SERIE->Descricao,10)
          case substr(nHIST,nPOS,2) == "CH"
               replace SH_PROCT->Ch with (cARQ)->Num_cheque
          case substr(nHIST,nPOS,2) == "BC"
               BANCO->(dbsetorder(3)) // codigo do banco
               BANCO->(Dbseek((cARQ)->Banco))
               replace SH_PROCT->Bc  with BANCO->Descricao
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next
return

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
function monta_r_vist(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       do case
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_PROCT->Dp with (cARQ)->Duplicata
               replace SH_PROCT->Fa with (cARQ)->Duplicata
               replace SH_PROCT->Nf with (cARQ)->Duplicata
          case substr(nHIST,nPOS,2) == "EP"
               ESPECIE->(Dbseek((cARQ)->Especie))
               replace SH_PROCT->Ep with left(ESPECIE->Descricao,3)
          case substr(nHIST,nPOS,2) == "SE"
               SERIE->(Dbseek((cARQ)->Serie))
               replace SH_PROCT->Se with left(SERIE->Descricao,3)
          case substr(nHIST,nPOS,2) == "CH"
               replace SH_PROCT->Ch with (cARQ)->Num_cheque
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next
return


////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
function monta_rec(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       CLI1->(dbgotop())
       do case
          case substr(nHIST,nPOS,2) == "CA"
               CLI1->(Dbseek((cARQ)->Cod_cli))
               replace SH_PROCT->Ca with left(CLI1->Razao,40)
          case substr(nHIST,nPOS,3) == "CGC"
               CLI1->(Dbseek((cARQ)->Cod_cli))
               replace SH_PROCT->Cgc with CLI1->Cgccpf
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_PROCT->Dp with (cARQ)->Fatura
               replace SH_PROCT->Fa with (cARQ)->Fatura
               replace SH_PROCT->Nf with (cARQ)->Fatura
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next

return

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
function monta_avis(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       do case
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
               replace SH_PROCT->Ch with (cARQ)->Nr_cheque
          case substr(nHIST,nPOS,2) == "BC"
               BANCO->(dbsetorder(3)) // codigo do banco
               BANCO->(Dbseek((cARQ)->Banco))
               replace SH_PROCT->Bc  with BANCO->Descricao
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next
return


static function setContabil(cFILE)

     if FATCFG->Modelo_fat == "1"
        if (cFILE)->(qrlock())
           replace (cFILE)->Contabil with .T.
           (cFILE)->(qunlock())
        else
           qmensa("Nao foi possivel marcar "+cFILE+" como contabilizado!","BL")

        endif
     endif

return
