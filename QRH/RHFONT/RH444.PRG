/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: ENTRADA DE FERIAS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1994
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// VIEW DO FUNCIONARIOS _____________________________________________________

private cANOMES := qanomes(XDATASYS)
private nFALTAS, nFALGET, nFERIAS

SITUA->(dbSetFilter({|| Anomes == XANOMES .and. Situacao <> "H"},"Anomes == XANOMES .and. Situacao <> 'H'"))

SITUA->(dbgotop())

SITUA->(qview({{"Matricula"          ,1},;
               {"i444a()/Nome"       ,2},;
               {"i444b()/Sit."       ,0},;
               {"Pi_ferias/Ini.Fer." ,0},;
               {"Pf_ferias/Fin.Fer." ,0},;
               {"Af_cod/Cod.Af."     ,0}},"P",;
               {NIL,"i444c",NIL,"str6"},;  // funcao str6 esta em funcoes.prg
                NIL,"ALT_O / ALT_P / coloca em <F>erias"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR O NOME DO FUNCIONARIO _______________________________

function i444a
   FUN->(dbseek(SITUA->Matricula))
return (left(FUN->Nome,30))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXPANDIR A SITUACAO DO FUNCIONARIO ___________________________

function i444b
return qabrev(FUN->Situacao," TFADH",{"      ","Traba.","F‚rias","Afast.","Demit.","Homol."})

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i444c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "F"
      if FUN->Situacao == "F"
         qmensa("Funcion rio j  est  em F‚rias !!","B")
         return ""
      endif
      qlbloc(8,3,"B444A","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// REALIZA A CONFIRMACAO DOS DADOS PARA A ENTRADA DE FERIAS _________________

static function i_edicao
   local lCONF := .F.
   local aEDICAO := {}

   private bESCAPE := { || empty(dDI_FERIAS) .or. (XNIVEL==3 .and. !XFLAG) .or. !empty(dDI_FERIAS) .and. lastkey()==27}

   qmensa("<ESC - Cnacela>")

   if empty(DI_FERIAS) .or. empty(DF_FERIAS) .or. empty(PI_FERIAS) .or. empty(PF_FERIAS)
      qmensa("Datas incompletas !! Rode antes a programa‡„o de F‚rias (op‡„o 443)","B")
      return
   endif

   FUN->(dbseek(SITUA->Matricula))

   private dDI_FERIAS := SITUA->Di_ferias
   private dDF_FERIAS := SITUA->Df_ferias
   private dPI_FERIAS := SITUA->Pi_ferias
   private dPF_FERIAS := SITUA->Pf_ferias
   private dBI_FERIAS := SITUA->Bi_ferias
   private dBF_FERIAS := SITUA->Bf_ferias

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || NIL                      },NIL        })
   aadd(aEDICAO,{{ || NIL                      },NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDI_FERIAS)  },"DI_FERIAS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDF_FERIAS)  },"DF_FERIAS"})
   aadd(aEDICAO,{{ || NIL                      },NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dPI_FERIAS)  },"PI_FERIAS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dPF_FERIAS)  },"PF_FERIAS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dBI_FERIAS)  },"BI_FERIAS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dBF_FERIAS)  },"BF_FERIAS"})
   aadd(aEDICAO,{{ || NIL                      },NIL        })
   aadd(aEDICAO,{{ || NIL                      },NIL        })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma f‚rias deste funcion rio ?") },NIL})

   // INICIALIZACAO DA EDICAO __________________________________________________

   XNIVEL  := 3
   XFLAG   := .T.
   nFALTAS := 0
   nFALGET := 0
   nFERIAS := 0

   qrsay(1,FUN->Matricula)
   qrsay(2,left(FUN->Nome,30))

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // PROCESSAMENTO _________________________________________________________

   iif ( lCONF , i_processa_ferias() ,)

return .T.

/////////////////////////////////////////////////////////////////////////////
// TRATAMENTO DE CRITICAS ___________________________________________________

static function i_critica ( cCAMPO )
   local n

   do case
      case cCAMPO == "DF_FERIAS"
           if dDF_FERIAS < dDI_FERIAS
              qmensa("Data anterior ao inicio do periodo !","B")
              return .F.
           endif

           nFALTAS := jficha(dDI_FERIAS,dDF_FERIAS,"MS","221","F","S")
           nFALTAS += jficha(dDI_FERIAS,dDF_FERIAS,"MS","270","F","S")

           nFALGET := nFALTAS

           qgetx(13,57,@nFALGET,"99")

           if nFALGET != nFALTAS
              nFALTAS := nFALGET
           endif

           qsay(13,57,strzero(nFALTAS,2))
           
           do case
              case nFALTAS <= 5
                   nFERIAS := dPF_FERIAS-dPI_FERIAS + 1
              case nFALTAS >= 6  .and. nFALTAS <= 14
                   nFERIAS := 24
              case nFALTAS >= 15 .and. nFALTAS <= 23
                   nFERIAS := 18
              case nFALTAS >= 24 .and. nFALTAS <= 32
                   nFERIAS := 12
           endcase
                  
           qrsay(XNIVEL+6,strzero(nFERIAS,2))

           if nFALTAS > 5
              dPF_FERIAS := (dPI_FERIAS + nFERIAS) - 1
              qrsay(XNIVEL+2,dPF_FERIAS)
           endif

      case cCAMPO == "PF_FERIAS"
           if dPF_FERIAS < dPI_FERIAS
              qmensa("Data anterior ao inicio das ferias !","B")
              return .F.
           endif

      case cCAMPO == "BI_FERIAS"
           if ! empty(dBI_FERIAS)
              if ! XFLAG
                 ++XNIVEL
              endif
              if nFALTAS > 5
                 dBF_FERIAS := dPF_FERIAS
              endif
           else
              dBF_FERIAS := ctod("")
              qrsay(XNIVEL++,"  /  /  ")
              qrsay(XNIVEL+2,space(2))
           endif

      case cCAMPO == "BF_FERIAS"
           if ! empty(dBF_FERIAS)
              if dBF_FERIAS < dBI_FERIAS
                 qmensa("Data anterior ao inicio do abono !","B")
                 return .F.
              endif
              qrsay(XNIVEL+2,strzero((dBF_FERIAS-dBI_FERIAS)+1,2))
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA PROCESSAR AS FERIAS __________________________________________

static function i_processa_ferias

   local nCONT, zTMP, nLENKIT

   qmensa()

   // SOLICITA RECONFIRMACAO ________________________________________________

   if alert("( "+FUN->Matricula+"-"+alltrim(left(FUN->Nome,30))+" );;Favor reconfirmar a entrada de F‚rias deste funcion rio !",{"N„o","Sim"}) != 2
      return
   endif

   // PROCESSA NOVA SITUACAO ________________________________________________

   i_aciona_kit()

   qmensa("Processando nova situa‡„o...")

   if FUN->(qrlock()) .and. SITUA->(qrlock())
      FUN->Situacao     := "F"
      SITUA->Situacao   := "F"
      SITUA->Af_cod     := "FR"
      SITUA->Pi_ferias  := dPI_FERIAS
      SITUA->Pf_ferias  := dPF_FERIAS
      SITUA->Pi_ferias  := dPI_FERIAS
      SITUA->Pf_ferias  := dPF_FERIAS
      SITUA->Bi_ferias  := dBI_FERIAS
      SITUA->Bf_ferias  := dBF_FERIAS
      SITUA->Af_ini     := SITUA->Pi_ferias
      SITUA->Af_ret     := SITUA->Pf_ferias
      SITUA->Ai_ferias  := SITUA->Di_ferias
      SITUA->Af_ferias  := SITUA->Df_ferias
      SITUA->Di_ferias  := dDI_FERIAS
      SITUA->Df_ferias  := dDF_FERIAS
   endif
   if ! empty(dBI_FERIAS) .and. ! empty(dBF_FERIAS)
      if ! LANC->(dbseek(cANOMES+FUN->Matricula+"FR191"))
         if LANC->(qappend())
            LANC->Anomes    := cANOMES
            LANC->Matricula := FUN->Matricula
            LANC->Ambiente  := "FR"
            LANC->Evento    := "191"
         endif
      endif
      if ! LANC->(dbseek(cANOMES+FUN->Matricula+"FR192"))
         if LANC->(qappend())
            LANC->Anomes    := cANOMES
            LANC->Matricula := FUN->Matricula
            LANC->Ambiente  := "FR"
            LANC->Evento    := "192"
         endif
      endif
   endif

   dbunlockall()
   FUN->(dbgoto(recno()))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA LANCAR OS KITS DE FERIAS _____________________________________

static function i_aciona_kit
   local aEVENTOS, nCONT

   qmensa("incluindo kit...")
   aEVENTOS := rh_ret_kit("KIT_I_FR")

   for nCONT := 1 to len(aEVENTOS)
       if ! LANC->(dbseek(cANOMES+FUN->Matricula+"FR"+aEVENTOS[nCONT]))
          if EVENT->(dbseek(aEVENTOS[nCONT]))
             if LANC->(qappend())
                LANC->Anomes    := cANOMES
                LANC->Matricula := FUN->Matricula
                LANC->Ambiente  := "FR"
                LANC->Evento    := aEVENTOS[nCONT]

                if aEVENTOS[nCONT] == "225"
                   LANC->Fracao := nFALTAS
                endif

                LANC->(qunlock())
             endif
          endif
       endif
   next

   qmensa("excluindo kit...")
   aEVENTOS := rh_ret_kit("KIT_E_FR")

   for nCONT := 1 to len(aEVENTOS)
       if LANC->(dbseek(cANOMES+FUN->Matricula+"FR"+aEVENTOS[nCONT]))
          if LANC->(qrlock())
             LANC->(dbdelete())
             LANC->(qunlock())
          endif
       endif
   next

return
