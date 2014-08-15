
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONFIGURACAO DA ORDEM DE CALCULO DOS EVENTOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........: CAMPO "ORDEM" NO ARQUIVO "EVENT"
// ALTERACOES.:

#include "inkey.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

local C_TMP, nCONT, nTECLA, C_POINTER, aEVENTOS := {}

// variaveis cOPCAO, sBLOCO3 e fCOMBINA sao utilizadas
// p/ manter compatibilidade com a funcao i_combinacao()
// ja construida no RH121.prg - cadastro de eventos

private cOPCAO   := "C"
private sBLOCO3  := qlbloc("B121D","QBLOC.GLO")
private fCOMBINA := ""

// PREENCHE VETOR ___________________________________________________________

qmensa("Lendo ordem de calculo...")
do while ! EVENT->(eof())
   qgirabarra()
   aadd(aEVENTOS,{EVENT->Ordem,EVENT->Evento,EVENT->Descricao,EVENT->Finalidade,EVENT->Tipo})
   EVENT->(dbskip())
enddo

// FAZ ORDENACAO BASEADO NO PRIMEIRO SUB-ELEMENTO "ORDEM" ___________________

qmensa("Classificando ordem de calculo... aguarde !")
asort(aEVENTOS,,,{|a,b|a[1]<b[1]})
aadd(aEVENTOS,{" "," "," "," "," "})

// ENTRA EM BROWSE __________________________________________________________

setcursor(0)
i_view(aEVENTOS)
setcursor(1)

// GRAVA ORDEM CORRETA DE CALCULO ___________________________________________

qmensa("Gravando ordem de calculo...")
for nCONT := 1 to len(aEVENTOS)
    qgirabarra()
    if EVENT->(dbseek(aEVENTOS[nCONT,2]))
       if EVENT->(qrlock())
          replace EVENT->Ordem with strzero(nCONT,3)
          EVENT->(dbunlock())
       endif
    endif
    EVENT->(dbskip())
next

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER O BROWSE _______________________________________________

static function i_view ( aEVENTOS )

   // DEFINICAO E INICIALIZACAO DE VARIAVEIS ________________________________

   local oVIEW              // OBJETO BROWSE
   local nTECLA             // USADO PARA PEGAR TECLA PRESSIONADA
   local nROW_EVENT := 0    // LINHA DO EVENTO MARCADO
   local cCOD_EVENT         // CODIGO DO EVENTO MARCADO
   local cDES_EVENT         // DESCRICAO DO EVENTO MARCADO
   local cFIN_EVENT         // FINALIDADE DO EVENTO MARCADO
   local cTIP_EVENT         // TIPO DO EVENTO MARCADO
   private nROW := 1        // POINTER PARA AS LINHAS DO BROWSE

   setcolor(atcsc_sl(08,28))

   // CRIA OBJETO BROWSE E CONFIGURA AMBIENTE _______________________________

   oVIEW := tbrowsenew ( 07 , 03 , 21 , 76 )

   oVIEW:headsep  := "Ä"
   oVIEW:colsep   := "³"
   oVIEW:autolite := .F.

   oVIEW:skipblock := { |x| x := askip(x,aEVENTOS) }

   oVIEW:GoTopBlock    := { || nROW := 1 }
   oVIEW:GoBottomBlock := { || nROW := len(aEVENTOS) }

   // ADICIONA AS COLUNAS DO BROWSE _________________________________________

   oVIEW:AddColumn(TBColumnNew("Cod"       ,{||aEVENTOS[nROW,2]} ))
   oVIEW:AddColumn(TBColumnNew("Descricao" ,{||aEVENTOS[nROW,3]} ))
   oVIEW:AddColumn(TBColumnNew("Finalidade",{||i_805a(aEVENTOS[nROW,4])} ))
   oVIEW:AddColumn(TBColumnNew("Tipo"      ,{||i_805b(aEVENTOS[nROW,5])} ))

   // INICIA EXIBICAO DO BROWSE _____________________________________________

   do while .T.

      if nROW_EVENT == 0
         qmensa("<M>arca/<D>esmarca/<I>nclui/<C>ombinacao/<ESC> p/ finalizar !")
      endif

      // ESTABILIZA E/OU ESPERA POR TECLA ___________________________________

      nTECLA := 0
      do while ! oVIEW:stabilize()
         if ( nTECLA := qinkey() ) != 0 ; exit ; endif
      enddo

      qinver(row(),03,74)
      if nTECLA == 0 ; nTECLA := qinkey(0) ; endif
      qinver(row(),03,74)

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
            case nTECLA == K_ESC    ;  exit

            // MARCA EVENTO _________________________________________________

            case upper(chr(nTECLA)) == "M"
                 cCOD_EVENT := aEVENTOS[nROW,2]
                 cDES_EVENT := aEVENTOS[nROW,3]
                 cFIN_EVENT := aEVENTOS[nROW,4]
                 cTIP_EVENT := aEVENTOS[nROW,5]
                 nROW_EVENT := nROW
                 qmensa("Evento Marcado: "+cCOD_EVENT+"... <D>esmarca/<I>nclui/ESC")

            // CANCELA MARCACAO _____________________________________________

            case upper(chr(nTECLA)) == "D"
                 nROW_EVENT := 0

            // INCLUI NA POSICAO ATUAL ______________________________________

            case upper(chr(nTECLA)) == "I"
                 if nROW_EVENT <> 0
                    nTECLA := iif(nROW>nROW_EVENT,1,0)
                    adel(aEVENTOS,nROW_EVENT)
                    ains(aEVENTOS,nROW-nTECLA)
                    aEVENTOS[nROW-nTECLA] := {" ",cCOD_EVENT,cDES_EVENT,cFIN_EVENT,cTIP_EVENT}
                    aEVENTOS[len(aEVENTOS)] := {" "," "," "," "," "}
                    nROW_EVENT := 0
                 endif
                 oVIEW:refreshall()

            // CONSULTA COMBINACAO __________________________________________

            case upper(chr(nTECLA)) == "C"

                 EVENT->(dbseek(aEVENTOS[nROW,2]))
                 fCOMBINA := EVENT->Combina
                 i_combinacao()

         endcase

      endif

   enddo

return

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

static function i_805a ( cFINALIDADE )
return qabrev(cFINALIDADE,"PD+-",{"Provento","Desconto","+ de Base","- de Base"})

static function i_805b ( cTIPO )
return qabrev(cTIPO,"123456",{"Formula Associada","Valor Constante","Valor Informado","Fra‡„o Informada","% sobre Combina‡„o","Beneficio"})

