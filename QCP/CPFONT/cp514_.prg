/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE COMPRAS POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: OUTUBRO DE 2002
// OBS........:
// ALTERACOES.:

function cp514

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private cTITULO2                   // titulo do relatorio
private dINI
private dFIM
private cPROD
private cPROD_DESC
private cFORN
private nVALOR
private nVAL_UNI
private nCUSTO
private nQUANT
private aEDICAO := {}             // vetor para os campos de entrada de dados

PROD->(dbsetorder(4)) // codigo reduzido

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD)       } ,"PROD"    })
aadd(aEDICAO,{{ || NIL                          } ,NIL       })

do while .T.

   qlbloc(5,0,"B514A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cFORN  := space(5)
   cPROD  := space(5)
   cPROD_DESC := space(45)
   dINI := dFIM := ctod("")
   nVALOR := nQUANT := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "PROD"
           if empty(cPROD) ; return .F. ; endif
           qrsay(XNIVEL,cPROD:=strzero(val(cPROD),5))
           PROD->(Dbsetorder(4))
           if ! PROD->(dbseek(cPROD))
               qmensa("Produto inv lido !","B")
               return .F.
           else
              qrsay(XNIVEL+1,left(PROD->Descricao,38))
              cPROD_DESC := left(PROD->Cod_Fabr,6) +"  "+ left(PROD->Descricao,20) +" "+ PROD->Cod_ass
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

//static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


//   cTITULO := " "+left(cPROD,5)+ " " + left(cPROD_DESC,45) + " de " + dtoc(dINI) + " a " + dtoc(dFIM)

//   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

//   PEDIDO->(dbsetorder(1)) // data de emissao
//   PEDIDO->(dbgotop())
//   set softseek on
//   PEDIDO->(dbseek(dINI))
//   set softseek off

//return .T.

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________
   cTITULO  := " RELATORIO DE COMPRAS POR PRODUTO" + dtoc(dINI) + " a " + dtoc(dFIM)
   cTITULO2 := cPROD_Desc
   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PEDIDO->(dbsetorder(1)) // data de emissao
   PEDIDO->(dbgotop())

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local lTEM := .F.
   local nQUANT := nTOT_QUANT := 0
   local nPRECO := nTOT_PRECO := 0
   local nTOT_QTD := nTOT_VAL := nTOTAL := 0
   local aPED := {}
   local asPED := {}
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! PEDIDO->(eof()) // condicao principal de loop

      if PEDIDO->Data_emiss < dINI .or. PEDIDO->Data_emiss > dFIM
         PEDIDO->(Dbskip())
         loop
      endif

      LANC->(dbsetorder(1))
      LANC->(dbgotop())
      LANC->(dbseek(PEDIDO->Codigo))

      do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(Eof())

         if LANC->Cod_prod == cPROD
            aadd(aPED,{LANC->Cod_prod,PEDIDO->Cod_forn,PEDIDO->Data_ped,LANC->Quant,LANC->Preco,PEDIDO->Numero_nf,left(PEDIDO->Codigo,5)})
            lTEM := .T.
         endif

         LANC->(Dbskip())
      enddo
      PEDIDO->(dbskip())

   enddo

   asPED := asort(aPED,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
   
   if lTEM
       zPROD := asPED[1,1]
       zFORN  := asPED[1,2]
       nCONT := 1
	   nQUANT := 0
	   
       do while  nCONT <= len(asPED)

          if ! qlineprn() ; exit ; endif

          if XPAGINA == 0 .or. prow() > K_MAX_LIN
             @prow()+1,0 say XCOND0
             qpageprn()
             qcabecprn(cTITULO,80,,cTITULO2)

             @ prow()+1,0 say XCOND1 + "Nota   Pedido  Fornecedor                         Emissao            Quantidade          Preco Unitario             Valor "
             @ prow()+1,0 say ""
          endif

          qgirabarra()

          qmensa("Aguarde... Processando ...")

           nQUANT += asPED[nCONT,4]
           nTOT_QUANT += asPED[nCONT,4]

           nPRECO += (asPED[nCONT,4] * asPED[nCONT,5])//Quantidade * valor unitario
           nTOT_PRECO += (asPED[nCONT,4] * asPED[nCONT,5])   //Quantidade * valor unitario

           @ prow()+1,00  say asPED[nCONT,6]
           @ prow()  ,08  say asPED[nCONT,7]
           FORN->(dbseek(asPED[nCONT,2]))
           cCGM := FORN->Cgm_ent
           @ prow()  ,15  say left(FORN->Razao,30)
           @ prow()  ,50  say dtoc(asPED[nCONT,3])
           @ prow()  ,65  say transform(asPED[nCONT,4], "@E 9,999,999.99")
           @ prow()  ,86  say transform(asPED[nCONT,5], "@E 9,999,999.99")
           @ prow()  ,110 say transform(asPED[nCONT,4]*asPED[nCONT,5], "@E 9,999,999.99")
           @ prow()  ,124 say iif(empty(asPED[nCONT,6]),"PD","NF")

           nCONT++
           if nCONT > len(asPED)
              nCONT := len(asPED)
              exit
           endif


         if alltrim(asPED[nCONT,1]) != alltrim(zPROD)
             PROD->(dbsetorder(4))
             PROD->(dbgotop())
             PROD->(dbseek(zPROD))
             @ prow()+2  ,00 say "TOTAIS DO PRODUTO.: " + left(PROD->Descricao,30) + PROD->Cod_ass
             @ prow()    ,65 say transf(nQUANT,"@E 9,999,999.99")
             @ prow()    ,110 say transf(nPRECO,"@E 9,999,999.99")
             @ prow()+1,00 say replicate("-",136)
             @ prow()+1,00 say ""
             nQUANT := 0
             nPRECO := 0

         endif


         zPROD := asPED[nCONT,1]

       enddo

       PROD->(dbsetorder(4))
       PROD->(dbgotop())
       PROD->(dbseek(zPROD))

       @ prow()+2  ,00 say "TOTAIS DO PRODUTO.: " + left(PROD->Descricao,30)
       @ prow()    ,65 say transf(nQUANT,"@E 9,999,999.99")
       @ prow()    ,110 say transf(nPRECO,"@E 9,999,999.99")
       nQUANT := 0
       nPRECO := 0

       @ prow()+1,00 say ""

       @ prow()+1,00 say replicate("-",134)
       @ prow()+1,00 say "TOTAL GERAL...: " + cPROD_DESC
       @ prow()  ,65 say transf(nTOT_QUANT,"@E 9,999,999.99")
       @ prow()  ,110 say transf(nTOT_PRECO,"@E 9,999,999.99")
       CGM->(dbseek(cCGM))
       @ prow()+1,00 say CGM->Municipio + " " + CGM->Estado
       nTOT_QUANT := 0
       nTOT_PRECO := 0
   endif
   PROD->(Dbclearfilter())
   PROD->(dbsetorder(1))
   qstopprn()

return

