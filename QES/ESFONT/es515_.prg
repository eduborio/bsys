////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO DE 2005
// OBS........:
// ALTERACOES.:
function es515

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private cDESCRICAO := space(35)                   // titulo do relatorio
private nSALDO_INI := 0                // titulo do relatorio
private nSALDO_ATU := 0               // titulo do relatorio
private nPC_INI    := 0               // Preco de Custo Inicial
private nPC_CORRENTE  := 0            // P.C. Corrente
private sBLOC1  := qlbloc("B510B","QBLOC.GLO")


private dINI
private dFIM
private cPROD := space(5)
private cSINTETICO := space(1)
private aEDICAO := {}             // vetor para os campos de entrada de dados

if ! quse(XDRV_ES,"ESTMP",{"ESTMP"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"ESANT",{"ESANT1"},"E")
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
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_sald_anter()

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

           if empty(cPROD)
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

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   if ! empty(cPROD)
      ITEN_FAT->(Dbsetfilter({||ITEN_FAT->Cod_prod == cPROD},'ITEN_FAT->Cod_prod == cPROD'))
   endif

   if ! empty(cPROD)
      LANC->(Dbsetfilter({||LANC->Cod_prod == cPROD},'LANC->Cod_prod == cPROD'))
   endif

   if ! empty(cPROD)
      MOVIMENT->(Dbsetfilter({||MOVIMENT->Cod_prod == cPROD},'MOVIMENT->Cod_prod == cPROD'))
   endif




   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   PEDIDO->(dbsetorder(1)) // data de emissao
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(Dbseek(dtos(dINI)))
   set softseek off
   LANC->(dbsetorder(1))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nTOTAL     := 0
    local nSALDO_COR := 0
    local nSALDO_INI := 0
    local nCUSTO_INI := 0
    local nCUSTO_COR := 0
    local nVALOR     := 0

    local nVLR_VEND  := 0
    local nVLR_VEND_TOT  := 0
    local nQTD_VEND      := 0
    local nVLR_ENT_TOT  := 0
    local nVLR_ESTQ_TOT  := 0
    local nTOT_QTD_VEND  := 0

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
    local nPERC      := 0
    local lTEM := .T.
    local lPRIM := .T.
    local zPROD := space(50)

    ESTMP->(__dbzap())
    CFOPTMP->(__dbzap())
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
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

      //qgirabarra()


         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
             nDESC := nVALOR * (FAT->Aliq_desc/100)
             nVALOR := nVALOR - nDESC

             if ESTMP->(qappend())
                replace ESTMP->Data       with FAT->Dt_emissao
                replace ESTMP->Produto    with right(PROD->Codigo,5)
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
   ESTMP->(DbCommit())



   //MOVIMENT->(dbsetfilter({|| MOVIMENT->Contabil == .F.},'MOVIMENT->Contabil == .F.'))
   MOVIMENT->(dbsetorder(2)) // data de emissao
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


         PROD->(dbsetorder(4))
         PROD->(dbseek(MOVIMENT->Cod_Prod))
         nVALOR := MOVIMENT->Val_uni * MOVIMENT->Quantidade

         if MOVIMENT->Tipo == "E"
            cDESCRICAO := "ENTRA"
         else
            cDESCRICAO := "SAIDA"
         endif

         //aadd(aFAT,{dtos(MOVIMENT->Data),right(PROD->Codigo,5)," ","    ",MOVIMENT->Quantidade,MOVIMENT->Val_uni,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,MOVIMENT->Tipo,cDESCRICAO,dtoc(MOVIMENT->Data)})
         //aadd(aFAT,{dtos(MOVIMENT->Data),right(PROD->Codigo,5),"","",MOVIMENT->Quantidade,MOVIMENT->Val_uni,"","",nVALOR,MOVIMENT->Tipo,cDESCRICAO,dtoc(MOVIMENT->Data)})
         if ESTMP->(qappend())
            replace ESTMP->Data       with MOVIMENT->Data
            replace ESTMP->Produto    with right(PROD->Codigo,5)
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
   ESTMP->(dbcommit())


   do while ! PEDIDO->(eof())  .and. PEDIDO->Data_ped >= dINI .and. PEDIDO->Data_ped <= dFIM  // condicao principal de loop

      //qgirabarra()

     // qmensa("Aguarde... Processando ...")

         if ! PEDIDO->Interface
            PEDIDO->(Dbskip())
            loop
         endif

         FORN->(dbseek(PEDIDO->Cod_forn))

         LANC->(Dbgotop())
         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(LANC->Cod_Prod))
             nVALOR := LANC->Preco * LANC->Quant

            // aadd(aFAT,{dtos(PEDIDO->Data_ped),right(PROD->Codigo,5),PEDIDO->Numero_nf,alltrim(PEDIDO->Cfop),LANC->Quant,LANC->Preco,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,"C",left(FORN->Razao,35),dtoc(PEDIDO->Data_ped)})
            // aadd(aFAT,{dtos(PEDIDO->Data_ped),right(PROD->Codigo,5),PEDIDO->Numero_nf,alltrim(PEDIDO->Cfop),LANC->Quant,LANC->Preco,"","",nVALOR,"C",left(FORN->Razao,35),dtoc(PEDIDO->Data_ped)})
             if ESTMP->(qappend())
                replace ESTMP->Data        with PEDIDO->Data_ped
                replace ESTMP->Produto     with right(PROD->Codigo,5)
                replace ESTMP->Nota        with PEDIDO->Numero_nf
                replace ESTMP->Cfop        with PEDIDO->Cfop
                replace ESTMP->Quantidade  with LANC->Quant
                replace ESTMP->Preco_cust  with LANC->Preco
                replace ESTMP->Es          with "C"
                replace ESTMP->Cod_fc      with PEDIDO->Cod_forn
             endif


             nPERC += nVALOR
             LANC->(Dbskip())
             lTEM := .T.
         enddo
         PEDIDO->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   ESTMP->(Dbcommit())

   ESTMP->(Dbgotop())
   ESTMP->(Dbsetorder(1))
   //classifica a matriz por descricao do produto
   //asFAT := asort(aFAT,,,{|x,y| x[2] + x[1] + x[3] < y[2] + y[1] + y[3]  })
   if lTEM
       cPROD := ESTMP->Produto
       PROD->(dbsetorder(4))
       PROD->(Dbgotop())
       PROD->(dbseek(ESTMP->Produto))
       zPROD := rtrim(PROD->Cod_fabr) + "/ "+rtrim(PROD->Cod_ass)+"    "+rtrim(PROD->Descricao)+"        "+rtrim(PROD->Marca)
       ESANT->(Dbseek(ESTMP->Produto))
       nSALDO_COR := ESANT->Quantidade
       nSALDO_TER := ESANT->Qty_ter

       lPRIM := .T.
       nCONT := 1
       do while ! ESTMP->(eof())

           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say + "  "+chr(9)+cTITULO+" 515"
              @ prow()+1,0 say + ""    +chr(9)+""       +chr(9)+""    +chr(9)+""    +chr(9)+"Local"         +chr(9)+""       +chr(9)+""     +chr(9)+""           +chr(9)+chr(9)+"Terceiros"     +chr(9)+""       +chr(9)+""     +chr(9)+""
              @ prow()+1,0 say + "Data"+chr(9)+"Cliente"+chr(9)+"Cfop"+chr(9)+"Doc."+chr(9)+"Saldo Anterior"+chr(9)+"Entrada"+chr(9)+"Saida"+chr(9)+"Saldo Atual"+chr(9)+chr(9)+"Saldo Anterior"+chr(9)+"Entrada"+chr(9)+"Saida"+chr(9)+"Saldo Atual"
           endif

           if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidades senao diminui

              @ prow()+1,02 say " "+dtoc(ESTMP->Data)+chr(9)

              if ESTMP->Es == "S"
                 CLI1->(dbseek(ESTMP->Cod_fc))
                 @ prow()  ,pcol()+1 say left(CLI1->Razao,35)+chr(9)
              else
                 @ prow()  ,pcol()+1 say "Saida sem Contabilizacao"+chr(9)
              endif

              @ prow()  ,pcol()+1 say ESTMP->Cfop+chr(9)
              @ prow()  ,pcol()+1 say "NF "+ESTMP->Nota+chr(9)
              @ prow()  ,pcol()+1 say transf(nSALDO_COR,"@E 999999")+chr(9)

              nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
              @ prow()  ,pcol()+1 say chr(9)+transf(ESTMP->Quantidade,"@E 999999")+chr(9)+transf(nSALDO_COR,"@R 99999")

              @ prow()  ,pcol()+1 say chr(9)+chr(9)+transf(nSALDO_TER,"@E 999999")

              if ESTMP->Cfop $ "5905-6905"
                 nSALDO_TER := nSALDO_TER + ESTMP->Quantidade
                 @ prow()  ,pcol()+1 say chr(9)+transf(ESTMP->Quantidade,"@E 999999")+chr(9)+chr(9)+transf(nSALDO_TER,"@R 99999")
              else
                 @ prow()  ,pcol()+1 say chr(9)+chr(9)+chr(9)+transf(nSALDO_TER,"@R 99999")
              endif


//              if ! CFOPTMP->(dbseek(ESTMP->Cfop))
//                 if CFOPTMP->(qappend())
//                    replace CFOPTMP->Cfop       with ESTMP->Cfop
//                    replace CFOPTMP->Quantidade with ESTMP->Quantidade
//                    replace CFOPTMP->Preco_cust with (nCUSTO_COR * ESTMP->Quantidade)
//                 endif
//              else
//                 if CFOPTMP->(qrlock())
//                    replace CFOPTMP->Quantidade with (CFOPTMP->Quantidade + ESTMP->Quantidade)
//                    replace CFOPTMP->Preco_cust with (CFOPTMP->Preco_cust + (nCUSTO_COR * ESTMP->Quantidade))
//                 endif
//              endif

//              CFOPTMP->(dbcommit())


           else
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
              @ prow()  ,pcol()+1 say "NF "+ESTMP->Nota+chr(9)
              @ prow()  ,pcol()+1 say transf(nSALDO_COR,"@E 999999")+chr(9)

              nSALDO_COR := nSALDO_COR + ESTMP->Quantidade

              @ prow()  ,pcol()+1 say transf(ESTMP->Quantidade,"@E 999999") + chr(9) + chr(9)+transf(nSALDO_COR,"@R 99999")

              @ prow()  ,pcol()+1 say chr(9)+chr(9)+transf(nSALDO_TER,"@E 999999")

              if ESTMP->Cfop $ "1906-2906"
                 nSALDO_TER := nSALDO_TER - ESTMP->Quantidade
                 @ prow()  ,pcol()+1 say chr(9)+chr(9)+transf(ESTMP->Quantidade,"@E 999999") + chr(9)+transf(nSALDO_TER,"@R 99999")
              else
                 @ prow()  ,pcol()+1 say chr(9)+chr(9)+chr(9)+transf(nSALDO_TER,"@R 99999")
              endif


//              if ! CFOPTMP->(dbseek(ESTMP->Cfop))
//                 if CFOPTMP->(qappend())
//                    replace CFOPTMP->Cfop       with ESTMP->Cfop
//                    replace CFOPTMP->Quantidade with ESTMP->Quantidade
//                    replace CFOPTMP->Preco_cust with (nCUSTO_COR * ESTMP->Quantidade)
//                 endif
//              else
//                 if CFOPTMP->(qrlock())
//                    //replace CFOPTMP->Cfop       with ESTMP->Cfop
//                    replace CFOPTMP->Quantidade with (CFOPTMP->Quantidade + ESTMP->Quantidade)
//                    replace CFOPTMP->Preco_cust with (CFOPTMP->Preco_cust + (nCUSTO_COR * ESTMP->Quantidade))
//                 endif
//              endif

//              CFOPTMP->(dbcommit())


           endif

           ESTMP->(dbskip())

           if ESTMP->Produto != cPROD
              @ prow()+1,00 say "  "+chr(9)+zPROD+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+chr(9)+chr(9)+transf(nSALDO_COR,"@R 9999999")+chr(9)+chr(9)+chr(9)+Chr(9)+chr(9)+transf(nSALDO_TER,"@R 9999999")+chr(9)+Transf(nSALDO_TER+nSALDO_COR,"@R 99999999")

              qlineprn()

              cPROD := ESTMP->Produto
              PROD->(dbsetorder(4))
              PROD->(Dbgotop())
              PROD->(dbseek(ESTMP->Produto))
              zPROD := rtrim(PROD->Cod_fabr) + "/ "+rtrim(PROD->Cod_ass)+"    "+rtrim(PROD->Descricao)+"        "+rtrim(PROD->Marca)


              ESANT->(Dbseek(ESTMP->Produto))
              nSALDO_COR := ESANT->Quantidade
              nSALDO_TER := ESANT->Qty_ter

              @ prow()+1,00 say " "
              @ prow()+1,00 say " "

           endif
       enddo

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
             endif
          endif


          PROD->(Dbskip())
       enddo



//       @ prow()+2,00 say "  "+chr(9)+"Quantidade Total de Saidas"+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+transf(nTOT_QTD_VEND,"@R 999999")+chr(9)+transf(nVLR_VEND_TOT,"@E 999,999.99")//+chr(9)+"Estoque em "+dtoc(dFIM)+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")


//       @ prow()+2,00 say "  "+chr(9)+"Estoque em "+dtoc(dFIM)+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+""+chr(9)+transf(nVLR_ESTQ_TOT,"@E 9,999,999.99")

//       @ prow()+2,00 say "  "+chr(9)+"Resumo por CFOP"

//       CFOPTMP->(dbgotop())
//       while ! CFOPTMP->(eof())

//          @ prow()+1,00 say " "+chr(9)+chr(9)+CFOPTMP->Cfop+" "+ chr(9)+transf(CFOPTMP->Quantidade,"@R 99999999")+chr(9)+transf(CFOPTMP->Preco_cust,"@E 999,999,999.99")


//       CFOPTMP->(dbskip())
//       enddo



   endif

return

static function i_sald_anter
    local nSALDO_COR := 0
    local nSALDO_TER := 0
    local lTEM := .T.
    local cPROD := ""

    ESTMP->(__dbzap())
    ESANT->(__dbzap())

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("Aguarde... Processando ...")


   FAT->(Dbsetorder(2))
   FAT->(dbgotop())
   do while ! FAT->(eof())  .and. FAT->Dt_emissao < dINI // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_Fatura) .and. FAT->Es == "S"
         FAT->(DbSkip())
         loop
      endif

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))

             if ESTMP->(qappend())
                replace ESTMP->Data       with FAT->Dt_emissao
                replace ESTMP->Produto    with right(PROD->Codigo,5)
                replace ESTMP->Nota       with FAT->Num_fatura
                replace ESTMP->Cfop       with alltrim(FAT->Cod_cfop)
                replace ESTMP->Quantidade with ITEN_FAT->Quantidade
                replace ESTMP->Es         with FAT->Es
                replace ESTMP->Cod_fc     with FAT->Cod_cli
             endif

             ITEN_FAT->(Dbskip())
         enddo
         FAT->(dbskip())
   enddo
   ESTMP->(DbCommit())



   MOVIMENT->(dbsetorder(2)) // data de emissao
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


         PROD->(dbsetorder(4))
         PROD->(dbseek(MOVIMENT->Cod_Prod))

         if MOVIMENT->Tipo == "E"
            cDESCRICAO := "ENTRA"
         else
            cDESCRICAO := "SAIDA"
         endif

         if ESTMP->(qappend())
            replace ESTMP->Data       with MOVIMENT->Data
            replace ESTMP->Produto    with right(PROD->Codigo,5)
            replace ESTMP->Nota       with ""
            replace ESTMP->Cfop       with ""
            replace ESTMP->Quantidade with MOVIMENT->Quantidade
            replace ESTMP->Es         with MOVIMENT->Tipo
            replace ESTMP->Cod_fc     with cDESCRICAO
         endif

         MOVIMENT->(dbskip())
   enddo
   ESTMP->(dbcommit())


   PEDIDO->(dbsetorder(1))
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

             PROD->(dbsetorder(4))
             PROD->(dbseek(LANC->Cod_Prod))

             if ESTMP->(qappend())
                replace ESTMP->Data        with PEDIDO->Data_ped
                replace ESTMP->Produto     with right(PROD->Codigo,5)
                replace ESTMP->Nota        with PEDIDO->Numero_nf
                replace ESTMP->Cfop        with PEDIDO->Cfop
                replace ESTMP->Quantidade  with LANC->Quant
                replace ESTMP->Preco_cust  with LANC->Preco
                replace ESTMP->Es          with "C"
                replace ESTMP->Cod_fc      with PEDIDO->Cod_forn
             endif

             LANC->(Dbskip())
         enddo
         PEDIDO->(dbskip())
   enddo
   ESTMP->(Dbcommit())

   lTEM := .T.

   ESTMP->(Dbgotop())
   ESTMP->(Dbsetorder(1))

   if lTEM
       cPROD := ESTMP->Produto
       nSALDO_COR := 0
       nSALDO_TER := 0

       do while ! ESTMP->(eof())

           if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidade senao diminui

              nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

              if ESTMP->Cfop $ "5905-6905"
                 nSALDO_TER := nSALDO_TER + ESTMP->Quantidade
              endif
           else
              nSALDO_COR := nSALDO_COR + ESTMP->Quantidade

              if ESTMP->Cfop $ "1906-2906"
                 nSALDO_TER := nSALDO_TER - ESTMP->Quantidade
              endif

           endif

           ESTMP->(dbskip())

           if ESTMP->Produto != cPROD

              if ESANT->(QAppend())
                 replace ESANT->Produto    with cPROD
                 replace ESANT->Quantidade with nSALDO_COR
                 replace ESANT->Qty_ter    with nSALDO_TER
              endif
              ESANT->(Dbcommit())

              cPROD := ESTMP->Produto

              nSALDO_TER := 0
              nSALDO_COR := 0
           endif
       enddo
   endif


return



