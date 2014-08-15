/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: CONSULTA PAGAMENTOS EM ABERTO
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function rb310
#include "inkey.ch"
#include "setcurs.ch"

fu_abre_cli1()

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

//RECEB2->(dbSetFilter({|| empty(RECEB2->Data_pagto) }, 'empty(RECEB2->Data_pagto'))

// VIEW INICIAL _____________________________________________________________

RECEB2->(qview({{"Data_venc/Vcto"              ,2},;
                 {"Cod_cli/Cod."                ,6},;
                 {"left(Cliente,26)/Cliente"            ,8},;
                 {"Codbanco/Banco"              ,0},;
                 {"transform(Valor,'@E 9999,999.99')/Valor" ,0},;
                 {"Fatura/Fatura"               ,0}},"P",;
                 {NIL,"f310a",NIL,NIL},;
                 NIL,"ESC/ALT-P/ALT-O/<C>onsulta/ <R>eversao "))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_310b
   CLI1->(dbseek(RECEB2->Cod_cli))
return left(CLI1->Razao,26)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_310c
return(transform(RECEB2->Valor,"@E 9999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f310a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(05,02,"B306A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
      i_consulta()
   endif
   if cOPCAO == "R" ; i_retorna() ; endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO =  "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , RECEB2->Codigo       )
      qrsay ( XNIVEL++ , RECEB2->Data_lanc    )
      qrsay ( XNIVEL++ , RECEB2->Cod_cli      ) ; CLI1->(dbseek(RECEB2->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))
      qrsay ( XNIVEL++ , RECEB2->Centro       ) ; CCUSTO->(dbseek(RECEB2->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , RECEB2->Filial       ) ; FILIAL->(dbseek(RECEB2->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , RECEB2->Data_emiss   )
      qrsay ( XNIVEL++ , RECEB2->Especie      ) ; ESPECIE->(dbseek(RECEB2->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , RECEB2->Serie        ) ; SERIE->(dbseek(RECEB2->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , RECEB2->Tipo_sub     ) ; TIPOCONT->(dbseek(RECEB2->Tipo_sub))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,45))
      qrsay ( XNIVEL++ , left(RECEB2->Historico,60))
      qrsay ( XNIVEL++ , RECEB2->Data_venc    )
      qrsay ( XNIVEL++ , RECEB2->Data_prorr   )
      qrsay ( XNIVEL++ , transform(RECEB2->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , RECEB2->Tipo_doc     ) ; TIPO_DOC->(dbseek(RECEB2->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , RECEB2->Fatura       )
      qrsay ( XNIVEL++ , RECEB2->Duplicata    )
      qrsay ( XNIVEL++ , RECEB2->Cgm          ) ; CGM->(dbseek(RECEB2->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , RECEB2->Cod_Banco    ) ; BANCO->(Dbseek(RECEB2->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , RECEB2->Situacao     ) ; SITUA->(dbseek(RECEB2->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , RECEB2->Data_cont    )
      qrsay ( XNIVEL++ , RECEB2->Vendedor     ) ; FUN->(dbseek(RECEB2->Vendedor))
      qrsay ( XNIVEL++ , left(FUN->Nome,40)    )
      qrsay ( XNIVEL++ , left(RECEB2->Observacao,59))


   endif

   qwait()

return

function i_retorna
   local lCONF

   lCONF := qconf("Confirma Reversao de Transferencia p/ Arquivo ?")

   if lCONF

      if ! RECEBER->(qrlock()) .and. ! RECEB2->(qrlock())
         qmensa("N„o foi Poss¡vel Realizar Reversao !","B")
         return
      else
         RECEB2->(qpublicfields())
         RECEB2->(qcopyfields())
         RECEBER->(qappend())
         fDATA_PAGTO := ctod("")
         RECEBER->(qreplacefields())
         RECEB2->(qrlock())
         RECEB2->(dbdelete())
         RECEBER->(qunlock())
         RECEB2->(qunlock())
      endif
   endif
return

