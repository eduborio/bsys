/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: Setembro de 2006
// OBS........:
// ALTERACOES.:

function cl548
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private cUFS   := space(2)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_ufs(-1,0,@cUFS   )      } , "UFS"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B536A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := qinimes(date())
   dFIM := qfimmes(date())
   cUFS := space(2)
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

      case cCAMPO == "UFS"

           qrsay(XNIVEL,cUFS)

           if empty(cUFS)
              qrsay(XNIVEL++, "Todos os Estados.......")
           else
              if ! UFS->(Dbseek(cUFS))
                 qmensa("Estado n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(UFS->Descricao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "FATURAMENTO + PENDENCIAS " +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   PEND->(dbsetorder(2)) // data de saida
   PEND->(dbgotop())
   set softseek on
   PEND->(Dbseek(dtos(dINI)))
   set softseek off
   ITEM_PEN->(dbsetorder(2))

return .T.


static function i_impressao
   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return

////////////////////////////////////////////////////////
// FUNCAO DE IMPRESSAO NA IMPORESSORA

static function i_impre_prn
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER_VEN  := 0
    local nTOT_GER_BRI  := 0
    local nTOT_GER_CON  := 0

    local nVENDA        := 0
    local nIPI          := 0
    local nBRINDE       := 0
    local nCONSIG       := 0


    local nTOT_COM   := 0
    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof()) .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      CGM->(dbseek(CLI1->Cgm_ent))

      CLI1->(dbseek(FAT->Cod_cli))

      if FAT->Es != "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612" .and. ! left(FAT->Cod_cfop,4) $ "5910-5911-6910-6911-5917-6917"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")
      nTOTAL := 0
      nDESC := 0
      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
          nIPI   += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Ipi/100)
          if CONFIG->Modelo_fat == "1"
             nDESC := nDESC + (ITEN_FAT->Vlr_desc * ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo
      nTOTAL:= nTOTAL + nIPI
      if CONFIG->Modelo_Fat == "1"
         nTOTAL := nTOTAL
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
         nTOTAL := nTOTAL - nDESC
      endif
      CGM->(dbseek(CLI1->Cgm_ent))
      qmensa(left(CLI1->Razao,30)+ "  "+CGM->Estado)

      if ! empty(cUFS) .and. CGM->Estado <> cUFS
        // aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es})
      else
         //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es,FAT->Codigo,alltrim(FAT->Cod_cfop) })
         aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es,FAT->Codigo,alltrim(FAT->Cod_cfop),nDESC })

      endif
      nTOTAL := 0
      nDESC  := 0
      nIPI   := 0
      FAT->(dbskip())

   enddo

   do while ! PEND->(eof()) .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop


      CGM->(dbseek(CLI1->Cgm_ent))

      CLI1->(dbseek(PEND->Cod_cli))

      qgirabarra()

      qmensa("Aguarde... Processando ...")
      nTOTAL := 0
      nDESC := 0
      ITEM_PEN->(Dbgotop())
      ITEM_PEN->(Dbseek(PEND->Codigo))
      do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEM_PEN->Cod_Prod))
          nTOTAL += (ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar)
          nIPI   += (ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar) * (ITEN_FAT->Ipi/100)
          if CONFIG->Modelo_fat == "1"
             nDESC := nDESC + (ITEM_PEN->Vlr_desc * ITEM_PEN->Quantidade)
          endif
          lTEM := .T.
          ITEM_PEN->(Dbskip())
      enddo
      nTOTAL:= nTOTAL + nIPI
      if CONFIG->Modelo_Fat == "1"
         nTOTAL := nTOTAL
      else
         nDESC := nTOTAL * (PEND->Aliq_desc/100)
         nTOTAL := nTOTAL - nDESC
      endif
      CGM->(dbseek(CLI1->Cgm_ent))
      qmensa(left(CLI1->Razao,30)+ "  "+CGM->Estado)

      if ! empty(cUFS) .and. CGM->Estado <> cUFS
        // aadd(aFAT,{dtoc(PEND->Dt_Emissao),PEND->Cod_cli,CLI1->Razao,nTOTAL,PEND->Num_fatura,CGM->Estado,FAT->Cod_repres,PEND->Es})
      else
         //aadd(aFAT,{dtoc(PEND->Dt_Emissao),PEND->Cod_cli,CLI1->Razao,nTOTAL,PEND->Num_fatura,CGM->Estado,FAT->Cod_repres,PEND->Es,PEND->Codigo,alltrim(PEND->Cod_cfop) })
         aadd(aFAT,{dtoc(PEND->Dt_Emissao),PEND->Cod_cli,CLI1->Razao,nTOTAL,PEND->Num_fatura,CGM->Estado,FAT->Cod_repres,PEND->Es,PEND->Codigo,alltrim(PEND->Cod_cfop),nDESC })

      endif
      nTOTAL := 0
      nDESC  := 0
      nIPI   := 0
      PEND->(dbskip())

   enddo





   //classifica a matriz por vendedor + data vencimento
   asFAT := asort(aFAT,,,{|x,y| x[6] +  x[10] + x[3] + x[5] < y[6] + y[10] + y[3] + y[5] })
   if lTEM
       zUFS  := asFAT[1,6]
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say XCOND1 + "Data Emissao  Cfop Cliente                                             Total  Nota Fiscal   UF  Representante"

              @ prow()+1,0 say replicate("-",136)
           endif

           if left(asFAT[nCONT,10],3) $ "510-511-512-610-611-612"
              nVENDA += (asFAT[nCONT,4])
              nTOT_GER_VEN  += (asFAT[nCONT,4])
           endif

           if left(asFAT[nCONT,10],4) $ "5910-5911-6910-6911"
              nBRINDE += (asFAT[nCONT,4])
              nTOT_GER_BRI  += (asFAT[nCONT,4])
           endif

           if left(asFAT[nCONT,10],4) $ "5917-6917"
              nCONSIG += (asFAT[nCONT,4])
              nTOT_GER_CON  += (asFAT[nCONT,4])
           endif

           @ prow()+1, 00  say asFAT[nCONT,1]                         //Data de Emissao
           @ prow()  , 16  say asFAT[nCONT,10]                         //CFOP
           @ prow()  , 24  say asFAT[nCONT,3]                         //Razao do Cliente
           @ prow()  , 80  say transf(asFAT[nCONT,4],"@E 9,999,999.99") //Valor da Nota
           @ prow()  , 96  say asFAT[nCONT,5]                         //Numero da Nota
           @ prow()  , 106 say asFAT[nCONT,6]                         //ESTADO
           REPRES->(DbSeek(asFAT[nCONT,7]))
           @ prow()  , 115 say left(REPRES->Razao,20)                 //REPRESENTANTE

          // ITEN_FAT->(dbsetorder(2))
          // ITEN_FAT->(dbseek(asFAT[nCONT,9]))
          // do while ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == asFAT[nCONT,9]
          //    PROD->(Dbsetorder(4))
          //    PROD->(Dbseek(ITEN_FAT->Cod_prod))
          //    @ prow()+1,00 say left(PROD->Cod_fabr,6) +" "+left(PROD->Descricao,20)+" "+PROD->Marca+" "+PROD->Cod_ass
          //    @ prow()  ,50 say transf(ITEN_FAT->Quantidade,"@R 999999")
          //    @ prow()  ,70 say transf(ITEN_FAT->Vl_unitar ,"@E 999,999.99")
          //    @ prow()  ,90 say transf((ITEN_FAT->Vl_unitar*ITEN_FAT->Quantidade)*1.15 ,"@E 999,999.99")
          //
          //    ITEN_FAT->(DbSkip())
          // enddo
           if asFAT[nCONT,11] > 0
              @ prow()+1,20 say "Desconto de "+transform(asFAT[nCONT,11],"@E 999,999.99")
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

          if alltrim(asFAT[nCONT,6]) != alltrim(zUFS)
              UFS->(dbseek(zUFS))
              @ prow()+2  ,00 say "TOTAIS DO ESTADO....: "+left(UFS->Descricao,20)+"  Venda.: "+transf(nVENDA,"@E 99,999,999.99")
              @ prow()+1,00 say replicate("-",136)
              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
              nVENDA  := 0
              nBRINDE := 0
              nCONSIG := 0
          endif

         zUFS := asFAT[nCONT,6]

       enddo
       UFS->(dbseek(zUFS))
       @ prow()+2  ,00 say "TOTAIS DO ESTADO....: "+left(UFS->Descricao,20)+"  Venda.: "+transf(nVENDA,"@E 99,999,999.99")
       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1,00 say replicate("-",136)
       @ prow()+1  ,00 say "TOTAIS GERAIS.......: "+space(20)+"  Venda.: "+transf(nTOT_GER_VEN,"@E 99,999,999.99")

       nQUANT  := 0
       nTOTAL  := 0
       nPERC   := 0
       nVENDA  := 0
       nBRINDE := 0
       nCONSIG := 0
       nTOT_GER_VEN  := 0
       nTOT_GER_BRI  := 0
       nTOT_GER_CON  := 0
       nIPI          := 0

   endif

   qstopprn()

return

////////////////////////////////////////////////////////
// FUNCAO DE IMPRESSAO em XLS

static function i_impre_xls
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nTOT_GER_VEN  := 0
    local nTOT_GER_BRI  := 0
    local nTOT_GER_CON  := 0

    local nVENDA        := 0
    local nBRINDE       := 0
    local nCONSIG       := 0
    local nIPI          := 0

    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
//   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof()) .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

        if FAT->Cancelado
           FAT->(dbskip())
           loop
        endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      CGM->(dbseek(CLI1->Cgm_ent))

      CLI1->(dbseek(FAT->Cod_cli))

      if FAT->Es != "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612" .and. ! left(FAT->Cod_cfop,4) $ "5910-5911-6910-6911-5917-6917"
         FAT->(dbskip())
         loop
      endif


      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
          nIPI   += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Ipi/100)
          if CONFIG->Modelo_fat == "1"
             nDESC := nDESC + (ITEN_FAT->Vlr_desc*ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo
      nTOTAL := nTOTAL + nIPI
      if CONFIG->Modelo_Fat == "1"
         //
      else
         nTOTAL := nTOTAL - nDESC
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif
      CGM->(dbseek(CLI1->Cgm_ent))
      //qmensa(left(CLI1->Razao,30)+ "  "+CGM->Estado)

      if ! empty(cUFS) .and. CGM->Estado <> cUFS
        // aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es})
      else
         aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es,FAT->Codigo,alltrim(FAT->Cod_cfop),nDESC })
      endif
      nTOTAL := 0
      nDESC  := 0
      nIPI   := 0
      FAT->(dbskip())

   enddo

   do while ! PEND->(eof()) .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop


      CGM->(dbseek(CLI1->Cgm_ent))

      CLI1->(dbseek(PEND->Cod_cli))

      qgirabarra()

      qmensa("Aguarde... Processando ...")
      nTOTAL := 0
      nDESC := 0
      ITEM_PEN->(Dbgotop())
      ITEM_PEN->(Dbseek(PEND->Codigo))
      do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEM_PEN->Cod_Prod))
          nTOTAL += (ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar)
          nIPI   += (ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar) * (ITEN_FAT->Ipi/100)
          if CONFIG->Modelo_fat == "1"
             nDESC := nDESC + (ITEM_PEN->Vlr_desc * ITEM_PEN->Quantidade)
          endif
          lTEM := .T.
          ITEM_PEN->(Dbskip())
      enddo
      nTOTAL:= nTOTAL + nIPI
      if CONFIG->Modelo_Fat == "1"
         nTOTAL := nTOTAL
      else
         nDESC := nTOTAL * (PEND->Aliq_desc/100)
         nTOTAL := nTOTAL - nDESC
      endif
      CGM->(dbseek(CLI1->Cgm_ent))
      qmensa(left(CLI1->Razao,30)+ "  "+CGM->Estado)

      if ! empty(cUFS) .and. CGM->Estado <> cUFS
        // aadd(aFAT,{dtoc(PEND->Dt_Emissao),PEND->Cod_cli,CLI1->Razao,nTOTAL,PEND->Num_fatura,CGM->Estado,FAT->Cod_repres,PEND->Es})
      else
         //aadd(aFAT,{dtoc(PEND->Dt_Emissao),PEND->Cod_cli,CLI1->Razao,nTOTAL,PEND->Num_fatura,CGM->Estado,FAT->Cod_repres,PEND->Es,PEND->Codigo,alltrim(PEND->Cod_cfop) })
         aadd(aFAT,{dtoc(PEND->Dt_Emissao),PEND->Cod_cli,CLI1->Razao,nTOTAL,PEND->Num_fatura,CGM->Estado,FAT->Cod_repres,PEND->Es,PEND->Codigo,alltrim(PEND->Cod_cfop),nDESC })

      endif
      nTOTAL := 0
      nDESC  := 0
      nIPI   := 0
      PEND->(dbskip())

   enddo



   //classifica a matriz por vendedor + data vencimento
   asFAT := asort(aFAT,,,{|x,y| x[6] +  x[3]+ x[5] < y[6] + y[3] + y[5] })
   if lTEM
       zUFS  := asFAT[1,6]
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0
              //@prow()+1,0 say XCOND1
              qpageprn()
              @ prow()+1,0 say "            " +chr(9)+ "    "+chr(9)+ cTITULO+" 548"
              @ prow()+1,0 say "Data Emissao" +chr(9)+ "Cfop"+chr(9)+ "Cliente"+chr(9)+ "Total"+chr(9)+"Nota Fiscal"+chr(9)+"UF"+chr(9)+"Representante"

           endif

           @ prow()+1, 00        say asFAT[nCONT,1]+chr(9)                         //Data de Emissao
           @ prow()  , pcol()+1  say asFAT[nCONT,10]+chr(9)                         //CFOP
           @ prow()  , pcol()+1  say asFAT[nCONT,3]+chr(9)                         //Razao do Cliente
           @ prow()  , pcol()+1  say transf(asFAT[nCONT,4],"@E 9,999,999.99")+chr(9) //Valor da Nota
           @ prow()  , pcol()+1  say asFAT[nCONT,5]+chr(9)                         //Numero da Nota
           @ prow()  , pcol()+1  say asFAT[nCONT,6]+chr(9)                         //ESTADO
           REPRES->(DbSeek(asFAT[nCONT,7]))
           @ prow()  , pcol()+1  say left(REPRES->Razao,20)                 //REPRESENTANTE

           if left(asFAT[nCONT,10],3) $ "510-511-512-610-611-612"
              nVENDA += (asFAT[nCONT,4])
              nTOT_GER_VEN  += (asFAT[nCONT,4])
           endif

           if left(asFAT[nCONT,10],4) $ "5910-5911-6910-6911"
              nBRINDE += (asFAT[nCONT,4])
              nTOT_GER_BRI  += (asFAT[nCONT,4])
           endif

           if left(asFAT[nCONT,10],4) $ "5917-6917"
              nCONSIG += (asFAT[nCONT,4])
              nTOT_GER_CON  += (asFAT[nCONT,4])
           endif


           //ITEN_FAT->(dbsetorder(2))
           //ITEN_FAT->(dbseek(asFAT[nCONT,9]))
           //do while ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == asFAT[nCONT,9]
           //   PROD->(Dbsetorder(4))
           //   PROD->(Dbseek(ITEN_FAT->Cod_prod))
           //   @ prow()+1,00 say " "+chr(9)+""+chr(9)+left(PROD->Cod_fabr,6) +" "+PROD->Cod_ass+"  "+left(PROD->Descricao,20)+chr(9)
           //   @ prow()  ,pcol()+1 say transf(ITEN_FAT->Quantidade,"@R 999999")+chr(9)
           //   @ prow()  ,pcol()+1 say transf(ITEN_FAT->Vl_unitar ,"@E 999,999.99")+chr(9)
           //   @ prow()  ,pcol()+1 say transf((ITEN_FAT->Vl_unitar*ITEN_FAT->Quantidade)*1.15 ,"@E 999,999.99")
           //
           //   ITEN_FAT->(DbSkip())
           //enddo

           if asFAT[nCONT,11] > 0
              @ prow()+1,00 say ""+chr(9)+""+chr(9)+"Desconto de "+transform(asFAT[nCONT,11],"@E 999,999.99")+chr(9)
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

          if alltrim(asFAT[nCONT,6]) != alltrim(zUFS)
              UFS->(dbseek(zUFS))
              @ prow()+2  ,00 say ""+chr(9)+""+chr(9)+"TOTAIS DO ESTADO....: "+left(UFS->Descricao,20)+chr(9)+transf(nVENDA,"@E 99,999,999.99")
              @ prow()+1  ,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
              nVENDA  := 0
              nCONSIG := 0
              nBRINDE := 0
          endif

         zUFS := asFAT[nCONT,6]

       enddo
       UFS->(dbseek(zUFS))
       @ prow()+2  ,00 say ""+chr(9)+""+chr(9)+"TOTAIS DO ESTADO....: "+left(UFS->Descricao,20)+chr(9)+transf(nVENDA,"@E 99,999,999.99")


       @ prow()+2  ,00 say ""+chr(9)+""+chr(9)+"TOTAIS GERAIS.......: "+space(20)+chr(9)+transf(nTOT_GER_VEN,"@E 99,999,999.99")




       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0

       nVENDA  := 0
       nBRINDE := 0
       nCONSIG := 0
       nTOT_GER_VEN  := 0
       nTOT_GER_BRI  := 0
       nTOT_GER_CON  := 0

   endif

   qstopprn()

return


