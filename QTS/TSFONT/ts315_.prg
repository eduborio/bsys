//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: CONSULTA EXTRATO de Aplicacao Financeira
// ANALISTA...: Eduardo Borio
// PROGRAMADOR: Eduardo Borio
// INICIO.....: Outubro de 2006
// OBS........:
// ALTERACOES.:
function ts315

private nSALDO_ATU := 0
private nSALDO_ANT := 0

INSTITU->(qview({{"Codigo/C¢digo"                          ,0},;
               {"left(Nome,20)/Nome"                ,2},;
               {"Telefone/Telefone"                      ,0},;
               {"Gerente/Gerente"                        ,0}},"P",;
               {NIL,"c315a",NIL,NIL},;
                NIL,"<E>xtrato do dia"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c315a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "E"
      qlbloc(5,0,"B315A","QBLOC.GLO",1)
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
   qrsay ( XNIVEL++ , INSTITU->Codigo     )
   qrsay ( XNIVEL++ , left(INSTITU->Nome,25))

   SALD_FIN->(Dbsetorder(1))
   SALD_FIN->(Dbgotop())

   if ! SALD_FIN->(dbseek(dtos(XDATA)+INSTITU->Codigo))
      nSALDO_ATU := 0  // final de semana ?
      SALD_FIN->(Dbskip(-1))
      nSALDO_ATU := SALD_FIN->Saldo
   else
      nSALDO_ATU := SALD_FIN->Saldo
   endif

   qrsay ( XNIVEL++ , transform(SALD_FIN->Saldo,"@R 99,999,999.99"  ))

   MOV_FIN->(Dbsetorder(1))
   MOV_FIN->(Dbgotop())
   set softseek on
   MOV_FIN->(Dbseek(XDATA))
   set softseek off

   do while ! MOV_FIN->(eof()) .and. MOV_FIN->Data = XDATA

      if MOV_FIN->Cod_inst <> INSTITU->Codigo
         MOV_FIN->(Dbskip())
         loop
      endif

      if ! empty(MOV_FIN->Entrada)
         nSALDO_ATU += MOV_FIN->Entrada
      endif

      if ! empty(MOV_FIN->Saida)
         nSALDO_ATU -= MOV_FIN->Saida
      endif

      MOV_FIN->(Dbskip())

   enddo

   qrsay ( XNIVEL++ , transform(nSALDO_ATU,"@R 999,999,999.99"  ))

   qrsay( XNIVEL++ , dtoc(XDATA))

   i_lancs()

return

///////////////////////////////////////////////////////////////
// FUNCAO QUE MOSTRA O VIEW DOS LANCAMENTOS DO DIA DO BANCO ___
static function i_lancs

//setcolor("W/B")

MOV_FIN->(qview({{"Num_docto/Docto"                     ,0},;
                  {"left(Historico,45)/Hist¢rico"        ,0},;
                  {"f315b()/Valor"                       ,0},;
                  {"f315a()/E/S"                         ,0}},;
                  "07002178S",;
                  {NIL,NIL,NIL,NIL},;
                  {"MOV_FIN->Cod_inst == INSTITU->Codigo .and. MOV_FIN->Data == XDATA",{||f315top()},{||f315bot()}},;
                  "<ESC> para retornar"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR O VALOR DE ENTRADA OU SAIDA _________________________

function f315b
   if empty(MOV_FIN->Saida)
      return transform(Entrada, '@E 99,999,999.99')
   else
      return transform(Saida, '@E 99,999,999.99')
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A SITUACAO  DE ENTRADA OU SAIDA _____________________

function f315a
   if empty(MOV_FIN->Saida)
      return "E"
   else
      return "S"
   endif
return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f315top
   MOV_FIN->(dbsetorder(2))
   MOV_FIN->(dbseek(INSTITU->Codigo+dtos(XDATA)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f315bot
   MOV_FIN->(dbsetorder(2))
   MOV_FIN->(qseekn(INSTITU->Codigo+dtos(XDATA)))
return
