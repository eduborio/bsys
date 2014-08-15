 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: CONSULTA MOVIMENTO DO CAIXA
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1998
// OBS........:
// ALTERACOES.:
function ts314

private nSALDO_ATU := 0

SALD_CAI->(Dbsetorder(1))
SALD_CAI->(Dbgotop())

if ! SALD_CAI->(dbseek(XDATA))
   nSALDO_ATU := 0  // final de semana ?
else
   nSALDO_ATU := SALD_CAI->Saldo
endif

XNIVEL := 1

qlbloc(5,0,"B314A","QBLOC.GLO",1)

qrsay ( XNIVEL++ , transform(SALD_CAI->Saldo,"@R 999,999,999.99"  ))

MOV_CAIX->(Dbsetorder(1))
MOV_CAIX->(Dbgotop())
set softseek on
MOV_CAIX->(Dbseek(XDATA))
set softseek off

do while ! MOV_CAIX->(eof()) .and. MOV_CAIX->Data == XDATA

   if ! empty(MOV_CAIX->Entrada)
      nSALDO_ATU += MOV_CAIX->Entrada
   endif

   if ! empty(MOV_CAIX->Saida)
      nSALDO_ATU -= MOV_CAIX->Saida
   endif

   MOV_CAIX->(Dbskip())

enddo

qrsay ( XNIVEL++ , transform(nSALDO_ATU,"@R 9,999,999.99"  ))

i_lancs()

return

///////////////////////////////////////////////////////////////
// FUNCAO QUE MOSTRA O VIEW DOS LANCAMENTOS DO DIA DO BANCO ___
static function i_lancs

//setcolor("W/B")

MOV_CAIX->(qview({{"Num_docto/Docto"                     ,0},;
                  {"left(Historico,45)/Hist¢rico"        ,0},;
                  {"f314b()/Valor"                       ,0},;
                  {"f314a()/E/S"                         ,0}},;
                  "07002179S",;
                  {NIL,"f314k",NIL,NIL},;
                  {"MOV_CAIX->Data == XDATA",{||f314top()},{||f314bot()}},;
                  "<ESC> para retornar/ <E>xcluir / <A>lterar"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR O VALOR DE ENTRADA OU SAIDA _________________________

function f314b
   if empty(MOV_CAIX->Saida)
      return transform(Entrada, '@E 99,999,999.99')
   else
      return transform(Saida, '@E 99,999,999.99')
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A SITUACAO  DE ENTRADA OU SAIDA _____________________

function f314a
   if empty(MOV_CAIX->Saida)
      return "E"
   else
      return "S"
   endif
return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f314top
   MOV_CAIX->(dbsetorder(1))
   MOV_CAIX->(dbseek(XDATA))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f314bot
   MOV_CAIX->(dbsetorder(1))
   MOV_CAIX->(qseekn(XDATA))
return

function f314k
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "E"
      i_exclusao()

      return
   endif

   if cOPCAO == "A"
      i_altera()

      return
   endif


   setcursor(nCURSOR)
return ""

static function i_exclusao
   if qconf("Confirma exclus„o deste Movimento no Caixa ?")

      if MOV_CAIX->(qrlock())
         MOV_CAIX->(dbdelete())
         MOV_CAIX->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_altera
local newValor := 0
local nLinha    := 0

  nLinha := row()

   qgetx(nLinha,61,@newValor,"@E 999,999.99")

   if MOV_CAIX->(qrlock())

      if MOV_CAIX->Entrada > 0
         replace MOV_CAIX->Entrada with newValor
      endif

      if MOV_CAIX->Saida > 0
         replace MOV_CAIX->Saida   with newValor
      endif


      MOV_CAIX->(qunlock())
   endif


return



