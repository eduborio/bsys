/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: TABELA DE PRECOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
//

function cl102
PROD->(Dbsetorder(4))

PROD->(qview({{"left(Descricao,20)/Produto"                        ,2},;
             {"transform(Preco_unit, '@e 999,999.99')/Pre‡o Fabr." ,0},;
             {"transform(Desconto, '@e 99.99')/Desconto"           ,0},;
             {"transform(Preco_cust, '@e 999,999.99')/Pre‡o Custo" ,0},;
             {"transform(Preco_cons, '@e 999,999.99')/Pre‡o Cons." ,0}},"P",;
             {NIL,"c102a",NIL,NIL},;
             NIL,"<C>onsulta/<R>eajuste/<A>lterar"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c102a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO == "R", i_reaj(),)
   if cOPCAO == "A" ; i_edita_preco() ; endif

   if cOPCAO == "C"
      qlbloc(10,5,"B102A","QBLOC.GLO",1)
      i_edicao()
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

      qrsay ( XNIVEL++ , right(PROD->Codigo,5)              )
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)           )
      qrsay ( XNIVEL++ , PROD->Preco_unit , "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->Desconto   , "@E 99.99"      )
      qrsay ( XNIVEL++ , PROD->Preco_cust , "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->Preco_cons , "@E 999,999.99" )

      qwait()

   endif

return

/////////////////////////////////////////////////////////////////////////////
// REAJUSTE DE TABELAS ______________________________________________________

static function i_reaj

   local cTAB   := space(4)
   local nFATOR := 0
   local nCONT  := PROD->(recc())

   qlbloc(10,5,"B102B","QBLOC.GLO",1)

   XNIVEL := 1

   if lastkey() == 27 ; return ; endif

   qgetx(-1,0,@nFATOR,"@E 999.99")

   if qconf("Confirma reajuste desta tabela ?")

      qmensa("Reajustando, aguarde...")

      do while ! PROD->(eof())

         qsay(24,70,nCONT--)

         if PROD->(qrlock())
            replace PROD->Preco_unit with PROD->Preco_unit * nFATOR
            replace PROD->Preco_cust with ( PROD->Preco_unit - (PROD->Preco_unit * (PROD->Desconto/100) ) )
            replace PROD->Preco_cons with (PROD->Preco_unit + (PROD->Preco_unit * 0.4285) )
            PROD->(qunlock())
         endif

         PROD->(dbskip())

      enddo

      PROD->(dbgotop())

   endif

return


static function i_edita_preco

   local nPRECO_FBA
   local nDESCONTOS
   local nPRECO
   local nPRECO_CON

   nPRECO_FRA := PROD->Preco_unit
   nDESCONTOS := PROD->Desconto
   nPRECO     := PROD->Preco_cust
   nPRECO_CON := PROD->Preco_cons

   Linha:=Row()

   qgetx(Linha,28,@nPRECO_FRA,"@e 999,999.99")
   qgetx(Linha,40,@nDESCONTOS,"@e 99.99")
   qgetx(Linha,49,@nPRECO    ,"@e 999,999.99")
   qgetx(Linha,61,@nPRECO_CON,"@e 999,999.99")

   if qconf("Confirma a altera‡„o destes valores ?")
      if PROD->(qrlock())
         replace PROD->Preco_unit with nPRECO_FRA
         replace PROD->Desconto   with nDESCONTOS
         replace PROD->Preco_cust with nPRECO
         replace PROD->Preco_cons with nPRECO_CON
      else
         qm2()
      endif
   endif

return

