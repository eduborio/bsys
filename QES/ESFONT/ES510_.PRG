////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO DE 2005
// OBS........:
// ALTERACOES.:
function es510

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private cDESCRICAO := space(35)                   // titulo do relatorio
private nSALDO_INI := 0                // titulo do relatorio
private nSALDO_ATU := 0               // titulo do relatorio
private nPC_INI    := 0               // Preco de Custo Inicial
private nPC_CORRENTE  := 0            // P.C. Corrente
private nTT_ANT       := 0
private sBLOC1  := qlbloc("B510B","QBLOC.GLO")


private dINI
private dFIM
private cPROD := space(5)
private cSINTETICO := space(1)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aReservas := {}

if ! quse(XDRV_ES,"ESTMP",{"ESTMP"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"ESANT",{"ESANT"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"CFOPTMP",{"CFOPTMP"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif



// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD)     } , "PROD"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cSINTETICO,sBLOC1)}, "SINTETICO"   })


do while .T.

   qlbloc(5,0,"B510A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   nSALDO_INI := 0                // SALDO Inicial de Estoque
   nSALDO_ATU := 0                // Saldo Corrente
   cSINTETICO := "A"
   nPC_INI    := 0               // Preco de Custo Inicial
   nPC_CORRENTE  := 0            // P.C. Corrente
   cPROD := space(5)

   dINI := dFIM := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE )
         dbcloseall()
         erase_index()
         return
      endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   faz_index(cPROD) 
   
   i_reserva()

   nTT_ANT := i_sald_anter()

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

      case cCAMPO == "PROD"

           qrsay(XNIVEL,cPROD)

           if empt(cPROD)
              qrsay(XNIVEL+1, "Todos os Produtos.......")
           else
              PROD->(dbsetorder(4))
              if ! PROD->(Dbseek(cPROD:=strzero(val(cPROD),5)))
                 qmensa("Produto n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(PROD->Descricao,20)+" "+PROD->Cod_ass+" "+left(PROD->Cod_fabr,6) )
              endif
           endif

      case cCAMPO == "SINTETICO"
           if empty(cSINTETICO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cSINTETICO,"AS",{"Analitico","Sintetico"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________
   
   


   cTITULO := "Razao por Produto " +" de " + dtoc(dINI) + " a " + dtoc(dFIM)


   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   
   PROD->(dbsetorder(4))
   PROD->(Dbgotop())


   FAT->(dbsetorder(FAT->(OrdCount()))) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))

   set softseek off
   ITEN_FAT->(dbsetorder(ITEN_FAT->(OrdCount())))

   PEDIDO->(dbsetorder(PEDIDO->(OrdCount()))) // data de emissao
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(Dbseek(dtos(dINI)))
   set softseek off
   LANC->(dbsetorder(LANC->(OrdCount())))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nSALDO_COR := 0
    local nSALDO_INI := 0
    local nCUSTO_INI := 0
    local nCUSTO_COR := 0
    local nVALOR     := 0

    local nTT_INI       := 0

    local nVLR_VEND  := 0
    local nVLR_VEND_TOT  := 0
    local nQTD_VEND      := 0
    local nVLR_ENT_TOT  := 0
    local nVLR_ESTQ_TOT  := 0
    local nTOT_QTD_VEND  := 0

    local nVLR_ENT   := 0
    local nVLR_ESTQ  := 0
    local nQTD_ENT   := 0

    local cPROD      := 0
    local lTEM := .T.
    local zPROD := space(50)
    local nCOMPRAS := 0
    local nCONSIG  := 0

    ESTMP->(__dbzap())
    CFOPTMP->(__dbzap())
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
	
	   oServer := TMySQLServer():New(XSERVER, "root", "borios")
	   if oServer:NetErr()
	      Alert(oServer:Error())
	   endif

	   oServer:SelectDB("comercial")
   
   if ! qinitprn() ; return ; endif
   qmensa("Aguarde... Processando ...")


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_Fatura) .and. FAT->Es == "S"
         FAT->(DbSkip())
         loop
      endif

      if left(FAT->Cod_cfop,4) $ "5905-6905-1906-2906-5906-6906-1905-2905"
         FAT->(DbSkip())
         loop
      endif


      //qgirabarra()


         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             if ESTMP->(qappend())
                replace ESTMP->Data       with FAT->Dt_emissao
                replace ESTMP->Produto    with right(ITEN_FAT->Cod_prod,5)
                replace ESTMP->Nota       with FAT->Num_fatura
                replace ESTMP->Cfop       with alltrim(FAT->Cod_cfop)
                replace ESTMP->Quantidade with ITEN_FAT->Quantidade
                replace ESTMP->Es         with FAT->Es
                replace ESTMP->Cod_fc     with FAT->Cod_cli
             endif
             ITEN_FAT->(Dbskip())
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //MOVIMENT->(dbsetfilter({|| MOVIMENT->Contabil == .F.},'MOVIMENT->Contabil == .F.'))
   MOVIMENT->(dbsetorder(MOVIMENT->(OrdCount()))) // data de emissao
   MOVIMENT->(dbgotop())

   do while ! MOVIMENT->(eof())

         if MOVIMENT->Contabil
            MOVIMENT->(dbSkip())
            Loop
         endif

         if MOVIMENT->Data < dINI .or. MOVIMENT->Data > dFIM
            MOVIMENT->(dbSkip())
            Loop
         endif

         if MOVIMENT->Tipo == "E"
            cDESCRICAO := "ENTRA"
         else
            cDESCRICAO := "SAIDA"
         endif

         if ESTMP->(qappend())
            replace ESTMP->Data       with MOVIMENT->Data
            replace ESTMP->Produto    with right(MOVIMENT->Cod_prod,5)
            replace ESTMP->Nota       with ""
            replace ESTMP->Cfop       with left(cDESCRICAO,4)
            replace ESTMP->Quantidade with MOVIMENT->Quantidade
            replace ESTMP->Es         with MOVIMENT->Tipo
            replace ESTMP->Cod_fc     with cDESCRICAO
         endif

         MOVIMENT->(dbskip())

         nVALOR := 0
         nDESC := 0
   enddo


   do while ! PEDIDO->(eof())  .and. PEDIDO->Data_ped >= dINI .and. PEDIDO->Data_ped <= dFIM  // condicao principal de loop

      //qgirabarra()

     // qmensa("Aguarde... Processando ...")

         if ! PEDIDO->Interface
            PEDIDO->(Dbskip())
            loop
         endif

         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

             if ESTMP->(qappend())
                replace ESTMP->Data        with PEDIDO->Data_ped
                replace ESTMP->Produto     with right(LANC->Cod_prod,5)
                replace ESTMP->Nota        with PEDIDO->Numero_nf
                replace ESTMP->Cfop        with PEDIDO->Cfop
                replace ESTMP->Quantidade  with LANC->Quant
                replace ESTMP->Preco_cust  with LANC->Preco
                replace ESTMP->Es          with "C"
                replace ESTMP->Cod_fc      with PEDIDO->Cod_forn
             endif


             LANC->(Dbskip())
             lTEM := .T.
         enddo
         PEDIDO->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   nCOMPRAS  := 0
   nCONSIG   := 0

   ESTMP->(Dbgotop())
   ESTMP->(Dbsetorder(1))
   //classifica a matriz por descricao do produto
   //asFAT := asort(aFAT,,,{|x,y| x[2] + x[1] + x[3] < y[2] + y[1] + y[3]  })
   if lTEM
       cPROD := ESTMP->Produto
       
       PROD->(dbseek(ESTMP->Produto))
	   
       zPROD := rtrim(PROD->Cod_fabr) + "/ "+rtrim(PROD->Cod_ass)+"    "+rtrim(PROD->Descricao)+"        "+rtrim(PROD->Marca)
       if ESANT->(Dbseek(ESTMP->Produto))
          nSALDO_COR := ESANT->Quantidade
          nCUSTO_COR := ESANT->Preco_cust
       else
          nSALDO_COR := 0
          nCUSTO_COR := 0
       endif

       nSALDO_INI := nSALDO_COR
       nCUSTO_INI := nCUSTO_COR

       lPRIM := .T.
       nCONT := 1
       do while ! ESTMP->(eof())

           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say + "  "+chr(9)+cTITULO
              if cSINTETICO == "A"
                 @ prow()+1,0 say + "Data"+chr(9)+"Cliente"+chr(9)+"Cfop"+chr(9)+"Saldo Inicial"+chr(9)+"Entrada"+chr(9)+"Saida"+chr(9)+"Saldo"+chr(9)+"Preco de Custo"+chr(9)+"Qtde x Preco Custo"+chr(9)+"Novo Preco de Custo Apos Entrada"
                 @ prow(),pcol() say chr(9)+chr(9)+chr(9)+"Valor Inicial"+chr(9)+"Entradas"+chr(9)+"Vendas"+chr(9)+"Total"+chr(9)+"Saldo x Pc. Custo"+chr(9)+"Diferenca"
              else

              endif
           endif

           if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidades senao diminui
              nQTD_VEND += ESTMP->Quantidade

              if cSINTETICO == "A"
                 @ prow()+1,02 say " "+dtoc(ESTMP->Data)+chr(9)
                 if ESTMP->Es == "S"
                    CLI1->(dbseek(ESTMP->Cod_fc))
                    @ prow()  ,pcol()+1 say left(CLI1->Razao,35)+chr(9)
                 else
                    @ prow()  ,pcol()+1 say "Saida sem Contabilizacao"+chr(9)
                 endif
                 @ prow()  ,pcol()+1 say ESTMP->Cfop+chr(9)
                 @ prow()  ,pcol()+1 say transf(nSALDO_COR,"@E 999999")+chr(9)
              endif

              nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

              if cSINTETICO == "A"
                 @ prow()  ,pcol()+1 say chr(9)+ transf(ESTMP->Quantidade,"@E 999999")+chr(9)+transf(nSALDO_COR,"@R 99999")+chr(9)
                 @ prow()  ,pcol()+1 say transf(nCUSTO_COR,"@E 999,999.99")+chr(9)+Transf(nSALDO_COR*nCUSTO_COR,"@E 999,999.99")
              endif

              nVLR_VEND += nCUSTO_COR * ESTMP->Quantidade // Custo da Venda de Produtos
              //nVLR_VEND += (nCUSTO_COR * ESTMP->Quantidade) // Custo da Venda de Produtos

              if ! CFOPTMP->(dbseek(ESTMP->Cfop)) //Soma o Total de Custo por Cfop
                 if CFOPTMP->(qappend())
                    replace CFOPTMP->Cfop       with ESTMP->Cfop
                    replace CFOPTMP->Quantidade with ESTMP->Quantidade
                    replace CFOPTMP->Preco_cust with (nCUSTO_COR * ESTMP->Quantidade)
                 endif
              else
                 if CFOPTMP->(qrlock())
                    //replace CFOPTMP->Cfop       with ESTMP->Cfop
                    replace CFOPTMP->Quantidade with (CFOPTMP->Quantidade + ESTMP->Quantidade)
                    replace CFOPTMP->Preco_cust with (CFOPTMP->Preco_cust + (nCUSTO_COR * ESTMP->Quantidade))
                 endif
              endif

           else // Quando Entra Mercadoria
              nQTD_ENT += ESTMP->Quantidade

              if ESTMP->Es == "C" // Se For Compra Faz Media Ponderada do Preco de Custo
                 nCUSTO_COR := ( (nSALDO_COR * nCUSTO_COR) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
                 nCUSTO_COR := round(nCUSTO_COR,2)
              Endif

              if cSINTETICO == "A"
                 @ prow()  ,02 say " "+dtoc(ESTMP->Data)+chr(9)
                 if ESTMP->Es == "E"
                    if CLI1->(dbseek(ESTMP->Cod_fc))
                       @ prow()  ,pcol()+1 say left(CLI1->Razao,35)+chr(9)
                    else
                       @ prow() ,pcol()+1 say "Entrada sem Contabilizacao"+chr(9)
                    endif
                 else
                    if ESTMP->Es == "C"
                       FORN->(DbSeek(ESTMP->Cod_fc))
                       @ prow()  ,pcol()+1 say FORN->Razao+chr(9)
                    endif
                 endif
                 @ prow()  ,pcol()+1 say ESTMP->Cfop+chr(9)
                 @ prow()  ,pcol()+1 say transf(nSALDO_COR,"@E 999999")+chr(9)
              endif

              nSALDO_COR := nSALDO_COR + ESTMP->Quantidade

              if cSINTETICO == "A"
                 @ prow()  ,pcol()+1 say transf(ESTMP->Quantidade,"@E 999999") + chr(9)+chr(9) + transf(nSALDO_COR,"@R 99999")+chr(9)
                 if ESTMP->Es == "C"
                    @ prow()  ,pcol()+1 say transf(ESTMP->Preco_cust,"@E 999,999.99")+chr(9)+transf(nSALDO_COR*nCUSTO_COR,"@E 99,999.99")+chr(9)+transf(nCUSTO_COR,"@E 99,999.99")
                 else
                    @ prow()  ,pcol()+1 say transf(nCUSTO_COR,"@E 999,999.99")+chr(9)+transf(nSALDO_COR*nCUSTO_COR,"@E 99,999.99")+chr(9)//transf(nCUSTO_COR,"@E 99,999.99")
                 endif
              endif

              if ESTMP->Es == "C"
                 nVLR_ENT  += ESTMP->Preco_cust * ESTMP->Quantidade
                 nCOMPRAS  += ESTMP->Preco_cust * ESTMP->Quantidade
              else
                 nVLR_ENT  += nCUSTO_COR * ESTMP->Quantidade
                 nCONSIG   += nCUSTO_COR * ESTMP->Quantidade
              endif

              if ! CFOPTMP->(dbseek(ESTMP->Cfop))
                 if CFOPTMP->(qappend())
                    replace CFOPTMP->Cfop       with ESTMP->Cfop
                    replace CFOPTMP->Quantidade with ESTMP->Quantidade
                    if ESTMP->Es == "C"
                       replace CFOPTMP->Preco_cust with (ESTMP->Preco_cust * ESTMP->Quantidade)
                    else
                       replace CFOPTMP->Preco_cust with (nCUSTO_COR * ESTMP->Quantidade)
                    endif
                 endif
              else
                 if CFOPTMP->(qrlock())
                    //replace CFOPTMP->Cfop       with ESTMP->Cfop
                    replace CFOPTMP->Quantidade with (CFOPTMP->Quantidade + ESTMP->Quantidade)
                    if ESTMP->Es == "C"
                       replace CFOPTMP->Preco_cust with (CFOPTMP->Preco_cust + (ESTMP->Preco_cust * ESTMP->Quantidade))
                    else
                       replace CFOPTMP->Preco_cust with (CFOPTMP->Preco_cust + (nCUSTO_COR * ESTMP->Quantidade))
                    endif
                 endif
              endif


           endif

           nVLR_ESTQ := (nSALDO_COR * nCUSTO_COR)
           nEST_INI  := (nSALDO_INI * nCUSTO_INI)

           ESTMP->(dbskip())

           if ESTMP->Produto != cPROD
              @ prow()+1,00 say "  "+chr(9)+zPROD+chr(9)+" "+chr(9)+" "+chr(9)+transf(nQTD_ENT,"@R 999999")+chr(9)+transf(nQTD_VEND,"@R 999999")+chr(9)+chr(9)+transf(nCUSTO_COR,"@E 999,999.99")+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")+chr(9)+transf(nSALDO_COR,"@E 999,999.99")
              @ prow(),pcol() say chr(9)+chr(9)+chr(9)+transf(nEST_INI,"@E 999,999.99")+chr(9)+transf(nVLR_ENT,"@E 999,999.99")+chr(9)+transf(nVLR_VEND,"@E 999,999.99")+chr(9)+transf((nEST_INI+nVLR_ENT)-nVLR_VEND,"@E 999,999.99")+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")+chr(9)+transf(((nEST_INI+nVLR_ENT)-nVLR_VEND)-nVLR_ESTQ,"@E 999,999.99")
			  
			  if month(dFim) == 12
				gravaNaWeb(oServer,cProd,nCUSTO_COR,nSALDO_COR,dFIM,"1")
			  endif
			  
			  if cSINTETICO == "S"
			     INVENT->(dbsetorder(4))
				 INVENT->(dbseek(cProd))
				 nQuant_res := 0
				 nQuant_tt  := 0
				 
				 nQUANT_RES := buscaReservas(cProd)
                 nQUANT_TT   := INVENT->Quant_Atu + nQuant_res + INVENT->Quant_defe + INVENT->Quant_show
				 nQuant_web  := i_totalWeb(oServer,cProd)
				 gravaNoMysql(oServer,cProd,nCUSTO_COR)
				 
				 @ prow(),pcol() say chr(9)+chr(9)+chr(9)+transf(nSaldo_cor,"@R 99999999") + chr(9)+ transf(nQuant_tt,"@R 99999999") + chr(9)+ transf(nQuant_web,"@R 99999999") + chr(9)+ transf(nSaldo_cor - nQuant_tt,"@R 99999999") + chr(9)+ transf(nSaldo_cor - nQuant_web,"@R 99999999") + chr(9)+chr(9)+ transf(nQuant_res,"@R 99999999")+chr(9)+transf(INVENT->quant_atu,"@R 99999999")+Chr(9)+transf(INVENT->quant_defe,"@R 99999999")+chr(9)+transf(INVENT->quant_show,"@R 99999999")

              
//               @ prow() ,pcol()+1 say chr(9)+" "+"Tot Entrada"+chr(9)+transf(nQTD_ENT,"@E 999,999.99")+chr(9)+transf(nVLR_ENT,"@E 999,999.99")+chr(9)+"Saldo"+transf(nSALDO_COR,"@R 999999")+chr(9)+"Estoqe em "+dtoc(dFIM)+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")
              else
                 @ prow()+1,00 say "  "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+""+chr(9)+""+chr(9)+""+chr(9)+""+chr(9)+""
              endif

              //qlineprn()

              cPROD := ESTMP->Produto
              PROD->(dbsetorder(4))
              PROD->(Dbgotop())
              PROD->(dbseek(ESTMP->Produto))
              zPROD := rtrim(PROD->Cod_fabr) + "/ "+rtrim(PROD->Cod_ass)+"    "+rtrim(PROD->Descricao)+"        "+rtrim(PROD->Marca)

              //zPROD := asFAT[nCONT,7]+" "+asFAT[nCONT,8]
              nVLR_VEND_TOT += nVLR_VEND
              nTOT_QTD_VEND += nQTD_VEND
              nVLR_ENT_TOT += nVLR_ENT
              nVLR_ESTQ_TOT += nVLR_ESTQ
              nTT_INI       += (nCUSTO_INI * nSALDO_INI)


              lPRIM := .T.

              nVLR_VEND := 0
              if ESANT->(Dbseek(ESTMP->Produto))
                 nSALDO_COR := ESANT->Quantidade
                 nCUSTO_COR := ESANT->Preco_cust
              else
                 nSALDO_COR := ESANT->Quantidade
                 nCUSTO_COR := ESANT->Preco_cust
              endif

              nSALDO_INI := nSALDO_COR
              nCUSTO_INI := nCUSTO_COR

              nVLR_VEND := 0
              nQTD_VEND := 0
              nVLR_ENT  := 0
              nQTD_ENT  := 0

              nQUANT := 0
              nTOTAL := 0
           endif
       enddo

//       if ESTMP->Produto != cPROD
//          @ prow()+1,00 say "  "+chr(9)+zPROD+chr(9)+" "+chr(9)+" "+chr(9)+"Qtde Saida"+chr(9)+transf(nQTD_VEND,"@R 999999")+chr(9)+transf(nVLR_VEND,"@E 999,999.99")+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")+chr(9)+transf(nCUSTO_COR,"@E 999,999.99")+chr(9)+transf(nSALDO_COR,"@E 999,999.99")
//
//          if cSINTETICO == "S"
//             @ prow() ,pcol()+1 say chr(9)+" "+"Tot Entrada"+chr(9)+transf(nQTD_ENT,"@E 999,999.99")+chr(9)+transf(nVLR_ENT,"@E 999,999.99")+chr(9)+"Saldo"+transf(nSALDO_COR,"@R 999999")+chr(9)+"Estoqe em "+dtoc(dFIM)+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")
//          else
//             @ prow()+1,00 say "  "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+""+chr(9)+""+chr(9)+""+chr(9)+""+chr(9)+""
//          endif
//
//          cPROD := ESTMP->Produto
//          PROD->(dbsetorder(4))
//          PROD->(Dbgotop())
//          PROD->(dbseek(ESTMP->Produto))
//          zPROD := rtrim(PROD->Cod_fabr) + "/ "+rtrim(PROD->Cod_ass)+"    "+rtrim(PROD->Descricao)+"        "+rtrim(PROD->Marca)
//
//          nVLR_VEND_TOT += nVLR_VEND
//          nTOT_QTD_VEND += nQTD_VEND
//          nVLR_ENT_TOT += nVLR_ENT
//          nVLR_ESTQ_TOT += nVLR_ESTQ
//
//
//          lPRIM := .T.
//
//          nVLR_VEND := 0
//          ESANT->(Dbseek(ESTMP->Produto))
//          nSALDO_COR := ESANT->Quantidade
//          nCUSTO_COR := ESANT->Preco_cust
//          nVLR_VEND := 0
//          nQTD_VEND := 0
//          nVLR_ENT  := 0
//          nQTD_ENT  := 0

//          nQUANT := 0
//          nTOTAL := 0
//       endif

//       @ prow()+2,00 say "  "+chr(9)+"Estoque em "+dtoc(dFIM)+chr(9)+" Antes de somar o itens sem Movimento "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+""+chr(9)+transf(nVLR_ESTQ_TOT,"@E 9,999,999.99")+chr(9)+chr(9)+chr(9)+chr(9)
//       @ prow()  ,pcol() say transf(nTT_ANT,"@E 999,999,999.99") +chr(9)+transf(nVLR_ENT_TOT,"@E 999,999,999.99")+chr(9)+transf(nVLR_VEND_TOT,"@E 999,999,999.99")+chr(9)+transf((nTT_ANT+nVLR_ENT_TOT)-nVLR_VEND_TOT,"@E 999,999,999.99")
//       @ prow()  ,pcol() say chr(9)+transf(nVLR_ESTQ_TOT,"@E 999,999,999.99")+chr(9)+transf(((nTT_ANT+nVLR_ENT_TOT)-nVLR_VEND_TOT)-nVLR_ESTQ_TOT,"@E 999,999,999.99")
//       @ prow()+1,00 say "  "+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)
//       @ prow()  ,pcol() say "Compras/Importacoes"+chr(9)+transf(nCOMPRAS,"@E 999,999,999.99")
//       @ prow()+1,00 say "  "+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)
//       @ prow()  ,pcol() say "Entradas de Consig/Devolucoes/Remessas/Outras"+chr(9)+transf(nCONSIG ,"@E 999,999,999.99")
//       @ prow()+1,00 say "  "+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)
//       @ prow()  ,pcol() say "Vendas/Consig/Brindes/Remessas/Outras"+chr(9)+transf(nVLR_VEND_TOT,"@E 999,999,999.99")
//       @ prow()+1,00 say "  "+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)
//       @ prow()  ,pcol() say "Custo da Mercadoria Vendida"+chr(9)+transf(nVLR_VEND_TOT-nCONSIG,"@E 999,999,999.99")


       @ prow()+2,00 say "  "+chr(9)+"Produtos sem movimento no periodo informado"
       @ prow()+1,00 say ""



       PROD->(dbgotop())
       While ! PROD->(Eof())

          if right(PROD->Codigo,5) == "     "
             PROD->(dbskip())
             loop
          endif


          if ESTMP->(dbseek(right(PROD->Codigo,5)))
             PROD->(Dbskip())
             loop
          else
             if ESANT->(dbseek(right(PROD->Codigo,5)))
                @ prow()+1,00 say "  "+chr(9)+rtrim(PROD->Cod_fabr) + "/ "+rtrim(PROD->Cod_ass)+"    "+rtrim(PROD->Descricao)+"        "+rtrim(PROD->Marca)+chr(9)+" "+chr(9)+" "+chr(9)+"Qtde Saida"+chr(9)+transf(0,"@R 999999")+chr(9)+transf(0,"@E 999,999.99")+chr(9)+transf(ESANT->Quantidade*ESANT->Preco_cust,"@E 999,999.99")+chr(9)+transf(ESANT->preco_cust,"@E 999,999.99")+chr(9)+transf(ESANT->Quantidade,"@E 999,999.99")
                nVLR_ESTQ_TOT += (ESANT->Quantidade * ESANT->Preco_cust)
				if month(dFim) == 12
					gravaNaWeb(oServer,right(PROD->Codigo,5),ESANT->preco_cust,ESANT->Quantidade,dFIM,"0")
			    endif
				if cSINTETICO == "S"
					//gravaNoMysql(oServer,right(PROD->Codigo,5),ESANT->preco_cust)
				endif	
             endif
          endif


          PROD->(Dbskip())
       enddo

       PROD->(dbsetorder(4))
       PROD->(dbgotop())


       ESANT->(dbgotop())
       While ! ESANT->(Eof())

          if PROD->(dbseek(right(ESANT->Produto,5)))
             ESANT->(Dbskip())
             loop
          else
             //if ESANT->(dbseek(right(PROD->Codigo,5)))
                @ prow()+1,00 say "  "+chr(9)+ ESANT->Produto + "/ Qsys Code "+rtrim("Item deletado do cadastro!")+"        "+" "+chr(9)+" "+chr(9)+" "+chr(9)+"Qtde Saida"+chr(9)+transf(0,"@R 999999")+chr(9)+transf(0,"@E 999,999.99")+chr(9)+transf(ESANT->Quantidade*ESANT->Preco_cust,"@E 999,999.99")+chr(9)+transf(ESANT->preco_cust,"@E 999,999.99")+chr(9)+transf(ESANT->Quantidade,"@E 999,999.99")
                nVLR_ESTQ_TOT += (ESANT->Quantidade * ESANT->Preco_cust)
             //endif
          endif

          ESANT->(Dbskip())
       enddo

       @ prow()+2,00 say "  "+chr(9)+"Quantidade Total de Saidas"+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+transf(nTOT_QTD_VEND,"@R 999999")+chr(9)+transf(nVLR_VEND_TOT,"@E 999,999.99")//+chr(9)+"Estoque em "+dtoc(dFIM)+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")

       @ prow()+2,00 say "  "+chr(9)+"Estoque em "+dtoc(dFIM)+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+""+chr(9)+transf(nVLR_ESTQ_TOT,"@E 9,999,999.99")+chr(9)+chr(9)+chr(9)+chr(9)
       @ prow()  ,pcol() say transf(nTT_ANT,"@E 999,999,999.99") +chr(9)+transf(nVLR_ENT_TOT,"@E 999,999,999.99")+chr(9)+transf(nVLR_VEND_TOT,"@E 999,999,999.99")+chr(9)+transf((nTT_ANT+nVLR_ENT_TOT)-nVLR_VEND_TOT,"@E 999,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf(nVLR_ESTQ_TOT,"@E 999,999,999.99")+chr(9)+transf(((nTT_ANT+nVLR_ENT_TOT)-nVLR_VEND_TOT)-nVLR_ESTQ_TOT,"@E 999,999,999.99")
       @ prow()+1,00 say "  "+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)
       @ prow()  ,pcol() say "Compras/Importacoes"+chr(9)+transf(nCOMPRAS,"@E 999,999,999.99")
       @ prow()+1,00 say "  "+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)
       @ prow()  ,pcol() say "Entradas de Consig/Devolucoes/Remessas/Outras"+chr(9)+transf(nCONSIG ,"@E 999,999,999.99")
       @ prow()+1,00 say "  "+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)
       @ prow()  ,pcol() say "Vendas/Consig/Brindes/Remessas/Outras"+chr(9)+transf(nVLR_VEND_TOT,"@E 999,999,999.99")
       @ prow()+1,00 say "  "+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)
       @ prow()  ,pcol() say "Custo da Mercadoria Vendida"+chr(9)+transf(nVLR_VEND_TOT-nCONSIG,"@E 999,999,999.99")





       nCONSIG  := 0
       nCOMPRAS := 0


       @ prow()+2,00 say "  "+chr(9)+"Resumo por CFOP"

       CFOPTMP->(dbgotop())
       while ! CFOPTMP->(eof())

          @ prow()+1,00 say " "+chr(9)+chr(9)+CFOPTMP->Cfop+" "+ chr(9)+transf(CFOPTMP->Quantidade,"@R 99999999")+chr(9)+transf(CFOPTMP->Preco_cust,"@E 999,999,999.99")


         CFOPTMP->(dbskip())
       enddo





       nQUANT := 0
       nTOTAL := 0
       nVLR_VEND_TOT := 0
       nVLR_ENT_TOT := 0
       nVLR_ESTQ_TOT := 0
   endif

   if ! empty(cPROD)
      ITEN_FAT->(dbclearfilter())
      LANC->(dbclearfilter())
      MOVIMENT->(dbclearfilter())
   endif


   qstopPrn(.F.)

return

static function i_sald_anter
    local nTOTAL     := 0
    local nSALDO_COR := 0
    local nSALDO_INI := 0
    local nCUSTO_INI := 0
    local nCUSTO_COR := 0
    local nVALOR     := 0

    local nVLR_VEND  := 0
    local nVLR_VEND_TOT  := 0
    local nVLR_ENT_TOT  := 0
    local nVLR_ESTQ_TOT  := 0
    local nQTD_VEND  := 0

    local nVLR_ENT   := 0
    local nVLR_ESTQ  := 0
    local nQTD_ENT   := 0

    local nDESC      := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local lPRIM := .T.
    local zPROD := space(50)
    local nResult := 0

    ESTMP->(__dbzap())
    ESANT->(__dbzap())
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   qmensa("Aguarde... Processando ...")


   FAT->(Dbsetorder(FAT->(OrdCount())))
   FAT->(dbgotop())

   //ITEN_FAT->(dbsetorder(ITEN_FAT->(OrdCount())))
   //ITEN_FAT->(dbgotop())

   do while ! FAT->(eof())  .and. FAT->Dt_emissao < dINI // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_Fatura) .and. FAT->Es == "S"
         FAT->(DbSkip())
         loop
      endif

      if left(FAT->Cod_cfop,4) $ "5905-6905-1905-2905-1906-2906"
         FAT->(DbSkip())
         loop
      endif

      ITEN_FAT->(dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
         if ESTMP->(qappend())
            replace ESTMP->Data       with FAT->Dt_emissao
            replace ESTMP->Produto    with right(ITEN_FAT->Cod_prod,5)
            replace ESTMP->Quantidade with ITEN_FAT->Quantidade
            replace ESTMP->Es         with FAT->Es
         endif
         ITEN_FAT->(Dbskip())
      enddo
      FAT->(dbskip())
   enddo

   MOVIMENT->(dbsetorder(MOVIMENT->(OrdCount()))) // data de emissao
   MOVIMENT->(dbgotop())

   do while ! MOVIMENT->(eof())

         if MOVIMENT->Contabil
            MOVIMENT->(dbSkip())
            Loop
         endif

         if MOVIMENT->Data >= dINI
            MOVIMENT->(dbSkip())
            Loop
         endif

         if MOVIMENT->Tipo == "E"
            cDESCRICAO := "ENTRA"
         else
            cDESCRICAO := "SAIDA"
         endif

         if ESTMP->(qappend())
            replace ESTMP->Data       with MOVIMENT->Data
            replace ESTMP->Produto    with right(MOVIMENT->Cod_prod,5)
            replace ESTMP->Quantidade with MOVIMENT->Quantidade
            replace ESTMP->Es         with MOVIMENT->Tipo
         endif

         MOVIMENT->(dbskip())
   enddo

   PEDIDO->(dbsetorder(PEDIDO->(OrdCount())))
   PEDIDO->(Dbgotop())
   do while ! PEDIDO->(eof())  .and. PEDIDO->Data_ped < dINI  // condicao principal de loop

         if ! PEDIDO->Interface
            PEDIDO->(Dbskip())
            loop
         endif

         FORN->(dbseek(PEDIDO->Cod_forn))

         LANC->(Dbgotop())
         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

             if ESTMP->(qappend())
                replace ESTMP->Data        with PEDIDO->Data_ped
                replace ESTMP->Produto     with right(LANC->Cod_prod,5)
                replace ESTMP->Quantidade  with LANC->Quant
                replace ESTMP->Preco_cust  with LANC->Preco
                replace ESTMP->Es          with "C"
             endif


             LANC->(Dbskip())
         enddo
         PEDIDO->(dbskip())
   enddo

   ESTMP->(Dbsetorder(1))
   ESTMP->(Dbgotop())

   //classifica a matriz por descricao do produto
   //asFAT := asort(aFAT,,,{|x,y| x[2] + x[1] + x[3] < y[2] + y[1] + y[3]  })

   PROD->(dbsetorder(4))
   PROD->(Dbgotop())
   cPROD := ESTMP->Produto
   nSALDO_COR := 0
   nCUSTO_COR := 0
   nVLR_ESTQ  := 0
   nVLR_ESTQ_TOT := 0

   do while ! ESTMP->(eof())

       if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidade senao diminui

          nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
       else
          if ESTMP->Es $ "E-C"
             if ESTMP->Es == "C"
                nCUSTO_COR := ( (nSALDO_COR * nCUSTO_COR) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
                nCUSTO_COR := round(nCUSTO_COR,2)
             Endif

             nSALDO_COR := nSALDO_COR + ESTMP->Quantidade
          endif

       endif

       nVLR_ESTQ := (nSALDO_COR * nCUSTO_COR)
       nVLR_ESTQ := round(nVLR_ESTQ,2)

       ESTMP->(dbskip())

       if ESTMP->Produto != cPROD

          if ESANT->(QAppend())
             replace ESANT->Produto    with cPROD
             replace ESANT->Quantidade with nSALDO_COR
             replace ESANT->Preco_cust with nCUSTO_COR
          endif

          cPROD := ESTMP->Produto

          nVLR_ESTQ_TOT += nVLR_ESTQ

          nVLR_ESTQ := 0

          nSALDO_COR := 0
          nCUSTO_COR := 0
       endif
   enddo

   nRESULT := nVlr_Estq_tot
   nVLR_ESTQ_TOT := 0


   if ! empty(cPROD)
      ITEN_FAT->(dbclearfilter())
      LANC->(dbclearfilter())
      MOVIMENT->(dbclearfilter())
   endif

return nResult

static function faz_index(cProd)
local cTime := ""

   if ! quse(XDRV_CL,"FAT")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CL,"ITEN_FAT")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CP,"PEDIDO")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CP,"LANC")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_ES,"MOVIMENT")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif
   
   if ! quse(XDRV_ES,"AVARIADO")
      qmensa("N„o foi poss¡vel abrir AVARIADO.DBF !! Tente novamente.")
      return
   endif

   select FAT

   cTIME := time()

   if empty(cProd)
      index on dtos(dt_emissao) tag emiss TO (XDRV_ES + "ES510A.TMP")
   else	  
      index on CODIGO           tag id    TO (XDRV_ES + "ES510A.TMP")
   endif
   dbsetindex(XDRV_ES + "es510A.TMP")


   select ITEN_FAT
    
   if empty(cProd)	
      index on NUM_FAT  tag num       TO (XDRV_ES + "ES510B.TMP")
   else	  
      index on COD_PROD tag cod_prod2 TO (XDRV_ES + "ES510B.TMP")
   endif	  
   dbsetindex(XDRV_ES + "ES510B.TMP")

   select PEDIDO

   if empty(cProd)	
      index on dtos(data_ped) tag dtp TO (XDRV_ES + "ES510C.TMP")
   else	  
      index on CODIGO tag ID TO (XDRV_ES + "ES510C.TMP")
   endif
   dbsetindex(XDRV_ES + "ES510C.TMP")


   select LANC
   
   if empty(cProd)
      index on cod_ped  tag UM TO (XDRV_ES + "ES510D.TMP")
   else
      index on cod_prod tag UM TO (XDRV_ES + "ES510D.TMP")
   endif	
   dbsetindex(XDRV_ES + "es510D.TMP")


   select MOVIMENT

   if empty(cProd)
      index on data     tag UM TO (XDRV_ES + "ES510E.TMP")
   else	  
      index on cod_prod tag UM TO (XDRV_ES + "ES510E.TMP")
   endif
   dbsetindex(XDRV_ES + "es510E.TMP")
   
   select AVARIADO

   if empty(cProd)
      index on data     tag UM TO (XDRV_ES + "ES510F.TMP")
   else	  
      index on cod_prod tag UM TO (XDRV_ES + "ES510F.TMP")
   endif
   dbsetindex(XDRV_ES + "ES510F.TMP")



   if neterr()
      qmensa("Erro ao indexar arquivos temporarios!","BL")
      return .F.
   endif


return

static function erase_index

   erase(XDRV_ES+"ES510A.TMP")
   erase(XDRV_ES+"ES510B.TMP")
   erase(XDRV_ES+"ES510C.TMP")
   erase(XDRV_ES+"ES510D.TMP")
   erase(XDRV_ES+"ES510E.TMP")
   erase(XDRV_ES+"COD_PROD.TMP")

   if neterr()
      qmensa("Erro ao deletar arquivos temporarios!","BL")
      return .F.
   endif

return

static function estoquePorProduto




return


static function i_reserva
local aPED := {}
local aPEDS := {}
local lTEM := .F.
local cLOTE   := space(10)
local cFILIAL := space(4)
local nQTY    := 0
local cPROD   := space(5)
local nCONT   := 1

ITEN_FAT->(dbsetorder(2))
FAT->(dbsetorder(11))
FAT->(dbgotop())

aReservas := {}

Do while ! FAT->(eof()) .and. empty(FAT->Num_fatura)
    if FAT->es != "S"
      FAT->(dbskip())
	  loop
   endif
   
   if left(FAT->Cod_cfop,4) $ "5905-6905"
      FAT->(dbskip())
	  loop
   endif

   ITEN_FAT->(Dbseek(FAT->Codigo))

   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      aadd(aPED,{ITEN_FAT->Cod_prod,FAT->Filial,ITEN_FAT->Num_Lote,ITEN_FAT->Quantidade})
      lTEM := .T.
      ITEN_FAT->(dbskip())
   enddo


   FAT->(Dbskip())
enddo

asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

if lTEM
    cPROD   := asPED[1,1]
    cFILIAL := asPED[1,2]
    cLOTE   := asPED[1,3]
    nQTY    := 0

    nCONT := 1
    do while  nCONT <= len(asPED)

        nQTY += asPED[nCONT,4]

        nCONT++
        if nCONT > len(asPED)
           nCONT := len(asPED)
           exit
        endif

        if asPED[nCONT,1] != cPROD
		   aadd(aReservas,{cPROD,cFILIAL,cLOTE,nQTY}) 

           cPROD   := asPED[nCONT,1]
           cFILIAL := asPED[nCONT,2]
           cLOTE   := asPED[nCONT,3]
           nQTY    := 0
        endif
    enddo
	aadd(aReservas,{cPROD,cFILIAL,cLOTE,nQTY})

endif

aPED := {}
asPED := {}
return

static function buscaReservas(cPROD)
local nKey := 0

       nKey := ascan(aReservas,{|ckey| cKey[1] == cPROD})

       if nKey > 0
          return aReservas[nKey,4] 
       endif

return 0


static function i_totalWeb(oServer,cProd)
   local oRow
   local oQuery
   local ncont
   local cQuery := ""
   local nSaldo := 0
   
   
   
   cQuery := "select "
   cQuery += " prod.id, "
   cQuery += " (select  sum(quantidade * if(nf.tipo_nota = 1,(-1),(1)) ) as qtde from item_nota_fiscal item "
   cQuery += "  join nota_fiscal nf on nf.id = item.nota_fiscal_id "
   cQuery += "  where produto_id = prod.id) as entradas_menos_saidas, "
   cQuery += " (select sum(quantidade) from item_compra where produto_id = prod.id) as comprado, "
   cQuery += " (select sum(quantidade * if(tipo='B',(-1),(1) ) ) from ajuste_saldo_estoque "
   cQuery += "  where produto_id = prod.id) as ajustes "
   
/*   (select sum(mov.quantidade) from movimentacoes as mov
    join item_pedido_venda as item on item.id = mov.item_pedido_id
    join expedicoes as exp on exp.id = mov.expedicao_id
    where exp.dataDeFaturamento is null and item.produto_id = prod.id and mov.tipo_movimento = 1) as expedicao,
    (select sum(quantidade) from avarias where produto_id = prod.id) as avarias,
    (select sum(quantidade) from show_room where produto_id = prod.id) as showroom*/
   
   cQuery += " from produtos prod "
   cQuery += " where prod.id ="+alltrim(str(val(cProd)))
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
   nCont := 1
   
   do while nCont <= oQuery:LastRec() 	 
      oRow := oQuery:getRow(nCont)
	  nSaldo := oRow:fieldget('comprado') + oRow:fieldget('entradas_menos_saidas') + oRow:fieldget('ajustes')
	  nCont++
   enddo


return nSaldo


static function gravaNoMysql(oServer,cProd,nPrecoCusto)
   local oRow
   local oQuery
   local cQuery := ""
   
   
   
   cQuery := "update "
   cQuery += " custo_qsys_vs_web "
   cQuery += " set custo_qsys = " +alltrim(transform(nPrecoCusto,"@R 9999999999.99"))
   cQuery += " where produto_id = " + alltrim(str(val(cProd)))
   
   //alert(cQuery)
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   

return

static function gravaNaWeb(oServer,cProd,nPrecoCusto,nQuantidade,dIni,cMov)
   local oRow
   local oQuery
   local cQuery := ""
   
   
   cQuery := "update "
   cQuery += " invent "
   cQuery += " set preco_custo = " +alltrim(transform(nPrecoCusto,"@R 9999999999.99"))
   cQuery += ", quantidade = " +alltrim(transform(nQuantidade,"@R 9999999999.99"))
   cQuery += ", movimentou = " + cMov 
	
   cQuery += " where produto_id = " + alltrim(str(val(cProd)))
   
   //alert(cQuery)
   
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   

return


