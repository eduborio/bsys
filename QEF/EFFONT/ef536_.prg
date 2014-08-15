//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: REGISTRO DE APURACAO DO ICMS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: JUNHO DE 1998
// OBS........:
// ALTERACOES.:
function ef536

#define K_MAX_LIN 55

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS _______________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27)}
private nBASE_CALC := 0
private cFILIAL                               // Filial
private cTITULO                               // Titulo do relatorio
private cTIT                                  // Titulo do relatorio - ENTRADA OU SAIDA
private bENT_FILTRO                           // Filtro
private bSAI_FILTRO                           // Filtro
private lMUDOU_MES := .F.
private nFALTA     := 0
private nMES       := 0
private nPAG       := 0
private l2003      := .F.
private fDEBITO    := 0
private cPIC1  := "@E 99,999,999.99"
private sBLOC1 := qlbloc("B521B","QBLOC.GLO") // Tipo de periodo


private aEDICAO    := {}             // vetor para os campos de entrada de dados

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

private fTOT1CONT  := 0
private fTOT1BASE  := 0
private fTOT1DEB   := 0
private fTOT1CRED  := 0
private fTOT1ISEN  := 0
private fTOT1OUT   := 0
private fTOT2CONT  := 0
private fTOT2BASE  := 0
private fTOT2DEB   := 0
private fTOT2CRED  := 0
private fTOT2ISEN  := 0
private fTOT2OUT   := 0
private fTOT3CONT  := 0
private fTOT3BASE  := 0
private fTOT3DEB   := 0
private fTOT3CRED  := 0
private fTOT3ISEN  := 0
private fTOT3OUT   := 0
private fTOT5CONT  := 0
private fTOT5BASE  := 0
private fTOT5DEB   := 0
private fTOT5CRED  := 0
private fTOT5ISEN  := 0
private fTOT5OUT   := 0
private fTOT6CONT  := 0
private fTOT6BASE  := 0
private fTOT6DEB   := 0
private fTOT6CRED  := 0
private fTOT6ISEN  := 0
private fTOT6OUT   := 0
private fTOT7CONT  := 0
private fTOT7BASE  := 0
private fTOT7DEB   := 0
private fTOT7CRED  := 0
private fTOT7ISEN  := 0
private fTOT7OUT   := 0

private dDATA_INI                    // Inicio do periodo do relatorio
private dDATA_FIM                    // Fim do periodo do relatorio

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

   qlbloc(5,0,"B536A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL ,"9999"           ) } ,"FILIAL"  })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL       }) // descricao do filial
//   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOC1                    ) } ,"TIPO"})
   aadd(aEDICAO,{{ || qgetx(-1,0 , @dDATA_INI   , "@!"     ,NIL,NIL) } ,"DATA_INI"})
   aadd(aEDICAO,{{ || qgetx(-1,0 , @dDATA_FIM   , "@!"     ,NIL,NIL) } ,"DATA_FIM"})
   aadd(aEDICAO,{{ || qgetx(-1,0 , @nPAG   , "9999"        ,NIL,NIL) } ,"PAG"})


do while .T.

   qlbloc(5,0,"B536A","QBLOC.GLO")
   iif(val(CONFIG->Anomes) < 200301,l2003 := .F.,l2003 := .T.)
   XNIVEL      := 1
   XFLAG       := .T.
   cTIPOPER    := " "
   cFILIAL     := "    "
   nBASE_CALC  := 0
   fVLR_CONT   := 0
   fICM_BASE   := 0
   fICM_VLR    := 0
   fICM_ISEN   := 0
   fICM_OUT    := 0
   fTOT_CONT   := 0
   fTOT_BASE   := 0
   fTOT_CRED   := 0
   fTOT_DEB    := 0
   fTOT_ISEN   := 0
   fTOT_OUT    := 0
   fICM_SUBS   := 0
   fICM_B_SUBS := 0

   fICM_OUT_DB := 0
   fICM_DOUTDB := space(136)
   fICM_OUT_CD := 0
   fICM_DOUTCD := space(136)
   fICM_EST_CD := 0
   fICM_DESTCD := space(136)
   fICM_EST_DB := 0
   fICM_DESTDB := space(136)

   fDIF_ALIQ   := 0
   fDIF_ALIQ_D := space(136)
   fEST_CR_BEN := 0
   fEST_CR_DES := space(136)
   fICM_REC_AN := 0
   fICM_R_A_DE := space(136)

   nFOLHA      := 1
   XPAGINA     := 0
   lCABECALHO  := .T.

   dDATA_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM   := qfimmes(dDATA_INI)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   return

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

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ________________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ___________________________________________________

   cTITULO := "R E G I S T R O   D E   A P U R A C A O    D O    I C M S"

   qmensa("")

   // CRIA MACRO DE FILTRO _______________________________________________________

   bENT_FILTRO := { || ENT->Data_Lanc >= dDATA_INI .and. ENT->Data_Lanc <= dDATA_FIM }

   ENT->(dbSetFilter({|| alltrim(Filial) $ cFILIAL}, 'alltrim(Filial) $ cFILIAL'))

   bSAI_FILTRO := { || SAI->Data_Lanc >= dDATA_INI .and. SAI->Data_Lanc <= dDATA_FIM }

   SAI->(dbSetFilter({|| alltrim(Filial) $ cFILIAL}, 'alltrim(Filial) $ cFILIAL'))

   // ESTABELECE RELACOES ENTRE ARQUIVOS _________________________________________

   select OUTENT
   OUTENT->(dbgotop())

   select OUTSAI
   OUTSAI->(dbgotop())

   //select IMP
   //IMP->(dbgotop())

   if cTIPOPER == "1"
      select SAI
      iif( !l2003 ,SAI->(dbsetorder(3)) ,SAI->(dbsetorder(8)))                             // Codigos Fiscais
      SAI->(dbgotop())
   else
      select SAI
      iif( !l2003 ,SAI->(dbsetorder(5)) ,SAI->(dbsetorder(9)))                             // Codigos Fiscais
      SAI->(dbgotop())
   endif

   if cTIPOPER == "1"
      select ENT
      iif( !l2003 ,ENT->(dbsetorder(3)) ,ENT->(dbsetorder(8)))                             // Codigos Fiscais
      ENT->(dbgotop())
   else
      select ENT
      iif( !l2003 ,ENT->(dbsetorder(4)) ,ENT->(dbsetorder(9)))                             // Codigos Fiscais
      ENT->(dbgotop())
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

      qgirabarra()

      if XPAGINA == 0 .or. prow() > K_MAX_LIN

         qpageprn()

         // CASO IMPRIMA ALGUMA NOTA, NAO IMPRIME CABECALHO FORA DESTE LOOP_______

         lCABECALHO := .F.

         // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

         if nFOLHA <> 0
            XPAGINA = nFOLHA
            nFOLHA  = 0
         endif

         nMES := month(ENT->Data_lanc)

         icm_apuracao(cTITULO,"ENT",nMES, "E N T R A D A S")

      endif

      if l2003 == .F.
         fCOD_FISC := ENT->COD_FISC

         // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________

         do while fCOD_FISC = ENT->COD_FISC

            qgirabarra()

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

                     if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
                        for nCONT := 1 to 5
                             qgirabarra()
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
                  fICM_ISEN += ENT->Icm_Isen
                  fICM_OUT  += ENT->Icm_Out

                  if XTIPOEMP $ "25" // soma substituicao tributaria
                     fICM_SUBS   += SAI->Icm_subst
                     fICM_B_SUBS += SAI->Icm_bc_s
                  endif

                  if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
                     for nCONT := 1 to 5
                         qgirabarra()
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
         fCFOP := ENT->Cfop

         // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________

         do while fCFOP = ENT->Cfop

            qgirabarra()

            if eval(bENT_FILTRO)

               if cTIPOPER == "1"
                  if nMES <> val(str(month(ENT->DATA_LANC),2))
                     lMUDOU_MES := .T.
                     exit
                  endif

                  if !lMUDOU_MES .and. cTIPOPER == "1"
                     qmensa("Imprimindo Codigo Fiscal: "+ENT->Cfop)

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

                     if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
                        for nCONT := 1 to 5
                             qgirabarra()
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
                  fICM_ISEN += ENT->Icm_Isen
                  fICM_OUT  += ENT->Icm_Out

                  if XTIPOEMP $ "25" // soma substituicao tributaria
                     fICM_SUBS   += SAI->Icm_subst
                     fICM_B_SUBS += SAI->Icm_bc_s
                  endif

                  if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie+ENT->Filial))
                     for nCONT := 1 to 5
                         qgirabarra()
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

      if fVLR_CONT > 0
         @ prow()+1,0 say "|" + space(8) + "|" + space(28) + "|" + space(23) + "|" + space(23) + "|" + space(23) + "|" + space(23) + "|"
         @ prow()+1,0 say "| " + iif(l2003,fCFOP,fCod_fisc+" ") + "   |" + space(15) + transform(fVLR_CONT,cPIC1) + "|" + space(10) + transform(fICM_BASE,cPIC1) + "|" +;
                                      space(10) + transform(fICM_VLR,cPIC1 ) + "|" + space(10) + transform(fICM_ISEN,cPIC1) + "|" +;
                                      space(10) + transform(fICM_OUT,cPIC1 ) + "|"
         do case
            case left(iif(l2003,fCFOP,fCOD_FISC),1) == "1"
                 fTOT1CONT += fVLR_CONT
                 fTOT1BASE += fICM_BASE
                 fTOT1CRED  += fICM_VLR
                 fTOT1ISEN += fICM_ISEN
                 fTOT1OUT  += fICM_OUT
            case left(iif(l2003,fCFOP,fCOD_FISC),1) == "2"
                 fTOT2CONT += fVLR_CONT
                 fTOT2BASE += fICM_BASE
                 fTOT2CRED += fICM_VLR
                 fTOT2ISEN += fICM_ISEN
                 fTOT2OUT  += fICM_OUT
            case left(iif(l2003,fCFOP,fCOD_FISC),1) == "3"
                 fTOT3CONT += fVLR_CONT
                 fTOT3BASE += fICM_BASE
                 fTOT3CRED  += fICM_VLR
                 fTOT3ISEN += fICM_ISEN
                 fTOT3OUT  += fICM_OUT
         endcase

      endif

      // ACUMULA TOTAL GERAL E SUB-TOTAIS  _______________________________________

      fTOT_CONT += fVLR_CONT
      fTOT_BASE += fICM_BASE
      fTOT_CRED += fICM_VLR
      fTOT_ISEN += fICM_ISEN
      fTOT_OUT  += fICM_OUT

      fVLR_CONT := 0
      fICM_BASE := 0
      fICM_VLR  := 0
      fICM_ISEN := 0
      fICM_OUT  := 0


   enddo

   @ prow()+1,0 say replicate("_",135)
   @ prow()+2,0 say "SUBTOTAIS DAS ENTRADAS:"
   @ prow()+1,0 say "1.000 - DO ESTADO:" + space(8) + transform(fTOT1CONT,cPIC1) + space(11) + transform(fTOT1BASE,cPIC1) +;
                                       space(11) + transform(fTOT1CRED,cPIC1) + space(11) + transform(fTOT1ISEN,cPIC1) +;
                                       space(11) + transform(fTOT1OUT,cPIC1 )

   @ prow()+2,0  say "2.000 - DE OUTROS " + space(8) + transform(fTOT2CONT,cPIC1) + space(11) + transform(fTOT2BASE,cPIC1) +;
                                       space(11) + transform(fTOT2CRED,cPIC1) + space(11) + transform(fTOT2ISEN,cPIC1) +;
                                       space(11) + transform(fTOT2OUT,cPIC1 )
   @ prow()+1,0  say "ESTADOS          "
   @ prow()+2,0  say "3.000 - DO        " + space(8) + transform(fTOT3CONT,cPIC1) + space(11) + transform(fTOT3BASE,cPIC1) +;
                                       space(11) + transform(fTOT3CRED,cPIC1) + space(11) + transform(fTOT3ISEN,cPIC1) +;
                                       space(11) + transform(fTOT3OUT,cPIC1 )

   @ prow()+1,0  say "EXTERIOR         "

   if ENT->(eof())

      @ prow()+1,0 say replicate("_",135)
      @ prow()+1,0 say "TOTAIS.......:" + space(11) + transform(fTOT_CONT,cPIC1) + space(11) + transform(fTOT_BASE,cPIC1) +;
                                          space(11) + transform(fTOT_CRED,cPIC1) + space(11) + transform(fTOT_ISEN,cPIC1) +;
                                          space(11) + transform(fTOT_OUT,cPIC1 )
      fTOT_CONT := 0
      fTOT_BASE := 0
//    fTOT_CRED := 0
      fTOT_ISEN := 0
      fTOT_OUT  := 0

   endif

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

         icm_apuracao(cTITULO,"ENT",nMES,"E N T R A D A S")
         i_busca_debito()
         ent_grava()
         setprc(56,00)

         nFALTA--
         nMES++

      enddo

   endif

   i_grava_pagina()           // PROGRAMA EF510.PRG

   XPAGINA := 0

   for nCONT := prow() to K_MAX_LIN
       @ prow()+1,nCONT say "*"
   next

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

         icm_apuracao(cTITULO,"SAI",nMES,"S A I D A S")

      endif
      if l2003 == .F.
         fCod_fisc := SAI->COD_FISC

         // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________

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
                           fICM_BASE += SAI->ICM_BASE
                        endif
                     else
                        fICM_BASE += SAI->ICM_BASE
                     endif

                     if XTIPOEMP $ "25" // soma substituicao tributaria
                        fICM_SUBS   += SAI->Icm_subst
                        fICM_B_SUBS += SAI->Icm_bc_s
                     endif

                     fICM_VLR += round(SAI->ICM_VLR,2)
                     fICM_ISEN += SAI->ICM_ISEN
                     fICM_OUT  += SAI->ICM_OUT

                     if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->FILIAL))
                        for nCONT := 1 to 5
                             qgirabarra()
                             aOUTALIQ[nCONT,1] := OUTSAI->ICM_BASE
                             aOUTALIQ[nCONT,2] := OUTSAI->ICM_ALIQ
                             aOUTALIQ[nCONT,3] := OUTSAI->ICM_VLR
                             fICM_BASE += OUTSAI->ICM_BASE
                             fICM_VLR  += OUTSAI->ICM_VLR
                             OUTSAI->(dbskip())
                             if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
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
                        fICM_BASE += SAI->ICM_BASE
                     endif
                  else
                     fICM_BASE += SAI->ICM_BASE
                  endif

                  if XTIPOEMP $ "25" // soma substituicao tributaria
                     fICM_SUBS   += SAI->Icm_subst
                     fICM_B_SUBS += SAI->Icm_bc_s
                  endif

                  fICM_VLR += round(SAI->ICM_VLR,2)
                  fICM_ISEN += SAI->ICM_ISEN
                  fICM_OUT  += SAI->ICM_OUT

                  if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->FILIAL))
                     for nCONT := 1 to 5
                          qgirabarra()
                          aOUTALIQ[nCONT,1] := OUTSAI->ICM_BASE
                          aOUTALIQ[nCONT,2] := OUTSAI->ICM_ALIQ
                          aOUTALIQ[nCONT,3] := OUTSAI->ICM_VLR
                          fICM_BASE += OUTSAI->ICM_BASE
                          fICM_VLR  += OUTSAI->ICM_VLR
                          OUTSAI->(dbskip())
                          if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                             exit
                          endif
                     next
                  endif

               endif

            endif

            SAI->(dbskip())

         enddo
      else
         fCFOP := SAI->Cfop

         // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________

         do while fCFOP = SAI->Cfop

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
                           fICM_BASE += SAI->ICM_BASE
                        endif
                     else
                        fICM_BASE += SAI->ICM_BASE
                     endif

                     if XTIPOEMP $ "25" // soma substituicao tributaria
                        fICM_SUBS   += SAI->Icm_subst
                        fICM_B_SUBS += SAI->Icm_bc_s
                     endif

                     fICM_VLR += round(SAI->ICM_VLR,2)
                     fICM_ISEN += SAI->ICM_ISEN
                     fICM_OUT  += SAI->ICM_OUT

                     if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->FILIAL))
                        for nCONT := 1 to 5
                             qgirabarra()
                             aOUTALIQ[nCONT,1] := OUTSAI->ICM_BASE
                             aOUTALIQ[nCONT,2] := OUTSAI->ICM_ALIQ
                             aOUTALIQ[nCONT,3] := OUTSAI->ICM_VLR
                             fICM_BASE += OUTSAI->ICM_BASE
                             fICM_VLR  += OUTSAI->ICM_VLR
                             OUTSAI->(dbskip())
                             if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                                exit
                             endif
                        next
                     endif
                  endif
               else
                  qmensa("Imprimindo Codigo Fiscal: "+SAI->CFop)

                  fVLR_CONT += SAI->VLR_CONT

                  if XTIPOEMP $ "38"
                     if left(SAI->Num_Nf,2) = "@@"
                        fICM_BASE += SAI->ICM_BASE
                     endif
                  else
                     fICM_BASE += SAI->ICM_BASE
                  endif

                  if XTIPOEMP $ "25" // soma substituicao tributaria
                     fICM_SUBS   += SAI->Icm_subst
                     fICM_B_SUBS += SAI->Icm_bc_s
                  endif

                  fICM_VLR += round(SAI->ICM_VLR,2)
                  fICM_ISEN += SAI->ICM_ISEN
                  fICM_OUT  += SAI->ICM_OUT

                  if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->FILIAL))
                     for nCONT := 1 to 5
                          qgirabarra()
                          aOUTALIQ[nCONT,1] := OUTSAI->ICM_BASE
                          aOUTALIQ[nCONT,2] := OUTSAI->ICM_ALIQ
                          aOUTALIQ[nCONT,3] := OUTSAI->ICM_VLR
                          fICM_BASE += OUTSAI->ICM_BASE
                          fICM_VLR  += OUTSAI->ICM_VLR
                          OUTSAI->(dbskip())
                          if SAI->Num_nf + SAI->Serie + SAI->Filial <> OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
                             exit
                          endif
                     next
                  endif

               endif

            endif

            SAI->(dbskip())

         enddo

      endif
      if fVLR_CONT > 0
         @ prow()+1,0 say "|" + space(8) + "|" + space(28) + "|" + space(23) + "|" + space(23) + "|" + space(23) + "|" + space(23) + "|"
         @ prow()+1,0 say "| " + iif(l2003,fCFOP,fCod_fisc+" ") + "   |" + space(15) + transform(fVLR_CONT,cPIC1) + "|" + space(10) + transform(fICM_BASE,cPIC1) + "|" +;
                                      space(10) + transform(fICM_VLR,cPIC1 ) + "|" + space(10) + transform(fICM_ISEN,cPIC1) + "|" +;
                                      space(10) + transform(fICM_OUT,cPIC1 ) + "|"
         do case
            case left(iif(l2003,fCFOP,fCOD_FISC),1) == "5"
                 fTOT5CONT += fVLR_CONT
                 fTOT5BASE += fICM_BASE
                 fTOT5DEB  += fICM_VLR
                 fTOT5ISEN += fICM_ISEN
                 fTOT5OUT  += fICM_OUT
            case left(iif(l2003,fCFOP,fCOD_FISC),1) == "6"
                 fTOT6CONT += fVLR_CONT
                 fTOT6BASE += fICM_BASE
                 fTOT6DEB  += fICM_VLR
                 fTOT6ISEN += fICM_ISEN
                 fTOT6OUT  += fICM_OUT
            case left(iif(l2003,fCFOP,fCOD_FISC),1) == "7"
                 fTOT7CONT += fVLR_CONT
                 fTOT7BASE += fICM_BASE
                 fTOT7DEB  += fICM_VLR
                 fTOT7ISEN += fICM_ISEN
                 fTOT7OUT  += fICM_OUT
         endcase

      endif

      // ACUMULA TOTAL GERAL E SUB-TOTAIS  _______________________________________

      fTOT_CONT += fVLR_CONT
      //nBASE_CALC +=fVLR_CONT
      fTOT_BASE += fICM_BASE
      fTOT_DEB  += fICM_VLR
      fTOT_ISEN += fICM_ISEN
      fTOT_OUT  += fICM_OUT

      fVLR_CONT := 0
      fICM_BASE := 0
      fICM_VLR  := 0
      fICM_ISEN := 0
      fICM_OUT  := 0

      if lMUDOU_MES .or. SAI->(eof()) .and. cTIPOPER == "1"

         // BUSCA O CREDITO, IMPRIME O TOTAL, O CABECALHO, GRAVA VALORES ___

         busca_credito()
         nMES++

         // PARA IMPRESSAO DO CABECALHO ____________________________________

         setprc(56,00)
         if ! qlineprn() ; return ; endif
         lMUDOU_MES := .F.
         loop

      endif


   enddo

   @ prow()+1,0 say replicate("_",135)
   @ prow()+2,0 say "SUBTOTAIS DAS SAIDAS:"
   @ prow()+1,0 say  "5.000 - P/ O       " + space(8) + transform(fTOT5CONT,cPIC1) + space(11) + transform(fTOT5BASE,cPIC1) +;
                                            space(9) + transform(fTOT5CRED,cPIC1) + space(11) + transform(fTOT5ISEN,cPIC1) +;
                                            space(11) + transform(fTOT5OUT,cPIC1 )
   @ prow()+1,0 say "ESTADO            "

   @ prow()+2,0  say "6.000 - PARA      " + space(8) + transform(fTOT6CONT,cPIC1) + space(11) + transform(fTOT6BASE,cPIC1) +;
                                         space(11) + transform(fTOT6CRED,cPIC1) + space(11) + transform(fTOT6ISEN,cPIC1) +;
                                         space(11) + transform(fTOT6OUT,cPIC1 )
   @ prow()+1,0  say "OUTROS ESTADOS   "

   @ prow()+2,0  say "7.000 - P/ O      " + space(8) + transform(fTOT7CONT,cPIC1) + space(11) + transform(fTOT7BASE,cPIC1) +;
                                         space(11) + transform(fTOT7CRED,cPIC1) + space(11) + transform(fTOT7ISEN,cPIC1) +;
                                       space(11) + transform(fTOT7OUT,cPIC1 )
   @ prow()+1,0  say "EXTERIOR         "

   if SAI->(eof())

      @ prow()+1,0 say replicate("_",135)
      @ prow()+1,0 say "TOTAIS.......:" + space(11) + transform(fTOT_CONT,cPIC1) + space(11) + transform(fTOT_BASE,cPIC1) +;
                                          space(11) + transform(fTOT_DEB,cPIC1)  + space(11) + transform(fTOT_ISEN,cPIC1) +;
                                          space(11) + transform(fTOT_OUT,cPIC1)
      fTOT_CONT := 0
      fTOT_BASE := 0
//    fTOT_DEB  := 0
      fTOT_ISEN := 0
      fTOT_OUT  := 0

   endif

   for nCONT := prow() to K_MAX_LIN
       @ prow()+1,nCONT say "*"
   next

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
         icm_apuracao(cTITULO,"SAI",nMES,"S A I D A S")
         busca_credito()
         setprc(56,00)
         nFALTA--
         nMES++
      enddo
   endif

   i_grava_pagina()           // PROGRAMA EF510.PRG

   eject

   i_resumo()

   qstopprn(.F.)

return
    
//////////////////////////////////////////////////////////////////////////////////
// GRAVA OS VALORES REFERENTES AO ICMS PARA EMISSAO DA GIA OU GIAR _______________

function ent_grava

   local dINICIO, dTERMINO

   dINICIO    := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
   dTERMINO   := dDATA_FIM
   fULT_CALC  := dtos(date()) + "-" + time()
   fAPURADO_E := .T.

   if IMP->(dbseek(K_ICM + dtos(dINICIO) + dtos(dTERMINO) + alltrim(cFILIAL)))
  // public nREG := recno()                    // ALTERADO POR ANDRE SANTOS
      IMP->(qrlock())
     // replace IMP->Icm_Cred  with fTOT_CRED         // total ICMS creditado
     // replace IMP->Icm_Deb   with fTOT_DEB          // total ICMS debitado
     // replace IMP->Ult_calc  with fULT_CALC         // Data e a hora para verificar as ordens de gravacao
     // replace IMP->Apurado_e with fAPURADO_E        // Grava valor verdadeiro por ter operado apuracao
      IMP->(qunlock())

   else
   //   public nREG := recno()
      IMP->(qappend())
     // replace IMP->Codigo    with K_ICM
     // replace IMP->Data_Ini  with dINICIO           // data inicial do periodo
     // replace IMP->Data_Fim  with dTERMINO          // data final do periodo
     // replace IMP->Icm_Cred  with fTOT_CRED         // total ICMS creditado
     // replace IMP->Icm_Deb   with fTOT_DEB          // total ICMS debitado
     // replace IMP->Ult_calc  with fULT_CALC         // Data e a hora para verificar as ordens de gravacao
     // replace IMP->Apurado_e with fAPURADO_E        // Grava valor verdadeiro por ter operado apuracao
     // replace IMP->Filial    with cFILIAL

      IMP->(qunlock())

   endif

return

//////////////////////////////////////////////////////////////////////////////////
// BUSCA O DEBITO DO ICMS PARA APURACAO _________________________________________

static function i_busca_debito

   local dINICIO, dTERMINO

   dINICIO  := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
   dTERMINO := dDATA_FIM//qfimmes(ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4)))

   fTOT_DEB := 0

   // CRIA MACRO DE FILTRO DAS SAIDAS _____________________________________________

   SAI->(dbgotop())

   // SOMA OS TOTAIS DOS DEBITOS PARA APURAR OS SALDOS ____________________________

   do while ! SAI->(eof())

      qgirabarra()

      if eval(bSAI_FILTRO)

         fTOT_DEB += round(SAI->Icm_Vlr,2)
         //fTOT_DEB := round(fTOT_DEB,2)
         //nBASE_CALC += SAI->Vlr_cont
         if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->NUM_NF + SAI->SERIE + SAI->FILIAL))
            for nCONT := 1 to 5
                 qgirabarra()
                 aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
                 aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
                 aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr
                 fTOT_DEB += OUTSAI->Icm_Vlr
                 OUTSAI->(dbskip())
                 if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
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

function icm_apuracao

   parameters cTITULO, cTIPO, nMES, cTIT
   local cOPERACAO, cIMPOSTO, dINICIO, dTERMINO

   cOPERACAO := "debito "
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

   
   @ prow()+1,00  say replicate("-",135)
   @ prow()+1,00   say "|"
   @ prow()  ,10   say cTITULO
   @ prow()  ,134  say "|"
   
   @ prow()+1,00   say "| Empresa...: "+ FILIAL->Razao + space(55)+ "|"
   @ prow()+1,00   say "| Insc. Est.: "+ FILIAL->INSC_ESTAD + "CNPJ    :" + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(78) + "|"

   dDATA_INI_A := ctod("01/01/" + left(XANOMES,4))
   dDATA_FIM_A := ctod("31/12/" + left(XANOMES,4))
   dINICIO  := dDATA_INI_A
   dTERMINO := dDATA_FIM_A
   @ prow()+1,00  say "| Mes ou Periodo/Ano: De " + dtoc(dDATA_INI) + " ate " + dtoc(dDATA_FIM)
   @ prow()  ,124 say "Pag.:" + strzero(nPAG,4) + " |"
   @ prow()+1,00  say replicate("-",135)
   @ prow()+1,00  say "|"
   @ prow()  ,45  say cTIT
   @ prow()  ,134 say "|"
   @ prow()+1,0 say replicate("_",135)
   //@ prow()+1,0 say XCOND1 + "|        |                            |                                               |                                               |"
   @ prow()+1,0 say "| Codigo |                            |       Operacoes com " + cOPERACAO+" do Imposto        |       Operacoes sem " + cOPERACAO + " do Imposto        |"
   @ prow()+1,0 say "|        |       Valor Contabil       |                     ICMS                      |                     ICMS                      |"
   @ prow()+1,0 say "| Fiscal |                            |_______________________________________________|_______________________________________________|"
   @ prow()+1,0 say "|        |                            |    Base de Calculo    |   Imposto " + cIMPOSTO+"   |Isentas/Nao Tributadas |         Outras        |"
   @ prow()+1,0 say replicate("_",135)
   nPAG++
return


//////////////////////////////////////////////////////////////////////////////////
// RESUMO DAS APURACOES __________________________________________________________

function i_resumo

   parameters cTITULO, cTIPO, nMES, cTIT
   local cOPERACAO, cIMPOSTO, dINICIO, dTERMINO

   cOPERACAO := "debito "
   cIMPOSTO  := "creditado"
   cTITULO   := "R E S U M O  D A   A P U R A C A O   D O   I M P O S T O"

   if empty(nMES)
      nMES := 0
   endif

   if nMES > 0
      dINICIO  := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
      dTERMINO := qfimmes(ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4)))
   endif
   cMES := right(XANOMES,2)
   dINI := ctod("01/"+ cMES + "/"+left(XANOMES,4))
   dFIM := qfimmes(ctod("01/"+ cMES + "/"+left(XANOMES,4)))

   cTIT := "D E B I T O S   D O   I M P O S T O"
   //@ prow(),pcol() say XCOND0
   @ prow()+1,00  say replicate("-",135)
   @ prow()+1,00   say "|"
   @ prow()  ,15   say XAENFAT + cTITULO + XDENFAT
   @ prow()  ,135  say "|"
   //@ prow(),pcol() say XCOND0
   @ prow()+1,00   say "| Empresa...: "+ FILIAL->Razao + space(56) + "|"
   @ prow()+1,00   say "| Insc. Est.: "+ FILIAL->INSC_ESTAD + "CNPJ    :" + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(79) + "|"

   dDATA_INI_A := ctod("01/01/" + left(XANOMES,4))
   dDATA_FIM_A := ctod("31/12/" + left(XANOMES,4))
   dINICIO  := dDATA_INI_A
   dTERMINO := dDATA_FIM_A
   nREGS := IMP->(recno())
   IMP->(dbsetorder(1))
   IMP->(dbgotop())
   IMP->(dbseek(K_ICM + dtos(dINI) + dtos(dFIM) + alltrim(cFILIAL)))

   @ prow()+1,00  say "| Mes ou Periodo/Ano: De " + dtoc(dDATA_INI) + " ate " + dtoc(dDATA_FIM)
   @ prow()  ,124 say "Pag..:" + strzero(nPAG,4) + " |"
   @ prow()+1,00  say replicate("-",136)
   @ prow()+1,00  say "|       D E B I T O S   D O   I M P O S T O               | COL.AUXIL.|  SOMAS |"
   @ prow()+1,0 say replicate("-",136)
   @ prow()+1,0 say "|     | 001 - POR SAIDAS/PRESTACOES C/ DEB. DO IMPOSTO    |"
   @ prow()  ,123 say transform(fTOT_DEB,cPIC1)
   @ prow()+1,0 say "|  D  | 002 - OUTROS DEBITOS (DISCRIMINAR ABAIXO)         |"
   @ prow()  ,123 say transform(IMP->Icm_out_db,cPIC1)
   @ prow()+1,0 say "|  E  |       "+iif(!empty(IMP->Icm_doutdb),left(IMP->Icm_doutdb,40),"........................................") +"    |"
   @ prow()+1,0 say "|  B  |       ........................................    |"
   @ prow()+1,0 say "|  I  | 003 - ESTORNO DE CREDITOS (DISCRIMINAR ABAIXO)    |"
   @ prow()  ,123 say  transform(IMP->Icm_est_cd,cPIC1)
   @ prow()+1,0 say "|  T  |       "+iif(!empty(IMP->Icm_destcd),left(IMP->Icm_destcd,40),"........................................") +"    |"
   @ prow()+1,0 say "|  O  |       ........................................    |"
   @ prow()+1,0 say "|     | 004 - SUBTOTAL................................    |"
   fTOT_DEB := fTOT_DEB + (IMP->Icm_out_db + IMP->Icm_est_cd)
   @ prow()  ,123 say transform(fTOT_DEB,cPIC1)
   @ prow()+1,0 say replicate("-",136)
   @ prow()+1,00  say "|       C R E D I T O S    D O   I M P O S T O            |           |        |"
   @ prow()+1,0 say replicate("-",136)
   @ prow()+1,0 say "|     | 005 - P/ENTRADAS/PREST. C/ CREDITO DO IMPOSTO     |"
   @ prow()  ,123 say transform(fTOT_CRED,cPIC1)
   @ prow()+1,0 say "|  C  | 006 - OUTROS CREDITOS (DISCRIMINAR ABAIXO)        |"
   @ prow()  ,123 say transform(IMP->Icm_out_cd,cPIC1)
   @ prow()+1,0 say "|  R  |       "+iif(!empty(IMP->Icm_doutcd),left(IMP->Icm_doutcd,40),"........................................") +"    |"
   @ prow()+1,0 say "|  E  |       .......................................     |"
   @ prow()+1,0 say "|  D  | 007 - ESTORNO DE DEBITOS (DISCRIMINAR ABAIXO)     |"
   @ prow()  ,123 say  transform(IMP->Icm_est_db,cPIC1)
   @ prow()+1,0 say "|  I  |       "+iif(!empty(IMP->Icm_destdb),left(IMP->Icm_destdb,40),"........................................") +"    |"
   @ prow()+1,0 say "|  T  |       .......................................     |"
   @ prow()+1,0 say "|  O  | 008 - SUBTOTAL...............................     |"
   fTOT_CRED := fTOT_CRED + (IMP->Icm_out_cd + IMP->Icm_est_db)
   @ prow()  ,123 say transform(fTOT_CRED,cPIC1)
   @ prow()+1,0 say "|     | 009 - SALDO CREDOR DO PERIODO ANTERIOR.......     |"
   @ prow()  ,123 say transform(i_icm_sld_anter(),cPIC1)

   @ prow()+1,0 say "|     | 010 - TOTAL..................................     |"
   @ prow()  ,123 say transform(fTOT_CRED + i_icm_sld_anter(),cPIC1)
   @ prow()+1,0 say replicate("-",136)
   @ prow()+1,00  say "|       A P U R A C A O   D O   S A L D O                 |           |        |"
   @ prow()+1,0 say replicate("-",136)
   @ prow()+1,0 say "|     | 011 - SALDO DEVEDOR (DEBITO MENOS CREDITO)....     |"
   if (fTOT_DEB - fTOT_CRED) > 0
      @ prow()  ,123 say transform(fTOT_DEB - fTOT_CRED,cPIC1)
   endif
   @ prow()+1,0 say "|  S  | 012 - DEDUCOES (DISCRIMINAR ABAIXO)...........     |"
   @ prow()+1,0 say "|  A  |       ........................................     |"
   @ prow()+1,0 say "|  L  |       ........................................     |"
   @ prow()+1,0 say "|  D  | 013 - IMPOSTO A RECOLHER......................     |"

   if CONFIG->Tipo_est != "D"
      if  l2003
         IMP->(dbsetorder(1))
         IMP->(dbgotop())
         if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(dDATA_FIM) + alltrim(cFILIAL)))
            fDEBITO := IMP->Icm_deb
            qmensa(K_ICM + " MES: "+Dtos(dDATA_INI) + "FIM: "+dtos(dDATA_FIM) +" "+cFILIAL)
         else
            qmensa("NÆo encontrado o registro!")
            qinkey(0)
            qmensa(K_ICM + " MES: "+Dtos(dDATA_INI) + "FIM: "+dtos(dDATA_FIM) +" "+cFILIAL)

         endif


         //if fDEBITO  > 0
            @ prow()  ,123 say transform(fDEBITO, cPIC1)
         //endif

      endif


   else
      if (fTOT_DEB - (fTOT_CRED + i_icm_sld_anter()) ) > 0
         @ prow()  ,123 say transform(fTOT_DEB - (fTOT_CRED+i_icm_sld_anter()),cPIC1)
      endif
   endif
   @ prow()+1,0 say "|  O  | 014 - SALDO CREDOR (CREDITO MENOS DEBITO)          |"
   @ prow()+1,0 say "|     |       A TRANSPORTAR PARA O PERIODO SEGUINTE....    |"
   if (fTOT_DEB - (fTOT_CRED+i_icm_sld_anter()) ) < 0
      @ prow()  ,123 say transform((fTOT_DEB - fTOT_CRED) * -1 + i_icm_sld_anter(),cPIC1)
   endif
   @ prow()+1,0 say replicate("-",136)
   nPAG++
   for nCONT := prow() to K_MAX_LIN
       @ prow()+1,nCONT say "*"
   next
   IMP->(dbgoto(nREGS))

return


//////////////////////////////////////////////////////////////////////////////////
// BUSCA TOTAL DE CREDITO DO ICMS ________________________________________________

static function busca_credito

   local dINICIO, dTERMINO

   dINICIO  := ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4))
   dTERMINO := qfimmes(ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4)))

   fTOT_CRED := 0

   // CRIA MACRO DE FITRO DAS ENTRADAS ___________________________________________

   ENT->(dbgotop())

   // SOMA OS TOTAIS DOS CREDITOS_________________________________________________

   do while ! ENT->(eof())   // condicao principal de loop

      qgirabarra()

      if eval(bENT_FILTRO)

         fTOT_CRED += round(ENT->ICM_VLR,2)

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
      endif

      ENT->(dbskip())

   enddo

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR SALDO CREDOR ANTERIOR DE ICMS ___________________________

function i_icm_sld_anter

   local dINI_ANTER, dFIM_ANTER, cMES_ANTERIOR, cANO_ANTERIOR, nREC

   fICM_TRANSP   := 0
   cMES_ANTERIOR := val(right(XANOMES,2)) - 1
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
// IMP->(dbgotop())
   IMP->(dbsetorder(1))
   if IMP->(dbseek(K_ICM + dtos(dINI_ANTER) + dtos(dFIM_ANTER)+alltrim(cFILIAL)))
       if IMP->Codigo == K_ICM .and. IMP->Data_ini == dINI_ANTER .and. IMP->Data_fim == dFIM_ANTER .and. IMP->Filial == alltrim(cFILIAL)
          if IMP->IMP_VALOR < 0
             fICM_TRANSP := (IMP->IMP_VALOR * -1)
          endif
       else
          alert("SALDO ANTERIOR COM PROBLEMAS !;SE FOR PRIMEIRO MES DE LANCAMENTO DESTA EMPRESA, CONTINUE.;SE NAO, VERIFIQUE SE FOI APURADO OS MESES ANTERIORES.",{"OK"})
       endif
   endif
   IMP->(dbgoto(nREC))

return fICM_TRANSP

