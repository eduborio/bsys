/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Exportar arquivo p/ DIPJ Ficha 25 - (Mantra)
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO DE  2009
// OBS........:
// ALTERACOES.:

function cl576

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cDRIVE  := space(2)
private cTIPO   := space(2)
private sBLOC1  := qlbloc("B576B","QBLOC.GLO")
//private sBLOC2  := qlbloc("B425C","QBLOC.GLO")

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOC1)    } , "TIPO" })
//aadd(aEDICAO,{{ || qesco(-1,0,@cDRIVE,sBLOC2)   } , "DRIVE"})


//aadd(aEDICAO,{{ || lCONF := qconf("Confirma Exportacao de Arquivo DIPJ ?") },NIL})



do while .T.

   qlbloc(5,0,"B576A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI    := ctod("")
   dFIM    := ctod("")
   cTIPO   := space(2)
   cDRIVE := ""

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_gravacao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "INI"
           dFIM := qfimmes(ctod("31/12/"+strzero(year(dINI),4)))
           qrsay(XNIVEL+1,dtoc(dFIM))

      case cCAMPO == "FIM"
           if dFIM < dINI
             qmensa("Data Final nÆo pode ser Inferior a Data Inicial !","B")
             return .F.
             qmensa("")
           endif

      case cCAMPO == "TIPO"
           if empty(cTIPO) ;  return .F. ; Endif
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"1 - Ficha 25","2 - Ficha 26"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := ""

   qmensa("")

return .T.


static function i_gravacao
   local   cDOMINIO :=  ""

   cDOMINIO := ""

   if ! quse(XDRV_CL,"FI559A",{"FI559A"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CL,"FI559B",{"FI559B"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
      return
   endif

   FI559A->(__dbzap())
   FI559B->(__dbzap())

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      if cTIPO == "1"
         i_XLS25()
      else
         i_XLS26()
      endif

   else
      if cTIPO == "1"
         i_ficha25()
      else
         i_ficha26()
      endif
   endif

return

static function i_ficha25
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
    local cFICHA  := ""
    local nSeq    := 0
    local ctitulo := " Relatorio - Ficha 25 da DIPJ "+DTOC(dINI)+" a "+DTOC(dFIM)

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. Dt_emissao <= dFIM .and. ! Cancelado .and. ! (empty(Num_fatura) .and. Es== "S") .and. Es == "S" }))

   FAT->(dbsetorder(6)) // data de saida
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   FAT->(Dbgotop())
   zCLI := FAT->Cod_cli
   nTOTAL := 0
   nSeq   := 1

   do while ! FAT->(eof()) // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(DbSeek(CLI1->Cgm_ent))

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

         nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)

         ITEN_FAT->(Dbskip())
      enddo

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
   nSeq   := 1


   zCLI  := alltrim(FI559B->Cod_cli)

   do while  FI559B->(!eof())

      if nSeq > 100
         exit
      endif

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          @prow()+1,0 say XCOND1
          qpageprn()
          qcabecprn(cTITULO,136)
          @ prow()+1,0 say "Cliente                                                    CNPJ                  Total                       "

          @ prow()+1,0 say replicate("-",134)

       endif

      CLI1->(Dbseek(alltrim(FI559B->Cod_cli)))

      @ prow()+1, 00  say left(CLI1->Razao,50)
      @ prow()  , 60   say fu_conv_cgccpf(CLI1->CGCCPF)
      @ prow()  , 90   say transf(FI559B->Total,"@E 9,999,999.99")
      CGM->(Dbseek(Cli1->cgm_ent))

      nSeq++

      FI559B->(dbskip())


   enddo

   qstopprn(.F.)

   nTOTAL := 0
   nSeq := 0

   FI559A->(dbClosearea())
   FI559B->(dbClosearea())


return

static function i_xls25
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
    local cFICHA  := ""
    local nSeq    := 0
    local ctitulo := " Relatorio - Ficha 25 da DIPJ "+DTOC(dINI)+" a "+DTOC(dFIM)

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. Dt_emissao <= dFIM .and. ! Cancelado .and. ! (empty(Num_fatura) .and. Es== "S") .and. Es == "S" }))

   FAT->(dbsetorder(6)) // data de saida
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))


    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   FAT->(Dbgotop())
   zCLI := FAT->Cod_cli
   nTOTAL := 0
   nSeq   := 1

   do while ! FAT->(eof()) // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(DbSeek(CLI1->Cgm_ent))

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

         nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)

         ITEN_FAT->(Dbskip())
      enddo

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
   nSeq   := 1


   zCLI  := alltrim(FI559B->Cod_cli)

   do while  FI559B->(!eof())

      if nSeq > 100
         exit
      endif

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 //.or. prow() > K_MAX_LIN
          @prow()+1,0 say "" //XCOND1
          qpageprn()
          @ prow()+1,0 say cTitulo+" 576"
          @ prow()+1,0 say "Cliente"+chr(9)+"CNPJ/CPF"+chr(9)+"Total"

          @ prow()+1,0 say ""

       endif

      CLI1->(Dbseek(alltrim(FI559B->Cod_cli)))

      @ prow()+1, 00  say left(CLI1->Razao,50)
      @ prow()  , pcol() say chr(9)+fu_conv_cgccpf(CLI1->CGCCPF)
      @ prow()  , pcol() say chr(9)+transf(FI559B->Total,"@E 9,999,999.99")

      nSeq++

      FI559B->(dbskip())


   enddo

   qstopprn(.F.)

   nTOTAL := 0
   nSeq := 0

   FI559A->(dbClosearea())
   FI559B->(dbClosearea())


return


static function i_ficha26
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
    local nSeq := 0
    local cTITULO := "Relatorio Ficha 26 DIPJ "+dtoc(dINI)+ " a "+dtoc(dFIM)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! quse(XDRV_CL,"FI560A",{"FI560A1"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CL,"FI560B",{"FI560B1"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
      return
   endif

   FI560A->(__dbzap())
   FI560B->(__dbzap())

   FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. Dt_emissao <= dFIM .and. ! Cancelado .and. ! (empty(Num_fatura) .and. Es== "S") .and. Es == "S" }))
   FAT->(dbsetorder(2))
   FAT->(dbgotop())


   do while ! FAT->(eof())  

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif


      if FAT->Es != "S"
         FAT->(dbskip())
         loop
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
          if FI560A->(Qappend())
             replace FI560A->Cod_prod   with right(PROD->Codigo,5)
             replace FI560A->Quantidade with ITEN_FAT->Quantidade
             replace FI560A->Vl_unitar  with ITEN_FAT->Vl_unitar
             replace FI560A->Valor      with nVALOR
             replace FI560A->Es         with FAT->Es
             replace FI560A->Quant_ent  with 0
          endif
          ITEN_FAT->(Dbskip())
          nVALOR := 0
          lTEM := .T.
      enddo
      FAT->(dbskip())
      nVALOR := 0
      nDESC := 0
   enddo

   FI560A->(dbcommit())

   FI560A->(dbgotop())

   cPROD := FI560A->Cod_prod

   do while ! FI560A->(Eof())

       nQUANT += FI560A->Quantidade
       nTOTAL += FI560A->Valor

       FI560A->(Dbskip())
       if FI560A->Cod_prod != cPROD
          if FI560B->(qappend())
             replace FI560B->cod_prod with cPROD
             replace FI560B->Qtde     with nQuant
             replace FI560B->total    with nTOTAL
          endif
          FI560B->(dbcommit())

          cPROD := FI560A->Cod_prod

          nQUANT     := 0
          nTOTAL     := 0
       endif
   enddo

   if FI560B->(qappend())
      replace FI560B->cod_prod with cPROD
      replace FI560B->Qtde     with nQuant
      replace FI560B->total    with nTOTAL
   endif

   FI560B->(dbcommit())


   nQUANT     := 0
   nQUANT_ENT := 0
   nTOTAL     := 0
   nTOTAL_ENT := 0
   nPERC  := 0
   nSeq   := 1


   FI560B->(dbgotop())

    do while ! FI560B->(eof())

       if nSeq > 50
          exit
       endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          @prow()+1,0 say XCOND1
          qpageprn()
          qcabecprn(cTITULO,134)
          @ prow()+1,0 say XCOND1 + "Produto                                                              Classif                                        Valor"
          @ prow()+1,0 say replicate("-",134)
       endif


       PROD->(Dbsetorder(4))
       PROD->(Dbseek(FI560B->Cod_prod))

       @ prow()+1 ,00 say PROD->Cod_ass
       @ prow()   ,10 say left(PROD->Cod_fabr,8)
       @ prow()   ,20 say left(PROD->Descricao,40)
       CLASSIF->(dbseek(PROD->Cod_class))
       @ prow()   ,70 say left(CLASSIF->Descricao,20)
       @ prow()   ,115 say Transform(FI560B->Total,"@E 9,999,999.99")

       nSeq++

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

static function i_xls26
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
    local nSeq := 0
    local cTITULO := "Relatorio Ficha 26 DIPJ "+dtoc(dINI)+ " a "+dtoc(dFIM)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! quse(XDRV_CL,"FI560A",{"FI560A1"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CL,"FI560B",{"FI560B1"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
      return
   endif

   FI560A->(__dbzap())
   FI560B->(__dbzap())

   FAT->(Dbsetfilter({|| Dt_emissao >= dINI .and. Dt_emissao <= dFIM .and. ! Cancelado .and. ! (empty(Num_fatura) .and. Es== "S") .and. Es == "S" }))
   FAT->(dbsetorder(2))
   FAT->(dbgotop())


   do while ! FAT->(eof())  

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif


      if FAT->Es != "S"
         FAT->(dbskip())
         loop
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
          if FI560A->(Qappend())
             replace FI560A->Cod_prod   with right(PROD->Codigo,5)
             replace FI560A->Quantidade with ITEN_FAT->Quantidade
             replace FI560A->Vl_unitar  with ITEN_FAT->Vl_unitar
             replace FI560A->Valor      with nVALOR
             replace FI560A->Es         with FAT->Es
             replace FI560A->Quant_ent  with 0
          endif
          ITEN_FAT->(Dbskip())
          nVALOR := 0
          lTEM := .T.
      enddo
      FAT->(dbskip())
      nVALOR := 0
      nDESC := 0
   enddo

   FI560A->(dbcommit())

   FI560A->(dbgotop())

   cPROD := FI560A->Cod_prod

   do while ! FI560A->(Eof())

       nQUANT += FI560A->Quantidade
       nTOTAL += FI560A->Valor

       FI560A->(Dbskip())
       if FI560A->Cod_prod != cPROD
          if FI560B->(qappend())
             replace FI560B->cod_prod with cPROD
             replace FI560B->Qtde     with nQuant
             replace FI560B->total    with nTOTAL
          endif
          FI560B->(dbcommit())

          cPROD := FI560A->Cod_prod

          nQUANT     := 0
          nTOTAL     := 0
       endif
   enddo

   if FI560B->(qappend())
      replace FI560B->cod_prod with cPROD
      replace FI560B->Qtde     with nQuant
      replace FI560B->total    with nTOTAL
   endif

   FI560B->(dbcommit())


   nQUANT     := 0
   nQUANT_ENT := 0
   nTOTAL     := 0
   nTOTAL_ENT := 0
   nPERC  := 0
   nSeq   := 1


   FI560B->(dbgotop())

    do while ! FI560B->(eof())

       if nSeq > 50
          exit
       endif

       if XPAGINA == 0 //.or. prow() > K_MAX_LIN
          @prow()+1,0 say ""
          qpageprn()
          @ prow()+1,0 say  chr(9)+chr(9)+cTitulo + " 576"
          @ prow()+1,0 say  "Cod"+chr(9)+"Ref."+chr(9)+"Produto"+chr(9)+"Classif"+chr(9)+"Valor"
          @ prow()+1,0 say  ""
       endif


       PROD->(Dbsetorder(4))
       PROD->(Dbseek(FI560B->Cod_prod))

       @ prow()+1 ,00 say PROD->Cod_ass
       @ prow()   ,pcol() say chr(9)+left(PROD->Cod_fabr,8)
       @ prow()   ,pcol() say chr(9)+left(PROD->Descricao,40)
       CLASSIF->(dbseek(PROD->Cod_class))
       @ prow()   ,pcol() say chr(9)+left(CLASSIF->Descricao,20)
       @ prow()   ,pcol() say chr(9)+Transform(FI560B->Total,"@E 9,999,999.99")

       nSeq++

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



