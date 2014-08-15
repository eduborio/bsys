call "c:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"
@echo off
set path2=%path%
set path=%path%;c:\hb20\bin;c:\Program Files\Microsoft Visual Studio 9.0\VC\bin
@echo on

hbmk2 qpg.hbm -inc

@echo off
set path=%path2%
set path2=""
@echo on

