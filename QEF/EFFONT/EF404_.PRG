/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: EMISSAO DE DARF SIMPLIFICADO
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.: EDUARDO BORIO
function ef404

#define K_MAX_LIN 55

#include "ef.ch"

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) .and. XNIVEL==1}
local nCONT   := 0
local lCONF

private lIMPRIME

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bENT1_FILTRO                  // code block de filtro entradas
private bENT2_FILTRO                  // code block de filtro entradas

private bSAI1_FILTRO                  // code block de filtro saidas
private bSAI2_FILTRO                  // code block de filtro saidas

private bISS1_FILTRO                  // code block de filtro servicos prestados
private bISS2_FILTRO                  // code block de filtro servicos prestados

private bBASE1_FILTRO
private bBASE2_FILTRO

private aEDICAO    := {}             // vetor para os campos de entrada de dados

private nENTRADA1                     // total valor contabil de entradas
private nENTRADA2                     // total valor contabil de entradas

private nSAIDA1                       // total valor contabil de saidas
private nSAIDA2                       // total valor contabil de saidas

private nS_CALC1
private nS_CALC2

private nSERV1                       // total de servicos prestados
private nSERV2                       // total de servicos prestados

private nDIVERSAS                    // Receitas de atividades diversas
private nDIVERSAS_ACUM               // Receitas de atividades diversas
private nRESULT                      // Demais resultados
private nCAPITAL                     // Ganhos de capital
private nLIQUIDO                     // Ganhos liquidos
private nLUCRO_INF                   // Lucro inflacionario
private nTRANSP                      // Valor de imposto de regime simplificado do mes anterior
private nMES
private nANO
private nSERVICOS                    //Total de servicos
private nREC_BRUT                    //Total de servicos
private lPERC  := .F.                //Verifica se os servicos ultrapassaram 30% das vendas
private lEPP   := .F.                //Verifica se ultrapassou o limite de microempresa


// SOMA DOS CODIGOS FISCAIS _________________________________________________

private dDATA1_INI                    // Data inicial do ICMS dentro do ano
private dDATA2_INI                    // Data inicial do ICMS dentro do mes

private dDATA1_FIM                    // Data final do ICMS dentro do mes
private dDATA2_FIM                    // Data final do ICMS dentro do mes

private cCODIGO := "6106"
private nJUROS
private nMULTA
private nLIMITE                       // O limite
private nACUM                         // O acumulado (exceto o mes corrente)
private nB_MICRO
private nV_MICRO
private nB_EPP
private nV_EPP
private nTOTAL
private nALIQUOTA
private dDATA_VENC

qlbloc(5,0,"B404A","QBLOC.GLO",1)

if ! TBRS->(dbseek(XANOMES))
   qmensa("Tabela de Regime Simplificado Incompleta para Este Per¡odo !","B")
   return .F.
endif

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

//aadd(aEDICAO,{{ || qgetx(-1,0,@nSERV2     ,"@E 999,999,999.99",NIL,NIL) }  ,"SERVICOS"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nSERV2     ,"@E 999,999,999.99",NIL,NIL) }  ,"SERVICOS"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nDIVERSAS   ,"@E 999,999,999.99",NIL,NIL) } ,"DIVERSAS"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nRESULT     ,"@E 999,999,999.99",NIL,NIL) } ,"RESULT"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAPITAL    ,"@E 999,999,999.99",NIL,NIL) } ,"CAPITAL"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nLIQUIDO    ,"@E 999,999,999.99",NIL,NIL) } ,"LIQUIDO"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nLUCRO_INF  ,"@E 999,999,999.99",NIL,NIL) } ,"LUCRO_INF"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nMULTA      ,"@E 999,999,999.99",NIL,NIL) } ,"MULTA"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nJUROS      ,"@E 999,999,999.99",NIL,NIL) } ,"JUROS"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC  ,"@D"               ,NIL,NIL) } ,"DATA_VENC"  })


do while .T.

   XNIVEL := 1
   XFLAG  := .T.

   nENTRADA1   := 0            // total valor contabil de entradas
   nENTRADA2   := 0            // total valor contabil de entradas

   nSAIDA1     := 0            // total valor contabil de saidas
   nSAIDA2     := 0            // total valor contabil de saidas

   nSERV1   := 0            // total de servicos prestados
   nSERV2   := 0            // total de servicos prestados

   nS_CALC1    := 0
   nS_CALC2    := 0

   nDIVERSAS   := 0            // Receitas de atividades diversas
   nDIVERSAS_ACUM  := 0            // Receitas de atividades diversas
   nRESULT     := 0            // Demais resultados
   nCAPITAL    := 0            // Ganhos de capital
   nLIQUIDO    := 0            // Ganhos liquidos
   nLUCRO_INF  := 0            // Lucro inflacionario

   nMULTA      := 0            // Multa de Imposto
   nJUROS      := 0            // Juros de Imposto

   nLIMITE     := 0
   nACUM       := 0
   nB_MICRO      := 0
   nV_MICRO      := 0
   nB_EPP        := 0
   nV_EPP        := 0
   nTOTAL      := 0
   nALIQUOTA   := 0

   dDATA1_INI   := ctod("01/01/" + left(XANOMES,4))
   dDATA2_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))

   nMES := val(right(XANOMES,2))
   nANO := val(left(XANOMES,4))

   cMES_ANTERIOR := nMES - 1
   cANO_ANTERIOR := nANO

   if cMES_ANTERIOR == 0
      cMES_ANTERIOR := 12
      cANO_ANTERIOR--
   endif

   cMES_ANTERIOR := strzero(cMES_ANTERIOR,2)
   cANO_ANTERIOR := strzero(cANO_ANTERIOR,4)

   dDATA1_FIM    := qfimmes(ctod("01/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR))
   dDATA2_FIM    := qfimmes(dDATA2_INI)
   dDATA_VENC    := ctod("")

   if BASE->(dbseek(dtos(dDATA2_INI) + dtos(dDATA2_FIM)))

      nSERV2      := BASE->SERVICOS
      nDIVERSAS   := BASE->DIVERSAS
      nRESULT     := BASE->RESULT
      nCAPITAL    := BASE->CAPITAL
      nLIQUIDO    := BASE->LIQUIDO
      nLUCRO_INF  := BASE->LUCRO_INF

      nCONT := 1

      qrsay ( nCONT++ , BASE->SERVICOS     ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->DIVERSAS     ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->RESULT       ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->CAPITAL      ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->LIQUIDO      ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , BASE->LUCRO_INF    ,  "@E 999,999,999.99" )

   endif

   if DARF->(dbseek(dtos(dDATA2_INI)+dtos(dDATA2_FIM)+cCODIGO))
      nMULTA      := DARF->Multa
      nJUROS      := DARF->Juros

      qrsay ( nCONT++ , DARF->Multa        ,  "@E 999,999,999.99" )
      qrsay ( nCONT++ , DARF->Juros        ,  "@E 999,999,999.99" )
   endif

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_calc_trib() , NIL )

   if ! lIMPRIME ; return ; endif

   lCONF := qconf("Confirma impressao ?")

   if ! lCONF ; return ; endif

   DARF->(dbsetrelation("TRIB",{||XANOMES+DARF->Cod_Trib},"|DARF->Cod_Trib"))

   DARF->(dbseek(dtos(dDATA2_INI)+dtos(dDATA2_FIM)+cCODIGO))

   if DARF->Valor < 10.00
      qmensa("Valor do Darf ‚ inferior a R$ 10,00","B")
      return
   endif

   i_impressao()

   lCONF := qconf("Confirma impressao de demonstrativo ?")

   if ! lCONF ; return ; endif

   i_imp_demonstrativo()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bENT1_FILTRO  := { || ENT->DATA_LANC >= dDATA1_INI .and. ENT->DATA_LANC <= dDATA1_FIM }
   bSAI1_FILTRO  := { || SAI->DATA_LANC >= dDATA1_INI .and. SAI->DATA_LANC <= dDATA1_FIM }
   bISS1_FILTRO  := { || ISS->DATA_LANC >= dDATA1_INI .and. ISS->DATA_LANC <= dDATA1_FIM }
   bBASE1_FILTRO := { || BASE->DATA_INI >= dDATA1_INI .and. BASE->DATA_FIM <= dDATA1_FIM }

   bBASE2_FILTRO := { || BASE->DATA_INI >= dDATA2_INI .and. BASE->DATA_FIM <= dDATA2_FIM }
   bENT2_FILTRO  := { || ENT->DATA_LANC >= dDATA2_INI .and. ENT->DATA_LANC <= dDATA2_FIM }
   bSAI2_FILTRO  := { || SAI->DATA_LANC >= dDATA2_INI .and. SAI->DATA_LANC <= dDATA2_FIM }
   bISS2_FILTRO  := { || ISS->DATA_LANC >= dDATA2_INI .and. ISS->DATA_LANC <= dDATA2_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select SAI
   if val(left(CONFIG->Anomes,4)) < 2003
      SAI->(dbsetorder(3)) // Codigos Fiscais
      SAI->(dbgotop())
   else
      SAI->(dbsetorder(8)) // Codigos Fiscais
      SAI->(dbgotop())
   endif

   select ENT
   if val(left(CONFIG->Anomes,4)) < 2003
      ENT->(dbsetorder(3)) // Codigos Fiscais
      ENT->(dbgotop())
   else
      ENT->(dbsetorder(8)) // Codigos Fiscais
      ENT->(dbgotop())
   endif

   select ISS         // Servicos Prestados
   ISS->(dbgotop())

   select BASE        // Base do lucro presumido
   BASE->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE CALCULO ___________________________________________

static function i_calc_trib

   local lTRAVA

   nLIMITE := nTOTAL := nS_CALC1 := nS_CALC2 := nSERV1 := nSAIDA1 := nSAIDA2 := nENTRADA1 := nENTRADA2 := 0

   // QUANDO O VALOR DOS SERVICOS NAO FOR INFORMADO E EMPRESA DE SERVICOS ___

   if nSERV2 == 0

      ISS->(dbsetorder(2))  // DTOS(DATA_LANC)

      ISS->(dbseek(dDATA1_INI,.T.))

      do while ! ISS->(eof())

         if eval(bISS1_FILTRO)
            qgirabarra()
            qmensa("Servi‡os: Somando Nota "+ISS->Num_Nf +" / Serie : "+ISS->Serie)
            nS_CALC1 := nS_CALC1 + ISS->VLR_CONT
         endif

         if eval(bISS2_FILTRO)
            qgirabarra()
            qmensa("Servi‡os: Somando Nota "+ISS->Num_Nf +" / Serie : "+ISS->Serie)
            nS_CALC2 := nS_CALC2 + ISS->VLR_CONT
         endif

         ISS->(dbskip())

      enddo

      BASE->(dbgotop())

      //do while ! BASE->(eof())
     //    if eval(bBASE1_FILTRO)
     //       nSERV1 := nSERV1 + BASE->Servicos
     //    endif
     //    BASE->(dbskip())
     // enddo

   else

      BASE->(dbgotop())

      do while ! BASE->(eof())
         if eval(bBASE1_FILTRO)
            nSERV1 := nSERV1 + BASE->Servicos
         endif
         BASE->(dbskip())
      enddo

   endif

   nS_CALC1 := nS_CALC1 + nSERV1
   nS_CALC2 := nS_CALC2 + nSERV2

   BASE->(dbgotop())

   do while ! BASE->(eof())
      if eval(bBASE1_FILTRO)
         nDIVERSAS_ACUM := nDIVERSAS_ACUM + BASE->Diversas
      endif
      BASE->(dbskip())
   enddo


   // NOTAS DE ENTRADA _____________________________________________________

   do while ! ENT->(eof())   // condicao principal de loop
       if val(left(CONFIG->Anomes,4)) < 2003
         if eval(bENT1_FILTRO)
            qmensa("Entradas: Somando Nota "+ENT->Num_Nf +" / Serie : "+ENT->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 1.3X e 2.3X ____________
            if left(ENT->COD_FISC,2) $ "13*23*33"
               nENTRADA1 := nENTRADA1 + ENT->VLR_CONT - ENT->Ipi_Vlr
            endif
         endif

         if eval(bENT2_FILTRO)
            qmensa("Entradas: Somando Nota "+ENT->Num_Nf +" / Serie : "+ENT->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 1.3X e 2.3X ____________
            if left(ENT->COD_FISC,2) $ "13*23*33"
               nENTRADA2 := nENTRADA2 + ENT->VLR_CONT - ENT->Ipi_Vlr
            endif
         endif
      else
         if eval(bENT1_FILTRO)
            qmensa("Entradas: Somando Nota "+ENT->Num_Nf +" / Serie : "+ENT->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 1.3X e 2.3X ____________
            if left(ENT->CFOP,3) $ "220*120"
               nENTRADA1 := nENTRADA1 + ENT->VLR_CONT - ENT->Ipi_Vlr
            endif
         endif

         if eval(bENT2_FILTRO)
            qmensa("Entradas: Somando Nota "+ENT->Num_Nf +" / Serie : "+ENT->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 1.3X e 2.3X ____________
            if left(ENT->CFOP,3) $ "120*220"
               nENTRADA2 := nENTRADA2 + ENT->VLR_CONT - ENT->Ipi_Vlr
            endif
         endif

      endif
      ENT->(dbskip())

   enddo

   // NOTAS DE SAIDA _______________________________________________________

   do while ! SAI->(eof())   // condicao principal de loop
      if val(left(CONFIG->anomes,4)) < 2003
         if eval(bSAI1_FILTRO)
            qmensa("Sa¡da: Somando Nota "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 5.1X 5.6X 6.1X 6.6X 7.1X
            if SAI->Cod_fisc $ "596*696*662*562*573"
               nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif
            if left(SAI->COD_FISC,2) $ "51*61*71*73"
               nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif
         endif

         if eval(bSAI2_FILTRO)
            qmensa("Sa¡da: Somando Nota "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 5.1X 5.6X 6.1X 6.6X 7.1X
            if SAI->Cod_fisc $ "596*696*662*562*573"
               nSAIDA2 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif
            if left(SAI->COD_FISC,2) $ "51*61*71*73"
               nSAIDA2 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif
         endif
      else
         if eval(bSAI1_FILTRO)
            qmensa("Sa¡da: Somando Nota "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 5.1X 5.6X 6.1X 6.6X 7.1X
            if SAI->Cfop $ "5904*5923*5932*6923*6904*6932"
               nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif
         
            if left(SAI->CFOP,3) $ "510*511*512*610*611*612"
               nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif

            if left(SAI->CFOP,3) $ "535*635"
               nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif

//            if left(SAI->Cfop,3) $ "515*615*515*615"
//               nSAIDA1 := nSAIDA1 - SAI->VLR_CONT
//            endif

         endif

         if eval(bSAI2_FILTRO)
            qmensa("Sa¡da: Somando Nota "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 5.1X 5.6X 6.1X 6.6X 7.1X
            if SAI->Cfop $ "5904*5923*5932*6923*6904*6932"
               nSAIDA2 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif

            if left(SAI->CFOP,3) $ "510*511*512*610*611*612"
               nSAIDA2 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif
            if left(SAI->CFOP,3) $ "535*635"
               nSAIDA2 += SAI->VLR_CONT - SAI->Ipi_Vlr
            endif

  //          if left(SAI->Cfop,3) $ "515*615"
  //             nSAIDA2 := nSAIDA2 - SAI->VLR_CONT
  //          endif

         endif

      endif
      SAI->(dbskip())

   enddo

   // CALCULA TRIBUTOS _________________________________________________________

   // TOTAL BRUTO ______________________________________________________________

   nLIMITE := (( nSAIDA1   - nENTRADA1 ) + nS_CALC1 + nDIVERSAS_ACUM +  nRESULT +;
                 nCAPITAL  + nLIQUIDO    + nLUCRO_INF)

   nTOTAL  := (( nSAIDA2   - nENTRADA2 ) + nS_CALC2 + nDIVERSAS + nRESULT +;
                 nCAPITAL  + nLIQUIDO    + nLUCRO_INF)

   nSERVICOS := nS_CALC2 + nS_CALC1

   if nSERVICOS >= ( (nSAIDA2+nSAIDA1+nSERVICOS) - (nENTRADA2+nENTRADA1)) * 0.30
      lPERC := .T.
   else
      lPERC := .F.
   endif

   nREC_BRUT := ( (nSERVICOS+nSAIDA1+nSAIDA2)-(nENTRADA2+nENTRADA1) )
   qrsay(10,nSERVICOS,"@E 9,999,999.99")
   qrsay(11,nREC_BRUT,"@E 9,999,999.99")
   qrsay(12, (nSERVICOS/nREC_BRUT) * 100,"@E 99.99")
   nACUM   := nLIMITE
   nLIMITE := nLIMITE + nTOTAL


   // CALCULA EM REGIME SIMPLIFICADO ___________________________________________

   lIMPRIME := .T.

   do case
      case nLIMITE <= TBRS->Rs_lim01
           do case
              case XTIPOEMP == "9"
                   if XNIVEL_EMP == "A"
                      nALIQUOTA := TBRS->Rs_ali01
                   else
                      nALIQUOTA := TBRS->Rs_ali04
                   endif
              case XTIPOEMP == "0"
                   if XNIVEL_EMP == "A"
                      nALIQUOTA := TBRS->Rs_ipi01
                   else
                      nALIQUOTA := TBRS->Rs_ipi04
                   endif
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase
      case nLIMITE <= TBRS->Rs_lim02
           do case
              case XTIPOEMP == "9"
                   if XNIVEL_EMP == "A"
                      nALIQUOTA := TBRS->Rs_ali02
                   else
                      nALIQUOTA := TBRS->Rs_ali04
                   endif
              case XTIPOEMP == "0"
                   if XNIVEL_EMP == "A"
                      nALIQUOTA := TBRS->Rs_ipi02
                   else
                      nALIQUOTA := TBRS->Rs_ipi04
                   endif
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase
      case nLIMITE <= TBRS->Rs_lim03
           do case
              case XTIPOEMP == "9"
                   if XNIVEL_EMP == "A"
                      nALIQUOTA := TBRS->Rs_ali03
                   else
                      nALIQUOTA := TBRS->Rs_ali04
                   endif
              case XTIPOEMP == "0"
                   if XNIVEL_EMP == "A"
                      nALIQUOTA := TBRS->Rs_ipi03
                   else
                      nALIQUOTA := TBRS->Rs_ipi04
                   endif
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim04
           do case
              case XTIPOEMP == "9"
                   if XNIVEL_EMP == "A"
                      nALIQUOTA := TBRS->Rs_ali04
                   else
                      nALIQUOTA := TBRS->Rs_ali04
                   endif
              case XTIPOEMP == "0"
                   if XNIVEL_EMP == "A"
                      nALIQUOTA := TBRS->Rs_ipi04
                   else
                      nALIQUOTA := TBRS->Rs_ipi04
                   endif
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim05
           if XNIVEL_EMP == "A"
              if nACUM <= TBRS->Rs_lim04
                 nB_MICRO := TBRS->Rs_lim04 - nACUM
                 nV_MICRO := nB_MICRO * 0.054
                 nB_EPP   := nLIMITE - TBRS->Rs_lim04
                 nV_EPP   := nB_EPP * 0.058
                 alert("Micro empresa ultrapassou a faixa. Favor enviar p/ Receita Federal FCPJ (Ficha Cadastral de Pessoa Juridica) para alteracao de porte.")
                 lEPP := .T.
              endif
           endif

           do case
              case XTIPOEMP == "9"
                  nALIQUOTA := TBRS->Rs_ali05
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi05
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim06
           do case
              case XTIPOEMP == "9"
                  nALIQUOTA := TBRS->Rs_ali06
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi06
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase
      case nLIMITE <= TBRS->Rs_lim07
           do case
              case XTIPOEMP == "9"
                  nALIQUOTA := TBRS->Rs_ali07
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi07
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase
      case nLIMITE <= TBRS->Rs_lim08
           do case
              case XTIPOEMP == "9"
                  nALIQUOTA := TBRS->Rs_ali08
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi08
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase
      case nLIMITE <= TBRS->Rs_lim09
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali09
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi09
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase
      case nLIMITE <= TBRS->Rs_lim10
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali10
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi10
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase
      case nLIMITE <= TBRS->Rs_lim11
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali11
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi11
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase
      case nLIMITE <= TBRS->Rs_lim12
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali12
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi12
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase
      case nLIMITE <= TBRS->Rs_lim13
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali13
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi13
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim14
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali14
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi14
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim15
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali15
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi15
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim16
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali16
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi16
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim17
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali17
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi17
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim18
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali18
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi18
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim19
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali19
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi19
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim20
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali20
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi20
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim21
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali21
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi21
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

      case nLIMITE <= TBRS->Rs_lim22
           do case
              case XTIPOEMP == "9"
                   nALIQUOTA := TBRS->Rs_ali22
              case XTIPOEMP == "0"
                   nALIQUOTA := TBRS->Rs_ipi22
              other
                  qmensa("Configure a Op‡„o 802 !","B")
                  nALIQUOTA := 0
                  lIMPRIME := .F.
                  return .F.
           endcase

//    other
//         qmensa("O limite m ximo para c culo simples foi excedido. Use a Op‡„o 401 !","B")
//         lIMPRIME := .F.
//         return .F.
   endcase

   if lPERC
      nALIQUOTA := nALIQUOTA * 1.5
   endif

   if lEPP
      nVAL_RECOLHE := nV_MICRO + nV_EPP
   else
      nVAL_RECOLHE := nTOTAL * nALIQUOTA / 100
   endif
   i_sald_anter()

   if IMP->(dbseek(cCODIGO+dtos(dDATA2_INI) + dtos(dDATA2_FIM)+"0001"))
      lTRAVA := IMP->(qrlock())
   else
      lTRAVA := IMP->(qappend())
   endif

   if lTRAVA

      replace IMP->CODIGO      with cCODIGO
      replace IMP->DATA_INI    with dDATA2_INI
      replace IMP->DATA_FIM    with dDATA2_FIM

      nVAL_RECOLHE := nTRANSP + nVAL_RECOLHE

      if nVAL_RECOLHE < 10.00
         replace IMP->Vl_r_s_acu with nVAL_RECOLHE
      else
         replace IMP->Vl_r_s_acu with 0
      endif

      IMP->(qunlock())

   endif

   i_grava_darf(cCODIGO,nVAL_RECOLHE)

   // GRAVA DADOS INFORMADOS ___________________________________________________

   if BASE->(dbseek(dtos(dDATA2_INI) + dtos(dDATA2_FIM)))
      lTRAVA := BASE->(qrlock())
   else
      lTRAVA := BASE->(qappend())
   endif

   if lTRAVA
      replace BASE->DATA_INI    with dDATA2_INI
      replace BASE->DATA_FIM    with dDATA2_FIM
      replace BASE->SERVICOS    with nS_CALC2
      replace BASE->DIVERSAS    with nDIVERSAS
      replace BASE->RESULT      with nRESULT
      replace BASE->CAPITAL     with nCAPITAL
      replace BASE->LIQUIDO     with nLIQUIDO
      replace BASE->LUCRO_INF   with nLUCRO_INF
      BASE->(qunlock())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GRAVAR AS DARF'S _____________________________________________

static function i_grava_darf ( cCODIGO , nVAL_RECOLHE )

   // APLICA ROUND PARA EVITAR PROBLEMAS DE ERRO NA SOMA ____________________

   nVAL_RECOLHE := round ( nVAL_RECOLHE, 2)
   // REALIZA TRAVAMENTO ____________________________________________________

   if DARF->(dbseek(dtos(dDATA2_INI) + dtos(dDATA2_FIM) + cCODIGO))
      lTRAVA := DARF->(qrlock())
   else
      lTRAVA := DARF->(qappend())
   endif

   // GRAVA DARF ____________________________________________________________

   if lTRAVA
      replace DARF->DATA_INI    with dDATA2_INI
      replace DARF->DATA_FIM    with dDATA2_FIM
      replace DARF->COD_TRIB    with cCODIGO

      replace DARF->VALOR       with nVAL_RECOLHE

      replace DARF->Multa       with nMULTA
      replace DARF->Juros       with nJUROS
      replace DARF->Limite      with nLIMITE
      replace DARF->Bc_mes      with nTOTAL
      DARF->(qunlock())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O DARF ______________________________________________

static function i_impressao

   nMES := val(right(XANOMES,2))
   nANO := val(left(XANOMES,4))

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   // INCREMENTA MES DO VENCIMENTO _______________________________________________

   nMES++

   // INCREMENTA ANO _____________________________________________________________

   if nMES == 13
      nMES := 1
      nANO++
   endif

   @ prow(),pcol() say XCOND0

   @ prow()  ,066  say dtoc(DARF->Data_fim)

   @ prow()+2,056 say XCGCCPF

   @ prow()+4,060 say transform(nLIMITE,"@E 999,999,999.99")

   @ prow()+2,069 say transform(nALIQUOTA,"@E 99.99")

   @ prow()+2,000 say XCOND2 + XRAZAO + " / " + XTELEFONE + XCOND0

// @ prow()  ,057 say TRIB->Dia_Venc + "/" + strzero(nMES,2)+ "/" + strzero(nANO,2)

// @ prow()+1,057 say DARF->Valor picture "@E 999,999,999.99"

   @ prow()  ,060 say DARF->Valor picture "@E 999,999,999.99"

      // IMPRIME MULTA E JUROS, CASO EXISTAM _____________________________________

   if DARF->Multa > 0
      @ prow()+2,60 say DARF->Multa picture "@E 999,999,999.99"
   else
      @ prow()+2,00 say ""
   endif

   if DARF->Juros > 0
      @ prow()+2,60 say DARF->Juros picture "@E 999,999,999.99"
   else
      @ prow()+2,00 say ""
   endif

   // IMPRIME O TOTAL, CASO EXISTAM MULTA E JUROS ________________________________

// @ prow()+2,60 say (DARF->Valor + DARF->Multa + DARF->Juros) picture "@E 999,999,999.99"
// @ prow()+8,00 say ""
   if lEPP
      @ prow()+1,00 say "MICRO.:   "+transform(nB_MICRO,"@E 9,999,999.99") + " - " + dtoc(dDATA_VENC)
      @ prow()+1,00 say "EPP   :   "+transform(nB_EPP,"@E 9,999,999.99")
      @ prow()  ,60 say (nV_EPP + nV_MICRO + DARF->Multa + DARF->Juros) picture "@E 999,999,999.99"
      @ prow()+8,00 say ""
   else
      @ prow()+2,10 say transform(nTOTAL,"@E 9,999,999.99") + " - " + dtoc(dDATA_VENC)
      @ prow()  ,60 say (DARF->Valor + DARF->Multa + DARF->Juros) picture "@E 999,999,999.99"
      @ prow()+8,00 say ""
   endif

   qstopprn(.F.)

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR SALDO DEVEDOR ANTERIOR DE IMPOSTO SIMPLIFICADO __________

STATIC function i_sald_anter

   local dINI_ANTER, dFIM_ANTER, cMES_ANTERIOR, cANO_ANTERIOR, nREC

   nMES := val(right(XANOMES,2))
   nANO := val(left(XANOMES,4))

   nTRANSP   := 0

   cMES_ANTERIOR := nMES - 1
   cANO_ANTERIOR := year(dDATA2_INI)

   if cMES_ANTERIOR == 0
      cMES_ANTERIOR := 12
      cANO_ANTERIOR--
   endif

   cMES_ANTERIOR := strzero(cMES_ANTERIOR,2)
   cANO_ANTERIOR := strzero(cANO_ANTERIOR,4)

   dINI_ANTER := ctod("01/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR)
   dFIM_ANTER := qfimmes(ctod("01/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR))

   nREC := IMP->(recno())

   // TRAZ SALDO CREDOR, PASSANDO PARA VALOR POSITIVO ____________________________

   IMP->(dbseek(cCODIGO + dtos(dINI_ANTER) + dtos(dFIM_ANTER)))

   if IMP->Codigo == cCODIGO .and. IMP->Data_ini == dINI_ANTER .and. IMP->Data_fim == dFIM_ANTER
      nTRANSP := IMP->Vl_r_s_acu
   endif

   IMP->(dbgoto(nREC))

return nTRANSP

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_imp_demonstrativo

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND0

   @ prow()+20,40 Say XAENFAT + "DEMONSTRATIVO"
// @ prow()  ,40 Say XAENFAT + "DEMONSTRATIVO"
   @ prow()+1,67 SAY qnomemes(val(right(XANOMES,2))) + "/" + left(XANOMES,4) + XDENFAT
   @ prow()+1,01 SAY "Empresa: " + XRAZAO
   @ prow()+1,01 Say "CGC(MF): " + XCGCCPF
   @ prow()+1,01 SAY replicate("-",78)

   @ prow()+1,01 Say XAENFAT + "IMPOSTO SIMPLES (6106): " + XDENFAT

   @ prow()+2,01 say "Valor acumulado.: " + transform(nLIMITE,"@E 999,999,999.99")
   @ prow()+1,01 say "Valor da Fatura.: " + transform(nTOTAL,"@E 999,999,999.99")
   @ prow()+1,01 say "Aliquota(%).....: " + transform(nALIQUOTA,"@E 99.99")
   @ prow()+1,01 say "Valor do Imposto: " + transform((DARF->Valor + DARF->Multa + DARF->Juros),"@E 999,999,999.99")

   qstopprn()

return


