/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CAIXA
// OBJETIVO...: VERIFICA INTEGRIDADE DAS CONTAS NOS LANCAMENTOS
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO 2012
// OBS........:
// ALTERACOES.:

function ct404
private aLanc := {}
private nCont := 0


if ! qconf("Confirma Verificacao da Integridade dos lancamentos ?") ; return ; endif


  aLanc = {}
  PLAN->(dbsetorder(3))

  LANC->(dbgotop())
  do while ! LANC->(eof())

     if ! PLAN->(dbseek(LANC->Cont_db))
        aadd(aLanc,{LANC->num_lanc,LANC->Cont_db,"",LANC->Valor,LANC->Data_lanc})
     endif

     if ! PLAN->(dbseek(LANC->Cont_cr))
        aadd(aLanc,{LANC->num_lanc,"",LANC->Cont_cr,LANC->Valor,LANC->Data_lanc})
     endif
    
     LANC->(dbskip())

  enddo

  qinitprn()
    
  @ prow()+1, 00   say "Data"+chr(9) 
	  @ prow(), pcol() say "Numero Lanc" +chr(9)
	  @ prow(), pcol() say "Debito" +chr(9)
	  @ prow(), pcol() say "Credito" +chr(9)
	  @ prow(), pcol() say "Valor"+chr(9)
	  @ prow(), pcol() say "Historico"		
  nCont = 1

  for nCont := 1 to len(aLanc)
	  @ prow()+1, 00   say dtoc(aLanc[nCont,5])+chr(9) 
	  @ prow(), pcol() say aLanc[nCont,1] +chr(9)
	  @ prow(), pcol() say aLanc[nCont,2] +chr(9)
	  @ prow(), pcol() say aLanc[nCont,3] +chr(9)
	  @ prow(), pcol() say transf (aLanc[nCont,4],"@E 99,999,999.99") +chr(9)
  next
  
  qstopprn(.F.)


return

