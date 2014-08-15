/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl566
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||((XNIVEL==1 .and. !XFLAG) .or. empty(dINI)) .or. lastkey() == 27 }

private cTITULO  := ""                 // titulo do relatorio
private cTITULO2 := ""                  // titulo do relatorio
private dINI
private dFIM
private cCLI  := space(5)
private cTIPO := space(1)
private cRAZAO := space(40)
private sBLOC1  := qlbloc("B566B","QBLOC.GLO")
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aProdZerados := {}
private azFAT := {}

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_Cli(-1,0,@cCLI)         } , "CLIENTE"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOC1)    } , "TIPO"  })


do while .T.

   qlbloc(5,0,"B566A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := ctod("01/03/2005")
   dFIM := date()
   cCLI := space(5)
   cTIPO := ""
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

      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"123",{"Consignacao","Demonstracao","Conserto"}))
           cTITULO2 := qabrev(cTIPO,"123",{"Consignacao","Demonstracao","Conserto"})


      case cCAMPO == "CLIENTE"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL+1, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cCLI:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CLI1->Razao,40))
                 cRAZAO := left(CLI1->Razao,40)
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   if empty(cCLI)
      cTITULO := "Relatorio de Saldos de " + dtoc(dINI) + " a " + dtoc(dFIM)
   else
      cTITULO := "Relatorio de Saldos de " + dtoc(dINI) + " a " + dtoc(dFIM)
      cTITULO2 := cRAZAO+" - " + cTITULO2

   endif

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
      i_impre_xls()
   else
      i_impre_prn()
   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nCONT      := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local zPROD := space(50)
    local cCONSIGN := ""
    local cCONSERT := ""
    local cDEMONST := ""
    local cCFOP    := ""
    local zCLI     := ""
    local nSAIDA     := 0
    local nTT_SAIDA  := 0
    local nCLI_SAIDA := 0
    local nVALOR     := 0

    local nENTRADA     := 0
    local nTT_ENTRADA  := 0
    local nCLI_ENTRADA := 0

    local nCli_ValorSaida    := 0
    local nCli_ValorEntrada  := 0

    local nTT_ValorSaida    := 0
    local nTT_ValorEntrada  := 0



    cCONSIGN := "5917-6917-1918-2918"
    cCONSERT := "5915-6915-1916-2916"
    cDEMOSNT := "5912-6912-1913-2913"

    if cTIPO == "1"
       cCFOP := cCONSIGN
    elseif cTIPO == "2"
       cCFOP := cDEMOSNT
    elseif cTIPO == "3"
       cCFOP := cCONSERT
    endif




   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,4) $ cCFOP
         FAT->(Dbskip())
         loop
      endif

      if ! empty(cCLI)
         if FAT->Cod_cli != cCLI
            FAT->(dbskip())
            loop
         endif
      endif


      qgirabarra()

      qmensa("Aguarde... Processando ... " + CLI1->Razao)

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             nVALOR := nVALOR + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100) ) )

             if FAT->Es == "S"
                aadd(aFAT,{FAT->Cod_cli,ITEN_FAT->Cod_prod,ITEN_FAT->Vl_unitar,ITEN_FAT->Quantidade,0,dtos(FAT->Dt_emissao),FAT->Num_fatura,left(FAT->Cod_cfop,4)})
             else
                aadd(aFAT,{FAT->Cod_cli,ITEN_FAT->Cod_prod,ITEN_FAT->Vl_unitar,0,ITEN_FAT->Quantidade,dtos(FAT->Dt_emissao),FAT->Num_fatura,left(FAT->Cod_cfop,4)})
             endif
             ITEN_FAT->(Dbskip())

             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] < y[1] + y[2] })

   procuraSaldosZerados(asFAT)
   eliminaZerados(asFAT)

   if len(azFAT) > 0
      lTEM := .T.
   else
      lTEM := .F.
   endif


   PROD->(dbsetorder(4))

   if lTEM
       cPROD := azFAT[1,2]
       zCLI  := azFAT[1,1]

       CLI1->(dbseek(zCLI))
       zRAZAO := CLI1->Razao

       nCONT := 1
       do while  nCONT <= len(azFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,134,,cTITULO2)
              @ prow()+1,0 say "Produto                                    Data Emissao  CFOP No. NF.                             Saida     Entrada            Saldo "
              @ prow()+1,0 say replicate("-",134)
           endif


           PROD->(dbseek(azFAT[nCONT,2]))
           @ prow()+1,00 say PROD->Cod_ass + " "+ left(PROD->Cod_fabr,6) +" "+ left(PROD->Descricao,25) + "   "+ dtoc(stod(azFAT[nCONT,6]))+"    "+azFAT[nCONT,8]+" "+ azFAT[nCONT,7]

           if azFAT[nCONT,4] > 0
              @ prow()  ,91 say transf(azFAT[nCONT,4] ,"@R 999999")
           endif

           if azFAT[nCONT,5] > 0
              @ prow()  ,103 say transf(azFAT[nCONT,5] ,"@R 999999")
           endif



           nSAIDA       += azFAT[nCONT,4]
           nENTRADA     += azFAT[nCONT,5]
           nCLI_SAIDA   += azFAT[nCONT,4]
           nCLI_ENTRADA += azFAT[nCONT,5]
           nTT_SAIDA    += azFAT[nCONT,4]
           nTT_ENTRADA  += azFAT[nCONT,5]

           nCli_ValorSaida    += ( azFat[nCont,3] * azFat[nCont,4] )
           nCli_ValorEntrada  += ( azFat[nCont,3] * azFat[nCont,5] )


           nTT_ValorSaida    += ( azFat[nCont,3] * azFat[nCont,4] )
           nTT_ValorEntrada  += ( azFat[nCont,3] * azFat[nCont,5] )


           qmensa("Produto.: "+azFAT[nCONT,2])



           nCONT++
           if nCONT > len(azFAT)
              nCONT := len(azFAT)
              exit
           endif

           if azFAT[nCONT,2] != alltrim(cPROD)
              PROD->(dbseek(cPROD))
              zPROD := PROD->Cod_ass + " "+ left(PROD->Cod_fabr,6) +" "+ left(PROD->Descricao,25)

              @ prow()+1,00 say "TOTAL..: "+ zPROD
              @ prow()  ,91 say transf(nSAIDA  ,"@R 999999")
              @ prow()  ,103 say transf(nENTRADA,"@R 999999")
              @ prow()  ,120 say transf(nSAIDA - nENTRADA,"@R 999999")

              cPROD := azFAT[nCONT,2]


              @ prow()+1,00 say ""

              nSAIDA   := 0
              nENTRADA := 0
           endif



           if azFAT[nCONT,1] != zCLI
              CLI1->(dbseek(zCLI))
              zRAZAO := CLI1->Razao

              @ prow()+1,00 say replicate("-",134)
              @ prow()+1,00 say "TOTAL..: "+left(zRAZAO,50)
              @ prow()  ,91 say transf(nCLI_SAIDA  ,"@R 999999")
              @ prow()  ,103 say transf(nCLI_ENTRADA,"@R 999999")
              @ prow()  ,120 say transf(nCLI_SAIDA - nCLI_ENTRADA,"@R 999999")
              zCLI   := azFAT[nCONT,1]

              @ prow()+2,00 say ""

              nCLI_SAIDA   := 0
              nCLI_ENTRADA := 0
           endif





       enddo

       //if azFAT[nCONT,2] != alltrim(cPROD)
          @ prow()+1,00 say "TOTAL.: "+zPROD
          @ prow()  ,91 say transf(nSAIDA  ,"@R 999999")
          @ prow()  ,103 say transf(nENTRADA,"@R 999999")
          @ prow()  ,120 say transf(nSAIDA - nENTRADA,"@R 999999")
          PROD->(dbseek(cPROD))
          zPROD := PROD->Cod_ass + " "+ left(PROD->Cod_fabr,6) +" "+ left(PROD->Descricao,25)+ " " + left(PROD->Marca,20)
      //    cPROD := azFAT[nCONT,2]

          @ prow()+1,00 say ""


          nSAIDA   := 0
          nENTRADA := 0
     //  endif

      // if azFAT[nCONT,1] != zCLI
          @ prow()+1,00 say replicate("-",134)
          @ prow()+1,00 say zRAZAO
          @ prow()  ,91 say transf(nCLI_SAIDA  ,"@R 999999")
          @ prow()  ,103 say transf(nCLI_ENTRADA,"@R 999999")
          @ prow()  ,120 say transf(nCLI_SAIDA - nCLI_ENTRADA,"@R 999999")
          @ prow()+2,00 say ""
          CLI1->(dbseek(zCLI))
          zRAZAO := CLI1->Razao
      //    zCLI   := azFAT[nCONT,1]

          nCLI_SAIDA   := 0
          nCLI_ENTRADA := 0
      // endif


       @ prow()+2,90 say transf(nTT_SAIDA,"@R 999999")
       @ prow()  ,103 say transf(nTT_ENTRADA,"@R 999999")
       @ prow()  ,120 say transf(nTT_SAIDA - nTT_ENTRADA,"@R 999999")


       nSAIDA       := 0
       nENTRADA     := 0
       nCLI_SAIDA   := 0
       nCLI_ENTRADA := 0
       nTT_SAIDA    := 0
       nTT_ENTRADA  := 0

   endif
   aFAT := {}
   asFAT:= {}
   azFAT:= {}

   aProdZerados := {}

   qstopprn()

return


static function i_impre_xls
    local nCONT      := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local zPROD := space(50)
    local cCONSIGN := ""
    local cCONSERT := ""
    local cDEMONST := ""
    local cCFOP    := ""
    local zCLI     := ""
    local nSAIDA     := 0
    local nTT_SAIDA  := 0
    local nCLI_SAIDA := 0
    local nVALOR     := 0
    local nCli_ValorSaida    := 0
    local nCli_ValorEntrada  := 0

    local nTT_ValorSaida    := 0
    local nTT_ValorEntrada  := 0


    local nENTRADA     := 0
    local nTT_ENTRADA  := 0
    local nCLI_ENTRADA := 0

    local aCli := {}


    cCONSIGN := "5917-6917-1918-2918"
    cCONSERT := "5915-6915-5949-6949-1916-2916-1949-2949"
    cDEMOSNT := "5912-6912-1913-2913"

    if cTIPO == "1"
       cCFOP := cCONSIGN
    elseif cTIPO == "2"
       cCFOP := cDEMOSNT
    elseif cTIPO == "3"
       cCFOP := cCONSERT
    endif

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,4) $ cCFOP
         FAT->(Dbskip())
         loop
      endif

      if ! empty(cCLI)
         if FAT->Cod_cli != cCLI
            FAT->(dbskip())
            loop
         endif
      endif


      qgirabarra()

      qmensa("Aguarde... Processando ... " + CLI1->Razao)

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             nVALOR := nVALOR + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100) ) )

             if FAT->Es == "S"
                aadd(aFAT,{FAT->Cod_cli,ITEN_FAT->Cod_prod,ITEN_FAT->Vl_unitar,ITEN_FAT->Quantidade,0,dtos(FAT->Dt_emissao),FAT->Num_fatura,left(FAT->Cod_cfop,4)})
             else
                aadd(aFAT,{FAT->Cod_cli,ITEN_FAT->Cod_prod,ITEN_FAT->Vl_unitar,0,ITEN_FAT->Quantidade,dtos(FAT->Dt_emissao),FAT->Num_fatura,left(FAT->Cod_cfop,4)})
             endif
             ITEN_FAT->(Dbskip())

             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo


   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2]+x[6] < y[1] + y[2]+y[6] })
   aFAT := {}

   procuraSaldosZerados(asFAT)
   eliminaZerados(asFAT)

   if len(azFAT) > 0
      lTEM := .T.
   else
      lTEM := .F.
   endif


   if lTEM
       cPROD := azFAT[1,2]
       zCLI  := azFAT[1,1]

       CLI1->(dbseek(zCLI))
       zRAZAO := CLI1->Razao

       PROD->(Dbsetorder(4))
       PROD->(dbseek(cPROD))
       zPROD := PROD->Cod_ass + " "+ left(PROD->Cod_fabr,6) +" "+ left(PROD->Descricao,25)

       nCONT := 1
       do while  nCONT <= len(azFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              @prow()+1,0 say ""
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO+"  566"
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO2
              @ prow()+1,0 say "Ref1" +chr(9)+"Ref2"+chr(9)+"Produto"+chr(9)+"Data Emissao"+chr(9)+"CFOP"+chr(9)+"No. NF."+chr(9)+"Saida"+chr(9)+"Entrada"+chr(9)+"Saldo"+chr(9)+"Valor Unitario"
              @ prow()+1,0 say ""
           endif


           PROD->(dbseek(azFAT[nCONT,2]))
           @ prow()+1,00 say PROD->Cod_ass+chr(9)+left(PROD->Cod_fabr,6)+chr(9)+left(PROD->Descricao,25) + chr(9)+ dtoc(stod(azFAT[nCONT,6]))+chr(9)+azFAT[nCONT,8]+chr(9)+ azFAT[nCONT,7]

           if azFAT[nCONT,4] > 0
              @ prow()  ,pcol() say chr(9)+transf(azFAT[nCONT,4] ,"@R 999999")
           endif

           if azFAT[nCONT,5] > 0
              @ prow()  ,pcol() say chr(9)+chr(9)+transf(azFAT[nCONT,5] ,"@R 999999")
           endif


           nSAIDA       += azFAT[nCONT,4]
           nENTRADA     += azFAT[nCONT,5]
           nCLI_SAIDA   += azFAT[nCONT,4]
           nCLI_ENTRADA += azFAT[nCONT,5]

           nCLI_ValorSaida    += ( azFat[nCont,3] * azFat[nCont,4] )
           nCLI_ValorEntrada  += ( azFat[nCont,3] * azFat[nCont,5] )

           nTT_SAIDA    += azFAT[nCONT,4]
           nTT_ENTRADA  += azFAT[nCONT,5]

           nTT_ValorSaida    += ( azFat[nCont,3] * azFat[nCont,4] )
           nTT_ValorEntrada  += ( azFat[nCont,3] * azFat[nCont,5] )




           qmensa("Produto.: "+azFAT[nCONT,2])



           nCONT++
           if nCONT > len(azFAT)
              nCONT := len(azFAT)
              exit
           endif

           if azFAT[nCONT,2] != alltrim(cPROD)
              PROD->(dbseek(cPROD))
              zPROD := PROD->Cod_ass + chr(9)+ left(PROD->Cod_fabr,6) +chr(9)+ left(PROD->Descricao,25)

              @ prow()+1,00 say zPROD
              @ prow()  ,pcol() say chr(9)+chr(9)+chr(9)+chr(9)+transf(nSAIDA  ,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nENTRADA,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nSAIDA - nENTRADA,"@R 999999")
              cPROD := azFAT[nCONT,2]

              @ prow()+1,00 say ""

              nSAIDA   := 0
              nENTRADA := 0
           endif

           if azFAT[nCONT,1] != zCLI

              CLI1->(dbseek(zCLI))
              zRAZAO := CLI1->Razao

              @ prow()+1,00 say chr(9)+chr(9)+left(zRAZAO,50)+chr(9)+chr(9)+chr(9)
              @ prow()  ,pcol() say chr(9)+transf(nCLI_SAIDA  ,"@R 999999")
              @ prow()  ,pcol() say chr(9)+ transf(nCLI_ENTRADA,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nCLI_SAIDA - nCLI_ENTRADA,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf( (nCLI_ValorSAida - nCLI_ValorEntrada) / (nCLI_SAIDA - nCLI_ENTRADA),"@E 99,999,999.99")
              @ prow()  ,pcol() say chr(9)+transf(nCLI_ValorSAida - nCLI_ValorEntrada,"@E 99,999,999.99")
              zCLI   := azFAT[nCONT,1]
              aadd(aCli,{left(zRazao,50),nCLI_SAIDA,nCLI_Entrada,nCLI_SAIDA - nCLI_ENTRADA,(nCLI_ValorSAida - nCLI_ValorEntrada) / (nCLI_SAIDA - nCLI_ENTRADA),nCLI_ValorSAida - nCLI_ValorEntrada})

              @ prow()+2,00 say ""


              nCLI_SAIDA        := 0
              nCLI_ENTRADA      := 0
              nCli_ValorSaida   := 0
              nCli_ValorEntrada := 0
           endif




       enddo

       if azFAT[nCONT,2] != alltrim(cPROD)
          PROD->(dbseek(cPROD))
          zPROD := PROD->Cod_ass + chr(9)+ left(PROD->Cod_fabr,6) +chr(9)+ left(PROD->Descricao,25)

          @ prow()+1,00 say zPROD
          @ prow()  ,pcol() say chr(9)+chr(9)+chr(9)+chr(9)+transf(nSAIDA  ,"@R 999999")
          @ prow()  ,pcol() say chr(9)+transf(nENTRADA,"@R 999999")
          @ prow()  ,pcol() say chr(9)+transf(nSAIDA - nENTRADA,"@R 999999")
          cPROD := azFAT[nCONT,2]

          @ prow()+1,00 say ""

          nSAIDA   := 0
          nENTRADA := 0
       endif

       if azFAT[nCONT,1] != zCLI
          CLI1->(dbseek(zCLI))
          zRAZAO := CLI1->Razao

          @ prow()+1,00 say chr(9)+chr(9)+left(zRAZAO,50)+chr(9)+chr(9)+chr(9)
          @ prow()  ,pcol() say chr(9)+transf(nCLI_SAIDA  ,"@R 999999")
          @ prow()  ,pcol() say chr(9)+ transf(nCLI_ENTRADA,"@R 999999")
          @ prow()  ,pcol() say chr(9)+transf(nCLI_SAIDA - nCLI_ENTRADA,"@R 999999")
          @ prow()  ,pcol() say chr(9)+transf( (nCLI_ValorSAida - nCLI_ValorEntrada) / (nCLI_SAIDA - nCLI_ENTRADA),"@E 99,999,999.99")
          @ prow()  ,pcol() say chr(9)+transf(nCLI_ValorSAida - nCLI_ValorEntrada,"@E 99,999,999.99")

          zCLI   := azFAT[nCONT,1]
          aadd(aCli,{left(zRazao,50),nCLI_SAIDA,nCLI_Entrada,nCLI_SAIDA - nCLI_ENTRADA,(nCLI_ValorSAida - nCLI_ValorEntrada) / (nCLI_SAIDA - nCLI_ENTRADA),nCLI_ValorSAida - nCLI_ValorEntrada})

          @ prow()+2,00 say ""


          nCLI_SAIDA   := 0
          nCLI_ENTRADA := 0
          nCli_ValorSaida := 0
          nCli_ValorEntrada := 0
       endif

       @ prow()+2,00  say chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+transf(nTT_SAIDA,"@R 999999")
       @ prow()  ,pcol() say chr(9)+transf(nTT_ENTRADA,"@R 999999")
       @ prow()  ,pcol() say chr(9)+transf(nTT_SAIDA - nTT_ENTRADA,"@R 999999")


       nSAIDA       := 0
       nENTRADA     := 0
       nCLI_SAIDA   := 0
       nCLI_ENTRADA := 0
       nTT_SAIDA    := 0
       nTT_ENTRADA  := 0

       @ prow()+2,00 say chr(9)+Chr(9)+"Resumo por Cliente"
       @ prow()+2,00 say chr(9)+Chr(9)+"Cliente"+chr(9)+"Saida"+chr(9)+"Entrada"+chr(9)+"Saldo"+Chr(9)+"Vlr Medio"+chr(9)+"Valor Total"

       nTotal := 0

       for nCONT := 1 to len(aCLi)
           @ prow()+1 ,00     say chr(9)+chr(9)+aCli[nCont,1]
           @ prow()   ,pcol() say chr(9)+transf(aCli[nCont,2],"@R 999999")
           @ prow()   ,pcol() say chr(9)+transf(aCli[nCont,3],"@R 999999")
           @ prow()   ,pcol() say chr(9)+transf(aCli[nCont,4],"@R 999999")
           @ prow()   ,pcol() say chr(9)+transf(aCli[nCont,5],"@E 999,999.99")
           @ prow()   ,pcol() say chr(9)+transf(aCli[nCont,6],"@E 999,999.99")
           nTotal += aCli[nCOnt,6]
       next

       @ prow()+1 ,00 say chr(9)+chr(9)+"Total..:"+chr(9)+Chr(9)+Chr(9)+Chr(9)+chr(9)+transf(nTotal,"@E 999,999.99")

   endif

   qstopprn(.F.)

return

static function procuraSaldosZerados(arrayFaturas)
  local aRet := {}
  local cPROD := ""
  local zCLI  := ""
  local nCONT := 0
  local nSAIDA       := 0
  local nENTRADA     := 0
  local nCLI_SAIDA   := 0
  local nCLI_ENTRADA := 0
  local nTT_SAIDA    := 0
  local nTT_ENTRADA  := 0
  local lTEM := .F.

  if len(arrayFaturas) > 0
     lTem := .T.
  endif


   if lTEM
       cPROD := arrayFaturas[1,2]
       zCLI  := arrayFaturas[1,1]

       CLI1->(dbseek(zCLI))

       nCONT := 1
       do while  nCONT <= len(arrayFaturas)

           nSAIDA       += arrayFaturas[nCONT,4]
           nENTRADA     += arrayFaturas[nCONT,5]
           nCLI_SAIDA   += arrayFaturas[nCONT,4]
           nCLI_ENTRADA += arrayFaturas[nCONT,5]
           nTT_SAIDA    += arrayFaturas[nCONT,4]
           nTT_ENTRADA  += arrayFaturas[nCONT,5]

           nCONT++
           if nCONT > len(arrayFaturas)
              nCONT := len(arrayFaturas)
              exit
           endif

           if arrayFaturas[nCONT,1] + arrayFaturas[nCONT,2] != alltrim(zCLI)+alltrim(cPROD)
              if(nSaida-nEntrada) == 0
                 putProdZerado(zCLI,cPROD)
              endif
              cPROD := arrayFaturas[nCONT,2]
              nSAIDA   := 0
              nENTRADA := 0
           endif

           if arrayFaturas[nCONT,1] != zCLI
              zCLI   := arrayFaturas[nCONT,1]
           endif

       enddo

       if arrayFaturas[nCONT,1] + arrayFaturas[nCONT,2] != alltrim(zCLI)+alltrim(cPROD)
          if(nSaida-nEntrada) == 0
             putProdZerado(zCLI,cPROD)
          endif
          cPROD := arrayFaturas[nCONT,2]
          nSAIDA   := 0
          nENTRADA := 0
       endif

       if arrayFaturas[nCONT,1] != zCLI
          zCLI   := arrayFaturas[nCONT,1]
       endif

       nSAIDA       := 0
       nENTRADA     := 0
       nCLI_SAIDA   := 0
       nCLI_ENTRADA := 0
       nTT_SAIDA    := 0
       nTT_ENTRADA  := 0

   endif

return 

static function putProdZerado(cCLI,cPROD)
   aadd(aProdZerados,cCLI+cPROD)
return


static function putCliZerado(cCLI)

return

static function eliminaZerados(arFat)
  local  nCONT := 1

  azFAT := {}


       do while  nCONT <= len(arFat)

           if(aScan(aProdZerados,arFat[nCont,1]+arFat[nCont,2])) == 0
             aadd(azFAT,{arFAT[nCONT,1],arFAT[nCONT,2],arFAT[nCONT,3],arFAT[nCONT,4],arFAT[nCONT,5],arFAT[nCONT,6],arFAT[nCONT,7],arFAT[nCONT,8]})
           endif

           nCONT++
           if nCONT > len(arFat)
              nCONT := len(arFat)
              exit
           endif

       enddo

       aFAT  := {}
       asFAT := {}

return

static function printaProd()

  local  nCONT := 1

  arFAt := aProdZerados

        @ prow()+4,10 say ""

       do while  nCONT <= len(arFat)

           @ prow()+1,10 say arFat[nCONT]

           nCONT++
           if nCONT > len(arFat)
              nCONT := len(arFat)
              exit
           endif

       enddo

       aFAT  := {}
       asFAT := {}

return
