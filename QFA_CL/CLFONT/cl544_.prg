/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS POR REPRESENTANTE/COLECAO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2006
// OBS........:
// ALTERACOES.:

function cl544
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cREPRES := space(5)
private cRAZAO := space(40)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_repres(-1,0,@cREPRES)         } , "REPRES"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B544A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cREPRES := space(5)
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

      case cCAMPO == "REPRES"

           qrsay(XNIVEL,cREPRES)

           if empty(cREPRES)
              qrsay(XNIVEL++, "Todos os Representantes.......")
              cRAZAO := "Todos os Representantes"
          //    qmensa("Campo Obrigat¢rio !!!","B")
          //    return .F.
           else
              if ! REPRES->(Dbseek(cREPRES:=strzero(val(cREPRES),5)))
                 qmensa("Represntante n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(REPRES->Razao,40))
                 cRAZAO := left(REPRES->Razao,40)
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
      i_impre_xls()
   else
      i_impre_prn()
   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nTOTAL     := 0
    local nVALOR     := 0
    local nDESC      := 0
    local cRAZ_REPRES    := ""
    local cDESC_PROD     := ""
    local cDESC_COLECAO  := ""

    local nQTD_REPRES    := 0
    local nQTD_COLECAO   := 0
    local nQTD_PROD      := 0

    local nVAL_REPRES    := 0
    local nVAL_COLECAO   := 0
    local nVAL_PROD      := 0

    local cREP           := ""
    local cCOLECAO       := ""
    local cITEM          := ""

    local nTOT_GER   := 0
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

      if ! empty(cREPRES)
         CLI1->(dbseek(FAT->Cod_cli))

         if FAT->Cod_repres != cREPRES
            FAT->(Dbskip())
            loop
         endif

      endif


      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-591-691-120-220"
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
             nVALOR := nVALOR + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100) ) )
             aadd(aFAT,{FAT->Cod_repres,left(PROD->Codigo,4),right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,left(PROD->Cod_fabr,6),left(PROD->Descricao,20),left(PROD->Marca,12),PROD->Cod_ass,nVALOR,FAT->Es})

             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   cRAZ_REPRES := ""
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3] })
   if lTEM
       cREP     := asFAT[1,1]
       cCOLECAO := asFAT[1,2]
       cITEM    := asFAT[1,3]
       REPRES->(dbseek(cREP))
       cRAZ_REPRES := left(REPRES->Razao,35)

       PROD->(dbsetorder(1))
       PROD->(dbseek(cCOLECAO))
       cDESC_COLECAO := left(PROD->Descricao,25)

       cDESC_PROD := asFAT[1,6]+" "+asFAT[1,9]+" "+asFAT[1,7]

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND0
              qpageprn()
              qcabecprn(cTITULO,80)
              @ prow()+1,0 say XCOND1 + "Produto                                                   Quantidade            Valor "
              @ prow()+1,0 say replicate("-",134)
           endif

           if asFAT[nCONT,11] == "S"  // Se for Saida soma as quantidade senao diminui
              nQTD_REPRES += asFAT[nCONT,4]
              nVAL_REPRES += asFAT[nCONT,10]
              nQTD_COLECAO += asFAT[nCONT,4]    //Quantidade * valor unitario
              nVAL_COLECAO += asFAT[nCONT,10]  //Quantidade * valor unitario
              nQTD_PROD    += asFAT[nCONT,4]    //Quantidade * valor unitario
              nVAL_PROD    += asFAT[nCONT,10]  //Quantidade * valor unitario
           else
              nQTD_REPRES -= asFAT[nCONT,4]
              nVAL_REPRES -= asFAT[nCONT,10]
              nQTD_COLECAO -= asFAT[nCONT,4]    //Quantidade * valor unitario
              nVAL_COLECAO -= asFAT[nCONT,10]  //Quantidade * valor unitario
              nQTD_PROD    -= asFAT[nCONT,4]    //Quantidade * valor unitario
              nVAL_PROD    -= asFAT[nCONT,10]  //Quantidade * valor unitario
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,3] != cITEM
              @ prow()+1,00 say cDESC_PROD
              @ prow()  ,61 say transf(nQTD_PROD,"@R 999999")
              @ prow()  ,73 say transf(nVAL_PROD,"@R 99,999,999.99")
              cITEM := asFAT[nCONT,3]
              cDESC_PROD := asFAT[nCONT,6]+" "+asFAT[nCONT,9]+" "+asFAT[nCONT,7]

              nQTD_PROD := 0
              nVAL_PROD := 0
           endif

           if asFAT[nCONT,2] != cCOLECAO
              @ prow()+1,00 say "Totais da Colecao.: "+cDESC_COLECAO
              @ prow()  ,61 say transf(nQTD_COLECAO,"@R 999999")
              @ prow()  ,73 say transf(nVAL_COLECAO,"@R 99,999,999.99")
              cCOLECAO := asFAT[nCONT,2]
              PROD->(Dbsetorder(1))
              PROD->(dbseek(cCOLECAO))
              cDESC_COLECAO := left(PROD->Descricao,25)
              @ prow()+1,00 say ""


              nQTD_COLECAO := 0
              nVAL_COLECAO := 0
           endif


           if asFAT[nCONT,1] != cREP
              @ prow()+1,00 say "Totais do Representante.: "+left(cRAZ_REPRES,35)
              @ prow()  ,61 say transf(nQTD_REPRES,"@R 999999")
              @ prow()  ,73 say transf(nVAL_REPRES,"@R 99,999,999.99")
              cREP := asFAT[nCONT,1]
              REPRES->(dbseek(cREP))
              cRAZ_REPRES := REPRES->Razao
              @ prow()+1,00 say ""

              nQTD_REPRES := 0
              nVAL_REPRES := 0
           endif
       enddo

       @ prow()+1,00 say cDESC_PROD
       @ prow()  ,61 say transf(nQTD_PROD,"@R 999999")
       @ prow()  ,73 say transf(nVAL_PROD,"@R 99,999,999.99")
       nQTD_PROD := 0
       nVAL_PROD := 0


       @ prow()+1,00 say "Totais da Colecao.: "+cDESC_COLECAO
       @ prow()  ,61 say transf(nQTD_COLECAO,"@R 999999")
       @ prow()  ,73 say transf(nVAL_COLECAO,"@R 99,999,999.99")
       nQTD_COLECAO := 0
       nVAL_COLECAO := 0


       REPRES->(dbseek(cREP))
       cRAZ_REPRES := REPRES->Razao

       @ prow()+1,00 say "Totais do Representante.: "+left(cRAZ_REPRES,35)
       @ prow()  ,61 say transf(nQTD_REPRES,"@R 999999")
       @ prow()  ,73 say transf(nVAL_REPRES,"@R 99,999,999.99")
       nQTD_REPRES := 0
       nTOT_REPRES := 0

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO EM EXCEL__________________

static function i_impre_xls
    local nTOTAL     := 0
    local nVALOR     := 0
    local nDESC      := 0
    local cRAZ_REPRES    := ""
    local cDESC_PROD     := ""
    local cDESC_COLECAO  := ""

    local nQTD_REPRES    := 0
    local nQTD_COLECAO   := 0
    local nQTD_PROD      := 0

    local nVAL_REPRES    := 0
    local nVAL_COLECAO   := 0
    local nVAL_PROD      := 0

    local cREP           := ""
    local cCOLECAO       := ""
    local cITEM          := ""

    local nTOT_GER   := 0
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

      if ! empty(cREPRES)
         CLI1->(dbseek(FAT->Cod_cli))

         if FAT->Cod_repres != cREPRES
            FAT->(Dbskip())
            loop
         endif

      endif


         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100) ) )
             aadd(aFAT,{FAT->Cod_repres,left(PROD->Codigo,4),right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,left(PROD->Cod_fabr,6),left(PROD->Descricao,20),left(PROD->Marca,12),PROD->Cod_ass,nVALOR,FAT->Es})

             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   cRAZ_REPRES := ""
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3] })
   if lTEM
       cREP     := asFAT[1,1]
       cCOLECAO := asFAT[1,2]
       cITEM    := asFAT[1,3]
       REPRES->(dbseek(cREP))
       cRAZ_REPRES := left(REPRES->Razao,35)

       PROD->(dbsetorder(1))
       PROD->(dbseek(cCOLECAO))
       cDESC_COLECAO := left(PROD->Descricao,25)

       cDESC_PROD := asFAT[1,6]+chr(9)+asFAT[1,9]+chr(9)+asFAT[1,7]

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO
              @ prow()+1,0 say "Cod. Fabr"+chr(9)+"Cod. ass."+chr(9)+"Descricao"+chr(9)+"Quantidade"+chr(9)+"Valor"
           endif

           if asFAT[nCONT,11] == "S"  // Se for Saida soma as quantidade senao diminui
              nQTD_REPRES += asFAT[nCONT,4]
              nVAL_REPRES += asFAT[nCONT,10]
              nQTD_COLECAO += asFAT[nCONT,4]    //Quantidade * valor unitario
              nVAL_COLECAO += asFAT[nCONT,10]  //Quantidade * valor unitario
              nQTD_PROD    += asFAT[nCONT,4]    //Quantidade * valor unitario
              nVAL_PROD    += asFAT[nCONT,10]  //Quantidade * valor unitario
           else
              nQTD_REPRES -= asFAT[nCONT,4]
              nVAL_REPRES -= asFAT[nCONT,10]
              nQTD_COLECAO -= asFAT[nCONT,4]    //Quantidade * valor unitario
              nVAL_COLECAO -= asFAT[nCONT,10]  //Quantidade * valor unitario
              nQTD_PROD    -= asFAT[nCONT,4]    //Quantidade * valor unitario
              nVAL_PROD    -= asFAT[nCONT,10]  //Quantidade * valor unitario
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,3] != cITEM
              @ prow()+1,00 say cDESC_PROD
              @ prow()  ,pcol() say chr(9)+transf(nQTD_PROD,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nVAL_PROD,"@R 99,999,999.99")
              cITEM := asFAT[nCONT,3]
              cDESC_PROD := asFAT[nCONT,6]+chr(9)+asFAT[nCONT,9]+chr(9)+asFAT[nCONT,7]

              nQTD_PROD := 0
              nVAL_PROD := 0
           endif

           if asFAT[nCONT,2] != cCOLECAO
              @ prow()+1,00 say chr(9)+chr(9)+cDESC_COLECAO
              @ prow()  ,pcol() say chr(9)+transf(nQTD_COLECAO,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nVAL_COLECAO,"@R 99,999,999.99")
              cCOLECAO := asFAT[nCONT,2]
              PROD->(Dbsetorder(1))
              PROD->(dbseek(cCOLECAO))
              cDESC_COLECAO := left(PROD->Descricao,25)
              @ prow()+1,00 say ""


              nQTD_COLECAO := 0
              nVAL_COLECAO := 0
           endif


           if asFAT[nCONT,1] != cREP
              @ prow()+1,00 say chr(9)+chr(9)+"Totais do Representante.: "+left(cRAZ_REPRES,35)
              @ prow()  ,pcol() say chr(9)+transf(nQTD_REPRES,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nVAL_REPRES,"@R 99,999,999.99")
              cREP := asFAT[nCONT,1]
              REPRES->(dbseek(cREP))
              cRAZ_REPRES := REPRES->Razao
              @ prow()+1,00 say ""

              nQTD_REPRES := 0
              nVAL_REPRES := 0
           endif
       enddo

       @ prow()+1,00 say cDESC_PROD
       @ prow()  ,pcol() say chr(9)+transf(nQTD_PROD,"@R 999999")
       @ prow()  ,pcol() say chr(9)+transf(nVAL_PROD,"@R 99,999,999.99")
       nQTD_PROD := 0
       nVAL_PROD := 0


       @ prow()+1,00 say chr(9)+chr(9)+cDESC_COLECAO
       @ prow()  ,pcol() say chr(9)+transf(nQTD_COLECAO,"@R 999999")
       @ prow()  ,pcol() say chr(9)+transf(nVAL_COLECAO,"@R 99,999,999.99")
       nQTD_COLECAO := 0
       nVAL_COLECAO := 0


       REPRES->(dbseek(cREP))
       cRAZ_REPRES := REPRES->Razao

       @ prow()+1,00 say chr(9)+chr(9)+"Totais do Representante.: "+left(cRAZ_REPRES,35)
       @ prow()  ,pcol() say chr(9)+transf(nQTD_REPRES,"@R 999999")
       @ prow()  ,pcol() say chr(9)+transf(nVAL_REPRES,"@R 99,999,999.99")
       nQTD_REPRES := 0
       nTOT_REPRES := 0

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return



