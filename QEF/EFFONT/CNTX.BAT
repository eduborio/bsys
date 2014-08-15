@ echo off
set lib2=%lib%
set lib=%lib%;\qsys_g\qutil;\clipper\lib
CLS
@echo on
RMAKE QEF
BLINKER @QEFntx
@echo off

set lib=%lib2%
set lib2=""
