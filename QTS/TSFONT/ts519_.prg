/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE CONTAS A RECEBER/RECEBIDO
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
function ts519

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

   cTITULO := "LISTAGEM DE CONTAS RECEBIDAS DE " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)
   if ! quse(XDRV_TS, "RECTMP",,"E")
      qmensa("N„o foi poss¡vel abrir arquivo RECTMP.DBF !! Tente novamente.")
      return
   endif


   if RECTMP->(qflock())
      RECTMP->(__dbZap())
      RECTMP->(dbCreateIndex( XDRV_TS + "PAGTMP", "dtos(Pagto)+Cliente", {|| dtos(Pagto)+Cliente}, if( .F., .T., NIL ) ))
      RECTMP->(dbunlock())
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

   nTOT := 0
   nTOT_GER := 0

   RECEBIDO->(dbsetfilter({||RECEBIDO->Tipo $ "46"},'RECEBIDO->Tipo $ "46" ')) //Somente Recebimento por Banco

   if ! empty(cCLI)
      RECEBIDO->(dbsetorder(3))
      RECEBIDO->(Dbseek(cCLI))
   else
      RECEBIDO->(dbsetorder(6))  // DATA_PAGTO
      RECEBIDO->(dbgotop())
      set softseek on
      RECEBIDO->(dbseek(dDATA_INI))
      set softseek off
   endif

   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   dVENC := RECEBIDO->Data_pagto
   
   do while ! RECEBIDO->(eof()) .and. RECEBIDO->Data_pagto >= dDATA_INI .and. RECEBIDO->Data_pagto <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! empty(cCLI) .and. RECEBIDO->Cod_cli <> cCLI
          RECEBIDO->(Dbskip())
          loop
       endif

       if RECTMP->(qappend())
          replace RECTMP->Venc    with RECEBIDO->Data_venc
          replace RECTMP->Pagto   with RECEBIDO->Data_pagto
          replace RECTMP->Docto   with RECEBIDO->Fatura
          replace RECTMP->Cliente with RECEBIDO->Cliente
          replace RECTMP->Tipo    with RECEBIDO->Tipo
          replace RECTMP->Valor   with RECEBIDO->Valor_liq
       endif


       RECEBIDO->(dbskip())


   enddo
   RECTMP->(Dbcommit())
   RECEBIDO->(dbclearfilter())
   qmensa("Aguarde... Gerando indice termporario...")

   RECTMP->(dbCreateIndex( XDRV_TS + "RECTMP", "dtos(Pagto)+Cliente", {|| dtos(Pagto)+Cliente}, if( .F., .T., NIL ) ))

   RECTMP->(Dbsetorder(1))
   RECTMP->(Dbgotop())
   dVENC := RECTMP->Pagto
   do while ! RECTMP->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                   LANCAMENTOS RECEBIDOS PELO BANCO           "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  PAGAMENTO NR.DOCTO   TIPO   CLIENTE/HISTORICO             VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(RECTMP->Venc)
       @ prow()  ,11  say dtoc(RECTMP->Pagto)
       @ prow()  ,22  say left(RECTMP->Docto,10)
       do case
          case RECTMP->Tipo == "1"
               @ prow()  ,32  say "CART.  "
          case RECTMP->Tipo == "2"
               @ prow()  ,32  say "CHEQUE"
          case RECTMP->Tipo == "3"
               @ prow()  ,32  say "PRE-DAT"
          case RECTMP->Tipo == "4"
               @ prow()  ,32  say "COB.BCO"
          case RECTMP->Tipo == "5"
               @ prow()  ,32  say "CAIXA"
          case RECTMP->Tipo == "6"
               @ prow()  ,32  say "DESCONT"
       endcase

       @ prow()  ,40  say left(RECTMP->Cliente,25)
       @ prow()  ,66  say transform(RECTMP->Valor, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + RECTMP->Valor
       nTOT := nTOT + RECTMP->Valor
       nTOT_GER := nTOT_GER + RECTMP->Valor

       RECTMP->(dbskip())

       if ! RECTMP->(eof()) .and. RECTMP->Pagto <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := RECTMP->Pagto
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,44 say "Valor Total Recebido ...> "+transform(nTOT, "@E 999,999,999.99")
   endif

   RECTMP->(dbclosearea())

   if ! quse(XDRV_TS, "RECTMP",,"E")
      qmensa("N„o foi poss¡vel abrir arquivo RECTMP.DBF !! Tente novamente.")
      return
   endif


   if RECTMP->(qflock())
      RECTMP->(__dbZap())
      RECTMP->(dbCreateIndex( XDRV_TS + "RECTMP", "dtos(Pagto)+Cliente", {|| dtos(Pagto)+Cliente}, if( .F., .T., NIL ) ))
      RECTMP->(dbunlock())
   endif

   qmensa("Aguarde... Gerando indice termporario...")

   RECEBIDO->(dbsetfilter({||RECEBIDO->Tipo $ "1235"},'RECEBIDO->Tipo $ "1235" ')) //Somente Recebimento por Caixa

   if ! empty(cCLI)
      RECEBIDO->(dbsetorder(3))
      RECEBIDO->(Dbseek(cCLI))
   else
      RECEBIDO->(dbsetorder(6))  // DATA_PAGTO
      RECEBIDO->(dbgotop())
      set softseek on
      RECEBIDO->(dbseek(dDATA_INI))
      set softseek off
   endif

   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   do while ! RECEBIDO->(eof()) .and. RECEBIDO->Data_pagto >= dDATA_INI .and. RECEBIDO->Data_pagto <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! empty(cCLI) .and. RECEBIDO->Cod_cli <> cCLI
          RECEBIDO->(Dbskip())
          loop
       endif

       if RECTMP->(qappend())
          replace RECTMP->Venc    with RECEBIDO->Data_venc
          replace RECTMP->Pagto   with RECEBIDO->Data_pagto
          replace RECTMP->Docto   with RECEBIDO->Fatura
          replace RECTMP->Cliente with RECEBIDO->Cliente
          replace RECTMP->Tipo    with RECEBIDO->Tipo
          replace RECTMP->Valor   with RECEBIDO->Valor_liq
       endif

       RECEBIDO->(dbskip())


   enddo
   RECTMP->(dbcommit())
   if empty(cCLI)
      REC_VIST->(Dbsetorder(2))  // DATA
      REC_VIST->(Dbgotop())

      set softseek on
      REC_VIST->(dbseek(dDATA_INI))
      set softseek off

      XPAGINA  := 0
      nTOT_DIA := 0
      nTOT     := 0

      do while ! REC_VIST->(eof()) .and. REC_VIST->Data >= dDATA_INI .and. REC_VIST->Data <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

         if RECTMP->(qappend())
            replace RECTMP->Pagto   with REC_VIST->Data
            replace RECTMP->Docto   with REC_VIST->Duplicata
            replace RECTMP->Cliente with REC_VIST->Historico
//            replace RECTMP->Tipo    with REC_VIST->Tipo
            replace RECTMP->Valor   with REC_VIST->Valor
         endif

         REC_VIST->(dbskip())


      enddo
      RECTMP->(dbcommit())
   endif

   qmensa("Aguarde... Gerando indice termporario...")

   RECTMP->(dbCreateIndex( XDRV_TS + "RECTMP", "dtos(Pagto)+Cliente", {|| dtos(Pagto)+Cliente}, if( .F., .T., NIL ) ))

   RECTMP->(Dbsetorder(1))
   RECTMP->(Dbgotop())
   dVENC := RECTMP->Pagto
   do while ! RECTMP->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "                   LANCAMENTOS RECEBIDOS PELO CAIXA           "
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "VENCIMENTO  PAGAMENTO NR.DOCTO   TIPO   CLIENTE/HISTORICO             VALOR"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00  say dtoc(RECTMP->Venc)
       @ prow()  ,11  say dtoc(RECTMP->Pagto)
       @ prow()  ,22  say left(RECTMP->Docto,10)
       do case
          case RECTMP->Tipo == "1"
               @ prow()  ,32  say "CART.  "
          case RECTMP->Tipo == "2"
               @ prow()  ,32  say "CHEQUE"
          case RECTMP->Tipo == "3"
               @ prow()  ,32  say "PRE-DAT"
          case RECTMP->Tipo == "4"
               @ prow()  ,32  say "COB.BCO"
          case RECTMP->Tipo == "5"
               @ prow()  ,32  say "CAIXA"
          case RECTMP->Tipo == "6"
               @ prow()  ,32  say "DESCONT"
       endcase

       @ prow()  ,40  say left(RECTMP->Cliente,25)
       @ prow()  ,66  say transform(RECTMP->Valor, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + RECTMP->Valor
       nTOT := nTOT + RECTMP->Valor
       nTOT_GER := nTOT_GER + RECTMP->Valor

       RECTMP->(dbskip())

       if ! RECTMP->(eof()) .and. RECTMP->Pagto <> dVENC
          @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := RECTMP->Pagto
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,50 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,44 say "Valor Total Recebido ...> "+transform(nTOT, "@E 999,999,999.99")
   endif

   RECTMP->(dbclosearea())


   qstopprn()

return
