/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: CONFIGURACAO DA DEMONSTRACAO DE RESULTADO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR:
// INICIO.....: 2008
// OBS........:
// ALTERACOES.:
function ct805

#include "inkey.ch"

private cCOMBINA

// FILTRA RESULT.DBF PARA NAO MOSTRAR TITULO MAE ____________________________

RESULTAD->(qview({{"Titulo/T¡tulo",1},{"i_805b()/Conte£do",0}},"P",;
                {"i_805a",NIL,NIL,NIL},;
                NIL,"<ENTER> para Combina‡„o de C¢digos Cont beis"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_805a
   local nCURSOR := setcursor(1)
   if Tipo == "2"
      i2_combinacao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO QUE MOSTRA SE HA COMBINACAO NESSE TITULO __________________________

function i_805b
   local nRET
   nRET := iif(Tipo=="1","   ",iif(empty(Combina2),"N„o","Sim"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA COMBINACAO DE CODIGOS CONTABEIS REDUZIDOS ____________________

function i2_combinacao

   local aCODIGOS, nCONT, cOPER, cEV, nLENCOMB, cCOMBINA

   local nORDER  := PLAN->(indexord())
   local sBLOCO  := qsbloc(07,14,19,67)
   local nCURSOR := setcursor(0)

   private sBLOCO1 := qlbloc("B805A","QBLOC.GLO") // combinacao

   qrbloc(07,14,sBLOCO1)

   PLAN->(dbsetorder(3))

   cCOMBINA := RESULTAD->Combina2

   // CONVERTE STRING P/ VETOR ______________________________________________

   aCODIGOS := {}

   if ! empty(cCOMBINA)
      nLENCOMB := len(cCOMBINA)
      for nCONT := 1 to nLENCOMB step 7
          cOPER := substr(cCOMBINA,nCONT,1)
          cCOD  := ct_convcod(substr(cCOMBINA,nCONT+1,6))
          if cOPER $ "+-" .and. val(cCOD) != 0
             PLAN->(dbseek(qtiraponto(cCOD)))
             aadd(aCODIGOS,{cCOD,PLAN->Descricao," "+cOPER+" "})
          else
             exit
          endif
      next
   endif

   aadd(aCODIGOS,{chr(255)+"      ",space(41),"   "})

   // ENTRA EM EDICAO _______________________________________________________

   browse121 ( aCODIGOS )

   // CONVERTE VETOR P/ STRING ______________________________________________

   cCOMBINA := ""

   for nCONT := 1 to len(aCODIGOS)
       if val(aCODIGOS[nCONT,1]) != 0
          cCOMBINA += ( substr(aCODIGOS[nCONT,3],2,1) + qtiraponto(aCODIGOS[nCONT,1]) )
       endif
   next

   if RESULTAD->(qrlock())
      replace RESULTAD->Combina2 with cCOMBINA
      RESULTAD->(qunlock())
   else
      qm2()
   endif

   qrbloc(07,14,sBLOCO)
   PLAN->(dbsetorder(nORDER))
   setcursor(nCURSOR)

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER O BROWSE _______________________________________________

static function browse121 ( aCODIGOS )

   // DEFINICAO E INICIALIZACAO DE VARIAVEIS ________________________________

   local   zTMP           // variavel temporaria
   local   oVIEW          // objeto browse
   local   nTECLA         // usado para pegar tecla pressionada
   private nROW := 1      // pointer para as linhas do browse
   private cREDUZ         // conta reduzida digitada

   setcolor(atcsc_sl(08,28))

   // CRIA OBJETO BROWSE E CONFIGURA AMBIENTE _______________________________

   oVIEW := tbrowsenew ( 08 , 15 , 18 , 66 )

   oVIEW:headsep := "Ä"
   oVIEW:colsep  := "³"

   oVIEW:skipblock := { |x| x := askip(x,aCODIGOS) }

   oVIEW:GoTopBlock    := { || nROW := 1 }
   oVIEW:GoBottomBlock := { || nROW := len(aCODIGOS) }

   // ADICIONA AS COLUNAS DO BROWSE _________________________________________

   oVIEW:AddColumn(TBColumnNew("C¢digo"   ,{||aCODIGOS[nROW,1]} ))
   oVIEW:AddColumn(TBColumnNew("Descri‡„o",{||aCODIGOS[nROW,2]} ))
   oVIEW:AddColumn(TBColumnNew("+/-"      ,{||aCODIGOS[nROW,3]} ))

   // INICIA EXIBICAO DO BROWSE _____________________________________________

   do while .T.

      qmensa("<I>nclui  <E>xclui  <Esc>-retorna")

      // ESTABILIZA E/OU ESPERA POR TECLA ___________________________________

      nTECLA := 0

      do while ! oVIEW:stabilize()
         if ( nTECLA := qinkey() ) != 0 ; exit ; endif
      enddo

      if nTECLA == 0 ; nTECLA := qinkey(0) ; endif

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

            case upper(chr(nTECLA)) == "I"
                 cREDUZ := "       "
                 zTMP   := " + "

                 view_plan(20,23,@cREDUZ)

                 cREDUZ := strzero(val(qtiraponto(cREDUZ)),6)

                 if PLAN->(dbseek(qtiraponto(cREDUZ)))
                    qsay(20,23,transform(cREDUZ,"@R 99999-9"))
                    qsay(20,33,padl(PLAN->Descricao,34))
                    if qconf("Confirma inclusao desta conta ?","B")
                       zTMP := " + "
                       asize(aCODIGOS,len(aCODIGOS)+1)
                       ains(aCODIGOS,nROW)
                       aCODIGOS[nROW]  := { ct_convcod(PLAN->Reduzido) , PLAN->Descricao , zTMP }
                    endif
                 endif

                 qmensa()
                 qsay(20,23,space(7))
                 qsay(20,33,space(34))

                 oVIEW:RefreshAll()

            // EXCLUI _______________________________________________________

            case upper(chr(nTECLA)) == "E" .and. len(aCODIGOS) > 1
                 if qconf("Confirma exclus„o deste evento ?")
                    adel(aCODIGOS,nROW)
                    asize(aCODIGOS,len(aCODIGOS)-1)
                    oVIEW:RefreshAll()
                 endif

            // ESC __________________________________________________________

            case nTECLA == K_ESC
                 exit

         endcase

      endif

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER O SKIP DO VETOR ________________________________________

static function askip ( nTO_JUMP, aCODIGOS )

   local nJUMPED := 0

   if nROW + nTO_JUMP < 1
      nJUMPED := -nROW + 1
      nROW    := 1
   elseif nROW + nTO_JUMP > len(aCODIGOS)
      nJUMPED := len(aCODIGOS) - nROW
      nROW    := len(aCODIGOS)
   else
      nJUMPED := nTO_JUMP
      nROW    += nTO_JUMP
   endif

return nJUMPED

