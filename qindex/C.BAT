set lib2=%lib%
set lib=%lib%;c:\qsys_g\qutil;c:\clipper\lib

CLS
RMAKE Qindex
BLINKER @QINDEX

set lib=%lib2%

