 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CAIXA
// OBJETIVO...: VIRADA DE ANO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: NOVEMBRO DE 1995
// OBS........:
// ALTERACOES.:
function ct410

// INICIALIZACOES ___________________________________________________________

#include "inkey.ch"

local nREC, nCONT, cDEBITO, cCREDITO, XNIVEL, cHIST := space(3)
local dDATA_AB := ctod("01/01/" + right(strzero(val(CONFIG->Exercicio) + 1,4),4))

// CONFIRMA E RECONFIRMA ENCERRAMENTO DO EXERCICIO __________________________

clear_sl(05,00,23,79,31)
qlbloc(07,05,"B410B","QBLOC.GLO")
if ! qconf("Confirma Encerramento Anual ?") ; return ; endif
if ! qconf("Reconfirma Encerramento Anual ?") ; return .F. ; endif
qlbloc(05,00,"B410A","QBLOC.GLO")

// PEDE HISTORICO PARA LANCAMENTOS DE TRANSFERENCIA DE SALDO ________________

view_hist(10,18,@cHIST)

if ! empty(cHIST)
   qsay(10,18,cHIST:=strzero(val(cHIST),3))
   if ! HIST->(dbseek(cHIST))
      qmensa("Hist¢rico n„o encontrado !","B")
      return
   endif
   qsay(10,24,LEFT(HIST->Descricao,50))
else
   return
endif

qsay(12,24,dDATA_AB)

// COPIA CONFIG.DBF, LANC.DBF E PLAN.DBF PARA OLD ___________________________

copy file (XDRV_CT + "CONFIG.DBF") to (XDRV_CT + "CONFIG.OLD")
copy file (XDRV_CT + "LANC.DBF")   to (XDRV_CT + "LANC.OLD")
copy file (XDRV_CT + "PLAN.DBF")   to (XDRV_CT + "PLAN.OLD")

// TRAVA O ARQUIVO CONFIG ___________________________________________________

if ! CONFIG->(qrlock())
   qmensa("N„o foi possivel travar arquivos, tente novamente...","B")
   return
endif

// LIMPA OS SALDOS DOS 12 MESES EM ABERTO DO CONFIG.DBF _____________________

replace CONFIG->DB01 with 0, CONFIG->CR01 with 0, CONFIG->DB02 with 0, CONFIG->CR02 with 0,;
        CONFIG->DB03 with 0, CONFIG->CR03 with 0, CONFIG->DB04 with 0, CONFIG->CR04 with 0,;
        CONFIG->DB05 with 0, CONFIG->CR05 with 0, CONFIG->DB06 with 0, CONFIG->CR06 with 0,;
        CONFIG->DB07 with 0, CONFIG->CR07 with 0, CONFIG->DB08 with 0, CONFIG->CR08 with 0,;
        CONFIG->DB09 with 0, CONFIG->CR09 with 0, CONFIG->DB10 with 0, CONFIG->CR10 with 0,;
        CONFIG->DB11 with 0, CONFIG->CR11 with 0, CONFIG->DB12 with 0, CONFIG->CR12 with 0,;
        CONFIG->Exercicio with strzero(val(CONFIG->Exercicio) + 1,4) , CONFIG->Num_lanc with 0,;
        CONFIG->Zerou_resu with "N"

// ABRE ARQUIVO LANC.DBF E ZAP ______________________________________________

if ! quse(XDRV_CT,"LANC",{"LA_DATA","LA_DBDAT","LA_CRDAT","LA_NLANC"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo LANC.DBF !! Tente novamente.")
   return
endif

LANC->(__dbZap())

PLAN->(dbgotop())

do while ! PLAN->(eof())

   // PUXA SALDO FIM DO EXERCICIO ___________________________________________

   nSALDATU := PLAN->Saldo_ant

   for nCONT = 1 to 12
       cDEBITO  := "DB" + strzero(nCONT,2)
       cCREDITO := "CR" + strzero(nCONT,2)
       nSALDATU += (PLAN->&cDEBITO + PLAN->&cCREDITO)
   next

   if PLAN->(qrlock())
      replace PLAN->DB01 with 0, PLAN->CR01 with 0, PLAN->DB02 with 0, PLAN->CR02 with 0,;
              PLAN->DB03 with 0, PLAN->CR03 with 0, PLAN->DB04 with 0, PLAN->CR04 with 0,;
              PLAN->DB05 with 0, PLAN->CR05 with 0, PLAN->DB06 with 0, PLAN->CR06 with 0,;
              PLAN->DB07 with 0, PLAN->CR07 with 0, PLAN->DB08 with 0, PLAN->CR08 with 0,;
              PLAN->DB09 with 0, PLAN->CR09 with 0, PLAN->DB10 with 0, PLAN->CR10 with 0,;
              PLAN->DB11 with 0, PLAN->CR11 with 0, PLAN->DB12 with 0, PLAN->CR12 with 0,;
              PLAN->Saldo_ant with 0
   else
      qmensa("N„o foi possivel completar o processo, tente novamente...","B")
      return
   endif
   
   if ! empty(round(nSALDATU,2))

      XNIVEL := 1

      if right(PLAN->Codigo,5) != " "

         if LANC->(qappend())
            replace LANC->Data_lanc with dDATA_AB

            if nSALDATU > 0.00
               replace LANC->Cont_db with PLAN->Reduzido
            else
               replace LANC->Cont_cr with PLAN->Reduzido
            endif

            replace LANC->Valor with iif(nSALDATU<0.00,nSALDATU*-1,nSALDATU)

            replace LANC->Num_lanc with strzero(CONFIG->Num_lanc + 1,5)
            replace LANC->Hp1      with cHIST

            replace CONFIG->Num_lanc with CONFIG->Num_lanc + 1

         endif

      endif

      if nSALDATU > 0.00
         qrsay(XNIVEL++,PLAN->Reduzido,"@R 99999-9")
         qrsay(XNIVEL++,PLAN->Descricao)
         qrsay(XNIVEL++,space(6))
         qrsay(XNIVEL++,space(40))
         replace PLAN->Db01 with nSALDATU
         if right(PLAN->Codigo,5) != " "
            replace CONFIG->Db01 with CONFIG->Db01 + nSALDATU
         endif
      else
         qrsay(XNIVEL++,space(6))
         qrsay(XNIVEL++,space(40))
         qrsay(XNIVEL++,PLAN->Reduzido,"@R 99999-9")
         qrsay(XNIVEL++,PLAN->Descricao)
         replace PLAN->Cr01 with nSALDATU
         if right(PLAN->Codigo,5) != " "
            replace CONFIG->Cr01 with CONFIG->Cr01 + nSALDATU
         endif
      endif

    endif

   PLAN->(dbskip())
enddo

return

