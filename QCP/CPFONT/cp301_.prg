/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: CONSULTA ORDENS DE COMPRA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function cp301

PROD->(dbsetorder(4))
CCUSTO->(dbsetorder(4))

ORDEM->(qview({{"Codigo/C¢digo"                            ,1},;
              {"Data/Data"                                 ,2},;
              {"c301a()/Centro"                            ,0},;
              {"c301b()/Filial"                            ,0},;
              {"c301c()/Pedido" ,0}},"P",;
              {NIL,"c301d",NIL,NIL},;
               NIL,"<ESC>-Sai/<C>onsulta"))


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DA FILIAL _______________________________________________

function c301a
   local cDescricao := space(25)
   if CCUSTO->(dbseek(ORDEM->Filial))
      cDescricao := left(CCUSTO->Descricao,22)
   endif
return cDescricao

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function  c301b
   local cDescricao := space(25)
   if FILIAL->(dbseek(ORDEM->Filial))
      cDescricao := left(FILIAL->Razao,22)
   endif
return cDescricao

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO NUMERO DO PEDIDO  ____________________________________

function c301c
return transform(ORDEM->Pedido,"@R 99999/9999")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c301d

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(5,0,"B301A","QBLOC.GLO",1)
      i_edicao()
   endif

   setcursor(nCURSOR)

   ORDEM->(dbgotop())

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.cOPCAO=="C".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"

      XNIVEL := 1

      qsay ( 06,23 , ORDEM->Codigo       )

      qsay ( 06,68 , ORDEM->Data         )

      qsay ( 07,23 , ORDEM->Filial       ) ; FILIAL->(dbseek(ORDEM->Filial))
      qsay ( 07,36 , left(FILIAL->Razao,25))

      qsay ( 08,23 , ORDEM->Centro       ) ; CCUSTO->(dbseek(ORDEM->Centro))
      qsay ( 08,36 , CCUSTO->Descricao   )


      qsay ( 09,13 , ORDEM->Veiculo      ) ; VEICULOS->(dbseek(ORDEM->Veiculo))
      qsay ( 09,19 , VEICULOS->Descricao )

      qsay ( 09,50 , ORDEM->Equipament   ) ; EQUIPTO->(dbseek(ORDEM->Equipament))
      qsay ( 09,56 , left(EQUIPTO->Descricao,20)  )

      qsay ( 10,23 , transform(ORDEM->Pedido, "@R 99999/9999" ))
      qsay ( 10,45 , ORDEM->Funcionari   ) ; FUN->(dbseek(ORDEM->Funcionari))
      qsay ( 10,52 , left(FUN->Nome,20)  )

      if cOPCAO == "C"
         i_atu_item()
      endif

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

   endcase


return .T.



////////////////////////////////////////////////////////////////////////////////////
static function i_atu_item

setcolor("W/B")

ITENS_OC->(qview({{"Produto/Cod."                                      ,2},;
                  {"f301a()/Descri‡„o"                                 ,0},;
                  {"transform(Quantidade,'@E 9999.99999')/Quant."      ,0}},;
                  "11002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITENS_OC->Cod_ord == ORDEM->Codigo",{||f301top()},{||f301bot()}},;
                 "<ESC> para sair" ))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f301top
   ITENS_OC->(dbsetorder(1))
   ITENS_OC->(dbseek(ORDEM->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f301bot
   ITENS_OC->(dbsetorder(1))
   ITENS_OC->(qseekn(ORDEM->Codigo))
return
/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f301a

   local cDESCRICAO := space(25)

   if ! empty(ITENS_OC->Produto)
      PROD->(dbseek(ITENS_OC->Produto))
      cDESCRICAO := left(PROD->Descricao,25)
   endif

return cDESCRICAO

