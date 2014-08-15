/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE MOVIMENTO DO CAIXA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1998
// OBS........:
// ALTERACAO..: 06/07/2001
function ts513

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________


local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private cTITULO          // titulo do relatorio
private nCOD             // codigo do historico padrao para montar historico
private nHISTORICO
private nENTRADA := 0
private nSAIDA   := 0


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

return
