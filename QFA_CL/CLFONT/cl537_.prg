/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS POR ESTADO (CLIENTE/PRODUTO/%)
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2005
// OBS........:
// ALTERACOES.:

function cl537
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private cUFS   := space(2)
private aEDICAO := {}             // vetor para os campos de entrada de dados

if ! quse(XDRV_CL,"FI537A",{"FI537A1"},"E")
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
   dINI := qinimes(date())
   dFIM := qfimmes(date())
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


   cTITULO := "LISTAGEM DE FATURAMENTO POR ESTADO" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

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
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   FI537A->(__dbzap())

   do while ! FAT->(eof()) .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      CGM->(dbseek(CLI1->Cgm_ent))

      //if ! empty(cUFSl) .and. CGM->Estado != alltrim(cUFS)
      //   FAT->(dbskip())
      //   loop
      //endif

      CLI1->(dbseek(FAT->Cod_cli))

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-120-220-640"
         FAT->(dbskip())
         loop
     endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          nTOTAL += q_soma_st()
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif
      nTOTAL := nTOTAL - nDESC
      CGM->(dbseek(CLI1->Cgm_ent))
      qmensa(left(CLI1->Razao,30)+ "  "+CGM->Estado)

      if ! empty(cUFS) .and. CGM->Estado <> cUFS
        // aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es})
      else
         if FI537A->(Qappend())
            replace FI537A->DT_emissao with FAT->dt_emissao
            replace FI537A->Cod_cli    with FAT->Cod_cli
            replace FI537A->Razao      with left(CLI1->razao,50)
            replace FI537A->Total      with nTOTAL
            replace FI537A->NF         with FAT->Num_fatura
            replace FI537A->Estado     with CGM->Estado
            replace FI537A->Cod_repres with FAT->Cod_repres
            replace FI537A->Es         with FAT->Es
         endif

        // aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es})
      endif
      nTOTAL := 0
      nDESC  := 0
      FAT->(dbskip())

   enddo

   FI537a->(dbcommit())

   FI537a->(dbgotop())

   zUFS  := FI537A->Estado

   do while  ! Fi537A->(eof())

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          @prow()+1,0 say XCOND1
          qpageprn()
          qcabecprn(cTITULO,136)
          @ prow()+1,0 say XCOND1 + "Data Emissao    Cod.  Cliente                                                          Total  Nota Fiscal   UF"

          @ prow()+1,0 say replicate("-",136)
       endif

       if FI537A->Es == "S"
          nUF_VALOR += FI537A->Total
          nTOT_GER  += FI537A->Total
        else
          nUF_VALOR -= FI537A->total
          nTOT_GER  -= FI537A->total
        endif

       @ prow()+1, 00  say dtoc(FI537A->dt_emissao)                 //Data de Emissao
       @ prow()  , 16  say FI537A->Cod_cli                         //Codigo do Cliente
       @ prow()  , 22  say FI537A->Razao                          //Razao do Cliente
       @ prow()  , 80  say transf(FI537A->Total,"@E 999,999.99")
       @ prow()  , 96  say FI537A->NF                              //Numero da Nota
       @ prow()  , 106 say FI537A->Estado                          //Numero da Nota

       if FI537A->Es != "S"
          @ prow()  , 115 say "Devolucao"
       endif

       FI537A->(dbskip())

       if FI537A->Estado != alltrim(zUFS)
           UFS->(dbseek(zUFS))
           @ prow()+2  ,00 say "TOTAIS DO ESTADO....: "+left(UFS->Descricao,30)
           @ prow()    , 79 say transf(nUF_VALOR,"@E 99,999,999.99")
           @ prow()+1,00 say replicate("-",136)
           @ prow()+1,00 say ""
           nUF_VALOR := 0
           nCOMISS := 0
       endif

       zUFS := FI537A->Estado

   enddo
   UFS->(dbseek(zUFS))
   @ prow()+2  ,00 say "TOTAIS DO ESTADO...: "+left(UFS->Descricao,30)
   @ prow()    ,79 say transf(nUF_VALOR,"@E 99,999,999.99")
   @ prow()    ,116 say transf(nCOMISS,"@E 99,999.99")


   @ prow()+1,00 say ""
   nUF_VALOR := 0


   @ prow()+1,00 say replicate("-",136)
   @ prow()  ,35 say "TOTAL GERAL...:"
   @ prow()  ,79 say transf(nTOT_GER,"@E 99,999,999.99")

   nQUANT := 0
   nTOTAL := 0
   nPERC  := 0

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
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
//   if ! qinitprn() ; return ; endif

   FI537A->(__dbzap())


   do while ! FAT->(eof()) .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      CGM->(dbseek(CLI1->Cgm_ent))

      //if ! empty(cUFS) .and. CGM->Estado != alltrim(cUFS)
      //   FAT->(dbskip())
      //   loop
      //endif

      CLI1->(dbseek(FAT->Cod_cli))

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220"
         FAT->(dbskip())
         loop
     endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          nTOTAL += q_soma_st()
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif
      nTOTAL := nTOTAL - nDESC
      CGM->(dbseek(CLI1->Cgm_ent))
      qmensa(left(CLI1->Razao,30)+ "  "+CGM->Estado)

      if ! empty(cUFS) .and. CGM->Estado <> cUFS
        // aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Cod_repres,FAT->Es})
      else
         if FI537A->(Qappend())
            replace FI537A->DT_emissao with FAT->dt_emissao
            replace FI537A->Cod_cli    with FAT->Cod_cli
            replace FI537A->Razao      with left(CLI1->razao,50)
            replace FI537A->Total      with nTOTAL
            replace FI537A->NF         with FAT->Num_fatura
            replace FI537A->Estado     with CGM->Estado
            replace FI537A->Cod_repres with FAT->Cod_repres
            replace FI537A->Es         with FAT->Es
         endif
      endif
      nTOTAL := 0
      nDESC  := 0
      FAT->(dbskip())

   enddo

   FI537a->(dbcommit())

   FI537a->(dbgotop())

   zUFS  := FI537A->Estado

   do while  ! FI537A->(eof())

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0
          qpageprn()
          @ prow()+1,0 say chr(9)+chr(9)+cTITULO
          @ prow()+1,0 say "Data Emissao"+chr(9)+"Cod."+chr(9)+"Cliente"+Chr(9)+"Total"+chr(9)+"Nota Fiscal"+chr(9)+"UF"

          @ prow()+1,0 say chr(9)+chr(9)+""
       endif

       if FI537A->Es == "S"
          nUF_VALOR += FI537A->Total
          nTOT_GER  += FI537A->Total
        else
          nUF_VALOR -= FI537A->total
          nTOT_GER  -= FI537A->total
        endif

       @ prow()+1, 00     say " "+dtoc(FI537A->dt_emissao)                 //Data de Emissao
       @ prow()  , pcol() say chr(9)+FI537A->Cod_cli                         //Codigo do Cliente
       @ prow()  , pcol() say chr(9)+FI537A->Razao                          //Razao do Cliente
       @ prow()  , pcol() say chr(9)+transf(FI537A->Total,"@E 999,999.99")
       @ prow()  , pcol() say chr(9)+FI537A->NF                              //Numero da Nota
       @ prow()  , pcol() say chr(9)+FI537A->Estado                          //Numero da Nota

       if FI537A->Es != "S"
          @ prow()  , pcol() say chr(9)+"Devolucao"
       endif

       FI537A->(dbskip())


      if FI537A->Estado != alltrim(zUFS)
          UFS->(dbseek(zUFS))
          @ prow()+1  ,00 say chr(9)+chr(9)+"TOTAIS DO ESTADO....: "+left(UFS->Descricao,30)
          @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
          @ prow()+1,0 say chr(9)+chr(9)+""
          nUF_VALOR := 0
          nCOMISS := 0
      endif

     zUFS := FI537A->Estado

   enddo
   UFS->(dbseek(zUFS))
   @ prow()+1  ,00 say chr(9)+chr(9)+"TOTAIS DO ESTADO....: "+left(UFS->Descricao,30)
   @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")


   @ prow()+1,0 say chr(9)+chr(9)+""
   nUF_VALOR := 0


   @ prow()+1,00 say chr(9)+chr(9)+"TOTAL GERAL...:"
   @ prow()  ,pcol() say chr(9)+transf(nTOT_GER,"@E 99,999,999.99")

   nQUANT := 0
   nTOTAL := 0
   nPERC  := 0

   qstopprn()

return



