/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DA GUIA DE IRRF (DARF)
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: JULHO DE 1995
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE    := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1    := qlbloc("B515B","QBLOC.GLO")
private sBLOCO2    := qlbloc("B515C","QBLOC.GLO")

private aEDICAO    := {}       // vetor para entrada de dados
private cTIPOFUN               // define tipo de funcionario
private cTIPOREL               // define tipo de funcionario
private cMESANO    := "  /    "  // mes e ano de referencia
private cANOMES                // inversao de cMESANO sem a barra
private dDT_VENC   := ctod("") // data de vencimento
private dDT_APU    := ctod("") // data de Apuracao
private dDT_REFI   := ctod("") // data de referencia inicial
private dDT_REFF   := ctod("") // data de referencia final
private cMATRICULA := space(6) // matricula para funcionario demitido
private nTOTAL     := 0.00     // total de irrf dos funcionarios
private cPRIMDIA               // primeiro dia da ultima semana do mes
private nVALOR     := 0.00     // valor para autonomo
public  lCONF      := .F.
// POSICIONA ARQUIVO CGM EM RELACAO A CIDADE DA EMPRESA _____________________

CGM->(dbseek(XCGM))
SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO2              )} , "TIPOREL"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOFUN ,sBLOCO1              )} , "TIPOFUN"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_APU                        )} , "DT_APU"  })

aadd(aEDICAO,{{ || qgetx(-1,0,@cMESANO  ,"99/9999"            )} , "MESANO"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_VENC                       )} , "DT_VENC"  })
// aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_REFI                    )} , "DT_REFI"  })
// aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_REFF                    )} , "DT_REFF"  })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA                  )} , "MATRICULA"})
aadd(aEDICAO,{{ || NIL },NIL})    // nome do funcionario
aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR ,"@E 999,999,999.99"    )} , "VALOR"    })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma emiss„o do DARF ?") },NIL})

do while .T.

   qlbloc(5,0,"B515A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   nTOTAL     := nVALOR := 0.00

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif
   if cTIPOREL == "1"
      if ( i_inicializacao() , i_impressao() , NIL )
   else
      if ( i_inicializacao() , i_imp2() , NIL )
   endif

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "TIPOFUN"
           qrsay(XNIVEL,qabrev(cTIPOFUN,"123",{"Funcion rios Mensalistas",;
                          "Funcion rios Aut“nomos","Funcion rio Demitido"}))
      case cCAMPO == "TIPOREL"
           qrsay(XNIVEL,qabrev(cTIPOREL,"12",{"Formul rio Cont¡nuo",;
                          "GUIA DARF"}))

      case cCAMPO == "MESANO"
           if cMESANO == "  /    "
              qmensa("Campo MES ANO ‚ obrigat¢rio !","B")
              return .F.
           endif

      case cCAMPO == "DT_VENC"
           if empty(dDT_VENC)
              qmensa("Campo DATA DE VENCIMENTO ‚ obrigat¢rio !","B")
              return .F.
           endif
           do case
//            case cTIPOFUN == "1"
//                 XNIVEL+=3
//              case cTIPOFUN == "2"
//                   XNIVEL+=2
           endcase

      case cCAMPO == "DT_REFI"
           if empty(dDT_REFI)
              qmensa("Campo DATA DE REFERENCIA INICIAL ‚ obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "DT_REFF"
           if empty(dDT_REFF)
              qmensa("Campo DATA DE REFERENCIA FINAL ‚ obrigat¢rio !","B")
              return .F.
           endif
           do case
              case cTIPOFUN == "1"
                   XNIVEL+=3
  //            case cTIPOFUN == "2"
 //                  XNIVEL+=2
           endcase
           if dDT_REFF < dDT_REFI
              qmensa("REFERENCIA FINAL anterior … REFERENCIA INICIAL !","B")
              return .F.
           endif
      case cCAMPO == "MATRICULA"
           do case
              case cTIPOFUN == "1"
                   if empty(cMATRICULA)
                      qrsay(++XNIVEL,"*** Todos Funcion rios ***")
                   else
                      qrsay(XNIVEL,cMATRICULA := strzero(val(cMATRICULA),6))
                      if ! FUN->(dbseek(cMATRICULA))
                         qmensa("Funcion rio n„o cadastrado !","B")
                         return .F.
                      endif
                      qrsay(++XNIVEL,left(FUN->Nome,30))
                   endif

              case cTIPOFUN == "2"
                   if empty(cMATRICULA)
                      qrsay(++XNIVEL,"*** Todos Funcion rios ***")
                   else
                      qrsay(XNIVEL,cMATRICULA := strzero(val(cMATRICULA),6))
                      if ! FUN->(dbseek(cMATRICULA))
                         qmensa("Funcion rio n„o cadastrado !","B")
                         return .F.
                      endif
                      qrsay(++XNIVEL,left(FUN->Nome,30))
                   endif

              case cTIPOFUN == "3"
                   if cTIPOFUN == "3" .and. empty(cMATRICULA)
                      qmensa("Campo MATRICULA ‚ obrigat¢rio !","B")
                      return .F.
                   else
                      qrsay(XNIVEL,cMATRICULA := strzero(val(cMATRICULA),6))
                      if ! FUN->(dbseek(cMATRICULA))
                         qmensa("Funcion rio n„o cadastrado !","B")
                         return .F.
                      endif
                      qrsay(++XNIVEL,left(FUN->Nome,30))
                   endif
           endcase

           if cTIPOFUN != "2"    // pula pedida do valor se funcionarios
              XNIVEL++           // mensalistas ou funcionario demitido
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
   local lACHOU := .F.
   cPRIMDIA := rh_ultsemana()
// cANOMES := right(cMESANO,2) + left(cMESANO,4)
   cANOMES := right(cMESANO,4) + left(cMESANO,2)
   do case
      case cTIPOFUN = "1"
           if empty(cMATRICULA)
              // TOTALIZACAO DE IRRF DE FUNCIONARIOS ___________________________________
              qmensa("Totalizando IRRF de funcion†rios...")
              FUN->(dbgotop())
              do while ! FUN->(eof())
                 if FUN->Data_adm  > qfimmes(XDATASYS)
                    FUN->(dbskip())
                    loop
                 endif
                 SITUA->(dbseek(FUN->Matricula))
                 if SITUA->Vinculo == "G"
                    FUN->(Dbskip())
                    loop
                 endif
               //  if month(SITUA->Af_ini) = month(XDATASYS) .and. year(SITUA->Af_ini) = year(XDATASYS)
               //     if SITUA->Af_ini < cPRIMDIA
               //        FUN->(dbskip())
               //        loop
               //     else
               //        lACHOU := .T.
               //     endif
               //  endif
                 if BASE->(dbseek(FUN->Matricula+cANOMES))
                    if BASE->V_irrfms + BASE->V_irrf13 + BASE->V_irrffr > 0.00
                       nTOTAL += BASE->V_irrfms + BASE->V_irrf13 + BASE->V_irrffr
                    endif
                 endif

                 FUN->(dbskip())
              enddo
           else
              qmensa("Localizando IRRF do funcion†rio...")
              SITUA->(dbseek(FUN->Matricula))
              if BASE->(dbseek(cMATRICULA+cANOMES))
                 nTOTAL := BASE->V_irrfms
              endif
           endif

      case cTIPOFUN = "2"
           if empty(cMATRICULA)
              // TOTALIZACAO DE IRRF DE FUNCIONARIOS ___________________________________
              qmensa("Totalizando IRRF de autonomos...")
              FUN->(dbgotop())
              do while ! FUN->(eof())
                 if FUN->Data_adm  > qfimmes(XDATASYS)
                    FUN->(dbskip())
                    loop
                 endif
                 SITUA->(dbseek(FUN->Matricula))
                 if SITUA->Vinculo <> "G"
                    FUN->(Dbskip())
                    loop
                 endif
                 if month(SITUA->Af_ini) = month(XDATASYS) .and. year(SITUA->Af_ini) = year(XDATASYS)
                    if SITUA->Af_ini < cPRIMDIA
                       FUN->(dbskip())
                       loop
                    else
                       lACHOU := .T.
                    endif
                 endif
                 if BASE->(dbseek(FUN->Matricula+cANOMES))
                    if BASE->V_irrfms + BASE->V_irrf13 + BASE->V_irrffr > 0.00
                       nTOTAL += BASE->V_irrfms + BASE->V_irrf13 + BASE->V_irrffr
                    endif
                 endif

                 FUN->(dbskip())
              enddo
           else
              qmensa("Localizando IRRF do funcion†rio...")
              SITUA->(dbseek(FUN->Matricula))
              if BASE->(dbseek(cMATRICULA+cANOMES))
                 nTOTAL := BASE->V_irrfms
              endif
           endif

      case cTIPOFUN = "3"
           qmensa("Localizando IRRF do funcion†rio...")
           SITUA->(dbseek(FUN->Matricula))
           if month(SITUA->Af_ini) = month(XDATASYS) .and. year(SITUA->Af_ini) = year(XDATASYS)
            //if SITUA->Af_ini < cPRIMDIA
                 if BASE->(dbseek(cMATRICULA+cANOMES))
                    nVALOR := BASE->V_irrfms
                 endif
            //else
            //  qmensa("Funcion rio afastado na £ltima semana do mes !","B")
            //endif
           else
              qmensa("Afastamento nao foi feito este mes !","B")
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE IMPRESSAO _________________________________________

static function i_impressao
   if ! qinitprn() ; return ; endif
   if ! qlineprn() ; return ; endif
   @ prow(),pcol() say XCOND0

   @ prow()+1,00 say "|"+replicate("-",78)+"|"
   @ prow()+1,00 say "|"+"      MINISTERIO DA FAZENDA            "+"|"+"02 PERIODO DE APURACAO  |" +dtoc((dDT_APU)) +"   |"
   @ prow()+1,00 say "|"+"  SECRETARIA DA RECEITA FEDERAL        "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"  Documento de Arrecadacao de Receitas "+"|"+"03 NUMERO DO CPF ou CGC |" +XCOND1+XCGCCPF+" "+XCOND0+"  |"
   @ prow()+1,00 say "|"+"  Federais                             "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"  DARF                                 "+"|"+"04 CODIGO DA RECEITA    |    0561     |"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"01 NOME/TELEFONE                       "+"|"+"05 NUMEROS DE REFERENCIA|             |"
   @ prow()+1,00 say "|"+XCOND1 + XRAZAO + space(1) + XTELEFONE + XCOND0+"   |"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"06 DATA DO VENCIMENTO   |"+dtoc(dDT_VENC)+"   |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"07 VALOR DO PRINCIPAL   |"+XCOND1+transf(nTOTAL,"@E 999,999,999.99")+XCOND0+"     |"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"08 VALOR DA MULTA       |             |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"09 VALOR DOS JUROS      |             |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"10 VALOR TOTAL          |"+XCOND1+transf(nTOTAL,"@E 999,999,999.99")+XCOND0+"     |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"11 AUTENTICACAO BANCARIA              |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"                                      |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"                                      |"
   @ prow()+1,00 say "|"+replicate("-",78)+"|"

   @ prow()+1,00 say " "
   @ prow()+1,00 say "|"+replicate("-",78)+"|"
   @ prow()+1,00 say "|"+"      MINISTERIO DA FAZENDA            "+"|"+"02 PERIODO DE APURACAO  |" +dtoc((dDT_APU)) +"   |"
   @ prow()+1,00 say "|"+"  SECRETARIA DA RECEITA FEDERAL        "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"  Documento de Arrecadacao de Receitas "+"|"+"03 NUMERO DO CPF ou CGC |" +XCOND1+XCGCCPF+" "+XCOND0+"  |"
   @ prow()+1,00 say "|"+"  Federais                             "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"  DARF                                 "+"|"+"04 CODIGO DA RECEITA    |    0561     |"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"01 NOME/TELEFONE                       "+"|"+"05 NUMEROS DE REFERENCIA|             |"
   @ prow()+1,00 say "|"+XCOND1 + XRAZAO + space(1) + XTELEFONE + XCOND0+"   |"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"06 DATA DO VENCIMENTO   |"+dtoc(dDT_VENC)+"   |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"07 VALOR DO PRINCIPAL   |"+XCOND1+transf(nTOTAL,"@E 999,999,999.99")+XCOND0+"     |"
   @ prow()+1,00 say "|"+"---------------------------------------"+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"08 VALOR DA MULTA       |             |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"09 VALOR DOS JUROS      |             |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"10 VALOR TOTAL          |"+XCOND1+transf(nTOTAL,"@E 999,999,999.99")+XCOND0+"     |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"--------------------------------------|"
   @ prow()+1,00 say "|"+"                                       "+"|"+"11 AUTENTICACAO BANCARIA              |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"                                      |"
   @ prow()+1,00 say "|"+"                                       "+"|"+"                                      |"
   @ prow()+1,00 say "|"+replicate("-",78)+"|"


   qstopprn()

return

static function i_imp2

   if ! qinitprn() ; return ; endif
   if ! qlineprn() ; return ; endif
   @ prow(),pcol() say XCOND0

   @ prow()  ,67 say dtoc(dDT_APU)
   @ prow()+2,58 say XCGCCPF
   @ prow()+2,60 say "0561"

   @ prow()+4,01 say XCOND1 + XRAZAO + space(1) + XTELEFONE + XCOND0
   @ prow()  ,60 say dtoc(dDT_VENC)

   // IMPRESSAO COM VALOR, INDIVIDUAL OU GERAL ___________________________________

   @ prow()+2,60 say nTOTAL picture "@E 999,999,999.99"

   // IMPRIME MULTA E JUROS, CASO EXISTAM _____________________________________

     @ prow()+4,00 say ""

   // IMPRIME O TOTAL, CASO EXISTAM MULTA E JUROS ________________________________

   @ prow()+2,60 say nTOTAL picture "@E 999,999,999.99"

   @ prow()+8 ,000 say ""

   qstopprn(.F.)

return

