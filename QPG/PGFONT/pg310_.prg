/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: CONSULTA PAGAMENTOS EM ABERTO
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function pg310

#include "inkey.ch"
#include "setcurs.ch"


// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

//PAGAR2->(dbSetFilter({|| empty(PAGAR2->Data_pagto) }, 'empty(PAGAR2->Data_pagto'))

// VIEW INICIAL _____________________________________________________________

PAGAR2->(qview({{"Data_venc/Vcto"              ,2},;
                 {"Cod_forn/Cod."              ,3},;
                 {"left(Fornec,26)/Fornecedor"            ,4},;
                 {"transform(Valor,'@E 9999,999.99')/Valor" ,0},;
                 {"Fatura/Fatura"               ,0}},"P",;
                 {NIL,"f310a",NIL,NIL},;
                 NIL,"ESC/ALT-P/ALT-O/<C>onsulta/ <R>eversao "))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_310b
   CLI1->(dbseek(PAGAR2->Cod_cli))
return left(CLI1->Razao,26)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_310c
return(transform(PAGAR2->Valor,"@E 9999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f310a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(05,02,"B307A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , PAGAR2->Codigo       )
      qrsay ( XNIVEL++ , PAGAR2->Data_lanc    )
      qrsay ( XNIVEL++ , PAGAR2->Cod_forn     ) ; FORN->(dbseek(PAGAR2->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , PAGAR2->Centro       ) ; CCUSTO->(dbseek(PAGAR2->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , PAGAR2->Filial       ) ; FILIAL->(dbseek(PAGAR2->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , PAGAR2->Data_emiss   )
      qrsay ( XNIVEL++ , PAGAR2->Cod_veic     ) ; VEICULOS->(dbseek(PAGAR2->Cod_veic))
      qrsay ( XNIVEL++ , left(VEICULOS->Descricao,13))
      qrsay ( XNIVEL++ , PAGAR2->Especie      ) ; ESPECIE->(dbseek(PAGAR2->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , PAGAR2->Serie        ) ; SERIE->(dbseek(PAGAR2->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , PAGAR2->Tipo_sub     ) ; TIPOCONT->(dbseek(PAGAR2->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(PAGAR2->Historico,60))
      qrsay ( XNIVEL++ , PAGAR2->Data_venc    )
      qrsay ( XNIVEL++ , PAGAR2->Data_prorr   )
      qrsay ( XNIVEL++ , transform(PAGAR2->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , PAGAR2->Tipo_doc     ) ; TIPO_DOC->(dbseek(PAGAR2->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , PAGAR2->Fatura       )
      qrsay ( XNIVEL++ , PAGAR2->Duplicata    )
      qrsay ( XNIVEL++ , PAGAR2->Cgm          ) ; CGM->(dbseek(PAGAR2->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , PAGAR2->Cod_Banco    ) ; BANCO->(Dbseek(PAGAR2->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , PAGAR2->Situacao     ) ; SITUA->(dbseek(PAGAR2->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , PAGAR2->Data_cont    )
      qrsay ( XNIVEL++ , left(PAGAR2->Observacao,59))


   endif

   qwait()

return

function i_retorna
   local lCONF

   lCONF := qconf("Confirma Reversao de Transferencia p/ Arquivo ?")

   if lCONF

      if ! PAGAR->(qrlock()) .and. ! PAGAR2->(qrlock())
         qmensa("N„o foi Poss¡vel Realizar Reversao !","B")
         return
      else
         PAGAR2->(qpublicfields())
         PAGAR2->(qcopyfields())
         PAGAR->(qappend())
         fDATA_PAGTO := ctod("")
         PAGAR->(qreplacefields())
         PAGAR2->(qrlock())
         PAGAR2->(dbdelete())
         PAGAR->(qunlock())
         PAGAR2->(qunlock())
      endif
   endif
return

