/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: CONSULTA AGRUPAMENTO DE PAGAMENTOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:

//#include "inkey.ch"
function pg309

private nVALOR := 0

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS AGRUPAMENTOS _____________________________________________

AGRUPA->(qview({{"Codigo/N£mero"        ,1},;
                {"Num_fatura/Fatura"    ,2},;
                 {"Data_venc/Vencimento",3}},"P",;
                 {NIL,"i_309a",NIL,NIL},;
                  NIL,"<ESC>-Sai/<C>onsulta"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_309a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(5,2,"B309A","QBLOC.GLO")
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO == "C"

      XNIVEL := 1

      qsay ( 06,13 , AGRUPA->Codigo           )
      qsay ( 06,40 , AGRUPA->Num_fatura       )
      qsay ( 06,67 , dtoc(AGRUPA->Data_venc)  )

   endif

   PAGAR->(DbSetorder(6))
   PAGAR->(dbSetFilter({|| Agrupado == AGRUPA->Codigo}, 'Agrupado == AGRUPA->Codigo'))
   PAGAR->(Dbgotop())

   do while ! PAGAR->(eof())
      nVALOR += PAGAR->Valor
      PAGAR->(Dbskip())
   enddo

   PAGAR->(Dbgotop())

   qsay(22,16,transform(nVALOR, "@e 99,999,999.99"))

   PAGAR->(qview({{"Codigo/C¢digo"             ,1},;
                  {"Data_venc/Vencimento"      ,2},;
                  {"f_309a()/Fornecedor"       ,3},;
                  {"f_309b()/   Valor"         ,4},;
                  {"Num_titulo/N£m. Doc."      ,5},;
                  {"f_309c()/Agrup."           ,0}},;
                  "08042074S",;
                  {NIL,NIL,NIL,NIL},;
                  NIL,"ESC - Retorna"))

   PAGAR->(Dbsetfilter())

return

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_309a
   FORN->(dbseek(PAGAR->Cod_forn))
return left(FORN->Razao,10)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_309b
return(transform(PAGAR->Valor,"@E 9,999,999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM SE AGRUPADO OU NAO __________________________________

function f_309c

   local cSITUACAO:=space(3)

   if ! empty(PAGAR->Agrupado)
      cSITUACAO := "SIM"
   else
      cSITUACAO := "NAO"
   endif

return cSITUACAO

