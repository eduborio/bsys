cd\qsys_g\qcp
pkzip a:qcp qcp_.exe qbloc.glo qindex.dbf qprogs.dbf qstruct.dbf -ex
cd\qsys_g\qcp\cpfont
pkzip a:cpfont *.prg *.lnk *.rmk -ex
cd\qsys_g\qcp\cpbloc
pkzip a:cpbloc *.rrb -ex

cd\qsys_g\qes
pkzip a:qes qes_.exe qbloc.glo qindex.dbf qprogs.dbf qstruct.dbf -ex
cd\qsys_g\qes\esfont
pkzip a:esfont *.prg *.lnk *.rmk -ex
cd\qsys_g\qes\esbloc
pkzip a:esbloc *.rrb -ex

