/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS POR ESTADO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JANEIRO DE 2003
// OBS........:
// ALTERACOES.:

function cl536
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private cUFS   := space(2)
private aEDICAO := {}             // vetor para os campos de entrada de dados

if ! quse(XDRV_CL,"FI536",{"FI536"},"E")
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
   dINI := dFIM := ctod("")
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


   cTITULO := "LISTAGEM DE PRODUTOS FATURADOS POR ESTADO" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

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
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

    FI536->(__dbzap())


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif


      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))
         CGM->(dbseek(CLI1->Cgm_ent))
         if !empty(cUFS) .and. CGM->Estado != cUFS
            FAT->(dbskip())
            loop
         endif

         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))

             if FI536->(Qappend())
                replace FI536->Cod_prod   with ITEN_FAT->Cod_prod
                replace FI536->Quantidade with ITEN_FAT->Quantidade
                replace FI536->Vl_unitar  with ITEN_FAT->Vl_unitar
                replace FI536->Estado     with CGM->Estado
                replace FI536->Es         with FAT->Es
             endif

             ITEN_FAT->(Dbskip())
             lTEM := .T.
         enddo
         FAT->(dbskip())

   enddo

   PROD->(dbsetorder(4))

   FI536->(dbcommit())
   FI536->(dbgotop())

   cCGM  := FI536->Estado
   cPROD := FI536->Cod_prod
   @prow()+1,0 say XCOND1



   do while  ! FI536->(eof())


       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,132)
          @ prow()+1,0 say "Produto                                                   Quantidade            Valor "
          @ prow()+1,0 say replicate("-",134)
       endif

       if FI536->Es == "S"
          nQUANT += FI536->Quantidade
          nTOT_QUANT += FI536->Quantidade
          nUF_QUANT  += FI536->Quantidade
          nUF_VALOR  += (FI536->Quantidade  * FI536->Vl_unitar)
          nTOTAL     += (FI536->Quantidade  * FI536->Vl_unitar)
          nTOT_GER   += (FI536->Quantidade  * FI536->Vl_unitar)

       else
          if FI536->ES == "E"
             nQUANT -= FI536->Quantidade
             nTOT_QUANT -= FI536->Quantidade
             nUF_QUANT  -= FI536->Quantidade
             nUF_VALOR  -= (FI536->Quantidade  * FI536->Vl_unitar)
             nTOTAL     -= (FI536->Quantidade  * FI536->Vl_unitar)
             nTOT_GER   -= (FI536->Quantidade  * FI536->Vl_unitar)
          endif

       endif

       FI536->(dbskip())

       if FI536->Cod_prod != cPROD
          PROD->(Dbseek(cPROD))
          cDESC_PROD := PROD->Cod_ass + "  " + left(PROD->Cod_fabr,7) + " " +left(PROD->Descricao,20)+ " "+left(PROD->Marca,15)
          if ! qlineprn(); return; endif

          @ prow()+1,00 say cDESC_PROD            //descricao do produto
          @ prow()  ,61 say transf(nQUANT,"@R 999999")
          @ prow()  ,73 say transf(nTOTAL,"@E 99,999,999.99")
          @ prow()  ,90 say cCGM
          cPROD := FI536->Cod_prod
          nQUANT := 0
          nTOTAL := 0
       endif

       if FI536->Estado != cCGM
           UFS->(dbseek(cCGM))
           @ prow()+2  ,00 say "TOTAIS DO ESTADO.: "+UFS->Descricao
           @ prow()    ,61 say transf(nUF_QUANT,"@R 999999")
           @ prow()    ,73 say transf(nUF_VALOR,"@E 99,999,999.99")
           @ prow()    ,90 say cCGM
           @ prow()+1,00 say replicate("-",136)
           @ prow()+1,00 say ""
           cCGM := FI536->Estado

           nUF_QUANT := 0
           nUF_VALOR := 0
       endif


   enddo

   PROD->(Dbseek(cPROD))
   cDESC_PROD := PROD->Cod_ass + "  " + left(PROD->Cod_fabr,7) + " " +left(PROD->Descricao,20)+ " "+left(PROD->Marca,15)
   @ prow()+1,00 say cDESC_PROD            //descricao do produto
   @ prow()  ,61 say transf(nQUANT,"@R 999999")
   @ prow()  ,73 say transf(nTOTAL,"@E 99,999,999.99")
   @ prow()  ,90 say cCGM
   nQUANT := 0
   nTOTAL := 0


   UFS->(dbseek(cCGM))
   @ prow()+2  ,00 say "TOTAIS DO ESTADO.: "+UFS->Descricao
   @ prow()    ,61 say transf(nUF_QUANT,"@R 999999")
   @ prow()    ,73 say transf(nUF_VALOR,"@E 99,999,999.99")
   @ prow()    ,90 say cCGM
   @ prow()+1,00 say replicate("-",136)
   @ prow()+1,00 say ""
   nUF_QUANT := 0
   nUF_VALOR := 0


   @ prow()+1,00 say replicate("-",134)
   @ prow()+1,60 say transf(nTOT_QUANT,"@R 9999999")
   @ prow()  ,73 say transf(nTOT_GER,"@E 99,999,999.99")

   nQUANT := 0
   nTOTAL := 0

   qstopprn(.F.)

return



static function i_impre_xls
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

    FI536->(__dbzap())


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif


      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))
         CGM->(dbseek(CLI1->Cgm_ent))
         if !empty(cUFS) .and. CGM->Estado != cUFS
            FAT->(dbskip())
            loop
         endif

         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))

             if FI536->(Qappend())
                replace FI536->Cod_prod   with ITEN_FAT->Cod_prod
                replace FI536->Quantidade with ITEN_FAT->Quantidade
                replace FI536->Vl_unitar  with ITEN_FAT->Vl_unitar
                replace FI536->Estado     with CGM->Estado
                replace FI536->Es         with FAT->Es
             endif

             ITEN_FAT->(Dbskip())
             lTEM := .T.
         enddo
         FAT->(dbskip())

   enddo

   PROD->(dbsetorder(4))

   FI536->(dbcommit())
   FI536->(dbgotop())

   cCGM  := FI536->Estado
   cPROD := FI536->Cod_prod


   do while  ! FI536->(eof())


       if XPAGINA == 0 //.or. prow() > K_MAX_LIN
          qpageprn()
          @ prow()+1,0 say chr(9)+chr(9)+cTITULO+" 536"
          @ prow()+1,0 say "Ref1."+chr(9)+"Ref2."+chr(9)+"Descricao"+chr(9)+"Marca"+chr(9)+"Quantidade"+chr(9)+"Valor"+chr(9)+"Uf"
          @ prow()+1,0 say ""
       endif

       if FI536->Es == "S"
          nQUANT += FI536->Quantidade
          nTOT_QUANT += FI536->Quantidade
          nUF_QUANT  += FI536->Quantidade
          nUF_VALOR  += (FI536->Quantidade  * FI536->Vl_unitar)
          nTOTAL     += (FI536->Quantidade  * FI536->Vl_unitar)
          nTOT_GER   += (FI536->Quantidade  * FI536->Vl_unitar)

       else
          if FI536->ES == "E"
             nQUANT -= FI536->Quantidade
             nTOT_QUANT -= FI536->Quantidade
             nUF_QUANT  -= FI536->Quantidade
             nUF_VALOR  -= (FI536->Quantidade  * FI536->Vl_unitar)
             nTOTAL     -= (FI536->Quantidade  * FI536->Vl_unitar)
             nTOT_GER   -= (FI536->Quantidade  * FI536->Vl_unitar)
          endif

       endif

       FI536->(dbskip())

       if FI536->Cod_prod != cPROD
          PROD->(Dbseek(cPROD))
          cDESC_PROD := PROD->Cod_ass + chr(9) + left(PROD->Cod_fabr,7) + chr(9) +left(PROD->Descricao,20)+ chr(9)+left(PROD->Marca,15)
          if ! qlineprn(); return; endif

          @ prow()+1,00     say cDESC_PROD            //descricao do produto
          @ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")
          @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")
          @ prow()  ,pcol() say chr(9)+cCGM
          cPROD := FI536->Cod_prod
          nQUANT := 0
          nTOTAL := 0
       endif

       if FI536->Estado != cCGM
           UFS->(dbseek(cCGM))
           @ prow()+2  ,00 say chr(9)+chr(9)+"TOTAIS DO ESTADO.: "+UFS->Descricao
           @ prow()    ,pcol() say chr(9)+chr(9)+transf(nUF_QUANT,"@R 999999")
           @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
           @ prow()    ,pcol() say chr(9)+cCGM
           @ prow()+1,00 say ""
           @ prow()+1,00 say ""
           cCGM := FI536->Estado

           nUF_QUANT := 0
           nUF_VALOR := 0
       endif


   enddo

   PROD->(Dbseek(cPROD))
   cDESC_PROD := PROD->Cod_ass + chr(9) + left(PROD->Cod_fabr,7) + chr(9) +left(PROD->Descricao,20)+ chr(9)+left(PROD->Marca,15)
   @ prow()+1,00     say cDESC_PROD            //descricao do produto
   @ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")
   @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")
   @ prow()  ,pcol() say chr(9)+cCGM
   nQUANT := 0
   nTOTAL := 0


   UFS->(dbseek(cCGM))
   @ prow()+2  ,00 say chr(9)+chr(9)+"TOTAIS DO ESTADO.: "+UFS->Descricao
   @ prow()    ,pcol() say chr(9)+chr(9)+transf(nUF_QUANT,"@R 999999")
   @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
   @ prow()    ,pcol() say chr(9)+cCGM
   @ prow()+1,00 say ""
   @ prow()+1,00 say ""
   nUF_QUANT := 0
   nUF_VALOR := 0


   @ prow()+1,00 say replicate("-",134)
   @ prow()+1,60 say transf(nTOT_QUANT,"@R 9999999")
   @ prow()  ,73 say transf(nTOT_GER,"@E 99,999,999.99")

   nQUANT := 0
   nTOTAL := 0

   qstopprn(.F.)

return



