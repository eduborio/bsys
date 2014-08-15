
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: ATUALIZACAO DO SALDO CREDOR DO IPI
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MAIO DE 1995
// OBS........:
// ALTERACOES.:
function ef403

#define K_MAX_LIN 55

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private aEDICAO    := {}      // vetor para os campos de entrada de dados
private lCONF
private lGRAVA_DATA
private cTIPO
private nIPI_TRANSP           // Imposto a recolher

private dDATA_INI             // Data inicial do IPI dentro do periodo
private dDATA_FIM             // Data final do IPI dentro do periodo
private cFILIAL               // Codigo do filial

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

   qlbloc(5,0,"B403A","QBLOC.GLO",1) // COM IPI

   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL ,"@!"                ) } ,"FILIAL"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do filial
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!"               ,NIL,NIL) } ,"DATA_INI"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!"               ,NIL,NIL) } ,"DATA_FIM"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nIPI_TRANSP ,"@E 999,999,999.99",NIL,NIL) } ,"IPI_TRANSP"})

do while .T.

   XNIVEL    := 1
   XFLAG     := .T.

   nIPI_TRANSP  := 0              // Imposto a transportar IPI
   cTIPO        := "1"
   cFILIAL      := "    "
   dDATA_INI    := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM := qfimmes(dDATA_INI)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      qmensa("")
   enddo

   i_grava_ipi_credito()


enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   qmensa("")
   do case
      case cCAMPO == "FILIAL"

           qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))

           if FILIAL->(dbseek(cFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,20))
           else
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
      case cCAMPO == "DATA_INI"
           dDATA_FIM := qfimmes(dDATA_INI)
           if strzero(day(dDATA_INI),2) $ "01_11"
              dDATA_FIM = (dDATA_INI + 9)
           endif
           if strzero(day(dDATA_INI),2) $ "21"
              dDATA_FIM = qfimmes(ctod("01/" + str(month(dDATA_INI)) + "/" + str(year(dDATA_INI))))
           endif
           qrsay(XNIVEL+1,dDATA_FIM)
      case cCAMPO == "DATA_FIM"
           if IMP->(dbseek(K_IPI + dtos(dDATA_INI) + dtos(dDATA_FIM)))
              nIPI_TRANSP := IMP->IMP_VALOR
              qrsay(XNIVEL+2,nIPI_TRANSP,"@E 999,999,999.99")
              lGRAVA_DATA := .F.
              return .T.
           endif
           lGRAVA_DATA := .T.
           nIPI_TRANSP := 0
//      case cCAMPO == "IPI_TRANSP"
//           if nIPI_TRANSP > 0 ; return .F. ; endif


   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GRAVAR VALORES DO SALDO CREDOR ICMS e IPI ____________________
function i_grava_ipi_credito()

      if ! qconf("Confirma gravar o saldo credor ?")
         return
      endif

      if lGRAVA_DATA ; IMP->(qappend()) ; endif

      IMP->(qrlock())
      replace IMP->Codigo       with  K_IPI
      replace IMP->Data_Ini     with  dDATA_INI
      replace IMP->Data_Fim     with  dDATA_FIM
      replace IMP->Imp_Valor    with  nIPI_TRANSP
      replace IMP->Filial       with  cFILIAL
      IMP->(qunlock())

return


