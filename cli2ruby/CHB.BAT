@echo off
set path2=%path%
set path=%path%;c:\borland\bcc55\bin
@ echo on
hbmake cli2ruby
@echo off
set path=%path2%
set path2=""
copy cli2ruby.exe c:\qsys_g\qutil





