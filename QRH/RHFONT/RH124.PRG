
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE EVENTOS PERMANENTES
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

private cMATRICULA, cAMBIENTE, sBLOCO, cOPCAO, cANOMES
private cMESANO := "  /  ", cTIPO

// ESTABELECE RELACIONAMENTO ENTRE ARQUIVOS E FILTRA FUN ____________________

FUN->(dbSetFilter({|| Situacao != 'H'},"Situacao != 'H'"))

LANC->(dbsetrelation("EVENT",{|| LANC->Evento},"LANC->Evento"))

// VIEW NO ARQUIVO FUN ______________________________________________________

FUN->(qview({{"Matricula" ,1},;
             {"left(Nome,30)/Nome",2}},"P",;
             {"i_inic_124()",NIL,NIL,NIL},NIL,;
             "ALT-P / ALT-O / <ENTER> Edita / <ESC>"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_inic_124
   local nCURSOR := setcursor(1)
   i_inicializacao()
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE INICIALIZACAO DOS LANCAMENTOS __________________________________

static function i_inicializacao

  // LOOP PRINCIPAL ___________________________________________________________

  setcolor("W/B")

  do while .T.

     setcursor(1)
     qlbloc(5,0,"B124A","QBLOC.GLO")
     qsay(06,13,FUN->Matricula)
     qsay(06,27,left(FUN->Nome,30))

     if lastkey() = 27
        return
     endif

     // GERA A MARCA DE FIXACAO DO EVENTO _____________________________________

     cANOMES := "FIXO  "

     // VERIFICA E ELIMINA DUPLICIDADES _______________________________________

     cTMP1 := ""
     do while ! LANC->(eof()) .and. LANC->Matricula == FUN->Matricula ;
        .and. LANC->Ambiente  == "MS" .and. LANC->Anomes == cANOMES
        if LANC->Evento $ cTMP1
           LANC->(qrlock())
           LANC->(dbdelete())
           LANC->(qunlock())
        else
           cTMP1 += ( LANC->Evento + "/" )
        endif
        LANC->(dbskip())
     enddo

     setcursor(0)

     LANC->(qview({{"EVENT->Evento/Evento"                    ,1},;
                   {"EVENT->Finalidade/F"                     ,0},;
                   {"tipo_conv(EVENT->Tipo)/Tipo"             ,0},;
                   {"left(EVENT->Descricao,35)/Descri‡„o"     ,0},;
                   {"transform(Valor,'@E 999,999.99')/Valor"  ,0},;
                   {"transform(Fracao,'@E 999.9999')/Fra‡„o"  ,0}},;
                   "07002379",;
                   {NIL,"f124a",NIL,NIL},;
                   {"LANC->Anomes+LANC->Matricula+LANC->Ambiente==cANOMES+FUN->Matricula+'MS'",{||f124ini()},{||f124fim()}},;
                   "<Esc>-Inc-Alt-Con-Exc"))
  enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONVERTER TIPO DE EVENTO PARA O VIEW ACIMA ___________________

function tipo_conv( cTIPO )
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

function f124ini
   LANC->(dbseek(cANOMES+FUN->Matricula+"MS"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f124fim
   LANC->(qseekn(cANOMES+FUN->Matricula+"MS"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f124a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "IACEFL"
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
           qlbloc(11,10,"B124B","QBLOC.GLO",1)

           cEVENTO := "   "

           view_event(12,26,@cEVENTO)

           if empty(cEVENTO) ; return ; endif

           zTMP := LANC->(recno())
           if LANC->(dbseek(cANOMES+FUN->Matricula+"MS"+cEVENTO))
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
                 LANC->Matricula := FUN->Matricula
                 LANC->Ambiente  := "MS"
                 LANC->Evento    := cEVENTO
                 LANC->Valor     := nVALOR
                 LANC->Fracao    := nFRACAO
                 LANC->(qunlock())
              else
                 qm1()
              endif
           endif

      // ALTERAR DADOS DO EVENTO _______________________________________

      case cOPCAO == "A"
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
   qlbloc(11,10,"B124B","QBLOC.GLO",1)
   qsay(12,26,EVENT->Evento)
   qsay(13,26,EVENT->Descricao)
   qsay(14,26,qabrev(EVENT->Tipo,"123456",{"Formula Associada","Valor Constante","Valor Informado","Fra‡„o Informada","% sobre Combina‡„o","Beneficio"}))
   qsay(15,26,qabrev(EVENT->Finalidade,"PD+-",{"Provento","Desconto","+ de Base","- de Base"}))
   if nCTRL == 1
      qsay(16,26,LANC->Valor ,"N10")
      qsay(17,26,LANC->Fracao,"@E 999.9999")
   endif
return NIL
