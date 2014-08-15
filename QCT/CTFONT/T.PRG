function T
use \qsys_g\qct\e001\tipocont.dbf index \qsys_g\qct\e001\tipo_des.ntx
cls
do while .t.
 for n:= 1 to 11
   @ 01,01 say &("hi_comp"+alltrim(str(n)))
   @ 01,01 say &("ct_liq_"+alltrim(str(n)))
   @ 01,01 say &("ct_comp"+alltrim(str(n)))
   @ 01,01 say &("fu_comp"+alltrim(str(n)))
 next
skip
wait
enddo
return
