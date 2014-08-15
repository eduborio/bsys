
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: CALCULO DE MULTA E JUROS SOBRE A GIAR
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MARCO DE 1995
// OBS........:
// ALTERACOES.:
function ef408

#define K_MAX_LIN 55

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private sBLOC1     := qlbloc("B408C","QBLOC.GLO")
private aEDICAO    := {}         // vetor para os campos de entrada de dados
private lCONF
private lVENC_FCA
private lPGTO_FCA

private cTIPO                 // Tipo Denuncia Expontanea ou Fora do Prazo
private nMULTA_MIN            // Multa Minima de 2 UPF/PR
private nFCP                  // FCP - Para calculo da multa minima
private nICM_RECOL            // Imposto a recolher
private nFCA_VENC             // F.C.A. dia do vencimento
private nFCA_PGTO             // F.C.A. dia do pagamento
private nMULTA                // % multa
private nJUROS                // % juros
private nCORRECAO             // Correcao monetaria
private nTOTAL                // Total imposto com correcao pelo F.C.A.
private nTOT_MULTA            // Total da multa sobre valor corrigido
private nTOT_JUROS            // Total dos juros sobre valor corrigido + multa

private dDATA_VENC            // Data de vencimento
private dDATA_PGTO            // Data do Pagamento
private dDATA_INI             // Data inicial do ICMS dentro do mes
private dDATA_FIM             // Data final do ICMS dentro do mes

private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0}}

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B408A","QBLOC.GLO",1)

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO      ,sBLOC1)                                 } ,"TIPO"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@nFCP       ,"@E 999,999,999.99",NIL,cTIPO=="2")     } ,"FCP"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI  ,"@!"               )                    } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_RECOL ,"@E 999,999,999.99")                    } ,"ICM_RECOL"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC ,"@!"               )                    } ,"DATA_VENC"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nFCA_VENC  ,"@E 99,999.9999"   )                    } ,"FCA_VENC" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_PGTO ,"@!"               )                    } ,"DATA_PGTO"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nFCA_PGTO  ,"@E 99,999.9999"   )                    } ,"FCA_PGTO" })

do while .T.

   XNIVEL    := 1
   XFLAG     := .T.
   lVENC_FCA := .F.
   lPGTO_FCA := .F.

   nTOT_MULTA   := 0              // Total da multa
   nMULTA_MIN   := 0              // Multa Minima sobre o imposto
   nFCP         := 0              // Fator para correcao
   nFCA_VENC    := 0              // Imposto a recolher
   nFCA_PGTO    := 0              // Imposto a recolher
   nICM_RECOL   := 0              // Imposto a recolher

   dDATA_VENC   := ctod("10/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_PGTO   := date()
   dDATA_INI    := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM    := qfimmes(dDATA_INI)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      qmensa("")
   enddo

   i_calc_juros()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   qmensa("")
   do case
      case cCAMPO == "DATA_INI"
           dDATA_FIM = qfimmes(dDATA_INI)
           if !IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(dDATA_FIM)))
              qmensa("N„o foi encontrado movimento. Emita as Apura‡”es do Per¡odo !!!","B")
              return .F.
           endif
           nICM_RECOL := IMP->IMP_VALOR
           if nICM_RECOL < 0
              qmensa("N„o h  d‚bito de imposto neste per¡odo !!!","B")
              return .F.
           endif
           qrsay(XNIVEL+1,nICM_RECOL,"@E 999,999,999.99")
           if !XFLAG .and. cTIPO = "1"
              XNIVEL--
           endif

      case cCAMPO == "ICM_RECOL"
           if empty(nICM_RECOL)
              qmensa("Valor deve ser maior que zero !","B")
              return .F.
           endif

      case cCAMPO == "DATA_VENC"
           if empty(dDATA_VENC) ; return .F. ; endif
//         // PEGA FATOR DE CORRECAO E ATUALIZACAO (DIARIO ou MENSAL)
//         if ! INDV->(dbseek("R80" + dtos(dDATA_VENC)))
//            if ! INDV->(dbseek("R80" + "01/" + str(month(dDATA_VENC),2) + "/" + str(year(dDATA_VENC))))
//               qmensa("F.C.A. da data n„o encontrado, Informe o valor !!! ","B")
//               lVENC_FCA = .T.
//            endif
//         endif
//         if !lVENC_FCA
//            nFCA_VENC := INDV->VALOR
//            qrsay(XNIVEL+1, nFCA_VENC ,"@E 99,999.99")
//         endif


      case cCAMPO == "FCA_VENC"
           if empty(nFCA_VENC)
              qmensa("Valor deve ser maior que zero !","B")
              return .F.
           endif

      case cCAMPO == "DATA_PGTO"
           if empty(dDATA_PGTO) ; return .F. ; endif
           if dDATA_VENC > dDATA_PGTO
              qmensa("Data pagamento deve ser maior que a Data de vencimento !","B")
              return .F.
           endif
//         // PEGA FATOR DE CORRECAO E ATUALIZACAO (DIARIO ou MENSAL)
//         if !INDV->(dbseek(dDATA_PGTO))
//            if !INDV->(dbseek("R80" + dtos(qfimmes(ctod("01/"+str(month(dDATA_PGTO))+"/"+str(year(dDATA_PGTO)))))))
//               qmensa("F.C.A. da data n„o encontrado, Informe o valor !!!","B")
//               lPGTO_FCA = .T.
//            endif
//         endif
//         if !lPGTO_FCA
//            nFCA_PGTO := INDV->VALOR
//            qrsay(XNIVEL+1, nFCA_PGTO ,"@E 99,999.99")
//         endif
      case cCAMPO == "FCA_PGTO"
           if empty(nFCA_PGTO)
              qmensa("Valor deve ser maior que zero !","B")
              return .F.
           endif
      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"Den£ncia Expontƒnea","Fora do Prazo"}))

      case cCAMPO == "FCP"
           // SE TIPO NAO EXPONTANEA CALCULA MULTA MINIMA ____________________
           if cTIPO = '2'
              nMULTA_MIN := nFCP * 2
           endif


   endcase
return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CALCULAR JUROS SOBRE O ICMS _______________________________________
function i_calc_juros()
local sBLOC := qsbloc(5,0,23,79)


      // FATOR DE CORRECAO _______________________________________________________
      nCORRECAO := (nFCA_PGTO / nFCA_VENC)

      // PERCENTAGEM DA MULTA ____________________________________________________
      nMULTA    := i_dias_multa()

      // PERCENTAGEM DO JURO _____________________________________________________
      nJUROS    := i_meses_juros()

      // TOTAL DO VALOR CORRIGIDO (COM F.C.A.)
      nTOTAL    := nCORRECAO * nICM_RECOL

      // TIPO FORA DO PRAZO  SOMA MULTA DE 2 UPF/PR + MULTA NORMAL _______________
      if cTIPO = '2'
         // TOTAL DA MULTA SOBRE VALOR CORRIGIDO _________________________________
         nTOT_MULTA := nMULTA * nTOTAL
         nTOT_MULTA += nMULTA_MIN
      endif

      // TOTAL DO JUROS SOBRE O VALOR CORRIGIDO + MULTA __________________________
      nTOT_JUROS = nJUROS * (nTOTAL + nTOT_MULTA)

      qlbloc(5,0,"B408B","QBLOC.GLO",1)

      XNIVEL := 1

      qrsay ( XNIVEL++, nICM_RECOL                       ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++, nTOT_MULTA                       ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++, nTOT_JUROS                       ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++, nTOTAL - nICM_RECOL              ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++, nTOTAL + nTOT_MULTA + nTOT_JUROS ,  "@E 999,999,999.99" )

//    // GRAVA VALORES DO FCA, CASO NAO ESTEJAM CADASTRADOS
//    if lVENC_FCA
//       INDV->(qrlock())
//       replace INDV->DATA_REF with dDATA_VENC
//       replace INDV->VALOR    with nFCA_VENC
//       INDV->(qunlock())
//    endif
//
//    if lPGTO_FCA
//       INDV->(qrlock())
//       replace INDV->DATA_REF with dDATA_PGTO
//       replace INDV->VALOR    with nFCA_PGTO
//       INDV->(qunlock())
//    endif

      if ! qconf("Confirma gravar os valores calculados ?")
         qrbloc(5,0,sBLOC)
         return
      endif

      // GRAVA VALORES PARA EMISSAO DA GIAR
      IMP->(qrlock())
      replace IMP->CORRECAO with (nTOTAL - nICM_RECOL)
      replace IMP->MULTA    with (nTOT_MULTA)
      replace IMP->JUROS    with (nTOT_JUROS)
      IMP->(qunlock())

      qrbloc(5,0,sBLOC)

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CALCULAR DIAS DE MULTA ____________________________________________
function i_dias_multa()
local nDIAS

      nDIAS := (dDATA_PGTO - dDATA_VENC)

      do case
         case nDIAS  = 1
              nMULTA = 1
         case nDIAS  >= 2  .and. nDIAS <= 15
              nMULTA = 10
         case nDIAS  >= 16 .and. nDIAS <= 30
              nMULTA = 20
         case nDIAS  >= 31
              nMULTA = 30
      endcase

return(nMULTA / 100)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CALCULAR TOTAL DE MESES PARA O JURO _______________________________
function i_meses_juros()
local nMESES
local nQTDIA

         nMESES := month(dDATA_PGTO) - month(dDATA_VENC)
         nMESES++

return(nMESES / 100)

