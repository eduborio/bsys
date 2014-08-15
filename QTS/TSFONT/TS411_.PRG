/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: CONCILIACAO BANCARIA
// ANALISTA...: EDUARDo BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: FEVEREIRO DE 2010
// OBS........:
// ALTERACOES.:   
function ts411

#include "inkey.ch"
#include "setcurs.ch"

BANCO->(Dbsetorder(3)) // codigo gerado

/////////////////////////////////////////////////////////////////////////////
// VIEW PRINCIPAL ___________________________________________________________

// FILTRO COM OS LANCAMENTOS PARA CONCILIACAO _______________________________
qmensa("Aguarde, Preparando Arquivo Para Concilia‡„o ")

//  qlbloc(21,0,"B411A","QBLOC.GLO")

//select MOV_BANC

//MOV_BANC->(dbsetfilter({|| MOV_BANC->Concilia $ "2"}))

qmensa("")

MOV_BANC->(qview({{"Data/Data"                        ,0},;
                  {"i_411hist()/Hist¢rico"            ,0},;
                  {"i_411c()/Valor"                   ,0},;
                  {"i_411d()/ "                       ,0},;
                  {"i_411Tipo()/Form"                ,0},;
                  {"i_411ch()/Cheque"                 ,0},;
                  {"i_411e()/Con"                   ,0}},;
                  "05002379",;
                  {NIL,"i_411a",NIL,NIL},;
                  NIL,;
                  "<Esc> / <C>onfirma  <Espa‡o> Concilia/Desconcilia <E>xclui <A>ltera"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_411b
  BANCO->(Dbseek(MOV_BANC->Cod_banco))
return left(BANCO->Descricao,15)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR VALORES COM PICTURE _________________________________

function i_411c
local nEntrada := 0

       if left(MOV_BANC->Internal,4) == "RE00"
          if MOV_BANC->Entrada == 0
             RECEBIDO->(dbseek(right(MOV_BANC->Internal,7)))
             nEntrada := RECEBIDO->Valor
          else
             nEntrada := MOV_BANC->Entrada
          endif
       else
          nEntrada := MOV_BANC->Entrada
       endif

return transform(nEntrada + MOV_BANC->Saida,"@R 999,999.99")

function i_411d
return iif(MOV_BANC->Saida == 0,"C","D")


/////////////////////////////////////////////////////////////////////////////
// IMPRIME MARCA NA TELA SE CONCILIADO ______________________________________

function i_411e
   do case
      case MOV_BANC->Concilia == "0" ; return "N"
      case MOV_BANC->Concilia == "1" ; return "S"
   endcase
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_411a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "CAE "+chr(K_DEL)
      i_processa_acao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local zTMP            // variavel temporaria
   local nVALOR          // para editar o valor
   local nDESCP          // para edicar o descont
   local cEVENTO         // para editar o evento

   do case

      case cOPCAO == " "        ; i_concilia()    // Concilia ou Desconcilia
      case cOPCAO == "C"        ; i_confirma()    // Confirma e sai desta opcao
      case cOPCAO == "E"        ; i_exclusao()    // Exclui lancamento
      case cOPCAO == "A"        ; i_alteracao()   // Altera lancamento

   endcase

   dbunlockall()

return

/////////////////////////////////////////////////////////////////////////////
// MARCA PARA CONCILIACAO DEFINITIVA QDO CONFIRMADA _________________________

static function i_concilia

   do case
      case MOV_BANC->Concilia == "1"
           // DESMARCA CONCILIACAO __________________________________________
           if MOV_BANC->(qrlock())
              replace MOV_BANC->Concilia with "0"
           else
              qm1()
           endif
      case MOV_BANC->Concilia == "0"
           // MARCA CONCILIACAO _____________________________________________
           if MOV_BANC->(qrlock())
              replace MOV_BANC->Concilia with "1"
           else
              qm1()
           endif
   endcase

return

/////////////////////////////////////////////////////////////////////////////
// CONCILIA TODOS OS REGISTROS MARCADOS EM DEFINITIVO _______________________

static function i_confirma

   if ! qconf("Confirma concilia‡„o dos Documentos Marcados ","B")
      return
   endif

   MOV_BANC->(dbgotop())

   do while ! MOV_BANC->(eof())
      qmensa("Aguarde confirmando concilia‡”es")
      if MOV_BANC->Concilia == "1"
         if MOV_BANC->(qrlock())
            replace MOV_BANC->Concilia with "2"
            MOV_BANC->(dbskip())
         endif
      else
         MOV_BANC->(dbskip())
      endif

   enddo

qmensa("Concili‡„o Ok ")

return

function i_411Hist
loca cHist := ""

   do case
      case left(MOV_BANC->Internal,4) == "PG00"
           PAGOS->(dbseek(right(MOV_BANC->Internal,7)))
           FORN->(Dbseek(PAGOS->Cod_forn))
           cHist := "PG "+left(PAGOS->Fatura,9) + " " +left(FORN->Razao,20)
//           if PAGOS->Nr_cheque != "0000000"
//              qrsay(1,PAGOS->Nr_Cheque)
//           else
//              qrsay(1,"       ")
//           endif

      case left(MOV_BANC->Internal,4) == "RE00"
           RECEBIDO->(dbseek(right(MOV_BANC->Internal,7)))
           CLI1->(Dbseek(RECEBIDO->Cod_cli))
           cHist := "RC "+left(RECEBIDO->Fatura,9) + " " +left(CLI1->Razao,20)

      otherwise
         cHIst := left(MOV_BANC->Historico,33)

   endcase


return cHIST

function i_411Tipo
local cHist := ""

   do case
      case left(MOV_BANC->Internal,4) == "PG00"
           PAGOS->(dbseek(right(MOV_BANC->Internal,7)))
           FORN->(Dbseek(PAGOS->Cod_forn))

           do case
              case PAGOS->Tipo $ "124"
                   cHist := "Cheq"

              case PAGOS->Tipo == "3"
                   cHist := "Deb."

              case PAGOS->Tipo == "5"
                   cHist := "Ord."

              case PAGOS->Tipo == "7"
                   cHist := "OnLi"

           endcase


      otherwise
         cHist := space(6)
   endcase


return cHist

function i_411ch
local cHist := ""

   do case
      case left(MOV_BANC->Internal,4) == "PG00"
           PAGOS->(dbseek(right(MOV_BANC->Internal,7)))
           FORN->(Dbseek(PAGOS->Cod_forn))
           if PAGOS->Nr_cheque == "0000000"
              cHist := space(7)
           else
              cHist := PAGOS->Nr_cheque
           endif

      otherwise
         cHist := space(7)
   endcase


return cHist

static function i_exclusao
local  cTIPO := left(MOV_BANC->Internal,4)
local  cCod  := right(MOV_BANC->Internal,5)

   if ! qconf("Confirma exclusao?","B")
      return .F.
   endif


   do case
      case cTIPO == "RFCX"
           if REF_CAIX->(dbseek(cCOD))
              if REF_CAIX->(qrlock())
                 REF_CAIX->(dbdelete())
                 REF_CAIX->(qunlock())
              endif
           endif

      case cTIPO == "DPST"
           if DEPOSITO->(dbseek(cCOD))
              if DEPOSITO->(qrlock())
                 DEPOSITO->(dbdelete())
                 DEPOSITO->(qunlock())
              endif
           endif

      case cTIPO == "AVBC"
           if AVIS_BAN->(dbseek(cCOD))
              if AVIS_BAN->(qrlock())
                 AVIS_BAN->(dbdelete())
                 AVIS_BAN->(qunlock())
              endif
           endif

      case cTIPO == "TRBC"
           if TRAN_BCO->(dbseek(cCOD))
              if TRAN_BCO->(qrlock())
                 TRAN_BCO->(dbdelete())
                 TRAN_BCO->(qunlock())
              endif
           endif

      case cTIPO == "PGVS"
           if PAG_VIST->(dbseek(cCOD))
              if PAG_VIST->(qrlock())
                 PAG_VIST->(dbdelete())
                 PAG_VIST->(qunlock())
              endif
           endif

      case cTIPO == "RCVS"
           if REC_VIST->(dbseek(cCOD))
              if REC_VIST->(qrlock())
                 REC_VIST->(dbdelete())
                 REC_VIST->(qunlock())
              endif
           endif

      case cTIPO == "ESDP"
           if ESTORNO->(dbseek(cCOD))
              if ESTORNO->(qrlock())
                 ESTORNO->(dbdelete())
                 ESTORNO->(qunlock())
              endif
           endif

      case cTIPO == "PG00"
           if PAGOS->(dbseek("00"+cCOD))
              if PAGOS->(qrlock())
                 PAGOS->(dbdelete())
                 PAGOS->(qunlock())
              endif
           endif

      case cTIPO == "RE00"
           if RECEBIDO->(dbseek("00"+cCOD))
              if RECEBIDO->(qrlock())
                 RECEBIDO->(dbdelete())
                 RECEBIDO->(qunlock())
              endif
           endif

      case cTIPO == "CHDV"
           if CHEQ_DEV->(dbseek(cCOD))
              if CHEQ_DEV->(qrlock())
                 CHEQ_DEV->(dbdelete())
                 CHEQ_DEV->(qunlock())
              endif
           endif

   endcase

   if MOV_BANC->(qrlock())
      MOV_BANC->(dbdelete())
      MOV_BANC->(qunlock())
   endif


return

static function i_alteracao
local cTIPO  := left(MOV_BANC->Internal,4)
local  cCod  := right(MOV_BANC->Internal,5)
local cDATA  := MOV_BANC->Data
local cDATA_COMP  := MOV_BANC->Data_comp
local nvalor := MOV_BANC->Entrada + MOV_BANC->Saida
local cMOV   := iif(MOV_BANC->Saida > 0,"S","E")

   if cTIPO == "RE00"
        if RECEBIDO->(dbseek(cCOD))
           if nValor == 0
              nValor := RECEBIDO->Valor
           endif
        endif
   endif

   qlbloc(10,10,"B410A","QBLOC.GLO")
   qsay (11,30,cDATA)
   qsay (13,30,cDATA_COMP)
   qsay (15,30,nValor ,"@E 9,999,999.99")

   qgetx(11,30,@cDATA)
   qgetx(13,30,@cDATA_COMP)
   qgetx(15,30,@nVALOR,"@E 9,999,999.99")
   read

   if ! qconf("Confirma Alteracao? ","B")
      return .F.
   endif

   do case
      case cTIPO == "RFCX"
           if REF_CAIX->(dbseek(cCOD))
              if REF_CAIX->(qrlock())
                 replace REF_CAIX->Data  with cDATA
                 replace REF_CAIX->Valor with nValor
                 REF_CAIX->(qunlock())
              endif
           endif

      case cTIPO == "DPST"
           if DEPOSITO->(dbseek(cCOD))
              if DEPOSITO->(qrlock())
                 replace DEPOSITO->Data  with cDATA
                 //replace DEPOSITO->Valor with nValor
                 DEPOSITO->(qunlock())
              endif
           endif

      case cTIPO == "AVBC"
           if AVIS_BAN->(dbseek(cCOD))
              if AVIS_BAN->(qrlock())
                 replace AVIS_BAN->Data  with cDATA
                 replace AVIS_BAN->Valor with nValor
                 AVIS_BAN->(qunlock())
              endif
           endif

      case cTIPO == "TRBC"
           if TRAN_BCO->(dbseek(cCOD))
              if TRAN_BCO->(qrlock())
                 replace TRAN_BCO->Data  with cDATA
                 replace TRAN_BCO->Valor with nValor
                 TRAN_BCO->(qunlock())
              endif
           endif

      case cTIPO == "PGVS"
           if PAG_VIST->(dbseek(cCOD))
              if PAG_VIST->(qrlock())
                 replace PAG_VIST->Data  with cDATA
                 replace PAG_VIST->Valor with nValor
                 PAG_VIST->(qunlock())
              endif
           endif

      case cTIPO == "RCVS"
           if REC_VIST->(dbseek(cCOD))
              if REC_VIST->(qrlock())
                 replace REC_VIST->Data  with cDATA
                 replace REC_VIST->Valor with nValor
                 REC_VIST->(qunlock())
              endif
           endif

      case cTIPO == "ESDP"
           if ESTORNO->(dbseek(cCOD))
              if ESTORNO->(qrlock())
                 replace ESTORNO->Data      with cDATA
                 replace ESTORNO->Valor_ch1 with nValor
                 ESTORNO->(qunlock())
              endif
           endif

      case cTIPO == "PG00"
           if PAGOS->(dbseek("00"+cCOD))
              if PAGOS->(qrlock())
                 replace PAGOS->Data_pagto with cDATA
                 replace PAGOS->Valor      with nValor
                 replace PAGOS->Valor_liq  with nValor
                 PAGOS->(qunlock())
              endif
           endif

      case cTIPO == "RE00"
           if RECEBIDO->(dbseek("00"+cCOD))
              if RECEBIDO->(qrlock())
                 replace RECEBIDO->Data_pagto with cDATA
                 replace RECEBIDO->Valor      with nValor
                 replace RECEBIDO->Valor_liq  with nValor
                 RECEBIDO->(qunlock())
              endif
           endif

      case cTIPO == "CHDV"
           if CHEQ_DEV->(dbseek(cCOD))
              if CHEQ_DEV->(qrlock())
                 replace CHEQ_DEV->Data  with cDATA
                 replace CHEQ_DEV->Valor_ch1 with nValor
                 CHEQ_DEV->(qunlock())
              endif
           endif

   endcase

   if MOV_BANC->(qrlock())
      replace MOV_BANC->Data with cDATA
      replace MOV_BANC->Data_comp with cDATA_COMP
      if cMOV == "S"
         replace MOV_BANC->Saida   with nValor
      else
         replace MOV_BANC->Entrada with nValor
      endif
      MOV_BANC->(qunlock())
   endif


return







