
function qbuscaind ( cINDICE , dDATA , lFLAG )

   iif(empty(lFLAG),lFLAG:=.F.,)

   if ! lFLAG
      if INDV->(dbseek(cINDICE+dtos(dDATA)))
         return INDV->Valor
      else
         return -1
      endif
   else
      INDV->( dbseek(cINDICE+dtos(dDATA),.T.) )
      if INDV->(found())
         return INDV->Valor
      else
         INDV->(dbskip(-1))
         if INDV->Indice == cINDICE
            return INDV->Valor
         else
            return -1
         endif
      endif
   endif

return

