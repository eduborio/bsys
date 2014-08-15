/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO CONTABIL
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 1998
// OBS........: EDUARDO AUGUSTO BORIO
function ts510

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private cFILIAL          // quebra por filial
private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nTOT    := 0
private nTOT_DIA:= 0
private nTOT_GER:= 0
private nENTRADA:= 0
private nSAIDA  := 0

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })

do while .T.

   qlbloc(05,0,"B503A","QBLOC.GLO",1)

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

   cTITULO := "RELATORIO CONTABIL DE " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)

   PAGOS->(dbsetorder(5))  // DATA_PAGTO

   set softseek on
   PAGOS->(dbseek(dDATA_INI))
   set softseek off

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   nTOT_DIA := 0
   nTOT     := 0

   dVENC := PAGOS->Data_pagto
   
   do while ! PAGOS->(eof()) .and. PAGOS->Data_pagto >= dDATA_INI .and. PAGOS->Data_pagto <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                   LANCAMENTOS PAGOS PELA TESOURARIA                       "
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
       nTOT := nTOT + PAGOS->Valor_liq
       nSAIDA := nSAIDA + PAGOS->Valor_liq

       PAGOS->(dbskip())

       if ! PAGOS->(eof()) .and. PAGOS->Data_pagto <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := PAGOS->Data_pagto
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,44 say "Valor Total Pago ...> "+transform(nTOT, "@E 999,999,999.99")
   endif

   PAG_VIST->(Dbsetorder(2))  // DATA
   PAG_VIST->(Dbgotop())

   set softseek on
   PAG_VIST->(dbseek(dDATA_INI))
   set softseek off
   
   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0
   dVENC := PAG_VIST->Data
   
   do while ! PAG_VIST->(eof()) .and. PAG_VIST->Data >= dDATA_INI .and. PAG_VIST->Data <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                   LANCAMENTOS PAGOS A VISTA                       "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "PAGAMENTO   NR. DOCTO     NR.CHEQUE  HISTORICO                            VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(PAG_VIST->Data)
       @ prow()  ,12  say left(PAG_VIST->Duplicata,12)
       @ prow()  ,26  say left(PAG_VIST->Num_cheque,10)
       @ prow()  ,37  say left(PAG_VIST->Historico,28)
       @ prow()  ,66  say transform(PAG_VIST->Valor, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + PAG_VIST->Valor
       nTOT := nTOT + PAG_VIST->Valor
       nSAIDA := nSAIDA + PAG_VIST->Valor

       PAG_VIST->(dbskip())

       if ! PAG_VIST->(eof()) .and. PAG_VIST->Data <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := PAG_VIST->Data
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,37 say "Valor Total Pago a Vista...> "+transform(nTOT, "@E 999,999,999.99")
   endif

   RECEBIDO->(dbsetorder(6))  // DATA_PAGTO

   set softseek on
   RECEBIDO->(dbseek(dDATA_INI))
   set softseek off
   
   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   dVENC := RECEBIDO->Data_pagto
   
   do while ! RECEBIDO->(eof()) .and. RECEBIDO->Data_pagto >= dDATA_INI .and. RECEBIDO->Data_pagto <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                  LANCAMENTOS RECEBIDOS PELA TESOURARIA                       "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  PAGAMENTO NR.DOCTO   TIPO   CLIENTE                       VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(RECEBIDO->Data_venc)
       @ prow()  ,11  say dtoc(RECEBIDO->Data_pagto)
       @ prow()  ,22  say left(RECEBIDO->Fatura,9)
       do case
          case RECEBIDO->Tipo == "1"
               @ prow()  ,32  say "CART.  "
          case RECEBIDO->Tipo == "2"
               @ prow()  ,32  say "CHEQUE"
          case RECEBIDO->Tipo == "3"
               @ prow()  ,32  say "PRE-DAT"
          case RECEBIDO->Tipo == "4"
               @ prow()  ,32  say "COB.BCO"
          case RECEBIDO->Tipo == "5"
               @ prow()  ,32  say "CAIXA"
          case RECEBIDO->Tipo == "6"
               @ prow()  ,32  say "DESCONTO"

       endcase
       CLI1->(dbseek(RECEBIDO->Cod_cli))
       @ prow()  ,40  say left(CLI1->Razao,25)
       @ prow()  ,66  say transform(RECEBIDO->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + RECEBIDO->Valor_liq
       nTOT := nTOT + RECEBIDO->Valor_liq
       nENTRADA := nENTRADA + RECEBIDO->Valor_liq

       RECEBIDO->(dbskip())

       if ! RECEBIDO->(eof()) .and. RECEBIDO->Data_pagto <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := RECEBIDO->Data_pagto
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif


   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,48 say "Valor Recebido..> "+transform(nTOT, "@E 999,999,999.99")
   endif

   REC_VIST->(Dbsetorder(2))  // DATA
   REC_VIST->(Dbgotop())

   set softseek on
   REC_VIST->(dbseek(dDATA_INI))
   set softseek off
   
   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0
   dVENC := REC_VIST->Data
   
   do while ! REC_VIST->(eof()) .and. REC_VIST->Data >= dDATA_INI .and. REC_VIST->Data <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                   LANCAMENTOS RECEBIDOS A VISTA                   "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "RECEBIMENTO  NR.DOCTO     NR.CHEQUE   HISTORICO                        VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(REC_VIST->Data)
       @ prow()  ,13  say left(REC_VIST->Duplicata,10)
       @ prow()  ,26  say REC_VIST->Num_cheque
       @ prow()  ,38  say left(REC_VIST->Historico,25)
       @ prow()  ,66  say transform(REC_VIST->Valor, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + REC_VIST->Valor
       nTOT := nTOT + REC_VIST->Valor
       nENTRADA := nENTRADA + REC_VIST->Valor

       REC_VIST->(dbskip())

       if ! REC_VIST->(eof()) .and. REC_VIST->Data <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := REC_VIST->Data
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,33 say "Valor Total Recebido a Vista...> "+transform(nTOT, "@E 999,999,999.99")
   endif

   if nSAIDA <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,44 say "Valor Total Pago ...> "+transform(nSAIDA, "@E 999,999,999.99")
   endif

   if nENTRADA <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,43 say "Valor Total Recebido.> " +transform(nENTRADA, "@E 999,999,999.99")
   endif

   qstopprn()


return
