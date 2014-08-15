//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl560
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private cTITULO2                   // titulo do relatorio
private cRazao                    // titulo do relatorio
private cEstado                   // titulo do relatorio
private cCidade                   // titulo do relatorio

private dINI
private cTIPO   := space(1)
private dFIM
private sBLOC1  := qlbloc("B560B","QBLOC.GLO")

private cUFS    := space(2)
private cCGM    := space(6)
private cREPRES := space(5)

private aEDICAO := {}             // vetor para os campos de entrada de dados

if ! quse(XDRV_ES,"ESTMP",{"ESTMP"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"ESATU",{"ESATU"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_CL,"FI560A",{"FI560A1"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif


if ! quse(XDRV_CL,"FI560B",{"FI560B1"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOC1    )}  ,"TIPO"  })

aadd(aEDICAO,{{ || view_Repres(-1,0,@cREPRES  ) } , "REPRES"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

aadd(aEDICAO,{{ || view_Ufs(-1,0,@cUFS   )      } , "UFS"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })


aadd(aEDICAO,{{ || view_cgm(-1,0,@cCGM   )      } , "CGM"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B560A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cTIPO := space(1)
   dINI := dFIM := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE )  
		 dbcloseall()  
		 erase_index()
		 return  
	  endif
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
              qrsay(XNIVEL+1, "Todos os Representantes.....")
              cRazao := " Todos "
           else
              if ! REPRES->(Dbseek(cREPRES))
                 qmensa("CLiente n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(REPRES->Razao,30))
                 cRazao := left(REPRES->Razao,30)
              endif
           endif


      case cCAMPO == "UFS"

           qrsay(XNIVEL,cUFS)

           if empty(cUFS)
              qrsay(XNIVEL+1, "Todos os Estados.......")
              cEstado := " Todos "
           else
              if ! UFS->(Dbseek(cUFS))
                 qmensa("Estado n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(UFS->Descricao,30))
                 cEstado := left(UFS->Descricao,30)

              endif
           endif

      case cCAMPO == "CGM"

           qrsay(XNIVEL,cCGM)

           if empty(cCGM)
              qrsay(XNIVEL+1, "Todas as Cidades.......")
              cCidade := " Todas "
           else
              if ! CGM->(Dbseek(cCGM))
                 qmensa("Municipio n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CGM->Municipio,30))
                 cCidade := left(CGM->Municipio,30)
              endif
           endif


      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"1234",{"1 - Produtos","2 - Representante","3 - Estado","4 - Cidade"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   faz_index()

   cTITULO := "RANKING DE PRODUTOS FATURADOS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   cTitulo2 := "Repres.: "+padc(cRazao,30)+"  Estado.: "+padc(cEstado,30)+"  Cidade.: "+cCidade

   qmensa("")

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))

   PEDIDO->(dbsetorder(PEDIDO->(Ordcount()))) // data de emissao
   PEDIDO->(dbgotop())
   LANC->(dbsetorder(LANC->(Ordcount())))
   
return .T.


static function i_impressao

   i_calcula_preco_custo()

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   if ! qinitprn() ; return ; endif

   if cTIPO == "1"
      i_normal(XLOCALIMP)
   endif

   if cTIPO == "2"
      i_repres(XLOCALIMP)
   endif

   if cTIPO == "3"
      i_Estado(XLOCALIMP)
   endif

   if cTIPO == "4"
      i_Cidade(XLOCALIMP)
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
    local aPROD      := {}
    local asFAT      := {}
    local asPROD     := {}
    local nPERC      := 0
    local lTEM := .F.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   FI560A->(__dbzap())
   FI560B->(__dbzap())



   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif


      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
         FAT->(dbskip())
         loop
      endif

      if ! empty(cREPRES)
         if alltrim(FAT->Cod_repres) != alltrim(cREPRES)
            FAT->(dbskip())
            loop
         endif
      endif


      if ! empty(cUFS)
         if alltrim(CGM->Estado) != alltrim(cUFS)
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cCGM)
         if alltrim(CGM->Codigo) != alltrim(cCGM)
            FAT->(dbskip())
            loop
         endif
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))
         CGM->(dbseek(CLI1->Cgm_ent))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nVALOR := nVALOR + q_soma_st()
             if FAT->Es == "S"
                if FI560A->(Qappend())
                   replace FI560A->Cod_prod   with right(PROD->Codigo,5)
                   replace FI560A->Quantidade with ITEN_FAT->Quantidade
                   replace FI560A->Vl_unitar  with ITEN_FAT->Vl_unitar
                   replace FI560A->Valor      with nVALOR
                   replace FI560A->Es         with FAT->Es
                   replace FI560A->Quant_ent  with 0
                endif
             else
                if FAT->Es == "E"
                   if FI560A->(Qappend())
                      replace FI560A->Cod_prod   with right(PROD->Codigo,5)
                      replace FI560A->Quantidade with 0
                      replace FI560A->Vl_unitar  with ITEN_FAT->Vl_unitar
                      replace FI560A->Valor      with nVALOR
                      replace FI560A->Es         with FAT->Es
                      replace FI560A->Quant_ent  with ITEN_FAT->Quantidade
                   endif

                endif
             endif

             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

//   FI560A->(dbcommit())

   FI560A->(dbgotop())

   cPROD := FI560A->Cod_prod

   do while ! FI560A->(Eof())

       if FI560a->Es == "S"  // Se for Saida soma as quantidade senao diminui
          nQUANT += FI560A->Quantidade
          nTOTAL += FI560A->Valor
       else
          nQUANT_ENT += FI560A->Quant_ent
          nTOTAL     -= FI560A->Valor
       endif


       FI560A->(Dbskip())
       if FI560A->Cod_prod != cPROD
          if FI560B->(qappend())
             replace FI560B->cod_prod with cPROD
             replace FI560B->Qtde     with (nQuant-nQuant_ent)
             replace FI560B->total    with nTOTAL
          endif
//          FI560B->(dbcommit())

          cPROD := FI560A->Cod_prod

          nQUANT     := 0
          nQUANT_ENT := 0
          nTOTAL     := 0
          nTOTAL_ENT := 0
       endif
   enddo

   if FI560B->(qappend())
      replace FI560B->cod_prod with cPROD
      replace FI560B->Qtde     with (nQuant-nQuant_ent)
      replace FI560B->total    with nTOTAL
   endif

//   FI560B->(dbcommit())


   nQUANT     := 0
   nQUANT_ENT := 0
   nTOTAL     := 0
   nTOTAL_ENT := 0
   nPERC  := 0


   FI560B->(dbgotop())

    do while ! FI560B->(eof())

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          @prow()+1,0 say XCOND1
          qpageprn()
          qcabecprn(cTITULO,136,,cTitulo2)
          @ prow()+1,0 say XCOND1 + "Produto                                                                                                Qtde               Valor       "
          @ prow()+1,0 say replicate("-",134)
       endif


       PROD->(Dbsetorder(4))
       PROD->(Dbseek(FI560B->Cod_prod))

       @ prow()+1 ,00 say PROD->Cod_ass
       @ prow()   ,10 say left(PROD->Cod_fabr,8)
       @ prow()   ,20 say left(PROD->Descricao,40)
       @ prow()   ,65 say left(PROD->Marca,10)
       @ prow()   ,100 say Transform(FI560B->Qtde,"@R 9999999")
       @ prow()   ,115 say Transform(FI560B->Total,"@E 9,999,999.99")

       FI560B->(dbskip())


    enddo

    nQUANT     := 0
    nQUANT_ENT := 0
    nTOTAL     := 0
    nTOTAL_ENT := 0
    nPERC  := 0

    qstopprn()

    FI560A->(dbClosearea())
    FI560B->(dbClosearea())

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls
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
    local aPROD      := {}
    local asFAT      := {}
    local asPROD     := {}
    local nPERC      := 0
    local lTEM := .F.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   FI560A->(__dbzap())
   FI560B->(__dbzap())

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif


      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
         FAT->(dbskip())
         loop
      endif

      if ! empty(cREPRES)
         if alltrim(FAT->Cod_repres) != alltrim(cREPRES)
            FAT->(dbskip())
            loop
         endif
      endif


      if ! empty(cUFS)
         if alltrim(CGM->Estado) != alltrim(cUFS)
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cCGM)
         if alltrim(CGM->Codigo) != alltrim(cCGM)
            FAT->(dbskip())
            loop
         endif
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
             nVALOR := nVALOR + q_soma_st()
             if FAT->Es == "S"
                if FI560A->(Qappend())
                   replace FI560A->Cod_prod   with right(PROD->Codigo,5)
                   replace FI560A->Quantidade with ITEN_FAT->Quantidade
                   replace FI560A->Vl_unitar  with ITEN_FAT->Vl_unitar
                   replace FI560A->Valor      with nVALOR
                   replace FI560A->Es         with FAT->Es
                   replace FI560A->Quant_ent  with 0
                endif
             else
                if FAT->Es == "E"
                   if FI560A->(Qappend())
                      replace FI560A->Cod_prod   with right(PROD->Codigo,5)
                      replace FI560A->Quantidade with 0
                      replace FI560A->Vl_unitar  with ITEN_FAT->Vl_unitar
                      replace FI560A->Valor      with nVALOR
                      replace FI560A->Es         with FAT->Es
                      replace FI560A->Quant_ent  with ITEN_FAT->Quantidade
                   endif

                endif
             endif

             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

//   FI560A->(dbcommit())

   FI560A->(dbgotop())

   cPROD := FI560A->Cod_prod

   do while ! FI560A->(Eof())

       if FI560a->Es == "S"  // Se for Saida soma as quantidade senao diminui
          nQUANT += FI560A->Quantidade
          nTOTAL += FI560A->Valor
       else
          nQUANT_ENT += FI560A->Quant_ent
          nTOTAL     -= FI560A->Valor
       endif


       FI560A->(Dbskip())
       if FI560A->Cod_prod != cPROD
          if FI560B->(qappend())
             replace FI560B->cod_prod with cPROD
             replace FI560B->Qtde     with (nQuant-nQuant_ent)
             replace FI560B->total    with nTOTAL
          endif
//          FI560B->(dbcommit())

          cPROD := FI560A->Cod_prod

          nQUANT     := 0
          nQUANT_ENT := 0
          nTOTAL     := 0
          nTOTAL_ENT := 0
       endif
   enddo

   if FI560B->(qappend())
      replace FI560B->cod_prod with cPROD
      replace FI560B->Qtde     with (nQuant-nQuant_ent)
      replace FI560B->total    with nTOTAL
   endif

//   FI560B->(dbcommit())


   nQUANT     := 0
   nQUANT_ENT := 0
   nTOTAL     := 0
   nTOTAL_ENT := 0
   nPERC  := 0


   FI560B->(dbgotop())

    do while ! FI560B->(eof())

       if XPAGINA == 0 //.or. prow() > K_MAX_LIN
          qpageprn()
          @ prow()+1,0 say chr(9)+chr(9)+cTITULO+"   560"
          @ prow()+1,0 say chr(9)+chr(9)+cTITULO2
          @ prow()+1,0 say "Cod."+chr(9)+"Ref."+chr(9)+"Produto"+chr(9)+"Colecao"+chr(9)+"Qtde"+chr(9)+"Valor"+chr(9)+chr(9) + "Preco de custo" + chr(9) + "Diferenca" + chr(9)+"Preco Custo Un."
          @ prow()+1,0 say ""
       endif


       PROD->(Dbsetorder(4))
       PROD->(Dbseek(FI560B->Cod_prod))

       @ prow()+1 ,00 say PROD->Cod_ass
       @ prow()   ,pcol() say chr(9)+left(PROD->Cod_fabr,8)
       @ prow()   ,pcol() say chr(9)+left(PROD->Descricao,50)
       @ prow()   ,pcol() say chr(9)+left(PROD->Marca,20)
       @ prow()   ,pcol() say chr(9)+Transform(FI560B->Qtde,"@R 9999999")
       @ prow()   ,pcol() say chr(9)+Transform(FI560B->Total,"@E 9,999,999.99")
	   
	   if ESATU->(Dbseek(right(PROD->Codigo,5)))
         nPRECO_CUSTO := ESATU->Preco_cust
	   endif
	   
	   @ prow()   ,pcol() say chr(9)+chr(9)+Transform(nPreco_custo * FI560B->Qtde,"@E 9,999,999.99")
	   @ prow()   ,pcol() say chr(9)+Transform(FI560B->Total - (nPreco_custo * FI560B->Qtde),"@E 9,999,999.99")
	   @ prow()   ,pcol() say chr(9)+Transform(nPreco_custo,"@E 9,999,999.99")

       FI560B->(dbskip())

    enddo

    nQUANT     := 0
    nQUANT_ENT := 0
    nTOTAL     := 0
    nTOTAL_ENT := 0
    nPERC  := 0

    qstopprn(.F.)

    FI560A->(dbClosearea())
    FI560B->(dbClosearea())

return


static function i_Prod(cFILE,cFIELD)
    local nVALOR     := 0
    local lTEM       := .F.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   FI560A->(__dbzap())
   FI560B->(__dbzap())

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop



      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if ! FAT->Es $ "E-S"
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif


      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
         FAT->(dbskip())
         loop
      endif

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->Cgm_ent))

      if ! empty(cREPRES)
         if alltrim(FAT->Cod_repres) != alltrim(cREPRES)
            FAT->(dbskip())
            loop
         endif
      endif


      if ! empty(cUFS)
         if alltrim(CGM->Estado) != alltrim(cUFS)
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cCGM)
         if alltrim(CGM->Codigo) != alltrim(cCGM)
            FAT->(dbskip())
            loop
         endif
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))
         CGM->(dbseek(CLI1->Cgm_ent))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nVALOR := nVALOR + q_soma_st()

             if FAT->Es == "S"
                if FI560A->(Qappend())
                   replace FI560A->Coringa    with (cFILE)->&(cFIELD)
                   replace FI560A->Cod_prod   with right(PROD->Codigo,5)
                   replace FI560A->Quantidade with ITEN_FAT->Quantidade
                   replace FI560A->Vl_unitar  with ITEN_FAT->Vl_unitar
                   replace FI560A->Valor      with nVALOR
                   replace FI560A->Es         with FAT->Es
                   replace FI560A->Quant_ent  with 0
                   replace FI560A->Cgm        with CGM->Codigo
                endif
             else
                if FAT->Es == "E"
                   if FI560A->(Qappend())
                      replace FI560A->Coringa    with (cFILE)->&(cFIELD)
                      replace FI560A->Cod_prod   with right(PROD->Codigo,5)
                      replace FI560A->Quantidade with 0
                      replace FI560A->Vl_unitar  with ITEN_FAT->Vl_unitar
                      replace FI560A->Valor      with nVALOR
                      replace FI560A->Es         with FAT->Es
                      replace FI560A->Quant_ent  with ITEN_FAT->Quantidade
                      replace FI560A->Cgm        with CGM->Codigo
                   endif
                endif
             endif

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
   enddo

//   FI560A->(dbcommit())

   FI560A->(dbgotop())

return

static function i_agrupa
   local cPROD      := ""
   local zCoringa   := ""
   local nQUANT     := 0
   local nQUANT_ENT := 0
   local nTOTAL     := 0

   FI560A->(dbgotop())

   cPROD    := FI560A->Cod_prod
   zCoringa := FI560A->Coringa

   do while ! FI560A->(Eof())

       if FI560a->Es == "S"  // Se for Saida soma as quantidade senao diminui
          nQUANT += FI560A->Quantidade
          nTOTAL += FI560A->Valor
       else
          nQUANT_ENT += FI560A->Quant_ent
          nTOTAL     -= FI560A->Valor
       endif

       FI560A->(Dbskip())

       if FI560A->Cod_prod != cPROD
          if FI560B->(qappend())
             replace FI560B->Coringa  with zCoringa
             replace FI560B->cod_prod with cPROD
             replace FI560B->Qtde     with (nQuant-nQuant_ent)
             replace FI560B->total    with nTOTAL
             replace FI560B->Cgm      with FI560A->Cgm
          endif
          cPROD    := FI560A->Cod_prod
          zCoringa := FI560A->Coringa
          nQUANT     := 0
          nQUANT_ENT := 0
          nTOTAL     := 0
          nTOTAL_ENT := 0
       endif
   enddo

//   FI560B->(dbcommit())

   nQUANT     := 0
   nQUANT_ENT := 0
   nTOTAL     := 0
   nTOTAL_ENT := 0

return

static function i_Coringa(cFILE,cFIELD,cTIT2,cLABEL)
local zCoringa := ""
local nTOTAL   := 0

   FI560B->(dbsetorder(1))
   FI560B->(dbgotop())
   PROD->(dbsetorder(4))

   zCoringa  := alltrim(FI560B->Coringa)

   do while  ! FI560B->(eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND1
         qpageprn()
         qcabecprn(cTITULO+cTIT2,136)
         @ prow()+1,0 say "Cod.     Ref1  Ref2  Produto                                                                    Qtde              Total "
         @ prow()+1,0 say replicate("-",134)

      endif

      @ prow()+1, 00  say FI560B->Coringa                            //Codigo do Cliente
      PROD->(Dbseek(FI560B->Cod_prod))
      @ prow()  , 10 say left(PROD->Cod_fabr,6)+"  "+PROD->Cod_ass + "  "+ left(PROD->Descricao,25)
      @ prow()  , 80 say transf(FI560B->Qtde,"@R 9999999")       //Total do Cliente
      @ prow()  , 110 say transf(FI560B->Total,"@E 9,999,999.99")  //Total do Cliente
      CGM->(Dbseek(FI560B->Cgm))
      //@ prow()  , 110  say CGM->Estado


       nTOTAL += FI560B->Total

       FI560B->(dbskip())

       if alltrim(FI560B->Coringa) != alltrim(zCoringa)
          if (cFILE)->(dbseek(zCoringa)) .and. nTOTAL > 0
             @ prow()+1,00 say cLABEL+left((cFILE)->&(cFIELD),35)
             @ prow()  ,80 say transform(nTOTAL,"@E 9,999,999.99")
             @ prow()+1,00 say replicate("-",132)
             @ prow()+1,00 say ""
             //aadd(aREP,{zREPRES,nTOTAL})
          endif
          nTOTAL := 0
          zCoringa := alltrim(FI560B->Coringa)
       endif


   enddo

   if (cFILE)->(dbseek(zCoringa)) .and. nTOTAL > 0
      @ prow()+1,00 say "Total do Representante.: "+left(cFILE->&(cFIELD),35)
      @ prow()  ,80 say transform(nTOTAL,"@E 9,999,999.99")
      @ prow()+1,00 say replicate("-",132)
      //aadd(aREP,{zREPRES,nTOTAL})
   endif

   nTOTAL   := 0
   zPROD    := ""
   zCoringa:= ""


   qstopprn(.F.)

   FI560A->(__dbzap())
   FI560B->(__dbzap())

return

static function i_Xls(cFILE,cFIELD,cTIT2,cLABEL)
local zCoringa := ""
local nTOTAL   := 0

   FI560B->(dbsetorder(1))
   FI560B->(dbgotop())
   PROD->(dbsetorder(4))

   zCoringa  := alltrim(FI560B->Coringa)

   do while  ! FI560B->(eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         @prow()+1,0 say ""
         qpageprn()
         @prow()+1,0 say chr(9)+chr(9)+Chr(9)+cTITULO+CTIT2+" 560"
         @prow()+1,0 say chr(9)+chr(9)+Chr(9)+cTITULO2

         @ prow()+1,0 say "Cod."+chr(9)+"Ref1"+chr(9)+"Ref2"+chr(9)+"Produto"+chr(9)+"Qtde"+chr(9)+"Total" + chr(9) + chr(9) + "Preco Custo Atual" + chr(9) + "Diferenca"
         @ prow()+1,0 say ""

      endif

      CGM->(Dbseek(FI560B->Coringa))

      if cFILE == "CGM"
         @ prow()+1, 00  say CGM->Municipio                             //Codigo do Cliente
      else
         @ prow()+1, 00  say FI560B->Coringa                            //Codigo do Cliente
      endif

      PROD->(Dbseek(FI560B->Cod_prod))

      @ prow()  , pcol()  say chr(9)+left(PROD->Cod_fabr,6)+chr(9)+PROD->Cod_ass + chr(9)+ left(PROD->Descricao,25)
      @ prow()  , pcol()  say chr(9)+transf(FI560B->Qtde,"@E 9,999,999.99")  //Qtde
      @ prow()  , pcol()  say chr(9)+transf(FI560B->Total,"@E 9,999,999.99")  //Total do Cliente

      if cFILE == "CGM"
         @ prow()  , pcol()  say chr(9)+CGM->Estado
      endif
	  
	  if ESATU->(Dbseek(right(PROD->Codigo,5)))
         nPRECO_CUSTO := ESATU->Preco_cust
	  endif
	 
      @ prow()  , pcol()  say chr(9)+transf(nPreco_custo,"@E 9,999,999.99")  //Preco custo
	  @ prow()  , pcol()  say chr(9)+transf(FI560B->Total - (  FI560B->Qtde * nPreco_Custo ),"@E 9,999,999.99")         //
	  @ prow()  , pcol()  say chr(9)+transf(nPreco_Custo ,"@E 9,999,999.99")         //

       nTOTAL += FI560B->Total

       FI560B->(dbskip())

       if alltrim(FI560B->Coringa) != alltrim(zCoringa)
          if (cFILE)->(dbseek(zCoringa)) .and. nTOTAL > 0
             @ prow()+1,00     say chr(9)+chr(9)+chr(9)+cLABEL+left((cFILE)->&(cFIELD),35)
             @ prow()  ,pcol() say chr(9)+chr(9)+transform(nTOTAL,"@E 9,999,999.99")
             @ prow()+1,00 say ""
             @ prow()+1,00 say ""
             //aadd(aREP,{zREPRES,nTOTAL})
          endif
          nTOTAL := 0
          zCoringa := alltrim(FI560B->Coringa)
       endif


   enddo

   if (cFILE)->(dbseek(zCoringa)) .and. nTOTAL > 0
      @ prow()+1,00     say chr(9)+chr(9)+chr(9)+cLABEL+left((cFILE)->&(cFIELD),35)
      @ prow()  ,pcol() say chr(9)+chr(9)+transform(nTOTAL,"@E 9,999,999.99")
      @ prow()+1,00 say ""

      //aadd(aREP,{zREPRES,nTOTAL})
   endif

   nTOTAL   := 0
   zPROD    := ""
   zCoringa:= ""


   qstopprn(.F.)

   FI560A->(__dbzap())
   FI560B->(__dbzap())

return

static function i_normal(cIMP)

  if cIMP == "X"
     i_impre_xls()
  else
     i_impre_prn()
  endif

return


static function i_Repres(cIMP)

   i_prod("FAT","Cod_repres")

   i_Agrupa()

   if cIMP == "X"
      i_xls("REPRES","Razao"," POR REPRESENTANTE"," Total do Representante.: ")
   else
      i_Coringa("REPRES","Razao"," POR REPRESENTANTE"," Total do Representante.: ")
   endif

return

static function i_Estado(cIMP)

   i_prod("CGM","Estado")

   i_Agrupa()

   if cIMP == "X"
      i_Xls("UFS","Descricao"," POR ESTADO"," Total do Estado.: ")
   else
      i_Coringa("UFS","Descricao"," POR ESTADO"," Total do Estado.: ")
   endif



return

static function i_Cidade(cIMP)

   i_prod("CGM","Codigo")

   i_Agrupa()

   if cIMP == "X"
      i_Xls("CGM","Municipio"," POR CIDADE"," Total do Municipio.: ")
   else
      i_Coringa("CGM","Municipio"," POR CIDADE"," Total do Municipio.: ")
   endif

return

static function faz_index
local cTime := ""

   if ! quse(XDRV_CP,"PEDIDO")
      qmensa("N„o foi poss¡vel abrir PEDIDO.DBF !! Tente novamente.")
      return
   endif
   
   if ! quse(XDRV_CP,"FORN")
      qmensa("N„o foi poss¡vel abrir FORN.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CP,"LANC")
      qmensa("N„o foi poss¡vel abrir LANC.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_ES,"MOVIMENT")
      qmensa("N„o foi poss¡vel abrir MOVIMENT.DBF !! Tente novamente.")
      return
   endif

   select PEDIDO

   index on dtos(data_ped) tag dtp TO (XDRV_ES + "ES510C.TMP")
   dbsetindex(XDRV_ES + "ES510C.TMP")


   select LANC
   index on cod_ped tag UM TO (XDRV_ES + "ES510D.TMP")
   dbsetindex(XDRV_ES + "es510D.TMP")


   select MOVIMENT

   index on data tag UM TO (XDRV_ES + "ES510E.TMP")
   dbsetindex(XDRV_ES + "es510E.TMP")

return

static function erase_index

   erase(XDRV_ES+"ES510C.TMP")
   erase(XDRV_ES+"ES510D.TMP")
   erase(XDRV_ES+"ES510E.TMP")

return

static function i_calcula_preco_custo
    local nTOTAL     := 0
    local nSALDO_COR := 0
    local nSALDO_INI := 0
    local nCUSTO_INI := 0
    local nCUSTO_COR := 0
    local nVALOR     := 0

    local nVLR_VEND  := 0
    local nVLR_VEND_TOT  := 0
    local nVLR_ENT_TOT  := 0
    local nVLR_ESTQ_TOT  := 0
    local nQTD_VEND  := 0

    local nVLR_ENT   := 0
    local nVLR_ESTQ  := 0
    local nQTD_ENT   := 0

    local nDESC      := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lPRIM := .T.
    local zPROD := space(50)

    ESTMP->(__dbzap())
    ESATU->(__dbzap())

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_Fatura) .and. FAT->Es == "S"
         FAT->(DbSkip())
         loop
      endif

      if left(FAT->Cod_cfop,4) $ "5905-6905-1906-2906-5906-6906-1905-2905"
         FAT->(DbSkip())
         loop
      endif

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          if ESTMP->(qappend())
             replace ESTMP->Data       with FAT->Dt_emissao
             replace ESTMP->Produto    with right(ITEN_FAT->Cod_prod,5)
             replace ESTMP->Quantidade with ITEN_FAT->Quantidade
             replace ESTMP->Es         with FAT->Es
          endif
          ITEN_FAT->(Dbskip())
      enddo

      if mod(val(FAT->codigo),60) == 1
         qmensa(FAT->Codigo)
      endif

      FAT->(dbskip())
      nVALOR := 0
      nDESC := 0
   enddo

   MOVIMENT->(dbsetorder(MOVIMENT->(Ordcount()))) // data de emissao
   MOVIMENT->(dbgotop())

   do while ! MOVIMENT->(eof())

         if MOVIMENT->Contabil
            MOVIMENT->(dbSkip())
            Loop
         endif

         if MOVIMENT->Tipo == "E"
            cDESCRICAO := "ENTRA"
         else
            cDESCRICAO := "SAIDA"
         endif

         if ESTMP->(qappend())
            replace ESTMP->Data       with MOVIMENT->Data
            replace ESTMP->Produto    with right(MOVIMENT->Cod_prod,5)
            replace ESTMP->Quantidade with MOVIMENT->Quantidade
            replace ESTMP->Es         with MOVIMENT->Tipo
         endif

         MOVIMENT->(dbskip())

         nVALOR := 0
         nDESC := 0
   enddo

   do while ! PEDIDO->(eof())  // condicao principal de loop

      //qgirabarra()

      qmensa("Aguarde... Processando ...")

         if ! PEDIDO->Interface
            PEDIDO->(Dbskip())
            loop
         endif

         FORN->(dbseek(PEDIDO->Cod_forn))

         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

             if ESTMP->(qappend())
                replace ESTMP->Data        with PEDIDO->Data_ped
                replace ESTMP->Produto     with right(LANC->Cod_prod,5)
                replace ESTMP->Quantidade  with LANC->Quant
                replace ESTMP->Preco_cust  with LANC->Preco
                replace ESTMP->Es          with "C"
             endif

             LANC->(Dbskip())
         enddo
         PEDIDO->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   i_agrupa_prod()

 return

static Function i_agrupa_prod

   ESTMP->(Dbgotop())
   ESTMP->(Dbsetorder(1))
   cPROD := ESTMP->Produto
   PROD->(dbsetorder(4))
   nSALDO_COR := 0
   nCUSTO_COR := 0

   lPRIM := .T.
   nCONT := 1
   do while ! ESTMP->(eof())

       if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidade senao diminui
          nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
       else

          if ESTMP->Es == "C"
             nCUSTO_COR := ( (nSALDO_COR * nCUSTO_COR) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
          Endif

          nSALDO_COR := nSALDO_COR + ESTMP->Quantidade
       endif

       nCUSTO_COR := round(nCUSTO_COR,2)

       nVLR_ESTQ := (nSALDO_COR * nCUSTO_COR)



       ESTMP->(dbskip())

       if ESTMP->Produto != cPROD

          if mod(val(cPROD),5) == 1
             qmensa("Calculando custo... Aguarde...  "+cPROD)
          endif


          if ESATU->(Qappend())
             replace ESATU->Produto     with cPROD
             replace ESATU->Saldo       with nSALDO_COR
             replace ESATU->Preco_cust  with nCUSTO_COR
          endif

          cPROD := ESTMP->Produto
          //ESANT->(Dbseek(ESTMP->Produto))
          nSALDO_COR := 0//ESANT->Quantidade
          nCUSTO_COR := 0//ESANT->Preco_cust


          lPRIM := .T.

          nVLR_VEND := 0
          nQTD_VEND := 0
          nVLR_ENT  := 0
          nVLR_ESTQ := 0
          nQTD_ENT  := 0

          nQUANT := 0
          nTOTAL := 0
       endif
   enddo

   if ESATU->(Qappend())
      replace ESATU->Produto     with cPROD
      replace ESATU->Saldo       with nSALDO_COR
      replace ESATU->Preco_cust  with nCUSTO_COR
   endif


   nVLR_VEND := 0
   nQTD_VEND := 0
   nVLR_ENT  := 0
   nQTD_ENT  := 0
   nQUANT := 0
   nTOTAL := 0
   nPERC  := 0
   nVLR_VEND_TOT := 0
   nVLR_ENT_TOT := 0
   nVLR_ESTQ_TOT := 0

return




