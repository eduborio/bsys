////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: OUTUBRO DE 2006
// OBS........:
// ALTERACOES.:
function es513

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
private aEDICAO := {}             // vetor para os campos de entrada de dados

if ! quse(XDRV_ES,"ESTMP",{"ESTMP"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"ESANT",{"ESANT1"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"ESATU",{"ESATU1"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD)     } , "PROD"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })


do while .T.

   qlbloc(5,0,"B513A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   nSALDO_INI := 0                // SALDO Inicial de Estoque
   nSALDO_ATU := 0                // Saldo Corrente
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


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "Saldo Anterior de Estoque " +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

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
    local nPERC      := 0
    local lPRIM := .T.
    local zPROD := space(50)

    ESTMP->(__dbzap())
    ESATU->(__dbzap())

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

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


      qmensa("Aguarde... Processando ...")

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
                replace ESTMP->Quantidade with ITEN_FAT->Quantidade
                replace ESTMP->Es         with FAT->Es
             endif
             qmensa(FAT->Codigo)
             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
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
            replace ESTMP->Quantidade with MOVIMENT->Quantidade
            replace ESTMP->Es         with MOVIMENT->Tipo
         endif

         MOVIMENT->(dbskip())

         nVALOR := 0
         nDESC := 0
   enddo
   ESTMP->(dbcommit())



   do while ! PEDIDO->(eof())  .and. PEDIDO->Data_ped >= dINI .and. PEDIDO->Data_ped <= dFIM  // condicao principal de loop

      //qgirabarra()

      qmensa("Aguarde... Processando ...")

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
                replace ESTMP->Quantidade  with LANC->Quant
                replace ESTMP->Preco_cust  with LANC->Preco
                replace ESTMP->Es          with "C"
             endif


             nPERC += nVALOR
             LANC->(Dbskip())
         enddo
         PEDIDO->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   ESTMP->(Dbcommit())

   i_agrupa_prod()

 return

static Function i_agrupa_prod

   ESTMP->(Dbgotop())
   ESTMP->(Dbsetorder(1))
   cPROD := ESTMP->Produto
   PROD->(dbsetorder(4))
   PROD->(Dbgotop())
   PROD->(dbseek(ESTMP->Produto))
   ESANT->(Dbseek(ESTMP->Produto))
   nSALDO_COR := ESANT->Quantidade
   nCUSTO_COR := ESANT->Preco_cust

   lPRIM := .T.
   nCONT := 1
   do while ! ESTMP->(eof())

       if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidade senao diminui
          //nQTD_VEND += ESTMP->Quantidade
          nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
          //nVLR_VEND += nCUSTO_COR * ESTMP->Quantidade
       else
          //nQTD_ENT += ESTMP->Quantidade

          if ESTMP->Es == "C"
             nCUSTO_COR := ( (nSALDO_COR * nCUSTO_COR) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
             nCUSTO_COR := round(nCUSTO_COR,2)
          Endif

          nSALDO_COR := nSALDO_COR + ESTMP->Quantidade
       endif

       nVLR_ESTQ := (nSALDO_COR * nCUSTO_COR)

       ESTMP->(dbskip())

       if ESTMP->Produto != cPROD

          if ESATU->(Qappend())
             replace ESATU->Produto     with cPROD
             replace ESATU->Saldo       with nSALDO_COR
             replace ESATU->Preco_cust  with nCUSTO_COR
          endif
          ESATU->(DbCommit())

          cPROD := ESTMP->Produto
          ESANT->(Dbseek(ESTMP->Produto))
          nSALDO_COR := ESANT->Quantidade
          nCUSTO_COR := ESANT->Preco_cust


          lPRIM := .T.

          nVLR_VEND := 0
          nQTD_VEND := 0
          nVLR_ENT  := 0
          nVLR_ESTQ := 0
          nQTD_ENT  := 0

          nQUANT := 0
          nTOTAL := 0
       endif
   enddo

   if ESATU->(Qappend())
      replace ESATU->Produto     with cPROD
      replace ESATU->Saldo       with nSALDO_COR
      replace ESATU->Preco_cust  with nCUSTO_COR
   endif
   ESATU->(DbCommit())


   nVLR_VEND := 0
   nQTD_VEND := 0
   nVLR_ENT  := 0
   nQTD_ENT  := 0
   nQUANT := 0
   nTOTAL := 0
   nPERC  := 0
   nVLR_VEND_TOT := 0
   nVLR_ENT_TOT := 0
   nVLR_ESTQ_TOT := 0

   if ! empty(cPROD)
      ITEN_FAT->(dbclearfilter())
      LANC->(dbclearfilter())
      MOVIMENT->(dbclearfilter())
   endif
   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

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
    local nPERC      := 0
    local lPRIM := .T.
    local zPROD := space(50)

    ESTMP->(__dbzap())
    ESANT->(__dbzap())
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

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

      if left(FAT->Cod_cfop,4) $ "5905-6905-1905-2905-1906-2906"
         FAT->(DbSkip())
         loop
      endif


      //qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
             nDESC := nVALOR * (FAT->Aliq_desc/100)
             nVALOR := nVALOR - nDESC

          //   aadd(aFAT,{dtos(FAT->Dt_emissao),right(PROD->Codigo,5),FAT->Num_fatura,alltrim(FAT->Cod_cfop),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,FAT->Es,left(CLI1->Razao,35),dtoc(FAT->Dt_emissao)})
          //   aadd(aFAT,{dtos(FAT->Dt_emissao),right(PROD->Codigo,5),FAT->Num_fatura,alltrim(FAT->Cod_cfop),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,"","",nVALOR,FAT->Es,CLI1->Codigo,dtoc(FAT->Dt_emissao)})
             if ESTMP->(qappend())
                replace ESTMP->Data       with FAT->Dt_emissao
                replace ESTMP->Produto    with right(PROD->Codigo,5)
                replace ESTMP->Nota       with FAT->Num_fatura
                replace ESTMP->Cfop       with alltrim(FAT->Cod_cfop)
                replace ESTMP->Quantidade with ITEN_FAT->Quantidade
                replace ESTMP->Es         with FAT->Es
                replace ESTMP->Cod_fc     with FAT->Cod_cli
             endif
             qmensa(FAT->Codigo)
             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
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

         if MOVIMENT->Data >= dINI
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
            replace ESTMP->Cfop       with ""
            replace ESTMP->Quantidade with MOVIMENT->Quantidade
            replace ESTMP->Es         with MOVIMENT->Tipo
            replace ESTMP->Cod_fc     with cDESCRICAO
         endif

         MOVIMENT->(dbskip())

         nVALOR := 0
         nDESC := 0
   enddo
   ESTMP->(dbcommit())


   PEDIDO->(dbsetorder(1))
   PEDIDO->(Dbgotop())
   do while ! PEDIDO->(eof())  .and. PEDIDO->Data_ped < dINI  // condicao principal de loop

      //qgirabarra()

      qmensa("Aguarde... Processando ...")

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
   cPROD := ESTMP->Produto
   PROD->(dbsetorder(4))
   PROD->(Dbgotop())
   PROD->(dbseek(ESTMP->Produto))
   zPROD := rtrim(PROD->Cod_fabr) + "/ "+rtrim(PROD->Cod_ass)+"    "+rtrim(PROD->Descricao)+"        "+rtrim(PROD->Marca)
   nSALDO_COR := 0
   nCUSTO_COR := 0
   lPRIM := .T.
   nCONT := 1
   do while ! ESTMP->(eof())

       if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidade senao diminui

          nQTD_VEND += ESTMP->Quantidade
          nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
          nVLR_VEND += nCUSTO_COR * ESTMP->Quantidade
       else
          nQTD_ENT += ESTMP->Quantidade

          if ESTMP->Es == "C"
             nCUSTO_COR := ( (nSALDO_COR * nCUSTO_COR) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
             nCUSTO_COR := round(nCUSTO_COR,2)

          Endif

          nSALDO_COR := nSALDO_COR + ESTMP->Quantidade

          nVLR_ENT += nCUSTO_COR * ESTMP->Quantidade

       endif

       nVLR_ESTQ := (nSALDO_COR * nCUSTO_COR)

       ESTMP->(dbskip())

       if ESTMP->Produto != cPROD

          if ESANT->(QAppend())
             replace ESANT->Produto    with cPROD
             replace ESANT->Quantidade with nSALDO_COR
             replace ESANT->Preco_cust with nCUSTO_COR
          endif
          ESANT->(Dbcommit())

          cPROD := ESTMP->Produto
          PROD->(dbsetorder(4))
          PROD->(Dbgotop())
          PROD->(dbseek(ESTMP->Produto))
          zPROD := rtrim(PROD->Cod_fabr) + "/ "+rtrim(PROD->Cod_ass)+"    "+rtrim(PROD->Descricao)+"        "+rtrim(PROD->Marca)

          //zPROD := asFAT[nCONT,7]+" "+asFAT[nCONT,8]
          nVLR_VEND_TOT += nVLR_VEND
          nVLR_ENT_TOT += nVLR_ENT
          nVLR_ESTQ_TOT += nVLR_ESTQ


          lPRIM := .T.

          nVLR_VEND := 0
          nQTD_VEND := 0
          nVLR_ENT  := 0
          nVLR_ESTQ := 0
          nQTD_ENT  := 0

          nSALDO_COR := 0
          nSALDO_COR := 0
          nCUSTO_COR := 0
          nCUSTO_COR := 0

          nQUANT := 0
          nTOTAL := 0
       endif
   enddo
   nVLR_VEND := 0
   nQTD_VEND := 0
   nVLR_ENT  := 0
   nQTD_ENT  := 0


   nQUANT := 0
   nTOTAL := 0
   nPERC  := 0
   nVLR_VEND_TOT := 0
   nVLR_ENT_TOT := 0
   nVLR_ESTQ_TOT := 0

   if ! empty(cPROD)
      ITEN_FAT->(dbclearfilter())
      LANC->(dbclearfilter())
      MOVIMENT->(dbclearfilter())
   endif
return

static function i_impre_prn
local nQUANT := 0
local nPRECO := 0

  PROD->(Dbsetorder(4))
  PROD->(Dbgotop())
  Do while ! PROD->(Eof())

     if right(PROD->Codigo,5) == "     "
        PROD->(Dbskip())
        loop
     endif

     if XPAGINA == 0 .or. prow() > K_MAX_LIN
        qpageprn()
        qcabecprn(cTITULO,80)
        @ prow()+1,0 say "PRODUTO                                              EM ESTOQUE   PRECO UNITARIO"
        @ prow()+1,0 say replicate("-",80)
     endif


     if ESATU->(Dbseek(right(PROD->Codigo,5)))
        nQUANT := ESATU->Saldo
        nPRECO := ESATU->Preco_cust
     else
        if ESANT->(Dbseek(right(PROD->Codigo,5)))
           nQUANT := ESANT->Quantidade
           nPRECO := ESANT->Preco_cust
        endif
     endif

     @ prow()+1,00 say left(PROD->Cod_fabr,7) + " - " + PROD->Cod_ass +" "+ left(PROD->Descricao,18)+" "+left(PROD->Marca,12)   + " " +;
                       iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT,"@E 999,999.99") + " " +;
                       transform(nPRECO,"@E 99,999,999.99") , "")

     nQUANT := 0
     nPRECO := 0


     PROD->(Dbskip())
  enddo

  qstopprn()

return


static function i_impre_xls
local nQUANT := 0
local nPRECO := 0

  PROD->(Dbsetorder(4))
  PROD->(Dbgotop())
  Do while ! PROD->(Eof())

     if right(PROD->Codigo,5) == "     "
        PROD->(Dbskip())
        loop
     endif

     if XPAGINA == 0
        qpageprn()
        @ prow()+1,0 say cTITULO+chr(9)+"513"
        @ prow()+1,0 say "Produto"+Chr(9)+"Cod."+Chr(9)+"Ref."+chr(9)+"Marca"+chr(9)+"Saldo do Estoque"+Chr(9)+"Preco Custo"+chr(9)+"Valor Total"
        @ prow()+1,0 say ""
     endif


     if ESATU->(Dbseek(right(PROD->Codigo,5)))
        nQUANT := ESATU->Saldo
        nPRECO := ESATU->Preco_cust
     else
        if ESANT->(Dbseek(right(PROD->Codigo,5)))
           nQUANT := ESANT->Quantidade
           nPRECO := ESANT->Preco_cust
        endif
     endif

     @ prow()+1,00 say left(PROD->Descricao,18)+chr(9)+;
                       PROD->Cod_ass+chr(9)+;
                       PROD->Cod_fabr+Chr(9)+;
                       PROD->Marca +chr(9)+;
                       transform(nQUANT,"@E 999,999.99") + chr(9) +;
                       transform(nPRECO,"@E 99,999,999.99")+chr(9)+;
                       transform(nQUANT*nPRECO,"@E 99,999,999.99")

     nQUANT := 0
     nPRECO := 0


     PROD->(Dbskip())
  enddo

  qstopprn()

return




