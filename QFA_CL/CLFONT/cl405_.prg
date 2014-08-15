/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO
// OBJETIVO...: Populate no arquivo ITEN_FAT com o preco de custo do periodo de cada venda
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2007
// OBS........:
// ALTERACOES.:

function cl405
local nCONT  := 0
local nVALOR := 0
local nALIQ  := 0
local nDESC  := 0

if ! qconf("Confirma Geracao de Repres para FAT ?")
   return .F.
endif


nCONT  := 0
nVALOR := 0
nALIQ  := 0
nDESC  := 0

FAT->(dbsetorder(1))
FAT->(dbgotop())

do while ! FAT->(eof())

   CLI1->(Dbseek(FAT->Cod_cli))
   REPRES->(Dbseek(CLI1->Cod_repres))

   if FAT->(Qrlock())
      replace FAT->Cod_repres with REPRES->Codigo
      FAT->(Qunlock())
   endif

   qgirabarra()
   qmensa(FAT->Cod_cli )



   FAT->(dbskip())

enddo

PEND->(dbsetorder(1))
PEND->(dbgotop())

do while ! PEND->(eof())

   CLI1->(Dbseek(PEND->Cod_cli))
   REPRES->(Dbseek(CLI1->Cod_repres))

   if PEND->(Qrlock())
      replace PEND->Cod_repres with REPRES->Codigo
      PEND->(Qunlock())
   endif

   qgirabarra()
   qmensa(PEND->Cod_cli )



   PEND->(dbskip())

enddo


return
