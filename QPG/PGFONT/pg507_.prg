/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: RELATORIO DE COMPROMISSO DE PAGAMENTO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JUNHO DE 1998
// OBS........:
// ALTERACOES.:
function pg507

#include "inkey.ch"
#include "setcurs.ch"

CCUSTO->(Dbsetorder(4))
BANCO->(dbsetorder(3))

private lCONF1
private lCONF2
private cDESC
public nVAL_LIQ

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

// VIEW INICIAL _____________________________________________________________

PAGAR->(qview({{"Data_venc/Vcto"             ,2},;
               {"Cod_forn/Codigo"            ,6},;
               {"f_507b()/Fornecedor"        ,9},;
               {"Val_tit()/Valor Tit."        ,0},;
               {"Val_liq()/Valor Liq."        ,0},;
               {"Duplicata/Duplicata"        ,3}},"P",;
               {NIL,"f507a",NIL,NIL},;
               NIL,"ESC/ALT-P/ALT-O/<C>onsulta/<I>mprime Compromisso de Pagamento"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR ______________________________________

function f_507b
   FORN->(dbseek(PAGAR->Cod_forn))
return left(FORN->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function Val_tit
return(transform(PAGAR->Valor,"@E 9999999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function Val_liq
return(transform(PAGAR->Valor_liq,"@E 9999999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f507a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(06,02,"B507A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
      i_edicao()
   endif

   if cOPCAO $ "I"
      i_impressao()
   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local aEDICAO := {}
   local bESCAPE := {||empty(fFIXO).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   fDATA_LANC := XDATASYS

   // MONTA DADOS NA TELA ___________________________________________________

   if ! cOPCAO $ "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PAGAR->Codigo       )
      qrsay ( XNIVEL++ , qabrev(PAGAR->Fixo,"SN", {"Sim","N„o"}))
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
      qrsay ( XNIVEL++ , PAGAR->Cod_eqpto    ) ; EQUIPTO->(dbseek(PAGAR->Cod_eqpto))
      qrsay ( XNIVEL++ , EQUIPTO->Descricao  )
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

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O COMPROMISSO DE PAGAMENTO __________________________
function i_impressao

   local cTITULO := "COMPROMISSO DE PAGAMENTO"

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")
   
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      qcabecprn(cTITULO,80)
   endif

   @ prow()+3,00  say "Fornecedor.....: " + PAGAR->Cod_forn

   FORN->(dbseek(PAGAR->Cod_forn))

   @ prow()  ,30  say FORN->Razao
   @ prow()+2,00  say "Nr. NF/Fatura..: " + PAGAR->Fatura
   @ prow()  ,40  say "Nr. Duplicata..: " + PAGAR->Num_titulo
   @ prow()+2,00  say "Data Vencimento: " + dtoc(PAGAR->Data_venc)
   @ prow()  ,40  say "Nr. Parcela....: " + PAGAR->Num_titulo
   @ prow()+2,00  say "Valor..........: " + transform(PAGAR->Valor,"@r 9,999,999,999.99")
   @ prow()+2,00  say "Data da Liberacao...:  ______/______/__________"

   @ prow()+2,00  say replicate("=",80)
   @ prow()+2,00  say "Conferencia....: ______/______/_________"
   @ prow()+2,00  say "Assinatura.....: ______________________________________________________________"

   @ prow()+3,00  say replicate("=",80)
   @ prow()+2,00  say "Data Pagto.....: ______/______/_________"
   @ prow()+2,00  say "Autorizacao....: ______________________________________________________________"
   @ prow()+3,00  say replicate("=",80)

   qstopprn()

return
