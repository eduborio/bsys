SET DATE BRITISH
SET CONFIRM ON

clear
dbusearea(.T.,,"FUN")
 if !file("FUNMATRI.NTX")
    dbcreateind("FUNMATRI","Matricula",{|| Matricula})
 endif

 if !file("FUNNOME.NTX")
    dbcreateind("FUNNOME","Nome",{|| Nome})
 endif

 dbsetindex("FUNNOME")
 dbsetindex("FUNMATRI")

 dbsetorder(1)
 cFUN       := space(30)
 cMATRI     := space(6)
 dD_ADM     := ctod("")
 cSITUA     := space(1)
 cFILIAL    := space(4)

 @ 5,5 say "Informe o nome de um funcionario :" get cFUN pict "@!"
 read

 FUN->(dbseek(cFUN))
 if !found()
   FUN->(dbsetorder(2))
   FUN->(dbgobottom())
   cMATRI := strzero(val(FUN->Matricula) + 1,6)
   
   FUN->(dbappend())
   field->FUN->Matricula := cMATRI
   field->FUN->Data_adm  := date()
   field->FUN->Situacao  := "T"
   field->FUN->Filial    := "0004"
   field->FUN->Nome      :=  cFUN

   FUN->(dbcommit())
 endif

 @ 7,5 say "Matricula         : " + FUN->Matricula
 @ 8,5 say "Data de Admissao  : " + dtoc(FUN->Data_adm)
 @ 9,5 say "Situacao          : " + FUN->Situacao
 @10,5 say "Filial            : " + FUN->Filial

 dbusearea(.T.,,"SALARIO")
 dbcreateind("SALMATRI","Matricula",{|| Matricula})

 nSAL   := 0
 cCARGO := space(20)

 SALARIO->(dbseek(FUN->Matricula))
  if SALARIO->(!found())
     @ 11,5 say "Salario           :" get nSAL   pict "99,999.99"
     @ 12,5 say "Cargo             :" get cCARGO pict "@!"
     read
     SALARIO->(dbappend())
     field->SALARIO->Matricula := FUN->Matricula
     field->SALARIO->Salario   := nSAL
     field->SALARIO->Cargo     := cCARGO
     SALARIO->(dbcommit())
  endif

 @ 11,5 say "Salario           : " + transf(SALARIO->Salario,"@E 99,999.99")
 @ 12,5 say "Cargo             : " + SALARIO->Cargo


















