/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: SALDO ATUAL DOS PRODUTOS
// ANALISTA...: Eduardo borio
// PROGRAMADOR: Eduardo Borio
// INICIO.....: AGOSTO DE 1997
// OBS........:
// ALTERACOES.: DEZEMBRO de 2006
function es511

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cTITULO                // titulo do relatorio
private aEDICAO   := {}        // vetor para os campos
private cCOD_PROD := space(5)  // produto
private cFILIAL   := space(4)  // filial
private cTIPO     := space(1)  // Tipo de Produto
private sBLOC1    := qlbloc("B507B","QBLOC.GLO")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"@R 9999"   )},"FILIAL"  })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
aadd(aEDICAO,{{ || view_prod(-1,0,@cCOD_PROD,"@R 99999"  )},"COD_PROD"})
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO       ,sBLOC1       )} ,"TIPO" })


do while .T.

   qlbloc(5,0,"B507A","QBLOC.GLO")

   XNIVEL     := 1
   XFLAG      := .T.
   cFILIAL    := space(4)
   cCOD_PROD  := space(5)
   cTIPO      := space(1)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   quse(XDRV_CL,"CONFIG",NIL,NIL,"FATCFG")

   iif( i_inicializacao() , i_impressao() , NIL )

   FATCFG->(DbCloseArea())


enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   do case

      case cCAMPO == "COD_PROD"

           if empty(cCOD_PROD)
              qrsay(XNIVEL+1,"*** Todos os Produtos ***")
           else
              PROD->(dbsetorder(4))

              if ! PROD->(dbseek(cCOD_PROD:=strzero(val(cCOD_PROD),5)))
                 qmensa("Produto n„o cadastrado !","B")
                 return .F.
              endif

              qrsay(XNIVEL+1,left(PROD->Descricao,36))

              if ! INVENT->(dbseek(cFILIAL+cCOD_PROD))
                 qmensa("N„o Existe Invent rio para este Produto !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "FILIAL"

           if empty(cFILIAL) ; return .F. ; endif

           qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))

           if ! FILIAL->(dbseek(cFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,30))

      case cCAMPO == "TIPO"
          // if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO," 123456", {"Todos","Produto Acabado","Matria prima","Material","Embalagens","Vazios","Outros"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ____________________________

static function i_inicializacao


   if cTIPO $ "1-2-3-4-5-6-7-8-9"
      PROD->(DbClearFilter())
      PROD->(dbsetfilter({|| PROD->Tipo == cTIPO},'PROD->Tipo == cTIPO'))
   Endif

   cTITULO := "SALDO ATUAL NA " + cFILIAL + "-" + ALLTRIM(FILIAL->Razao)

   PROD->(dbsetorder(1)) // codigo
   INVENT->(dbsetorder(1)) // filial + produto

   qmensa()

return .T.

static function i_impressao

   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return


/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_impre_prn

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   @ prow(),pcol() say XCOND0

   do while ! PROD->(eof()) .and. qcontprn()

      if ! qlineprn() ; exit ; endif

      qgirabarra()

      if ! empty(cCOD_PROD)
         if right(PROD->Codigo,5) <> cCOD_PROD
            exit
         endif
      endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,0 say "PRODUTO                                              EM ESTOQUE   PRECO UNITARIO"
         @ prow()+1,0 say replicate("-",80)
      endif

      INVENT->(dbgotop())

      if empty(cCOD_PROD)
         if ! INVENT->(dbseek(cFILIAL+right(PROD->Codigo,5)))
            PROD->(dbskip())
            loop
         endif
      else
         INVENT->(dbseek(cFILIAL+cCOD_PROD))
         PROD->(dbsetorder(4))
         PROD->(dbseek(cCOD_PROD))
         PROD->(dbsetorder(1))
      endif

//    PROD->(dbseek(INVENT->Cod_prod))

      // rotina que localiza todos os produtos lancados no inventario de lotes distintos
      nQUANT := 0
      do while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
         nQUANT+= INVENT->Quant_atu
         INVENT->(dbskip())
      enddo

      @ prow()+1,00 say iif(FATCFG->Modelo_lfat == "1",left(PROD->Cod_fabr,7),right(PROD->Codigo,5)) + " - " + PROD->Cod_ass +" "+ left(PROD->Descricao,26)+" "+left(PROD->Marca,12)   + " " +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT,"@R 9999999") + " " +;
                        transform(PROD->Preco_Cust,"@E 999,999.99") , "")

      PROD->(dbskip())

   enddo

   qstopprn()



return

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_impre_xls

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do while ! PROD->(eof()) 
      qgirabarra()

      if ! empty(cCOD_PROD)
         if right(PROD->Codigo,5) <> cCOD_PROD
            exit
         endif
      endif

      if XPAGINA == 0
         qpageprn()
         @ prow()+1,0 say chr(9)+chr(9)+cTITULO+chr(9)+"511"
         @ prow()+1,0 say "Ref."+chr(9)+"Cod assoc."+Chr(9)+"Descricao"+chr(9)+"Marca"+chr(9)+"Em Estoque"+chr(9)+"Preco Unitario"+chr(9)+"Valor Total"
         @ prow()+1,0 say ""
      endif

      INVENT->(dbgotop())

      if empty(cCOD_PROD)
         if ! INVENT->(dbseek(cFILIAL+right(PROD->Codigo,5)))
            PROD->(dbskip())
            loop
         endif
      else
         INVENT->(dbseek(cFILIAL+cCOD_PROD))
         PROD->(dbsetorder(4))
         PROD->(dbseek(cCOD_PROD))
         PROD->(dbsetorder(1))
      endif

//    PROD->(dbseek(INVENT->Cod_prod))

      // rotina que localiza todos os produtos lancados no inventario de lotes distintos
      nQUANT := 0
      do while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
         nQUANT+= INVENT->Quant_atu
         INVENT->(dbskip())
      enddo

      @ prow()+1,00 say left(PROD->Cod_fabr,7) +  chr(9)  + PROD->Cod_ass +chr(9)+ left(PROD->Descricao,18)+chr(9)+left(PROD->Marca,12)   +chr(9)+;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT,"@R 99999999") + chr(9) +;
                        transform(PROD->Preco_cust,"@E 999,999.99") , "")+chr(9)+transform(PROD->Preco_cust*nQUANT,"@E 9,999,999.99")

      PROD->(dbskip())

   enddo

   qstopprn()

return

