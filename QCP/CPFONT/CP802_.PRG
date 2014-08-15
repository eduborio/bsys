/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: CONFIGURACAO DE SENHA DE LIBERACAO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:

// DECLARACAO DE VARIAVEIS __________________________________________________

function cp802

local cSENHALIB := fu_decodifica_senha(CONFIG->Senhalib)
local cSENHA_V, cSENHA_N1, cSENHA_N2, cTECLA

// LOOP DE SOLICITACAO DAS SENHAS ___________________________________________

do while .T.

   qlbloc(5,0,"B802A","QBLOC.GLO")

   qmensa("Digite a senha atual ou <ESC> para retornar...")

   cSENHA_V := qgetsenha(11,45,10)

   if lastkey() == 27 ; return ; endif

   if alltrim(cSENHA_V) <> alltrim(cSENHALIB) .and. ! chr(255)+chr(255) $ cSENHA_V
      alert("SENHA INVALIDA !",{"RETORNAR"})
      loop
   endif

   qmensa("Digite a nova senha...")

   cSENHA_N1 := qgetsenha(13,45,10)

   if len(alltrim(cSENHA_N1)) < 3
      alert("A SENHA DEVE TER NO MINIMO 3 LETRAS...",{"RETORNAR"})
      loop
   endif

   qmensa("Reconfirme a nova senha...")

   cSENHA_N2 := qgetsenha(15,45,10)

   if cSENHA_N1 == cSENHA_N2
      exit
   endif

   alert("CONFIRMACAO DA SENHA INCORRETA !",{"RETORNAR"})

enddo

// GRAVA NOVA SENHA _________________________________________________________

cSENHALIB := fu_codifica_senha(cSENHA_N1)

if CONFIG->(qrlock())
   replace CONFIG->Senhalib with cSENHALIB
else
   qm2()
endif

return

