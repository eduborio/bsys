/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: REVERSAO DE LIBERACAO
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function rb402

#include "inkey.ch"
#include "setcurs.ch"

fu_abre_cli1()

BANCO->(Dbsetorder(3))
SERIE->(Dbsetorder(3))
ESPECIE->(Dbsetorder(3))
CGM->(Dbsetorder(2))

// VIEW INICIAL _____________________________________________________________

REC_TESO->(qview({{"Data_venc/Vcto"          ,0},;
                 {"Cod_cli/Codigo"            ,0},;
                 {"f_402b()/Cliente"          ,0},;
                 {"f_val5()/Valor Tit."       ,0},;
                 {"fval6()/Valor Liq."        ,0},;
                 {"Fatura/Documento"          ,0}},"P",;
                 {NIL,"f402a",NIL,NIL},;
                 NIL,"ESC/ALT-P/ALT-O/<C>onsulta/<R>evers„o"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_402b
   CLI1->(dbseek(REC_TESO->Cod_cli))
return left(CLI1->Razao,28)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_val5
return(transform(REC_TESO->Valor,"@E 9999999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function fval6
return(transform(REC_TESO->Valor_liq,"@E 9999999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f402a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO = "R" ; i_reversao()    ; return ; endif
   if cOPCAO = "C" ; qlbloc(05,02,"B402A","QBLOC.GLO",1) ; i_consulta() ; endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONSULTAR LANCAMENTO DE PAGAMENTO _____________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

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

      qwait()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A REVERSAO DO LANCAMENTO DA TESOURARIA ________________

static function i_reversao

   local lCONF

   lCONF := qconf("Confirma Reversao deste Lancamento ?")

   if lCONF

      qgirabarra()

      if REC_TESO->(qrlock())

         if RECEBER->(qrlock()) .and. RECEBER->(qappend())

               qmensa("Aguarde ... Revertendo Lancamento para Contas a Receber ...")

               replace RECEBER->Codigo       with REC_TESO->Codigo
               replace RECEBER->Data_lanc    with REC_TESO->Data_lanc
               replace RECEBER->Cod_cli      with REC_TESO->Cod_cli
               replace RECEBER->Centro       with REC_TESO->Centro
               replace RECEBER->Filial       with REC_TESO->Filial
               replace RECEBER->Data_emiss   with REC_TESO->Data_emiss
               replace RECEBER->Especie      with REC_TESO->Especie
               replace RECEBER->Serie        with REC_TESO->Serie
               replace RECEBER->Tipo_sub     with REC_TESO->Tipo_sub
               replace RECEBER->Historico    with REC_TESO->Historico
               replace RECEBER->Data_venc    with REC_TESO->Data_venc
               replace RECEBER->Data_prorr   with REC_TESO->Data_prorr
               replace RECEBER->Valor        with REC_TESO->Valor
               replace RECEBER->Valor_liq    with REC_TESO->Valor_liq
               replace RECEBER->Fatura       with REC_TESO->Fatura
               replace RECEBER->Num_titulo   with REC_TESO->Num_titulo
               replace RECEBER->Cgm          with REC_TESO->Cgm
               replace RECEBER->Cod_banco    with REC_TESO->Cod_banco
               replace RECEBER->Situacao     with REC_TESO->Situacao
               replace RECEBER->Vendedor     with REC_TESO->Vendedor
               replace RECEBER->Dt_contabi   with REC_TESO->Dt_contabi
               replace RECEBER->Cnab         with REC_TESO->Cnab
               replace RECEBER->Num_lote     with REC_TESO->Num_lote
               replace RECEBER->Form_pgto    with REC_TESO->Form_pgto
               replace RECEBER->Desc_valor   with REC_TESO->Desc_valor
               replace RECEBER->Indice       with REC_TESO->Indice
               replace RECEBER->Periodo      with REC_TESO->Periodo
               replace RECEBER->Fatura       with REC_TESO->Nota_fisc
               replace RECEBER->Duplicata    with REC_TESO->Duplicata
               replace RECEBER->Valor_1      with REC_TESO->Valor_1
               replace RECEBER->Valor_1      with REC_TESO->Valor_ded
               replace RECEBER->Valor_ind    with REC_TESO->Valor_ind
               replace RECEBER->Valor_cor    with REC_TESO->Valor_cor
               replace RECEBER->Cod_cli      with REC_TESO->Grupo_p
               replace RECEBER->Data_cont    with REC_TESO->Data_cont
               replace RECEBER->Libera_mat   with REC_TESO->Libera_mat
               replace RECEBER->Libera_con   with REC_TESO->Libera_con
               replace RECEBER->Libera_fin   with REC_TESO->Libera_fin
               replace RECEBER->Fatura       with REC_TESO->Doc_interf
               replace RECEBER->Tipo_doc     with REC_TESO->Tipo_doc
               replace RECEBER->Data_venc    with REC_TESO->Data_vhis
               replace RECEBER->Codbanco     with REC_TESO->Codbanco
               replace RECEBER->Bco_porta    with REC_TESO->Bco_porta
               replace RECEBER->Forma_port   with REC_TESO->Forma_port
               replace RECEBER->Data         with REC_TESO->Data
               replace RECEBER->Status_tit   with REC_TESO->Status_tit
               replace RECEBER->Data_pagto   with ctod("")
               replace RECEBER->Cliente      with REC_TESO->Cliente
               replace RECEBER->Setor        with REC_TESO->Setor


         else

           qm1()

         endif

         qmensa("")
         if REC_TESO->(Qrlock())
            REC_TESO->(dbdelete())
            REC_TESO->(qunlock())
         endif

      endif

   endif
return
