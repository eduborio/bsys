/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: LANCAMENTOS DE BENEFICIOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: JUNHO DE 1994
// OBS........:
// ALTERACOES.:

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

local   zTMP                            // variavel temporaria
private cEVENTO                         // codigo do evento
private aBENEF := {}                    // vetor com os beneficios
private cAMBIENTE                       // ambiente sendo trabalhado
private cMATRICULA := space(6)          // matricula do funcionario

// MONTA VETOR COM OS BENEFICIOS CADASTRADOS ________________________________

qmensa("Aguarde um momento...")

EVENT->(dbgotop())

do while ! EVENT->(eof())
   qgirabarra()
   iif ( EVENT->Tipo == "6" , aadd(aBENEF,EVENT->Evento+" - "+EVENT->Descricao) , NIL )
   EVENT->(dbskip())
enddo

// CARGA DA TABELA GERAL ____________________________________________________

if ! quse(XDRV_RHX,"TBGR",{"TBGR"},"R") ; return .F. ; endif
if ! TBGR->(dbseek(XANOMES))
   qmensa("Tabela Geral incompleta para este periodo !","B")
   return .F.
endif
TBGR->(qpublicfields("X")) ; TBGR->(qcopyfields("X")) ; TBGR->(dbclosearea())

// ESTABELECE RELACIONAMENTO ENTRE ARQUIVOS _________________________________

BENEF->(dbSetRelation("FUN" ,{|| Matricula},"Matricula"))
BENEF->(dbSetRelation("LANC",{|| XANOMES+Matricula+cAMBIENTE+Evento},"XANOMES+Matricula+cAMBIENTE+Evento"))

cAMBIENTE := rh_escolhe_amb() // "MS","AD","DT","FR","PV"

if empty(cAMBIENTE) ; return ; endif

i_inic_204()

release XTB_GR*

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL PARA LANCAMENTOS ________________________________________

static function i_inic_204

setcolor("W/B")

do while .T.

   qlbloc(5,0,"B204A","QBLOC.GLO")
   qsay(06,07,cAMBIENTE)
   cEVENTO := space(3)

   // SOLICITA CODIGO DO BENEFICIO (EVENTO) _________________________________

   qmensa("F9 para view dos beneficios disponiveis...")
   set key -8 to i_escolhe_beneficios()
   qgetx(06,22,@cEVENTO,"999",NIL,.T.)
   set key -8 to
   qmensa()
   if val(cEVENTO) == 0 ; exit ; endif
   if LAstkey()==27; Exit; Endif
   qsay(06,22,cEVENTO := strzero(val(cEVENTO),3))

   if ascan(aBENEF,cEVENTO) == 0
      qmensa("Evento n„o ‚ tipo Beneficio !","B")
      loop
   endif

   // PROCURA EVENTO ________________________________________________________

   if ! EVENT->(dbseek(cEVENTO))
      qmensa("Beneficio n„o cadastrado !","B") ; loop
   endif

   qsay(06,38,EVENT->Descricao)

   FORM->(dbseek(EVENT->Formula))

   // ACIONA BROWSE DE VINCULACAO DE FUNCIONARIOS ___________________________

   BENEF->(dbseek(XANOMES+cEVENTO+cAMBIENTE))

   BENEF->(qview({{"Matricula/Matri."                            ,1},;
                  {"left(FUN->Nome,30)/Nome do Funcion rio"      ,0},;
                  {"transform(Valor ,'@E 999,999.99')/Valor"     ,0},;
                  {"transform(Fracao,'@E 999.9999')/Fra‡„o"      ,0},;
                  {"transform(N1,'999')/L1"                      ,0},;
                  {"transform(N2,'999')/Q1"                      ,0},;
                  {"C1"                                          ,0},;
                  {"C2"                                          ,0},;
                  {"iif(BENEF->Fixa,'FI','  ')/Fi"               ,0}},;
                  "07002379",;
                  {NIL,"f204a",NIL,NIL},;
                  {"BENEF->Anomes+BENEF->Evento+BENEF->Ambiente==XANOMES+cEVENTO+cAMBIENTE",{||f204top()},{||f204bot()}},;
                  "<Esc>-Incl-Alte-Excl-Glob-Fixa-Libe-Matr-Nome-Quant"))

enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f204top
   BENEF->(dbseek(XANOMES+cEVENTO+cAMBIENTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f204bot
   BENEF->(qseekn(XANOMES+cEVENTO+cAMBIENTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

function f204a

   local zTMP            // variavel temporaria
   local nCONT           // contador para for/next
   local nVALOR          // para editar valor
   local nFRACAO         // para editar fracao
   local cC1, cC2        // para editar campos caracteres
   local nN1, nN2        // para editar campos numericos
   local cBLOCO          // variavel de salvamento de area de video
   local nREG            // registro do arquivo FUN para retorno

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   do case

      case cOPCAO == "I"            // incluir ______________

           qmensa("Incluir Funcion rio... <ESC Cancela>")

           cMATRICULA := space(6)

           cBLOCO := qsbloc(10,16,19,64)
           qlbloc(10,16,"B204D","QBLOC.GLO")

           view_fun(11,32,@cMATRICULA)

           cMATRICULA := strzero(val(cMATRICULA),6)

           if ! empty(cMATRICULA) .and. FUN->(dbseek(cMATRICULA))
              if FUN->Data_adm > qfimmes(XDATASYS)
                 qmensa("Funcion rio admitido em mˆs posterior ! Inclus„o cancelada !","B")
                 return
              endif

              if cEVENTO != "207"
                 nREG := FUN->(recno())
                 if BENEF->(dbseek(XANOMES+cEVENTO+cAMBIENTE+cMATRICULA))
                    qmensa("Este Benef¡cio s¢ admite um lan‡amento por Matr¡cula !!","B")
                    return
                 endif
                 FUN->(dbgoto(nREG))
              endif
              
              qsay(11,32,FUN->Matricula)
              qsay(12,32,left(FUN->Nome,30))

              nVALOR  := 0
              nFRACAO := 0
              nN1     := 0
              nN2     := 0
              cC1     := " "
              cC2     := " "

              if cEVENTO != "207"
                 qgetx(13,32,@nVALOR ,"@E 999,999.99" )
                 if Lastkey()==27 ;return; endif
                 qgetx(14,32,@nFRACAO,"@E 999.9999"   )
                 if Lastkey()==27 ;return; endif
                 qgetx(15,32,@nN1    ,"999"           )
                 if Lastkey()==27 ;return; endif
                 qgetx(16,32,@nN2    ,"999"           )
                 if Lastkey()==27 ;return; endif
                 qgetx(17,32,@cC1    ,"!"             )
                 if Lastkey()==27 ;return; endif
                 qgetx(18,32,@cC2    ,"!"             )
                 if Lastkey()==27 ;return; endif
              else
                 qgetx(15,32,@nN1    ,"999"           )
                 if Lastkey()==27 ;return; endif
                 VALE->(Dbsetorder(1))
                 if ! VALE->(dbseek(XANOMES+strzero(nN1,2)))
                    nN1 := 0
                 endif
                 qgetx(16,32,@nN2    ,"999"           )
                 if Lastkey()==27 ;return; endif
              endif

              if BENEF->(qappend())
                 replace BENEF->Anomes    with XANOMES
                 replace BENEF->Evento    with cEVENTO
                 replace BENEF->Ambiente  with cAMBIENTE
                 replace BENEF->Matricula with FUN->Matricula
                 replace BENEF->Valor     with nVALOR
                 replace BENEF->Fracao    with nFRACAO
                 replace BENEF->N1        with nN1
                 replace BENEF->N2        with nN2
                 replace BENEF->C1        with cC1
                 replace BENEF->C2        with cC2

                 if CONFIG->Datasys < CONFIG->Data_atual
                    zREGBNF:=BENEF->(recno())
                    if BENEF->(qappend()) .and. BENEF->(qrlock())
                       if right(XANOMES,2) == "12"
                          replace BENEF->Anomes with strzero(val(XANOMES)+89,6)
                       else
                          replace BENEF->Anomes with strzero(val(XANOMES)+1,6)
                       endif
                       replace BENEF->Evento    with cEVENTO
                       replace BENEF->Ambiente  with cAMBIENTE
                       replace BENEF->Matricula with FUN->Matricula
                       replace BENEF->Valor     with nVALOR
                       replace BENEF->Fracao    with nFRACAO
                       replace BENEF->N1        with nN1
                       replace BENEF->N2        with nN2
                       replace BENEF->C1        with cC1
                       replace BENEF->C2        with cC2
                    endif
                    BENEF->(qunlock())
                    BENEF->(dbgoto(zREGBNF))
                 endif
                 BENEF->(qunlock())
              else
                 qm1()
              endif
           else
              if !Lastkey()==27
                 qmensa("Funcionario n„o cadastrado !!","B")
              Endif
           endif

           qrbloc(10,16,cBLOCO)

      case cOPCAO == "A"            // alterar ______________
           qmensa("<Pressione ESC para Cancelar>")
           if BENEF->Fixa
              qmensa("Evento fixado. Altera‡„o negada...","B") ; return ""
           endif

           nVALOR  := BENEF->Valor
           nFRACAO := BENEF->Fracao
           nN1     := BENEF->N1
           nN2     := BENEF->N2
           cC1     := BENEF->C1
           cC2     := BENEF->C2
           zTMP    := row()

           if cEVENTO != "207"
              qgetx(zTMP,41,@nVALOR ,"@E 999,999.99" )
              if Lastkey()==27 ;return; endif
              qgetx(zTMP,52,@nFRACAO,"@E 999.9999"   )
              if Lastkey()==27 ;return; endif
              qgetx(zTMP,61,@nN1    ,"999"           )
              if Lastkey()==27 ;return; endif
              qgetx(zTMP,65,@nN2    ,"999"           )
              if Lastkey()==27 ;return; endif
              qgetx(zTMP,69,@cC1    ,"!"             )
              if Lastkey()==27 ;return; endif
              qgetx(zTMP,72,@cC2    ,"!"             )
              if Lastkey()==27 ;return; endif
           else
              qgetx(zTMP,61,@nN1    ,"999"           )
              if Lastkey()==27 ;return; endif
              if ! VALE->(dbseek(XANOMES+strzero(nN1,2)))
                 nN1 := 0
              endif
              qgetx(zTMP,65,@nN2    ,"999"           )
              if Lastkey()==27 ;return; endif
           endif

           if qconf("Confirma altera‡„o ?")
              if BENEF->(qrlock())
                 replace BENEF->Valor  with nVALOR
                 replace BENEF->Fracao with nFRACAO
                 replace BENEF->N1     with nN1
                 replace BENEF->N2     with nN2
                 replace BENEF->C1     with cC1
                 replace BENEF->C2     with cC2
                 BENEF->(qunlock())
              else
                 qm2()
              endif
           endif

      case cOPCAO == "E"            // excluir _______________

           if qconf("Confirma excluir "+FUN->Matricula+"/"+left(FUN->Nome,30)+" ?")
              if BENEF->(qrlock())
                 BENEF->(dbdelete())
                 BENEF->(qunlock())
              else
                 qm3()
              endif
           endif

      case cOPCAO == "G"            // alteracao global ______

           i_altera_global()

      case cOPCAO == "Q"            // alteracao global ______

           i_quant()

      case cOPCAO == "F"            // fixar _________________

           if qconf("Confirma fixar "+FUN->Matricula+"/"+left(FUN->Nome,30)+" ?")
              if BENEF->(qrlock())
                 replace BENEF->Fixa with .T.
                 BENEF->(qunlock())
              else
                 qmensa("N„o foi possivel fixar, tente novamente...","B")
              endif
           endif

      case cOPCAO == "L"            // liberar _______________

           if ! BENEF->Fixa
              qmensa("Funcionario n„o esta fixado ...","B") ; return ""
           endif

           if qconf("Confirma liberar "+FUN->Matricula+"/"+left(FUN->Nome,30)+" ?")
              if BENEF->(qrlock())
                 BENEF->Fixa  := .F.
                 BENEF->Valor := 0
                 BENEF->(qunlock())
              else
                 qmensa("N„o foi possivel liberar, tente novamente...","B")
              endif
           endif

      case cOPCAO == "M"            // buscar matricula_______

           qmensa("Buscar Matricula:")
           zTMP := space(6)
           qgetx(24,29,@zTMP,"999999",NIL,.T.)
           qmensa()
           zTMP := strzero(val(zTMP),6)
           BENEF->(dbseek(XANOMES+BENEF->Evento+cAMBIENTE+zTMP,.T.))

      case cOPCAO == "N"            // buscar nome____________

           qmensa("Buscar Nome:")
           zTMP := space(30)
           qgetx(24,24,@zTMP,"@!",NIL,.T.)
           zTMP := alltrim(zTMP)
           qmensa()
           FUN->(ordsetfocus(2)) // nome
           FUN->(dbseek(zTMP))
           FUN->(ordsetfocus(1)) // matricula
           BENEF->(dbseek(XANOMES+BENEF->Evento+cAMBIENTE+FUN->Matricula,.T.))

   endcase

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHER BENEFICIOS CADASTRADOS ______________________________

static function i_escolhe_beneficios
   local cOPCAO, sTELA := qsbloc(5,5,20,70)
   clear_sl(06,13,14,60,23)
   @ 06,13 to 14,60
   cOPCAO := achoice(07,14,13,59,aBENEF)
   if lastkey() == 13 ; keyboard(left(aBENEF[cOPCAO],3))+chr(13) ; endif
   qrbloc(5,5,sTELA)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR ALTERACOES GLOBAIS __________________________________

static function i_altera_global
   local cTIPO   := "1"
   local nVALOR  := 0
   local nFRACAO := 0
   local cC1 := cC2 := " "
   local nN1 := nN2 := 0
   local sBLOC := qlbloc("B204C","QBLOC.GLO")

   qmensa("Escolha o campo a ser alterado p/ todos...")

   qesco(14,50,@cTIPO,sBLOC,1)

   if empty(cTIPO) ; return .F. ; endif

   qmensa("Edite o campo escolhido: ")

   do case
      case cTIPO == "1" ; qgetx(24,36,@nVALOR ,"@E 999,999.99" )
      case cTIPO == "2" ; qgetx(24,36,@nFRACAO,"@E 999.9999"   )
      case cTIPO == "3" ; qgetx(24,36,@nN1    ,"999"           )
      case cTIPO == "4" ; qgetx(24,36,@nN2    ,"999"           )
      case cTIPO == "5" ; qgetx(24,36,@cC1    ,"@!"            )
      case cTIPO == "6" ; qgetx(24,36,@cC2    ,"@!"            )
   endcase

   qmensa("Alterando, aguarde...")

   BENEF->(dbseek(XANOMES+cEVENTO+cAMBIENTE))

   do while ! BENEF->(eof()) .and. BENEF->Anomes == XANOMES .and. BENEF->Evento == cEVENTO .and. BENEF->Ambiente == cAMBIENTE
      qgirabarra()
      if BENEF->(qrlock())
         do case
            case cTIPO == "1" ; replace BENEF->Valor  with nVALOR
            case cTIPO == "2" ; replace BENEF->Fracao with nFRACAO
            case cTIPO == "3" ; replace BENEF->N1     with nN1
            case cTIPO == "4" ; replace BENEF->N2     with nN2
            case cTIPO == "5" ; replace BENEF->C1     with cC1
            case cTIPO == "6" ; replace BENEF->C2     with cC2
         endcase
         BENEF->(qunlock())
      endif
      BENEF->(dbskip())
   enddo

   BENEF->(dbseek(XANOMES+cEVENTO+cAMBIENTE))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR ALTERACOES GLOBAIS __________________________________

static function i_quant
   local cTIPO   := "1"
   local nN1 := nN2 := nUTIL := nSAB := nTOT:= nFUN :=0

   qmensa("Alterando, aguarde...")

   BENEF->(dbseek(XANOMES+cEVENTO+cAMBIENTE))
   nFUN:= FUN->(recno())
   do while ! BENEF->(eof()) .and. BENEF->Anomes == XANOMES .and. BENEF->Evento == cEVENTO .and. BENEF->Ambiente == cAMBIENTE
      qgirabarra()
      if BENEF->(qrlock())
            FUN->(dbseek(BENEF->Matricula))
            nUTIL := FUN->Util * XGR_D_UTIL
            nTOT  := day(qfimmes(XDATASYS))
            nSAB  := FUN->Sabado * (nTOT - (XGR_D_UTIL+XGR_D_DESC))

            replace BENEF->N2     with nUTIL + nSAB

         BENEF->(qunlock())
      endif
      nSAB := nUTIL := nTOT := 0
      BENEF->(dbskip())
   enddo
   FUN->(dbgoto(nFUN))
   BENEF->(dbseek(XANOMES+cEVENTO+cAMBIENTE))

return .T.

