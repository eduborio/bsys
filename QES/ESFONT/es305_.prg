/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: CONSULTA DE PRODUTOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: DEZEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function es305

PROD->(qview({{"transform(Codigo,'@R 99.99.99999')/C¢digo" ,4},;
              {"c305b()/Descri‡„o"                         ,2},;
              {"Cod_ass/C. Ass."                           ,3},;
              {"c305c()/Estoque"                           ,0},;
              {"c305tr()/Tercei"                           ,0},;
              {"c305rt()/Res. Ter"                         ,0},;
              {"c305de()/Avariado"                         ,0},;
              {"Cod_fabr/C¢d. Fabricante"                  ,5}},"P",;
              {NIL,"c305a",NIL,NIL},;
               NIL,"<ESC> para Sair / <C>onsulta"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A QUANTIDADE EM ESTOQUE __________________

function c305c

     INVENT->(dbsetorder(4))
     INVENT->(dbgotop())
     INVENT->(dbseek(right(PROD->Codigo,5)))
     cSOMA_QTD := 0
     do while ! INVENT->(eof()) .and. right(PROD->Codigo,5) == INVENT->Cod_prod
        cSOMA_QTD += INVENT->Quant_atu
        INVENT->(dbskip())
     enddo
return transf(cSOMA_QTD,"@R 999999")

function c305de
     INVENT->(dbsetorder(4))
     INVENT->(dbgotop())
     INVENT->(dbseek(right(PROD->Codigo,5)))
     cSOMA_QTD := 0
     do while ! INVENT->(eof()) .and. right(PROD->Codigo,5) == INVENT->Cod_prod
        cSOMA_QTD += INVENT->Quant_Defe
        INVENT->(dbskip())
     enddo
return transf(cSOMA_QTD,"@R 999999")

function c305tr
     INVENT->(dbsetorder(4))
     INVENT->(dbgotop())
     INVENT->(dbseek(right(PROD->Codigo,5)))
     cSOMA_QTD := 0
     do while ! INVENT->(eof()) .and. right(PROD->Codigo,5) == INVENT->Cod_prod
        cSOMA_QTD += (INVENT->Quant_ter-INVENT->Quant_res)
        INVENT->(dbskip())
     enddo
return transf(cSOMA_QTD,"@R 999999")


function c305rt
     INVENT->(dbsetorder(4))
     INVENT->(dbgotop())
     INVENT->(dbseek(right(PROD->Codigo,5)))
     cSOMA_QTD := 0
     do while ! INVENT->(eof()) .and. right(PROD->Codigo,5) == INVENT->Cod_prod
        cSOMA_QTD += INVENT->Quant_res
        INVENT->(dbskip())
     enddo
return transf(cSOMA_QTD,"@R 999999")




/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESLOCAR EM ARVORE A DESCRICAO DOS PRODUTOS __________________

function c305b
   local cDESCRICAO := PROD->Descricao + "    "
   do case
      case len(alltrim(PROD->Codigo)) == 2 ; cDESCRICAO := left(PROD->Descricao,30)+"    "
      case len(alltrim(PROD->Codigo)) == 4 ; cDESCRICAO := "  "+left(PROD->Descricao,30)+"  "
      case len(alltrim(PROD->Codigo)) == 9 ; cDESCRICAO := "    "+left(PROD->Descricao,30)
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

