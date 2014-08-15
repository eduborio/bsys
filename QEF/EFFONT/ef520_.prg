//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: LIVRO DE SAIDAS ICMS/IPI
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........:
// ALTERACOES.:
function ef520

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS _______________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

//fu_abre_ccusto()

// CONFIGURACOES _________________________________________________________________

if ! quse("","QCONFIG") ; return ; endif
private cSUBTOTAL  := QCONFIG->Subtotal
private cFILT_ICMS := QCONFIG->Filt_icms
QCONFIG->(dbclosearea())

// INDUSTRIAS ____________________________________________________________________

private sBLOC2     := qlbloc("B520C","QBLOC.GLO")
private cPIC1      := "@E 99,999,999.99"
private lCABECALHO := .T.               // Imprime cabecalho caso nao tenha notas
private cTITULO                         // Titulo do relatorio
private bSAI_FILTRO                     // Code block de filtro
private aEDICAO    := {}                // Vetor para os campos de entrada de dados
private nFALTA                          // Numero de meses que faltam para imprimir cabecalho em branco
private nFOLHA                          // Numero da Folha
private cTIPO                           // Tipo de relatorio
private nMES                            // Mes para controlar mudanca de pagina

private fVLR_CONT                       // Total valor contabil
private fICM_BASE                       // Total base de icms
private fICM_VLR                        // Total imposto creditado
private fICM_ISEN                       // Total isentos icms
private fICM_OUT                        // Total outras icms
private nICM_R_B  := 0                  // Valor de icms outras para resumo

private cFILIAL                         // Filial
private dDATA_INI                       // Inicio do periodo do relatorio
private dDATA_FIM                       // Fim do periodo do relatorio

private aOUTALIQ  := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}

private nNF_ANT   := 0
private cNF_INI   := 0
private lPR_VEZ   := .T.

private nV_CONT   := 0
private nI_BASE   := 0
private nI_VLR    := 0
private nI_ISEN   := 0
private nI_OUT    := 0

private nS_V_CONT := 0
private nS_I_BASE := 0
private nS_I_VLR  := 0
private nS_I_ISEN := 0
private nS_I_OUT  := 0

private aOUT_B    := {}
private aOUT_P    := {}
private aOUT_V    := {}

private aRESUMO_UF := {}
private aRESUMO_VC := {}
private aRESUMO_BI := {}
private aRESUMO_BC := {}
private aRESUMO_OI := {}
private aRESUMO_IS := {}

if XTIPOEMP $ "457"
   private fIPI_BASE                    // Total base de ipi
   private fIPI_VLR                     // Total imposto creditado
   private fIPI_ISEN                    // Total isentos ipi
   private fIPI_OUT                     // Total outras ipi

   private nIPI_BASE
   private nIPI_VLR
   private nIPI_ISEN
   private nIPI_OUT

   private nS_IPI_BASE
   private nS_IPI_VLR
   private nS_IPI_ISEN
   private nS_IPI_OUT

endif

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL ,"9999"              ) } ,"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                              } ,NIL         }) // descricao do filial
   aadd(aEDICAO,{{ || qgetx(-1,0 , @dDATA_INI , "@!"      , NIL , NIL) } , "DATA_INI" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @dDATA_FIM , "@!"      , NIL , NIL) } , "DATA_FIM" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @nFOLHA    , "@E 9999" , NIL , NIL) } , "FOLHA"    })
   aadd(aEDICAO,{{ || qesco(-1,0 , @cTIPO     , sBLOC2               ) } , "TIPO"     })

do while .T.

   if XTIPOEMP $ "457"                  // Industriais
      qlbloc(5,0,"B520B","QBLOC.GLO")
   else
      qlbloc(5,0,"B520A","QBLOC.GLO")
   endif

   XNIVEL      := 1
   XFLAG       := .T.

   fVLR_CONT   := 0
   fICM_BASE   := 0
   fICM_VLR    := 0
   fICM_ISEN   := 0
   fICM_OUT    := 0

   nS_I_BASE := 0
   nS_I_VLR  := 0
   nS_I_ISEN := 0
   nS_I_OUT  := 0

   nS_IPI_BASE := 0
   nS_IPI_VLR  := 0
   nS_IPI_ISEN := 0
   nS_IPI_OUT  := 0

   nFALTA      := 0                        // Meses que faltam para imprimir cabecalho
// nFOLHA      := val(CONFIG->PAGINA_SAI)
   nFOLHA      := 1
   cTIPO       := "1"
   lCABECALHO  := .T.                      // Imprime cabecalho caso nao tenha notas

   cFILIAL     := "    "
   dDATA_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM   := qfimmes(dDATA_INI)

   if XTIPOEMP $ "457"

      fIPI_BASE := 0
      fIPI_VLR  := 0
      fIPI_ISEN := 0
      fIPI_OUT  := 0

   endif

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

//////////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA __________________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "FILIAL"

           if empty(cFILIAL) ; return .F. ; endif

           qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))

           if FILIAL->(dbseek(cFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,26))
           else
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif

      case cCAMPO == "DATA_INI"

           if empty(dDATA_INI) ; return .F. ; endif

           if XTIPOEMP $ "12368"
              dDATA_FIM := qfimmes(dDATA_INI)
              qrsay(XNIVEL+1,dDATA_FIM)
           endif

           if XTIPOEMP $ "457"

              if strzero(day(dDATA_INI),2) $ "01_11"
                 dDATA_FIM = (dDATA_INI + 9)
              endif

              if strzero(day(dDATA_INI),2) $ "21"
                 dDATA_FIM = qfimmes(ctod("01/" + str(month(dDATA_INI)) + "/" + str(year(dDATA_INI))))
              endif

           endif

           nMES := val(str(month(dDATA_INI),2))

      case cCAMPO == "DATA_FIM"

           if empty(dDATA_FIM) ; return .F. ; endif

           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "TIPO"

           if empty(cTIPO); return .F.; endif 1

           qrsay(XNIVEL,qabrev(cTIPO,"12",{"Normal","Totalizado"}))

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ________________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ___________________________________________________

   cTITULO := "REGISTROS DE SAIDAS - ICMS"

   qmensa("")

   // CRIA MACRO DE FILTRO _______________________________________________________

   bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }

   SAI->(dbSetFilter({|| alltrim(Filial) $ cFILIAL}, 'alltrim(Filial) $ cFILIAL'))

   // VERIFICA SE E MAQUINA REGISTRADORA _________________________________________

   if XTIPOEMP $ "3"                     // "38"

      // VERIFICA SE EXISTE BASE GRAVADA NO ARQUIVO DE SAIDAS ____________________

      if !SAI->(dbseek("@@" + left(XANOMES,2) + right(XANOMES,4)))
         qmensa("B.C.Ajustada n„o encontrada nas sa¡das ! Utilize Op‡„o <509>","B")
         return .F.
      endif

   endif

   // ESTABELECE RELACOES ENTRE ARQUIVOS _________________________________________

   set softseek on
   select OUTSAI
   OUTSAI->(dbgotop())

   // ORDEM DATA DE LANCAMENTO + DATA DE EMISSAO _________________________________

   select SAI
   SAI->(dbsetorder(2))
   SAI->(dbseek(dtos(dDATA_INI)))
   set softseek off

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _______________________________

static function i_impressao

   local nTMP                                      // Para notas totalizadas
   local nTMPX                                     // Para resumo no final do livro
   local nCONT := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND2

   // CONDICAO PRINCIPAL DE LOOP _________________________________________________

   do while !SAI->(eof()) .and. eval(bSAI_FILTRO) .and. qcontprn()

      qgirabarra()

      if cTIPO == "1"

         // SALTA NOTA DE CONTROLE DA BASE DE CALCULO PARA MAQUINA REGISTRADORA

         if XTIPOEMP $ "38"

            if SAI->Num_Nf = "@@" + left(XANOMES,2) + right(XANOMES,4)
               qgirabarra()
               SAI->(dbskip())
               loop
            endif

         endif

         if !qlineprn() ; exit ; endif

         if XPAGINA == 0 .or. prow() > K_MAX_LIN

            qpageprn()

            // CASO IMPRIMA ALGUMA NOTA, NAO IMPRIME CABECALHO FORA DESTE LOOP_______

            lCABECALHO := .F.

            // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

            if nFOLHA <> 0
               XPAGINA = nFOLHA
               nFOLHA  = 0
            endif

            i_cabecalho(cTITULO,150)
            i_cabec()

         endif

         if eval(bSAI_FILTRO)

            if nMES <> val(str(month(SAI->DATA_LANC),2))

               nMES++

               // IMPRIME O TOTAL QUANDO MUDA O MES _________________________________

               i_tot_periodo()

               setprc(56,00)

               loop

            endif

            qmensa("Imprimindo Nota: "+SAI->Num_Nf +" / Serie : "+SAI->Serie)

            i_imp_nf()

         endif

         SAI->(dbskip())

      else

         // SALTA NOTA DE CONTROLE DA BASE DE CALCULO PARA MAQUINA REGISTRADORA

         if XTIPOEMP $ "38"

            if SAI->Num_Nf = "@@" + left(XANOMES,2) + right(XANOMES,4)
               qgirabarra()
               SAI->(dbskip())
               loop
            endif

         endif

         if !qlineprn() ; exit ; endif

         if XPAGINA == 0 .or. prow() > K_MAX_LIN

            qpageprn()

            // CASO IMPRIMA ALGUMA NOTA, NAO IMPRIME CABECALHO FORA DESTE LOOP_______

            lCABECALHO := .F.

            // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

            if nFOLHA <> 0
               XPAGINA = nFOLHA
               nFOLHA  = 0
            endif

            i_cabecalho(cTITULO,150)
            i_cabec()

         endif

         if eval(bSAI_FILTRO)

            if nMES <> val(str(month(SAI->DATA_LANC),2))
               nMES++
               i_tot_periodo()
               setprc(56,00)
               loop
            endif

            qmensa("Imprimindo Nota: "+SAI->Num_Nf +" / Serie : "+SAI->Serie)

            nNF_ANT    := val(SAI->Num_nf)                  // Guarda os dados do registro...
            cNF_SERIE  := SAI->Serie                        // ... anterior
            dNF_DATA   := SAI->Data_Emis
            cNF_C_FISC := SAI->Cod_Fisc
            cNF_CFOP   := SAI->Cfop
            cNF_I_COD  := SAI->Icm_Cod
            cNF_ESTADO := SAI->Estado
            cNF_CONT   := SAI->Cod_cont

            SAI->(dbskip())

            if val(SAI->Num_nf) <> nNF_ANT+1 .or. SAI->Serie    <> cNF_SERIE  .or.;
               SAI->Data_emis   <> dNF_DATA  .or. iif(val(left(CONFIG->Anomes,4)) < 2003,SAI->Cod_fisc <> cNF_C_FISC,SAI->Cfop <> cNF_CFOP ).or.;
               SAI->Icm_Cod     <> cNF_I_COD .or. SAI->Estado   <> cNF_ESTADO .or.;
               SAI->Cod_cont    <> cNF_CONT                                    // Quando nao for mesma caracteristica

               SAI->(dbskip(-1))

               nV_CONT := SAI->Vlr_cont
               nI_BASE := SAI->Icm_base
               nI_VLR  := round(SAI->Icm_vlr,2)
               nI_ISEN := SAI->Icm_isen
               nI_OUT  := SAI->Icm_out

               nIPI_BASE := SAI->Ipi_base
               nIPI_VLR  := round(SAI->Ipi_vlr,2)
               nIPI_ISEN := SAI->Ipi_isen
               nIPI_OUT  := SAI->Ipi_out
			   nBASE_ST  := SAI->Icm_bc_s
			   nVALOR_ST := SAI->Icm_subst

               if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->Filial))                     // Procura outras aliquotas

                  for nCONT := 1 to 5
                      qgirabarra()
                      aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
                      aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
                      aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr

                      if ( nTMP := ascan(aOUT_P,aOUTALIQ[nCONT,2]) ) == 0      // Soma os valores de ICMS (aliquotas iguais)
                         aadd(aOUT_B,aOUTALIQ[nCONT,1])
                         aadd(aOUT_P,aOUTALIQ[nCONT,2])
                         aadd(aOUT_V,aOUTALIQ[nCONT,3])
                      else
                         aOUT_B[nTMP] += aOUTALIQ[nCONT,1]
                         aOUT_V[nTMP] += aOUTALIQ[nCONT,3]
                      endif

                      fICM_BASE += OUTSAI->ICM_BASE
                      fICM_VLR  += OUTSAI->ICM_VLR
                      nICM_R_B  += OUTSAI->Icm_base

                      OUTSAI->(dbskip())

                      if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                         exit
                      endif
                  next

               endif

               CGM->(dbseek(FILIAL->Cgm))
               cEMP_UF := CGM->Estado

               if cFILT_ICMS $ "1 "  // Quando usa filtro de codigo de icms de sub. tributaria (na configuracao geral do sistema)
                  if cEMP_UF <> SAI->Estado .and. SAI->Icm_cod $ "1367"  // Se for diferente de cgm entre a empresa e
                                                                         // do fornecedor faz a soma

                     if ( nTMPX := ascan(aRESUMO_UF,SAI->Estado) ) == 0  // Soma os valores por estado
                        aadd(aRESUMO_UF,SAI->Estado   )
                        aadd(aRESUMO_VC,SAI->Vlr_cont )
                        aadd(aRESUMO_BI,SAI->Icm_base + nICM_R_B)
                        aadd(aRESUMO_BC,SAI->Icm_bc_s )
                        aadd(aRESUMO_OI,SAI->Icm_out  )
                        aadd(aRESUMO_IS,SAI->Icm_subst)
                     else
                        aRESUMO_VC[nTMPX] += SAI->Vlr_cont
                        aRESUMO_BI[nTMPX] += SAI->Icm_base + nICM_R_B
                        aRESUMO_BC[nTMPX] += SAI->Icm_bc_s
                        aRESUMO_OI[nTMPX] += SAI->Icm_out
                        aRESUMO_IS[nTMPX] += SAI->Icm_subst
                     endif

                  endif
               else
                  if cEMP_UF <> SAI->Estado                              // Se for diferente de cgm entre a empresa e
                                                                         // do fornecedor faz a soma

                     if ( nTMPX := ascan(aRESUMO_UF,SAI->Estado) ) == 0  // Soma os valores por estado
                        aadd(aRESUMO_UF,SAI->Estado   )
                        aadd(aRESUMO_VC,SAI->Vlr_cont )
                        aadd(aRESUMO_BI,SAI->Icm_base + nICM_R_B)
                        aadd(aRESUMO_BC,SAI->Icm_bc_s )
                        aadd(aRESUMO_OI,SAI->Icm_out  )
                        aadd(aRESUMO_IS,SAI->Icm_subst)
                     else
                        aRESUMO_VC[nTMPX] += SAI->Vlr_cont
                        aRESUMO_BI[nTMPX] += SAI->Icm_base + nICM_R_B
                        aRESUMO_BC[nTMPX] += SAI->Icm_bc_s
                        aRESUMO_OI[nTMPX] += SAI->Icm_out
                        aRESUMO_IS[nTMPX] += SAI->Icm_subst
                     endif

                  endif

               endif

               i_imp_nf2()

            else

               SAI->(dbskip(-1))

               if lPR_VEZ
                  cNF_INI := SAI->Num_nf
                  lPR_VEZ := .F.
               endif

               if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->Filial))

                  for nCONT := 1 to 5

                      qgirabarra()

                      aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
                      aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
                      aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr

                      if ( nTMP := ascan(aOUT_P,aOUTALIQ[nCONT,2]) ) == 0
                         aadd(aOUT_B,aOUTALIQ[nCONT,1])
                         aadd(aOUT_P,aOUTALIQ[nCONT,2])
                         aadd(aOUT_V,aOUTALIQ[nCONT,3])
                      else
                         aOUT_B[nTMP] += aOUTALIQ[nCONT,1]
                         aOUT_V[nTMP] += aOUTALIQ[nCONT,3]
                      endif

                      fICM_BASE  += OUTSAI->ICM_BASE
                      fICM_VLR   += OUTSAI->ICM_VLR
                      nICM_R_B   += OUTSAI->Icm_base

                      OUTSAI->(dbskip())

                      if dtos(SAI->Data_Lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                         exit
                      endif
                  next

               endif

               CGM->(dbseek(FILIAL->CGM))
               cEMP_UF := CGM->Estado

               if cFILT_ICMS $ "1 "  // Quando usa filtro de codigo de icms de sub. tributaria (na configuracao geral do sistema)
                  if cEMP_UF <> SAI->Estado .and. SAI->Icm_cod $ "1367"  // Se for diferente de cgm entre a empresa e
                                                                         // do fornecedor faz a soma

                     if ( nTMPX := ascan(aRESUMO_UF,SAI->Estado) ) == 0  // Soma os valores, por estado
                        aadd(aRESUMO_UF,SAI->Estado   )
                        aadd(aRESUMO_VC,SAI->Vlr_cont )
                        aadd(aRESUMO_BI,SAI->Icm_base + nICM_R_B)
                        aadd(aRESUMO_BC,SAI->Icm_bc_s )
                        aadd(aRESUMO_OI,SAI->Icm_out  )
                        aadd(aRESUMO_IS,SAI->Icm_subst)
                     else
                        aRESUMO_VC[nTMPX] += SAI->Vlr_cont
                        aRESUMO_BI[nTMPX] += SAI->Icm_base + nICM_R_B
                        aRESUMO_BC[nTMPX] += SAI->Icm_bc_s
                        aRESUMO_OI[nTMPX] += SAI->Icm_out
                        aRESUMO_IS[nTMPX] += SAI->Icm_subst
                     endif

                  endif
               else
                  if cEMP_UF <> SAI->Estado                              // Se for diferente de cgm entre a empresa e
                                                                         // do fornecedor faz a soma

                     if ( nTMPX := ascan(aRESUMO_UF,SAI->Estado) ) == 0  // Soma os valores, por estado
                        aadd(aRESUMO_UF,SAI->Estado   )
                        aadd(aRESUMO_VC,SAI->Vlr_cont )
                        aadd(aRESUMO_BI,SAI->Icm_base + nICM_R_B)
                        aadd(aRESUMO_BC,SAI->Icm_bc_s )
                        aadd(aRESUMO_OI,SAI->Icm_out  )
                        aadd(aRESUMO_IS,SAI->Icm_subst)
                     else
                        aRESUMO_VC[nTMPX] += SAI->Vlr_cont
                        aRESUMO_BI[nTMPX] += SAI->Icm_base + nICM_R_B
                        aRESUMO_BC[nTMPX] += SAI->Icm_bc_s
                        aRESUMO_OI[nTMPX] += SAI->Icm_out
                        aRESUMO_IS[nTMPX] += SAI->Icm_subst
                     endif

                  endif
               endif

            endif

            nICM_R_B := 0

         endif

         nNF_ANT    := val(SAI->Num_nf)                               // Guarda os dados do registro...
         cNF_SERIE  := SAI->Serie                                     // ... anterior
         dNF_DATA   := SAI->Data_Emis
         cNF_C_FISC := SAI->Cod_Fisc
         cNF_CFOP   := SAI->Cfop
         cNF_I_COD  := SAI->Icm_cod
         cNF_ESTADO := SAI->Estado
         cNF_CONT   := SAI->Cod_cont

         nV_CONT := SAI->Vlr_cont
         nI_BASE := SAI->Icm_base
         nI_VLR  := round(SAI->Icm_vlr,2)
         nI_ISEN := SAI->Icm_isen
         nI_OUT  := SAI->Icm_out

         nIPI_BASE := SAI->Ipi_base
         nIPI_VLR  := round(SAI->Ipi_vlr,2)
         nIPI_ISEN := SAI->Ipi_isen
         nIPI_OUT  := SAI->Ipi_out

         SAI->(dbskip())

         if val(SAI->Num_nf) == nNF_ANT+1 .and. SAI->Serie    == cNF_SERIE  .and.;
            SAI->Data_emis   == dNF_DATA  .and. iif(val(left(CONFIG->Anomes,4)) < 2003,SAI->Cod_fisc <> cNF_C_FISC,SAI->Cfop <> cNF_CFOP ) .and.;
            SAI->Icm_cod     == cNF_I_COD .and. SAI->Estado   == cNF_ESTADO .and.;
            SAI->Cod_cont    == cNF_CONT

            nS_V_CONT += nV_CONT
            nS_I_BASE += nI_BASE
            nS_I_VLR  += nI_VLR
            nS_I_ISEN += nI_ISEN
            nS_I_OUT  += nI_OUT

            nS_IPI_BASE += nIPI_BASE
            nS_IPI_VLR  += nIPI_VLR
            nS_IPI_ISEN += nIPI_ISEN
            nS_IPI_OUT  += nIPI_OUT

            nV_CONT := 0
            nI_BASE := 0
            nI_VLR  := 0
            nI_ISEN := 0
            nI_OUT  := 0

            nIPI_BASE := 0
            nIPI_VLR  := 0
            nIPI_ISEN := 0
            nIPI_OUT  := 0

         endif

      endif

      // IMPRIME SUBTOTAL, CONFIGURADO NA OPCAO 801 ______________________________

      if cSUBTOTAL == "1"

         if prow() > 53

            @ prow()+1,2 say replicate("_",156)
            @ prow()+1,2 say "Sub-Total........:" + space(31) + transform(fVLR_CONT,cPIC1) +;
                                                    space(13) + transform(fICM_BASE,cPIC1) +;
                                                     "      " + transform(fICM_VLR,cPIC1)  +;
                                                         "  " + transform(fICM_ISEN,cPIC1) +;
                                                         "  " + transform(fICM_OUT,cPIC1)

            if XTIPOEMP $ "457"
               @ prow()+1,70 say "IPI    " + transform(fIPI_BASE,cPIC1) +;
                                  "      " + transform(fIPI_VLR,cPIC1)  +;
                                      "  " + transform(fIPI_ISEN,cPIC1) +;
                                      "  " + transform(fIPI_OUT,cPIC1)
            endif

         endif

      endif

   enddo

   // IMPRIME O FINAL DO RELATORIO _______________________________________________

   i_tot_periodo()

   // INCREMENTA nMES PARA VERIFICAR TERMINO DO RELATORIO COM MESES EM BRANCO ____

   nMES++

   // VERIFICA NUMERO DE MESES QUE FALTAM PARA IMPRESSAO _________________________

   if nMES <= month(dDATA_FIM)

      do while nMES <= month(dDATA_FIM)
         nFALTA++
         nMES++
      enddo

   endif

   // FAZ O RELATORIO DOS MESES SEM MOVIMENTO, ATE A DATA FINAL __________________

   if nFALTA > 0

      nMES -= nFALTA

      do while nFALTA > 0

         // BUSCA O DEBITO, IMPRIME O TOTAL, O CABECALHO, GRAVA VALORES __________

         qpageprn()

         i_cabecalho(cTITULO,150)
         i_cabec()

         if cSUBTOTAL == "1"

            if prow() > 53

               @ prow()+1,2 say replicate("_",156)
               @ prow()+1,2 say "Sub-Total........:" + space(32) + transform(fVLR_CONT,cPIC1) +;
                                                       space(13) + transform(fICM_BASE,cPIC1) +;
                                                       "       " + transform(fICM_VLR,cPIC1)  +;
                                                            "  " + transform(fICM_ISEN,cPIC1) +;
                                                            "  " + transform(fICM_OUT,cPIC1)

               if XTIPOEMP $ "457"
                  @ prow()+1,71 say "IPI    " + transform(fIPI_BASE,cPIC1) +;
                                    "       " + transform(fIPI_VLR,cPIC1)  +;
                                         "  " + transform(fIPI_ISEN,cPIC1) +;
                                         "  " + transform(fIPI_OUT,cPIC1)
               endif

            endif

         endif

         lCABECALHO := .F.

         i_tot_periodo()

      //   i_cabec_resumo()

         setprc(56,00)

         nFALTA--
         nMES++

      enddo

   endif

   // PROGRAMA EF510.PRG _________________________________________________________

   i_grava_pagina()

   qstopprn()

return

//////////////////////////////////////////////////////////////////////////////////
// IMPRIME O TOTAL DE CADA PERIODO _______________________________________________

static function i_tot_periodo

   local nCONTX    := 0
   local nTOT_R_VC := 0
   local nTOT_R_BI := 0
   local nTOT_R_BC := 0
   local nTOT_R_OI := 0
   local nTOT_R_IS := 0

   // IMPRIME CABECALHO QUANDO NAO ENTRA NO while ACIMA __________________________

   if lCABECALHO
      XPAGINA := nFOLHA
      i_cabecalho(cTITULO,150)
      i_cabec()
   endif

   // POSICIONA SOBRE O REGISTRO DA BASE DE CALCULO AJUSTADA P/ MAQ.REG. _________

   if XTIPOEMP $ "3" // "38"

      SAI->(dbsetorder(1))
      SAI->(dbgotop())

      if SAI->(dbseek("@@" + left(XANOMES,2) + right(XANOMES,4)))

         @ prow()+1,2 say substr(dtoc(SAI->DATA_LANC),1,2)            +;
                          space(27)  + dtoc(SAI->DATA_EMIS)           +;
                          space(26)  + iif(val(left(CONFIG->Anomes,4)) < 2003,SAI->COD_FISC,SAI->Cfop)+;
                          " ICMS   " + transform(SAI->ICM_BASE,cPIC1) +;
                          " " + substr(str(SAI->ICM_ALIQ),2,4)        +;
                          " " + transform(round(SAI->ICM_VLR,2),cPIC1)+;
                          " " + SAI->OBS

         fICM_BASE += SAI->ICM_BASE
         fICM_VLR  += round(SAI->ICM_VLR,2)
         //fICM_VLR  += SAI->ICM_VLR
         //fICM_VLR  := round(fICM_VLR,2)

      endif

      SAI->(dbsetorder(2))

   endif

   @ prow()+1,2 say replicate("_",156)

   // APENAS PARA MELHORAR ESTETICA DO RELATORIO SEM MOVIMENTO ___________________

   if (fVLR_CONT + fICM_BASE + fICM_VLR + fICM_ISEN + fICM_OUT) > 0

      @ prow()+1,2 say "Totais do Periodo:" + space(31) + transform(fVLR_CONT,cPIC1) +;
                                              space(13) + transform(fICM_BASE,cPIC1) +;
                                               "      " + transform(fICM_VLR,cPIC1)  +;
                                                   "  " + transform(fICM_ISEN,cPIC1) +;
                                                   "  " + transform(fICM_OUT,cPIC1)
   else

      @ prow()+1,2 say "Totais do Periodo:" + space(29) + transform(fVLR_CONT, cPIC1) +;
                                              space(11) + transform(fICM_BASE, cPIC1) +;
                                              space(05) + transform(fICM_VLR , cPIC1) +;
                                                          transform(fICM_ISEN, cPIC1) +;
                                                          transform(fICM_OUT , cPIC1)

      if lCABECALHO .and. ! XTIPOEMP $ "457"
         if val(left(CONFIG->Anomes,4)) == 1996  // Legislacao apartir do ano 1996 resumo no final do livro...
                                               // ... as notas de fora do estado
            i_cabec_resumo()

            for nCONTX := 1 to len(aRESUMO_UF)

                if prow() > K_MAX_LIN
                   qpageprn()

                   // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

                   if nFOLHA <> 0
                      XPAGINA = nFOLHA
                      nFOLHA  = 0
                   endif

                   i_cabecalho(cTITULO,150)
                   i_cabec()
                   i_cabec_resumo()
                endif

                @ prow()+1,02 say aRESUMO_UF[nCONTX]                  + "    "   +;
                                  transform(aRESUMO_VC[nCONTX],cPIC1) + "    "   +;
                                  transform(aRESUMO_BI[nCONTX],cPIC1) + "    "   +;
                                  transform(aRESUMO_BC[nCONTX],cPIC1) + "  "     +;
                                  transform(aRESUMO_OI[nCONTX],cPIC1) + "      " +;
                                  transform(aRESUMO_IS[nCONTX],cPIC1)

                nTOT_R_VC += aRESUMO_VC[nCONTX]
                nTOT_R_BI += aRESUMO_BI[nCONTX]
                nTOT_R_BC += aRESUMO_BC[nCONTX]
                nTOT_R_OI += aRESUMO_OI[nCONTX]
                nTOT_R_IS += aRESUMO_IS[nCONTX]

            next

            @ prow()+1,02 say replicate("_",93)

            @ prow()+1,08 say transform(nTOT_R_VC,cPIC1) + "    "   +;
                              transform(nTOT_R_BI,cPIC1) + "    "   +;
                              transform(nTOT_R_BC,cPIC1) + "  "     +;
                              transform(nTOT_R_OI,cPIC1) + "      " +;
                              transform(nTOT_R_IS,cPIC1)

         endif
         eject
      endif

   endif

   if XTIPOEMP $ "457"

      if (fIPI_BASE + fIPI_VLR + fIPI_ISEN + fIPI_OUT) > 0

         @ prow()+1,70 say "IPI    " + transform(fIPI_BASE,cPIC1) +;
                            "      " + transform(fIPI_VLR,cPIC1)  +;
                                "  " + transform(fIPI_ISEN,cPIC1) +;
                                "  " + transform(fIPI_OUT,cPIC1)

      else

         @ prow()+1,70 say "IPI" + transform(fIPI_BASE, cPIC1) +;
                         "     " + transform(fIPI_VLR, cPIC1)  +;
                                   transform(fIPI_ISEN, cPIC1) +;
                                   transform(fIPI_OUT, cPIC1)

         if lCABECALHO
            if val(left(CONFIG->Anomes,4)) == 1996  // Legislacao apartir do ano 1996 resumo no final do livro...
                                                  // ... as notas de fora do estado
               i_cabec_resumo()

               for nCONTX := 1 to len(aRESUMO_UF)

                   if prow() > K_MAX_LIN
                      qpageprn()

                      // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

                      if nFOLHA <> 0
                         XPAGINA = nFOLHA
                         nFOLHA  = 0
                      endif

                      i_cabecalho(cTITULO,150)
                      i_cabec()
                      i_cabec_resumo()
                   endif

                   @ prow()+1,02 say aRESUMO_UF[nCONTX]                  + "    "   +;
                                     transform(aRESUMO_VC[nCONTX],cPIC1) + "    "   +;
                                     transform(aRESUMO_BI[nCONTX],cPIC1) + "    "   +;
                                     transform(aRESUMO_BC[nCONTX],cPIC1) + "  "     +;
                                     transform(aRESUMO_OI[nCONTX],cPIC1) + "      " +;
                                     transform(aRESUMO_IS[nCONTX],cPIC1)

                   nTOT_R_VC += aRESUMO_VC[nCONTX]
                   nTOT_R_BI += aRESUMO_BI[nCONTX]
                   nTOT_R_BC += aRESUMO_BC[nCONTX]
                   nTOT_R_OI += aRESUMO_OI[nCONTX]
                   nTOT_R_IS += aRESUMO_IS[nCONTX]

               next

               @ prow()+1,02 say replicate("_",93)

               @ prow()+1,08 say transform(nTOT_R_VC,cPIC1) + "    "   +;
                                 transform(nTOT_R_BI,cPIC1) + "    "   +;
                                 transform(nTOT_R_BC,cPIC1) + "  "     +;
                                 transform(nTOT_R_OI,cPIC1) + "      " +;
                                 transform(nTOT_R_IS,cPIC1)

            endif
            eject
         endif

      endif

   endif

   if prow() > K_MAX_LIN

      qpageprn()

      // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

      if nFOLHA <> 0
         XPAGINA = nFOLHA
         nFOLHA  = 0
      endif

      i_cabecalho(cTITULO,150)
      i_cabec()

   endif

   if val(left(CONFIG->Anomes,4)) >= 1996 .and. ! lCABECALHO  // Legislacao apartir do ano 1996 resumo no final do livro...
                                                            // ... as notas de fora do estado
      i_cabec_resumo()

      for nCONTX := 1 to len(aRESUMO_UF)

          if prow() > K_MAX_LIN
             qpageprn()

             // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

             if nFOLHA <> 0
                XPAGINA = nFOLHA
                nFOLHA  = 0
             endif

             i_cabecalho(cTITULO,150)
             i_cabec()
             i_cabec_resumo()
          endif

          @ prow()+1,02 say aRESUMO_UF[nCONTX]                  + "    "   +;
                            transform(aRESUMO_VC[nCONTX],cPIC1) + "    "   +;
                            transform(aRESUMO_BI[nCONTX],cPIC1) + "    "   +;
                            transform(aRESUMO_BC[nCONTX],cPIC1) + "  "     +;
                            transform(aRESUMO_OI[nCONTX],cPIC1) + "      " +;
                            transform(aRESUMO_IS[nCONTX],cPIC1)

          nTOT_R_VC += aRESUMO_VC[nCONTX]
          nTOT_R_BI += aRESUMO_BI[nCONTX]
          nTOT_R_BC += aRESUMO_BC[nCONTX]
          nTOT_R_OI += aRESUMO_OI[nCONTX]
          nTOT_R_IS += aRESUMO_IS[nCONTX]

      next

      @ prow()+1,02 say replicate("_",93)

      @ prow()+1,08 say transform(nTOT_R_VC,cPIC1) + "    "   +;
                        transform(nTOT_R_BI,cPIC1) + "    "   +;
                        transform(nTOT_R_BC,cPIC1) + "  "     +;
                        transform(nTOT_R_OI,cPIC1) + "      " +;
                        transform(nTOT_R_IS,cPIC1)

   endif

   // ZERA VALORES DOS TOTAIS DOS PERIODOS IMPRESSOS _____________________________

   fVLR_CONT := 0
   fICM_BASE := 0
   fICM_VLR  := 0
   fICM_ISEN := 0
   fICM_OUT  := 0

   if XTIPOEMP $ "457"
      fIPI_BASE := 0
      fIPI_VLR  := 0
      fIPI_ISEN := 0
      fIPI_OUT  := 0
   endif

   aRESUMO_UF := {}
   aRESUMO_VC := {}
   aRESUMO_BI := {}
   aRESUMO_BC := {}
   aRESUMO_OI := {}
   aRESUMO_IS := {}

   nTOT_R_VC  := 0
   nTOT_R_BI  := 0
   nTOT_R_BC  := 0
   nTOT_R_OI  := 0
   nTOT_R_IS  := 0

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO PARA OS LIVROS DE ENTRADA E SAIDA DE NOTAS FISCAIS __________________

static function i_cabec

   @ prow()+1,2 say replicate("_",156)
   @ prow()+1,2 say "  |              DOCUMENTOS FISCAIS           |               |  CODIGO  |                   VALORES FISCAIS                             |              "
   @ prow()+1,2 say "DT|___________________________________________|   VALOR       |________ *|_______________________________________________________________|              "
   @ prow()+1,2 say "  |     |SERIE|             |DATA DO |  |     |               |   |ICMS|C|              |   |   IMPOSTO    |              |              | OBSERVACAO   "
   @ prow()+1,2 say "EN|ESPEC|SUB- |NUMERO|NUMERO|        |UF| CONT|   CONTABIL    |FIS|IPI |O| BASE DE CALC.|AL |   DEBITADO   |   ISENTAS    |    OUTRAS    |              "
   @ prow()+1,2 say "TR|     |SERIE|INIC. |FINAL |  DOC.  |  |     |               |CAL|    |D| VLR OPERACAO |IQ |              |              |              |              "
   @ prow()+1,2 say replicate("_",156)

return

//////////////////////////////////////////////////////////////////////////////////
// IMPRIME AS NOTAS FISCAIS EM SEQUENCIAS NORMAIS ________________________________

static function i_imp_nf

   // SE FOR MAQUINA REGISTRADORA LISTA NOTA SOMENTE ATE' CODIGO FISCAL

//   @ prow()+1,2 say substr(dtoc(SAI->DATA_LANC),1,2) + " "  + i_especie(SAI->ESPECIE) + " " + i_serie(SAI->SERIE)    +;
//                                                     " "  + SAI->NUM_NF             + " " + SAI->NUM_ULT_NF        +;
//                                                     " "  + dtoc(SAI->DATA_EMIS)    + " " + SAI->ESTADO            +;
//                                                     " "  + SAI->Cod_Cont + "  " + transform(SAI->VLR_CONT,cPIC1)  +;
//                                                     " "  + SAI->COD_FISC + iif(XTIPOEMP $ "1245678", " " + "ICMS" +;
//                                                     " "  + SAI->ICM_COD  + "  " + transform(SAI->ICM_BASE,cPIC1)  +;
//                                                     " "  + substr(str(SAI->ICM_ALIQ),2,4)                         +;
//                                                     " "  + transform(SAI->ICM_VLR,cPIC1)                          +;
//                                                     "  " + transform(SAI->ICM_ISEN,cPIC1)                         +;
//                                                     "  " + transform(SAI->ICM_OUT,cPIC1) + " " + SAI->OBS,"")

   @ prow()+1,2  say substr(dtoc(SAI->DATA_LANC),1,2)       // Modificado 31/05/96
   @ prow()  ,5  say i_especie(SAI->ESPECIE)                // para impressao de observacao em duas linhas
   @ prow()  ,11 say i_serie(SAI->SERIE)
   @ prow()  ,17 say SAI->NUM_NF
   @ prow()  ,24 say SAI->NUM_ULT_NF
   @ prow()  ,30 say dtoc(SAI->DATA_EMIS)
   @ prow()  ,40 say SAI->ESTADO
   @ prow()  ,43 say SAI->Cod_Cont
   @ prow()  ,51 say transform(SAI->VLR_CONT,cPIC1)
   @ prow()  ,65 say iif(val(left(CONFIG->Anomes,4)) < 2003,SAI->Cod_fisc,SAI->Cfop)

   if XTIPOEMP $ "124567890"
      @ prow()  ,69  say "ICMS"
      @ prow()  ,74  say SAI->ICM_COD
      @ prow()  ,77  say transform(SAI->ICM_BASE,cPIC1)
      @ prow()  ,91  say substr(str(SAI->ICM_ALIQ),2,4)
      @ prow()  ,96  say transform(round(SAI->ICM_VLR,2),cPIC1)
      @ prow()  ,111 say transform(SAI->ICM_ISEN,cPIC1)
      @ prow()  ,126 say transform(SAI->ICM_OUT,cPIC1)
      if len(rtrim(SAI->Obs)) > 18
         @ prow()  ,140 say substr(SAI->Obs,1,18)
         @ prow()+1,140 say substr(SAI->Obs,19,36)
      else
         @ prow()  ,140 say subst(SAI->Obs,1,18)
      endif
   else
      @ prow()  ,69  say ""
   endif

   if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->Filial))

      for nCONT := 1 to 5

          qgirabarra()

          aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
          aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
          aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr

          @ prow()+1,69 say "ICM" + str(nCONT+1,1)                     +;
                           "    " + transform(aOUTALIQ[nCONT,1],cPIC1) +;
                              " " + substr(str(aOUTALIQ[nCONT,2]),2,4) +;
                              " " + transform(aOUTALIQ[nCONT,3],cPIC1)

          fICM_BASE  += OUTSAI->ICM_BASE
          fICM_VLR   += OUTSAI->ICM_VLR
          nICM_R_B   += OUTSAI->Icm_base

          OUTSAI->(dbskip())

          if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
             exit
          endif

      next

   endif

   if XTIPOEMP $ "457"

      @ prow()+1,70 say "IPI    " + transform(SAI->IPI_BASE,cPIC1) +;
                         "      " + transform(SAI->IPI_VLR,cPIC1)  +;
                             "  " + transform(SAI->IPI_ISEN,cPIC1) +;
                             "  " + transform(SAI->IPI_OUT,cPIC1)

      fIPI_BASE += SAI->IPI_BASE
      fIPI_VLR  += SAI->IPI_VLR
      fIPI_ISEN += SAI->IPI_ISEN
      fIPI_OUT  += SAI->IPI_OUT

   endif

   fVLR_CONT += SAI->VLR_CONT
   fICM_BASE += SAI->ICM_BASE
   fICM_VLR  += round(SAI->ICM_VLR,2)
   //fICM_VLR  += SAI->ICM_VLR
   //fICM_VLR  := round(fICM_VLR,2)
   fICM_ISEN += SAI->ICM_ISEN
   fICM_OUT  += SAI->ICM_OUT

   CGM->(dbseek(FILIAL->CGM))
   cEMP_UF := CGM->Estado

   if cFILT_ICMS $ "1 "  // Quando usa filtro de codigo de icms de sub. tributaria (na configuracao geral do sistema)
      if cEMP_UF <> SAI->Estado .and. SAI->Icm_cod $ "1367"  // Se for diferente de cgm entre a empresa e
                                                             // do fornecedor faz a soma

         if ( nTMPX := ascan(aRESUMO_UF,SAI->Estado) ) == 0  // Soma os valores, por estado
            aadd(aRESUMO_UF,SAI->Estado   )
            aadd(aRESUMO_VC,SAI->Vlr_cont )
            aadd(aRESUMO_BI,SAI->Icm_base + nICM_R_B)
            aadd(aRESUMO_BC,SAI->Icm_bc_s )
            aadd(aRESUMO_OI,SAI->Icm_out  )
            aadd(aRESUMO_IS,SAI->Icm_subst)
         else
            aRESUMO_VC[nTMPX] += SAI->Vlr_cont
            aRESUMO_BI[nTMPX] += SAI->Icm_base + nICM_R_B
            aRESUMO_BC[nTMPX] += SAI->Icm_bc_s
            aRESUMO_OI[nTMPX] += SAI->Icm_out
            aRESUMO_IS[nTMPX] += SAI->Icm_subst
         endif

      endif
   else
      if cEMP_UF <> SAI->Estado                              // Se for diferente de cgm entre a empresa e
                                                             // do fornecedor faz a soma

         if ( nTMPX := ascan(aRESUMO_UF,SAI->Estado) ) == 0  // Soma os valores, por estado
            aadd(aRESUMO_UF,SAI->Estado   )
            aadd(aRESUMO_VC,SAI->Vlr_cont )
            aadd(aRESUMO_BI,SAI->Icm_base + nICM_R_B)
            aadd(aRESUMO_BC,SAI->Icm_bc_s )
            aadd(aRESUMO_OI,SAI->Icm_out  )
            aadd(aRESUMO_IS,SAI->Icm_subst)
         else
            aRESUMO_VC[nTMPX] += SAI->Vlr_cont
            aRESUMO_BI[nTMPX] += SAI->Icm_base + nICM_R_B
            aRESUMO_BC[nTMPX] += SAI->Icm_bc_s
            aRESUMO_OI[nTMPX] += SAI->Icm_out
            aRESUMO_IS[nTMPX] += SAI->Icm_subst
         endif

      endif
   endif

   nICM_R_B := 0

return

//////////////////////////////////////////////////////////////////////////////////
// IMPRIME AS NOTAS FISCAIS EM SEQUENCIAS TOTALIZADAS ____________________________

static function i_imp_nf2

   // SE FOR MAQUINA REGISTRADORA LISTA NOTA SOMENTE ATE' CODIGO FISCAL

// @ prow()+1,2 say substr(dtoc(SAI->DATA_LANC),1,2) + " "  + i_especie(SAI->ESPECIE) + " " + i_serie(SAI->SERIE)         +;
//                                                     " "  + if(nS_V_CONT <> 0, cNF_INI, SAI->Num_nf)                    +;
//                                                     " "  + if(nS_V_CONT <> 0, SAI->Num_nf, SAI->Num_ult_nf)            +;
//                                                     " "  + dtoc(SAI->DATA_EMIS)    + " " + SAI->ESTADO                 +;
//                                                     " "  + SAI->Cod_Cont + "  " + transform(nV_CONT + nS_V_CONT,cPIC1) +;
//                                                     " "  + SAI->COD_FISC + iif(XTIPOEMP $ "1245678", " " + "ICMS"      +;
//                                                     " "  + SAI->ICM_COD  + "  " + transform(nI_BASE + nS_I_BASE,cPIC1) +;
//                                                     " "  + substr(str(SAI->ICM_ALIQ),2,4)                              +;
//                                                     " "  + transform(nI_VLR + nS_I_VLR,cPIC1)                          +;
//                                                     "  " + transform(nI_ISEN + nS_I_ISEN,cPIC1)                        +;
//                                                     "  " + transform(nI_OUT + nS_I_OUT,cPIC1) + " " + SAI->OBS,"")
                  
   @ prow()+1,2  say substr(dtoc(SAI->DATA_LANC),1,2)       // Modificado 31/05/96
   @ prow()  ,5  say i_especie(SAI->ESPECIE)                // para impressao de observacao em duas linhas
   @ prow()  ,11 say i_serie(SAI->SERIE)
   @ prow()  ,17 say if(nS_V_CONT <> 0, cNF_INI, SAI->Num_nf)
   @ prow()  ,24 say if(nS_V_CONT <> 0, SAI->Num_nf, SAI->Num_ult_nf)
   @ prow()  ,30 say dtoc(SAI->DATA_EMIS)
   @ prow()  ,40 say SAI->ESTADO
   @ prow()  ,43 say SAI->Cod_Cont
   @ prow()  ,51 say transform(nV_CONT + nS_V_CONT,cPIC1)
   @ prow()  ,65 say iif(val(left(CONFIG->Anomes,4)) < 2003,SAI->Cod_fisc,SAI->Cfop)

   if XTIPOEMP $ "1245678"
      @ prow()  ,69  say "ICMS"
      @ prow()  ,74  say SAI->ICM_COD
      @ prow()  ,77  say transform(nI_BASE + nS_I_BASE,cPIC1)
      @ prow()  ,91  say substr(str(SAI->ICM_ALIQ),2,4)
      @ prow()  ,96  say transform(nI_VLR + nS_I_VLR,cPIC1)
      @ prow()  ,111 say transform(nI_ISEN + nS_I_ISEN,cPIC1)
      @ prow()  ,126 say transform(nI_OUT + nS_I_OUT,cPIC1)
      if len(rtrim(SAI->Obs)) > 18
         @ prow()  ,140 say substr(SAI->Obs,1,18)
         @ prow()+1,140 say substr(SAI->Obs,19,36)
      else
         @ prow()  ,140 say subst(SAI->Obs,1,18)
      endif
   else
      @ prow()  ,69  say ""
   endif

   for nCONTX := 1 to len(aOUT_P)

       @ prow()+1,69 say "ICM" + str(nCONTX+1,1)                 +;
                        "    " + transform(aOUT_B[nCONTX],cPIC1) +;
                           " " + substr(str(aOUT_P[nCONTX]),2,4) +;
                           " " + transform(aOUT_V[nCONTX],cPIC1)
   next

   if XTIPOEMP $ "457"

      @ prow()+1,70 say "IPI    " + transform(nIPI_BASE + nS_IPI_BASE,cPIC1) +;
                         "      " + transform(nIPI_VLR  + nS_IPI_VLR ,cPIC1) +;
                             "  " + transform(nIPI_ISEN + nS_IPI_ISEN,cPIC1) +;
                             "  " + transform(nI_OUT    + nS_I_OUT   ,cPIC1)

      fIPI_BASE += SAI->IPI_BASE + nS_IPI_BASE
      fIPI_VLR  += SAI->IPI_VLR  + nS_IPI_VLR
      fIPI_ISEN += SAI->IPI_ISEN + nS_IPI_ISEN
      fIPI_OUT  += SAI->IPI_OUT  + nS_IPI_OUT

   endif

   fVLR_CONT += SAI->VLR_CONT + nS_V_CONT
   fICM_BASE += SAI->ICM_BASE + nS_I_BASE
   fICM_VLR  += round(SAI->ICM_VLR,2) + nS_I_VLR
   //fICM_VLR  += SAI->ICM_VLR + nS_I_VLR
   //fICM_VLR  := round(fICM_VLR,2)
   fICM_ISEN += SAI->ICM_ISEN + nS_I_ISEN
   fICM_OUT  += SAI->ICM_OUT  + nS_I_OUT

   nV_CONT   := 0
   nI_BASE   := 0
   nI_VLR    := 0
   nI_ISEN   := 0
   nI_OUT    := 0

   nIPI_BASE   := 0
   nIPI_VLR    := 0
   nIPI_ISEN   := 0
   nIPI_OUT    := 0

   nS_V_CONT := 0
   nS_I_BASE := 0
   nS_I_VLR  := 0
   nS_I_ISEN := 0
   nS_I_OUT  := 0

   nS_IPI_BASE := 0
   nS_IPI_VLR  := 0
   nS_IPI_ISEN := 0
   nS_IPI_OUT  := 0

   aOUT_B    := {}
   aOUT_P    := {}
   aOUT_V    := {}

   lPR_VEZ   := .T.

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO DO RESUMO ___________________________________________________________

static function i_cabec_resumo

   @ prow()+2,14 say "RESUMO DAS SAIDAS CONFORME ART. 236 PARAGRAFO 7. RICMS/PR"
   @ prow()+1,02 say "UF    Valor Contabil    B.C. do Icms    B.C do Icms Sub.   Outras     Valor ICMS Substituicao"
   @ prow()+1,02 say replicate("_",93)

return
