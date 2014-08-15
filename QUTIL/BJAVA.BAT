@ECHO OFF

IF     [%2] == [] GOTO SEM_LINHA
IF NOT [%2] == [] GOTO COM_LINHA

GOTO END

:SEM_LINHA
IF EXIST %1.java     Q %1.java
IF EXIST %1          Q %1
GOTO END

:COM_LINHA
IF EXIST %1.java     Q %1.java -n%2
IF EXIST %1          Q %1      -n%2
GOTO END

:END

rem VGA 2

cls


