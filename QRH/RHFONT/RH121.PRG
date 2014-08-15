
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE EVENTOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

#include "inkey.ch"

EVENT->(qview({{"Evento/C¢digo"      ,1},;
               {"Descricao/Descri‡„o",2},;
               {"Finalidade/Fin."    ,0},;
               {"i_tipo121()/Tipo"   ,0},;
               {"Formula/F¢rmula"    ,0}},"P",;
               {NIL,"c121a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

function i_tipo121
return qabrev(EVENT->Tipo,"123456",{"Formu","VaCon","VaInf","FrInf","% Com","Benef"})

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c121a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(5,4,"B121A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fEVENTO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fDESCRICAO) .and. XNIVEL==2 .and. Lastkey()==27) .or. ;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}
   private sBLOCO1 := qlbloc("B121B","QBLOC.GLO") // tipo
   private sBLOCO2 := qlbloc("B121C","QBLOC.GLO") // finalidade
   private sBLOCO3 := qlbloc("B121D","QBLOC.GLO") // combinacao
   private sBLOCO4 := qlbloc("B121E","QBLOC.GLO") // +ou- na combinacao

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , EVENT->Evento    )
      qrsay ( XNIVEL++ , EVENT->Descricao )
      qrsay ( XNIVEL++ , EVENT->Formula   ) ; FORM->(dbseek(EVENT->Formula))
      qrsay ( XNIVEL++ , FORM->Descricao )
      qrsay ( XNIVEL++ , qabrev(EVENT->Tipo,"123456",{"F¢rmula Associada","Valor Constante","Valor Informado","Fra‡„o Informada","% sobre Combina‡„o","Beneficio"}))
      qrsay ( XNIVEL++ , qabrev(EVENT->Finalidade,"PD+-",{"Provento","Desconto","+ de Base","- de Base"}))
      qrsay ( XNIVEL++ , EVENT->Valor,"@E 999,999.9999")
      qrsay ( XNIVEL++ , EVENT->Edicao)
      qrsay ( XNIVEL++ , EVENT->Legal_irrf)
      qrsay ( XNIVEL++ , EVENT->Legal_inss)
      qrsay ( XNIVEL++ , EVENT->Legal_fgts)
      qrsay ( XNIVEL++ , qabrev(EVENT->inssms,"SN",{"Sim","N„o"}))
      qrsay ( XNIVEL++ , qabrev(EVENT->inssfr,"SN",{"Sim","N„o"}))
      qrsay ( XNIVEL++ , qabrev(EVENT->irrfms,"SN",{"Sim","N„o"}))
      qrsay ( XNIVEL++ , qabrev(EVENT->irrffr,"SN",{"Sim","N„o"}))
      qrsay ( XNIVEL++ , qabrev(EVENT->fgtsms,"SN",{"Sim","N„o"}))
      qrsay ( XNIVEL++ , qabrev(EVENT->fgtsfr,"SN",{"Sim","N„o"}))
      qrsay ( XNIVEL++ , qabrev(EVENT->salfam,"SN",{"Sim","N„o"}))
      qrsay ( XNIVEL++ , qabrev(EVENT->sindic,"SN",{"Sim","N„o"}))
      qrsay ( XNIVEL++ , qabrev(EVENT->rais  ,"SN",{"Sim","N„o"}))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEVENTO   ,"@!",NIL,cOPCAO=="I") }         ,"EVENTO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!"     ,NIL,.T.) }            ,"DESCRICAO"})
   aadd(aEDICAO,{{ || FORM->(qview(-1,0,@fFORMULA,"9999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL})) },"FORMULA"})
   aadd(aEDICAO,{{ || NIL } ,NIL}) // descricao da formula utilizada
   aadd(aEDICAO,{{ || qesco(-1,0,@fTIPO,sBLOCO1) },"TIPO"       })
   aadd(aEDICAO,{{ || qesco(-1,0,@fFINALIDADE  ,sBLOCO2) },"FINALIDADE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR, "@E 999,999.9999",NIL,.T.) },"VALOR" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fEDICAO,"@!",NIL,.T.) },"EDICAO"                 })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLEGAL_IRRF,"@!",NIL,.T.) },"LEGAL_IRRF"         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLEGAL_INSS,"@!",NIL,.T.) },"LEGAL_INSS"         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLEGAL_FGTS,"@!",NIL,.T.) },"LEGAL_FGTS"         })
   aadd(aEDICAO,{{ || qesco(-1,0,@fINSSMS,XSN  )},"INSSMS"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fINSSFR,XSN  )},"INSSFR"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fIRRFMS,XSN  )},"IRRFMS"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fIRRFFR,XSN  )},"IRRFFR"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fFGTSMS,XSN  )},"FGTSMS"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fFGTSFR,XSN  )},"FGTSFR"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fSALFAM,XSN  )},"SALFAM"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fSINDIC,XSN  )},"SINDIC"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fRAIS  ,XSN  )},"RAIS"    })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   EVENT->(qpublicfields())
   iif(cOPCAO=="I",EVENT->(qinitfields()),EVENT->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; EVENT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if EVENT->(iif(cOPCAO=="I",qappend(),qrlock()))
      EVENT->(qreplacefields())
      EVENT->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "EVENTO" .and. cOPCAO == "I"
           if val(fEVENTO) < 100
              qmensa("N„o ‚ permitida a inclus„o de Eventos inferiores a 100 !","B")
              return .F.
           else
              alert("Informe a Q-SYS da cria‡„o deste Evento !!")
           endif
           if EVENT->(dbseek(fEVENTO))
              qmensa("Evento j  cadastrado !","B")
              return .F.
           endif
           fEDICAO := "VFDXLP"
      case cCAMPO == "FORMULA"
           if ! empty(fFORMULA)
              if ! FORM->(dbseek(fFORMULA))
                 qmensa("F¢rmula n„o encontrada !","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,FORM->Descricao)
              endif
           endif
      case cCAMPO == "TIPO"
           if empty(fTIPO)
              qmensa("A escolha do Tipo ‚ obrigat¢ria !","B")
              return .F.
           endif
           qrsay ( XNIVEL , qabrev(fTIPO,"123456",{"Formula Associada","Valor Constante","Valor Informado","Fra‡„o Informada","% sobre Combina‡„o","Beneficio"}))
           iif(fTIPO=="5",i_combinacao(),NIL)
      case cCAMPO == "FINALIDADE"
           if empty(fFINALIDADE)
              qmensa("A escolha da Finalidade ‚ obrigat¢ria !","B")
              return .F.
           endif
           qrsay ( XNIVEL , qabrev(fFINALIDADE,"PD+-",{"Provento","Desconto","+ de Base","- de Base"}))
      case cCAMPO == "SALFAM"
           qrsay ( XNIVEL , qabrev(fSALFAM,"SN",{"Sim","N„o"}))
      case cCAMPO == "INSSMS"
           qrsay ( XNIVEL , qabrev(fINSSMS,"SN",{"Sim","N„o"}))
      case cCAMPO == "INSSFR"
           qrsay ( XNIVEL , qabrev(fINSSFR,"SN",{"Sim","N„o"}))
      case cCAMPO == "IRRFMS"
           qrsay ( XNIVEL , qabrev(fIRRFMS,"SN",{"Sim","N„o"}))
      case cCAMPO == "IRRFFR"
           qrsay ( XNIVEL , qabrev(fIRRFFR,"SN",{"Sim","N„o"}))
      case cCAMPO == "FGTSMS"
           qrsay ( XNIVEL , qabrev(fFGTSMS,"SN",{"Sim","N„o"}))
      case cCAMPO == "FGTSFR"
           qrsay ( XNIVEL , qabrev(fFGTSFR,"SN",{"Sim","N„o"}))
      case cCAMPO == "SINDIC"
           qrsay ( XNIVEL , qabrev(fSINDIC,"SN",{"Sim","N„o"}))
      case cCAMPO == "RAIS"
           qrsay ( XNIVEL , qabrev(fRAIS ,"SN",{"Sim","N„o"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR EVENTO _______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Evento ?")
      if EVENT->(qrlock())
         EVENT->(dbdelete())
         EVENT->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA COMBINACAO DE EVENTOS ________________________________________

function i_combinacao

   local aEVENTOS, nCONT, cOPER, cEV, nLENCOMB

   local nRECNO := EVENT->(recno())
   local nORDER := EVENT->(indexord())
   local sBLOCO := qsbloc(07,15,19,64)
   local nCURSOR := setcursor(0)

   qrbloc(07,15,sBLOCO3)
   EVENT->(dbsetorder(1))

   // CONVERTE STRING P/ VETOR ______________________________________________

   aEVENTOS := {{chr(255)+"  ",space(40),"   "}}
   if ! empty(fCOMBINA)
      nLENCOMB := len(fCOMBINA)
      for nCONT := 1 to nLENCOMB step 4
          cOPER := substr(fCOMBINA,nCONT  ,1)
          cEV   := substr(fCOMBINA,nCONT+1,3)
          if cOPER $ "+-" .and. val(cEV) != 0
             EVENT->(dbseek(cEV))
             aadd(aEVENTOS,{cEV,EVENT->Descricao," "+cOPER+" "})
          elseif cEV == "@SC"
             aadd(aEVENTOS,{cEV,"Salario Contratual"+space(12)," "+cOPER+" "})
          else
             exit
          endif
      next
   endif

   // ENTRA EM EDICAO _______________________________________________________

   browse121 ( aEVENTOS )

   // CONVERTE VETOR P/ STRING ______________________________________________

   fCOMBINA := ""
   for nCONT := 1 to len(aEVENTOS)
       if val(aEVENTOS[nCONT,1]) != 0 .or. aEVENTOS[nCONT,1] == "@SC"
          fCOMBINA += ( substr(aEVENTOS[nCONT,3],2,1) + aEVENTOS[nCONT,1] )
       endif
   next

   qrbloc(07,15,sBLOCO)
   EVENT->(dbsetorder(nORDER))
   EVENT->(dbgoto(nRECNO))
   setcursor(nCURSOR)

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER O BROWSE _______________________________________________

static function browse121 ( aEVENTOS )

   // DEFINICAO E INICIALIZACAO DE VARIAVEIS ________________________________

   local zTMP           // VARIAVEL TEMPORARIA
   local oVIEW          // OBJETO BROWSE
   local nTECLA         // USADO PARA PEGAR TECLA PRESSIONADA
   private nROW := 1    // POINTER PARA AS LINHAS DO BROWSE

   setcolor(atcsc_sl(08,28))

   // CRIA OBJETO BROWSE E CONFIGURA AMBIENTE _______________________________

   oVIEW := tbrowsenew ( 08 , 16 , 18 , 63 )

   oVIEW:headsep := "Ä"
   oVIEW:colsep  := "³"

   oVIEW:skipblock := { |x| x := askip(x,aEVENTOS) }

   oVIEW:GoTopBlock    := { || nROW := 1 }
   oVIEW:GoBottomBlock := { || nROW := len(aEVENTOS) }

   // ADICIONA AS COLUNAS DO BROWSE _________________________________________

   oVIEW:AddColumn(TBColumnNew("Ev."      ,{||aEVENTOS[nROW,1]} ))
   oVIEW:AddColumn(TBColumnNew("Descri‡„o",{||aEVENTOS[nROW,2]} ))
   oVIEW:AddColumn(TBColumnNew("+/-"      ,{||aEVENTOS[nROW,3]} ))

   // INICIA EXIBICAO DO BROWSE _____________________________________________

   do while .T.

      if cOPCAO == "C"
         qmensa("<ESC> p/ retornar...")
      else
         qmensa("<I>nclui  <E>xclui  <S>alario Contratual  <Esc>-retorna")
      endif

      // FAZ ASORT PARA MANTER EM ORDEM NUMERICA DE EVENTOS _________________

      asort ( aEVENTOS ,,, { |x,y| x[1]<y[1] } )

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

            case upper(chr(nTECLA)) == "I" .and. cOPCAO != "C"
                 zTMP := " + "
                 EVENT->(qview({{"Evento/Ev."         ,1},;
                                {"Descricao/Descri‡„o",2},;
                                {"conv121a()/Tipo",0}},"09111968",;
                                {"EXIT",NIL,NIL,NIL}))
                 if lastkey() == 13
                    qesco(08,60,@zTMP,sBLOCO4)
                    zTMP := iif(zTMP=="+"," + "," - ")
                    aadd(aEVENTOS,{ EVENT->Evento , EVENT->Descricao , zTMP })
                 endif
                 oVIEW:RefreshAll()

            // EXCLUI _______________________________________________________

            case upper(chr(nTECLA)) == "E" .and. cOPCAO != "C" .and. len(aEVENTOS) > 1
                 if qconf("Confirma exclus„o deste evento ?")
                    adel(aEVENTOS,nROW)
                    asize(aEVENTOS,len(aEVENTOS)-1)
                    oVIEW:RefreshAll()
                 endif

            // SALARIO CONTRATUAL ___________________________________________

            case upper(chr(nTECLA)) == "S" .and. cOPCAO != "C"
                 zTMP := " + "
                 qesco(08,60,@zTMP,sBLOCO4)
                 zTMP := iif(zTMP=="+"," + "," - ")
                 aadd(aEVENTOS,{ "@SC" , "Salario Contratual" , zTMP })
                 oVIEW:RefreshAll()

            // ESC __________________________________________________________

            case nTECLA == K_ESC
                 exit

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

function conv121a
return qabrev(EVENT->Tipo,"123456",{"Formula Associada","Valor Constante","Valor Informado","Fra‡„o Informada","% sobre Combina‡„o","Beneficio"})

