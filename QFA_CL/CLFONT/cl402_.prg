/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO
// OBJETIVO...: GRAVA RESPONSAVEL DO REPRES NO FAT
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 2012
// OBS........:
// ALTERACOES.:

function cl402

if ! qconf("Confirma geraçao de responsaveis nos pedidos ?")
   return .F.
endif

do while ! FAT->(eof()) 

   CLI1->(dbseek(FAT->Cod_cli))
   if FAT->(qrlock())
      if ! empty(CLI1->Cod_resp)
	      replace FAT->Cod_resp with CLI1->cod_resp
	  else
         REPRES->(dbseek(FAT->Cod_repres))
         replace FAT->Cod_resp with REPRES->Cod_resp	
	  endif
	  FAT->(qunlock())
   endif	  

   FAT->(dbskip())

enddo


PEND->(dbsetorder(1))
PEND->(dbgotop())

do while ! PEND->(eof())

   CLI1->(dbseek(PEND->Cod_cli))
   
   if PEND->(qrlock())
      if ! empty(CLI1->Cod_resp)
	      replace PEND->Cod_resp with CLI1->cod_resp
		  qmensa("cli " + cli1->cod_resp)
	  else
         if REPRES->(dbseek(PEND->Cod_repres))
		    replace PEND->Cod_resp with REPRES->Cod_resp	
            qmensa("repres "+repres->cod_resp)		 
		 endif	
	  endif
	  PEND->(qunlock())
   endif	  
   
   PEND->(dbskip())

enddo

qmensa("Concluido!","BL")

return
