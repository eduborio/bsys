/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: RELATORIO DE PEDIDOS POR FILIAL
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: DEZEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function cp502

#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private sBLOC1 := qlbloc("B502B","QBLOC.GLO") // ordem de impressao

private cTITULO                               // titulo do relatorio

private bFILTRO                               // code block de filtro
private bFILTRO1                              // code block de filtro
private aEDICAO := {}                         // vetor para os campos de entrada de dados
private cFILIAL
private cTMP_FILIAL := space(10)
private cTMP_CENTRO := SPACE(10)
private lIMP_FILIAL := .T.

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_FILIAL(-1,0,@cFILIAL                    )} ,"FILIAL"   })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI     ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM     ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})

do while .T.

   qlbloc(5,0,"B502A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cFILIAL := space(11)
   dDATA_INI  := ctod("01/" + right(qanomes(date()),2) + "/" + left(qanomes(date()),4))
   dDATA_FIM  := qfimmes(dDATA_INI)

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
              qrsay(XNIVEL,cFILIAL:=alltrim(cFILIAL))
              if ! FILIAL->(dbseek(cFILIAL))
                 qmensa("Filial n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->RAZAO,28))
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

   cTITULO := "RELATORIO DE PEDIDOS POR FILIAL DE: " + dtoc(dDATA_INI) + " ATE " + dtoc(dDATA_FIM)
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   bFILTRO := { || PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIM }
   bFILTRO1:= { || PEDIDO2->Data_ped >= dDATA_INI .and. PEDIDO2->Data_ped <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PEDIDO->(dbsetorder(4)) // POR FILIAL

   PEDIDO2->(dbsetorder(4)) // POR FILIAL

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local cPIC := "@E 999,999.99"
   local nSUB_TOT := nTOT_GERAL := nTOT_CENT := nS_TOT_L := nT_CENT_L := nT_GERAL_L := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! empty(cFILIAL)
      PEDIDO->(dbseek(cFILIAL))
   else
      PEDIDO->(dbgotop())
      FILIAL->(dbseek(PEDIDO->Filial))
   endif

   do while ! PEDIDO->(eof()) .and. qcontprn()

      if ! qlineprn() ; exit ; endif
      qgirabarra()

      qmensa("Totalizando os Pedidos: " + transform(PEDIDO->Codigo,"@R 99999/9999") )

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @ prow(),pcol() say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
      endif

      if (empty(cFILIAL).and.eval(bFILTRO)) .or. (alltrim(cFILIAL) == alltrim(PEDIDO->Filial).and.eval(bFILTRO))

         if lIMP_FILIAL
            FILIAL->(dbseek(PEDIDO->Filial))
            @ prow()+1,0 say "Filial: " + FILIAL->Razao
            @ prow()+1,0 say replicate("-",80)
            @ prow()+1,0 say "  Data      Pedido    Fornecedor             Valor Br.  Valor Lq.  Centro  Comp."
            @ prow()+1,0 say replicate("-",80)
            lIMP_FILIAL := .F.
         endif

         ///////////////////////////////////////////////////
         // Procura o sub grupo do produto / fornecedor ____

         cTMP_FILIAL := PEDIDO->Filial
         cTMP_CENTRO := PEDIDO->Centro

         TIPOCONT->(dbseek(PEDIDO->Tipo))

//       PROD->(dbsetorder(1))
//       PROD->(dbseek(PEDIDO->Sub_grup))

         FORN->(dbseek(PEDIDO->Cod_forn))

         @ prow()+1,0  say dtoc(PEDIDO->Data_ped)
         @ prow()  ,11 say transform(PEDIDO->Codigo,"@R 99999/9999")
//       @ prow()  ,22 say XCOND2 + left(TIPOCONT->Descricao,24) + XCOND0  alteracao em 05/07/99
         @ prow()  ,22 say left(FORN->Razao,20)
         @ prow()  ,44 say transform(PEDIDO->Val_liq+PEDIDO->Vl_desc_c,cPIC)
         @ prow()  ,55 say transform(PEDIDO->Val_liq,cPIC)
         @ prow()  ,67 say alltrim(PEDIDO->Centro)
         @ prow()  ,74 say PEDIDO->Comprador

         nSUB_TOT  += PEDIDO->Val_liq+PEDIDO->Vl_desc_c
         nTOT_CENT += PEDIDO->Val_liq+PEDIDO->Vl_desc_c

         nS_TOT_L  += PEDIDO->Val_liq
         nT_CENT_L += PEDIDO->Val_liq

      endif

      PEDIDO->(dbskip())

      if (alltrim(cTMP_FILIAL) <> alltrim(PEDIDO->Filial).and.nSUB_TOT<>0) .or. (PEDIDO->(eof()).and.nSUB_TOT<>0)
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,0 say XAENFAT + "Total da Filial " + alltrim(cTMP_FILIAL) + "....................: " + transform(nSUB_TOT,"@E 9,999,999.99") +;
                          transform(nS_TOT_L,"@E 9,999,999.99") + XDENFAT
         @ prow()+2,0 say ""
         nTOT_GERAL += nSUB_TOT
         nT_GERAL_L += nS_TOT_L
         nSUB_TOT := 0
         nS_TOT_L := 0
         lIMP_FILIAL := .T.
      endif

      if (alltrim(cTMP_CENTRO) <> alltrim(PEDIDO->Centro).and.nTOT_CENT<>0) .or. (PEDIDO->(eof()).and.nTOT_CENT<>0)
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,0 say XAENFAT + "Total do Centro de Custo " + alltrim(cTMP_CENTRO) + "...........: " + transform(nTOT_CENT,"@E 9,999,999.99") +;
                          transform(nT_CENT_L,"@E 9,999,999.99") + XDENFAT
         @ prow()+2,0 say ""
         nTOT_CENT := 0
         nT_CENT_L := 0
         lIMP_FILIAL := .T.
      endif

   enddo

   if ! empty(cFILIAL)
      PEDIDO2->(dbseek(cFILIAL))
   else
      PEDIDO2->(dbgotop())
      FILIAL->(dbseek(PEDIDO2->Filial))
   endif

   do while ! PEDIDO2->(eof()) .and. qcontprn()

      if ! qlineprn() ; exit ; endif
      qgirabarra()

      qmensa("Totalizando os Pedidos: " + transform(PEDIDO2->Codigo,"@R 99999/9999") )

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
      endif

      if (empty(cFILIAL).and.eval(bFILTRO1)) .or. (alltrim(cFILIAL) == alltrim(PEDIDO2->Filial).and.eval(bFILTRO1))

         if lIMP_FILIAL
            FILIAL->(dbseek(PEDIDO2->Filial))
            @ prow()+1,0 say "Filial: " + FILIAL->Razao
            @ prow()+1,0 say replicate("-",80)
            @ prow()+1,0 say "  Data      Pedido    Fornecedor             Valor Br.  Valor Lq.  Centro  Comp."
            @ prow()+1,0 say replicate("-",80)
            lIMP_FILIAL := .F.
         endif

         ///////////////////////////////////////////////////
         // Procura o sub grupo do produto / fornecedor ____

         cTMP_FILIAL := PEDIDO2->Filial
         cTMP_CENTRO := PEDIDO2->Centro

         TIPOCONT->(dbseek(PEDIDO->Tipo))
//       PROD->(dbsetorder(1))
//       PROD->(dbseek(PEDIDO2->Sub_grup))
         FORN->(dbseek(PEDIDO2->Cod_forn))

         @ prow()+1,0  say dtoc(PEDIDO2->Data_ped)
         @ prow()  ,11 say transform(PEDIDO2->Codigo,"@R 99999/9999")
//       @ prow()  ,21 say left(PROD->Descricao,10)
//       @ prow()  ,22 say XCOND2 + left(TIPOCONT->Descricao,24) + XCOND0 alteracao em 05/07/99
         @ prow()  ,22 say left(FORN->Razao,20)
         @ prow()  ,44 say transform(PEDIDO2->Val_liq+PEDIDO->Vl_desc_c,cPIC)
         @ prow()  ,55 say transform(PEDIDO2->Val_liq,cPIC)
         @ prow()  ,67 say alltrim(PEDIDO2->Centro)
         @ prow()  ,74 say PEDIDO2->Comprador

         nSUB_TOT  += PEDIDO2->Val_liq+PEDIDO->Vl_desc_c
         nTOT_CENT += PEDIDO2->Val_liq+PEDIDO->Vl_desc_c

         nS_TOT_L  += PEDIDO2->Val_liq
         nT_CENT_L += PEDIDO2->Val_liq

      endif

      PEDIDO2->(dbskip())

      if (alltrim(cTMP_FILIAL) <> alltrim(PEDIDO2->Filial).and.nSUB_TOT<>0) .or. (PEDIDO2->(eof()).and.nSUB_TOT<>0)
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,0 say XAENFAT + "Total da Filial " + alltrim(cTMP_FILIAL) + "....................: " + transform(nSUB_TOT,"@E 9,999,999.99") +;
                           transform(nS_TOT_L,"@E 9,999,999.99") + XDENFAT
         @ prow()+2,0 say ""
         nTOT_GERAL += nSUB_TOT
         nT_GERAL_L += nS_TOT_L
         nSUB_TOT := 0
         nS_TOT_L := 0
         lIMP_FILIAL := .T.
      endif

      if (alltrim(cTMP_CENTRO) <> alltrim(PEDIDO2->Centro).and.nTOT_CENT<>0) .or. (PEDIDO2->(eof()).and.nTOT_CENT<>0)
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,0 say XAENFAT + "Total do Centro de Custo " + alltrim(cTMP_CENTRO) + "...........: " + transform(nTOT_CENT,"@E 9,999,999.99") +;
                          transform(nT_CENT_L,"@E 9,999,999.99") + XDENFAT
         nTOT_GERAL += nSUB_TOT
         nT_GERAL_L += nS_TOT_L
         nSUB_TOT := 0
         nS_TOT_L := 0
         lIMP_FILIAL := .T.
      endif

      if (alltrim(cTMP_CENTRO) <> alltrim(PEDIDO->Centro).and.nTOT_CENT<>0) .or. (PEDIDO->(eof()).and.nTOT_CENT<>0)
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,0 say XAENFAT + "Total do Centro de Custo " + alltrim(cTMP_CENTRO) + "...............: " + transform(nTOT_CENT,"@E 9,999,999.99") +;
                          transform(nT_CENT_L,"@E 9,999,999.99") + XDENFAT
         @ prow()+2,0 say ""
         nTOT_CENT := 0
         nT_CENT_L := 0
         lIMP_FILIAL := .T.
      endif

   enddo

   if ! empty(cFILIAL)
      PEDIDO2->(dbseek(cFILIAL))
   else
      PEDIDO2->(dbgotop())
      FILIAL->(dbseek(PEDIDO2->Filial))
   endif

   do while ! PEDIDO2->(eof()) .and. qcontprn()

      if ! qlineprn() ; exit ; endif
      qgirabarra()

      qmensa("Totalizando os Pedidos: " + transform(PEDIDO2->Codigo,"@R 99999/9999") )

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
      endif

      if (empty(cFILIAL).and.eval(bFILTRO1)) .or. (alltrim(cFILIAL) == alltrim(PEDIDO2->Filial).and.eval(bFILTRO1))

         if lIMP_FILIAL
            FILIAL->(dbseek(PEDIDO2->Filial))
            @ prow()+1,0 say "Filial: " + FILIAL->Razao
            @ prow()+1,0 say replicate("-",80)
            @ prow()+1,0 say "  Data      Pedido    Fornecedor            Valor Br.  Valor Lq.  Centro  Comp."
            @ prow()+1,0 say replicate("-",80)
            lIMP_FILIAL := .F.
         endif

         ///////////////////////////////////////////////////
         // Procura o sub grupo do produto / fornecedor ____

         cTMP_FILIAL := PEDIDO2->Filial
         cTMP_CENTRO := PEDIDO2->Centro

         TIPOCONT->(dbseek(PEDIDO->Tipo))
//       PROD->(dbsetorder(1))
//       PROD->(dbseek(PEDIDO2->Sub_grup))
         FORN->(dbseek(PEDIDO2->Cod_forn))

         @ prow()+1,0  say dtoc(PEDIDO2->Data_ped)
         @ prow()  ,11 say transform(PEDIDO2->Codigo,"@R 99999/9999")
//       @ prow()  ,21 say left(PROD->Descricao,10)
//       @ prow()  ,22 say XCOND2 + left(TIPOCONT->Descricao,24) + XCOND0 alteracao em 05/07/99
         @ prow()  ,22 say left(FORN->Razao,20)
         @ prow()  ,44 say transform(PEDIDO2->Val_liq+PEDIDO->Vl_desc_c,cPIC)
         @ prow()  ,55 say transform(PEDIDO2->Val_liq,cPIC)
         @ prow()  ,67 say alltrim(PEDIDO2->Centro)
         @ prow()  ,74 say PEDIDO2->Comprador

         nSUB_TOT  += PEDIDO2->Val_liq+PEDIDO->Vl_desc_c
         nTOT_CENT += PEDIDO2->Val_liq+PEDIDO->Vl_desc_c

         nS_TOT_L  += PEDIDO2->Val_liq
         nT_CENT_L += PEDIDO2->Val_liq

      endif

      PEDIDO2->(dbskip())

      if (alltrim(cTMP_FILIAL) <> alltrim(PEDIDO2->Filial).and.nSUB_TOT<>0) .or. (PEDIDO2->(eof()).and.nSUB_TOT<>0)
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,0 say XAENFAT + "Total da Filial " + alltrim(cTMP_FILIAL) + "....................: " + transform(nSUB_TOT,"@E 9,999,999.99") +;
                           transform(nS_TOT_L,"@E 9,999,999.99") + XDENFAT
         @ prow()+2,0 say ""
         nTOT_GERAL += nSUB_TOT
         nT_GERAL_L += nS_TOT_L
         nSUB_TOT := 0
         nS_TOT_L := 0
         lIMP_FILIAL := .T.
      endif

      if (alltrim(cTMP_CENTRO) <> alltrim(PEDIDO2->Centro).and.nTOT_CENT<>0) .or. (PEDIDO2->(eof()).and.nTOT_CENT<>0)
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,0 say XAENFAT + "Total do Centro de Custo " + alltrim(cTMP_CENTRO) + "...........: " + transform(nTOT_CENT,"@E 9,999,999.99") +;
                          transform(nT_CENT_L,"@E 9,999,999.99") + XDENFAT
         @ prow()+2,0 say ""
         nTOT_CENT := 0
         nT_CENT_L := 0
         lIMP_FILIAL := .T.
      endif

   enddo

   @ prow()+1,0 say replicate("-",80)
   @ prow()+1,0 say XAENFAT + "Total Geral.............................: " + transform(nTOT_GERAL,"@E 9,999,999.99") +;
                    transform(nT_GERAL_L,"@E 9,999,999.99") + XDENFAT

   qstopprn()

return
