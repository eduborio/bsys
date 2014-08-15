clear
dbusearea(.T.,,"CLI1")
   if !file("CLI1_COD.NTX")
      dbcreateind("CLI1_COD","Codigo",{|| Codigo})
   endif
dbsetindex("CLI1_COD")
CLI1->(dbsetorder(1))
CLI1->(dbgotop())
nCONT:= 0
nMAX := 0
nMAX := CLI1->(Lastrec())
for ncont := 0 to nMAX
     replace CLI1->Codigo with strzero(nCONT+1,5)
     CLI1->(dbskip())
next






