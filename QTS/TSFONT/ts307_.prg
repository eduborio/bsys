/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: CONSULTA DE PAGAMENTOS LIBERADOS ( A RECEBER )
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function ts307

//#include "inkey.ch"
//#include "setcurs.ch"

BANCO->(Dbsetorder(3))
CCUSTO->(dbsetorder(4))

fu_abre_cli1()

// VIEW INICIAL _____________________________________________________________

REC_TESO->(qview({{"Data_venc/Vencimento"         ,2},;
               {"left(cliente,22)/Cliente"     ,7},;
               {"f_307c()/    Valor"           ,4},;
               {"f_307d()/Valor liq"           ,0},;
               {"Fatura/Fatura"                ,5}},"P",;
               {NIL,"f307a",NIL,NIL},;
                NIL,"ESC/ALT-P/ALT-O/<C>onsulta"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_307b
   CLI1->(dbseek(REC_TESO->Cod_cli))
return left(CLI1->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_307c
return(transform(REC_TESO->Valor,"@E 9,999,999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_307d
return(transform(REC_TESO->Valor_liq,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f307a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "C"
      qlbloc(05,02,"B307A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
      i_consulta()
   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"
      XNIVEL := 1

      qrsay ( XNIVEL++ , REC_TESO->Codigo       )
      qrsay ( XNIVEL++ , REC_TESO->Data_lanc    )
      qrsay ( XNIVEL++ , REC_TESO->Cod_cli      ) ; CLI1->(dbseek(REC_TESO->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))
      qrsay ( XNIVEL++ , REC_TESO->Centro       ) ; CCUSTO->(dbseek(REC_TESO->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , REC_TESO->Filial       ) ; FILIAL->(dbseek(REC_TESO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , REC_TESO->Data_emiss   )
      qrsay ( XNIVEL++ , REC_TESO->Especie      ) ; ESPECIE->(dbseek(REC_TESO->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , REC_TESO->Serie        ) ; SERIE->(dbseek(REC_TESO->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , REC_TESO->Tipo_sub     ) ; TIPOCONT->(dbseek(REC_TESO->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(REC_TESO->Historico,60))
      qrsay ( XNIVEL++ , REC_TESO->Data_venc    )
      qrsay ( XNIVEL++ , REC_TESO->Data_prorr   )
      qrsay ( XNIVEL++ , transform(REC_TESO->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , REC_TESO->Tipo_doc     ) ; TIPO_DOC->(dbseek(REC_TESO->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , REC_TESO->Fatura       )
      qrsay ( XNIVEL++ , REC_TESO->Duplicata    )
      qrsay ( XNIVEL++ , REC_TESO->Cgm          ) ; CGM->(dbseek(REC_TESO->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , REC_TESO->Cod_Banco    ) ; BANCO->(Dbseek(REC_TESO->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , REC_TESO->Situacao     ) ; SITUA->(dbseek(REC_TESO->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , REC_TESO->Data_cont    )
      qrsay ( XNIVEL++ , REC_TESO->Vendedor     ) ; FUN->(dbseek(REC_TESO->Vendedor))
      qrsay ( XNIVEL++ , left(FUN->Nome,40)    )
      qrsay ( XNIVEL++ , left(REC_TESO->Observacao,59))
   endif

   qwait()

return
