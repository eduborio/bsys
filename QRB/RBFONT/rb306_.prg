/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: CONSULTA PAGAMENTOS EM ABERTO
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function rb306

#include "inkey.ch"
#include "setcurs.ch"

fu_abre_cli1()

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

RECEBER->(dbSetFilter({|| empty(RECEBER->Data_pagto) }, 'empty(RECEBER->Data_pagto'))

// VIEW INICIAL _____________________________________________________________

RECEBER->(qview({{"Data_venc/Vcto"              ,2},;
                 {"Cod_cli/Cod."                ,6},;
                 {"f_306b()/Cliente"            ,9},;
                 {"Codbanco/Banco"              ,0},;
                 {"transform(Valor,'@E 9999,999.99')/Valor" ,0},;
                 {"Fatura/Fatura"               ,0}},"P",;
                 {NIL,"f306a",NIL,NIL},;
                 NIL,"ESC/ALT-P/ALT-O/<C>onsulta"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_306b
   CLI1->(dbseek(RECEBER->Cod_cli))
return left(CLI1->Razao,26)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_306c
return(transform(RECEBER->Valor,"@E 9999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f306a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(05,02,"B306A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
      i_consulta()
   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO =  "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , RECEBER->Codigo       )
      qrsay ( XNIVEL++ , RECEBER->Data_lanc    )
      qrsay ( XNIVEL++ , RECEBER->Cod_cli      ) ; CLI1->(dbseek(RECEBER->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))
      qrsay ( XNIVEL++ , RECEBER->Centro       ) ; CCUSTO->(dbseek(RECEBER->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , RECEBER->Filial       ) ; FILIAL->(dbseek(RECEBER->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , RECEBER->Data_emiss   )
      qrsay ( XNIVEL++ , RECEBER->Especie      ) ; ESPECIE->(dbseek(RECEBER->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , RECEBER->Serie        ) ; SERIE->(dbseek(RECEBER->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , RECEBER->Tipo_sub     ) ; TIPOCONT->(dbseek(RECEBER->Tipo_sub))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,45))
      qrsay ( XNIVEL++ , left(RECEBER->Historico,60))
      qrsay ( XNIVEL++ , RECEBER->Data_venc    )
      qrsay ( XNIVEL++ , RECEBER->Data_prorr   )
      qrsay ( XNIVEL++ , transform(RECEBER->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , RECEBER->Tipo_doc     ) ; TIPO_DOC->(dbseek(RECEBER->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , RECEBER->Fatura       )
      qrsay ( XNIVEL++ , RECEBER->Duplicata    )
      qrsay ( XNIVEL++ , RECEBER->Cgm          ) ; CGM->(dbseek(RECEBER->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , RECEBER->Cod_Banco    ) ; BANCO->(Dbseek(RECEBER->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , RECEBER->Situacao     ) ; SITUA->(dbseek(RECEBER->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , RECEBER->Data_cont    )
      qrsay ( XNIVEL++ , RECEBER->Vendedor     ) ; FUN->(dbseek(RECEBER->Vendedor))
      qrsay ( XNIVEL++ , left(FUN->Nome,40)    )
      qrsay ( XNIVEL++ , left(RECEBER->Observacao,59))


   endif

   qwait()

return
