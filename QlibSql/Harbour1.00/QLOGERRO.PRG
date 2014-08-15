function qlogerro
local aSTRUCT := {}

aadd(aSTRUCT,{"XDATA" ,"D",  8,0})
aadd(aSTRUCT,{"XHORA" ,"C",  5,0})
aadd(aSTRUCT,{"USR"   ,"C", 10,0})
aadd(aSTRUCT,{"OPCAO" ,"C",  3,0})
aadd(aSTRUCT,{"ERRO"  ,"C", 55,0})
aadd(aSTRUCT,{"TRACE1","C",500,0})

dbcreate("QERRSYS",aSTRUCT)

if ! quse("","QPROGS",{"QPROGS"}) ; return .F. ; endif
if ! quse("","QERRSYS") ; return .F. ; endif

qmensa("Aguarde, carregando log de erros...")

append from ("QERRSYS.LOG") sdf for qgirabarra()

index on descend(dtos(XDATA)+XHORA) to QERRSYS for qgirabarra()

set filter to ! empty(Erro)

set relation to OPCAO into QPROGS

dbgotop()

qlbloc(5,0,"LOGERRO1",XDRV_SH+"QSBLOC.GLO",1)

qview({{"XDATA/Data" ,1},;
       {"XHORA/Hora" ,0},;
       {"ERRO/Erro"  ,0}},;
       "05002179",;
       {"i_err_trace",NIL,"i_err_tela",NIL},;
       NIL,;
       "<ESC> p/ retornar ou <ENTER> p/ ver Trace...")

QERRSYS->(dbclosearea())
QPROGS->(dbclosearea())

erase ("QERRSYS.DBF")
erase ("QERRSYS.DBT")
erase ("QERRSYS.NTX")

return

/////////////////////////////////////////////////////////////////////////////
// TRACE RETROATIVO DE EXECUCAO _____________________________________________

function i_err_trace
   local cTRACE := QERRSYS->Trace1

   cTRACE := strtran(cTRACE,chr(255),chr(13)+chr(10))

   qmensa("<ESC> p/ retornar...")

   qlbloc(6,29,"LOGERRO2",XDRV_SH+"QSBLOC.GLO",1)

   memoedit(cTRACE,09,30,20,71)

return

/////////////////////////////////////////////////////////////////////////////
// REFRESH DE TELA __________________________________________________________

function i_err_tela
   qsay(22,12,QERRSYS->Usr)
   qsay(22,31,QPROGS->Prog)
   qsay(22,37,QPROGS->Descricao)
return .T.

