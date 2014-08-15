/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO PAGAS/ BANCO/CAIXA
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: SETEMBRO de 2002
// OBS........: EDUARDO AUGUSTO BORIO
function ts518

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

   if ! quse(XDRV_TS, "PAGTMP",,"E")
      qmensa("N„o foi poss¡vel abrir arquivo PAGTMP.DBF !! Tente novamente.")
      return
   endif


   if PAGTMP->(qflock())
      PAGTMP->(__dbZap())
      PAGTMP->(dbCreateIndex( XDRV_TS + "PAGTMP", "dtos(Pagto)+Forn", {|| dtos(Pagto)+Forn}, if( .F., .T., NIL ) ))
      PAGTMP->(dbunlock())
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
// PAGOS->(dbsetfilter({||PAGOS->Tipo != "6"},'PAGOS->Tipo != "6"')) //Somente pagamentos efetuados pelo Banco
   PAGOS->(dbsetfilter({||PAGOS->Tipo != "6" .and. iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000") .and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM}, 'PAGOS->Tipo != "6" .and. iif(!empty(cCLIENTE),Cod_forn == cFORN,Cod_forn != "00000").and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM'))

   PAGOS->(dbsetorder(11))
   PAGOS->(Dbgotop())

   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   do while ! PAGOS->(eof()) // condicao principal de loop

       if PAGTMP->(qappend())
          replace PAGTMP->Venc  with PAGOS->Data_venc
          replace PAGTMP->Pagto with PAGOS->Data_pagto
          replace PAGTMP->Docto with PAGOS->Fatura
          replace PAGTMP->Forn  with PAGOS->Fornec
          replace PAGTMP->Valor with PAGOS->Valor_liq
       endif

       PAGOS->(dbskip())

   enddo
   PAGTMP->(dbcommit())
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

       do while ! PAG_VIST->(eof()) .and. PAG_VIST->Data >= dDATA_INI .and. PAG_VIST->Data <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

          if PAGTMP->(qappend())
             replace PAGTMP->Pagto  with PAG_VIST->Data
             replace PAGTMP->Docto  with PAG_VIST->Duplicata
             replace PAGTMP->Forn   with left(PAG_VIST->HIstorico,25)
             replace PAGTMP->cheque with PAG_VIST->Num_cheque
             replace PAGTMP->Valor  with PAG_VIST->Valor
          endif

          PAG_VIST->(dbskip())
      enddo
      PAGTMP->(dbcommit())
   endif

   qmensa("Aguarde... Gerando indice termporario...")

   PAGTMP->(dbCreateIndex( XDRV_TS + "PAG_TMP", "dtos(Pagto)+Forn", {|| dtos(Pagto)+Forn}, if( .F., .T., NIL ) ))

   PAGTMP->(Dbsetorder(1))
   PAGTMP->(Dbgotop())
   dVENC := PAGTMP->Pagto
   do while ! PAGTMP->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                   LANCAMENTOS PAGOS PELO BANCO           "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  PAGAMENTO NR.DOCTO   CHEQUE FORNECEDOR/HISTORICO          VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(PAGTMP->Venc)
       @ prow()  ,11  say dtoc(PAGTMP->Pagto)
       @ prow()  ,22  say left(PAGTMP->Docto,10)
       @ prow()  ,32  say PAGTMP->Cheque
       @ prow()  ,40  say left(PAGTMP->Forn,25)
       @ prow()  ,66  say transform(PAGTMP->Valor, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + PAGTMP->Valor
       nTOT := nTOT + PAGTMP->Valor
       nTOT_GER := nTOT_GER + PAGTMP->Valor

       PAGTMP->(dbskip())

       if ! PAGTMP->(eof()) .and. PAGTMP->Pagto <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := PAGTMP->Pagto
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

   PAG_VIST->(dbclearfilter())
   PAGTMP->(dbclosearea())

   if ! quse(XDRV_TS, "PAGTMP",,"E")
      qmensa("N„o foi poss¡vel abrir arquivo PAGTMP.DBF !! Tente novamente.")
      return
   endif


   if PAGTMP->(qflock())
      PAGTMP->(__dbZap())
      PAGTMP->(dbCreateIndex( XDRV_TS + "PAGTMP", "dtos(Data_pagto)+Forn", {|| dtos(Pagto)+Forn}, if( .F., .T., NIL ) ))
      PAGTMP->(dbunlock())
   endif

   qmensa("Aguarde... Gerando indice termporario...")

//   PAGOS->(dbsetfilter({||PAGOS->Tipo == "6"},'PAGOS->Tipo == "6"')) //Somente pagamentos efetuados pelo Caixa
   PAGOS->(dbsetfilter({||PAGOS->Tipo == "6" .and. iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000") .and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM}, 'PAGOS->Tipo == "6" .and. iif(!empty(cCLIENTE),Cod_forn == cFORN,Cod_forn != "00000").and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM'))

   PAGOS->(dbsetorder(11))
   PAGOS->(Dbgotop())

   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   do while ! PAGOS->(eof()) .and. qcontprn()  // condicao principal de loop

       if PAGTMP->(qappend())
          replace PAGTMP->Venc  with PAGOS->Data_venc
          replace PAGTMP->Pagto with PAGOS->Data_pagto
          replace PAGTMP->Docto with PAGOS->Fatura
          replace PAGTMP->Forn  with PAGOS->Fornec
          replace PAGTMP->Valor with PAGOS->Valor_liq
       endif

       PAGOS->(dbskip())

   enddo
   PAGTMP->(dbcommit())

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

       do while ! PAG_VIST->(eof()) .and. PAG_VIST->Data >= dDATA_INI .and. PAG_VIST->Data <= dDATA_FIM .and. qcontprn()  // condicao principal de loop
          if PAGTMP->(qappend())
             replace PAGTMP->Pagto  with PAG_VIST->Data
             replace PAGTMP->Docto  with PAG_VIST->Duplicata
             replace PAGTMP->Forn   with left(PAG_VIST->HIstorico,25)
             replace PAGTMP->cheque with PAG_VIST->Num_cheque
             replace PAGTMP->Valor  with PAG_VIST->Valor
          endif

          PAG_VIST->(dbskip())

       enddo
       PAGTMP->(dbcommit())

   endif

   PAG_VIST->(dbclearfilter())


   set softseek on
   DEPOSITO->(Dbsetorder(2)) // data
   DEPOSITO->(dbgotop())
   DEPOSITO->(Dbseek(dDATA_INI))
   set softseek off

   do while ! DEPOSITO->(eof()) .and. DEPOSITO->Data >= dData_ini .and. DEPOSITO->Data <= dDATA_FIM .and. qcontprn()  // condicao principal de loop
      if PAGTMP->(qappend())
         replace PAGTMP->Pagto  with DEPOSITO->Data
         replace PAGTMP->Docto  with DEPOSITO->Docto
         replace PAGTMP->Forn   with "Dep.: "+left(DEPOSITO->Historico,19)
         replace PAGTMP->cheque with DEPOSITO->Docto
         replace PAGTMP->Valor  with (DEPOSITO->Valor_ch1 + DEPOSITO->Valor_ch2+DEPOSITO->Valor_es1+DEPOSITO->Valor_es2)
      endif



      DEPOSITO->(dbskip())
   enddo
   PAGTMP->(dbcommit())

   PAG_VIST->(dbclearfilter())





   qmensa("Aguarde... Gerando indice termporario...")

   PAGTMP->(dbCreateIndex( XDRV_TS + "PAGTMP", "dtos(Pagto)+Forn", {|| dtos(Pagto)+Forn}, if( .F., .T., NIL ) ))

   PAGTMP->(Dbsetorder(1))
   PAGTMP->(Dbgotop())
   dVENC := PAGTMP->Pagto
   do while ! PAGTMP->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                   LANCAMENTOS PAGOS PELO CAIXA           "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  PAGAMENTO NR.DOCTO   CHEQUE FORNECEDOR/HISTORICO          VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(PAGTMP->Venc)
       @ prow()  ,11  say dtoc(PAGTMP->Pagto)
       @ prow()  ,22  say left(PAGTMP->Docto,10)
       @ prow()  ,32  say PAGTMP->Cheque
       @ prow()  ,40  say left(PAGTMP->Forn,25)
       @ prow()  ,66  say transform(PAGTMP->Valor, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + PAGTMP->Valor
       nTOT := nTOT + PAGTMP->Valor
       nTOT_GER := nTOT_GER + PAGTMP->Valor

       PAGTMP->(dbskip())

       if ! PAGTMP->(eof()) .and. PAGTMP->Pagto <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := PAGTMP->Pagto
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


   qstopprn()

return
