/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: LISTAGEM DE CONTAS A PAGAR/PAGOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MARCO DE 1997
// OBS........:
function pg505

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO     := {}    // vetor para os campos de entrada de dados
private nTOT        := 0
private nTOT_DIA    := 0
private cFILIAL     := space(4)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                     ) } ,"DATA_INI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                     ) } ,"DATA_FIM"  })
aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL                 ) } ,"FILIAL"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // descricao da filial

do while .T.

   qlbloc(05,0,"B505A","QBLOC.GLO",1)

   XNIVEL     := 1
   XFLAG      := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cFILIAL    := space(4)

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
      case cCAMPO == "FILIAL"

           qrsay(XNIVEL,cFILIAL)

           if empty(cFILIAL)
              qrsay(XNIVEL++, "Todos as Filiais..........")
           else
              if ! FILIAL->(Dbseek(cFILIAL:=strzero(val(cFILIAL),4)))
                 qmensa("Filial n„o Cadastrada","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(FILIAL->Razao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTAS A PAGAR/PAGOS"

   PAGAR->(dbsetorder(8))  // DATA_VENC + FILIAL + COD_FORN
   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55
   local dVENC   := ctod("")

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")
   
   nTOT_DIA    := 0
   nTOT        := 0

   PAGAR->(Dbsetorder(8))
   PAGAR->(dbgotop())

   dVENC     := PAGAR->Data_venc

   do while ! PAGAR->(eof())  .and. qcontprn()  // condicao principal de loop

      if PAGAR->Data_venc < dDATA_INI .or. PAGAR->Data_venc > dDATA_FIM
         PAGAR->(Dbskip(1))
         loop
      endif

      if ! empty(cFILIAL) .and. PAGAR->Filial <> cFILIAL
         PAGAR->(Dbskip(1))
         loop
      endif

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,123)
         if ! empty(cFILIAL)
            FILIAL->(dbseek(cFILIAL))
            @ prow()+1,0 say XAENFAT + " FILIAL " + FILIAL->Razao + XDENFAT
         endif
         @ prow()+1, 0 say "VENCIMENTO  FORNECEDOR                         PGTO         VALOR   HISTORICO                                   SUB_TOTAL"
         @ prow()+1, 0 say replicate("-",123)
      endif

      @ prow()+1,00  say dtoc(PAGAR->Data_venc)
      FORN->(Dbseek(PAGAR->Cod_forn))
      @ prow() ,12 say left(FORN->Razao,30)
      @ prow() ,55  say transform(PAGAR->Valor_liq, "@E 999,999.99")
      @ prow() ,67  say left(PAGAR->Historico,38)

      nTOT := nTOT + PAGAR->Valor_liq
      nTOT_DIA := nTOT_DIA + PAGAR->Valor_liq

      PAGAR->(dbskip())

      if ! PAGAR->(eof()) .and. PAGAR->Data_venc <> dVENC
         @ prow()  ,111 say XAENFAT + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
         nTOT_DIA := 0
         dVENC := PAGAR->Data_venc
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow() ,111 say XAENFAT + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
      nTOT_DIA := 0
      dVENC := PAGAR->Data_venc
   endif

   @ prow()+1, 0 say replicate("-",123)
   @ prow()+1,0 say XAENFAT +       "Total Geral............... " + transform(nTOT, "@E 99,999,999.99") + XDENFAT

   PAGOS->(Dbsetorder(6))
   PAGOS->(dbgotop())

   XPAGINA   := 0
   dVENC     := PAGOS->Data_venc
   nTOT_DIA  := 0
   nTOT      := 0

   do while ! PAGOS->(eof())  .and. qcontprn()  // condicao principal de loop

      if PAGOS->Data_venc < dDATA_INI .or. PAGOS->Data_venc > dDATA_FIM
         PAGOS->(Dbskip(1))
         loop
      endif

      if ! empty(cFILIAL) .and. PAGOS->Filial <> cFILIAL
         PAGOS->(Dbskip(1))
         loop
      endif

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,123)
         if ! empty(cFILIAL)
            FILIAL->(dbseek(cFILIAL))
            @ prow()+1,0 say XAENFAT + " FILIAL " + FILIAL->Razao + XDENFAT
         endif
         @ prow()+1, 0 say "VENCIMENTO  FORNECEDOR                         PGTO         VALOR   HISTORICO                                   SUB_TOTAL"
         @ prow()+1, 0 say replicate("-",123)
      endif

      @ prow()+1,00  say dtoc(PAGOS->Data_venc)
      FORN->(Dbseek(PAGOS->Cod_forn))
      @ prow() ,12  say left(FORN->Razao,30)
      @ prow() ,45  say dtoc(PAGOS->Data_pagto)
      @ prow() ,55  say transform(PAGOS->Valor_liq, "@E 999,999.99")
      @ prow() ,68  say left(PAGOS->Historico,38)

      nTOT := nTOT + PAGOS->Valor_liq
      nTOT_DIA := nTOT_DIA + PAGOS->Valor_liq

      PAGOS->(dbskip())

      if ! PAGOS->(eof()) .and. PAGOS->Data_venc <> dVENC
         @ prow()  ,111 say XAENFAT + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
         nTOT_DIA := 0
         dVENC := PAGOS->Data_venc
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow() ,111 say XAENFAT + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
      nTOT_DIA := 0
      dVENC := PAGOS->Data_venc
   endif

   @ prow()+1, 0 say replicate("-",123)
   @ prow()+1,0 say XAENFAT +       "Total Geral............... " + transform(nTOT, "@E 99,999,999.99") + XDENFAT

   qstopprn()

return
