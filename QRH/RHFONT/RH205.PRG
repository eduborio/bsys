
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: LANCAMENTOS POR REFERENCIA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: IDEM
// INICIO.....: MAIO DE 1995
// OBS........:
// ALTERACOES.:

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

private cEVENTO                         // codigo do evento
private cAMBIENTE                       // ambiente sendo trabalhado
private cANOMES := qanomes(XDATASYS)    // anomes

// ESCOLHE AMBIENTE DE TRABALHO _____________________________________________

cAMBIENTE := rh_escolhe_amb() // "MS","AD","DT","FR","PV"
if empty(cAMBIENTE) ; return ; endif

// ESTABELECE RELACIONAMENTO ENTRE ARQUIVOS _________________________________

FUN->(dbSetRelation("LANC",{|| XANOMES+Matricula+cAMBIENTE+cEVENTO},"XANOMES+Matricula+cAMBIENTE+cEVENTO"))
FUN->(dbSetFilter( {|| Situacao <> "H"},'Situacao <> "H"'))

i_inic_205()

FUN->(dbClearRel())

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE INICIALIZACAO SOLICITANDO MATRICULA E REALIZANDO VIEW __________

static function i_inic_205

   do while .T.

      // TRAZ BLOCO E MOSTRA AMBIENTE _______________________________________

      qlbloc(5,0,"B205A","QBLOC.GLO")
      qsay(06,07,cAMBIENTE)
      cEVENTO := space(3)

      // SOLICITA CODIGO DO BENEFICIO (EVENTO) ______________________________

      view_event(06,22,@cEVENTO)

      if val(cEVENTO) == 0 ; exit ; endif
      qsay(06,22,cEVENTO := strzero(val(cEVENTO),3))

      // PROCURA EVENTO _____________________________________________________

      if ! EVENT->(dbseek(cEVENTO))
         qmensa("Evento n„o cadastrado !","B") ; loop
      endif

      qsay(06,38,EVENT->Descricao)

      // ACIONA VIEW DE FUNCIONARIOS ________________________________________

      FUN->(dbgotop())
      FUN->(qview({{"Matricula/Matricula"                 ,1},;
                   {"left(Nome,30)/Nome do Funcionario"   ,2},;
                   {"i_sit205()/Sit"                      ,0},;
                   {"i_val205()/Valor"                    ,0},;
                   {"i_fra205()/Fra‡„o"                   ,0},;
                   {"iif(LANC->Fixa,' sim ','     ')/Fixo",0}},;
                   "07002379",;
                   {NIL,"f205a",NIL,NIL},NIL,;
                   "<Esc> / ALT_O / ALT_P / <I>nclui <A>ltera <E>xclui <F>ixa <L>ibera"))
   enddo

return

/////////////////////////////////////////////////////////////////////////////
// RETORNA VALOR ____________________________________________________________

function i_val205
   if LANC->(eof())
      return "            "
   endif
return " " + transform(LANC->Valor,"@E 999,999.99") + " "

/////////////////////////////////////////////////////////////////////////////
// RETORNA FRACAO ___________________________________________________________

function i_fra205
   if LANC->(eof())
      return "          "
   endif
return " " + transform(LANC->Fracao,"@E 999.9999") + " "

/////////////////////////////////////////////////////////////////////////////
// RETORNA A SITUACAO _______________________________________________________

function i_sit205
return " " + FUN->Situacao + " "

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

function f205a

   local nLINHA          // linha para alteracao
   local nVALOR          // para editar valor
   local nFRACAO         // para editar fracao

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   do case

      case cOPCAO == "I"            // INCLUSAO _____________________________

           if LANC->(eof())
              if qconf("Confirma inclus„o ?")
                 if FUN->Data_Adm > qfimmes(XDATASYS)
                    qmensa("Funcionario admitido em mes posterior ! Inclus„o cancelada !","B")
                 else
                    if LANC->(qappend())
                       replace LANC->Anomes    with cANOMES
                       replace LANC->Matricula with FUN->Matricula
                       replace LANC->Ambiente  with cAMBIENTE
                       replace LANC->Evento    with cEVENTO
                       LANC->(qunlock())
                    endif
                 endif
              endif
           endif

      case cOPCAO == "A"            // alterar ______________

           if ! LANC->(eof())
              nVALOR  := LANC->Valor
              nFRACAO := LANC->Fracao
              nLINHA  := row()
              if FUN->(indexord()) == 1
                 qgetx(nLINHA,49,@nVALOR,"@E 999,999.99")
                 qgetx(nLINHA,62,@nFRACAO,"@E 999.9999")
              else
                 qgetx(nLINHA,39,@nVALOR,"@E 999,999.99")
                 qgetx(nLINHA,52,@nFRACAO,"@E 999.9999")
              endif
              if qconf("Confirma altera‡„o ?")
                 if FUN->Data_Adm > qfimmes(XDATASYS)
                    qmensa("Funcionario admitido em mes posterior ! Altera‡„o cancelada !","B")
                 else
                    if LANC->(qrlock())
                       replace LANC->Valor  with nVALOR
                       replace LANC->Fracao with nFRACAO
                       LANC->(qunlock())
                    endif
                 endif
              endif
           endif

      case cOPCAO == "E"            // excluir ______________

           if ! LANC->(eof())
              if qconf("Confirma exclus„o ?")
                 if FUN->Data_Adm > qfimmes(XDATASYS)
                    qmensa("Funcionario admitido em mes posterior ! Exclus„o cancelada !","B")
                 else
                    if LANC->(qrlock())
                       LANC->(dbdelete())
                       LANC->(qunlock())
                    endif
                 endif
              endif
           endif

      case cOPCAO == "F"            // fixar _________________

           if ! LANC->(eof())
              if LANC->(qrlock())
                 replace LANC->Fixa with .T.
                 LANC->(qunlock())
              endif
           endif

      case cOPCAO == "L"            // liberar ______________

           if ! LANC->(eof())
              if LANC->(qrlock())
                 replace LANC->Fixa with .F.
                 LANC->(qunlock())
              endif
           endif

   endcase

   FUN->(dbgoto(recno()))

return ""

