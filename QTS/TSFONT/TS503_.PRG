/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE CONTAS A PAGAR/PAGAS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: ABRIL DE 1997
// OBS........: EDUARDO AUGUSTO BORIO
function ts503

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private cTITULO2         // titulo do relatorio
private cFILIAL          // quebra por filial
private cFORN := space(5)           // quebra por Fornecedor
private cTIPO := ""
private zFORN := ""
private zTIPO := ""

private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nTOT    := 0
private nTOT_DIA:= 0
private nTOT_GER:= 0
private sBLOC1      := qlbloc("B503B","QBLOC.GLO",1)


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })
aadd(aEDICAO,{{ || view_forn(-1,0,@cFORN                   ) } ,"FORN" })
aadd(aEDICAO,{{ || NIL                                       } ,  NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO , sBLOC1                   ) } ,"TIPO"       })



do while .T.

   qlbloc(05,0,"B503A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.

   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cFORN := space(5)
   cTIPO := " "
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
              qrsay(XNIVEL+1, "Todos os Fornecedores.......")
              zFORN := " Todos"
           else
              if ! FORN->(Dbseek(cFORN:=strzero(val(cFORN),5)))
                 qmensa("Fornecedor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(FORN->Razao,30))
                 zFORN := Left(FORN->Razao,30)
              endif
           endif

      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO," 1234567",{"Todos","Cheque","Pr‚-Datado","D‚bito C/C","C¢pia Cheque","Ordem Pgto","Esp‚cie","Pg On Line"}))
           if cTIPO == " "
              zTIPO := " Todos"
           else
              zTipo := qabrev(cTIPO," 1234567",{"Todos","Cheque","Pr‚-Datado","D‚bito C/C","C¢pia Cheque","Ordem Pgto","Esp‚cie","Pg On Line"})
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTAS A PAGAR/PAGOS DE " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)
   cTitulo2 := " Fornecedor.: "+zFORN+"                                   Tipo Pagto.: "+zTIPO

//   PAGOS->(dbsetfilter({||iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000") .and. PAGOS->Data_pgto >= dDATA_INI .and. PAGOS->Data_pagto <= dDATA_FIM}))

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
   local aResumo := {}

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")

   PAGOS->(dbsetfilter({||iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000") .and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM .and. iif(cTIPO != " ",PAGOS->Tipo == cTIPO,)}))
   PAGOS->(dbsetorder(11))  // DATA_PAGTO + FORNEC
   PAGOS->(dbgotop())


   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   dVENC := PAGOS->Data_pagto
   
   do while ! PAGOS->(eof()) .and. qcontprn()  // condicao principal de loop


       //if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND1
          qcabecprn(cTITULO,135,,cTitulo2)
          @ prow()+1, 0 say "                   LANCAMENTOS PAGOS PELA TESOURARIA                       "
          @ prow()+1, 0 say replicate("-",135)
          @ prow()+1, 0 say "VENCIMENTO    PAGAMENTO   NR.DOCTO      COD.  FORNECEDOR                                      VALOR         TIPO PGTO.     NR. CHEQUE"
          @ prow()+1, 0 say replicate("-",135)
       endif

       @ prow()+1,00  say dtoc(PAGOS->Data_venc)
       @ prow()  ,14  say dtoc(PAGOS->Data_pagto)
       @ prow()  ,26  say left(PAGOS->Fatura,10)
       @ prow()  ,40  say PAGOS->Cod_forn ; FORN->(Dbseek(PAGOS->Cod_forn))
       @ prow()  ,46  say left(FORN->Razao,35)
       @ prow()  ,85  say transform(PAGOS->Valor_liq, "@E 999,999,999.99")
       @ prow()  ,108 say qabrev(PAGOS->Tipo,"1234567",{"Cheque","Pre-Datado","Debito C/C","Copia Cheque","Ordem Pgto","Especie","Pg On Line"})

       //if cTIPO != " "
          aadd(aResumo,{PAGOS->Tipo,PAGOS->Valor_liq})
       //endif

       if PAGOS->Tipo $ "1-2-4"
          @ prow() ,123  say PAGOS->Nr_cheque
       endif

       nTOT_DIA := nTOT_DIA + PAGOS->Valor_liq
       nTOT     := nTOT + PAGOS->Valor_liq
       nTOT_GER := nTOT_GER + PAGOS->Valor_liq

       PAGOS->(dbskip())

       if ! PAGOS->(eof()) .and. PAGOS->Data_pagto <> dVENC
          @ prow()+1,69 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
          @ prow()+1,00 say ""
          nTOT_DIA := 0
          dVENC := PAGOS->Data_pagto
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,69 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
      @ prow()+1,00 say ""
      nTOT_DIA := 0
   endif

   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",135)
      @ prow()+1,64 say "Valor Total Pago ...> "+transform(nTOT, "@E 999,999,999.99")
   endif

//   if empty(cFORN)
//       PAG_VIST->(Dbsetorder(2))  // DATA
//       PAG_VIST->(Dbgotop())
//
//       set softseek on
//       PAG_VIST->(dbseek(dDATA_INI))
//       set softseek off
//
//       XPAGINA  := 0
//       nTOT_DIA := 0
//       nTOT     := 0
//       dVENC := PAG_VIST->Data
//
//       do while ! PAG_VIST->(eof()) .and. PAG_VIST->Data >= dDATA_INI .and. PAG_VIST->Data <= dDATA_FIM .and. qcontprn()  // condicao principal de loop
//
//           //if ! qlineprn() ; exit ; endif
//
//           if XPAGINA == 0 .or. prow() > K_MAX_LIN
//              qpageprn()
//              @ prow(),pcol() say XCOND1
//              qcabecprn(cTITULO,136)
//              @ prow()+1, 0 say "                   LANCAMENTOS PAGOS A VISTA                       "
//              @ prow()+1, 0 say replicate("-",136)
//              @ prow()+1, 0 say "VENCIMENTO   PAGAMENTO   NR. DOCTO     NR.CHEQUE  HISTORICO                            VALOR  FAVORECIDO"
//              @ prow()+1, 0 say replicate("-",136)
//           endif
//
//           @ prow()+1,00  say dtoc(PAG_VIST->Data)
//           @ prow()  ,14  say dtoc(PAG_VIST->Data)
//           @ prow()  ,26  say left(PAG_VIST->Duplicata,10)
//           @ prow()  ,46  say left(PAG_VIST->Favorecido,35)
//           @ prow()  ,85  say transform(PAG_VIST->Valor, "@E 999,999,999.99")
//           @ prow()  ,108 say qabrev(Pag_VIST->Forma,"COE",{"Cheque","Ordem","Especie"})
//
//           @ prow()  ,116 say left(PAG_VIST->Num_cheque,10)
//           @ prow()  ,128 say left(PAG_VIST->Historico,10)
//
//           nTOT_DIA := nTOT_DIA + PAG_VIST->Valor
//           nTOT := nTOT + PAG_VIST->Valor
//           nTOT_GER := nTOT_GER + PAG_VIST->Valor
//
//           PAG_VIST->(dbskip())
//
//           if ! PAG_VIST->(eof()) .and. PAG_VIST->Data <> dVENC
//              @ prow()+1,69 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
//              nTOT_DIA := 0
//              dVENC := PAG_VIST->Data
//           endif
//
//       enddo
//
//       if nTOT_DIA <> 0
//          @ prow()+1,69 say " Total do dia > "+transform(nTOT_DIA, "@E 999,999,999.99")
//          nTOT_DIA := 0
//       endif
//
//       if nTOT <> 0
//          @ prow()+1, 0 say replicate("-",136)
//          @ prow()+1,56 say "Valor Total Pago a Vista...> "+transform(nTOT, "@E 999,999,999.99")
//       endif

//   endif

//   if nTOT_GER <> 0
//      @ prow()+1, 0 say replicate("-",136)
//      @ prow()+1,63 say "Valor Total Pago ...> "+transform(nTOT_GER, "@E 999,999,999.99")
//   endif

    if len(aResumo) > 0
      @ prow()+1,00 say ""
      i_Resumo(aResumo)
    endif

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")

   dVENC := PAG_TESO->Data_emiss
   nTOT := 0
   nTOT_GER := 0
   do while ! PAG_TESO->(eof()) .and. qcontprn()  // condicao principal de loop

       //if ! qlineprn() ; exit ; endif

       if XPAGINA == 0
          qpageprn()
          @ prow()+1, 0 say chr(9)+chr(9)+Chr(9)+cTITULO
          @ prow()+1, 0 say chr(9)+chr(9)+Chr(9)+"LANCAMENTOS LIBERADOS PARA A TESOURARIA - AGUARDANDO BAIXA"
          @ prow()+1, 0 say "Vencimento" +chr(9)+ "Documento" +chr(9)+  "Codigo"  +chr(9)+ "Fornecedor" +chr(9)+ "Valor"
       endif

       @ prow()+1,00  say dtoc(PAG_TESO->Data_venc)
       @ prow()  ,pcol()  say chr(9)+PAG_TESO->Fatura
       @ prow()  ,pcol()  say chr(9)+PAG_TESO->Cod_forn ; FORN->(Dbseek(PAG_TESO->Cod_forn))
       @ prow()  ,pcol()  say chr(9)+left(FORN->Razao,34)
       @ prow()  ,pcol()  say chr(9)+transform(PAG_TESO->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + PAG_TESO->Valor_liq
       nTOT := nTOT + PAG_TESO->Valor_liq

       PAG_TESO->(dbskip())

       if ! PAG_TESO->(eof()) .and. PAG_TESO->Data_venc <> dVENC
          @ prow()+1,00 say chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := PAG_TESO->Data_venc
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,00 say chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   if nTOT <> 0
      @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total a Pagar"+chr(9)+transform(nTOT, "@E 999,999,999.99")
   endif

   PAGOS->(dbsetfilter({||iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000") .and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM}, 'iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000").and. PAGOS->Data_pagto>=dDATA_INI .and. PAGOS->Data_pagto<= dDATA_FIM'))

   PAGOS->(dbsetorder(11))  // DATA_PAGTO + FORNEC
   PAGOS->(dbgotop())


   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   dVENC := PAGOS->Data_pagto
   
   do while ! PAGOS->(eof()) .and. qcontprn()  // condicao principal de loop

//      if PAGOS->Data_pagto < dDATA_INI .or. PAGOS->Data_pagto > dDATA_FIM
//         PAGOS->(dbskip())
//         loop
//      endif


       //if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+chr(9)+cTITULO
          @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+chr(9)+ "LANCAMENTOS PAGOS PELA TESOURARIA"
          @ prow()+1, 0 say ""
          @ prow()+1, 0 say "Vencimento" +chr(9)+ "Pagamento"+Chr(9)+"Documento"+chr(9)+"Codigo"+chr(9)+"Forncecedor"+chr(9)+"Valor"
       endif

       @ prow()+1,00  say dtoc(PAGOS->Data_venc)
       @ prow()  ,pcol()  say chr(9)+dtoc(PAGOS->Data_pagto)
       @ prow()  ,pcol()  say chr(9)+left(PAGOS->Fatura,10)
       @ prow()  ,pcol()  say chr(9)+PAGOS->Cod_forn ; FORN->(Dbseek(PAGOS->Cod_forn))
       @ prow()  ,pcol()  say chr(9)+left(FORN->Razao,25)
       @ prow()  ,pcol()  say chr(9)+transform(PAGOS->Valor_liq, "@E 999,999,999.99")

       nTOT_DIA := nTOT_DIA + PAGOS->Valor_liq
       nTOT := nTOT + PAGOS->Valor_liq
       nTOT_GER := nTOT_GER + PAGOS->Valor_liq

       PAGOS->(dbskip())

       if ! PAGOS->(eof()) .and. PAGOS->Data_pagto <> dVENC
          @ prow()+1,0 say chr(9)+chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
          nTOT_DIA := 0
          dVENC := PAGOS->Data_pagto
       endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say chr(9)+chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
      nTOT_DIA := 0
   endif

   if nTOT <> 0
      @ prow()+1,0 say chr(9)+chr(9)+chr(9)+chr(9)+"Valor Total Pago"+chr(9)+transform(nTOT, "@E 999,999,999.99")
   endif

//   if empty(cFORN)
//       PAG_VIST->(Dbsetorder(2))  // DATA
//       PAG_VIST->(Dbgotop())
//
//       set softseek on
//       PAG_VIST->(dbseek(dDATA_INI))
//       set softseek off
//
//       XPAGINA  := 0
//       nTOT_DIA := 0
//       nTOT     := 0
//       dVENC := PAG_VIST->Data
//
//       do while ! PAG_VIST->(eof()) .and. PAG_VIST->Data >= dDATA_INI .and. PAG_VIST->Data <= dDATA_FIM .and. qcontprn()  // condicao principal de loop
//
//           //if ! qlineprn() ; exit ; endif
//
//           if XPAGINA == 0 .or. prow() > K_MAX_LIN
//              qpageprn()
//              @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+cTITULO
//              @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+"LANCAMENTOS PAGOS A VISTA"
//              @ prow()+1, 0 say ""
//              @ prow()+1, 0 say "PAGAMENTO"+chr(9)+"NR. DOCTO"+chr(9)+"NR.CHEQUE"+chr(9)+"HISTORICO"+chr(9)+"VALOR"+chr(9)+"FAVORECIDO"
//           endif
//
//           @ prow()+1,00      say dtoc(PAG_VIST->Data)
//           @ prow()  ,pcol()  say chr(9)+left(PAG_VIST->Duplicata,12)
//           @ prow()  ,pcol()  say chr(9)+left(PAG_VIST->Num_cheque,10)
//           @ prow()  ,pcol()  say chr(9)+left(PAG_VIST->Historico,28)
//           @ prow()  ,pcol()  say chr(9)+transform(PAG_VIST->Valor, "@E 999,999,999.99")
//           @ prow()  ,pcol()  say chr(9)+left(PAG_VIST->Favorecido,35)
//
//
//           nTOT_DIA := nTOT_DIA + PAG_VIST->Valor
//           nTOT := nTOT + PAG_VIST->Valor
//           nTOT_GER := nTOT_GER + PAG_VIST->Valor
//
//           PAG_VIST->(dbskip())
//
//           if ! PAG_VIST->(eof()) .and. PAG_VIST->Data <> dVENC
//              @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
//              nTOT_DIA := 0
//              dVENC := PAG_VIST->Data
//           endif
//
//       enddo
//
//       if nTOT_DIA <> 0
//          @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999,999.99")
//          nTOT_DIA := 0
//       endif
//
//       if nTOT <> 0
//          @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Valor Total Pago a Vista"+chr(9)+transform(nTOT, "@E 999,999,999.99")
//       endif
//
//   endif

//   if nTOT_GER <> 0
//      @ prow()+1, 0 say ""
//      @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+"Valor Total Pago"+chr(9)+transform(nTOT_GER, "@E 999,999,999.99")
//   endif
   qstopprn(.F.)

return

static function i_Resumo(aResumo)
   local cATU := ""

   aResumo := asort(aResumo,,,{|x,y| x[1] > y[1] })

   nCONT := 1

   @ prow()+2,0   say padc(" Resumo por Tipo de Pagamento ",135)
   @ prow()+1,0   say replicate("-",135)
   @ prow()+1,0   say "Tipo de Pagamento                                         Valor"
   @ prow()+1,0   say ""

   cATU := aResumo[1,1]
   nTOTAL := 0

   do while  nCONT <= len(aResumo)

      nTOTAL += aResumo[nCONT,2]

      nCONT++

      if nCONT > len(aResumo)
         nCONT := len(aResumo)
         exit
      endif

      if aResumo[nCONT,1] != cATU
         @ prow()+1,00 say qabrev(cATU,"1234567",{"Cheque","Pre-Datado","Debito C/C","Copia Cheque","Ordem Pgto","Especie","Pgto OnLine"})
         @ prow()  ,50 say transform(nTOTAL,"@E 9,999,999.99")
         nTOTAL := 0
         cATU := aResumo[nCONT,1]
      endif

   enddo

   @ prow()+1,00 say qabrev(cATU,"1234567",{"Cheque","Pre-Datado","Debito C/C","Copia Cheque","Ordem Pgto","Especie","Pgto OnLine"})
   @ prow()  ,50 say transform(nTOTAL,"@E 9,999,999.99")
   nTOTAL := 0
   cATU   := ""

return



