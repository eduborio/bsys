/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: CONTAS A PAGAR
// OBJETIVO...: CONVERSAO DO CAMPO FORNECEDOR
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2001
// OBS........:
// ALTERACOES.:
function rb410


if ! qconf("Confirma Convers„o dos indices ?")
   return
endif

CLI1->(dbsetorder(1))
CLI1->(dbgotop())

RECEBER->(dbgotop())
RECEBIDO->(dbgotop())
REC_TESO->(dbgotop())

do while ! RECEBER->(eof())

   qgirabarra()

   CLI1->(dbseek(RECEBER->cod_cli))

   if RECEBER->(qrlock())

      replace RECEBER->cliente with CLI1->Razao

   endif

   RECEBER->(qunlock())

   RECEBER->(dbskip())

enddo


CLI1->(dbgotop())
do while ! RECEBIDO->(eof())

   qgirabarra()

   CLI1->(dbseek(RECEBIDO->cod_cli))

   if RECEBIDO->(qrlock())

      replace RECEBIDO->cliente with CLI1->Razao

   endif

   RECEBIDO->(qunlock())

   RECEBIDO->(dbskip())

enddo

CLI1->(dbgotop())
do while ! REC_TESO->(eof())

   qgirabarra()

   CLI1->(dbseek(REC_TESO->cod_cli))

   if REC_TESO->(qrlock())

      replace REC_TESO->cliente with CLI1->Razao

   endif

   REC_TESO->(qunlock())

   REC_TESO->(dbskip())

enddo


return
