/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: MARGEM DE LUCRO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2007
// OBS........:
// ALTERACOES.:

function cl562

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cPRODUTO := space(5)
private cDESC := space(40)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cPRODUTO)       } , "PROD"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B562A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cPRODUTO := space(5)
   cDESC := space(40)

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
           PROD->(Dbsetorder(4))
           qrsay(XNIVEL,cPRODUTO)

           if empty(cPRODUTO)
              qmensa("Campo Obrigat¢rio !!!","B")
              return .F.
           else
              if ! PROD->(Dbseek(cPRODUTO:=strzero(val(cPRODUTO),5)))
                 qmensa("Produto nao Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,PROD->Cod_ass+" / "+left(PROD->Cod_fabr,6)+" "+left(PROD->Descricao,20) + left(PROD->Marca,10))
                 cDESC := PROD->Cod_ass+" / "+left(PROD->Cod_fabr,6)+" "+left(PROD->Descricao,20) + left(PROD->Marca,10)
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := cPRODUTO+" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PROD->(dbsetorder(4))

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nTOTAL     := 0
    local nVENDAS    := 0
    local nIPI       := 0
    local nPIS       := 0
    local nCOFINS   := 0
    local nIRPJ      := 0
    local nCSLL      := 0
    local nCOMIS_RPR := 0
    local nCOMIS_VND := 0
    local nTOT_RPR   := 0
    local nTOT_VND := 0
    local nPRECO_CUST := 0
    local nTOT_CUST := 0
    local nVALOR     := 0
    local nBONIF     := 0  //Notas de Bonificacao
    local nTTBONIF   := 0  //Total de Bonificacao
    local nDESC      := 0
    local nTOT_GER   := 0
    local nICMS      := 0
    local nTOTICMS   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         if CONFIG->Modelo_2 != "7"
            FAT->(dbskip())
            loop
         endif
      endif

      if left(FAT->Cod_cfop,4) $ "5917-6917"
         FAT->(dbskip())
         loop
      endif
      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))

             if ITEN_FAT->Cod_prod != cPRODUTO
                ITEN_FAT->(Dbskip())
                loop
             endif

             if left(FAT->Cod_cfop,4) $ "5910-5911-5912-6910-6911-6912" .or. (FAT->No_nf .and. FAT->Tipo $ "2-3-6")
                nBONIF := nBONIF + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
                aadd(aFAT,{right(PROD->Codigo,5),0,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,ITEN_FAT->Quantidade,FAT->Codigo})
             else
                nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                nPRECO_CUST:= nPRECO_CUST + (ITEN_FAT->Preco_cust * ITEN_FAT->Quantidade)
                nCOMIS_RPR := nCOMIS_RPR + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comi_repre/100))
                nCOMIS_VND := nCOMIS_VND + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comissao/100))
                nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
                aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,0,FAT->Codigo})
             endif

             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             nICMS  := 0
             nBONIF := 0
             nPRECO_CUST := 0
             nCOMIS_RPR  := 0
             nCOMIS_VND  := 0

             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
         nICMS := 0
         nBONIF := 0
         nTTBONIF := 0
         nPRECO_CUST := 0
         nCOMIS_RPR  := 0
         nCOMIS_VND  := 0

   enddo

   nVENDAS := 0
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]
       PROD->(dbsetorder(4))
       PROD->(Dbseek(cPROD))
       zPROD := left(PROD->Cod_fabr,7) + " "+PROD->Cod_ass + " "+left(PROD->Descricao,20)+" "+PROD->Marca

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND0
              qpageprn()
              qcabecprn(cTITULO,80)
              @ prow()+1,0 say XCOND1 + "Produto                                                   Quantidade        Bonif       Valor "
              @ prow()+1,0 say replicate("-",134)
           endif

           if asFAT[nCONT,5] == "S"  // Se for Saida soma as quantidade senao diminui
              nQUANT     += asFAT[nCONT,2]    //Quantidade
              nTOT_QUANT += asFAT[nCONT,2]    //Quantidade
              nTOTAL     += asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOT_GER   += asFAT[nCONT,4]    //Quantidade * valor unitario

              nCOMIS_RPR += asFAT[nCONT,6]    //Comissao para Representante
              nTOT_RPR   += asFAT[nCONT,6]    //Comissao para Representante
              nCOMIS_VND += asFAT[nCONT,7]    //Comissao para Vendedor
              nTOT_VND   += asFAT[nCONT,7]    //Comissao para Vendedor
              nPRECO_CUST+= asFAT[nCONT,8]    //Preco de Custo
              nTOT_CUST  += asFAT[nCONT,8]    //Preco de Custo
              nICMS      += asFAT[nCONT,9]    //Icms
              nTOTICMS   += asFAT[nCONT,9]    //Total Geral de Icms
              nBONIF     += asFAT[nCONT,11]   //Bonificacoes
              nTTBONIF   += asFAT[nCONT,10]   //Total Geral de Bonificacoes
           else
              nQUANT -= asFAT[nCONT,2]
              nTOT_QUANT -= asFAT[nCONT,2]
              nTOTAL -= asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOT_GER -= asFAT[nCONT,4]  //Quantidade * valor unitario
              nCOMIS_RPR -= asFAT[nCONT,6]
              nTOT_RPR   -= asFAT[nCONT,6]
              nCOMIS_VND -= asFAT[nCONT,7]
              nTOT_VND   -= asFAT[nCONT,7]
              nPRECO_CUST-= asFAT[nCONT,8]
              nTOT_CUST  -= asFAT[nCONT,8]
              nICMS      -= asFAT[nCONT,9]
              nTOTICMS   -= asFAT[nCONT,9]
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00  say zPROD
              @ prow()  ,61  say transf(nQUANT,"@R 999999")
              @ prow()  ,75  say transf(nBONIF,"@R 999999")
              @ prow()  ,87  say transf(nTOTAL,"@E 999,999.99")
              @ prow()  ,102 say transf(nPRECO_CUST,"@E 99,999.99")

              cPROD := asFAT[nCONT,1]
              PROD->(dbsetorder(4))
              PROD->(Dbseek(cPROD))
              zPROD := left(PROD->Cod_fabr,6) + " "+PROD->Cod_ass + " "+left(PROD->Descricao,20)+" "+left(PROD->Marca,12)

              nQUANT := 0
              nTOTAL := 0
              nBONIF := 0
              nCOMIS_RPR  := 0
              nCOMIS_VND  := 0
              nPRECO_CUST := 0
           endif
       enddo
       @ prow()+1,00 say zPROD
       @ prow()  ,61  say transf(nQUANT,"@R 999999")
       @ prow()  ,75  say transf(nBONIF,"@R 999999")
       @ prow()  ,87  say transf(nTOTAL,"@E 999,999.99")
       @ prow()  ,102 say transf(nPRECO_CUST,"@E 99,999.99")
       cPROD := asFAT[nCONT,1]
       PROD->(dbsetorder(4))
       PROD->(Dbseek(cPROD))
       zPROD := left(PROD->Cod_fabr,6) + " "+PROD->Cod_ass + " "+left(PROD->Descricao,20)+" "+left(PROD->Marca,12)

       nQUANT := 0
       nTOTAL := 0
       nBONIF := 0
       nCOMIS_RPR  := 0
       nCOMIS_VND  := 0
       nPRECO_CUST := 0


       @ prow()+1,00 say replicate("-",134)
       @ prow()+1,00 say "Quantidade     : "+transf(nTOT_QUANT,"@R 9999999999")
       @ prow()+1,00 say "Vendas         : "+transf(nTOT_GER,  "@E 999,999.99")
       if CONFIG->Modelo_fat == "1"
          @ prow()+1,00 say "Vendas + IPI   : "+transf(nTOT_GER*1.15,"@E 999,999.99")
       endif
       @ prow()+1,00 say "Custo:"
       @ prow()+1,00 say "Preco de Custo : "+transf(nTOT_CUST,  "@E 999,999.99")

       nVENDAS  := nTOT_GER
       nTOT_GER := nTOT_GER + nTTBONIF   //Para Incluir os Impostos das Bonificacoes

       nIPI  := nTOT_GER * 0.15
       nCOFINS := nTOT_GER * 0.03
       nPIS  := nTOT_GER * 0.0065
       nCSLL := nTOT_GER * 0.0108
       nIRPJ := nTOT_GER * 0.012
       @ prow()+1,00 say "Impostos.: "
       @ prow()+1,00 say "Icms           : "+transf(nTOTICMS,"@E 999,999.99")
       if CONFIG->Modelo_fat == "1"
          @ prow()+1,00 say "Ipi            : "+transf(nIPI,"@E 999,999.99")
       else
          nIPI := 0
       endif
       @ prow()+1,00 say "Cofins         : "+transf(nCOFINS,"@E 999,999.99")
       @ prow()+1,00 say "Pis            : "+transf(nPIS,"@E 999,999.99")
       @ prow()+1,00 say "Csll           : "+transf(nCSLL,"@E 999,999.99")

       if CONFIG->Modelo_fat == "1"
          @ prow()+1,00 say "Irpj           : "+transf(nIRPJ,"@E 999,999.99")
       else
         nIRPJ := 0
       endif

       @ prow()+1,00 say "Comissoes.: "
       @ prow()+1,00 say "Representantes.: "+transf(nTOT_RPR,"@E 999,999.99")
       @ prow()+1,00 say "Vendedores    .: "+transf(nTOT_VND,"@E 999,999.99")

       @ prow()+2,00 say "Frete          : "//+transf(i_frete(),"@E 999,999.99")
       @ prow()+1,00 say "Bonificacoes   : "+transf(nTTBONIF ,"@E 999,999.99")
       nTOTAL := nTOTICMS+nTOT_CUST+nTOT_RPR+nTOT_VND+nCOFINS+nPIS+nCSLL+nIRPJ+nTTBONIF
       @ prow()+2,00 say "Total Despesas.: "+transf(nTOTAL,"@E 999,999.99 ")
       @ prow()+1,00 say "Liquido       .: "+transf(nVENDAS-nTOTAL,"@E 999,999.99 ")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
       nTTBONIF := 0
       nBONIF := 0
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO EM EXCEL__________________

static function i_impre_xls
    local nTOTAL     := 0
    local nVENDAS    := 0
    local nIPI       := 0
    local nPIS       := 0
    local nCOFINS   := 0
    local nIRPJ      := 0
    local nCSLL      := 0
    local nCOMIS_RPR := 0
    local nCOMIS_VND := 0
    local nTOT_RPR   := 0
    local nTOT_VND := 0
    local nPRECO_CUST := 0
    local nTOT_CUST := 0
    local nVALOR     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nICMS      := 0
    local nBONIF     := 0
    local nTOTICMS   := 0
    local nTTBONIF   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         if CONFIG->Modelo_2 != "7"
            FAT->(dbskip())
            loop
         endif
      endif

      if left(FAT->Cod_cfop,4) $ "5917-6917"
         FAT->(dbskip())
         loop
      endif
      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))

             if ITEN_FAT->Cod_prod != cPRODUTO
                ITEN_FAT->(Dbskip())
                loop
             endif

             if left(FAT->Cod_cfop,4) $ "5910-5911-5912-6910-6911-6912" .or. (FAT->No_nf .and. FAT->Tipo $ "2-3-6")
                nBONIF := nBONIF + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
                aadd(aFAT,{right(PROD->Codigo,5),0,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,ITEN_FAT->Quantidade,FAT->Codigo})
             else
                nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                nPRECO_CUST:= nPRECO_CUST + (ITEN_FAT->Preco_cust * ITEN_FAT->Quantidade)
                nCOMIS_RPR := nCOMIS_RPR + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comi_repre/100))
                nCOMIS_VND := nCOMIS_VND + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comissao/100))
                nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
                aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,0,FAT->Codigo})
             endif

             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             nICMS  :=  0
             nBONIF := 0
             nPRECO_CUST := 0
             nCOMIS_RPR  := 0
             nCOMIS_VND  := 0

             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
         nICMS := 0
         nBONIF := 0
         nPRECO_CUST := 0
         nCOMIS_RPR  := 0
         nCOMIS_VND  := 0

   enddo
   nVENDAS := 0
   nTTBONIF:= 0
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]
       PROD->(dbsetorder(4))
       PROD->(Dbseek(cPROD))
       zPROD := left(PROD->Cod_fabr,7) + " "+PROD->Cod_ass + " "+left(PROD->Descricao,20)+" "+PROD->Marca

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say cTITULO
              @ prow()+1,0 say "Produto"+chr(9)+"Quantidade"+chr(9)+"Qty Bonificacoes"+chr(9)+"Valor"+chr(9)+"Preco de Custo"
              @ prow()+1,0 say ""
           endif

           if asFAT[nCONT,5] == "S"  // Se for Saida soma as quantidade senao diminui
              nQUANT     += asFAT[nCONT,2]    //Quantidade
              nTOT_QUANT += asFAT[nCONT,2]    //Quantidade
              nTOTAL     += asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOT_GER   += asFAT[nCONT,4]    //Quantidade * valor unitario

              nCOMIS_RPR += asFAT[nCONT,6]    //Comissao para Representante
              nTOT_RPR   += asFAT[nCONT,6]    //Comissao para Representante
              nCOMIS_VND += asFAT[nCONT,7]    //Comissao para Vendedor
              nTOT_VND   += asFAT[nCONT,7]    //Comissao para Vendedor
              nPRECO_CUST+= asFAT[nCONT,8]    //Preco de Custo
              nTOT_CUST  += asFAT[nCONT,8]    //Preco de Custo
              nICMS      += asFAT[nCONT,9]
              nTOTICMS   += asFAT[nCONT,9]
              nBONIF     += asFAT[nCONT,11]
              nTTBONIF   += asFAT[nCONT,10]
           else
              nQUANT -= asFAT[nCONT,2]
              nTOT_QUANT -= asFAT[nCONT,2]
              nTOTAL -= asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOT_GER -= asFAT[nCONT,4]  //Quantidade * valor unitario
              nCOMIS_RPR -= asFAT[nCONT,6]
              nTOT_RPR   -= asFAT[nCONT,6]
              nCOMIS_VND -= asFAT[nCONT,7]
              nTOT_VND   -= asFAT[nCONT,7]
              nPRECO_CUST-= asFAT[nCONT,8]
              nTOT_CUST  -= asFAT[nCONT,8]
              nICMS      -= asFAT[nCONT,9]
              nTOTICMS   -= asFAT[nCONT,9]
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say zPROD+chr(9)
              @ prow()  ,pcol() say transf(nQUANT,"@R 999999")+chr(9)
              @ prow()  ,pcol() say transf(nBONIF,"@R 999999")+chr(9)
              @ prow()  ,pcol() say transf(nTOTAL,"@E 999,999.99")+chr(9)
              @ prow()  ,pcol() say transf(nPRECO_CUST,"@E 99,999.99")
              cPROD := asFAT[nCONT,1]
              PROD->(dbsetorder(4))
              PROD->(Dbseek(cPROD))
              zPROD := left(PROD->Cod_fabr,6) + " "+PROD->Cod_ass + " "+left(PROD->Descricao,20)+" "+left(PROD->Marca,12)

              nQUANT := 0
              nTOTAL := 0
              nBONIF := 0
              nCOMIS_RPR  := 0
              nCOMIS_VND  := 0
              nPRECO_CUST := 0
           endif
       enddo
       @ prow()+1,00 say zPROD+chr(9)
       @ prow()  ,pcol() say transf(nQUANT,"@R 999999")+chr(9)
       @ prow()  ,pcol() say transf(nBONIF,"@R 999999")+chr(9)
       @ prow()  ,pcol() say transf(nTOTAL,"@E 999,999.99")+chr(9)
       @ prow()  ,pcol()  say transf(nPRECO_CUST,"@E 99,999.99")
       cPROD := asFAT[nCONT,1]
       PROD->(dbsetorder(4))
       PROD->(Dbseek(cPROD))
       zPROD := left(PROD->Cod_fabr,6) + " "+PROD->Cod_ass + " "+left(PROD->Descricao,20)+" "+left(PROD->Marca,12)

       nQUANT := 0
       nTOTAL := 0
       nBONIF := 0
       nCOMIS_RPR  := 0
       nCOMIS_VND  := 0
       nPRECO_CUST := 0


       @ prow()+1,00 say ""
       @ prow()+1,00 say "Quantidade     "+chr(9)+transf(nTOT_QUANT,"@R 9999999999")
       @ prow()+1,00 say "Vendas         "+chr(9)+transf(nTOT_GER,  "@E 999,999.99")
       if CONFIG->Modelo_fat == "1"
          @ prow()+1,00 say "Vendas + IPI   "+chr(9)+transf(nTOT_GER*1.15,"@E 999,999.99")
       endif
       @ prow()+2,00 say "Custo:"
       @ prow()+1,00 say "Preco de Custo  "+chr(9)+transf(nTOT_CUST,  "@E 999,999.99")
       nVENDAS  := nTOT_GER
       nTOT_GER := nTOT_GER + nTTBONIF

       nIPI  := nTOT_GER * 0.15
       nCOFINS := nTOT_GER * 0.03
       nPIS  := nTOT_GER * 0.0065
       nCSLL := nTOT_GER * 0.0108
       nIRPJ := nTOT_GER * 0.012
       @ prow()+2,00 say "Impostos "
       @ prow()+1,00 say "Icms            "+chr(9)+transf(nTOTICMS,"@E 999,999.99")
       if CONFIG->Modelo_fat == "1"
          @ prow()+1,00 say "Ipi             "+chr(9)+transf(nIPI,"@E 999,999.99")
       else
          nIPI := 0
       endif
       @ prow()+1,00 say "Cofins          "+chr(9)+transf(nCOFINS,"@E 999,999.99")
       @ prow()+1,00 say "Pis             "+chr(9)+transf(nPIS,"@E 999,999.99")
       @ prow()+1,00 say "Csll            "+chr(9)+transf(nCSLL,"@E 999,999.99")
       if CONFIG->Modelo_fat == "1"
          @ prow()+1,00 say "Irpj            "+chr(9)+transf(nIRPJ,"@E 999,999.99")
       else
          nIRPJ := 0
       endif

       @ prow()+2,00 say "Comissoes.: "
       @ prow()+1,00 say "Representantes "+chr(9)+transf(nTOT_RPR,"@E 999,999.99")
       @ prow()+1,00 say "Vendedores     "+chr(9)+transf(nTOT_VND,"@E 999,999.99")

       @ prow()+2,00 say "Frete          "//+chr(9)+transf(i_frete(),"@E 999,999.99")
       @ prow()+1,00 say "Bonificacoes   "+chr(9)+transf(nTTBONIF,"@E 999,999.99")
       nTOTAL := nTOTICMS+nTOT_CUST+nTOT_RPR+nTOT_VND+nCOFINS+nPIS+nCSLL+nIRPJ+nTTBONIF
       @ prow()+2,00 say "Total Despesas "+chr(9)+transf(nTOTAL,"@E 999,999.99 ")
       @ prow()+1,00 say "Liquido        "+chr(9)+transf(nVENDAS-nTOTAL,"@E 999,999.99 ")

       nQUANT   := 0
       nTOTAL   := 0
       nTTBONIF := 0
       nPERC    := 0
       nVENDAS  := 0
   endif

   qstopprn(.F.)

return


static function i_frete
local nTOT_FRETE := 0
FRETE->(Dbsetfilter({||Cod_cli == cCLI  .and. Dt_emissao >= dINI .and. Dt_emissao <= dFIM}))
FRETE->(Dbsetorder(2)) //SDatada Emissao
FRETE->(Dbgotop())


Do while ! FRETE->(Eof()) .and. FRETE->Dt_emissao >= dINI .and. FRETE->Dt_emissao <= dFIM

   nTOT_FRETE := nTOT_FRETE + FRETE->Vlr_total
   FRETE->(Dbskip())
enddo

FRETE->(dbclearfilter())
return nTOT_FRETE


