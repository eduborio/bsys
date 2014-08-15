/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: maio DE 2006
// OBS........:
// ALTERACOES.:

function cl549
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cCLI := space(5)
private cRAZAO := space(40)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_Cli(-1,0,@cCLI)         } , "CLIENTE"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B542A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cCLI := space(5)
   cRAZAO := space(40)

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

      case cCAMPO == "CLIENTE"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL+1, "Todos os Clientes.......")
              cRAZAO := " *** Todos os Clientes *** "
           else
              if ! CLI1->(Dbseek(cCLI:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(CLI1->Razao,40))
                 cRAZAO := left(CLI1->Razao,40)
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := cRAZAO+" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

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
      if ! empty(cCLI)
         i_impre_xls()
      else
         i_analitico_xls()
      endif
   else
      if ! empty(cCLI)
         i_impre_prn()
      else
         i_analitico_xls()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nFrete     := 0
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
    local nVENCIDAS   := 0
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
         FAT->(dbskip())
         loop
      endif

      if FAT->Cod_cli != cCLI
         FAT->(dbskip())
         loop
      endif

      //qgirabarra()

      //qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))

             if left(FAT->Cod_cfop,4) $ "5910-5911-6910-6911" .or. (FAT->No_nf .and. FAT->Tipo $ "2-3-6")
                nBONIF := nBONIF + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
                aadd(aFAT,{right(PROD->Codigo,5),0,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,ITEN_FAT->Quantidade,FAT->Codigo})
             else
               if left(FAT->cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
                   nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                   nPRECO_CUST:= nPRECO_CUST + (ITEN_FAT->Preco_cust * ITEN_FAT->Quantidade)
                   nCOMIS_RPR := nCOMIS_RPR + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comi_repre/100))
                   nCOMIS_VND := nCOMIS_VND + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comissao/100))
                   nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
                   aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,0,FAT->Codigo})
               endif
             endif

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

           if mod(nCont,200) == 0 
		      if ! qlineprn() ; exit ; endif
			  qgirabarra()
		   endif
		   
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

	   nFrete := i_frete()
       
	   @ prow()+2,00 say "Frete          : "+transf(nFrete,"@E 999,999.99")
	   	   
       @ prow()+1,00 say "Bonificacoes   : "+transf(nTTBONIF ,"@E 999,999.99")
       nTOTAL := nTOTICMS+nTOT_CUST+nTOT_RPR+nTOT_VND+nCOFINS+nPIS+nCSLL+nIRPJ+nFrete+nTTBONIF
       @ prow()+2,00 say "Total Despesas.: "+transf(nTOTAL,"@E 999,999.99 ")
       @ prow()+1,00 say "Vendas-Despesas: "+transf(nVENDAS-nTOTAL,"@E 999,999.99 ")
       nVencidas := getFaturasVencidas(cCLI)
       @ prow()+1,00 say "Fat. Vencidas..: "+transf(nVencidas,"@E 999,999.99")
       @ prow()+2,00 say "Liquido       .: "+transf(nVENDAS-(nTOTAL+nVENCIDAS),"@E@) 999,999,999.99")


       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
       nTTBONIF := 0
       nBONIF := 0
	   nFrete := 0
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO EM EXCEL__________________

static function i_impre_xls
    local nTOTAL     := 0
    local nVENDAS    := 0
    local nVENCIDAS  := 0
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

      if FAT->Cod_cli != cCLI
         FAT->(dbskip())
         loop
      endif

      if left(FAT->Cod_cfop,4) $ "5917-6917"
         FAT->(dbskip())
         loop
      endif

      //qgirabarra()
      //qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             if left(FAT->Cod_cfop,4) $ "5910-5911-6910-6911" 
                nBONIF := nBONIF + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
                aadd(aFAT,{right(PROD->Codigo,5),0,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,ITEN_FAT->Quantidade})
             else
               if left(FAT->cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
                   nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                   nPRECO_CUST:= nPRECO_CUST + (ITEN_FAT->Preco_cust * ITEN_FAT->Quantidade)
                   nCOMIS_RPR := nCOMIS_RPR + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comi_repre/100))
                   nCOMIS_VND := nCOMIS_VND + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comissao/100))
                   nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
                   aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,0})
               endif
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
       zPROD := left(PROD->Cod_fabr,7) + chr(9) +PROD->Cod_ass + chr(9) +left(PROD->Descricao,20)+ chr(9) +PROD->Marca

       nCONT := 1
       do while  nCONT <= len(asFAT)

		   
		   if mod(nCont,200) == 0 
		      if ! qlineprn() ; exit ; endif
			  qgirabarra()
		   endif
		   
           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO+" 549"
              @ prow()+1,0 say "Ref."+chr(9)+"Ref."+chr(9)+"Produto"+chr(9)+"Colecao"+chr(9)+"Quantidade"+chr(9)+"Qty Bonificacoes"+chr(9)+"Valor"+chr(9)+"Preco de Custo"
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
              zPROD := left(PROD->Cod_fabr,6) + chr(9)+PROD->Cod_ass + chr(9) +left(PROD->Descricao,20)+chr(9)+left(PROD->Marca,12)

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
       zPROD := left(PROD->Cod_fabr,6) + chr(9) +PROD->Cod_ass + chr(9) +left(PROD->Descricao,20)+ chr(9) +left(PROD->Marca,12)

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

       nFrete := i_frete(cCLI)
	   @ prow()+2,00 say "Frete          "+chr(9)+transf(nFrete,"@E 999,999.99")
       @ prow()+1,00 say "Bonificacoes   "+chr(9)+transf(nTTBONIF,"@E 999,999.99")
       nVencidas := getFaturasVencidas(cCLI)
       @ prow()+1,00 say "Faturas Vencidas"+chr(9)+transf(nVencidas,"@E 999,999.99")
       nTOTAL := nTOTICMS+nTOT_CUST+nTOT_RPR+nTOT_VND+nCOFINS+nPIS+nCSLL+nIRPJ+nFrete+nTTBONIF
       @ prow()+2,00 say "Total Despesas "+chr(9)+transf(nTOTAL,"@E 999,999.99 ")
       @ prow()+1,00 say "Vendas - Despesas"+chr(9)+transf(nVENDAS-nTOTAL,"@E 999,999.99 ")
       @ prow()+1,00 say "Faturas Vencidas"+chr(9)+transf(nVencidas,"@E 99,999,999.99")
       @ prow()+2,00 say "Liquido         "+chr(9)+transf(nVENDAS-(nTOTAL+nVENCIDAS),"@E@) 999,999,999.99")

       nQUANT   := 0
       nTOTAL   := 0
       nTTBONIF := 0
       nPERC    := 0
       nVENDAS  := 0
   endif

   qstopprn(.F.)

return


static function i_frete(cCOD_CLI)
local nTOT_FRETE := 0

FRETE->(Dbsetorder(3)) //SDatada Emissao
FRETE->(dbseek(cCod_cli + dtos(dINI),.T.))

Do while ! FRETE->(Eof()) .and. FRETE->Cod_cli == cCOD_CLI

   if FRETE->Dt_emissao < dINI .or. Frete->Dt_emissao > dFIM
      FRETE->(dbskip())
	  loop
   endif

   nTOT_FRETE := nTOT_FRETE + FRETE->Vlr_total
   FRETE->(Dbskip())
enddo

return nTOT_FRETE


static function getFaturasVencidas(cCOD_CLI)
return 0

static function getFaturasVencidasTireiparanaorodarfilterMudar(cCOD_CLI)
  local nTotalVencido := 0

  RECEBER->(dbclearfilter())
  RECEBER->(dbsetfilter({|| Cod_cli == cCOD_CLI}))

  do while ! RECEBER->(eof())

     if RECEBER->Data_venc < date()
        nTotalVencido += RECEBER->Valor_liq
     endif

     RECEBER->(dbskip())

  enddo

  RECEBER->(dbclearfilter())

return nTotalVencido


static function i_analitico_xls
    local nTOTAL     := 0
    local nVENDAS    := 0
    local nVENCIDAS  := 0
    local nIPI       := 0
    local nPIS       := 0
    local nCOFINS    := 0
    local nIRPJ      := 0
    local nCSLL      := 0
    local nCOMIS_RPR := 0
    local nCOMIS_VND := 0
    local nPRECO_CUST:= 0
    local nVALOR     := 0
    local nICMS      := 0
    local nBONIF     := 0
    local nCONT      := 0
    local nDESPESAS  := 0
    local nCOMISSOES := 0
    local nIMPOSTOS  := 0
    local nLIQUIDO   := 0
    local nFRETE     := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local aCli       := {}
    local cCOD_CLI := ""

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())

      if FAT->Dt_emissao < dINI .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif


      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
      //   if CONFIG->Modelo_2 != "7"
            FAT->(dbskip())
            loop
      //   endif
      endif

      //if ! empty(cCLI)
      //   if FAT->Cod_cli != cCLI
      //      FAT->(dbskip())
       //     loop
       //  endif
      //endif

      if left(FAT->Cod_cfop,4) $ "5917-6917"
         FAT->(dbskip())
         loop
      endif

      if mod(FAT->(recno()),300) == 0
	     qgirabarra()
         qmensa("Aguarde... Processando ...")
	  endif	 

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             if left(FAT->Cod_cfop,4) $ "5910-5911-6910-6911"
                nBONIF := nBONIF + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
//              aadd(aFAT,{right(PROD->Codigo,5),0,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,ITEN_FAT->Quantidade})
             else
               if left(FAT->cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
                   nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
                   nPRECO_CUST:= nPRECO_CUST + (ITEN_FAT->Preco_cust * ITEN_FAT->Quantidade)
                   nCOMIS_RPR := nCOMIS_RPR + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comi_repre/100))
                   nCOMIS_VND := nCOMIS_VND + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Comissao/100))
                   nICMS := nICMS + ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
//                 aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,nCOMIS_RPR,nCOMIS_VND,nPRECO_CUST,nICMS,nBONIF,0})
               endif
             endif

             ITEN_FAT->(Dbskip())

             lTEM := .T.
         enddo

         if FAT->Es == "S"
            aadd(aFAT,{FAT->Cod_cli,   nVALOR  ,nPRECO_CUST    ,nBONIF,  nCOMIS_RPR   ,  nCOMIS_VND   ,nICMS     })
         else
            aadd(aFAT,{FAT->Cod_cli,nVALOR*(-1),nPRECO_CUST*(-1),  0  ,nCOMIS_RPR*(-1),nCOMIS_VND*(-1),nICMS*(-1)})
         endif


         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
         nICMS := 0
         nBONIF := 0
         nPRECO_CUST := 0
         nCOMIS_RPR  := 0
         nCOMIS_VND  := 0

   enddo

   //classifica a matriz por descricao do produto

   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cCOD_CLI := asFAT[1,1]
       CLI1->(dbsetorder(1))

       nCONT := 1
       do while  nCONT <= len(asFAT)

           //if ! qlineprn() ; exit ; endif
           //if XPAGINA == 0
           //   qpageprn()
           //   @ prow()+1,0 say cTITULO+" Resumido  -  549"
           //   @ prow()+1,0 say "Cliente"+chr(9)+"Vendas"+chr(9)+"Preco Custo"+chr(9)+"Impostos"+chr(9)+"Comissoes"+chr(9)+"Frete"+chr(9)+"Bonificacao"+"Total Despesas"+chr(9)+"Faturas Vencidas"+chr(9)+"Liquido"
           //   @ prow()+1,0 say ""
           //endif

           nVALOR     += asFAT[nCONT,2]    //Quantidade
           nPRECO_CUST+= asFAT[nCONT,3]    //Preco de Custo
           nBONIF     += asFAT[nCONT,4]


           nCOMIS_RPR += asFAT[nCONT,5]    //Comissao para Representante
           nCOMIS_VND += asFAT[nCONT,6]    //Comissao para Vendedor
           nICMS      += asFAT[nCONT,7]

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cCOD_CLI
//              CLI1->(dbseek(cCOD_CLI))
//              @ prow()+1,00     say CLI1->Razao
              nTOTAL     := (nVALOR + nBONIF)
              nCOMISSOES := (nCOMIS_RPR + nCOMIS_VND)
              nCOFINS    := nTOTAL * 0.03
              nPIS       := nTOTAL * 0.0065
              nCSLL      := nTOTAL * 0.0108
              nIRPJ      := nTOTAL * 0.012
              nIMPOSTOS  := (nPIS + nCOFINS + nCSLL + nIRPJ + nICMS)
              nFRETE     := i_frete(cCOD_CLI)
              nVENCIDAS  := getFaturasVencidas(cCOD_CLI)
              nDESPESAS  := (nPRECO_CUST + nIMPOSTOS + nCOMISSOES + nFRETE + nBONIF )
              nLIQUIDO   := (nVALOR - (nDESPESAS+nVENCIDAS))

//              @ prow()  ,pcol() say chr(9)+transf(nVALOR     ,"@E 9,999,999.99")
//              @ prow()  ,pcol() say chr(9)+transf(nPRECO_CUST,"@E 9,999,999.99")
//              @ prow()  ,pcol() say chr(9)+transf(nIMPOSTOS  ,"@E 9,999,999.99")
//              @ prow()  ,pcol() say chr(9)+transf(nCOMISSOES ,"@E 9,999,999.99")
//              @ prow()  ,pcol() say chr(9)+transf(nFRETE     ,"@E 9,999,999.99")
//              @ prow()  ,pcol() say chr(9)+transf(nBONIF     ,"@E 9,999,999.99")
//              @ prow()  ,pcol() say chr(9)+transf(nDESPESAS  ,"@E 9,999,999.99")
//              @ prow()  ,pcol() say chr(9)+transf(nVENCIDAS  ,"@E 9,999,999.99")
//              @ prow()  ,pcol() say chr(9)+transf(nLIQUIDO   ,"@E 9,999,999.99")
              CLI1->(dbseek(cCOD_CLI))


              aadd(aCli,{CLI1->Razao,nVALOR,nPRECO_CUST,nIMPOSTOS,nCOMISSOES,nFRETE,nBONIF,nDESPESAS,nVENCIDAS,nLIQUIDO,CLI1->codigo})

              cCOD_CLI  := asFAT[nCONT,1]

              nCOFINS     := 0
              nPIS        := 0
              nCSLL       := 0
              nIRPJ       := 0
              nVALOR      := 0
              nTOTAL      := 0
              nBONIF      := 0
              nCOMIS_RPR  := 0
              nCOMIS_VND  := 0
              nPRECO_CUST := 0
              nICMS       := 0
              nCOMISSOES  := 0
              nIMPOSTOS   := 0
              nFRETE      := 0
              nVENCIDAS   := 0
              nDESPESAS   := 0
              nLIQUIDO    := 0
           endif
       enddo

       if nVALOR > 0
          CLI1->(dbseek(cCOD_CLI))
//          @ prow()+1,00     say CLI1->Razao
          nTOTAL     := (nVALOR + nBONIF)
          nCOMISSOES := (nCOMIS_RPR + nCOMIS_VND)
          nCOFINS    := nTOTAL * 0.03
          nPIS       := nTOTAL * 0.0065
          nCSLL      := nTOTAL * 0.0108
          nIRPJ      := nTOTAL * 0.012
          nIMPOSTOS  := (nPIS + nCOFINS + nCSLL + nIRPJ + nICMS)
          nFRETE     := i_frete(cCOD_CLI)
          nVENCIDAS  := getFaturasVencidas(cCOD_CLI)
          nDESPESAS  := (nPRECO_CUST + nIMPOSTOS + nCOMISSOES + nFRETE + nBONIF )
          nLIQUIDO   := (nVALOR - (nDESPESAS+nVENCIDAS))

//          @ prow()  ,pcol() say chr(9)+transf(nVALOR     ,"@E 9,999,999.99")
//          @ prow()  ,pcol() say chr(9)+transf(nPRECO_CUST,"@E 9,999,999.99")
//          @ prow()  ,pcol() say chr(9)+transf(nIMPOSTOS  ,"@E 9,999,999.99")
//          @ prow()  ,pcol() say chr(9)+transf(nCOMISSOES ,"@E 9,999,999.99")
//          @ prow()  ,pcol() say chr(9)+transf(nFRETE     ,"@E 9,999,999.99")
//          @ prow()  ,pcol() say chr(9)+transf(nBONIF     ,"@E 9,999,999.99")
//          @ prow()  ,pcol() say chr(9)+transf(nDESPESAS  ,"@E 9,999,999.99")
//          @ prow()  ,pcol() say chr(9)+transf(nVENCIDAS  ,"@E 9,999,999.99")
//          @ prow()  ,pcol() say chr(9)+transf(nLIQUIDO   ,"@E 9,999,999.99")

         aadd(aCli,{CLI1->Razao,nVALOR,nPRECO_CUST,nIMPOSTOS,nCOMISSOES,nFRETE,nBONIF,nDESPESAS,nVENCIDAS,nLIQUIDO,CLI1->Codigo})
         cCOD_CLI  := asFAT[nCONT,1]
       endif

       nCOFINS     := 0
       nPIS        := 0
       nCSLL       := 0
       nIRPJ       := 0
       nVALOR      := 0
       nTOTAL      := 0
       nBONIF      := 0
       nCOMIS_RPR  := 0
       nCOMIS_VND  := 0
       nPRECO_CUST := 0
       nICMS       := 0
       nCOMISSOES  := 0
       nIMPOSTOS   := 0
       nFRETE      := 0
       nVENCIDAS   := 0
       nDESPESAS   := 0
       nLIQUIDO    := 0
   endif


   aCLI := asort(aCli,,,{|x,y| x[10] > y[10] })



   nCONT := 1
   do while  nCONT <= len(aCli)

       if mod(nCont,200) == 0 
	      if ! qlineprn() ; exit ; endif
		  qgirabarra()
	   endif
	   
       if XPAGINA == 0
          qpageprn()
          @ prow()+1,0 say cTITULO+" Resumido  -  549"
          @ prow()+1,0 say "Cliente"+chr(9)+"Vendas"+chr(9)+"Preco Custo"+chr(9)+"Impostos"+chr(9)+"Comissoes"+chr(9)+"Frete"+chr(9)+"Bonificacao"+chr(9)+"Total Despesas"+chr(9)+"Faturas Vencidas"+chr(9)+"Liquido"
          @ prow()+1,0 say ""
       endif

       CLI1->(dbseek(aCLI[nCONT,11]))
       @ prow()+1,00     say aCli[nCONT,1]
       @ prow()  ,pcol() say chr(9)+transf(aCli[nCONT,2] ,"@E 9,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf(aCli[nCONT,3] ,"@E 9,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf(aCli[nCONT,4] ,"@E 9,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf(aCli[nCONT,5] ,"@E 9,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf(aCli[nCONT,6] ,"@E 9,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf(aCli[nCONT,7] ,"@E 9,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf(aCli[nCONT,8] ,"@E 9,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf(aCli[nCONT,9] ,"@E 9,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf(aCli[nCONT,10],"@E 9,999,999.99")


      nCONT++
      if nCONT > len(aCli)
         nCONT := len(aCli)
         exit
      endif
   enddo


   qstopprn(.F.)

return




