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
        aadd(aLanc,{LANC->num_lanc,LANC->Cont_db,""})
     endif

     if ! PLAN->(dbseek(LANC->Cont_cr))
        aadd(aLanc,{LANC->num_lanc,"",LANC->Cont_cr})
     endif
    
     LANC->(dbskip())

  enddo

  nCont = 1
  for nCont := 1 to len(aLanc)
      alert("Problema encontrado no Lancamento No .: "+aLANC[nCont,1])
  next


return

