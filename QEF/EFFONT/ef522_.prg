//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: APURACAO DE SAIDAS IPI
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........: ATUALIZA CREDITOS DO IPI
// ALTERACOES.:
function ef522

#define K_MAX_LIN 55

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS _______________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private sBLOC1 := qlbloc("B522A","QBLOC.GLO") // Periodo de impressao

private cPIC1  := "@E 99,999,999.99"

private lCABECALHO := .T.            // imprime cabecalho caso nao tenha notas
private cTITULO                      // titulo do relatorio
private bFILTRO                      // code block de filtro
private aEDICAO    := {}             // vetor para os campos de entrada de dados

private nFOLHA                       // Numero da folha
private fCOD_FISC                    // Codigo fiscal natureza de operacao
private fCFOP                        // Codigo fiscal natureza de operacao
private fVLR_CONT                    // total valor contabil por natureza de operacao
private fIPI_BASE                    // total base de ipi
private fIPI_VLR                     // total imposto creditado
private fIPI_ISEN                    // total isentos ipi
private fIPI_OUT                     // total outras ipi
private fTOT_CONT                    // total geral valor contabil
private fTOT_BASE                    // total geral base de ipi
private fTOT_VLR                     // total geral imposto creditado
private fTOT_ISEN                    // total geral isentos ipi
private fTOT_OUT                     // total geral outras ipi
private fDEBITOS                     // total de debitos
private fCREDITOS                    // total de creditos

private dDATA_INI                     // Inicio do periodo do relatorio
private dDATA_FIM                     // Fim do periodo do relatorio

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

   qlbloc(5,0,"B522A","QBLOC.GLO",1)
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@nFOLHA      ,"@E 9999",NIL,NIL) } ,"FOLHA"   })

do while .T.

   XNIVEL      := 1
   XFLAG       := .T.
   fVLR_CONT   := 0
   fIPI_BASE   := 0
   fIPI_VLR    := 0
   fIPI_ISEN   := 0
   fIPI_OUT    := 0
   fTOT_CONT   := 0
   fTOT_BASE   := 0
   fTOT_VLR    := 0
   fTOT_ISEN   := 0
   fTOT_OUT    := 0
   fIPI_TOTAL  := 0
   fDEBITOS    := 0
   fCREDITOS   := 0
   fIPI_TRANSP := 0

   nFOLHA      := val(XIPI_AP_SAI)

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

enddo

//////////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA __________________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "DATA_INI" .and. CONFIG->Ipi_desc $ "S "
           if empty(dDATA_INI) ; return .F. ; endif
           if strzero(day(dDATA_INI),2) $ "01_11"
              dDATA_FIM = (dDATA_INI + 9)
           endif
           if strzero(day(dDATA_INI),2) $ "21"
              dDATA_FIM = qfimmes(ctod("01/" + str(month(dDATA_INI)) + "/" + str(year(dDATA_INI))))
           endif
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_INI" .and. CONFIG->Ipi_desc == "N"
           if empty(dDATA_INI) ; return .F. ; endif
           dDATA_FIM = qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if !strzero(day(dDATA_FIM),2) $ "10_20" + strzero(day(qfimmes(dDATA_FIM)),2)
              qmensa("Data final inv lida para apura‡„o do IPI ! Redigite. ", "B")
              return .F.
           endif
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

   cTITULO := "APURACAO DE SAIDAS - IPI "

   qmensa("")

   // CRIA MACRO DE FILTRO _______________________________________________________

   bFILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS _________________________________________

   select IMP
   IMP->(dbgotop())

   select SAI
   if val(left(CONFIG->Anomes,4)) < 2003
      SAI->(dbsetorder(3))                  // Mes do lancamento + Codigos Fiscais
      SAI->(dbgotop())
   else
      SAI->(dbsetfilter({||SAI->Data_Lanc >= dDATA_INI .and. SAI->Data_Lanc <= dDATA_FIM},'SAI->Data_Lanc >= dDATA_INI .and. SAI->Data_Lanc <= dDATA_FIM'))
      SAI->(dbsetorder(8))                  // Mes do lancamento + Codigos Fiscais
      SAI->(dbgotop())
   endif

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _______________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND2

   do while ! SAI->(eof())               // condicao principal de loop

      if XPAGINA == 0 .or. prow() > K_MAX_LIN

         qpageprn()

         // CASO IMPRIMA ALGUMA NOTA, NAO IMPRIME CABECALHO FORA DESTE LOOP_______

         lCABECALHO := .F.

         // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

         if nFOLHA <> 0
            XPAGINA = nFOLHA
            nFOLHA  = 0
         endif

         i_ipi_apur(cTITULO,"SAI")

      endif
      if val(left(CONFIG->Anomes,4)) < 2003
         fCod_fisc := SAI->COD_FISC

         // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________

         do while fCOD_FISC = SAI->COD_FISC

            //qgirabarra()

            if eval(bFILTRO)

               qmensa("Imprimindo Codigo Fiscal: "+SAI->Cod_Fisc)

               fVLR_CONT += SAI->VLR_CONT
               fIPI_BASE += SAI->IPI_BASE
               fIPI_VLR  += SAI->IPI_VLR
               fIPI_ISEN += SAI->IPI_ISEN
               fIPI_OUT  += SAI->IPI_OUT

            endif

            SAI->(dbskip())

         enddo
      else
         fCFOP := SAI->CFOP

         // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________

         do while fCFOP = SAI->CFOP

            //qgirabarra()

            if eval(bFILTRO)

               qmensa("Imprimindo Codigo Fiscal: "+SAI->Cfop)

               fVLR_CONT += SAI->VLR_CONT
               fIPI_BASE += SAI->IPI_BASE
               fIPI_VLR  += SAI->IPI_VLR
               fIPI_ISEN += SAI->IPI_ISEN
               fIPI_OUT  += SAI->IPI_OUT

            endif

            SAI->(dbskip())

         enddo
      endif
      if val(left(CONFIG->Anomes,4)) < 2003

         if fVLR_CONT > 0
            @ prow()+2,4 say fCod_fisc + space(19) + transform(fVLR_CONT,cPIC1) + space(13) + transform(fIPI_BASE,cPIC1) +;
                                         space(11) + transform(fIPI_VLR,cPIC1 ) + space(12) + transform(fIPI_ISEN,cPIC1) +;
                                         space(11) + transform(fIPI_OUT,cPIC1 )
         endif
      else
         if fVLR_CONT > 0
            @ prow()+2,4 say fCFOP   + space(18) + transform(fVLR_CONT,cPIC1) + space(13) + transform(fIPI_BASE,cPIC1) +;
                                         space(11) + transform(fIPI_VLR,cPIC1 ) + space(12) + transform(fIPI_ISEN,cPIC1) +;
                                         space(11) + transform(fIPI_OUT,cPIC1 )
         endif
      endif
      // ACUMULA TOTAL GERAL E SUB-TOTAIS  _______________________________________

      fTOT_CONT += fVLR_CONT
      fTOT_BASE += fIPI_BASE
      fTOT_VLR  += fIPI_VLR
      fTOT_ISEN += fIPI_ISEN
      fTOT_OUT  += fIPI_OUT

      if fVLR_CONT > 0
         @ prow()+1,4 say "Sub-Total.:" + space(11) + transform(fVLR_CONT,cPIC1) + space(13) + transform(fIPI_BASE,cPIC1) +;
                                          space(11) + transform(fIPI_VLR,cPIC1 ) + space(12) + transform(fIPI_ISEN,cPIC1) +;
                                          space(11) + transform(fIPI_OUT,cPIC1 )
      endif

      fVLR_CONT := 0
      fIPI_BASE := 0
      fIPI_VLR  := 0
      fIPI_ISEN := 0
      fIPI_OUT  := 0

      //if ! qlineprn() ; return ; endif

   enddo

   // IMPRIME CABECALHO QUANDO NAO ENTRA NO while ACIMA __________________________
   if lCABECALHO
      XPAGINA := nFOLHA
      i_ipi_apur(cTITULO,"ENT")
   endif

   @ prow()+1,4 say replicate("_",135)
   @ prow()+1,4 say "Total Geral..:" + space(08) + transform(fTOT_CONT,cPIC1) + space(13) + transform(fTOT_BASE,cPIC1) +;
                                       space(11) + transform(fTOT_VLR,cPIC1)  + space(12) + transform(fTOT_ISEN,cPIC1) +;
                                       space(11) + transform(fTOT_OUT,cPIC1)

   // GRAVA DADOS DO IPI e MANTEM POSICIONADO O REGISTRO P/ GRAVAR A APURACAO ____

   i_sai_ipi_grava()

   @ prow(),pcol() say XCOND0
   @ prow()+2,29 say "APURACAO DOS SALDOS"
   @ prow(),pcol() say XCOND2

   fDEBITOS  := (IMP->IPI_DEB  + IMP->IPI_OUT_DB + IMP->IPI_EST_CD)
   fCREDITOS := (IMP->IPI_CRED + IMP->IPI_OUT_CD + IMP->IPI_EST_DB)

   if fCREDITOS <= fDEBITOS

      // DEBITO(RECOLHE) - CREDITO(TRANSPORTA) ___________________________________

      fIPI_TOTAL = (fDEBITOS - fCREDITOS)

      @ prow()+2,4 say "SALDO DEVEDOR (DEBITO MENOS CREDITO)...:" + space(81) + transform(fIPI_TOTAL,cPIC1)

      // SALDO CREDOR MES ANTERIOR _______________________________________________

      @ prow()+1,4 say "SALDO CREDOR ANTERIOR .................:" + space(81) + transform(i_ipi_sald_anter(dDATA_INI),cPIC1)

      // SE TOTAL DE DEBITOS > CREDITO ANTERIOR, DIMINUI CREDITO ANTERIOR ________

      if fIPI_TOTAL >= fIPI_TRANSP

         // GRAVA VALOR DO IPI NO ARQUIVO DARF, PARA EMISSAO DO DARF _____________

         if abs(fIPI_TOTAL - fIPI_TRANSP) > 0
            i_ipi_darf( fIPI_TOTAL - fIPI_TRANSP )
         endif

         @ prow()+2,4 say "IMPOSTO A RECOLHER.....................:" + transform(fIPI_TOTAL - fIPI_TRANSP,cPIC1)

         IMP->(qrlock())
         replace IMP->IMP_VALOR  with (fIPI_TOTAL - fIPI_TRANSP)
         IMP->(qunlock())

      else

         @ prow()+2,4 say "SALDO CREDOR A TRANSPORTAR PARA O MES SEGUINTE.:" + transform(fIPI_TRANSP - fIPI_TOTAL,cPIC1)

         // GRAVA SALDO CREDOR ___________________________________________________

         IMP->(qrlock())
         replace IMP->IMP_VALOR with ((fIPI_TRANSP - fIPI_TOTAL) * -1)
         IMP->(qunlock())

      endif

   endif

   if fCREDITOS > fDEBITOS

      // CREDITO - DEBITO ________________________________________________________

      fIPI_TOTAL = (fCREDITOS - fDEBITOS)

      @ prow()+2,4 say "SALDO CREDOR (CREDITO MENOS DEBITO)....:" + space(81) + transform(fIPI_TOTAL,cPIC1)

      // SALDO CREDOR MES ANTERIOR _______________________________________________

      @ prow()+1,4 say "SALDO CREDOR ANTERIOR .................:" + space(81) + transform(i_ipi_sald_anter(dDATA_INI),cPIC1)

      @ prow()+2,4 say "SALDO CREDOR A TRANSPORTAR PARA O MES SEGUINTE.:" + transform(fIPI_TOTAL + fIPI_TRANSP,cPIC1)

      // GRAVAR SALDO CREDOR  COM VALOR NEGATIVO _________________________________

      IMP->(qrlock())
      replace IMP->IMP_VALOR with ((fIPI_TRANSP + fIPI_TOTAL) * -1)
      IMP->(qunlock())

   endif

   // PROGRAMA EF510.PRG : GRAVA PAGINA DO RELATORIO _____________________________

   i_grava_pagina()
   qstopprn()

return

//////////////////////////////////////////////////////////////////////////////////
// GRAVA OS VALORES REFERENTES AO IPI  (DEBITO) __________________________________

function i_sai_ipi_grava()

   local dDATA_GRAVA, cDIA

   // dDATA_GRAVA tem o 1§ dia do mes do periodo final
   // Ex.: Periodo de 01/01/95 a 30/04/95
   //      Š gravado  21/04/95 a 30/04/95

   cDIA := day(dDATA_FIM)

   // BUSCA INICIO DO PRIMEIRO DECENDIO __________________________________________

   if cDIA == 10
      cDIA = 1
   endif

   // BUSCA INICIO DO SEGUNDO DECENDIO ___________________________________________

   if cDIA == 20
      cDIA = 11
   endif

   // BUSCA INICIO DO TERCEIRO DECENDIO __________________________________________

   if cDIA ==  day(qfimmes(dDATA_FIM))
      cDIA = 21
   endif

   if CONFIG->Ipi_desc == "N"
      cDIA := day(qinimes(dDATA_FIM))
   endif

   cDIA := strzero(cDIA,2)

   dDATA_GRAVA := ctod(cDIA + "/" + strzero(month(dDATA_FIM),2) + "/" + substr(str(year(dDATA_FIM),4),3,2))

   if IMP->(dbseek(K_IPI + dtos(dDATA_GRAVA) + dtos(dDATA_FIM)))
      IMP->(qrlock())
      replace IMP->IPI_DEB with fTOT_VLR              // total IPI creditado
      IMP->(qunlock())
   else
      IMP->(qappend())
      replace IMP->Codigo   with K_IPI
      replace IMP->DATA_INI with dDATA_GRAVA          // data inicial do periodo
      replace IMP->DATA_FIM with dDATA_FIM            // data final do periodo
      replace IMP->IPI_DEB  with fTOT_VLR             // total IPI debitado
      replace IMP->Filial   with "0001"
      IMP->(qunlock())
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR SALDO CREDOR ANTERIOR DE IPI ____________________________

function i_ipi_sald_anter ( dINICIO )

   local dINI_ANTER , dFIM_ANTER , cMES_ANTERIOR, cANO_ANTERIOR, nREC
   local cDIA_ANTERIOR, nVARTMP

   // dINI_ANTER e dFIM_ANTER RECEBEM AS DATAS DO INICIO E FIM DO PERIODO ANTERIOR

   cDIA_ANTERIOR := val(str(day(dINICIO)))-1
   if CONFIG->Ipi_desc == "N"
       cMES_ANTERIOR := val(str(month(dINICIO)))-1
   else
       cMES_ANTERIOR := val(str(month(dINICIO)))
   endif
   cANO_ANTERIOR := val(substr(str(year(dINICIO)),4,4))

   // CASO SEJA 01/01/9999 _______________________________________________________

   if (cMES_ANTERIOR -1) == 0 .and. cDIA_ANTERIOR = 0
      cMES_ANTERIOR = 12
      cANO_ANTERIOR--
   endif

   // BUSCA PRIMEIRO DECENDIO ____________________________________________________

   if cDIA_ANTERIOR == 10
      cDIA_ANTERIOR = 1
   endif

   // BUSCA SEGUNDO DECENDIO _____________________________________________________

   if cDIA_ANTERIOR == 20
      cDIA_ANTERIOR = 11
   endif

   nVARTMP := iif ( cMES_ANTERIOR == 12 , 13 , 12 )

   // BUSCA TERCEIRO DECENDIO ____________________________________________________

   if cDIA_ANTERIOR == 0 .and. CONFIG->Ipi_desc == "S"
      cDIA_ANTERIOR = 21
       if cMES_ANTERIOR # nVARTMP                // modificado 21/12/95, colocar 13 para transportar de mes 11 para 12
          cMES_ANTERIOR--
          if nVARTMP == 13 .and. val(str(month(dINICIO))) == 1
            cMES_ANTERIOR = 12
          endif
       endif
   endif

   cDIA_ANTERIOR := strzero(cDIA_ANTERIOR,2)
   cMES_ANTERIOR := strzero(cMES_ANTERIOR,2)
   cANO_ANTERIOR := strzero(cANO_ANTERIOR,4)

   dINI_ANTER := ctod(cDIA_ANTERIOR + "/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR)

   // MONTA DATA FINAL DO SALDO CREDOR ANTERIOR __________________________________

   if val(cDIA_ANTERIOR) = 21
      dFIM_ANTER := qfimmes(ctod(cDIA_ANTERIOR + "/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR))
   else
      // SOMA 9 DIAS AO INICIO DO PERIODO DO SALDO CREDOR
      cDIA_ANTERIOR := strzero((val(cDIA_ANTERIOR) + 9),2)
      dFIM_ANTER := ctod(cDIA_ANTERIOR + "/" + cMES_ANTERIOR + "/" + cANO_ANTERIOR)
   endif

   if CONFIG->Ipi_desc == "N"
      dFIM_ANTER := qfimmes(dFIM_ANTER)
      dINI_ANTER := qinimes(dFIM_ANTER)
   endif

   nREC := IMP->(recno())

   // TRAZ SALDO CREDOR, PASSANDO PARA VALOR POSITIVO ____________________________

   if IMP->(dbseek(K_IPI + dtos(dINI_ANTER) + dtos(dFIM_ANTER) + "0001"))
//    fIPI_TRANSP := IMP->IPI_TRANSP
      if IMP->IMP_VALOR < 0
         fIPI_TRANSP := (IMP->IMP_VALOR * -1)
      endif
   endif

   IMP->(dbgoto(nREC))

return fIPI_TRANSP


//////////////////////////////////////////////////////////////////////////////////
// GRAVA VALOR DO IPI NO ARQUIVO DARF, PARA EMISSAO DO DARF ______________________

function i_ipi_darf( nVALOR_REC )

   local dDATA_GRAVA, dINICIO, dFINAL, cDIA, nUFIR := 0, nVALOR_UFIR := 0

   // dDATA_GRAVA tem o 1§ dia do mes do periodo final
   // Ex.: Periodo de 01/01/95 a 30/04/95
   //      Š gravado  21/04/95 a 30/04/95

   cDIA := day(dDATA_FIM)

   // BUSCA INICIO DO PRIMEIRO DECENDIO __________________________________________

   if cDIA == 10
      cDIA = 1
   endif

   // BUSCA INICIO  DO SEGUNDO DECENDIO __________________________________________

   if cDIA == 20
      cDIA = 11
   endif

   // BUSCA INICIO DO TERCEIRO DECENDIO __________________________________________

   if cDIA ==  day(qfimmes(dDATA_FIM))
      cDIA = 21
   endif

   if CONFIG->Ipi_desc == "N"
      cDIA := day(qinimes(dDATA_FIM))
   endif
   
   cDIA := strzero(cDIA,2)

   dDATA_GRAVA := ctod(cDIA + "/" + strzero(month(dDATA_FIM),2) + "/" + substr(str(year(dDATA_FIM),4),3,2))

   // DATA PARA BUSCAR UFIR ______________________________________________________

   dINICIO := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dFINAL  := qfimmes(ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4)))

   // CALCULA VALOR DO IMPOSTO EM UFIR'S _________________________________________

   if BASE->(dbseek(dtos(dINICIO) + dtos(dFINAL)))
      nUFIR := BASE->Ufir_1

      // PARA EVITAR DIVISAO POR ZERO ____________________________________________

      if nUFIR = 0; nUFIR := 1; endif
      nVALOR_UFIR := nVALOR_REC / nUFIR
   endif

   if DARF->(dbseek(dtos(dDATA_GRAVA) + dtos(dDATA_FIM)))
      DARF->(qrlock())
      replace DARF->VALOR      with nVALOR_REC           // Valor do IPI a recolher no DARF
      replace DARF->VALOR_UFIR with nVALOR_UFIR          // Valor do IPI a recolher no DARF em ufir's
      DARF->(qunlock())
   else
      DARF->(qappend())
      replace DARF->DATA_INI   with dDATA_GRAVA          // data inicial do periodo
      replace DARF->DATA_FIM   with dDATA_FIM            // data final do periodo
      replace DARF->COD_TRIB   with K_IPI                // Codigo do tributo
      replace DARF->VALOR      with nVALOR_REC           // Valor do IPI a recolher no DARF
      replace DARF->VALOR_UFIR with nVALOR_UFIR          // Valor do IPI a recolher no DARF em ufir's
      DARF->(qunlock())

   endif

return
