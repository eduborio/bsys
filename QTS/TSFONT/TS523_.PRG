/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE MOVIMENTO DO CAIXA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 2007
// OBS........:
// ALTERACAO..:
function ts523

#define K_MAX_LIN 50

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________


local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private cTITULO          // titulo do relatorio
private nCOD             // codigo do historico padrao para montar historico
private nHISTORICO
private nENTRADA := 0
private nCHEQUE  := 0
private nESPECIE := 0
private nBOLETO  := 0
private nC_CORR  := 0
private nSAIDA   := 0
private dINI := dFIM := ctod("")
private aEdicao := {}

fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI                   ) } ,"dINI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM                   ) } ,"dFIM" })

do while .T.

   qlbloc(5,0,"B523A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   set softseek off

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "INI"
           if empty(dINI) ; return .F. ; endif
           //dFIM := qfimmes(dINI)
           //qrsay(XNIVEL+1,dFIM)

      case cCAMPO == "FIM"
           if empty(dFIM) ; return .F. ; endif
           if dINI > dFIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

   endcase

return .T.

if ( i_inicializacao() , i_impressao() , NIL )

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE MOVIMENTO DO CAIXA DE: " + dtoc(dINI) + " A "+dtoc(dFIM)

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   set softseek on
   REF_CAIX->(Dbsetorder(2)) // data
   REF_CAIX->(dbgotop())
   REF_CAIX->(Dbseek(dINI))
   set softseek off

   do while ! REF_CAIX->(eof()) .and. REF_CAIX->Data >= dINI .and. REF_CAIX->Data <= dFIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          //prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow()+1, 0 say "DATA         NR. DOC          Valor  Origem/Destino                    Dinheiro       Cheque      Boleto    C/Corrente          Saida"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(REF_CAIX->Data)
       @ prow()  ,14  say REF_CAIX->Docto
       @ prow()  ,26  say transform(REF_CAIX->Valor,"@E 999,999.99")
       @ prow()  ,38  say "REFORCO DE CAIXA"
       @ prow()  ,84  say transform(REF_CAIX->Valor,"@E 999,999.99")



       nENTRADA += REF_CAIX->Valor

       REF_CAIX->(dbskip())

   enddo

   set softseek on
   DEPOSITO->(Dbsetorder(2)) // data
   DEPOSITO->(dbgotop())
   DEPOSITO->(Dbseek(dINI))
   set softseek off

   do while ! DEPOSITO->(eof()) .and. DEPOSITO->Data >= dINI .and. DEPOSITO->Data <= dFIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          //@ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow()+1, 0 say "DATA         NR. DOC          Valor  Origem/Destino                    Dinheiro       Cheque      Boleto    C/Corrente          Saida"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(DEPOSITO->Data)
       @ prow()  ,14  say DEPOSITO->Docto
       nVALOR := DEPOSITO->Valor_ch1 + DEPOSITO->Valor_ch2 + DEPOSITO->Valor_es1 + DEPOSITO->Valor_es2

       @ prow()  ,26  say transform(nVALOR,"@E 999,999.99")

       @ prow()  ,38  say "DEPOSITO BANCARIO"
       @ prow()  ,123  say transform(nVALOR,"@E 999,999.99")
       nSAIDA += nVALOR

       DEPOSITO->(dbskip())

   enddo

   set softseek on
   CHEQ_DEV->(Dbsetorder(2)) // data
   CHEQ_DEV->(dbgotop())
   CHEQ_DEV->(Dbseek(dINI))
   set softseek off

   do while ! CHEQ_DEV->(eof()) .and. CHEQ_DEV->Data >= dINI .and. CHEQ_DEV->Data <= dFIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          //@ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow()+1, 0 say "DATA         NR. DOC          Valor  Origem/Destino                    Dinheiro       Cheque      Boleto    C/Corrente          Saida"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(CHEQ_DEV->Data)
       @ prow()  ,14  say CHEQ_DEV->Docto

       nVALOR := CHEQ_DEV->Valor_ch1
       @ prow()  ,26  say transform(nVALOR,"@E 999,999.99")

       @ prow()  ,38  say "CHEQUE DEVOLVIDO"
       @ prow()  ,83  say transform(nVALOR,"@E 999,999.99")
       nENTRADA += nVALOR

       CHEQ_DEV->(dbskip())

   enddo

   set softseek on
   ESTORNO->(Dbsetorder(2)) // data
   ESTORNO->(dbgotop())
   ESTORNO->(Dbseek(dINI))
   set softseek off

   do while ! ESTORNO->(eof()) .and. ESTORNO->Data >= dINI .and. ESTORNO->Data <= dFIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DATA         NR. DOC          Valor  Origem/Destino                    Dinheiro       Cheque      Boleto    C/Corrente          Saida"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(ESTORNO->Docto)
       @ prow()  ,14  say ESTORNO->Docto
       nVALOR := ESTORNO->Valor_ch1

       @ prow()  ,26  say transform(nVALOR,"@E 999,999.99")

       @ prow()  ,38  say "ESTORNO DE DEPOSITO"
       @ prow()  ,70  say transform(nVALOR,"@E 999,999.99")
       nENTRADA += nVALOR

       ESTORNO->(dbskip())

   enddo


   set softseek on
   REC_VIST->(Dbsetorder(2)) // data
   REC_VIST->(dbgotop())
   REC_VIST->(Dbseek(dINI))
   set softseek off

   do while ! REC_VIST->(eof()) .and. REC_VIST->Data >= dINI .and. REC_VIST->Data <= dFIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DATA         NR. DOC          Valor  Origem/Destino                    Dinheiro       Cheque      Boleto    C/Corrente          Saida"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(REC_VIST->Data)
       @ prow()  ,14  say REC_VIST->Duplicata
       @ prow()  ,26  say transform(REC_VIST->Valor,"@E 999,999.99")

       @ prow()  ,38  say left(REC_VIST->Favorecido,30)
       @ prow()  ,70  say transform(REC_VIST->Valor,"@E 999,999.99")
       nENTRADA += REC_VIST->Valor

       REC_VIST->(dbskip())

   enddo

   RECEBIDO->(dbsetfilter({||RECEBIDO->Tipo != "4" .and. RECEBIDO->Tipo != "6"},'RECEBIDO->Tipo != "4".and. RECEBIDO->Tipo != "6" '))
   set softseek on
   RECEBIDO->(Dbsetorder(6)) // data recebimento
   RECEBIDO->(dbgotop())
   RECEBIDO->(Dbseek(dtos(dINI)))
   set softseek off
   do while ! RECEBIDO->(eof()) .and. RECEBIDO->Data_pagto >= dINI .and. RECEBIDO->Data_pagto <= dFIM  .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          //@ prow()+1, 0 say "NR. NF           Valor  Destino                                         Dinheiro       Cheque      Boleto    C/Corrente"
          @ prow()+1, 0 say "DATA         NR. DOC          Valor  Origem/Destino                    Dinheiro       Cheque      Boleto    C/Corrente          Saida"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(RECEBIDO->Data_pagto)
       @ prow()  ,14  say left(RECEBIDO->Fatura,9)
       @ prow()  ,26  say transform(RECEBIDO->Valor_liq,"@E 999,999.99")
       CLI1->(Dbseek(RECEBIDO->Cod_Cli))
       @ prow()  ,38  say left(CLI1->Razao,30)
       @ prow()  ,70  say iif(RECEBIDO->Vlr_espec<>0,transform(RECEBIDO->Vlr_espec,"@E 999,999.99"),"")
       @ prow()  ,83  say iif(RECEBIDO->Vlr_Cheque<>0,transform(RECEBIDO->Vlr_Cheque,"@E 999,999.99"),"")

       nCHEQUE  += RECEBIDO->Vlr_Cheque
       nESPECIE += RECEBIDO->Vlr_espec
       nENTRADA += RECEBIDO->Valor_liq

       RECEBIDO->(dbskip())

   enddo

   set softseek on
   RECEBER->(Dbsetorder(4)) // data recebimento
   RECEBER->(dbgotop())
   RECEBER->(Dbseek(dINI))
   set softseek off
   do while ! RECEBER->(eof()) .and. RECEBER->Data_emiss >= dINI .and. RECEBER->Data_emiss <= dINI  .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
         // @ prow()+1, 0 say "NR. NF           Valor  Destino                                         Dinheiro       Cheque      Boleto    C/Corrente"
          @ prow()+1, 0 say "DATA         NR. NF           Valor  Origem/Destino                    Dinheiro       Cheque      Boleto    C/Corrente          Saida"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(RECEBER->Data_emiss)
       @ prow()  ,14  say left(RECEBER->Fatura,9)
       @ prow()  ,26  say transform(RECEBER->Valor_liq,"@E 999,999.99")
       CLI1->(Dbseek(RECEBER->Cod_Cli))
       @ prow()  ,38  say left(CLI1->Razao,30)

       if RECEBER->Tipo_doc == "02" //Boleto
          @ prow()  ,95  say transform(RECEBER->Valor_liq,"@E 999,999.99")
          nBOLETO += RECEBER->Valor_liq
       endif

       if RECEBER->Tipo_doc == "03" //Conta Corrente
          @ prow()  ,109  say transform(RECEBER->Valor_liq,"@E 999,999.99")
          nC_CORR += RECEBER->Valor_liq

       endif

       RECEBER->(dbskip())

   enddo

   PAG_VIST->(Dbsetfilter({||PAG_VIST->Forma == "E"},'PAG_VIST->Forma == "E"'))
   set softseek on
   PAG_VIST->(Dbsetorder(2)) // data
   PAG_VIST->(dbgotop())
   PAG_VIST->(Dbseek(dINI))
   set softseek off

   do while ! PAG_VIST->(eof()) .and. PAG_VIST->Data >= dINI .and. PAG_VIST->Data <= dFIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DATA         NR. DOC          Valor  Origem/Destino                    Dinheiro       Cheque      Boleto    C/Corrente          Saida"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(PAG_VIST->Data)
       @ prow()  ,14  say PAG_VIST->Duplicata
       @ prow()  ,26  say transform(PAG_VIST->Valor,"@E 999,999.99")

       @ prow()  ,38  say left(PAG_VIST->Favorecido,30)
       @ prow()  ,123 say transform(PAG_VIST->Valor,"@E 999,999.99")

       nSAIDA += PAG_VIST->Valor

       PAG_VIST->(dbskip())

   enddo



   PAGOS->(dbsetfilter({||PAGOS->Tipo == "6"},'PAGOS->Tipo == "6"'))
   set softseek on
   PAGOS->(Dbsetorder(5)) // data pagto
   PAGOS->(dbgotop())
   PAGOS->(Dbseek(dtos(dINI)))
   set softseek off
   do while ! PAGOS->(eof()) .and. PAGOS->Data_pagto >= dINI .and. PAGOS->Data_pagto <= dFIM  .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
//          @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow()+1, 0 say "DATA         NR. NF           Valor  Origem/Destino                    Dinheiro       Cheque      Boleto    C/Corrente          Saida"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(PAGOS->data_pagto)
       @ prow()  ,14  say left(PAGOS->Fatura,9)
       @ prow()  ,26  say transform(PAGOS->Valor_liq,"@E 999,999.99")
       FORN->(Dbseek(PAGOS->Cod_forn))
       @ prow()  ,38  say left(FORN->Razao,30)
       @ prow()  ,123 say transform(PAGOS->Valor_liq,"@E 999,999.99")


       nSAIDA += PAGOS->Valor_liq

       PAGOS->(dbskip())

   enddo

   @ prow(),pcol() say XCOND0

   if (nENTRADA + nSAIDA) == 0
      qcabecprn(cTITULO,80)
      @ prow(),pcol() say XCOND1
      @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
      @ prow(),pcol() say XCOND0
      @ prow()+1, 0 say replicate("-",80)

   endif
   @ prow()+1, 0 say replicate("=",80)
   @ prow()+1,44 say "TOTAIS DO DIA "
   @ prow()  ,50 say transform(nENTRADA,"@E 99,999,999.99")
   @ prow()  ,67 say transform(nSAIDA,"@E 99,999,999.99")
   SALD_CAI->(dbseek(dINI))
   @ prow()+1,44 say "SALDO ANTERIOR"
   @ prow()  ,50 say transform(SALD_CAI->Saldo,"@E 99,999,999.99")
   @ prow()+1,44 say "SALDO ATUAL"
   @ prow()  ,67 say transform(SALD_CAI->Saldo+(nENTRADA-nSAIDA),"@E 99,999,999.99")
   @ prow()+1,44 say "CONFERENCIA"
   @ prow()  ,50 say transform(nENTRADA+SALD_CAI->Saldo,"@E 999,999.99")
   @ prow()  ,67 say transform(nSAIDA+SALD_CAI->Saldo+(nENTRADA-nSAIDA),"@E 99,999,999.99")
   @ prow()+1, 0 say replicate("=",80)
   @ prow()+1,44 say "BOLETO.: "+transform(nBOLETO,"@E 99,999,999.99")
   @ prow()+1,44 say "C/C. ..: "+transform(nC_CORR,"@E 99,999,999.99")

   nENTRADA := 0
   nCHEQUE  := 0
   nESPECIE := 0
   nBOLETO  := 0
   nC_CORR  := 0
   nSAIDA   := 0


   qstopprn()

return


