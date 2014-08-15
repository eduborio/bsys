// ESTA ROTINA E ACIONADA SEMPRE QUE CRIADA UMA EMPRESA __________________________
function new_emp

   if ! quse(XDRV_EF,"CONFIG") ; return ; endif

   if CONFIG->(eof())
      CONFIG->(qappend())
      replace CONFIG->Num_lote with 1
   endif

   CONFIG->(dbclosearea())

   // COPIA ARQUIVO DE TRIBUTOS DA EMPRESA 001 PARA A NOVA EMPRESA _______________

   private cORIGEM  := XDRV_EFX + "TRIB.DBF"
   private cDESTINO := XDRV_EF  + "TRIB.DBF"

   copy file &cORIGEM to &cDESTINO

return
