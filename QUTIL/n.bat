@ echo off
IF EXIST %1_.PRG     notepad++ %1_.PRG
IF EXIST %1.PRG      notepad++ %1.PRG
IF EXIST %1          notepad++ %1
IF EXIST %1.BAT      notepad++ %1.bat
