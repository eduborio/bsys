/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: TABELA DE PRECOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:

function cl107
PROD->(Dbsetorder(4))
UNIDADE->(dbsetorder(1))

PROD->(qview({{"left(Descricao,29)/Produto"                          ,2},;
             {"f107b()/UN. "                                         ,0},;
             {"transform(Preco_at  , '@e 999,999.99')/Pre‡o Atacado" ,0},;
             {"transform(Preco_vr  , '@e 999,999.99')/Pre‡o Varejo " ,0}},"P",;
             {NIL,"c107a",NIL,NIL},;
             NIL,"<C>onsulta/<A>lterar"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c107a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

  // iif(cOPCAO == "R", i_reaj(),)
   if cOPCAO == "A" ; i_edita_preco() ; endif

   if cOPCAO == "C"
      qlbloc(10,5,"B107A","QBLOC.GLO",1)
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

function f107b
      UNIDADE->(dbseek(PROD->Unidade))
return UNIDADE->Sigla

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
      UNIDADE->(dbseek(PROD->Unidade))
      qrsay ( XNIVEL++ , UNIDADE->Sigla     )
      qrsay ( XNIVEL++ , UNIDADE->Descricao )
      qrsay ( XNIVEL++ , PROD->Preco_at , "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->Preco_vr , "@E 999,999.99" )

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

   local nPRECO_AT
   local nPRECO_VR

   nPRECO_AT     := PROD->Preco_at
   nPRECO_VR     := PROD->Preco_vr

   Linha:=Row()

   qgetx(Linha,44,@nPRECO_AT ,"@e 999,999.99")
   qgetx(Linha,58,@nPRECO_VR ,"@e 999,999.99")

   if qconf("Confirma a altera‡„o destes valores ?")
      if PROD->(qrlock())
         replace PROD->Preco_at   with nPRECO_AT
         replace PROD->Preco_vr   with nPRECO_VR
      else
         qm2()
      endif
   endif

return

