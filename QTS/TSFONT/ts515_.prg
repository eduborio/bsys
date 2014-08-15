/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE CONTAS A PAGAR/PAGAS
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: SETEMBRO de 2002
// OBS........: EDUARDO AUGUSTO BORIO
function ts515

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private cFILIAL          // quebra por filial
private cFORN := space(5)           // quebra por Fornecedor

private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nTOT    := 0
private nTOT_DIA:= 0
private nTOT_GER:= 0

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })
aadd(aEDICAO,{{ || view_forn(-1,0,@cFORN                   ) } ,"FORN" })
aadd(aEDICAO,{{ || NIL                                       } ,  NIL  })

do while .T.

   qlbloc(05,0,"B503A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.

   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cFORN := space(5)
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

      case cCAMPO == "FORN"

           qrsay(XNIVEL,cFORN)

           if empty(cFORN)
              qrsay(XNIVEL++, "Todos os Fornecedores.......")
           else
              if ! FORN->(Dbseek(cFORN:=strzero(val(cFORN),5)))
                 qmensa("Fornecedor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(FORN->Razao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTAS PAGAS DE " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)


   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")
// PAGOS->(dbsetfilter({||PAGOS->Tipo != "6"},'PAGOS->Tipo != "6"')) //Somente pagamentos efetuados pelo Banco
   PAGOS->(dbsetfilter({||PAGOS->Tipo != "6" .and. iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000") .and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM}, 'PAGOS->Tipo != "6" .and. iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000").and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM'))

   PAGOS->(dbsetorder(11))
   PAGOS->(Dbgotop())

   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   dVENC := PAGOS->Data_pagto
   

   do while ! PAGOS->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                   LANCAMENTOS PAGOS PELA TESOURARIA - BANCO        "
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
       nTOT_GER := nTOT_GER + PAGOS->Valor_liq

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

   PAGOS->(dbclearfilter())

   if empty(cFORN)
       PAG_VIST->(dbsetfilter({||PAG_VIST->Forma != "E"},'PAG_VIST->Forma != "E" ')) //Somente Pagamentos feitos por Banco
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
              @ prow()+1, 0 say "                   LANCAMENTOS PAGOS A VISTA - BANCO          "
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
           nTOT_GER := nTOT_GER + PAG_VIST->Valor

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

   endif

   if nTOT_GER <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,44 say "Valor Total Pago ...> "+transform(nTOT_GER, "@E 999,999,999.99")
   endif
   PAG_VIST->(dbclearfilter())

//   PAGOS->(dbsetfilter({||PAGOS->Tipo == "6"},'PAGOS->Tipo == "6"')) //Somente pagamentos efetuados pelo Caixa
   PAGOS->(dbsetfilter({||PAGOS->Tipo == "6" .and. iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000") .and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM}, 'PAGOS->Tipo == "6" .and. iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000").and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM'))

      PAGOS->(dbsetorder(11))
      PAGOS->(Dbgotop())

   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   dVENC := PAGOS->Data_pagto
   

   do while ! PAGOS->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                   LANCAMENTOS PAGOS PELA TESOURARIA - CAIXA               "
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
       nTOT_GER := nTOT_GER + PAGOS->Valor_liq

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

   PAGOS->(dbclearfilter())

   if empty(cFORN)
       PAG_VIST->(dbsetfilter({||PAG_VIST->Forma == "E"},'PAG_VIST->Forma == "E" ')) //Somente Pagamentos feitos por Banco
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
              @ prow()+1, 0 say "                   LANCAMENTOS PAGOS A VISTA - CAIXA             "
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
           nTOT_GER := nTOT_GER + PAG_VIST->Valor

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

   endif

   if nTOT_GER <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,44 say "Valor Total Pago ...> "+transform(nTOT_GER, "@E 999,999,999.99")
   endif
   PAG_VIST->(dbclearfilter())


   qstopprn()

return
