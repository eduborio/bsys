@ echo off
set lib2=%lib%
set lib=%lib%;c:\hb20\lib\win\msvc

@ echo on
hbmk2 cli2ruby
copy cli2ruby.exe c:\qsys_g\qutil
@echo off
set lib=%lib2%
