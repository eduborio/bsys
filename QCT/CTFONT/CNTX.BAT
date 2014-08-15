@ echo off
set lib2=%lib%
set path2=%path%
set lib=%lib%;\qsys_g\qutil;\clipper\lib
set path=%path%;\clipper\bin;\blinker\bin
CLS
@echo on
RMAKE QCT
BLINKER @QCTntx
@echo off

set lib=%lib2%
set lib2=""

set path=%path2%
set path2=""



