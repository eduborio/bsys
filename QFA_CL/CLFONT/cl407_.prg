/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO
// OBJETIVO...: Populate no arquivo ITEN_FAT com o preco de custo do periodo de cada venda
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2007
// OBS........:
// ALTERACOES.:

function cl407
local nCONT  := 0
local nVALOR := 0
local nALIQ  := 0
local nDESC  := 0
local dINI   := ctod("01/01/1995")

if ! qconf("Confirma POPULATE em ITENS ?")
   return .F.
endif


nCONT  := 0
nVALOR := 0
nALIQ  := 0
nDESC  := 0

PROD->(Dbsetorder(4))
PROD->(Dbgotop())


FAT->(dbsetorder(1))
FAT->(dbgotop())


Do while ! ITEN_FAT->(Eof())

   if FAT->(Dbseek(ITEN_FAT->Num_fat)) .and. ITEN_FAT->(qrlock())
      //replace ITEN_FAT->Data       with FAT->Dt_emissao
      if PROD->(Dbseek(ITEN_FAT->Cod_prod)) .and. ITEN_FAT->Preco_cust == 0
         replace ITEN_FAT->Preco_cust with PROD->Preco_cust
      endif

      Qunlock()
   endif

   ITEN_FAT->(Dbskip())
enddo

return
