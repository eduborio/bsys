/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELACAO DE RECIBOS DE PAGAMENTO A AUTONOMOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 2002
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. Lastkey()==27) }

private sBLOCO1 := qlbloc("B530A","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B530B","QBLOC.GLO") // bloco basico

private cTIPOREL               // tipo de relatorio (mensal ou 13o.)
private cTITULO                // titulo do contra-cheque
private cMATRICULA             // matricula p/ impressao individual
private bFILTRO                // code block de filtro (centro/filial/grupo)
private aEDICAO := {}          // vetor para os campos de entrada de dados
private nEV641
private nEV642

private nEV643
private nEV644
private nEV645
private nEV646
private nEV647
private nEV648
private nEV447
private nTETO

private nEV741
private nEV742

private nEV653
private nEV654
private nEV655
private nEV656
private nEV657
private nEV678
private nEV749
private nEV719
private nEV729
private nEV718
private nEV730

private nCONT
private nBASE
private nPERC
private nIR
private nTOTIR
private nTOTBASE
private nTOTLIQ
private nTOTDESC
private nTOTINSS
private nTOTPERC
private nTOTSERV
private nDED
private nSERV
private nSERV2
private nDESC
private nLIQ
private nIRRF





SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL,sBLOCO2) }   , "TIPOREL"   })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario

do while .T.

   qlbloc(5,0,"B530A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   nEV641     := 0
   nEV642     := 0

   nTETO      := 0
   nEV643     := 0
   nEV447     := 0
   nEV644     := 0
   nEV645     := 0
   nEV646     := 0
   nEV647     := 0
   nEV648     := 0

   nEV653     := 0
   nEV654     := 0
   nEV655     := 0
   nEV656     := 0
   nEV657     := 0
   nEV678     := 0
   nEV749     := 0
   nEV718     := 0
   nEV729     := 0
   nEV730     := 0

   nEV741     := 0
   nEV742     := 0
   nCONT      := 0
   nBASE      := 0
   nPERC      := 0
   nIR        := 0
   nTOTIR     := 0
   nTOTBASE   := 0
   nTOTLIQ    := 0
   nTOTDESC   := 0
   nTOTINSS   := 0
   nTOTPERC   := 0
   nTOTSERV   := 0
   nTOTAL     := 0
   nDED       := 0
   nSERV      := 0
   nSERV2      := 0
   nDESC      := 0
   nLIQ       := 0
   nIRRF      := 0
   cTIPOREL   := " "

   qmensa()

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "MATRICULA"
           if ! empty(cMATRICULA) 
              qrsay(XNIVEL,cMATRICULA:=strzero(val(cMATRICULA),6))
           endif
           qrsay(XNIVEL+1,iif(FUN->(dbseek(cMATRICULA)),left(FUN->Nome,30),"*** Todos os Funcion rios ***"))
      case cCAMPO == "TIPOREL"
           if empty(cTIPOREL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOREL,"MD123456GAB",{"Mˆs Corrente","D‚cimo Terceiro","1 Semana","2 Semana","3 Semana","4 Semana","5 Semana","6 Semana","Grande Premio","13 1 PARCELA","13 2 PARCELA"}))

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTITULO = "RELACA DE RECIBOS DE PAGAMENTO A AUTONOMO"


   cTITULO += " - " + upper(qnomemes(month(XDATASYS))) + "/" + str(year(XDATASYS),4)

   // SELECIONA ORDEM DO ARQUIVO FUN _____________________________________

   FUN->(dbsetorder(01))

   qmensa()

   // CRIA MACRO DE FILTRO __________________________________________________


   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   SITUA->(dbsetrelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))

   SITUA->(dbsetrelation("LANC",{|| XANOMES+Matricula},"XANOMES+Matricula"))

   LANC->(dbsetrelation("EVENT",{|| Evento},"Evento"))

   FUN->(dbsetrelation("FILIAL",{|| Filial},"Filial"))

   FUN->(dbgotop())
   LANC->(dbsetorder(03))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
       do case
          case cTIPOREL == "M"
                  i_auto()

          case cTIPOREL == "1"
               i_1auto()

          case cTIPOREL == "2"
               i_2auto()

          case cTIPOREL == "3"
               i_3auto()

          case cTIPOREL == "4"
               i_4auto()

          case cTIPOREL == "5"
               i_5auto()

          case cTIPOREL == "6"
               i_6auto()

          case cTIPOREL == "G"
               i_gpauto()

          case cTIPOREL == "A"
               i_dt1auto()

          case cTIPOREL == "B"
               i_dt2auto()

         endcase
return

function i_auto
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"643"))
   nEV643 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"653"))
   nEV653 := LANC->Valor

   do case
      case  nEV643 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV643 > 1058 .and. nEV643 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV643 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV643 * 0.11
   iif(nINSS>275.75,nINSS:=275.75,nINSS)
   nIR   := ( (nEV643-nINSS) * (nPERC/100)) - nDED
   iif(nIR <= 0 ,nIR := 0,nIR)
   nBASE := (nEV643-nINSS) - (nIR + nEV653)


   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome
   if nEV643 <> 0
       @ prow()+1,00 say "01" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV643,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV653+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(iif(nEV643>1561.56,1561.56,nEV643),"@E 999,999.99")
       @ prow()  ,119 say transf(nEV643-nINSS,"@E 999,999.99")
       nTOTSERV += nEV643
       nTOTDESC += nEV653
       nTOTINSS += nINSS
   endif
   nINSS := 0
   LANC->(dbseek(FUN->Matricula + XANOMES+"644"))
   nEV644:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"654"))
   nEV654 := LANC->Valor

   do case
      case  nEV644 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV644 > 1058 .and. nEV644 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV644 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase

   nINSS := nEV644 * 0.11
   iif(nINSS>275.75,nINSS:=275.75,nINSS)
   nIR   := ((nEV644-nINSS) * (nPERC/100)) - nDED
   iif(nIR <= 0 , nIR := 0,nIR)

   nBASE := nEV644 - (nIR + nEV654 + nINSS)
   if nEV644 <> 0
       @ prow()+1,00 say "02" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV644,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV654+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV644,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV644-nINSS,"@E 999,999.99")
       nTOTSERV += nEV644
       nTOTDESC += nEV654
       nTOTINSS += nINSS
   endif
   nINSS := 0
   LANC->(dbseek(FUN->Matricula + XANOMES+"645"))
   nEV645:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"655"))
   nEV655 := LANC->Valor

   do case
      case  nEV645 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV645 > 1058 .and. nEV644 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV645 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase

   nINSS := nEV645 * 0.11
   iif(nINSS>275.75,nINSS:=275.75,nINSS)
   nIR   := ((nEV645-nINSS) * (nPERC/100)) - nDED
   iif(nIR <= 0,nIR := 0,nIR)
   nBASE := nEV645 - (nIR + nEV655 + nINSS)
   if nEV645 <> 0
       @ prow()+1,00 say "03" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV645,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV655+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV645,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV645-nINSS,"@E 999,999.99")
       nTOTSERV += nEV645
       nTOTDESC += nEV655
       nTOTINSS += nINSS

   endif
   nINSS := 0
   LANC->(dbseek(FUN->Matricula + XANOMES+"646"))
   nEV646:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"656"))
   nEV656 := LANC->Valor

   do case
      case  nEV646 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV646 > 1058 .and. nEV644 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV646 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase

   nINSS := nEV646 * 0.11
   iif(nINSS>275.75,nINSS:=275.75,nINSS)
   nIR   := ((nEV646+nINSS) * (nPERC/100)) - nDED
   iif(nIR <= 0,nIR := 0,nIR)
   nBASE := nEV646 - (nIR + nEV656+nINSS)

   if nEV646 <> 0
       @ prow()+1,00 say "04" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV646,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV656+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV646,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV646-nINSS,"@E 999,999.99")
       nTOTSERV += nEV646
       nTOTDESC += nEV656
       nTOTINSS += nINSS

   endif
   nINSS := 0
   LANC->(dbseek(FUN->Matricula + XANOMES+"647"))
   nEV647:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"657"))
   nEV657 := LANC->Valor

   do case
      case  nEV647 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV647 > 1058 .and. nEV644 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV647 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV647 * 0.11
   iif(nINSS>275.75,nINSS:=275.75,nINSS)
   nIR   := ((nEV647-nINSS) * (nPERC/100)) - nDED
   iif(nIR<=0,nIR := 0, nIR)
   nBASE := nEV647 - (nIR + nEV657 + nINSS)
   if nEV647 <> 0
       @ prow()+1,00 say "05" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV647,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV657+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV647,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV647-nINSS,"@E 999,999.99")
       nTOTSERV += nEV647
       nTOTDESC += nEV657
       nTOTINSS += nINSS

   endif
   nINSS := 0
   LANC->(dbseek(FUN->Matricula + XANOMES+"648"))
   nEV648:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"678"))
   nEV678 := LANC->Valor

   do case
      case  nEV648 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV648 > 1058 .and. nEV648 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV648 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV648 * 0.11
   iif(nINSS>275.75,nINSS:=275.75,nINSS)
   nIR   := ((nEV648-nINSS) * (nPERC/100)) - nDED
   iif(nIR<=0,nIR := 0, nIR)
   nBASE := nEV648 - (nIR + nEV678+nINSS)
   if nEV648 <> 0
       @ prow()+1,00 say "06" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV648,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV678+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV648,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV648-nINSS,"@E 999,999.99")
       nTOTSERV += nEV648
       nTOTDESC += nEV678
       nTOTINSS += nINSS

   endif

   nPERC := 0

   do case
      case  nTOTSERV <= 1058
            nPERC := 0
            nDED  := 0
      case  nTOTSERV > 1058 .and. nTOTSERV <= 2115
            nPERC := 15
            nDED := 158.70
      case  nTOTSERV > 2115
            nPERC := 27.5
            nDED :=  423.08
   endcase

   nTOTIR := (nTOTSERV - nTOTINSS) * (nPERC/100)
   nTOTIR := nTOTIR - nDED
   iif(nTOTIR <= 0 , nTOTIR := 0,nTOTIR)
   nTOTLIQ := nTOTSERV - (nTOTDESC + nTOTIR + nTOTINSS)
   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,40 say transf(nTOTIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nTOTDESC+nTOTINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nTOTLIQ ,"@E 999,999.99")
       @ prow()  ,103 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,119 say transf(nTOTSERV-nTOTINSS,"@E 999,999.99")
       nSERV2 += nTOTINSS
       nSERV += nTOTSERV
       nLIQ  += nTOTLIQ
       nIRRF += nTOTIR
       nDESC += nTOTDESC + nTOTINSS
   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV657 := 0
   nIR    := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ  := 0
   nTOTIR   := 0
   nDED     := 0
   nTOTINSS := 0

enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,119 say transf(nSERV-nSERV2,"@E 999,999.99")
endif

nSERV := 0
nDESC := 0
nLIQ  := 0
nIRRF := 0

qstopprn()
return

function i_1auto
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"643"))
      FUN->(dbskip())
      loop
   endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"643"))
   nEV643 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"653"))
   nEV653 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"447"))
   nEV447 := LANC->Valor


   do case
      case  nEV643 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV643 > 1058 .and. nEV643 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV643 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV643 * 0.11
   nTETO := 275.75
   nTETO := nTETO -(nEV447 * 0.11)
   iif(nINSS >= nTETO, nINSS := nTETO,nINSS)
   iif(nINSS < 0,nINSS := 0,nINSS)

   nIR   := ((nEV643-nINSS) * (nPERC/100)) - nDED
   iif(nIR<=0,nIR := 0,nIR)
   nBASE := (nEV643-nINSS) - (nIR + nEV653)


   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome
   if nEV643 <> 0
       @ prow()+1,00 say "01" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV643,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV653+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV643,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV643-nINSS,"@E 999,999.99")
       nTOTSERV += nEV643
       nTOTDESC += nEV653
       nTOTINSS += nINSS
   endif
   nPERC := 0

   do case
      case  nTOTSERV <= 1058
            nPERC := 0
            nDED  := 0
      case  nTOTSERV > 1058 .and. nTOTSERV <= 2115
            nPERC := 15
            nDED := 158.70
      case  nTOTSERV > 2115
            nPERC := 27.5
            nDED :=  423.08
   endcase

   nTOTIR := (nTOTSERV-nINSS) * (nPERC/100)
   nTOTIR := nTOTIR - nDED
   nTOTLIQ := nTOTSERV - (nTOTDESC + nTOTIR + nINSS)
   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,40 say transf(nTOTIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nTOTDESC+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nTOTLIQ ,"@E 999,999.99")
       @ prow()  ,103 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,119 say transf(nTOTSERV-nINSS,"@E 999,999.99")
       nSERV += nTOTSERV
       nLIQ  += nTOTLIQ
       nIRRF += nTOTIR
       nDESC += nTOTDESC + nINSS

   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV657 := 0
   nIR    := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ := 0
   nTOTIR  := 0
   nDED    := 0
   nINSS   := 0

enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,119 say transf(nSERV-nTOTINSS,"@E 999,999.99")
endif

nSERV    := 0
nDESC    := 0
nLIQ     := 0
nIRRF    := 0
nTOTINSS := 0

qstopprn()
return

function i_2auto
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"644"))
      FUN->(dbskip())
      loop
   endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   LANC->(dbseek(FUN->Matricula + XANOMES+"644"))
   nEV644:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"654"))
   nEV654 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"447"))
   nEV447 := LANC->Valor

   do case
      case  nEV644 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV644 > 1058 .and. nEV644 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV644 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV644 * 0.11

   nTETO := 275.75
   nTETO := nTETO -(nEV447 * 0.11)
   iif(nINSS >= nTETO, nINSS := nTETO,nINSS)
   iif(nINSS < 0,nINSS := 0,nINSS)
   nIR   := ((nEV644-nINSS) * (nPERC/100)) - nDED
   iif(nIR <= 0,nIR := 0,nIR)
   nBASE := nEV644 - (nIR + nEV654 + nINSS)
   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome

   if nEV644 <> 0
       @ prow()+1,00 say "02" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV644,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV654+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV644,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV644-nINSS,"@E 999,999.99")
       nTOTSERV += nEV644
       nTOTDESC += nEV654
       nTOTINSS += nINSS

   endif

   nPERC := 0

   do case
      case  nTOTSERV <= 1058
            nPERC := 0
            nDED  := 0
      case  nTOTSERV > 1058 .and. nTOTSERV <= 2115
            nPERC := 15
            nDED := 158.70
      case  nTOTSERV > 2115
            nPERC := 27.5
            nDED :=  423.08
   endcase

   nTOTIR := nTOTSERV * (nPERC/100)
   nTOTIR := nTOTIR - nDED
   nTOTLIQ := nTOTSERV - (nTOTDESC + nTOTIR + nINSS)
   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,40 say transf(nTOTIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nTOTDESC+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nTOTLIQ ,"@E 999,999.99")
       @ prow()  ,103 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,119 say transf(nTOTSERV-nINSS,"@E 999,999.99")
       nSERV += nTOTSERV
       nLIQ  += nTOTLIQ
       nIRRF += nTOTIR
       nDESC += nTOTDESC + nINSS
   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV657 := 0
   nIR    := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ := 0
   nTOTIR  := 0
   nDED    := 0
   nINSS    := 0
enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,119 say transf(nSERV-nTOTINSS,"@E 999,999.99")
endif

nSERV := 0
nDESC := 0
nLIQ  := 0
nIRRF := 0
nTOTINSS := 0
qstopprn()
return

function i_3auto
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif
   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"645"))
      FUN->(dbskip())
      loop
   endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome

   LANC->(dbseek(FUN->Matricula + XANOMES+"645"))
   nEV645:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"655"))
   nEV655 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"447"))
   nEV447 := LANC->Valor

   do case
      case  nEV645 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV645 > 1058 .and. nEV644 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV645 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV645 * 0.11
   nTETO := 275.75
   nTETO := nTETO -(nEV447 * 0.11)
   iif(nINSS >= nTETO, nINSS := nTETO,nINSS)
   iif(nINSS < 0,nINSS := 0,nINSS)
   nIR   := ((nEV645-nINSS) * (nPERC/100)) - nDED
   iif(nIR<= 0,nIR:=0,nIR)
   nBASE := nEV645 - (nIR + nEV655 + nINSS)
   if nEV645 <> 0
       @ prow()+1,00 say "03" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV645,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV655+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV645,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV645-nINSS,"@E 999,999.99")
       nTOTSERV += nEV645
       nTOTDESC += nEV655
       nTOTINSS += nINSS

   endif

   nPERC := 0

   do case
      case  nTOTSERV <= 1058
            nPERC := 0
            nDED  := 0
      case  nTOTSERV > 1058 .and. nTOTSERV <= 2115
            nPERC := 15
            nDED := 158.70
      case  nTOTSERV > 2115
            nPERC := 27.5
            nDED :=  423.08
   endcase

   nTOTIR := (nTOTSERV-nINSS) * (nPERC/100)
   nTOTIR := nTOTIR - nDED
   nTOTLIQ := nTOTSERV - (nTOTDESC + nTOTIR + nINSS)
   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,40 say transf(nTOTIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nTOTDESC+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nTOTLIQ ,"@E 999,999.99")
       @ prow()  ,103 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,119 say transf(nTOTSERV-nINSS,"@E 999,999.99")
       nSERV += nTOTSERV
       nLIQ  += nTOTLIQ
       nIRRF += nTOTIR
       nDESC += nTOTDESC+nINSS
   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV657 := 0
   nIR    := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ := 0
   nTOTIR  := 0
   nDED    := 0
   nINSS   := 0

enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,119 say transf(nSERV-nTOTINSS,"@E 999,999.99")
endif

nSERV := 0
nDESC := 0
nLIQ  := 0
nIRRF := 0
nTOTINSS := 0

qstopprn()
return

function i_4auto
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"646"))
      FUN->(dbskip())
      loop
   endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome
   LANC->(dbseek(FUN->Matricula + XANOMES+"646"))
   nEV646:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"656"))
   nEV656 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"447"))
   nEV447 := LANC->Valor

   do case
      case  nEV646 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV646 > 1058 .and. nEV644 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV646 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV646 * 0.11
   nTETO := 275.75
   nTETO := nTETO -(nEV447 * 0.11)
   iif(nINSS >= nTETO, nINSS := nTETO,nINSS)
   iif(nINSS < 0,nINSS := 0,nINSS)

   nIR   := ((nEV646-nINSS) * (nPERC/100)) - nDED
   iif(nIR<=0,nIR:=0,nIR)
   nBASE := nEV646 - (nIR + nEV656+ nINSS)
   if nEV646 <> 0
       @ prow()+1,00 say "04" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV646,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV656+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV646,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV646-nINSS,"@E 999,999.99")
       nTOTSERV += nEV646
       nTOTDESC += nEV656
       nTOTINSS += nINSS
   endif

   nPERC := 0

   do case
      case  nTOTSERV <= 1058
            nPERC := 0
            nDED  := 0
      case  nTOTSERV > 1058 .and. nTOTSERV <= 2115
            nPERC := 15
            nDED := 158.70
      case  nTOTSERV > 2115
            nPERC := 27.5
            nDED :=  423.08
   endcase

   nTOTIR := (nTOTSERV-nINSS) * (nPERC/100)
   nTOTIR := nTOTIR - nDED
   nTOTLIQ := nTOTSERV - (nTOTDESC + nTOTIR + nINSS)
   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,40 say transf(nTOTIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nTOTDESC+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nTOTLIQ ,"@E 999,999.99")
       @ prow()  ,103 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,119 say transf(nTOTSERV-nINSS,"@E 999,999.99")
       nSERV += nTOTSERV
       nLIQ  += nTOTLIQ
       nIRRF += nTOTIR
       nDESC += nTOTDESC + nINSS
   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV657 := 0
   nIR    := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ := 0
   nTOTIR  := 0
   nDED    := 0
   nINSS   := 0
enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,119 say transf(nSERV-nTOTINSS,"@E 999,999.99")
endif

nSERV := 0
nDESC := 0
nLIQ  := 0
nIRRF := 0
nTOTINSS := 0
qstopprn()
return

function i_5auto
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"647"))
      FUN->(dbskip())
      loop
    endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   LANC->(dbseek(FUN->Matricula + XANOMES+"647"))
   nEV647:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"657"))
   nEV657 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"447"))
   nEV447 := LANC->Valor

   do case
      case  nEV647 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV647 > 1058 .and. nEV644 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV647 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV647 * 0.11

   nTETO := 275.75
   nTETO := nTETO -(nEV447 * 0.11)
   iif(nINSS >= nTETO, nINSS := nTETO,nINSS)
   iif(nINSS < 0,nINSS := 0,nINSS)
   nIR   := ((nEV647-nINSS) * (nPERC/100)) - nDED
   iif(nIR<=0,nIR := 0, nIR)
   nBASE := nEV647 - (nIR + nEV657+nINSS)
   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome

   if nEV647 <> 0
       @ prow()+1,00 say "05" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV647,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV657+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV647,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV647-nINSS,"@E 999,999.99")
       nTOTSERV += nEV647
       nTOTDESC += nEV657
       nTOTINSS += nINSS

   endif
   nPERC := 0

   do case
      case  nTOTSERV <= 1058
            nPERC := 0
            nDED  := 0
      case  nTOTSERV > 1058 .and. nTOTSERV <= 2115
            nPERC := 15
            nDED := 158.70
      case  nTOTSERV > 2115
            nPERC := 27.5
            nDED :=  423.08
   endcase

   nTOTIR := (nTOTSERV-nINSS) * (nPERC/100)
   nTOTIR := nTOTIR - nDED
   nTOTLIQ := nTOTSERV - (nTOTDESC + nTOTIR + nINSS)
   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,40 say transf(nTOTIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nTOTDESC+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nTOTLIQ ,"@E 999,999.99")
       @ prow()  ,103 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,119 say transf(nTOTSERV-nINSS,"@E 999,999.99")
       nSERV += nTOTSERV
       nLIQ  += nTOTLIQ
       nIRRF += nTOTIR
       nDESC += nTOTDESC + nINSS
   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV657 := 0
   nIR    := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ := 0
   nTOTIR  := 0
   nDED    := 0
   nINSS   := 0
enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,119 say transf(nSERV-nTOTINSS,"@E 999,999.99")
endif

nSERV := 0
nDESC := 0
nLIQ  := 0
nIRRF := 0
nTOTINSS := 0
qstopprn()
return

function i_6auto
local nDESC_730 := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"648"))
      FUN->(dbskip())
      loop
    endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   LANC->(dbseek(FUN->Matricula + XANOMES+"648"))
   nEV648:= LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"678"))
   nEV678 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"730"))
   nEV730 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"447"))
   nEV447 := LANC->Valor


   do case
      case  (nEV648+nEV730) <= 1058
            nPERC := 0
            nDED  := 0
      case  (nEV648+nEV730) > 1058 .and. (nEV648+nEV730) <= 2115
            nPERC := 15
            nDED  := 158.70
      case  (nEV648+nEV730) > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV648 * 0.11
   nTETO := 275.75
   nTETO := nTETO -(nEV447 * 0.11)
   iif(nINSS >= nTETO, nINSS := nTETO,nINSS)
   iif(nINSS < 0,nINSS := 0,nINSS)
   nIR   := (((nEV648+nEV730)-nINSS) * (nPERC/100)) - nDED
   iif(nIR<=0,nIR := 0, nIR)
   nBASE := (nEV648 - (nIR + nEV678+ nINSS)) + nEV730
   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome

   if nEV648 <> 0
       @ prow()+1,00 say "06" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV648+nEV730,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV678+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV648,"@E 999,999.99")
       @ prow()  ,119 say transf((nEV648+nEV730)-nINSS,"@E 999,999.99")
       nTOTSERV += (nEV648 + nEV730)
       nTOTDESC += nEV678
       nTOTINSS += nINSS

   endif
   nPERC := 0

   do case
      case  nTOTSERV <= 1058
            nPERC := 0
            nDED  := 0
      case  nTOTSERV > 1058 .and. nTOTSERV <= 2115
            nPERC := 15
            nDED := 158.70
      case  nTOTSERV > 2115
            nPERC := 27.5
            nDED :=  423.08
   endcase

   nTOTIR := (nTOTSERV-nINSS) * (nPERC/100)
   nTOTIR := nTOTIR - nDED
   nTOTLIQ := nTOTSERV - (nTOTDESC + nTOTIR + nINSS)
   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,40 say transf(nTOTIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nTOTDESC+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nTOTLIQ ,"@E 999,999.99")
       @ prow()  ,103 say transf(nTOTSERV-nEV730,"@E 999,999.99")
       @ prow()  ,119 say transf(nTOTSERV-nINSS,"@E 999,999.99")
       nSERV += nTOTSERV
       nLIQ  += nTOTLIQ
       nIRRF += nTOTIR
       nDESC += nTOTDESC + nINSS
       nDESC_730 += nEV730
   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV648 := 0
   nEV657 := 0
   nEV658 := 0
   nEV730 := 0
   nIR    := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ := 0
   nTOTIR  := 0
   nDED    := 0
   nINSS   := 0
enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV-nDESC_730,"@E 999,999.99")
    @ prow()  ,119 say transf(nSERV-nTOTINSS,"@E 999,999.99")
endif

nSERV := 0
nDESC := 0
nLIQ  := 0
nIRRF := 0
nTOTINSS := 0
nDESC_730 := 0
qstopprn()
return


function i_gpauto
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"749"))
      FUN->(dbskip())
      loop
    endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   LANC->(dbseek(FUN->Matricula + XANOMES+"749"))
   nEV749:= LANC->Valor
   do case
      case  nEV749 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV749 > 1058 .and. nEV749 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV749 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase

   nINSS := nEV749 * 0.11
   nTETO := 275.75
   nTETO := nTETO -(nEV749 * 0.11)
   iif(nINSS >= nTETO, nINSS := nTETO,nINSS)
   iif(nINSS < 0,nINSS := 0,nINSS)

   nIR   := ((nEV749-nINSS) * (nPERC/100)) - nDED
   iif(nIR<=0,nIR := 0,nIR)
   nBASE := (nEV749-nINSS) - (nIR)

   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome

   if nEV749 <> 0
       @ prow()+1,00 say "GP" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV749,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV678+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV749,"@E 999,999.99")
       @ prow()  ,119 say transf(nEV749-nINSS,"@E 999,999.99")
       nTOTSERV += nEV749
       nTOTDESC += nEV678 + nINSS
       nTOTINSS += nINSS


   endif
   nPERC := 0

   do case
      case  nTOTSERV <= 1058
            nPERC := 0
            nDED  := 0
      case  nTOTSERV > 1058 .and. nTOTSERV <= 2115
            nPERC := 15
            nDED := 158.70
      case  nTOTSERV > 2115
            nPERC := 27.5
            nDED :=  423.08
   endcase

   nTOTIR := nTOTSERV * (nPERC/100)
   nTOTIR := nTOTIR - nDED
   nTOTLIQ := nTOTSERV - (nTOTDESC + nTOTIR)
   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,40 say transf(nTOTIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nTOTDESC,"@E 999,999.99")
       @ prow()  ,85 say transf(nTOTLIQ ,"@E 999,999.99")
       @ prow()  ,103 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,119 say transf(nTOTSERV-nINSS,"@E 999,999.99")
       nSERV += nTOTSERV
       nLIQ  += nTOTLIQ
       nIRRF += nTOTIR
       nDESC += nTOTDESC
   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV648 := 0
   nEV657 := 0
   nEV658 := 0
   nEV749 := 0
   nEV718 := 0
   nEV719 := 0
   nEV729 := 0
   nIR    := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ := 0
   nTOTIR  := 0
   nDED    := 0

enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,119 say transf(nSERV-nDESC,"@E 999,999.99")
endif

nSERV := 0
nDESC := 0
nLIQ  := 0
nIRRF := 0

qstopprn()
return

function i_dt1auto
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"718"))
      FUN->(dbskip())
      loop
    endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   LANC->(dbseek(FUN->Matricula + XANOMES+"718"))
   nnEV718:= LANC->Valor
   do case
      case  nnEV718 <= 1058
            nPERC := 0
            nDED  := 0
      case  nnEV718 > 1058 .and. nnEV718 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nnEV718 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nIR   := (nnEV718 * (nPERC/100)) - nDED
   iif(nIR<=0,nIR := 0, nIR)
   nBASE := nnEV718 - nIR
   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome

   if nnEV718 <> 0
       @ prow()+1,00 say "DT" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nnEV718,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV678,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nnEV718,"@E 999,999.99")
       @ prow()  ,119 say transf(nnEV718,"@E 999,999.99")
       nTOTSERV += nnEV718

   endif
   nPERC := 0

   do case
      case  nTOTSERV <= 1058
            nPERC := 0
            nDED  := 0
      case  nTOTSERV > 1058 .and. nTOTSERV <= 2115
            nPERC := 15
            nDED := 158.70
      case  nTOTSERV > 2115
            nPERC := 27.5
            nDED :=  423.08
   endcase

   nTOTIR := nTOTSERV * (nPERC/100)
   nTOTIR := nTOTIR - nDED
   nTOTLIQ := nTOTSERV - (nTOTDESC + nTOTIR)
   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,40 say transf(nTOTIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nTOTDESC,"@E 999,999.99")
       @ prow()  ,85 say transf(nTOTLIQ ,"@E 999,999.99")
       @ prow()  ,103 say transf(nTOTSERV,"@E 999,999.99")
       @ prow()  ,119 say transf(nTOTSERV,"@E 999,999.99")
       nSERV += nTOTSERV
       nLIQ  += nTOTLIQ
       nIRRF += nTOTIR
       nDESC += nTOTDESC
   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV648 := 0
   nEV657 := 0
   nEV658 := 0
   nEV749 := 0
   nEV718 := 0
   nEV719 := 0
   nEV729 := 0
   nIR    := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ := 0
   nTOTIR  := 0
   nDED    := 0

enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,119 say transf(nSERV,"@E 999,999.99")
endif

nSERV := 0
nDESC := 0
nLIQ  := 0
nIRRF := 0

qstopprn()
return

function i_dt2auto
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()
   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow() , 0 say XCOND0
      qcabecprn(cTITULO,80)

      @ prow()+1,0 say XCOND1 + "NR                 VLR SERVICO           DESC IRRF           OUTROS DESC.           VLR LIQUIDO         BASE INSS       BASE IRRF"
      @ prow()+1,0 say XCOND0 + replicate("-",80)
   endif

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif

   if SITUA->Categoria == "7"
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"719"))
      FUN->(dbskip())
      loop
    endif

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"719"))
   nEV719 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"729"))
   nEV729 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"923"))
   nIR := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"913"))
   nINSS := LANC->Valor

   nBASE :=  BASE->Prov_dt - BASE->Desc_dt


   @ prow()+1,00 say XCOND1 + "AUTONOMO: " + FUN->Matricula +" - " + FUN->Nome

   if nEV719 <> 0
       @ prow()+1,00 say "DT" + right(XANOMES,2) + substr(XANOMES,3,2)
       @ prow()  ,20 say transf(nEV719,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV729+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV719,"@E 999,999.99")
       @ prow()  ,119 say transf(nBASE,"@E 999,999.99")
       nTOTSERV += nEV719

   endif

   if nTOTSERV <> 0
       @ prow()+1,00 say "TOTAL AUTONOMO: "
       @ prow()  ,20 say transf(nEV719,"@E 999,999.99")
       @ prow()  ,40 say transf(nIR   ,"@E 999,999.99")
       @ prow()  ,61 say transf(nEV729+nINSS,"@E 999,999.99")
       @ prow()  ,85 say transf(nBASE ,"@E 999,999.99")
       @ prow()  ,103 say transf(nEV719,"@E 999,999.99")
       @ prow()  ,119 say transf(nBASE,"@E 999,999.99")
       nSERV += nEV719
       nLIQ  += nBASE
       nIRRF += nIR
       nDESC += nEV729+nINSS
   endif
   @ prow()+1,0 say XCOND0 + replicate("-",80) + XCOND1

   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
   nBASE  := 0
   nEV643 := 0
   nEV653 := 0
   nEV644 := 0
   nEV654 := 0
   nEV645 := 0
   nEV655 := 0
   nEV646 := 0
   nEV656 := 0
   nEV647 := 0
   nEV648 := 0
   nEV657 := 0
   nEV658 := 0
   nEV749 := 0
   nEV718 := 0
   nEV719 := 0
   nEV729 := 0
   nIR    := 0
   nINSS  := 0
   nPERC  := 0
   nBASE  := 0
   nTOTSERV := 0
   nTOTDESC := 0
   nTOTLIQ := 0
   nTOTIR  := 0
   nDED    := 0

enddo
if nSERV <> 0
    @ prow()+1,00 say "TOTAL GERAL: "
    @ prow()  ,20 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,40 say transf(nIRRF   ,"@E 999,999.99")
    @ prow()  ,61 say transf(nDESC,"@E 999,999.99")
    @ prow()  ,85 say transf(nLIQ ,"@E 999,999.99")
    @ prow()  ,103 say transf(nSERV,"@E 999,999.99")
    @ prow()  ,119 say transf(nLIQ,"@E 999,999.99")
endif

nSERV := 0
nDESC := 0
nLIQ  := 0
nIRRF := 0

qstopprn()
return

