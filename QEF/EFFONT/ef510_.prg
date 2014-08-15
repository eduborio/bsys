//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: LIVRO DE ENTRADA ICMS/IPI
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........:
// ALTERACOES.:
function ef510

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

private cPIC1      := "@E 99,999,999.99"
private lCABECALHO := .T.                  // Imprime cabecalho caso nao tenha notas
private cTITULO                            // Titulo do relatorio
private bENT_FILTRO                        // Code block de filtro
private aEDICAO    := {}                   // Vetor para os campos de entrada de dados

private nFALTA                             // Numero de meses que faltam para imprimir cabecalho
private nFOLHA                             // Numero da Folha
private nMES                               // Mes para controlar mudanca de pagina
private fVLR_CONT                          // Total valor contabil
private fICM_BASE                          // Total base de icms
private fICM_VLR                           // Total imposto creditado
private fICM_ISEN                          // Total isentos icms
private fICM_OUT                           // Total outras icms
private nICM_R_B := 0                      // Valor da icms outras para resumo

private cFILIAL                            // Filial
private dDATA_INI                          // Inicio do periodo do relatorio
private dDATA_FIM                          // Fim do periodo do relatorio

private aRESUMO_UF := {}
private aRESUMO_VC := {}
private aRESUMO_BI := {}
private aRESUMO_BC := {}
private aRESUMO_OI := {}
private aRESUMO_IS := {}

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}

if XTIPOEMP $ "457"
   private fIPI_BASE                       // Total base de ipi
   private fIPI_VLR                        // Total imposto creditado
   private fIPI_ISEN                       // Total isentos ipi
   private fIPI_OUT                        // Total outras ipi
endif

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL ,"9999"           ) } ,"FILIAL"  })
aadd(aEDICAO,{{ || NIL                                           } ,NIL       }) // descricao do filial
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI     ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM     ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nFOLHA        ,"@E 9999",NIL,NIL) } ,"FOLHA"   })

do while .T.

   if XTIPOEMP $ "457"
      qlbloc(5,0,"B510B","QBLOC.GLO")
   else
      qlbloc(5,0,"B510A","QBLOC.GLO")
   endif

   XNIVEL     := 1
   XFLAG      := .T.

   fVLR_CONT  := 0
   fICM_BASE  := 0
   fICM_VLR   := 0
   fICM_ISEN  := 0
   fICM_OUT   := 0

   nFALTA     := 0                         // Meses que faltam para imprimir cabecalho
   lCABECALHO := .T.                       // Imprime cabecalho caso nao tenha notas
// nFOLHA     := val(CONFIG->PAGINA_ENT)
   nFOLHA     := 1

   cFILIAL    := "    "
   dDATA_INI  := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM  := qfimmes(dDATA_INI)

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
              qmensa("Filial encontrada !","B")
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

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ________________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ___________________________________________________

   cTITULO := "REGISTROS DE ENTRADA - ICMS"

   qmensa("")

   // CRIA MACRO DE FILTRO _______________________________________________________

   bENT_FILTRO := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }

   ENT->(dbSetFilter({|| alltrim(Filial) $ cFILIAL}, 'alltrim(Filial) $ cFILIAL'))

   // ESTABELECE RELACOES ENTRE ARQUIVOS _________________________________________


   set softseek on
   select OUTENT
   OUTENT->(dbseek(dtos(dDATA_INI)))

   // ORDEM DATA DE LANCAMENTO + DATA DE EMISSAO _________________________________

   select ENT
   ENT->(dbsetorder(2))
   ENT->(dbseek(dtos(dDATA_INI)))
   set softseek off

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _______________________________

static function i_impressao

   local nTMP

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND2

   // CONDICAO PRINCIPAL DE LOOP _________________________________________________

   do while !ENT->(eof()) .and. eval(bENT_FILTRO) .and. qcontprn()

      qgirabarra()

      if ! qlineprn() ; exit ; endif

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

      if eval(bENT_FILTRO)

         if nMES <> val(str(month(ENT->DATA_LANC),2))

            nMES++

            // IMPRIME O TOTAL QUANDO MUDA O MES _________________________________

            i_tot_periodo()
            setprc(56,00)
            loop

         endif

         qmensa("Imprimindo Nota: "+ENT->Num_Nf +" / Serie : "+ENT->Serie)

         // PROCURA O CODIGO DO ESTADO ___________________________________________

         FORN->(dbseek(ENT->Cod_forn))

         cICM_UF := FORN->Cgm_ent

         // PROCURA A DESCRICAO DO ESTADO ________________________________________

         CGM->(dbseek(FORN->Cgm_ent))
         cICM_UF := CGM->Estado

         @ prow()+1,2 say substr(dtoc(ENT->DATA_LANC),1,2) + " " +;
                          i_especie(ENT->ESPECIE)          + " " +;
                          i_serie(ENT->SERIE)             + "  " +;
                          ENT->NUM_NF                    + "   " +;
                          dtoc(ENT->DATA_EMIS)             + " " +;
                          ENT->COD_FORN                    + " " +;
                          cICM_UF                         + "  " +;
                          ENT->COD_CONT                          +;
                          transform(ENT->VLR_CONT,"@E 9999999.99") + " " +;
                          iif( val(left(CONFIG->Anomes,4)) < 2003,ENT->COD_FISC,ENT->Cfop) + " " +;
                          "ICMS"                           + " " +;
                          ENT->ICM_COD                    + "  " +;
                          transform(ENT->ICM_BASE,cPIC1)   + " " +;
                          substr(str(ENT->ICM_ALIQ),2,4)   + " " +;
                          transform(round(ENT->ICM_VLR,2),cPIC1)   + "  " +;
                          transform(ENT->ICM_ISEN,cPIC1)  + "  " +;
                          transform(ENT->ICM_OUT,cPIC1)
                          if len(rtrim(ENT->Obs)) > 17
                             @ prow()  ,140 say substr(ENT->Obs,1,17)
                             @ prow()+1,140 say substr(ENT->Obs,18,35)
                          else
                             @ prow()  ,140 say subst(ENT->Obs,1,17)
                          endif

         if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
      // if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial+ENT->Icm_cod))

            for nCONT := 1 to 5

                qgirabarra()

                aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
                aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
                aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr

                @ prow()+1,69 say "ICM"+ str(nCONT+1,1)                      + "    " +;
                                         transform((aOUTALIQ[nCONT,1]),cPIC1)+ " "    +;
                                         substr(str(aOUTALIQ[nCONT,2]),2,4)  + " "    +;
                                         transform((aOUTALIQ[nCONT,3]),cPIC1)

                fICM_BASE += OUTENT->ICM_BASE
                fICM_VLR  += OUTENT->ICM_VLR
                nICM_R_B  += OUTENT->ICM_BASE


                OUTENT->(dbskip())

                if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
             // if ENT->Num_nf + ENT->Serie + ENT->Filial+ENT->Icm_cod <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial + OUTENT->Icm_cod
                   exit
                endif

            next

         endif

         if XTIPOEMP $ "457"
            @ prow()+1,70 say "IPI    " + transform(ENT->IPI_BASE,cPIC1) + "      " +;
                                          transform(ENT->IPI_VLR,cPIC1)  + "  "     +;
                                          transform(ENT->IPI_ISEN,cPIC1) + "  "     +;
                                          transform(ENT->IPI_OUT,cPIC1)
            fIPI_BASE += ENT->IPI_BASE
            fIPI_VLR  += ENT->IPI_VLR
            fIPI_ISEN += ENT->IPI_ISEN
            fIPI_OUT  += ENT->IPI_OUT
         endif

         fVLR_CONT += ENT->VLR_CONT
         fICM_BASE += ENT->ICM_BASE
         fICM_VLR  += round(ENT->ICM_VLR,2)

         //fICM_VLR  += ENT->ICM_VLR
         //fICM_VLR  := round(fICM_VLR,2)

         fICM_ISEN += ENT->ICM_ISEN
         fICM_OUT  += ENT->ICM_OUT

         // SE A NOTA FOR FORA DO ESTADO, FAZ A SOMA ENTRE OS ESTADOS IGUAIS  ____

         CGM->(dbseek(XCGM))
         cEMP_UF := CGM->Estado

         if cFILT_ICMS $ "1 "  // Quando usa filtro de codigo de icms de sub. tributaria (na configuracao geral do sistema)
            if cEMP_UF <> cICM_UF .and. ENT->Icm_cod $ "1367" // Se for diferente de cgm entre a empresa e do fornecedor faz a soma

               if ( nTMP := ascan(aRESUMO_UF,cICM_UF) ) == 0  // Soma os valores por estado
                  aadd(aRESUMO_UF,cICM_UF       )
                  aadd(aRESUMO_VC,ENT->Vlr_cont )
                  aadd(aRESUMO_BI,ENT->Icm_base + nICM_R_B )
                  aadd(aRESUMO_BC,ENT->Icm_bc_s )
                  aadd(aRESUMO_OI,ENT->Icm_out  )
                  aadd(aRESUMO_IS,ENT->Icm_subst)
               else
                  aRESUMO_VC[nTMP] += ENT->Vlr_cont
                  aRESUMO_BI[nTMP] += ENT->Icm_base + nICM_R_B
                  aRESUMO_BC[nTMP] += ENT->Icm_bc_s
                  aRESUMO_OI[nTMP] += ENT->Icm_out
                  aRESUMO_IS[nTMP] += ENT->Icm_subst
               endif

            endif
         else
            if cEMP_UF <> cICM_UF // Se for diferente de cgm entre a empresa e do fornecedor faz a soma
               if ( nTMP := ascan(aRESUMO_UF,cICM_UF) ) == 0  // Soma os valores por estado
                  aadd(aRESUMO_UF,cICM_UF       )
                  aadd(aRESUMO_VC,ENT->Vlr_cont )
                  aadd(aRESUMO_BI,ENT->Icm_base + nICM_R_B )
                  aadd(aRESUMO_BC,ENT->Icm_bc_s )
                  aadd(aRESUMO_OI,ENT->Icm_out  )
                  aadd(aRESUMO_IS,ENT->Icm_subst)
               else
                  aRESUMO_VC[nTMP] += ENT->Vlr_cont
                  aRESUMO_BI[nTMP] += ENT->Icm_base + nICM_R_B
                  aRESUMO_BC[nTMP] += ENT->Icm_bc_s
                  aRESUMO_OI[nTMP] += ENT->Icm_out
                  aRESUMO_IS[nTMP] += ENT->Icm_subst
               endif
            endif
         endif

         nICM_R_B := 0

      endif

      ENT->(dbskip())

      // IMPRIME SUBTOTAL, CONFIGURADO NA OPCAO 801 ______________________________

      if cSUBTOTAL == "1"
         if prow() > 53
            @ prow()+1,2 say replicate("_",157)
            @ prow()+1,2 say "Sub-Total........:" + space(31)+ transform(fVLR_CONT,cPIC1) +;
                                                    space(13)+ transform(fICM_BASE,cPIC1) +;
                                                    space(06)+ transform(fICM_VLR,cPIC1)  +;
                                                    space(02)+ transform(fICM_ISEN,cPIC1) +;
                                                    space(02)+ transform(fICM_OUT,cPIC1)
            if XTIPOEMP $ "457"
               @ prow()+1,70 say "IPI    " + transform(fIPI_BASE,cPIC1) + "      " +;
                                             transform(fIPI_VLR,cPIC1)  + "  "     +;
                                             transform(fIPI_ISEN,cPIC1) + "  "     +;
                                             transform(fIPI_OUT,cPIC1)
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

      nMES := nMES - nFALTA

      do while nFALTA > 0

         // BUSCA O DEBITO, IMPRIME O TOTAL, O CABECALHO, GRAVA VALORES __________

         eject
         XPAGINA++

         // qpageprn()

         i_cabecalho(cTITULO,150)

         i_cabec()

         if cSUBTOTAL == "1"
            if prow() > 53
               @ prow()+1,2 say replicate("_",157)
               @ prow()+1,2 say "Sub-Total........:" + space(31) + transform(fVLR_CONT,cPIC1) +;
                                                       space(13) + transform(fICM_BASE,cPIC1) +;
                                                       space(06) + transform(fICM_VLR,cPIC1)  +;
                                                       space(02) + transform(fICM_ISEN,cPIC1) +;
                                                       space(02) + transform(fICM_OUT,cPIC1)
               if XTIPOEMP $ "457"
                  @ prow()+1,70 say "IPI    " + transform(fIPI_BASE,cPIC1) + "      " +;
                                                transform(fIPI_VLR,cPIC1)  + "  "     +;
                                                transform(fIPI_ISEN,cPIC1) + "  "     +;
                                                transform(fIPI_OUT,cPIC1)
               endif
            endif
         endif

         lCABECALHO := .F.

         i_tot_periodo()

         setprc(56,00)

         nFALTA--
         nMES++

      enddo

   endif

   // GRAVA PAGINA E DESLIGA IMPRESSORA __________________________________________

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

   @ prow()+1,2 say replicate("_",157)

   // APENAS PARA MELHORAR ESTETICA DO RELATORIO SEM MOVIMENTO ___________________

   if (fVLR_CONT + fICM_BASE + fICM_VLR + fICM_ISEN + fICM_OUT) > 0
      @ prow()+1,2 say "Totais do Periodo:" + space(31) + transform(fVLR_CONT,cPIC1) +;
                                              space(13) + transform(fICM_BASE,cPIC1) +;
                                              space(06) + transform(fICM_VLR,cPIC1)  +;
                                              space(02) + transform(fICM_ISEN,cPIC1) +;
                                              space(02) + transform(fICM_OUT,cPIC1)
   else
      @ prow()+1,2 say "Totais do Periodo:" + space(29)+ transform(fVLR_CONT, cPIC1) +;
                                              space(11)+ transform(fICM_BASE, cPIC1) +;
                                              space(5) + transform(fICM_VLR , cPIC1) +;
                                                         transform(fICM_ISEN, cPIC1) +;
                                                         transform(fICM_OUT , cPIC1)
   endif

   if XTIPOEMP $ "457"
      if (fIPI_BASE + fIPI_VLR + fIPI_ISEN + fIPI_OUT) > 0
         @ prow()+1,70 say "IPI    " + transform(fIPI_BASE,cPIC1) + "      " +;
                                       transform(fIPI_VLR,cPIC1)  + "  "     +;
                                       transform(fIPI_ISEN,cPIC1) + "  "     +;
                                       transform(fIPI_OUT,cPIC1)
      else
         @ prow()+1,70 say "IPI" + transform(fIPI_BASE, cPIC1) + "     " +;
                                   transform(fIPI_VLR,  cPIC1)           +;
                                   transform(fIPI_ISEN, cPIC1)           +;
                                   transform(fIPI_OUT,  cPIC1)
      endif
   endif

   if prow() > K_MAX_LIN

      qpageprn()

      // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA_____________________________

      if nFOLHA <> 0
         XPAGINA = nFOLHA
         nFOLHA  = 0
      endif

      i_cabecalho(cTITULO,150)
      i_cabec()

   endif

   if val(left(CONFIG->Anomes,4)) >= 1996       // Legislacao apartir do ano 1996

      i_resumo()

      for nCONTX := 1 to len(aRESUMO_UF)

          if prow() > K_MAX_LIN

             qpageprn()

             // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA______________________

             if nFOLHA <> 0
                XPAGINA = nFOLHA
                nFOLHA  = 0
             endif

             i_cabecalho(cTITULO,150)
             i_cabec()
             i_resumo()

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

function i_cabecalho

   parameters cTITULO
   local dINI_PERIODO, dFIM_PERIODO

   // SE NAO ESTIVER DENTRO DO MES, ALTERA A DATA DO CABECALHO ___________________

   if month(dDATA_INI) <> month(dDATA_FIM)
      dINI_PERIODO := ctod("01/" + str(nMES,2) + "/" + left(XANOMES,4))
      dFIM_PERIODO := qfimmes(ctod("01/" + str(nMES,2) + "/" + left(XANOMES,4)))
   endif

   @ prow()+1,062 say cTITULO + space(54) + "Folha...:" + strzero(XPAGINA,4)

   if val(left(CONFIG->Anomes,4)) = 1995

      @ prow()+2,116 say "| 1- Operacoes com Credito do Imposto.   |"
      @ prow()+1,116 say "| 2- Oper. sem Credito do Imposto-Isentas|"
//    @ prow()+1,002 say "Empresa...: "+ FILIAL->Razao
      @ prow()  ,090 say "(*) Codigo de             | 3- Oper. sem Credito do Imposto-Outras.|"
      @ prow()+1,002 say "Insc. Est.: "+ transform(val(alltrim(qtiraponto(FILIAL->INSC_ESTAD))),"@R 99.99999-99") + " CNPJ    :" + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99")
      @ prow()  ,090 say "Valores Fiscais ========> | 4- Oper. com deferimento               |"

      if month(dDATA_INI) <> month(dDATA_FIM)
         @ prow()+1,002 say "Mes ou Periodo/Ano: De " + dtoc(dINI_PERIODO) + " ate " + dtoc(dFIM_PERIODO)
      else
         @ prow()+1,002 say "Mes ou Periodo/Ano: De " + dtoc(dDATA_INI) + " ate " + dtoc(dDATA_FIM)
      endif

      @ prow()  ,116 say "| 5- Outras com substituicao tributaria  |"
      @ prow()+1,116 say "| 7- Cigarros                            |"

   else                                     // Mudanca na legislacao apartir do ano 1996

      @ prow()+2,104 say "| 0- Tributada Integralmente                         |"
      @ prow()+1,104 say "| 1- Tributada e com Cobranca do ICMS por Sub. Trib. |"
      @ prow()+1,002 say "Empresa...: "+ XRAZAO      // FILIAL->Razao
      @ prow()  ,078 say "(*) Codigo de             | 2- Com Reducao de Base de Calculo                  |"
      @ prow()+1,002 say "Insc. Est.: "+ transform(alltrim(qtiraponto(FILIAL->INSC_ESTAD)),"@R 999.99999-99") + " CNPJ    :" + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99")
      @ prow()  ,078 say "Valores Fiscais ========> | 3- Isenta/nao Trib. e com Cobr. ICMS por Sub. Trib.|"

      if month(dDATA_INI) <> month(dDATA_FIM)
         @ prow()+1,002 say "Mes ou Periodo/Ano: De " + dtoc(dINI_PERIODO) + " ate " + dtoc(dFIM_PERIODO)
      else
         @ prow()+1,002 say "Mes ou Periodo/Ano: De " + dtoc(dDATA_INI) + " ate " + dtoc(dDATA_FIM)
      endif

      @ prow()  ,104 say "| 4- Isenta ou nao Tributada                         |"
      @ prow()+1,104 say "| 5- Com Suspencao ou Diferimento                    |"
      @ prow()+1,104 say "| 6- ICMS Cobrado Anteriormente por Substituicao Trib|"
      @ prow()+1,104 say "| 7- Com Red. de Base de Calc. e Cobr. ICMS Sub. Trib|"
      @ prow()+1,104 say "| 9- Outras                                          |"

   endif

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO PARA OS LIVROS DE ENTRADA E SAIDA DE NOTAS FISCAIS __________________

static function i_cabec

   @ prow()+1,2 say replicate("_",157)
   @ prow()+1,2 say "  |             DOCUMENTOS FISCAIS             |              |  CODIGO  |                   VALORES FISCAIS                             |"
   @ prow()+1,2 say "DT|____________________________________________|  VALOR       |________ *|_______________________________________________________________|"
   @ prow()+1,2 say "  |     |SERIE|  NOTA   |DATA DO |    |  |     |              |   |ICMS|C|              |   |   IMPOSTO    |              |              | OBSERVACAO"
   @ prow()+1,2 say "EN|ESPEC|SUB- |         |        |    |UF| CONT|  CONTABIL    |FIS|IPI |O| BASE DE CALC.|AL |   CREDITADO  |   ISENTAS    |    OUTRAS    |"
   @ prow()+1,2 say "TR|     |SERIE| FISCAL  |  DOC.  |EMIT|  |     |              |CAL|    |D| VLR OPERACAO |IQ |              |              |              |"
   @ prow()+1,2 say replicate("_",157)

return

//////////////////////////////////////////////////////////////////////////////////
// DESCRICAO DA ESPECIE PARA EMISSAO DOS LIVROS __________________________________

//    function i_especie ( fESPECIE )
//
//       do case
//          case fESPECIE = "1"  ; return "N.F. "
//          case fESPECIE = "2"  ; return "Luz  "
//          case fESPECIE = "3"  ; return "Telef"
//          case fESPECIE = "4"  ; return "Telex"
//          case fESPECIE = "5"  ; return "Conh."
//          case fESPECIE = "6"  ; return "CMR  "
//          case fESPECIE = "7"  ; return "N.F  "
//          case fESPECIE = "8"  ; return "CMR  "
//          case fESPECIE = "10" ; return "N.F.F"
//       endcase
//
//    return ""

//////////////////////////////////////////////////////////////////////////////////
// DESCRICAO DA SERIE PARA EMISSAO DOS LIVROS ____________________________________

function i_serie ( fSERIE )

   if SERIE->(dbseek(fSERIE))
      return (substr(SERIE->DESCRICAO,1,5))
   endif

return ""

//////////////////////////////////////////////////////////////////////////////////
// DESCRICAO DA SERIE PARA EMISSAO DOS LIVROS ____________________________________

function i_especie ( fESPECIE )

   if ESPECIE->(dbseek(fESPECIE))
      return (substr(ESPECIE->DESCRICAO,1,5))
   endif

return ""

//////////////////////////////////////////////////////////////////////////////////
// GRAVA O NUMERO DA PAGINA DOS LIVROS E DAS APURACOES ___________________________

function i_grava_pagina

   CONFIG->(qrlock())

   do case
      case XPROG = "510"
           replace CONFIG->PAGINA_ENT with strzero(XPAGINA:=XPAGINA+1,4)
      case XPROG = "520"
           replace CONFIG->PAGINA_SAI with strzero(XPAGINA:=XPAGINA+1,4)
      case XPROG = "511"
           replace CONFIG->ICM_AP_ENT with strzero(XPAGINA:=XPAGINA+1,4)
      case XPROG = "512"
           replace CONFIG->IPI_AP_ENT with strzero(XPAGINA:=XPAGINA+1,4)
      case XPROG = "521"
           replace CONFIG->ICM_AP_SAI with strzero(XPAGINA:=XPAGINA+1,4)
      case XPROG = "522"
           replace CONFIG->IPI_AP_SAI with strzero(XPAGINA:=XPAGINA+1,4)
      case XPROG = "530"
           replace CONFIG->PAGINA_ISS with strzero(XPAGINA:=XPAGINA+1,4)
   endcase

   CONFIG->(qunlock())

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO DO RESUMO ___________________________________________________________

static function i_resumo

   @ prow()+2,11 say "RESUMO DAS ENTRADAS CONFORME ART. 235 PARAGRAFO 7. RICMS/PR"
   @ prow()+1,02 say "UF    Valor Contabil    B.C. do Icms  B.C do Icms Sub.     Outras     Valor ICMS Substituicao"
   @ prow()+1,02 say replicate("_",93)

return

