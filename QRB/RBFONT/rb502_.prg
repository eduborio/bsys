/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: LISTAGEM DE LOTES
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: ABRIL DE 1997
// OBS........:
function rb502

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dLOTE_INI        // define numero lote inicial para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nTOT    := 0
private nTOT_DIA:= 0

fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dLOTE_INI                   ) } ,"LOTE_INI" })

do while .T.

   qlbloc(05,0,"B502A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   dLOTE_INI  := space(5)

   dLOTE_INI := strzero(CONFIG->Num_lote,5,0)

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

      case cCAMPO == "LOTE_INI"
           if empty(dLOTE_INI) ; return .F. ; endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE LOTE DAS DUPLICATAS"

   RECEBER->(dbsetorder(7))  // num_lote

   if ! RECEBER->(dbseek(dLOTE_INI))
      qmensa("N„o Existe Este n£mero de Lote!","B")
      return .F.
   endif

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55
   nTOT    := 0
   nTOT_DIA:= 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   do while ! RECEBER->(eof()) .and. qcontprn() // condicao principal de loop

       if ! qlineprn() ; exit ; endif
       @ prow(),pcol() say XCOND1

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,110)
          BANCO->(Dbseek(RECEBER->Cod_banco))
          @ prow()+1, 0 say "BANCO   -> " + BANCO->Banco + "  " + BANCO->Descricao + space(30) + "LOTE Nr.: " + XAENFAT + dLOTE_INI + XDENFAT
          @ prow()+1, 0 say "AGENCIA -> " + BANCO->Agencia + " C/C -> " + transform(BANCO->Conta, "@R 999999-9")
          @ prow()+2, 0 say "NR.TITULO        VENCIMENTO PRACA                     CLIENTE                               VALOR  JUROS P/DIA"
          @ prow()+1, 0 say replicate("-",110)
       endif

       @ prow()+1,00  say RECEBER->Num_titulo
       @ prow()  ,17  say dtoc(RECEBER->Data_venc)     ; CGM->(Dbseek(RECEBER->Praca))
       @ prow()  ,28  say left(CGM->Municipio,22) + " " + CGM->Estado ; CLI1->(Dbseek(RECEBER->Cod_cli))
       @ prow()  ,54  say left(CLI1->Razao,30)
       @ prow()  ,89 say transform(RECEBER->Valor, "@E 999,999.99")
       @ prow()  ,100 say transform(RECEBER->Juros_val, "@E 999,999.99")

       nTOT := nTOT + RECEBER->Valor

       RECEBER->(dbskip())

   enddo

   @ prow()+1, 0 say replicate("-",110)
   @ prow()+1,84 say XAENFAT+transform(nTOT, "@E 999,999,999.99")+XDENFAT
   @ prow()+1, 0 say replicate("-",110)

   qstopprn()

return
