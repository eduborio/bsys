call "%VC%\vcvarsall.bat"
@echo off
set path2=%path%
set path=%path%;c:\hb20\bin;%VC%\bin
@echo on

hbmk2 qts.hbm -inc

@echo off
set path=%path2%
set path2=""
@echo on

