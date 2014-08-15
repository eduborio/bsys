
///////////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: QCGM.PRG
// OBJETIVO...: ATUALIZA NO ARQUIVO DE MUNICIP.DBF NO CAMPO CGM_DESC A DESCRICAO DO CGM

function qcgm

if ! quse("","MUNICIP",{"MUN_COD"},"E")
   qmensa("N„o foi possivel abrir MUNICIP.DBF !","B")
   return .F.
endif

if ! quse("\QSYS\QSHARE\","CGM",{"CGM_COD"},"R")
   qmensa("N„o foi possivel abrir CGM.DBF !","B")
   return .F.
endif

MUNICIP->(dbgotop())

cls

? "ATUALIZANDO...."

do while ! MUNICIP->(eof())

   qgirabarra()

   CGM->(dbseek(MUNICIP->Cgm))

   replace MUNICIP->Cgm_desc with CGM->Municipio

   MUNICIP->(dbskip())

enddo

MUNICIP->(dbclosearea())
CGM->(dbclosearea())
return