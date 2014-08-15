/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: LANCAMENTOS MULTIPLOS PARA OS FUNCIONARIOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: IDEM
// INICIO.....: JUNHO DE 1994
// OBS........:
// ALTERACOES.:

private cAMBIENTE := rh_escolhe_amb() // "MS","AD","DT","FR","PV"

if empty(cAMBIENTE) ; return ; endif

SITUA->(dbSetFilter({|| Anomes == XANOMES},'Anomes == XANOMES'))

i_inic_202()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE INICIALIZACAO E ENTRADA DE DADOS _______________________________

static function i_inic_202

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO := {}, lCONF
private bESCAPE, sBLOCO1, sBLOCO2
private cACAO, cCATEGO, cEVENTO, cCENTRO, cCBO
private cFILIAL, cCARGO, cSINDICAT, cFORMULA, nVALOR, nFRACAO, cFIXA

// INICIALIZACAO DE VARIAVEIS _______________________________________________

bESCAPE := { || empty(cACAO) .or. (XNIVEL==1 .and. !XFLAG) }
sBLOCO1 := qlbloc("B202B","QBLOC.GLO") // acao a ser executada
sBLOCO2 := qlbloc("B202C","QBLOC.GLO") // categoria

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cACAO,sBLOCO1)          },"ACAO"})
aadd(aEDICAO,{{ || view_event(-1,0,@cEVENTO)           },"EVENTO"})
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do evento
aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR,"@E 999,999.99") },"VALOR"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nFRACAO,"@E 999.9999")  },"FRACAO"})
aadd(aEDICAO,{{ || qesco(-1,0,@cFIXA,XSN)              },"FIXA"})
aadd(aEDICAO,{{ || qesco(-1,0,@cCATEGO,sBLOCO2)        },"CATEGO"})
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)          },"CENTRO"})
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)           },"FILIAL"})
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial
aadd(aEDICAO,{{ || view_cargo(-1,0,@cCARGO)            },"CARGO"})
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do cargo
aadd(aEDICAO,{{ || view_cbo(-1,0,@cCBO)                },"CBO"})
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do cbo
aadd(aEDICAO,{{ || view_sind(-1,0,@cSINDICAT)          },"SINDICAT"})
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do sindicato
aadd(aEDICAO,{{ || view_form(-1,0,@cFORMULA)           },"FORMULA"})
aadd(aEDICAO,{{ || NIL },NIL}) // descricao da formula
aadd(aEDICAO,{{ || lCONF := qconf("Confirma o processamento ?") },NIL})

// PRIMEIRO LOOP ____________________________________________________________

qmensa()

do while .T.

   // INICIALIZACAO DA ENTRADA DE DADOS _____________________________________

   i_crit_s("EVENTO")
   qsay(07,13,cAMBIENTE)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; return ; endif
      if XFLAG
         if ! i_crit_d( aEDICAO[XNIVEL,2] ) ; loop ; endif
      else
         if ! i_crit_s( aEDICAO[XNIVEL,2] )  ; loop ; endif
      endif
      if ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // CONFIRMACAO ___________________________________________________________

   if lCONF
      i_processa()
      LANC->(dbunlock())
      LANC->(dbgoto(recno()))
   endif

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_crit_d ( cCAMPO )
   do case
      case cCAMPO == "ACAO"
           qrsay ( XNIVEL , qabrev(cACAO,"IE",{"Inclus„o de Evento para um grupo de Funcionarios","Exclus„o de Evento de um grupo de Funcionarios"}))
      case cCAMPO == "EVENTO"
           if ! EVENT->(dbseek(cEVENTO))
              qmensa("Evento n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1 , EVENT->Descricao)
           if cACAO =="E"
              XNIVEL+=4
           endif
      case cCAMPO == "CATEGO"
           qrsay(XNIVEL , qabrev(cCATEGO,"T123456789",{"Todos","Mensal","Quinzenal","Semanal","Diario","Horario","Tarefa","Comissao","Honorario","Estagiario"}))
      case cCAMPO == "CENTRO"
           if ! empty(cCENTRO)
              if empty(right(cCENTRO,4))
                 qmensa("Centro de Custo n„o Anal¡tico !!","B")
                 return .F.
              endif
              if ! CCUSTO->(dbseek(cCENTRO))
                 qmensa("Centro de Custo n„o Cadastrado !!","B")
                 return .F.
              endif
           endif
           qrsay(XNIVEL+1,iif(CCUSTO->(dbseek(cCENTRO)),CCUSTO->Descricao,"*** Todos os Centros ***"))
      case cCAMPO == "FILIAL"
           if FILIAL->(dbseek(cFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,40))
           else
              qrsay(XNIVEL+1,"Todas as Filiais...")
           endif
      case cCAMPO == "CARGO"
           if CARGO->(dbseek(cCARGO))
              qrsay(XNIVEL+1,CARGO->Descricao)
           else
              qrsay(XNIVEL+1,"Todos os Cargos...")
           endif
      case cCAMPO == "SINDICAT"
           if SIND->(dbseek(cSINDICAT))
              qrsay(XNIVEL+1,SIND->Descricao)
           else
              qrsay(XNIVEL+1,"Todos os Sindicatos...")
           endif
      case cCAMPO == "CBO"
           if CBO->(dbseek(cCBO))
              qrsay(XNIVEL+1,CBO->Descricao)
           else
              qrsay(XNIVEL+1,"Todos os CBO's...")
           endif
      case cCAMPO == "FORMULA"
           if FORM->(dbseek(cFORMULA))
              qrsay(XNIVEL+1,FORM->Descricao)
           else
              qrsay(XNIVEL+1,"Sem f¢rmula especificada...")
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL DA SUBIDA ______________________________________________

static function i_crit_s ( cCAMPO )
   do case
      case cCAMPO == "EVENTO"
           qlbloc(5,0,"B202A","QBLOC.GLO")
           cACAO      := " "
           cCATEGO    := " "
           cEVENTO    := "   "
           cCENTRO    := space(8)
           cFILIAL    := space(4)
           cCARGO     := "      "
           cSINDICAT  := "    "
           cFORMULA   := "    "
           cCBO       := "       "
           nVALOR     := 0
           nFRACAO    := 0
           cFIXA      := "N"
           XNIVEL := 1
           XFLAG      := .T.
           return .F.
      case cCAMPO == "FIXA"
           if empty(cFIXA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cFIXA,"SN",{"SIM","NŽO"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INCLUIR/EXCLUIR EVENTOS ______________________________________

static function i_processa
   local nQUANT_PROC := 0
   local nQUANT_EFET := 0

   FUN->(dbgotop())

   if ! LANC->(qflock())
      qmensa("N„o foi possivel travar arquivo! Tente novamente...","B")
      return
   endif

   do while ! FUN->(eof())

      qmensa(FUN->Matricula+" / "+FUN->Nome)

      SITUA->(dbseek(FUN->Matricula))

      // FAZ FILTRO _________________________________________________________

      if FUN->Situacao == "H"                // HOMOLOGADO __________________
         FUN->(dbskip()) ; loop
      endif

      if cCATEGO <> "T"                      // CATEGORIA ___________________
         if SITUA->Categoria != cCATEGO
            FUN->(dbskip()) ; loop
         endif
      endif
      if ! empty(cCENTRO)                    // CENTRO DE CUSTO _____________
//       if FUN->Centro != cCENTRO
         if SITUA->Ccusto != cCENTRO
            FUN->(dbskip()) ; loop
         endif
      endif
      if ! empty(cFILIAL)                    // FILIAL ______________________
         if FUN->Filial != cFILIAL
            FUN->(dbskip()) ; loop
         endif
      endif
      if ! empty(cCARGO)                     // CARGO _______________________
         if SITUA->Cargo != cCARGO
            FUN->(dbskip()) ; loop
         endif
      endif
      if ! empty(cSINDICAT)                  // SINDICATO ___________________
         if FUN->Sind_cod != cSINDICAT
            FUN->(dbskip()) ; loop
         endif
      endif
      if ! empty(cCBO)                       // CBO _________________________
         if SITUA->Cbo != cCBO
            FUN->(dbskip()) ; loop
         endif
      endif
      if ! empty(cFORMULA)                   // FORMULA _____________________
         if ! seval(FORM->Formula)
            FUN->(dbskip()) ; loop
         endif
      endif
      if cAMBIENTE $ SITUA->Trav .or. cAMBIENTE $ SITUA->Bloq //TRAVADO/BLOQUEADO
         FUN->(dbskip()) ; loop
      endif
      if FUN->Data_Adm > qfimmes(XDATASYS)
         FUN->(dbskip()) ; loop
      endif

      // INCLUIR OU EXCLUIR _________________________________________________

      LANC->(dbseek(XANOMES+FUN->Matricula+cAMBIENTE+cEVENTO))

      if cACAO == "I"
         nQUANT_PROC++
         if LANC->(eof())
            nQUANT_EFET++
            LANC->(dbappend())
            replace LANC->Anomes    with XANOMES
            replace LANC->Matricula with FUN->Matricula
            replace LANC->Ambiente  with cAMBIENTE
            replace LANC->Evento    with cEVENTO
            replace LANC->Valor     with nVALOR
            replace LANC->Fracao    with nFRACAO
            replace LANC->Fixa      with iif(cFIXA=="S",.T.,.F.)
         endif
      else
         nQUANT_PROC++
         if ! LANC->(eof())
            nQUANT_EFET++
            LANC->(dbdelete())
         endif
      endif

      FUN->(dbskip())

   enddo

   nQUANT_PROC := "Quantidade de registros processados... " + strzero(nQUANT_PROC,5)
   nQUANT_EFET := ";Quantidade de altera‡”es efetuadas.... " + strzero(nQUANT_EFET,5)

   qmensa()
   alert(nQUANT_PROC+nQUANT_EFET,{"OK"})

return

