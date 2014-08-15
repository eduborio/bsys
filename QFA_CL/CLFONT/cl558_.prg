/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Relatorio de Pedidos Simples(sem Nota)
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JANEIRO DE 2007
// OBS........:
// ALTERACOES.:

function cl558
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private cCLI := space(5)
private dINI
private dFIM
private cTIPO   := space(1)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private sBLOC1  := qlbloc("B558B","QBLOC.GLO")


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI)         } , "CLI"    })
aadd(aEDICAO,{{ || NIL                          } , NIL      })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOC1    )}  ,"TIPO"  })


do while .T.

   qlbloc(5,0,"B558A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cCLI   := space(5)
   dINI := dFIM := ctod("")
   cTIPO := space(1)
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

      case cCAMPO == "TIPO"
           //if empty(fTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO," 123456789",{"Todos os Tipos","Venda","Bonificacao","Doacao","Troca","Emprestimo","Amostra","Devolucao de Venda","Devolucao de Emprestimo","Cancelados"}))

      case cCAMPO == "CLI"
           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL+1, "Todos os CLientes.......")
           else
              if ! CLI1->(Dbseek(cCLI))
                 qmensa("CLiente n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CLI1->Razao,30))
              endif
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   if cTIPO == "9"
     cTITULO := "RELATORIO DE PEDIDOS CANCELADOS" + " de " + dtoc(dINI) + " a " + dtoc(dFIM)
   else
     cTITULO := "RELATORIO DE VENDAS POR OPERACAO" + " de " + dtoc(dINI) + " a " + dtoc(dFIM)
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

   if ! qinitprn() ; return  ; endif

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
    local nDESC      := 0
    local nTOT_GER   := 0
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
    local nREP_COM := 0
    local nCOM_ITEM := 0
    local lFIRST := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())//  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))

      if cTIPO == "9"
         if FAT->Cancelado == .F.
            FAT->(Dbskip())
            loop
         endif

      else
         if FAT->Cancelado
            FAT->(Dbskip())
            loop
         endif
      endif

      if ! FAT->No_nf
         FAT->(Dbskip())
         loop
      endif

      if ! empty(cCLI)
         if FAT->Cod_cli != cCLI
            FAT->(Dbskip())
            loop
         endif
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      if FAT->Dt_emissao < dINI .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      nREP_COM := 0

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          nDESC += ITEN_FAT->Vlr_desc * ITEN_FAT->Quantidade
          nREP_COM += ((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Comi_repre/100))
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if CONFIG->Modelo_fat == "1"
         nDESC := nDESC
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      if !empty(cTIPO) .and. FAT->Tipo <> cTIPO .and. cTIPO != "9"
         //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,,CGM->Estado,FAT->Cod_repres,CLI1->Comis_repr})
      else
          aadd(aFAT,{dtoc(FAT->Dt_Emissao),left(CLI1->Razao,35),nTOTAL,FAT->Tipo,FAT->Es,FAT->Codigo})
      endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      FAT->(dbskip())

   enddo

   //classifica a matriz por vendedor + data vencimento
   asFAT := asort(aFAT,,,{|x,y| x[4] + x[1]  < y[4] + y[1] })
   if lTEM
       zTIPO  := asFAT[1,4]
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say XCOND1 + "Data Emissao   Pedido  Cliente                               Produto                                 Vlr.Unit.    Qtde           Total"

              @ prow()+1,0 say replicate("-",136)
           endif

           if asFAT[nCONT,5] == "S"
              nUF_VALOR += (asFAT[nCONT,3])
              nTOT_GER  += (asFAT[nCONT,3])
           else
              nUF_VALOR -= asFAT[nCONT,3]
              nTOT_GER  -= asFAT[nCONT,3]
           endif

           @ prow()+1, 00  say asFAT[nCONT,1]                         //Data de Emissao
           @ prow()  , 15  say asFAT[nCONT,6]                         //Pedido
           @ prow()  , 23  say asFAT[nCONT,2]                         //Razao do Cliente

           ITEN_FAT->(Dbsetorder(2))
           ITEN_FAT->(Dbgotop())
           if ITEN_FAT->(DbSeek(asFAT[nCONT,6]))
              PROD->(Dbsetorder(4))
              PROD->(Dbseek(ITEN_FAT->Cod_prod))
              @ prow()  , 61  say left(PROD->Descricao,35)
              @ prow()  , 100  say transform(ITEN_FAT->Vl_unitar,"@E 999,999.99")
              @ prow()  , 114 say transform(ITEN_FAT->Quantidade,"@R 9999")
              @ prow()  , 124 say transform(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,"@E 999,999.99")
              ITEN_FAT->(Dbskip())

              if ITEN_FAT->Num_fat == asFAT[nCONT,6]
                 do while ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == asFAT[nCONT,6]
                    lFIRST := .F.
                    PROD->(Dbsetorder(4))
                    PROD->(Dbseek(ITEN_FAT->Cod_prod))

                    @ prow()+1, 61  say left(PROD->Descricao,35)
                    @ prow()  , 100  say transform(ITEN_FAT->Vl_unitar,"@E 999,999.99")
                    @ prow()  , 114 say transform(ITEN_FAT->Quantidade,"@R 9999")
                    @ prow()  , 124 say transform(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,"@E 999,999.99")
                    ITEN_FAT->(Dbskip())
                 enddo
              endif
           endif

           if ! lFIRST
              @ prow()+1 , 95   say "Total do Pedido.:"
              @ prow()   , 124  say transf(asFAT[nCONT,3],"@E 999,999.99") //Valor da Nota
              @ prow()   , 00   say ""

           endif



           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

          if alltrim(asFAT[nCONT,4]) != alltrim(zTIPO)
              REPRES->(dbseek(zTIPO))
              @ prow()+2  ,00 say "TOTAIS DA OPERACAO....: " +qabrev(zTIPO,"12345678", {"Venda","Bonificacao","Doacao","Troca","Emprestimo","Amostra","Devolucao de Venda","Devolucao de Emprestimo"})
              @ prow()    , 122 say transf(nUF_VALOR,"@E 9,999,999.99")
              @ prow()+1,00 say replicate("-",136)
              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
          endif

         zTIPO := asFAT[nCONT,4]

       enddo

       @ prow()+2  ,00  say "TOTAIS DA OPERACAO....: " +qabrev(zTIPO,"12345678", {"Venda","Bonificacao","Doacao","Troca","Emprestimo","Amostra","Devolucao de Venda","Devolucao de Emprestimo"})
       @ prow()    ,120 say transf(nUF_VALOR,"@E 9,999,999.99")


       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1,00 say replicate("-",136)
       @ prow()  ,35 say "TOTAL GERAL...:"
       @ prow()  ,120 say transf(nTOT_GER,"@E 9,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return


static function i_impre_xls
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
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
    local nREP_COM := 0
    local nCOM_ITEM := 0
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())//  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))

      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif

      if ! FAT->No_nf
         FAT->(Dbskip())
         loop
      endif

      if ! empty(cCLI)
         if FAT->Cod_cli != cCLI
            FAT->(Dbskip())
            loop
         endif
      endif



      qgirabarra()

      qmensa("Aguarde... Processando ...")

      if FAT->Dt_emissao < dINI .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      nREP_COM := 0

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          nDESC += ITEN_FAT->Vlr_desc * ITEN_FAT->Quantidade
          nREP_COM += ((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Comi_repre/100))
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if CONFIG->Modelo_fat == "1"
         nDESC := nDESC
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif
      if !empty(cTIPO) .and. FAT->Tipo <> cTIPO .and. cTIPO != "9"
         //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,,CGM->Estado,FAT->Cod_repres,CLI1->Comis_repr})
      else
          aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CLI1->Cod_repres,nREP_COM,FAT->Es,FAT->Codigo})
      endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      FAT->(dbskip())

   enddo

   //classifica a matriz por vendedor + data vencimento
   asFAT := asort(aFAT,,,{|x,y| x[6] + x[3] + x[5] < y[6] + y[3] + y[5] })
   if lTEM
       zVEND  := asFAT[1,6]
       nCONT := 1
       do while  nCONT <= len(asFAT)


           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO
              @ prow()+1,0 say "Data Emissao"+chr(9)+"Ped."+chr(9)+"Cliente"+chr(9)+"Total"+chr(9)+"Nota Fiscal"+chr(9)+"Vlr Comissao"

              @ prow()+1,0 say ""
           endif

           if asFAT[nCONT,8] == "S"
              nUF_VALOR += (asFAT[nCONT,4])
              nTOT_GER  += (asFAT[nCONT,4])
           else
              nUF_VALOR -= asFAT[nCONT,4]
              nTOT_GER  -= asFAT[nCONT,4]
           endif

           @ prow()+1, 00  say asFAT[nCONT,1]                         //Data de Emissao
           @ prow()  , pcol()  say chr(9)+asFAT[nCONT,2]                         //Codigo do Cliente
           @ prow()  , pcol()  say chr(9)+asFAT[nCONT,6]                         //Razao do Cliente
           @ prow()  , pcol()  say chr(9)+transf(asFAT[nCONT,4],"@E 9,999,999.99") //Valor da Nota

           @ prow()  , pcol()  say chr(9)+asFAT[nCONT,5]                         //Numero da Nota

           if asFAT[nCONT,8] == "S"
             // @ prow()  ,106  say chr(9)+transf(asFAT[nCONT,7],"@E 99.9") //Comissao
              @ prow()  ,pcol()  say chr(9)+transf(asFAT[nCONT,7],"@E 999,999.99") //Comissao
              nCOMISS  += ( asFAT[nCONT,7] )
              nTOT_COM += ( asFAT[nCONT,7])

           else
              @ prow()  ,pcol()  say chr(9)+transf(asFAT[nCONT,7],"@E 999,999.99") //Comissao
              @ prow()  ,pcol()  say chr(9)+"Devolucao" //Comissao

              nCOMISS  -= ( asFAT[nCONT,7] )
              nTOT_COM -= ( asFAT[nCONT,7])


           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

          if alltrim(asFAT[nCONT,6]) != alltrim(zVEND)
              REPRES->(dbseek(zVEND))
              @ prow()+2  ,00 say chr(9)+chr(9)+"TOTAIS DO REPRESENTANTE....: "+left(REPRES->Razao,30)
              @ prow()    , pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
              @ prow()    ,pcol() say chr(9)+transf(nCOMISS,"@E 99,999.99")
              @ prow()+1,00 say ""
              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
          endif

         zVEND := asFAT[nCONT,6]

       enddo
       REPRES->(dbseek(zVEND))
       @ prow()+2  ,00 say chr(9)+chr(9)+"TOTAIS DO REPRESENTANTE...: "+left(REPRES->Razao,30)
       @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
       @ prow()    ,pcol() say chr(9)+transf(nCOMISS,"@E 99,999.99")


       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1 ,00 say chr(9)+chr(9)+"TOTAL GERAL...:"
       @ prow()  ,pcol() say chr(9)+transf(nTOT_GER,"@E 99,999,999.99")
       @ prow() ,pcol() say chr(9)+transf(nTOT_COM,"@E 99,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return

