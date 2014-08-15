cd\qsys_g\%1
copy *.exe *.bor
pkzip c:\qsystxt\%1 *.bor qbloc.glo qprogs.dbf qindex.dbf qstruct.dbf -ex
