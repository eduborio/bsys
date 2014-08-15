/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: CONFIGURACAO DOS HISTORICOS PARA IMPOSTOS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: MAIO DE 1998
// OBS........:
// ALTERACOES.:

function ef805

// DECLARACAO DE VARIAVEIS __________________________________________________

private cHIS_ICMS  := HIST_IMP->HIS_icms
private cHIS_IPI   := HIST_IMP->HIS_ipi
private cHIS_IRRF  := HIST_IMP->HIS_irrf
private aEDICAO    := {}
private lCONF      := .F.
private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1) }

qlbloc(5,0,"B805A","QBLOC.GLO",1)

aadd(aEDICAO,{{ || view_hist(-1,0,@cHIS_ICMS       ) } ,"HIS_ICMS" })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do HIS
aadd(aEDICAO,{{ || view_hist(-1,0,@cHIS_IPI        ) } ,"HIS_IPI" })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do HIS
aadd(aEDICAO,{{ || view_hist(-1,0,@cHIS_IRRF       ) } ,"HIS_IRRF" })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do HIS

aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

XNIVEL := 1

qrsay ( XNIVEL++ , cHIS_ICMS ) ; HIST->(dbseek(cHIS_ICMS))
qrsay ( XNIVEL++ , left(HIST->Descricao,40) )
qrsay ( XNIVEL++ , cHIS_IPI ) ; HIST->(dbseek(cHIS_IPI))
qrsay ( XNIVEL++ , left(HIST->Descricao,40) )
qrsay ( XNIVEL++ , cHIS_IRRF ) ; HIST->(dbseek(cHIS_IRRF))
qrsay ( XNIVEL++ , left(HIST->Descricao,40) )

XNIVEL := 1
XFLAG  := .T.

// LOOP PARA ENTRADA DOS DADOS ______________________________________________

do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
   eval ( aEDICAO [XNIVEL,1] )
   if eval ( bESCAPE ) ; return ; endif
   if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
   iif ( XFLAG , XNIVEL++ , XNIVEL-- )
enddo

// GRAVACAO _________________________________________________________________

if lCONF

   iif (HIST_IMP->(eof()) , HIST_IMP->(qappend()) , HIST_IMP->(qrlock()) )

   replace HIST_IMP->HIS_icms  with cHIS_ICMS
   replace HIST_IMP->HIS_ipi   with cHIS_IPI
   replace HIST_IMP->HIS_irrf  with cHIS_IRRF

   HIST_IMP->(qunlock())

endif

HIST_IMP->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "HIS_ICMS"
           if empty(cHIS_ICMS) ; return .F. ; endif
           if ! HIST->(dbseek(cHIS_ICMS))
               qmensa("Tipo Cont bil n„o encontrado...","B")
               return .F.
           else
             qrsay(XNIVEL+1,left(HIST->Descricao,40))
           endif
      case cCAMPO == "HIS_IPI"
           if empty(cHIS_IPI) ; return .F. ; endif
           if ! HIST->(dbseek(cHIS_IPI))
               qmensa("Tipo Cont bil n„o encontrado...","B")
               return .F.
           else
             qrsay(XNIVEL+1,left(HIST->Descricao,40))
           endif
      case cCAMPO == "HIS_IRRF"
           if empty(cHIS_IRRF) ; return .F. ; endif
           if ! HIST->(dbseek(cHIS_IRRF))
               qmensa("Tipo Cont bil n„o encontrado...","B")
               return .F.
           else
               qrsay(XNIVEL+1,left(HIST->Descricao,40))
           endif

   endcase
return .T.
