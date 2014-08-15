/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: GUIA DE RECOLHIMENTO DE ICMS - GIAR
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MARCO DE 1995
// OBS........:
// ALTERACOES.:
function ef508

#define K_MAX_LIN 55

#include "ef.ch"

// POSICIONA NO MUNICIPIO E ESTADO DA EMPRESA ______________________________

CGM->(dbseek(XCGM))

// SE FOR MAQUINA REGISTRADORA _____________________________________________

if XTIPOEMP $ "38"
   qmensa("Resumo da m quina Registradora deve ser emitido antes da GIAR","B")
endif

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

// DADOS DO CONTADOR ________________________________________________________

if ! quse("","QCONFIG") ; return ; endif

private cCONT_NOME := QCONFIG->Cont_Nome
private cCONT_CRC  := QCONFIG->Cont_Crc
private cCONT_FONE := QCONFIG->Cont_Fone

QCONFIG->(dbclosearea())

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1) }

private sBLOC1  := qlbloc("B508A","QBLOC.GLO")  // Periodo de impressao

private bENT_FILTRO                  // code block de filtro entradas
private bSAI_FILTRO                  // code block de filtro saidas
private aEDICAO := {}                // vetor para os campos de entrada de dados

private cPIC1   := "@E 999,999,999.99"

private nMES                         // Mes do movimento
private nFOL_PGTO                    // Valor da folha de pagamento dos funcionarios
private nNUM_FUNC                    // Numero de funcionarios da folha

private cOBS                         // Observacao

private fVLR_CONT                    // total valor contabil
private fICM_BASE                    // total base de icms
private fICM_VLR                     // total imposto creditado
private fICM_ISEN                    // total isentos icms
private fICM_OUT                     // total outras icms
private fOUT_BASES                   // Outras bases de icms

private fICM_TRANSP                  // Saldo credor anterior
private fICM_RECOL                   // Imposto a recolher
private fICM_DEB                     // Imposto debitado
private fICM_CRED                    // Imposto creditado
private fICM_OUT_DB                  // Outros Debitos
private fICM_OUT_CD                  // Outros creditos
private fICM_EST_CD                  // Estornos Creditos
private fICM_EST_DB                  // Estornos debitos
private fTOT_DEB                     // Total debitos  (campo 60)
private fTOT_CRED                    // Total creditos (campo 70)

private nBASE                        // Base de calculo ajustada para maquina registradora
private nTOTSUBST                    // Total de substituicao tributaria
private nCAMPO_01                    // Valores fiscais campo 01
private nCAMPO_02                    // Valores fiscais campo 02
private nCAMPO_03                    // Valores fiscais campo 03
private nCAMPO_04                    // Valores fiscais campo 04
private nCAMPO_05                    // Valores fiscais campo 05
private nCAMPO_10                    // Total do campos (01 + 02 + 03 + 04 + 05)

private nCAMPO_91 := IMP->MULTA      // Valores fiscais campo 91
private nCAMPO_92 := IMP->JUROS      // Valores fiscais campo 92
private nCAMPO_93 := IMP->CORRECAO   // Valores fiscais campo 93

private nSOMA_11                     // Valores fiscais campo 11
private nSOMA_12                     // Valores fiscais campo 12
private nSOMA_13 := 0                     // Valores fiscais campo 13
private nSOMA_14 := 0                    // Valores fiscais campo 14
private nSOMA_15 := 0                    // Valores fiscais campo 15

private nSOMA_21 := 0                    // Valores fiscais campo 21
private nSOMA_22 := 0                    // Valores fiscais campo 22
private nSOMA_23 := 0                    // Valores fiscais campo 23
private nSOMA_24 := 0                    // Valores fiscais campo 24
private nSOMA_25 := 0                    // Valores fiscais campo 25

private nSOMA_31 := 0                    // Valores fiscais campo 31
private nSOMA_32 := 0                    // Valores fiscais campo 32
private nSOMA_33 := 0                    // Valores fiscais campo 33
private nSOMA_34 := 0                    // Valores fiscais campo 34
private nSOMA_35 := 0                    // Valores fiscais campo 35
private nSOMA_41                     // Valores fiscais campo 41
private nSOMA_42                     // Valores fiscais campo 42
private nSOMA_43                     // Valores fiscais campo 43
private nSOMA_44                     // Valores fiscais campo 44
private nSOMA_45                     // Valores fiscais campo 45

private nSOMA_20                     // Valores fiscais campo 20
private nSOMA_30                     // Valores fiscais campo 30
private nSOMA_40                     // Valores fiscais campo 40
private nSOMA_50                     // Valores fiscais campo 50

private dDATA_INI                    // Data inicial do ICMS dentro do mes
private dDATA_FIM                    // Data final do ICMS dentro do mes
private dDATA_EMIS                   // Data de emissao
private dDATA_VENC                   // Data de vencimento
private dDATA_INVE                   // Data do ultimo inventario

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0}}

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

   qlbloc(5,0,"B508A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_EMIS ,"@!"               ,NIL,NIL) } ,"DATA_EMIS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC ,"@!"               ,NIL,NIL) } ,"DATA_VENC"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@nNUM_FUNC  ,"@R 9999"          ,NIL,NIL) } ,"NUM_FUNC" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nFOL_PGTO  ,"@E 999,999,999.99",NIL,NIL) } ,"FOL_PGTO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INVE ,"@!"               ,NIL,NIL) } ,"DATA_INVE"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@nCAMPO_01  ,"@E 999,999,999.99",NIL,NIL) } ,"CAMPO_01" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nCAMPO_02  ,"@E 999,999,999.99",NIL,NIL) } ,"CAMPO_02" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nCAMPO_03  ,"@E 999,999,999.99",NIL,NIL) } ,"CAMPO_03" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nCAMPO_04  ,"@E 999,999,999.99",NIL,NIL) } ,"CAMPO_04" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nCAMPO_05  ,"@E 999,999,999.99",NIL,NIL) } ,"CAMPO_05" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nCAMPO_91  ,"@E 999,999,999.99",NIL,NIL) } ,"CAMPO_91" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nCAMPO_92  ,"@E 999,999,999.99",NIL,NIL) } ,"CAMPO_92" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nCAMPO_93  ,"@E 999,999,999.99",NIL,NIL) } ,"CAMPO_93" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@cOBS       ,"@!@S40"                   ) } ,"OBS"      })

do while .T.

   XNIVEL := 1
   XFLAG  := .T.

   fVLR_CONT    := 0
   fICM_BASE    := 0
   fICM_VLR     := 0
   fICM_ISEN    := 0
   fICM_OUT     := 0
   fOUT_BASES   := 0

   fICM_TRANSP  := 0              // Saldo credor anterior
   fICM_RECOL   := 0              // Imposto a recolher
   fICM_DEB     := 0              // Imposto debitado
   fICM_CRED    := 0              // Imposto creditado
   fICM_OUT_DB  := 0              // Outros Debitos
   fICM_OUT_CD  := 0              // Outros creditos
   fICM_EST_CD  := 0              // Estornos Creditos
   fICM_EST_DB  := 0              // Estornos debitos
   fTOT_DEB     := 0              // Total debitos  (campo 60)
   fTOT_CRED    := 0              // Total creditos (campo 70)
// fMULTA       := 0              // Multa
// fJUROS       := 0              // Juros
// fCORRECAO    := 0              // Correca Monetaria

   dDATA_EMIS   := date()
   dDATA_VENC   := date()
   dDATA_INVE   := ctod("")
   dDATA_INI    := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM    := qfimmes(dDATA_INI)

   nMES         := month(dDATA_INI)
   nFOL_PGTO    := 0             // Valor da folha de pagamento dos funcionarios
   nNUM_FUNC    := 0             // Numero de funcionarios da folha

   cOBS         := space(100)    // Observacao

   nBASE        := 0             // Base de calculo ajustada para maquina registradora
   nTOTSUBST    := 0             // Total da substituicao tributaria
   nCAMPO_01    := 0             // Valores fiscais campo 01
   nCAMPO_02    := 0             // Valores fiscais campo 02
   nCAMPO_03    := 0             // Valores fiscais campo 03
   nCAMPO_04    := 0             // Valores fiscais campo 04
   nCAMPO_05    := 0             // Valores fiscais campo 05

// nCAMPO_91    := 0             // Valores fiscais campo 91
// nCAMPO_92    := 0             // Valores fiscais campo 92
// nCAMPO_93    := 0             // Valores fiscais campo 93

   nSOMA_11     := 0             // Valores fiscais campo 11
   nSOMA_12     := 0             // Valores fiscais campo 12
   nSOMA_13     := 0             // Valores fiscais campo 13
   nSOMA_14     := 0             // Valores fiscais campo 14
   nSOMA_15     := 0             // Valores fiscais campo 15

   nSOMA_21     := 0             // Valores fiscais campo 21
   nSOMA_22     := 0             // Valores fiscais campo 22
   nSOMA_23     := 0             // Valores fiscais campo 23
   nSOMA_24     := 0             // Valores fiscais campo 24
   nSOMA_25     := 0             // Valores fiscais campo 25

   nSOMA_31     := 0             // Valores fiscais campo 31
   nSOMA_32     := 0             // Valores fiscais campo 32
   nSOMA_33     := 0             // Valores fiscais campo 33
   nSOMA_34     := 0             // Valores fiscais campo 34
   nSOMA_35     := 0             // Valores fiscais campo 35

   nSOMA_41     := 0             // Valores fiscais campo 41
   nSOMA_42     := 0             // Valores fiscais campo 42
   nSOMA_43     := 0             // Valores fiscais campo 43
   nSOMA_44     := 0             // Valores fiscais campo 44
   nSOMA_45     := 0             // Valores fiscais campo 45

   nSOMA_20     := 0             // Valores fiscais campo 20
   nSOMA_30     := 0             // Valores fiscais campo 30
   nSOMA_40     := 0             // Valores fiscais campo 40
   nSOMA_50     := 0             // Valores fiscais campo 50

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

   qmensa("")

   do case
      case cCAMPO == "DATA_EMIS"
           if empty(dDATA_EMIS) ; return .F. ; endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA MACRO DE FILTRO __________________________________________________

   bENT_FILTRO := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   set softseek on

   select IMP
   IMP->(dbgotop())

   select OUTENT
   OUTENT->(dbseek(dtos(dDATA_INI)))

   select OUTSAI
   OUTSAI->(dbgotop())

   select ENT
   ENT->(dbsetorder(2))
   ENT->(dbseek(dtos(dDATA_INI)))

   select SAI
   SAI->(dbsetorder(2))
   SAI->(dbseek(dtos(dDATA_INI)))

   set softseek off

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if !qinitprn() ; return ; endif

   // CONDICAO PRINCIPAL DE LOOP ____________________________________________

   do while !ENT->(eof()) .and. eval(bENT_FILTRO)

      if eval(bENT_FILTRO)

         qmensa("Aguarde! Somando Nota: "+ENT->Num_Nf +" / Serie : "+ENT->Serie)

         if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->NUM_NF+ENT->SERIE+ENT->FILIAL))
            for nCONT = 1 to 3
                 aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
                 aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
                 aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr

                 // BASE DAS OUTRAS ALIQUOTAS DE ICMS _______________________

                 fOUT_BASES += OUTENT->ICM_BASE
                 OUTENT->(dbskip())
                 if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                    exit
                 endif
            next
         endif

         // CODIGOS DE ICMS (ICM_COD) PARA ENTRADA OU SAIDA NO ANO 1995.
         //     1- Operacoes com Credito do Imposto.
         //     2- Oper. sem Credito do Imposto-Isentas
         //     3- Oper. sem Credito do Imposto-Outras.
         //     4- Oper. com deferimento
         //     5- Isentas com substituicao tributaria
         //     7- Cigarros


            do case

               case ENT->ICM_COD $ "0249" .and. left(ENT->COD_FISC,1) $ "1"
                    nSOMA_11 += ENT->VLR_CONT
                    nSOMA_21 += ENT->ICM_BASE + fOUT_BASES

               case ENT->ICM_COD $ "5"
                    nSOMA_11 += ENT->VLR_CONT - ENT->ICM_ISEN
                    nSOMA_12 += ENT->ICM_ISEN
                    nSOMA_21 += ENT->ICM_BASE + fOUT_BASES

               case ENT->ICM_COD $ "0249" .and. left(ENT->COD_FISC,1) $ "2"
                    nSOMA_13 += ENT->VLR_CONT
                    nSOMA_23 += ENT->ICM_BASE + fOUT_BASES

               case ENT->ICM_COD $ "0249" .and. left(ENT->COD_FISC,1) $ "3"
                    nSOMA_14 += ENT->VLR_CONT
                    nSOMA_24 += ENT->ICM_BASE + fOUT_BASES

               case ENT->ICM_COD $ "1367"  .and. left(ENT->COD_FISC,1) == "1"
                    nSOMA_15 += ENT->ICM_OUT
                    nSOMA_11 += ENT->VLR_CONT - ENT->ICM_OUT
                    nSOMA_21 += ENT->ICM_BASE + fOUT_BASES

               case ENT->ICM_COD $ "1367"  .and. left(ENT->COD_FISC,1) $ "2"

                    nSOMA_15 += ENT->ICM_OUT
                    nSOMA_23 += ENT->ICM_BASE + fOUT_BASES
                    nSOMA_13 += ENT->Vlr_Cont - ENT->Icm_out


            endcase


         // MAQUINA REGISTRADORA ________________________________________________

         if XTIPOEMP $ "3"       // "38"

            if val(left(CONFIG->Anomes,4)) = 1995
               if ENT->Icm_Cod $ "75"
                  nTOTSUBST += ENT->Icm_Out
               endif
            else
               if ENT->Icm_Cod $ "1367"
                  nTOTSUBST += ENT->Icm_Out
               endif
            endif

         endif

         fOUT_BASES := 0

      endif

      ENT->(dbskip())

   enddo

   // CONDICAO PRINCIPAL DE LOOP_________________________________________________

   do while !SAI->(eof()) .and. eval(bSAI_FILTRO)

      if eval(bSAI_FILTRO)
         qmensa("Aguarde! Somando Nota: "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
         if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE+ SAI->Filial))
            for nCONT = 1 to 3
                 aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
                 aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
                 aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr

                 // BASE DAS OUTRAS ALIQUOTAS DE ICMS ___________________________

                 fOUT_BASES += OUTSAI->ICM_BASE
                 OUTSAI->(dbskip())
                 if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                    exit
                 endif
            next
         endif

         if val(left(CONFIG->Anomes,4)) = 1995

            do case

               case SAI->ICM_COD $ "123" .and. left(SAI->COD_FISC,1) $ "5"
                    nSOMA_31 += SAI->VLR_CONT
                    nSOMA_41 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "4"
                    nSOMA_31 += SAI->VLR_CONT - SAI->ICM_ISEN
                    nSOMA_32 += SAI->ICM_ISEN
                    nSOMA_41 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "123" .and. left(SAI->COD_FISC,1) $ "6"
                    nSOMA_33 += SAI->VLR_CONT
                    nSOMA_43 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "123" .and. left(SAI->COD_FISC,1) $ "7"
                    nSOMA_34 += SAI->VLR_CONT
                    nSOMA_44 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "57"  .and. left(SAI->COD_FISC,1) $ "56"
                    nSOMA_35 += SAI->ICM_OUT
                    if left(SAI->COD_FISC,1) $ "5"
                       nSOMA_31 += SAI->VLR_CONT - SAI->ICM_OUT
                       nSOMA_41 += SAI->ICM_BASE + fOUT_BASES
                    else
                       nSOMA_33 += SAI->VLR_CONT - SAI->ICM_OUT
                       nSOMA_43 += SAI->ICM_BASE + fOUT_BASES
                    endif

            endcase

         else

            do case

               case SAI->ICM_COD $ "0249" .and. left(SAI->COD_FISC,1) $ "5"
                    nSOMA_31 += SAI->VLR_CONT
                    nSOMA_41 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "5"
                    nSOMA_31 += SAI->VLR_CONT - SAI->ICM_ISEN
                    nSOMA_32 += SAI->ICM_ISEN
                    nSOMA_41 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "0249" .and. left(SAI->COD_FISC,1) $ "6"
                    nSOMA_33 += SAI->VLR_CONT
                    nSOMA_43 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "0249" .and. left(SAI->COD_FISC,1) $ "7"
                    nSOMA_34 += SAI->VLR_CONT
                    nSOMA_44 += SAI->ICM_BASE + fOUT_BASES

               case SAI->ICM_COD $ "1367"  .and. left(SAI->COD_FISC,1) $ "56"
//                  if XTIPOEMP $ "25"          // Empresa com Substituicao tributaria
//                     nSOMA_35 += SAI->Vlr_cont
//                     nSOMA_45 += SAI->Icm_base
//                  else
                       nSOMA_35 += SAI->Icm_out
//                  endif
                    if XTIPOEMP $ "134678"
                       if left(SAI->COD_FISC,1) $ "5"
                          nSOMA_31 += SAI->VLR_CONT - SAI->ICM_OUT
                          nSOMA_41 += SAI->ICM_BASE + fOUT_BASES
                       else
                          nSOMA_33 += SAI->VLR_CONT - SAI->ICM_OUT
                          nSOMA_43 += SAI->ICM_BASE + fOUT_BASES
                       endif
                    endif

            endcase

         endif

         // MAQUINA REGISTRADORA ________________________________________________

         if XTIPOEMP $ "3"      //  "38"
            if SAI->Cod_Fisc $ "532_632"
               nBASE += SAI->Icm_Base
            endif
         endif

         fOUT_BASES := 0

      endif

      SAI->(dbskip())

   enddo

   if XTIPOEMP $ "38"

      // PARA SOMAR SUBST. NO CAMPO 35 E SUBTRAIR NO CAMPO 31 __________________

      if XTIPOEMP $ "3"
         nSOMA_35 += nTOTSUBST
         nSOMA_31 -= nTOTSUBST
      endif

      // SOMA BASE DOS CODIGOS "532 E 632" 'A BASE AJUSTADA ____________________
      // ICM_BASE E' O VALOR FINAL DO IMPOSTO COM BASE AJUSTADA PARA MAQ.REG. __
      // E' GRAVADO NO EF509 LINHA 308, COM N.F. @@ANOMES ______________________

      SAI->(dbsetorder(1))

      if SAI->(dbseek("@@" + left(XANOMES,2) + right(XANOMES,4)))
         nBASE += (SAI->Icm_Base)
      endif

   endif

   nSOMA_20 := nSOMA_11 + nSOMA_12 + nSOMA_13 + nSOMA_14 + nSOMA_15
   nSOMA_30 := nSOMA_21 + nSOMA_23 + nSOMA_24 + nSOMA_25
   nSOMA_40 := nSOMA_31 + nSOMA_32 + nSOMA_33 + nSOMA_34 + nSOMA_35
   nSOMA_50 := nSOMA_41 + nSOMA_43 + nSOMA_44 + nSOMA_45

   // BASE AJUSTADA PARA MAQUINA REGISTRADORA __________________________________

   if XTIPOEMP $ "38"
      nSOMA_50 := nBASE + nSOMA_43 + nSOMA_44 + nSOMA_45
   endif

   // IMPRESSSAO CABECALHO DA GIAR _____________________________________________

   @ prow(),pcol() say XCOND1

   @ prow()+5,010 say "+-" + space(41) + "-+"
   @ prow()  ,065 say qnomemes(Val(right(XANOMES,2)))
   @ prow()  ,089 say left(XANOMES,4)
   @ prow()  ,123 say nCAMPO_01 picture cPIC1
   @ prow()+1,010 say "|"
   @ prow()  ,018 say XAEXPAN + XINSCR_EST + XDEXPAN
   @ prow()  ,046 say "|"

   @ prow()+1,123 say nCAMPO_02 picture cPIC1
   @ prow()+1,012 say Substr(XRAZAO,1,38)
   @ prow()+1,012 say Substr(XRAZAO,39,50)
   @ prow()  ,123 say nCAMPO_03 picture cPIC1

   @ prow()+2,070 say dDATA_VENC
   @ prow()  ,123 say nCAMPO_04 picture cPIC1

   @ prow()+1,012 say XENDERECO

   @ prow()+1,012 say XCEP + " - " + Alltrim(CGM->MUNICIPIO) + " - " + alltrim(CGM->ESTADO)

   @ prow()  ,097 say substr(dtoc(dDATA_INVE),1,2)+"   "+substr(dtoc(dDATA_INVE),4,2)+"   "+substr(dtoc(dDATA_INVE),7,2)
   @ prow()  ,123 say nCAMPO_05 picture cPIC1
   @ prow()+1,010 say "|"  + space(43) + "|"
   @ prow()+1,010 say "+-" + space(41) + "-+"
   @ prow()  ,060 say nNUM_FUNC
   @ prow()  ,075 say nFOL_PGTO picture cPIC1
   @ prow()  ,123 say (nCAMPO_01 + nCAMPO_02 + nCAMPO_03 + nCAMPO_04 + nCAMPO_05) picture cPIC1

   // IMPRESSSAO QUADRO 07 DA GIAR ____________________________________________

   @ prow()+5,038 say nSOMA_11 picture cPIC1
   @ prow()  ,065 say nSOMA_21 picture cPIC1
   @ prow()  ,095 say nSOMA_31 picture cPIC1

   if XTIPOEMP $ "38"
      @ prow(),123 say nBASE   picture cPIC1
   else
      @ prow(),123 say nSOMA_41 picture cPIC1
   endif

   @ prow()+2,038 say nSOMA_12 picture cPIC1
   @ prow()  ,095 say nSOMA_32 picture cPIC1
   @ prow()+2,038 say nSOMA_13 picture cPIC1
   @ prow()  ,065 say nSOMA_23 picture cPIC1
   @ prow()  ,095 say nSOMA_33 picture cPIC1
   @ prow()  ,123 say nSOMA_43 picture cPIC1
   @ prow()+2,038 say nSOMA_14 picture cPIC1
   @ prow()  ,065 say nSOMA_24 picture cPIC1
   @ prow()  ,095 say nSOMA_34 picture cPIC1
   @ prow()  ,123 say nSOMA_44 picture cPIC1
   @ prow()+2,038 say nSOMA_15 picture cPIC1
   @ prow()  ,065 say nSOMA_25 picture cPIC1
   @ prow()  ,095 say nSOMA_35 picture cPIC1
   @ prow()  ,123 say nSOMA_45 picture cPIC1

   @ prow()+2,038 say nSOMA_20 picture cPIC1
   @ prow()  ,065 say nSOMA_30 picture cPIC1
   @ prow()  ,095 say nSOMA_40 picture cPIC1
   @ prow()  ,123 say nSOMA_50 picture cPIC1

   // IMPRESSSAO QUADRO 08 e 09 DA GIAR _______________________________________

   // CAMPOS 51 ao 70, BUSCA OS VALORES GRAVADOS QUANDO EMITIDAS AS APURACOES.

// if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(dDATA_FIM) + cFILIAL))
   if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(dDATA_FIM)))
      // fICM_RECOL : VALOR DO ICMS A RECOLHER, JA DEDUZIDO O SALDO CREDOR ____
      fICM_RECOL   := IMP->IMP_VALOR       // Imposto a recolher campo 90
      fICM_DEB     := IMP->ICM_DEB         // Campo 51
      fICM_OUT_DB  := IMP->ICM_OUT_DB      // Campo 52
      fICM_EST_CD  := IMP->ICM_EST_CD      // Campo 53
      fICM_CRED    := IMP->ICM_CRED        // Campo 62
      fICM_OUT_CD  := IMP->ICM_OUT_CD      // Campo 63
      fICM_EST_DB  := IMP->ICM_EST_DB      // Campo 64
//    fMULTA       := IMP->MULTA           // Campo 91
//    fJUROS       := IMP->JUROS           // Campo 92
//    fCORRECAO    := IMP->CORRECAO        // Campo 93
   endif

   // BUSCA SALDO CREDOR ANTERIOR, PARA DEDUZIR DO IMP A RECOLHER _____________

   i_icm4_saldo_anter(nMES)                 // PROGRAMA EF521.PRG

   @ prow()+3,055 say fICM_DEB              picture cPIC1
   @ prow()  ,123 say fICM_TRANSP           picture cPIC1
   @ prow()+2,055 say fICM_OUT_DB           picture cPIC1
   @ prow()  ,123 say fICM_CRED             picture cPIC1
   @ prow()+2,055 say fICM_EST_CD           picture cPIC1
   @ prow()  ,123 say fICM_OUT_CD           picture cPIC1
   @ prow()+2,123 say fICM_EST_DB           picture cPIC1

   fTOT_DEB  := fICM_DEB  + fICM_OUT_DB + fICM_EST_CD
   fTOT_CRED := fICM_CRED + fICM_EST_DB + fICM_OUT_CD + fICM_TRANSP

   @ prow()+4,055 say fTOT_DEB              picture cPIC1
   @ prow()  ,123 say fTOT_CRED             picture cPIC1

   // IMPRESSSAO QUADRO 10 DA GIAR ____________________________________________
   // DEDUZ O SALDO CREDOR ANTERIOR DO IMPOSTO A RECOLHER _____________________

   fICM_RECOL := fICM_RECOL - fICM_TRANSP

   @ prow()+3,123 say fICM_RECOL            picture cPIC1

// @ prow()+2,123 say fMULTA                picture cPIC1
// @ prow()+2,123 say fJUROS                picture cPIC1
   @ prow()+2,123 say nCAMPO_91             picture cPIC1
   @ prow()+2,123 say nCAMPO_92             picture cPIC1    

   @ prow()+2,015 say substr(dtoc(dDATA_EMIS),1,2)+"   "+substr(dtoc(dDATA_EMIS),4,2)+"   "+substr(dtoc(dDATA_EMIS),7,4)

// @ prow()  ,123 say fCORRECAO             picture cPIC1
   @ prow()  ,123 say nCAMPO_93             picture cPIC1

// @ prow()+2,123 say (fICM_RECOL + fMULTA + fJUROS + fCORRECAO) picture cPIC1
   @ prow()+2,123 say (fICM_RECOL + nCAMPO_91 + nCAMPO_92 + nCAMPO_93) picture cPIC1

   // IMPRESSSAO OBSERVACOES E DADOS DO CONTADOR _______________________________

   @ prow()+2,012 say Substr(cOBS,01,50)
   @ prow()+2,012 say Substr(cOBS,51,50)

   @ prow()+04,012 say right(cCONT_CRC,12)
   @ prow()   ,029 say left(cCONT_CRC,2)
   @ prow()   ,035 say cCONT_NOME
   @ prow()   ,122 say cCONT_FONE
   @ prow()+10,000 say ""

   qstopprn(.F.)

return
//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR SALDO CREDOR ANTERIOR DE ICMS ___________________________

STATIC function i_icm4_saldo_anter

   local dINI_ANTER, dFIM_ANTER, cMES_ANTERIOR, cANO_ANTERIOR, nREC

   fICM_TRANSP   := 0
   cMES_ANTERIOR := nMES - 1
//   cANO_ANTERIOR := val(substr(str(year(dDATA_INI),4),3,2))
   cANO_ANTERIOR := val(substr(str(year(dDATA_INI),4),0,4))

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

// IMP->(dbseek(K_ICM + dtos(dINI_ANTER) + dtos(dFIM_ANTER) + alltrim(cFILIAL)))
   IMP->(dbseek(K_ICM + dtos(dINI_ANTER) + dtos(dFIM_ANTER)))

// if IMP->Codigo == K_ICM .and. IMP->Data_ini == dINI_ANTER .and. IMP->Data_fim == dFIM_ANTER .and. IMP->Filial == cFILIAL
   if IMP->Codigo == K_ICM .and. IMP->Data_ini == dINI_ANTER .and. IMP->Data_fim == dFIM_ANTER
      if IMP->IMP_VALOR < 0
         fICM_TRANSP := (IMP->IMP_VALOR * -1)
      endif
   else
      alert("SALDO ANTERIOR COM PROBLEMAS !;SE FOR PRIMEIRO MES DE LANCAMENTO DESTA EMPRESA, CONTINUE.;SE NAO, VERIFIQUE SE FOI APURADO OS MESES ANTERIORES.",{"OK"})
   endif

   IMP->(dbgoto(nREC))

return fICM_TRANSP


