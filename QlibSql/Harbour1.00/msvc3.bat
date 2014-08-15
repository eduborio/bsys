rem call c:\qsys_g\qutil\msvc.bat
call "%VC10%\vcvarsall.bat"
@echo off
set path2=%path%
set path=%path%;c:\hb30\bin;%VC10%\bin
@echo on

hbmk2 hbqsys.hbm 
copy hbqsys.lib c:\hb30\lib\win\msvc

@echo off
set path=%path2%
set path2=""
@echo on

