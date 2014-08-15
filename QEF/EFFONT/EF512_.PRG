//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: APURACAO DE ENTRADA IPI
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........: ATUALIZA DEBITOS DO IMPOSTO (IPI_DEB)
// ALTERACOES.:
function ef512

#define K_MAX_LIN 55

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS _______________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private sBLOC1 := qlbloc("B512A","QBLOC.GLO") // Periodo de impressao

private cPIC1  := "@E 99,999,999.99"

private lCABECALHO := .T.            // imprime cabecalho caso nao tenha notas
private cTITULO                      // titulo do relatorio
private bENT_FILTRO                  // code block de filtro entradas
private bSAI_FILTRO                  // code block de filtro saidas

private aEDICAO := {}                // vetor para os campos de entrada de dados

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
private fTOT_CRED                    // total geral imposto creditado
private fTOT_ISEN                    // total geral isentos ipi
private fTOT_OUT                     // total geral outras ipi
private fTOT_DEB                     // total de debitos

private dDATA_INI                    // Inicio do periodo do relatorio
private dDATA_FIM                    // Fim do periodo do relatorio

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
                   
private fIpi_Out_Db                  // Outros Debitos
private fIpi_DoutDb                  // Descricao outros debitos
private fIpi_Out_Cd                  // Outros creditos
private fIpi_DoutCd                  // Descricao outros creditos
private fIpi_Est_Cd                  // Estornos Creditos
private fIpi_DestCd                  // Descricao estornos creditos
private fIpi_Est_Db                  // Estornos debitos
private fIpi_DestDb                  // Descricao estornos debitos

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

   qlbloc(5,0,"B512A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@nFOLHA      ,"@E 9999",NIL,NIL) } ,"FOLHA"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fIpi_Out_Db ,"@E 999,999,999.99" ) } ,"IPI_OUT_DB" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIpi_DoutDb ,"@!@S40"            ) } ,"IPI_DOUTDB" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIpi_Out_Cd ,"@E 999,999,999.99" ) } ,"IPI_OUT_CD" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIpi_DoutCd ,"@!@S40"            ) } ,"IPI_DOUTCD" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIpi_Est_Cd ,"@E 999,999,999.99" ) } ,"IPI_EST_CD" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIpi_DestCd ,"@!@S40"            ) } ,"IPI_DESTCD" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIpi_Est_Db ,"@E 999,999,999.99" ) } ,"IPI_EST_DB" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIpi_DestDb ,"@!@S40"            ) } ,"IPI_DESTDB" })

do while .T.

   XNIVEL := 1
   XFLAG  := .T.

   nFOLHA := val(XIPI_AP_ENT)

   dDATA_INI := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM := qfimmes(dDATA_INI)

   fVLR_CONT := 0
   fIPI_BASE := 0
   fIPI_VLR  := 0
   fIPI_ISEN := 0
   fIPI_OUT  := 0
   fTOT_CONT := 0
   fTOT_BASE := 0
   fTOT_CRED := 0
   fTOT_ISEN := 0
   fTOT_OUT  := 0
   fTOT_DEB  := 0

   fIpi_Out_Db := 0
   fIpi_DoutDb := space(80)
   fIpi_Out_Cd := 0
   fIpi_DoutCd := space(80)
   fIpi_Est_Cd := 0
   fIpi_DestCd := space(80)
   fIpi_Est_Db := 0
   fIpi_DestDb := space(80)

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
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

           if IMP->(dbseek(K_IPI + dtos(dDATA_INI) + dtos(dDATA_FIM)))

              fIpi_Out_Db := IMP->IPI_OUT_DB
              fIpi_DoutDb := IMP->IPI_DOUTDB
              fIpi_Out_Cd := IMP->IPI_OUT_CD
              fIpi_DoutCd := IMP->IPI_DOUTCD
              fIpi_Est_Cd := IMP->IPI_EST_CD
              fIpi_DestCd := IMP->IPI_DESTCD
              fIpi_Est_Db := IMP->IPI_EST_DB
              fIpi_DestDb := IMP->IPI_DESTDB

              nCONT := 4

              qrsay ( nCONT++ , IMP->Ipi_Out_Db , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Ipi_DoutDb , "@!@S40"            )
              qrsay ( nCONT++ , IMP->Ipi_Out_Cd , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Ipi_DoutCd , "@!@S40"            )
              qrsay ( nCONT++ , IMP->Ipi_Est_Cd , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Ipi_DestCd , "@!@S40"            )
              qrsay ( nCONT++ , IMP->Ipi_Est_Db , "@E 999,999,999.99" )
              qrsay ( nCONT++ , IMP->Ipi_DestDb , "@!@S40"            )

           endif
   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ________________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ___________________________________________________

   cTITULO := "APURACAO DE ENTRADA - IPI  "

   qmensa("")

   // CRIA MACRO DE FILTRO _______________________________________________________

   bENT_FILTRO := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS _________________________________________

   select IMP
   IMP->(dbgotop())

   select SAI
   SAI->(dbsetorder(3))              // Mes do lancamento + Codigos Fiscais
   SAI->(dbgotop())

   select ENT
   if val(left(CONFIG->Anomes,4)) < 2003
      ENT->(dbsetorder(3))                          // Codigos Fiscais
      ENT->(dbgotop())
   else
      ENT->(dbsetfilter({||ENT->Data_Lanc >= dDATA_INI .and. ENT->Data_Lanc <= dDATA_FIM},'ENT->Data_Lanc >= dDATA_INI .and. ENT->Data_Lanc <= dDATA_FIM'))
      ENT->(dbsetorder(8))                          // Codigos Fiscais
      ENT->(dbgotop())
   endif

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _______________________________

static function i_impressao

   // SOMA OS TOTAIS DOS DEBITOS PARA APURAR OS SALDOS ___________________________

   do while ! SAI->(eof())           // condicao principal de loop

      qgirabarra()

      if eval(bSAI_FILTRO)
         fTOT_DEB += SAI->IPI_VLR
      endif

      SAI->(dbskip())

   enddo

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND2

   do while ! ENT->(eof())           // condicao principal de loop

      if XPAGINA == 0 .or. prow() > K_MAX_LIN

         qpageprn()

         // CASO IMPRIMA ALGUMA NOTA, NAO IMPRIME CABECALHO FORA DESTE LOOP ______

         lCABECALHO := .F.

         // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA _________________________

         if nFOLHA <> 0
            XPAGINA = nFOLHA
            nFOLHA  = 0
         endif

         i_ipi_apur(cTITULO,"ENT")

      endif
      if val(left(CONFIG->Anomes,4 )) < 2003
         fCod_fisc := ENT->COD_FISC

         // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________

         do while fCOD_FISC = ENT->COD_FISC

            qgirabarra()

            if eval(bENT_FILTRO)

               qmensa("Imprimindo Codigo Fiscal: "+ENT->Cod_Fisc)

               fVLR_CONT += ENT->VLR_CONT
               fIPI_BASE += ENT->IPI_BASE
               fIPI_VLR  += ENT->IPI_VLR
               fIPI_ISEN += ENT->IPI_ISEN
               fIPI_OUT  += ENT->IPI_OUT

            endif

            ENT->(dbskip())

         enddo
      else
         fCFOP := ENT->Cfop

         // ACUMULA TOTAIS POR NATUREZA DE OPERACAO _________________________________

         do while fCFOP = ENT->CFOP

            qgirabarra()

            if eval(bENT_FILTRO)

               qmensa("Imprimindo Codigo Fiscal: "+ENT->Cfop)

               fVLR_CONT += ENT->VLR_CONT
               fIPI_BASE += ENT->IPI_BASE
               fIPI_VLR  += ENT->IPI_VLR
               fIPI_ISEN += ENT->IPI_ISEN
               fIPI_OUT  += ENT->IPI_OUT

            endif

            ENT->(dbskip())

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
            @ prow()+2,4 say fCFOP + space(18) + transform(fVLR_CONT,cPIC1) + space(13) + transform(fIPI_BASE,cPIC1) +;
                                         space(11) + transform(fIPI_VLR,cPIC1 ) + space(12) + transform(fIPI_ISEN,cPIC1) +;
                                         space(11) + transform(fIPI_OUT,cPIC1 )
         endif
      endif

      // ACUMULA TOTAL GERAL E SUB-TOTAIS  _______________________________________

      fTOT_CONT += fVLR_CONT
      fTOT_BASE += fIPI_BASE
      fTOT_CRED += fIPI_VLR
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

      if ! qlineprn() ; return ; endif

   enddo

   // IMPRIME CABECALHO QUANDO NAO ENTRA NO while ACIMA __________________________

   if lCABECALHO
      XPAGINA := nFOLHA
      i_ipi_apur(cTITULO,"ENT")
   endif

   @ prow()+1,4 say replicate("_",135)
   @ prow()+1,4 say "Total Geral..:" + space(08) + transform(fTOT_CONT,cPIC1) + space(13) + transform(fTOT_BASE,cPIC1) +;
                                       space(11) + transform(fTOT_CRED,cPIC1) + space(12) + transform(fTOT_ISEN,cPIC1) +;
                                       space(11) + transform(fTOT_OUT,cPIC1 )

   // GRAVA DADOS DO IPI e MANTEM POSICIONADO P/ IMPRESSAO DOS DADOS ABAIXO ______

   i_ent_ipi_grava()

   @ prow(),pcol() say XCOND0
   @ prow()+2,36 say "TOTAL DE DEBITOS"
   @ prow(),pcol() say XCOND2
   @ prow()+2,4 say "51-POR SAIDAS COM DEBITO DO IMPOSTO....:" + space(81) + transform(IMP->IPI_DEB,cPIC1)
   @ prow()+1,4 say "52-OUTROS DEBITOS......................:" + IMP->IPI_DOUTDB + " " + transform(IMP->IPI_OUT_DB,cPIC1)
   @ prow()+1,4 say "53-ESTORNOS DE CREDITOS................:" + IMP->IPI_DESTCD + " " + transform(IMP->IPI_EST_CD,cPIC1)
   @ prow()+1,4 say "Total..................................:" + space(81) + transform(IMP->IPI_DEB + IMP->IPI_OUT_DB + IMP->IPI_EST_CD,cPIC1)

   @ prow(),pcol() say XCOND0
   @ prow()+2,36 say "TOTAL DE CREDITOS"
   @ prow(),pcol() say XCOND2
   @ prow()+2,4 say "61-POR ENTRADAS COM CREDITO DO IMPOSTO.:" + space(81) + transform(IMP->IPI_CRED,cPIC1)
   @ prow()+1,4 say "62-OUTROS CREDITOS.....................:" + IMP->IPI_DOUTCD + " " + transform(IMP->IPI_OUT_CD,cPIC1)
   @ prow()+1,4 say "63-ESTORNOS DE DEBITOS.................:" + IMP->IPI_DESTDB + " " + transform(IMP->IPI_EST_DB,cPIC1)
   @ prow()+1,4 say "Total..................................:" + space(81) + transform(IMP->IPI_CRED + IMP->IPI_OUT_CD + IMP->IPI_EST_DB,cPIC1)

   i_grava_pagina()                  // PROGRAMA EF510.PRG

   qstopprn()

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO PARA OS LIVROS DE ENTRADA E SAIDA DE NOTAS FISCAIS __________________

function i_ipi_apur

   parameters cTITULO, cTIPO
   local cOPERACAO, cIMPOSTO

   cOPERACAO := "credito"
   cIMPOSTO  := "creditado"

   if cTIPO == "SAI"
      cOPERACAO := "debito "
      cIMPOSTO  := "debitado "
   endif

   @ prow(),pcol() say XCOND0
   @ prow()+1,029 say cTITULO
   @ prow(),pcol() say XCOND2
   @ prow()+1,004 say "Empresa...: "+ XRAZAO
   @ prow()+1,004 say "Insc. Est.: "+ XINSCR_EST + "CGC (MF):" + XCGCCPF
   @ prow()+1,004 say "Mes ou Periodo/Ano: De " + dtoc(dDATA_INI) + " ate " + dtoc(dDATA_FIM)
   @ prow()  ,116 say "Folha...:" + strzero(XPAGINA,4)
   @ prow()+1,4 say replicate("_",135)
   @ prow()+1,4 say "|          |                       |                                                 |                                                |"
   @ prow()+1,4 say "|  Codigo  |                       |         Operacoes com " + cOPERACAO+" do Imposto        |        Operacoes sem " + cOPERACAO + " do Imposto        |"
   @ prow()+1,4 say "|          |     Valor Contabil    |                        IPI                      |                       IPI                      |"
   @ prow()+1,4 say "|  Fiscal  |                       |_________________________________________________|________________________________________________|"
   @ prow()+1,4 say "|          |                       |      Base de Calculo    |   Imposto " + cIMPOSTO + "   | Isentas/Nao Tributadas |         Outras        |"
   @ prow()+1,4 say replicate("_",135)

return

//////////////////////////////////////////////////////////////////////////////////
// GRAVA OS VALORES REFERENTES AO ICMS PARA EMISSAO DA GIA OU GIAR _______________

function i_ent_ipi_grava()

   local dDATA_GRAVA, cDIA

   // dDATA_GRAVA tem o 1§ dia do mes do periodo final
   // Ex.: Periodo de 01/01/95 a 30/04/95
   //      Š gravado  21/04/95 a 30/04/95

   cDIA := day(dDATA_FIM)

   // BUSCA INICIO DO PRIMEIRO DECENDIO

   if cDIA == 10
      cDIA = 1
   endif

   // BUSCA INICIO DO SEGUNDO DECENDIO

   if cDIA == 20
      cDIA = 11
   endif

   // BUSCA INICIO DO TERCEIRO DECENDIO

   if cDIA == day(qfimmes(dDATA_FIM))
      cDIA = 21
   endif

   if CONFIG->Ipi_desc == "N"
      cDIA := day(qinimes(dDATA_FIM))
   endif

   cDIA := strzero(cDIA,2)

   dDATA_GRAVA := ctod(cDIA + "/" + strzero(month(dDATA_FIM),2) + "/" + substr(str(year(dDATA_FIM),4),3,2))

   if IMP->(dbseek(K_IPI + dtos(dDATA_GRAVA) + dtos(dDATA_FIM)))

      IMP->(qrlock())
      replace IMP->IPI_CRED   with fTOT_CRED      // total IPI creditado
      replace IMP->IPI_DEB    with fTOT_DEB       // total IPI Debitado
      replace IMP->IPI_OUT_DB with fIpi_Out_Db    // Outros Debitos
      replace IMP->IPI_DOUTDB with fIpi_DoutDb    // Descricao outros debitos
      replace IMP->IPI_OUT_CD with fIpi_Out_Cd    // Outros creditos
      replace IMP->IPI_DOUTCD with fIpi_DoutCd    // Descricao outros creditos
      replace IMP->IPI_EST_CD with fIpi_Est_Cd    // Estornos Creditos
      replace IMP->IPI_DESTCD with fIpi_DestCd    // Descricao estornos creditos
      replace IMP->IPI_EST_DB with fIpi_Est_Db    // Estornos debitos
      replace IMP->IPI_DESTDB with fIPI_DESTDB
      IMP->(qunlock())

   else

      IMP->(qappend())
      replace IMP->Codigo     with K_IPI
      replace IMP->DATA_INI   with dDATA_GRAVA    // data inicial do periodo
      replace IMP->DATA_FIM   with dDATA_FIM      // data final do periodo
      replace IMP->IPI_CRED   with fTOT_CRED      // total IPI creditado
      replace IMP->IPI_DEB    with fTOT_DEB       // total IPI Debitado
      replace IMP->IPI_OUT_DB with fIpi_Out_Db    // Outros Debitos
      replace IMP->IPI_DOUTDB with fIpi_DoutDb    // Descricao outros debitos
      replace IMP->IPI_OUT_CD with fIpi_Out_Cd    // Outros creditos
      replace IMP->IPI_DOUTCD with fIpi_DoutCd    // Descricao outros creditos
      replace IMP->IPI_EST_CD with fIpi_Est_Cd    // Estornos Creditos
      replace IMP->IPI_DESTCD with fIpi_DestCd    // Descricao estornos creditos
      replace IMP->IPI_EST_DB with fIpi_Est_Db    // Estornos debitos
      replace IMP->IPI_DESTDB with fIpi_DestDb    // Descricao estornos debitos

      IMP->(qunlock())

   endif

return
