/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE CONTROLE DE CAIXA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: ABRIL DE 1997
// OBS........:
function ts505

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nPAG_TOT    := 0
private nPAGOS      := 0
private nREC_TOT    := 0
private nRECEBIDO   := 0

private nTOT_DIA:= 0

fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })

do while .T.

   qlbloc(05,0,"B505A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTROLE DE CAIXA DE " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)

   PAG_TESO->(dbsetorder(4))  // DATA_EMISS

   set softseek on
   PAG_TESO->(dbseek(dDATA_INI))

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   dVENC := PAG_TESO->Data_emiss
   
   do while ! PAG_TESO->(eof()) .and. PAG_TESO->Data_emiss >= dDATA_INI .and. PAG_TESO->Data_emiss <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "      LANCAMENTOS A PAGAR LIBERADOS PARA A TESOURARIA - AGUARDANDO BAIXA  "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  NR.DOCTO   CODIGO FORNECEDOR                             VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(PAG_TESO->Data_venc)
       @ prow()  ,11  say left(PAG_TESO->Fatura,6)
       @ prow()  ,23  say PAG_TESO->Cod_forn ; FORN->(Dbseek(PAG_TESO->Cod_forn))
       @ prow()  ,30  say left(FORN->Razao,34)
       @ prow()  ,66  say transform(PAG_TESO->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + PAG_TESO->Valor_liq
       nPAG_TOT := nPAG_TOT + PAG_TESO->Valor_liq

       PAG_TESO->(dbskip())

       if ! PAG_TESO->(eof()) .and. PAG_TESO->Data_venc <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := PAG_TESO->Data_venc
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   @ prow()+1, 0 say replicate("-",80)
//   @ prow()+1,41 say "Valor Total a Pagar ...> "+transform(nPAG_TOT, "@E 999,999,999.99")

   PAGOS->(dbsetorder(3))  // DATA_EMISS

   set softseek on
   PAGOS->(dbseek(dDATA_INI))
   
   XPAGINA  := 0
   nTOT_DIA := 0

   dVENC := PAGOS->Data_emiss
   
   do while ! PAGOS->(eof()) .and. PAGOS->Data_emiss >= dDATA_INI .and. PAGOS->Data_emiss <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "              LANCAMENTOS A PAGAR PAGOS PELA TESOURARIA               "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  PAGAMENTO NR.DOCTO   CODIGO FORNECEDOR                    VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(PAGOS->Data_venc)
       @ prow()  ,11  say dtoc(PAGOS->Data_pagto)
       @ prow()  ,22  say left(PAGOS->Fatura,10)
       @ prow()  ,33  say PAGOS->Cod_forn ; FORN->(Dbseek(PAGOS->Cod_forn))
       @ prow()  ,40  say left(FORN->Razao,25)
       @ prow()  ,66  say transform(PAGOS->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + PAGOS->Valor_liq
       nPAGOS := nPAGOS + PAGOS->Valor_liq

       PAGOS->(dbskip())

       if ! PAGOS->(eof()) .and. PAGOS->Data_venc <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := PAGOS->Data_venc
       endif

   enddo
   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
   endif

   @ prow()+1, 0 say replicate("-",80)
//   @ prow()+1,44 say "Valor Total Pago ...> "+transform(nPAGOS, "@E 999,999,999.99")

   REC_TESO->(dbsetorder(4))  // DATA_EMISS

   set softseek on
   REC_TESO->(dbseek(dDATA_INI))

   dVENC    := REC_TESO->Data_emiss
   nTOT_DIA := 0
   XPAGINA  := 0
   
   do while ! REC_TESO->(eof()) .and. REC_TESO->Data_emiss >= dDATA_INI .and. REC_TESO->Data_emiss <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "      LANCAMENTOS A RECEBER LIBERADOS PARA A TESOURARIA - AGUARDANDO BAIXA     "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  NR.DOCTO   CODIGO CLIENTE                                VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(REC_TESO->Data_venc)
       @ prow()  ,12  say left(REC_TESO->Fatura,10)
       @ prow()  ,23  say REC_TESO->Cod_cli ; CLI1->(Dbseek(REC_TESO->Cod_cli))
       @ prow()  ,30  say left(CLI1->Razao,34)
       @ prow()  ,66  say transform(REC_TESO->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + REC_TESO->Valor_liq
       nREC_TOT := nREC_TOT + REC_TESO->Valor_liq

       REC_TESO->(dbskip())

       if ! REC_TESO->(eof()) .and. REC_TESO->Data_venc <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := REC_TESO->Data_venc
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   @ prow()+1, 0 say replicate("-",80)
//   @ prow()+1,41 say "Valor Total a Pagar ...> "+transform(nREC_TOT, "@E 999,999,999.99")

   RECEBIDO->(dbsetorder(4))  // DATA_EMISS

   set softseek on
   RECEBIDO->(dbseek(dDATA_INI))
   
   XPAGINA   := 0
   nTOT_DIA  := 0

   dVENC := RECEBIDO->Data_emiss
   
   do while ! RECEBIDO->(eof()) .and. RECEBIDO->Data_emiss >= dDATA_INI .and. RECEBIDO->Data_emiss <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "          LANCAMENTOS A RECEBER RECEBIDOS PELA TESOURARIA             "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  PAGAMENTO NR.DOCTO   CODIGO CLIENTE                       VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(RECEBIDO->Data_venc)
       @ prow()  ,12  say dtoc(RECEBIDO->Data_pagto)
       @ prow()  ,22  say left(RECEBIDO->Fatura,10)
       @ prow()  ,33  say RECEBIDO->Cod_cli  ; CLI1->(Dbseek(RECEBIDO->Cod_cli))
       @ prow()  ,40  say left(CLI1->Razao,25)
       @ prow()  ,66  say transform(RECEBIDO->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + RECEBIDO->Valor_liq
       nRECEBIDO := nRECEBIDO + RECEBIDO->Valor_liq

       RECEBIDO->(dbskip())

       if ! RECEBIDO->(eof()) .and. RECEBIDO->Data_venc <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := RECEBIDO->Data_venc
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
   endif

   @ prow()+1, 0 say replicate("-",80)
//   @ prow()+1,44 say "Valor Total Pago ...> "+transform(nRECEBIDO, "@E 999,999,999.99")

   @ prow()+1, 0 say replicate("=",80)
   @ prow()+1, 0 say "============================== RESUMO DO MOVIMENTO ============================="

   cPICT := "@E 999,999,999.99"

   @ prow()+1, 15 say "Valor Total a Pagar     > "+transform(nPAG_TOT , cPICT)
   @ prow()+1, 15 say "Valor Total Pago        > "+transform(nPAGOS   , cPICT)
   @ prow()+2, 15 say "Valor Total a Receber   > "+transform(nREC_TOT , cPICT)
   @ prow()+1, 15 say "Valor Total Recebido    > "+transform(nRECEBIDO, cPICT)
   @ prow()+2, 15 say "Saldo Atual             > "+transform(nRECEBIDO-nPAGOS, cPICT)
   @ prow()+1, 15 say "Saldo Previsto          > "+transform(nREC_TOT-nPAG_TOT, cPICT)
   @ prow()+1, 0 say replicate("=",80)

   qstopprn()

return
