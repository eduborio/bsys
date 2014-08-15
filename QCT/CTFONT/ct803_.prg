/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: IMPORTACAO DO PLANO DE CONTAS DE OUTRA EMPRESA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: SETEMBRO DE 1995
// OBS........:
// ALTERACOES.:

function ct803

#include "inkey.ch"
#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO  := {}        // vetor para os campos
private cEMPRESA := space(3)  // empresa cedente do plano
private nNIVEL                // nivel da conta
private lCONF                 // flag de confirmacao
private cEMPFILT              // string auxiliar para filtro

// ABRE ARQUIVO QINST.DBF (CONTROLE DE EMPRESAS) E FILTRA ___________________

quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")

cEMPFILT := "000-" + XEMPRESA

QINST->(dbSetFilter({|| ! Empresa $ cEMPFILT}, '! Empresa $ cEMPFILT'))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_qinst(-1,0,@cEMPRESA )},"EMPRESA"  })
aadd(aEDICAO,{{ || lCONF := qconf("Confirma importa‡„o ?" )},NIL })

do while .T.

   qlbloc(5,0,"B803A","QBLOC.GLO")
   qmensa()
   cEMPRESA := space(3)
   XNIVEL   := 1
   XFLAG    := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_importa()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "EMPRESA"
           if QINST->(dbseek(cEMPRESA:=strzero(val(cEMPRESA),3)))
              qrsay(XNIVEL,cEMPRESA)
              qrsay(XNIVEL+1,left(QINST->Razao,40))
           else
              qmensa("Empresa n„o cadastrada !","B")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPORTACAO ___________________________________________

static function i_importa
  local cCAMINHO1 , cCAMINHO2 , nREC

  cCAMINHO1 := alltrim(XDRV_CT)
  cCAMINHO2 := alltrim(QINST->Drv_ct)

  if ! lCONF ; return .F. ; endif

  qmensa("Copiando arquivos. Aguarde...")

  copy file &(cCAMINHO1+"PLAN.DBF")     to &(cCAMINHO1+"PLAN.OLD")
  copy file &(cCAMINHO2+"PLAN.DBF")     to &(cCAMINHO1+"PLAN.DBF")
  copy file &(cCAMINHO2+"PL_CODIG.NTX") to &(cCAMINHO1+"PL_CODIG.NTX")
  copy file &(cCAMINHO2+"PL_DESCR.NTX") to &(cCAMINHO1+"PL_DESCR.NTX")
  copy file &(cCAMINHO2+"PL_REDUZ.NTX") to &(cCAMINHO1+"PL_REDUZ.NTX")
  copy file &(cCAMINHO2+"RESULT.DBF")   to &(cCAMINHO1+"RESULT.DBF")

  // ABRE O ARQUIVO PLAN.DBF __________________________________________________

  quse(XDRV_CT,"PLAN",{"PL_CODIG","PL_DESCR","PL_REDUZ"})

  // TRAVA OS ARQUIVOS ________________________________________________________

  if ! PLAN->(flock()) .or. ! CONFIG->(flock())
     qmensa("N„o foi possivel travar arquivos, tente novamente...","B")
     return
  endif

  // LIMPA OS SALDOS DOS 12 MESES EM ABERTO (CONFIG.DBF INCLUSIVE) ____________

  qmensa("Zerando os saldos. Aguarde...")

  replace CONFIG->DB01 with 0, CONFIG->CR01 with 0, CONFIG->DB02 with 0, CONFIG->CR02 with 0,;
          CONFIG->DB03 with 0, CONFIG->CR03 with 0, CONFIG->DB04 with 0, CONFIG->CR04 with 0,;
          CONFIG->DB05 with 0, CONFIG->CR05 with 0, CONFIG->DB06 with 0, CONFIG->CR06 with 0,;
          CONFIG->DB07 with 0, CONFIG->CR07 with 0, CONFIG->DB08 with 0, CONFIG->CR08 with 0,;
          CONFIG->DB09 with 0, CONFIG->CR09 with 0, CONFIG->DB10 with 0, CONFIG->CR10 with 0,;
          CONFIG->DB11 with 0, CONFIG->CR11 with 0, CONFIG->DB12 with 0, CONFIG->CR12 with 0

  nREC := PLAN->(lastrec())

  do while ! PLAN->(eof())

     qsay(24,70,nREC--)

     replace PLAN->DB01 with 0, PLAN->CR01 with 0, PLAN->DB02 with 0, PLAN->CR02 with 0,;
             PLAN->DB03 with 0, PLAN->CR03 with 0, PLAN->DB04 with 0, PLAN->CR04 with 0,;
             PLAN->DB05 with 0, PLAN->CR05 with 0, PLAN->DB06 with 0, PLAN->CR06 with 0,;
             PLAN->DB07 with 0, PLAN->CR07 with 0, PLAN->DB08 with 0, PLAN->CR08 with 0,;
             PLAN->DB09 with 0, PLAN->CR09 with 0, PLAN->DB10 with 0, PLAN->CR10 with 0,;
             PLAN->DB11 with 0, PLAN->CR11 with 0, PLAN->DB12 with 0, PLAN->CR12 with 0,;
             PLAN->Saldo_ant with 0

     PLAN->(dbskip())
  enddo

return

