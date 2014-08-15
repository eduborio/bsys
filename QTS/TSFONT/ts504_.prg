/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE CONTAS A RECEBER/RECEBIDO
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MARCO DE 1999
// OBS........:
function ts504

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private cCLI := space(5)            // Codigo do cliente

private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nTOT    := 0
private nTOT_DIA:= 0
private nTOT_GER:= 0

fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })
aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI                     ) } ,"CLI" })
aadd(aEDICAO,{{ || NIL                                       } ,  NIL  })

do while .T.

   qlbloc(05,0,"B504A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cCLI  := space(5)
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

      case cCAMPO == "CLI"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL++, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cCLI:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(CLI1->Razao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTAS A RECEBER/RECEBIDOS DE " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)

   if ! empty(cCLI)
      REC_TESO->(dbsetorder(3))  // COD_CLI + DATA_VENC
      qmensa("")
   else
     REC_TESO->(dbsetorder(2))  // DATA_EMISS
     qmensa("")
   endif

   set softseek on
   REC_TESO->(dbseek(dDATA_INI))

   qmensa("")

return .T.

static function i_impressao

   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")

   if ! empty(cCLI)
      REC_TESO->(Dbseek(cCLI))
   else
      REC_TESO->(Dbsetorder(4))
      REC_TESO->(dbgotop())
   endif

   dVENC := REC_TESO->Data_venc
   nTOT := 0
   nTOT_GER := 0

   do while ! REC_TESO->(eof()) .and. REC_TESO->Data_venc >= dDATA_INI .and. REC_TESO->Data_venc <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! empty(cCLI) .and. REC_TESO->Cod_cli <> cCLI
          REC_TESO->(Dbskip())
          loop
       endif

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "         LANCAMENTOS LIBERADOS PARA A TESOURARIA - AGUARDANDO BAIXA       "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  NR.DOCTO   CODIGO CLIENTE                                VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(REC_TESO->Data_venc)
       @ prow()  ,11  say left(REC_TESO->Fatura,10)
       @ prow()  ,23  say REC_TESO->Cod_cli ; CLI1->(Dbseek(REC_TESO->Cod_cli))
       @ prow()  ,30  say left(CLI1->Razao,34)
       @ prow()  ,66  say transform(REC_TESO->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + REC_TESO->Valor_liq
       nTOT := nTOT + REC_TESO->Valor_liq

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

   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,39 say "Valor Total a Receber ...> "+transform(nTOT, "@E 999,999,999.99")
   endif

RECEBIDO->(dbsetfilter({||iif(!empty(cCLI),Cod_cli==cCLI,Cod_cli!="00000").and.RECEBIDO->Data_pagto>=dDATA_INI.and.RECEBIDO->Data_pagto<=dDATA_FIM}, 'iif(!empty(cCLI),Cod_cli == cCLI,cod_cli != "00000").and.RECEBIDO->Data_pagto>=dDATA_INI.and.RECEBIDO->Data_pagto<=dDATA_FIM'))


   RECEBIDO->(dbsetorder(10))  // DATA DO RECEBIMENTO + RAZAO DO CLIENTE
   RECEBIDO->(dbgotop())

   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   dVENC := RECEBIDO->Data_pagto
   
   do while ! RECEBIDO->(eof()) .and. qcontprn()  // condicao principal de loop

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
               @ prow()  ,32  say "DESCONT"

       endcase
       CLI1->(dbseek(RECEBIDO->Cod_cli))
       @ prow()  ,40  say left(CLI1->Razao,25)
       @ prow()  ,66  say transform(RECEBIDO->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + RECEBIDO->Valor_liq
       nTOT := nTOT + RECEBIDO->Valor_liq
       nTOT_GER := nTOT_GER + RECEBIDO->Valor_liq

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

   if empty(cCLI)
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
          nTOT_GER := nTOT_GER + REC_VIST->Valor

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
   endif

   if nTOT_GER <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,40 say "Valor Total Recebido ...> "+transform(nTOT_GER, "@E 999,999,999.99")
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO (Modelo Excel)

static function i_impre_xls

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")

   if ! empty(cCLI)
      REC_TESO->(Dbseek(cCLI))
   else
      REC_TESO->(Dbsetorder(2))
      REC_TESO->(dbgotop())
   endif

   dVENC := REC_TESO->Data_venc
   nTOT := 0
   nTOT_GER := 0

   do while ! REC_TESO->(eof()) .and. REC_TESO->Data_venc >= dDATA_INI .and. REC_TESO->Data_venc <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! empty(cCLI) .and. REC_TESO->Cod_cli <> cCLI
          REC_TESO->(Dbskip())
          loop
       endif

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+cTITULO
          @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+"LANCAMENTOS LIBERADOS PARA A TESOURARIA - AGUARDANDO BAIXA"
          @ prow()+1, 0 say "VENCIMENTO"+chr(9)+"NR.DOCTO"+chr(9)+"CODIGO"+chr(9)+"CLIENTE"+chr(9)+"VALOR"
       endif

       @ prow()+1,00  say dtoc(REC_TESO->Data_venc)
       @ prow()  ,pcol()  say chr(9)+left(REC_TESO->Fatura,10)
       @ prow()  ,pcol()  say chr(9)+REC_TESO->Cod_cli ; CLI1->(Dbseek(REC_TESO->Cod_cli))
       @ prow()  ,pcol()  say chr(9)+left(CLI1->Razao,34)
       @ prow()  ,pcol()  say chr(9)+transform(REC_TESO->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + REC_TESO->Valor_liq
       nTOT := nTOT + REC_TESO->Valor_liq

       REC_TESO->(dbskip())

       if ! REC_TESO->(eof()) .and. REC_TESO->Data_venc <> dVENC
          @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := REC_TESO->Data_venc
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   if nTOT <> 0
      @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total a Receber"+chr(9)+transform(nTOT, "@E 999,999,999.99")
   endif

RECEBIDO->(dbsetfilter({||iif(!empty(cCLI),Cod_cli==cCLI,Cod_cli!="00000").and.RECEBIDO->Data_pagto>=dDATA_INI.and.RECEBIDO->Data_pagto<=dDATA_FIM}, 'iif(!empty(cCLI),Cod_cli == cCLI,cod_cli != "00000").and.RECEBIDO->Data_pagto>=dDATA_INI.and.RECEBIDO->Data_pagto<=dDATA_FIM'))


   RECEBIDO->(dbsetorder(10))  // DATA DO RECEBIMENTO + RAZAO DO CLIENTE
   RECEBIDO->(dbgotop())

   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   dVENC := RECEBIDO->Data_pagto
   
   do while ! RECEBIDO->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+chr(9)+ctitulo
          @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+chr(9)+"LANCAMENTOS RECEBIDOS PELA TESOURARIA"
          @ prow()+1, 0 say "VENCIMENTO"+chr(9)+"PAGAMENTO"+chr(9)+"NR.DOCTO"+chr(9)+"TIPO"+chr(9)+"CLIENTE"+chr(9)+"VALOR"
       endif

       @ prow()+1,00  say dtoc(RECEBIDO->Data_venc)
       @ prow()  ,pcol()  say chr(9)+dtoc(RECEBIDO->Data_pagto)
       @ prow()  ,pcol()  say chr(9)+left(RECEBIDO->Fatura,9)
       do case
          case RECEBIDO->Tipo == "1"
               @ prow()  ,pcol()  say chr(9)+"CART.  "
          case RECEBIDO->Tipo == "2"
               @ prow()  ,pcol()  say chr(9)+"CHEQUE"
          case RECEBIDO->Tipo == "3"
               @ prow()  ,pcol()  say chr(9)+"PRE-DAT"
          case RECEBIDO->Tipo == "4"
               @ prow()  ,pcol()  say chr(9)+"COB.BCO"
          case RECEBIDO->Tipo == "5"
               @ prow()  ,pcol()  say chr(9)+"CAIXA"
          case RECEBIDO->Tipo == "6"
               @ prow()  ,pcol()  say chr(9)+"DESCONT"

       endcase
       CLI1->(dbseek(RECEBIDO->Cod_cli))
       @ prow()  ,pcol()  say chr(9)+left(CLI1->Razao,25)
       @ prow()  ,pcol()  say chr(9)+transform(RECEBIDO->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + RECEBIDO->Valor_liq
       nTOT := nTOT + RECEBIDO->Valor_liq
       nTOT_GER := nTOT_GER + RECEBIDO->Valor_liq

       RECEBIDO->(dbskip())

       if ! RECEBIDO->(eof()) .and. RECEBIDO->Data_pagto <> dVENC
          @ prow()+1,0 say chr(9)+chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := RECEBIDO->Data_pagto
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say chr(9)+chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif


   if nTOT <> 0
      @ prow()+1,0 say chr(9)+chr(9)+chr(9)+chr(9)+"Total Recebido"+chr(9)+transform(nTOT, "@E 999,999,999.99")
   endif

   if empty(cCLI)
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
             @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+cTITULO
             @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+"LANCAMENTOS RECEBIDOS A VISTA"
             @ prow()+1, 0 say "RECEBIMENTO"+chr(9)+"NR.DOCTO"+chr(9)+"NR.CHEQUE"+chr(9)+"HISTORICO"+chr(9)+"VALOR"
          endif

          @ prow()+1,00  say dtoc(REC_VIST->Data)
          @ prow()  ,pcol()  say chr(9)+left(REC_VIST->Duplicata,10)
          @ prow()  ,pcol()  say chr(9)+REC_VIST->Num_cheque
          @ prow()  ,pcol()  say chr(9)+left(REC_VIST->Historico,25)
          @ prow()  ,pcol()  say chr(9)+transform(REC_VIST->Valor, "@E 999,999,999.99")

          nTOT_DIA := nTOT_DIA + REC_VIST->Valor
          nTOT := nTOT + REC_VIST->Valor
          nTOT_GER := nTOT_GER + REC_VIST->Valor

          REC_VIST->(dbskip())

          if ! REC_VIST->(eof()) .and. REC_VIST->Data <> dVENC
             @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
             nTOT_DIA := 0
             dVENC := REC_VIST->Data
          endif

      enddo

      if nTOT_DIA <> 0
         @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
         nTOT_DIA := 0
      endif

      if nTOT <> 0
         @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Valor Total Recebido a Vista"+chr(9)+transform(nTOT, "@E 999,999,999.99")
      endif
   endif

   if nTOT_GER <> 0
      @ prow()+1, 0 say ""
      @ prow()+1,40 say chr(9)+chr(9)+chr(9)+"Valor Total Recebido"+chr(9)+transform(nTOT_GER, "@E 999,999,999.99")
   endif

   qstopprn()

return

