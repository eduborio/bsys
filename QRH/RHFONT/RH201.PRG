/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: LANCAMENTOS INDIVIDUAIS PARA OS FUNCIONARIOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: IDEM
// INICIO.....: OUTUBRO DE 1996
// OBS........:
// ALTERACOES.:

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

private cMATRICULA                   // matricula do funcionario com strzero
private dDATA_CALCULO := XDATASYS    // data de calculo
private cANOMES       := qanomes(XDATASYS)

// MANUTENCAO E CALCULO SOMENTE PERMITIDO NO ULTIMO MES EM ABERTO ___________

//  if XDATASYS != CONFIG->Data_atual
//     qmensa("Manuten‡„o n„o ‚ permitida em meses anteriores !!","B")
//     return
//  endif

// ESTABELECE RELACIONAMENTO ENTRE ARQUIVOS _________________________________

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

SITUA->(dbsetrelation("BASE",{|| Matricula + cANOMES},"Matricula + cANOMES"))

LANC->(dbsetrelation("EVENT",{|| Evento},"Evento"))

qmensa("<Pressione ESC para Cancelar>")

cAMBIENTE := rh_escolhe_amb() // "MS","AD","DT","FR","PV"
if empty(cAMBIENTE) ; return ; endif
if Lastkey() == 27; Return; Endif
i_inic_201()

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE INICIALIZACAO DOS LANCAMENTOS E ESCOLHA DO FUNCIONARIO _________

static function i_inic_201

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

do while .T.

   qmensa("<Pressione ESC para Cancelar>")

   if Lastkey() == 27
//      keyboard chr(32)
      cAMBIENTE := rh_escolhe_amb() // "MS","AD","DT","FR","PV"
      if empty(cAMBIENTE) ; return ; endif
//      if Lastkey() == 27; Return; Endif
      i_inic_201()
   Endif

   setcursor(1)
   qlbloc(5,0,"B201A","QBLOC.GLO")
   cMATRICULA := space(6)
   keyboard chr(32)

   // SOLICITA MATRICULA DO FUNCIONARIO _____________________________________

   qsay(06,04,cAMBIENTE)
   if Empty(cAMBIENTE)
      Exit
   Endif

   view_fun(6,19,@cMATRICULA)
   cMATRICULA := strzero(val(cMATRICULA),6)
   if val(cMATRICULA) == 0 ; exit ; endif
   if Lastkey() == 27; exit; endif

   if ! FUN->(dbseek(cMATRICULA))
      qmensa("Funcionario n„o cadastrado !","B")
      loop
   endif

   if FUN->Data_adm > qfimmes(XDATASYS)
      qmensa("Funcionario admitido em mes posterior !","B")
      loop
   endif

   qsay(06,19,FUN->Matricula)
   qsay(06,33,left(FUN->Nome,30))

   SITUA->(dbseek(FUN->Matricula))

   if FUN->Situacao == "H"
      qmensa("Funcionario com Homologa‡„o confirmada ...","B")
      loop
   endif

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

   LANC->(qview({{"EVENT->Evento/Ev."                       ,1},;
                 {"EVENT->Finalidade/F"                     ,0},;
                 {"conv_tip(EVENT->Tipo)/Tp"                ,0},;
                 {"left(EVENT->Descricao,37)/Descri‡„o"     ,0},;
                 {"transform(Valor,'@E 999,999.99')/Valor"  ,0},;
                 {"transform(Fracao,'@E 999.9999')/Fra‡„o"  ,0},;
                 {"iif(LANC->Fixa,'Sim','N„o')/Fixado"      ,0}},;
                 "07002379",;
                 {NIL,"f201a","f201b",NIL},;
                 {"LANC->Anomes+LANC->Matricula+LANC->Ambiente==cANOMES+cMATRICULA+cAMBIENTE",{||f201top()},{||f201bot()}},;
                 "<I>nc-<A>lt-<C>on-<E>xc-<F>ix-<L>ib-<T>ra-Bl<O>-<B>as-<R>ec-<K>it-<X>"))

enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONVERTER TIPO DE EVENTO PARA O VIEW ACIMA ___________________

function conv_tip ( cTIPO )
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

function f201top
   LANC->(dbseek(cANOMES+cMATRICULA+cAMBIENTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f201bot
   LANC->(qseekn(cANOMES+cMATRICULA+cAMBIENTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f201a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA+"XFLTODBPRK?"
      i_processa_acao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// ATUALIZACAO DE TELA A CADA MOVIMENTACAO DO VIEW E/OU REFRESH _____________

function f201b
   qsay(06,65,if(cAMBIENTE $ SITUA->Bloq,"<BLOQ>","      "))
   qsay(06,72,if(cAMBIENTE $ SITUA->Trav,"<TRAV>","      "))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local zTMP            // variavel temporaria
   local nVALOR          // para editar valor
   local nFRACAO         // para editar fracao
   local cEVENTO         // para editar o evento
   local cAQUISICAO      // para editar a aquisicao
   local cMACROP         // macro para proventos
   local cMACROD         // macro para descontos

   cMACROP := "BASE->Prov_" + cAMBIENTE
   cMACROD := "BASE->Desc_" + cAMBIENTE

   do case

           // INCLUSAO DE EVENTOS ___________________________________________

      case cOPCAO == "I"

           if cAMBIENTE $ SITUA->Bloq
              qmensa("Funcionario bloqueado, inclus„o negada !","B") ; return
           endif

           qlbloc(11,10,"B201B","QBLOC.GLO",1)

           cEVENTO := "   "

           // FILTRA NAO MOSTRANDO EVENTOS BENEFICIO

           view_event(12,26,@cEVENTO)

           EVENT->(dbclearFilter())

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

           if "V" $ EVENT->Edicao ; qgetx(17,26,@nVALOR    ,"@E 999,999.99",NIL,.T.) ; endif
           if "F" $ EVENT->Edicao ; qgetx(18,26,@nFRACAO   ,"@E 999.9999",NIL,.T.) ; endif

           if qconf("Confirma inclus„o deste evento ?")
              if LANC->(qappend())
                 replace LANC->Anomes    with cANOMES
                 replace LANC->Matricula with cMATRICULA
                 replace LANC->Ambiente  with cAMBIENTE
                 replace LANC->Evento    with cEVENTO
                 replace LANC->Valor     with nVALOR
                 replace LANC->Fracao    with nFRACAO
                 LANC->(qunlock())
              else
                 qm1()
              endif
           endif

           // ALTERAR DADOS DO EVENTO _______________________________________

      case cOPCAO == "A"

           if LANC->Fixa
              qmensa("Evento fixado. Altera‡„o negada !","B") ; return
           endif

           nVALOR     := LANC->Valor
           nFRACAO    := LANC->Fracao
           i_bloco_evento(1)

           if "V" $ EVENT->Edicao
              qgetx(17,26,@nVALOR,"@E 999,999.99",NIL,.T.)
           endif

           if "F" $ EVENT->Edicao
              qgetx(18,26,@nFRACAO,"@E 999.9999",NIL,.T.)
           endif

           if qconf("Confirma altera‡„o deste evento ?")
              if LANC->(qrlock())
                 replace LANC->Valor     with nVALOR
                 replace LANC->Fracao    with nFRACAO
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

           if cAMBIENTE $ SITUA->Bloq
              qmensa("Funcionario Bloqueado, exclus„o negada !","B") ; return
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

           // FIXAR EVENTO __________________________________________________

      case cOPCAO == "F"

           if ! "X" $ EVENT->Edicao .or. left(EVENT->Evento,1) == "9"
              qmensa("Evento nao pode ser fixado !","B") ; return
           endif

           if LANC->Fixa
              qmensa("Evento j  esta fixado !","B") ; return
           endif

           i_bloco_evento(0)

           nVALOR  := LANC->Valor
           nFRACAO := LANC->Fracao
           qgetx(17,26,@nVALOR,"@E 999,999.99",NIL,.T.)
           qgetx(18,26,@nFRACAO,"@E 999.9999",NIL,.T.)
           if qconf("Confirma fixar este evento ?")
              if LANC->(qrlock())
                 replace LANC->Fixa   with .T.
                 replace LANC->Valor  with nVALOR
                 replace LANC->Fracao with nFRACAO
                 LANC->(qunlock())
              else
                 qmensa("N„o foi possivel fixar ! Tente novamente...","B")
              endif
           endif

           // LIBERAR EVENTO FIXADO _________________________________________

      case cOPCAO == "L"

           if ! LANC->Fixa
              qmensa("Evento n„o esta fixado !","B") ; return
           endif
           if ! "L" $ EVENT->Edicao
              qmensa("Evento nao pode ser liberado...","B") ; return
           endif

           i_bloco_evento(1)

           if qconf("Confirma liberar este evento ?")
              if LANC->(qrlock())
                 replace LANC->Fixa   with .F.
                 replace LANC->Valor  with 0
                 replace LANC->Fracao with 0
                 LANC->(qunlock())
              else
                 qmensa("N„o foi possivel liberar ! Tente novamente...","B")
              endif
           endif

           // TRAVAR FUNCIONARIO ____________________________________________

      case cOPCAO == "T"

           if SITUA->(qrlock())
              if cAMBIENTE $ SITUA->Trav
                 replace SITUA->Trav with strtran(SITUA->Trav,cAMBIENTE+"/","")
              else
                 replace SITUA->Trav with alltrim(SITUA->Trav) + cAMBIENTE + "/"
              endif
              SITUA->(qunlock())
           else
              qmensa("N„o foi possivel travar ! Tente novamente ...","B")
           endif

           // BLOQUEAR FUNCIONARIO __________________________________________

      case cOPCAO == "O"

           if SITUA->(qrlock())
              if cAMBIENTE $ SITUA->Bloq
                 replace SITUA->Bloq with strtran(SITUA->Bloq,cAMBIENTE+"/","")
              else
                 replace SITUA->Bloq with alltrim(SITUA->Bloq) + cAMBIENTE + "/"
              endif
              SITUA->(qunlock())
           else
              qmensa("N„o foi possivel bloquear ! Tente novamente ...","B")
           endif

           // CONSULTA DE BASES _____________________________________________

      case cOPCAO == "B"

           zTMP := qsbloc(7,1,24,79)
           qlbloc(7,1,"B201C","QBLOC.GLO")
           qsay ( 09 , 12 , BASE->B_irrfms   , "N10" )
           qsay ( 10 , 12 , BASE->B_inssms   , "N10" )
           qsay ( 11 , 12 , BASE->B_fgtsms   , "N10" )
           qsay ( 13 , 12 , BASE->B_irrffr   , "N10" )
           qsay ( 14 , 12 , BASE->B_inssfr   , "N10" )
           qsay ( 15 , 12 , BASE->B_fgtsfr   , "N10" )

           do case
              case cAMBIENTE== "DT"
                   qsay ( 17 , 12 , BASE->B_irrf13   , "N10" )
                   qsay ( 18 , 12 , BASE->B_inss13   , "N10" )
                   qsay ( 19 , 12 , BASE->B_fgts13   , "N10" )
              case cAMBIENTE== "MS"
                   qsay ( 17 , 12 , BASE->B_irrfdt   , "N10" )
                   qsay ( 18 , 12 , BASE->B_inssdt   , "N10" )
                   qsay ( 19 , 12 , BASE->B_fgtsdt   , "N10" )
           endcase

           qsay ( 09 , 24 , BASE->V_irrfms   , "N10" )
           qsay ( 10 , 24 , BASE->V_inssms   , "N10" )
           qsay ( 11 , 24 , BASE->V_fgtsms   , "N10" )
           qsay ( 13 , 24 , BASE->V_irrffr   , "N10" )
           qsay ( 14 , 24 , BASE->V_inssfr   , "N10" )
           qsay ( 15 , 24 , BASE->V_fgtsfr   , "N10" )

           do case
              case cAMBIENTE== "DT"
                   qsay ( 17 , 24 , BASE->V_irrf13   , "N10" )
                   qsay ( 18 , 24 , BASE->V_inss13   , "N10" )
                   qsay ( 19 , 24 , BASE->V_fgts13   , "N10" )
              case cAMBIENTE== "MS"
                   qsay ( 17 , 24 , BASE->V_irrfdt   , "N10" )
                   qsay ( 18 , 24 , BASE->V_inssdt   , "N10" )
                   qsay ( 19 , 24 , BASE->V_fgtsdt   , "N10" )
           endcase

           qsay ( 09 , 35 , BASE->P_irrfms   , "N5" )
           qsay ( 10 , 35 , BASE->P_inssms   , "N5" )
           qsay ( 11 , 35 , BASE->P_fgtsms   , "N5" )
           qsay ( 13 , 35 , BASE->P_irrffr   , "N5" )
           qsay ( 14 , 35 , BASE->P_inssfr   , "N5" )
           qsay ( 15 , 35 , BASE->P_fgtsfr   , "N5" )

           do case
              case cAMBIENTE== "DT"
                   qsay ( 17 , 35 , BASE->P_irrf13   , "N5" )
                   qsay ( 18 , 35 , BASE->P_inss13   , "N5" )
                   qsay ( 19 , 35 , BASE->P_fgts13   , "N5" )
              case cAMBIENTE== "MS"
                   qsay ( 17 , 35 , BASE->P_irrfdt   , "N5" )
                   qsay ( 18 , 35 , BASE->P_inssdt   , "N5" )
                   qsay ( 19 , 35 , BASE->P_fgtsdt   , "N5" )
           endcase

           qsay ( 21 , 30 , BASE->B_salfam   , "N10" )
           qsay ( 22 , 30 , BASE->V_salfam   , "N10" )
           qsay ( 09 , 56 , SITUA->Dep_ir      , "99" )
           qsay ( 10 , 56 , SITUA->Dep_fam     , "99" )
           qsay ( 08 , 72 , SITUA->Dep_bolsa   , "99" )
           qsay ( 09 , 72 , SITUA->Dep_saude   , "99" )
           qsay ( 10 , 72 , SITUA->Dep_vida    , "99" )
           qsay ( 12 , 56 , SITUA->Salario     , "N10" )
           qsay ( 12 , 68 , iif(FUN->Aposentado=="S","Aposentado","") )
           qsay ( 13 , 56 , qabrev(SITUA->Categoria,"123456789",{"Mensal","Quinzenal","Semanal","Diario","Horario","Tarefa","Comissao","Honorario","Estagiario"}))
           qsay ( 14 , 56 , qabrev(SITUA->Vinculo,"ABCDEFGHIJKLMN",{"Urbano-CLT/PJ/Pz Ind.","Urbano-CLT/PF/Pz Ind.","Rural-CLT/PJ/Pz Ind.","Rural-CLT/PF/Pz Ind.","Servidor(RJU)-Militar","Servidor n„o efetivo",+;
           "Trabalhador Avulso","Trabalhador Tempor rio","Urbano-CLT/PJ/Pz. Det.","Urbano-CLT/PF/Pz. Det.","Rural-CLT/PJ/Pz. Det.","Rural-CLT/PF/Pz. Det.","Diretor c/V¡nc. FGTS","Diretor s/V¡nc. FGTS"}))
           qsay ( 15 , 56 , FUN->Hor_trab , "999" )
           qsay ( 15 , 74 , FUN->Hor_sema , "999" )
           qsay ( 16 , 56 , qabrev(FUN->Situacao," TFADH",{"      ","Trabalhando","de F‚rias","Afastado","Demitido","Homologado"}))
           qsay ( 16 , 69 , "("+SITUA->Af_cod+")" )
           qsay ( 17 , 56 , SITUA->Af_ini   )
           qsay ( 18 , 56 , SITUA->Af_ret   )
           qsay ( 18 , 67 , FUN->Data_adm )
           qsay ( 20 , 56 , &cMACROP.            , "N10" )
           qsay ( 21 , 56 , &cMACROD.            , "N10" )
           qsay ( 22 , 56 , &cMACROP - &cMACROD. , "N10" )
           qwait()
           qrbloc(0,0,zTMP)
           zTMP := NIL

           // CALCULO DESTE FUNCIONARIO _____________________________________

      case cOPCAO == "R"            // recalculo ______________

           if cAMBIENTE $ SITUA->Trav
              qmensa("Funcionario Travado ! Recalculo n„o permitido...","B")
           else
              i_calculo()
           endif

           // LANCAMENTO DE KITS ____________________________________________

      case cOPCAO == "K"

           i_lanca_kit()

           // CONSULTAS DIVERSAS AUXILIARES _________________________________

      case cOPCAO == "X"

           i_x_consultas_auxiliares()

   endcase

return

// FUNCAO PARA LANCAR UM KIT INTEIRO ________________________________________

static function i_lanca_kit
   local nCONT, cACAO := "I"
   local aEVENTOS := {}
   local sBLOC := qlbloc("B201H","QBLOC.GLO")

   // FAZ BROWSE DE CONSULTA IMEDIATA E RETORNA SE <ESC> PRESSIONADO ________

   qmensa("Escolha o kit para ser incluido ou excluido...")
   KIT->(qview({{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"EXIT",NIL,NIL,NIL}))
   if lastkey() <> 13 ; return ; endif

   qmensa("Kit "+KIT->Codigo+" / "+KIT->Descricao+" !")

   qesco(17,53,@cACAO,sBLOC,1)

   if empty(cACAO) ; return .F. ; endif

   if ! qconf("Confirma "+iif(cACAO=="I","inclus„o","exclus„o")+" deste Kit ?") ; return ; endif

   qmensa("Incluindo kit...")

   // AGORA CRIA O VETOR E FAZ AS INCLUSOES/EXCLUSOES NECESSARIAS ___________

   i_alimenta(aEVENTOS)
   for nCONT := 1 to len(aEVENTOS)
       qgirabarra()
       if cACAO == "I"
          if ! LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE+aEVENTOS[nCONT]))
             if EVENT->(dbseek(aEVENTOS[nCONT]))
                if LANC->(qappend())
                   replace LANC->Anomes    with cANOMES
                   replace LANC->Matricula with FUN->Matricula
                   replace LANC->Ambiente  with cAMBIENTE
                   replace LANC->Evento    with aEVENTOS[nCONT]
                   LANC->(qunlock())
                endif
             endif
          endif
       else
          if LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE+aEVENTOS[nCONT]))
             if LANC->(qrlock())
                LANC->(dbdelete())
                LANC->(qunlock())
             endif
          endif
       endif
   next

   LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CHAMAR A ROTINA DE CALCULO ___________________________________

static function i_calculo
   local nSELECT   := select()
   local nFU_RECNO := FUN->(recno())
   local nGR_RECNO := LANC->(recno())

   rh401(cAMBIENTE)

   select (nSELECT)
   LANC->(dbgoto(nGR_RECNO))
   FUN->(dbgoto(nFU_RECNO))
return NIL

/////////////////////////////////////////////////////////////////////////////
// MONTA BLOCO BASICO _______________________________________________________

static function i_bloco_evento ( nCTRL )
   qlbloc(11,10,"B201B","QBLOC.GLO",1)
   qsay ( 12 , 26 , EVENT->Evento     )
   qsay ( 13 , 26 , EVENT->Descricao  )
   qsay ( 14 , 26 , qabrev(EVENT->Tipo,"123456",{"Formula Associada","Valor Constante","Valor Informado","Fra‡„o Informada","% sobre Combina‡„o","Beneficio"}) )
   qsay ( 15 , 26 , qabrev(EVENT->Finalidade,"PD+-",{"Provento","Desconto","+ de Base","- de Base"}) )
   qsay ( 16 , 26 , EVENT->Edicao     )
   if nCTRL == 1
      qsay ( 17 , 26 , LANC->Valor  , "N10" )
      qsay ( 18 , 26 , LANC->Fracao , "@E 999.9999" )
   endif
return NIL

/////////////////////////////////////////////////////////////////////////////
// CONSULTAS AUXILIARES _____________________________________________________

static function i_x_consultas_auxiliares
   local cESCOLHA
   local sBLOC := qlbloc("B201G","QBLOC.GLO")

   qmensa("Consultas Auxiliares...")
   qesco(12,25,@cESCOLHA,sBLOC)

   do case
      case cESCOLHA == "A" ; i_x_formula()
      case cESCOLHA == "B" ; i_x_tabela()
      case cESCOLHA == "C" ; i_x_combinacao()
      case cESCOLHA == "D" ; i_x_ordem_de_calculo()
      case cESCOLHA == "E" ; i_x_kits_utilizados()
   endcase

return

/////////////////////////////////////////////////////////////////////////////
// MOSTRA FORMULA UTILIZADA PELO EVENTO _____________________________________

static function i_x_formula
   local cINF, nPOINTER
   clear_sl(08,02,22,77,48)
   qsay(9,4,"Evento....: "+EVENT->Evento+" / "+EVENT->Descricao)
   if ! FORM->(dbseek(EVENT->Formula))
      qsay(10,4,"F¢rmula...: N„o h  f¢rmula associada a este evento !!!")
   else
      if ( nPOINTER := at("#INF",FORM->Formula) ) <> 0
         cINF := left(FORM->Formula,nPOINTER)
      else
         cINF := FORM->Formula
      endif
      qsay(10,4,"F¢rmula...: "+FORM->Codigo+" / "+FORM->Descricao+" / "+FORM->Parameter)
      qmensa("<ESC> p/ retornar...")
      memoedit(cINF,12,02,21,77,.F.,NIL,.T.)
   endif
return

/////////////////////////////////////////////////////////////////////////////
// MOSTRA TABELA DE INCIDENCIAS UTILIZADA PELOS LANCAMENTOS _________________

static function i_x_tabela
   local nLA_RECNO := LANC->(recno())
   local nEV_RECNO := EVENT->(recno())
   local aEVENTOS  := {}
   local nCONT

   clear_sl(08,02,22,77,48)
   qsay(09,04,"Tabela de")
   qsay(10,04,"Incidˆncias:")

   LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE))
   do while ! LANC->(eof()) .and. FUN->Matricula == LANC->Matricula .and. cAMBIENTE == LANC->Ambiente
       aadd(aEVENTOS,EVENT->Evento+"-"+left(EVENT->Descricao,21)+"  "+;
            iif(EVENT->salfam=="S","SIM","---")+" "+;
            iif(EVENT->inssms=="S","SIM","---")+" "+;
            iif(EVENT->inssfr=="S","SIM","---")+" "+;
            iif(EVENT->irrfms=="S","SIM","---")+" "+;
            iif(EVENT->irrffr=="S","SIM","---")+" "+;
            iif(EVENT->fgtsms=="S","SIM","---")+" "+;
            iif(EVENT->fgtsfr=="S","SIM","---")+" "+;
            iif(EVENT->sindic=="S","SIM","---")+" "+;
            iif(EVENT->rais  =="S","SIM","---"))
       LANC->(dbskip())
   enddo

   LANC->(dbgoto(nLA_RECNO))
   EVENT->(dbgoto(nEV_RECNO))

   if empty(aEVENTOS)
      qsay(11,04,"*** N„o h  eventos lan‡ados...")
      qwait()
   else
      qmensa("Utilize as setas ou <ESC> p/ retornar...")
      qsay(11,30,"SaFam   InssF   IrrfF   FgtsF   Rais.   ")
      qsay(12,30,"    InssM   IrrfM   FgtsM   Sind    ")

      achoice(14,03,22,76,aEVENTOS)
   endif

return

/////////////////////////////////////////////////////////////////////////////
// MOSTRA COMBINACAO DO EVENTO ______________________________________________

static function i_x_combinacao
   local nLA_RECNO   := LANC->(recno())
   local nEV_RECNO   := EVENT->(recno())
   local cCOMBINA     := EVENT->Combina
   local nLENCOMBINA  := len(cCOMBINA)
   local aCOMBINACAO := {}
   local nCONT, cSINAL, cEVENTO, cTMP

   clear_sl(08,02,22,77,48)
   qsay(09,04,"Evento...: "+EVENT->Evento)
   qsay(10,04,"Descri‡„o: "+EVENT->Descricao)
   qsay(09,49,"Valor....: "+Transform(LANC->Valor,"@E 999,999.99"))
   qsay(10,49,"Fra‡„o...: "+Transform(LANC->Fracao,"@E 999.9999"))

   for nCONT := 1 to nLENCOMBINA step 4
       cSINAL  := substr(cCOMBINA,nCONT,1)
       if empty(cSINAL) ; exit ; endif
       cEVENTO := substr(cCOMBINA,nCONT+1,3)
       EVENT->(dbseek(cEVENTO))
       cTMP := EVENT->Evento + " - " + EVENT->Descricao
       LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE+cEVENTO))
       if cEVENTO == "@SC"
          aadd(aCOMBINACAO," *** SALARIO CONTRATUAL ***"+space(13)+cSINAL+" "+transform(SITUA->Salario,"@E 999,999.99")+" ")
       else
          aadd(aCOMBINACAO," "+cTMP+"   "+cSINAL+" "+transform(LANC->Valor,"@E 999,999.99")+" ")
       endif
   next

   LANC->(dbgoto(nLA_RECNO))
   EVENT->(dbgoto(nEV_RECNO))

   if empty(aCOMBINACAO)
      qsay(12,03,"*** Este evento n„o ‚ percentual sobre combina‡„o !")
      qwait()
   else
      qsay(22,35,"BASE FORMADA -->"+transform(jcombeve(),"@E 999,999.99"))
      qmensa("Utilize as setas ou <ESC> p/ retornar...")
      achoice(12,06,20,72,aCOMBINACAO)
   endif

return

/////////////////////////////////////////////////////////////////////////////
// VERIFICA ORDEM DE CALCULO DOS LANCAMENTOS ________________________________

static function i_x_ordem_de_calculo
   local nLA_RECNO := LANC->(recno())
   local nEV_RECNO := EVENT->(recno())
   local aEVENTOS  := {}

   LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE))
   do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == cAMBIENTE
      aadd(aEVENTOS,EVENT->Ordem+" - "+LANC->Evento+" - "+EVENT->Descricao+" - "+EVENT->Finalidade+" - "+EVENT->Tipo)
      LANC->(dbskip())
   enddo
   asort(aEVENTOS)

   clear_sl(08,02,22,77,48)
   qsay(09,04,"Ordem de c lculo efetuada:")

   LANC->(dbgoto(nLA_RECNO))
   EVENT->(dbgoto(nEV_RECNO))

   qmensa("Utilize as setas ou <ESC> p/ retornar...")
   achoice(11,11,21,67,aEVENTOS)
return

/////////////////////////////////////////////////////////////////////////////
// VERIFICA OS KITS UTILIZADOS ______________________________________________

static function i_x_kits_utilizados

   if ! cAMBIENTE $ "MS.AD.FE.DT"
      qmensa("Kits n„o utilizados neste ambiente...")
      return
   endif

   private aKITS   := {}
   private cMACROI := "Kit_i_" + cAMBIENTE
   private cMACROE := "Kit_e_" + cAMBIENTE

   CARGO->(dbseek(SITUA->Cargo))
   SIND->(dbseek(FUN->Sind_cod))
// CCUSTO->(dbseek(FUN->Centro))
   CCUSTO->(dbseek(SITUA->Ccusto))
   FILIAL->(dbseek(FUN->Filial))

   if KIT->(dbseek(SITUA->(&cMACROI)))  ; i_aux("Inc.Funcs.") ; endif
   if KIT->(dbseek(SITUA->(&cMACROE)))  ; i_aux("Exc.Funcs.") ; endif
   if KIT->(dbseek(CARGO->(&cMACROI)))  ; i_aux("Inc.Cargo.") ; endif
   if KIT->(dbseek(CARGO->(&cMACROE)))  ; i_aux("Exc.Cargo.") ; endif
   if KIT->(dbseek(SIND->(&cMACROI)))   ; i_aux("Inc.Sind..") ; endif
   if KIT->(dbseek(SIND->(&cMACROE)))   ; i_aux("Exc.Sind..") ; endif
   if KIT->(dbseek(FILIAL->(&cMACROI))) ; i_aux("Inc.Filial") ; endif
   if KIT->(dbseek(FILIAL->(&cMACROE))) ; i_aux("Exc.Filial") ; endif
   if KIT->(dbseek(CCUSTO->(&cMACROI))) ; i_aux("Inc.Centro") ; endif
   if KIT->(dbseek(CCUSTO->(&cMACROE))) ; i_aux("Exc.Centro") ; endif
   if KIT->(dbseek(CONFIG->(&cMACROI))) ; i_aux("Inc.Empre.") ; endif
   if KIT->(dbseek(CONFIG->(&cMACROE))) ; i_aux("Exc.Empre.") ; endif

   clear_sl(08,02,22,77,48)
   qsay(09,04,"Kits utilizados:")
   qmensa("Utilize as setas ou <ESC> p/ retornar...")
   achoice(11,11,21,67,aKITS)
return

static function i_aux ( cSTRING )
   aadd(aKITS,cSTRING+": "+KIT->Codigo+" - "+KIT->Descricao)
return

