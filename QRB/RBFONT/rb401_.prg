/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: LIBERACAO DE RECEBIMENTOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function rb401

#include "inkey.ch"
#include "setcurs.ch"

fu_abre_cli1()

// VIEW INICIAL _____________________________________________________________

RECEBER->(qview({{"Marcacao/M"                ,0},;
                 {"Data_venc/Vcto"            ,2},;
                 {"left(Cliente,20)/Cliente"  ,8},;
                 {"fval3()/Valor Tit."        ,0},;
                 {"fval4()/Valor Liq."        ,6},;
                 {"Fatura/Documento"          ,11}},"P",;
                 {NIL,"f401a",NIL,NIL},;
                 NIL,"<C>onsulta/<M>arca ou desmarca/<L>ibera/Pe<S>quisa valor"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE _________________________________________

function f_401b
   CLI1->(dbseek(RECEBER->Cod_cli))
return left(CLI1->Razao,20)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function fval3
return(transform(RECEBER->Valor,"@E 9999999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function fval4
return(transform(RECEBER->Valor_liq,"@E 9999999.99"))
//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_401c
return(transform(RECEBER->Valor,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f401a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "M" ; i_marca()  ; return ; endif
   if cOPCAO == "S" ; i_pesq_nota()  ; return ; endif
   if cOPCAO == "L" ; i_libera() ; return ; endif
   if cOPCAO == "C" ; qlbloc(05,02,"B401A","QBLOC.GLO",1) ; i_consulta() ; endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONSULTAR LANCAMENTO DE PAGAMENTO _____________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO ==  "C"
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
      qrsay ( XNIVEL++ , RECEBER->Tipo_sub     ) ; TIPOCONT->(dbseek(RECEBER->Tipo_sub) )
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

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A MARCACAO PARA LIBERACAO ______________________________

static function i_marca
   if RECEBER->(qrlock())
      if RECEBER->Marcacao == "*"
         replace RECEBER->Marcacao with " "
      else
         replace RECEBER->Marcacao with "*"
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A LIBERACAO DO LANCAMENTO PARA TESOURARIA _____________

static function i_libera

   local lCONF

   lCONF := qconf("Confirma Liberacao deste(s) Lancamento(s) ?")

   if lCONF

      if ! RECEBER->(qflock()) .and. ! SH_RECEB->(qflock())
         qmensa("N„o foi Poss¡vel Liberar para Tesouraria !","B")
         return
      endif

      RECEBER->(dbgotop())

      do while ! RECEBER->(eof())

         qgirabarra()

         if RECEBER->Marcacao == "*"

            if SH_RECEB->(qappend())

               qmensa("Aguarde ... Liberando Recebimento para Tesouraria ...")

               replace SH_RECEB->Codigo     with RECEBER->Codigo
               replace SH_RECEB->Data_lanc  with RECEBER->Data_lanc
               replace SH_RECEB->Cod_cli    with RECEBER->Cod_cli
               replace SH_RECEB->Centro     with RECEBER->Centro
               replace SH_RECEB->Filial     with RECEBER->Filial
               replace SH_RECEB->Data_emiss with RECEBER->Data_emiss
               replace SH_RECEB->Especie    with RECEBER->Especie
               replace SH_RECEB->Serie      with RECEBER->Serie
               if empty(CONFIG->Remoplast)
                  replace SH_RECEB->Tipo_sub   with RECEBER->Tipo_sub
               else
                  replace SH_RECEB->Tipo_sub   with "010001"
               endif
               replace SH_RECEB->Historico  with RECEBER->Historico
               replace SH_RECEB->Data_venc  with RECEBER->Data_venc
               replace SH_RECEB->Data_prorr with RECEBER->Data_prorr
               replace SH_RECEB->Valor      with RECEBER->Valor
               replace SH_RECEB->Valor_liq  with RECEBER->Valor_liq
               replace SH_RECEB->Fatura     with RECEBER->Fatura
               replace SH_RECEB->Num_titulo with RECEBER->Num_titulo
               replace SH_RECEB->Cgm        with RECEBER->Cgm
               replace SH_RECEB->Situacao   with RECEBER->Situacao
               replace SH_RECEB->Vendedor   with RECEBER->Vendedor
               replace SH_RECEB->Dt_contabi with RECEBER->Data_cont
               replace SH_RECEB->Cnab       with RECEBER->Cnab
               replace SH_RECEB->Num_lote   with RECEBER->Num_lote
               replace SH_RECEB->Form_pgto  with RECEBER->Form_pgto
               replace SH_RECEB->Desc_valor with RECEBER->Desc_valor
               replace SH_RECEB->Indice     with "01"
               replace SH_RECEB->Periodo    with "C"
               replace SH_RECEB->Nota_fisc  with subs(RECEBER->Fatura,2,8)
               replace SH_RECEB->Duplicata  with RECEBER->Duplicata
               replace SH_RECEB->Valor_1    with RECEBER->Valor_1
               replace SH_RECEB->Valor_ded  with RECEBER->Valor_1
               replace SH_RECEB->Valor_ind  with 1
               replace SH_RECEB->Valor_cor  with 1
               replace SH_RECEB->Grupo_p    with RECEBER->Cod_cli
               replace SH_RECEB->Data_cont  with RECEBER->Data_cont
               replace SH_RECEB->Libera_mat with RECEBER->Libera_mat
               replace SH_RECEB->Libera_con with RECEBER->Libera_con
               replace SH_RECEB->Libera_fin with XUSRIDT+dtoc(date())+time()
               replace SH_RECEB->Doc_interf with RECEBER->Fatura
               replace SH_RECEB->Tipo_doc   with RECEBER->Tipo_doc
               replace SH_RECEB->Data_vhis  with RECEBER->Data_venc
               replace SH_RECEB->Bco_porta  with RECEBER->Bco_porta
               replace SH_RECEB->Cliente    with RECEBER->Cliente
               replace SH_RECEB->Setor      with RECEBER->Setor
               replace SH_RECEB->Observacao with RECEBER->Observacao
               if RECEBER->(qrlock())
                  RECEBER->(dbdelete())
                  RECEBER->(qunlock())
               endif

            else

              qm1()

            endif

            qmensa("")

         endif

         RECEBER->(dbskip())

      enddo

      RECEBER->(qunlock())
      SH_RECEB->(qunlock())

   endif

   RECEBER->(dbgotop())

return


static function i_pesq_nota

   local nValor  := 0
   local nIndice := RECEBER->(indexord())
   local nRec    := RECEBER->(recno())

   qmensa("Digite o valor da Fatura p/ pesquisa:          ")
   qgetx(24,48,@nValor ,"@E 9,999,999.99")


   RECEBER->(dbsetorder(6))
   if ! RECEBER->(dbseek(nValor))
      RECEBER->(dbsetorder(nIndice))
      qmensa("Fatura n„o encontrada !","BL")
      RECEBER->(dbgoto(nREC))
      return
   endif
return

