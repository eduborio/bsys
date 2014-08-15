/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: TABELA DE PONTOS por Produto
// ANALISTA...: Eduardo Borio
// PROGRAMADOR: Eduardo Borio
// INICIO.....:
// OBS........:
// ALTERACOES.:

function cl122
PROD->(Dbsetfilter({|| right(Codigo,5) != "     "}))

PROD->(qview({{"Cod_ass/Cod."                                     ,3},;
             {"left(Cod_fabr,10)/Fabr."                           ,5},;
             {"left(Descricao,35)/Produto"                        ,2},;
             {"Marca/Colecao"                                     ,0},;
             {"transform(Pontos, '@R 99')/Pontos" ,0}},"P",;
             {NIL,"c122a",NIL,NIL},;
             NIL,"<A>lterar"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c122a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "A" ; i_edita_preco() ; endif

   if cOPCAO == "C"
//      qlbloc(10,5,"B102A","QBLOC.GLO",1)
//      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"

      XNIVEL := 1

//      qrsay ( XNIVEL++ , right(PROD->Codigo,5)              )
//      qrsay ( XNIVEL++ , left(PROD->Descricao,40)           )
//      qrsay ( XNIVEL++ , PROD->Preco_unit , "@E 999,999.99" )
//      qrsay ( XNIVEL++ , PROD->Desconto   , "@E 99.99"      )
//      qrsay ( XNIVEL++ , PROD->Preco_cust , "@E 999,999.99" )
//      qrsay ( XNIVEL++ , PROD->Preco_cons , "@E 999,999.99" )

      qwait()

   endif

return

static function i_edita_preco

   local nPONTOS

   nPONTOS    := PROD->Pontos

   Linha:=Row()

   qgetx(Linha,70,@nPONTOS,"@R 99")

   if qconf("Confirma a altera‡„o ?")
      if PROD->(qrlock())
         replace PROD->Pontos with nPONTOS
      else
         qm2()
      endif
   endif

return

