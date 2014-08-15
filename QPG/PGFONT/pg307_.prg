/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: CONSULTA PAGAMENTOS A VENCER
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:

//#include "inkey.ch"
//#include "setcurs.ch"
function pg307

CCUSTO->(Dbsetorder(4))
BANCO->(dbsetorder(3))

// VIEW INICIAL _____________________________________________________________

PAGAR->(dbSetFilter({|| ! PAGAR->Libera}, '! PAGAR->Libera'))
PAGAR->(Dbgotop())

PAGAR->(qview({{"Codigo/C¢digo"             ,1},;
               {"Data_venc/Vencimento"      ,2},;
               {"left(Fornec,30)/Fornecedor",10},;
               {"f_307c()/    Valor"        ,4},;
               {"f_307d()/Liberado"         ,0}},"P",;
               {NIL,"f307a",NIL,NIL},;
               NIL,"ESC/ALT-P/ALT-O/<C>onsulta"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_307b
   FORN->(dbseek(PAGAR->Cod_forn))
return left(FORN->Razao,15)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_307c
return(transform(PAGAR->Valor,"@E 9,999,999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDICACAO SE BLOQUETO FOI IMPRESSO OU NAO ____________________

function f_307d
return(iif(PAGAR->Libera,"SIM","NAO"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f307a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO = "C" ; qlbloc(06,02,"B307A","QBLOC.GLO",1) ; i_consulta() ; endif
   setcursor(nCURSOR)
return ""


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONSULTAR LANCAMENTO DE PAGAMENTO _____________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

      XNIVEL := 1
      qrsay ( XNIVEL++ , PAGAR->Codigo       )
      qrsay ( XNIVEL++ , PAGAR->Data_lanc    )
      qrsay ( XNIVEL++ , PAGAR->Cod_forn     ) ; FORN->(dbseek(PAGAR->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , PAGAR->Centro       ) ; CCUSTO->(dbseek(PAGAR->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , PAGAR->Filial       ) ; FILIAL->(dbseek(PAGAR->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , PAGAR->Data_emiss   )
      qrsay ( XNIVEL++ , PAGAR->Cod_veic     ) ; VEICULOS->(dbseek(PAGAR->Cod_veic))
      qrsay ( XNIVEL++ , left(VEICULOS->Descricao,13))
      qrsay ( XNIVEL++ , PAGAR->Especie      ) ; ESPECIE->(dbseek(PAGAR->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , PAGAR->Serie        ) ; SERIE->(dbseek(PAGAR->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , PAGAR->Tipo_sub     ) ; TIPOCONT->(dbseek(PAGAR->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(PAGAR->Historico,60))
      qrsay ( XNIVEL++ , PAGAR->Data_venc    )
      qrsay ( XNIVEL++ , PAGAR->Data_prorr   )
      qrsay ( XNIVEL++ , transform(PAGAR->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , PAGAR->Tipo_doc     ) ; TIPO_DOC->(dbseek(PAGAR->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , PAGAR->Fatura       )
      qrsay ( XNIVEL++ , PAGAR->Duplicata    )
      qrsay ( XNIVEL++ , PAGAR->Cgm          ) ; CGM->(dbseek(PAGAR->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , PAGAR->Cod_Banco    ) ; BANCO->(Dbseek(PAGAR->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , PAGAR->Situacao     ) ; SITUA->(dbseek(PAGAR->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , PAGAR->Data_cont    )
      qrsay ( XNIVEL++ , left(PAGAR->Observacao,59))

      qwait()

return
