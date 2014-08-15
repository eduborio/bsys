
// ESTA ROTINA E ACIONADA SEMPRE QUE CRIADA UMA EMPRESA __________________________

function new_emp

   local cMACRO

   if ! quse(XDRV_CT,"CONFIG") ; return ; endif

   if CONFIG->(eof())
      CONFIG->(qappend())
   endif

   CONFIG->(dbclosearea())

   if ! quse(XDRV_CT ,"RESULT") ; return ; endif

   cMACRO := XDRV_CTX + "RESULT.DBF"

   if RESULT->(qflock())
      append from &cMACRO
      replace all RESULT->Combina2 with ""
   endif
   
   RESULT->(dbclosearea())

   if ! quse(XDRV_CT ,"RESULTAD") ; return ; endif

   cMACRO := XDRV_CTX + "RESULTAD.DBF"

   if RESULTAD->(qflock())
      append from &cMACRO
      replace all RESULTAD->Combina2 with ""
   endif
   
   RESULTAD->(dbclosearea())

return

