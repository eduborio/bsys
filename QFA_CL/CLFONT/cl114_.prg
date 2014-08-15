/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: TABELA DE PRECOS DISTRIBUIDORA
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO DE 2000
// OBS........:
// ALTERACOES.:

function cl114
PROD->(Dbsetorder(4))
UNIDADE->(dbsetorder(1))

PROD->(qview({{"Cod_ass/Codigo Ass"                       ,3},;
             {"left(Descricao,40)/Produto"                          ,2},;
             {"transform(E218_7   , '@e 999,999.99')/Pre‡o a vista" ,0}},"P",;
             {NIL,"c114a",NIL,NIL},;
             NIL,"<C>onsulta/<A>lterar"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c114a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

  // iif(cOPCAO == "R", i_reaj(),)
   if cOPCAO == "A" ; i_edita_preco() ; endif

   if cOPCAO == "C"
      qlbloc(10,5,"B112A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , PROD->E218_7,    "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_36 ,  "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_369 , "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_36912,"@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_SEM , "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_COMIS, "@E 99.99" )

      qwait()

   endif

return

/////////////////////////////////////////////////////////////////////////////
// REAJUSTE DE TABELAS ______________________________________________________

static function i_reaj

   local cTAB   := space(4)
   local nFATOR := 0
   local nCONT  := PROD->(recc())

   qlbloc(8,5,"B102B","QBLOC.GLO",1)

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
   local nVAL_7
   local nVAL_36
   local nVAL_369
   local nVAL_3612
   local nVAL_SEM
   local nVAL_COMIS
   qlbloc(8,5,"B112A","QBLOC.GLO",1)

   nVAL_7     := PROD->E218_7
   nVAL_36    := PROD->E218_36
   nVAL_369   := PROD->E218_369
   nVAL_36912 := PROD->E218_36912
   nVAL_SEM   := PROD->E218_SEM
   nVAL_COMIS := PROD->E218_COMIS


      XNIVEL := 1

      qrsay ( XNIVEL++ , right(PROD->Codigo,5)              )
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)           )
      qrsay ( XNIVEL++ , PROD->E218_7,    "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_36 ,  "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_369 , "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_36912,"@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_SEM , "@E 999,999.99" )
      qrsay ( XNIVEL++ , PROD->E218_COMIS, "@E 99.99" )

   XNIVEL := 2

   XNIVEL++
   qgetx(-1,0,@nVAL_7 ,"@e 999,999.99")
   XNIVEL++
   qgetx(-1,0,@nVAL_36  ,"@e 999,999.99")
   XNIVEL++
   qgetx(-1,0,@nVAL_369  ,"@e 999,999.99")
   XNIVEL++
   qgetx(-1,0,@nVAL_36912  ,"@e 999,999.99")
   XNIVEL++
   qgetx(-1,0,@nVAL_SEM  ,"@e 999,999.99")
   XNIVEL++
   qgetx(-1,0,@nVAL_COMIS  ,"@e 99.99")

   if qconf("Confirma a altera‡„o destes valores ?")
      if PROD->(qrlock())
         replace PROD->E218_7     with nVAL_7
         replace PROD->E218_36    with nVAL_36
         replace PROD->E218_369   with nVAL_369
         replace PROD->E218_36912 with nVAL_36912
         replace PROD->E218_SEM   with nVAL_SEM
         replace PROD->E218_COMIS with nVAL_COMIS

      else
         qm2()
      endif
   endif

return

