/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: SALDO ATUAL DOS PRODUTOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MAIO DE 2000
// OBS........:
// ALTERACOES.:
function es509

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cTITULO                // titulo do relatorio
private aEDICAO   := {}        // vetor para os campos
private cCOD_PROD := space(5)  // produto
private cFILIAL   := space(4)  // filial

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"@R 9999"   )},"FILIAL"  })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
aadd(aEDICAO,{{ || view_prod(-1,0,@cCOD_PROD,"@R 99999"  )},"COD_PROD"})
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto

do while .T.

   qlbloc(5,0,"B507A","QBLOC.GLO")

   XNIVEL     := 1
   XFLAG      := .T.
   cFILIAL    := space(4)
   cCOD_PROD  := space(5)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif( i_inicializacao() , i_imprime() , NIL )

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

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ____________________________

static function i_inicializacao

   cTITULO := "VALOR TOTAL EM ESTOQUE" + "  "  + cFILIAL + "-" + ALLTRIM(FILIAL->Razao)
   nTOTCUSTO := 0
   nTOTVENDA := 0
   PROD->(dbsetorder(1)) // codigo
   INVENT->(dbsetorder(1)) // filial + produto

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND0
   nTOTCUSTO := 0
   nTOTVENDA := 0

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
         @ prow()+1,0 say "PRODUTO                                EM ESTOQUE    PRECO CUSTO     PRECO VENDA"
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


      // rotina que localiza todos os produtos lancados no inventario de lotes distintos
      nQUANT := 0
      do while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
         nQUANT+= INVENT->Quant_atu
         INVENT->(dbskip())
      enddo

      @ prow()+1,00 say left(PROD->Descricao,32)   + " " +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT,"@E 999,999,999.99") + "   " +;
                        transform(nQUANT*PROD->Preco_cust,"@E 99,999,999.99")+"    "+transform(nQUANT*PROD->Preco_cons,"@E 99,999,999.99") , "")
      nTOTCUSTO += (nQUANT * PROD->Preco_cust)
      nTOTVENDA += (nQUANT * PROD->Preco_cons)
      PROD->(dbskip())

   enddo
      @ prow()+3,0 say replicate("-",80)
      @ prow()+1,0 say "                                    TOTAL PRECO CUSTO          TOTAL PRECO VENDA"
      @ prow()+1,0 say replicate("-",80)
      @ prow()+1,37 say transform(nTOTCUSTO,"@E 99,999,999.99") +"               "+ transform(nTOTVENDA,"@E 99,999,999.99")
   qstopprn()

return
