/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DA FICHA FINANCEIRA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

local sBLOC , cOPCAO

private cMATRICULA , cAMBIENTE , cAQUIS := "*417" , cANOMES
private cMESANO := "  /    "

// ESTABELECE RELACIONAMENTO ENTRE ARQUIVOS _________________________________

select LANC
set relation to Evento into EVENT

sBLOC     := qsbloc(5,0,10,24)
cOPCAO    := qachoice(5,0,qlbloc("B417C","QBLOC.GLO"),"1",1)
cAMBIENTE := qabrev(cOPCAO,"123 ",{"MS","FR","DT","  "})
qrbloc(5,0,sBLOC)

if empty(cAMBIENTE) ; return ; endif

i_inic_417()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE INICIALIZACAO DOS LANCAMENTOS E ESCOLHA DO FUNCIONARIO _________

static function i_inic_417

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

do while .T.

   setcursor(1)
   qlbloc(5,0,"B417A","QBLOC.GLO")
   cMATRICULA := space(6)

   // SOLICITA MATRICULA DO FUNCIONARIO _____________________________________

   qsay(06,03,cAMBIENTE)
   qgetx(06,16,@cMESANO,"99/9999")

   if empty(cMESANO)
      qmensa("Campo MES/ANO ‚ obrigat¢rio !","B") ; loop
   endif

   if lastkey() = 27
      return
   endif

   cANOMES := right(cMESANO,4) + left(cMESANO,2) // +left(cMESANO,4)

   view_fun(06,35,@cMATRICULA)
   cMATRICULA := strzero(val(cMATRICULA),6)
   if val(cMATRICULA) == 0 ; exit ; endif

   if ! FUN->(dbseek(cMATRICULA))
      qmensa("Funcionario n„o cadastrado !","B") ; loop
   endif

   qsay(06,35,FUN->Matricula)
   qsay(06,48,left(FUN->Nome,30))

   LANC->(dbseek(cANOMES+cMATRICULA+cAMBIENTE))

   // VERIFICA E ELIMINA DUPLICIDADES _______________________________________

   cTMP1 := ""
   do while ! LANC->(eof()) .and. LANC->Matricula == cMATRICULA ;
      .and. LANC->Ambiente  == cAMBIENTE .and. LANC->Anomes == cANOMES
      if LANC->Evento $ cTMP1
         LANC->(qrlock())
         LANC->(dbdelete())
         LANC->(qunlock())
      else
         cTMP1 += ( LANC->Evento + "/" )
      endif
      LANC->(dbskip())
   enddo

   LANC->(dbseek(cANOMES+cMATRICULA+cAMBIENTE))

   setcursor(0)

   cTMP1 := "transform(LANC->Valor,'@E 999,999.99')"
   cTMP2 := "transform(LANC->Fracao,'@E 999.9999')"

   LANC->(qview({{"EVENT->Evento/Evento"                                  ,1},;
                 {"EVENT->Finalidade/F"                                   ,0},;
                 {"conv_tipo(EVENT->Tipo)/Tipo"                           ,0},;
                 {"left(EVENT->Descricao,37)/Descri‡„o"                   ,0},;
                 {"transform(Valor,'@E 999,999.99')/Valor"                ,0},;
                 {"transform(Fracao,'@E 999.9999')/Fra‡„o"                ,0}},;
                 "07002379",;
                 {NIL,"f417a",NIL,NIL},;
                 {"LANC->Anomes+LANC->Matricula+LANC->Ambiente==cANOMES+cMATRICULA+cAMBIENTE",{||f417top()},{||f417bot()}},;
                 "<Esc>-Inc-Alt-Con-Exc"))
enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONVERTER TIPO DE EVENTO PARA O VIEW ACIMA ___________________

function conv_tipo( cTIPO )
   do case
      case cTIPO == "1" ; return "FO"
      case cTIPO == "2" ; return "VC"
      case cTIPO == "3" ; return "VI"
      case cTIPO == "4" ; return "FI"
      case cTIPO == "5" ; return "%C"
      case cTIPO == "6" ; return "BE"
   endcase
return "  "

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f417top
   LANC->(dbseek(cANOMES+cMATRICULA+cAMBIENTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f417bot
   LANC->(qseekn(cANOMES+cMATRICULA+cAMBIENTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f417a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "IACE"
      i_processa_acao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local zTMP            // variavel temporaria
   local nVALOR          // para editar valor
   local nFRACAO         // para editar fracao
   local cEVENTO         // para editar o evento

   do case

      // INCLUSAO DE EVENTOS ___________________________________________

      case cOPCAO == "I"
           qlbloc(11,10,"B417B","QBLOC.GLO",1)

           cEVENTO := "   "
           view_event(12,26,@cEVENTO)
           if empty(cEVENTO) ; return ; endif

           zTMP := LANC->(recno())
           if LANC->(dbseek(cANOMES+cMATRICULA+cAMBIENTE+cEVENTO))
              qmensa("Evento j  lan‡ado !!!","B") ; return
           endif
           LANC->(dbgoto(zTMP))

           if ! EVENT->(dbseek(cEVENTO))
              qmensa("Evento n„o cadastrado !!!","B") ; return
           endif

           i_bloco_evento(0)
           nVALOR := nFRACAO := 0

           qgetx(16,26,@nVALOR ,"@E 999,999.99",NIL,.T.)
           qgetx(17,26,@nFRACAO,"@E 999.9999",NIL,.T.)

           if qconf("Confirma inclus„o deste evento ?")
              if LANC->(qappend())
                 LANC->Anomes    := cANOMES
                 LANC->Matricula := cMATRICULA
                 LANC->Ambiente  := cAMBIENTE
                 LANC->Evento    := cEVENTO
                 LANC->Valor     := nVALOR
                 LANC->Fracao    := nFRACAO
                 LANC->Aquisicao := "*417"
                 LANC->(qunlock())
              else
                 qm1()
              endif
           endif

      // ALTERAR DADOS DO EVENTO _______________________________________

      case cOPCAO == "A"
           if LANC->Aquisicao != cAQUIS
              qmensa("Evento n„o incluido por essa rotina ! Altera‡„o negada !","B") ; return
           endif

           nVALOR  := LANC->Valor
           nFRACAO := LANC->Fracao
           i_bloco_evento(1)

           qgetx(16,26,@nVALOR,"@E 999,999.99",NIL,.T.)

           qgetx(17,26,@nFRACAO,"@E 999.9999",NIL,.T.)

           if qconf("Confirma altera‡„o deste evento ?")
              if LANC->(qrlock())
                 LANC->Valor  := nVALOR
                 LANC->Fracao := nFRACAO
                 LANC->(qunlock())
              else
                 qm2()
              endif
           endif

      // CONSULTA AO EVENTO ____________________________________________

      case cOPCAO == "C"
           i_bloco_evento(1)
           qwait()

      // EXCLUIR EVENTO ________________________________________________

      case cOPCAO == "E"
           if LANC->Aquisicao != cAQUIS
              qmensa("Evento n„o incluido por essa rotina ! Exclus„o negada !","B") ; return
           endif

           i_bloco_evento(1)

           if qconf("Confirma exclus„o deste evento ?")
              if LANC->(qrlock())
                 LANC->(dbdelete())
                 LANC->(qunlock())
              else
                 qm3()
              endif
           endif
   endcase

return

/////////////////////////////////////////////////////////////////////////////
// MONTA BLOCO BASICO _______________________________________________________

static function i_bloco_evento ( nCTRL )
   qlbloc(11,10,"B417B","QBLOC.GLO",1)
   qsay(12,26,EVENT->Evento)
   qsay(13,26,EVENT->Descricao)
   qsay(14,26,qabrev(EVENT->Tipo,"123456",{"Formula Associada","Valor Constante","Valor Informado","Fra‡„o Informada","% sobre Combina‡„o","Beneficio"}))
   qsay(15,26,qabrev(EVENT->Finalidade,"PD+-",{"Provento","Desconto","+ de Base","- de Base"}))
   if nCTRL == 1
      qsay(16,26,LANC->Valor ,"N10")
      qsay(17,26,LANC->Fracao,"@E 999.9999")
   endif
return NIL
