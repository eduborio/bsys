// ESTA ROTINA E ACIONADA SEMPRE QUE CRIADA UMA EMPRESA __________________________
function new_emp

   if ! quse(XDRV_CP,"CONFIG") ; return ; endif

   if CONFIG->(eof())
      CONFIG->(qappend())
      if CONFIG->(qrlock())
         replace CONFIG->Cod_forn with 0
         CONFIG->(Qunlock())
      endif
   endif

   CONFIG->(dbclosearea())

return
