
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: ATUALIZACAO DO SALDO CREDOR DO ICMS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MAIO DE 1995
// OBS........:
// ALTERACOES.:
function ef402

#define K_MAX_LIN 55

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private aEDICAO    := {}         // vetor para os campos de entrada de dados
private lCONF
private lGRAVA_DATA
private cTIPO
private nICM_TRANSP           // Imposto a recolher

private dDATA_INI             // Data inicial do ICMS dentro do mes
private dDATA_FIM             // Data final do ICMS dentro do mes
private cFILIAL               // Codigo do filial

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

   qlbloc(5,0,"B402A","QBLOC.GLO",1) // SO ICMS

   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL ,"@!"                ) } ,"FILIAL"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do filial
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!"               ,NIL,NIL) } ,"DATA_INI"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!"               ,NIL,NIL) } ,"DATA_FIM"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_TRANSP ,"@E 999,999,999.99",NIL,NIL) } ,"ICM_TRANSP"})

do while .T.

   XNIVEL    := 1
   XFLAG     := .T.

   nICM_TRANSP  := 0              // Imposto a transportar ICMS
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

   i_grava_icm_credito()


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
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(dDATA_FIM) + alltrim(cFILIAL)))
              nICM_TRANSP := IMP->IMP_VALOR
              qrsay(XNIVEL+1,nICM_TRANSP,"@E 999,999,999.99")
              lGRAVA_DATA := .F.
              return .T.
           endif
           lGRAVA_DATA := .T.
           nICM_TRANSP := 0

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GRAVAR VALORES DO SALDO CREDOR ICMS __________________________
function i_grava_icm_credito

      if ! qconf("Confirma gravar o saldo credor ?")
         return
      endif

      if lGRAVA_DATA ; IMP->(qappend()) ; endif

      IMP->(qrlock())
      replace IMP->Codigo       with  K_ICM
      replace IMP->Data_Ini     with  dDATA_INI
      replace IMP->Data_Fim     with  dDATA_FIM
      replace IMP->Imp_Valor    with  nICM_TRANSP
      replace IMP->Filial       with  cFILIAL
      IMP->(qunlock())

return

