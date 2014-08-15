
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: RESUMO MAQUINA REGISTRADORA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MAIO DE 1995
// OBS........:
// ALTERACOES.:
function ef509

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1) }

// VERIFICA SE EMPRESA E' MAQUINA REGISTRADORA ______________________________

if !XTIPOEMP $ "38"
   qmensa("Empresa n„o Cadastrada como M quina Registradora !","B")
   return
endif

private bENT_FILTRO                 // code block de filtro entradas
private bSAI_FILTRO                 // code block de filtro saidas
private aEDICAO := {}               // vetor para os campos de entrada de dados

private cPIC1   := "@E  999,999,999.99"

private nTOT_ENT                    // total entradas
private nTOT_SAI                    // total saidas
private nISEN_ENT                   // total isentos icms - informado na entrada
private nISEN_SAI                   // total isentos icms - informado na saida
private nTOT_OUT                    // total outras icms
private nOUT_ENT                    // total de mercadorias com substituicao tributaria
private nOUT_SAI                    // total de mercadorias com substituicao tributaria
private nOUT_BASES                  // Outras bases de icms
private nVLR_TOT_1                  // Soma total para calculo do coeficiente de ajuste da base de calculo
private nVLR_TOT_2                  // Soma total * pela aliquota do codigo
private nCOEFICIENTE                // Coeficiente de ajuste para nova base de calculo
private nDEVOLUCAO                  // Total das devolucoes
private nDEDUCAO                    // Total de deducoes

private nSOMA_11                    // Valor codigo maquina 11
private nSOMA_12                    // Valor codigo maquina 12
private nSOMA_13                    // Valor codigo maquina 13
private nSOMA_14                    // Valor codigo maquina 14
private nSOMA_21                    // Valor codigo maquina 21
private nSOMA_22                    // Valor codigo maquina 22
private nSOMA_23                    // Valor codigo maquina 23
private nSOMA_24                    // Valor codigo maquina 24
private nSOMA_31                    // Valor codigo maquina 31
private nSOMA_32                    // Valor codigo maquina 32
private nSOMA_33                    // Valor codigo maquina 33
private nSOMA_34                    // Valor codigo maquina 34
private nSOMA_41                    // Valor codigo maquina 41

private dDATA_INI                   // Data inicial do ICMS dentro do mes
private dDATA_FIM                   // Data final do ICMS dentro do mes

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B509A","QBLOC.GLO",1)

do while .T.

   XNIVEL := 1
   XFLAG  := .T.

   nTOT_ENT     := 0                // Total do valor contabil entradas
   nTOT_SAI     := 0                // Total do valor contabil saidas
   nISEN_ENT    := 0                // Total de isentas para deducao nas saidas
   nISEN_SAI    := 0                // Total de isentas nas saidas
   nTOT_OUT     := 0                // Total de outras para deducao nas saidas
   nOUT_ENT     := 0                // Total de substituicao tributaria para deducao nas saidas
   nOUT_SAI     := 0                // Total de substituicao tributaria para deducao nas saidas
   nOUT_BASES   := 0                // Base  de calculo das outras aliquotas
   nVLR_TOT_1   := 0                // Soma  total para calculo do coeficiente de ajuste da base de calculo
   nVLR_TOT_2   := 0                // Soma  total * pela aliquota do codigo
   nCOEFICIENTE := 0                // Coeficiente de ajuste para nova base de calculo
   nDEVOLUCAO   := 0                // Total de devolucoes
   nDEDUCAO     := 0                // Total de deducoes

   dDATA_INI    := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM    := qfimmes(dDATA_INI)

   nSOMA_11     := 0                // Valor codigo maquina 11
   nSOMA_12     := 0                // Valor codigo maquina 12
   nSOMA_13     := 0                // Valor codigo maquina 13
   nSOMA_14     := 0                // Valor codigo maquina 14
   nSOMA_21     := 0                // Valor codigo maquina 21
   nSOMA_22     := 0                // Valor codigo maquina 22
   nSOMA_23     := 0                // Valor codigo maquina 23
   nSOMA_24     := 0                // Valor codigo maquina 24
   nSOMA_31     := 0                // Valor codigo maquina 35
   nSOMA_32     := 0                // Valor codigo maquina 32
   nSOMA_33     := 0                // Valor codigo maquina 33
   nSOMA_34     := 0                // Valor codigo maquina 34
   nSOMA_41     := 0                // Valor codigo maquina 41

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   if eval ( bESCAPE ) ; dbcloseall() ; return ; endif

   if ( i_inicializacao() , i_calculo() , NIL )

   return

enddo

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   qmensa("")

   if !qconf("Confirma o calculo do resumo para M quina Registradora !","B")
      return .F.
   endif

   // CRIA MACRO DE FILTRO __________________________________________________

   bENT_FILTRO := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   set softseek on

   select IMP                           // IMPOSTO ICMS e IPI
   IMP->(dbgotop())

   select OUTENT                        // ENTRADA - OUTRAS ALIQUOTAS DE ICMS
   OUTENT->(dbgotop())

   select OUTSAI                        // SAIDA - OUTRAS ALIQUOTAS DE ICMS
   OUTSAI->(dbgotop())

   select ENT                           // NOTAS FISCAIS DE ENTRADA
   ENT->(dbsetorder(2))
   ENT->(dbseek(dtos(dDATA_INI)))

   select SAI                           // NOTAS FISCAIS DE SAIDA
   SAI->(dbsetorder(2))
   SAI->(dbseek(dtos(dDATA_INI)))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE CALCULO ____________________________

static function i_calculo

   do while ! ENT->(eof())              // condicao principal de loop

      if eval(bENT_FILTRO)

         qmensa("Somando Nota: "+ENT->Num_Nf +" / Serie : "+ENT->Serie)

         if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->NUM_NF+ENT->SERIE+ENT->FILIAL))
            for nCONT := 1 to 3
//                 aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
//                 aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
//                 aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr

                 // BASE DAS OUTRAS ALIQUOTAS DE ICMS ___________________

                 nOUT_BASES += OUTENT->Icm_base

                 do case
                    case OUTENT->Cod_Maq == "90"
                         nISEN_ENT  += OUTENT->Icm_Base
                    case OUTENT->Cod_Maq == "11"
                         nSOMA_11   += OUTENT->Icm_Base
                         nVLR_TOT_1 += OUTENT->Icm_Base
                    case OUTENT->Cod_Maq == "12"
                         nSOMA_12   += OUTENT->Icm_Base
                         nVLR_TOT_1 += OUTENT->Icm_Base
                    case OUTENT->Cod_Maq == "13"
                         nSOMA_13   += OUTENT->Icm_Base
                         nVLR_TOT_1 += OUTENT->Icm_Base
                    case OUTENT->Cod_Maq == "14"
                         nSOMA_14   += OUTENT->Icm_Base
                         nVLR_TOT_1 += OUTENT->Icm_Base
                    case OUTENT->Cod_Maq == "21"
                         nSOMA_21   += OUTENT->Icm_base
                         nVLR_TOT_1 += OUTENT->Icm_base
                    case OUTENT->Cod_Maq == "22"
                         nSOMA_22   += OUTENT->Icm_base
                         nVLR_TOT_1 += OUTENT->Icm_base
                    case OUTENT->Cod_Maq == "23"
                         nSOMA_23   += OUTENT->Icm_base
                         nVLR_TOT_1 += OUTENT->Icm_base
                    case OUTENT->Cod_Maq == "24"
                         nSOMA_24   += OUTENT->Icm_base
                         nVLR_TOT_1 += OUTENT->Icm_base
                    case OUTENT->Cod_Maq == "31"
                         nSOMA_31   += OUTENT->Icm_Isen
                         nVLR_TOT_1 += OUTENT->Icm_Isen
                    case OUTENT->Cod_Maq == "32"
                         nSOMA_32   += OUTENT->Icm_Isen
                         nVLR_TOT_1 += OUTENT->Icm_Isen
                    case OUTENT->Cod_Maq == "33"
                         nSOMA_33   += OUTENT->Icm_Isen
                         nVLR_TOT_1 += OUTENT->Icm_Isen
                    case OUTENT->Cod_Maq == "34"
                         nSOMA_34   += OUTENT->Icm_Isen
                         nVLR_TOT_1 += OUTENT->Icm_Isen
                    case OUTENT->Cod_Maq == "41"
                         nOUT_ENT   += ENT->Icm_Out
                    otherwise
                         qmensa("C¢digo de Sa¡da Inv lido " + ENT->Num_nf + " " + ENT->Serie, "B")
                 endcase

                 OUTENT->(dbskip())

                 if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                    exit
                 endif

            next

         endif

            // SEPARA VALORES DAS ENTRADAS PELOS CODIGOS DE MAQ.REGISTRADORA

            do case
               case ENT->Cod_Maq == "90"
                    nISEN_ENT  += ENT->Icm_Isen
               case ENT->Cod_Maq == "11"
                    nSOMA_11   += ENT->Vlr_cont - nOUT_BASES - ENT->Icm_Out - ENT->Icm_Isen
                    nVLR_TOT_1 += ENT->Vlr_cont - nOUT_BASES - ENT->Icm_Out - ENT->Icm_Isen
               case ENT->Cod_Maq == "12"
                    nSOMA_12   += ENT->Vlr_cont - nOUT_BASES - ENT->Icm_Out - ENT->Icm_Isen
                    nVLR_TOT_1 += ENT->Vlr_cont - nOUT_BASES - ENT->Icm_Out - ENT->Icm_Isen
               case ENT->Cod_Maq == "13"
                    nSOMA_13   += ENT->Vlr_cont - nOUT_BASES - ENT->Icm_Out - ENT->Icm_Isen
                    nVLR_TOT_1 += ENT->Vlr_cont - nOUT_BASES - ENT->Icm_Out - ENT->Icm_Isen
               case ENT->Cod_Maq == "14"
                    nSOMA_14   += ENT->Vlr_cont - nOUT_BASES - ENT->Icm_Out - ENT->Icm_Isen
                    nVLR_TOT_1 += ENT->Vlr_cont - nOUT_BASES - ENT->Icm_Out - ENT->Icm_Isen
               case ENT->Cod_Maq == "21"
                    nSOMA_21   += ENT->Icm_base
                    nVLR_TOT_1 += ENT->Icm_base // + nOUT_BASES
               case ENT->Cod_Maq == "22"
                    nSOMA_22   += ENT->Icm_base // + nOUT_BASES
                    nVLR_TOT_1 += ENT->Icm_base // + nOUT_BASES
               case ENT->Cod_Maq == "23"
                    nSOMA_23   += ENT->Icm_base // + nOUT_BASES
                    nVLR_TOT_1 += ENT->Icm_base // + nOUT_BASES
               case ENT->Cod_Maq == "24"
                    nSOMA_24   += ENT->Icm_base // + nOUT_BASES
                    nVLR_TOT_1 += ENT->Icm_base // + nOUT_BASES
               case ENT->Cod_Maq == "31"
                    nSOMA_31   += ENT->Icm_Isen
                    nVLR_TOT_1 += ENT->Icm_Isen
               case ENT->Cod_Maq == "32"
                    nSOMA_32   += ENT->Icm_Isen
                    nVLR_TOT_1 += ENT->Icm_Isen
               case ENT->Cod_Maq == "33"
                    nSOMA_33   += ENT->Icm_Isen
                    nVLR_TOT_1 += ENT->Icm_Isen
               case ENT->Cod_Maq == "34"
                    nSOMA_34   += ENT->Icm_Isen
                    nVLR_TOT_1 += ENT->Icm_Isen
               case ENT->Cod_Maq == "41"
                    nOUT_ENT   += ENT->Icm_Out
               otherwise
                    qmensa("C¢digo de Sa¡da Inv lido "+ENT->Num_nf, "B")
            endcase

            // NO case ACIMA NAO SOMA ISENTAS QUANDO EXISTE TRIBUTADAS E ISENTAS EM UMA MESMA NOTA ____

            // POR ISSO TOTALIZA ISENTAS AQUI. ________________________________________________________

            if !empty(ENT->Icm_Isen)

               if XTIPOEMP $ "3" .and. !ENT->Cod_Maq $ "40_90_31_32_33_34"

                  if val(left(CONFIG->Anomes,4)) = 1995

                     if ENT->Icm_Cod $ "2"
                        nISEN_ENT += ENT->Icm_Isen
                     endif

                  else

                     if ENT->Icm_Cod $ "4"
                        nISEN_ENT += ENT->Icm_Isen
                     endif

                  endif

               endif

            endif

            if !empty(ENT->Icm_Out)

               if XTIPOEMP $ "3" .and. !ENT->Cod_Maq $ "41"

                  if val(left(CONFIG->Anomes,4)) = 1995

                     if ENT->Icm_Cod $ "57"
                        nOUT_ENT += ENT->Icm_Out
                     endif

                  else

                     if ENT->Icm_Cod $ "167"
                        nOUT_ENT += ENT->Icm_Out
                     endif

                  endif

               endif

            endif
      endif

      nOUT_BASES := 0

      ENT->(dbskip())

   enddo

   nVLR_TOT_2 = ((nSOMA_11 * 07) + (nSOMA_12 * 12) + (nSOMA_13 * 17) + (nSOMA_14 * 25) +;
                 (nSOMA_21 * 07) + (nSOMA_22 * 12) + (nSOMA_23 * 17) + (nSOMA_24 * 25) +;
                 (nSOMA_31 * 07) + (nSOMA_32 * 12) + (nSOMA_33 * 17) + (nSOMA_34 * 25))

   // CALCULO DO COEFICIENTE DE AJUSTE DA BASE DE CALCULO ________________________

   if nVLR_TOT_1 # 0
      nCOEFICIENTE = ((nVLR_TOT_2 / nVLR_TOT_1 ) / 25)
   endIf

   do while ! SAI->(eof())   // condicao principal de loop

      if SAI->Num_Nf = "@@" + left(XANOMES,2) + right(XANOMES,4)
         SAI->(dbskip())
         loop
      endif

      if eval(bSAI_FILTRO)

         nTOT_SAI := nTOT_SAI + SAI->Vlr_Cont

         if val(left(CONFIG->Anomes,4)) = 1995

            if SAI->Icm_Cod $ "57"
               nOUT_SAI += SAI->Icm_Out
            else
               nTOT_OUT += SAI->Icm_Out
            endif

         else

            if SAI->Icm_Cod $ "167"
               nOUT_SAI += SAI->Icm_Out
            else
               nTOT_OUT += SAI->Icm_Out
            endif

         endif

         // TOTAL DE ISENTAS NAS SAIDAS PARA MAQUINA C/ 3 DEPTOS _________________

         if XTIPOEMP $ "8"
            nISEN_SAI += SAI->Icm_Isen
         endif

         // TOTAL DAS MERCADORIAS DEVOLVIDAS _____________________________________

         if SAI->Cod_Fisc $ "532_632"
            nDEVOLUCAO += SAI->Vlr_Cont
         endif

      endif

      SAI->(dbskip())

   enddo

   // CALCULO DO TOTAL DE DEDUCOES __________________________________________

   if XTIPOEMP $ "3"
      nDEDUCAO := ((nISEN_ENT * 1.15) + nOUT_ENT + nDEVOLUCAO + nTOT_OUT)
   else
      nDEDUCAO := ((nISEN_SAI) + nOUT_SAI + nDEVOLUCAO + nTOT_OUT)
   endif

   // GRAVA BASE AJUSTADA PARA EMISSAO DO LIVRO E GIA/GIAR __________________

   i_grava_base()

   i_impressao()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O RESUMO DA MAQUINA REGISTRADORA ____________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow()+02,01 say "Sistema..: SISTEMA DE LIVROS FISCAIS"
   @ prow()   ,63 say "- Data..: " + DtOC(Date())
   @ prow()+01,01 say "Empresa..: " + XRAZAO
   @ prow()   ,63 say "- Hora..: " + Time()
   @ prow()+01,01 say "Relatorio: DEMONSTRATIVO DO CALCULO DO ICMS P/ MAQUINA REGISTRADORA"
   @ prow()+05,23 say "R E S U M O  -   E N T R A D A S"
   @ prow()+02,30 say qnomemes(val(right(XANOMES,2))) + " / " + left(XANOMES,4)

   if XTIPOEMP $ "3"
      @ prow()+04,01 say "00 - Total Isentas ................ : " + Transform(nISEN_ENT, cPIC1)+" X 1,15 = "+Transform(nISEN_ENT*1.15, cPIC1)
      @ prow()+01,01 say Replicate("-",80)
   else
      @ prow()+05,01 say Replicate("-",80)
   endif

   @ prow()+01,01 say "11 - Total Merc.que sairao com  7 % : " + Transform(nSOMA_11, cPIC1)+" X   07 = "+Transform((nSOMA_11 * 07), cPIC1)
   @ prow()+01,01 say "12 - Total Merc.que sairao com 12 % : " + Transform(nSOMA_12, cPIC1)+" X   12 = "+Transform((nSOMA_12 * 12), cPIC1)
   @ prow()+01,01 say "13 - Total Merc.que sairao com 17 % : " + Transform(nSOMA_13, cPIC1)+" X   17 = "+Transform((nSOMA_13 * 17), cPIC1)
   @ prow()+01,01 say "14 - Total Merc.que sairao com 25 % : " + Transform(nSOMA_14, cPIC1)+" X   25 = "+Transform((nSOMA_14 * 25), cPIC1)
   @ prow()+01,01 say "21 - Total Merc.c/Subst.Trib.   7 % : " + Transform(nSOMA_21, cPIC1)+" X   07 = "+Transform((nSOMA_21 * 07), cPIC1)
   @ prow()+01,01 say "22 - Total Merc.c/Subst.Trib.  12 % : " + Transform(nSOMA_22, cPIC1)+" X   12 = "+Transform((nSOMA_22 * 12), cPIC1)
   @ prow()+01,01 say "23 - Total Merc.c/Subst.Trib.  17 % : " + Transform(nSOMA_23, cPIC1)+" X   17 = "+Transform((nSOMA_23 * 17), cPIC1)
   @ prow()+01,01 say "24 - Total Merc.c/Subst.Trib.  25 % : " + Transform(nSOMA_24, cPIC1)+" X   25 = "+Transform((nSOMA_24 * 25), cPIC1)
   @ prow()+01,01 say "31 - Diferidas ou ME - Saidas   7 % : " + Transform(nSOMA_31, cPIC1)+" X   07 = "+Transform((nSOMA_31 * 07), cPIC1)
   @ prow()+01,01 say "32 - Diferidas ou ME - Saidas  12 % : " + Transform(nSOMA_32, cPIC1)+" X   12 = "+Transform((nSOMA_32 * 12), cPIC1)
   @ prow()+01,01 say "33 - Diferidas ou ME - Saidas  17 % : " + Transform(nSOMA_33, cPIC1)+" X   17 = "+Transform((nSOMA_33 * 17), cPIC1)
   @ prow()+01,01 say "34 - Diferidas ou ME - Saidas  25 % : " + Transform(nSOMA_34, cPIC1)+" X   25 = "+Transform((nSOMA_34 * 25), cPIC1)
   @ prow()+01,01 say space(37) + "------------------" + space(8) + "------------------"

   @ prow()+01,01 say "T o t a i s ....................... : " + Transform(nVLR_TOT_1, cPIC1) + space(10)  +  Transform(nVLR_TOT_2, cPIC1)
   @ prow()+03,01 say "CABC (Coef.p/ Ajuste da B.C.) = ( "     + Alltrim(Transform(nVLR_TOT_2, cPIC1)) + " : " ;
                                                               + Alltrim(Transform(nVLR_TOT_1, cPIC1)) + " ) : 25 = " ;
                                                               + Alltrim(Transform(nCOEFICIENTE,"@E  99.9999"))
   @ prow()+03,01 say Replicate("-",80)
   @ prow()+04,25 say "R E S U M O  -   S A I D A S"
   @ prow()+03,17 say "Total das Saidas............: R$     "  + Transform(nTOT_SAI           , cPIC1)

   if XTIPOEMP $ "3"
      @ prow()+01,17 say "(-) Total Isentas...........: R$   - "  + Transform(nISEN_ENT * 1.15, cPIC1)
      @ prow()+01,17 say "(-) Total Subst. Tributaria.: R$   - "  + Transform(nOUT_ENT        , cPIC1)
   else
      @ prow()+01,17 say "(-) Total Isentas...........: R$   - "  + Transform(nISEN_SAI       , cPIC1)
      @ prow()+01,17 say "(-) Total Subst. Tributaria.: R$   - "  + Transform(nOUT_SAI        , cPIC1)
   endif

   @ prow()+01,17 say "(-) Total Devol. de Compra..: R$   - "  + Transform(nDEVOLUCAO         , cPIC1)
   @ prow()+01,17 say "(-) Total Outras............: R$   - "  + Transform(nTOT_OUT           , cPIC1)

   @ prow()+02,17 say "           SubTotal.........: R$     "  + Transform(nTOT_SAI - nDEDUCAO, cPIC1)
   @ prow()+01,17 say "CABC (Coefic.Ajuste da B.C.): R$   X"   + space(9) + Transform(nCOEFICIENTE ,"@E 99.9999")
   @ prow()+01,46 say "------------------------"

   if nTOT_SAI - nDEDUCAO >= 0
      @ prow()+01,17 say "BCA (Base de Calc. Ajustada): R$     " + Transform((nTOT_SAI - nDEDUCAO) * Round(nCOEFICIENTE,4), cPIC1)
      @ prow()+01,17 say "Aplicacao da Aliquota.......: R$   X " + Transform(0.25, cPIC1)
      @ prow()+01,46 say "------------------------"
      @ prow()+01,17 say "Debito de ICMS das Saidas...: R$     " + Transform(((nTOT_SAI - nDEDUCAO) * Round(nCOEFICIENTE,4))*0.25, cPIC1)
   else
      @ prow()+01,17 say "BCA (Base de Calc. Ajustada): R$     " + Transform(0, cPIC1)
      @ prow()+01,17 say "Aplicacao da Aliquota.......: R$   X " + Transform(0.25, cPIC1)
      @ prow()+01,46 say "------------------------"
      @ prow()+01,17 say "Debito de ICMS das Saidas...: R$     " + Transform(0, cPIC1)
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GRAVA A BASE AJUSTADA ________________________________________

static function i_grava_base

   // VERIFICA SE EXISTE BASE GRAVADA NO ARQUIVO DE SAIDAS __________________

   SAI->(dbsetorder(1))

   if SAI->(dbseek("@@" + left(XANOMES,2) + right(XANOMES,4)))
      SAI->(qrlock())
      replace SAI->Icm_Base with (nTOT_SAI - nDEDUCAO) * round(nCOEFICIENTE,4)
      replace SAI->Icm_Vlr  with (nTOT_SAI - nDEDUCAO) * round(nCOEFICIENTE,4)*0.25
   else
      SAI->(qappend())
      replace SAI->Num_Nf    with "@@" + left(XANOMES,2) + right(XANOMES,4)
      replace SAI->Icm_Base  with (nTOT_SAI - nDEDUCAO) * round(nCOEFICIENTE,4)
      replace SAI->Icm_Vlr   with (nTOT_SAI - nDEDUCAO) * round(nCOEFICIENTE,4)*0.25
      replace SAI->Data_Lanc with dDATA_FIM
      replace SAI->Data_Emis with dDATA_FIM
      replace SAI->Icm_Aliq  with 25
      replace SAI->Cod_Fisc  with "512"
      replace SAI->Obs       with "B.C.AJUSTADA"
   endif

SAI->(qunlock())

return
