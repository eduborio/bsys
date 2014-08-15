
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: CONSULTA DE PRODUTOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: DEZEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function ts305

PROD->(qview({{"transform(Codigo,'@R 99.99.99999')/C¢digo" ,1},;
              {"c305b()/Descri‡„o"                         ,2},;
              {"Cod_ass/C. Ass."                           ,3},;
              {"Cod_fabr/C¢d. Fabricante"                  ,5}},"P",;
              {NIL,"c305a",NIL,NIL},;
               NIL,"<ESC> para Sair / <C>onsulta"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESLOCAR EM ARVORE A DESCRICAO DOS PRODUTOS __________________

function c305b
   local cDESCRICAO := PROD->Descricao + "    "
   do case
      case len(alltrim(PROD->Codigo)) == 2 ; cDESCRICAO := left(PROD->Descricao,35)+"    "
      case len(alltrim(PROD->Codigo)) == 4 ; cDESCRICAO := "  "+left(PROD->Descricao,35)+"  "
      case len(alltrim(PROD->Codigo)) == 9 ; cDESCRICAO := "    "+left(PROD->Descricao,35)
   endcase
return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c305a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "C"
      qlbloc(09,07,"B305A","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   private nTIPO := 0

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PROD->Codigo , "@R 99.99.99999" )
      qrsay ( XNIVEL++ , PROD->Cod_ass   )
      qrsay ( XNIVEL++ , PROD->Cod_fabr  )
      qrsay ( XNIVEL++ , PROD->Marca     )
      qrsay ( XNIVEL++ , PROD->Descricao )
      qrsay ( XNIVEL++ , qabrev(PROD->Prod_iss,"SN",{"Sim","N„o"}))
      qrsay ( XNIVEL++ , transform(PROD->Ipi,"@E 99.99") )
      qrsay ( XNIVEL++ , PROD->Unidade   ) ; UNIDADE->(dbseek(PROD->Unidade))
      qrsay ( XNIVEL++ , UNIDADE->Sigla  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

return

