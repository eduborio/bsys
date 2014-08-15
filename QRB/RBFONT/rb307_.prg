/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: CONSULTA RECEBIMENTOS LIQUIDADOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

//#include "inkey.ch"
//#include "setcurs.ch"
function rb307

fu_abre_cli1()

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

RECEBIDO->(dbSetFilter({|| ! empty(RECEBIDO->Data_pagto) }, '! empty(RECEBIDO->Data_pagto'))

// VIEW INICIAL _____________________________________________________________

RECEBIDO->(qview({{"Data_venc/Vcto"            ,2},;
                 {"Data_pagto/Pagto"           ,6},;
                 {"f_307a()/Cliente"          ,9},;
                 {"f_307b()/  Valor"          ,0},;
                 {"Num_titulo/Titulo"         ,3}},"P",;
                 {NIL,"f307a",NIL,NIL},;
                 NIL,"ESC/ALT-P/ALT-O/<C>onsulta"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_307a
   CLI1->(dbseek(RECEBIDO->Cod_cli))
return left(CLI1->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_307b
return(transform(RECEBIDO->Valor,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f307a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
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

   if cOPCAO =  "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , RECEBIDO->Codigo       )
      qrsay ( XNIVEL++ , RECEBIDO->Data_lanc    )
      qrsay ( XNIVEL++ , RECEBIDO->Cod_cli      ) ; CLI1->(dbseek(RECEBIDO->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))
      qrsay ( XNIVEL++ , RECEBIDO->Centro       ) ; CCUSTO->(dbseek(RECEBIDO->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , RECEBIDO->Filial       ) ; FILIAL->(dbseek(RECEBIDO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , RECEBIDO->Data_emiss   )
      qrsay ( XNIVEL++ , RECEBIDO->Especie      ) ; ESPECIE->(dbseek(RECEBIDO->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , RECEBIDO->Serie        ) ; SERIE->(dbseek(RECEBIDO->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , RECEBIDO->Tipo_sub     ) ; TIPOCONT->(dbseek(RECEBIDO->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,45))
      qrsay ( XNIVEL++ , left(RECEBIDO->Historico,60))
      qrsay ( XNIVEL++ , RECEBIDO->Data_venc    )
      qrsay ( XNIVEL++ , RECEBIDO->Data_prorr   )
      qrsay ( XNIVEL++ , transform(RECEBIDO->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , RECEBIDO->Tipo_doc     ) ; TIPO_DOC->(dbseek(RECEBIDO->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , RECEBIDO->Fatura       )
      qrsay ( XNIVEL++ , RECEBIDO->Duplicata    )
      qrsay ( XNIVEL++ , RECEBIDO->Cgm          ) ; CGM->(dbseek(RECEBIDO->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , RECEBIDO->Cod_Banco    ) ; BANCO->(Dbseek(RECEBIDO->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , RECEBIDO->Situacao     ) ; SITUA->(dbseek(RECEBIDO->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , RECEBIDO->Data_cont    )
      qrsay ( XNIVEL++ , RECEBIDO->Vendedor     ) ; FUN->(dbseek(RECEBIDO->Vendedor))
      qrsay ( XNIVEL++ , left(FUN->Nome,40)    )
      qrsay ( XNIVEL++ , left(RECEBIDO->Observacao,59))


   endif

   qwait()

return
