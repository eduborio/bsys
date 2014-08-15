/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE NOTAS FISCAIS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: setembro de 2006
// OBS........:
// ALTERACOES.:

function cl408
if ! qconf("Rodar Procura de No nos enderecos dos clientes ?")
   return .F.
endif
  acertaNums()

return

static function acertaNums
local nPosicao   := 0
local nTamanho   := 0
local cNumero    := ""
local cEndNovo   := ""
local cGetNumero := space(7)
local cGetCompl  := space(20)
local nLerEndate := 0

  clear

  CLI1->(dbgotop())
  do while ! CLI1->(Eof())

     clear

     nTamanho := len(CLI1->end_ent)
     nPosicao := at(",",CLI1->End_ent)
     if nPosicao > 0
        cNumero  := substr(CLI1->End_ent,nPosicao+1,nTamanho)
        cEndNovo := substr(CLI1->End_ent,1,nPosicao-1)
     endif

     @ 07,10 say CLI1->NUmero
     @ 08,10 say CLI1->Compl
     @ 09,10 say CLI1->Codigo
     @ 10,10 say CLI1->Razao
     @ 11,10 say "         1         2         3         4         5         6"
     @ 12,10 say "123456789012345678901234567890123456789012345678901234567890"
     @ 13,10 say CLI1->end_ent
     @ 14,10 say cNumero

     if qconf("O endereco esta OK ?")
        nPosicao   := 0
        nTamanho   := 0
        nLerEndAte := 0
        cNumero    := ""
        cEndNovo   := ""
        CLI1->(dbskip())
        loop
     endif

     if qconf("Deseja Gravar este endereco, ou mudar os dados ?")
        if CLI1->(qrlock())
           replace CLI1->Numero  with alltrim(cNumero)
           replace CLI1->End_ent with cEndNovo
           CLI1->(qunlock())
        endif
     else
        @ 16,10 say "Numero.....: "
        qgetx(16,23,@cGetNumero)
        @ 17,10 say "Compl......: "
        qgetx(17,23,@cGetCompl)
        @ 18,10 say "Ler end Ate: "
        qgetx(18,23,@nLerEndAte)

        if CLI1->(qrlock())
           if ! empty(cGetNumero)
              replace CLI1->Numero  with cGetNumero
           endif
           if ! empty(cGetCompl)
              replace CLI1->Compl   with cGetCompl
           endif
           if nLerEndAte > 0
              replace CLI1->End_ent with left(CLI1->End_ent,nLerEndAte)
           endif
           CLI1->(qunlock())
        endif

     endif

     @ 20,10 say CLI1->Codigo
     @ 21,10 say CLI1->Razao
     @ 22,10 say CLI1->end_ent
     @ 23,10 say CLI1->Numero + " Compl.: "+CLI1->Compl
     qinkey(0)


     CLI1->(dbskip())

     nPosicao   := 0
     nTamanho   := 0
     nLerEndAte := 0
     cNumero    := ""
     cEndNovo   := ""


  enddo

  CLI1->(dbcommit())

return

