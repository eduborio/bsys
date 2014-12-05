//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: APURACAO DE ENTRADA ICMS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........: ATUALIZA DEBITOS DO IMPOSTO (TOT_DEB)
// ALTERACOES.:
function ef511

#define K_MAX_LIN 55

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS _______________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) .or. empty(cTIPOPER)}

private cFILIAL                               // Filial
private sBLOC1 := qlbloc("B511A","QBLOC.GLO") // Periodo de impressao
private sBLOC2 := qlbloc("B511B","QBLOC.GLO") // Tipo de periodo
private sBLOC3 := qlbloc("B521D","QBLOC.GLO") // Tipo de gia
private cTP_GIA:= "1"                          //Normal /Subs .Tributaria

private cPIC1  := "@E 99,999,999.99"
private cPIC2  := "@E 999,999.99"

private lCABECALHO := .T.            // imprime cabecalho caso nao tenha notas
private lMUDOU_MES := .F.            // Verifica se mudou mes, para totalizar e novo cabecalho
private cTITULO                      // titulo do relatorio
private bENT_FILTRO                  // code block de filtro entrada
private bSAI_FILTRO                  // code block de filtro saida

private aEDICAO    := {}             // vetor para os campos de entrada de dados

private cTIPOPER                     // tipo de periodo
private nMES                         // Mes da listagem
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
private fICM_SUBS                    // valor da substituicao tributaria
private fICM_B_SUBS                  // base da substituicao tributaria

//private fTOT_SUBST                  // base da substituicao tributaria
//private fTOT_BC_S                   // base da substituicao tributaria


private fICM_OUT_DB                  // Outros Debitos
private fICM_DOUTDB                  // Descricao outros debitos
private fICM_OUT_CD                  // Outros creditos
private fICM_DOUTCD                  // Descricao outros creditos
private fICM_EST_CD                  // Estornos Creditos
private fICM_DESTCD                  // Descricao estornos creditos
private fICM_EST_DB                  // Estornos debitos
private fICM_DESTDB                  // Descricao estornos debitos

private fDIF_ALIQ                    // Diferencial de aliquota
private fDIF_ALIQ_D                  // Descricao de diferencial de aliquota
private fEST_CR_BEN                  // Estornos de creditos de bens do ativo imobilizado
private fEST_CR_DES                  // Descricao de Estornos de creditos de bens do ativo imobilizado
private fICM_REC_AN                  // ICMS recolhido antecipadamente
private fICM_R_A_DE                  // Descricao ICMS recolhido antecipadamente

private dDATA_INI_A                  // Inicio do periodo do relatorio anual
private dDATA_FIM_A                  // Fim do periodo do relatorio anual
private dDATA_INI                    // Inicio do periodo do relatorio
private dDATA_FIM                    // Fim do periodo do relatorio

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

   qlbloc(5,0,"B511A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || qesco(-1,0 , @cTIPOPER,sBLOC2)} , "TIPOPER"  })
   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL ,"9999"           ) } ,"FILIAL"  })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL       }) // descricao do filial

   aadd(aEDICAO,{{ || qgetx(-1,0 , @dDATA_INI   , "@!"     ,NIL,NIL) } ,"DATA_INI"})
   aadd(aEDICAO,{{ || qgetx(-1,0 , @dDATA_FIM   , "@!"     ,NIL,NIL) } ,"DATA_FIM"})
   aadd(aEDICAO,{{ || qgetx(-1,0 , @nFOLHA      , "@E 9999",NIL,NIL) } ,"FOLHA"  })

   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_OUT_DB , "@E 999,999,999.99" ) } ,"ICM_OUT_DB" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_DOUTDB , "@!@S40"            ) } ,"ICM_DOUTDB" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_OUT_CD , "@E 999,999,999.99" ) } ,"ICM_OUT_CD" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_DOUTCD , "@!@S40"            ) } ,"ICM_DOUTCD" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_EST_CD , "@E 999,999,999.99" ) } ,"ICM_EST_CD" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_DESTCD , "@!@S40"            ) } ,"ICM_DESTCD" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_EST_DB , "@E 999,999,999.99" ) } ,"ICM_EST_DB" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_DESTDB , "@!@S40"            ) } ,"ICM_DESTDB" })

   aadd(aEDICAO,{{ || qgetx(-1,0 , @fDIF_ALIQ   , "@E 999,999,999.99" ) } ,"DIF_ALIQ"   })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fDIF_ALIQ_D , "@!@S40"            ) } ,"DIF_ALIQ_D" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fEST_CR_BEN , "@E 999,999,999.99" ) } ,"EST_CR_BEN" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fEST_CR_DES , "@!@S40"            ) } ,"EST_CR_DES" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_REC_AN , "@E 999,999,999.99" ) } ,"ICM_REC_AN" })
   aadd(aEDICAO,{{ || qgetx(-1,0 , @fICM_R_A_DE , "@!@S40"            ) } ,"ICM_R_A_DE" })

   if XTIPOEMP $ "25"
      aadd(aEDICAO,{{ || qesco(-1,0,@cTP_GIA ,sBLOC3                     ) } ,"TP_GIA"   })
   else
      aadd(aEDICAO,{{ || NIL                                               },NIL         })
   endif

do while .T.

   qlbloc(5,0,"B511A","QBLOC.GLO")

   XNIVEL    := 1
   XFLAG     := .T.
   cTIPOPER  := " "
   cFILIAL   := "    "
   fVLR_CONT := 0
   fICM_BASE := 0
   fICM_VLR  := 0
   fICM_ISEN := 0
   fICM_OUT  := 0
   fTOT_CONT := 0
   fTOT_BASE := 0
   fTOT_CRED := 0
   fTOT_DEB  := 0
   fTOT_ISEN := 0
   fTOT_OUT  := 0
   fICM_SUBS   := 0
   fICM_B_SUBS := 0

   fICM_OUT_DB := 0
   fICM_DOUTDB := space(80)
   fICM_OUT_CD := 0
   fICM_DOUTCD := space(80)
   fICM_EST_CD := 0
   fICM_DESTCD := space(80)
   fICM_EST_DB := 0
   fICM_DESTDB := space(80)

   fDIF_ALIQ   := 0
   fDIF_ALIQ_D := space(80)
   fEST_CR_BEN := 0
   fEST_CR_DES := space(80)
   fICM_REC_AN := 0
   fICM_R_A_DE := space(80)

   nFALTA      := 0                   // MESES QUE FALTAM PARA IMPRIMIR CABECALHO
  // nFOLHA      := val(XICM_AP_ENT)
   nFOLHA      := 1
   XPAGINA     := 0
   lCABECALHO  := .T.

   dDATA_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM   := qfimmes(dDATA_INI)
   dDATA_INI_A := ctod("01/01/" + left(XANOMES,4))
   dDATA_FIM_A := ctod("31/12/" + left(XANOMES,4))

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

   local nCONT

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
//              qrsay (XNIVEL+1,dDATA_INI_A)
//              qrsay (XNIVEL+2,dDATA_FIM_A)
              dDATA_INI := dDATA_INI_A
              dDATA_FIM := dDATA_FIM_A
              nMES := val(str(month(dDATA_INI_A),2))
//              XNIVEL+=2
           endif
      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           if cTIPOPER <> "2"
              dDATA_FIM := qfimmes(dDATA_INI)
              qrsay(XNIVEL+1,dDATA_FIM)
              nMES := val(str(month(dDATA_INI),2))
           Endif
      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

           if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(dDATA_FIM) + alltrim(cFILIAL)))

              fICM_OUT_DB := IMP->Icm_Out_Db
              fICM_DOUTDB := IMP->Icm_DoutDb
              fICM_OUT_CD := IMP->Icm_Out_Cd
              fICM_DOUTCD := IMP->Icm_DoutCd
              fICM_EST_CD := IMP->Icm_Est_Cd
              fICM_DESTCD := IMP->Icm_DestCd
              fICM_EST_DB := IMP->Icm_Est_Db
              fICM_DESTDB := IMP->Icm_DestDb

              fDIF_ALIQ   := IMP->Dif_aliq
              fDIF_ALIQ_D := IMP->Dif_aliq_d
              fEST_CR_BEN := IMP->Est_cr_ben
              fEST_CR_DES := IMP->Est_cr_des
              fICM_REC_AN := IMP->Icm_rec_an
              fICM_R_A_DE := IMP->Icm_r_a_de

              nCONT := 7

              qrsay ( nCONT++ , IMP->Icm_Out_Db , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Icm_DoutDb , "@!@S40"            )
              qrsay ( nCONT++ , IMP->Icm_Out_Cd , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Icm_DoutCd , "@!@S40"            )
              qrsay ( nCONT++ , IMP->Icm_Est_Cd , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Icm_DestCd , "@!@S40"            )
              qrsay ( nCONT++ , IMP->Icm_Est_Db , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Icm_DestDb , "@!@S40"            )

              qrsay ( nCONT++ , IMP->Dif_aliq   , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Dif_aliq_d , "@!@S40"            )
              qrsay ( nCONT++ , IMP->Est_cr_ben , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Est_cr_des , "@!@S40"            )
              qrsay ( nCONT++ , IMP->Icm_rec_an , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Icm_r_a_de , "@!@S40"            )

           endif

      case cCAMPO == "ICM_R_A_DE"

           // GRAVA VALORES INFORMADOS PRIMEIRO MES ______________________________

//         if (fICM_OUT_DB + fICM_OUT_CD + fICM_EST_CD + fICM_EST_DB) > 0     // Foi modificado no dia 05/06/96, porque nao
                                                                              // deixa colocar zero nos campos de outras e
                                                                              // estornos (Ex.: voce por engano colocou um valor)
                                                                              // no campo outro credito, mas nao era necessario
                                                                              // voce tenta incluir zero mas ele nao aceita a
                                                                              // alteracao.)
              fULT_CALC  := dtos(date()) + "-" + time()
              fAPURADO_E := .T.

              if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(qfimmes(dDATA_INI))+alltrim(cFILIAL)))
                 IMP->(qrlock())
                 replace IMP->Icm_Out_Db with fICM_OUT_DB         // Outros Debitos
                 replace IMP->Icm_DoutDb with fICM_DOUTDB         // Descricao outros debitos
                 replace IMP->Icm_Out_Cd with fICM_OUT_CD         // Outros creditos
                 replace IMP->Icm_DoutCd with fICM_DOUTCD         // Descricao outros creditos
                 replace IMP->Icm_Est_Cd with fICM_EST_CD         // Estornos Creditos
                 replace IMP->Icm_DestCd with fICM_DESTCD         // Descricao estornos creditos
                 replace IMP->Icm_Est_Db with fICM_EST_DB         // Estornos debitos
                 replace IMP->Icm_DestDb with fICM_DESTDB         // Descricao estornos debitos
                 replace IMP->Ult_calc   with fULT_CALC           // Data e a hora para verificar as ordens de gravacao
                 replace IMP->Apurado_e  with fAPURADO_E          // Grava valor verdadeiro por ter operado apuracao

                 replace IMP->Dif_aliq   with fDIF_ALIQ           // Diferencial de aliquota
                 replace IMP->Dif_aliq_d with fDIF_ALIQ_D         // Descricao de diferencial de aliquota
                 replace IMP->Est_cr_ben with fEST_CR_BEN         // Estornos de creditos de bens do ativo imobilizado
                 replace IMP->Est_cr_des with fEST_CR_DES         // Descricao de Estornos de creditos de bens do ativo imobilizado
                 replace IMP->Icm_rec_an with fICM_REC_AN         // ICMS recolhido antecipadamente
                 replace IMP->Icm_r_a_de with fICM_R_A_DE         // Descricao ICMS recolhido antecipadamente

                 IMP->(qunlock())
              else
                 IMP->(qappend())
                 replace IMP->Codigo     with K_ICM
                 replace IMP->Data_Ini   with dDATA_INI           // data inicial do periodo
                 replace IMP->Data_Fim   with qfimmes(dDATA_INI)  // data final do periodo
                 replace IMP->Icm_Out_Db with fICM_OUT_DB         // Outros Debitos
                 replace IMP->Icm_DoutDb with fICM_DOUTDB         // Descricao outros debitos
                 replace IMP->Icm_Out_Cd with fICM_OUT_CD         // Outros creditos
                 replace IMP->Icm_DoutCd with fICM_DOUTCD         // Descricao outros creditos
                 replace IMP->Icm_Est_Cd with fICM_EST_CD         // Estornos Creditos
                 replace IMP->Icm_DestCd with fICM_DESTCD         // Descricao estornos creditos
                 replace IMP->Icm_Est_Db with fICM_EST_DB         // Estornos debitos
                 replace IMP->Icm_DestDb with fICM_DESTDB         // Descricao estornos debitos
                 replace IMP->Ult_calc   with fULT_CALC           // Data e a hora para verificar as ordens de gravacao
                 replace IMP->Apurado_e  with fAPURADO_E          // Grava valor verdadeiro por ter operado apuracao
                 replace IMP->Filial     with cFILIAL

                 replace IMP->Dif_aliq   with fDIF_ALIQ           // Diferencial de aliquota
                 replace IMP->Dif_aliq_d with fDIF_ALIQ_D         // Descricao de diferencial de aliquota
                 replace IMP->Est_cr_ben with fEST_CR_BEN         // Estornos de creditos de bens do ativo imobilizado
                 replace IMP->Est_cr_des with fEST_CR_DES         // Descricao de Estornos de creditos de bens do ativo imobilizado
                 replace IMP->Icm_rec_an with fICM_REC_AN         // ICMS recolhido antecipadamente
                 replace IMP->Icm_r_a_de with fICM_R_A_DE         // Descricao ICMS recolhido antecipadamente

                 IMP->(qunlock())
              endif

//         endif
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
      cTITULO := "APURACAO DE ENTRADA - ICMS "
   else
      cTITULO := "APURACAO DE ENTRADA - ICMS - ANUAL"
   endif
   // CRIA MACRO DE FILTRO _______________________________________________________

   qmensa("")

   bENT_FILTRO := { || ENT->Data_Lanc >= dDATA_INI .and. ENT->Data_Lanc <= dDATA_FIM }

   ENT->(dbSetFilter({|| alltrim(Filial) $ cFILIAL}, 'alltrim(Filial) $ cFILIAL'))

   bSAI_FILTRO := { || SAI->Data_Lanc >= dDATA_INI .and. SAI->Data_Lanc <= dDATA_FIM }

   SAI->(dbSetFilter({|| alltrim(Filial) $ cFILIAL}, 'alltrim(Filial) $ cFILIAL'))

   // ESTABELECE RELACOES ENTRE ARQUIVOS _________________________________________

   select OUTENT
   OUTENT->(dbgotop())

   select OUTSAI
   OUTSAI->(dbgotop())

   select IMP
   IMP->(dbgotop())

   select SAI
   SAI->(dbsetorder(3))                             // Codigos Fiscais
   SAI->(dbgotop())

   if cTIPOPER == "1"
      select ENT
      if val(left(CONFIG->Anomes,4)) < 2003
         ENT->(dbsetorder(3))                          // Codigos Fiscais
         ENT->(dbgotop())
      else
         ENT->(dbsetfilter({||alltrim(ENT->Filial)$cFILIAL.and.ENT->Data_Lanc >= dDATA_INI .and. ENT->Data_Lanc <= dDATA_FIM},'alltrim(ENT->Filial)$cFILIAL.and.ENT->Data_Lanc >= dDATA_INI .and. ENT->Data_Lanc <= dDATA_FIM'))
         ENT->(dbsetorder(8))                          // Codigos Fiscais
         ENT->(dbgotop())
      endif
   else
      select ENT
      if val(left(CONFIG->Anomes,4)) < 2003
         ENT->(dbsetorder(4))                          // Codigos Fiscais do ano todo
         ENT->(dbgotop())
      else
         ENT->(dbsetfilter({||alltrim(ENT->Filial)$cFILIAL.and.ENT->Data_Lanc >= dDATA_INI .and. ENT->Data_Lanc <= dDATA_FIM},'alltrim(ENT->Filial)$cFILIAL.and.ENT->Data_Lanc >= dDATA_INI .and. ENT->Data_Lanc <= dDATA_FIM'))
         ENT->(dbsetorder(9))                          // Codigos Fiscais do ano todo
         ENT->(dbgotop())
      endif
   endif

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _______________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND2

   ENT->(dbgotop())

   do while ! ENT->(eof())   // condicao principal de loop

      //qgirabarra()

      if XPAGINA == 0 .or. prow() > K_MAX_LIN

         qpageprn()

         // CASO IMPRIMA ALGUMA NOTA, NAO IMPRIME CABECALHO FORA DESTE LOOP_______

         lCABECALHO := .F.

         // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

         if nFOLHA <> 0
            XPAGINA = nFOLHA
            nFOLHA  = 0
         endif

         i_icm_apuracao(cTITULO,"ENT",nMES)

      endif


      // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________
      if val(left(CONFIG->Anomes,4)) < 2003
         fCOD_FISC := ENT->COD_FISC
         do while fCOD_FISC = ENT->COD_FISC

           // qgirabarra()

            if eval(bENT_FILTRO)

               if cTIPOPER == "1"
                  if nMES <> val(str(month(ENT->DATA_LANC),2))
                     lMUDOU_MES := .T.
                     exit
                  endif

                  if !lMUDOU_MES .and. cTIPOPER == "1"
                     qmensa("Imprimindo Codigo Fiscal: "+ENT->Cod_Fisc)

                     fVLR_CONT += ENT->Vlr_Cont
                     fICM_BASE += ENT->Icm_Base
                     fICM_VLR  += round(ENT->Icm_Vlr,2)
                     //fICM_VLR  += ENT->Icm_Vlr
                     //fICM_VLR  := round(fICM_VLR,2)
                     fICM_ISEN += ENT->Icm_Isen
                     fICM_OUT  += ENT->Icm_Out

                     if XTIPOEMP $ "25" // soma substituicao tributaria
                        fICM_SUBS   += ENT->Icm_subst
                        fICM_B_SUBS += ENT->Icm_bc_s
                     endif

                     if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->NUM_NF+ENT->SERIE+ENT->FILIAL))
                        for nCONT := 1 to 5
                            // qgirabarra()
                             aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
                             aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
                             aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr
                             fICM_BASE += OUTENT->Icm_Base
                             fICM_VLR  += OUTENT->Icm_Vlr
                             OUTENT->(dbskip())
                             if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                                exit
                             endif
                        next
                     endif
                  endif

               else

                  qmensa("Imprimindo Codigo Fiscal: "+ENT->Cod_Fisc)

                  fVLR_CONT += ENT->Vlr_Cont
                  fICM_BASE += ENT->Icm_Base
                  fICM_VLR  += round(ENT->Icm_Vlr,2)
                  //fICM_VLR  += ENT->Icm_Vlr
                  //fICM_VLR  := round(fICM_VLR,2)
                  fICM_ISEN += ENT->Icm_Isen
                  fICM_OUT  += ENT->Icm_Out

                  if XTIPOEMP $ "25" // soma substituicao tributaria
                     fICM_SUBS   += SAI->Icm_subst
                     fICM_B_SUBS += SAI->Icm_bc_s
                  endif

                  if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->NUM_NF+ENT->SERIE+ENT->FILIAL))
                     for nCONT := 1 to 5
                         //qgirabarra()
                         aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
                         aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
                         aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr
                         fICM_BASE += OUTENT->Icm_Base
                         fICM_VLR  += OUTENT->Icm_Vlr
                         OUTENT->(dbskip())
                         if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                            exit
                         endif
                     next
                  endif

               endif

            endif

            ENT->(dbskip())

         enddo
      else
         fCFOP     := ENT->Cfop
         do while fCFOP = ENT->CFOP

            //qgirabarra()

            if eval(bENT_FILTRO)

               if cTIPOPER == "1"
                  if nMES <> val(str(month(ENT->DATA_LANC),2))
                     lMUDOU_MES := .T.
                     exit
                  endif

                  if !lMUDOU_MES .and. cTIPOPER == "1"
                     qmensa("Imprimindo Codigo Fiscal: "+ENT->Cfop + strzero(ENT->(recno()),5 ))

                     fVLR_CONT += ENT->Vlr_Cont
                     fICM_BASE += ENT->Icm_Base
                     fICM_VLR  += round(ENT->Icm_Vlr,2)
                     //fICM_VLR  += ENT->Icm_Vlr
                     //fICM_VLR  := round(fICM_VLR,2)
                     fICM_ISEN += ENT->Icm_Isen
                     fICM_OUT  += ENT->Icm_Out

                     if XTIPOEMP $ "25" // soma substituicao tributaria
                        fICM_SUBS   += ENT->Icm_subst
                        fICM_B_SUBS += ENT->Icm_bc_s
                     endif

                     if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->NUM_NF+ENT->SERIE+ENT->FILIAL))
                        for nCONT := 1 to 5
                            // qgirabarra()
                             aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
                             aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
                             aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr
                             fICM_BASE += OUTENT->Icm_Base
                             fICM_VLR  += OUTENT->Icm_Vlr
                             OUTENT->(dbskip())
                             if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                                exit
                             endif
                        next
                     endif
                  endif

               else

                  qmensa("Imprimindo Codigo Fiscal: "+ENT->Cfop)

                  fVLR_CONT += ENT->Vlr_Cont
                  fICM_BASE += ENT->Icm_Base
                  fICM_VLR  += round(ENT->Icm_Vlr,2)
                  //fICM_VLR  += ENT->Icm_Vlr
                  //fICM_VLR  := round(fICM_VLR,2)
                  fICM_ISEN += ENT->Icm_Isen
                  fICM_OUT  += ENT->Icm_Out

                  if XTIPOEMP $ "25" // soma substituicao tributaria
                     fICM_SUBS   += SAI->Icm_subst
                     fICM_B_SUBS += SAI->Icm_bc_s
                  endif

                  if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->NUM_NF+ENT->SERIE+ENT->FILIAL))
                     for nCONT := 1 to 5
                         //qgirabarra()
                         aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
                         aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
                         aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr
                         fICM_BASE += OUTENT->Icm_Base
                         fICM_VLR  += OUTENT->Icm_Vlr
                         OUTENT->(dbskip())
                         if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
                            exit
                         endif
                     next
                  endif

               endif

            endif

            ENT->(dbskip())

         enddo
      endif

      if val(left(CONFIG->Anomes,4)) < 2003
         if fVLR_CONT > 0
            @ prow()+2,4 say fCod_fisc + space(22) + transform(fVLR_CONT,cPIC1) + space(11) + transform(fICM_BASE,cPIC1) +;
                                         space(11) + transform(fICM_VLR,cPIC1 ) + space(11) + transform(fICM_ISEN,cPIC1) +;
                                         space(11) + transform(fICM_OUT,cPIC1 ) + space(2)  + "B.C. ST: "+transform(fICM_B_SUBS,cPIC2)
            @ prow()+1,140 say "ICMS ST: "+transform(fICM_SUBS,cPIC2)
         endif
     else
         if fVLR_CONT > 0
            @ prow()+2,4 say fCFOP + space(21) + transform(fVLR_CONT,cPIC1) + space(11) + transform(fICM_BASE,cPIC1) +;
                                         space(11) + transform(fICM_VLR,cPIC1 ) + space(11) + transform(fICM_ISEN,cPIC1) +;
                                         space(11) + transform(fICM_OUT,cPIC1 ) + space(2)  + "B.C. ST: "+transform(fICM_B_SUBS,cPIC2)
            @ prow()+1,140 say "ICMS ST: "+transform(fICM_SUBS,cPIC2)
         endif
    endif
      // ACUMULA TOTAL GERAL E SUB-TOTAIS  _______________________________________

      fTOT_CONT += fVLR_CONT
      fTOT_BASE += fICM_BASE
      fTOT_CRED += fICM_VLR
      fTOT_ISEN += fICM_ISEN
      fTOT_OUT  += fICM_OUT

      if fVLR_CONT > 0 .and. cTIPOPER == "1"
         @ prow()+1,4 say "Sub-Total.:" + space(14) + transform(fVLR_CONT,cPIC1) + space(11) + transform(fICM_BASE,cPIC1) +;
                                          space(11) + transform(fICM_VLR,cPIC1 ) + space(11) + transform(fICM_ISEN,cPIC1) +;
                                          space(11) + transform(fICM_OUT,cPIC1 )
      endif

      fVLR_CONT := 0
      fICM_BASE := 0
      fICM_VLR  := 0
      fICM_ISEN := 0
      fICM_OUT  := 0

      if lMUDOU_MES .or. ENT->(eof()) .and. cTIPOPER == "1"

         // BUSCA O DEBITO, IMPRIME O TOTAL, O CABECALHO, GRAVA VALORES ____

         i_busca_debito()
         i_ent_grava()
         i_tot_periodo()

         nMES++

         // PARA IMPRESSAO DO CABECALHO ____________________________________

         setprc(56,00)

         //if ! qlineprn() ; return ; endif

         lMUDOU_MES := .F.

         loop

      endif

      if ENT->(eof()) .and. cTIPOPER == "2"

         @ prow()+1,4 say replicate("_",135)
         @ prow()+1,4 say "Total Geral..:" + space(11) + transform(fTOT_CONT,cPIC1) + space(11) + transform(fTOT_BASE,cPIC1) +;
                                             space(11) + transform(fTOT_CRED,cPIC1) + space(11) + transform(fTOT_ISEN,cPIC1) +;
                                             space(11) + transform(fTOT_OUT,cPIC1 )
         fTOT_CONT := 0
         fTOT_BASE := 0
         fTOT_CRED := 0
         fTOT_ISEN := 0
         fTOT_OUT  := 0

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

         // BUSCA O DEBITO, IMPRIME O TOTAL, O CABECALHO, GRAVA VALORES ____

         qpageprn()

         if lCABECALHO
            XPAGINA := nFOLHA
            lCABECALHO := .F.
         endif

         i_icm_apuracao(cTITULO,"ENT",nMES)
         i_busca_debito()
         i_ent_grava()
         i_tot_peRiodo()

         setprc(56,00)

         nFALTA--
         nMES++

      enddo

   endif

   i_grava_pagina()           // PROGRAMA EF510.PRG

   qstopprn()

return
    
//////////////////////////////////////////////////////////////////////////////////
// IMPRIME O TOTAL DE CADA PERIODO _______________________________________________

static function i_tot_periodo

   @ prow()+1,4 say replicate("_",135)
   @ prow()+1,4 say "Total Geral..:" + space(11) + transform(fTOT_CONT,cPIC1) + space(11) + transform(fTOT_BASE,cPIC1) +;
                                       space(11) + transform(fTOT_CRED,cPIC1) + space(11) + transform(fTOT_ISEN,cPIC1) +;
                                       space(11) + transform(fTOT_OUT,cPIC1 )

   @ prow(),pcol() say XCOND0
   @ prow()+2,28 say "TOTAL DE DEBITOS"
   @ prow(),pcol() say XCOND2
   @ prow()+1,4 say "51-POR SAIDAS COM DEBITO DO IMPOSTO....:" + space(81) + transform(IMP->Icm_Deb,cPIC1)
   @ prow()+1,4 say "52-OUTROS DEBITOS......................:" + IMP->Icm_DoutDb + " " + transform(IMP->Icm_Out_Db,cPIC1)
   @ prow()+1,4 say "53-ESTORNOS DE CREDITOS................:" + IMP->Icm_DestCd + " " + transform(IMP->Icm_Est_Cd,cPIC1)
   @ prow()+1,4 say "54-DIFERENCIAL DE ALIQUOTA.............:" + IMP->Dif_aliq_d + " " + transform(IMP->Dif_aliq,cPIC1)
   @ prow()+1,4 say "56-EST. DE CRED. DE BENS DO ATIVO IMOB.:" + IMP->Est_cr_des + " " + transform(IMP->Est_cr_ben,cPIC1)
   @ prow()+1,4 say "Total..................................:" + space(81) + transform(IMP->Icm_Deb +;
                                                                                       IMP->Icm_Out_Db +;
                                                                                       IMP->Icm_Est_Cd +;
                                                                                       IMP->Dif_aliq +;
                                                                                       IMP->Est_cr_ben,cPIC1)

   @ prow(),pcol() say XCOND0
   @ prow()+2,28 say "TOTAL DE CREDITOS"
   @ prow(),pcol() say XCOND2
   @ prow()+1,4 say "62-POR ENTRADAS COM CREDITO DO IMPOSTO.:" + space(81) + transform(IMP->Icm_Cred,cPIC1)
   @ prow()+1,4 say "63-OUTROS CREDITOS.....................:" + IMP->ICM_DOUTCD + " " + transform(IMP->Icm_Out_Cd,cPIC1)
   @ prow()+1,4 say "64-ESTORNOS DE DEBITOS.................:" + IMP->ICM_DESTDB + " " + transform(IMP->Icm_Est_Db,cPIC1)
   @ prow()+1,4 say "68-ICMS RECOLHIDO ANTECIPADAMENTE......:" + IMP->ICM_R_A_DE + " " + transform(IMP->Icm_rec_an,cPIC1)
   @ prow()+1,4 say "Total..................................:" + space(81) + transform(IMP->Icm_Cred +;
                                                                                       IMP->Icm_Out_Cd +;
                                                                                       IMP->Icm_Est_Db +;
                                                                                       IMP->Icm_rec_an,cPIC1)

   fDIF_ALIQ   := 0
   fDIF_ALIQ_D := space(80)
   fEST_CR_BEN := 0
   fEST_CR_DES := space(80)
   fICM_REC_AN := 0
   fICM_R_A_DE := space(80)

   fTOT_CONT := 0
   fTOT_BASE := 0
   fTOT_CRED := 0
   fTOT_ISEN := 0
   fTOT_OUT  := 0

return

//////////////////////////////////////////////////////////////////////////////////
// GRAVA OS VALORES REFERENTES AO ICMS PARA EMISSAO DA GIA OU GIAR _______________

function i_ent_grava

   local dINICIO, dTERMINO

   dINICIO    := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
   dTERMINO   := qfimmes(ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4)))
   fULT_CALC  := dtos(date()) + "-" + time()
   fAPURADO_E := .T.

   if IMP->(dbseek(K_ICM + dtos(dINICIO) + dtos(dTERMINO) + alltrim(cFILIAL)))

      IMP->(qrlock())
      replace IMP->Icm_Cred  with fTOT_CRED         // total ICMS creditado
      replace IMP->Icm_Deb   with fTOT_DEB          // total ICMS debitado
      replace IMP->Ult_calc  with fULT_CALC         // Data e a hora para verificar as ordens de gravacao
      replace IMP->Apurado_e with fAPURADO_E        // Grava valor verdadeiro por ter operado apuracao
      IMP->(qunlock())

   else

      IMP->(qappend())
      replace IMP->Codigo    with K_ICM
      replace IMP->Data_Ini  with dINICIO           // data inicial do periodo
      replace IMP->Data_Fim  with dTERMINO          // data final do periodo
      replace IMP->Icm_Cred  with fTOT_CRED         // total ICMS creditado
      replace IMP->Icm_Deb   with fTOT_DEB          // total ICMS debitado
      replace IMP->Ult_calc  with fULT_CALC         // Data e a hora para verificar as ordens de gravacao
      replace IMP->Apurado_e with fAPURADO_E        // Grava valor verdadeiro por ter operado apuracao
      replace IMP->Filial    with cFILIAL
      IMP->(qunlock())

   endif

return

//////////////////////////////////////////////////////////////////////////////////
// BUSCA O DEBITO DO ICMS PARA APURACAO _________________________________________

static function i_busca_debito

   local dINICIO, dTERMINO

   dINICIO  := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
   dTERMINO := qfimmes(ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4)))

   fTOT_DEB := 0

   // CRIA MACRO DE FILTRO DAS SAIDAS _____________________________________________

   SAI->(dbgotop())

   // SOMA OS TOTAIS DOS DEBITOS PARA APURAR OS SALDOS ____________________________

   do while ! SAI->(eof())

      //qgirabarra()

      if eval(bSAI_FILTRO)

         fTOT_DEB += round(SAI->Icm_Vlr,2)
         //fTOT_DEB := round(fTOT_DEB,2)

         if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->FILIAL))
            for nCONT := 1 to 5
                 //qgirabarra()
                 aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
                 aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
                 aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr
                 fTOT_DEB += OUTSAI->Icm_Vlr
                 OUTSAI->(dbskip())
                 if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> Dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                    exit
                 endif
            next
         endif

      endif

      SAI->(dbskip())

   enddo

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO PARA OS LIVROS DE ENTRADA E SAIDA DE NOTAS FISCAIS __________________

function i_icm_apuracao

   parameters cTITULO, cTIPO, nMES
   local cOPERACAO, cIMPOSTO, dINICIO, dTERMINO

   cOPERACAO := "credito"
   cIMPOSTO  := "creditado"

   if cTIPO == "SAI"
      cOPERACAO := "debito "
      cIMPOSTO  := "debitado "
   endif

   if empty(nMES)
      nMES := 0
   endif

   if nMES > 0
      dINICIO  := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
      dTERMINO := qfimmes(ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4)))
   endif

   @ prow(),pcol() say XCOND0
   @ prow()+1,029 say cTITULO
   @ prow(),pcol() say XCOND2
   @ prow()+2,004 say "Empresa...: "+ XRAZAO    // FILIAL->Razao
   @ prow()+1,004 say "Insc. Est.: "+ transform(alltrim(qtiraponto(FILIAL->INSC_ESTAD)),"@R 999.99999-99") + " CNPJ    :" + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99")

   if cTIPOPER == "1"
      @ prow()+1,004 say "Mes ou Periodo/Ano: De " + dtoc(dINICIO) + " ate " + dtoc(dTERMINO)
//    @ prow()  ,122 say "Folha...:" + strzero(XPAGINA,4)
      @ prow()  ,122 say "Folha...:" + strzero(XPAGINA,4)
      @ prow()+1,4 say replicate("_",135)
      @ prow()+1,4 say "|        |                            |                                               |                                               |"
      @ prow()+1,4 say "| Codigo |                            |       Operacoes com " + cOPERACAO + " do Imposto        |       Operacoes sem " + cOPERACAO + " do Imposto        |     Observacao  "
      @ prow()+1,4 say "|        |       Valor Contabil       |                     ICMS                      |                     ICMS                      |"
      @ prow()+1,4 say "| Fiscal |                            |_______________________________________________|_______________________________________________|"
      @ prow()+1,4 say "|        |                            |    Base de Calculo    |   Imposto " + cIMPOSTO+"   |Isentas/Nao Tributadas |         Outras        |"
      @ prow()+1,4 say replicate("_",135)
   else
      dDATA_INI_A := ctod("01/01/" + left(XANOMES,4))
      dDATA_FIM_A := ctod("31/12/" + left(XANOMES,4))
      dINICIO  := dDATA_INI_A
      dTERMINO := dDATA_FIM_A
      @ prow()+1,004 say "Mes ou Periodo/Ano: De " + dtoc(dINICIO) + " ate " + dtoc(dTERMINO)
//    @ prow()  ,122 say "Folha...:" + strzero(XPAGINA,4)
      @ prow()  ,122 say "Folha...:" + strzero(XPAGINA,4)
      @ prow()+1,4 say replicate("_",135)
      @ prow()+1,4 say "|        |                            |                                               |                                               |"
      @ prow()+1,4 say "| Codigo |                            |       Operacoes com " + cOPERACAO+" do Imposto        |       Operacoes sem " + cOPERACAO + " do Imposto        |     Observacao  "
      @ prow()+1,4 say "|        |       Valor Contabil       |                     ICMS                      |                     ICMS                      |"
      @ prow()+1,4 say "| Fiscal |                            |_______________________________________________|_______________________________________________|"
      @ prow()+1,4 say "|        |                            |    Base de Calculo    |   Imposto " + cIMPOSTO+"   |Isentas/Nao Tributadas |         Outras        |"
      @ prow()+1,4 say replicate("_",135)
   endif
return
