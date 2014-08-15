/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RANKING DE CLIENTES
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2007
// OBS........:
// ALTERACOES.:

function cl559
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private cTIPO  := space(1)
private dINI
private dFIM
private cUFS    := space(2)
private cCGM    := space(6)
private cREPRES := space(5)
private cCFOP   := ""
private aEDICAO := {}             // vetor para os campos de entrada de dados
private sBLOC1  := qlbloc("B559B","QBLOC.GLO")

if ! quse(XDRV_CL,"FI559A",{"FI559A"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_CL,"FI559B",{"FI559B"},"E")
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

   qlbloc(5,0,"B559A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cREPRES := space(5)
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
              qrsay(XNIVEL+1, "Todos os Representantes.....")
           else
              if ! REPRES->(Dbseek(cREPRES))
                 qmensa("CLiente n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(REPRES->Razao,30))
              endif
           endif


      case cCAMPO == "UFS"

           qrsay(XNIVEL,cUFS)

           if empty(cUFS)
              qrsay(XNIVEL+1, "Todos os Estados.......")
           else
              if ! UFS->(Dbseek(cUFS))
                 qmensa("Estado n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(UFS->Descricao,30))
              endif
           endif

      case cCAMPO == "CGM"

           qrsay(XNIVEL,cCGM)

           if empty(cCGM)
              qrsay(XNIVEL+1, "Todas as Cidades.......")
           else
              if ! CGM->(Dbseek(cCGM))
                 qmensa("Municipio n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CGM->Municipio,30))
              endif
           endif


      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"1234",{"1 - Clientes","2 - Representante","3 - Estado","4 - Cidade"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
//local cCFOP := ""

   // CRIA TITULO DO RELATORIO ______________________________________________

   cCFOP := "510-511-512-540-610-611-612-640-120-220"
   cTITULO := "RANKING DE VENDAS POR CLIENTE" + " de " +   dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. Dt_emissao <= dFIM .and. left(Cod_cfop,3) $ cCFOP .and. ! Cancelado .and. ! (empty(Num_fatura) .and. Es== "S") .and. Es $ "S*E" }))

   FAT->(dbsetorder(6)) // data de saida
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))
return .T.

static function i_impressao

   FI559A->(__dbzap())
   FI559B->(__dbzap())

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

   FAT->(DbclearFilter())
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

if cTIPO == "1"
   i_1impre_prn()
endif

if cTIPO == "2"
   i_2impre_prn()
endif

if cTIPO == "3"
   i_3impre_prn()
endif

if cTIPO == "4"
   i_4impre_prn()
endif


return


static function i_impre_xls

if cTIPO == "1"
   i_1impre_xls()
endif

if cTIPO == "2"
   i_2impre_xls()
endif

if cTIPO == "3"
   i_3impre_xls()
endif

if cTIPO == "4"
   i_4impre_xls()
endif

return

static function i_1impre_prn
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local zCLI       := ""
    local lTEM := .F.

   cCFOP := "510-511-512-540-610-611-612-640-120-220"
   cTITULO := "RANKING DE VENDAS POR CLIENTE" + " de " +   dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. Dt_emissao <= dFIM .and. left(Cod_cfop,3) $ cCFOP .and. ! Cancelado .and. ! (empty(Num_fatura) .and. Es== "S") .and. Es $ "S*E" }))

   FAT->(dbsetorder(6)) // data de saida
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   FAT->(Dbgotop())
   zCLI := FAT->Cod_cli
   nTOTAL := 0


   do while ! FAT->(eof()) // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(DbSeek(CLI1->Cgm_ent))

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          if FAT->Es == "S"
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
          else
             nTOTAL -= (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo


      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      nTOTAL := nTOTAL - nDESC
      nDESC := 0

      FAT->(dbskip())

      if FAT->Cod_cli != zCLI
         if FI559B->(qappend())
            replace Fi559B->Coringa with ""
            replace Fi559B->Cod_cli with zCLI
            replace FI559B->Total   with nTotal
            replace FI559B->Estado  with CGM->Estado
         endif
         zCLI   := FAT->Cod_cli
         nTOTAL := 0
      endif


   enddo

   FI559B->(dbcommit())
   FI559B->(dbsetorder(1))
   FI559B->(dbgotop())


   nTOTAL := 0
   zCLI   := ""

   zCLI  := alltrim(FI559B->Cod_cli)

   do while  FI559B->(!eof())

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          @prow()+1,0 say XCOND1
          qpageprn()
          qcabecprn(cTITULO,136)
          @ prow()+1,0 say "Cod.  Cliente                                                                    Total                       UF"

          @ prow()+1,0 say replicate("-",134)

       endif

       nTOT_GER += FI559B->total

       @ prow()+1, 00  say alltrim(FI559B->Cod_cli)                            //Codigo do Cliente
       CLI1->(Dbseek(alltrim(FI559B->Cod_cli)))
       @ prow()  , 07   say left(CLI1->Razao,50)                      //Razao do Cliente
       @ prow()  , 80   say transf(FI559B->Total,"@E 9,999,999.99")  //Total do Cliente
       CGM->(Dbseek(Cli1->cgm_ent))
       @ prow()  , 110  say CGM->Estado

       FI559B->(dbskip())


   enddo

   @ prow()+1,00 say replicate("-",134)
   @ prow()+1,79 say transf(nTOT_GER,"@E 99,999,999.99")

   nTOTAL := 0
   nPERC  := 0

   qstopprn(.F.)

return

static function i_2impre_prn
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aREP       := {}
    local asREP      := {}
    local zCLI       := ""
    local zREPRES    := ""
    local lTEM := .F.
    local bFATFIL

   cCFOP := "510-511-512-540-610-611-612-640-120-220"
   cTITULO := "RANKING DE CLIENTES POR REPRESENTANTE" + " de " +   dtoc(dINI) + " a " + dtoc(dFIM)

//    bFATFIL := {|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and.  (!empty(FAT->Num_fatura) .and. FAT->Es == "S") .and. FAT->Es $ "S*E" }
   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and. ! (empty(FAT->Num_fatura) .and. Es == "S") .and. FAT->Es $ "S*E" .and. iif(!empty(cREPRES),FAT->cod_repres == cREPRES,)}))

   qmensa("")

   set softseek on
   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   zCLI := FAT->Cod_cli
   nTOTAL := 0


   do while ! FAT->(eof()) //.and. eval(bFATFIL) // condicao principal de loop

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          if FAT->Es == "S"
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
          else
             nTOTAL -= (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo


      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      nTOTAL := nTOTAL - nDESC

      if FI559A->(qappend())
         replace Fi559A->Coringa with FAT->Cod_repres
         replace Fi559A->Cod_cli with FAT->Cod_cli
         replace Fi559A->Total   with nTotal
         replace Fi559A->Estado  with CGM->Estado
      endif

      lTEM := .T.

      nTOTAL := 0

      FAT->(dbskip())


   enddo

   FI559A->(dbcommit())

   FI559A->(dbsetorder(1))
   FI559A->(dbgotop())


   nTOTAL := 0
   zCLI   := ""



   //asFAT := asort(aFAT,,,{|x,y| x[1]+X[2] > y[1]+y[2] })
   //aFAT:= {}

   zREPRES  := alltrim(FI559A->Coringa)
   zCLI     := FI559A->Cod_cli

   do while  ! FI559A->(eof())


      nTOTAL += FI559A->Total


      FI559A->(dbskip())

      if zCLI != FI559A->cod_cli
         if FI559B->(qappend())
            replace FI559B->Coringa with zREPRES
            replace FI559B->Cod_cli with zCLI
            replace FI559B->Total   with nTotal
         endif
         nTOTAL := 0
         zCLI    := FI559A->Cod_cli
         zREPRES := alltrim(FI559A->coringa)
      endif

   enddo

   //if FI559B->(qappend())
   //   replace FI559B->Coringa with zREPRES
   //   replace FI559B->Cod_cli with zCLI
   //   replace FI559B->Total   with nTotal
   //endif

   nTOTAL := 0
   zCLI    := ""
   zREPRES := ""

   FI559B->(dbcommit())
   FI559B->(dbsetorder(1))
   FI559B->(dbgotop())


   //asFAT := asort(aFAT,,,{|x,y| x[1]+transform(X[3],"@E 9,999,999.99") > y[1]+transform(y[3],"@E 9,999,999.99") })
   //aFAT:= {}

   zREPRES  := alltrim(FI559B->Coringa)

   do while  ! FI559B->(eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND1
         qpageprn()
         qcabecprn(cTITULO,136)
         @ prow()+1,0 say "Cod.  Cliente                                                                    Total                       UF"
         @ prow()+1,0 say replicate("-",134)

      endif

      @ prow()+1, 00  say FI559B->Coringa                            //Codigo do Cliente
      CLI1->(Dbseek(FI559B->Cod_cli))
      @ prow()  , 07  say left(CLI1->Razao,50)                      //Razao do Cliente
      @ prow()  , 80  say transf(FI559B->total,"@E 9,999,999.99")  //Total do Cliente
      CGM->(Dbseek(Cli1->cgm_ent))
      @ prow()  , 110  say CGM->Estado


       nTOTAL += FI559B->Total

       FI559B->(dbskip())

       if alltrim(FI559B->Coringa) != alltrim(zREPRES)
          if REPRES->(dbseek(zREPRES)) .and. nTOTAL > 0
             @ prow()+1,00 say "Total do Representante.: "+left(REPRES->Razao,35)
             @ prow()  ,80 say transform(nTOTAL,"@E 9,999,999.99")
             @ prow()+1,00 say replicate("-",132)
             @ prow()+1,00 say ""
             aadd(aREP,{zREPRES,nTOTAL})
          endif
          nTOTAL := 0
          zREPRES := alltrim(FI559B->Coringa)
       endif


   enddo

   if REPRES->(dbseek(zREPRES)) .and. nTOTAL > 0
      @ prow()+1,00 say "Total do Representante.: "+left(REPRES->Razao,35)
      @ prow()  ,80 say transform(nTOTAL,"@E 9,999,999.99")
      @ prow()+1,00 say replicate("-",132)
      aadd(aREP,{zREPRES,nTOTAL})
   endif

   nTOTAL  := 0
   zCLI    := ""
   zREPRES := ""


   eject // Para imprimir Resumo
   XPAGINA := 0


   asREP := asort(aREP,,,{|x,y| x[2] > y[2] })

   nCONT := 1


   do while  nCONT <= len(asREP)

      if ! qlineprn() ; exit ; endif
      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn("Resumo dos Representantes",134)
         @ prow()+1,0 say  "Codigo Representante                                                     Valor "
         @ prow()+1,0 say replicate("-",134)
      endif

      REPRES->(dbseek(asREP[nCONT,1]))
      @ prow()+1,00 say asREP[nCONT,1]
      @ prow()  ,08 say left(REPRES->Razao,50)
      @ prow()  ,79 say transform(asREP[nCONT,2],"@E 99,999,999.99")

      nCONT++

      if nCONT > len(asREP)
         nCONT := len(asREP)
         exit
      endif

   enddo

   aREP  := {}
   asREP := {}


   qstopprn(.F.)

return


static function i_3impre_prn
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aREP       := {}
    local asREP      := {}
    local zCLI       := ""
    local zREPRES    := ""
    local lTEM := .F.
    local bFATFIL
    local zUF := ""

   cCFOP := "510-511-512-540-610-611-612-640-120-220"
   cTITULO := "RANKING DE CLIENTES POR ESTADO" + " de " +   dtoc(dINI) + " a " + dtoc(dFIM)

//    bFATFIL := {|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and.  (!empty(FAT->Num_fatura) .and. FAT->Es == "S") .and. FAT->Es $ "S*E" }
   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and. ! (empty(FAT->Num_fatura) .and. Es == "S") .and. FAT->Es $ "S*E" }))

   qmensa("")

   set softseek on
   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   zCLI := FAT->Cod_cli
   nTOTAL := 0


   do while ! FAT->(eof()) //.and. eval(bFATFIL) // condicao principal de loop

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))


      if ! empty(cUFS)
         if alltrim(CGM->Estado) != alltrim(cUFS)
            FAT->(dbskip())
            loop
         endif
      endif

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          if FAT->Es == "S"
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
          else
             nTOTAL -= (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo


      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      nTOTAL := nTOTAL - nDESC

      if FI559A->(qappend())
         replace Fi559A->Coringa with CGM->Estado
         replace Fi559A->Cod_cli with FAT->Cod_cli
         replace Fi559A->Total   with nTotal
      endif

      nTOTAL := 0

      FAT->(dbskip())

   enddo

   FI559A->(dbcommit())
   FI559A->(dbsetorder(1))
   FI559A->(dbgotop())


   nTOTAL := 0
   zCLI   := ""

   zCLI     := FI559A->Cod_cli
   zUF      := alltrim(FI559A->Coringa)
   nCONT := 1

   do while  ! FI559A->(eof())


      nTOTAL += FI559A->Total


      FI559A->(dbskip())

      if zCLI != FI559A->Cod_cli

         if FI559B->(qappend())
            replace FI559B->Coringa with zUF
            replace FI559B->Cod_cli with zCLI
            replace FI559B->Total   with nTotal
         endif
         nTOTAL := 0
         zCLI    := FI559A->Cod_cli
         zUF     := alltrim(FI559A->Coringa)
      endif

   enddo

   nTOTAL  := 0
   zCLI    := ""
   zUF     := ""
   FI559B->(dbcommit())
   FI559B->(dbsetorder(1))
   FI559B->(dbgotop())

   zUF  := alltrim(FI559B->Coringa)

   do while ! FI559B->(eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND1
         qpageprn()
         qcabecprn(cTITULO,136)
         @ prow()+1,0 say "Estado  Cliente                                                                    Total"
         @ prow()+1,0 say replicate("-",134)

      endif

      @ prow()+1, 00  say alltrim(FI559B->Coringa)                            //Codigo do Cliente
      CLI1->(Dbseek(FI559B->cod_cli))
      @ prow()  , 09  say left(CLI1->Razao,50)                      //Razao do Cliente
      @ prow()  , 80  say transf(FI559B->total,"@E 9,999,999.99")  //Total do Cliente
      CGM->(Dbseek(Cli1->cgm_ent))


       nTOTAL += FI559B->total


       FI559B->(dbskip())

       if zUF != alltrim(FI559B->Coringa)
          UFS->(dbseek(zUF))
          @ prow()+1,00 say "Total do Estado.: "+left(UFS->Descricao,35)
          @ prow()  ,80 say transform(nTOTAL,"@E 9,999,999.99")
          @ prow()+1,00 say replicate("-",132)
          @ prow()+1,00 say ""
          aadd(aREP,{zUF,nTOTAL})
          nTOTAL := 0
          zUF := alltrim(FI559B->Coringa)
       endif

   enddo

   aadd(aREP,{zUF,nTOTAL})
   UFS->(dbseek(zUF))
   @ prow()+1,00 say "Total do Estado.: "+left(UFS->Descricao,35)
   @ prow()  ,80 say transform(nTOTAL,"@E 9,999,999.99")
   @ prow()+1,00 say replicate("-",132)
   nTOTAL := 0

   nTOTAL  := 0
   zCLI    := ""
   zUF     := ""

   eject // Para imprimir Resumo
   XPAGINA := 0


   asREP := asort(aREP,,,{|x,y| x[2] > y[2] })

   nCONT := 1


   do while  nCONT <= len(asREP)

      if ! qlineprn() ; exit ; endif
      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn("Resumo dos Estados",134)
         @ prow()+1,0 say  "Sigla Estado                                                     Valor "
         @ prow()+1,0 say replicate("-",134)
      endif

      UFS->(dbseek(asREP[nCONT,1]))
      @ prow()+1,00 say asREP[nCONT,1]
      @ prow()  ,08 say left(UFS->Descricao,50)
      @ prow()  ,79 say transform(asREP[nCONT,2],"@E 99,999,999.99")

      nCONT++

      if nCONT > len(asREP)
         nCONT := len(asREP)
         exit
      endif

   enddo

   aREP  := {}
   asREP := {}


   qstopprn(.F.)

return

static function i_4impre_prn
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aREP       := {}
    local asREP      := {}
    local zCLI       := ""
    local zREPRES    := ""
    local lTEM := .F.
    local bFATFIL
    local zCGM := ""

   cCFOP := "510-511-512-540-610-611-612-640-120-220"
   cTITULO := "RANKING DE CLIENTES POR CIDADE" + " de " +   dtoc(dINI) + " a " + dtoc(dFIM)

//    bFATFIL := {|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and.  (!empty(FAT->Num_fatura) .and. FAT->Es == "S") .and. FAT->Es $ "S*E" }
//   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and. ! (empty(FAT->Num_fatura) .and. Es == "S") .and. FAT->Es $ "S*E" }))
   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and. ! (empty(FAT->Num_fatura) .and. Es == "S") .and. FAT->Es $ "S*E" .and. iif(!empty(cREPRES),FAT->cod_repres == cREPRES,)}))


   qmensa("")

   set softseek on
   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   zCLI := FAT->Cod_cli
   nTOTAL := 0


   do while ! FAT->(eof()) //.and. eval(bFATFIL) // condicao principal de loop

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))

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

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          if FAT->Es == "S"
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
          else
             nTOTAL -= (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo


      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      nTOTAL := nTOTAL - nDESC

      if FI559A->(qappend())
         replace Fi559A->Coringa with CGM->Codigo
         replace Fi559A->Cod_cli with FAT->Cod_cli
         replace Fi559A->Total   with nTotal
      endif

      nTOTAL := 0

      FAT->(dbskip())


   enddo

   FI559A->(dbcommit())
   FI559A->(dbsetorder(1))
   FI559A->(dbgotop())



   nTOTAL := 0
   zCLI   := ""

   zCLI      := FI559A->Cod_cli
   zCGM      := alltrim(FI559A->Coringa)

   nCONT := 1

   do while FI559A->(!eof())


      nTOTAL += FI559A->Total


      FI559A->(dbskip())

      if zCLI != alltrim(FI559A->Cod_cli)
         //aadd(aFAT,{zCGM,zCLI,nTOTAL})
         if FI559B->(qappend())
            replace FI559B->Coringa with zCGM
            replace FI559B->Cod_cli with zCLI
            replace FI559B->Total   with nTotal
         endif

         nTOTAL := 0
         zCLI     := alltrim(FI559A->Cod_cli)
         zCGM     := alltrim(FI559A->Coringa)
      endif

   enddo

   nTOTAL  := 0
   zCLI    := ""
   zCGM     := ""

   FI559B->(dbcommit())
   FI559B->(dbsetorder(1))
   FI559B->(dbgotop())


   //asFAT := asort(aFAT,,,{|x,y| x[1]+transform(X[3],"@E 9,999,999.99") > y[1]+transform(y[3],"@E 9,999,999.99") })
   //aFAT:= {}

   zCGM  := alltrim(FI559B->Coringa)
   nCONT := 1

   do while  FI559B->(!eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND1
         qpageprn()
         qcabecprn(cTITULO,136)
         @ prow()+1,0 say "Cidade                    Cliente                                                                Total"
         @ prow()+1,0 say replicate("-",134)

      endif

      CLI1->(Dbseek(FI559B->Cod_cli))
      CGM->(Dbseek(Cli1->cgm_ent))

      @ prow()+1, 00  say left(CGM->Municipio,25)                            //Codigo do Cliente
      @ prow()  , 27  say left(CLI1->Razao,50)                      //Razao do Cliente
      @ prow()  , 80  say transf(FI559B->Total,"@E 9,999,999.99")  //Total do Cliente
      @ prow()  , 110  say CGM->Estado  //Total do Cliente



       nTOTAL += FI559B->Total


       FI559B->(dbskip())

       if zCGM != alltrim(FI559B->Coringa)
          CGM->(dbseek(zCGM))
          @ prow()+1,00 say "Total da Cidade.: "+left(CGM->Municipio,35)
          @ prow()  ,80 say transform(nTOTAL,"@E 9,999,999.99")
          @ prow()+1,00 say replicate("-",132)
          @ prow()+1,00 say ""
          aadd(aREP,{zCGM,nTOTAL})
          nTOTAL := 0
          zCGM := (FI559B->Coringa)
       endif

   enddo

   aadd(aREP,{zCGM,nTOTAL})
   CGM->(dbseek(zCGM))
   @ prow()+1,00 say "Total da Cidade.: "+left(CGM->Municipio,35)
   @ prow()  ,80 say transform(nTOTAL,"@E 9,999,999.99")
   @ prow()+1,00 say replicate("-",132)
   nTOTAL := 0

   nTOTAL  := 0
   zCLI    := ""
   zCGM     := ""

   eject // Para imprimir Resumo
   XPAGINA := 0


   asREP := asort(aREP,,,{|x,y| x[2] > y[2] })

   nCONT := 1


   do while  nCONT <= len(asREP)

      if ! qlineprn() ; exit ; endif
      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn("Resumo dos Municipios",134)
         @ prow()+1,0 say  "Codigo Municipio                         Estado     Valor "
         @ prow()+1,0 say replicate("-",134)
      endif

      CGM->(dbseek(asREP[nCONT,1]))
      @ prow()+1,00 say asREP[nCONT,1]
      @ prow()  ,08 say left(CGM->Municipio,30)
      @ prow()  ,42 say left(CGM->Estado,2)
      @ prow()  ,79 say transform(asREP[nCONT,2],"@E 99,999,999.99")

      nCONT++

      if nCONT > len(asREP)
         nCONT := len(asREP)
         exit
      endif

   enddo

   aREP  := {}
   asREP := {}


   qstopprn(.F.)

return



static function i_1impre_xls
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local zCLI       := ""
    local lTEM := .F.

   cCFOP := "510-511-512-540-610-611-612-640-120-220"
   cTITULO := "RANKING DE VENDAS POR CLIENTE" + " de " +   dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

//   FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. Dt_emissao <= dFIM .and. left(Cod_cfop,3) $ cCFOP .and. ! Cancelado .and. ! (empty(Num_fatura) .and. Es== "S") .and. Es $ "S*E" }))
   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and. ! (empty(FAT->Num_fatura) .and. Es == "S") .and. FAT->Es $ "S*E" .and. iif(!empty(cREPRES),FAT->cod_repres == cREPRES,)}))


   FAT->(dbsetorder(6)) // data de saida
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   FAT->(Dbgotop())
   zCLI := FAT->Cod_cli
   nTOTAL := 0


   do while ! FAT->(eof()) // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(DbSeek(CLI1->Cgm_ent))

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          if FAT->Es == "S"
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
          else
             nTOTAL -= (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo


      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      nTOTAL := nTOTAL - nDESC
      nDESC := 0

      FAT->(dbskip())

      if FAT->Cod_cli != zCLI
         if FI559B->(qappend())
            replace Fi559B->Coringa with ""
            replace Fi559B->Cod_cli with zCLI
            replace FI559B->Total   with nTotal
            replace FI559B->Estado  with CGM->Estado
         endif
         zCLI   := FAT->Cod_cli
         nTOTAL := 0
      endif


   enddo

   FI559B->(dbcommit())
   FI559B->(dbsetorder(1))
   FI559B->(dbgotop())


   nTOTAL := 0
   zCLI   := ""

   zCLI  := alltrim(FI559B->Cod_cli)

   do while  FI559B->(!eof())

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0
          qpageprn()
          @ prow()+1,0 say chr(9)+cTITULO+"  559"
          @ prow()+1,0 say "Cod" + chr(9) + "Cliente" + chr(9) + "Total"+chr(9)+"VIC"
          @ prow()+1,0 say ""
       endif

       nTOT_GER += FI559B->total

       @ prow()+1, 00  say alltrim(FI559B->Cod_cli)+chr(9)                            //Codigo do Cliente
       CLI1->(Dbseek(alltrim(FI559B->Cod_cli)))
       @ prow()  , pcol()  say left(CLI1->Razao,50)+chr(9)                      //Razao do Cliente
       @ prow()  , pcol()  say transf(FI559B->total,"@E 9,999,999.99")+chr(9)  //Total do Cliente
       @ prow()  , pcol()  say qabrev(CLI1->Categoria,'VPN FC',{'VIC','Potencial',"Normal","Nao Informado","Final","Problematico"})

       FI559B->(dbskip())


   enddo

   @ prow()+2,00 say chr(9)+chr(9)+transf(nTOT_GER,"@E 99,999,999.99")

   nTOTAL := 0
   nPERC  := 0

   qstopprn(.F.)

return

static function i_2impre_xls
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aREP       := {}
    local asREP      := {}
    local zCLI       := ""
    local zREPRES    := ""
    local lTEM := .F.
    local bFATFIL

   cCFOP := "510-511-512-540-610-611-612-640-120-220"
   cTITULO := "RANKING DE CLIENTES POR REPRESENTANTE" + " de " +   dtoc(dINI) + " a " + dtoc(dFIM)

//    bFATFIL := {|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and.  (!empty(FAT->Num_fatura) .and. FAT->Es == "S") .and. FAT->Es $ "S*E" }
   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and. ! (empty(FAT->Num_fatura) .and. Es == "S") .and. FAT->Es $ "S*E" .and. iif(!empty(cREPRES),FAT->cod_repres == cREPRES,)}))

   qmensa("")

   set softseek on
   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   zCLI := FAT->Cod_cli
   nTOTAL := 0


   do while ! FAT->(eof()) //.and. eval(bFATFIL) // condicao principal de loop

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          if FAT->Es == "S"
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
          else
             nTOTAL -= (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo


      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      nTOTAL := nTOTAL - nDESC

      //aadd(aFAT,{FAT->Cod_repres,FAT->Cod_cli,nTOTAL,CGM->Estado})
      if FI559A->(qappend())
         replace Fi559A->Coringa with FAT->Cod_repres
         replace Fi559A->Cod_cli with FAT->Cod_cli
         replace Fi559A->Total   with nTotal
         replace Fi559A->Estado  with CGM->Estado
      endif

      lTEM := .T.

      nTOTAL := 0

      FAT->(dbskip())


   enddo


   FI559A->(dbcommit())
   FI559A->(dbgotop())

   nTOTAL := 0
   zCLI   := ""



   //classifica a matriz por descricao do produto + Estado
   //asFAT := asort(aFAT,,,{|x,y| x[1]+X[2] > y[1]+y[2] })
   //aFAT:= {}

   zREPRES  := alltrim(FI559A->Coringa)
   zCLI     := FI559A->Cod_cli
   nCONT := 1
   do while  ! FI559A->(eof())


      nTOTAL += FI559A->Total


      Fi559A->(dbskip())

      if zCLI != FI559A->Cod_cli
         if FI559B->(qappend())
            replace FI559B->Coringa with zREPRES
            replace FI559B->Cod_cli with zCLI
            replace FI559B->Total   with nTotal
         endif

         nTOTAL := 0
         zCLI    := FI559A->Cod_cli
         zREPRES := alltrim(FI559A->Coringa)
      endif

   enddo

   nTOTAL  := 0
   zCLI    := ""
   zREPRES := ""

   FI559B->(dbcommit())
   FI559B->(dbsetorder(1))
   Fi559B->(dbgotop())

    zREPRES  := alltrim(FI559B->Coringa)
    nCONT := 1

    do while ! FI559B->(eof())

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 //.or. prow() > K_MAX_LIN
          qpageprn()
          @ prow()+1,0 say chr(9)+cTITULO+" 559"
          @ prow()+1,0 say "Cod. " + chr(9) + "Cliente"+chr(9)+"Total"+chr(9)+"UF"+chr(9)+"VIC"
          @ prow()+1,0 say ""

       endif

       @ prow()+1, 00     say alltrim(FI559B->Coringa)                            //Codigo do Cliente
       CLI1->(Dbseek(FI559B->Cod_cli))
       @ prow()  , pcol() say chr(9)+left(CLI1->Razao,50)                      //Razao do Cliente
       @ prow()  , pcol() say chr(9)+transf(FI559B->Total,"@E 9,999,999.99")  //Total do Cliente
       CGM->(Dbseek(Cli1->cgm_ent))
       @ prow()  , pcol() say chr(9)+CGM->Estado
       @ prow()  , pcol()  say chr(9)+qabrev(CLI1->Categoria,'VPN FC',{'VIC','Potencial',"Normal","Nao Informado","Final","Problematico"})




        nTOTAL += FI559B->Total


        FI559B->(Dbskip())

        if zREPRES != alltrim(FI559B->Coringa)
           if REPRES->(dbseek(zREPRES)) .and. nTOTAL > 0
              @ prow()+1,00     say chr(9)+"Total do Representante.: "+left(REPRES->Razao,35)
              @ prow()  ,pcol() say chr(9)+transform(nTOTAL,"@E 9,999,999.99")
              @ prow()+1,00 say ""
              @ prow()+1,00 say ""
              aadd(aREP,{zREPRES,nTOTAL})
           endif
           nTOTAL := 0
           zREPRES := alltrim(FI559B->Coringa)
        endif

    enddo

    if REPRES->(dbseek(zREPRES)) .and. nTOTAL > 0
       aadd(aREP,{zREPRES,nTOTAL})
       @ prow()+1,00     say chr(9)+"Total do Representante.: "+left(REPRES->Razao,35)
       @ prow()  ,pcol() say chr(9)+transform(nTOTAL,"@E 9,999,999.99")
    endif

    @ prow()+1,00 say ""
    @ prow()+1,00 say ""
    @ prow()+1,00 say ""

    nTOTAL := 0

    nTOTAL  := 0
    zCLI    := ""
    zREPRES := ""

    asREP := asort(aREP,,,{|x,y| x[2] > y[2] })

    nCONT := 1


    do while  nCONT <= len(asREP)

       if ! qlineprn() ; exit ; endif
       if XPAGINA == 0 //.or. prow() > K_MAX_LIN
          qpageprn()
          @ prow()+1,0 say chr(9)+"Resumo dos Representantes"
          @ prow()+1,0 say  "Codigo"+chr(9)+"Representante"+chr(9)+"Valor"
          @ prow()+1,0 say ""
       endif

       REPRES->(dbseek(asREP[nCONT,1]))
       @ prow()+1,00 say asREP[nCONT,1]
       @ prow()  ,pcol() say chr(9)+left(REPRES->Razao,50)
       @ prow()  ,pcol() say chr(9)+transform(asREP[nCONT,2],"@E 99,999,999.99")

       nCONT++

       if nCONT > len(asREP)
          nCONT := len(asREP)
          exit
       endif

    enddo

    aREP  := {}
    asREP := {}




   qstopprn(.F.)

return


static function i_3impre_xls
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aREP       := {}
    local asREP      := {}
    local zCLI       := ""
    local zREPRES    := ""
    local lTEM := .F.
    local bFATFIL
    local zUF := ""

   cCFOP := "510-511-512-540-610-611-612-640-120-220"
   cTITULO := "RANKING DE CLIENTES POR ESTADO" + " de " +   dtoc(dINI) + " a " + dtoc(dFIM)

//    bFATFIL := {|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and.  (!empty(FAT->Num_fatura) .and. FAT->Es == "S") .and. FAT->Es $ "S*E" }
   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and. ! (empty(FAT->Num_fatura) .and. Es == "S") .and. FAT->Es $ "S*E" }))

   qmensa("")

   set softseek on
   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   zCLI := FAT->Cod_cli
   nTOTAL := 0


   do while ! FAT->(eof()) //.and. eval(bFATFIL) // condicao principal de loop

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))


      if ! empty(cUFS)
         if alltrim(CGM->Estado) != alltrim(cUFS)
            FAT->(dbskip())
            loop
         endif
      endif

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          if FAT->Es == "S"
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
          else
             nTOTAL -= (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo


      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      nTOTAL := nTOTAL - nDESC


      if FI559A->(qappend())
         replace Fi559A->Coringa with CGM->Estado
         replace Fi559A->Cod_cli with FAT->Cod_cli
         replace Fi559A->Total   with nTotal
      endif

      lTEM := .T.

      nTOTAL := 0

      FAT->(dbskip())


   enddo


   FI559A->(dbcommit())
   FI559A->(dbsetorder(1))
   FI559A->(dbgotop())

   nTOTAL := 0
   zCLI   := ""

   zCLI     := FI559A->Cod_cli

   zUF      := alltrim(FI559A->Coringa)

   do while Fi559A->(!eof())


      nTOTAL += FI559A->Total


      FI559A->(dbskip())

      if zCLI != FI559A->Cod_cli
         if FI559B->(qappend())
            replace FI559B->Coringa with zUF
            replace FI559B->Cod_cli with zCLI
            replace FI559B->Total   with nTotal
         endif

         nTOTAL := 0
         zCLI    := FI559A->Cod_cli
         zUF     := alltrim(FI559A->Coringa)
      endif

   enddo

   FI559B->(dbcommit())
   FI559B->(dbsetorder(1))
   FI559B->(dbgotop())


   nTOTAL  := 0
   zCLI    := ""
   zUF     := ""

   zUF  := alltrim(FI559B->Coringa)

   do while  FI559B->(!eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0 say chr(9)+cTITULO+" 559"
         @ prow()+1,0 say "Estado"+chr(9)+"Cliente"+chr(9)+"Total"+chr(9)+"VIC"
         @ prow()+1,0 say ""
      endif

      @ prow()+1, 00  say alltrim(FI559B->Coringa)                            //Codigo do Cliente
      CLI1->(Dbseek(FI559B->Cod_cli))
      @ prow()  , pcol()  say chr(9)+left(CLI1->Razao,50)                      //Razao do Cliente
      @ prow()  , pcol()  say chr(9)+transf(FI559B->Total,"@E 9,999,999.99")  //Total do Cliente
      @ prow()  , pcol()  say chr(9)+qabrev(CLI1->Categoria,'VPN FC',{'VIC','Potencial',"Normal","Nao Informado","Final","Problematico"})


      CGM->(Dbseek(Cli1->cgm_ent))


       nTOTAL += FI559B->Total


       FI559B->(dbskip())

       if zUF != alltrim(FI559B->Coringa)
          UFS->(dbseek(zUF))
          @ prow()+1,00 say chr(9)+"Total do Estado.: "+left(UFS->Descricao,35)
          @ prow()  ,pcol() say chr(9)+transform(nTOTAL,"@E 9,999,999.99")
          @ prow()+1,00 say ""
          @ prow()+1,00 say ""
          aadd(aREP,{zUF,nTOTAL})
          nTOTAL := 0
          zUF := alltrim(FI559B->Coringa)
       endif

   enddo

   aadd(aREP,{zUF,nTOTAL})
   UFS->(dbseek(zUF))
   @ prow()+1,00 say chr(9)+"Total do Estado.: "+left(UFS->Descricao,35)
   @ prow()  ,pcol() say chr(9)+transform(nTOTAL,"@E 9,999,999.99")

   @ prow()+1,00 say ""
   @ prow()+1,00 say ""
   @ prow()+1,00 say ""

   nTOTAL := 0
   zCLI    := ""
   zUF     := ""

   eject // Para imprimir Resumo
   XPAGINA := 0


   asREP := asort(aREP,,,{|x,y| x[2] > y[2] })

   nCONT := 1


   do while  nCONT <= len(asREP)

      if ! qlineprn() ; exit ; endif
      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0 say chr(9)+"Resumo dos Estados"
         @ prow()+1,0 say "Sigla"+chr(9)+"Estado"+chr(9)+"Valor"
         @ prow()+1,0 say ""
      endif

      UFS->(dbseek(asREP[nCONT,1]))
      @ prow()+1,00 say asREP[nCONT,1]
      @ prow()  ,pcol() say chr(9)+left(UFS->Descricao,50)
      @ prow()  ,pcol() say chr(9)+transform(asREP[nCONT,2],"@E 99,999,999.99")

      nCONT++

      if nCONT > len(asREP)
         nCONT := len(asREP)
         exit
      endif

   enddo

   aREP  := {}
   asREP := {}

   qstopprn(.F.)

return

static function i_4impre_xls
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aREP       := {}
    local asREP      := {}
    local zCLI       := ""
    local zREPRES    := ""
    local lTEM := .F.
    local bFATFIL
    local zCGM := ""

   cCFOP := "510-511-512-540-610-611-612-640-120-220"
   cTITULO := "RANKING DE CLIENTES POR CIDADE" + " de " +   dtoc(dINI) + " a " + dtoc(dFIM)

//    bFATFIL := {|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and.  (!empty(FAT->Num_fatura) .and. FAT->Es == "S") .and. FAT->Es $ "S*E" }
//   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and. ! (empty(FAT->Num_fatura) .and. Es == "S") .and. FAT->Es $ "S*E" }))

   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. left(FAT->Cod_cfop,3) $ cCFOP .and. ! FAT->Cancelado .and. ! (empty(FAT->Num_fatura) .and. Es == "S") .and. FAT->Es $ "S*E" .and. iif(!empty(cREPRES),FAT->cod_repres == cREPRES,)}))

   qmensa("")

   set softseek on
   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   zCLI := FAT->Cod_cli
   nTOTAL := 0


   do while ! FAT->(eof()) //.and. eval(bFATFIL) // condicao principal de loop

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))

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

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          if FAT->Es == "S"
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
          else
             nTOTAL -= (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
          endif
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo


      if CONFIG->Modelo_fat == "1"
         nDESC := 0
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      nTOTAL := nTOTAL - nDESC

      if FI559A->(qappend())
         replace Fi559A->Coringa with CGM->Codigo
         replace Fi559A->Cod_cli with FAT->Cod_cli
         replace Fi559A->Total   with nTotal
      endif

      nTOTAL := 0

      FAT->(dbskip())


   enddo

   FI559A->(dbcommit())
   FI559A->(dbsetorder(1))
   FI559A->(dbgotop())



   nTOTAL := 0
   zCLI   := ""



   zCLI     := FI559A->Cod_cli
   zCGM      := alltrim(FI559A->Coringa)


   do while FI559A->(!eof())

      nTOTAL += FI559A->Total


      FI559A->(dbskip())

      if zCLI != FI559A->Cod_cli
         if FI559B->(qappend())
            replace FI559B->Coringa with zCGM
            replace FI559B->Cod_cli with zCLI
            replace FI559B->Total   with nTotal
         endif

         nTOTAL := 0
         zCLI    := FI559A->Cod_cli
         zCGM     := alltrim(FI559A->Coringa)
      endif

   enddo

   FI559B->(dbcommit())
   FI559B->(dbsetorder(1))
   FI559B->(dbgotop())


   nTOTAL  := 0
   zCLI    := ""
   zCGM     := ""

   zCGM  := alltrim(FI559B->Coringa)
   nCONT := 1

   do while  FI559B->(!eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0 say chr(9)+cTITULO+" 559"
         @ prow()+1,0 say "Cidade"+chr(9)+"Cliente"+chr(9)+"Total"+chr(9)+"UF"+"VIC"
         @ prow()+1,0 say ""

      endif
      CLI1->(Dbseek(FI559B->Cod_cli))
      CGM->(Dbseek(Cli1->cgm_ent))

      @ prow()+1, 00  say left(CGM->Municipio,25)                            //Codigo do Cliente
      @ prow()  , pcol()  say chr(9)+left(CLI1->Razao,50)                      //Razao do Cliente
      @ prow()  , pcol()  say chr(9)+transf(FI559B->Total,"@E 9,999,999.99")  //Total do Cliente
      @ prow()  , pcol()  say chr(9)+CGM->Estado  //Total do Cliente
      @ prow()  , pcol()  say chr(9)+qabrev(CLI1->Categoria,'VPN FC',{'VIC','Potencial',"Normal","Nao Informado","Final","Problematico"})





       nTOTAL += FI559B->Total


       FI559B->(dbskip())


       if zCGM != alltrim(FI559B->Coringa)
          CGM->(dbseek(zCGM))
          @ prow()+1,00     say chr(9)+"Total da Cidade.: "+left(CGM->Municipio,35)
          @ prow()  ,pcol() say chr(9)+transform(nTOTAL,"@E 9,999,999.99")
          @ prow()+1,00 say ""
          @ prow()+1,00 say ""
          aadd(aREP,{zCGM,nTOTAL})
          nTOTAL := 0
          zCGM := alltrim(FI559B->Coringa)
       endif

   enddo

   aadd(aREP,{zCGM,nTOTAL})

   CGM->(dbseek(zCGM))
   @ prow()+1,00     say chr(9)+"Total da Cidade.: "+left(CGM->Municipio,35)
   @ prow()  ,pcol() say chr(9)+transform(nTOTAL,"@E 9,999,999.99")
   @ prow()+1,00 say ""
   @ prow()+1,00 say ""
   nTOTAL := 0

   nTOTAL  := 0
   zCLI    := ""
   zCGM     := ""


   asREP := asort(aREP,,,{|x,y| x[2] > y[2] })

   nCONT := 1

   XPAGINA := 0


   do while  nCONT <= len(asREP)

      if ! qlineprn() ; exit ; endif
      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0 say chr(9)+"Resumo das Cidades"
         @ prow()+1,0 say  "Codigo"+chr(9)+"Municipio"+chr(9)+"Estado"+chr(9)+"Valor"
         @ prow()+1,0 say ""
      endif

      CGM->(dbseek(asREP[nCONT,1]))
      @ prow()+1,00 say asREP[nCONT,1]
      @ prow()  ,pcol() say chr(9)+left(CGM->Municipio,30)
      @ prow()  ,pcol() say chr(9)+left(CGM->Estado,2)
      @ prow()  ,pcol() say chr(9)+transform(asREP[nCONT,2],"@E 99,999,999.99")

      nCONT++

      if nCONT > len(asREP)
         nCONT := len(asREP)
         exit
      endif

   enddo

   aREP  := {}
   asREP := {}

   qstopprn(.F.)

return



