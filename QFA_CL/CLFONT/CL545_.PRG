/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2005
// OBS........:
// ALTERACOES.:

function cl545
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private cUFS   := space(2)
private aEDICAO := {}             // vetor para os campos de entrada de dados

if ! quse(XDRV_CL,"FI545",{"FI545"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif


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

   if empty(cPEDINI)
      cTITULO := "LISTAGEM DE FATURAMENTO " +" de " + dtoc(dINI) + " a " + dtoc(dFIM)
   else
      cTITULO := "LISTAGEM DE FATURAMENTO " + " PEDIDOS de " + cPEDINI + " a " + cPEDFIM
   endif

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.


static function i_impressao
   if ! qinitprn() ; return ; endif

   FI545->(__dbzap())

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
    local nDESCONTO  := 0
    local nTOT_GER_VEN  := 0
    local nTOT_GER_BRI  := 0
    local nTOT_GER_CON  := 0
    local nTOT_GER_DES  := 0

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

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-540-640" .and. ! left(FAT->Cod_cfop,4) $ "5910-5911-6910-6911-5917-6917"
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
          nTOTAL += q_soma_st()
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
         //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es,FAT->Codigo,alltrim(FAT->Cod_cfop),nDESC })
         if FI545->(qappend())
            replace FI545->Dt_emissao with FAT->Dt_emissao
            replace FI545->Cod_cli    with FAT->Cod_cli
            replace FI545->Razao      with CLI1->Razao
            replace FI545->Total      with nTOTAL
            replace FI545->Num_fatura with FAT->Num_fatura
            replace FI545->Estado     with CGM->Estado
            replace FI545->cod_repres with FAT->Cod_repres
            replace FI545->Es         with FAT->Es
            replace FI545->Codigo     with FAT->Codigo
            replace FI545->Cfop       with alltrim(FAT->Cod_cfop)
            replace FI545->Desc       with nDesc
         endif

      endif
      nTOTAL := 0
      nDESC  := 0
      nIPI   := 0
      FAT->(dbskip())

   enddo
   FI545->(dbcommit())
   FI545->(dbgotop())

   //classifica a matriz por vendedor + data vencimento
   //asFAT := asort(aFAT,,,{|x,y| x[6] +  x[10] + x[3] + x[5] < y[6] + y[10] + y[3] + y[5] })
   if lTEM
       zUFS  := FI545->Estado
       nCONT := 1
       do while  FI545->(!eof())

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say XCOND1 + "Data Emissao  Cfop Cliente                                             Total  Nota Fiscal   UF  Representante"

              @ prow()+1,0 say replicate("-",136)
           endif

           if left(FI545->Cfop,3) $ "510-511-512-610-611-612-540-640"
              nVENDA        += (FI545->Total)
              nTOT_GER_VEN  += (FI545->Total)
           endif

           if left(FI545->Cfop,4) $ "5910-5911-6910-6911"
              nBRINDE +=       (FI545->Total)
              nTOT_GER_BRI  += (Fi545->Total)
           endif

           if left(FI545->Cfop,4) $ "5917-6917"
              nCONSIG       += (FI545->Total)
              nTOT_GER_CON  += (FI545->Total)
           endif

           if FI545->Desc > 0
              nDESCONTO    += FI545->Desc
              nTOT_GER_DES += FI545->Desc
           endif


           @ prow()+1, 00  say dtoc(FI545->Dt_Emissao)                          //Data de Emissao
           @ prow()  , 16  say FI545->Cfop                         //CFOP
           @ prow()  , 24  say FI545->Razao                        //Razao do Cliente
           @ prow()  , 80  say transf(FI545->Total,"@E 9,999,999.99") //Valor da Nota
           @ prow()  , 96  say FI545->Num_fatura                         //Numero da Nota
           @ prow()  , 106 say FI545->Estado                           //ESTADO
           REPRES->(DbSeek(FI545->cod_repres))
           @ prow()  , 115 say left(REPRES->Razao,20)                 //REPRESENTANTE

           if FI545->Desc > 0
              @ prow()+1,20 say "Desconto de "+transform(FI545->Desc,"@E 999,999.99")
           endif

           FI545->(dbskip())
          if alltrim(FI545->Estado) != alltrim(zUFS)
              UFS->(dbseek(zUFS))
              @ prow()+2  ,00 say "TOTAIS DO ESTADO....: "+left(UFS->Descricao,20)+"  Venda.: "+transf(nVENDA,"@E 99,999,999.99")+"  Doacao.: "+transf(nBRINDE,"@E 99,999,999.99")+" Consignacao.: " +transf(nCONSIG,"@E 99,999,999.99") +" Descontos.: "+transf(nDesconto,"@E 999,999.99")
              @ prow()+1,00 say replicate("-",136)
              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
              nVENDA  := 0
              nBRINDE := 0
              nCONSIG := 0
              nDESCONTO := 0
          endif

          zUFS := FI545->Estado

       enddo
       UFS->(dbseek(zUFS))
       @ prow()+2  ,00 say "TOTAIS DO ESTADO....: "+left(UFS->Descricao,20)+"  Venda.: "+transf(nVENDA,"@E 99,999,999.99")+"  Doacao.: "+transf(nBRINDE,"@E 99,999,999.99")+" Consignacao.: " +transf(nCONSIG,"@E 99,999,999.99")+" Descontos.: "+transf(nDesconto,"@E 999,999.99")
       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1,00 say replicate("-",136)
       @ prow()+1  ,00 say "TOTAIS GERAIS.......: "+space(20)+"  Venda.: "+transf(nTOT_GER_VEN,"@E 99,999,999.99")+"  Doacao.: "+transf(nTOT_GER_BRI,"@E 99,999,999.99")+" Consignacao.: " +transf(nTOT_GER_CON,"@E 99,999,999.99")+" Descontos.: "+transf(nTOT_GER_DES,"@E 999,999.99")

       nQUANT  := 0
       nTOTAL  := 0
       nPERC   := 0
       nVENDA  := 0
       nBRINDE := 0
       nCONSIG := 0
       nTOT_GER_VEN  := 0
       nTOT_GER_BRI  := 0
       nTOT_GER_CON  := 0
       nTOT_GER_DES  := 0
       nIPI          := 0
       nDESCONTO     := 0

   endif

   qstopprn()

return

////////////////////////////////////////////////////////
// FUNCAO DE IMPRESSAO em XLS

static function i_impre_xls
    local nTOTAL     := 0
    local nDESC      := 0
    local nDESCONTO  := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nTOT_GER_VEN  := 0
    local nTOT_GER_BRI  := 0
    local nTOT_GER_CON  := 0
    local nTOT_GER_DES  := 0

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

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-540-640" .and. ! left(FAT->Cod_cfop,4) $ "5910-5911-6910-6911-5917-6917"
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
          nTOTAL += q_soma_st()
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
        // aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es,FAT->Codigo,alltrim(FAT->Cod_cfop),nDESC })
        if FI545->(qappend())
           replace FI545->Dt_emissao with FAT->Dt_emissao
           replace FI545->Cod_cli    with FAT->Cod_cli
           replace FI545->Razao      with CLI1->Razao
           replace FI545->Total      with nTOTAL
           replace FI545->Num_fatura with FAT->Num_fatura
           replace FI545->Estado     with CGM->Estado
           replace FI545->cod_repres with FAT->Cod_repres
           replace FI545->Es         with FAT->Es
           replace FI545->Codigo     with FAT->Codigo
           replace FI545->Cfop       with alltrim(FAT->Cod_cfop)
           replace FI545->Desc       with nDesc
        endif
      endif
      nTOTAL := 0
      nDESC  := 0
      nIPI   := 0
      FAT->(dbskip())

   enddo

   FI545->(dbcommit())
   FI545->(dbgotop())

   //clas->sifica a matriz por vendedor + data vencimento
   //asFAT := asort(aFAT,,,{|x,y| x[6] +  x[3]+ x[5] < y[6] + y[3] + y[5] })
   if lTEM
       zUFS  := FI545->Estado
       nCONT := 1
       do while FI545->(!Eof())

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say "            " +chr(9)+ "    "+chr(9)+ cTITULO
              @ prow()+1,0 say "Data Emissao" +chr(9)+ "Cfop"+chr(9)+ "Cliente"+chr(9)+ "Total"+chr(9)+"Nota Fiscal"+chr(9)+"UF"+chr(9)+"Representante"
           endif

           @ prow()+1, 00        say dtoc(FI545->dt_emissao)+chr(9)                         //Data de Emissao
           @ prow()  , pcol()+1  say FI545->Cfop+chr(9)                         //CFOP
           @ prow()  , pcol()+1  say FI545->Razao+chr(9)                         //Razao do Cliente
           @ prow()  , pcol()+1  say transf(FI545->Total,"@E 9,999,999.99")+chr(9) //Valor da Nota
           @ prow()  , pcol()+1  say FI545->Num_fatura+chr(9)                         //Numero da Nota
           @ prow()  , pcol()+1  say FI545->Estado+chr(9)                         //ESTADO
           REPRES->(DbSeek(FI545->Cod_repres))
           @ prow()  , pcol()+1  say left(REPRES->Razao,20)                 //REPRESENTANTE

           if left(FI545->Cfop,3) $ "510-511-512-610-611-612-540-640"
              nVENDA += (FI545->Total)
              nTOT_GER_VEN  += (FI545->total)
           endif

           if left(FI545->Cfop,4) $ "5910-5911-6910-6911"
              nBRINDE += (FI545->Total)
              nTOT_GER_BRI  += (FI545->total)
           endif

           if left(FI545->Cfop,4) $ "5917-6917"
              nCONSIG += (FI545->total)
              nTOT_GER_CON  += (FI545->total)
           endif

           if FI545->Desc > 0
              nDESCONTO    += FI545->Desc
              nTOT_GER_DES += FI545->Desc
           endif


           if FI545->Desc > 0
              @ prow()+1,00 say ""+chr(9)+""+chr(9)+"Desconto de "+transform(FI545->Desc,"@E 999,999.99")+chr(9)
           endif

           FI545->(dbskip())


          if alltrim(FI545->Estado) != alltrim(zUFS)
              UFS->(dbseek(zUFS))
              @ prow()+2  ,00 say ""+chr(9)+""+chr(9)+"TOTAIS DO ESTADO....: "+left(UFS->Descricao,20)+"  Venda.: "+transf(nVENDA,"@E 99,999,999.99")+"  Doacao.: "+transf(nBRINDE,"@E 99,999,999.99")+" Consignacao.: " +transf(nCONSIG,"@E 99,999,999.99")+" Descontos.: "+transf(nDesconto,"@E 999,999.99")
              @ prow()+1  ,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
              nVENDA  := 0
              nCONSIG := 0
              nBRINDE := 0
              nDesconto := 0
          endif

         zUFS := FI545->Estado

       enddo
       UFS->(dbseek(zUFS))
       @ prow()+2  ,00 say ""+chr(9)+""+chr(9)+"TOTAIS DO ESTADO....: "+left(UFS->Descricao,20)+"  Venda.: "+transf(nVENDA,"@E 99,999,999.99")+"  Doacao.: "+transf(nBRINDE,"@E 99,999,999.99")+" Consignacao.: " +transf(nCONSIG,"@E 99,999,999.99")+" Descontos.: "+transf(nDesconto,"@E 999,999.99")
       @ prow()+2  ,00 say ""+chr(9)+""+chr(9)+"TOTAIS GERAIS.......: "+space(20)+"  Venda.: "+transf(nTOT_GER_VEN,"@E 99,999,999.99")+"  Doacao.: "+transf(nTOT_GER_BRI,"@E 99,999,999.99")+" Consignacao.: " +transf(nTOT_GER_CON,"@E 99,999,999.99")+" Descontos.: "+transf(nTOT_GER_DES,"@E 999,999.99")


       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0

       nVENDA  := 0
       nBRINDE := 0
       nCONSIG := 0
       nDesconto := 0
       nTOT_GER_VEN  := 0
       nTOT_GER_BRI  := 0
       nTOT_GER_CON  := 0
       nTOT_GER_DES  := 0

   endif

   qstopprn(.F.)

return


