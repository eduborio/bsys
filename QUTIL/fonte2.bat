cd\qsys_g\q%1\%1font
pkzip c:\Dudu\%1font -x*.obj -x*.err -x*.zip -x*.arj -x*.old -x*.bak -x*.bor -x*.and -x*.exe -x*.luc -x*.lu -x*.edu -ex

pause
cd\qsys_g\q%1\%1bloc
pkzip c:\Dudu\%1bloc *.rrb -ex

pause
cd\qsys_g\q%1\e001
pkzip c:\Dudu\%1E001 *.db? -ex

pause
cd\qsys_g\q%1
pkzip c:\Dudu\q%1 *.db? -ex

pause


