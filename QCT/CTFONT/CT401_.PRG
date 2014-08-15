/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CAIXA
// OBJETIVO...: PROPAGACAO DE SALDOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: JANEIRO DE 1995
// OBS........:
// ALTERACOES.:
function ct401

// INICIALIZACOES ___________________________________________________________

#include "inkey.ch"

local nREC

// CONFIRMA PROPAGACAO DE SALDOS ____________________________________________

if ! qconf("Confirma Propaga‡„o de Saldos ?") ; return ; endif

// TRAVA OS ARQUIVOS ________________________________________________________

if ! CONFIG->(qrlock())
   qmensa("N„o foi possivel travar arquivos, tente novamente...","B")
   return
endif

// LIMPA OS SALDOS DOS 12 MESES EM ABERTO (CONFIG.DBF INCLUSIVE) ____________

qmensa("Zerando os saldos. Aguarde...")

replace CONFIG->DB01 with 0, CONFIG->CR01 with 0, CONFIG->DB02 with 0, CONFIG->CR02 with 0,;
        CONFIG->DB03 with 0, CONFIG->CR03 with 0, CONFIG->DB04 with 0, CONFIG->CR04 with 0,;
        CONFIG->DB05 with 0, CONFIG->CR05 with 0, CONFIG->DB06 with 0, CONFIG->CR06 with 0,;
        CONFIG->DB07 with 0, CONFIG->CR07 with 0, CONFIG->DB08 with 0, CONFIG->CR08 with 0,;
        CONFIG->DB09 with 0, CONFIG->CR09 with 0, CONFIG->DB10 with 0, CONFIG->CR10 with 0,;
        CONFIG->DB11 with 0, CONFIG->CR11 with 0, CONFIG->DB12 with 0, CONFIG->CR12 with 0

nREC := PLAN->(lastrec())

do while ! PLAN->(eof())

   qsay(24,70,nREC--)

   if PLAN->(qrlock())
      replace PLAN->DB01 with 0, PLAN->CR01 with 0, PLAN->DB02 with 0, PLAN->CR02 with 0,;
              PLAN->DB03 with 0, PLAN->CR03 with 0, PLAN->DB04 with 0, PLAN->CR04 with 0,;
              PLAN->DB05 with 0, PLAN->CR05 with 0, PLAN->DB06 with 0, PLAN->CR06 with 0,;
              PLAN->DB07 with 0, PLAN->CR07 with 0, PLAN->DB08 with 0, PLAN->CR08 with 0,;
              PLAN->DB09 with 0, PLAN->CR09 with 0, PLAN->DB10 with 0, PLAN->CR10 with 0,;
              PLAN->DB11 with 0, PLAN->CR11 with 0, PLAN->DB12 with 0, PLAN->CR12 with 0
   else
      qmensa("N„o foi possivel completar o processo, tente novamente...","B")
      return
   endif

   replace PLAN->Descricao with alltrim(PLAN->Descricao)

   if right(PLAN->Codigo,4) == "0000"
      replace PLAN->Saldo_ant with 0
   else
      ct_prop_saldo(PLAN->Reduzido,PLAN->Saldo_ant)
   endif
   
   PLAN->(dbskip())
enddo

if ! LANC->(eof())
   i_atualiza_saldo()
endif

return

// ATUALIZA SALDO DE UM DETERMINADO MES _____________________________________

static function i_atualiza_saldo

   local cMACRODB, cMACROCR , cMESANT, nRECS := LANC->(lastrec())
   local nTOTDBMES := nTOTCRMES := 0.00
   local nATUAL    := 1

   dbunlockall()

   PLAN->(dbsetorder(3))

   LANC->(dbgotop())

   cMESANT := strzero(month(LANC->Data_lanc),2)

   qmensa("Atualizando os saldos. Aguarde...")

   do while .T.

      qgirabarra()

      cMACRODB := "DB" + strzero(month(LANC->Data_lanc),2)
      cMACROCR := "CR" + strzero(month(LANC->Data_lanc),2)

      // TOTALIZA LANC. DE DEB E CRED NO MES E ATUALIZA CONFIG ___________

      if strzero(month(LANC->Data_lanc),2) == cMESANT .and. ! LANC->(eof())
         if ! empty(LANC->Cont_db)
            nTOTDBMES += LANC->Valor
         endif
         if ! empty(LANC->Cont_cr)
            nTOTCRMES += LANC->Valor*-1
         endif
      else
         if CONFIG->(qflock())
            replace CONFIG->&("DB"+cMESANT) with nTOTDBMES
            replace CONFIG->&("CR"+cMESANT) with nTOTCRMES
         endif
         nTOTDBMES := nTOTCRMES := 0.00
         cMESANT   := strzero(month(LANC->Data_lanc),2)
         if LANC->(eof())
            exit
         endif
         CONFIG->(qunlock())
         loop
      endif

      // ATUALIZA TELA E SALDO ___________________________________________

      XNIVEL := 1

      qrsay(XNIVEL++,LANC->Data_lanc)

      nPERCENT := nATUAL / nRECS * 100

      qrsay(XNIVEL++,nPERCENT,"999")

      if PLAN->(dbseek(LANC->Cont_db))
         qrsay(XNIVEL++,PLAN->Reduzido,"@R 99999-9")
         qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40)))
         ct_prop_saldo(PLAN->Codigo,LANC->Valor,cMACRODB)
      else
         qrsay(XNIVEL++,space(6))
         qrsay(XNIVEL++,space(40))
      endif

      dbunlockall()

      if PLAN->(dbseek(LANC->Cont_cr))
         qrsay(XNIVEL++,PLAN->Reduzido,"@R 99999-9")
         qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40)))
         ct_prop_saldo(PLAN->Codigo,LANC->Valor,cMACROCR)
      else
         qrsay(XNIVEL++,space(6))
         qrsay(XNIVEL++,space(40))
      endif

      dbunlockall()

      nATUAL++

      LANC->(dbskip())

   enddo

return

