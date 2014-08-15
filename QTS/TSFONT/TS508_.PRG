/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE MOVIMENTO DO CAIXA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1998
// OBS........:
// ALTERACAO..: 06/07/2001
function ts508

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________


local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private cTITULO          // titulo do relatorio
private nCOD             // codigo do historico padrao para montar historico
private nHISTORICO
private nENTRADA := 0
private nSAIDA   := 0

fu_abre_cli1()

qlbloc(05,0,"B508A","QBLOC.GLO")

BANCO->(dbsetorder(3)) // codigo do banco

if ( i_inicializacao() , i_impressao() , NIL )

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE MOVIMENTO DO CAIXA EM: " + dtoc(XDATA)

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
   REF_CAIX->(Dbseek(dtos(XDATA)))
   set softseek off

   do while ! REF_CAIX->(eof()) .and. REF_CAIX->Data >= XDATA .and. REF_CAIX->Data <= XDATA .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say REF_CAIX->Docto
       @ prow()  ,13  say "REFORCO DE CAIXA"
       @ prow()  ,60  say transform(REF_CAIX->Valor,"@R 999,999.99")

       nENTRADA += REF_CAIX->Valor

       REF_CAIX->(dbskip())

   enddo

   set softseek on
   DEPOSITO->(Dbsetorder(2)) // data
   DEPOSITO->(dbgotop())
   DEPOSITO->(Dbseek(dtos(XDATA)))
   set softseek off

   do while ! DEPOSITO->(eof()) .and. DEPOSITO->Data >= XDATA .and. DEPOSITO->Data <= XDATA .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say DEPOSITO->Docto
       @ prow()  ,13  say "DEPOSITO BANCARIO"
       nVALOR := DEPOSITO->Valor_ch1 + DEPOSITO->Valor_ch2 + DEPOSITO->Valor_es1 + DEPOSITO->Valor_es2
       @ prow()  ,70  say transform(nVALOR,"@R 999,999.99")
       nSAIDA += nVALOR

       DEPOSITO->(dbskip())

   enddo

   set softseek on
   CHEQ_DEV->(Dbsetorder(2)) // data
   CHEQ_DEV->(dbgotop())
   CHEQ_DEV->(Dbseek(dtos(XDATA)))
   set softseek off

   do while ! CHEQ_DEV->(eof()) .and. CHEQ_DEV->Data >= XDATA .and. CHEQ_DEV->Data <= XDATA .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say CHEQ_DEV->Docto
       @ prow()  ,13  say "CHEQUE DEVOLVIDO"
       nVALOR := CHEQ_DEV->Valor_ch1
       @ prow()  ,60  say transform(nVALOR,"@R 999,999.99")
       nENTRADA += nVALOR

       CHEQ_DEV->(dbskip())

   enddo

   set softseek on
   ESTORNO->(Dbsetorder(2)) // data
   ESTORNO->(dbgotop())
   ESTORNO->(Dbseek(XDATA))
   set softseek off

   do while ! ESTORNO->(eof()) .and. ESTORNO->Data >= XDATA .and. ESTORNO->Data <= XDATA .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say ESTORNO->Docto
       @ prow()  ,13  say "ESTORNO DE DEPOSITO"
       nVALOR := ESTORNO->Valor_ch1
       @ prow()  ,60  say transform(nVALOR,"@R 999,999.99")
       nENTRADA += nVALOR

       ESTORNO->(dbskip())

   enddo

   PAG_VIST->(Dbsetfilter({||PAG_VIST->Forma == "E"},'PAG_VIST->Forma == "E"'))
   set softseek on
   PAG_VIST->(Dbsetorder(2)) // data
   PAG_VIST->(dbgotop())
   PAG_VIST->(Dbseek(XDATA))
   set softseek off

   do while ! PAG_VIST->(eof()) .and. PAG_VIST->Data >= XDATA .and. PAG_VIST->Data <= XDATA .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say PAG_VIST->Duplicata
       TIPOCONT->(dbseek(PAG_VIST->Tipocont))
       if TIPOCONT->Regime_ope == "2" // Regime de competencia
          nCOD := TIPOCONT->Hist_l_1
       else // regime de caixa
          nCOD := TIPOCONT->Hi_l_liq1
       endif

       i_hist1("PAG_VIST",nCOD)
       if len(nHISTORICO) > 46
          @ prow()  ,13  say left(nHISTORICO,46)
          @ prow()+1,13  say substr(nHISTORICO,47,len(nHISTORICO))
       else
          @ prow()  ,13  say nHISTORICO
       endif
       @ prow()  ,70  say transform(PAG_VIST->Valor,"@R 999,999.99")
       nSAIDA += PAG_VIST->Valor

       PAG_VIST->(dbskip())

   enddo

   set softseek on
   REC_VIST->(Dbsetorder(2)) // data
   REC_VIST->(dbgotop())
   REC_VIST->(Dbseek(XDATA))
   set softseek off

   do while ! REC_VIST->(eof()) .and. REC_VIST->Data >= XDATA .and. REC_VIST->Data <= XDATA .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say REC_VIST->Duplicata
       TIPOCONT->(dbseek(REC_VIST->Tipocont))
       if TIPOCONT->Regime_ope == "2" // Regime de competencia
          nCOD := TIPOCONT->Hist_l_2
       else // regime de caixa
          nCOD := TIPOCONT->Hi_l_liq2
       endif

       i_hist2("REC_VIST",nCOD)
       if len(nHISTORICO) > 46
          @ prow()  ,13  say left(nHISTORICO,46)
          @ prow()+1,13  say substr(nHISTORICO,47,len(nHISTORICO))
       else
          @ prow()  ,13  say nHISTORICO
       endif
       @ prow()  ,60  say transform(REC_VIST->Valor,"@R 999,999.99")
       nENTRADA += REC_VIST->Valor

       REC_VIST->(dbskip())

   enddo
   RECEBIDO->(dbsetfilter({||RECEBIDO->Tipo != "4" .and. RECEBIDO->Tipo != "6"},'RECEBIDO->Tipo != "4".and. RECEBIDO->Tipo != "6" '))
   set softseek on
   RECEBIDO->(Dbsetorder(6)) // data recebimento
   RECEBIDO->(dbgotop())
   RECEBIDO->(Dbseek(dtos(XDATA)))
   set softseek off
   do while ! RECEBIDO->(eof()) .and. RECEBIDO->Data_pagto >= XDATA .and. RECEBIDO->Data_pagto <= XDATA  .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say RECEBIDO->Duplicata
       TIPOCONT->(dbseek(RECEBIDO->Tipo_sub))
       if TIPOCONT->Regime_ope == "2" // Regime de competencia
          nCOD := TIPOCONT->Hist_l_2
       else // regime de caixa
          nCOD := TIPOCONT->Hi_l_liq2
       endif

       i_hist3("RECEBIDO",nCOD)
       if len(nHISTORICO) > 46
          @ prow()  ,13  say left(nHISTORICO,46)
          @ prow()+1,13  say substr(nHISTORICO,47,len(nHISTORICO))
       else
          @ prow()  ,13  say nHISTORICO
       endif
       @ prow()  ,60  say transform(RECEBIDO->Valor_liq,"@R 999,999.99")
       nENTRADA += RECEBIDO->Valor_liq

       RECEBIDO->(dbskip())

   enddo

   PAGOS->(dbsetfilter({||PAGOS->Tipo == "6"},'PAGOS->Tipo == "6"'))
   set softseek on
   PAGOS->(Dbsetorder(5)) // data pagto
   PAGOS->(dbgotop())
   PAGOS->(Dbseek(XDATA))
   set softseek off
   do while ! PAGOS->(eof()) .and. PAGOS->Data_pagto >= XDATA .and. PAGOS->Data_pagto <= XDATA  .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "DOCTO        HISTORICO                                        ENTRADAS     SAIDA"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say PAGOS->Duplicata
       TIPOCONT->(dbseek(PAGOS->Tipo_sub))
       if TIPOCONT->Regime_ope == "2" // Regime de competencia
          nCOD := TIPOCONT->Hist_l_2
       else // regime de caixa
          nCOD := TIPOCONT->Hi_l_liq2
       endif

       i_hist4("PAGOS",nCOD)
       if len(nHISTORICO) > 46
          @ prow()  ,13  say left(nHISTORICO,46)
          @ prow()+1,13  say substr(nHISTORICO,47,len(nHISTORICO))
       else
          @ prow()  ,13  say nHISTORICO
       endif
       @ prow()  ,70  say transform(PAGOS->Valor_liq,"@R 999,999.99")
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
   @ prow()  ,50 say transform(nENTRADA,"@R 99,999,999.99")
   @ prow()  ,67 say transform(nSAIDA,"@R 99,999,999.99")
   SALD_CAI->(dbseek(XDATA))
   @ prow()+1,44 say "SALDO ANTERIOR"
   @ prow()  ,50 say transform(SALD_CAI->Saldo,"@R 99,999,999.99")
   @ prow()+1,44 say "SALDO ATUAL"
   @ prow()  ,67 say transform(SALD_CAI->Saldo+(nENTRADA-nSAIDA),"@R 99,999,999.99")
   @ prow()+1,44 say "CONFERENCIA"
   @ prow()  ,50 say transform(nENTRADA+SALD_CAI->Saldo,"@R 99,999,999.99")
   @ prow()  ,67 say transform(nSAIDA+SALD_CAI->Saldo+(nENTRADA-nSAIDA),"@R 99,999,999.99")
   @ prow()+1, 0 say replicate("=",80)

   qstopprn()

return

///////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A MONTAGEM DO HISTORICO PADRAO _______

function i_hist1(cARQ,cCOD)

local lTEM := .F.

   HIST->(dbseek(cCOD))
   nHIST := HIST->Descricao

   nHISTORICO := ""

   for nCONT := 1 to len(nHIST)

       if ( nPOS := at("[",nHIST) )  <> 0

          iif(nPOS <> 1 ,nHISTORICO += substr(nHIST,1,nPOS-1),)

          nPOS += 2  // para ignorar os simbolos [@

          lTEM := .T.
          do case

             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO +=XDATSYS
             case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
                  nHISTORICO += (cARQ)->Duplicata
             case substr(nHIST,nPOS,2) == "EP"
                  ESPECIE->(Dbseek((cARQ)->Especie))
                  nHISTORICO += left(ESPECIE->Descricao,10)
             case substr(nHIST,nPOS,2) == "SE"
                  SERIE->(Dbseek((cARQ)->Serie))
                  nHISTORICO += left(SERIE->Descricao,10)
             case substr(nHIST,nPOS,2) == "CH"
                  nHISTORICO += (cARQ)->Num_cheque
             case substr(nHIST,nPOS,2) == "BC"
                  BANCO->(dbsetorder(3)) // codigo do banco
                  BANCO->(Dbseek((cARQ)->Banco))
                  nHISTORICO += BANCO->Descricao
          endcase

          nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

       else

         if ! lTEM
            nHISTORICO := HIST->Descricao
         endif

         exit

       endif

   next
   nHISTORICO += " "+left((cARQ)->Historico,35)
return alltrim(nHISTORICO)


///////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A MONTAGEM DO HISTORICO PADRAO _______

function i_hist2(cARQ,cCOD)

local lTEM := .F.

   HIST->(dbseek(cCOD))
   nHIST := HIST->Descricao

   nHISTORICO := ""

   for nCONT := 1 to len(nHIST)

       if ( nPOS := at("[",nHIST) )  <> 0

          iif(nPOS <> 1 ,nHISTORICO += substr(nHIST,1,nPOS-1),)

          nPOS += 2  // para ignorar os simbolos [@

          lTEM := .T.
          do case

             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO +=  XDATSYS
             case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
                  nHISTORICO += (cARQ)->Duplicata
             case substr(nHIST,nPOS,2) == "EP"
                  ESPECIE->(Dbseek((cARQ)->Especie))
                  nHISTORICO += left(ESPECIE->Descricao,3)
             case substr(nHIST,nPOS,2) == "SE"
                  SERIE->(Dbseek((cARQ)->Serie))
                  nHISTORICO += left(SERIE->Descricao,3)
             case substr(nHIST,nPOS,2) == "CH"
                  nHISTORICO += (cARQ)->Num_cheque
          endcase

          nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

       else

         if ! lTEM
            nHISTORICO := HIST->Descricao
         endif

         exit

       endif

   next
   nHISTORICO += left((cARQ)->Historico,35)
return alltrim(nHISTORICO)

///////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A MONTAGEM DO HISTORICO PADRAO _______

function i_hist3(cARQ,cCOD)

local lTEM := .F.

   HIST->(dbseek(cCOD))
   nHIST := HIST->Descricao

   nHISTORICO := ""

   for nCONT := 1 to len(nHIST)

       if ( nPOS := at("[",nHIST) )  <> 0

          iif(nPOS <> 1 ,nHISTORICO += substr(nHIST,1,nPOS-1),)

          nPOS += 2  // para ignorar os simbolos [@

          lTEM := .T.
          do case

             case substr(nHIST,nPOS,2) == "CA"
                  CLI1->(Dbseek((cARQ)->Cod_cli))
                  nHISTORICO += left(CLI1->Razao,40)
             case substr(nHIST,nPOS,2) == "EP"
                  ESPECIE->(Dbseek((cARQ)->Especie))
                  nHISTORICO += left(ESPECIE->Descricao,5)
             case substr(nHIST,nPOS,3) == "CGC"
                  CLI1->(Dbseek((cARQ)->Cod_cli))
                  nHISTORICO += CLI1->Cgccpf
             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO +=  XDATSYS
             case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
                  nHISTORICO += (cARQ)->Fatura
          endcase

          nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

       else

         if ! lTEM
            nHISTORICO := HIST->Descricao
         endif

         exit

       endif

   next

return nHISTORICO

///////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A MONTAGEM DO HISTORICO PADRAO _______

function i_hist4(cARQ,cCOD)

local lTEM := .F.

   HIST->(dbseek(cCOD))
   nHIST := HIST->Descricao

   nHISTORICO := ""

   for nCONT := 1 to len(nHIST)

       if ( nPOS := at("[",nHIST) )  <> 0

          iif(nPOS <> 1 ,nHISTORICO += substr(nHIST,1,nPOS-1),)

          nPOS += 2  // para ignorar os simbolos [@

          lTEM := .T.
          do case

             case substr(nHIST,nPOS,2) == "CA"
                  FORN->(Dbseek((cARQ)->Cod_forn))
                  nHISTORICO += left(FORN->Razao,40)
             case substr(nHIST,nPOS,3) == "CGC"
                  FORN->(Dbseek((cARQ)->Cod_forn))
                  nHISTORICO += FORN->Cgccpf
             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO +=  XDATSYS
             case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
                  nHISTORICO += (cARQ)->Fatura
          endcase

          nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

       else

         if ! lTEM
            nHISTORICO := HIST->Descricao
         endif

         exit

       endif

   next

return nHISTORICO

