/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: REVERSAO DE BALANCO FISCAL
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: JULHO DE 1996
// OBS........:
// ALTERACOES.:
function ct205

#include "inkey.ch"
#include "setcurs.ch"

/////////////////////////////////////////////////////////////////////////////
// DECLARACAO DE VARIAVEIS E INICIALIZACOES DIVERSAS ________________________

if empty(CONFIG->Exercicio) .or. len(alltrim(CONFIG->Exercicio)) < 4
    qmensa("Sistema sem o ano do Exerc¡cio informado !! Execute a op‡„o 803 !")
    return
endif

private dDATA_FX := ctod("")   // data do lote

PLAN->(dbsetorder(3))          // mantem a ordem em codigo reduzido p/ check...

qlbloc(5,0,"B205A","QBLOC.GLO")

qmensa("ESC - Cancela...")

qgetx(08,46,@dDATA_FX)

if empty(dDATA_FX)
   return
endif

LANC->(dbsetorder(1))

if qconf("Confirma a Revers„o do Balan‡o Fiscal ?","B")
   if LANC->(dbseek(dtos(dDATA_FX)))
      i_reverte()
   else
      qmensa("Sem lan‡amentos de encerramento do exerc¡cio na data fornecida !!","B")
   endif
endif

return

/////////////////////////////////////////////////////////////////////////////
// REVERSAO DOS LANCAMENTOS NOS SALDOS CONTABEIS ____________________________

static function i_reverte
   local lACHOU := .F.

   qmensa("Aguarde... Processando Revers„o do Balan‡o Fiscal...")

   LANC->(dbgotop())

   do while ! LANC->(eof())
      if alltrim(LANC->Num_lote) == "*FECHA"
         qgirabarra()

         if ct_trava_prop(LANC->Cont_cr,LANC->Cont_db) .and. CONFIG->(qrlock()) // A ORDEM CR/DB ESTA INVERTIDA
            qgirabarra()

            lACHOU := .T.

            XNIVEL := 1
            qrsay(XNIVEL++,LANC->Cont_db,"@R 99999-9" ) ; PLAN->(dbseek(LANC->Cont_db))
            qrsay(XNIVEL++,PLAN->Descricao    )
            qrsay(XNIVEL++,LANC->Cont_cr,"@R 99999-9" ) ; PLAN->(dbseek(LANC->Cont_cr))
            qrsay(XNIVEL++,PLAN->Descricao    )
            qrsay(XNIVEL++,LANC->Num_doc )
            qrsay(XNIVEL++,LANC->Valor,"@E 9,999,999,999.99" )
            qrsay(XNIVEL++,LANC->Hp1     ) ; HIST->(dbseek(LANC->Hp1))
            qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
            qrsay(XNIVEL++,LANC->Hp2     ) ; HIST->(dbseek(LANC->Hp2))
            qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
            qrsay(XNIVEL++,LANC->Hp3     ) ; HIST->(dbseek(LANC->Hp3))
            qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
            qrsay(XNIVEL++,left(LANC->Hist_comp,58))

            i_propagacao()

         else
            qm1()
         endif

         dbunlockall()

         if LANC->(qrlock())
            LANC->(dbdelete())
         endif

      endif

      LANC->(dbskip())

   enddo

   if lACHOU
      if CONFIG->(qrlock())
         replace CONFIG->Zerou_resu with "N"
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO GERAL DE SALDO ________________________________________________

static function i_propagacao

   // ATUALIZA SALDOS NA INCLUSAO ___________________________________________

   if ! empty(LANC->Cont_db)
      ct_prop_saldo(LANC->Cont_db,LANC->Valor*-1,"DB"+strzero(month(dDATA_FX),2))
      CONFIG->&("DB"+strzero(month(dDATA_FX),2))+=LANC->Valor*-1
   endif
   if ! empty(LANC->Cont_cr)
      ct_prop_saldo(LANC->Cont_cr,LANC->Valor*-1,"CR"+strzero(month(dDATA_FX),2))
      CONFIG->&("CR"+strzero(month(dDATA_FX),2))+=LANC->Valor
   endif

return

