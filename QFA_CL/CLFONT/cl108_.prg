/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: TABELA DE PRECOS DISTRIBUIDORA
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO DE 2000
// OBS........:
// ALTERACOES.:

function cl108
PROD->(Dbsetorder(4))
UNIDADE->(dbsetorder(1))

PROD->(qview({{"left(Descricao,29)/Produto"                          ,2},;
             {"transform(Preco_1  , '@e 999,999.99')/Pre‡o Unit rio" ,0},;
             {"transform(Preco_cx   , '@e 999,999.99')/Pre‡o da caixa" ,0}},"P",;
             {NIL,"c108a",NIL,NIL},;
             NIL,"<C>onsulta/<A>lterar"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c108a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

  // iif(cOPCAO == "R", i_reaj(),)
   if cOPCAO == "A" ; i_edita_preco() ; endif

   if cOPCAO == "C"
      qlbloc(10,5,"B108A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , PROD->Preco_1, "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->Preco_cx , "@E 999,999.99" )

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
            replace PROD->Preco_uni with PROD->Preco_uni * nFATOR
            replace PROD->Preco_cust with ( PROD->Preco_uni - (PROD->Preco_unit * (PROD->Desconto/100) ) )
            replace PROD->Preco_cons with (PROD->Preco_uni + (PROD->Preco_unit * 0.4285) )
            PROD->(qunlock())
         endif

         PROD->(dbskip())

      enddo

      PROD->(dbgotop())

   endif

return


static function i_edita_preco

   local nVAL_UNI
   local nVAL_CX

   nVAL_UNI     := PROD->Preco_1
   nVAL_CX      := PROD->Preco_cx

   Linha:=Row()

   qgetx(Linha,44,@nVAL_UNI ,"@e 999,999.99")
   qgetx(Linha,58,@nVAL_CX  ,"@e 999,999.99")

   if qconf("Confirma a altera‡„o destes valores ?")
      if PROD->(qrlock())
         replace PROD->Preco_1  with nVAL_UNI
         replace PROD->Preco_cx   with nVAL_CX

      else
         qm2()
      endif
   endif

return

