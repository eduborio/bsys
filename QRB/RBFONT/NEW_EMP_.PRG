// ESTA ROTINA E ACIONADA SEMPRE QUE CRIADA UMA EMPRESA __________________________

function new_emp

   if ! quse(XDRV_RB,"CONFIG") ; return ; endif

   if CONFIG->(eof())
      CONFIG->(qappend())
      replace CONFIG->Num_lote  with 1
   endif

   CONFIG->(dbclosearea())

return
