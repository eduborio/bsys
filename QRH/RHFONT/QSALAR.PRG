
///////////////////////////////////////////////////////////////////////////////
// SISTEMA....: QSALAR
// OBJETIVO...: ATUALIZA SALRIO DO MEGA PARA QSYS
// COMO USAR..: QSALAR E001 9705

parameters cDIRETORIO, cANOMES
private nREC, cEMPRESA := right(cDIRETORIO,3)

? "ATUALIZANDO"

cPATH2 := "\QCONVERT\"
cPATH3 := "\QSYS_G\QRH\" + cDIRETORIO + "\"
quse(cPATH2,"SALAR"+cEMPRESA,NIL,"E","SALAR")
quse(cPATH3,"SITUA",{"SI_MATRI"},"E")

SALAR->(dbgotop())
SALAR->(dbCreateIndex( (cPATH2 + "MATRIC"), "FUNCC+dtos(DATA)", {|| Funcc+dtos(Data)}, if( .F., .T., NIL )))
SITUA->(dbgotop())

do while ! SITUA->(eof())
   qgirabarra()
   if val(SITUA->Anomes) <= val(cANOMES)
      SALAR->(dbgotop())
      SALAR->(dbSetFilter({|| Funcc == SITUA->Matricula}, 'Funcc == SITUA->Matricula'))
      SALAR->(dbgobottom())
      replace SITUA->Salario with SALAR->Valor
   endif
   SITUA->(dbskip())
enddo

SITUA->(dbclosearea())
SALAR->(dbclosearea())
