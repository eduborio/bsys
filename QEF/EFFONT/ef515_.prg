//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: DADOS PARA DECLARACAO DE IRPJ SOBRE LUCRO PRESUMIDO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDURADO AUGUSTO BORIO
// INICIO.....: NOVEMBRO DE 1995
// OBS........:
// ALTERACOES.: MAIO DE 2004
function ef515

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) .and. XNIVEL==1}
private cPIC1   := "@E 9,999,999.99"
private aEDICAO := {}                // vetor para os campos de entrada de dados

private bSAI_FILTRO                  // code block de filtro saidas
private bISS_FILTRO                  // code block de filtro servicos prestados

private nVENDAS                      // total valor contabil de saidas
private nSERVICOS                    // total de servicos prestados
private nMES                         // Mes do imposto
private nIRPJ                        // I.R. a recolher
private nSIMPLES   := 0              // Valor do Darf Simples
private nUSIMPLES  := 0              // Valor do Darf Simples
private nACUM      := 0              // Valor Acumulado do Darf Simples
private nBASE_MES  := 0              // Base de calculo no mes corrente
private nALIQ                        // Aliquota do mes

private nPIS                         // 3885 - PIS - RECEITA OPERACIONAL
private nPIS1                        // 8109 - PIS FATURAMENTO
private nPIS2                        // 8002 - PIS DEDUCAO
private nPIS3                        // 8205 - PIS REPIQUE
private nPISF                        // 4574 - PIS - ENT.FINANCEIRAS,SEGURADORAS EQUIP

private nCOFINS                      // COFINS a recolher
private nCONT_SOC                    // CONTRIBUICAO SOCIAL a recolher

private nUVENDAS
private nUSERVICOS
private nUPIS
private nUPIS1
private nUPIS2
private nUPIS3
private nUPISF
private nUCOFINS
private nUCONT_SOC
private nUIRPJ

// TOTAL GERAL EM REAIS __________________________________________________

private nTVENDAS
private nTSIMPLES   := 0
private nTUSIMPLES  := 0
private nTACUM      := 0
private nTSERVICOS
private nTPIS
private nTPIS1
private nTPIS2
private nTPIS3
private nTPISF
private nTCOFINS
private nTCONT_SOC
private nTIRPJ

// TOTAL GERAL EM UFIR'S _________________________________________________

private nTUVENDAS
private nTUSERVICOS
private nTUPIS
private nTUPIS1
private nTUPIS2
private nTUPIS3
private nTUPISF
private nTUCOFINS
private nTUCONT_SOC
private nTUIRPJ

private nUFIR_1                      // Ufir Pis e Cofins

private dDATA_INI                    // Data inicial do ICMS dentro do mes
private dDATA_FIM                    // Data final do ICMS dentro do mes

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B515A","QBLOC.GLO",1)

do while .T.

   nVENDAS     := 0                  // total valor contabil de saidas
   nSERVICOS   := 0                  // total de servicos prestados
   XNIVEL      := 1
   XFLAG       := .T.
   nMES        := 1                  // inicia o mes em janeiro
   nIRPJ       := 0                  // I.R. a recolher

   nPIS        := 0                  // 3885 - PIS - RECEITA OPERACIONAL
   nPIS1       := 0                  // 8109 - PIS FATURAMENTO
   nPIS2       := 0                  // 8002 - PIS DEDUCAO
   nPIS3       := 0                  // 8205 - PIS REPIQUE
   nPISF       := 0                  // 4574 - PIS - ENT.FINANCEIRAS,SEGURADORAS EQUIP
   nSIMPLES    := 0
   nACUM       := 0

   nCOFINS     := 0                  // COFINS a recolher
   nCONT_SOC   := 0                  // CONTRIBUICAO SOCIAL a recolher
   nUVENDAS    := 0
   nUSERVICOS  := 0

   nUPIS       := 0
   nUPIS1      := 0
   nUPIS2      := 0
   nUPIS3      := 0
   nUPISF      := 0

   nUCOFINS    := 0
   nUCONT_SOC  := 0
   nUIRPJ      := 0

   nTVENDAS    := 0
   nTSERVICOS  := 0
   nTSIMPLES   := 0
   nTACUM      := 0

   nTPIS       := 0
   nTPIS1      := 0
   nTPIS2      := 0
   nTPIS3      := 0
   nTPISF      := 0

   nTCOFINS    := 0
   nTCONT_SOC  := 0
   nTIRPJ      := 0
   nTUVENDAS   := 0
   nTUSERVICOS := 0

   nTUPIS      := 0
   nTUPIS1     := 0
   nTUPIS2     := 0
   nTUPIS3     := 0
   nTUPISF     := 0

   nTUCOFINS   := 0
   nTUCONT_SOC := 0
   nTUIRPJ     := 0

   if eval ( bESCAPE ) ; dbcloseall() ; return ; endif

   if ( i_inicializacao() , i_impressao() , NIL )

   return

enddo

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   qmensa("")

   if !qconf("Confirma emiss„o do relat¢rio !","B")
      return .F.
   endif

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select SAI
   SAI->(dbgotop())

   select ISS         // Servicos Prestados
   ISS->(dbgotop())

   select BASE        // Base do lucro presumido
   BASE->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE CALCULO ___________________________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND2

   @ prow()  ,00  say "Empresa: " + XRAZAO
   @ prow()+1,00  say "CNPJ   : " + XCGCCPF
   @ prow()+1,00  say "DADOS PARA DECLARACAO DE IRPJ - LUCRO PRESUMIDO"
   @ prow()  ,137 say "ANO BASE..: " + left(XANOMES,4)
   @ prow()+1,00  say replicate("-",153)
   @ prow()+1,00  say "MES           VENDAS    SERVICOS  PIS REC. OPERAC.   PIS FATURAM.     VALOR ACUMULADO    B.C. SIMPLES    VALOR SIMPLES     COFINS    C.SOCIAL        IRPJ"
   @ prow()+1,00  say replicate("-",153)

   do while nMES < 13

      // INICIALIZA COM 1 PARA EVITAR DIVISAO POR ZERO _________________________

      nUFIR_1 := 1

      dDATA_INI := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
      dDATA_FIM := qfimmes(ctod("01/" + strzero(nMES,2)+ "/" + left(XANOMES,4)))

      // CRIA MACRO DE FILTRO __________________________________________________

      bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }
      bISS_FILTRO := { || ISS->DATA_LANC >= dDATA_INI .and. ISS->DATA_LANC <= dDATA_FIM }

      // BUSCA VALOR DOS SERVICOS E UFIR NO ARQUIVO DE BASE ____________________

      if BASE->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM)))
         nSERVICOS := BASE->SERVICOS
         nUFIR_1   := BASE->UFIR_1
      endif

      qgirabarra()

      // QUANDO O VALOR DOS SERVICOS NAO FOR ENCONTRADO E EMPRESA DE SERVICOS __

      if nSERVICOS = 0 .and. XTIPOEMP $ "67"

         ISS->(dbgotop())

         do while ! ISS->(eof())                   // condicao principal de loop
            if eval(bISS_FILTRO)
               qmensa("Totalizando servi‡os de " + alltrim(qnomemes(nMES)) + " Aguarde...")
               nSERVICOS := nSERVICOS + ISS->VLR_CONT
            endif
            ISS->(dbskip())
         enddo

      endif

      // NOTAS DE SAIDA _______________________________________________________

      SAI->(dbgotop())

      do while ! SAI->(eof())                     // condicao principal de loop
         if eval(bSAI_FILTRO)
            if val(CONFIG->Anomes) <= 200212
               if left(SAI->COD_FISC,2) $ "51*56*61*66*71"
                  qmensa("Totalizando vendas de " + alltrim(qnomemes(nMES)) + " Aguarde...")
                  nVENDAS += SAI->VLR_CONT - SAI->Ipi_Vlr
               endif
            else
               if left(SAI->CFOP,2) $ "51*56*61*66*71"
                  qmensa("Totalizando vendas de " + alltrim(qnomemes(nMES)) + " Aguarde...")
                  nVENDAS += SAI->VLR_CONT - SAI->Ipi_Vlr
               endif

            endif

         endif
         SAI->(dbskip())
      enddo

      if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + K_PIS))
         nPIS  := DARF->Valor
         nUPIS := DARF->Valor_Ufir
      endif

      if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + K_PIS1))
         nPIS1  := DARF->Valor
         nUPIS1 := DARF->Valor_Ufir
      endif

      if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + "6106"))
         nSIMPLES   := DARF->Valor
         nBASE_MES  := DARF->Bc_mes
         nACUM      := DARF->Limite
         nUSIMPLES := DARF->Valor_Ufir
      endif

      if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + K_PIS2))
         nPIS2  := DARF->Valor
         nUPIS2 := DARF->Valor_Ufir
      endif

      if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + K_PIS3))
         nPIS3  := DARF->Valor
         nUPIS3 := DARF->Valor_Ufir
      endif

      if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + K_PISF))
         nPISF  := DARF->Valor
         nUPISF := DARF->Valor_Ufir
      endif

      if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + K_COFINS))
         nCOFINS  := DARF->Valor
         nUCOFINS := DARF->Valor_Ufir
      endif

      if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + K_CONT_SOC))
         nCONT_SOC  := DARF->Valor
         nUCONT_SOC := DARF->Valor_Ufir
      else
         if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + K_CONTR_SOC))
            nCONT_SOC  := DARF->Valor
            nUCONT_SOC := DARF->Valor_Ufir
         endif
      endif

      if DARF->(dbseek(dtos(dDATA_INI) + dtos(dDATA_FIM) + K_IRPJ))
         nIRPJ  := DARF->Valor
         nUIRPJ := DARF->Valor_Ufir
      endif

      i_impr()

      nMES++

   enddo

   @ prow()+1,00  say REPLICATE("-",153)

   @ prow()+1,00  say "TOTAIS.:"
   @ prow()  ,08  say nTVENDAS    pict cPIC1
   @ prow()  ,20  say nTSERVICOS  pict cPIC1
   @ prow()  ,35  say nTPIS       pict cPIC1
   @ prow()  ,53  say nTPIS1      pict cPIC1
   @ prow()  ,73  say " "         //nTSIMPLES   pict cPIC1
   @ prow()  ,89  say " "         //nTSIMPLES   pict cPIC1
   @ prow()  ,106 say nTSIMPLES   pict cPIC1
   @ prow()  ,117 say nTCOFINS    pict cPIC1
   @ prow()  ,129 say nTCONT_SOC  pict cPIC1
   @ prow()  ,141 say nTIRPJ      pict cPIC1

   @ prow()+1,08  say nTUVENDAS   pict cPIC1
   @ prow()  ,20  say nTUSERVICOS pict cPIC1
   @ prow()  ,35  say nTUPIS      pict cPIC1
   @ prow()  ,53  say nTUPIS1     pict cPIC1
   @ prow()  ,73  say " "         //nTUSIMPLES  pict cPIC1
   @ prow()  ,89  say " "         //nTUPIS3     pict cPIC1
   @ prow()  ,106 say " "         //nTUSIMPLES  pict cPIC1
   @ prow()  ,117 say nTUCOFINS   pict cPIC1
   @ prow()  ,129 say nTUCONT_SOC pict cPIC1
   @ prow()  ,141 say nTUIRPJ     pict cPIC1

   qmensa("")

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impr

   // CALCULA VENDAS E SERVICOS EM UFIR _____________________________________

   nUVENDAS   += (nVENDAS   / nUFIR_1)
   nUSERVICOS += (nSERVICOS / nUFIR_1)

   // APLICA ROUND PARA EVITAR PROBLEMAS DE ERRO NA SOMA ____________________

   nUVENDAS   := round (nUVENDAS   , 2)
   nUSERVICOS := round (nUSERVICOS , 2)

   // TOTAL GERAL EM REAIS __________________________________________________

   nTVENDAS   += nVENDAS
   nTSERVICOS += nSERVICOS
   nTPIS      += nPIS
   nTPIS1     += nPIS1
   nTSIMPLES  += nSIMPLES
   nTUSIMPLES  += nUSIMPLES
   nTCOFINS   += nCOFINS
   nTCONT_SOC += nCONT_SOC
   nTIRPJ     += nIRPJ

   // TOTAL GERAL EM UFIR'S _________________________________________________

   nTUVENDAS   += nUVENDAS
   nTUSERVICOS += nUSERVICOS
   nTUPIS      += nUPIS
   nTUPIS1     += nUPIS1
   nTUPIS2     += nUPIS2
   nTUPIS3     += nUPIS3
   nTUPISF     += nUPISF
   nTUCOFINS   += nUCOFINS
   nTUCONT_SOC += nUCONT_SOC
   nTUIRPJ     += nUIRPJ

   @ prow()+2,00  say left(qnomemes(nMES),3) + " R$"
   @ prow()  ,08  say nVENDAS   pict cPIC1
   @ prow()  ,20  say nSERVICOS pict cPIC1
   @ prow()  ,35  say nPIS      pict cPIC1
   @ prow()  ,53  say nPIS1     pict cPIC1
   @ prow()  ,73  say nACUM     pict cPIC1
   @ prow()  ,89  say nBASE_MES pict cPIC1
   @ prow()  ,106 say nSIMPLES  pict cPIC1
   @ prow()  ,117 say nCOFINS   pict cPIC1
   @ prow()  ,129 say nCONT_SOC pict cPIC1
   @ prow()  ,141 say nIRPJ     pict cPIC1

   @ prow()+1,00  say "Ufir's"
   @ prow()  ,08  say nUVENDAS   pict cPIC1
   @ prow()  ,20  say nUSERVICOS pict cPIC1
   @ prow()  ,35  say nUPIS      pict cPIC1
   @ prow()  ,53  say nUPIS1     pict cPIC1
   @ prow()  ,73  say " "//nUPIS2     pict cPIC1
   @ prow()  ,89  say " "//nUSIMPLES  pict cPIC1
   @ prow()  ,106 say " "//nUSIMPLES    pict cPIC1
   @ prow()  ,117 say nUCOFINS   pict cPIC1
   @ prow()  ,129 say nUCONT_SOC pict cPIC1
   @ prow()  ,141 say nUIRPJ     pict cPIC1

   // ZERA VALORES MENSAIS __________________________________________________

   nVENDAS   := nSERVICOS  := nPIS  := nPIS1  := nPIS2  := nPIS3  := nPISF  := nCOFINS  := nCONT_SOC  := nIRPJ  := 0
   nUVENDAS  := nUSERVICOS := nUPIS := nUPIS1 := nUPIS2 := nUPIS3 := nUPISF := nUCOFINS := nUCONT_SOC := nUIRPJ := 0
   nSIMPLES  := 0
   nBASE_MES := 0
   nACUM     := 0
   nUSIMPLES :=  0


return

