/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl542
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cDATA := ""
private cCLI := space(5)
private cRAZAO := space(40)
private sBLOC1 := XSN
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_Cli(-1,0,@cCLI)         } , "CLIENTE"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cDATA,sBLOC1)    } , "DATA"  })

do while .T.

   qlbloc(5,0,"B542A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cCLI := space(5)
   cRAZAO := space(40)
   cDATA := ""

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
              //qrsay(XNIVEL++, "Todos os Setores.......")
              qmensa("Campo Obrigat¢rio !!!","B")
              return .F.
           else
              if ! CLI1->(Dbseek(cCLI:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CLI1->Razao,40))
                 cRAZAO := left(CLI1->Razao,40)
              endif
           endif

      case cCAMPO == "DATA"
           if empty(cDATA) ; return .F. ; endif
           qrsay (XNIVEL,qabrev(cDATA,"SN", {"Sim","Nao"}))


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
      if cDATA == "S"
         i_separapordata()
      else
         i_impre_xls()
      endif
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

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if FAT->Cod_cli != cCLI
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
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
             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)

             aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,FAT->Es,dtos(FAT->Dt_emissao)})
             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]
       PROD->(Dbsetorder(4))
       PROD->(dbseek(cPROD))
       zPROD := asFAT[1,4]+" "+asFAT[1,5]

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

           if asFAT[nCONT,7] == "S"  // Se for Saida soma as quantidade senao diminui
              nQUANT += asFAT[nCONT,2]
              nTOT_QUANT += asFAT[nCONT,2]
              nTOTAL += asFAT[nCONT,6]    //Quantidade * valor unitario
              nTOT_GER += asFAT[nCONT,6]  //Quantidade * valor unitario

           else
              nQUANT -= asFAT[nCONT,2]
              nTOT_QUANT -= asFAT[nCONT,2]
              nTOTAL -= asFAT[nCONT,6]    //Quantidade * valor unitario
              nTOT_GER -= asFAT[nCONT,6]  //Quantidade * valor unitario
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif
           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say zPROD
              @ prow()  ,61 say transf(nQUANT,"@R 999999")
              @ prow()  ,73 say transf(nTOTAL,"@E 99,999,999.99")
              @ prow()  ,90 say transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"
              cPROD := asFAT[nCONT,1]
              zPROD := asFAT[nCONT,4]+" "+asFAT[nCONT,5]

              nQUANT := 0
              nTOTAL := 0
           endif
       enddo
       @ prow()+1,00 say zPROD            //descricao do produto
       @ prow()  ,61 say transf(nQUANT,"@R 999999")
       @ prow()  ,73 say transf(nTOTAL,"@E 99,999,999.99")
       @ prow()  ,90 say transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"


       @ prow()+1,00 say replicate("-",134)
       @ prow()+1,60 say transf(nTOT_QUANT,"@R 9999999")
       @ prow()  ,73 say transf(nTOT_GER,"@E 99,999,999.99")

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

      if empty(FAT->Num_fatura).and. FAT->Es == "S" .and. FAT->No_nf == .F.
         FAT->(dbskip())
         loop
      endif

      if alltrim(FAT->Cod_cli) != alltrim(cCLI)
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
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

             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)

             aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+PROD->Marca+" "+PROD->Cod_ass,nVALOR,FAT->Es})
             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0

             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]
       PROD->(DbSetOrder(4))
       PROD->(Dbseek(cPROD))
       zPROD := left(PROD->Descricao,20)+Chr(9)+PROD->Cod_ass + chr(9)+ PROD->Cod_fabr + chr(9)+ PROD->Marca

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say cTITULO
              @ prow()+1,0 say "Produto"+chr(9)+"Cod. Ass."+chr(9)+"Cod. Fabr."+chr(9)+"Marca/Colecao"+chr(9)+"Quantidade"+chr(9)+"Valor"
              @ prow()+1,0 say ""
           endif

           if asFAT[nCONT,7] == "S"  // Se for Saida soma as quantidade senao diminui
              nQUANT += asFAT[nCONT,2]
              nTOT_QUANT += asFAT[nCONT,2]
              nTOTAL += asFAT[nCONT,6]    //Quantidade * valor unitario
              nTOT_GER += asFAT[nCONT,6]  //Quantidade * valor unitario

           else
              nQUANT -= asFAT[nCONT,2]
              nTOT_QUANT -= asFAT[nCONT,2]
              nTOTAL -= asFAT[nCONT,6]    //Quantidade * valor unitario
              nTOT_GER -= asFAT[nCONT,6]  //Quantidade * valor unitario
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif
           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say zPROD
              @ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")
              @ prow()  ,pcol() say chr(9)+transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"
              cPROD := asFAT[nCONT,1]
              PROD->(DbSetOrder(4))
              PROD->(Dbseek(cPROD))
              zPROD := left(PROD->Descricao,20)+Chr(9)+PROD->Cod_ass + chr(9)+ PROD->Cod_fabr + chr(9)+ PROD->Marca

              nQUANT := 0
              nTOTAL := 0
           endif
       enddo
       //PROD->(DbSetOrder(4))
      // PROD->(Dbseek(cPROD))
      // zPROD := left(PROD->Descricao,20)+Chr(9)+PROD->Cod_ass + chr(9)+ PROD->Cod_fabr + chr(9)+ PROD->Marca

       @ prow()+1,00 say zPROD            //descricao do produto
       @ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")
       @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")
      // @ prow()  ,pcol() say chr(9)+transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"


       @ prow()+1,00 say ""
       @ prow()+1,00 say chr(9)+transf(nTOT_QUANT,"@R 9999999")
       @ prow()  ,pcol() say chr(9)+transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return



static function i_SeparaPorData
    local nTOTAL     := 0
    local nVALOR     := 0
    local zCOD_ASS   := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local ndQuant  := 0
    local ndValor  := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local aRank      := {}
    local asRank     := {}
    local asFAT      := {}
    local nPERC      := 0
    local zDT        := ctod("")
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   PROD->(dbsetorder(4))

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S" .and. FAT->No_nf == .F.
         FAT->(dbskip())
         loop
      endif

      if alltrim(FAT->Cod_cli) != alltrim(cCLI)
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(Dbseek(ITEN_FAT->Cod_prod))


             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)

             aadd(aFAT,{ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,dtos(FAT->Dt_emissao),left(PROD->Cod_fabr,6)})
             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0

             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[6] < y[1] + y[6] })
   aFAT:= {}
   if lTEM
       cPROD := asFAT[1,1]
       cDIA  := asFAT[1,6]

       PROD->(DbSetOrder(4))
       PROD->(Dbseek(cPROD))
       zPROD := left(PROD->Descricao,20)+Chr(9)+PROD->Cod_ass + chr(9)+ PROD->Cod_fabr + chr(9)+ PROD->Marca
       zCOD_ASS := left(PROD->cod_fabr,6)

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say cTITULO+" 542"
              @ prow()+1,0 say "Ref."+chr(9)+"Emissao"+chr(9)+"Quantide"+chr(9)+"Valor"
              @ prow()+1,0 say ""
           endif

           if asFAT[nCONT,5] == "S"  // Se for Saida soma as quantidade senao diminui

              ndQuant   += asFAT[nCONT,2]
              nQUANT      += asFAT[nCONT,2]
              nTOT_QUANT  += asFAT[nCONT,2]
              ndValor   += asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOTAL += asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOT_GER += asFAT[nCONT,4]  //Quantidade * valor unitario

           else
              ndQuant   -= asFAT[nCONT,2]
              nQUANT      -= asFAT[nCONT,2]
              nTOT_QUANT  -= asFAT[nCONT,2]
              ndValor   -= asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOTAL -= asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOT_GER -= asFAT[nCONT,4]  //Quantidade * valor unitario
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] + asFAT[nCONT,6] != cPROD+cDIA
              @ prow()+1,00 say zCOD_ASS
              @ prow()  ,pcol() say chr(9)+right(cDIA,2)+"/"+subs(cDIA,5,2)+"/"+left(cDia,4)
              @ prow()  ,pcol() say chr(9)+transf(ndQuant,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(ndValor,"@E 99,999,999.99")
              cDIA  := asFAT[nCONT,6]
              ndQuant := 0
              ndValor := 0
           endif

           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say "Total.: "+zCOD_ASS
              @ prow()  ,pcol() say chr(9)+chr(9)+transf(nQUANT,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")
              aadd(aRank,{cPROD,nQUANT,nTOTAL})
              cPROD := asFAT[nCONT,1]
              cDIA  := asFAT[nCONT,6]
              PROD->(Dbseek(cPROD))
              zPROD := left(PROD->Descricao,20)+Chr(9)+PROD->Cod_ass + chr(9)+ PROD->Cod_fabr + chr(9)+ PROD->Marca
              zCOD_ASS := left(PROD->cod_fabr,6)
              @ prow()+2  ,00 say ""

              nQUANT := 0
              nTOTAL := 0
           endif
       enddo

       @ prow()+1,00 say zCOD_ASS
       @ prow()  ,pcol() say chr(9)+right(cDIA,2)+"/"+subs(cDIA,5,2)+"/"+left(cDia,4)
       @ prow()  ,pcol() say chr(9)+transf(ndQuant,"@R 999999")
       @ prow()  ,pcol() say chr(9)+transf(ndValor,"@E 99,999,999.99")


       @ prow()+1,00 say "Total.: "+zCOD_ASS
       @ prow()  ,pcol() say chr(9)+chr(9)+transf(nQUANT,"@R 999999")
       @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")

       @ prow()+1,00 say ""
       @ prow()+1,00 say chr(9)+chr(9)+transf(nTOT_QUANT,"@R 9999999")
       @ prow()  ,pcol() say chr(9)+transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
       ndQuant:= 0
       ndValor:= 0
   endif


   //Inicia Impressao Do Ranking Do Cliente
   PROD->(Dbsetorder(4))

   nCONT := 1

   asRank := asort(aRank,,,{|x,y| x[3] > y[3] })
   aRank:= {}



   @ prow()+2,0 say "Ranking de Pecas do Cliente"
   @ prow()+1,0 say ""


   do while  nCONT <= len(asRank)



      PROD->(Dbseek(asRank[nCONT,1]))

      @ prow()+1 ,00 say PROD->Cod_ass
      @ prow()   ,pcol() say chr(9)+left(PROD->Cod_fabr,8)
      @ prow()   ,pcol() say chr(9)+left(PROD->Descricao,50)
      @ prow()   ,pcol() say chr(9)+left(PROD->Marca,20)
      @ prow()   ,pcol() say chr(9)+Transform(asRank[nCONT,2],"@R 9999999")
      @ prow()   ,pcol() say chr(9)+Transform(asRank[nCOnt,3],"@E 9,999,999.99")

      nCONT++
      if nCONT > len(asRank)
         nCONT := len(asRank)
         exit
      endif

   enddo

   qstopprn(.F.)

return



