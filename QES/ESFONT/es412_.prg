////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO DE 2005
// OBS........:
// ALTERACOES.:
function es412

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


   nSALDO_INI := 0                // SALDO Inicial de Estoque
   nSALDO_ATU := 0                // Saldo Corrente
   cSINTETICO := "A"
   nPC_INI    := 0               // Preco de Custo Inicial
   nPC_CORRENTE  := 0            // P.C. Corrente
   cPROD := space(5)

   if qconf("Confirma Propaga‡Æo dos Saldos de Estoque ?")
      i_impressao()
      ESTMP->(Dbclosearea())
   endif





/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nTOTAL     := 0
    local nSALDO_COR := 0
    local nSALDO_INI := 0
    local nCUSTO_INI := 0
    local nCUSTO_COR := 0
    local nVALOR     := 0

    local nVLR_VEND     := 0
    local nVLR_VEND_TOT := 0
    local nVLR_ENT_TOT  := 0
    local nVLR_ESTQ_TOT := 0
    local nQTD_VEND     := 0
    local nQUANT_TER    := 0
    local nQUANT_DEFE   := 0



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
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif
   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))

   do while ! FAT->(eof())  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
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
                replace ESTMP->Nota       with FAT->Num_fatura
                replace ESTMP->Cfop       with alltrim(FAT->Cod_cfop)
                replace ESTMP->Quantidade with ITEN_FAT->Quantidade
                replace ESTMP->Es         with FAT->Es
                replace ESTMP->Cod_fc     with FAT->Cod_cli
             endif
             qmensa(FAT->Codigo)
             nPERC += nVALOR
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


         PROD->(dbsetorder(4))
         PROD->(dbseek(MOVIMENT->Cod_Prod))
         nVALOR := MOVIMENT->Val_uni * MOVIMENT->Quantidade

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

         nVALOR := 0
         nDESC := 0
   enddo
   ESTMP->(dbcommit())

   AVARIADO->(dbsetorder(2)) // data de emissao
   AVARIADO->(dbgotop())

   do while ! AVARIADO->(eof())

         PROD->(dbsetorder(4))
         PROD->(dbseek(AVARIADO->Cod_Prod))
         nVALOR := AVARIADO->Val_uni * AVARIADO->Quantidade

         if ESTMP->(qappend())
            replace ESTMP->Data       with AVARIADO->Data
            replace ESTMP->Produto    with right(PROD->Codigo,5)
            replace ESTMP->Nota       with ""
            replace ESTMP->Cfop       with "AVAR"
            replace ESTMP->Quantidade with AVARIADO->Quantidade
            replace ESTMP->Es         with "B"
         endif

         AVARIADO->(dbskip())

         nVALOR := 0
         nDESC := 0
   enddo
   ESTMP->(dbcommit())


   PEDIDO->(dbsetorder(1)) // data de emissao
   PEDIDO->(dbgotop())
   LANC->(dbsetorder(1))


   do while ! PEDIDO->(eof())  // condicao principal de loop

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
   ESTMP->(Dbsetorder(1))
   ESTMP->(Dbgotop())
       cPROD := ESTMP->Produto
       PROD->(dbsetorder(4))
       PROD->(Dbgotop())
       PROD->(dbseek(ESTMP->Produto))
       zPROD := rtrim(PROD->Cod_fabr) + "/ "+rtrim(PROD->Cod_ass)+"    "+rtrim(PROD->Descricao)+"        "+rtrim(PROD->Marca)
       nSALDO_COR := 0
       nCUSTO_COR := 0
       nQUANT_TER := 0
       nQUANT_DEFE:= 0
       lPRIM := .T.
       nCONT := 1
       do while ! ESTMP->(eof())

           if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidade senao diminui

              if ESTMP->Cfop $ "5905-6905-5906-6906"
                 nQUANT_TER := nQUANT_TER + ESTMP->Quantidade
              else

                 if ESTMP->Cfop == "AVAR"
                    nQUANT_DEFE := nQUANT_DEFE + ESTMP->Quantidade
                 endif

              endif

              nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
              nVLR_VEND += nCUSTO_COR * ESTMP->Quantidade


           else
              nQTD_ENT += ESTMP->Quantidade

              if ESTMP->Es == "C"
                 nCUSTO_COR := ( (nSALDO_COR * nCUSTO_COR) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
              Endif

              if ESTMP->Cfop $ "1906-2906-1905-2905"
                 nQUANT_TER := nQUANT_TER - ESTMP->Quantidade
              endif

              nSALDO_COR := nSALDO_COR + ESTMP->Quantidade
              nVLR_ENT += nCUSTO_COR * ESTMP->Quantidade

           endif

           ESTMP->(dbskip())

           if ESTMP->Produto != cPROD

              PROD->(dbsetorder(4))
//              PROD->(dbgotop())
//              if PROD->(dbseek(cPROD))
//                 if PROD->(qrlock())
//                    replace PROD->Preco_cust  with nCUSTO_COR
//                    PROD->(qunlock())
//                 endif
//              endif


              INVENT->(dbsetorder(4))
              INVENT->(dbgotop())
              if INVENT->(dbseek(cPROD))
                 if INVENT->(qrlock())
                    replace INVENT->Quant_atu  with nSALDO_COR
                    replace INVENT->Quant_ter  with nQUANT_TER
                    replace INVENT->Quant_defe with nQUANT_DEFE
                    INVENT->(qunlock())
                 endif
              endif

              qmensa(left(PROD->Cod_fabr,4) + "  "+PROD->Cod_ass+" "+ PROD->Marca)

              cPROD := ESTMP->Produto
              zPROD := right(PROD->Codigo,5)

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
              nQUANT_TER := 0
              nQUANT_DEFE:= 0
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
       nQUANT_TER := 0
       nQUANT_DEFE:= 0

return


