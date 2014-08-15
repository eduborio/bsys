/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE FATURAMENTO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: AGOSTO DE 2000
// OBS........:
// ALTERACOES.:

function cl522
#define K_MAX_LIN 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cPROD
private cPROD_DESC
private cFABR
private cCLI
private nVALOR
private nVAL_UNI
private nCUSTO
private nQUANT
private aEDICAO := {}             // vetor para os campos de entrada de dados

if ! quse(XDRV_CL,"FI522",{"FI522"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif


PROD->(dbsetorder(4)) // codigo reduzido

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD)       } ,"PROD"    })
aadd(aEDICAO,{{ || NIL                          } ,NIL       })

do while .T.

   qlbloc(5,0,"B522A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cCLI   := space(5)
   cPROD  := space(5)
   cPROD_DESC := space(45)
   cFABR := space(4)
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
           if ! PROD->(dbseek(cPROD))
               qmensa("Produto inv lido !","B")
               return .F.
           else
              qrsay(XNIVEL+1,left(PROD->Descricao,38))
              cPROD_DESC := left(PROD->Descricao,45)
              cFABR := left(PROD->Cod_fabr,4)
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := " "+left(cFABR,4)+ " " + left(cPROD_DESC,45) + " de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off

return .T.

static function i_impressao
   if ! qinitprn() ; return  ; endif

   FI522->(__dbzap())

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif
return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

   local lTEM := .F.
   local nTOT_QTD := nTOT_VAL := nTOT_CUS := 0
   local cCLI := ""
   local nQuant_cli := 0
   local nQuant_tot := 0
   local nValor_cli := 0
   local nValor_tot := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      nValor := 0

      if ITEN_FAT->(Dbseek(FAT->Codigo+cPROD))

         if CONFIG->Modelo_fat != "1"
            nDESC := (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (FAT->Aliq_desc/100)
         else
            nDESC := 0
         endif

         nVALOR += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) - nDESC
         nVALOR += q_soma_st()

         if FI522->(Qappend())
            replace FI522->Cod_cli    with FAT->cod_cli
            replace FI522->NF         with FAT->Num_fatura
            replace FI522->Pedido     with FAT->Codigo
            replace FI522->Valor      with ITEN_FAT->Vl_unitar
            replace FI522->Quantidade with ITEN_FAT->Quantidade
            replace FI522->Total      with nValor
         endif

         nValor := 0
      endif

      FAT->(dbskip())

   enddo

   FAT->(dbsetorder(1))
   FAT->(dbgotop())

   FI522->(dbcommit())


   FI522->(dbgotop())

   cCLI := FI522->Cod_Cli

   do while ! FI522->(Eof())

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "Nota   Pedido  Cliente                           Emissao            Quantidade          Preco Unitario             Valor "
         @ prow()+1,0 say ""
      endif

      CLI1->(dbseek(FI522->Cod_cli))
      FAT->(dbseek(FI522->Pedido))

      @ prow()+1,00  say XCOND1 + FI522->NF
      @ prow()  ,08  say FI522->Pedido
      @ prow()  ,15  say left(CLI1->Razao,30)
      @ prow()  ,50  say dtoc(FAT->Dt_emissao)
      @ prow()  ,65  say transform(FI522->Quantidade, "@E 9,999,999.99")
      @ prow()  ,86  say transform(FI522->Valor, "@E 9,999,999.99")
      @ prow()  ,110 say transform(FI522->Total, "@E 9,999,999.99")
      @ prow()  ,125 say FAT->(Cod_cfop)

      if FAT->Es == "S"
         nQuant_cli += FI522->Quantidade
         nQuant_tot += FI522->Quantidade
         nValor_cli += FI522->Total
         nValor_tot += FI522->Total
      else
         nQuant_cli -= FI522->Quantidade
         nQuant_tot -= FI522->Quantidade
         nValor_cli -= FI522->Total
         nValor_tot -= FI522->Total
      endif

      FI522->(dbskip())

      if FI522->Cod_cli != cCLI
         CLI1->(dbseek(cCLI))
         @ prow()+2 ,00  say "Totais do Cliente .: " +left(Cli1->Razao,35)
         @ prow()   ,65  say transform(nQuant_cli, "@E 9,999,999.99")
         @ prow()  ,110  say transform(nValor_cli, "@E 9,999,999.99")
         nQuant_cli := 0
         nValor_cli := 0
         @ prow()+1,00 say replicate("-",134)
         @ prow()+1,00 say ""
      endif

      cCLI := FI522->Cod_cli

   enddo

   CLI1->(dbseek(cCLI))
   @ prow()+2 ,00  say "Totais do Cliente .: " +left(Cli1->Razao,35)
   @ prow()   ,65  say transform(nQuant_cli, "@E 9,999,999.99")
   @ prow()  ,110  say transform(nValor_cli, "@E 9,999,999.99")
   @ prow()+1,00 say replicate("-",134)
   @ prow()+1,00 say ""

   nQuant_cli := 0
   nValor_cli := 0

   @ prow()+1, 00  say "Total Geral........: "
   @ prow()  , 65  say transform(nquant_tot,"@E 9,999,999.99")
   @ prow()  ,110  say transform(nValor_tot,"@E 9,999,999.99")

   nQuant_tot := 0
   nValor_tot := 0

   qstopprn()

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls

   local lTEM := .F.
   local nTOT_QTD := nTOT_VAL := nTOT_CUS := 0
   local cCLI := ""
   local nQuant_cli := 0
   local nQuant_tot := 0
   local nValor_cli := 0
   local nValor_tot := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      nValor := 0

      if ITEN_FAT->(Dbseek(FAT->Codigo+cPROD))

         if CONFIG->Modelo_fat != "1"
            nDESC := (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (FAT->Aliq_desc/100)
         else
            nDESC := 0
         endif

         nVALOR += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) - nDESC
         nVALOR += q_soma_st()

         if FI522->(Qappend())
            replace FI522->Cod_cli    with FAT->cod_cli
            replace FI522->NF         with FAT->Num_fatura
            replace FI522->Pedido     with FAT->Codigo
            replace FI522->Valor      with ITEN_FAT->Vl_unitar
            replace FI522->Quantidade with ITEN_FAT->Quantidade
            replace FI522->Total      with nValor
         endif

         nValor := 0
      endif

      FAT->(dbskip())

   enddo

   FAT->(dbsetorder(1))
   FAT->(dbgotop())

   FI522->(dbcommit())


   FI522->(dbgotop())

   cCLI := FI522->Cod_Cli

   do while ! FI522->(Eof())

      if XPAGINA == 0
         qpageprn()
         @ prow()+1,0 say chr(9)+chr(9)+cTITULO + " 522"
         @ prow()+1,0 say "Nota"+chr(9)+"Pedido"+chr(9)+"Cliente"+chr(9)+"Emissao"+chr(9)+"Quantidade"+chr(9)+"Preco"+chr(9)+"Unitario"+chr(9)+"Valor"+chr(9)+"Cfop"
         @ prow()+1,0 say " "
      endif

      CLI1->(dbseek(FI522->Cod_cli))
      FAT->(dbseek(FI522->Pedido))

      @ prow()+1,00     say FI522->NF+" "
      @ prow()  ,pcol() say chr(9)+FI522->Pedido+" "
      @ prow()  ,pcol() say chr(9)+left(CLI1->Razao,30)
      @ prow()  ,pcol() say chr(9)+dtoc(FAT->Dt_emissao)+" "
      @ prow()  ,pcol() say chr(9)+transform(FI522->Quantidade, "@E 9,999,999.99")
      @ prow()  ,pcol() say chr(9)+transform(FI522->Valor, "@E 9,999,999.99")
      @ prow()  ,pcol() say chr(9)+transform(FI522->Total, "@E 9,999,999.99")
      @ prow()  ,pcol() say chr(9)+FAT->(Cod_cfop)

      if FAT->Es == "S"
         nQuant_cli += FI522->Quantidade
         nQuant_tot += FI522->Quantidade
         nValor_cli += FI522->Total
         nValor_tot += FI522->Total
      else
         nQuant_cli -= FI522->Quantidade
         nQuant_tot -= FI522->Quantidade
         nValor_cli -= FI522->Total
         nValor_tot -= FI522->Total
      endif

      FI522->(dbskip())

      if FI522->Cod_cli != cCLI
         CLI1->(dbseek(cCLI))
         @ prow()+1 ,00  say chr(9)+chr(9)+"Totais do Cliente ... "
         @ prow()   ,pcol() say chr(9)+chr(9)+transform(nQuant_cli, "@E 9,999,999.99")
         @ prow()   ,pcol() say chr(9)+chr(9)+transform(nValor_cli, "@E 9,999,999.99")
         nQuant_cli := 0
         nValor_cli := 0
         @ prow()+1,00 say ""
      endif

      cCLI := FI522->Cod_cli

   enddo

   CLI1->(dbseek(cCLI))
   @ prow()+2 ,00  say chr(9)+chr(9)+"Totais do Cliente ... "
   @ prow()   ,pcol() say chr(9)+chr(9)+transform(nQuant_cli, "@E 9,999,999.99")
   @ prow()   ,pcol() say chr(9)+chr(9)+transform(nValor_cli, "@E 9,999,999.99")
   @ prow()+1,00 say ""



   nQuant_cli := 0
   nValor_cli := 0

   @ prow()+1, 00  say chr(9)+chr(9)+"Total Geral........: "
   @ prow()   ,pcol() say chr(9)+chr(9)+transform(nQuant_tot, "@E 9,999,999.99")
   @ prow()   ,pcol() say chr(9)+chr(9)+transform(nValor_tot, "@E 9,999,999.99")


   nQuant_tot := 0
   nValor_tot := 0

   qstopprn(.F.)

return






