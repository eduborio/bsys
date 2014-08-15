//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JANEIRO DE 2010
// OBS........:
// ALTERACOES.:

function cl575
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cCLI := space(5)
private cTIPO   := ""
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aAnomes := {}             // vetor para os campos de entrada de dados
private aTotal := {}             // vetor para os campos de entrada de dados
private sBLOC1  := qlbloc("B575B","QBLOC.GLO")


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOC1    )}  ,"TIPO"  })

//aadd(aEDICAO,{{ || view_cli2(-1,0,@cCLI)        } , "CLI"  })
//aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B575A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cTIPO := ""

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

      case cCAMPO == "CLI"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL++, "Todos os Clientes..")
           else
              if ! CLI1->(Dbseek(cCLI:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(CLI1->Razao,30))
              endif
           endif

      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"123",{"1 - Clientes","2 - Representantes","3 - Estados"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   if cTIPO == "1"
      cTITULO := "Rel. de Faturamento por Cliente Mes a Mes" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)
   elseif cTIPO == "2"
      cTITULO := "Rel. de Faturamento por Represntante Mes a Mes" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)
   else
      cTITULO := "Rel. de Faturamento por Estado Mes a Mes" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)
   endif
   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   METAS->(dbsetorder(2))

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.


static function i_impressao

   if ! quse(XDRV_CL,"FI575A",{"FI575A"},"E")
      qmensa("Nao foi possivel abrir arquivo temporario!! Tente Novamente.")
      return
   endif

   if ! quse(XDRV_CL,"FI575B",{"FI575B"},"E")
      qmensa("Nao foi possivel abrir arquivo temporario!! Tente Novamente.")
      return
   endif

   FI575A->(__dbzap())
   FI575B->(__dbzap())

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      do case
         case cTIPO == "1"
              i_Clixls()
         case cTIPO == "2"
              i_RepresXls()
         case cTIPO == "3"
              i_EstadoXls()
      endcase
   else
      do case
         case cTIPO == "1"
              i_CliPrn()
         case cTIPO == "2"
              i_RepresPrn()
         case cTIPO == "3"
              i_EstadoPrn()
      endcase

   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_CliPrn
    local nQUANT     := 0
    local cCLI       := 0
    local lTEM := .T.
    local zCLI       := space(50)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

    lTEM := .F.

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
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
             nVALOR := ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
             //nVALOR += q_soma_st()

             if FI575A->(Qappend())
                replace FI575A->Cod_cli      with FAT->cod_cli
                replace FI575A->Anomes       with i_Anomes(FAT->Dt_emissao)
                replace FI575A->Quantidade   with ITEN_FAT->Quantidade
                replace FI575A->vl_unitar    with ITEN_FAT->vl_unitar
                replace FI575A->Es           with FAT->Es
                replace FI575A->Total        with nVALOR
             endif

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
   enddo

   FI575A->(dbcommit())
   FI575A->(dbgotop())

   cCLI   := FI575A->Cod_cli
   cANOMES := FI575A->Anomes
   nQUANT  := 0

   do while ! FI575A->(eof())


      if FI575A->Es == "S"
         nQUANT+= FI575A->Total
      else
         nQUANT-= FI575A->Total
      endif

      FI575A->(Dbskip())

      if cCLI + cANOMES !=  FI575A->cod_cli + FI575A->Anomes
         if FI575B->(qappend())
            replace FI575B->Cod_cli      with cCLI
            replace FI575B->Quantidade   with nQUANT
            replace FI575B->Anomes       with cANOMES
         endif

         cANOMES := FI575A->Anomes
         cCLI   := FI575A->Cod_cli
         nQUANT  := 0

      endif

   enddo

   FI575B->(dbcommit())
   FI575B->(dbgotop())

   nQUANT := 0
   cCLI := FI575B->cod_cli
   do while ! FI575B->(eof())


      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND1
         qpageprn()
         qcabecprn(cTITULO,134)
         @ prow()+1,0 say "cod.  Razao                                                          Mes/Ano               Qtde     Estoque Avaria    Saldo"
         @ prow()+1,0 say replicate("-",134)
      endif

      CLI1->(dbseek(FI575B->Cod_cli))

      nQUANT+= FI575B->Quantidade

      @ prow()+1,00 say CLI1->Codigo
      @ prow()  ,10 say CLI1->Razao
      @ prow()  ,70 say right(FI575B->Anomes,2)+"/"+left(FI575B->anomes,4)
      @ prow()  ,90 say transform(FI575B->Quantidade,"@E 9,999,999.99")
      
      FI575B->(dbskip())

      if cCLI != Fi575B->cod_cli
         @ prow()+1,00     say "Total do Cliente..: "+CLI1->Razao
         @ prow()  ,90    say transform(nQUANT,"@E 9,999,999.99")
         @ prow()+1,00    say replicate("-",132)
         @ prow()+1,00    say ""

         cCLI := FI575B->cod_cli
         nQUANT := 0
      endif


   enddo

   @ prow()+1,00     say "Total do Cliente..: "+CLI1->Razao
   @ prow()  ,90    say transform(nQUANT,"@E 9,999,999.99")
   @ prow()+1,00    say replicate("-",132)
   @ prow()+1,00    say ""

   cCLI := FI575B->cod_cli
   nQUANT := 0

   //FI575A->(__dbzap())
   //FI575B->(__dbzap())
   FI575A->(dbclosearea())
   FI575B->(dbclosearea())

   qstopPrn(.F.)


return

static function i_CliXls
    local nQUANT     := 0
    local cCLI      := 0
    local cTABS      := ""
    local cGeraCabec := ""
    local lTEM := .T.
    local lStartNewProduto := .F.
    local zPROD := space(50)
    local aCabec      := {}
    local uPosicao    := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

    lTEM := .F.

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif
      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
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
             nVALOR := ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
             nVALOR += q_soma_st()

             if FI575A->(Qappend())
                replace FI575A->Cod_cli      with FAT->Cod_cli
                replace FI575A->Anomes       with i_Anomes(FAT->Dt_emissao)
                replace FI575A->Quantidade   with ITEN_FAT->Quantidade
                replace FI575A->vl_unitar    with ITEN_FAT->vl_unitar
                replace FI575A->Es           with FAT->Es
                replace FI575A->Total        with nVALOR
             endif

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
   enddo

   FI575A->(dbcommit())
   FI575A->(dbgotop())

   cCLI   := FI575A->Cod_cli
   cANOMES := FI575A->Anomes
   nQUANT  := 0

   do while ! FI575A->(eof())


      if FI575A->Es == "S"
         nQUANT+= FI575A->Total
      else
         nQUANT-= FI575A->Total
      endif

      FI575A->(Dbskip())

      if cCLI + cANOMES !=  FI575A->cod_cli + FI575A->Anomes
         if FI575B->(qappend())
            replace FI575B->Cod_cli      with cCLI
            replace FI575B->Quantidade   with nQUANT
            replace FI575B->Anomes       with cANOMES
         endif

         cANOMES := FI575A->Anomes
         cCLI   := FI575A->Cod_cli
         nQUANT  := 0

      endif

   enddo

   FI575B->(dbcommit())
   FI575B->(dbgotop())

   nQUANT := 0
   cCLI := FI575B->cod_cli
   lStartNewProduto := .T.
   uPosicao := 0

   do while ! FI575B->(eof())


      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         @prow()+1,0 say ""
         qpageprn()
         @ prow()+1,0 say chr(9)+cTITULO+" 575"
         @ prow()+1,0 say "Cod"+chr(9)+"Razao"
         GeraCabec(dINI,dFIM)
         @ prow(),pcol() say chr(9)+"Total"

      endif

      if lStartNewProduto
         CLI1->(dbseek(cCLI))
         @ prow()+1,00 say " "+left(CLI1->codigo,5)+" " +chr(9)+ " "+CLI1->Razao
         lStartNewProduto := .F.
      endif

      nQUANT+= FI575B->Quantidade

      EscolhecolunaSimples(FI575B->Anomes,@uPosicao)

      @ prow()  ,pcol() say chr(9)+transform(FI575B->Quantidade,"@E 9,999,999.99")

      FI575B->(dbskip())

      if cCLI != Fi575B->cod_cli
         //aEstoque := i_calcEstoque(cCLI)
         PreencheRestoSimples(@uPosicao)
         @ prow()  ,pcol()   say chr(9)+transform(nQUANT,"@E 9,999,999.99")
//         @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,1],"@R 99999")

         cCLI := FI575B->cod_cli
         nQUANT := 0
         lStartNewProduto := .T.
         uPosicao := 0
      endif


   enddo

//   aEstoque := i_calcEstoque(cCLI)
   PreencheRestoSimples(@uPosicao)
   @ prow()  ,pcol()   say chr(9)+transform(nQUANT,"@E 9,999,999.99")
//   @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,1],"@R 99999")

   cCLI := FI575B->cod_cli
   nQUANT := 0
   lStartNewProduto := .T.
   uPosicao := 0


   cCLI := FI575B->cod_cli
   nQUANT := 0

   FI575A->(__dbzap())
   FI575B->(__dbzap())
   FI575A->(dbclosearea())
   FI575B->(dbclosearea())
   qstopPrn(.F.)


return


static function i_RepresXls
    local nQUANT     := 0
    local cCLI       := 0
    local cTABS      := ""
    local cGeraCabec := ""
    local lTEM := .T.
    local lStartNewProduto := .F.
    local zPROD := space(50)
    local aCabec      := {}
    local uPosicao    := 0
    local nMETA := 0
    local nFAtGer  := 0
    local nMetaGer := 0
    local nMetaPar := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

    lTEM := .F.

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif
      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
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
             nVALOR := ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
             //nVALOR += q_soma_st()

             if FI575A->(Qappend())
                replace FI575A->Cod_cli      with CLI1->Cod_repres
                replace FI575A->Anomes       with i_Anomes(FAT->Dt_emissao)
                replace FI575A->Quantidade   with ITEN_FAT->Quantidade
                replace FI575A->vl_unitar    with ITEN_FAT->vl_unitar
                replace FI575A->Es           with FAT->Es
                replace FI575A->Total        with nVALOR
             endif

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
   enddo

   FI575A->(dbcommit())
   FI575A->(dbgotop())

   cCLI   := FI575A->Cod_cli
   cANOMES := FI575A->Anomes
   nQUANT  := 0

   do while ! FI575A->(eof())


      if FI575A->Es == "S"
         nQUANT+= FI575A->Total
      else
         nQUANT-= FI575A->Total
      endif

      FI575A->(Dbskip())

      if cCLI + cANOMES !=  FI575A->cod_cli + FI575A->Anomes
         if FI575B->(qappend())
            replace FI575B->Cod_cli      with cCLI
            replace FI575B->Quantidade   with nQUANT
            replace FI575B->Anomes       with cANOMES
         endif

         cANOMES := FI575A->Anomes
         cCLI   := FI575A->Cod_cli
         nQUANT  := 0

      endif

   enddo

   FI575B->(dbcommit())
   FI575B->(dbgotop())

   nQUANT := 0
   cCLI := FI575B->cod_cli
   lStartNewProduto := .T.
   uPosicao := 0

   do while ! FI575B->(eof())


      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         @prow()+1,0 say ""
         qpageprn()
         @ prow()+1,0 say chr(9)+cTITULO+" 575"
         @ prow()+1,0 say "Cod"+chr(9)+"Razao"
         GeraCabec(dINI,dFIM,"R")
         @ prow(),pcol() say chr(9)+"Faturado"+chr(9)+chr(9)+"Meta Parcial"+chr(9)+"%"+chr(9)+chr(9)+"Meta Total"+chr(9)+"%"
      endif

      if lStartNewProduto
         REPRES->(dbseek(cCLI))
         @ prow()+1,00 say " "+left(REPRES->codigo,5)+" " +chr(9)+ " "+REPRES->Razao
         lStartNewProduto := .F.
      endif

      nQUANT+= FI575B->Quantidade
      addTotal(FI575B->Anomes,FI575B->Quantidade,0)


      Escolhecoluna(FI575B->Anomes,@uPosicao,"R",cCLI,nQUANT-FI575B->Quantidade)

      @ prow()  ,pcol() say chr(9)+transform(FI575B->Quantidade,"@E 9,999,999.99")
      if METAS->(dbseek(cCLI))
         nMeta := Metas->Meta    //round(METAS->Meta /12,2)
         nMeta := nMeta - (nQuant-FI575B->Quantidade)
         nMeta := nMeta / (13-(uPosicao/4))
         //nMeta := nMeta * (uPosicao/4)
         //nMeta := nMeta - (nQUANT-FI575B->Quantidade)



         @ prow()  ,pcol() say chr(9)+transform(nMeta,"@E 9,999,999.99"  )
         @ prow()  ,pcol() say chr(9)+transform((FI575B->Quantidade/nMeta)*100,"@E 9,999,999.99"  )+"%"
         @ prow()  ,pcol() say chr(9)
         addTotal(FI575B->Anomes,0,nMeta)
      else
         @ prow()  ,pcol() say chr(9)
         @ prow()  ,pcol() say chr(9)
         @ prow()  ,pcol() say chr(9)
      endif

      FI575B->(dbskip())

      if cCLI != Fi575B->cod_cli
         PreencheResto(@uPosicao,"R",cCLI,nQUANT)
         @ prow()  ,pcol()   say chr(9)+transform(nQUANT,"@E 9,999,999.99")
         @ prow()  ,pcol()   say chr(9)

         if METAS->(dbseek(cCLI))
            @ prow()  ,pcol() say chr(9)+transform((Metas->Meta/12)*month(dFIM),"@E 9,999,999.99")
            @ prow()  ,pcol() say chr(9)+transform( (nQUANT/( (Metas->Meta/12)*month(dFIM)) )*100,"@E 9,999,999.99")+"%"
            @ prow()  ,pcol() say chr(9)
            @ prow()  ,pcol() say chr(9)+transform(Metas->Meta,"@E 9,999,999.99"  )
            @ prow()  ,pcol() say chr(9)+transform((nQUANT/Metas->Meta)*100,"@E 9,999,999.99"  )+"%"
            @ prow()  ,pcol() say chr(9)
         else
            @ prow()  ,pcol() say chr(9)
            @ prow()  ,pcol() say chr(9)
            @ prow()  ,pcol() say chr(9)
            @ prow()  ,pcol() say chr(9)
            @ prow()  ,pcol() say chr(9)
            @ prow()  ,pcol() say chr(9)
         endif
         cCLI := FI575B->cod_cli
         nQUANT := 0
         lStartNewProduto := .T.
         uPosicao := 0
      endif


   enddo

   PreencheResto(@uPosicao,"R",cCLI,nQUANT)

   RepresSemVendas()

   @ prow()+1,00 say chr(9)+"Totais.: "

   for nCONT := 1 to len(aTotal)
       @ prow(), pcol() say chr(9) +transform(aTotal[nCONT,2],"@E 9,999,999.99")
       nFATGer  += aTotal[nCONT,2]
       nMetaGer += aTotal[nCONT,3]
       @ prow(), pcol() say chr(9) +transform(aTotal[nCONT,3],"@E 9,999,999.99")
       @ prow() ,pcol() say chr(9)+transform((aTotal[nCONT,2]/aTotal[nCONT,3])*100,"@E 9,999,999.99"  )+"%"
       @ prow(), pcol() say chr(9) 
   next

   nMETA    := MetaGer()
   nMetaPar := (nMeta/12)*month(dFIM)

   @ prow(),pcol() say chr(9)+transform(nFATGer ,"@E 999,999,999.99")
   @ prow(),pcol() say chr(9)+chr(9)+transform(nMetaPar ,"@E 999,999,999.99")
   @ prow(),pcol() say chr(9)+transform((nFATGer/nMetaPar)*100,"@E 9999.99")+"%"+chr(9)


   @ prow(),pcol() say chr(9)+transform(nMETA,"@E 999,999,999.99")
   @ prow(),pcol() say chr(9)+transform((nFATGer/nMETA)*100,"@E 9999.99")+"%"




   cCLI := FI575B->cod_cli
   nQUANT := 0
   lStartNewProduto := .T.
   uPosicao := 0


   cCLI := FI575B->cod_cli
   nQUANT := 0

//   FI575A->(__dbzap())
//   FI575B->(__dbzap())
   FI575A->(dbclosearea())
   FI575B->(dbclosearea())
   qstopPrn(.F.)


return

static function i_EstadoXls
    local nQUANT     := 0
    local cCLI       := 0
    local cTABS      := ""
    local cGeraCabec := ""
    local lTEM := .T.
    local lStartNewProduto := .F.
    local zPROD := space(50)
    local aCabec      := {}
    local uPosicao    := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

    lTEM := .F.

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif
      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
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
             nVALOR := ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
             nVALOR += q_soma_st()

             if FI575A->(Qappend())
                CGM->(dbseek(CLI1->cgm_ent))
                replace FI575A->Cod_cli      with CGM->Estado
                replace FI575A->Anomes       with i_Anomes(FAT->Dt_emissao)
                replace FI575A->Quantidade   with ITEN_FAT->Quantidade
                replace FI575A->vl_unitar    with ITEN_FAT->vl_unitar
                replace FI575A->Es           with FAT->Es
                replace FI575A->Total        with nVALOR
             endif

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
   enddo

   FI575A->(dbcommit())
   FI575A->(dbgotop())

   cCLI   := FI575A->Cod_cli
   cANOMES := FI575A->Anomes
   nQUANT  := 0

   do while ! FI575A->(eof())


      if FI575A->Es == "S"
         nQUANT+= FI575A->Total
      else
         nQUANT-= FI575A->Total
      endif

      FI575A->(Dbskip())

      if cCLI + cANOMES !=  FI575A->cod_cli + FI575A->Anomes
         if FI575B->(qappend())
            replace FI575B->Cod_cli      with cCLI
            replace FI575B->Quantidade   with nQUANT
            replace FI575B->Anomes       with cANOMES
         endif

         cANOMES := FI575A->Anomes
         cCLI   := FI575A->Cod_cli
         nQUANT  := 0

      endif

   enddo

   FI575B->(dbcommit())
   FI575B->(dbgotop())

   nQUANT := 0
   cCLI := FI575B->cod_cli
   lStartNewProduto := .T.
   uPosicao := 0

   do while ! FI575B->(eof())


      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         @prow()+1,0 say ""
         qpageprn()
         @ prow()+1,0 say chr(9)+cTITULO+" 575"
         @ prow()+1,0 say "Cod"+chr(9)+"Razao"
         GeraCabec(dINI,dFIM)
         @ prow(),pcol() say chr(9)+"Total"

      endif

      if lStartNewProduto
         UFS->(dbseek(alltrim(cCLI)))
         @ prow()+1,00 say " "+left(UFS->codigo,2)+" " +chr(9)+ " "+UFS->Descricao
         lStartNewProduto := .F.
      endif

      nQUANT+= FI575B->Quantidade

      EscolhecolunaSimples(FI575B->Anomes,@uPosicao)
      addTotalEstado(FI575B->Anomes,FI575B->Quantidade)

      @ prow()  ,pcol() say chr(9)+transform(FI575B->Quantidade,"@E 9,999,999.99")

      FI575B->(dbskip())

      if cCLI != Fi575B->cod_cli
         //aEstoque := i_calcEstoque(cCLI)
         PreencheRestoSimples(@uPosicao)
         @ prow()  ,pcol()   say chr(9)+transform(nQUANT,"@E 9,999,999.99")
//         @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,1],"@R 99999")

         cCLI := FI575B->cod_cli
         nQUANT := 0
         lStartNewProduto := .T.
         uPosicao := 0
      endif


   enddo

//   aEstoque := i_calcEstoque(cCLI)
   PreencheRestoSimples(@uPosicao)
   @ prow()  ,pcol()   say chr(9)+transform(nQUANT,"@E 9,999,999.99")
//   @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,1],"@R 99999")

   cCLI := FI575B->cod_cli
   nQUANT := 0
   lStartNewProduto := .T.
   uPosicao := 0


   cCLI := FI575B->cod_cli
   nQUANT := 0

   FI575A->(__dbzap())
   FI575B->(__dbzap())
   FI575A->(dbclosearea())
   FI575B->(dbclosearea())
   qstopPrn(.F.)


return



static function i_EstadoPrn ; return
static function i_RepresPrn ; return


static function i_anomes(dDATA)
local result := ""

   result := strzero(year(dDATA),4)+strzero(month(dDATA),2)

return result


static function EscolheColuna(cANOMES,nPos,cTIPO2,cRepres,nQuant)
local nCONT    := 0
local nIndexOf := 0
local nDif     := 0
local zPosicao := 0
local nMeta    := 0

   nIndexOf := ascan(aAnomes,cAnomes)


   if cTIPO2 == "R"
      nDif := nIndexOf - (nPos/4)

      for nCONT := 1 to ((nDIF-1))

          if METAS->(dbseek(cREPRES))
             //nMeta := round(METAS->Meta /12,2)
             //nMeta := nMeta * ((nPos/4)+nCONT)
             //nMeta := nMeta - (nQUANT)

             nMeta := Metas->Meta    //round(METAS->Meta /12,2)
             nMeta := nMeta - (nQuant)
             nMeta := nMeta / (13-(nPos/4))




             addTotal(((nPos/4)+nCONT),0,nMeta)


             @ prow()  ,pcol() say chr(9)+" "
             @ prow()  ,pcol() say chr(9)+transform(nMeta,"@E 9,999,999.99"  )
             @ prow()  ,pcol() say chr(9)+"0"+"%"
             @ prow()  ,pcol() say chr(9)
          else
             @ prow()  ,pcol() say chr(9)
             @ prow()  ,pcol() say chr(9)
             @ prow()  ,pcol() say chr(9)
             @ prow()  ,pcol() say chr(9)
          endif
      next
   else
      nDif := nIndexOf - nPos

      for nCONT := 1 to (nDIF-1)
          @ prow(), pcol() say chr(9)+"0"
      next
   endif

   if cTIPO2 == "R"
      nPos := nIndexOf * 4
   else
      nPos := nIndexOf
   endif


return

static function PreencheResto(nPos,cTIPO2,cRepres,nQuant)
local nCONT    := 0
local nResto   := 0
local nMeta    := 0

   nResto := len(aAnomes) - (nPos/4)
   if cTIPO2 == "R"
      for nCONT := 1 to (nResto)

          if METAS->(dbseek(cREPRES))
             //nMeta := round(METAS->Meta /12,2)
             //nMeta := nMeta * ((nPos/4)+nCONT)
             //nMeta := nMeta - (nQUANT)

             nMeta := Metas->Meta    //round(METAS->Meta /12,2)
             nMeta := nMeta - (nQuant)
             nMeta := nMeta / (12-(nPos/4))

             addTotal(((nPos/4)+nCONT),0,nMeta)

             @ prow()  ,pcol() say chr(9)+" "
             @ prow()  ,pcol() say chr(9)+transform(nMeta,"@E 9,999,999.99"  )
             @ prow()  ,pcol() say chr(9)+"0"+"%"
             @ prow()  ,pcol() say chr(9)
          else
             @ prow()  ,pcol() say chr(9)
             @ prow()  ,pcol() say chr(9)
             @ prow()  ,pcol() say chr(9)
             @ prow()  ,pcol() say chr(9)
          endif
      next
   else
      for nCONT := 1 to (nResto)
          @ prow(), pcol() say chr(9)+" "
      next
   endif


return



static function geraCabec(dINICIAL,dFINAL,cTIPO)
local nMESES  := 0
local intCONT   := 0
local cANOMES := 0
local nANOMES_INI := 0
local nANOMES_FIM := 0
local lFIRST := .T.
local cResult := ""
local lFisrt := .F.

cANOMES := strzero(year(dINICIAL),4)+strzero(month(dINICIAL),2)
nANOMES_INI := val(cANOMES)

cANOMES := strzero(year(dFINAL),4)+strzero(month(dFINAL),2)
nANOMES_FIM := val(cANOMES)

aAnomes := {}
aTotais := {}

lFirst := .T.

For intCONT := nANOMES_INI To nANOMES_FIM

    if cTIPO == "R"
       @ prow(),pcol() say  chr(9)+right(strzero(intCont,6),2)+"/"+left(strzero(intCont,6),4)
       @ prow(),pcol() say  chr(9)+"Meta - "+right(strzero(intCont,6),2)+"/"+left(strzero(intCont,6),4)
       @ prow(),pcol() say  chr(9)+"%"
       @ prow(),pcol() say  chr(9)+""
    else
       @ prow(),pcol() say  chr(9)+right(strzero(intCont,6),2)+"/"+left(strzero(intCont,6),4)
    endif

    aadd(aAnomes,strzero(intCONT,6))
    aadd(aTotal,{strzero(intCONT,6),0,0,0})

    if right(strzero(intCONT),2) == "12"
       intCONT += 88
    endif

    nMESES++


next

return

static function addTotal(cAnomes,nFat,nMeta)
local nIndexOf := 0

   do case
      case valtype(cAnomes) $ "Cc"
           nIndexOf := ascan(aAnomes,cAnomes)
           aTotal[nIndexOf,2] += nFat
           aTotal[nIndexOf,3] += nMeta
      case valtype(cAnomes) $ "Nn"
           nIndexOf := cAnomes
           aTotal[nIndexOf,2] += nFat
           aTotal[nIndexOf,3] += nMeta
  endcase

return

static function addTotalEstado(cAnomes,nFat,nMeta)
local nIndexOf := 0

   do case
      case valtype(cAnomes) $ "Cc"
           nIndexOf := ascan(aAnomes,cAnomes)
           aTotal[nIndexOf,2] += nFat
        //   aTotal[nIndexOf,3] += nMeta
      case valtype(cAnomes) $ "Nn"
           nIndexOf := cAnomes
           aTotal[nIndexOf,2] += nFat
       //    aTotal[nIndexOf,3] += nMeta
  endcase

return


static function EscolheColunaSimples(cANOMES,nPos)
local nCONT    := 0
local nIndexOf := 0
local nDif     := 0

   nIndexOf := ascan(aAnomes,cAnomes)

   nDif := nIndexOf - nPos

   for nCONT := 1 to (nDIF-1)
       @ prow(), pcol() say chr(9)+"0"
   next

   nPos := nIndexOf


return

static function PreencheRestoSimples(nPos)
local nCONT    := 0
local nResto   := 0

   nResto := len(aAnomes) - nPos

   for nCONT := 1 to nResto
       @ prow(), pcol() say chr(9)+"0"
   next

return

static function RepresSemVendas
local aResult := {}
local nQtde   :=  len(aAnomes)
local nCONT   := 1
local zCONT   := 1
local nMETA   := 0

    METAS->(dbgotop())
    do while ! METAS->(eof())
       if ! FI575B->(dbseek(METAS->Cod_repres))
          aadd(aResult,{METAS->Cod_repres,METAS->Meta})
       endif

       METAS->(dbskip())
    enddo

    if len(AResult) > 0
       for nCONT := 1 to len(aResult)
           @ prow()+1,00 say aResult[nCONT,1]
           REPRES->(dbseek(aResult[nCONT,1]))
           @ prow(),pcol() say chr(9)+REPRES->Razao
           nMETA := round(aResult[nCONT,2]/12,2)

           for zCONT := 1 to nQTDE
               @ prow(),pcol() say chr(9) +"0"
               @ prow(),pcol() say chr(9) + transform(nMETA * zCONT,"@E 99,999,999.99")
               @ prow(),pcol() say chr(9) + "0%"
               @ prow(),pcol() say chr(9) + ""
               addTotal(aAnomes[zCONT],0,nMETA * zCONT)
           next

           @ prow(),pcol() say chr(9) +"0"
           @ prow(),pcol() say chr(9)+chr(9) + transform((aResult[nCONT,2]/12)*month(dFIM),"@E 99,999,999.99")
           @ prow(),pcol() say chr(9) + "0%"

           @ prow(),pcol() say chr(9)+chr(9) + transform(aResult[nCONT,2],"@E 99,999,999.99")
           @ prow(),pcol() say chr(9) + "0%"

       next



    endif



return

static function MetaGer
local nMETA   := 0

    METAS->(dbgotop())
    do while ! METAS->(eof())
       nMeta += Metas->Meta

       METAS->(dbskip())
    enddo


return nMeta


