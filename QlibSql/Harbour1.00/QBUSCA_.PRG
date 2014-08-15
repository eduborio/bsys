
/////////////////////////////////////////////////////////////////////////////
// BUSCA CENTRO SUPERIOR ____________________________________________________

function qbusca_sup ( cATUAL )
   local cCOD := space(8)
   local nREC := recno()

   if dbseek(cATUAL)
      do case
         case len(cATUAL) = 8
              cCOD := left(cATUAL,4)
         case len(cATUAL) = 4
              cCOD := left(cATUAL,2)
         case len(cATUAL) = 2
              cCOD := space(8)
      endcase
   endif

   dbgoto(nREC)
return cCOD

