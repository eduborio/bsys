/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: COTACAO DE PRECOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: AGOSTO DE 1997
// OBS........:

function cp509

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private cTITULO          // titulo do relatorio
private cCOD_PROD
private aEDICAO := {}    // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_prod(-1,0,@cCOD_PROD)   } , "COD_PROD" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do produto

do while .T.

   qlbloc(05,0,"B509A","QBLOC.GLO",1)

   XNIVEL    := 1
   XFLAG     := .T.
   cCOD_PROD := space(5)

   LANC->(dbSetFilter())

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
      case cCAMPO == "COD_PROD"

           if empty(cCOD_PROD) ; return .F. ; endif

           PROD->(dbsetorder(4))

           if ! PROD->(dbseek(cCOD_PROD:=strzero(val(cCOD_PROD),5)))
              qmensa("Produto n„o cadastrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(PROD->Descricao,36))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "COTACAO DE PRECO DO PRODUTO: " + cCOD_PROD + "-" + alltrim(PROD->Descricao)

   PEDIDO->(dbsetorder(2))

   LANC->(dbSetFilter({|| Cod_prod == cCOD_PROD }, 'Cod_prod == cCOD_PROD'))

   LANC->(dbgobottom())

   LANC->(dbskip(-1))
   LANC->(dbskip(-1))

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")
   
   @ prow(),pcol() say XCOND1

   do while ! LANC->(eof()) .and. qcontprn()

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,135)
          @ prow()+1 ,00 say "FORNECEDOR                                                               TELEFONE                         PRECO UNIT.    DATA DA COMPRA"
          @ prow()+1,0 say replicate("-",135)
       endif


       PEDIDO->(dbseek(LANC->Cod_ped))
       FORN->(dbseek(PEDIDO->Cod_forn))

       @ prow()+1,000 say FORN->Codigo + "-"  + FORN->Razao + "  " +;
                          FORN->Fone1  + space(13) +;
                          transform(LANC->Preco/LANC->Fator,"@E 999,999,999.99999") + space(08) +;
                          dtoc(PEDIDO->Data_ped)

       LANC->(dbskip())

   enddo

   qstopprn()

return
