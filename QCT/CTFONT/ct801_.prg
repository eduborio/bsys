/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:
function ct801

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO      := {}
local lCONF        := .F.
local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                    (!empty(cEXERCICIO) .and. XNIVEL==1 .and. !XFLAG .or. !empty(cEXERCICIO) .and. XNIVEL==1 .and. Lastkey()==27) .or.;
                    (XNIVEL==1.and.lastkey()==27)}

//private bESCAPE    := { || XNIVEL == 1 .and. !XFLAG }
private cEXERCICIO := CONFIG->Exercicio
private cCT_DEV    := CONFIG->Ct_dev
private cCTALUCR   := CONFIG->Ctalucro
private cCTAPREJ   := CONFIG->Ctapreju
private cCTALUPR   := CONFIG->Ctalupr
private cCTAPRACUM := CONFIG->Ctapracum
private cPARTIDA   := CONFIG->Partida
private cLANCFILIAL:= CONFIG->Lancfilial
private cLANCCENT  := CONFIG->Lanccent
private cINTER_FISC := CONFIG->Inter_fisc
private nNIVEL

qmensa("ESC - Cancela...")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cEXERCICIO            )},"EXERCICIO"})
//aadd(aEDICAO,{{ || qgetx(-1,0,@cCT_DEV               )},"CT_DEV"   })
aadd(aEDICAO,{{ || view_plredu(-1,0,@cCTALUCR,"99999-9")},"CTALUCR"  })
aadd(aEDICAO,{{ || view_plredu(-1,0,@cCTAPREJ,"99999-9")},"CTAPREJ"  })
aadd(aEDICAO,{{ || view_plredu(-1,0,@cCTALUPR,"99999-9")},"CTALUPR"  })
aadd(aEDICAO,{{ || view_plredu(-1,0,@cCTAPRACUM,"99999-9")},"CTAPRACUM"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cPARTIDA ,XSN           )},"PARTIDA"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cLANCCENT,XSN           )},"LANCCENT" })
aadd(aEDICAO,{{ || qesco(-1,0,@cLANCFILIAL,XSN           )},"LANCFILIAL"})
aadd(aEDICAO,{{ || qesco(-1,0,@cINTER_FISC,XSN       )},"INTER_FISC" })
aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?")},"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

qlbloc(05,00,"B801A","QBLOC.GLO",1)

PLAN->(dbsetorder(3))

XNIVEL := 1
XFLAG  := .T.

qrsay(XNIVEL++,CONFIG->Exercicio)
//qrsay(XNIVEL++,CONFIG->Ct_dev)
qrsay(XNIVEL++,transform(CONFIG->Ctalucro  ,"@R 99999-9"))
qrsay(XNIVEL++,transform(CONFIG->Ctapreju  ,"@R 99999-9"))
qrsay(XNIVEL++,transform(CONFIG->Ctalupr   ,"@R 99999-9"))
qrsay(XNIVEL++,transform(CONFIG->Ctapracum ,"@R 99999-9"))
qrsay(XNIVEL++,qabrev(CONFIG->Partida,"SN" ,{"Sim","N„o"}))
qrsay(XNIVEL++,qabrev(CONFIG->Lanccent,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++,qabrev(CONFIG->Lancfilial,"SN",{"Sim","N„o"}))
qrsay(XNIVEL++,qabrev(CONFIG->Inter_fisc,"SN",{"Sim","N„o"}))

XNIVEL := 1

// LOOP PARA ENTRADA DOS DADOS ______________________________________________

do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
   eval ( aEDICAO [XNIVEL,1] )
   if eval ( bESCAPE ) ; return ; endif
   if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
   iif ( XFLAG , XNIVEL++ , XNIVEL-- )
enddo

// GRAVACAO _________________________________________________________________

if lCONF
   if CONFIG->(qrlock())
      replace CONFIG->Exercicio  with cEXERCICIO
//    replace CONFIG->Ct_dev     with cCT_DEV
      replace CONFIG->Ctalucro   with cCTALUCR
      replace CONFIG->Ctapreju   with cCTAPREJ
      replace CONFIG->Ctalupr    with cCTALUPR
      replace CONFIG->Ctapracum  with cCTAPRACUM
      replace CONFIG->Partida    with cPARTIDA
      replace CONFIG->Lanccent   with cLANCCENT
      replace CONFIG->Lancfilial with cLANCFILIAL
      replace CONFIG->Inter_fisc with cINTER_FISC
      CONFIG->(qunlock())
   else
      qmensa("Nao foi possivel alterar a configura‡„o, tente novamente","B")
   endif
endif
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "TIPO_MAT"
           if empty(cEXERCICIO) ; return .F. ; endif
      case cCAMPO == "CTALUCR"
           if ! empty(cCTALUCR)
              cCTALUCR := strzero(val(cCTALUCR),6)
              qrsay(XNIVEL,cCTALUCR,"@R 99999-9")
              if PLAN->(dbseek(qtiraponto(cCTALUCR)))
                 i_nivelcta()
                 if nNIVEL != 5
                    qmensa("Conta n„o ‚ anal¡tica !","B")
                    return .F.
                 endif
              else
                 qmensa("Conta n„o encontrada !","B")
                 return .F.
              endif
           endif
      case cCAMPO == "CTAPREJ"
           if ! empty(cCTAPREJ)
              cCTAPREJ := strzero(val(cCTAPREJ),6)
              qrsay(XNIVEL,cCTAPREJ,"@R 99999-9")
              if PLAN->(dbseek(qtiraponto(cCTAPREJ)))
                 i_nivelcta()
                 if nNIVEL != 5
                    qmensa("Conta n„o ‚ anal¡tica !","B")
                    return .F.
                 endif
              else
                 qmensa("Conta n„o encontrada !","B")
                 return .F.
              endif
           endif
      case cCAMPO == "CTALUPR"
           if ! empty(cCTALUPR)
              cCTALUPR := strzero(val(cCTALUPR),6)
              qrsay(XNIVEL,cCTALUPR,"@R 99999-9")
              if PLAN->(dbseek(qtiraponto(cCTALUPR)))
                 i_nivelcta()
                 if nNIVEL != 5
                    qmensa("Conta n„o ‚ anal¡tica !","B")
                    return .F.
                 endif
              else
                 qmensa("Conta n„o encontrada !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "CTAPRACUM"
           if ! empty(cCTAPRACUM)
              cCTAPRACUM := strzero(val(cCTAPRACUM),6)
              qrsay(XNIVEL,cCTAPRACUM,"@R 99999-9")
              if PLAN->(dbseek(qtiraponto(cCTAPRACUM)))
                 i_nivelcta()
                 if nNIVEL != 5
                    qmensa("Conta n„o ‚ anal¡tica !","B")
                    return .F.
                 endif
              else
                 qmensa("Conta n„o encontrada !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "PARTIDA"
           qrsay(XNIVEL,qabrev(cPARTIDA,"SN",{"Sim","N„o"}))
      case cCAMPO == "LANCCENT"
           qrsay(XNIVEL,qabrev(cLANCCENT,"SN",{"Sim","N„o"}))
      case cCAMPO == "LANCFILIAL"
           qrsay(XNIVEL,qabrev(cLANCFILIAL,"SN",{"Sim","N„o"}))
      case cCAMPO == "INTER_FISC"
           qrsay(XNIVEL,qabrev(cINTER_FISC,"SN",{"Sim","N„o"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// VERIFICA NIVEL DE CONTA __________________________________________________

static function i_nivelcta
       local nCONT

       for nCONT = 11 to 1 step -1
           if subs(PLAN->Codigo,nCONT,1) != "0"
              do case
                 case nCONT = 1
                      nNIVEL :=  1
                 case nCONT = 2
                      nNIVEL :=  2
                 case nCONT < 5
                      nNIVEL :=  3
                 case nCONT < 8
                      nNIVEL :=  4
                 case nCONT < 12
                      nNIVEL :=  5
              endcase
              exit
           endif
       next
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS RETORNANDO CODIGO REDUZIDO ______________

static function view_plredu (XX,YY,ZZ)
   PLAN->(dbSetFilter({|| right(PLAN->Codigo,4) <> "0000"}, 'right(PLAN->Codigo,4) <> "0000"'))

   PLAN->(qview(XX,YY,@ZZ,"@K@R 99999-9",NIL,.T.,NIL,;
         {{"ct_convcod(Codigo)/C¢digo"     ,1},;
          {"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Reduzido)/Cod.Red." ,3}},;
          "C",{"keyb(Reduzido)",NIL,NIL,NIL}))

   PLAN->(dbClearFilter())
return

