/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: RELATORIO DE AUTORIZACAO DE PAGAEMENTO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MAIO DE 1997
// OBS........:
// ALTERACOES.:
function pg503

//#include "inkey.ch"
//#include "setcurs.ch"

//fu_abre_tiporpc()
CCUSTO->(Dbsetorder(4))

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private dDATA_VENC := ctod("")

// VIEW INICIAL _____________________________________________________________

PAGAR->(qview({{"Codigo/C¢digo"             ,1},;
               {"Data_venc/Vencimento"      ,2},;
               {"f_503b()/Fornecedor"       ,3},;
               {"f_503c()/    Valor"        ,4},;
               {"Num_titulo/N£m. Doc."      ,5}},"P",;
               {NIL,"f503a",NIL,NIL},;
                NIL,"ESC/ALT-P/ALT-O/<C>on/Im<P>rimir"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_503b
   FORN->(dbseek(PAGAR->Cod_forn))
return left(FORN->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_503c
return(transform(PAGAR->Valor,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f503a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "C"
      qlbloc(06,02,"B503A","QBLOC.GLO",1)
      i_consulta()
   endif

   if cOPCAO = "P" ; i_imprime() ; endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   local lCONF
   local aEDICAO := {}

   // MONTA DADOS NA TELA ___________________________________________________

      XNIVEL := 1
      qrsay ( XNIVEL++ , PAGAR->Codigo       )
      qrsay ( XNIVEL++ , PAGAR->Data_lanc    )
      qrsay ( XNIVEL++ , transform(PAGAR->Ped_compra, "@R 99999/99"))
      qrsay ( XNIVEL++ , PAGAR->C_custo      ) ; CCUSTO->(dbseek(PAGAR->C_custo))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , PAGAR->Filial       ) ; FILIAL->(dbseek(PAGAR->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , PAGAR->Docto        )
      qrsay ( XNIVEL++ , PAGAR->Data_emiss   )
      qrsay ( XNIVEL++ , PAGAR->Especie      ) ; ESPECIE->(dbseek(PAGAR->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , PAGAR->Serie        ) ; SERIE->(dbseek(PAGAR->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , PAGAR->Tipo_sub     ) ; TIPOCONT->(dbseek(PAGAR->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPORPC->Descricao,20))
      qrsay ( XNIVEL++ , PAGAR->Historico    )
      qrsay ( XNIVEL++ , PAGAR->Cod_forn     ) ; FORN->(dbseek(PAGAR->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , PAGAR->Cod_veic     ) ; VEICULOS->(dbseek(PAGAR->Cod_veic))
      qrsay ( XNIVEL++ , VEICULOS->Descricao )
      qrsay ( XNIVEL++ , VEICULOS->Placa     )
      qrsay ( XNIVEL++ , PAGAR->Data_venc    )
      qrsay ( XNIVEL++ , PAGAR->Data_prorr   )
      qrsay ( XNIVEL++ , transform(PAGAR->Valor,"@E 9,999,999.99" ))
      qrsay ( XNIVEL++ , transform(PAGAR->Multa_per,"@E 999" ))
      qrsay ( XNIVEL++ , transform(PAGAR->Multa_val,"@E 9,999,999.99" ))
      qrsay ( XNIVEL++ , transform(PAGAR->Juros_per,"@E 999" ))
      qrsay ( XNIVEL++ , transform(PAGAR->Juros_val,"@E 9,999,999.99" ))
      qrsay ( XNIVEL++ , PAGAR->Fatura       )
      qrsay ( XNIVEL++ , PAGAR->Num_titulo   )
      qrsay ( XNIVEL++ , PAGAR->Praca        ) ; CGM->(dbseek(PAGAR->Praca))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40  ))
      qrsay ( XNIVEL++ , PAGAR->Banco        )
      qrsay ( XNIVEL++ , PAGAR->Situacao     ) ; SITUA->(dbseek(PAGAR->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , PAGAR->Dt_contabi   )

      qwait()

return


function i_imprime
return
