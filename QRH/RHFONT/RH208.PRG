/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: LANCAMENTOS DE DIVISAO POR CENTRO DE CUSTO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: IDEM
// INICIO.....: AGOSTO DE 1999
// OBS........:
// ALTERACOES.:

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

private cMATRICULA                   // matricula do funcionario com strzero
private cANOMES       := qanomes(XDATASYS)
private cTOT_MES      := 0
private cT_EVENTO     := space(3)
private cT_CENTRO     := space(8)
private cT_TOT_MES    := 0
private nMES          := 0
private nTOTAL        := 0
private lPRIMEIRO_LANCAMENTO := .T.

/////////////////////////////////////////////////////////////////////////////
// SELECIONA RELACAO ENTRE ARQUIVOS _________________________________________

DIV_CUST->(dbsetrelation("EVENT",{|| Evento},"Evento"))
DIV_CUST->(dbsetrelation("CCUSTO",{|| Centro},"Codigo"))

DIV_CUST->(Dbsetorder(1))

/////////////////////////////////////////////////////////////////////////////
// EXECUTA A FUNCAO PRINCIPAL _______________________________________________

i_inic_208()

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE INICIALIZACAO DOS LANCAMENTOS E ESCOLHA DO FUNCIONARIO _________

static function i_inic_208

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

do while .T.

   setcursor(1)
   qlbloc(5,0,"B208A","QBLOC.GLO")
   cMATRICULA := space(6)
   keyboard chr(32)

   // SOLICITA MATRICULA DO FUNCIONARIO _____________________________________

   view_fun(6,14,@cMATRICULA)
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

   qsay(06,14,FUN->Matricula)
   qsay(06,27,left(FUN->Nome,25))

   SITUA->(dbseek(FUN->Matricula))

   if FUN->Situacao == "H"
      qmensa("Funcionario com Homologa‡„o confirmada ...","B")
      loop
   endif

   qgetx(6,73,@cTOT_MES,"@R 9999")

   i_pr_acao()

enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f208top
   DIV_CUST->(dbsetorder(1))
   DIV_CUST->(dbgotop())
   DIV_CUST->(dbseek(XANOMES+cMATRICULA))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f208bot
   DIV_CUST->(qseekn(XANOMES+cMATRICULA))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f208a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      i_pr_acao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_pr_acao

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

DIV_CUST->(qview({{"Evento/Evento"                                      ,0},;
                  {"left(EVENT->Descricao,45)/Descri‡„o"                ,0},;
                  {"Centro/Centro"                                      ,0},;
                  {"transform(Horas,'@R 999.99')/Horas"                 ,0}},;
                  "07002279S",;
                  {NIL,"f208d",NIL,NIL},;
                  {"DIV_CUST->Anomes==XANOMES .and. DIV_CUST->Matricula==cMATRICULA",{||f208top()},{||f208bot()}},;
                  "<I>nc./<A>lt./<C>on.<E>xc."))

   if LASTKEY() == K_ESC
      i_diferenca()
      if nTOTAL <> cTOT_MES
         alert("O numero do horas lan‡adas" +transform(nTOTAL,'@R 9999') + ", difere do total "+transform(cTOT_MES,'@R 9999'))
         i_pr_acao()
      endif
   endif

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f208d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))


   if cOPCAO $ XUSRA
      qlbloc(13,08,"B208B","QBLOC.GLO",1)
      i_proc_acao()
   endif


   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_proc_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fEVENTO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , DIV_CUST->Evento                               )
      qrsay ( XNIVEL++ , left(EVENT->Descricao,32)                      )
      qrsay ( XNIVEL++ , left(DIV_CUST->Centro,28)                      )
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,25)                     )
      qrsay ( XNIVEL++ , DIV_CUST->Horas, "@E 999.99"                   )
      qrsay ( XNIVEL++ , DIV_CUST->Percentual, "@E 99.99"               )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_div_cust() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_event(-1,0,@fEVENTO                     ) } ,"EVENTO"    })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })

   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO                    ) } ,"CENTRO"    })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fHORAS, "@E 999.99"              ) } ,"HORAS"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERCENTUAL, "@E 99.99"          ) } ,"PERCENTUAL"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   DIV_CUST->(qpublicfields())

//   iif(cOPCAO=="I",DIV_CUST->(qinitfields()),DIV_CUST->(qcopyfields()))

   if cOPCAO == "I"
      if ! lPRIMEIRO_LANCAMENTO
         fANOMES     := XANOMES
         fEVENTO     := cT_EVENTO
         fCENTRO     := cT_CENTRO
         fTOT_MES    := cT_TOT_MES
         fHORAS      := 0
         fPERCENTUAL := 0
      else
         DIV_CUST->(qinitfields())
      endif
   endif

   if cOPCAO == "A"
      DIV_CUST->(qcopyfields())
   endif

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; DIV_CUST->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if DIV_CUST->(qrlock()) .and. DIV_CUST->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fMATRICULA := cMATRICULA
         fANOMES    := XANOMES
         fTOT_MES   := cTOT_MES
      endif
      DIV_CUST->(qreplacefields())
      DIV_CUST->(qunlock())
      cT_EVENTO  := fEVENTO
      cT_CENTRO  := fCENTRO
      cT_TOT_MES := fTOT_MES

      lPRIMEIRO_LANC := .F.

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif


   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "EVENTO"

           if ! EVENT->(dbseek(fEVENTO))
              qmensa("Evento n„o encontrado !","B")
              return .F.
           endif

           qrsay ( XNIVEL+1 , left(EVENT->Descricao,32) )

           fANOMES    := XANOMES

      case cCAMPO == "CENTRO"

           if ! CCUSTO->(dbseek(fCENTRO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif

           qrsay ( XNIVEL+1 , left(CCUSTO->Descricao,28) )

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR LANCAMENTOS __________________________________________

static function i_exc_div_cust

   if qconf("Confirma exclus„o do Lan‡amento ?")
      if DIV_CUST->(qrlock())
         DIV_CUST->(dbdelete())
         DIV_CUST->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc

setcolor("W/B")

DIV_CUST->(qview({{"Evento/Evento"                                      ,0},;
                  {"left(EVENT->Descricao,45)/Descri‡„o"                ,0},;
                  {"Centro/Centro"                                      ,0},;
                  {"transform(Horas,'@E 999.99')/Horas"                 ,0}},;
                  "07002279S",;
                  {NIL,NIL,NIL,NIL},;
                  {"DIV_CUST->Matricula==cMATRICULA",{||f208top()},{||f208bot()}},;
                 "<ESC> para sair" ))

return ""

////////////////////////////////////////////////////////////////////////////////////
function i_diferenca
   local cREG := DIV_CUST->(recno())
   nTOTAL := 0
   DIV_CUST->(dbgotop())
   DIV_CUST->(dbseek(XANOMES+FUN->Matricula))
   do while ! DIV_CUST->(eof()) .and. DIV_CUST->Anomes == XANOMES .and. DIV_CUST->Matricula == FUN->Matricula
      nTOTAL += DIV_CUST->Horas
      DIV_CUST->(Dbskip())
   enddo
return
