/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: AGOSTO DE 1998
// OBS........:
// ALTERACOES.:
function es503

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cTITULO                // titulo do relatorio
private aEDICAO   := {}        // vetor para os campos
private cCOD_PROD := space(5)  // produto
private cFILIAL   := space(4)  // filial
private dDT_INI                // data inicial na faixa
private dDT_FIM                // data final na faixa
private nSALDO     := 0
private nSALDO_ANT := 0

private tFILIAL
private tDATA
private tCOD_PROD
private tCODIGO
private tCOD_ITEM
private tQTDE

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"@R 9999"   )},"FILIAL"})
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
aadd(aEDICAO,{{ || view_prod(-1,0,@cCOD_PROD,"@R 99999"  )},"PROD"  })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_INI    ,"@D"      )},"DT_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_FIM    ,"@D"      )},"DT_FIMF"})

do while .T.

   qlbloc(5,0,"B503A","QBLOC.GLO")

   XNIVEL     := 1
   XFLAG      := .T.
   dDT_INI    := ctod("")
   dDT_FIM    := qfimmes(dDT_INI)
   cFILIAL    := space(4)
   cCOD_PROD  := space(5)
   nSALDO     := 0
   nSALDO_ANT := 0

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

      case cCAMPO == "PROD"

           if empty(cCOD_PROD) ; return .F. ; endif

           PROD->(dbsetorder(4))

           if ! PROD->(dbseek(cCOD_PROD:=strzero(val(cCOD_PROD),5)))
              qmensa("Produto n„o cadastrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(PROD->Descricao,20)+" "+left(PROD->Cod_fabr,4))

           if ! INVENT->(dbseek(cFILIAL+cCOD_PROD))
              qmensa("N„o Existe Invent rio para este Produto !","B")
              return .F.
           endif

           //do while ! INVENT->(eof()) .and. INVENT->Filial == cFILIAL .and. INVENT->Cod_prod == cCOD_PROD
           //   nSALDO_ANT += INVENT->Quantidade
           //   nSALDO     += INVENT->Quantidade
           //   INVENT->(dbskip())
           //enddo
                            
      case cCAMPO == "FILIAL"

           if empty(cFILIAL) ; return .F. ; endif

           qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))

           if ! FILIAL->(dbseek(cFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,30))


      case cCAMPO == "DT_INI"

           if empty(dDT_INI) ; return .F. ; endif
           dDT_FIM := qfimmes(dDT_INI)
           qrsay(XNIVEL+1,dDT_FIM)

      case cCAMPO == "DT_FIM"

           if empty(dDT_FIM) ; return .F. ; endif
           if dDT_INI > cDT_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ____________________________

static function i_inicializacao

   cTITULO := "RAZAO POR PRODUTO - " + dtoc(dDT_INI) + " ATE " + dtoc(dDT_FIM)

   // SELECIONA ORDEM DO ARQUIVO REQUISIC ____________________________________

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND0

   /////////////////////////////////////////////////////////////////////
   // SALDO ANTERIOR ___________________________________________________

   // rotina para verificar qual faturamento esta sendo utilizado
   do case

      case CONFIG->Tipo_fat == "1"
           if ! quse(XDRV_CL , "FAT",{"FATFATUR","FATDTEMI","FAT_FIDE","FAT_REPR","FAT_DTRE"})
              qmensa("N„o foi poss¡vel abrir arquivo FAT.DBF !! Tente novamente.")
              return
           endif
           if ! quse(XDRV_CL , "ITEN_FAT",{"FAT_FAPR","ITEN_NUM","FAT_SERV"})
              qmensa("N„o foi poss¡vel abrir arquivo ITEN_FAT.DBF !! Tente novamente.")
              return
           endif

           FAT->(dbsetorder(3))
           FAT->(dbgotop())

           ITEN_FAT->(dbsetorder(2))
           ITEN_FAT->(dbgotop())

           ver_fat("FAT->Filial","FAT->Dt_emissao","FAT->Codigo","ITEN_FAT->Cod_prod","ITEN_FAT->Num_fat","ITEN_FAT->Quantidade","FAT","ITEN_FAT")

           FAT->(dbclosearea())
           ITEN_FAT->(dbclosearea())

      case CONFIG->Tipo_fat == "2"
           if ! quse(XDRV_IN , "FAT",{"FATFATUR","FATDTEMI","FAT_FIDE","FAT_REPR"})
              qmensa("N„o foi poss¡vel abrir arquivo FAT.DBF !! Tente novamente.")
              return
           endif
           if ! quse(XDRV_IN , "ITEN_FAT",{"FAT_FAPR"})
              qmensa("N„o foi poss¡vel abrir arquivo ITEN_FAT.DBF !! Tente novamente.")
              return
           endif

           FAT->(dbsetorder(3))
           FAT->(dbgotop())

           ITEN_FAT->(dbsetorder(1))
           ITEN_FAT->(dbgotop())

           ver_fat("FAT->Filial","FAT->Dt_emissao","FAT->Codigo","ITEN_FAT->Cod_prod","ITEN_FAT->Num_fat","ITEN_FAT->Quantidade","FAT","ITEN_FAT")

           FAT->(dbclosearea())
           ITEN_FAT->(dbclosearea())

      case CONFIG->Tipo_fat == "4" // tele-vendas na PAPYRUS, puxa o arquivo do faturamento da fabrica
           if ! quse(XDRV_TV , "PEDIDO",{"PED_CODI","PED_FATU","PEDI_DAT","PED_MOTI","PED_CLIE","PED_DTFA","PED_CODC"})
              qmensa("N„o foi poss¡vel abrir arquivo PEDIDO.DBF !! Tente novamente.")
              return
           endif
           if ! quse(XDRV_TV , "ITEN_PED",{"IPED_COD"})
              qmensa("N„o foi poss¡vel abrir arquivo ITEN_PED.DBF !! Tente novamente.")
              return
           endif

           PEDIDO->(dbsetorder(3))
           PEDIDO->(dbgotop())

           ITEN_PED->(dbsetorder(1))
           ITEN_PED->(dbgotop())

           ver_fat("PEDIDO->Filial","PEDIDO->Data","PEDIDO->Codigo","ITEN_PED->Codi_prod","ITEN_PED->Codi_ped","ITEN_PED->Quantidade","PEDIDO","ITEN_PED")

           PEDIDO->(dbclosearea())
           ITEN_PED->(dbclosearea())

   endcase

   // fim da rotina para verificar faturamento

   ////////////////////////////////////////
   // REQUISIC.DBF E ITENS_RQ.DBF ________

   REQUISIC->(dbsetorder(3))
   REQUISIC->(dbgotop())

   if REQUISIC->(dbseek(cFILIAL))

      qmensa("Filial: " + cFILIAL + " Produto: " + cCOD_PROD + " Requisi‡„o: " + REQUISIC->Codigo)

      qgirabarra()

      do while ! REQUISIC->(eof()) .and. REQUISIC->Filial == cFilial

         qgirabarra()

         ITENS_RQ->(Dbsetorder(2))
         ITENS_RQ->(Dbgotop())
         ITENS_RQ->(Dbseek(REQUISIC->Codigo))

         if REQUISIC->Dt_requisi < dDT_INI
            do while ! ITENS_RQ->(eof()) .and. ITENS_RQ->Cod_req == REQUISIC->Codigo
               if ITENS_RQ->Cod_produt == cCod_prod
                  nSALDO_ANT := nSALDO_ANT - ITENS_RQ->Quantidade
                  nSALDO     := nSALDO - ITENS_RQ->Quantidade
               endif
               ITENS_RQ->(dbskip())
            enddo
         endif

         REQUISIC->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // OFICINA.DBF E ITENS_OF.DBF ________

   OFICINA->(dbsetorder(3))
   OFICINA->(dbgotop())

   if OFICINA->(dbseek(cFILIAL))

      qmensa("Filial: " + cFILIAL + " Produto: " + cCOD_PROD + " Oficina: " + OFICINA->Codigo)

      qgirabarra()

      do while ! OFICINA->(eof()) .and. OFICINA->Filial == cFilial

         qgirabarra()

         ITENS_OF->(Dbsetorder(2))
         ITENS_OF->(Dbgotop())
         ITENS_OF->(Dbseek(OFICINA->Codigo))

         if OFICINA->Dt_servico < dDT_INI
            do while ! ITENS_OF->(eof()) .and. ITENS_OF->Cod_oficin == OFICINA->Codigo
               if ITENS_OF->Cod_produt == cCOD_PROD
                  nSALDO_ANT := nSALDO_ANT - ITENS_OF->Quantidade
                  nSALDO     := nSALDO - ITENS_OF->Quantidade
               endif
               ITENS_OF->(dbskip())
            enddo
         endif

         OFICINA->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // PEDIDO.DBF E LANC.DBF _______________

   PEDIDO->(Dbsetorder(4))
   PEDIDO->(Dbgotop())

   if PEDIDO->(dbseek(cFilial))

      do while ! PEDIDO->(eof()) .and. alltrim(PEDIDO->Filial) == cFilial

         qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Pedido: " + PEDIDO->Codigo)

         LANC->(Dbsetorder(1))
         LANC->(Dbgotop())

         if PEDIDO->Data_ped < dDT_INI
            if LANC->(dbseek(PEDIDO->Codigo))
               do while ! LANC->(eof()) .and. PEDIDO->Codigo == LANC->Cod_ped

                  qgirabarra()

                  if LANC->Cod_prod == cCod_prod .and. PEDIDO->Estoque == "S"
                     nSALDO_ANT := nSALDO_ANT + (LANC->Quant * LANC->Fator)
                     nSALDO     := nSALDO + (LANC->Quant * LANC->Fator)
                  endif

                  LANC->(dbskip())

               enddo
            endif
         endif

         PEDIDO->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // PEDIDO2.DBF E LANC2.DBF _____________

   PEDIDO2->(Dbsetorder(4))
   PEDIDO2->(Dbgotop())

   if PEDIDO2->(dbseek(cFilial))

      do while ! PEDIDO2->(eof()) .and. alltrim(PEDIDO2->Filial) == cFilial

         qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Pedido: " + PEDIDO2->Codigo)

         LANC2->(Dbsetorder(1))
         LANC2->(Dbgotop())

         if PEDIDO2->Data_ped < dDT_INI
            if LANC2->(dbseek(PEDIDO2->Codigo))
               do while ! LANC2->(eof()) .and. PEDIDO2->Codigo == LANC2->Cod_ped

                  qgirabarra()

                  if LANC2->Cod_prod == cCod_prod .and. PEDIDO2->Estoque == "S"
                     nSALDO_ANT := nSALDO_ANT + (LANC2->Quant * LANC2->Fator)
                     nSALDO     := nSALDO + (LANC2->Quant * LANC2->Fator)
                  endif

                  LANC2->(dbskip())

               enddo
            endif
         endif

         PEDIDO2->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // MOVIMENT.DBF ________________________

   MOVIMENT->(Dbsetorder(5))
   MOVIMENT->(Dbgotop())

   if MOVIMENT->(Dbseek(cFilial+cCod_prod))

      qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Dt. Mov.: " + dtoc(MOVIMENT->Data) + " E/S: " + MOVIMENT->Tipo)

      do while ! MOVIMENT->(eof()) .and. MOVIMENT->Filial == cFilial .and. MOVIMENT->Cod_prod == cCod_prod

         qgirabarra()

         if MOVIMENT->Data < dDT_INI
            if MOVIMENT->Tipo == "E" .and. ! MOVIMENT->Contabil
               nSALDO_ANT := nSALDO_ANT + MOVIMENT->Quantidade
               nSALDO     := nSALDO + MOVIMENT->Quantidade
            endif

            if MOVIMENT->Tipo $ "SB" .and. ! MOVIMENT->Contabil
               nSALDO_ANT := nSALDO_ANT - MOVIMENT->Quantidade
               nSALDO     := nSALDO - MOVIMENT->Quantidade
            endif
         endif

         MOVIMENT->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // REL_COMB.DBF E ITENS_RC.DBF _________

   REL_COMB->(Dbsetorder(2))
   REL_COMB->(Dbgotop())

   if REL_COMB->(Dbseek(cFilial+cCod_prod))

      qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Rel. Comb.: " + REL_COMB->Codigo)

      do while ! REL_COMB->(eof()) .and. REL_COMB->Filial == cFilial .and. REL_COMB->Cod_prod == cCod_prod

         qgirabarra()

         ITENS_RC->(dbgotop())

         if REL_COMB->Dt_relato < dDT_INI

            if ITENS_RC->(dbseek(REL_COMB->Codigo))
               do while ! ITENS_RC->(eof()) .and. ITENS_RC->Cod_relcom == REL_COMB->Codigo
                  nSALDO_ANT := nSALDO_ANT - ITENS_RC->Quantidade
                  nSALDO     := nSALDO - ITENS_RC->Quantidade
                  ITENS_RC->(dbskip())
               enddo
            endif

         endif

         REL_COMB->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // NFTRANF.DBF E ITENS_NF.DBF __________

   NFTRANSF->(Dbsetorder(2))
   NFTRANSF->(Dbgotop())

   if NFTRANSF->(dbseek(cFilial))

      do while ! NFTRANSF->(eof()) .and. NFTRANSF->Filial == cFilial

         qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Nf. Transf.: " + NFTRANSF->Codigo)

         ITENS_NF->(Dbsetorder(1))
         ITENS_NF->(Dbgotop())

         if NFTRANSF->Dt_lancto < dDT_INI

            if ITENS_NF->(dbseek(NFTRANSF->Codigo))
               do while ! ITENS_NF->(eof()) .and. NFTRANSF->Codigo == ITENS_NF->Num_nf

                  qgirabarra()

                  if ITENS_NF->Cod_produt == cCod_prod
                     nSALDO_ANT := nSALDO_ANT - ITENS_NF->Quantidade
                     nSALDO     := nSALDO - ITENS_NF->Quantidade
                  endif

                  ITENS_NF->(dbskip())

               enddo
            endif

         endif

         NFTRANSF->(dbskip())

      enddo

   endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      qcabecprn(cTITULO,80)
      @ prow()+1,0 say "PRODUTO -> "+left(PROD->Cod_fabr,4)  + " - " + left(PROD->Descricao,20) + " "+PROD->Cod_ass + " "+left(PROD->Marca,12)
      @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
      @ prow()+1,0 say replicate("-",80)
      @ prow()+1,0 say "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
      @ prow()+1,0 say replicate("-",80)
   endif

   @ prow()+1,00 say dtoc(dDT_INI-1)
   @ prow()  ,11 say transform(nSALDO_ANT, "@E 9,999,999.99")
   @ prow()  ,45 say "Saldo Anterior"
   @ prow()  ,68 say transform(nSALDO_ANT, "@E 9,999,999.99")

   /////////////////////////////////////////////////////////////////////
   // IMPRESSAO DE MOVIMENTO DENTRO DO PERIODO SOLICITADO ______________

   ////////////////////////////////////////
   // PEDIDO.DBF E LANC.DBF _______________

   PEDIDO->(Dbsetorder(4))
   PEDIDO->(Dbgotop())

   if PEDIDO->(dbseek(cFilial))

      do while ! PEDIDO->(eof()) .and. alltrim(PEDIDO->Filial) == cFilial .and. qcontprn()

         if ! qlineprn() ; exit ; endif

         qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Pedido: " + PEDIDO->Codigo)

         LANC->(Dbsetorder(1))
         LANC->(Dbgotop())

         if PEDIDO->Data_ped >= dDT_INI .and. PEDIDO->Data_ped <= dDT_FIM
            if LANC->(dbseek(PEDIDO->Codigo))
               do while ! LANC->(eof()) .and. PEDIDO->Codigo == LANC->Cod_ped .and. qcontprn()

                  if ! qlineprn() ; exit ; endif

                  qgirabarra()

                  if LANC->Cod_prod == cCod_prod .and. PEDIDO->Estoque == "S"

                     if XPAGINA == 0 .or. prow() > K_MAX_LIN
                        qpageprn()
                        qcabecprn(cTITULO,80)
                        @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
                        @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
                        @ prow()+1,0 say replicate("-",80)
                        @ prow()+1,0 say "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
                        @ prow()+1,0 say replicate("-",80)
                     endif
                                                  
                     @ prow()+1,00 say dtoc(PEDIDO->Data_ped)
                     @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
                     @ prow()  ,24 say LANC->Lote
                     @ prow()  ,35 say transform(LANC->Quant * LANC->Fator, "@E 999999.99")
                     @ prow()  ,45 say "Entrada "
                     @ prow()  ,56 say transform(PEDIDO->Codigo,"@R 99999/9999")
                     nSALDO := nSALDO + (LANC->Quant * LANC->Fator)
                     @ prow()  ,68 say transform(nSALDO, "@E 9,999,999.99")

                  endif

                  LANC->(dbskip())

               enddo
            endif
         endif

         PEDIDO->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // PEDIDO2.DBF E LANC2.DBF _____________

   PEDIDO2->(Dbsetorder(4))
   PEDIDO2->(Dbgotop())

   if PEDIDO2->(dbseek(cFilial))

      do while ! PEDIDO2->(eof()) .and. alltrim(PEDIDO2->Filial) == cFilial .and. qcontprn()

         if ! qlineprn() ; exit ; endif

         qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Pedido: " + PEDIDO2->Codigo)

         LANC2->(Dbsetorder(1))
         LANC2->(Dbgotop())

         if PEDIDO2->Data_ped >= dDT_INI .and. PEDIDO2->Data_ped <= dDT_FIM
            if LANC2->(dbseek(PEDIDO2->Codigo))
               do while ! LANC2->(eof()) .and. PEDIDO2->Codigo == LANC2->Cod_ped .and. qcontprn()

                  if ! qlineprn() ; exit ; endif

                  qgirabarra()

                  if LANC2->Cod_prod == cCod_prod .and. PEDIDO2->Estoque == "S"

                     if XPAGINA == 0 .or. prow() > K_MAX_LIN
                        qpageprn()
                        qcabecprn(cTITULO,80)
                        @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
                        @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
                        @ prow()+1,0 say replicate("-",80)
                        @ prow()+1,0 say "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
                        @ prow()+1,0 say replicate("-",80)
                     endif

                     @ prow()+1,00 say dtoc(PEDIDO2->Data_ped)
                     @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
                     @ prow()  ,24 say LANC2->Lote
                     @ prow()  ,35 say transform(LANC2->Quant * LANC2->Fator, "@E 999999.99")
                     @ prow()  ,45 say "Entrada "
                     @ prow()  ,56 say transform(PEDIDO2->Codigo,"@R 99999/9999")
                     nSALDO := nSALDO + (LANC2->Quant * LANC2->Fator)
                     @ prow()  ,68 say transform(nSALDO, "@e 9,999,999.99")

                  endif

                  LANC2->(dbskip())

               enddo
            endif
         endif

         PEDIDO2->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // REQUISIC.DBF E ITENS_RQ.DBF ________

   REQUISIC->(dbsetorder(3))
   REQUISIC->(dbgotop())

   if REQUISIC->(dbseek(cFILIAL))

      qmensa("Filial: " + cFILIAL + " Produto: " + cCOD_PROD + " Requisi‡„o: " + REQUISIC->Codigo)

      qgirabarra()

      do while ! REQUISIC->(eof()) .and. REQUISIC->Filial == cFilial .and. qcontprn()

         if ! qlineprn() ; exit ; endif

         qgirabarra()

         ITENS_RQ->(Dbsetorder(2))
         ITENS_RQ->(Dbgotop())
         ITENS_RQ->(Dbseek(REQUISIC->Codigo))

         if REQUISIC->Dt_requisi >= dDT_INI .and. REQUISIC->Dt_requisi <= dDT_FIM
            do while ! ITENS_RQ->(eof()) .and. ITENS_RQ->Cod_req == REQUISIC->Codigo .and. qcontprn()

               if ! qlineprn() ; exit ; endif

               if ITENS_RQ->Cod_produt == cCod_prod

                  if XPAGINA == 0 .or. prow() > K_MAX_LIN
                     qpageprn()
                     qcabecprn(cTITULO,80)
                     @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
                     @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
                     @ prow()+1,0 say replicate("-",80)
                     @ prow()+1,0 say "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
                     @ prow()+1,0 say replicate("-",80)
                  endif

                  @ prow()+1,00 say dtoc(REQUISIC->Dt_requisi)
                  @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
                  @ prow()  ,24 say ITENS_RQ->Lote
                  @ prow()  ,36 say transform(ITENS_RQ->Quantidade, "@E 99999.99")
                  @ prow()  ,45 say "Saida  "
                  @ prow()  ,56 say REQUISIC->Codigo
                  nSALDO := nSALDO - ITENS_RQ->Quantidade
                  @ prow()  ,68 say transform(nSALDO, "@e 9,999,999.99")

               endif
               ITENS_RQ->(dbskip())
            enddo
         endif

         REQUISIC->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // OFICINA.DBF E ITENS_OF.DBF ________

   OFICINA->(dbsetorder(3))
   OFICINA->(dbgotop())

   if OFICINA->(dbseek(cFILIAL))

      qmensa("Filial: " + cFILIAL + " Produto: " + cCOD_PROD + " Oficina: " + OFICINA->Codigo)

      qgirabarra()

      do while ! OFICINA->(eof()) .and. OFICINA->Filial == cFilial .and. qcontprn()

         if ! qlineprn() ; exit ; endif

         qgirabarra()

         ITENS_OF->(Dbsetorder(2))
         ITENS_OF->(Dbgotop())
         ITENS_OF->(Dbseek(OFICINA->Codigo))

         if OFICINA->Dt_servico >= dDT_INI .and. OFICINA->Dt_servico <= dDT_FIM
            do while ! ITENS_OF->(eof()) .and. ITENS_OF->Cod_oficin == OFICINA->Codigo .and. qcontprn()

               if ! qlineprn() ; exit ; endif

               if ITENS_OF->Cod_produt == cCod_prod

                  if XPAGINA == 0 .or. prow() > K_MAX_LIN
                     qpageprn()
                     qcabecprn(cTITULO,80)
                     @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
                     @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
                     @ prow()+1,0 say replicate("-",80)
                     @ prow()+1,0 say "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
                     @ prow()+1,0 say replicate("-",80)
                  endif

                  @ prow()+1,00 say dtoc(OFICINA->Dt_servico)
                  @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
                  @ prow()  ,36 say transform(ITENS_OF->Quantidade, "@E 99999.99")
                  @ prow()  ,45 say "Oficina"
                  @ prow()  ,56 say OFICINA->Codigo
                  nSALDO := nSALDO - ITENS_OF->Quantidade
                  @ prow()  ,68 say transform(nSALDO, "@e 9,999,999.99")

               endif
               ITENS_OF->(dbskip())
            enddo
         endif

         OFICINA->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // MOVIMENT.DBF ________________________

   MOVIMENT->(Dbsetorder(5))
   MOVIMENT->(Dbgotop())

   if MOVIMENT->(Dbseek(cFilial+cCod_prod))

      qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Dt. Mov.: " + dtoc(MOVIMENT->Data) + " E/S: " + MOVIMENT->Tipo)

      do while ! MOVIMENT->(eof()) .and. MOVIMENT->Filial == cFilial .and. MOVIMENT->Cod_prod == cCod_prod .and. qcontprn()

         if ! qlineprn() ; exit ; endif

         qgirabarra()

         if MOVIMENT->Data >= dDT_INI .and. MOVIMENT->Data <= dDT_FIM

            if XPAGINA == 0 .or. prow() > K_MAX_LIN
               qpageprn()
               qcabecprn(cTITULO,80)
               @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
               @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
               @ prow()+1,0 say replicate("-",80)
               @ prow()+1,0 say "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
               @ prow()+1,0 say replicate("-",80)
            endif


            if MOVIMENT->Tipo == "E" .and. ! MOVIMENT->Contabil
               @ prow()+1,00 say dtoc(MOVIMENT->Data)
               @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
               @ prow()  ,24 say MOVIMENT->Lote
               @ prow()  ,36 say transform(MOVIMENT->Quantidade, "@E 99999.99")
               @ prow()  ,45 say "Entrada s/ Contabil."
               nSALDO := nSALDO + MOVIMENT->Quantidade
               @ prow()  ,68 say transform(nSALDO, "@e 9,999,999.99")
            endif

            if MOVIMENT->Tipo $ "SB" .and. ! MOVIMENT->Contabil
               @ prow()+1,00 say dtoc(MOVIMENT->Data)
               @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
               @ prow()  ,24 say MOVIMENT->Lote
               @ prow()  ,36 say transform(MOVIMENT->Quantidade, "@E 99999.99")
               @ prow()  ,45 say "Sa¡da s/ Contabil.  "
               nSALDO := nSALDO - MOVIMENT->Quantidade
               @ prow()  ,68 say transform(nSALDO, "@e 9,999,999.99")
            endif
         endif

         MOVIMENT->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // REL_COMB.DBF E ITENS_RC.DBF _________

   REL_COMB->(Dbsetorder(2))
   REL_COMB->(Dbgotop())

   if REL_COMB->(Dbseek(cFilial+cCod_prod))

      qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Rel. Comb.: " + REL_COMB->Codigo)

      do while ! REL_COMB->(eof()) .and. REL_COMB->Filial == cFilial .and. REL_COMB->Cod_prod == cCod_prod .and. qcontprn()

         if ! qlineprn() ; exit ; endif

         qgirabarra()

         ITENS_RC->(dbgotop())

         if REL_COMB->Dt_relato >= dDT_INI .and. REL_COMB->Dt_relato <= dDT_FIM
                  
            if ITENS_RC->(dbseek(REL_COMB->Codigo))
               do while ! ITENS_RC->(eof()) .and. ITENS_RC->Cod_relcom == REL_COMB->Codigo .and. qcontprn()

                  if ! qlineprn() ; exit ; endif

                  if XPAGINA == 0 .or. prow() > K_MAX_LIN
                     qpageprn()
                     qcabecprn(cTITULO,80)
                     @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
                     @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
                     @ prow()+1,0 say replicate("-",80)
                     @ prow()+1,0 say "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
                     @ prow()+1,0 say replicate("-",80)
                  endif

                  @ prow()+1,00 say dtoc(REL_COMB->Dt_relato)
                  @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
                  @ prow()  ,24 say ITENS_RC->Lote
                  @ prow()  ,36 say transform(ITENS_RC->Quantidade, "@E 99999.99")
                  @ prow()  ,45 say "Rel. de Combust¡vel."
                  nSALDO := nSALDO - ITENS_RC->Quantidade
                  @ prow()  ,68 say transform(nSALDO, "@e 9,999,999.99")

                  ITENS_RC->(dbskip())
               enddo
            endif

         endif

         REL_COMB->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // NFTRANF.DBF E ITENS_NF.DBF __________

   NFTRANSF->(Dbsetorder(2))
   NFTRANSF->(Dbgotop())

   if NFTRANSF->(dbseek(cFilial))

      do while ! NFTRANSF->(eof()) .and. NFTRANSF->Filial == cFilial .and. qcontprn()

         if ! qlineprn() ; exit ; endif

         qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Nf. Transf.: " + NFTRANSF->Codigo)

         ITENS_NF->(Dbsetorder(1))
         ITENS_NF->(Dbgotop())

         if NFTRANSF->Dt_lancto >= dDT_INI .and. NFTRANSF->Dt_lancto <= dDT_FIM

            if ITENS_NF->(dbseek(NFTRANSF->Codigo))
               do while ! ITENS_NF->(eof()) .and. NFTRANSF->Codigo == ITENS_NF->Num_nf .and. qcontprn()

                  if ! qlineprn() ; exit ; endif

                  qgirabarra()

                  if ITENS_NF->Cod_produt == cCod_prod

                     if XPAGINA == 0 .or. prow() > K_MAX_LIN
                        qpageprn()
                        qcabecprn(cTITULO,80)
                        @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
                        @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
                        @ prow()+1,0 say replicate("-",80)
                        @ prow()+1,0 say  "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
                        @ prow()+1,0 say replicate("-",80)
                     endif

                     @ prow()+1,00 say dtoc(NFTRANSF->Dt_lancto)
                     @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
                     @ prow()  ,24 say ITENS_NF->Lote
                     @ prow()  ,36 say transform(ITENS_NF->Quantidade, "@E 99999.99")
                     @ prow()  ,45 say "Nota Fiscal Transf. "
                     nSALDO := nSALDO - ITENS_NF->Quantidade
                     @ prow()  ,68 say transform(nSALDO, "@E 9,999,999.99")

                  endif

                  ITENS_NF->(dbskip())

               enddo
            endif

         endif

         NFTRANSF->(dbskip())

      enddo

   endif

   ////////////////////////////////////////
   // FATURAMENTO _________________________

   // rotina para verificar qual faturamento esta sendo utilizado
   do case

      case CONFIG->Tipo_fat == "1"
           if ! quse(XDRV_CL , "FAT",{"FATFATUR","FATDTEMI","FAT_FIDE","FAT_REPR","FAT_DTRE"})
              qmensa("N„o foi poss¡vel abrir arquivo FAT.DBF !! Tente novamente.")
              return
           endif
           if ! quse(XDRV_CL , "ITEN_FAT",{"FAT_FAPR","ITEN_NUM","FAT_SERV"})
              qmensa("N„o foi poss¡vel abrir arquivo ITEN_FAT.DBF !! Tente novamente.")
              return
           endif

           FAT->(dbsetorder(3))
           FAT->(dbgotop())

           if FAT->(dbseek(cFilial))

              do while ! FAT->(eof()) .and. FAT->Filial == cFilial .and. qcontprn()

                 if ! qlineprn() ; exit ; endif

                 qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Codigo.: " + FAT->Codigo)

                 ITEN_FAT->(Dbsetorder(2))
                 ITEN_FAT->(Dbgotop())

                 if FAT->Dt_emissao >= dDT_INI .and. FAT->Dt_emissao <= dDT_FIM

                    if ITEN_FAT->(dbseek(FAT->Codigo))
                       do while ! ITEN_FAT->(eof()) .and. FAT->Codigo == ITEN_FAT->Num_fat .and. qcontprn()

                          if ! qlineprn() ; exit ; endif

                          qgirabarra()

                          if ITEN_FAT->Cod_prod == cCod_prod

                             if XPAGINA == 0 .or. prow() > K_MAX_LIN
                                qpageprn()
                                qcabecprn(cTITULO,80)
                                @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
                                @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
                                @ prow()+1,0 say replicate("-",80)
                                @ prow()+1,0 say  "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
                                @ prow()+1,0 say replicate("-",80)
                             endif

                             @ prow()+1,00 say dtoc(FAT->Dt_emissao)
                             @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
                         //  @ prow()  ,24 say FAT->Num_lote
                             @ prow()  ,36 say transform(ITEN_FAT->Quantidade, "@E 99999.99")
                             @ prow()  ,45 say "Faturamento"
                             nSALDO := nSALDO - ITEN_FAT->Quantidade
                             @ prow()  ,68 say transform(nSALDO, "@E 9,999,999.99")

                          endif

                          ITEN_FAT->(dbskip())

                       enddo
                    endif

                 endif

                 FAT->(dbskip())

              enddo

           endif

           FAT->(dbclosearea())
           ITEN_FAT->(dbclosearea())

      case CONFIG->Tipo_fat == "2"
           if ! quse(XDRV_IN , "FAT",{"FATFATUR","FATDTEMI","FAT_FIDE","FAT_REPR"})
              qmensa("N„o foi poss¡vel abrir arquivo FAT.DBF !! Tente novamente.")
              return
           endif
           if ! quse(XDRV_IN , "ITEN_FAT",{"FAT_FAPR"})
              qmensa("N„o foi poss¡vel abrir arquivo ITEN_FAT.DBF !! Tente novamente.")
              return
           endif

           FAT->(dbsetorder(3))
           FAT->(dbgotop())

           if FAT->(dbseek(cFilial))

              do while ! FAT->(eof()) .and. FAT->Filial == cFilial .and. qcontprn()

                 if ! qlineprn() ; exit ; endif

                 qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Codigo.: " + FAT->Codigo)

                 ITEN_FAT->(Dbsetorder(1))
                 ITEN_FAT->(Dbgotop())

                 if FAT->Dt_emissao >= dDT_INI .and. FAT->Dt_emissao <= dDT_FIM

                    if ITEN_FAT->(dbseek(FAT->Codigo))
                       do while ! ITEN_FAT->(eof()) .and. FAT->Codigo == ITEN_FAT->Num_fat .and. qcontprn()

                          if ! qlineprn() ; exit ; endif

                          qgirabarra()

                          if ITEN_FAT->Cod_prod == cCod_prod

                             if XPAGINA == 0 .or. prow() > K_MAX_LIN
                                qpageprn()
                                qcabecprn(cTITULO,80)
                                @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
                                @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
                                @ prow()+1,0 say replicate("-",80)
                                @ prow()+1,0 say  "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
                                @ prow()+1,0 say replicate("-",80)
                             endif

                             @ prow()+1,00 say dtoc(FAT->Dt_emissao)
                             @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
                             @ prow()  ,24 say "0000000000"
                             @ prow()  ,36 say transform(ITEN_FAT->Quantidade, "@E 99999.99")
                             if FAT->E_s $ "2 "
                                @ prow()  ,45 say "Fat. Saida"
                             else
                                @ prow()  ,45 say "Fat.Entrada"
                             endif
                             nSALDO := nSALDO - ITEN_FAT->Quantidade
                             @ prow()  ,68 say transform(nSALDO, "@E 9,999,999.99")

                          endif

                          ITEN_FAT->(dbskip())

                       enddo
                    endif

                 endif

                 FAT->(dbskip())

              enddo

           endif

           FAT->(dbclosearea())
           ITEN_FAT->(dbclosearea())

      case CONFIG->Tipo_fat == "4" // tele-vendas na PAPYRUS, puxa o arquivo do faturamento da fabrica
           if ! quse(XDRV_TV , "PEDIDO",{"PED_CODI","PED_FATU","PEDI_DAT","PED_MOTI","PED_CLIE","PED_DTFA","PED_CODC"})
              qmensa("N„o foi poss¡vel abrir arquivo PEDIDO.DBF !! Tente novamente.")
              return
           endif
           if ! quse(XDRV_TV , "ITEN_PED",{"IPED_COD"})
              qmensa("N„o foi poss¡vel abrir arquivo ITEN_PED.DBF !! Tente novamente.")
              return
           endif

           PEDIDO->(dbsetorder(3))
           PEDIDO->(dbgotop())

           if PEDIDO->(dbseek(cFilial))

              do while ! PEDIDO->(eof()) .and. PEDIDO->Filial == cFilial .and. qcontprn()

                 if ! qlineprn() ; exit ; endif

                 qmensa("Filial: " + cFilial + " Produto: " + cCod_prod + " Codigo.: " + PEDIDO->Codigo)

                 ITEN_PED->(Dbsetorder(1))
                 ITEN_PED->(Dbgotop())

                 if PEDIDO->Data >= dDT_INI .and. PEDIDO->Data <= dDT_FIM

                    if ITEN_PED->(dbseek(PEDIDO->Codigo))
                       do while ! ITEN_PED->(eof()) .and. PEDIDO->Codigo == ITEN_PED->Codi_ped .and. qcontprn()

                          if ! qlineprn() ; exit ; endif

                          qgirabarra()

                          if ITEN_PED->Codi_prod == cCod_prod

                             if XPAGINA == 0 .or. prow() > K_MAX_LIN
                                qpageprn()
                                qcabecprn(cTITULO,80)
                                @ prow()+1,0 say "PRODUTO ->"+ cCOD_PROD + "-" + PROD->Descricao
                                @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
                                @ prow()+1,0 say replicate("-",80)
                                @ prow()+1,0 say  "DATA      ESTOQUE       LOTE          QUANT  TIPO        REQ/PED        SALDO"
                                @ prow()+1,0 say replicate("-",80)
                             endif

                             @ prow()+1,00 say dtoc(PEDIDO->Data)
                             @ prow()  ,11 say transform(nSALDO, "@E 9,999,999.99")
                             @ prow()  ,24 say "0000000000"
                             @ prow()  ,36 say transform(ITEN_PED->Quantidade, "@E 99999.99")
                             @ prow()  ,45 say "Faturamento"
                             nSALDO := nSALDO - ITEN_PED->Quantidade
                             @ prow()  ,68 say transform(nSALDO, "@E 9,999,999.99")

                          endif

                          ITEN_PED->(dbskip())

                       enddo
                    endif

                 endif

                 PEDIDO->(dbskip())

              enddo

           endif

           PEDIDO->(dbclosearea())
           ITEN_PED->(dbclosearea())

   endcase

   @ prow()+1,0 say replicate("-",80)

   qstopprn()

return

////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR MOVIMENTACAO DE ESTOQUE NO FATURAMENTO ____
function ver_fat(tFILIAL,tDATA,tCOD_PROD,tCODIGO,tCOD_ITEM,tQTDE,cARQ1,cARQ2)

   if &(cARQ1)->(dbseek(tFILIAL))

      qgirabarra()

      do while ! &(cARQ1)->(eof()) .and. &tFILIAL == cFilial

         qgirabarra()

         &(cARQ2)->(Dbseek(tCODIGO))

         if tDATA < dDT_INI
            do while ! &(cARQ2)->(eof()) .and. tCOD_ITEM == tCODIGO
               if tCOD_PROD == cCod_prod
                  nSALDO_ANT := nSALDO_ANT - tQTDE
                  nSALDO     := nSALDO - tQTDE
               endif
               &(cARQ2)->(dbskip())
            enddo
         endif

         &(cARQ1)->(dbskip())

      enddo

   endif
return
