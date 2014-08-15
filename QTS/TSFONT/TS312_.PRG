 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: CONSULTA EXTRATO BANCARIO DO DIA
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1998
// OBS........:
// ALTERACOES.:
function ts312

private nSALDO_ATU := 0
private nSALDO_ANT := 0

BANCO->(qview({{"Codigo/C¢digo"                          ,0},;
               {"Banco/Banco"                            ,1},;
               {"left(Descricao,20)/Nome"                ,2},;
               {"c101b()/Nr. Conta"                      ,0},;
               {"Agencia/Agˆncia"                        ,0},;
               {"Telefone/Telefone"                      ,0},;
               {"Gerente/Gerente"                        ,0}},"P",;
               {NIL,"c312a",NIL,NIL},;
                NIL,"<E>xtrato do dia"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c312a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "E"
      qlbloc(5,0,"B312A","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1
   qrsay ( XNIVEL++ , BANCO->Codigo     )
   qrsay ( XNIVEL++ , left(BANCO->Descricao,25))

   SALD_BAN->(Dbsetorder(1))
   SALD_BAN->(Dbgotop())

   if ! SALD_BAN->(dbseek(dtos(XDATA)+BANCO->Codigo))
      nSALDO_ATU := 0  // final de semana ?
      SALD_BAN->(Dbskip(-1))
      nSALDO_ATU := SALD_BAN->Saldo
   else
      nSALDO_ATU := SALD_BAN->Saldo
   endif

   qrsay ( XNIVEL++ , transform(SALD_BAN->Saldo,"@R 99,999,999.99"  ))

   MOV_BANC->(Dbsetorder(1))
   MOV_BANC->(Dbgotop())
   set softseek on
   MOV_BANC->(Dbseek(XDATA))
   set softseek off

   do while ! MOV_BANC->(eof()) .and. MOV_BANC->Data = XDATA

      if MOV_BANC->Cod_banco <> BANCO->Codigo
         MOV_BANC->(Dbskip())
         loop
      endif

      if ! empty(MOV_BANC->Entrada)
         nSALDO_ATU += MOV_BANC->Entrada
      endif

      if ! empty(MOV_BANC->Saida)
         nSALDO_ATU -= MOV_BANC->Saida
      endif

      MOV_BANC->(Dbskip())

   enddo

   qrsay ( XNIVEL++ , transform(nSALDO_ATU,"@R 999,999,999.99"  ))

   qrsay( XNIVEL++ , dtoc(XDATA))

   i_lancs()

return

///////////////////////////////////////////////////////////////
// FUNCAO QUE MOSTRA O VIEW DOS LANCAMENTOS DO DIA DO BANCO ___
static function i_lancs

//setcolor("W/B")

MOV_BANC->(qview({{"Num_docto/Docto"                     ,0},;
                  {"left(Historico,45)/Hist¢rico"        ,0},;
                  {"f312b()/Valor"                       ,0},;
                  {"f312a()/E/S"                         ,0}},;
                  "07002178S",;
                  {NIL,"f312k",NIL,NIL},;
                  {"MOV_BANC->Cod_banco == BANCO->Codigo .and. MOV_BANC->Data == XDATA",{||f312top()},{||f312bot()}},;
                  "<ESC> para retornar / <E>xcluir / <A>lterar"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR O VALOR DE ENTRADA OU SAIDA _________________________

function f312b
   if empty(MOV_BANC->Saida)
      return transform(Entrada, '@E 99,999,999.99')
   else
      return transform(Saida, '@E 99,999,999.99')
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A SITUACAO  DE ENTRADA OU SAIDA _____________________

function f312a
   if empty(MOV_BANC->Saida)
      return "E"
   else
      return "S"
   endif
return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f312top
   MOV_BANC->(dbsetorder(2))
   MOV_BANC->(dbseek(BANCO->Codigo+dtos(XDATA)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f312bot
   MOV_BANC->(dbsetorder(2))
   MOV_BANC->(qseekn(BANCO->Codigo+dtos(XDATA)))
return

function f312k
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
   if qconf("Confirma exclus„o deste Movimento no Banco ?")

      if MOV_BANC->(qrlock())
         MOV_BANC->(dbdelete())
         MOV_BANC->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_altera
local newValor := 0
local nLinha    := 0

  nLinha := row()

   qgetx(nLinha,60,@newValor,"@E 999,999.99")

   if MOV_BANC->(qrlock())

      if MOV_BANC->Entrada > 0
         replace MOV_BANC->Entrada with newValor
      endif

      if MOV_BANC->Saida > 0
         replace MOV_BANC->Saida   with newValor
      endif


      MOV_BANC->(qunlock())
   endif


return


