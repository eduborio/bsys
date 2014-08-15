/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA RECURSOS HUMANOS
// OBJETIVO...: RELATORIO DE PRODUCAO E CUSTO DOS VEICULOS
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: AGOSTO DE 1997
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private cTITULO                               // titulo do relatorio

private bFILTRO                               // code block de filtro
private bFILTRO1                              // code block de filtro
private cFILIAL
private aEDICAO := {}                         // vetor para os campos de entrada de dados
private nPROD_M
private nPROD_R
private nTOT_CUSTO
private nT_PROD_M
private nT_PROD_R
private nTOT_PREMIO
private nTOT_H_EXTRA
private nTOT_QUANT
private nPREMIO
private nH_EXTRA
private nACU_PROD
private nACU_MAN
private nACU_PREM

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL                    )} ,"FILIAL"   })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI     ,"@D"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM     ,"@D"     ,NIL,NIL) } ,"DATA_FIM"})

do while .T.

   qlbloc(5,0,"B550A","QBLOC.GLO",1)

   XNIVEL     := 1
   XFLAG      := .T.
   cFILIAL    := space(4)
   dDATA_INI  := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM  := qfimmes(dDATA_INI)
   nPROD_M      := 0
   nPROD_R      := 0
   nTOT_CUSTO   := 0
   nT_PROD_M    := 0
   nT_PROD_R    := 0
   nTOT_PREMIO  := 0
   nTOT_H_EXTRA := 0
   nTOT_QUANT   := 0
   nPREMIO      := 0
   nH_EXTRA     := 0
   nACU_PROD    := 0
   nACU_MAN     := 0
   nACU_PREM    := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FILIAL"
           if empty(cFILIAL)
              qrsay(XNIVEL+1,"*** Todas as Filiais ***")
           else
              qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))
              if ! FILIAL->(dbseek(cFILIAL))
                 qmensa("Filial n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->Razao,28))
           endif

      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE PRODUCAO E CUSTO DOS VEICULOS: " + dtoc(dDATA_INI) + " ATE " + dtoc(dDATA_FIM)
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   bFILTRO := { || PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIM }
   bFILTRO1:= { || PEDIDO2->Data_ped >= dDATA_INI .and. PEDIDO2->Data_ped <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   if ! quse(XDRV_CP,"LANC",{"LA_VEIC"},"R","LANC_CP")
      qmensa("N„o foi possivel abrir LANC.DBF do Compras !","B")
      return .F.
   endif

   VEICULOS->(dbsetorder(7)) // FILIAL + CENTRO + CODIGO
   VEICULOS->(dbgotop())

   PEDIDO->(dbsetorder(2))    // CODIGO

   PEDIDO2->(dbsetorder(2))   // CODIGO

   LANC2->(dbsetorder(3))     // COD_VEIC

   PROD->(dbsetorder(4))      // CODIGO REDUZIDO

   SITUA->(dbSetFilter({|| Anomes == qanomes(dDATA_INI)},"Anomes == qanomes(dDATA_INI)"))

   CCUSTO->(dbsetorder(4))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! empty(cFILIAL)
      VEICULOS->(dbseek(cFILIAL))
   else
      VEICULOS->(dbgotop())
   endif

   cTEMP_FILIAL := VEICULOS->Filial
   cTEMP_CENTRO := VEICULOS->Centro

   do while ! VEICULOS->(eof()) .and. qcontprn()

      if ! qlineprn() ; exit ; endif

      qgirabarra()

      if left(VEICULOS->Descricao,2) == "SR"
         loop
      endif

      if VEICULOS->Centro <> cTEMP_CENTRO .and. VEICULOS->Filial == "0001"
         i_imprime_funcionarios()
         CCUSTO->(dbseek(VEICULOS->Centro))
         @ prow()+1,0 say "CENTRO: " + VEICULOS->Centro + "-" + CCUSTO->Descricao
         @ prow()+1,0 say replicate("-",264)
         cTEMP_CENTRO := VEICULOS->Centro
      endif

      if ! empty(cFILIAL)
         if VEICULOS->Filial <> cFILIAL
            i_imprime_funcionarios()
            exit
         endif
      else
         if VEICULOS->Filial <> cTEMP_FILIAL
            i_imprime_funcionarios()
            qpageprn()
            qcabecprn(cTITULO,264)
            FILIAL->(VEICULOS->Filial)
            CCUSTO->(dbseek(VEICULOS->Centro))
            @ prow()+1,0 say "FILIAL: " + VEICULOS->Filial + "-" + FILIAL->Razao
            @ prow()+1,0 say "CENTRO: " + VEICULOS->Centro + "-" + CCUSTO->Descricao
            @ prow()+1,0 say replicate("-",264)
            cTEMP_FILIAL := VEICULOS->Filial
         endif
      endif
         
      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @ prow(),pcol() say XCOND2
         qpageprn()
         qcabecprn(cTITULO,264)
         FILIAL->(VEICULOS->Filial)
         CCUSTO->(dbseek(VEICULOS->Centro))
         @ prow()+1,0 say "FILIAL: " + VEICULOS->Filial + "-" + FILIAL->Razao
         @ prow()+1,0 say "CENTRO: " + VEICULOS->Centro + "-" + CCUSTO->Descricao
         @ prow()+1,0 say replicate("-",264)
         @ prow()+1,0 say "                                                 MES ANTERIOR                                                                           MES CORRENTE"
         @ prow()+1,0 say "VEICULO/CARGO   FUNCIONARIO                      PROD. M3   PROD. R$   LIM.MAN.  CUSTO MAN.    PREMIO   H.EXTRAS   RES.MAN.    CT.COR.  PROD. M3   PROD. R$   LIM.MAN.  CUSTO MAN.    PREMIO   H.EXTRAS   RES.MAN.  CONTA COR.  PROD.ACUM.  C.ACUM.  PREM. ACUM. P.PAGAR"
         @ prow()+1,0 say replicate("-",264)
      endif

      ////////////////////////////////////////////////////////////////////
      // COMPRAS _________________________________________________________

      if LANC_CP->(dbseek(VEICULOS->Codigo))

         do while LANC_CP->Cod_veic == VEICULOS->Codigo .and. ! LANC_CP->(eof()) .and. qcontprn()

            qgirabarra()

            if ! qlineprn() ; exit ; endif

            if PEDIDO->(dbseek(LANC_CP->Cod_ped))

               if eval(bFILTRO)

                  PROD->(dbseek(LANC_CP->Cod_prod))

                  nTOT_CUSTO += (LANC_CP->Preco*LANC_CP->Quant) + ( (LANC_CP->Preco*LANC_CP->Quant) * (LANC_CP->Aliq_ipi/100) )

               endif

            endif

            LANC_CP->(dbskip())

         enddo

      endif

      if LANC2->(dbseek(VEICULOS->Codigo))

         do while LANC2->Cod_veic == VEICULOS->Codigo .and. ! LANC2->(eof()) .and. qcontprn()

            if ! qlineprn() ; exit ; endif

            qgirabarra()

            if PEDIDO2->(dbseek(LANC2->Cod_ped))

               if eval(bFILTRO1)

                  PROD->(dbseek(LANC2->Cod_prod))

                  nTOT_CUSTO += (LANC2->Preco*LANC2->Quant) + ( (LANC2->Preco*LANC2->Quant) * (LANC2->Aliq_ipi/100) )

               endif
            endif

            LANC2->(dbskip())

         enddo

      endif

      REQUISIC->(Dbsetorder(2))
      REQUISIC->(Dbgotop())

      if REQUISIC->(dbseek(VEICULOS->Codigo))

         do while ! REQUISIC->(eof()) .and. REQUISIC->Cod_veic == VEICULOS->Codigo .and. qcontprn()

            if ! qlineprn() ; exit ; endif
         
            qgirabarra()

            ITENS_RQ->(Dbsetorder(2))
            ITENS_RQ->(Dbseek(REQUISIC->Codigo))

            do while ITENS_RQ->Cod_req == REQUISIC->Codigo .and. ! ITENS_RQ->(eof()) .and. qcontprn()

               if ! qlineprn() ; exit ; endif
            
               qgirabarra()

               if REQUISIC->Dt_requisi >= dDATA_INI .and. REQUISIC->Dt_requisi <= dDATA_FIM

                  PROD->(dbseek(ITENS_RQ->Cod_produt))
                  nTOT_CUSTO += (ITENS_RQ->Vl_unitari*ITENS_RQ->Quantidade)+((ITENS_RQ->Vl_unitari*ITENS_RQ->Quantidade) * (PROD->Ipi / 100))

               endif

               ITENS_RQ->(dbskip())

            enddo

            REQUISIC->(Dbskip())

         enddo

      endif

      OFICINA->(Dbsetorder(2))
      OFICINA->(Dbgotop())

      if OFICINA->(dbseek(VEICULOS->Codigo))

         do while ! OFICINA->(eof()) .and. OFICINA->Cod_veic == VEICULOS->Codigo .and. qcontprn()

            if ! qlineprn() ; exit ; endif
         
            qgirabarra()

            ITENS_OF->(Dbsetorder(2))
            ITENS_OF->(Dbseek(OFICINA->Codigo))

            if OFICINA->Dt_servico >= dDATA_INI .and. OFICINA->Dt_servico <= dDATA_FIM
               nTOT_CUSTO += OFICINA->Valor_1 + OFICINA->Valor_2 + OFICINA->Valor_3 + OFICINA->Valor_4 + OFICINA->Valor_5
            endif

            do while ITENS_OF->Cod_oficin == OFICINA->Codigo .and. ! ITENS_OF->(eof()) .and. qcontprn()

               if ! qlineprn() ; exit ; endif
            
               qgirabarra()

               if OFICINA->Dt_servico >= dDATA_INI .and. OFICINA->Dt_servico <= dDATA_FIM

                  PROD->(dbseek(ITENS_OF->Cod_produt))

                  nTOT_CUSTO += (ITENS_OF->Vl_unitari*ITENS_OF->Quantidade)+((ITENS_OF->Vl_unitari*ITENS_OF->Quantidade) * (PROD->Ipi / 100))

               endif

               ITENS_OF->(dbskip())

            enddo

            OFICINA->(Dbskip())

         enddo

      endif

      ////////////////////////////////////////////////////////////////////
      // FATURAMENTO _____________________________________________________

      REME->(dbsetorder(3))
      REME->(dbgotop())

      if REME->(dbseek(VEICULOS->Codigo))

         do while REME->Produto == VEICULOS->Codigo .and. ! REME->(eof()) .and. qcontprn()

            if ! qlineprn() ; exit ; endif

            qgirabarra()

            if REME->Emissao >= dDATA_INI .and. REME->Emissao <= dDATA_FIM

               nT_PROD_M += REME->Quant
               nT_PROD_R += REME->Valor

            endif

            REME->(dbskip())

         enddo

      endif

      ////////////////////////////////////////////////////////////////////
      // FATURAMENTO DO C.V.M. ___________________________________________

      FAT_CVM->(dbsetorder(1))
      FAT_CVM->(dbgotop())

      if FAT_CVM->(dbseek(VEICULOS->Codigo))

         do while FAT_CVM->Veiculo == VEICULOS->Codigo .and. ! FAT_CVM->(eof()) .and. qcontprn()

            if ! qlineprn() ; exit ; endif

            qgirabarra()

            if FAT_CVM->Data_lanc >= dDATA_INI .and. FAT_CVM->Data_lanc <= dDATA_FIM

               nT_PROD_M += FAT_CVM->Quant
               nT_PROD_R += FAT_CVM->Valor

            endif

            FAT_CVM->(dbskip())

         enddo

      endif

      if left(VEICULOS->Descricao,3) == "CVM" .and. ! empty(VEICULOS->Veic_assoc)

         ////////////////////////////////////////////////////////////////////
         // COMPRAS _________________________________________________________

         if LANC_CP->(dbseek(VEICULOS->Veic_assoc))

            do while LANC_CP->Cod_veic == VEICULOS->Veic_assoc .and. ! LANC_CP->(eof()) .and. qcontprn()

               qgirabarra()

               if ! qlineprn() ; exit ; endif

               if PEDIDO->(dbseek(LANC_CP->Cod_ped))

                  if eval(bFILTRO)

                     PROD->(dbseek(LANC_CP->Cod_prod))

                     nTOT_CUSTO += (LANC_CP->Preco*LANC_CP->Quant) + ( (LANC_CP->Preco*LANC_CP->Quant) * (LANC_CP->Aliq_ipi/100) )

                  endif

               endif

               LANC_CP->(dbskip())

            enddo

         endif

         if LANC2->(dbseek(VEICULOS->Veic_assoc))

            do while LANC2->Cod_veic == VEICULOS->Veic_assoc .and. ! LANC2->(eof()) .and. qcontprn()

               if ! qlineprn() ; exit ; endif

               qgirabarra()

               if PEDIDO2->(dbseek(LANC2->Cod_ped))

                  if eval(bFILTRO1)

                     PROD->(dbseek(LANC2->Cod_prod))

                     nTOT_CUSTO += (LANC2->Preco*LANC2->Quant) + ( (LANC2->Preco*LANC2->Quant) * (LANC2->Aliq_ipi/100) )

                  endif
               endif

               LANC2->(dbskip())

            enddo

         endif

         REQUISIC->(Dbsetorder(2))
         REQUISIC->(Dbgotop())

         if REQUISIC->(dbseek(VEICULOS->Veic_assoc))

            do while ! REQUISIC->(eof()) .and. REQUISIC->Cod_veic == VEICULOS->Veic_assoc .and. qcontprn()

               if ! qlineprn() ; exit ; endif

               qgirabarra()

               ITENS_RQ->(Dbsetorder(2))
               ITENS_RQ->(Dbseek(REQUISIC->Codigo))

               do while ITENS_RQ->Cod_req == REQUISIC->Codigo .and. ! ITENS_RQ->(eof()) .and. qcontprn()

                  if ! qlineprn() ; exit ; endif

                  qgirabarra()

                  if REQUISIC->Dt_requisi >= dDATA_INI .and. REQUISIC->Dt_requisi <= dDATA_FIM

                     PROD->(dbseek(ITENS_RQ->Cod_produt))
                     nTOT_CUSTO += (ITENS_RQ->Vl_unitari*ITENS_RQ->Quantidade)+((ITENS_RQ->Vl_unitari*ITENS_RQ->Quantidade) * (PROD->Ipi / 100))

                  endif

                  ITENS_RQ->(dbskip())

               enddo

               REQUISIC->(Dbskip())

            enddo

         endif

         OFICINA->(Dbsetorder(2))
         OFICINA->(Dbgotop())

         if OFICINA->(dbseek(VEICULOS->Veic_assoc))

            do while ! OFICINA->(eof()) .and. OFICINA->Cod_veic == VEICULOS->Veic_assoc .and. qcontprn()

               if ! qlineprn() ; exit ; endif

               qgirabarra()

               ITENS_OF->(Dbsetorder(2))
               ITENS_OF->(Dbseek(OFICINA->Codigo))

               if OFICINA->Dt_servico >= dDATA_INI .and. OFICINA->Dt_servico <= dDATA_FIM
                  nTOT_CUSTO += OFICINA->Valor_1 + OFICINA->Valor_2 + OFICINA->Valor_3 + OFICINA->Valor_4 + OFICINA->Valor_5
               endif

               do while ITENS_OF->Cod_oficin == OFICINA->Codigo .and. ! ITENS_OF->(eof()) .and. qcontprn()

                  if ! qlineprn() ; exit ; endif

                  qgirabarra()

                  if OFICINA->Dt_servico >= dDATA_INI .and. OFICINA->Dt_servico <= dDATA_FIM

                     PROD->(dbseek(ITENS_OF->Cod_produt))

                     nTOT_CUSTO += (ITENS_OF->Vl_unitari*ITENS_OF->Quantidade)+((ITENS_OF->Vl_unitari*ITENS_OF->Quantidade) * (PROD->Ipi / 100))

                  endif

                  ITENS_OF->(dbskip())

               enddo

               OFICINA->(Dbskip())

            enddo

         endif

         ////////////////////////////////////////////////////////////////////
         // FATURAMENTO _____________________________________________________

         REME->(dbsetorder(3))
         REME->(dbgotop())

         if REME->(dbseek(VEICULOS->Veic_assoc))

            do while REME->Veiculo == VEICULOS->Veic_assoc .and. ! REME->(eof()) .and. qcontprn()

               if ! qlineprn() ; exit ; endif

               qgirabarra()

               if REME->Emissao >= dDATA_INI .and. REME->Emissao <= dDATA_FIM

                  nT_PROD_M += REME->Quant
                  nT_PROD_R += REME->Valor

               endif

               REME->(dbskip())

            enddo

         endif

         ////////////////////////////////////////////////////////////////////
         // FATURAMENTO DO C.V.M. ___________________________________________

         FAT_CVM->(dbsetorder(1))
         FAT_CVM->(dbgotop())

         if FAT_CVM->(dbseek(VEICULOS->Veic_assoc))

            do while FAT_CVM->Veiculo == VEICULOS->Veic_assoc .and. ! FAT_CVM->(eof()) .and. qcontprn()

               if ! qlineprn() ; exit ; endif

               qgirabarra()

               if FAT_CVM->Data_lanc >= dDATA_INI .and. FAT_CVM->Data_lanc <= dDATA_FIM

                  nT_PROD_M += FAT_CVM->Quant
                  nT_PROD_R += FAT_CVM->Valor

               endif

               FAT_CVM->(dbskip())

            enddo

         endif

      endif

      /////////////////////////////////////////////////////////////////////////
      // VALORES ACUMULADOS ___________________________________________________

      PRODUCAO->(dbgotop())

      do while ! PRODUCAO->(eof())
         if val(PRODUCAO->Anomes) < val(qanomes(dDATA_INI)) .and. PRODUCAO->Cod_veic == VEICULOS->Codigo
            nACU_PROD := nACU_PROD + PRODUCAO->Prod_m
            nACU_MAN  := nACU_MAN  + PRODUCAO->Custo
            if PRODUCAO->Conta_corr < 0
               nACU_PREM := nACU_PREM + PRODUCAO->Premio
            endif
         endif
         PRODUCAO->(dbskip())
      enddo

      /////////////////////////////////////////////////////////////////////////
      // IMPRESSAO DE VEICULOS ________________________________________________

      FUN->(dbsetorder(1))

      FUN->(dbgotop())

      FUN->(dbseek(VEICULOS->Cod_fun))
      
      PRODUCAO->(dbgotop())
      PRODUCAO->(dbseek(strzero(val(qanomes(dDATA_INI))-1,4)+VEICULOS->Codigo))

      nCT_MES_ANT := PRODUCAO->Conta_corr
   
      SITUA->(dbseek(FUN->Matricula))

      do case
         case SITUA->Cargo == "30012A"
              nPREMIO  := nT_PROD_M * 0.3 // R$ 0,30
              nH_EXTRA := nT_PROD_M * 0.1 // 10%

              nTOT_PREMIO  := nTOT_PREMIO + nPREMIO
              nTOT_H_EXTRA := nTOT_H_EXTRA + nH_EXTRA
              nTOT_QUANT   := nTOT_QUANT + 1

              @ prow()+1,000 say VEICULOS->Descricao + " " +;
                                 FUN->Nome           + " " +;
                                 transform(PRODUCAO->PROD_M,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->PROD_R,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->Limite,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->CUSTO,"@E 999,999.99") + " " +;
                                 transform(iif(PRODUCAO->Conta_corr<0,0,PRODUCAO->PREMIO),"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->HORAS_EXT,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->Resultado,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->Conta_corr,"@E 999,999.99")

              @ prow()  ,134 say transform(nT_PROD_M,"@E 999,999.99")   + " " +;
                                 transform(nT_PROD_R,"@E 999,999.99")   + " " +;
                                 transform(nT_PROD_M*4,"@E 999,999.99") + " " +;
                                 transform(nTOT_CUSTO,"@E 999,999.99")  + " " +;
                                 transform(iif((nT_PROD_M*4) - nTOT_CUSTO + nCT_MES_ANT<0,0,nPREMIO),"@E 999,999.99")     + " " +;
                                 transform(nH_EXTRA,"@E 999,999.99")    + " " +;
                                 transform((nT_PROD_M*4) - nTOT_CUSTO,"@E 999,999.99") + " " +;
                                 transform((nT_PROD_M*4) - nTOT_CUSTO + nCT_MES_ANT,"@E 999,999.99") + " " +;
                                 transform(nACU_PROD+nT_PROD_M,"@E 999,999.99") + " " +;
                                 transform(nACU_MAN+nTOT_CUSTO,"@E 999,999.99") + " " +;
                                 transform(iif((nT_PROD_M*4) - nTOT_CUSTO + nCT_MES_ANT>0,0,nACU_PREM+nPREMIO),"@E 999,999.99") + ;
                                 transform(iif((nT_PROD_M*4) - nTOT_CUSTO + nCT_MES_ANT<0,0,nACU_PREM+nPREMIO),"@E 999,999.99")

              if PRODUCAO->(dbseek(qanomes(dDATA_INI)+VEICULOS->Codigo))

                 if PRODUCAO->(qrlock())
                    replace PRODUCAO->Cod_fun    with VEICULOS->Cod_fun
                    replace PRODUCAO->Prod_m     with nT_PROD_M
                    replace PRODUCAO->Prod_r     with nT_PROD_R
                    replace PRODUCAO->Limite     with (nT_PROD_M*4)
                    replace PRODUCAO->Custo      with nTOT_CUSTO
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with (nT_PROD_M*4) - nTOT_CUSTO
                    replace PRODUCAO->Conta_corr with (nT_PROD_M*4) - nTOT_CUSTO + nCT_MES_ANT
                 endif

              else

                 if PRODUCAO->(qappend())
                    replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                    replace PRODUCAO->Cod_veic   with VEICULOS->Codigo
                    replace PRODUCAO->Cod_fun    with VEICULOS->Cod_fun
                    replace PRODUCAO->Prod_m     with nT_PROD_M
                    replace PRODUCAO->Prod_r     with nT_PROD_R
                    replace PRODUCAO->Limite     with (nT_PROD_M*4)
                    replace PRODUCAO->Custo      with nTOT_CUSTO
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with (nT_PROD_M*4) - nTOT_CUSTO
                    replace PRODUCAO->Conta_corr with (nT_PROD_M*4) - nTOT_CUSTO + nCT_MES_ANT
                 endif

              endif

              PRODUCAO->(qunlock())

         case SITUA->Cargo == "30013A"
              nPREMIO  := nT_PROD_M * 0.2      // R$ 0,20
              nH_EXTRA := nT_PROD_M * 0.05     // 5 %

              @ prow()+1,000 say VEICULOS->Descricao + " " +;
                                 FUN->Nome           + " " +;
                                 transform(PRODUCAO->PROD_M,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->PROD_R,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->Limite,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->CUSTO,"@E 999,999.99") + " " +;
                                 transform(iif(PRODUCAO->Conta_corr<0,0,PRODUCAO->PREMIO),"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->HORAS_EXT,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->Resultado,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->Conta_corr,"@E 999,999.99")

              @ prow()  ,134 say transform(nT_PROD_M,"@E 999,999.99") + " " +;
                                 transform(nT_PROD_R,"@E 999,999.99") + " " +;
                                 transform(nT_PROD_M * 2.7,"@E 999,999.99") + " " +;
                                 transform(nTOT_CUSTO,"@E 999,999.99") + " " +;
                                 transform(iif((nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT<0,0,nPREMIO),"@E 999,999.99") + " " +;
                                 transform(nH_EXTRA,"@E 999,999.99") + " " +;
                                 transform((nT_PROD_M*2.7) - nTOT_CUSTO,"@E 999,999.99") + " " +;
                                 transform((nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT,"@E 999,999.99") + " " +;
                                 transform(nACU_PROD+nT_PROD_M,"@E 999,999.99") + " " +;
                                 transform(nACU_MAN+nTOT_CUSTO,"@E 999,999.99") + " " +;
                                 transform(iif((nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT>0,0,nACU_PREM+nPREMIO),"@E 999,999.99") + ;
                                 transform(iif((nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT<0,0,nACU_PREM+nPREMIO),"@E 999,999.99")

              if PRODUCAO->(dbseek(qanomes(dDATA_INI)+VEICULOS->Codigo))

                 if PRODUCAO->(qrlock())
                    replace PRODUCAO->Cod_fun    with VEICULOS->Cod_fun
                    replace PRODUCAO->Prod_m     with nT_PROD_M
                    replace PRODUCAO->Prod_r     with nT_PROD_R
                    replace PRODUCAO->Limite     with (nT_PROD_M*2.7)
                    replace PRODUCAO->Custo      with nTOT_CUSTO
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with (nT_PROD_M*2.7) - nTOT_CUSTO
                    replace PRODUCAO->Conta_corr with (nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT
                 endif

              else

                 if PRODUCAO->(qappend())
                    replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                    replace PRODUCAO->Cod_veic   with VEICULOS->Codigo
                    replace PRODUCAO->Cod_fun    with VEICULOS->Cod_fun
                    replace PRODUCAO->Prod_m     with nT_PROD_M
                    replace PRODUCAO->Prod_r     with nT_PROD_R
                    replace PRODUCAO->Limite     with (nT_PROD_M*2.7)
                    replace PRODUCAO->Custo      with nTOT_CUSTO
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with (nT_PROD_M*2.7) - nTOT_CUSTO
                    replace PRODUCAO->Conta_corr with (nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT
                 endif

              endif

              PRODUCAO->(qunlock())

              //////////////////////////////////////////////////////////////////////////
              // IMPRESSAO DE AJUDANTE DE BOMBA ________________________________________

              if ! empty(VEICULOS->Ajudante)

                 /////////////////////////////////////////////////////////////////////////
                 // VALORES ACUMULADOS ___________________________________________________

                 PRODUCAO->(dbgotop())

                 nACU_PROD := 0
                 nACU_MAN  := 0
                 nACU_PREM := 0

                 do while ! PRODUCAO->(eof())
                    if val(PRODUCAO->Anomes) < val(qanomes(dDATA_INI)) .and. PRODUCAO->Cod_veic == VEICULOS->Ajudante
                       nACU_PROD := nACU_PROD + PRODUCAO->Prod_m
                       nACU_MAN  := nACU_MAN  + PRODUCAO->Custo
                       if PRODUCAO->Conta_corr < 0
                          nACU_PREM := nACU_PREM + PRODUCAO->Premio
                       endif
                    endif
                    PRODUCAO->(dbskip())
                 enddo

                 FUN->(dbseek(VEICULOS->Ajudante))

                 PRODUCAO->(dbgotop())
                 PRODUCAO->(dbseek(strzero(val(qanomes(dDATA_INI))-1,4)+VEICULOS->Ajudante))
                 nCT_MES_ANT := PRODUCAO->Conta_corr

                 @ prow()+1,000 say "AJ. DE BOMBA    " +;
                                    FUN->Nome           + " " +;
                                    transform(PRODUCAO->PROD_M,"@E 999,999.99") + " " +;
                                    transform(PRODUCAO->PROD_R,"@E 999,999.99") + " " +;
                                    transform(PRODUCAO->Limite,"@E 999,999.99") + " " +;
                                    transform(PRODUCAO->CUSTO,"@E 999,999.99") + " " +;
                                    transform(iif(PRODUCAO->Conta_corr<0,0,PRODUCAO->PREMIO),"@E 999,999.99") + " " +;
                                    transform(PRODUCAO->HORAS_EXT,"@E 999,999.99") + " " +;
                                    transform(PRODUCAO->Resultado,"@E 999,999.99") + " " +;
                                    transform(PRODUCAO->Conta_corr,"@E 999,999.99")

                 @ prow()  ,134 say transform(nT_PROD_M,"@E 999,999.99") + " " +;
                                    transform(nT_PROD_R,"@E 999,999.99") + " " +;
                                    transform(nT_PROD_M*2.7,"@E 999,999.99") + " " +;
                                    transform(nTOT_CUSTO,"@E 999,999.99") + " " +;
                                    transform(iif((nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT<0,0,nPREMIO/2),"@E 999,999.99") + " " +;
                                    transform(nH_EXTRA,"@E 999,999.99") + " " +;
                                    transform((nT_PROD_M*2.7) - nTOT_CUSTO,"@E 999,999.99") + " " +;
                                    transform((nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT,"@E 999,999.99") + " " +;
                                    transform(nACU_PROD+nT_PROD_M,"@E 999,999.99") + " " +;
                                    transform(nACU_MAN+nTOT_CUSTO,"@E 999,999.99") + " " +;
                                    transform(iif((nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT>0,0,nACU_PREM+nPREMIO),"@E 999,999.99") + ;
                                    transform(iif((nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT<0,0,nACU_PREM+nPREMIO),"@E 999,999.99")

                 if PRODUCAO->(dbseek(qanomes(dDATA_INI)+VEICULOS->Ajudante))

                    if PRODUCAO->(qrlock())
                       replace PRODUCAO->Prod_m     with nT_PROD_M
                       replace PRODUCAO->Prod_r     with nT_PROD_R
                       replace PRODUCAO->Limite     with (nT_PROD_M*2.7)
                       replace PRODUCAO->Custo      with nTOT_CUSTO
                       replace PRODUCAO->Premio     with nPREMIO/2
                       replace PRODUCAO->Horas_ext  with nH_EXTRA
                       replace PRODUCAO->Resultado  with (nT_PROD_M*2.7) - nTOT_CUSTO
                       replace PRODUCAO->Conta_corr with (nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT
                    endif

                 else

                    if PRODUCAO->(qappend())
                       replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                       replace PRODUCAO->Cod_veic   with VEICULOS->Ajudante
                       replace PRODUCAO->Prod_m     with nT_PROD_M
                       replace PRODUCAO->Prod_r     with nT_PROD_R
                       replace PRODUCAO->Limite     with (nT_PROD_M*2.7)
                       replace PRODUCAO->Custo      with nTOT_CUSTO
                       replace PRODUCAO->Premio     with nPREMIO/2
                       replace PRODUCAO->Horas_ext  with nH_EXTRA
                       replace PRODUCAO->Resultado  with (nT_PROD_M*2.7) - nTOT_CUSTO
                       replace PRODUCAO->Conta_corr with (nT_PROD_M*2.7) - nTOT_CUSTO + nCT_MES_ANT
                    endif

                 endif

                 PRODUCAO->(qunlock())

              endif

         case SITUA->Cargo == "30043A"
              nPREMIO  := 0
              nH_EXTRA := 0

              @ prow()+1,000 say VEICULOS->Descricao + " " +;
                                 FUN->Nome           + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99")

              @ prow()  ,134 say transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99")

              if PRODUCAO->(dbseek(qanomes(dDATA_INI)+VEICULOS->Codigo))

                 if PRODUCAO->(qrlock())
                    replace PRODUCAO->Cod_fun    with VEICULOS->Cod_fun
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with 0
                    replace PRODUCAO->Horas_ext  with 0
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              else

                 if PRODUCAO->(qappend())
                    replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                    replace PRODUCAO->Cod_veic   with VEICULOS->Codigo
                    replace PRODUCAO->Cod_fun    with VEICULOS->Cod_fun
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with 0
                    replace PRODUCAO->Horas_ext  with 0
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              endif

              PRODUCAO->(qunlock())

      endcase
           
      nTOT_CUSTO    := 0
      nT_PROD_M     := 0
      nT_PROD_R     := 0
      nPREMIO       := 0
      nH_EXTRA      := 0
      nACU_PROD     := 0
      nACU_MAN      := 0
      nACU_PREM     := 0

      VEICULOS->(Dbskip())

   enddo

   LANC_CP->(dbclosearea())
   
   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR OS DEMAIS FUNCIONARIOS ______________________________

static function i_imprime_funcionarios

   FUN->(dbsetorder(5))       // FILIAL + MATRICULA

   FUN->(dbgotop())

   if ! empty(cFILIAL)
      FUN->(dbseek(cFILIAL))
   endif

   do while ! FUN->(eof()) .and. qcontprn()

      if ! qlineprn() ; exit ; endif

      qgirabarra()

      if ! empty(cFILIAL)
         if FUN->Filial <> cFILIAL
            return
         endif
      else
         if FUN->Filial <> cTEMP_FILIAL
            return
         endif
      endif
      
      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @ prow(),pcol() say XCOND2
         qpageprn()
         qcabecprn(cTITULO,264)
         FILIAL->(VEICULOS->Filial)
         CCUSTO->(VEICULOS->Centro)
         @ prow()+1,0 say "FILIAL: " + FUN->Filial + "-" + FILIAL->Razao
         @ prow()+1,0 say "CENTRO: " + VEICULOS->Centro + "-" + CCUSTO->Descricao
         @ prow()+1,0 say replicate("-",264)
         @ prow()+1,0 say "                                                 MES ANTERIOR                                                                           MES CORRENTE"
         @ prow()+1,0 say "VEICULO/CARGO   FUNCIONARIO                      PROD. M3   PROD. R$   LIM.MAN.  CUSTO MAN.    PREMIO   H.EXTRAS   RES.MAN.    CT.COR.  PROD. M3   PROD. R$   LIM.MAN.  CUSTO MAN.    PREMIO   H.EXTRAS   RES.MAN.  CONTA COR.  PROD.ACUM.  C.ACUM.  PREM. ACUM. P.PAGAR"
         @ prow()+1,0 say replicate("-",264)
      endif

      /////////////////////////////////////////////////////////////////////////
      // VALORES ACUMULADOS ___________________________________________________

      PRODUCAO->(dbgotop())

      nACU_PREM := 0

      do while ! PRODUCAO->(eof())
         if val(PRODUCAO->Anomes) < val(qanomes(dDATA_INI)) .and. PRODUCAO->Cod_veic == FUN->Matricula
            if PRODUCAO->Conta_corr < 0
               nACU_PREM := nACU_PREM + PRODUCAO->Premio
            endif
         endif
         PRODUCAO->(dbskip())
      enddo

      PRODUCAO->(dbgotop())
      PRODUCAO->(dbseek(strzero(val(qanomes(dDATA_INI))-1,4)+FUN->Matricula))
      nCT_MES_ANT := PRODUCAO->Conta_corr

      SITUA->(dbseek(FUN->Matricula))

      do case
//       case SITUA->Cargo == "30039A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(FUN->Centro,4) == cTEMP_CENTRO,.T.)
         case SITUA->Cargo == "30039A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(SITUA->Ccusto,4) == cTEMP_CENTRO,.T.)
              nPREMIO  := nTOT_PREMIO  / nTOT_QUANT
              nH_EXTRA := nTOT_H_EXTRA / nTOT_QUANT
              nH_EXTRA := nH_EXTRA / 2

              @ prow()+1,000 say "BALANCEIRO      " +;
                                 FUN->Nome    + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->PREMIO,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->HORAS_EXT,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99")

              @ prow()  ,134 say transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nPREMIO,"@E 999,999.99") + " " +;
                                 transform(nH_EXTRA,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nACU_PREM+nPREMIO,"@E 999,999.99")

              if PRODUCAO->(dbseek(qanomes(dDATA_INI)+FUN->Matricula))

                 if PRODUCAO->(qrlock())
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              else

                 if PRODUCAO->(qappend())
                    replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                    replace PRODUCAO->Cod_veic   with FUN->Matricula
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              endif

              PRODUCAO->(qunlock())

//       case SITUA->Cargo $ "30008A_30009A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(FUN->Centro,4) == cTEMP_CENTRO,.T.)
         case SITUA->Cargo $ "30008A_30009A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(SITUA->Ccusto,4) == cTEMP_CENTRO,.T.)
              nPREMIO  := nTOT_PREMIO  / nTOT_QUANT
              nH_EXTRA := nTOT_H_EXTRA / nTOT_QUANT
              nH_EXTRA := nH_EXTRA / 2

              @ prow()+1,000 say "PROGRAMADOR     " +;
                                 FUN->Nome    + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->PREMIO,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->HORAS_EXT,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99")

              @ prow()  ,134 say transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nPREMIO,"@E 999,999.99") + " " +;
                                 transform(nH_EXTRA,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nACU_PREM+nPREMIO,"@E 999,999.99")

              if PRODUCAO->(dbseek(qanomes(dDATA_INI)+FUN->Matricula))

                 if PRODUCAO->(qrlock())
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              else

                 if PRODUCAO->(qappend())
                    replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                    replace PRODUCAO->Cod_veic   with FUN->Matricula
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              endif

              PRODUCAO->(qunlock())

//       case SITUA->Cargo == "30007A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(FUN->Centro,4) == cTEMP_CENTRO,.T.)
         case SITUA->Cargo == "30007A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(SITUA->Ccusto,4) == cTEMP_CENTRO,.T.)
              nPREMIO  := nTOT_PREMIO  / nTOT_QUANT

              @ prow()+1,000 say "CHEFE CENTRAL   " +;
                                 FUN->Nome    + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->PREMIO,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99")

              @ prow()  ,134 say transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nPREMIO,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nACU_PREM+nPREMIO,"@E 999,999.99")

              if PRODUCAO->(dbseek(qanomes(dDATA_INI)+FUN->Matricula))

                 if PRODUCAO->(qrlock())
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with 0
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              else

                 if PRODUCAO->(qappend())
                    replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                    replace PRODUCAO->Cod_veic   with FUN->Matricula
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with 0
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              endif

              PRODUCAO->(qunlock())

//       case SITUA->Cargo == "30019A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(FUN->Centro,4) == cTEMP_CENTRO,.T.)
         case SITUA->Cargo == "30019A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(SITUA->Ccusto,4) == cTEMP_CENTRO,.T.)
              nPREMIO  := nTOT_PREMIO  / nTOT_QUANT
              nH_EXTRA := nTOT_H_EXTRA / nTOT_QUANT

              @ prow()+1,000 say "MECANICO        " +;
                                 FUN->Nome    + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->PREMIO,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->HORAS_EXT,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99")

              @ prow()  ,134 say transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nPREMIO,"@E 999,999.99") + " " +;
                                 transform(nH_EXTRA,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nACU_PREM+nPREMIO,"@E 999,999.99")

              if PRODUCAO->(dbseek(qanomes(dDATA_INI)+FUN->Matricula))

                 if PRODUCAO->(qrlock())
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              else

                 if PRODUCAO->(qappend())
                    replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                    replace PRODUCAO->Cod_veic   with FUN->Matricula
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              endif

              PRODUCAO->(qunlock())

//       case SITUA->Cargo == "30010A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(FUN->Centro,4) == cTEMP_CENTRO,.T.)
         case SITUA->Cargo == "30010A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(SITUA->Ccusto,4) == cTEMP_CENTRO,.T.)
              nPREMIO  := (nTOT_PREMIO  / nTOT_QUANT) / 2
              nH_EXTRA := (nTOT_H_EXTRA / nTOT_QUANT) / 2

              @ prow()+1,000 say "OPERADOR DE PA  " +;
                                 FUN->Nome    + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->PREMIO,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->HORAS_EXT,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99")

              @ prow()  ,134 say transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nPREMIO,"@E 999,999.99") + " " +;
                                 transform(nH_EXTRA,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nACU_PREM+nPREMIO,"@E 999,999.99")

              if PRODUCAO->(dbseek(qanomes(dDATA_INI)+FUN->Matricula))

                 if PRODUCAO->(qrlock())
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              else

                 if PRODUCAO->(qappend())
                    replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                    replace PRODUCAO->Cod_veic   with FUN->Matricula
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              endif

              PRODUCAO->(qunlock())

//       case SITUA->Cargo == "30040A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(FUN->Centro,4) == cTEMP_CENTRO,.T.)
         case SITUA->Cargo == "30040A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(SITUA->Ccusto,4) == cTEMP_CENTRO,.T.)
              nPREMIO  := (nTOT_PREMIO  / nTOT_QUANT) / 2
              nH_EXTRA := (nTOT_H_EXTRA / nTOT_QUANT) / 2

              @ prow()+1,000 say "AJ. SERV.GERAIS " +;
                                 FUN->Nome    + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->PREMIO,"@E 999,999.99") + " " +;
                                 transform(PRODUCAO->HORAS_EXT,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99")

              @ prow()  ,134 say transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nPREMIO,"@E 999,999.99") + " " +;
                                 transform(nH_EXTRA,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nACU_PREM+nPREMIO,"@E 999,999.99")

              if PRODUCAO->(dbseek(qanomes(dDATA_INI)+FUN->Matricula))

                 if PRODUCAO->(qrlock())
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              else

                 if PRODUCAO->(qappend())
                    replace PRODUCAO->Anomes     with qanomes(dDATA_INI)
                    replace PRODUCAO->Cod_veic   with FUN->Matricula
                    replace PRODUCAO->Prod_m     with 0
                    replace PRODUCAO->Prod_r     with 0
                    replace PRODUCAO->Limite     with 0
                    replace PRODUCAO->Custo      with 0
                    replace PRODUCAO->Premio     with nPREMIO
                    replace PRODUCAO->Horas_ext  with nH_EXTRA
                    replace PRODUCAO->Resultado  with 0
                    replace PRODUCAO->Conta_corr with 0
                 endif

              endif

              PRODUCAO->(qunlock())

//       case SITUA->Cargo == "10018A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(FUN->Centro,4) == cTEMP_CENTRO,.T.)
         case SITUA->Cargo == "10018A" .and. SITUA->Situacao $ "TD" .and. iif(FUN->Filial=="0001",right(SITUA->Ccusto,4) == cTEMP_CENTRO,.T.)
              nPREMIO  := 0
              nH_EXTRA := 0

              @ prow()+1,000 say "GERENTE         " +;
                                 FUN->Nome    + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99")

              @ prow()  ,134 say transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(0,"@E 999,999.99") + " " +;
                                 transform(nACU_PREM+nPREMIO,"@E 999,999.99")

      endcase

      nPREMIO       := 0
      nH_EXTRA      := 0

      FUN->(dbskip())

   enddo

return
