/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: CONSULTA DE EQUIPAMENTOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: DEZEMBRO DE 1996
// OBS........:
// ALTERACOES.:

//fu_abre_ccusto()
function es304

EQUIPTO->(qview({{"Codigo/C¢digo"          ,1},;
                 {"Descricao/Descri‡„o"    ,2},;
                 {"Fabricante/Fabricante"  ,0},;
                 {"Modelo/Modelo"          ,0},;
                 {"Ano/Ano"                ,0}},"P",;
                 {NIL,"c304a",NIL,NIL},;
                  NIL,"<ESC> para Sair / <C>onsulta"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c304a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "C"
      qlbloc(10,01,"B304A","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , EQUIPTO->Codigo    )
      qrsay ( XNIVEL++ , EQUIPTO->Descricao )
      qrsay ( XNIVEL++ , EQUIPTO->Fabricante)
      qrsay ( XNIVEL++ , EQUIPTO->Modelo    )
      qrsay ( XNIVEL++ , EQUIPTO->Ano       )
      qrsay ( XNIVEL++ , EQUIPTO->Nr_serie  )
      qrsay ( XNIVEL++ , EQUIPTO->Patrimonio)
      qrsay ( XNIVEL++ , EQUIPTO->Centro    ) ; CCUSTO->(dbseek(EQUIPTO->Centro))
      qrsay ( XNIVEL++ , CCUSTO->Descricao  )
      qrsay ( XNIVEL++ , EQUIPTO->Filial    ) ; FILIAL->(dbseek(EQUIPTO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , EQUIPTO->Cod_segur ) ; SEGURA->(dbseek(EQUIPTO->Cod_segur))
      qrsay ( XNIVEL++ , left(SEGURA->Nome,14))
      qrsay ( XNIVEL++ , transform(EQUIPTO->Val_franq,"@E 999,999,999.99" ))
      qrsay ( XNIVEL++ , EQUIPTO->Data_comp )
      qrsay ( XNIVEL++ , EQUIPTO->Doc_comp  )
      qrsay ( XNIVEL++ , transform(EQUIPTO->Val_comp,"@E 999,999,999.99"))
      qrsay ( XNIVEL++ , EQUIPTO->Observacao)
   endif

   if cOPCAO == "C" ; qwait()      ; return ; endif

return

