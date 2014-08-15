/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITURA FISCAL
// OBJETIVO...: CONVERSAO DO T.P.O. NAS NOTAS FISCAIS
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: AGOSTO DE 1997
// OBS........:
// ALTERACOES.:
function ef420

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________


#include "ef.ch"

lCONF := qconf("Confirma a convers„o do T.P.O. nas notas ?")

if lCONF== .F.
   Return
Endif

qmensa("")

ENT->(dbsetorder(1))
NATOP->(Dbsetorder(1))

do while ! ENT->(eof())
   qgirabarra()
   NATOP->(dbseek(ENT->Cod_fisc))
   if ENT->(qrlock())
      replace ENT->Tipo_cont with NATOP->Tip_cont
   else
     qm1()
   endif
   ENT->(dbskip())
enddo

do while ! SAI->(eof())
   qgirabarra()
   NATOP->(dbseek(SAI->Cod_fisc))
   if SAI->(qrlock())
      replace SAI->Tipo_cont with NATOP->Tip_cont
   else
     qm1()
   endif
   SAI->(dbskip())
enddo

qmensa("Por favor... reindexe os arquivos ENT.DBF e SAI.DBF ...","B")

return
