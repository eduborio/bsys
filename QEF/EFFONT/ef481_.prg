/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO
// OBJETIVO...: PROPAGACAO DE SALDOS (SOMENTE NAS SAIDAS)
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2005
// OBS........:
// ALTERACOES.:
function ef481

local nCONT := 0

if ! qconf("Confirma Busca de Cfop ?")
   return .F.
endif

qmensa("Buscando Registros... Aguarde")

FAT->(dbsetorder(11))
FAT->(dbgotop())
SAI->(dbGotop())

do while ! SAI->(eof())


   qgirabarra()
   qmensa(SAI->Num_nf )
   if FAT->(dbseek(SAI->Num_nf))
      SAI->(Qrlock())
      replace SAI->Cfop with left(FAT->Cod_cfop,4)
      SAI->(Qunlock())
   endif


   SAI->(dbskip())

enddo

PEDIDO->(dbsetorder(10))
PEDIDO->(dbgotop())
ENT->(dbGotop())

do while ! ENT->(eof())


   qgirabarra()
   qmensa(ENT->Num_nf )
   if PEDIDO->(dbseek(ENT->Num_nf+ENT->Cod_forn))
      ENT->(Qrlock())
      replace ENT->Cfop with left(PEDIDO->cfop,4)
      ENT->(Qunlock())
   endif


   ENT->(dbskip())

enddo


return
