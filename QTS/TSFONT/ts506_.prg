/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE MOVIMENTO DE CAIXA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: ABRIL DE 1997
// OBS........:
function ts506

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local    cCONT := 1
private  lPRI  := .T.

private cTITULO          // titulo do relatorio
private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nSUPRI      := {}
private nPAG_TOT    := 0
private nPAGOS      := 0
private nREC_TOT    := 0
private nRECEBIDO   := 0
private nVAL_SUP    := 0
private nVAL_PAG    := 0

fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })

do while .T.

   qlbloc(05,0,"B506A","QBLOC.GLO",1)

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

   cTITULO := "MOVIMENTO DE CAIXA DE " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)

   if ! quse(XDRV_TS, "TEMP_1",,"E")
      qmensa("N„o foi poss¡vel abrir arquivo TEMP_1.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_TS, "TEMP_2",,"E")
      qmensa("N„o foi poss¡vel abrir arquivo TEMP_2.DBF !! Tente novamente.")
      return
   endif

   if TEMP_1->(qflock()) .and. TEMP_2->(qflock())
      TEMP_1->(__dbZap())
      TEMP_1->(dbCreateIndex( XDRV_TS + "TMP1", "dtos(Dt_pagto)", {|| dtos(Dt_pagto)}, if( .F., .T., NIL ) ))
      TEMP_2->(__dbZap())
      TEMP_2->(dbCreateIndex( XDRV_TS + "TMP2", "dtos(Dt_pagto)", {|| dtos(Dt_pagto)}, if( .F., .T., NIL ) ))
      TEMP_1->(dbunlock())
      TEMP_2->(dbunlock())
   endif

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   PAGOS->(Dbsetorder(7)) // numero de cheque

   do while ! PAGOS->(eof()) .and. qcontprn()  // condicao principal de loop

      if PAGOS->Data_pagto >= dDATA_INI .and. PAGOS->Data_pagto <= dDATA_FIM

          nCHEQUE := PAGOS->Nr_cheque

          PAGOS->(Dbskip())

          if PAGOS->Nr_cheque == nCHEQUE

             PAGOS->(Dbskip(-1))

             if TEMP_1->(qappend())
                replace TEMP_1->Dt_pagto  with PAGOS->Data_pagto
                replace TEMP_1->C_custo   with PAGOS->Centro
                replace TEMP_1->nr_cheque with PAGOS->nr_cheque
                replace TEMP_1->Historico with left(PAGOS->Historico,50)
                replace TEMP_1->Valor     with PAGOS->Valor_liq
                replace TEMP_1->Cod_forn  with PAGOS->Cod_forn
             endif

             PAGOS->(Dbskip())

             if TEMP_1->(qappend())
                replace TEMP_1->Dt_pagto  with PAGOS->Data_pagto
                replace TEMP_1->C_Custo   with PAGOS->Centro
                replace TEMP_1->nr_cheque with PAGOS->nr_cheque
                replace TEMP_1->Historico with left(PAGOS->Historico,50)
                replace TEMP_1->Valor     with PAGOS->Valor_liq
                replace TEMP_1->Cod_forn  with PAGOS->Cod_forn
             endif

             PAGOS->(Dbskip())

             do while ! PAGOS->(eof()) .and. PAGOS->Nr_cheque == nCHEQUE

                if TEMP_1->(qappend())
                   replace TEMP_1->Dt_pagto  with PAGOS->Data_pagto
                   replace TEMP_1->C_Custo   with PAGOS->Centro
                   replace TEMP_1->nr_cheque with PAGOS->nr_cheque
                   replace TEMP_1->Historico with left(PAGOS->Historico,50)
                   replace TEMP_1->Valor     with PAGOS->Valor_liq
                   replace TEMP_1->Cod_forn  with PAGOS->Cod_forn
                endif

                PAGOS->(Dbskip())

             enddo

             PAGOS->(dbskip())
             loop

          else

             PAGOS->(Dbskip(-1))

             if TEMP_2->(qappend())
                replace TEMP_2->Dt_pagto  with PAGOS->Data_pagto
                replace TEMP_2->C_custo   with PAGOS->Centro
                replace TEMP_2->nr_cheque with PAGOS->nr_cheque
                replace TEMP_2->Historico with left(PAGOS->Historico,50)
                replace TEMP_2->Valor     with PAGOS->Valor_liq
                replace TEMP_2->Cod_forn  with PAGOS->Cod_forn
             endif

          endif

      endif

      PAGOS->(dbskip())

   enddo

   qmensa("Aguarde... Gerando indice termporario...")

   TEMP_2->(dbCreateIndex( XDRV_TS + "TMP2", "dtos(Dt_pagto)", {|| dtos(Dt_pagto)}, if( .F., .T., NIL ) ))

   TEMP_2->(Dbsetorder(1))
   TEMP_2->(Dbgotop())

   qmensa("")

   do while ! TEMP_2->(eof())

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say replicate("-",80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "PAGAMENTO  C/CUSTO   NR.CHEQUE  FORNECEDOR                                 HISTORICO                                               VALOR"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(TEMP_2->Dt_pagto)
       @ prow()  ,12  say TEMP_2->C_Custo
       @ prow()  ,20  say TEMP_2->Nr_cheque ; FORN->(Dbseek(TEMP_2->Cod_forn))
       @ prow()  ,32  say left(FORN->Razao,40)
       @ prow()  ,75  say left(TEMP_2->Historico,50)
       @ prow()  ,127 say transform(TEMP_2->Valor, "@E 999,999.99")

       nVAL_PAG += TEMP_2->Valor
       nPAGOS := nPAGOS + TEMP_2->Valor

       TEMP_2->(dbskip())

   enddo

   @ prow(),pcol() say XCOND0
   @ prow()+1, 0 say replicate("-",80)
   @ prow()+1,0 say "Valor Total ............................... " + transform(nVAL_PAG,"@E 9,999,999.99")
   @ prow()+1, 0 say replicate("-",80)

   XPAGINA := 0

   qmensa("Aguarde... Gerando indice termporario...")

   TEMP_1->(dbCreateIndex( XDRV_TS + "TMP1", "dtos(Dt_pagto)", {|| dtos(Dt_pagto)}, if( .F., .T., NIL ) ))

   qmensa("")

   TEMP_1->(Dbsetorder(1))
   TEMP_1->(Dbgotop())

   do while ! TEMP_1->(eof())

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1,30   say XAENFAT+ "SUPRIMENTO DE CAIXA" + XDENFAT
          @ prow()+1, 0   say replicate("-",80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0   say "PAGAMENTO  C/CUSTO   NR.CHEQUE  FORNECEDOR                                 HISTORICO                                               VALOR"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0   say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(TEMP_1->Dt_pagto)
       @ prow()  ,12  say TEMP_1->C_custo
       @ prow()  ,20  say TEMP_1->nr_cheque ; FORN->(Dbseek(TEMP_1->Cod_forn))
       @ prow()  ,32  say left(FORN->Razao,40)
       @ prow()  ,75  say TEMP_1->Historico
       @ prow()  ,127 say transform(TEMP_1->Valor, "@E 999,999.99")

       nVAL_SUP += TEMP_1->Valor
       nPAGOS := nPAGOS + TEMP_1->Valor

       TEMP_1->(dbskip())

   enddo

   @ prow(),pcol() say XCOND0
   @ prow()+1, 0 say replicate("-",80)
   @ prow()+1,0 say "Valor Total do Suprimento ................. " + transform(nVAL_SUP,"@E 9,999,999.99")
   @ prow()+1, 0 say replicate("-",80)

   nSUPRI := {}

   RECEBIDO->(dbsetorder(6))  // DATA_PAGTO
   set softseek on
   RECEBIDO->(dbseek(dDATA_INI))
   set softseek off
   
   XPAGINA   := 0

   dRECEB := RECEBIDO->Data_pagto
   
   do while ! RECEBIDO->(eof()) .and. RECEBIDO->Data_pagto >= dDATA_INI .and. RECEBIDO->Data_pagto <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "RECEBIMENTO NR.DOTCO   HISTORICO                                                       VALOR"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1
       @ prow()+1,00  say dtoc(RECEBIDO->Data_pagto)
       @ prow()  ,12  say left(RECEBIDO->Fatura,7)   // ; CLI1->(Dbseek(RECEBIDO->Cod_cli))
//     @ prow()  ,22  say left(CLI1->Razao,40)
       @ prow()  ,22  say RECEBIDO->Historico
       @ prow()  ,90  say transform(RECEBIDO->Valor_liq, "@E 999,999.99")

       nRECEBIDO := nRECEBIDO + RECEBIDO->Valor_liq

       RECEBIDO->(dbskip())

   enddo

   cPICT := "@e 9,999,999.99"

   @ prow(),pcol() say XCOND0
   @ prow()+2, 0 say replicate("=",80)
   @ prow()+1, 15 say "Valor Total Recebido    > "+transform(nRECEBIDO, cPICT)
   @ prow()+1, 15 say "Valor Total Pago        > "+transform(nPAGOS, cPICT)
   @ prow()+1, 0 say replicate("=",80)

   qstopprn()

   TEMP_1->(dbclosearea())
   TEMP_2->(dbclosearea())

return
