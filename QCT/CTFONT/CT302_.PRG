/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CAIXA
// OBJETIVO...: CONSULTA SALDOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1994
// OBS........:
// ALTERACOES.:
function ct302

#include "inkey.ch"

// VIEW INICIAL NO ARQUIVO DE CONTAS CONTABEIS ______________________________

PLAN->(qview({{"ct_convcod(Codigo)/C¢digo"    ,1},;
              {"left(Descricao,31)/Descri‡„o" ,2},;
              {"ct_convcod(Reduzido)/Cd.Red." ,3},;
              {"i_saldo_302()/Saldo.Atual"    ,0}},"P",;
              {NIL,"i302a",NIL,NIL},;
              NIL,"Saldos <A>cumulados / Saldos <M>ensais / <ESC> p/ sair"))

return

/////////////////////////////////////////////////////////////////////////////
// "ENTER" ACIONA CONSULTA DA CONTA SELECIONADA _____________________________

function i302a
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   qlbloc(8,0,"B302A","QBLOC.GLO",1)

   iif(cOPCAO=="A",i_sald_a(),)

   iif(cOPCAO=="M",i_sald_m(),)

return

/////////////////////////////////////////////////////////////////////////////
// CONSULTA SALDOS ACUMULADOS _______________________________________________

static function i_sald_a

   local nSALDO_ANT, nSALDO_T, nSOMA_DB, nSOMA_CR, nCONT
   local cPIC := "@E 9,999,999,999.99"

   nSALDO_ANT := PLAN->Saldo_ant

   for nCONT := 1 to 12

       nSOMA_DB := PLAN->&("DB"+strzero(nCONT,2))
       nSOMA_CR := PLAN->&("CR"+strzero(nCONT,2))

       nSALDO_T := nSOMA_DB + nSOMA_CR

       qsay(nCONT+10,12,nSALDO_ANT,cPIC)

       qsay(nCONT+10,29,nSOMA_DB  ,cPIC)

       qsay(nCONT+10,45,nSOMA_CR  ,cPIC)

       qsay(nCONT+10,61,nSALDO_T + nSALDO_ANT ,cPIC)

       nSALDO_ANT := nSALDO_T + nSALDO_ANT

   next

   qwait()

return ""

/////////////////////////////////////////////////////////////////////////////
// CONSULTA SALDOS MENSAIS __________________________________________________

static function i_sald_m

   local nSALDO_ANT, nSALDO_T, nSOMA_DB, nSOMA_CR, nCONT
   local cPIC := "@E 9,999,999,999.99"

   nSALDO_ANT := PLAN->Saldo_ant

   for nCONT := 1 to 12

       nSOMA_DB := PLAN->&("DB"+strzero(nCONT,2))
       nSOMA_CR := PLAN->&("CR"+strzero(nCONT,2))

       nSALDO_T := nSOMA_DB + nSOMA_CR

       if nCONT == 1
          qsay(nCONT+10,12,nSALDO_ANT,cPIC)
       endif

       qsay(nCONT+10,29,nSOMA_DB ,cPIC)

       qsay(nCONT+10,45,nSOMA_CR ,cPIC)

       qsay(nCONT+10,61,nSALDO_T ,cPIC)

   next

   qwait()

return ""

/////////////////////////////////////////////////////////////////////////////
// RETORNA SALDO ATUAL PARA O VIEW __________________________________________

function i_saldo_302
   local nCONT, nSALDO := PLAN->Saldo_ant

   for nCONT := 1 to 12
       nSALDO += PLAN->&("DB"+strzero(nCONT,2))
       nSALDO += PLAN->&("CR"+strzero(nCONT,2))
   next

return transform(nSALDO,"@E 999,999,999,999.99")

