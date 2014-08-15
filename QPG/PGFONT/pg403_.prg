/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: REVERSAO DE LIBERACAO
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function pg403

#include "inkey.ch"
#include "setcurs.ch"

// VIEW INICIAL _____________________________________________________________

PAG_TESO->(qview({{"Data_venc/Vcto"        ,2},;
               {"Cod_forn/Codigo"          ,6},;
               {"left(Fornec,30)/Fornecedor",9},;
               {"f_403c()/Valor Tit."      ,0},;
               {"Duplicata/Duplicata"      ,3}},"P",;
               {NIL,"f403a",NIL,NIL},;
               NIL,"ESC/ALT-P/ALT-O/<C>onsulta/<R>evers„o"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_403b
   FORN->(dbseek(PAG_TESO->Cod_forn))
return left(FORN->Razao,30)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_403c
return(transform(PAG_TESO->Valor,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f403a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO = "R" ; i_reversao()    ; return ; endif
   if cOPCAO = "C" ; qlbloc(05,02,"B403A","QBLOC.GLO",1) ; i_consulta() ; endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONSULTAR LANCAMENTO DE PAGAMENTO _____________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

      XNIVEL := 1

      qrsay ( XNIVEL++ , PAG_TESO->Codigo       )
      qrsay ( XNIVEL++ , PAG_TESO->Data_lanc    )
      qrsay ( XNIVEL++ , PAG_TESO->Cod_forn     ) ; FORN->(dbseek(PAG_TESO->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , PAG_TESO->Centro       ) ; CCUSTO->(dbseek(PAG_TESO->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , PAG_TESO->Filial       ) ; FILIAL->(dbseek(PAG_TESO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , PAG_TESO->Data_emiss   )
      qrsay ( XNIVEL++ , PAG_TESO->Cod_veic     ) ; VEICULOS->(dbseek(PAG_TESO->Cod_veic))
      qrsay ( XNIVEL++ , left(VEICULOS->Descricao,13))
      qrsay ( XNIVEL++ , PAG_TESO->Cod_eqpto    ) ; EQUIPTO->(dbseek(PAG_TESO->Cod_eqpto))
      qrsay ( XNIVEL++ , EQUIPTO->Descricao  )
      qrsay ( XNIVEL++ , PAG_TESO->Especie      ) ; ESPECIE->(dbseek(PAG_TESO->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , PAG_TESO->Serie        ) ; SERIE->(dbseek(PAG_TESO->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , PAG_TESO->Tipo_sub     ) ; TIPOCONT->(dbseek(PAG_TESO->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(PAG_TESO->Historico,60))
      qrsay ( XNIVEL++ , PAG_TESO->Data_venc    )
      qrsay ( XNIVEL++ , PAG_TESO->Data_prorr   )
      qrsay ( XNIVEL++ , transform(PAG_TESO->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , PAG_TESO->Tipo_doc     ) ; TIPO_DOC->(dbseek(PAG_TESO->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , PAG_TESO->Fatura       )
      qrsay ( XNIVEL++ , PAG_TESO->Duplicata    )
      qrsay ( XNIVEL++ , PAG_TESO->Cgm          ) ; CGM->(dbseek(PAG_TESO->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , PAG_TESO->Cod_Banco    ) ; BANCO->(Dbseek(PAG_TESO->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , PAG_TESO->Situacao     ) ; SITUA->(dbseek(PAG_TESO->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , PAG_TESO->Data_cont    )
      qrsay ( XNIVEL++ , left(PAG_TESO->Observacao,59))

      qwait()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A REVERSAO DO LANCAMENTO DA TESOURARIA ________________

static function i_reversao

   local lCONF

   lCONF := qconf("Confirma Reversao deste Lancamento ?")

   if lCONF

      qgirabarra()

      if PAG_TESO->(qrlock())

         if PAGAR->(qrlock())

            if PAGAR->(qappend())

               qmensa("Aguarde ... Revertendo Pagamento para Contas a Pagar  ...")

               replace PAGAR->Codigo     with PAG_TESO->Codigo
               replace PAGAR->Data_lanc  with PAG_TESO->Data_lanc
               replace PAGAR->Cod_forn   with PAG_TESO->Cod_forn
               replace PAGAR->Centro     with PAG_TESO->Centro
               replace PAGAR->Filial     with PAG_TESO->Filial
               replace PAGAR->Data_emiss with PAG_TESO->Data_emiss
               replace PAGAR->Especie    with PAG_TESO->Especie
               replace PAGAR->Serie      with PAG_TESO->Serie
               replace PAGAR->Tipo_Sub   with PAG_TESO->Tipo_Sub
               replace PAGAR->Historico  with PAG_TESO->Historico
               replace PAGAR->Data_venc  with PAG_TESO->Data_venc
               replace PAGAR->Data_prorr with PAG_TESO->Data_prorr
               replace PAGAR->Valor      with PAG_TESO->Valor
               replace PAGAR->Valor_liq  with PAG_TESO->Valor_liq
               replace PAGAR->Fatura     with PAG_TESO->Fatura
               replace PAGAR->Num_titulo with PAG_TESO->Num_titulo
               replace PAGAR->Cgm        with PAG_TESO->Cgm
               replace PAGAR->Cod_banco  with PAG_TESO->Cod_banco
               replace PAGAR->Situacao   with PAG_TESO->Situacao
               replace PAGAR->Dt_contabi with PAG_TESO->Dt_contabi
               replace PAGAR->Agrupado   with PAG_TESO->Agrupado
               replace PAGAR->Fornec     with PAG_TESO->Fornec

            endif

         else

           qm1()

         endif

         qmensa("")

         PAG_TESO->(dbdelete())

      endif

   endif

return
