
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE KITS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

#include "inkey.ch"

KIT->(qview({{"Codigo/C¢digo"      ,1},;
             {"Descricao/Descri‡„o",2}},"P",;
             {NIL,"c122a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c122a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(7,6,"B122A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fCODIGO) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , KIT->Codigo    )
      qrsay ( XNIVEL++ , KIT->Descricao )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; func122a()   ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!",NIL,cOPCAO=="I") }    ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!",NIL,.T.) }            ,"DESCRICAO"})
   aadd(aEDICAO,{{ || func122a() },"VETOR"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   KIT->(qpublicfields())
   iif(cOPCAO=="I",KIT->(qinitfields()),KIT->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; KIT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if KIT->(iif(cOPCAO=="I",qappend(),qrlock()))
      KIT->(qreplacefields())
      KIT->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           if KIT->(dbseek(fCODIGO))
              qmensa("Kit j  cadastrado !","B")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR KITS _________________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Kit ?")
      if KIT->(qrlock())
         KIT->(dbdelete())
         KIT->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MARCAR OS EVENTOS DO KIT _____________________________________

function func122a
   local nCONT, cSTRING, zTMP
   local aEVENTOS := {{chr(255)+"  ",space(40),space(18)}}

   // CONVERTE STRING PARA VETOR ____________________________________________

   for nCONT := 1 to 150 step 3
       zTMP := substr(KIT->Eventos,nCONT,3)
       if val(zTMP) == 0
          exit
       else
          EVENT->(dbseek(zTMP))
          aadd(aEVENTOS,{zTMP,EVENT->Descricao,conv121a(EVENT->Tipo)})
       endif
   next

   // ENTRA EM BROWSE _______________________________________________________

   i_browse ( aEVENTOS )

   // CONVERTE VETOR PARA STRING ____________________________________________

   fEVENTOS := ""
   for nCONT := 1 to len(aEVENTOS)
       if val(aEVENTOS[nCONT,1]) != 0
          fEVENTOS += aEVENTOS[nCONT,1]
       endif
   next
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO QUE VAI FAZER O BROWSE DA COMPOSICAO DE EVENTOS DO KIT ____________

static function i_browse ( aEVENTOS )

   // DEFINICAO E INICIALIZACAO DE VARIAVEIS ________________________________

   local zTMP                       // VARIAVEL TEMPORARIA
   local oVIEW                      // OBJETO BROWSE
   local nTECLA                     // USADO PARA PEGAR TECLA PRESSIONADA
   local nCURSOR := setcursor(0)    // ESTADO ATUAL DO CURSOR
   private nROW := 1                // POINTER PARA AS LINHAS DO BROWSE

   setcolor(atcsc_sl(00,40))

   // CRIA OBJETO BROWSE E CONFIGURA AMBIENTE _______________________________

   oVIEW := tbrowsenew ( 10 , 07 , 20 , 72 )

   oVIEW:headsep := "Ä"
   oVIEW:colsep  := "³"

   oVIEW:skipblock := { |x| x := askip(x,aEVENTOS) }

   oVIEW:GoTopBlock    := { || nROW := 1 }
   oVIEW:GoBottomBlock := { || nROW := len(aEVENTOS) }

   // ADICIONA AS COLUNAS DO BROWSE _________________________________________

   oVIEW:AddColumn(TBColumnNew("Ev."      ,{||aEVENTOS[nROW,1]} ))
   oVIEW:AddColumn(TBColumnNew("Descri‡„o",{||aEVENTOS[nROW,2]} ))
   oVIEW:AddColumn(TBColumnNew("Tipo"     ,{||aEVENTOS[nROW,3]} ))

   // INICIA EXIBICAO DO BROWSE _____________________________________________

   do while .T.

       if cOPCAO == "C"
          qmensa("<ESC> p/ retornar...")
       else
          qmensa("<I>nclui   <E>xclui   <Esc>-retorna")
       endif

      // FAZ ASORT PARA MANTER EM ORDEM NUMERICA DE EVENTOS _________________

      asort ( aEVENTOS ,,, { |x,y| x[1]<y[1] } )

      // ESTABILIZA E/OU ESPERA POR TECLA ___________________________________

      nTECLA := 0
      do while ! oVIEW:stabilize()
         if ( nTECLA := qinkey() ) != 0 ; exit ; endif
      enddo

      if cOPCAO != "E"
         if nTECLA == 0
            nTECLA := qinkey(0)
         endif
      endif

      if oVIEW:Stable

         do case

            // MOVIMENTACAO PADRAO __________________________________________

            case nTECLA == K_UP     ;  oVIEW:Up()
            case nTECLA == K_DOWN   ;  oVIEW:Down()
            case nTECLA == K_LEFT   ;  oVIEW:Left()
            case nTECLA == K_RIGHT  ;  oVIEW:Right()
            case nTECLA == K_PGUP   ;  oVIEW:pageup()
            case nTECLA == K_PGDN   ;  oVIEW:pagedown()
            case nTECLA == K_HOME   ;  oVIEW:gotop()
            case nTECLA == K_END    ;  oVIEW:gobottom()

            // INCLUI _______________________________________________________

            case upper(chr(nTECLA)) == "I" .and. cOPCAO != "C"
                 EVENT->(qview({{"Evento/Ev."         ,1},;
                                {"Descricao/Descri‡„o",2},;
                                {"conv121a(Tipo)/Tipo",0}},"09111968",;
                                {"EXIT",NIL,NIL,NIL}))
                 if lastkey() == 13
                    if ascan(aEVENTOS,{|x|x[1]==EVENT->Evento}) != 0
                       qmensa("Evento j  incluido no Kit !","B")
                    else
                       aadd(aEVENTOS,{ EVENT->Evento , EVENT->Descricao , conv121a(EVENT->Tipo) })
                    endif
                 endif
                 oVIEW:RefreshAll()

            // EXCLUI _______________________________________________________

            case upper(chr(nTECLA)) == "E" .and. cOPCAO != "C" .and. len(aEVENTOS) > 1
                 if qconf("Confirma exclus„o deste evento ?")
                    adel(aEVENTOS,nROW)
                    asize(aEVENTOS,len(aEVENTOS)-1)
                    oVIEW:RefreshAll()
                 endif
                 if cOPCAO == "C"
                    qmensa("<ESC> p/ retornar...")
                 else
                    qmensa("<I>nclui   <E>xclui   <Esc>-retorna")
                 endif

            // ESC __________________________________________________________

            case nTECLA == K_ESC .or. cOPCAO == "E"
                 exit

         endcase

      endif

   enddo

   setcursor ( nCURSOR )

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER O SKIP DO VETOR ________________________________________

static function askip ( nTO_JUMP, aEVENTOS )

   local nJUMPED := 0

   if nROW + nTO_JUMP < 1
      nJUMPED := -nROW + 1
      nROW    := 1
   elseif nROW + nTO_JUMP > len(aEVENTOS)
      nJUMPED := len(aEVENTOS) - nROW
      nROW    := len(aEVENTOS)
   else
      nJUMPED := nTO_JUMP
      nROW    += nTO_JUMP
   endif

return nJUMPED

