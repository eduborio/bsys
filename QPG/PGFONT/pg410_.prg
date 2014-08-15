/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: CONTAS A PAGAR
// OBJETIVO...: CONVERSAO DO CAMPO FORNECEDOR
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2001
// OBS........:
// ALTERACOES.:
function pg410


if ! qconf("Confirma Convers„o dos indices ?")
   return
endif

FORN->(dbsetorder(1))
FORN->(dbgotop())

PAGAR->(dbgotop())
PAGOS->(dbgotop())
PAG_TESO->(dbgotop())

do while ! PAGAR->(eof())

   qgirabarra()

   FORN->(dbseek(PAGAR->Cod_forn))

   if PAGAR->(qrlock())

      replace PAGAR->Fornec with FORN->Razao

   endif

   PAGAR->(qunlock())

   PAGAR->(dbskip())

enddo


FORN->(dbgotop())
do while ! PAGOS->(eof())

   qgirabarra()

   FORN->(dbseek(PAGOS->Cod_forn))

   if PAGOS->(qrlock())

      replace PAGOS->Fornec with FORN->Razao

   endif

   PAGOS->(qunlock())

   PAGOS->(dbskip())

enddo

FORN->(dbgotop())
do while ! PAG_TESO->(eof())

   qgirabarra()

   FORN->(dbseek(PAG_TESO->Cod_forn))

   if PAG_TESO->(qrlock())

      replace PAG_TESO->Fornec with FORN->Razao

   endif

   PAG_TESO->(qunlock())

   PAG_TESO->(dbskip())

enddo


return
