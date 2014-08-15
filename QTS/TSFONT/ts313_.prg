 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: CONSULTA EXTRATO BANCARIO PASSADO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1998
// OBS........:
// ALTERACOES.:
function ts313

private nSALDO_ATU := 0
private nSALDO_ANT := 0
private nVAL       := 0
private dDATA1      := ctod("")
private dDATA2      := ctod("")

BANCO->(qview({{"Codigo/C¢digo"                          ,0},;
               {"Banco/Banco"                            ,1},;
               {"left(Descricao,20)/Nome"                ,2},;
               {"c101b()/Nr. Conta"                      ,0},;
               {"Agencia/Agˆncia"                        ,0},;
               {"Telefone/Telefone"                      ,0},;
               {"Gerente/Gerente"                        ,0}},"P",;
               {NIL,"c313a",NIL,NIL},;
                NIL,"<E>xtrato Passado"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c313a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "E"

      qlbloc(12,20,"B313A","QBLOC.GLO",1)  // data da consulta
      i_edicao()

      qlbloc(5,0,"B313B","QBLOC.GLO",1)
      i_edicao1()

   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA1).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA1        ,"@D")                    },"DATA1"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA2        ,"@D")                    },"DATA2"     })

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; BANCO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo


return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DATA2"
           if dDATA2 > CONFIG->Data_atual
              qmensa("Data ‚ superior a do Sistema...","B")
              return .F.
           endif
           if dDATA2 < dDATA1
              qmensa("Data Final ‚ Inferior a data inicial !","B")
              return .F.
           endif

   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao1

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1
   qrsay ( XNIVEL++ , BANCO->Codigo     )
   qrsay ( XNIVEL++ , left(BANCO->Descricao,25))

   SALD_BAN->(Dbsetorder(1))
   SALD_BAN->(Dbgotop())

   if ! SALD_BAN->(dbseek(dtos(dDATA2)+BANCO->Codigo))
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
   MOV_BANC->(Dbseek(dDATA1))
   set softseek off

   do while ! MOV_BANC->(eof()) .and. MOV_BANC->Data >= dDATA1 .and. MOV_BANC->Data <= dDATA2

      if MOV_BANC->Cod_banco <> BANCO->Codigo
         MOV_BANC->(Dbskip())
         loop
      endif

      if MOV_BANC->Data == dDATA2
         if ! empty(MOV_BANC->Entrada)
            nSALDO_ATU += MOV_BANC->Entrada
         endif

         if ! empty(MOV_BANC->Saida)
            nSALDO_ATU -= MOV_BANC->Saida
         endif
      endif
      MOV_BANC->(Dbskip())

   enddo

   if nSALDO_ATU <> SALD_BAN->Saldo
      qrsay ( XNIVEL++ , transform(nSALDO_ATU,"@R 999,999,999.99"  ))
   else
      qrsay ( XNIVEL++ , transform(nSALDO_ATU,"@R 999,999,999.99"  ))
   endif

   qrsay ( XNIVEL++, dtoc(dDATA2))

   i_lancs()

return

///////////////////////////////////////////////////////////////
// FUNCAO QUE MOSTRA O VIEW DOS LANCAMENTOS DO DIA DO BANCO ___
static function i_lancs

//setcolor("W/B")

MOV_BANC->(qview({{"Num_docto/Docto"                     ,0},;
                  {"left(Historico,45)/Hist¢rico"        ,0},;
                  {"f313b()/Valor"                       ,0},;
                  {"f313a()/E/S"                         ,0}},;
                  "07002178S",;
                  {NIL,NIL,NIL,NIL},;
                  {"MOV_BANC->Cod_banco == BANCO->Codigo .and. MOV_BANC->Data >= dDATA1 .and. MOV_BANC->Data <= dDATA2",{||f313top()},{||f313bot()}},;
                  "<ESC> para retornar"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR O VALOR DE ENTRADA OU SAIDA _________________________

function f313b
   if empty(MOV_BANC->Saida)
      return transform(Entrada, '@E 99,999,999.99')
   else
      return transform(Saida, '@E 99,999,999.99')
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A SITUACAO  DE ENTRADA OU SAIDA _____________________

function f313a
   if empty(MOV_BANC->Saida)
      return "E"
   else
      return "S"
   endif
return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f313top
   MOV_BANC->(dbsetorder(2))
   MOV_BANC->(dbseek(BANCO->Codigo+dtos(dDATA1)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f313bot
   MOV_BANC->(dbsetorder(2))
   MOV_BANC->(qseekn(BANCO->Codigo+dtos(dDATA2)))
return
