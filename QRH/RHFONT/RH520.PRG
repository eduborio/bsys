/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DE GUIA DE R.P.A. (INSS) - AUTONOMO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 2000
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. Lastkey()==27) }

private sBLOCO1 := qlbloc("B520A","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B520B","QBLOC.GLO") // bloco basico

private cTIPOREL               // tipo de relatorio (mensal ou 13o.)
private cTITULO                // titulo do contra-cheque
private cMATRICULA             // matricula p/ impressao individual
private bFILTRO                // code block de filtro (centro/filial/grupo)
private aEDICAO := {}          // vetor para os campos de entrada de dados
private nEV641
private nEV642
private nEV447
private nTETO

private nEV643
private nEV644
private nEV645
private nEV646
private nEV647
private nEV648

private nEV749
private nEV718
private nEV719
private nEV729
private nEV741
private nEV742
private nEV743

private nEV653
private nEV654
private nEV655
private nEV656
private nEV657
private nEV678
private nEV730

private nCONT
private nBASE
private nPERC
private nIR
private nDED

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL,sBLOCO2) }   , "TIPOREL"   })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario

do while .T.

   qlbloc(5,0,"B520A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   nEV641     := 0
   nEV642     := 0
   nEV447     := 0
   nTETO     := 0

   nEV643     := 0
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
   nEV719     := 0
   nEV729     := 0
   nEV741     := 0
   nEV742     := 0
   nEV743     := 0
   nEV730     := 0
   nCONT      := 0
   nBASE      := 0
   nPERC      := 0
   nIR        := 0
   nDED       := 0
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
           qrsay(XNIVEL,qabrev(cTIPOREL,"MD123456GAB",{"Mˆs Corrente","D‚cimo Terceiro","1 Semana","2 Semana","3 Semana","4 Semana","5 Semana","6 Semana","Grande Premio","13 1a Parcela","13 2a Parcela"}))

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTITULO = "CONTRA-CHEQUE "


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
               if empty(cMATRICULA)
                  i_mes()
               else
                  i_mes_fun()
               endif

          case cTIPOREL == "D"
              if empty(cMATRICULA)
                 i_decimo()
              else
                 i_decimo_fun()
              endif

          case cTIPOREL == "1"
               i_1semana()

          case cTIPOREL == "2"
               i_2semana()

          case cTIPOREL == "3"
               i_3semana()

          case cTIPOREL == "4"
               i_4semana()

          case cTIPOREL == "5"
               i_5semana()

          case cTIPOREL == "6"
               i_6semana()
          case cTIPOREL == "G"
               i_gpremio()
          case cTIPOREL == "A"
               i_1parcela()
          case cTIPOREL == "B"
               i_2parcela()

       endcase
return

function i_mes
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif
   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(BASE->B_IRRFMS - BASE->V_IRRFMS,"@R 999,999.99")+"  ("+ left(qextenso(BASE->B_IRRFMS-BASE->V_IRRFMS),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"641"))
   nEV641 := LANC->Valor
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV641,"@R 999,999.99")+XCOND0+space(15)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"642"))
   nEV642 := LANC->Valor
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  COMISSAO"+space(14)+"R$ "+transf(nEV642,"@R 999,999.99")+XCOND0+space(15)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "          SOMA"+space(14)+"R$ "+transf(nEV641+nEV642,"@R 999,999.99")+XCOND0+space(15)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(BASE->V_IRRFMS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "   IV INSS    "+space(14)+"R$ "+transf(BASE->V_INSSMS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(BASE->B_IRRFMS-BASE->V_IRRFMS,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""
   nCONT++
   if nCONT == 2
      nCONT := 0
      eject
   endif
   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
enddo
qstopprn()
return

function i_mes_fun
local nINDEX := SITUA->(IndexOrd())

FUN->(dbseek(cMATRICULA))
SITUA->(dbsetorder(4))
SITUA->(dbseek(FUN->Matricula+XANOMES))
if ! qinitprn() ; return ; endif

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(BASE->B_IRRFMS - BASE->V_IRRFMS,"@R 999,999.99")+"  ("+ left(qextenso(BASE->B_IRRFMS-BASE->V_IRRFMS),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"641"))
   nEV641 := LANC->Valor
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV641,"@R 999,999.99")+XCOND0+space(15)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"642"))
   nEV642 := LANC->Valor
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  COMISSAO"+space(14)+"R$ "+transf(nEV642,"@R 999,999.99")+XCOND0+space(15)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "          SOMA"+space(14)+"R$ "+transf(nEV641+nEV642,"@R 999,999.99")+XCOND0+space(15)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(BASE->V_IRRFMS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "   IV INSS    "+space(14)+"R$ "+transf(BASE->V_INSSMS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(BASE->B_IRRFMS-BASE->V_IRRFMS,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""
   if ! qlineprn() ; return ; endif


   SITUA->(dbsetorder(nINDEX))

qstopprn()
return

function i_decimo

nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   SITUA->(dbseek(FUN->Matricula+XANOMES))
   if SITUA->Vinculo <> "G"
      FUN->(dbskip())
      loop
   endif
   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   LANC->(dbseek(FUN->Matricula + XANOMES+"743"))
   nEV743 := LANC->Valor

   LANC->(dbseek(FUN->Matricula + XANOMES+"741"))
   nEV741 := LANC->Valor

   LANC->(dbseek(FUN->Matricula + XANOMES+"742"))
   nEV742 := LANC->Valor

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform( (nEV741+nEV742)-(nEV743+BASE->V_IRRF13),"@R 999,999.99")+"  ("+ left(qextenso((nEV741+nEV742)-(nEV743+BASE->V_IRRF13)),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"741"))
   nEV741 := LANC->Valor
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "13. 2 PARCELA "+space(14)+"R$ "+transf(nEV741,"@R 999,999.99")+XCOND0+space(15)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"742"))
   nEV742 := LANC->Valor
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "M de COMISSOES"+space(14)+"R$ "+transf(nEV742,"@R 999,999.99")+XCOND0+space(15)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"743"))
   nEV743 := LANC->Valor

   @ prow()+1,00 say "|" + space(38) + "|" + space(39) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "          SOMA"+space(14)+"R$ "+transf(nEV741+nEV742,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "DESC 13 1 PARC"+space(14)+"R$ "+transf(nEV743,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(BASE->V_IRRF13,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans( (nEV741+nEV742)-(nEV743+BASE->V_IRRF13),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""
   nCONT++
   if nCONT == 2
      nCONT := 0
      eject
   endif
   if ! qlineprn() ; return ; endif

   FUN->(dbskip())
enddo
qstopprn()
return

function i_decimo_fun
FUN->(dbseek(cMATRICULA))
if ! qinitprn() ; return ; endif

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))

   LANC->(dbseek(FUN->Matricula + XANOMES+"743"))
   nEV743 := LANC->Valor

   LANC->(dbseek(FUN->Matricula + XANOMES+"741"))
   nEV741 := LANC->Valor

   LANC->(dbseek(FUN->Matricula + XANOMES+"742"))
   nEV742 := LANC->Valor

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform( (nEV741+nEV742)-(nEV743+BASE->V_IRRF13),"@R 999,999.99")+"  ("+ left(qextenso((nEV741+nEV742)-(nEV743+BASE->V_IRRF13)),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"741"))
   nEV741 := LANC->Valor
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "13. 2 PARCELA "+space(14)+"R$ "+transf(nEV741,"@R 999,999.99")+XCOND0+space(15)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"742"))
   nEV742 := LANC->Valor
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "M de COMISSOES"+space(14)+"R$ "+transf(nEV742,"@R 999,999.99")+XCOND0+space(15)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + space(39) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "          SOMA"+space(14)+"R$ "+transf(nEV741+nEV742,"@R 999,999.99")+XCOND0+space(15)+"|"

   LANC->(dbseek(FUN->Matricula + XANOMES+"743"))
   nEV743 := LANC->Valor

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "DESC 13 1 PARC"+space(14)+"R$ "+transf(nEV743,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(BASE->V_IRRF13,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans( (nEV741+nEV742)-(nEV743+BASE->V_IRRF13),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""
   if ! qlineprn() ; return ; endif

qstopprn()

return

function i_1semana
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   if empty(cMATRICULA)
      SITUA->(dbseek(FUN->Matricula+XANOMES))
      if SITUA->Vinculo <> "G"
         FUN->(dbskip())
         loop
      endif
   else
      FUN->(dbseek(cMATRICULA))
      SITUA->(dbseek(cMatricula+XANOMES))
   endif

   BASE->(dbseek(FUN->Matricula+XANOMES))
   if BASE->B_irrfms == 0
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"643"))
      FUN->(dbskip())
      loop
   endif

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

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
   nTETO := nTETO - (nEV447 * 0.11)
   iif(nINSS >= nTETO,nINSS := nTETO,nINSS)
   iif(nINSS <= 0 , nINSS := 0,nINSS)
   nIR :=  ( (nEV643 - nINSS) * (nPERC/100)) - nDED
   nBASE := (nEV643 - nINSS) - nIR

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV643,"@R 999,999.99")+XCOND0+space(15)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV653,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV643-(nIR+nEV653+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV643,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV653,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  OUTROS  "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV643-(nIR+nEV653+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   eject
   nEV643 := 0
   nEV653 := 0
   nBASE := 0
   nPERC := 0
   nDED  := 0
   nIR   := 0
   nINSS := 0
   if ! qlineprn() ; return ; endif

   if empty(cMATRICULA)
      FUN->(dbskip())
   else
      exit
   endif
enddo
qstopprn()
return

function i_2semana
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   if empty(cMATRICULA)
      SITUA->(dbseek(FUN->Matricula+XANOMES))
      if SITUA->Vinculo <> "G"
         FUN->(dbskip())
         loop
      endif
   else
      FUN->(dbseek(cMATRICULA))
      SITUA->(dbseek(cMatricula+XANOMES))
   endif
   BASE->(dbseek(FUN->Matricula+XANOMES))
   if BASE->B_irrfms == 0
      FUN->(dbskip())
      loop
   endif
   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"644"))
      FUN->(dbskip())
      loop
   endif

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"644"))
   nEV644 := LANC->Valor
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
   nTETO := nTETO - (nEV447 * 0.11)
   iif(nINSS >= nTETO,nINSS := nTETO,nINSS)
   iif(nINSS <= 0 , nINSS := 0,nINSS)
   nIR := ( (nEV644-nINSS) * (nPERC/100)) - nDED
   nBASE := (nEV644-nINSS) - nIR
   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV644,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV654,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS ,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV644-(nIR+nEV654+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV644,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV654,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV644-(nIR+nEV654+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   eject
   nEV644 := 0
   nEV654 := 0
   nBASE := 0
   nPERC := 0
   nIR   := 0
   nDED  := 0
   nINSS := 0

   if ! qlineprn() ; return ; endif

   if empty(cMATRICULA)
      FUN->(dbskip())
   else
     exit
   endif
enddo
qstopprn()
return


function i_3semana
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   if empty(cMATRICULA)
      SITUA->(dbseek(FUN->Matricula+XANOMES))
      if SITUA->Vinculo <> "G"
         FUN->(dbskip())
         loop
      endif
   else
      FUN->(dbseek(cMATRICULA))
      SITUA->(dbseek(cMatricula+XANOMES))
   endif

   BASE->(dbseek(FUN->Matricula+XANOMES))
   if BASE->B_irrfms == 0
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"645"))
      FUN->(dbskip())
      loop
   endif

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"645"))
   nEV645 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"655"))
   nEV655 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"447"))
   nEV447 := LANC->Valor


   do case
      case  nEV645 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV645 > 1058 .and. nEV645 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV645 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase

   nINSS := nEV645 * 0.11
   nTETO := 275.75
   nTETO := nTETO - (nEV447 * 0.11)
   iif(nINSS >= nTETO,nINSS := nTETO,nINSS)
   iif(nINSS <= 0 , nINSS := 0,nINSS)
   nIR := ((nEV645-nINSS) * (nPERC/100)) - nDED
   nBASE := (nEV645-nINSS) - nIR

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV645,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV655,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV645-(nIR+nEV655+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV645,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV655,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV645-(nIR+nEV655+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   eject
   nEV645 := 0
   nEV655 := 0
   nBASE  := 0
   nPERC  := 0
   nDED   := 0
   nIR    := 0
   nINSS  := 0
   if ! qlineprn() ; return ; endif

   if empty(cMATRICULA)
      FUN->(dbskip())
   else
      exit
   endif
enddo
qstopprn()
return

function i_4semana
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   if empty(cMATRICULA)
      SITUA->(dbseek(FUN->Matricula+XANOMES))
      if SITUA->Vinculo <> "G"
         FUN->(dbskip())
         loop
      endif
   else
      FUN->(dbseek(cMATRICULA))
      SITUA->(dbseek(cMatricula+XANOMES))
   endif

   BASE->(dbseek(FUN->Matricula+XANOMES))
   if BASE->B_irrfms == 0
      FUN->(dbskip())
      loop
   endif

   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"646"))
      FUN->(dbskip())
      loop
   endif

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"646"))
   nEV646 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"656"))
   nEV656 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"447"))
   nEV447 := LANC->Valor

   do case
      case  nEV646 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV646 > 1058 .and. nEV646 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV646 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase

   nINSS := nEV646 * 0.11
   nTETO := 275.75
   nTETO := nTETO - (nEV447 * 0.11)
   iif(nINSS >= nTETO,nINSS := nTETO,nINSS)
   iif(nINSS <= 0 , nINSS := 0,nINSS)

   nIR := ( (nEV646-nINSS) * (nPERC/100)) - nDED
   nBASE := (nEV646-nINSS) - nIR

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV646,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV656,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV646-(nIR+nEV656+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV646,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV656,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS ,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV646-(nIR+nEV656+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   eject
   nEV646 := 0
   nEV656 := 0
   nBASE := 0
   nPERC := 0
   nDED  := 0
   nIR   := 0
   nINSS := 0
   if ! qlineprn() ; return ; endif

   if empty(cMAtricula)
      FUN->(dbskip())
   else
      exit
   endif
enddo
qstopprn()
return

function i_5semana
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   if empty(cMATRICULA)
      SITUA->(dbseek(FUN->Matricula+XANOMES))
      if SITUA->Vinculo <> "G"
         FUN->(dbskip())
         loop
      endif
   else

      FUN->(dbseek(cMATRICULA))
      SITUA->(dbseek(cMatricula+XANOMES))
   endif

   BASE->(dbseek(FUN->Matricula+XANOMES))
   if BASE->B_irrfms == 0
      FUN->(dbskip())
      loop
   endif
   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"647"))
      FUN->(dbskip())
      loop
   endif


   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"647"))
   nEV647 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"657"))
   nEV657 := LANC->Valor
   LANC->(dbseek(FUN->Matricula + XANOMES+"447"))
   nEV447 := LANC->Valor


   do case
      case  nEV647 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV647 > 1058 .and. nEV647 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV647 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV647 * 0.11
   nTETO := 275.75
   nTETO := nTETO - (nEV447 * 0.11)
   iif(nINSS >= nTETO,nINSS := nTETO,nINSS)
   iif(nINSS <= 0 , nINSS := 0,nINSS)

   nIR := ( (nEV647-nINSS) * (nPERC/100) ) - nDED
   nBASE := (nEV647-nINSS) - nIR

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV647,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV657,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV647-(nIR+nEV657+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV647,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV657,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nEV647-(nIR+nEV657+nINSS),"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   eject
   nEV647 := 0
   nEV657 := 0
   nBASE := 0
   nPERC := 0
   nDED  := 0
   nIR   := 0
   nINSS  := 0

   if ! qlineprn() ; return ; endif

   if empty(cMATRICULA)
      FUN->(dbskip())
   else
      exit
   endif
enddo
qstopprn()
return

function i_6semana
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   if empty(cMATRICULA)
      SITUA->(dbseek(FUN->Matricula+XANOMES))
      if SITUA->Vinculo <> "G"
         FUN->(dbskip())
         loop
      endif
   else

      FUN->(dbseek(cMATRICULA))
      SITUA->(dbseek(cMatricula+XANOMES))
   endif

   BASE->(dbseek(FUN->Matricula+XANOMES))
   if BASE->B_irrfms == 0
      FUN->(dbskip())
      loop
   endif
   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"648"))
      FUN->(dbskip())
      loop
   endif


   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"648"))
   nEV648 := LANC->Valor
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
   nTETO := nTETO - (nEV447 * 0.11)
   iif(nINSS >= nTETO,nINSS := nTETO,nINSS)
   iif(nINSS <= 0 , nINSS := 0,nINSS)
   nIR := ( ((nEV648+nEV730)-nINSS) * (nPERC/100)) - nDED
   nBASE := (((nEV648+nEV730)-nINSS) - nIR)

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV648,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  OUTROS  "+space(14)+"R$ "+transf(nEV730,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV678,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans((nEV648-(nIR+nEV678+nINSS))+nEV730,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV648,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  OUTROS  "+space(14)+"R$ "+transf(nEV730,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+transf(nEV678,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans((nEV648-(nIR+nEV678+nINSS))+nEV730,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   eject
   nEV648 := 0
   nEV678 := 0
   nEV630 := 0
   nBASE  := 0
   nPERC  := 0
   nDED   := 0
   nIR    := 0
   nINSS  := 0

   if ! qlineprn() ; return ; endif

   if empty(cMATRICULA)
      FUN->(dbskip())
   else
      exit
   endif
enddo
qstopprn()
return


function i_gpremio
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   if empty(cMATRICULA)
      SITUA->(dbseek(FUN->Matricula+XANOMES))
      if SITUA->Vinculo <> "G"
         FUN->(dbskip())
         loop
      endif
   else

      FUN->(dbseek(cMATRICULA))
      SITUA->(dbseek(cMatricula+XANOMES))
   endif

   BASE->(dbseek(FUN->Matricula+XANOMES))
   if BASE->B_irrfms == 0
      FUN->(dbskip())
      loop
   endif
   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"749"))
      FUN->(dbskip())
      loop
   endif


   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"749"))
   nEV749 := LANC->Valor
   do case
      case  nEV749 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV749 > 1058 .and. nEV718 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV749 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nINSS := nEV749 * 0.11
   nTETO := 275.75
   nTETO := nTETO - (nEV749 * 0.11)
   iif(nINSS >= nTETO,nINSS := nTETO,nINSS)
   iif(nINSS <= 0 , nINSS := 0,nINSS)
   nIR :=  ( (nEV749 - nINSS) * (nPERC/100)) - nDED
   nBASE := (nEV749 - nINSS) - nIR

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV749,"@R 999,999.99")+XCOND0+space(15)+"|"



   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nBASE,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV749,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   OUTROS  "+space(14)+"R$ "+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"

   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nBASE,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   eject
   nEV749 := 0
   nBASE := 0
   nPERC := 0
   nDED  := 0
   nIR   := 0

   if ! qlineprn() ; return ; endif

   if empty(cMATRICULA)
      FUN->(dbskip())
   else
      exit
   endif
enddo
qstopprn()
return

function i_1parcela
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   if empty(cMATRICULA)
      SITUA->(dbseek(FUN->Matricula+XANOMES))
      if SITUA->Vinculo <> "G"
         FUN->(dbskip())
         loop
      endif
   else

      FUN->(dbseek(cMATRICULA))
      SITUA->(dbseek(cMatricula+XANOMES))
   endif

   BASE->(dbseek(FUN->Matricula+XANOMES))
   if BASE->B_irrfms == 0
      FUN->(dbskip())
      loop
   endif
   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"718"))
      FUN->(dbskip())
      loop
   endif


   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   CARGO->(dbseek(SITUA->Cargo))
   BASE->(dbseek(FUN->Matricula+XANOMES))
   LANC->(dbseek(FUN->Matricula + XANOMES+"718"))
   nEV718 := LANC->Valor
   do case
      case  nEV718 <= 1058
            nPERC := 0
            nDED  := 0
      case  nEV718 > 1058 .and. nEV718 <= 2115
            nPERC := 15
            nDED  := 158.70
      case  nEV718 > 2115
            nPERC := 27.5
            nDED  := 423.08
   endcase
   nIR := (nEV718 * (nPERC/100)) - nDED
   nBASE := nEV718 - nIR

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV718,"@R 999,999.99")+XCOND0+space(15)+"|"


   @ prow()+1,00 say "|" + space(38) + "|" + space(39) + "|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  OUTROS  "+space(14)+"R$ "+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nBASE,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  I   FIXO    "+space(14)+"R$ "+transf(nEV718,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + space(39) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS    " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  OUTROS  "+space(14)+"R$ "+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nBASE,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   eject
   nEV718 := 0
   nBASE := 0
   nPERC := 0
   nDED  := 0
   nIR   := 0

   if ! qlineprn() ; return ; endif

   if empty(cMATRICULA)
      FUN->(dbskip())
   else
      exit
   endif
enddo
qstopprn()
return

function i_2parcela
nCONT := 0
if ! qinitprn() ; return ; endif

do while ! FUN->(eof()) .and. qcontprn()

   if empty(cMATRICULA)
      SITUA->(dbseek(FUN->Matricula+XANOMES))
      if SITUA->Vinculo <> "G"
         FUN->(dbskip())
         loop
      endif
   else

      FUN->(dbseek(cMATRICULA))
      SITUA->(dbseek(cMatricula+XANOMES))
   endif

 //  BASE->(dbseek(FUN->Matricula+XANOMES))
 //  if BASE->B_irrfms == 0
 //     FUN->(dbskip())
 //     loop
 //  endif
   if ! LANC->(dbseek(FUN->Matricula + XANOMES+"719"))
      FUN->(dbskip())
      loop
   endif


   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

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

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  13 2a Parc. "+space(14)+"R$ "+transf(nEV719,"@R 999,999.99")+XCOND0+space(15)+"|"


   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS   " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESC 1a Parc"+space(14)+"R$ "+transf(nEV729,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+transf(nBASE,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say ""

   @ prow()  ,00 say XCOND0+"|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(21)+ "RECIBO DE PAGAMENTO A AUTONOMO - R P A" + space(19) + "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(3) + "Nome ou Razao Social da Empresa" + space(12) + "|" + "     Matricula (CNPJ)" +space(10)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|"+ space(3) + XCOND1 + FILIAL->Razao +XCOND0+space(3)+ "  |"
   @ prow()  ,51 say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + space(10)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   @ prow()+1,00 say "|" + XCOND1 + "Recebi da empresa acima identificada, pela prestacao dos servicos de "+XCOND0+left(CARGO->Descricao,20)+ " " +XCOND1+right(XANOMES,2)+"/"+left(XANOMES,4)+" "+XCOND0+space(12)+"|"
   @ prow()+1,00 say "|" + XCOND1 + "a importancia de R$ "+ transform(nBASE,"@R 999,999.99")+"  ("+ left(qextenso(nBASE),95)+") "+XCOND0+space(23)+"|"
   @ prow()+1,00 say "|" + "Conforme discriminativo abaixo"+space(48)+ "|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  ESPECIFICACAO" +XCOND0+space(30)+"|"

   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  13 2a Parc. "+space(14)+"R$ "+transf(nEV719,"@R 999,999.99")+XCOND0+space(15)+"|"


   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESCONTOS   " +XCOND0+space(30)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  DESC 1a Parc"+space(14)+"R$ "+transf(nEV729,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  II  INSS    "+space(14)+"R$ "+transf(nINSS,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + space(38) + "|" + XCOND1 + "  III IRRF    "+space(14)+"R$ "+transf(nIR,"@R 999,999.99")+XCOND0+space(15)+"|"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"NUMERO DE INSCRICAO"+space(34)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+"NA PREVIDENCIA..: "+FUN->Pis_num+space(36)+XCOND0+"|"+"    VALOR LIQUIDO... R$ "+trans(nBASE,"@R 999,999.99")+"     |"
   @ prow()+1,00 say "|" +XCOND1+"NO CPF..........: "+FUN->Cpf_num+space(36)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(12)+"DOCUMENTO DE IDENTIDADE"+space(30)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"NUMERO"+space(20)+"ORGAO EMISSOR"+space(22)+XCOND0+"|"+replicate("-",14)+"ASSINATURA"+replicate("-",15)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(1)+FUN->Idt_num+space(15)+FUN->Idt_emi+space(24)+XCOND0+"|"+ space(39)+"|"
   @ prow()+1,00 say "|" + replicate("-",38) + "|"+replicate("_",39)+"|"
   @ prow()+1,00 say "|" +XCOND1+space(4)+"LOCALIDADE"+space(30)+"DATA"+space(17)+XCOND0+"|"+replicate("-",13)+"NOME COMPLETO"+replicate("-",13)+"|"
   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00 say "|" +XCOND1+space(1)+CGM->Municipio+space(9)+dtoc(FUN->Idt_dat)+space(15)+XCOND0+"|  "+left(FUN->Nome,30)+"       |"
   @ prow()+1,00 say "|" + replicate("-",78) + "|"

   eject
   nEV719 := 0
   nBASE := 0
   nPERC := 0
   nDED  := 0
   nIR   := 0

   if ! qlineprn() ; return ; endif

   if empty(cMATRICULA)
      FUN->(dbskip())
   else
      exit
   endif
enddo
qstopprn()
return

