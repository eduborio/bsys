
// CONTROLES DO ADMIN
// HISTORICO DE LOGIN E ATIVIDADES

function qad_hist
if ! quse("","QPROGS",{"QPROGS"})                      ; return .F. ; endif
if ! quse("","QLOGIN",{"QLOGIN1","QLOGIN2","QLOGIN3"}) ; return .F. ; endif

QUSERS->(ordsetfocus(2)) // ordem de usrnum

QLOGIN->(dbsetrelation("QUSERS",{||Usrnum},"Usrnum"))
QLOGIN->(dbsetrelation("QPROGS",{||Prog}  ,"Prog"  ))
QLOGIN->(dbsetfilter({||Empresa==XEMPRESA},"Empresa==XEMPRESA"))
QLOGIN->(dbgotop())

QLOGIN->(qview({{"Datalog/Data"       ,1},;
                {"zhist1()/Usr."      ,2},;
                {"zhist2()/Prog."     ,3},;
                {"Inicio"             ,0},;
                {"Final"              ,0}},"C"))

QLOGIN->(dbclosearea())
QPROGS->(dbclosearea())
QUSERS->(ordsetfocus("IDENTIFIC"))

return .T.

function zhist1
   local cIDT := qdecri(QUSERS->Identific)
return (Usrnum+"/"+subs(cIDT,11,10))

function zhist2
return (Prog+"/"+left(QPROGS->Descricao,20))

