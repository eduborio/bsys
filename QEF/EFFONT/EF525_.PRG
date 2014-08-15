//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: APURACAO SAIDAS ICMS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........: ATUALIZA CREDITOS DO IMPOSTO (TOT_CRED)
// ALTERACOES.:
function ef525

#define K_MAX_LIN 55

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS _______________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private cFILIAL                            // Filial
private sBLOC1 := qlbloc("B521A","QBLOC.GLO") // Periodo de impressao
private sBLOC2 := qlbloc("B521B","QBLOC.GLO") // Tipo de periodo
private sBLOC3 := qlbloc("B521C","QBLOC.GLO") // Confirma gravacao de pagina
private sBLOC4 := qlbloc("B521D","QBLOC.GLO") // Tipo de gia
private cTP_GIA := "1"              // Normal / Sub. Tributaria

private cGRAVA_PAGINA                      // Para confirmar se grava pagana no config.dbf

private cPIC1  := "@E 99,999,999.99"

private lCABECALHO := .T.            // imprime cabecalho caso nao tenha notas
private lMUDOU_MES := .F.            // Verifica se mudou mes, para totalizar e novo cabecalho
private cTITULO                      // titulo do relatorio
private bENT_FILTRO                  // code block de filtro entradas
private bENT1_FILTRO                // code block de filtro entrada
private bSAI_FILTRO                  // code block de filtro saidas

private bSAI1_FILTRO                  // code block de filtro saidas
private bISS1_FILTRO                  // code block de filtro saidas
private bFILTRO                  // code block de filtro saidas

private cTIPOPER                     // tipo de periodo

private aEDICAO    := {}             // vetor para os campos de entrada de dados

private nMES                         // Mes da apuracao
private nFOLHA                       // Numero da folha
private nFALTA                       // Numero de meses que faltam para imprimir cabecalho em branco
private fCOD_FISC                    // Codigo fiscal natureza de operacao
private fCFOP                        // Codigo fiscal natureza de operacao
private fVLR_CONT                    // total valor contabil por natureza de operacao
private fICM_BASE                    // total base de icms por natureza de operacao
private fICM_VLR                     // total imposto creditado por natureza de operacao
private fICM_ISEN                    // total isentos icms por natureza de operacao
private fICM_OUT                     // total outras icms por natureza de operacao
private fTOT_CONT                    // total geral valor contabil
private fTOT_BASE                    // total geral base de icms
private fTOT_DEB                     // total geral imposto debitado
private fTOT_CRED                    // total geral imposto creditado
private fTOT_ISEN                    // total geral isentos icms
private fTOT_OUT                     // total geral outras icms
private fDEBITOS                     // total de debitos com outros e estornos
private fCREDITOS                    // total de creditos com outros e estornos
private fICM_TRANSP                  // saldo credor anterior de icms

private fICM_SUBST                   // total geral da subst. trib
private fICM_BC_S                    // total geral da base de sub.trib.

private fTOT_SUBST                   // total geral da subst. trib
private fTOT_BC_S                    // total geral da base de sub.trib.

private fICM_SUBS                    // valor da substituicao tributaria
private fICM_B_SUBS                  // base da substituicao tributaria

private dDATA_INI                    // Inicio do periodo do relatorio
private dDATA_FIM                    // Fim do periodo do relatorio
private dDATA_INI_A                  // Inicio do periodo do relatorio anual
private dDATA_FIM_A                  // Fim do periodo do relatorio anual

private nSAIDA
private nSAIDA1

private nENTRADA
private nENTRADA1

private nSERVICO1
private nCAMPO_06

private dDATA1_INI                    // Data inicial do ICMS dentro do ano
private dDATA1_FIM                    // Data final do ICMS ate  o mes corrente
   
private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
private nALIQ_SPL

//private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0}}

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

   qlbloc(5,0,"B521A","QBLOC.GLO",1)
   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL ,"9999"         ) } ,"FILIAL"   })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL        }) // descricao do filial
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!"     ,NIL,NIL) } ,"DATA_INI" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!"     ,NIL,NIL) } ,"DATA_FIM" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nFOLHA      ,"@E 9999",NIL,NIL) } ,"FOLHA"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOPER,sBLOC2                 )}, "TIPOPER" })
   aadd(aEDICAO,{{ || qesco(-1,0,@cGRAVA_PAGINA,sBLOC3            )},"GRAVA_PAG"})
   if XTIPOEMP $ "25"
      aadd(aEDICAO,{{ || qesco(-1,0,@cTP_GIA ,sBLOC4              )},"TP_GIA"   })
   Else
      aadd(aEDICAO,{{ || NIL                                       },NIL        }) // descricao do filial
   endif

do while .T.

   XNIVEL      := 1
   XFLAG       := .T.
   cFILIAL    := "    "
   cTIPOPER    := " "
   fVLR_CONT   := 0
   fICM_BASE   := 0
   fICM_VLR    := 0
   fICM_ISEN   := 0
   fICM_OUT    := 0
   fTOT_CONT   := 0
   fTOT_BASE   := 0
   fTOT_DEB    := 0
   fTOT_CRED   := 0
   fTOT_ISEN   := 0
   fTOT_OUT    := 0
   fICM_TOTAL  := 0
   fICM_TRANSP := 0
   fDEBITOS    := 0
   fCREDITOS   := 0
   fICM_SUBST:= 0
   fICM_BC_S := 0
   fTOT_SUBST:= 0
   fTOT_BC_S := 0
   fICM_SUBS   := 0
   fICM_B_SUBS := 0

   nFALTA      := 0     // MESES QUE FALTAM PARA IMPRIMIR CABECALHO
/////  Alteracoes feitas por Eduardo em 18/02/2005
   //nFOLHA      := val(XICM_AP_SAI)

   nFOLHA      := 1
   XPAGINA     := 0
   lCABECALHO := .T.
//////

   dDATA_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM   := qfimmes(dDATA_INI)
   dDATA_INI_A := ctod("01/01/" + left(XANOMES,4))
   dDATA_FIM_A := ctod("31/12/" + left(XANOMES,4))
   cGRAVA_PAGINA := "1"

   nSAIDA      := 0
   nSAIDA1     := 0

   nENTRADA    := 0
   nENTRADA1   := 0

   nSERVICO1   := 0
   nCAMPO_06   := 0
   nVAL_ICMS   := 0
   nALIQ_SPL     := 0
   nBASE_CALCULO := 0

   dDATA1_INI  := ctod("01/01/" + left(XANOMES,4))
   dDATA1_FIM  := qfimmes(ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4)))

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

      case cCAMPO == "TIPOPER"
           if empty(cTIPOPER) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOPER,"12",{"Per¡odo","Anual"}))
           if cTIPOPER == "2"
              qrsay (XNIVEL+1,dDATA_INI_A)
              qrsay (XNIVEL+2,dDATA_FIM_A)
              dDATA_INI := dDATA_INI_A
              dDATA_FIM := dDATA_FIM_A
              nMES := val(str(month(dDATA_INI_A),2))
              XNIVEL+=2
           endif
      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)
           nMES := val(str(month(dDATA_INI),2))
      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif
      case cCAMPO == "GRAVA_PAG"
           if empty(cGRAVA_PAGINA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cGRAVA_PAGINA,"12",{"Sim","N„o"}))
      case cCAMPO == "TP_GIA"
           if empty(cTP_GIA); return .F.; endif
           qrsay(XNIVEL,qabrev(cTP_GIA,"12",{"Normal","Sub. Trib."}))
   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ________________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ___________________________________________________

   if cTIPOPER == "1"
      cTITULO := "APURACAO DE SAIDAS - ICMS "
   else
      cTITULO := "APURACAO DE SAIDAS - ICMS - ANUAL"
   endif

   qmensa("")

   // CRIA MACRO DE FILTRO _______________________________________________________

   bENT_FILTRO := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }

   ENT->(dbSetFilter({|| alltrim(Filial) $ cFILIAL}, 'alltrim(Filial) $ cFILIAL'))
   SAI->(dbSetFilter({|| alltrim(Filial) $ cFILIAL}, 'alltrim(Filial) $ cFILIAL'))

   bENT1_FILTRO := { || ENT->DATA_LANC >= dDATA1_INI .and. ENT->DATA_LANC <= dDATA1_FIM }
   bSAI1_FILTRO := { || SAI->DATA_LANC >= dDATA1_INI .and. SAI->DATA_LANC <= dDATA1_FIM }
   bISS1_FILTRO := { || ISS->DATA_LANC >= dDATA1_INI .and. ISS->DATA_LANC <= dDATA1_FIM }

   // VERIFICA SE E MAQUINA REGISTRADORA _________________________________________

   if XTIPOEMP $ "38"

      // VERIFICA SE EXISTE BASE GRAVADA NO ARQUIVO DE SAIDAS ____________________

      if !SAI->(dbseek("@@" + left(XANOMES,2) + right(XANOMES,4)))
         qmensa("B.C.Ajustada n„o encontrada nas sa¡das ! Utilize Op‡„o <509>","B")
         return .F.
      endif

   endif

   // ESTABELECE RELACOES ENTRE ARQUIVOS _________________________________________

   select OUTENT
   OUTENT->(dbgotop())

   select OUTSAI
   OUTSAI->(dbgotop())

   select IMP
   IMP->(dbgotop())

   select ENT
   ENT->(dbsetorder(3))                     // Mes do lancamento + Codigos Fiscais
   ENT->(dbgotop())

   if cTIPOPER == "1"
      select SAI
      if val(left(CONFIG->Anomes,4)) < 2003
         SAI->(dbsetorder(3))                  // Mes do lancamento + Codigos Fiscais
         SAI->(dbgotop())
      else
         SAI->(dbsetfilter({||alltrim(SAI->Filial)$cFILIAL.and.SAI->Data_Lanc >= dDATA_INI .and. SAI->Data_Lanc <= dDATA_FIM},'alltrim(SAI->Filial)$cFILIAL.and.SAI->Data_Lanc >= dDATA_INI .and. SAI->Data_Lanc <= dDATA_FIM'))
         SAI->(dbsetorder(8))                  // Mes do lancamento + Codigos Fiscais
         SAI->(dbgotop())
      endif
   else
      select SAI
      if val(left(CONFIG->Anomes,4)) < 2003
         SAI->(dbsetorder(5))                  // Mes do lancamento + Codigos Fiscais
         SAI->(dbgotop())
      else
         SAI->(dbsetfilter({||alltrim(SAI->Filial)$cFILIAL.and.SAI->Data_Lanc >= dDATA_INI .and. SAI->Data_Lanc <= dDATA_FIM},'alltrim(SAI->Filial)$cFILIAL.and.SAI->Data_Lanc >= dDATA_INI .and. SAI->Data_Lanc <= dDATA_FIM'))
         SAI->(dbsetorder(9))                  // Mes do lancamento + Codigos Fiscais
         SAI->(dbgotop())
      endif

   endif

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _______________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND2

   do while ! SAI->(eof())                           // condicao principal de loop

      if XPAGINA == 0 .or. prow() > K_MAX_LIN

         qpageprn()

         // CASO IMPRIMA ALGUMA NOTA, NAO IMPRIME CABECALHO FORA DESTE LOOP_______

         lCABECALHO := .F.

         // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

         if nFOLHA <> 0
            XPAGINA = nFOLHA
            nFOLHA  = 0
         endif

         i_icm_apuracao(cTITULO,"SAI",nMES)

      endif

      fCod_fisc := SAI->COD_FISC
      fCFOP     := SAI->Cfop
      // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________
      if val(left(CONFIG->Anomes,4)) < 2003
         do while fCOD_FISC = SAI->COD_FISC

            qgirabarra()

            if eval(bSAI_FILTRO)

               qgirabarra()

               if cTIPOPER == "1"
                  if nMES <> val(str(month(SAI->DATA_LANC),2))
                     lMUDOU_MES := .T.
                     exit
                  endif

                  if !lMUDOU_MES
                     qmensa("Imprimindo Codigo Fiscal: "+SAI->Cod_Fisc)

                     fVLR_CONT += SAI->VLR_CONT
                     if XTIPOEMP $ "38"
                        if left(SAI->Num_Nf,2) = "@@"
                           if cTP_GIA == "1"
                              fICM_BASE += SAI->ICM_BASE
                           else
                              fICM_BASE += SAI->ICM_BC_S
                           endif
                        endif
                     else
                        if cTP_GIA == "1"
                           fICM_BASE += SAI->ICM_BASE
                        else
                           fICM_BASE += SAI->ICM_BC_S
                        endif
                     endif

                     if XTIPOEMP $ "25" // soma substituicao tributaria
                        fICM_SUBS   += SAI->Icm_subst
                        fICM_B_SUBS += SAI->Icm_bc_s
                     endif

                     fICM_VLR += round(SAI->ICM_VLR,2)
                     fICM_ISEN += SAI->ICM_ISEN
                     fICM_OUT  += SAI->ICM_OUT
                     if cTP_GIA == "2"
                        fICM_SUBST += SAI->Icm_subst
                        fICM_BC_S  += SAI->Icm_bc_s
                     endif

                     if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->FILIAL))
                        for nCONT := 1 to 5
                             qgirabarra()
                             aOUTALIQ[nCONT,1] := OUTSAI->ICM_BASE
                             aOUTALIQ[nCONT,2] := OUTSAI->ICM_ALIQ
                             aOUTALIQ[nCONT,3] := OUTSAI->ICM_VLR
                             fICM_BASE += OUTSAI->ICM_BASE
                             fICM_VLR  += OUTSAI->ICM_VLR
                             OUTSAI->(dbskip())
                             if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                                exit
                             endif
                        next
                     endif
                  endif
               else
                  qmensa("Imprimindo Codigo Fiscal: "+SAI->Cod_Fisc)

                  fVLR_CONT += SAI->VLR_CONT

                  if XTIPOEMP $ "38"
                     if left(SAI->Num_Nf,2) = "@@"
                        if cTP_GIA == "1"
                           fICM_BASE += SAI->ICM_BASE
                        else
                           fICM_BASE += SAI->ICM_BC_S
                        endif
                     endif
                  else
                     if cTP_GIA == "1"
                        fICM_BASE += SAI->ICM_BASE
                     else
                        fICM_BASE += SAI->ICM_BC_S
                     endif
                  endif

                  if XTIPOEMP $ "25" // soma substituicao tributaria
                     fICM_SUBS   += SAI->Icm_subst
                     fICM_B_SUBS += SAI->Icm_bc_s
                  endif

                  fICM_VLR += round(SAI->ICM_VLR,2)
                  fICM_ISEN += SAI->ICM_ISEN
                  fICM_OUT  += SAI->ICM_OUT

                  if cTP_GIA == "2"
                     fICM_SUBST += SAI->Icm_subst
                     fICM_BC_S  += SAI->Icm_bc_s
                  endif

                  if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->Filial))
                     for nCONT := 1 to 5
                          qgirabarra()
                          aOUTALIQ[nCONT,1] := OUTSAI->ICM_BASE
                          aOUTALIQ[nCONT,2] := OUTSAI->ICM_ALIQ
                          aOUTALIQ[nCONT,3] := OUTSAI->ICM_VLR
                          fICM_BASE += OUTSAI->ICM_BASE
                          fICM_VLR  += OUTSAI->ICM_VLR
                          OUTSAI->(dbskip())
                          if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                             exit
                          endif
                     next
                  endif

               endif

            endif

            SAI->(dbskip())

         enddo
      else
         do while fCFOP = SAI->CFOP

            qgirabarra()

            if eval(bSAI_FILTRO)

               qgirabarra()

               if cTIPOPER == "1"
                  if nMES <> val(str(month(SAI->DATA_LANC),2))
                     lMUDOU_MES := .T.
                     exit
                  endif

                  if !lMUDOU_MES
                     qmensa("Imprimindo Codigo Fiscal: "+SAI->Cfop)

                     fVLR_CONT += SAI->VLR_CONT
                     if XTIPOEMP $ "38"
                        if left(SAI->Num_Nf,2) = "@@"
                           if cTP_GIA == "1"
                              fICM_BASE += SAI->ICM_BASE
                           else
                              fICM_BASE += SAI->ICM_BC_S
                           endif
                        endif
                     else
                        if cTP_GIA == "1"
                           fICM_BASE += SAI->ICM_BASE
                        else
                           fICM_BASE += SAI->ICM_BC_S
                        endif
                     endif

                     if XTIPOEMP $ "25" // soma substituicao tributaria
                        fICM_SUBS   += SAI->Icm_subst
                        fICM_B_SUBS += SAI->Icm_bc_s
                     endif

                     fICM_VLR += round(SAI->ICM_VLR,2)
                     fICM_ISEN += SAI->ICM_ISEN
                     fICM_OUT  += SAI->ICM_OUT
                     if cTP_GIA == "2"
                        fICM_SUBST += SAI->Icm_subst
                        fICM_BC_S  += SAI->Icm_bc_s
                     endif

                     if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->FILIAL))
                        for nCONT := 1 to 5
                             qgirabarra()
                             aOUTALIQ[nCONT,1] := OUTSAI->ICM_BASE
                             aOUTALIQ[nCONT,2] := OUTSAI->ICM_ALIQ
                             aOUTALIQ[nCONT,3] := OUTSAI->ICM_VLR
                             fICM_BASE += OUTSAI->ICM_BASE
                             fICM_VLR  += OUTSAI->ICM_VLR
                             OUTSAI->(dbskip())
                             if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                                exit
                             endif
                        next
                     endif
                  endif
               else
                  qmensa("Imprimindo Codigo Fiscal: "+SAI->Cfop)

                  fVLR_CONT += SAI->VLR_CONT

                  if XTIPOEMP $ "38"
                     if left(SAI->Num_Nf,2) = "@@"
                        if cTP_GIA == "1"
                           fICM_BASE += SAI->ICM_BASE
                        else
                           fICM_BASE += SAI->ICM_BC_S
                        endif
                     endif
                  else
                     if cTP_GIA == "1"
                        fICM_BASE += SAI->ICM_BASE
                     else
                        fICM_BASE += SAI->ICM_BC_S
                     endif
                  endif

                  if XTIPOEMP $ "25" // soma substituicao tributaria
                     fICM_SUBS   += SAI->Icm_subst
                     fICM_B_SUBS += SAI->Icm_bc_s
                  endif

                  fICM_VLR += round(SAI->ICM_VLR,2)
                  fICM_ISEN += SAI->ICM_ISEN
                  fICM_OUT  += SAI->ICM_OUT

                  if cTP_GIA == "2"
                     fICM_SUBST += SAI->Icm_subst
                     fICM_BC_S  += SAI->Icm_bc_s
                  endif

                  if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->Filial))
                     for nCONT := 1 to 5
                          qgirabarra()
                          aOUTALIQ[nCONT,1] := OUTSAI->ICM_BASE
                          aOUTALIQ[nCONT,2] := OUTSAI->ICM_ALIQ
                          aOUTALIQ[nCONT,3] := OUTSAI->ICM_VLR
                          fICM_BASE += OUTSAI->ICM_BASE
                          fICM_VLR  += OUTSAI->ICM_VLR
                          OUTSAI->(dbskip())
                          if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                             exit
                          endif
                     next
                  endif

               endif

            endif

            SAI->(dbskip())

         enddo

      endif
      if val(left(CONFIG->Anomes,4)) < 2003
         if fVLR_CONT > 0 //.and. cTIPOPER == "1"
            if fVLR_CONT > 0
               @ prow()+2,4 say fCod_fisc + space(22) + transform(fVLR_CONT,cPIC1) + space(11) + transform(fICM_BASE,cPIC1) +;
                                            space(11) + transform(fICM_VLR,cPIC1 ) + space(11) + transform(fICM_ISEN,cPIC1) +;
                                            space(11) + transform(fICM_OUT,cPIC1 )  //+ space(2)  + "B.C. ST: "+transform(fICM_B_SUBS,cPIC1)
      //       @ prow()+1,140 say "ICMS ST: "+transform(fICM_SUBS,cPIC1)
            else
               @ prow()+2,4 say fCod_fisc + space(22) + transform(fVLR_CONT,cPIC1) + space(11) + transform(fICM_BC_S,cPIC1) +;
                                            space(11) + transform(fICM_SUBST,cPIC1 ) + space(11) + transform(fICM_ISEN,cPIC1) +;
                                            space(11) + transform(fICM_OUT,cPIC1 )
            endif
         Endif
      else
         if fVLR_CONT > 0 //.and. cTIPOPER == "1"
            if fVLR_CONT > 0
               @ prow()+2,4 say fCfop + space(21) + transform(fVLR_CONT,cPIC1) + space(11) + transform(fICM_BASE,cPIC1) +;
                                            space(11) + transform(fICM_VLR,cPIC1 ) + space(11) + transform(fICM_ISEN,cPIC1) +;
                                            space(11) + transform(fICM_OUT,cPIC1 )  //+ space(2)  + "B.C. ST: "+transform(fICM_B_SUBS,cPIC1)
      //       @ prow()+1,140 say "ICMS ST: "+transform(fICM_SUBS,cPIC1)
            else
               @ prow()+2,4 say fCfop + space(21) + transform(fVLR_CONT,cPIC1) + space(11) + transform(fICM_BC_S,cPIC1) +;
                                            space(11) + transform(fICM_SUBST,cPIC1 ) + space(11) + transform(fICM_ISEN,cPIC1) +;
                                            space(11) + transform(fICM_OUT,cPIC1 )
            endif
         Endif

      endif
      // ACUMULA TOTAL GERAL E SUB-TOTAIS  _______________________________________

      if cTP_GIA == "1"
         fTOT_CONT += fVLR_CONT
         fTOT_BASE += fICM_BASE
         fTOT_DEB  += fICM_VLR
         fTOT_ISEN += fICM_ISEN
         fTOT_OUT  += fICM_OUT
      else
         fTOT_SUBST += fICM_SUBST
         fTOT_BC_S  += fICM_BC_S
         fTOT_DEB  += fICM_SUBST
      endif

      if fVLR_CONT > 0 .and. cTIPOPER == "1"
         if cTP_GIA == "1"
            @ prow()+1,4 say "Sub-Total.:" + space(14) + transform(fVLR_CONT,cPIC1) + space(11) + transform(fICM_BASE,cPIC1)  +;
                                             space(11) + transform(fICM_VLR,cPIC1)  + space(11) + transform(fICM_ISEN,cPIC1) +;
                                             space(11) + transform(fICM_OUT,cPIC1)
         else
            @ prow()+1,4 say "Sub-Total.:" + space(14) + transform(fVLR_CONT,cPIC1) + space(11) + transform(fICM_BC_S,cPIC1)  +;
                                             space(11) + transform(fICM_SUBST,cPIC1)  + space(11) + transform(fICM_ISEN,cPIC1) +;
                                             space(11) + transform(fICM_OUT,cPIC1)
         endif
      endif

      fVLR_CONT := 0
      fICM_BASE := 0
      fICM_VLR  := 0
      fICM_ISEN := 0
      fICM_OUT  := 0

      if cTP_GIA == "2"
         fICM_SUBST := 0
         fICM_BC_S  := 0
      endif

      if lMUDOU_MES .or. SAI->(eof()) .and. cTIPOPER == "1"

         // BUSCA O CREDITO, IMPRIME O TOTAL, O CABECALHO, GRAVA VALORES ___

         i_busca_credito()
         i_sai_icm_grava()
         i_tot_periodo()

         nMES++

         // PARA IMPRESSAO DO CABECALHO ____________________________________

         setprc(56,00)
         if ! qlineprn() ; return ; endif
         lMUDOU_MES := .F.
         loop

      endif

      if SAI->(eof()) .and. cTIPOPER == "2"

         @ prow()+1,4 say replicate("_",135)
         if cTP_GIA == "1"
            @ prow()+1,4 say "Total Geral..:" + space(11) + transform(fTOT_CONT,cPIC1) + space(11) + transform(fTOT_BASE,cPIC1) +;
                                                space(11) + transform(fTOT_DEB,cPIC1)  + space(11) + transform(fTOT_ISEN,cPIC1) +;
                                                space(11) + transform(fTOT_OUT,cPIC1)
         else
            @ prow()+1,4 say "Total Geral..:" + space(11) + transform(fTOT_CONT,cPIC1) + space(11) + transform(fTOT_BC_S,cPIC1) +;
                                                space(11) + transform(fTOT_SUBST,cPIC1)  + space(11) + transform(fTOT_ISEN,cPIC1) +;
                                                space(11) + transform(fTOT_OUT,cPIC1)
         Endif

         fTOT_CONT := 0
         fTOT_BASE := 0
         fTOT_DEB  := 0
         fTOT_ISEN := 0
         fTOT_OUT  := 0
         fTOT_OUT  := 0
         fTOT_SUBST := 0

      endif

   enddo

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
      do while nFALTA > 0 .and. cTIPOPER == "1"
         // BUSCA O DEBITO, IMPRIME O TOTAL, O CABECALHO, GRAVA VALORES __________
         qpageprn()
         if lCABECALHO
            XPAGINA := nFOLHA
            lCABECALHO := .F.
         endif
         i_icm_apuracao(cTITULO,"SAI",nMES)
         i_busca_credito()
         i_sai_icm_grava()
         i_tot_periodo()
         setprc(56,00)
         nFALTA--
         nMES++
      enddo
   endif

   if cGRAVA_PAGINA == "1"
      i_grava_pagina()
   endif
//   i_grava_pagina()           // PROGRAMA EF510.PRG

   qstopprn()

return

//////////////////////////////////////////////////////////////////////////////////
// GRAVA OS VALORES REFERENTES AO ICMS PARA EMISSAO DA GIA OU GIAR _______________
static function i_sai_icm_grava()
   local dINICIO, dTERMINO

   dINICIO    := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
   dTERMINO   := qfimmes(ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4)))
   fULT_CALC  := dtos(date()) + "-" + time()
   fAPURADO_S := .T.
   nREC_SAI   := SAI->(recno())

   nSAIDA      := 0
   nSAIDA1     := 0

   nSERVICO1   := 0
   nCAMPO_06   := 0

   nVAL_ICMS   := 0
   nBASE_CALCULO := 0

   SAI->(dbgotop())


   do while ! SAI->(eof())   // condicao principal de loop
      if val(left(CONFIG->Anomes,4)) < 2003

         if eval(bSAI_FILTRO)
            if SAI->Cod_fisc $ "511-512-513-514-515-516-517-611-612-613-614-615-616-617-618-619-711-712-716-717" .and. SAI->Icm_cod <> "1"
               if cTP_GIA == "1"
                  nSAIDA := nSAIDA + SAI->Vlr_cont // mudei dia 06/03/98
         //       nSAIDA := nSAIDA + SAI->Icm_base
               else
                  nSAIDA := nSAIDA + SAI->Icm_bc_s
               endif
            endif
         endif

         if eval(bSAI1_FILTRO)
            qmensa("Sa¡da: Somando Nota "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 5.1X 5.6X 6.1X 6.6X 7.1X
            if cTP_GIA == "1"
               if SAI->Cod_fisc $ "596*696"  .and. SAI->Icm_cod <> "1"
                  nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
               endif
               if left(SAI->COD_FISC,2) $ "51*61"  .and. SAI->Icm_cod <> "1"
                  nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
               endif
            else
               if SAI->Cod_fisc $ "596*696"  .and. SAI->Icm_cod <> "1"
                  nSAIDA1 += SAI->ICM_BC_S
               endif
               if left(SAI->COD_FISC,2) $ "51*61"  .and. SAI->Icm_cod <> "1"
                  nSAIDA1 += SAI->ICM_BC_S
               endif
            endif
         endif
      else
         if eval(bSAI_FILTRO)
            if SAI->Cfop $ "5101-5102-5103-5104-5105-5106-5109-5110-5111-5112-5113-5114-5115-5116-5117-5118-5119-5120-5122-5123-6101-6102-6103-6104-6105-6106-6107-6108-6109-6110-6111-6112-6113-6114-6115-6116-6117-6118-6119-6120-6122-6123" .and. SAI->Icm_cod <> "1"
               if cTP_GIA == "1"
                  nSAIDA := nSAIDA + SAI->Vlr_cont // mudei dia 06/03/98
         //       nSAIDA := nSAIDA + SAI->Icm_base
               else
                  nSAIDA := nSAIDA + SAI->Icm_bc_s
               endif
            endif
         endif

         if eval(bSAI1_FILTRO)
            qmensa("Sa¡da: Somando Nota "+SAI->Num_Nf +" / Serie : "+SAI->Serie)
            // SOMA VALOR CONTABIL DOS CODIGOS FISCAIS 5.1X 5.6X 6.1X 6.6X 7.1X
            if cTP_GIA == "1"
               if SAI->Cfop $ "5904*5923*5924*6904*6923*6924"  .and. SAI->Icm_cod <> "1"
                  nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
               endif
               if left(SAI->Cfop,2) $ "51*61"  .and. SAI->Icm_cod <> "1"
                  nSAIDA1 += SAI->VLR_CONT - SAI->Ipi_Vlr
               endif
            else
               if SAI->Cfop $ "5904*5923*5924*6904*6923*6924"  .and. SAI->Icm_cod <> "1"
                  nSAIDA1 += SAI->ICM_BC_S
               endif
               if left(SAI->COD_FISC,2) $ "51*61"  .and. SAI->Icm_cod <> "1"
                  nSAIDA1 += SAI->ICM_BC_S
               endif
            endif
         endif
      endif
      SAI->(dbskip())

   enddo

   SAI->(dbgoto(nREC_SAI))

   bFILTRO := { || ISS->DATA_LANC >= dDATA_INI .and. ISS->DATA_LANC <= qfimmes(dDATA_INI) }

   ISS->(dbgotop())
   do while ! ISS->(eof())
      qgirabarra()
      if eval(bFILTRO)
         nCAMPO_06 += ISS->Vlr_cont
      endif
      if eval(bISS1_FILTRO)
         qmensa("Servi‡os: Somando Nota "+ISS->Num_Nf +" / Serie : "+ISS->Serie)
         nSERVICO1 += ISS->VLR_CONT
      endif
      ISS->(dbskip())
   enddo

   nSAIDA1 := nSAIDA1 + nSERVICO1 - nENTRADA1         // ACUMULADOS DO ANO
   if val(CONFIG->Anomes) < 200301
       do case
          case CONFIG->Tipo_est == "A"
               do case
                  case nSAIDA1 >=  66858.74 .and. nSAIDA1 <= 160445.96
                       qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa B","B")
                       return

                  case nSAIDA1 >= 160445.96 .and. nSAIDA1 <= 962563.14
                       qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa C","B")
                       return

                  case nSAIDA1 >= 962563.14
                       qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa D","B")
                       return
               endcase

          case CONFIG->Tipo_est == "B"
               do case
                  case nSAIDA1 >= 160445.96 .and. nSAIDA1 <= 962563.14
                       qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa C","B")
                       return

                  case nSAIDA1 >= 962563.14
                       qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa D","B")
                       return
               endcase

               if CONFIG->Iss == "1"
                  nALIQ_SPL := 0.005
               else
                  nALIQ_SPL := 0.01
               endif

          case CONFIG->Tipo_est == "C"
               do case
                  case nSAIDA1 >= 962563.14
                       qmensa("Valor Acumulado: " + transform(nSAIDA1,"@E 999,999.99") + ", Mude na Op‡„o 802 p/ Faixa D","B")
                       return
               endcase

               if CONFIG->Iss == "1"
                  nALIQ_SPL := 0.02
               else
                  nALIQ_SPL := 0.025
               endif

       endcase
   endif

   nVAL_ICMS := ((nSAIDA+nCAMPO_06)-nENTRADA) * nALIQ_SPL

   if val(CONFIG->Anomes) >= 200301 .and. val(CONFIG->Anomes) <= 200512
      nBASE_CALCULO := nSAIDA-nENTRADA
      if nBASE_CALCULO <= 18000
         nVAL_ICMS := 0
         nALIQ_SPL := 0
      endif

      if nBASE_CALCULO >=18000.01  .and. nBASE_CALCULO <= 48000
         nVAL_ICMS := (nBASE_CALCULO * 0.02) - 360
         nALIQ_SPL := 0.02
      endif

      if nBASE_CALCULO >= 48000.01  .and. nBASE_CALCULO <= 120000
         nVAL_ICMS := (nBASE_CALCULO * 0.03) - 840
         nALIQ_SPL := 0.03
      endif

      if nBASE_CALCULO >= 120000.01
         nVAL_ICMS := (nBASE_CALCULO * 0.04) - 2040
         nALIQ_SPL := 0.04
      endif

   endif

   if val(CONFIG->Anomes) > 200512
      nBASE_CALCULO := nSAIDA-nENTRADA
      if nBASE_CALCULO <= 30000
         nVAL_ICMS := 0
         nALIQ_SPL := 0
      endif

      if nBASE_CALCULO >=30000.01  .and. nBASE_CALCULO <= 66000
         nVAL_ICMS := (nBASE_CALCULO * 0.02) - 600
         nALIQ_SPL := 0.02
      endif

      if nBASE_CALCULO >= 66000.01  .and. nBASE_CALCULO <= 166000
         nVAL_ICMS := (nBASE_CALCULO * 0.03) - 1260
         nALIQ_SPL := 0.03
      endif

      if nBASE_CALCULO >= 166000.01
         nVAL_ICMS := (nBASE_CALCULO * 0.04) - 2920
         nALIQ_SPL := 0.04
      endif

   endif

   //qinkey(0)
   if IMP->(dbseek(K_ICM + dtos(dINICIO) + dtos(dTERMINO) + alltrim(cFILIAL)))
      IMP->(qrlock())
      replace IMP->ICM_DEB   with iif(CONFIG->Tipo_est $ "D ",fTOT_DEB,nVAL_ICMS)           // total ICMS debitado
      replace IMP->ICM_CRED  with iif(CONFIG->Tipo_est $ "D ",fTOT_CRED,0)                  // total ICMS creditado
      replace IMP->Ult_calc  with fULT_CALC          // Data e a hora para verificar as ordens de gravacao
      replace IMP->Apurado_s with fAPURADO_S         // Grava valor verdadeiro por ter operado apuracao
      if CONFIG->Tipo_est $ "ABC"
         replace IMP->Val_base with (nSAIDA+nCAMPO_06-nENTRADA)  // Valor faturado no mes
         replace IMP->Aliq_spl with nALIQ_SPL           // Aliquota de regime simples
      else
         replace IMP->Val_base with 0  // Valor faturado no mes
         replace IMP->Aliq_spl with 0  // Aliquota de regime simples
      endif
      IMP->(qunlock())
   else
      IMP->(qappend())
      replace IMP->Codigo    with K_ICM
      replace IMP->DATA_INI  with dINICIO            // data inicial do mes do periodo final
      replace IMP->DATA_FIM  with dTERMINO           // data final do periodo
      replace IMP->ICM_DEB   with iif(CONFIG->Tipo_est $ "D ",fTOT_DEB,nVAL_ICMS)   // total ICMS debitado
      replace IMP->ICM_CRED  with iif(CONFIG->Tipo_est $ "D ",fTOT_CRED,0)          // total ICMS creditado
      replace IMP->Ult_calc  with fULT_CALC          // Data e a hora para verificar as ordens de gravacao
      replace IMP->Apurado_s with fAPURADO_S         // Grava valor verdadeiro por ter operado apuracao
      replace IMP->Filial    with cFILIAL            //Grava Filial
      if CONFIG->Tipo_est $ "ABC"
         replace IMP->Val_base with (nSAIDA+nCAMPO_06-nENTRADA)  // Valor faturado no mes
         replace IMP->Aliq_spl with nALIQ_SPL                    // Aliquota de regime simples
      else
         replace IMP->Val_base with 0  // Valor faturado no mes
         replace IMP->Aliq_spl with 0  // Aliquota de regime simples
      endif
      IMP->(qunlock())
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// BUSCA TOTAL DE CREDITO DO ICMS ________________________________________________

static function i_busca_credito

   local dINICIO, dTERMINO

   dINICIO  := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
   dTERMINO := qfimmes(ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4)))

   fTOT_CRED := 0

   // CRIA MACRO DE FITRO DAS ENTRADAS ___________________________________________

   ENT->(dbgotop())

   bENT_FILTRO := { || ENT->Data_Lanc >= dINICIO .and. ENT->Data_Lanc <= dTERMINO }

   // SOMA OS TOTAIS DOS CREDITOS_________________________________________________

   do while ! ENT->(eof())   // condicao principal de loop

      qgirabarra()

      if eval(bENT_FILTRO)

         if cTP_GIA == "1"
            fTOT_CRED += round(ENT->ICM_VLR,2)
         else
            fTOT_CRED += round(ENT->ICM_SUBST,2)
         endif

         if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
            for nCONT := 1 to 5
                qgirabarra()
                aOUTALIQ[nCONT,1] := OUTENT->ICM_BASE
                aOUTALIQ[nCONT,2] := OUTENT->ICM_ALIQ
                aOUTALIQ[nCONT,3] := OUTENT->ICM_VLR
                fTOT_CRED += OUTENT->ICM_VLR
                OUTENT->(dbskip())
                if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                   exit
                endif
            next
         endif

         // EXCLUSAO PARA ICMS (NORMAL) ____________________________________

         // COMENTARIO
         if val(left(CONFIG->Anomes,4)) < 2003
            if ENT->Cod_fisc $ "131-132-133-134-231-232-233-234-321-322-323-324"
               if cTP_GIA == "1"
                  nENTRADA := nENTRADA + ENT->Vlr_cont
               endif
            endif
         else
            if ENT->Cfop $ "1201-1202-1203-1204-2201-2202-2203-2204-3201-3202-3203-3204"
               if cTP_GIA == "1"
                  nENTRADA := nENTRADA + ENT->Vlr_cont
               endif
            endif

         endif
      endif

//    if eval(bENT1_FILTRO)
//       qmensa("Entrada: Somando Nota "+ENT->Num_Nf +" / Serie : "+ENT->Serie)
//       if ENT->Cod_fisc $ "131-132-133-134-231-232-233-234-321-322-323-324"
//          nENTRADA1 += ENT->VLR_CONT - ENT->Ipi_Vlr
//       endif
//    endif

      ENT->(dbskip())

   enddo

return
//////////////////////////////////////////////////////////////////////////////////
// IMPRIME O TOTAL DE CADA PERIODO _______________________________________________

static function i_tot_periodo

   fULT_CALC  := dtos(date()) + "-" + time()
   fAPURADO_S := .T.

   @ prow()+1,4 say replicate("_",135)
   if cTP_GIA == "1"
      @ prow()+1,4 say "Total Geral..:" + space(11) + transform(fTOT_CONT,cPIC1) + space(11) + transform(fTOT_BASE,cPIC1) +;
                                          space(11) + transform(fTOT_DEB,cPIC1 ) + space(11) + transform(fTOT_ISEN,cPIC1) +;
                                          space(11) + transform(fTOT_OUT,cPIC1 )
     else
      @ prow()+1,4 say "Total Geral..:" + space(11) + transform(fTOT_CONT,cPIC1) + space(11) + transform(fTOT_BC_S,cPIC1) +;
                                          space(11) + transform(fTOT_SUBST,cPIC1 ) + space(11) + transform(fTOT_ISEN,cPIC1) +;
                                          space(11) + transform(fTOT_OUT,cPIC1 )
   endif
   @ prow(),pcol() say XCOND0
   @ prow()+3,29 say "APURACAO DOS SALDOS"
   @ prow(),pcol() say XCOND2

   // TOTALIZA DEBITOS E CREDITOS ________________________________________________

   if CONFIG->Tipo_est $ "D "
      fDEBITOS  := (IMP->ICM_DEB  + IMP->ICM_OUT_DB + IMP->ICM_EST_CD + IMP->DIF_ALIQ + IMP->EST_CR_BEN + IMP->TRA_CRE_AC)
      fCREDITOS := (IMP->ICM_CRED + IMP->ICM_OUT_CD + IMP->ICM_EST_DB + IMP->ICM_REC_AN + IMP->CRE_REC_TR)
   else
      fDEBITOS  := IMP->Icm_deb
      fCREDITOS := 0
   endif

   if fCREDITOS <= fDEBITOS
      fICM_TOTAL = (fDEBITOS - fCREDITOS)
      @ prow()+2,4 say "SALDO DEVEDOR (DEBITO MENOS CREDITO)...:" + space(81) + transform(fICM_TOTAL,cPIC1)
      @ prow()+1,4 say "SALDO CREDOR ANTERIOR .................:" + space(81) + transform(i_icms_sald_anter(),cPIC1)

      // SALDO DO IMPOSTO A RECOLHER ________________________________________

      if fICM_TOTAL >= fICM_TRANSP
         @ prow()+2,4 say "IMPOSTO A RECOLHER.....................:" + transform(fICM_TOTAL - fICM_TRANSP,cPIC1)
         IMP->(qrlock())
         replace IMP->IMP_VALOR with (fICM_TOTAL)
         replace IMP->Ult_calc  with fULT_CALC        // Data e a hora para verificar as ordens de gravacao
         replace IMP->Apurado_s with fAPURADO_S       // Grava valor verdadeiro por ter operado apuracao
   //      if val(CONFIG->Anomes) < 200302
            replace IMP->Gr_pr     with (fICM_TOTAL - fICM_TRANSP)
   //      else
   //         replace IMP->Gr_pr  with iif(CONFIG->Tipo_est == "D",)
   //     endif
         IMP->(qunlock())
      endif

      // SALDO DO IMPOSTO A TRANSPORTAR _____________________________________

      if fICM_TOTAL < fICM_TRANSP
         @ prow()+2,4 say "SALDO CREDOR A TRANSPORTAR PARA O MES SEGUINTE.:" + transform(fICM_TRANSP - fICM_TOTAL,cPIC1)
         IMP->(qrlock())
         replace IMP->IMP_VALOR with ((fICM_TRANSP - fICM_TOTAL) * -1)
         replace IMP->Ult_calc  with fULT_CALC        // Data e a hora para verificar as ordens de gravacao
         replace IMP->Apurado_s with fAPURADO_S       // Grava valor verdadeiro por ter operado apuracao
         IMP->(qunlock())
      endif

   endif

   // SALDO DO IMPOSTO A TRANSPORTAR ________________________________________

   if fCREDITOS > fDEBITOS
      fICM_TOTAL = (fCREDITOS - fDEBITOS)
      @ prow()+2,4 say "SALDO CREDOR (CREDITO MENOS DEBITO)....:" + space(81) + transform(fICM_TOTAL,cPIC1)
      @ prow()+1,4 say "SALDO CREDOR ANTERIOR .................:" + space(81) + transform(i_icms_sald_anter(),cPIC1)
      @ prow()+2,4 say "SALDO CREDOR A TRANSPORTAR PARA O MES SEGUINTE.:"     + transform(fICM_TOTAL + fICM_TRANSP,cPIC1)
      IMP->(qrlock())
      replace IMP->IMP_VALOR with ((fICM_TRANSP + fICM_TOTAL) * -1)
      replace IMP->Ult_calc  with fULT_CALC           // Data e a hora para verificar as ordens de gravacao
      replace IMP->Apurado_s with fAPURADO_S          // Grava valor verdadeiro por ter operado apuracao
      IMP->(qunlock())
   endif

   fTOT_CONT := 0
   fTOT_BASE := 0
   fTOT_DEB  := 0
   fTOT_ISEN := 0
   fTOT_OUT  := 0

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR SALDO CREDOR ANTERIOR DE ICMS ___________________________

function i_icms_sald_anter

   local dINI_ANTER, dFIM_ANTER, cMES_ANTERIOR, cANO_ANTERIOR, nREC

   fICM_TRANSP   := 0
   cMES_ANTERIOR := nMES - 1
   cANO_ANTERIOR := year(dDATA_INI)

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

   IMP->(dbseek(K_ICM + dtos(dINI_ANTER) + dtos(dFIM_ANTER) + alltrim(cFILIAL))) //alteracao p/romero dudu

   if IMP->Codigo == K_ICM .and. IMP->Data_ini == dINI_ANTER .and. IMP->Data_fim == dFIM_ANTER .and. IMP->Filial == cFILIAL
      if IMP->IMP_VALOR < 0
         fICM_TRANSP := (IMP->IMP_VALOR * -1)
      endif
   else
      alert("SALDO ANTERIOR COM PROBLEMAS !;SE FOR PRIMEIRO MES DE LANCAMENTO DESTA EMPRESA, CONTINUE.;SE NAO, VERIFIQUE SE FOI APURADO OS MESES ANTERIORES.",{"OK"})
   endif

   IMP->(dbgoto(nREC))

return fICM_TRANSP

