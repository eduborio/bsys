/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: CONSULTA DE PAGAMENTOS LIBERADOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function ts306

//#include "inkey.ch"
//#include "setcurs.ch"

BANCO->(dbsetorder(3))
CCUSTO->(Dbsetorder(4))

// VIEW INICIAL _____________________________________________________________

PAG_TESO->(qview({{"Codigo/C¢digo"             ,1},;
               {"Data_venc/Vencimento"         ,2},;
               {"left(Fornec,22)/Fornecedor"   ,6},;
               {"f_306c()/    Valor"           ,4},;
               {"Fatura/Fatura"                ,5}},"P",;
               {NIL,"f306a",NIL,NIL},;
                NIL,"ESC/ALT-P/ALT-O/<C>onsulta"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_306b
   FORN->(dbseek(PAG_TESO->Cod_forn))
return left(FORN->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_306c
return(transform(PAG_TESO->Valor,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f306a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "C"
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

   if cOPCAO == "C"
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

   endif

   qwait()

return
