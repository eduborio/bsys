////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE ANALITICA DE ESTOQUES
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO DE 2005
// OBS........:
// ALTERACOES.:
function es411

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

   dINI := dFIM := ctod("")

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
      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

      case cCAMPO == "PROD"

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PRODUTOS " +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   ITEN_FAT->(dbsetorder(2))

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
    local lTEM := .T.
    local lPRIM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  //.and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
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

             aadd(aFAT,{dtos(FAT->Dt_emissao),right(PROD->Codigo,5),FAT->Num_fatura,alltrim(FAT->Cod_cfop),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,FAT->Es,left(CLI1->Razao,35),dtoc(FAT->Dt_emissao)})
             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //MOVIMENT->(dbsetfilter({|| MOVIMENT->Contabil == .F.},'MOVIMENT->Contabil == .F.'))
   MOVIMENT->(dbsetorder(2)) // data de emissao
   MOVIMENT->(dbgotop())

   do while ! MOVIMENT->(eof())

         if MOVIMENT->Contabil
            MOVIMENT->(dbSkip())
            Loop
         endif

         //if MOVIMENT->Data < dINI .or. MOVIMENT->Data > dFIM
         //   MOVIMENT->(dbSkip())
         //   Loop
         //endif


         PROD->(dbsetorder(4))
         PROD->(dbseek(MOVIMENT->Cod_Prod))
         nVALOR := MOVIMENT->Val_uni * MOVIMENT->Quantidade

         if MOVIMENT->Tipo == "E"
            cDESCRICAO := "Entrada Sem Contabilizacao "
         else
            cDESCRICAO := "Saida Sem Contabilizacao "
         endif

         aadd(aFAT,{dtos(MOVIMENT->Data),right(PROD->Codigo,5),"      ","    ",MOVIMENT->Quantidade,MOVIMENT->Val_uni,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,MOVIMENT->Tipo,cDESCRICAO,dtoc(MOVIMENT->Data)})

         MOVIMENT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo



   do while ! PEDIDO->(eof())  //.and. PEDIDO->Data_ped >= dINI .and. PEDIDO->Data_ped <= dFIM  // condicao principal de loop

      //qgirabarra()

      qmensa("Aguarde... Processando ...")

         FORN->(dbseek(PEDIDO->Cod_forn))

         LANC->(Dbgotop())
         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(LANC->Cod_Prod))
             nVALOR := LANC->Preco * LANC->Quant

             aadd(aFAT,{dtos(PEDIDO->Data_ped),right(PROD->Codigo,5),PEDIDO->Numero_nf,alltrim(PEDIDO->Cfop),LANC->Quant,LANC->Preco,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,"C",left(FORN->Razao,35),dtoc(PEDIDO->Data_ped)})
             nPERC += nVALOR
             LANC->(Dbskip())
             //lTEM := .T.
         enddo
         PEDIDO->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo


   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[2] + x[1] + x[3] < y[2] + y[1] + y[3]  })
   if lTEM
       cPROD := asFAT[1,2]
       zPROD := asFAT[1,7]+" "+asFAT[1,8]
       nSALDO_COR := i_saldo_Ini(asFAT[1,2])
       nCUSTO_COR := i_custo_ini(asFAT[1,2])
       lPRIM := .T.
       nCONT := 1
       do while  nCONT <= len(asFAT)

           //if ! qlineprn() ; exit ; endif
           //if XPAGINA == 0 .or. prow() > K_MAX_LIN
           //   qpageprn()
           //   @ prow()+1,0 say + "  "+chr(9)+cTITULO
              if cSINTETICO == "A"
           //      @ prow()+1,0 say + "Data"+chr(9)+"Cliente"+chr(9)+"Cfop"+chr(9)+"Saldo Inicial"+chr(9)+"Tipo"+chr(9)+"Entrada/Saida"+chr(9)+"Saldo"+chr(9)+"Preco de Custo"+chr(9)+"Total"+chr(9)+"Novo Preco de Custo Apos Entrada"
              else

              endif
//           endif
           Qmensa(zPROD+"   "+transf(nSALDO_COR,"@R 999999.99"))
           if lPRIM
//              @ prow()  ,00 say "Saldo Inicial"+chr(9) + transf(nSALDO_INI,"@E 999,999.99")+chr(9)+"Custo"+chr(9)+transf(nCUSTO_INI,"@E 999,999.99")
//              lPRIM := .F.
           endif

           if asFAT[nCONT,10] $ "S*B"  // Se for Saida soma as quantidade senao diminui
              nQTD_VEND += asFAT[nCONT,5]

              if cSINTETICO == "A"
           //      @ prow()+1,02 say asFAT[nCONT,12]+chr(9)+asFAT[nCONT,11]+chr(9)+asFAT[nCONT,4]+chr(9)
           //      @ prow()  ,pcol()+1 say transf(nSALDO_COR,"@E 999999")+chr(9)
              endif

              nSALDO_COR := nSALDO_COR - asFAT[nCONT,5]

              if cSINTETICO == "A"
          //       @ prow()  ,pcol()+1 say "Saida" +chr(9)+ transf(asFAT[nCONT,5],"@E 999999")+chr(9)+transf(nSALDO_COR,"@R 99999")+chr(9)
         //        @ prow()  ,pcol()+1 say transf(nCUSTO_COR,"@E 999,999.99")+chr(9)+Transf(asFAT[nCONT,5]*nCUSTO_COR,"@E 999,999.99")
              endif
              nVLR_VEND += nCUSTO_COR * asFAT[nCONT,5]
           else
              nQTD_ENT += asFAT[nCONT,5]

              if asFAT[nCONT,10] == "C"
                 nCUSTO_COR := ( (nSALDO_COR * nCUSTO_COR) + (asFAT[nCONT,5]*asFAT[nCONT,6]) ) / (nSALDO_COR+asFAT[nCONT,5])
              Endif

              if cSINTETICO == "A"
         //        @ prow()  ,02 say asFAT[nCONT,12]+chr(9)+asFAT[nCONT,11]+chr(9)+asFAT[nCONT,4]+chr(9)
         //        @ prow()  ,pcol()+1 say transf(nSALDO_COR,"@E 999999")+chr(9)
              endif

              nSALDO_COR := nSALDO_COR + asFAT[nCONT,5]

              if cSINTETICO == "A"
        //         @ prow()  ,pcol()+1 say "Entrada" +chr(9)+ transf(asFAT[nCONT,5],"@E 999999") + chr(9) + transf(nSALDO_COR,"@R 99999")+chr(9)
                 if asFAT[nCONT,10] == "E"
       //             @ prow()  ,pcol()+1 say transf(nCUSTO_COR,"@E 999,999.99")+chr(9)+transf(asFAT[nCONT,5]*nCUSTO_COR,"@E 99,999.99")+chr(9)//transf(nCUSTO_COR,"@E 99,999.99")
                 else
       //             @ prow()  ,pcol()+1 say transf(asFAT[nCONT,6],"@E 999,999.99")+chr(9)+transf(asFAT[nCONT,5]*asFAT[nCONT,6],"@E 99,999.99")+chr(9)+transf(nCUSTO_COR,"@E 99,999.99")
                 endif
              endif

              nVLR_ENT += nCUSTO_COR * asFAT[nCONT,5]

           endif

           nVLR_ESTQ := (nSALDO_COR * nCUSTO_COR)



           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,2] != cPROD
             // @ prow()+1,00 say "  "+chr(9)+zPROD+chr(9)+" "+chr(9)+" "+chr(9)+"Qtde Saida"+chr(9)+transf(nQTD_VEND,"@R 999999")+chr(9)+transf(nVLR_VEND,"@E 999,999.99")+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")+chr(9)+transf(nCUSTO_COR,"@E 999,999.99")+chr(9)+transf(nSALDO_COR,"@E 999,999.99")
             INVENT->(Dbsetorder(4))
             if INVENT->(dbseek(alltrim(cPROD))) .and. INVENT->(Qrlock())
                replace INVENT->Quant_atu with nSALDO_COR
             endif

              if cSINTETICO == "S"
       //          @ prow() ,pcol()+1 say chr(9)+" "+"Tot Entrada"+chr(9)+transf(nQTD_ENT,"@E 999,999.99")+chr(9)+transf(nVLR_ENT,"@E 999,999.99")+chr(9)+"Saldo"+transf(nSALDO_COR,"@R 999999")+chr(9)+"Estoqe em "+dtoc(dFIM)+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")
              else
      //           @ prow()+1,00 say "  "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+""+chr(9)+""+chr(9)+""+chr(9)+""+chr(9)+""
              endif

              cPROD := asFAT[nCONT,2]
              zPROD := asFAT[nCONT,7]+" "+asFAT[nCONT,8]
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
              nSALDO_COR := i_saldo_Ini(asFAT[nCONT,2])
              nCUSTO_COR := 0
              nCUSTO_COR := i_custo_Ini(asFAT[nCONT,2])

              nQUANT := 0
              nTOTAL := 0
           endif
       enddo
//       @ prow()+1,00 say "  "+chr(9)+zPROD+chr(9)+" "+chr(9)+" "+chr(9)+"Qtde Saida"+chr(9)+transf(nQTD_VEND,"@R 999999")+chr(9)+transf(nVLR_VEND,"@E 999,999.99")+chr(9)+"Estoque em "+dtoc(dFIM)+chr(9)+transf(nVLR_ESTQ,"@E 999,999.99")
       if cSINTETICO == "S"
//          @ prow() ,pcol()+1 say chr(9)+" "+"Tot Entrada"+chr(9)+transf(nQTD_ENT,"@E 999,999.99")+chr(9)+transf(nVLR_ENT,"@E 999,999.99")+transf(nSALDO_COR,"@R 999999")
       endif

       INVENT->(Dbsetorder(4))
       if INVENT->(dbseek(alltrim(cPROD))) .and. INVENT->(Qrlock())
          replace INVENT->Quant_atu with nSALDO_COR
       endif

       nVLR_VEND := 0
       nQTD_VEND := 0
       nVLR_ENT  := 0
       nQTD_ENT  := 0



//        @ prow()+2,00 say "  "+chr(9)+zPROD+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+" "+chr(9)+transf(nVLR_VEND_TOT,"@E 999,999.99")+chr(9)+"Estoque em "+dtoc(dFIM)+chr(9)+transf(nVLR_ESTQ_TOT,"@E 9,999,999.99")
       if cSINTETICO == "S"
//          @ prow() ,pcol()+1 say chr(9)+" "+" "+chr(9)+" "+chr(9)
       endif


       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
       nVLR_VEND_TOT := 0
       nVLR_ENT_TOT := 0
       nVLR_ESTQ_TOT := 0
   endif


return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_saldo_ini( cPRODUTO )
    local nlSALDO_INI  := 0
    local nlSALDO_COR  := 0
    local nlSALDO_FIM  := 0

    local nlPRECO_INI  := 0
    local nlPRECO_COR  := 0
    local nlPRECO_FIM  := 0
    local lFIRST       := .T.

   PEDIDO->(dbsetorder(1)) // data de emissao
   PEDIDO->(dbgotop())

   do while ! PEDIDO->(eof())  .and. PEDIDO->Data_ped < dINI  // condicao principal de loop

      //qgirabarra()

      qmensa("Aguarde... Processando ...")

         FORN->(dbseek(PEDIDO->Cod_forn))
         LANC->(dbsetorder(1))
         LANC->(Dbgotop())
         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(LANC->Cod_Prod))

             if LANC->Cod_prod != cPRODUTO
                LANC->(dbSkip())
                loop
             endif

             nlSALDO_COR := nlSALDO_COR + LANC->Quant



       //  endif

           LANC->(Dbskip())
         enddo
         PEDIDO->(dbskip())
   enddo

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())


   do while ! FAT->(eof())  .and. FAT->Dt_emissao < dINI  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

         CLI1->(dbseek(FAT->Cod_cli))
         ITEN_FAT->(dbsetorder(2))
         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

            PROD->(dbsetorder(4))
            PROD->(dbseek(ITEN_FAT->Cod_Prod))
            if ITEN_FAT->Cod_prod != cPRODUTO
               ITEN_FAT->(dbskip())
               loop
            endif

            if FAT->ES == "S"
               nlSALDO_COR := nlSALDO_COR - ITEN_FAT->Quantidade
            else
               nlSALDO_COR := nlSALDO_COR + ITEN_FAT->Quantidade
            endif
            ITEN_FAT->(Dbskip())

         enddo
         FAT->(dbskip())
   enddo

   MOVIMENT->(dbsetorder(2)) // data de emissao
   MOVIMENT->(dbgotop())

   do while ! MOVIMENT->(eof()) .and. MOVIMENT->Data < dini

         if MOVIMENT->Contabil
            MOVIMENT->(dbSkip())
            Loop
         endif

         PROD->(dbsetorder(4))
         PROD->(dbseek(MOVIMENT->Cod_Prod))
         if MOVIMENT->Cod_prod != cPRODUTO
            MOVIMENT->(dbskip())
            loop
         endif


         nlSALDO_COR := nlSALDO_COR + MOVIMENT->Quantidade

         MOVIMENT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo



return nlSALDO_COR

static function i_custo_ini( cPRODUTO )
    local nlSALDO_INI  := 0
    local nlSALDO_COR  := 0
    local nlSALDO_FIM  := 0

    local nlCUSTO_INI  := 0
    local nlCUSTO_COR  := 0
    local nlPRECO_FIM  := 0
    local lFIRST       := .T.
    local bFAT         := {}
    local bsFAT        := {}
    lTEM := .F.

   PEDIDO->(dbsetorder(1)) // data de emissao
   PEDIDO->(dbgotop())



   do while ! PEDIDO->(eof())  .and. PEDIDO->Data_ped < dINI  // condicao principal de loop

      //qgirabarra()

      qmensa("Aguarde... Processando ...")

         FORN->(dbseek(PEDIDO->Cod_forn))
         LANC->(dbsetorder(1))
         LANC->(Dbgotop())
         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(LANC->Cod_Prod))

             if LANC->Cod_prod != cPRODUTO
                LANC->(dbSkip())
                loop
             endif

             nVALOR := LANC->Preco * LANC->Quant


             //nlSALDO_COR := nlSALDO_COR + LANC->Quant
             aadd(bFAT,{dtos(PEDIDO->Data_ped),right(PROD->Codigo,5),PEDIDO->Numero_nf,alltrim(PEDIDO->Cfop),LANC->Quant,LANC->Preco,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,"C",left(FORN->Razao,35),dtoc(PEDIDO->Data_ped)})
             lTEM := .T.
             nVALOR := 0
       //  endif

           LANC->(Dbskip())
         enddo
         PEDIDO->(dbskip())
   enddo

   MOVIMENT->(dbsetorder(2)) // data de emissao
   MOVIMENT->(dbgotop())

   do while ! MOVIMENT->(eof())

         if MOVIMENT->Contabil
            MOVIMENT->(dbSkip())
            Loop
         endif

         if MOVIMENT->Data > dINI
            MOVIMENT->(dbSkip())
            Loop
         endif


         PROD->(dbsetorder(4))
         PROD->(dbseek(MOVIMENT->Cod_Prod))
         nVALOR := MOVIMENT->Val_uni * MOVIMENT->Quantidade

         if MOVIMENT->Tipo == "E"
            cDESCRICAO := "Entrada Sem Contabilizacao "
         else
            cDESCRICAO := "Saida Sem Contabilizacao "
         endif

         aadd(aFAT,{dtos(MOVIMENT->Data),right(PROD->Codigo,5),"      ","    ",MOVIMENT->Quantidade,MOVIMENT->Val_uni,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,MOVIMENT->Tipo,cDESCRICAO,dtoc(MOVIMENT->Data)})

         MOVIMENT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo





   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())


   do while ! FAT->(eof())  .and. FAT->Dt_emissao < dINI  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

         CLI1->(dbseek(FAT->Cod_cli))
         ITEN_FAT->(dbsetorder(2))
         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             if ITEN_FAT->Cod_prod != cPRODUTO
                ITEN_FAT->(dbskip())
                loop
             endif

             nVALOR := ITEN_FAT->Vl_Unitar * ITEN_FAT->Quantidade

             aadd(bFAT,{dtos(FAT->Dt_emissao),right(PROD->Codigo,5),FAT->Num_fatura,alltrim(FAT->Cod_cfop),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,FAT->Es,left(CLI1->Razao,35),dtoc(FAT->Dt_emissao)})
             lTEM := .T.
             nVALOR := 0

             //if FAT->ES == "S"
             //   nlSALDO_COR := nlSALDO_COR - ITEN_FAT->Quantidade
             //else
             //   nlSALDO_COR := nlSALDO_COR + ITEN_FAT->Quantidade
             //endif
           ITEN_FAT->(Dbskip())
         enddo
         FAT->(dbskip())
   enddo
   //nlSALDO_FIM := nlSALDO_COR


   //classifica a matriz por descricao do produto
   bsFAT := asort(bFAT,,,{|x,y| x[2] + x[1] + x[3] < y[2] + y[1] + y[3]  })
   if lTEM
       cPROD := bsFAT[1,2]
       zPROD := bsFAT[1,7]+" "+bsFAT[1,8]
       nlSALDO_INI := 0 //_saldo_Ini(bsFAT[1,2])
       nlSALDO_COR := 0 //i_saldo_Ini(bsFAT[1,2])
       nlCUSTO_INI := 0
       nlCUSTO_COR := 0
       lPRIM := .T.
       nCONT := 1
       do while  nCONT <= len(bsFAT)

           if bsFAT[nCONT,10] == "S*B"  // Se for Saida soma as quantidade senao diminui

              nlSALDO_COR := nlSALDO_COR - bsFAT[nCONT,5]

           else
              if bsFAT[nCONT,10] == "C"
                 nlCUSTO_COR := ( (nlSALDO_COR * nlCUSTO_COR) + (bsFAT[nCONT,5]*bsFAT[nCONT,6]) ) / (nlSALDO_COR+bsFAT[nCONT,5])
              Endif

              nlSALDO_COR := nlSALDO_COR + bsFAT[nCONT,5]
           endif



           nCONT++
           if nCONT > len(bsFAT)
              nCONT := len(bsFAT)
              exit
           endif

           if bsFAT[nCONT,2] != cPROD
              cPROD := bsFAT[nCONT,2]

              nlSALDO_INI := 0
              nlSALDO_COR := 0
              nlSALDO_COR := i_saldo_Ini(bsFAT[nCONT,2])


              nQUANT := 0
              nTOTAL := 0
           endif
       enddo

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif


return nlCUSTO_COR

