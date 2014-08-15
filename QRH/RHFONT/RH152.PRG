/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE FORMULAS DE CALCULO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

#include "inkey.ch"

private cPILHA         // BUFFER TEMPORARIO PARA SALVAR FORMULA...

setcolor("W/B")

// SENHA ADICIONAL PARA MANUTENCAO DAS FORMULAS _____________________________

qmensa("Acesso n„o autorizado para esta op‡„o !!!")
qbeep()
if qinkey(0) <> K_ALT_O ; return ; endif
if qinkey(0) <> K_ALT_K ; return ; endif

// SETA RELACAO ENTRE FORMULAS E EVENTOS ____________________________________

select EVENT
set order to 3

select FORM
set relation to Codigo into Event

go top

// BROWSE ___________________________________________________________________

FORM->(qview({{"Codigo/C¢d."                                                 ,1},;
              {"Descricao/Descri‡„o"                                         ,2},;
              {"str(len(alltrim(Formula)),4)/Tam."                           ,0},;
              {"if('jform('$Formula,'*',' ')/F"                              ,0},;
              {"if('#INF'$Formula,'*',' ')/I"                                ,0},;
              {"EVENT->Evento+'-'+left(EVENT->Descricao,16)/Evento Associado",0}},;
              "05001679",;
              {NIL,"f152a","f152b",NIL},;
              NIL,q_msg_acesso_usr()+"/<SRLV>"))

setcolor("W/N")
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f152a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA+"SRLV" // Salva,Restaura,Localiza,Vincula Evento...
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO QUE SERA CHAMADA QUANDO PRESSIONAR ENTER __________________________

function i_edicao

   FORM->(qpublicfields())
   do case

      // INCLUSAO ___________________________________________________________

      case cOPCAO == "I"
           FORM->(qinitfields()) ; i_get_cod()
           do while .T.
              fFORMULA := i_memoedit(fFORMULA)
              if lastkey() == 27 ; exit ; endif
              if i_check() ; exit ; endif
           enddo
           if lastkey() != 27
              if qconf("Confirma inclus„o desta f¢rmula ?")
                 if FORM->(qappend())
                    fUSR_IDT  := XUSRIDT
                    fULT_DATA := date()
                    fULT_HORA := left(time(),5)
                    FORM->(qreplacefields())
                    FORM->(qunlock())
                 else
                    qm1()
                 endif
              endif
           endif

      // ALTERACAO __________________________________________________________

      case cOPCAO == "A"
           FORM->(qcopyfields()) ; i_get_cod()
           do while .T.
              fFORMULA := i_memoedit(fFORMULA)
              if lastkey() == 27 ; exit ; endif
              if i_check() ; exit ; endif
           enddo
           if lastkey() != 27
              if qconf("Confirma altera‡„o desta f¢rmula ?")
                 if FORM->(qrlock())
                    fUSR_IDT  := XUSRIDT
                    fULT_DATA := date()
                    fULT_HORA := left(time(),5)
                    FORM->(qreplacefields())
                    FORM->(qunlock())
                 else
                    qm2()
                 endif
              endif
           endif

      // EXCLUSAO ___________________________________________________________

      case cOPCAO == "E"
           if qconf("Confirma exclus„o desta f¢rmula ?")
              if FORM->(qrlock())
                 replace FORM->Usr_idt  with XUSRIDT
                 replace FORM->Ult_data with date()
                 replace FORM->Ult_Hora with left(time(),5)
                 FORM->(dbdelete())
                 FORM->(qunlock())
              else
                 qm3()
              endif
           endif

      // SALVA FORMULA ______________________________________________________

      case cOPCAO == "S" ; i_salva_form()

      // RESTAURA FORMULA ___________________________________________________

      case cOPCAO == "R" ; i_restaura_form()

      // LOCALIZAR STRINGS NA FORMULA _______________________________________

      case cOPCAO == "L" ; i_localiza()

      // VINCULAR EVENTO ASSOCIADO __________________________________________

      case cOPCAO == "V" ; i_vinc_event()

   endcase
   FORM->(qreleasefields())
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO QUE SERA CHAMADA A CADA MOVIMENTACAO DO BROWSE ____________________

function f152b
   keyboard chr(27)
   memoedit(FORM->Formula,17,01,22,78,.F.,NIL,.T.)
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ENTRAR COM CODIGO E DESCRICAO DA FORMULA _____________________

static function i_get_cod
   local nRECNO := FORM->(recno())
   qlbloc(5,0,"B152B","QBLOC.GLO")
   qsay ( 6 , 08 , fCODIGO    )
   qsay ( 6 , 24 , fDESCRICAO )
   qsay ( 6 , 73 , fPARAMETER )
   do while .T.
      qgetx(6,08,@fCODIGO,"@!",NIL,.T.)
      FORM->(dbseek(fCODIGO))
      if ! FORM->(eof()) .and. FORM->(recno()) != nRECNO
         qmensa("C¢digo j  utilizado !","B")
         loop
      endif
      exit
   enddo
   qgetx(6,24,@fDESCRICAO,"@!",NIL,.T.)
   qgetx(6,73,@fPARAMETER,"@!",NIL,.T.)
   FORM->(dbgoto(nRECNO))
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CHECAR PARCIALMENTE SINTAXE DA FORMULA _______________________

static function i_check
   local nQUANT1, nQUANT2, nTMP := 6

   // VERIFICA QUANTIDADE DE CHAVES _________________________________________
   qmensa("Checando f¢rmula..."+strzero(nTMP--,1))
   nQUANT1 := qtotchr("{",fFORMULA)
   nQUANT2 := qtotchr("}",fFORMULA)
   if nQUANT1 != nQUANT2
      qmensa('Erro de sintaxe ! Faltam "chaves"...',"B")
      return .F.
   endif

   // VERIFICA QUANTIDADE DE PARENTESES _____________________________________
   qmensa("Checando f¢rmula..."+strzero(nTMP--,1))
   nQUANT1 := qtotchr("(",fFORMULA)
   nQUANT2 := qtotchr(")",fFORMULA)
   if nQUANT1 != nQUANT2
      qmensa('Erro de sintaxe ! Faltam "parenteses"...',"B")
      return .F.
   endif

   // VERIFICA QUANTIDADE DE COLCHETES ______________________________________
   qmensa("Checando f¢rmula..."+strzero(nTMP--,1))
   nQUANT1 := qtotchr("[",fFORMULA)
   nQUANT2 := qtotchr("]",fFORMULA)
   if nQUANT1 != nQUANT2
      qmensa('Erro de sintaxe ! Faltam "colchetes"...',"B")
      return .F.
   endif

   // VERIFICA QUANTIDADE DE ASPAS DUPLAS ___________________________________
   qmensa("Checando f¢rmula..."+strzero(nTMP--,1))
   nQUANT1 := qtotchr('"',fFORMULA)
   if nQUANT1/2 != int(nQUANT1/2)
      qmensa('Erro de sintaxe ! Faltam "aspas duplas"...',"B")
      return .F.
   endif

   // VERIFICA QUANTIDADE DE ASPAS SIMPLES __________________________________
   qmensa("Checando f¢rmula..."+strzero(nTMP--,1))
   nQUANT1 := qtotchr("'",fFORMULA)
   if nQUANT1/2 != int(nQUANT1/2)
      qmensa('Erro de sintaxe ! Faltam "aspas simples"...',"B")
      return .F.
   endif

   // VERIFICA QUANTIDADE DE ESCOPAS ________________________________________
   qmensa("Checando f¢rmula..."+strzero(nTMP--,1))
   nQUANT1 := qtotchr("#",fFORMULA)
   if nQUANT1/2 != int(nQUANT1/2)
      qmensa('Erro de sintaxe ! Faltam "escopas"...',"B")
      return .F.
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ENTRAR NO MEMOEDIT ___________________________________________

static function i_memoedit ( cFORMULA )
   qmensa("CTRL+W / ALT+F / ALT+E / ALT+V / ALT+T / <ESC>")
   set key K_ALT_F to i_help_funcoes()
   set key K_ALT_E to i_help_estrutura()
   set key K_ALT_V to i_help_variaveis()
   set key K_ALT_T to i_aciona_qtabela()
   readinsert(.T.)
   cFORMULA := memoedit(cFORMULA,08,01,22,78,.T.,NIL,.T.)
   set key K_ALT_F to
   set key K_ALT_E to
   set key K_ALT_V to
   set key K_ALT_T to
   qmensa()
return cFORMULA

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR AS VARIAVEIS PUBLICAS DISPONIVEIS ____________________

static function i_help_variaveis
   sTELA := qsbloc(5,0,23,79)
   qlbloc(5,0,"B152D","QBLOC.GLO")
   qwait()
   qrbloc(5,0,sTELA)

   /*
   aadd(V_VARIAVEIS,"P_DATASIST  - data do sistema                      ")
   aadd(V_VARIAVEIS,"P_IAP_EMP   - base para calculo do desconto de inss")
   aadd(V_VARIAVEIS,"P_BASE_FGTS - base para calculo do deposito do fgts")
   aadd(V_VARIAVEIS,"P_BASE_IR   - base para calculo do desconto de irrf")
   aadd(V_VARIAVEIS,"P_BASE_SIND - base para calculo da contr. sindical ")
   aadd(V_VARIAVEIS,"P_BASE_RAIS - base para calculo da rais            ")
   aadd(V_VARIAVEIS,"P_BASE_SALF - base de calculo do salario familia   ")
   aadd(V_VARIAVEIS,"P_PROVENTO  - proventos totalizados                ")
   aadd(V_VARIAVEIS,"P_DESCONTO  - descontos totalizados                ")
   aadd(V_VARIAVEIS,"P_DIASMES   - numero de dias no mes de calculo.    ")
   aadd(V_VARIAVEIS,"P_U_SEMANA  - flag ind. da ultima semana do mes    ")
   aadd(V_VARIAVEIS,"P_N_SEMANA  - numero da semana atual               ")
   aadd(V_VARIAVEIS,"P_DATA_SEM  - data limite do periodo semanal       ")
   aadd(V_VARIAVEIS,"P_GER_SEGU  - valor do indice para seguro          ")
   aadd(V_VARIAVEIS,"P_GER_CEST  - valor da cesta basica                ")
   aadd(V_VARIAVEIS,"P_GER_SMIN  - valor do salario minimo              ")
   aadd(V_VARIAVEIS,"P_GER_NATA  - valor do auxilio natalidade          ")
   aadd(V_VARIAVEIS,"P_GER_FGTS  - percentual de desconto de fgts       ")
   aadd(V_VARIAVEIS,"P_GER_IAEM  - inss / desconto da empresa           ")
   aadd(V_VARIAVEIS,"P_GER_IAAC  - inss / desconto por acidente trab.   ")
   aadd(V_VARIAVEIS,"P_GER_IATE  - inss / desconto para terceiros       ")
   aadd(V_VARIAVEIS,"P_GER_PROL  - inss / desconto pro-labore           ")
   */

return

/////////////////////////////////////////////////////////////////////////////
// HELP DE FUNCOES PARA AS FORMULAS _________________________________________

static function i_help_funcoes
   sTELA := qsbloc(5,0,23,79)
   qlbloc(5,0,"B152C","QBLOC.GLO")
   qwait()
   qrbloc(5,0,sTELA)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR ESTRUTURA DO ARQUIVOS ________________________________

static function i_help_estrutura
   local sTELA := qsbloc(6,0,21,79)
   local nROW  := row()
   local nCOL  := col()
   local nCONT, nESCOLHA

   if ! quse("","QINDEX") ; return .F. ; endif
   if ! quse("","QSTRUCT") ; return .F. ; endif

   QINDEX->(qview({{"Arquivo",0},{"Descricao/Descri‡„o",2}},;
                   "06021655",;
                   {"i_help_stru2",NIL,NIL,NIL},;
                   NIL,"<ESC> / <ENTER> visualiza campos"))

   QINDEX->(dbclosearea())
   QSTRUCT->(dbclosearea())
   qrbloc(6,0,sTELA)
   setpos(nROW,nCOL)
   select FORM
return

function i_help_stru2
   private nTOP := nBOT := 1
   qmensa("Aguarde, verificando estrutura deste arquivo...")
   select QSTRUCT
   locate for QINDEX->Arquivo == QSTRUCT->Arquivo
   nTOP := QSTRUCT->(recno())
   do while QSTRUCT->Arquivo == QINDEX->Arquivo
      nBOT := QSTRUCT->(recno())
      QSTRUCT->(dbskip())
   enddo
   QSTRUCT->(dbgoto(nTOP))
   if QSTRUCT->(eof())
      qmensa("Estrutura deste arquivo n„o esta disponivel...","B")
   else
      nREC := QSTRUCT->(recno())
      QSTRUCT->(qview({{"Campo"              ,0},;
                       {"Tipo"               ,0},;
                       {"Tamanho/Tam."       ,0},;
                       {"Decimal/Dec."       ,0},;
                       {"Descricao/Descri‡„o",0}},;
                       "08042176",;
                       {"EXIT",NIL,NIL,NIL},;
                       {"QSTRUCT->Arquivo==QINDEX->Arquivo",{||dbgoto(nTOP)},{||dbgoto(nBOT)}},;
                       "Arquivo: "+QINDEX->Arquivo+"  / <ESC> para sair..."))
   endif
   select QINDEX
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EDITAR UMA TABELA ____________________________________________

function i_aciona_qtabela()
   // REVER NO FUTURO keyboard qtabela()
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER UM PUSH DA FORMULA ATUAL _______________________________

function i_salva_form
   if qconf("Salva esta formula no buffer ?")
      cPILHA := alltrim(FORM->Formula)
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER UM POP NA FORMULA ATUAL ________________________________

function i_restaura_form
   if qconf("Restaura a formula do buffer ? <atual sera perdida!>")
      if FORM->(qrlock())
         replace FORM->Formula with cPILHA
         FORM->(qunlock())
         FORM->(dbgoto(recno()))
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA LOCALIZAR STRINGS NAS FORMULAS _______________________________

function i_localiza
   static cSTRING := "                    "
   static cANTERIOR := "                    "
   qmensa()
   qsay(24,21,"Localizar: ")
   setcursor(1)
   qgetx(24,32,@cSTRING,"@!@K",NIL,.T.)
   setcursor(0)
   if cANTERIOR == cSTRING
      continue
   else
      locate for (upper(alltrim(cSTRING)) $ upper(FORM->Formula) .and. qgirabarra())
   endif
   if FORM->(eof()) ; FORM->(dbgotop()) ; qbeep() ; endif
   cANTERIOR := cSTRING
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VINCULAR EVENTO A FORMULA ____________________________________

function i_vinc_event
   EVENT->(qview({{"Evento/C¢digo"      ,1},;
                  {"Descricao/Descri‡„o",2},;
                  {"Formula/F¢rmula"    ,0}},"C",;
                  {"i_vinc_ok",NIL,NIL,NIL},;
                  NIL,"ESC, ALT-P, ALT-O, <ENTER> p/ vincula‡„o..."))
return

/////////////////////////////////////////////////////////////////////////////
// CONFIRMACAO E VINCULACAO DO EVENTO ESCOLHIDO _____________________________

function i_vinc_ok
   if qconf("Confirma f¢rmula "+FORM->Codigo+" p/ o evento "+EVENT->Evento)
      if EVENT->(qrlock())
         replace EVENT->Formula with FORM->Codigo
         EVENT->(qunlock())
      else
         qm2()
      endif
   endif
return

