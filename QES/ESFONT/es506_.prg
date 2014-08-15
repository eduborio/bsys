///////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: RELATORIO DE BAIXAS POR PERDAS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JULHO DE 1999
// OBS........:
// ALTERACOES.:
function es506

#include "inkey.ch"
#define K_LEN_HIST 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO   := {}       // vetor para os campos
private cTITULO               // titulo do relatorio
private cDT_INI   := ctod("")             // data inicial na faixa
private cDT_FIM   := ctod("")             // data final na faixa
private nTOTAL    := 0
private nTOT_GER  := 0

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cDT_INI    ,"@D"      )},"DT_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@cDT_FIM    ,"@D"      )},"DT_FIMF"})

do while .T.

   qlbloc(5,0,"B506A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "DT_INI"

           if empty(cDT_INI) ; return .F. ; endif
           cDT_FIM := qfimmes(cDT_INI)
           qrsay(XNIVEL+1,cDT_FIM)

      case cCAMPO == "DT_FIM"

           if empty(cDT_FIM) ; return .F. ; endif
           if cDT_INI > cDT_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // INICIALIZA cTITULO ____________________________________________________

   cTITULO := "RELATORIO DAS BAIXAS POR PERDAS"

   qmensa("")

   PROD->(dbsetorder(4))
   PROD->(dbgotop())

   PERDAS->(dbsetorder(1))
   PERDAS->(dbgotop())
   set softseek on
   PERDAS->(dbseek(dtos(cDT_INI)))
   set softseek off

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   nTOTAL   := 0
   nQUANT   := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   if ! qlineprn() ; return ; endif

   do while ! PERDAS->(eof()) .and. PERDAS->Data >= cDT_INI .and. PERDAS->data <= cDT_FIM

      // CABECALHO PRINCIPAL _____________________________________________

      if XPAGINA = 0 .or. prow() > 57

         qpageprn()
         qcabecprn(cTITULO,132)
         @ prow()+2,0 say "Data        Produto                                          Quant          Obs"
         @ prow()+1,0 say ""

      endif

      @ prow()+1,00 say dtoc(PERDAS->Data)
      @ prow()  ,12 say left(PERDAS->Descricao,45)
      @ prow()  ,60 say transform(PERDAS->Quant,"@R 999999")
      @ prow()  ,76 say PERDAS->Obs

      nQUANT += PERDAS->Quant
      nTOTAL += PERDAS->Valor

      PERDAS->(Dbskip())

   enddo

   @ prow()+1,0 say replicate("-",132)
   @ prow()+1,0 say " TOTAIS..."
   @ prow()  ,58 say transform(nQUANT,"@R 99999999")
   @ prow()+1,0 say replicate("-",132)

   qstopprn()

return
