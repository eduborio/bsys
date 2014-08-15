//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: abril DE 2007
// OBS........:
// ALTERACOES.:

function cl563
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cSETOR)     } , "SETOR"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B563A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")

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

      case cCAMPO == "SETOR"

           qrsay(XNIVEL,cSETOR)
           PROD->(Dbsetorder(4))
           if empty(cSETOR)
              qrsay(XNIVEL++, "Todos os Produtos.....")
           else
              if ! PROD->(Dbseek(cSETOR:=strzero(val(cSETOR),5)))
                 qmensa("Produto n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,PROD->Cod_ass+" / "+left(PROD->Cod_fabr,6)+" "+left(PROD->Descricao,20) + left(PROD->Marca,10))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PRODUTOS FATURADOS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

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
    local nTOTAL_ENT := 0
    local nVALOR     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nQUANT_ENT := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lTEM       :=.T.
    local nQTDE      := 0
    local nVENDA     := 0
    local nCUSTO     := 0
    local nTT_QTDE   := 0
    local nTT_VENDA  := 0
    local nTT_CUSTO  := 0




    local zPROD := space(50)
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

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-640"
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

             if ! empty(cSETOR) .and. ITEN_FAT->Cod_prod != cSETOR
                ITEN_FAT->(Dbskip())
                loop
             endif

             if FAT->Es == "S"
                aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,ITEN_FAT->Preco_cust,FAT->Codigo,FAT->Es,dtos(FAT->Dt_emissao),ITEN_FAT->Preco_vend,ITEN_FAT->Desc_prod,ITEN_FAT->Vlr_desc})
             endif

             ITEN_FAT->(Dbskip())
             lTEM := .T.
         enddo
         FAT->(dbskip())
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[7] < y[1] + y[7] })
   if lTEM
       cPROD := asFAT[1,1]
       PROD->(Dbsetorder(4))
       PROD->(Dbseek(cPROD))

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif


           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,134)
              @ prow()+1,0 say "Ref.1   Ref.2   Produto               Marca         Qtde              Venda                  Custo                  Margem         % Margem"
              @ prow()+1,0 say "                                                              Unitario      Total     Unitario     Total    Unitario      Total            "
              @ prow()+1,0 say replicate("-",134)
           endif

           @ prow()+1,00 say PROD->Cod_ass
           @ prow()  ,09 say left(PROD->Cod_fabr,6)
           @ prow()  ,16 say left(PROD->Descricao,20)
           @ prow()  ,38 say left(PROD->Marca,10)

           @ prow()  ,50 say transform(asFAT[nCONT,2],"@R 99999999")

           @ prow()  ,60 say transform(asFAT[nCONT,3],"@E 99,999.99")
           @ prow()  ,71 say transform(asFAT[nCONT,3]*asFAT[nCONT,2],"@E 999,999.99")

           @ prow()  ,83 say transform(asFAT[nCONT,4],"@E 99,999.99")
           @ prow()  ,94 say transform(asFAT[nCONT,4]*asFAT[nCONT,2],"@E 999,999.99")

           @ prow()  ,106 say transform(asFAT[nCONT,3]-asFAT[nCONT,4],"@E 99,999.99")
           @ prow()  ,117 say transform((asFAT[nCONT,3]-asFAT[nCONT,4])*asFAT[nCONT,2],"@E 999,999.99")

           @ prow()  ,129 say transform(((asFAT[nCONT,3]-asFAT[nCONT,4])/asFAT[nCONT,3])*100,"@E 9999.99")+"%"



           nQTDE     += asFAT[nCONT,2] //Quantidade
           nTT_QTDE  += asFAT[nCONT,2]
           nVENDA    += asFAT[nCONT,3] * asFAT[nCONT,2]
           nTT_VENDA += asFAT[nCONT,3] * asFAT[nCONT,2]
           nCUSTO    += asFAT[nCONT,4] * asFAT[nCONT,2]
           nTT_CUSTO += asFAT[nCONT,4] * asFAT[nCONT,2]


           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cPROD
              PROD->(dbseek(cPROD))
              @ prow()+1,00 say replicate("-",134)
              @ prow()+1,00 say PROD->Cod_ass
              @ prow()  ,09 say left(PROD->Cod_fabr,6)
              @ prow()  ,16 say left(PROD->Descricao,20)
              @ prow()  ,38 say left(PROD->Marca,10)

              @ prow()  ,50 say transform(nQTDE,"@R 99999999")

              @ prow()  ,60 say transform(nVENDA/nQTDE,"@E 99,999.99")
              @ prow()  ,71 say transform(nVENDA,"@E 999,999.99")

              @ prow()  ,83 say transform(nCUSTO/nQTDE,"@E 99,999.99")
              @ prow()  ,94 say transform(nCUSTO,"@E 999,999.99")

              @ prow()  ,106 say transform((nVENDA-nCUSTO)/nQTDE,"@E 99,999.99")
              @ prow()  ,117 say transform(nVENDA-nCUSTO,"@E 999,999.99")
              @ prow()  ,129 say transform( ( (nVENDA-nCUSTO)/nVENDA)*100,"@E 9999.99")+"%"


              @ prow()+1,00 say ""
              @ prow()+1,00 say ""


              cPROD := asFAT[nCONT,1]
              PROD->(Dbseek(cPROD))

              nQTDE      := 0
              nVENDA     := 0
              nCUSTO     := 0
           endif
       enddo

       PROD->(dbseek(cPROD))
       @ prow()+1,00 say replicate("-",134)
       @ prow()+1,00 say PROD->Cod_ass
       @ prow()  ,09 say left(PROD->Cod_fabr,6)
       @ prow()  ,16 say left(PROD->Descricao,20)
       @ prow()  ,38 say left(PROD->Marca,10)

       @ prow()  ,50 say transform(nQTDE,"@R 99999999")

       @ prow()  ,60 say transform(nVENDA/nQTDE,"@E 99,999.99")
       @ prow()  ,71 say transform(nVENDA,"@E 999,999.99")

       @ prow()  ,83 say transform(nCUSTO/nQTDE,"@E 99,999.99")
       @ prow()  ,94 say transform(nCUSTO,"@E 999,999.99")

       @ prow()  ,106 say transform((nVENDA-nCUSTO)/nQTDE,"@E 99,999.99")
       @ prow()  ,117 say transform(nVENDA-nCUSTO,"@E 999,999.99")
       @ prow()  ,129 say transform( ( (nVENDA-nCUSTO)/nVENDA)*100,"@E 9999.99")+"%"


       @ prow()+2,00 say replicate("-",134)
       @ prow()+1,00 say "Total Geral.: "

       @ prow()  ,50 say transform(nTT_QTDE,"@R 99999999")

       @ prow()  ,60 say transform(nTT_VENDA/nTT_QTDE,"@E 99,999.99")
       @ prow()  ,71 say transform(nTT_VENDA,"@E 999,999.99")

       @ prow()  ,83 say transform(nTT_CUSTO/nTT_QTDE,"@E 99,999.99")
       @ prow()  ,94 say transform(nTT_CUSTO,"@E 999,999.99")

       @ prow()  ,106 say transform((nTT_VENDA-nTT_CUSTO)/nTT_QTDE,"@E 99,999.99")
       @ prow()  ,117 say transform(nTT_VENDA-nTT_CUSTO,"@E 999,999.99")



       nQTDE      := 0
       nVENDA     := 0
       nCUSTO     := 0

       nTT_QTDE      := 0
       nTT_VENDA     := 0
       nTT_CUSTO     := 0


   endif

   qstopprn()

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls
    local nTOTAL     := 0
    local nTOTAL_ENT := 0
    local nVALOR     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nQUANT_ENT := 0
    local nTOT_QUANT := 0
    local cPROD      := ""
    local cCFOP      := ""
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lTEM       :=.T.
    local nQTDE      := 0
    local nVENDA     := 0
    local nCUSTO     := 0
    local nTT_QTDE   := 0
    local nTT_VENDA  := 0
    local nTT_CUSTO  := 0
    local nDESC      := 0
    local nTT_DESC   := 0
    local nPRECO     := 0
    local nTT_PRECO  := 0
    local nCFPRECO   := 0
    local nCFQTDE    := 0
    local nCFVENDA   := 0
    local nCFCUSTO   := 0
    local nCFDESC    := 0
    local aResumo    := {}

    local zPROD := space(50)
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


      if ! FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif


//      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611"
//         FAT->(dbskip())
//         loop
//      endif
      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))

             if ! empty(cSETOR) .and. ITEN_FAT->Cod_prod != cSETOR
                ITEN_FAT->(Dbskip())
                loop
             endif

             if FAT->Es == "S"
                aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,ITEN_FAT->Preco_cust,FAT->Codigo,FAT->Es,dtos(FAT->Dt_emissao),ITEN_FAT->Preco_vend,left(FAT->cod_cfop,4)})
             endif

             ITEN_FAT->(Dbskip())
             lTEM := .T.
         enddo
         FAT->(dbskip())
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[9] + x[1] + x[7] < y[9] + y[1] +y[7] })
   if lTEM
       cCFOP := asFAT[1,9]
       cPROD := asFAT[1,1]
       PROD->(Dbsetorder(4))
       PROD->(Dbseek(cPROD))

       nCONT := 1
       do while  nCONT <= len(asFAT)


           if mod(nCONT,65) == 0
              if ! qlineprn() ; exit ; endif
           endif

           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO+" 563"
              @ prow()+1,0 say "Ref.1"+chr(9)+"Ref.2"+chr(9)+"Produto"+chr(9)+"Marca"+chr(9)+"Qtde"+chr(9)+"Preco Tabela"+chr(9)+"Venda Unitario"+chr(9)+"Venda Total"+chr(9)+chr(9)+"Custo Unitario"+chr(9)+"Custo Total"+Chr(9)+chr(9)+"Margem Unitario"+chr(9)+"Margem Total"+chr(9)+"% Margem"+chr(9)+chr(9)+"Preco Tabela"+chr(9)+"Desconto"+chr(9)+"% Desconto"+chr(9)+chr(9)+"Emissao"+chr(9)+"NF"+chr(9)+"CFOP"+chr(9)+"Cliente"
              @ prow()+1,0 say " "
           endif

           @ prow()+1,00     say PROD->Cod_ass           +chr(9)
           @ prow()  ,pcol() say PROD->Cod_fabr   +chr(9)
           @ prow()  ,pcol() say left(PROD->Descricao,20)+chr(9)
           @ prow()  ,pcol() say left(PROD->Marca,10)    +chr(9)

           @ prow()  ,pcol() say transform(asFAT[nCONT,2],"@R 99999999")+chr(9)
           @ prow()  ,pcol() say transform(asFAT[nCONT,8],"@E 999,999.99")+chr(9)


           @ prow()  ,pcol() say transform(asFAT[nCONT,3],"@E 99,999.99")+chr(9)
           @ prow()  ,pcol() say transform(asFAT[nCONT,3]*asFAT[nCONT,2],"@E 999,999.99")+chr(9)+chr(9)

           @ prow()  ,pcol() say transform(asFAT[nCONT,4],"@E 99,999.99")+chr(9)
           @ prow()  ,pcol() say transform(asFAT[nCONT,4]*asFAT[nCONT,2],"@E 999,999.99")+chr(9)+chr(9)

           @ prow()  ,pcol() say transform(asFAT[nCONT,3]-asFAT[nCONT,4],"@E 99,999.99")+chr(9)
           @ prow()  ,pcol() say transform((asFAT[nCONT,3]-asFAT[nCONT,4])*asFAT[nCONT,2],"@E 999,999.99")+chr(9)
           @ prow()  ,pcol() say transform(((asFAT[nCONT,3]-asFAT[nCONT,4])/asFAT[nCONT,3])*100,"@E 9999.99")+"%"+Chr(9)+chr(9)

           @ prow()  ,pcol() say transform(asFAT[nCONT,8]*asFAT[nCONT,2],"@E 999,999.99")+chr(9)
           @ prow()  ,pcol() say transform((asFAT[nCONT,8]*asFAT[nCONT,2])-(asFAT[nCONT,3]*asFAT[nCONT,2]),"@E 999,999.99")+chr(9)
           @ prow()  ,pcol() say transform( ( ( (asFAT[nCONT,8]*asFAT[nCONT,2])-(asFAT[nCONT,3]*asFAT[nCONT,2]) )/(asFAT[nCONT,8]*asFAT[nCONT,2])*100),"@E 9999.99")+"%"+Chr(9)+chr(9)


           FAT->(Dbsetorder(1))
           FAT->(Dbseek(asFAT[nCONT,5]))
           CLI1->(dbseek(FAT->Cod_cli))
           @ prow()  ,pcol() say dtoc(FAT->Dt_emissao)+chr(9)+"NF "+FAT->Num_fatura+chr(9)+FAT->Cod_cfop+chr(9)+CLI1->Razao

           nPRECO    += asFAT[nCONT,8] * asFAT[nCONT,2]
           nTT_PRECO += asFAT[nCONT,8] * asFAT[nCONT,2]
           nQTDE     += asFAT[nCONT,2] //Quantidade
           nTT_QTDE  += asFAT[nCONT,2]
           nVENDA    += asFAT[nCONT,3] * asFAT[nCONT,2]
           nTT_VENDA += asFAT[nCONT,3] * asFAT[nCONT,2]
           nCUSTO    += asFAT[nCONT,4] * asFAT[nCONT,2]
           nTT_CUSTO += asFAT[nCONT,4] * asFAT[nCONT,2]
           nDESC     += ((asFAT[nCONT,8]*asFAT[nCONT,2])-(asFAT[nCONT,3]*asFAT[nCONT,2]) )
           nTT_DESC  += ((asFAT[nCONT,8]*asFAT[nCONT,2])-(asFAT[nCONT,3]*asFAT[nCONT,2]) )

           nCFPRECO    += asFAT[nCONT,8] * asFAT[nCONT,2]
           nCFQTDE     += asFAT[nCONT,2] //Quantidade
           nCFVENDA    += asFAT[nCONT,3] * asFAT[nCONT,2]
           nCFCUSTO    += asFAT[nCONT,4] * asFAT[nCONT,2]
           nCFDESC     += ((asFAT[nCONT,8]*asFAT[nCONT,2])-(asFAT[nCONT,3]*asFAT[nCONT,2]) )

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if (asFAT[nCont,9] + asFAT[nCONT,1]) != (cCFOP + cPROD)
              PROD->(dbseek(cPROD))
              @ prow()+1,00     say chr(9)
              @ prow()  ,pcol() say chr(9)
              @ prow()  ,pcol() say chr(9)
              @ prow()  ,pcol() say chr(9)

              @ prow()  ,pcol() say transform(nQTDE,"@R 99999999")+chr(9)
              @ prow()  ,pcol() say transform(nPRECO,"@E 999,999,999.99")+chr(9)

              @ prow()  ,pcol() say transform(nVENDA/nQTDE,"@E 99,999.99")+chr(9)
              @ prow()  ,pcol() say transform(nVENDA,"@E 999,999.99")+chr(9)+chr(9)

              @ prow()  ,pcol() say transform(nCUSTO/nQTDE,"@E 99,999.99")+chr(9)
              @ prow()  ,pcol() say transform(nCUSTO,"@E 999,999.99")+chr(9)+chr(9)

              @ prow()  ,pcol() say transform((nVENDA-nCUSTO)/nQTDE,"@E 99,999.99")+chr(9)
              @ prow()  ,pcol() say transform(nVENDA-nCUSTO,"@E 999,999.99")+chr(9)
              @ prow()  ,pcol() say transform(((nVENDA-nCUSTO)/nVENDA)*100,"@E 999,999.99")+"%"+chr(9)+chr(9)

              @ prow()  ,pcol() say transform(nPRECO,"@E 999,999.99")+chr(9)
              @ prow()  ,pcol() say transform(nDESC ,"@E 999,999.99")+chr(9)
              @ prow()  ,pcol() say transform( ((nPRECO-nVENDA)/nPRECO)*100,"@E 999,999.99")+"%"+chr(9)

              @ prow()+1,00 say ""


              cPROD := asFAT[nCONT,1]
              PROD->(Dbseek(cPROD))

              nQTDE      := 0
              nVENDA     := 0
              nCUSTO     := 0
              nDESC      := 0
              nPRECO     := 0
           endif

           if asFAT[nCont,9] != cCFOP
              //PROD->(dbseek(cPROD))
              @ prow()+1,00     say "TOTAL - "+cCFOP
              @ prow()  ,pcol() say chr(9)
              @ prow()  ,pcol() say chr(9)
              @ prow()  ,pcol() say chr(9)
              @ prow()  ,pcol() say chr(9)

              @ prow()  ,pcol() say transform(nCFQTDE,"@R 99999999")+chr(9)
              @ prow()  ,pcol() say transform(nCFPRECO,"@E 999,999,999.99")+chr(9)

              @ prow()  ,pcol() say transform(nCFVENDA/nCFQTDE,"@E 99,999.99")+chr(9)
              @ prow()  ,pcol() say transform(nCFVENDA,"@E 999,999.99")+chr(9)+chr(9)

              @ prow()  ,pcol() say transform(nCFCUSTO/nCFQTDE,"@E 99,999.99")+chr(9)
              @ prow()  ,pcol() say transform(nCFCUSTO,"@E 999,999.99")+chr(9)+chr(9)

              @ prow()  ,pcol() say transform((nCFVENDA-nCFCUSTO)/nCFQTDE,"@E 99,999.99")+chr(9)
              @ prow()  ,pcol() say transform(nCFVENDA-nCFCUSTO,"@E 999,999.99")+chr(9)
              @ prow()  ,pcol() say transform(((nCFVENDA-nCFCUSTO)/nCFVENDA)*100,"@E 999,999.99")+"%"+chr(9)+chr(9)

              @ prow()  ,pcol() say transform(nCFPRECO,"@E 999,999.99")+chr(9)
              @ prow()  ,pcol() say transform(nCFDESC ,"@E 999,999.99")+chr(9)
              @ prow()  ,pcol() say transform( ((nCFPRECO-nCFVENDA)/nCFPRECO)*100,"@E 999,999.99")+"%"+chr(9)
              aadd(aResumo,{cCFOP,nCFQTDE,nCFPRECO,nCFVENDA,nCFCUSTO,nCFDESC})

              @ prow()+1,00 say ""

              cCFOP := asFAT[nCONT,9]

              nCFQTDE      := 0
              nCFVENDA     := 0
              nCFCUSTO     := 0
              nCFDESC      := 0
              nCFPRECO     := 0
           endif

       enddo

       PROD->(dbseek(cPROD))
       @ prow()+1,00     say ""

       @ prow()  ,pcol() say chr(9)
       @ prow()  ,pcol() say chr(9)
       @ prow()  ,pcol() say chr(9)

       @ prow()  ,pcol() say transform(nQTDE,"@R 99999999")+chr(9)
       @ prow()  ,pcol() say transform(nPRECO,"@E 999,999,999.99")+chr(9)


       @ prow()  ,pcol() say transform(nVENDA/nQTDE,"@E 99,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nVENDA,"@E 999,999.99")+chr(9)+chr(9)

       @ prow()  ,pcol() say transform(nCUSTO/nQTDE,"@E 99,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nCUSTO,"@E 999,999.99")+chr(9)+chr(9)

       @ prow()  ,pcol() say transform((nVENDA-nCUSTO)/nQTDE,"@E 99,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nVENDA-nCUSTO,"@E 999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(((nVENDA-nCUSTO)/nVENDA)*100,"@E 999,999.99")+"%"+chr(9)+chr(9)

       @ prow()  ,pcol() say transform(nPRECO,"@E 999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nDESC ,"@E 999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(((nPRECO-nVENDA)/nPRECO)*100,"@E 999,999.99")+"%"+chr(9)

       @ prow()+1,00     say "TOTAL - "+cCFOP
       @ prow()  ,pcol() say chr(9)
       @ prow()  ,pcol() say chr(9)
       @ prow()  ,pcol() say chr(9)
       @ prow()  ,pcol() say chr(9)

       @ prow()  ,pcol() say transform(nCFQTDE,"@R 99999999")+chr(9)
       @ prow()  ,pcol() say transform(nCFPRECO,"@E 999,999,999.99")+chr(9)

       @ prow()  ,pcol() say transform(nCFVENDA/nCFQTDE,"@E 99,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nCFVENDA,"@E 999,999.99")+chr(9)+chr(9)

       @ prow()  ,pcol() say transform(nCFCUSTO/nCFQTDE,"@E 99,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nCFCUSTO,"@E 999,999.99")+chr(9)+chr(9)

       @ prow()  ,pcol() say transform((nCFVENDA-nCFCUSTO)/nCFQTDE,"@E 99,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nCFVENDA-nCFCUSTO,"@E 999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(((nCFVENDA-nCFCUSTO)/nCFVENDA)*100,"@E 999,999.99")+"%"+chr(9)+chr(9)

       @ prow()  ,pcol() say transform(nCFPRECO,"@E 999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nCFDESC ,"@E 999,999.99")+chr(9)
       @ prow()  ,pcol() say transform( ((nCFPRECO-nCFVENDA)/nCFPRECO)*100,"@E 999,999.99")+"%"+chr(9)

       aadd(aResumo,{cCFOP,nCFQTDE,nCFPRECO,nCFVENDA,nCFCUSTO,nCFDESC})


       @ prow()+1,00 say ""


       @ prow()+1,00 say chr(9)+chr(9)+"Total Geral.: "+chr(9)+chr(9)

       @ prow()  ,pcol() say transform(nTT_QTDE,"@R 99999999")+chr(9)
       @ prow()  ,pcol() say transform(nTT_PRECO,"@E 999,999,999.99")+chr(9)


       @ prow()  ,pcol() say transform(nTT_VENDA/nTT_QTDE,"@E 9,999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nTT_VENDA,"@E 99,999,999.99")+chr(9)+chr(9)

       @ prow()  ,pcol() say transform(nTT_CUSTO/nTT_QTDE,"@E 99,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nTT_CUSTO,"@E 99,999,999.99")+chr(9)+chr(9)

       @ prow()  ,pcol() say transform((nTT_VENDA-nTT_CUSTO)/nTT_QTDE,"@E 9,999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nTT_VENDA-nTT_CUSTO,"@E 99,999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(((nTT_VENDA-nTT_CUSTO)/nTT_VENDA)*100,"@E 999,999.99")+"%"+chr(9)+chr(9)

       @ prow()  ,pcol() say transform(nTT_PRECO,"@E 999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(nTT_DESC ,"@E 999,999.99")+chr(9)
       @ prow()  ,pcol() say transform(((nTT_PRECO-nTT_VENDA)/nTT_PRECO)*100,"@E 999,999.99")+"%"+chr(9)

       nQTDE      := 0
       nVENDA     := 0
       nCUSTO     := 0
       nPRECO     := 0
       nDESC      := 0

       nCFQTDE      := 0
       nCFVENDA     := 0
       nCFCUSTO     := 0
       nCFPRECO     := 0
       nCFDESC      := 0


       nTT_QTDE      := 0
       nTT_VENDA     := 0
       nTT_CUSTO     := 0

   endif

   asResumo := asort(aResumo,,,{|x,y| x[1] > y[1] })

   nCONT := 1

   XPAGINA := 0

   @ prow()+2,00 say chr(9)+chr(9)+"Resumo por Cfop.: "

   do while  nCONT <= len(asResumo)

     // if XPAGINA == 0 //.or. prow() > K_MAX_LIN
     //    qpageprn()
     //    @ prow()+1,0 say "Resumo por CFOP "
     //    @ prow()+1,0 say  "CFOP"+chr(9)+"Descricao"+chr(9)+"Razao"+chr(9)+"Mes Corrente"+chr(9)+chr(9)+chr(9)+chr(9)+"Acumulado"
     //    @ prow()+1,0 say ""
     // endif

     //aadd(aResumo,{cCFOP,nCFQTDE,nCFPRECO,nCFVENDA,nCFCUSTO,nCFDESC})
     nCFQTDE  := aResumo[nCONT,2]
     nCFPRECO := aResumo[nCONT,3]
     nCFVENDA := aResumo[nCONT,4]
     nCFCUSTO := aResumo[nCONT,5]
     nCFDESC  := aResumo[nCONT,6]

      CFOP->(dbseek(aResumo[nCONT,1]))
      @ prow()+1,00 say chr(9)+chr(9)+aResumo[nCONT,1]+" - "+CFOP->Nat_desc
      @ prow()  ,pcol() say chr(9)+chr(9)
      @ prow()  ,pcol() say transform(nCFQTDE,"@R 99999999")+chr(9)
      @ prow()  ,pcol() say transform(nCFPRECO,"@E 999,999,999.99")+chr(9)

      @ prow()  ,pcol() say transform(nCFVENDA/nCFQTDE,"@E 99,999.99")+chr(9)
      @ prow()  ,pcol() say transform(nCFVENDA,"@E 999,999.99")+chr(9)+chr(9)

      @ prow()  ,pcol() say transform(nCFCUSTO/nCFQTDE,"@E 99,999.99")+chr(9)
      @ prow()  ,pcol() say transform(nCFCUSTO,"@E 999,999.99")+chr(9)+chr(9)

      @ prow()  ,pcol() say transform((nCFVENDA-nCFCUSTO)/nCFQTDE,"@E 99,999.99")+chr(9)
      @ prow()  ,pcol() say transform(nCFVENDA-nCFCUSTO,"@E 999,999.99")+chr(9)
      @ prow()  ,pcol() say transform(((nCFVENDA-nCFCUSTO)/nCFVENDA)*100,"@E 999,999.99")+"%"+chr(9)+chr(9)

      if left(aResumo[nCont,1],3) $ "510-511-512-540-610-611-612-640"
         @ prow()  ,pcol() say transform(nCFPRECO,"@E 999,999.99")+chr(9)
         @ prow()  ,pcol() say transform(nCFDESC ,"@E 999,999.99")+chr(9)
         @ prow()  ,pcol() say transform( ((nCFPRECO-nCFVENDA)/nCFPRECO)*100,"@E 999,999.99")+"%"+chr(9)
      else
         @ prow()  ,pcol() say transform(0,"@E 999,999.99")+chr(9)
         @ prow()  ,pcol() say transform(0,"@E 999,999.99")+chr(9)
         @ prow()  ,pcol() say transform(0,"@E 999,999.99")+"%"+chr(9)
      endif

      nCONT++

      if nCONT > len(asResumo)
         nCONT := len(asResumo)
         exit
      endif

   enddo

   @ prow()+1,00 say chr(9)+chr(9)+"Desconto somente e considerado nos CFOPs de Venda."
   @ prow()+1,00 say chr(9)+chr(9)+"Nos demais CFOPs o valor considerado de saida, devera ser sempre o preco de custo."

   qstopprn(.F.)

return



