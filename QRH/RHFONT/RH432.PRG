
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: AFASTAMENTO DE FUNCIONARIOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....:
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// VIEW DO FUNCIONARIOS _____________________________________________________

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

FUN->(dbSetFilter({|| Situacao <> "H"},"Situacao <> 'H'"))

FUN->(dbgotop())

FUN->(qview({{"Matricula/Matr."    ,1},;
             {"left(Nome,30)/Nome" ,2},;
             {"i432a()/Sit."       ,0},;
             {"i432b()/Af"         ,0},;
             {"i432c()/Tipo Afast.",0}},"P",;
             {NIL,"i432d",NIL,"str6"},;  // funcao str6 esta em funcoes.prg
             NIL,"ALT_O / ALT_P / <A>fastamento"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXPANDIR A SITUACAO DO FUNCIONARIO ___________________________

function i432a
return qabrev(FUN->Situacao," TFADH",{"      ","Traba.","F‚rias","Afast.","Demit.","Homol."})

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR O CODIGO DE AFASTAMENTO DO FUNCIONARIO ______________

function i432b
   SITUA->(dbseek(FUN->Matricula))
return (SITUA->Af_cod)

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO AFASTAMENTO _______________________________________

function i432c
   AFAST->(dbseek(SITUA->Af_cod))
return left(AFAST->Descricao,25)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i432d
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "AE"
      qlbloc(9,3,"B432A","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// EDICAO DOS DADOS PARA O AFASTAMENTO ______________________________________

static function i_edicao

   local   aEDICAO := {}, lCONF
   private bESCAPE := { || empty(cAF_COD) .or. (XNIVEL==3 .and. !XFLAG) .or. !empty(cAF_COD) .and. Lastkey()==27}
   private cMATRICULA, dAF_INI, dAF_RET, cAF_COD, cCODSAQFGTS
   private dINICIO_AV, dFINAL_AV, cREADMISSAO, lALTERAR := .F.

   // CRIACAO DO VETOR DE BLOCOS ____________________________________________

   aadd(aEDICAO,{{ || NIL },"MATRICULA"})
   aadd(aEDICAO,{{ || NIL },"NOME"}) // nome do funcionario
   aadd(aEDICAO,{{ || view_afast(-1,0,@cAF_COD)                            },"AF_COD"})
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao do afastamento
   aadd(aEDICAO,{{ || NIL },NIL}) // codigo do kit
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao do kit
   aadd(aEDICAO,{{ || NIL },NIL}) // codigo da formula
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao da formula
   aadd(aEDICAO,{{ || qgetx(-1,0,@dAF_INI)                                 },"AF_INI"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dAF_RET    ,NIL,NIL,AFAST->Retorno=="S") },"AF_RET"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dINICIO_AV ,NIL,NIL,AFAST->Retorno=="N") },"INICIO_AV"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dFINAL_AV  ,NIL,NIL,AFAST->Retorno=="N") },"FINAL_AV"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@cCODSAQFGTS,NIL,NIL,AFAST->Retorno=="N") },"CODSAQFGTS"})
   aadd(aEDICAO,{{ || iif(AFAST->Retorno=="N",qesco(-1,0,@cREADMISSAO,XSN),NIL) },"READMISSAO"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma afastamento deste funcionario ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL      := 3
   XFLAG       := .T.
   cMATRICULA  := space(6)
   cAF_COD     := "  "
   cCODSAQFGTS := SITUA->Codsaqfgts
   dAF_INI     := ctod("")
   dAF_RET     := ctod("")
   dINICIO_AV  := SITUA->Inicio_av
   dFINAL_AV   := SITUA->Final_av
   cREADMISSAO := "S"

   qrsay(1,FUN->Matricula)
   qrsay(2,left(FUN->Nome,30))

   SITUA->(dbseek(FUN->Matricula))

   // SE JA AFASTADO, ENTAO E' ALTERACAO ____________________________________

   if FUN->Situacao <> "T"
      
      AFAST->(dbseek(SITUA->Af_cod))
      KIT->(dbseek(AFAST->Kit))
      FORM->(dbseek(AFAST->Formula))

      qrsay(3,SITUA->Af_cod)
      qrsay(4,AFAST->Descricao)
      qrsay(5 ,KIT->Codigo)
      qrsay(6 ,KIT->Descricao)
      qrsay(7 ,FORM->Codigo)
      qrsay(8 ,left(FORM->Descricao,30))
      qrsay(9 ,SITUA->Af_ini)
      qrsay(10,SITUA->Af_ret)
      qrsay(11,SITUA->Inicio_av)
      qrsay(12,SITUA->Final_av)
      qrsay(13,SITUA->Codsaqfgts)
      qrsay(14,iif(SITUA->Readmissao=="S","Sim","N„o"))


      if qconf("Funcion rio j  afastado ! Quer alterar dados ?")
         lALTERAR    := .T.
         cAF_COD     := SITUA->Af_cod
         dAF_INI     := SITUA->Af_ini
         dAF_RET     := SITUA->Af_ret
         dINICIO_AV  := SITUA->Inicio_av
         dFINAL_AV   := SITUA->Final_av
         cCODSAQFGTS := SITUA->Codsaqfgts
         cREADMISSAO := SITUA->Readmissao
      else
         keyboard chr(13)
      endif
   endif

   XFLAG   := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // PROCESSAMENTO _________________________________________________________

   iif ( lCONF , i_processa_afastamento() , NIL )

return

/////////////////////////////////////////////////////////////////////////////
// TRATAMENTO DE CRITITICAS _________________________________________________

static function i_critica ( cCAMPO )
   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "AF_COD"
           if AFAST->(dbseek(cAF_COD))
              qrsay ( XNIVEL+1 , AFAST->Descricao )
           else
              qmensa("Afastamento n„o encontrado !","B")
              return .F.
           endif
           if KIT->(dbseek(AFAST->Kit))
              qrsay ( XNIVEL+2 , KIT->Codigo    )
              qrsay ( XNIVEL+3 , KIT->Descricao )
           else
              qmensa("Kit n„o encontrado !","B")
              return .F.
           endif
           if FORM->(dbseek(AFAST->Formula))
              qrsay ( XNIVEL+4 , FORM->Codigo    )
              qrsay ( XNIVEL+5 , left(FORM->Descricao,30) )
           else
              qmensa("F¢rmula n„o encontrada !","B")
              return .F.
           endif
           if ! lALTERAR .and. ! seval(FORM->Formula)
              qmensa("Funcionario n„o pode ser afastado !","B")
              return .F.
           endif
      case cCAMPO == "AF_INI"
           if empty(dAF_INI)
              qmensa("Data do Afastamento ‚ obrigat¢ria !","B")
              return .F.
           endif
      case cCAMPO == "INICIO_AV"
           if empty(dINICIO_AV)
              XNIVEL++
           endif
      case cCAMPO == "CODSAQFGTS"
           if cCODSAQFGTS $  "00- 0-0 "
                cCODSAQFGTS := space(2)
           endif
      case cCAMPO == "READMISSAO"
           qrsay(XNIVEL,qabrev(cREADMISSAO,"SN",{"SIM","NŽO"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA PROCESSAR O AFASTAMENTO ______________________________________

static function i_processa_afastamento

   local nCONT, zTMP, nLEN_EVKIT

   qmensa()

   if ! lALTERAR

      if alert("( "+FUN->Matricula+"-"+alltrim(left(FUN->Nome,30))+" );;Favor reconfirmar o afastamento deste funcion rio !",{"N„o","Sim"}) != 2
         return
      endif

      // antes estava nesta posicao rotina para limpar os lancamentos atuais...

      qmensa("Processando... (Fase 2)")

      nLEN_EVKIT := len(KIT->Eventos)

      for nCONT := 1 to nLEN_EVKIT step 3
          zTMP := substr(KIT->Eventos,nCONT,3)
          if val(zTMP) == 0
             exit
          else
             if LANC->(qappend())
                replace LANC->Anomes    with XANOMES
                replace LANC->Ambiente  with "MS"
                replace LANC->Matricula with FUN->Matricula
                replace LANC->Evento    with zTMP
                LANC->(dbunlock())
                LANC->(dbgoto(recno()))
             endif
          endif
      next

      qmensa("Processando... (Fase 3)")

   endif

   if FUN->(qrlock()) .and. SITUA->(qrlock())
      replace FUN->Situacao     with iif(AFAST->Retorno=="S","A","D")
      replace SITUA->Situacao   with iif(AFAST->Retorno=="S","A","D")
      replace SITUA->Af_cod     with AFAST->Codigo
      replace SITUA->Af_ini     with dAF_INI
      replace SITUA->Af_ret     with dAF_RET
      replace SITUA->Inicio_av  with dINICIO_AV
      replace SITUA->Final_av   with dFINAL_AV
      replace SITUA->Codsaqfgts with cCODSAQFGTS
      replace SITUA->Readmissao with cREADMISSAO
      replace FUN->dt_afast     with dAF_INI
      FUN->(dbunlock())
      SITUA->(dbunlock())
      FUN->(dbgoto(recno()))
      SITUA->(dbgoto(recno()))
   endif

return

