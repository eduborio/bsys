/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: BASE DE CALCULO E CALCULO DOS TRIBUTOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: ABRIL DE 1995
// OBS........: PARA EMISSAO DO GR-DARF
// ALTERACOES.:

function ef401
#define K_MAX_LIN 55

#include "ef.ch"

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) .and. XNIVEL==1}
local nCONT   := 0

private nTRANSP                      // Valor de imposto de regime simplificado do mes anterior

// CONFIGURACOES ____________________________________________________________

// if !quse(XDRV_EF,"CONFIG") ; return ; endif

private cTRIB_SINC := CONFIG->Trib_Sinc
private nALIQ_SERV := CONFIG->Perc_slp

// CONFIG->(dbclosearea())

// SE TRIBUTOS FOREM SINCRONIZADOS, PEGA DA E001 ____________________________

if cTRIB_SINC == "1"
   if !quse(XDRV_EFX,"TRIB",{"TRIB_COD","TRIB_DES"}) ; return ; endif
else
   if !quse(XDRV_EF ,"TRIB",{"TRIB_COD","TRIB_DES"}) ; return ; endif
endif

qmensa("<ESC - Cancela>")
// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private cPIC1 := "@E 999,999,999.99"

private bENT_FILTRO                  // code block de filtro entradas
private bSAI_FILTRO                  // code block de filtro saidas
private bISS_FILTRO                  // code block de filtro servicos prestados
private aEDICAO    := {}             // vetor para os campos de entrada de dados

private nENTRADA                     // total valor contabil de entradas
private nSAIDA                       // total valor contabil de saidas
private nSERVICOS                    // total de servicos prestados
private nDESCONTO                    // total de descontos
private nS_CALC
private nS_LUCR

private nIRPJ                        // I.R. a recolher
private nISS                         // ISS a recolher
private nPIS_FAT                     // PIS a recolher
private nPIS_REP                     // PIS repique
private nPIS_DED                     // PIS deducao do IR
private nCOFINS                      // COFINS a recolher
private nCONT_SOC                    // CONTRIBUICAO SOCIAL a recolher
private nDIVERSAS                    // Receitas de atividades diversas
private nRESULT                      // Demais resultados
private nCAPITAL                     // Ganhos de capital
private nLIQUIDO                     // Ganhos liquidos
private nLUCRO_INF                    // Deducoes     alterado por Eduardo especifico p/ empresas de comercio de automoveis
private nIR_FONTE                    // I.R. na fonte
private nIR_COMP                     // Compensacoes I.R.
private nALIMENT                     // Total Alimentacao
private nVALE_TRANS                  // Total Vale transporte
private nPAT                         // Alimentacao a deduzir
private nVT                          // Vale transporte a deduzir
private nUFIR_1                      // Ufir Pis e Cofins
private nUFIR_2                      // Irpj e Contribuicao Social

// SOMA DOS CODIGOS FISCAIS _________________________________________________

private nSOMA131                     // Total Codigo Fiscal 1.31
private nSOMA132                     // Total Codigo Fiscal 1.32
private nSOMA133                     // Total Codigo Fiscal 1.33
private nSOMA231                     // Total Codigo Fiscal 2.31
private nSOMA232                     // Total Codigo Fiscal 2.32
private nSOMA233                     // Total Codigo Fiscal 2.33
private nSOMA511                     // Total Codigo Fiscal 5.11
private nSOMA512                     // Total Codigo Fiscal 5.12
private nSOMA513                     // Total Codigo Fiscal 5.13
private nSOMA561                     // Total Codigo Fiscal 5.61
private nSOMA562                     // Total Codigo Fiscal 5.62
private nSOMA563                     // Total Codigo Fiscal 5.63
private nSOMA611                     // Total Codigo Fiscal 6.11
private nSOMA612                     // Total Codigo Fiscal 6.12
private nSOMA613                     // Total Codigo Fiscal 6.13
private nSOMA661                     // Total Codigo Fiscal 6.61
private nSOMA662                     // Total Codigo Fiscal 6.62
private nSOMA663                     // Total Codigo Fiscal 6.63
private nSOMA711                     // Total Codigo Fiscal 7.11
private nSOMA712                     // Total Codigo Fiscal 7.12

private n1201
private n1202
private n1203
private n1204
private n1205
private n1206
private n1207
private n1208
private n1209

private n2201
private n2202
private n2203
private n2204
private n2205
private n2206
private n2207
private n2208
private n1209

private n5101
private n5102
private n5103
private n5124

private n6101
private n6102
private n6103
private n6124

private n5301
private n5302
private n5303
private n5304
private n5305
private n5306
private n5307

private n6301
private n6302
private n6303
private n6304
private n6305
private n6306
private n6307

private n7101
private n7102


private dDATA_INI                    // Data inicial do ICMS dentro do mes
private dDATA_FIM                    // Data final do ICMS dentro do mes

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}

private aSLP_P := {}
private aSLP_V := {}
private nVLR_S

qlbloc(5,0,"B401A","QBLOC.GLO",1)

// APENAS COLOCA UMA MENSAGEM NA TELA _______________________________________

if cTRIB_SINC == "1"
   qlbloc(06,0,"B401C","QBLOC.GLO",1)
else
   qlbloc(06,0,"B401D","QBLOC.GLO",1)
endif

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@nSERVICOS   ,"@E 999,999,999.99",NIL,NIL) } ,"SERVICOS"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nDIVERSAS   ,"@E 999,999,999.99",NIL,NIL) } ,"DIVERSAS"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nRESULT     ,"@E 999,999,999.99",NIL,NIL) } ,"RESULT"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAPITAL    ,"@E 999,999,999.99",NIL,NIL) } ,"CAPITAL"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nLIQUIDO    ,"@E 999,999,999.99",NIL,NIL) } ,"LIQUIDO"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nLUCRO_INF  ,"@E 999,999,999.99",NIL,NIL) } ,"LUCRO_INF"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nALIMENT    ,"@E 999,999,999.99",NIL,NIL) } ,"ALIMENT"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nVALE_TRANS ,"@E 999,999,999.99",NIL,NIL) } ,"VALE_TRANS" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nIR_FONTE   ,"@E 999,999,999.99",NIL,NIL) } ,"IR_FONTE"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nIR_COMP    ,"@E 999,999,999.99",NIL,NIL) } ,"IR_COMP"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nUFIR_1     ,"@E 9,999.9999"    ,NIL,NIL) } ,"UFIR_1"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@nUFIR_2     ,"@E 9,999.9999"    ,NIL,NIL) } ,"UFIR_2"     })

do while .T.

   XNIVEL := 1
   XFLAG  := .T.

   nENTRADA    := 0            // total valor contabil de entradas
   nSAIDA      := 0            // total valor contabil de saidas
   nDESCONTO   := 0            // Desconto
   nCIGARROS   := 0            // Cigarros para deducao
   nCIGARRO1   := 0            // Cigarros para deducao ENT
   nCIGARRO2   := 0            // Cigarros para deducao SAI
   nIRPJ       := 0            // I.R. a recolher
   nISS        := 0            // ISS a recolher
   nPIS_FAT    := 0            // PIS a recolher
   nCOFINS     := 0            // COFINS a recolher
   nPIS_REP    := 0            // PIS REPIQUE
   nPIS_DED    := 0            // PIS DEDUCAO
   nCONT_SOC   := 0            // CONTRIBUICAO SOCIAL a recolher
   nSERVICOS   := 0            // total de servicos prestados
   nS_CALC     := 0
   nS_LUCR     := 0
   nDIVERSAS   := 0            // Receitas de atividades diversas
   nRESULT     := 0            // Demais resultados
   nCAPITAL    := 0            // Ganhos de capital
   nLIQUIDO    := 0            // Ganhos liquidos
   nLUCRO_INF  := 0            // Lucro inflacionario
   nIR_FONTE   := 0            // I.R. na fonte
   nIR_COMP    := 0            // Compensacoes de I.R.
   nALIMENT    := 0            // Total Alimentacao
   nVALE_TRANS := 0            // Total Vale Transporte
   nPAT        := 0            // Alimentacao a deduzir
   nVT         := 0            // Vale Transporte a deduzir
   nUFIR_1     := 0            // Ufir Pis e Cofins
   nUFIR_2     := 0            // Irpj e Contribuicao Social

   nSOMA131    := 0            // Total codigo fiscal 1.31
   nSOMA132    := 0            // Total codigo fiscal 1.32
   nSOMA133    := 0            // Total codigo fiscal 1.33
   nSOMA231    := 0            // Total codigo fiscal 2.31
   nSOMA232    := 0            // Total codigo fiscal 2.32
   nSOMA233    := 0            // Total codigo fiscal 2.33
   nSOMA511    := 0            // Total codigo fiscal 5.11
   nSOMA512    := 0            // Total codigo fiscal 5.12
   nSOMA513    := 0            // Total codigo fiscal 5.13
   nSOMA561    := 0            // Total codigo fiscal 5.61
   nSOMA562    := 0            // Total codigo fiscal 5.62
   nSOMA563    := 0            // Total codigo fiscal 5.63
   nSOMA611    := 0            // Total codigo fiscal 6.11
   nSOMA612    := 0            // Total codigo fiscal 6.12
   nSOMA613    := 0            // Total codigo fiscal 6.13
   nSOMA661    := 0            // Total codigo fiscal 6.61
   nSOMA662    := 0            // Total codigo fiscal 6.62
   nSOMA663    := 0            // Total codigo fiscal 6.63
   nSOMA711    := 0            // Total codigo fiscal 7.11
   nSOMA712    := 0            // Total codigo fiscal 7.12

    n1201  := 0
    n1202  := 0
    n1203  := 0
    n1204  := 0
    n1205  := 0
    n1206  := 0
    n1207  := 0
    n1208  := 0
    n1209  := 0

    n2201  := 0
    n2202  := 0
    n2203  := 0
    n2204  := 0
    n2205  := 0
    n2206  := 0
    n2207  := 0
    n2208  := 0
    n1209  := 0

    n5101  := 0
    n5102  := 0
    n5103  := 0
    n5124  := 0

    n6101  := 0
    n6102  := 0
    n6103  := 0
    n6124  := 0

    n5301  := 0
    n5302  := 0
    n5303  := 0
    n5304  := 0
    n5305  := 0
    n5306  := 0
    n5307  := 0

    n6301  := 0
    n6302  := 0
    n6303  := 0
    n6304  := 0
    n6305  := 0
    n6306  := 0
    n6307  := 0

    n7101  := 0
    n7102  := 0


   dDATA_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM   := qfimmes(dDATA_INI)

   if BASE->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM)))

      nSERVICOS   := BASE->SERVICOS
      nDIVERSAS   := BASE->DIVERSAS
      nRESULT     := BASE->RESULT
      nCAPITAL    := BASE->CAPITAL
      nLIQUIDO    := BASE->LIQUIDO
      nLUCRO_INF  := BASE->LUCRO_INF
      nIR_FONTE   := BASE->IR_FONTE
      nIR_COMP    := BASE->IR_COMP
      nALIMENT    := BASE->ALIMENT
      nVALE_TRANS := BASE->VALE_TRANS
      nUFIR_1     := BASE->UFIR_1
      nUFIR_2     := BASE->UFIR_2

      nCONT := 1

      qrsay ( nCONT++ , BASE->SERVICOS     ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->DIVERSAS     ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->RESULT       ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->CAPITAL      ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->LIQUIDO      ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->LUCRO_INF    ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->ALIMENT      ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->VALE_TRANS   ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->IR_FONTE     ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->IR_COMP      ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->UFIR_1       ,  "@E 9,999.9999"     )
      qrsay ( nCONT++ , BASE->UFIR_2       ,  "@E 9,999.9999"     )

   endif

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_calc_trib() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "UFIR_1"
           if nUFIR_1 = 0 ; return .F. ; endif

      case cCAMPO == "UFIR_2"
           if nUFIR_2 = 0 ; return .F. ; endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bENT_FILTRO  := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO  := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }
   bISS_FILTRO  := { || ISS->DATA_LANC >= dDATA_INI .and. ISS->DATA_LANC <= dDATA_FIM }
   bBASE_FILTRO := { || BASE->DATA_INI >= dDATA_INI .and. BASE->DATA_FIM <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   if val(CONFIG->Anomes) < 200301
      select SAI
      SAI->(dbsetorder(3)) // Codigos Fiscais
      SAI->(dbgotop())

      select ENT
      ENT->(dbsetorder(3)) // Codigos Fiscais
      ENT->(dbgotop())
   else
      select SAI
      SAI->(dbsetorder(8)) // Codigos Fiscais
      SAI->(dbgotop())

      select ENT
      ENT->(dbsetorder(8)) // Codigos Fiscais
      ENT->(dbgotop())
   endif
   select ISS         // Servicos Prestados
   ISS->(dbgotop())

   select TRIB        // Tributos
   TRIB->(dbsetorder(1))
   TRIB->(dbgotop())

   select BASE        // Base do lucro presumido
   BASE->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE CALCULO ___________________________________________

static function i_calc_trib

   local sBLOC := qsbloc(2,1,24,79)
   local nGRAVA, nVALOR, nVALOR_UFIR, cCODIGO, lTRAVA, nTMP, nCONTX := 0, nLUC_S := 0

   // QUANDO O VALOR DOS SERVICOS NAO FOR INFORMADO E EMPRESA DE SERVICOS ___

   aSLP_P := {}
   aSLP_V := {}
   nVLR_S := 0

   if nSERVICOS = 0 .and. XTIPOEMP $ "67"

      ISS->(dbsetorder(2))  // DTOS(DATA_LANC)

      ISS->(dbseek(dDATA_INI,.T.))

      do while ISS->Data_lanc <= dDATA_FIM .and. ISS->Data_lanc >= dDATA_INI

         qgirabarra()

         qmensa("Servi‡os: Somando Nota "+ISS->Num_Nf +" / Serie : "+ISS->Serie)

         if ( nTMP := ascan(aSLP_P,ISS->Perc_slp) ) == 0
            aadd(aSLP_P,ISS->Perc_slp)
            aadd(aSLP_V,ISS->Vlr_cont)
         else
            aSLP_V[nTMP] += ISS->Vlr_cont
         endif

         ISS->(dbskip())

      enddo

      for nCONTX := 1 to len(aSLP_P)

          nS_CALC += aSLP_V[nCONTX]
          nS_LUCR += aSLP_V[nCONTX] * aSLP_P[nCONTX] / 100

      next

   endif

   nS_CALC := nS_CALC + nSERVICOS

   // NOTAS DE ENTRADA _____________________________________________________

   do while ! ENT->(eof())   // condicao principal de loop

      if eval(bENT_FILTRO)

         qmensa("Entradas: Somando Nota "+ENT->Num_Nf +" / Serie : "+ENT->Serie)

         // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 1.3X e 2.3X ____________
         if val(CONFIG->Anomes) < 200301
            if left(ENT->COD_FISC,2) $ "13*23"
               nENTRADA := nENTRADA + ENT->VLR_CONT - ENT->Ipi_Vlr
            endif

            // SOMA OS CODIGOS FISCAIS QUE ENTRAM NO LUCRO PRESUMIDO __________

            do case
               case ENT->COD_FISC  = "131"
                    nSOMA131 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->COD_FISC  = "132"
                    nSOMA132 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->COD_FISC  = "133"
                    nSOMA133 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->COD_FISC  = "231"
                    nSOMA231 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->COD_FISC  = "232"
                    nSOMA232 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->COD_FISC  = "233"
                    nSOMA233 += ENT->VLR_CONT - ENT->Ipi_Vlr
            endcase
         else
            if ENT->CFOP $ "1201*1202*1203*1204*1205*1206*1207*1208*1209*2201*2202*2203*2204*2205*2206*2207*2208*2209"
               nENTRADA := nENTRADA + ENT->VLR_CONT - ENT->Ipi_Vlr
            endif

            // SOMA OS CODIGOS FISCAIS QUE ENTRAM NO LUCRO PRESUMIDO __________

            do case
               case ENT->CFOP  = "1201"
                    n1201 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "1202"
                    n1202 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "1203"
                    n1203 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "1204"
                    n1204 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "1205"
                    n1205 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "1206"
                    n1206 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "1207"
                    n1207 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "1208"
                    n1208 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "1209"
                    n1209 += ENT->VLR_CONT - ENT->Ipi_Vlr

               case ENT->CFOP  = "2201"
                    n2201 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "2202"
                    n2202 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "2203"
                    n2203 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "2204"
                    n2204 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "2205"
                    n2205 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "2206"
                    n2206 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "2207"
                    n2207 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "2208"
                    n2208 += ENT->VLR_CONT - ENT->Ipi_Vlr
               case ENT->CFOP  = "2209"
                    n2209 += ENT->VLR_CONT - ENT->Ipi_Vlr
            endcase

         endif
         // Serve para fazer calculo de cigarro ____________________________

//       if val(left(CONFIG->Anomes,2)) = 95
//          if ENT->ICM_COD = "7"
//             nCIGARRO1 += ENT->Vlr_Cont
//          endif
//       endif

      endif

      ENT->(dbskip())

   enddo

   // NOTAS DE SAIDA _______________________________________________________

   do while ! SAI->(eof())   // condicao principal de loop

      if eval(bSAI_FILTRO)

         qmensa("Sa¡da: Somando Nota "+SAI->Num_Nf +" / Serie : "+SAI->Serie)

         // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 5.1X 5.6X 6.1X 6.6X 7.1X

         if val(CONFIG->Anomes) < 200301
            if left(SAI->COD_FISC,2) $ "51*56*61*66*71"

               nSAIDA += SAI->VLR_CONT - SAI->Ipi_Vlr

               // SOMA DESCONTO PARA PIS E COFINS ____________________________

               if left(SAI->COD_FISC,2) = "71"
                  nDESCONTO += SAI->VLR_CONT - SAI->Ipi_Vlr
               endif

               // SOMA SOMENTE CIGARROS PARA DEDUZIR DO PIS __________________

   //          if val(left(CONFIG->Anomes,2)) = 95
   //             if SAI->ICM_COD = "7" .and. ENT->ICM_COD = "7"
   //                nCIGARROS += SAI->VLR_CONT - SAI->Ipi_Vlr - ENT->Vlr_Cont
   //             endif
   //          endif

               if val(left(CONFIG->Anomes,4)) = 1995
                  if SAI->Icm_Cod $ "7"
                     nCIGARRO2 += SAI->Vlr_Cont
                  endif
               else
                  if SAI->Especie $ "78"
                     nCIGARRO2 += SAI->Vlr_Cont
                  endif
               endif

            endif

            do case
               case SAI->COD_FISC  = "511"
                    nSOMA511 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "512"
                    nSOMA512 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "513"
                    nSOMA513 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "561"
                    nSOMA561 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "562"
                    nSOMA562 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "563"
                    nSOMA563 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "611"
                    nSOMA611 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "612"
                    nSOMA612 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "613"
                    nSOMA613 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "661"
                    nSOMA661 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "662"
                    nSOMA662 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "663"
                    nSOMA663 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "711"
                    nSOMA711 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->COD_FISC  = "712"
                    nSOMA712 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endcase
         else
            if SAI->CFOP $ "5101*5102*5103*5124*6101*6102*6103*6124*3124*5301*5302*5303*5304*5305*5306*5307*6301*6302*6303*6304*6305*6306*6307*7101*7102"

               nSAIDA += SAI->VLR_CONT - SAI->Ipi_Vlr

               // SOMA DESCONTO PARA PIS E COFINS ____________________________

               if left(SAI->CFOP,2) = "71"
                  nDESCONTO += SAI->VLR_CONT - SAI->Ipi_Vlr
               endif

               // SOMA SOMENTE CIGARROS PARA DEDUZIR DO PIS __________________

   //          if val(left(CONFIG->Anomes,2)) = 95
   //             if SAI->ICM_COD = "7" .and. ENT->ICM_COD = "7"
   //                nCIGARROS += SAI->VLR_CONT - SAI->Ipi_Vlr - ENT->Vlr_Cont
   //             endif
   //          endif

               if val(left(CONFIG->Anomes,4)) = 1995
                  if SAI->Icm_Cod $ "7"
                     nCIGARRO2 += SAI->Vlr_Cont
                  endif
               else
                  if SAI->Especie $ "78"
                     nCIGARRO2 += SAI->Vlr_Cont
                  endif
               endif

            endif

            do case
               case SAI->CFOP  = "5101"
                    n5101 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5102"
                    n5102 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5103"
                    n5103 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6101"
                    n6101 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6102"
                    n6102 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6103"
                    n6103 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5301"
                    n5301 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5302"
                    n5302 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5303"
                    n5303 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5304"
                    n5304 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5305"
                    n5305 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5306"
                    n5306 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5307"
                    n5307 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6301"
                    n6301 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6302"
                    n6302 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6303"
                    n6303 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6304"
                    n6304 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6305"
                    n6305 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6306"
                    n6306 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6307"
                    n6307 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "7101"
                    n7101 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "7102"
                    n7102 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "5124"
                    n5124 += SAI->VLR_CONT - SAI->Ipi_Vlr
               case SAI->CFOP  = "6124"
                    n6124 += SAI->VLR_CONT - SAI->Ipi_Vlr




            endcase

         endif
      endif

      SAI->(dbskip())

   enddo

   // VALOR DO CIGARRO PARA DEDUCAO NOS CALCULOS _______________________________

   nCIGARROS := nCIGARRO2

   // CALCULA TRIBUTOS _________________________________________________________

   // BASE DO PIS (USA ESTA BASE NA DEMONSTRACAO DO PIS) _______________________

   nPIS_FAT := (nSAIDA   + nS_CALC + nDIVERSAS + nRESULT + nCAPITAL +;
                nLIQUIDO - nENTRADA  - nDESCONTO - nCIGARROS)

   // BASE DO COFINS (USA ESTA BASE NA DEMONSTRACAO DO COFINS) _________________

   nPARTE := at("2172/",CONFIG->Conf_trib)

   if substr(CONFIG->Conf_trib,nPARTE,4) == "2172" .or. empty(CONFIG->Conf_trib)
      nCOFINS := (nSAIDA + nS_CALC - nENTRADA - nDESCONTO - nCIGARROS)
   endif

   // BASE DO ISS ______________________________________________________________

   nISS := nS_CALC

   // VALOR TOTAL DA CONTRIBUICAO SOCIAL _______________________________________

   nCONT_SOC := (nSAIDA + nS_CALC + nDIVERSAS + nRESULT + nCAPITAL + nLIQUIDO - nENTRADA )

   // TOTAL BRUTO ______________________________________________________________

   nTOTAL := (( nSAIDA - nENTRADA ) + nS_CALC + nDIVERSAS + nRESULT +;
             nCAPITAL + nLIQUIDO    + nLUCRO_INF)

   // TOTAL DO LUCRO PARA BASE DO CALCULO DO IR ________________________________

   nLUCRO := (nS_LUCR    + (nSERVICOS * nALIQ_SERV / 100) + (nDIVERSAS    * i_aliquota(K_DIVERSAS))+;
             (nRESULT    * i_aliquota(K_RESULT))   + (nCAPITAL            * i_aliquota(K_CAPITAL)) +;
             (nLUCRO_INF * i_aliquota(K_LUCRO_INF))+ (nSAIDA - nENTRADA ) * i_aliquota(K_RECEITA))

   // CALCULA VALOR DA ALIMENTACAO E VALE TRANSPORTE PARA DEDUCAO ______________

   nPAT := i_calc_pat(nALIMENT)
   nVT  := i_calc_vt(nVALE_TRANS)

   // TOTAL DO IRPJ A RECOLHER _________________________________________________

   nPARTE := at("2089/",CONFIG->Conf_trib)

   if substr(CONFIG->Conf_trib,nPARTE,4) == "2089" .or. empty(CONFIG->Conf_trib)
      nIRPJ := nLUCRO * i_aliquota(K_IRPJ) - nVT - nPAT
   endif

   // CALCULA PIS-REPIQUE E PIS DEDUCAO SOBRE O VALOR DO IR ____________________

   nPARTE := at("8002/",CONFIG->Conf_trib)

   if substr(CONFIG->Conf_trib,nPARTE,4) == "8002" .or. empty(CONFIG->Conf_trib)
      nPIS_REP := nIRPJ * i_aliquota(K_PIS2)
   endif

   nPARTE := at("8205/",CONFIG->Conf_trib)

   if substr(CONFIG->Conf_trib,nPARTE,4) == "8205" .or. empty(CONFIG->Conf_trib)
      nPIS_DED := nIRPJ * i_aliquota(K_PIS3)
   endif

   // MOSTRA TRIBUTOS CALCULADOS NA TELA _______________________________________

   qlbloc(5,0,"B401B","QBLOC.GLO",1)

   XNIVEL := 1

   if TRIB->(dbseek(XANOMES+K_PIS1))
      qrsay ( XNIVEL++, nPIS_FAT  * i_aliquota(K_PIS1)     , "@E 999,999,999.99")
   else
      // REPIQUE OU DEDUCAO POIS POSSUEM O MESMO VALOR _________________________
      qrsay ( XNIVEL++, nPIS_REP                           , "@E 999,999,999.99")
   endif

   qrsay ( XNIVEL++, nCOFINS      * i_aliquota(K_COFINS)   , "@E 999,999,999.99")

   if TRIB->(dbseek(XANOMES+K_CONT_SOC))
      qrsay ( XNIVEL++, nCONT_SOC * i_aliquota(K_CONT_SOC) , "@E 999,999,999.99")
   else
      qrsay ( XNIVEL++, nCONT_SOC * i_aliquota(K_CONTR_SOC), "@E 999,999,999.99")
   endif

   qrsay ( XNIVEL++, (nIRPJ - nIR_COMP - nIR_FONTE)        , "@E 999,999,999.99")
   qrsay ( XNIVEL++, (nISS * i_aliquota(K_ISS))            , "@E 999,999,999.99")

   // GRAVA DADOS INFORMADOS ___________________________________________________

   if BASE->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM)))
      lTRAVA := BASE->(qrlock())
   else
      lTRAVA := BASE->(qappend())
   endif

   if lTRAVA
      replace BASE->DATA_INI    with dDATA_INI
      replace BASE->DATA_FIM    with dDATA_FIM
      replace BASE->SERVICOS    with nS_CALC
      replace BASE->DIVERSAS    with nDIVERSAS
      replace BASE->RESULT      with nRESULT
      replace BASE->CAPITAL     with nCAPITAL
      replace BASE->LIQUIDO     with nLIQUIDO
      replace BASE->LUCRO_INF   with nLUCRO_INF
      replace BASE->ALIMENT     with nALIMENT
      replace BASE->VALE_TRANS  with nVALE_TRANS
      replace BASE->IR_FONTE    with nIR_FONTE
      replace BASE->IR_COMP     with nIR_COMP
      replace BASE->UFIR_1      with nUFIR_1
      replace BASE->UFIR_2      with nUFIR_2
      BASE->(qunlock())
   else
      // FUTURO REVER CONDICOES DE NAO TRAVAMENTO...
   endif

   // 4574 - ENTIDADES FINANCEIRAS __________________________________________

   if TRIB->(dbseek(XANOMES+K_PISF))
      cCODIGO     := K_PISF
      nVALOR      := nPIS_FAT * i_aliquota(K_PISF)
      nVALOR_UFIR := (nPIS_FAT * i_aliquota(K_PISF)) / UFIR_1

      nPARTE := at("4574/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "4574" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif

   // 3885 - PIS FATURAMENTO ________________________________________________

   if TRIB->(dbseek(XANOMES+K_PIS))

      cCODIGO     := K_PIS
      nVALOR      := nPIS_FAT * i_aliquota(K_PIS)
      nVALOR_UFIR := (nPIS_FAT * i_aliquota(K_PIS)) / UFIR_1

      nPARTE := at("3885/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "3885" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif

   // 8109 - PIS FATURAMENTO ________________________________________________

   if TRIB->(dbseek(XANOMES+K_PIS1))

      cCODIGO     := K_PIS1
      nVALOR      := nPIS_FAT * i_aliquota(K_PIS1)
      nVALOR_UFIR := (nPIS_FAT * i_aliquota(K_PIS1)) / UFIR_1

      nPARTE := at("8109/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "8109" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif

   // 8002 - PIS DEDUCAO ____________________________________________________

   if TRIB->(dbseek(XANOMES+K_PIS2))

      cCODIGO     := K_PIS2
      nVALOR      := nPIS_DED
      nVALOR_UFIR := (nPIS_DED) / UFIR_1

      nPARTE := at("8002/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "8002" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif

   // 8205 - PIS REPIQUE ____________________________________________________

   if TRIB->(dbseek(XANOMES+K_PIS3))

      cCODIGO     := K_PIS3
      nVALOR      := nPIS_REP
      nVALOR_UFIR := (nPIS_REP) / UFIR_1

      nPARTE := at("8205/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "8205" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif

   // 2172 - COFINS _________________________________________________________

   if TRIB->(dbseek(XANOMES+K_COFINS))

      cCODIGO     := K_COFINS
      nVALOR      := nCOFINS * i_aliquota(K_COFINS)
      nVALOR_UFIR := (nCOFINS * i_aliquota(K_COFINS)) / UFIR_1

      nPARTE := at("2172/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "2172" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif

   // 2372 - CONTRIBUICAO SOCIAL S/ LUCRO REAL ______________________________

   if TRIB->(dbseek(XANOMES+K_CONT_SOC))

      cCODIGO     := K_CONT_SOC  // CODIGO -> 2372
      nVALOR      := nCONT_SOC * i_aliquota(K_CONT_SOC)
      nVALOR_UFIR := (nCONT_SOC * i_aliquota(K_CONT_SOC)) / UFIR_2

      nPARTE := at("2372/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "2372" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif

   // 2484 - CONTRIBUICAO SOCIAL S/ LUCRO PRESUMIDO _________________________

   if TRIB->(dbseek(XANOMES+K_CONTR_SOC))

      cCODIGO   := K_CONTR_SOC
      nVALOR    := nCONT_SOC * i_aliquota(K_CONTR_SOC)
      nVALOR_UFIR := (nCONT_SOC * i_aliquota(K_CONTR_SOC)) / UFIR_2

      nPARTE := at("2484/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "2484" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif

   // 6895 - IOF________________________

   if TRIB->(dbseek(XANOMES+"6895"))

      cCODIGO   := "6895"
      nVALOR    := nTOTAL * i_aliquota("6895")
      nVALOR_UFIR := (nTOTAL * i_aliquota("6895")) / UFIR_2

      nPARTE := at("6895/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "6895" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif


   // 2089 - IRPJ S/ LUCRO PRESUMIDO ________________________________________

   if TRIB->(dbseek(XANOMES+K_IRPJ))

      cCODIGO     := K_IRPJ

      if XTIPOEMP <> "6"
         nVALOR      := (nIRPJ - nIR_COMP - nIR_FONTE)
         nVALOR_UFIR := (nIRPJ - nIR_COMP - nIR_FONTE) / UFIR_2
      else
         if (nSAIDA - nENTRADA) == 0
            nVALOR      := (nIRPJ - nIR_COMP - nIR_FONTE - nPIS_REP)
            nVALOR_UFIR := (nIRPJ - nIR_COMP - nIR_FONTE - nPIS_REP) / UFIR_2
         else
            nVALOR      := (nIRPJ - nIR_COMP - nIR_FONTE)
            nVALOR_UFIR := (nIRPJ - nIR_COMP - nIR_FONTE) / UFIR_2
         endif
      endif


      nPARTE := at("2089/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "2089" .or. empty(CONFIG->Conf_trib)
         i_grava_darf(cCODIGO,nVALOR,nVALOR_UFIR)
      endif

   endif

   // EMISSAO DO LUCRO PRESSUMIDO ___________________________________________

   if qconf("Confirma a emiss„o do Lucro Presumido ?","B")
      i_impressao()
   endif

   qrbloc(2,1,sBLOC)

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GRAVAR AS DARF'S _____________________________________________

static function i_grava_darf ( cCODIGO , nVALOR , nVALOR_UFIR )

   i_sald_anter(cCODIGO)

   if IMP->(dbseek(cCODIGO+dtos(dDATA_INI) + dtos(dDATA_FIM)))
      lTRAVA := IMP->(qrlock())
   else
      lTRAVA := IMP->(qappend())
   endif

   if lTRAVA

      replace IMP->CODIGO      with cCODIGO
      replace IMP->DATA_INI    with dDATA_INI
      replace IMP->DATA_FIM    with dDATA_FIM

      nVALOR := nTRANSP + nVALOR

      if nVALOR < 10.00
         replace IMP->Valor_acum with nVALOR
      else
         replace IMP->Valor_acum with 0
      endif

      IMP->(qunlock())

   endif

   // APLICA ROUND PARA EVITAR PROBLEMAS DE ERRO NA SOMA ____________________

   nVALOR      := round ( nVALOR, 2)
   nVALOR_UFIR := round ( nVALOR_UFIR, 2)

   // REALIZA TRAVAMENTO ____________________________________________________

   if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + cCODIGO))
      lTRAVA := DARF->(qrlock())
   else
      lTRAVA := DARF->(qappend())
   endif

   // GRAVA DARF ____________________________________________________________

   if lTRAVA
      replace DARF->DATA_INI    with dDATA_INI
      replace DARF->DATA_FIM    with dDATA_FIM
      replace DARF->COD_TRIB    with cCODIGO
      replace DARF->VALOR       with nVALOR
      replace DARF->VALOR_UFIR  with nVALOR_UFIR
      DARF->(qunlock())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nCONT

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND0

   @ prow()  ,24 Say XAENFAT + "DEMONSTRATIVO DO LUCRO PRESUMIDO"
   @ prow()+1,65 SAY qnomemes(val(right(XANOMES,2))) + "/" + left(XANOMES,4) + XDENFAT
   @ prow()+1,01 SAY "Empresa: " + XRAZAO
   @ prow()+1,01 Say "CGC(MF): " + XCGCCPF
   @ prow()+1,01 Say "Referencia                                           Valor R$   Lucro Pres. R$"
   @ prow()+1,01 SAY REPLICATE("-",78)

   @ prow()+1,01 Say str((i_aliquota(K_RECEITA)*100),3,1)  + "% Sobre Receita Bruta de"
   @ prow()+1,10 Say "Nat. Operacao..:"

   if val(CONFIG->Anomes) < 200301
      if ! empty(nSOMA511)
         @ prow()+1,26 Say "5.11" + space(18) + transform(nSOMA511, cPIC1)
      endif
      if ! empty(nSOMA512)
         @ prow()+1,26 Say "5.12" + space(18) + transform(nSOMA512, cPIC1)
      endif
      if ! empty(nSOMA513)
         @ prow()+1,26 Say "5.13" + space(18) + transform(nSOMA513, cPIC1)
      endif
      if ! empty(nSOMA561)
         @ prow()+1,26 Say "5.61" + space(18) + transform(nSOMA561, cPIC1)
      endif
      if ! empty(nSOMA562)
         @ prow()+1,26 Say "5.62" + space(18) + transform(nSOMA562, cPIC1)
      endif
      if ! empty(nSOMA563)
         @ prow()+1,26 Say "5.63" + space(18) + transform(nSOMA563, cPIC1)
      endif
      if ! empty(nSOMA611)
         @ prow()+1,26 Say "6.11" + space(18) + transform(nSOMA611, cPIC1)
      endif
      if ! empty(nSOMA612)
         @ prow()+1,26 Say "6.12" + space(18) + transform(nSOMA612, cPIC1)
      endif
      if ! empty(nSOMA613)
         @ prow()+1,26 Say "6.13" + space(18) + transform(nSOMA613, cPIC1)
      endif
      if ! empty(nSOMA661)
         @ prow()+1,26 Say "6.61" + space(18) + transform(nSOMA661, cPIC1)
      endif
      if ! empty(nSOMA662)
         @ prow()+1,26 Say "6.62" + space(18) + transform(nSOMA662, cPIC1)
      endif
      if ! empty(nSOMA663)
         @ prow()+1,26 Say "6.63" + space(18) + transform(nSOMA663, cPIC1)
      endif
      if ! empty(nSOMA711)
         @ prow()+1,26 Say "7.11" + space(18) + transform(nSOMA711, cPIC1)
      endif
      if ! empty(nSOMA712)
         @ prow()+1,26 Say "7.12" + space(18) + transform(nSOMA712, cPIC1)
      endif
      if ! empty(nSOMA131)
         @ prow()+1,26 Say "1.31" + space(18) + transform(nSOMA131 * -1, cPIC1)
      endif
      if ! empty(nSOMA132)
         @ prow()+1,26 Say "1.32" + space(18) + transform(nSOMA132 * -1, cPIC1)
      endif
      if ! empty(nSOMA133)
         @ prow()+1,26 Say "1.33" + space(18) + transform(nSOMA133 * -1, cPIC1)
      endif
      if ! empty(nSOMA231)
         @ prow()+1,26 Say "2.31" + space(18) + transform(nSOMA231 * -1, cPIC1)
      endif
      if ! empty(nSOMA232)
         @ prow()+1,26 Say "2.32" + space(18) + transform(nSOMA232 * -1, cPIC1)
      endif
      if ! empty(nSOMA233)
         @ prow()+1,26 Say "2.33" + space(18) + transform(nSOMA233 * -1, cPIC1)
      endif
   else
      if ! empty(n5101)
         @ prow()+1,26 Say "5.101" + space(17) + transform(n5101, cPIC1)
      endif
      if ! empty(n5102)
         @ prow()+1,26 Say "5.102" + space(17) + transform(n5102, cPIC1)
      endif
      if ! empty(n5103)
         @ prow()+1,26 Say "5.103" + space(17) + transform(n5103, cPIC1)
      endif
      if ! empty(n5124)
         @ prow()+1,26 Say "5.124" + space(17) + transform(n5124, cPIC1)
      endif

      if ! empty(n6101)
         @ prow()+1,26 Say "6.101" + space(17) + transform(n6101, cPIC1)
      endif
      if ! empty(n6102)
         @ prow()+1,26 Say "6.102" + space(17) + transform(n6102, cPIC1)
      endif
      if ! empty(n6103)
         @ prow()+1,26 Say "6.103" + space(17) + transform(n6103, cPIC1)
      endif
      if ! empty(n6124)
         @ prow()+1,26 Say "6.124" + space(17) + transform(n6124, cPIC1)
      endif

      if ! empty(n5301)
         @ prow()+1,26 Say "5.301" + space(17) + transform(n5301, cPIC1)
      endif
      if ! empty(n5302)
         @ prow()+1,26 Say "5.302" + space(17) + transform(n5302, cPIC1)
      endif
      if ! empty(n5303)
         @ prow()+1,26 Say "5.303" + space(17) + transform(n5303, cPIC1)
      endif
      if ! empty(n5304)
         @ prow()+1,26 Say "5.304" + space(17) + transform(n5304, cPIC1)
      endif
      if ! empty(n5305)
         @ prow()+1,26 Say "5.305" + space(17) + transform(n5305, cPIC1)
      endif
      if ! empty(n5306)
         @ prow()+1,26 Say "5.306" + space(17) + transform(n5306, cPIC1)
      endif
      if ! empty(n5307)
         @ prow()+1,26 Say "5.307" + space(17) + transform(n5307, cPIC1)
      endif

      if ! empty(n6301)
         @ prow()+1,26 Say "6.301" + space(17) + transform(n6301, cPIC1)
      endif
      if ! empty(n6302)
         @ prow()+1,26 Say "6.302" + space(17) + transform(n6302, cPIC1)
      endif
      if ! empty(n6303)
         @ prow()+1,26 Say "6.303" + space(17) + transform(n6303, cPIC1)
      endif
      if ! empty(n6304)
         @ prow()+1,26 Say "6.304" + space(17) + transform(n6304, cPIC1)
      endif
      if ! empty(n6305)
         @ prow()+1,26 Say "6.305" + space(17) + transform(n6305, cPIC1)
      endif
      if ! empty(n6306)
         @ prow()+1,26 Say "6.306" + space(17) + transform(n6306, cPIC1)
      endif
      if ! empty(n6307)
         @ prow()+1,26 Say "6.307" + space(17) + transform(n6307, cPIC1)
      endif

      if ! empty(n7101)
         @ prow()+1,26 Say "7.101" + space(17) + transform(n7101, cPIC1)
      endif
      if ! empty(n7102)
         @ prow()+1,26 Say "7.102" + space(17) + transform(n7102, cPIC1)
      endif




   endif
   @ prow()+1,42 SAY REPLICATE("-",37)

   @ prow()+1,10 Say "Totais.........................: "

   @ prow()  ,48 Say (nSAIDA - nENTRADA) picture cPIC1
   @ prow()  ,65 Say (nSAIDA - nENTRADA ) * i_aliquota(K_RECEITA) picture cPIC1

   @ prow()+1,00 say ""

   if nSERVICOS <> 0

      @ prow()+1,01 Say str(nALIQ_SERV,2) + "% s/ a receita de servicos ...........:"
      @ prow()  ,48 Say nSERVICOS picture cPIC1
      @ prow()  ,65 Say (nSERVICOS * nALIQ_SERV / 100) picture cPIC1

   else

      for nCONT := 1 to len(aSLP_P)

          @ prow()+1,01 Say str(aSLP_P[nCONT],2) + "% s/ a receita de servicos ...........:"
          @ prow()  ,48 Say aSLP_V[nCONT] picture cPIC1
          @ prow()  ,65 Say (aSLP_V[nCONT] * aSLP_P[nCONT] / 100) picture cPIC1

      next

   endif

   @ prow()+1,01 Say str((i_aliquota(K_DIVERSAS)*100),2) + "% s/ a receita de outras atividades...:"
   @ prow()  ,48 Say nDIVERSAS picture cPIC1
   @ prow()  ,65 Say (nDIVERSAS * i_aliquota(K_DIVERSAS)) picture cPIC1

   @ prow()+1,01 Say str((i_aliquota(K_RESULT)*100),3)   + "% dos demais resultados..............:"
   @ prow()  ,48 Say nRESULT picture cPIC1
   @ prow()  ,65 Say (nRESULT * i_aliquota(K_RESULT)) picture cPIC1

   @ prow()+1,01 Say str((i_aliquota(K_CAPITAL)*100),3)  + "% de ganhos de capital"
   @ prow()  ,48 Say nCAPITAL picture cPIC1
   @ prow()  ,65 Say (nCAPITAL * i_aliquota(K_CAPITAL)) picture cPIC1

   @ prow()+1,01 Say "Ganhos liquidos nao compoem B.C. I.R....:"
   @ prow()  ,48 Say nLIQUIDO picture cPIC1

   @ prow()+1,01 Say "Lucro inflacionario realizado ..........:"
   @ prow()  ,65 Say nLUCRO_INF picture cPIC1

   @ prow()+1,42 SAY REPLICATE("-",37)

   @ prow()+1,04 Say "Totais ..............................:"
   @ prow()  ,48 Say nTOTAL picture cPIC1
   @ prow()  ,65 Say nLUCRO picture cPIC1

   nPARTE := at("2089/",CONFIG->Conf_trib)

   if substr(CONFIG->Conf_trib,nPARTE,4) == "2089" .or. empty(CONFIG->Conf_trib)
      @ prow()+2,01 Say "Imposto de Renda........................:"
      @ prow()  ,65 Say (nLUCRO * i_aliquota(K_IRPJ)) picture cPIC1
   endif

   @ prow()+1,01 Say "Incentivos fiscais :"
   @ prow()+1,05 Say "Programa de alimentacao trabalhador.:"
   @ prow()  ,65 Say nPAT  picture cPIC1

   @ prow()+1,05 Say "Vale Transporte.....................:"
   @ prow()  ,65 Say nVT   picture cPIC1

   @ prow()+1,05 Say "Imposto de renda devido.............:"
   @ prow()  ,65 Say nIRPJ picture cPIC1

   @ prow()+1,05 Say "Valor da UFIR (PIS e COFINS)........:"
   @ prow()  ,39 Say nUFIR_1

   @ prow()+1,05 Say "Valor da UFIR (I.R. e CONT.SOCIAL)..:"
   @ prow()  ,39 Say nUFIR_2

   @ prow()+1,01 Say "Imposto de renda devido.................:"
   @ prow()  ,65 Say nIRPJ picture cPIC1

   @ prow()+1,01 Say "Compensacoes e I.R. Fonte...............:"
   @ prow()  ,65 Say ((nIR_COMP + nIR_FONTE) * -1) picture cPIC1

   nPARTE := at("8002/",CONFIG->Conf_trib)
   if substr(CONFIG->Conf_trib,nPARTE,4) == "8002" .or. empty(CONFIG->Conf_trib)
      @ prow()+1,01 say "PIS DEDUCAO.............................:"
      @ prow()  ,65 say nPIS_REP picture cPIC1
   endif

   @ prow()+1,42 SAY REPLICATE("-",37)

   @ prow()+1,01 Say XAENFAT + "IMPOSTO DE RENDA A RECOLHER.............:" + XDENFAT

   if XTIPOEMP <> "6"
      @ prow()  ,69 Say (nIRPJ - nIR_COMP - nIR_FONTE)                 picture cPIC1
   else
      if  (nSAIDA - nENTRADA) == 0
          @ prow()  ,69 Say (nIRPJ - nIR_COMP - nIR_FONTE - nPIS_REP)             picture cPIC1
      else
          @ prow()  ,69 Say (nIRPJ - nIR_COMP - nIR_FONTE )   picture cPIC1
      endif
   endif

   @ prow()+1,01 Say XAENFAT + "IMPOSTO DE RENDA A RECOLHER..(em Ufir)..:" + XDENFAT

   if XTIPOEMP <> "6"
      @ prow()  ,69 Say (nIRPJ - nIR_COMP - nIR_FONTE) / nUFIR_2  picture cPIC1
   else
      if (nSAIDA - nENTRADA) == 0
         @ prow()  ,69 Say (nIRPJ - nIR_COMP - nIR_FONTE - nPIS_REP) / nUFIR_2  picture cPIC1
      else
         @ prow()  ,69 Say (nIRPJ - nIR_COMP - nIR_FONTE)  / nUFIR_2  picture cPIC1
      endif
   endif

   @ prow()+2,50 Say "    Valor R$           Ufir's"

   if TRIB->(dbseek(XANOMES+K_CONT_SOC))

      nPARTE := at("2372/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "2372" .or. empty(CONFIG->Conf_trib)
         @ prow()+1,01 Say XAENFAT + "CONTRIBUICAO SOCIAL.(2372)..............:" + XDENFAT
         @ prow()  ,52 Say (nCONT_SOC  * i_aliquota(K_CONT_SOC))             picture cPIC1
         @ prow()  ,69 Say ((nCONT_SOC * i_aliquota(K_CONT_SOC)) / nUFIR_2)  picture cPIC1
      endif

   endif

   if TRIB->(dbseek(XANOMES+K_CONTR_SOC))

      nPARTE := at("2484/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "2484" .or. empty(CONFIG->Conf_trib)
         @ prow()+1,01 Say XAENFAT + "CONTRIBUICAO SOCIAL.(2484)..............:" + XDENFAT
         @ prow()  ,52 Say (nCONT_SOC  * i_aliquota(K_CONTR_SOC))            picture cPIC1
         @ prow()  ,69 Say ((nCONT_SOC * i_aliquota(K_CONTR_SOC)) / nUFIR_2) picture cPIC1
      endif

   endif

   if TRIB->(dbseek(XANOMES+K_PIS))

      nPARTE := at("3885/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "3885" .or. empty(CONFIG->Conf_trib)
         @ prow()+1,01 Say XAENFAT + "PIS FATURAMENTO (3885)..................:" + XDENFAT
         @ prow()  ,52 Say (nPIS_FAT * i_aliquota(K_PIS))                       picture cPIC1
         @ prow()  ,69 Say (nPIS_FAT * i_aliquota(K_PIS) / nUFIR_1)             picture cPIC1
      endif

   endif

   if TRIB->(dbseek(XANOMES+K_PIS1))

      nPARTE := at("8109/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "8109" .or. empty(CONFIG->Conf_trib)
         @ prow()+1,01 Say XAENFAT + "PIS FATURAMENTO (8109)..................:" + XDENFAT
         @ prow()  ,52 Say (nPIS_FAT * i_aliquota(K_PIS1))                       picture cPIC1
         @ prow()  ,69 Say (nPIS_FAT * i_aliquota(K_PIS1) / nUFIR_1)             picture cPIC1
      endif

   endif

   if TRIB->(dbseek(XANOMES+K_PISF))
      nPARTE := at("4574/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "4574" .or. empty(CONFIG->Conf_trib)
         @ prow()+1,01 Say XAENFAT + "PIS-ENT. FINAN. SEGURADO (4574).........:" + XDENFAT
         @ prow()  ,52 Say (nPIS_FAT * i_aliquota(K_PISF))                       picture cPIC1
         @ prow()  ,69 Say (nPIS_FAT * i_aliquota(K_PISF) / nUFIR_1)             picture cPIC1
      endif
   endif

   if TRIB->(dbseek(XANOMES+K_PIS2))
      nPARTE := at("8002/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "8002" .or. empty(CONFIG->Conf_trib)
         @ prow()+1,01 Say XAENFAT + "PIS DEDUCAO (8002)......................:" + XDENFAT
         @ prow()  ,52 Say nPIS_DED                                          picture cPIC1
         @ prow()  ,69 Say (nPIS_DED / nUFIR_1)                              picture cPIC1
      endif
   endif

   if TRIB->(dbseek(XANOMES+K_PIS2))
      nPARTE := at("8205/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "8205" .or. empty(CONFIG->Conf_trib)
         @ prow()+1,01 Say XAENFAT + "PIS REPIQUE (8205)......................:" + XDENFAT
         @ prow()  ,52 Say nPIS_REP                                          picture cPIC1
         @ prow()  ,69 Say (nPIS_REP / nUFIR_1)                              picture cPIC1
      endif
   endif

   if TRIB->(dbseek(XANOMES+K_COFINS))
      nPARTE := at("2172/",CONFIG->Conf_trib)

      if substr(CONFIG->Conf_trib,nPARTE,4) == "2172" .or. empty(CONFIG->Conf_trib)
         @ prow()+1,01 Say XAENFAT + "C O F I N S ............................:" + XDENFAT
         @ prow()  ,52 Say (nCOFINS * i_aliquota(K_COFINS))                    picture cPIC1
         @ prow()  ,69 Say (nCOFINS * i_aliquota(K_COFINS) / nUFIR_1)          picture cPIC1
      endif
   endif

   @ prow()+3,14 Say XAENFAT + "DEMONSTRATIVO DA BASE DE CALCULO DO PIS E DO COFINS" + XDENFAT
   @ prow()+2,01 Say "Referencia                                            B.C.PIS       B.C.COFINS"
   @ prow()+1,01 SAY REPLICATE("-",78)

   @ prow()+1,01 Say "Sobre Receita Bruta.....................:"
   @ prow()  ,48 Say (nSAIDA - nENTRADA) picture cPIC1
   @ prow()  ,65 Say (nSAIDA - nENTRADA) picture cPIC1

   @ prow()+1,01 Say "Cigarros................................:"
   @ prow()  ,48 Say (nCIGARROS * -1) picture cPIC1
   @ prow()  ,65 Say (nCIGARROS * -1) picture cPIC1

   if nSERVICOS <> 0

      @ prow()+1,01 Say str(nALIQ_SERV,2) + "% s/ a receita de servicos ...........:"
      @ prow()  ,48 Say nSERVICOS picture cPIC1
      @ prow()  ,65 Say nSERVICOS picture cPIC1

   else

      for nCONT := 1 to len(aSLP_P)

          @ prow()+1,01 Say str(aSLP_P[nCONT],2) + "% s/ a receita de servicos ...........:"
          @ prow()  ,48 Say aSLP_V[nCONT] picture cPIC1
          @ prow()  ,65 Say aSLP_V[nCONT] picture cPIC1

      next

   endif

   @ prow()+1,01 Say str((i_aliquota(K_DIVERSAS)*100),2) + "% S/a receita de outras atividades....:"
   @ prow()  ,48 Say nDIVERSAS picture cPIC1

   @ prow()+1,01 Say str((i_aliquota(K_RESULT)*100),3)   + "% dos demais resultados .............:"
   @ prow()  ,48 Say nRESULT   picture cPIC1

   @ prow()+1,01 Say str((i_aliquota(K_CAPITAL)*100),3)  + "% de ganhos de capital...............:"
   @ prow()  ,48 Say nCAPITAL  picture cPIC1                                                    

   @ prow()+1,01 Say "Ganhos liquidos nao compoem B.C. I.R....:"
   @ prow()  ,48 Say nLIQUIDO  picture cPIC1

   @ prow()+1,01 SAY REPLICATE("-",78)

   @ prow()+1,01 Say "Base de Calculo.........................:"
   @ prow()  ,48 Say nPIS_FAT  picture cPIC1
   @ prow()  ,65 Say nCOFINS   picture cPIC1

   qstopprn()

return

////////////////////////////////////////////////////////////////////////////////
// ALIQUOTA DOS TRIBUTOS FISCAIS _______________________________________________

function  i_aliquota ( cTRIB )
   if TRIB->(dbseek(XANOMES+cTRIB))
      return TRIB->ALIQUOTA / 100
   endif
return(0)

////////////////////////////////////////////////////////////////////////////////
// CALCULO DA DEDUCAO DO P.A.T. ________________________________________________

function  i_calc_pat ( nPAT )

   local nBASE

   nBASE := (nLUCRO * i_aliquota(K_IRPJ))
   nPAT  := nPAT   * 0.25

   // PERCENTUAL LIMITE PARA O P.A.T. __________________________________________

   if (nBASE * 0.05) < nPAT
      nPAT := (nBASE * 0.05)
   endif

return(nPAT)

////////////////////////////////////////////////////////////////////////////////
// CALCULO DA DEDUCAO DO V.T. __________________________________________________

function  i_calc_vt ( nVT )

   local nBASE

   nBASE := (nLUCRO * i_aliquota(K_IRPJ))
   nVT   := nVT * 0.25

   // PERCENTUAL LIMITE DO VALE TRANSPORTE _____________________________________

   if nVT > (nBASE * 0.08)
      nVT = (nBASE * 0.08)
   endif

   // PERCENTUAL LIMITE DO VALE TRANSPORTE E DO P.A.T. _________________________

   if (nVT + nPAT) > (nBASE * 0.10)
      nVT = (nBASE * 0.10) - nPAT
   endif

return(nVT)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR SALDO DEVEDOR ANTERIOR DE IMPOSTO SIMPLIFICADO __________

STATIC function i_sald_anter (cCODIGO)

   local dINI_ANTER, dFIM_ANTER, cMES_ANTERIOR, cANO_ANTERIOR, nREC

   nMES := val(right(XANOMES,2))
   nANO := val(left(XANOMES,4))

   nTRANSP   := 0

   cMES_ANTERIOR := nMES - 1
   cANO_ANTERIOR := val(substr(str(year(dDATA_INI),4),3,2))

   if cMES_ANTERIOR == 0
      cMES_ANTERIOR := 12
      cANO_ANTERIOR--
   endif

   cMES_ANTERIOR := strzero(cMES_ANTERIOR,2)
   cANO_ANTERIOR := strzero(cANO_ANTERIOR,2)

   dINI_ANTER := ctod("01/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR)
   dFIM_ANTER := qfimmes(ctod("01/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR))

   nREC := IMP->(recno())

   // TRAZ SALDO CREDOR, PASSANDO PARA VALOR POSITIVO ____________________________

   IMP->(dbseek(cCODIGO + dtos(dINI_ANTER) + dtos(dFIM_ANTER)))

   if IMP->Codigo == cCODIGO .and. IMP->Data_ini == dINI_ANTER .and. IMP->Data_fim == dFIM_ANTER
      nTRANSP := IMP->Valor_acum
   endif

   IMP->(dbgoto(nREC))

return nTRANSP

