/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: LISTAGEM DE DESPESAS POR VEICULOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1997
// OBS........:
function pg502

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define data final para impressao
private cVEIC            // define veiculo
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nTOT    := 0

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_veic(-1,0,@cVEIC) } , "VEIC"   })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do veiculo
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })

do while .T.

   qlbloc(05,0,"B502A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cVEIC      := space(5)

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

      case cCAMPO == "VEIC"
           if ! empty(cVEIC)
             if VEICULOS->(Dbseek(strzero(val(cVEIC),5)))
               qrsay(XNIVEL+1,VEICULOS->Descricao)
             else
               qmensa("N„o Existe este Ve¡culo no Cadastro !","B")
               return .F.
             endif
           else
             qrsay(XNIVEL+1,"*** Todos os Veiculos ***")
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

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE DESPESAS DE VEICULOS"

   PAGOS->(dbsetorder(3))     // DATA_EMISS + COD_VEIC
   PAGOS->(Dbgotop())
   PAG_TESO->(dbsetorder(4))  // DATA_EMISS + COD_VEIC
   PAG_TESO->(Dbgotop())

   if ! empty(cVEIC)
      PAGOS->(dbsetFilter({|| Cod_veic == cVEIC},"Cod_veic == cVEIC"))
      PAG_TESO->(dbsetFilter({|| Cod_veic == cVEIC},"Cod_veic == cVEIC"))
   endif

   set softseek on
   PAGOS->(Dbseek(dDATA_INI))
   PAG_TESO->(Dbseek(dDATA_INI))

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")
   
   do while ! PAG_TESO->(eof()) .and. PAG_TESO->Data_emiss >= dDATA_INI .and. PAG_TESO->Data_emiss <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "DOCTO  EMISSAO   FORNECEDOR                       VALOR     VEICULO"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00   say left(PAG_TESO->Fatura,6)
       @ prow()  ,07   say dtoc(PAG_TESO->Data_emiss)
       @ prow()  ,17   say iif(FORN->(dbseek(PAG_TESO->Cod_forn)) , left(FORN->Razao,29) , space(29) )
       @ prow()  ,47   say transform(PAG_TESO->Valor, "@E 9,999,999.99")
       @ prow()  ,60   say iif(VEICULOS->(dbseek(PAG_TESO->Cod_veic)) , VEICULOS->Descricao , space(15) )

       nTOT := nTOT + PAG_TESO->Valor

       PAG_TESO->(dbskip())

   enddo

   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,20 say "Valor Total a Pagar ...> "+transform(nTOT, "@E 999,999,999.99")
   endif

   nTOT := 0

   do while ! PAGOS->(eof()) .and. PAGOS->Data_emiss >= dDATA_INI .and. PAGOS->Data_emiss <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say "DOCTO  EMISSAO   FORNECEDOR                          VALOR     VEICULO"
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow()+1,00   say left(PAGOS->Fatura,6)
       @ prow()  ,07   say dtoc(PAGOS->Data_emiss)
       @ prow()  ,17   say iif(FORN->(dbseek(PAGOS->Cod_forn)) , left(FORN->Razao,29) , space(29) )
       @ prow()  ,47   say transform(PAGOS->Valor, "@E 9,999,999.99")
       @ prow()  ,60   say iif(VEICULOS->(dbseek(PAGOS->Cod_veic)) , VEICULOS->Descricao , space(15) )

       nTOT := nTOT + PAGOS->Valor

       PAGOS->(dbskip())

   enddo

   if nTOT <> 0
      @ prow()+1, 0 say replicate("-",80)
      @ prow()+1,23 say "Valor Total Pago ...> "+transform(nTOT, "@E 999,999,999.99")
   endif

   qstopprn()

return
