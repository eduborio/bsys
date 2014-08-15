clear
dbusearea(.T.,,"CLI1")
   if !file("CLI1_COD.NTX")
      dbcreateind("CLI1_COD","Codigo",{|| Codigo})
   endif
dbsetindex("CLI1_COD")

dbusearea(.T.,,"FAT")
   if !file("FAT_cCLI1.NTX")
      dbcreateind("FAT_cCLI1","Cod_cli",{|| Cod_cli})
   endif
dbsetindex("FAT_cCLI1")

CLI1->(dbsetorder(1))
FAT ->(dbsetorder(1))
FAT->(dbgotop())
fRAZAO := space(65)
   do while ! FAT->(eof())
      CLI1->(dbseek(FAT->Cod_cli))
      fRAZAO := CLI1->Razao
      replace FAT->Cliente with fRAZAO
      FAT->(dbskip())


   enddo



