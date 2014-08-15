/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE PONTO DE REPOSICAO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCIANO DA SILVA GORSKI
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:
function es108

PROD->(qview({{"Codigo/C¢digo"               ,1},;
              {"Descricao/Descricao"         ,2},;
              {"c108c()/Estoque"             ,0}},"P",;
              {NIL,"c108a",NIL,NIL},;
              NIL,"<ESC>-Sai / <S>eleciona Produto para manuten‡Æo"))


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A QUANTIDADE EM ESTOQUE __________________

function c108c

     INVENT->(dbsetorder(4))
     INVENT->(dbgotop())
     INVENT->(dbseek(right(PROD->Codigo,5)))
     cSOMA_QTD := 0
     do while ! INVENT->(eof()) .and. right(PROD->Codigo,5) == INVENT->Cod_prod
        cSOMA_QTD += INVENT->Quant_atu
        INVENT->(dbskip())
     enddo
return cSOMA_QTD

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c108a

//   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   qlbloc(07,06,"B108A","QBLOC.GLO",1)

   if cOPCAO $ "S"
      if Right(PROD->Codigo,5) == "     "; Return ""; Endif
      qsay ( 08,17, Right(PROD->Codigo,5)    )
      qsay ( 08,25, left(PROD->Descricao,32) )
      LOTES->(dbsetorder(2))
      if ! LOTES->(dbseek(Right(PROD->CODIGO,5)))
         qmensa("Produto nÆo existe no Invent rio, N§ de Lotes nÆo encontrado...","B")
         Return ""
      Endif
      xViewColor:= "N/W"
      LOTES->(dbsetorder(1))
      LOTES->(dbSetFilter({|| Produto == Right(PROD->CODIGO,5) }, 'Produto == Right(PROD->CODIGO,5)'))
      nSOMA_QTD := 0
      Do While LOTES->Produto == Right(PROD->CODIGO,5)
         qgirabarra()
         nSOMA_QTD += LOTES->Quantidade
         LOTES->(dbskip())
      Enddo
      LOTES->(dbgotop())
      qsay ( 20,10,"Quantidade Total de itens.......> "+Transform(nSOMA_QTD,"@R 999999.99999") )

      LOTES->(qview({{"Produto/C¢d.Prod.Assoc."   ,1},;
                    {"Filial/Filial-Associada"    ,0},;
                    {"Quantidade/Quantidade"      ,0},;
                    {"Num_lote/N§ de lote"        ,0}},"09071971",;
                    {NIL,NIL,NIL,NIL             },;
                    NIL,"<ESC>-Sai"))

   endif

//   setcursor(nCURSOR)

xViewColor:= "N/BG"

return ""
