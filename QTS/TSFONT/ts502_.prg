/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: EMISSAO DE CHEQUES
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: MAIO DE 1998
// OBS........:
// ALTERACOES.:
function ts502

#include "inkey.ch"
#include "setcurs.ch"

CCUSTO->(dbsetorder(4))
BANCO->(Dbsetorder(3))

// VIEW INICIAL _____________________________________________________________

PAGOS->(qview({{"Codigo/C¢digo"                ,1},;
               {"Data_venc/Vencimento"         ,2},;
               {"f_502b()/Fornecedor"          ,3},;
               {"f_502c()/    Valor"           ,4},;
               {"Fatura/Fatura"                ,5},;
               {"Nr_cheque/Cheque"             ,0}},"P",;
               {NIL,"f502a",NIL,NIL},;
               NIL,"ESC/ALT-P/ALT-O/<C>onsulta/<E>mite cheque/<N>ominal"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_502b
   FORN->(dbseek(PAGOS->Cod_forn))
return left(FORN->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_502c
return(transform(PAGOS->Valor_liq,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f502a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   i_emite()

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_emite

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"

      qlbloc(05,00,"B502A","QBLOC.GLO",1)

      XNIVEL := 1

      qrsay ( XNIVEL++ , PAGOS->Codigo       )
      qrsay ( XNIVEL++ , PAGOS->Data_lanc    )
      qrsay ( XNIVEL++ , PAGOS->Cod_forn     ) ; FORN->(dbseek(PAGOS->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , PAGOS->Centro       ) ; CCUSTO->(dbseek(PAGOS->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , PAGOS->Filial       ) ; FILIAL->(dbseek(PAGOS->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , PAGOS->Data_emiss   )
      qrsay ( XNIVEL++ , PAGOS->Cod_veic     ) ; VEICULOS->(dbseek(PAGOS->Cod_veic))
      qrsay ( XNIVEL++ , left(VEICULOS->Descricao,13))
      qrsay ( XNIVEL++ , PAGOS->Cod_eqpto    ) ; EQUIPTO->(dbseek(PAGOS->Cod_eqpto))
      qrsay ( XNIVEL++ , EQUIPTO->Descricao  )
      qrsay ( XNIVEL++ , PAGOS->Especie      ) ; ESPECIE->(dbseek(PAGOS->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , PAGOS->Serie        ) ; SERIE->(dbseek(PAGOS->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , PAGOS->Tipo_sub     ) ; TIPOCONT->(dbseek(PAGOS->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(PAGOS->Historico,60))
      qrsay ( XNIVEL++ , PAGOS->Data_venc    )
      qrsay ( XNIVEL++ , PAGOS->Data_prorr   )
      qrsay ( XNIVEL++ , transform(PAGOS->Valor_liq,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , PAGOS->Tipo_doc     ) ; TIPO_DOC->(dbseek(PAGOS->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , PAGOS->Fatura       )
      qrsay ( XNIVEL++ , PAGOS->Duplicata    )
      qrsay ( XNIVEL++ , PAGOS->Cgm          ) ; CGM->(dbseek(PAGOS->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , PAGOS->Cod_Banco    ) ; BANCO->(Dbseek(PAGOS->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , PAGOS->Situacao     ) ; SITUA->(dbseek(PAGOS->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , PAGOS->Data_cont    )
      qrsay ( XNIVEL++ , left(PAGOS->Observacao,59))

      qwait()

   elseif cOPCAO == "E"

      if ! qconf("Confirma emissao do Cheque??") ; return .F. ; endif

      i_cheq()
   elseif cOPCAO == "N"

      if ! qconf("Confirma emissao do Cheque Nominal??") ; return .F. ; endif

      i_nominal()

   endif

return

////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA IMPRESSAO DO CHEQUE ______________________________
function i_cheq()

   local cEXTENSO

   if POS_CHEQ->(Dbseek(PAGOS->Cod_banco))

      if ! qinitprn() ; return ; endif

      @ prow()+1,val(POS_CHEQ->Valor) say "## " + transform(PAGOS->Valor_liq,"@E 999,999.99") + " ##"

      cEXTENSO := qextenso(PAGOS->Valor_liq)
      nTAM := len(cEXTENSO)

      @ prow()+2,val(POS_CHEQ->Extenso)      say iif( nTAM > val(POS_CHEQ->Linha) , left(cEXTENSO, val(POS_CHEQ->Linha) ) , cEXTENSO  )

      if nTAM > val(POS_CHEQ->Linha)
         @ prow()+1,val(POS_CHEQ->Extenso)-6   say substr( cEXTENSO, val(POS_CHEQ->Linha)+1, nTAM )
      else
         @ prow()+1,0 say ""
      endif

      @ prow()+2,val(POS_CHEQ->Nominal) say iif( FORN->(Dbseek(PAGOS->Cod_forn)) , space(20)    , space(20) )
      @ prow()+3,val(POS_CHEQ->Cidade)  say iif( CGM-> (Dbseek(PAGOS->Cgm))    , left(CGM->Municipio,10) , space(10) )
      @ prow()  ,val(POS_CHEQ->Dia)     say left(dtoc(XDATASYS),2)
      @ prow()  ,val(POS_CHEQ->Mes)     say qnomemes(XDATASYS)
      @ prow()  ,val(POS_CHEQ->Ano)     say right(dtoc(XDATASYS),2)

      @ prow()+3,0 say ""

      qstopprn()
   else
      qmensa("N„o existe lay-out de cheques ...","B")
      return .F.
   endif
return

////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA IMPRESSAO DO CHEQUE ______________________________
function i_nominal()

   local cEXTENSO

   if POS_CHEQ->(Dbseek(PAGOS->Cod_banco))

      if ! qinitprn() ; return ; endif

      @ prow()+1,val(POS_CHEQ->Valor) say "## " + transform(PAGOS->Valor_liq,"@E 999,999.99") + " ##"

      cEXTENSO := qextenso(PAGOS->Valor_liq)
      nTAM := len(cEXTENSO)

      @ prow()+2,val(POS_CHEQ->Extenso)      say iif( nTAM > val(POS_CHEQ->Linha) , left(cEXTENSO, val(POS_CHEQ->Linha) ) , cEXTENSO  )

      if nTAM > val(POS_CHEQ->Linha)
         @ prow()+1,val(POS_CHEQ->Extenso)-6   say substr( cEXTENSO, val(POS_CHEQ->Linha)+1, nTAM )
      else
         @ prow()+1,0 say ""
      endif

      @ prow()+2,val(POS_CHEQ->Nominal) say iif( FORN->(Dbseek(PAGOS->Cod_forn)) , left(FORN->Razao,50) , space(20) )
      @ prow()+3,val(POS_CHEQ->Cidade)  say iif( CGM-> (Dbseek(PAGOS->Cgm))    , left(CGM->Municipio,10) , space(10) )
      @ prow()  ,val(POS_CHEQ->Dia)     say left(dtoc(XDATASYS),2)
      @ prow()  ,val(POS_CHEQ->Mes)     say qnomemes(XDATASYS)
      @ prow()  ,val(POS_CHEQ->Ano)     say right(dtoc(XDATASYS),2)

      @ prow()+3,0 say ""

      qstopprn()
   else
      qmensa("N„o existe lay-out de cheques ...","B")
      return .F.
   endif
return

