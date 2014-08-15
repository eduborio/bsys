/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: LIVRO DE APURACAO DE ISS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........:
// ALTERACOES.:
function ef530

#define K_MAX_LIN 55

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1) }


// SE TRIBUTOS FOREM SINCRONIZADOS, PEGA DA E001 ____________________________

private sBLOC1     := qlbloc("B530B","QBLOC.GLO") // Tipo: Valor contabil / Valor de prestacao de servico

private cPIC1      := "@E 99,999,999.99"
private cTITULO                                   // titulo do relatorio
private cSERIE                                    // descricao de serie da nota fiscal
private cSERVICO                                  // descricao do servico da nota fiscal
private bFILTRO                                   // code block de filtro
private aEDICAO    := {}                          // vetor para os campos de entrada de dados

private lCABECALHO := .T.                         // imprime cabecalho caso nao tenha notas
private nFALTA                                    // Numero de meses que faltam para imprimir cabecalho em branco
private nMES                                      // Mes para controlar mudanca de pagina

private nFOLHA                                    // Numero da Folha
private nIMPOSTO                                  // Total do imposto
private nVAL_TRIB                                 // Valor total do ISS

private cTIPO_LIVRO                               // Tipo: Valor contabil / Valor de prestacao de servico

private dDATA_INI                                 // Inicio do periodo do relatorio
private dDATA_FIM                                 // Fim do periodo do relatorio

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0}}

private aRESUMO_MP := {}
private aRESUMO_BI := {}
private aRESUMO_VI := {}

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL ,"9999"           ) } ,"FILIAL"  })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL       }) // descricao do filial

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})
   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO_LIVRO ,sBLOC1           ) } ,"TIPO_LIVRO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@nFOLHA      ,"@E 9999",NIL,NIL) } ,"FOLHA"     })
// aadd(aEDICAO,{{ || qgetx(-1,0,@cQUINZE     ,"@!"     ,NIL,NIL) } ,"QUINZE"    })

do while .T.

   qlbloc(5,0,"B530A","QBLOC.GLO",1)

   XNIVEL      := 1
   XFLAG       := .T.
   nIMPOSTO    := 0
   nFOLHA      := val(XPAGINA_ISS)
   dDATA_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM   := qfimmes(dDATA_INI)
   nFALTA      := 0                 // MESES QUE FALTAM PARA IMPRIMIR CABECALHO
   cFILIAL     := "    "
   cTIPO_LIVRO := "1"
// cQUINZE     := "N"
   nVAL_TRIB   := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   ISS->(dbSetFilter())

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

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
           nMES := val(str(month(dDATA_INI),2))
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif
      case cCAMPO == "TIPO_LIVRO"
           if empty(cTIPO_LIVRO); return .F.; endif
           qrsay(XNIVEL,qabrev(cTIPO_LIVRO,"12",{"Pelo Valor Cont bil","Pelo Vlr. Prest. Servi‡o"}))
  //  case cCAMPO == "QUINZE"
  //       if empty(cQUINZE); return .F.; endif
  //       qrsay(XNIVEL,qabrev(cQUINZE,"SN",{"Sim","N„o"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "REGISTRO DOS SERVICOS PRESTADOS - ISS  "

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bFILTRO := { || ISS->DATA_LANC >= dDATA_INI .and. ISS->DATA_LANC <= dDATA_FIM }

   ISS->(dbSetFilter({|| alltrim(Filial) == cFILIAL}, 'alltrim(Filial) == cFILIAL'))

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select ISS
   ISS->(dbsetorder(2))
   ISS->(dbgotop())

   select SERV
   SERV->(dbgotop())

   select SERIE
   SERIE->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

// local lIMP := .T.   // para imprimir o primeiro total quinzenal

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND2

   // CONDICAO PRINCIPAL DE LOOP_____________________________________________

   do while ! ISS->(eof()) .and. qcontprn() // .and. eval(bFILTRO)

      qgirabarra()

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN

         qpageprn()

         // CASO IMPRIMA ALGUMA NOTA, NAO IMPRIME CABECALHO FORA DESTE LOOP__

         lCABECALHO := .F.

         // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA_____________________

         if nFOLHA <> 0
            XPAGINA = nFOLHA
            nFOLHA  = 0
         endif

//       XPAGINA++

         i_iss_apur(cTITULO)
         i_cabec()

      endif

      if eval(bFILTRO)

         if nMES <> val(str(month(ISS->DATA_LANC),2))
            nMES++

            // IMPRIME O TOTAL QUANDO MUDA O MES _________________________________

            i_tot_periodo()
            setprc(56,00)
            loop
         endif

         qmensa("Imprimindo Nota: " + padl(alltrim(ISS->Num_Nf),6) +" / Serie : "+ISS->Serie)

         cISS_MP := ISS->Municip

         @ prow()+1,05  say substr(dtoc(ISS->DATA_LANC),1,2) + "   " +;
                           i_iss_especie(ISS->ESPECIE)           + "  " +;
                           ISS->NUM_NF + ISS->NUM_ULT_NF     + " " +;
                           i_serie(ISS->SERIE)

         SERV->(dbseek(ISS->Cod_serv))
         @ prow()  ,46 say left(SERV->Descricao,25)

         do case
            case cTIPO_LIVRO == "1"
                 @ prow()  ,76 say transform(ISS->VLR_CONT,cPIC1) + "       " +;
                                   transform(ISS->VLR_MERC,cPIC1) + "   " +;
                                   transform(ISS->ISS_BASE,cPIC1) + " " +;
                                   left(ISS->OBS,27)
            case cTIPO_LIVRO == "2"
                 @ prow()  ,76 say transform(ISS->Iss_base,cPIC1) + "   " +;
                                   transform(ISS->Iss_base,cPIC1) + " " +;
                                   left(ISS->OBS,27)
         endcase

         // NAO CALCULA IMPOSTO NA EMISSAO DO RELATORIO ______________________

         nVAL_TRIB += ISS->Iss_base
         nIMPOSTO  += ISS->Iss_vlr

         FILIAL->(dbseek(ISS->Filial))
         MUNICIP->(dbseek(ISS->Municip))

//       if left(MUNICIP->Cgm_desc,15) <> FILIAL->Cidade
            if ( nTMP := ascan(aRESUMO_MP,cISS_MP) ) == 0  // Soma os valores por estado
               aadd(aRESUMO_MP,cISS_MP       )
               aadd(aRESUMO_BI,ISS->Iss_base )
               aadd(aRESUMO_VI,ISS->Iss_vlr  )
            else
               aRESUMO_BI[nTMP] += ISS->Iss_base
               aRESUMO_VI[nTMP] += ISS->Iss_vlr
            endif
//       endif

      endif

      ISS->(dbskip())

//    if lIMP .and. cQUINZE == "S" .and. ( val(str(day(ISS->DATA_LANC),2)) > "15")
//       lIMP := .F.
//       i_tot_periodo()
//       nVAL_TRIB := 0
//       nIMPOSTO  := 0
//    endif

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

         // BUSCA O DEBITO, IMPRIME O TOTAL, O CABECALHO, GRAVA VALORES ____

         eject
         xpagina++

         // qpageprn()

         i_iss_apur(cTITULO)
         i_cabec()

         lCABECALHO := .F.

         i_tot_periodo()

         setprc(56,00)

         nFALTA--
         nMES++

      enddo

   endif

   qstopprn()

   lCABECALHO := .T.

return

//////////////////////////////////////////////////////////////////////////////
// CABECALHO PARA LIVRO DE ISS _______________________________________________

function i_iss_apur

   parameters cTITULO

   local dINI_PERIODO, dFIM_PERIODO

   // SE NAO ESTIVER DENTRO DO MES, ALTERA A DATA DO CABECALHO _______________

   if month(dDATA_INI) <> month(dDATA_FIM)
      dINI_PERIODO := ctod("01/" + str(nMES,2) + "/" + left(XANOMES,4))
      dFIM_PERIODO := qfimmes(ctod("01/" + str(nMES,2) + "/" + left(XANOMES,4)))
   endif

   @ prow()+1,070 say cTITULO + space(30) + "Folha...: " + strzero(XPAGINA,4)
   @ prow()+2,005 say "Empresa...: "+ FILIAL->RAZAO
   @ prow()+1,005 say "Insc. Mun.: "+ FILIAL->Insc_munic + " CNPJ   : " + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99")
   @ prow()+1,005 say "Endereco..: "+ FILIAL->Endereco

   if month(dDATA_INI) <> month(dDATA_FIM)
      @ prow()+1,005 say "Mes ou Periodo/Ano: De " + dtoc(dINI_PERIODO) + " ate " + dtoc(dFIM_PERIODO)
   else
      @ prow()+1,005 say "Mes ou Periodo/Ano: De " + dtoc(dDATA_INI) + " ate " + dtoc(dDATA_FIM)
   endif

// @ prow()+1,010 say "Mes ou Periodo/Ano: De " + dtoc(dDATA_INI) + " ate " + dtoc(dDATA_FIM)

return

//////////////////////////////////////////////////////////////////////////////////
// IMPRIME O TOTAL DE CADA PERIODO _______________________________________________

static function i_tot_periodo

   local nCONTX    := 0
   local nTOT_R_BI := 0
   local nTOT_R_VI := 0

   // IMPRIME CABECALHO QUANDO NAO ENTRA NO while ACIMA __________________________

   if lCABECALHO
      XPAGINA := nFOLHA
      i_iss_apur(cTITULO)
      i_cabec()
   endif

   do case
      case cTIPO_LIVRO == "1"
           @ prow()+1,05  say replicate("-",155)
           @ prow()+1,89  say "Total: " + transform(nVAL_TRIB,cPIC1)
           @ prow()+2,125 say "Imposto a recolher:" + space(02) + transform(nIMPOSTO,cPIC1)
      case cTIPO_LIVRO == "2"
           @ prow()+1,05  say replicate("-",127)
           @ prow()+1,85  say "Total: " + transform(nVAL_TRIB,cPIC1)
           @ prow()+2,97  say "Imposto a recolher:" + space(02) + transform(nIMPOSTO,cPIC1)
   endcase

   nIMPOSTO := 0

   i_cabec_resumo()
   

   for nCONTX := 1 to len(aRESUMO_MP)
       MUNICIP->(dbseek(aRESUMO_MP[nCONTX]))
       @ prow()+1,05 say MUNICIP->Cgm_desc                   + "   "     +;
                         transform(aRESUMO_BI[nCONTX],cPIC1) + space(11) +;
                         transform(aRESUMO_VI[nCONTX],cPIC1)

       nTOT_R_BI += aRESUMO_BI[nCONTX]
       nTOT_R_VI += aRESUMO_VI[nCONTX]
   next

   @ prow()+1,05 say replicate("_",70)

   @ prow()+1,31 say "Total: " + transform(nTOT_R_BI,cPIC1) + space(11) +;
                     transform(nTOT_R_VI,cPIC1)

   aRESUMO_MP := {}
   aRESUMO_BI := {}
   aRESUMO_VI := {}

   nTOT_R_BI  := 0
   nTOT_R_VI  := 0
   nVAL_TRIB  := 0

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO PARA OS LIVROS DE ISS _______________________________________________

static function i_cabec

   do case
      case cTIPO_LIVRO == "1"
           @ prow()+1,05 say replicate("-",155)
           @ prow()+1,05 say "   |      DOCUMENTOS FISCAIS       |          NATUREZA DO          |    PRECO  DO   | VLR DA MERCADORIA |     VALOR     |                     "
           @ prow()+1,05 say "DIA|-------------------------------|                               |                |  FORNECIDA OU DA  |               |     OBSERVACAO      "
           @ prow()+1,05 say "   |ESPECIE|     NUMERO    | SERIE |            SERVICO            |     SERVICO    |   SUBEMPREITADA   |   TRIBUTAVEL  |                     "
           @ prow()+1,05 say "   |       |    DE     A   |       |                               |                |                   |               |                     "
           @ prow()+1,05 say replicate("-",155)
      case cTIPO_LIVRO =="2"
           @ prow()+1,05 say replicate("-",127)
           @ prow()+1,05 say "   |      DOCUMENTOS FISCAIS       |          NATUREZA DO          |    PRECO  DO   |     VALOR     |                     "
           @ prow()+1,05 say "DIA|-------------------------------|                               |                |               |     OBSERVACAO      "
           @ prow()+1,05 say "   |ESPECIE|     NUMERO    | SERIE |            SERVICO            |     SERVICO    |   TRIBUTAVEL  |                     "
           @ prow()+1,05 say "   |       |    DE     A   |       |                               |                |               |                     "
           @ prow()+1,05 say replicate("-",127)
   endcase
return

//////////////////////////////////////////////////////////////////////////////////
// DESCRICAO DA ESPECIE PARA EMISSAO DO LIVRO ISS ________________________________

static function i_iss_especie ( fESPECIE )

   do case
      case fESPECIE = "A"  ; return "N.F. "
      case fESPECIE = "B"  ; return "Luz  "
      case fESPECIE = "C"  ; return "Telef"
      case fESPECIE = "D"  ; return "Telex"
      case fESPECIE = "E"  ; return "Trans"
      case fESPECIE = "F"  ; return "CMR  "
      case fESPECIE = "G"  ; return "N.F.F"
   endcase

return ""

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO DO RESUMO ___________________________________________________________

static function i_cabec_resumo

  if prow() >= 48

     eject

     @ prOw()+2,20 say "     REGISTRO  DOS  SERVICOS  PRESTADOS   -   CONTINUACAO  -   RESUMO  "
     @ prow()+1,36 say replicate("-",20)
     @ prow()+2,36 say "RESUMO POR MUNICIPIO"
     @ prow()+1,36 say replicate("-",20)
     @ prow()+2,05 say "MUNICIPIO                        BASE DO CALCULO DO ISS   VALOR DO ISS"
     @ prow()+1,05 say replicate("_",70)

   else

     @ prow()+1,36 say replicate("-",20)
     @ prow()+2,36 say "RESUMO POR MUNICIPIO"
     @ prow()+1,36 say replicate("-",20)
     @ prow()+2,05 say "MUNICIPIO                        BASE DO CALCULO DO ISS   VALOR DO ISS"
     @ prow()+1,05 say replicate("_",70)

   endif

return

