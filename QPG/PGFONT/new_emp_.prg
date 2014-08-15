// ESTA ROTINA E ACIONADA SEMPRE QUE CRIADA UMA EMPRESA __________________________

function new_emp

   if ! quse(XDRV_PG,"CONFIG") ; return ; endif

   if CONFIG->(eof())
      CONFIG->(qappend())
      replace CONFIG->Pathconta with "\QSYS_G\QFU\IQ\"
      replace CONFIG->Pathteso  with "\QSYS_G\QFU\IQ\"
   endif

   CONFIG->(dbclosearea())

return
