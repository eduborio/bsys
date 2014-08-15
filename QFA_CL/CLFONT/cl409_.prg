/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO
// OBJETIVO...: Acerto de IPI
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2012
// OBS........:
// ALTERACOES.:

function cl409

	if ! qconf("Confirma Acerto de IPi ?")
		return .F.
	endif
	
	PROD->(dbsetorder(4))
	
	ITEN_FAT->(dbgotop())
	do while ! ITEN_FAT->(eof())
       
	   if ITEN_FAT->Data < ctod("27/03/2012")
	      if ITEN_FAT->(qrlock())
		     replace ITEN_FAT->ipi with 15.00
          endif
	   else
	      PROD->(dbseek(ITEN_FAT->Cod_prod))
		  if ITEN_FAT->(qrlock())
		     replace ITEN_FAT->ipi with PROD->Ipi
          endif
       endif	   
	
	   ITEN_FAT->(dbskip())
	enddo
	
	
	ITEM_PEN->(dbgotop())
	do while ! ITEM_PEN->(eof())
       
	   if ITEM_PEN->Data < ctod("27/03/2012")
	      if ITEM_PEN->(qrlock())
		     replace ITEM_PEN->ipi with 15.00
          endif
	   else
	      PROD->(dbseek(ITEM_PEN->Cod_prod))
		  if ITEM_PEN->(qrlock())
		     replace ITEM_PEN->ipi with PROD->Ipi
          endif
       endif	   
	
	   ITEM_PEN->(dbskip())
	enddo
	

return