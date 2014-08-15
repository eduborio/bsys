/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: CONTAS A PAGAR
// OBJETIVO...: CONVERSAO DO CBO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 2003
// OBS........:
// ALTERACOES.:


if ! qconf("Confirma Convers„o dos CBOs ?")
   return
endif

CBO2->(dbsetorder(1))
CBO2->(dbgotop())

CBO->(dbsetorder(1))
CBO->(dbgotop())

SITUA->(dbgotop())

do while ! SITUA->(eof())

   qgirabarra()
   CBO2->(dbgotop())

   if CBO2->(dbseek(SITUA->Cbo))
     if SITUA->(qrlock())
        replace SITUA->Cbo with CBO2->Cbo2002
     endif
   endif
   SITUA->(qunlock())

   SITUA->(dbskip())

enddo


return
