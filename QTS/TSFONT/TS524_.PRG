/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE MOVIMENTO DO CAIXA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 2007
// OBS........:
// ALTERACAO..:
function ts524

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
private dINI :=  dFIM := ctod("")
private aEDICAO := {}

fu_abre_cli1()


//BANCO->(dbsetorder(3)) // codigo do banco

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI                   ) } ,"dINI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM                   ) } ,"dFIM" })

do while .T.

   qlbloc(5,0,"B524A","QBLOC.GLO",1)
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

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE MOVIMENTO DO CAIXA DE: " + dtoc(dINI)+ " A "+dtoc(dFIM)

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
// REF_CAIX->(Dbseek(CONFIG->Data_atual))
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
          @ prow()+1, 0 say "DATA       NR. DOC      Nr Cheque  Origem/Destino                       Entrada      Saida      Historico"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(REF_CAIX->Data)
       @ prow()  ,12  say REF_CAIX->Docto
       @ prow()  ,25  say REF_CAIX->Num_cheque
       @ prow()  ,36  say left(REF_CAIX->Favorecido,32)
       @ prow()  ,70  say transform(REF_CAIX->Valor,"@E 999,999.99")
       @ prow()  ,97  say "Reforco de Caixa"




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
        //@ prow()+1, 0 say "NR. DOC      Nr Cheque  Origem/Destino                                   Entrada      Saida      Historico"
          @ prow()+1, 0 say "DATA       NR. DOC      Nr Cheque  Origem/Destino                     Entrada      Saida      Historico"


          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(DEPOSITO->Data)
       @ prow()  ,12  say DEPOSITO->Docto
       BANCO->(Dbsetorder(3))
       BANCO->(Dbseek(DEPOSITO->Banco))
       @ prow()  ,36  say left(BANCO->Descricao,32)
       nVALOR := DEPOSITO->Valor_ch1 + DEPOSITO->Valor_ch2 + DEPOSITO->Valor_es1 + DEPOSITO->Valor_es2
       @ prow()  ,81  say transform(nVALOR,"@E 999,999.99")
       @ prow()  ,97  say "Deposito Bancario"
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
          @ prow()+1, 0 say "DATA       NR. DOC      Nr Cheque  Origem/Destino                     Entrada      Saida      Historico"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(CHEQ_DEV->Data)
       @ prow()  ,12  say CHEQ_DEV->Docto
       @ prow()  ,25  say CHEQ_DEV->Docto
       BANCO->(Dbsetorder(3))
       BANCO->(Dbseek(CHEQ_DEV->Banco))
       @ prow()  ,36  say left(BANCO->Descricao,32)
       nVALOR := CHEQ_DEV->Valor_ch1
       @ prow()  ,70  say transform(nVALOR,"@E 999,999.99")
       nENTRADA += nVALOR
       @ prow()  ,97  say "Cheque Devolvido"

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
          @ prow()+1, 0 say "DATA       NR. DOC      Nr Cheque  Origem/Destino                     Entrada      Saida      Historico"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(ESTORNO->Data)
       @ prow()  ,12  say ESTORNO->Docto
       BANCO->(Dbsetorder(3))
       BANCO->(Dbseek(ESTORNO->Banco))
       @ prow()  ,36  say left(BANCO->Descricao,32)
       nVALOR := ESTORNO->Valor_ch1
       @ prow()  ,70  say transform(nVALOR,"@E 999,999.99")
       @ prow()  ,97  say "Estorno de Deposito"
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
          @ prow()+1, 0 say "DATA       NR. DOC      Nr Cheque  Origem/Destino                     Entrada      Saida      Historico"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(REC_VIST->Data)
       @ prow()  ,12  say REC_VIST->Duplicata
       @ prow()  ,25  say left(REC_VIST->Num_cheque,6)
       @ prow()  ,36  say left(REC_VIST->Favorecido,32)
       @ prow()  ,70  say transform(REC_VIST->Valor,"@E 999,999.99")
       @ prow()  ,97  say left(REC_VIST->Historico,30)
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
          @ prow()+1, 0 say "DATA       NR. DOC      Nr Cheque  Origem/Destino                     Entrada      Saida      Historico"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(RECEBIDO->Data_pagto)
       @ prow()  ,12  say left(RECEBIDO->Fatura,9)
       CLI1->(Dbseek(RECEBIDO->Cod_Cli))
       @ prow()  ,36  say left(CLI1->Razao,32)
       @ prow()  ,70  say transform(RECEBIDO->Valor_liq,"@E 999,999.99")
       @ prow()  ,97  say left(RECEBIDO->Historico,30)

       nENTRADA += RECEBIDO->Valor_liq

       RECEBIDO->(dbskip())

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
          @ prow()+1, 0 say "DATA       NR. DOC      Nr Cheque  Origem/Destino                     Entrada      Saida      Historico"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(PAG_VIST->Data)
       @ prow()  ,12  say PAG_VIST->Duplicata
       @ prow()  ,25  say left(PAG_VIST->Num_cheque,6)
       @ prow()  ,36  say left(PAG_VIST->Favorecido,32)
       @ prow()  ,81  say transform(PAG_VIST->Valor,"@E 999,999.99")
       @ prow()  ,97  say left(PAG_VIST->Historico,30)


       nSAIDA += PAG_VIST->Valor

       PAG_VIST->(dbskip())

   enddo

   AD_VIAG->(Dbsetfilter({||AD_VIAG->Forma == "E"},'AD_VIAG->Forma == "E"'))
   set softseek on
   AD_VIAG->(Dbsetorder(2)) // data
   AD_VIAG->(dbgotop())
   AD_VIAG->(Dbseek(dINI))
   set softseek off

   do while ! AD_VIAG->(eof()) .and. AD_VIAG->Data >= dINI .and. AD_VIAG->Data <= dFIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DATA       NR. DOC      Nr Cheque  Origem/Destino                     Entrada      Saida      Historico"

          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(AD_VIAG->Data)
       @ prow()  ,25  say left(AD_VIAG->Num_cheque,6)
       @ prow()  ,36  say left(AD_VIAG->Favorecido,32)
       @ prow()  ,81  say transform(AD_VIAG->Valor,"@E 999,999.99")
       @ prow()  ,97  say left(AD_VIAG->Historico,30)


       nSAIDA += AD_VIAG->Valor

       AD_VIAG->(dbskip())

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
          @ prow()+1, 0 say "DATA       NR. DOC      Nr Cheque  Origem/Destino                     Entrada      Saida      Historico"


          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say dtoc(PAGOS->Data_pagto)
       @ prow()  ,12  say left(PAGOS->Fatura,9)
       @ prow()  ,25  say PAGOS->Nr_CHEQUE
       FORN->(Dbseek(PAGOS->Cod_forn))
       @ prow()  ,36  say left(FORN->Razao,32)
       @ prow()  ,81  say transform(PAGOS->Valor_liq,"@E 999,999.99")
       @ prow()  ,97  say left(PAGOS->Historico,30)



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
   @ prow()  ,50 say transform(nENTRADA+SALD_CAI->Saldo,"@E 99,999,999.99")
   @ prow()  ,67 say transform(nSAIDA+SALD_CAI->Saldo+(nENTRADA-nSAIDA),"@E 99,999,999.99")
   @ prow()+1, 0 say replicate("=",80)

   nENTRADA := 0
   nCHEQUE  := 0
   nESPECIE := 0
   nBOLETO  := 0
   nC_CORR  := 0
   nSAIDA   := 0


   qstopprn()

return

