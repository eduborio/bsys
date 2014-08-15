@echo off
set path2=%path%
set path=%path%;c:\hb20\bin;c:\borland\bcc55\bin
@echo on

hbmk2 qcl.hbm

@echo off
set path=%path2%
set path2=""
@echo on

