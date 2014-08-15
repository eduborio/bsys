///////////////////////////////////////////////////////////////////////////////
// SISTEMA....: QGRPS
// OBJETIVO...: DUIPLICA GRPS P/ PROX. MES
// COMO USAR..: QGRPS E001 9702

parameters cDIRETORIO, cINI, cFIM
private nREC

? "ATUALIZANDO"

use (cDIRETORIO+"\GRPS")

GRPS->(dbgotop())

do while ! GRPS->(eof())
   if cINI == GRPS->Anomes
      GRPS->(qpublicfields())
      GRPS->(qcopyfields())
      fANOMES := cFIM
      nREC := GRPS->(recno())
      append blank
      GRPS->(qreplacefields())
      GRPS->(qreleasefields())
      GRPS->(dbgoto(nREC))
   endif
   GRPS->(dbskip())
enddo

GRPS->(dbclosearea())
