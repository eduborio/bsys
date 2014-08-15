cls
@ echo off
set path=%path%;c:\Borland\BCC55\Bin;c:\harbour-1.0.0\bin
set lib=c:\Harbour-1.0.0\lib;c:\Borland\BCC55\Lib
set include=c:\Harbour-1.0.0\include;c:\Borland\BCC55\Include
@ echo on
hbmake hbqcl
@ echo off

