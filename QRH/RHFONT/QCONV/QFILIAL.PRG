
///////////////////////////////////////////////////////////////////////////////
// SISTEMA....: QFILIAL
// OBJETIVO...:
// COMO USAR..: QFILIAL

parameters cDIRETORIO

? "ATUALIZANDO"

use (cDIRETORIO+"\FUN")

FUN->(dbgotop())

do while ! FUN->(eof())
   replace FUN->Filial with "0001"
   FUN->(dbskip())
enddo

FUN->(dbclosearea())
