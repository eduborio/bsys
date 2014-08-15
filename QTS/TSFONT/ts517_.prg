/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE FLUXO DE CAIXA
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: SETEMBRO DE 2001
// OBS........:
function ts517

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}
private cTITULO          // titulo do relatorio
private aEDICAO := {}    // vetor para os campos de entrada de dados
private cBANCO := space(5)
private cTIPO := space(1)
private dDATA_INI  := ctod("")
private dDATA_FIN  := ctod("")

sBLOC1 :=  qlbloc("B512B","QBLOC.GLO",1)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_banco(-1,0,@cBANCO ,"99999"        ) } ,"BANCO"    })
aadd(aEDICAO,{{ || NIL                                       } ,NIL        })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO , sBLOC1              ) } ,"TIPO"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })

do while .T.

   qlbloc(05,0,"B517A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   cBANCO  := space(5)
   cTIPO := space(1)
   dDATA_INI  := ctod("")
   dDATA_FIM  := ctod("")
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
      case cCAMPO == "BANCO"
           if empty(cBANCO)
              return .F.
           else
              BANCO->(dbsetorder(3))
              if ! BANCO->(dbseek(strzero(val(cBANCO),5)))
                 qmensa("Banco nao cadastrado ! ","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(BANCO->Descricao,40))
           endif

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
      case cCAMPO == "TIPO"

           qrsay(XNIVEL,qabrev(cTIPO,"GP",{"Geral","Periodo"}))
           if cTIPO == "G"
              XNIVEL+=2

           endif
   endcase

return .T.


// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE FLUXO DE CAIXA  "

   if ! quse(XDRV_TS, "FLUXO",,"E")
      qmensa("N„o foi poss¡vel abrir arquivo FLUXO.DBF !! Tente novamente.")
      return
   endif


   if FLUXO->(qflock())
      FLUXO->(__dbZap())
      FLUXO->(dbCreateIndex( XDRV_TS + "FLUXO", "dtos(Data)", {|| dtos(Data)}, if( .F., .T., NIL ) ))
      FLUXO->(dbunlock())
   endif

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
 do case
    case cTIPO == "G"
         i_imp1()
    case cTIPO == "P"
         i_imp2()
 endcase
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_imp1

   local nMAXLIN := 55
   local nSALDO := nENTRADA := nSAIDA := nSLD := 0
   local nSALDO_INI := 0.00
   local nSALDO_TOT := 0.00
   local nSALDO_CAI := 0.00

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   do while ! PAGAR->(eof()) .and. qcontprn()  // condicao principal de loop

             if FLUXO->(qappend())
                replace FLUXO->Data       with PAGAR->Data_venc
                replace FLUXO->Saida      with PAGAR->Valor_liq
             endif

             PAGAR->(Dbskip())
   enddo
   FLUXO->(dbcommit())

   do while ! RECEBER->(eof()) .and. qcontprn()  // condicao principal de loop

             if FLUXO->(qappend())
                replace FLUXO->Data       with RECEBER->Data_venc
                replace FLUXO->Entrada    with RECEBER->Valor_liq
             endif

             RECEBER->(Dbskip())
   enddo
   FLUXO->(dbcommit())


   qmensa("Aguarde... Gerando indice termporario...")

   FLUXO->(dbCreateIndex( XDRV_TS + "FLUXO", "dtos(Data)", {|| dtos(Data)}, if( .F., .T., NIL ) ))

   FLUXO->(Dbsetorder(1))
   FLUXO->(Dbgotop())

   qmensa("")
   nSALDO_CAI := 0
   dVENC := FLUXO->Data

   do while ! FLUXO->(eof()) .and. qcontprn()


       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "DATA          CAIXA/BANCOS    ENTRADA               SAIDA                SALDO"
          @ prow()+1, 0 say replicate("-",80)
       endif


       nENTRADA += FLUXO->Entrada
       nSAIDA   += FLUXO->Saida

       FLUXO->(dbskip())

       if FLUXO->Data <> dVENC .or. FLUXO->(eof())

          @ prow()+1,00  say dtoc(dVENC)

          if dVENC == XDATA
             @ prow()  ,12  say transform(i_bank(), "@E 9,999,999.99")
             nSLD := nSLD + i_bank()
          endif
          @ prow()  ,26  say transform(nENTRADA, "@E 9,999,999.99")
          @ prow()  ,46  say transform(nSAIDA  , "@E 9,999,999.99")
          nSLD := nSLD + (nENTRADA - nSAIDA)
          if nSLD < 0
             @ prow()  ,66  say transform(nSLD*-1, "@E 9,999,999.99")+" C"
          elseif nSLD > 0
             @ prow()  ,66  say transform(nSLD, "@E 9,999,999.99")+" D"
          else
             @ prow()  ,66  say transform(0, "@E 9,999,999.99")
          endif
          nENTRADA := 0
          nSAIDA := 0
          dVENC := FLUXO->Data
       endif
   enddo

FLUXO->(dbclosearea())
//   eject
   qstopprn()
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_imp2

   local nMAXLIN := 55
   local nSALDO := nENTRADA := nSAIDA := nSLD := 0
   local nSALDO_INI := 0.00
   local nSALDO_TOT := 0.00
   local nSALDO_CAI := 0.00

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   do while ! PAGAR->(eof()) .and. qcontprn()  // condicao principal de loop

             if FLUXO->(qappend())
                replace FLUXO->Data       with PAGAR->Data_venc
                replace FLUXO->Saida      with PAGAR->Valor_liq
             endif

             PAGAR->(Dbskip())
   enddo
   FLUXO->(dbcommit())

   do while ! RECEBER->(eof()) .and. qcontprn()  // condicao principal de loop

             if FLUXO->(qappend())
                replace FLUXO->Data       with RECEBER->Data_venc
                replace FLUXO->Entrada    with RECEBER->Valor_liq
             endif

             RECEBER->(Dbskip())
   enddo
   FLUXO->(dbcommit())


   qmensa("Aguarde... Gerando indice termporario...")

   FLUXO->(dbCreateIndex( XDRV_TS + "FLUXO", "dtos(Data)", {|| dtos(Data)}, if( .F., .T., NIL ) ))

   FLUXO->(Dbsetorder(1))
   FLUXO->(Dbgotop())

   qmensa("")
   nSALDO_CAI := 0
   set softseek on
   FLUXO->(dbseek(dDATA_INI))
   dVENC := FLUXO->Data

   do while ! FLUXO->(eof()) .and. FLUXO->Data >= dDATA_INI .and. FLUXO->Data <= dDATA_FIM .and. qcontprn()

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say replicate("-",80)
          @ prow()+1, 0 say "DATA          CAIXA/BANCOS    ENTRADA               SAIDA                SALDO"
          @ prow()+1, 0 say replicate("-",80)
       endif


       nENTRADA += FLUXO->Entrada
       nSAIDA   += FLUXO->Saida

       FLUXO->(dbskip())

       if FLUXO->Data <> dVENC .or. FLUXO->(eof())

          @ prow()+1,00  say dtoc(dVENC)

          if dVENC == XDATA
             @ prow()  ,12  say transform(i_bank(), "@E 9,999,999.99")
             nSLD := nSLD + i_bank()
          endif
          @ prow()  ,26  say transform(nENTRADA, "@E 9,999,999.99")
          @ prow()  ,46  say transform(nSAIDA  , "@E 9,999,999.99")
          nSLD := nSLD + (nENTRADA - nSAIDA)
          if nSLD < 0
             @ prow()  ,66  say transform(nSLD*-1, "@E 9,999,999.99")+" C"
          elseif nSLD > 0
             @ prow()  ,66  say transform(nSLD, "@E 9,999,999.99")+" D"
          else
             @ prow()  ,66  say transform(0, "@E 9,999,999.99")
          endif
          nENTRADA := 0
          nSAIDA := 0
          dVENC := FLUXO->Data
       endif
   enddo

FLUXO->(dbclosearea())
//   eject
   qstopprn()
return

/////////////////////////////////////////////////////////////////////////////
//CALCULA SALDO DE TODOS OS BANCOS___________________________________________
function i_bank
     nSALDO := 0
     SALD_BAN->(Dbsetorder(1))
     SALD_BAN->(Dbgotop())

     BANCO->(dbgotop())

     MOV_BANC->(Dbsetorder(2))
     MOV_BANC->(Dbgotop())


    if ! SALD_BAN->(dbseek(dtos(XDATA)+cBANCO))
       nSALDO := 0  // final de semana ?
    else
       if SALD_BAN->Cod_banco != "99999"
          nSALDO := SALD_BAN->Saldo
       endif
    endif

    set softseek on
    MOV_BANC->(Dbseek(cBANCO+dtos(XDATA)))
    set softseek off

    do while ! MOV_BANC->(eof()) .and. MOV_BANC->Cod_banco = cBANCO .and. MOV_BANC->Data = XDATA
       do case
          case ! empty(MOV_BANC->Entrada)
               nSALDO += MOV_BANC->Entrada
          case ! empty(MOV_BANC->Saida)
               nSALDO -= MOV_BANC->Saida
       endcase

       MOV_BANC->(Dbskip())
    enddo

return nSALDO


