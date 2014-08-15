/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CAIXA
// OBJETIVO...: CONSULTA RAZAO MENSAL
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1994
// OBS........:
// ALTERACOES.:
function ct301

// SOLICITA MES, ANO E CONTA ________________________________________________

#include "inkey.ch"

private nMES   := 1
private nANO   := right(CONFIG->Exercicio,4) // CONFIG->Exercicio
private cMESANO := strzero(nMES,2) + nANO
private cCONTA := space(5), cCENTRO := space(10)
private cDEBITO , cCREDITO , nSALDANT, lACHOU

PLAN->(dbsetorder(3))

do while .T.

   qlbloc(5,0,"B301A","QBLOC.GLO")

   qmensa("ESC - Cancela...")

   qgetx(06,08,@cMESANO,"@R 99/9999")


   nMES := val(left(cMESANO,2))
   nANO := right(cMESANO,4)

   if nMES > 12 .or. nMES < 0
      nMES := 1
      loop
   endif

   if lastkey() == K_ESC .or. empty(nMES) ; exit ; endif

   do while .T.


      view_plan(06,23,@cCONTA)

      if lastkey() == K_ESC .or. empty(cCONTA) ; exit ; endif

      qsay(06,23,transform(cCONTA:=strzero(val(cCONTA),6),"@R 99999-9"))
   
      if PLAN->(dbseek(cCONTA))
         qsay(06,33,left(PLAN->Descricao,26))

         view_ccusto(06,68,@cCENTRO)

         cDEBITO  := "DB" + strzero(nMES,2)
         cCREDITO := "CR" + strzero(nMES,2)

         if empty(cCENTRO)
            i_puxasaldo()
            qsay(22,12,transform(nSALDANT,"@E 9,999,999,999.99"))
            qsay(22,34,transform(PLAN->&cDEBITO+PLAN->&cCREDITO,"@E 9,999,999,999.99"))
            qsay(22,61,transform(nSALDANT+PLAN->&cDEBITO+PLAN->&cCREDITO,"@E 9,999,999,999.99"))
         else
            if left(PLAN->Codigo,1) $ "12"
               qmensa("Centro de Custo somente para Contas de Resultado !!","B")
               return
            endif

            qmensa("Aguarde, levantando saldo por Centro de Custo...")

            select PLAN
            qmensa("Filtrando Lan‡amentos com Centro de Custo. Aguarde...")
            if PLAN->(qflock())
               replace all PLAN->Saantce with 0,PLAN->Dbce with 0,PLAN->Crce with 0
               PLAN->(qunlock())
            endif
            
            select LANC
            set index to (XDRV_CT+"LA_DATA")
            LANC->(dbgotop())

            lACHOU := .F.

            i_saldoce2()

            if lACHOU
               qsay(22,12,transform(PLAN->Saantce,"@E 9,999,999,999.99"))
               qsay(22,34,transform(PLAN->Dbce+PLAN->Crce,"@E 9,999,999,999.99"))
               qsay(22,61,transform(PLAN->Saantce+PLAN->Dbce+PLAN->Crce,"@E 9,999,999,999.99"))
            endif
         endif
      else
         qmensa("Conta n„o encontrada...","B")
         loop
      endif

      i_inic(nMES,nANO)

      qsay(22,12,transform(0.00,"@E 9,999,999,999.99"))
      qsay(22,34,transform(0.00,"@E 9,999,999,999.99"))
      qsay(22,61,transform(0.00,"@E 9,999,999,999.99"))
      
   enddo

enddo

// ACIONA INICIO DA CONSULTA DO RAZAO _______________________________________

static function i_inic ( nMES, nANO )
   local dDAT, nSALDO_00, nSALDO_AT, cNSALDO, nCONT

   // CRIACAO DE INDICE TEMPORARIO __________________________________________

   qmensa("Aguarde... Criando indice temporario...")

   dDAT := nANO + strzero(nMES,2) + "01"

   select LANC
   LANC->(dbgotop())
   LANC->(dbseek(dDAT,.T.))

   if empty(cCENTRO)
//      LANC->(dbSetFilter({|| month(LANC->Data_lanc)==nMES }, 'month(LANC->Data_lanc)==nMES'))
      LANC->(dbSetFilter({|| month(LANC->Data_lanc)==nMES .and. LANC->Cont_cr == cCONTA .or. month(LANC->Data_lanc)==nMES .and. LANC->Cont_db == cCONTA }, 'month(LANC->Data_lanc)==nMES .and. LANC->Cont_cr == cCONTA .or. month(LANC->Data_lanc)==nMES .and. LANC->Cont_db == cCONTA'))
   else
//      LANC->(dbSetFilter({|| month(LANC->Data_lanc)==nMES .and. LANC->Centro == cCENTRO }, 'month(LANC->Data_lanc)==nMES .and. LANC->Centro == cCENTRO'))
      LANC->(dbSetFilter({|| month(LANC->Data_lanc)==nMES .and. LANC->Centro == cCENTRO .and. LANC->Cont_cr == cCONTA .or. month(LANC->Data_lanc)==nMES .and. LANC->Centro == cCENTRO .and. LANC->Cont_db == cCONTA }, 'month(LANC->Data_lanc)==nMES .and. LANC->Centro == cCENTRO .and. LANC->Cont_cr == cCONTA .or. month(LANC->Data_lanc)==nMES .and. LANC->Centro == cCENTRO .and. LANC->Cont_db == cCONTA'))
   endif

// if empty(cCENTRO)
//    index on dtos(Data_lanc) to (XDRV_CT+"TMP"+XUSRNUM) for cCONTA $ Cont_db + "-" + Cont_cr ;
//                                                               while month(Data_lanc) == nMES
// else
//    index on dtos(Data_lanc) to (XDRV_CT+"TMP"+XUSRNUM) for cCONTA $ Cont_db + "-" + Cont_cr ;
//                                        .and. Centro = cCENTRO while month(Data_lanc) == nMES
// endif

   // VIEW DE LANCAMENTOS EM FORMATO RAZAO __________________________________


   LANC->(qview({{"left(dtoc(Data_lanc),2)/Dia",1},;
                 {"Num_lote/Lote"              ,0},;
                 {"i_contra301()/Contra"       ,0},;
                 {"i_hist301()/Hist¢rico"      ,0},;
                 {"i_val301()/Valor"           ,0}},;
                 "07002079",;
                 {NIL,"i301a","i301b",NIL},;
                 NIL,;
                 "<Esc> / <Setas> / <H>ist"))

return

/////////////////////////////////////////////////////////////////////////////
// FORMATA O HISTORICO DO LANCAMENTO PARA O VIEW ____________________________

function i_hist301
   local cRET := ""
   HIST->(dbseek(LANC->Hp1)) ; cRET += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp2)) ; cRET += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp3)) ; cRET += alltrim(HIST->Descricao) + " "
return pad(ltrim(alltrim(cRET)+" "+LANC->Hist_comp),35)

/////////////////////////////////////////////////////////////////////////////
// RETORNA CONTRA-PARTIDA PARA O VIEW _______________________________________

function i_contra301
  local cRET := Cont_db
  if cCONTA == Cont_db
     cRET := Cont_cr
  endif
return transform(cRET,"@R 99999-9")

/////////////////////////////////////////////////////////////////////////////
// FORMATA SINAL DO VALOR PARA O VIEW _______________________________________

function i_val301
   local nVAL := Valor
   if cCONTA == Cont_cr ; nVAL *= -1 ; endif
return transform(nVAL,"@E 9,999,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// FAZ MOSTRAGEM DE HISTORICO COMPLETO (TECLA "H") __________________________

function i301a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO=="H",ct_con_hist(),)

   setcursor(nCURSOR)

   LANC->(dbsetfilter())

return ""

/////////////////////////////////////////////////////////////////////////////
// ATUALIZA TELA A CADA MOVIMENTACAO DO VIEW ________________________________

function i301b
   PLAN->(dbseek(iif(cCONTA==LANC->Cont_cr,LANC->Cont_db,LANC->Cont_cr)))
   qsay(21,19,transform(PLAN->Reduzido,"@R 99999-9"))
   qsay(21,38,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40)))
return

/////////////////////////////////////////////////////////////////////////////
// PUXA SALDO ATE MES QUE ESTA TRABALHANDO __________________________________

static function i_puxasaldo
   local nCONT

   nSALDANT := PLAN->Saldo_ant
   for nCONT = 1 to nMES
       if nCONT != nMES
          nSALDANT := nSALDANT + PLAN->&("DB"+strzero(nCONT,2)) + PLAN->&("CR"+strzero(nCONT,2))
       endif
   next
return

/////////////////////////////////////////////////////////////////////////////
// PUXA SALDO ANTERIOR PARA EMISSAO POR CENTRO DE CUSTO _____________________

static function i_saldoce2
   do while ! LANC->(eof())
      if LANC->Centro == cCENTRO
         if ! empty(LANC->Cont_cr)
            PLAN->(dbsetorder(3))
            PLAN->(dbseek(LANC->Cont_cr))
            if PLAN->(qrlock())
               if month(LANC->Data_lanc) < nMES
                  replace PLAN->Saantce with PLAN->Saantce + LANC->Valor * -1
               else
                  replace PLAN->Dbce with PLAN->Dbce + LANC->Valor * -1
               endif
               PLAN->(qunlock())
            endif
         endif
         if ! empty(LANC->Cont_db)
            PLAN->(dbsetorder(3))
            PLAN->(dbseek(LANC->Cont_db))
            if PLAN->(qrlock())
               if month(LANC->Data_lanc) < nMES
                  replace PLAN->Saantce with PLAN->Saantce + LANC->Valor
               else
                  replace PLAN->Crce with PLAN->Crce + LANC->Valor * -1
               endif
               PLAN->(qunlock())
            endif
         endif
         lACHOU := .T.
      endif
      LANC->(dbskip())
      if month(LANC->Data_lanc) > nMES
         exit
      endif
   enddo
return
