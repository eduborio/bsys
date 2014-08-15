rem call c:\qsys_g\qutil\msvc.bat
call "%VC%\vcvarsall.bat"
@echo off
set path2=%path%
set path=%path%;c:\hb20\bin;%VC%\bin
@echo on

hbmk2 hbqsys.hbm 
copy hbqsys.lib c:\hb20\lib\win\msvc

@echo off
set path=%path2%
set path2=""
@echo on

