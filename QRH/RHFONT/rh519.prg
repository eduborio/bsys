/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DA GUIA DE RECOLHIMENTO RESCISORIO DO FGTS e Cont Social (GRFC)
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO 2002
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE    := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1    := qlbloc("B519B","QBLOC.GLO")
private sBLOCO3    := qlbloc("B519D","QBLOC.GLO")
private sBLOCO4    := qlbloc("B519E","QBLOC.GLO")
private sBLOCO5    := qlbloc("B519K","QBLOC.GLO")

private aEDICAO   := {}        // vetor para entrada de dados
private nSALDO    := 0
private nDED      := 0
private nCAM_25   := 0
private nCAM_26   := 0
private nCAM_27   := 0
private nCAM_28   := 0
private nCAM_29   := 0
private nCAM_30   := 0
private nCAM_31   := 0
private nCAM_32   := 0
private nCAM_33   := 0
private nCAM_34   := 0
private lACHOU    := .F.       // flag verificador de existencia de dados
private cMATRICULA := space(6) // matricula do funcionario
private cCATEG    := ""
private cIMP      := ""
private cAVISO    := ""
private cDISSI    := ""
private cANOMES   := space(6)   // ano/mes de competencia
private cTIPO     := ""

// POSICIONA ARQUIVO CGM EM RELACAO A CIDADE DA EMPRESA _____________________

CGM->(dbseek(XCGM))
LANC->(Dbsetorder(3))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________
FUN->(dbsetfilter({|| Situacao != "H"}, 'Situacao != "H"'))
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA                  )}, "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || qesco(-1,0,@cCATEG ,sBLOCO1                )} , "CATEG"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cAVISO ,sBLOCO3                )} , "AVISO"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cDISSI ,sBLOCO4                )} , "DISSI"    })

aadd(aEDICAO,{{ || qgetx(-1,0,@nSALDO ,"99,999,999.99"      )} ,"SALDO"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_25 ,"99,999,999.99"      )} ,"CAM_25"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_26 ,"99,999,999.99"      )} ,"CAM_26"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_27 ,"99,999,999.99"      )} ,"CAM_27"  })

aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_28 ,"99,999,999.99"      )} , "CAM_28"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_29 ,"99,999,999.99"      )} , "CAM_29"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_30 ,"99,999,999.99"      )} , "CAM_30"  })

aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_31 ,"99,999,999.99"      )} , "CAM_31"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_32 ,"99,999,999.99"      )} , "CAM_32"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_33 ,"99,999,999.99"      )} , "CAM_33"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_34 ,"99,999,999.99"      )} , "CAM_34"  })

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOCO5                )} , "TIPO"    })

do while .T.

   qlbloc(5,0,"B519A","QBLOC.GLO")
   qmensa()
   XNIVEL   := 1
   XFLAG    := .T.
   dDT_VENC := ctod("")
   nSALDO    := 0
   nDED      := 0
   nCAM_25   := 0
   nCAM_26   := 0
   nCAM_27   := 0
   nCAM_28   := 0
   nCAM_29   := 0
   nCAM_30   := 0
   nCAM_31   := 0
   nCAM_32   := 0
   nCAM_33   := 0
   nCAM_34   := 0
  // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "MATRICULA"
           if empty(cMATRICULA) ; return .F. ; endif
           if ! FUN->(dbseek(cMATRICULA:=strzero(val(cMATRICULA),6)))
              qmensa("Funcionario n„o Encontrado !","B")
              qmensa("")
              return .F.
           else
             if FUN->Situacao == "H"
                Qmensa("Funcionario com Homologacao Confirmada !!","B")
                return .F.
             endif
             qrsay(XNIVEL+1,left(FUN->Nome,30))
           endif

      case cCAMPO == "CATEG"
           qrsay(XNIVEL,qabrev(cCATEG,"ABCDEFGHIJK",{"Empregado",;
                                                     "Trabalhador Avulso",;
                                                     "Empregado afastado p/prestar servico militar",;
                                                     "Empregado sob cont. trabalho p/prazo determ.",;
                                                     "Diretor n„o Empregado com FGTS",;
                                                     "Diretor n„o Empregado sem FGTS",;
                                                     "Agente Publico",;
                                                     "Trab. autonomo ou equip. c/contr. s/ remuneracao",;
                                                     "Trab. autonomo ou equip. c/contr. s/ salario-base",;
                                                     "Transp. autonomo c/ contrib. s/ remuneracao",;
                                                     "Transp. autonomo c/ contrib. s/ salario-base"}))

      case cCAMPO == "AVISO"
           qrsay(XNIVEL,qabrev(cAVISO,"12",{"Trabalhado","Indenizado"}))

      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO,"PF",{"Pre-Impresso","Formulario Continuo"}))


      case cCAMPO == "DISSI"
           qrsay(XNIVEL,qabrev(cDISSI,"01",{"0 - Sim",;
                                            "1 - N„o"}))

           qmensa("Aguarde... calculando...")

           cMES_ATU := subs(dtoc(XDATASYS),4,2) + "/" + right(dtoc(XDATASYS),4)
           cMES_ANT := strzero(val(subs(dtoc(XDATASYS),4,2))-1,2) + "/" + right(dtoc(XDATASYS),4)

           XMES_ATU := right(dtoc(XDATASYS),4) + subs(dtoc(XDATASYS),4,2)
           XMES_ANT := right(dtoc(XDATASYS),4) + strzero(val(subs(dtoc(XDATASYS),4,2))-1,2)

           SITUA->(dbSetFilter({|| Anomes == XMES_ANT},"Anomes == XMES_ANT"))
           SITUA->(dbseek(FUN->Matricula))
           LANC->(dbSetFilter({|| Anomes == XMES_ANT},"Anomes == XMES_ANT"))
           LANC->(dbseek(FUN->Matricula))
           BASE->(dbSetFilter({|| Anomes == XMES_ANT},"Anomes == XMES_ANT"))
           BASE->(dbseek(FUN->Matricula))

           nCAM_25 := BASE->B_fgtsms + BASE->B_fgtsdt

           SITUA->(Dbclearfilter())
           LANC->(Dbclearfilter())
           BASE->(Dbclearfilter())

           SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
           SITUA->(dbseek(FUN->Matricula))
           LANC->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
           LANC->(dbseek(FUN->Matricula))
           BASE->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
           BASE->(dbseek(FUN->Matricula))
           if day(SITUA->Af_ini) > 7
              nCAM_25 := 0
           endif
           do while LANC->Matricula == FUN->Matricula

              if LANC->Evento $ "150*813*115"
                 nCAM_27 += LANC->Valor
              endif

              if LANC->Evento $ "150*813*115"
                 nDED += LANC->Valor
              endif

              LANC->(Dbskip())
           enddo

           if empty(SITUA->Codsaqfgts)
              nCAM_26 += BASE->B_fgtsms
              nCAM_26 += BASE->B_fgtsdt
              iif(!empty(CONFIG->Grfc),nCAM_26 := nCAM_26 - nDED,nCAM_26)
           else
              nCAM_26 += BASE->B_sfipms
              nCAM_26 += BASE->B_sfipdt
              iif(!empty(CONFIG->Grfc),nCAM_26 := nCAM_26 - nDED,nCAM_26)
           endif

           if day(SITUA->Af_ini) > 7
              nCAM_25 := 0
           else
    //          nCAM_26 := 0
           endif

      case cCAMPO == "CAM_27"
           if CONFIG->Aliq == "S"
              nCAM_30 := nCAM_25 * (8.5/100)
              nCAM_31 := nCAM_26 * (8.5/100)
              nCAM_32 := nCAM_27 * (8.5/100)

           else
              nCAM_30 := nCAM_25 * (8.0/100)
              nCAM_31 := nCAM_26 * (8.0/100)
              nCAM_32 := nCAM_27 * (8.0/100)
           endif

           nCAM_28 := nSALDO + nCAM_30 + nCAM_31 + nCAM_32
           nCAM_29 := nCAM_25 + nCAM_26 + nCAM_27 + nCAM_28
           nCAM_33 := nCAM_28 / 2
           nCAM_34 := nCAM_30 + nCAM_31 + nCAM_32 + nCAM_33

           qmensa("")

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   cANOMES := right(dtoc(XDATASYS),4) + subs(dtoc(XDATASYS),4,2)
   SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
   SITUA->(dbseek(FUN->Matricula))

   // TOTALIZACAO DE PROVENTOS DE FUNCIONARIOS ______________________________

   qmensa("Totalizando FGTS do funcionario...")

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE IMPRESSAO _________________________________________
static function i_impressao
   if cTIPO == "P"
      i_Pre()
   else
      i_Form()
   endif

return


static function i_Pre

   if ! qinitprn() ; return ; endif
   if ! qlineprn() ; return ; endif
   @ prow(),pcol() say XCOND0

   @ prow()+13,05  say left(XRAZAO,50)
   @ prow()+3 ,05  say XCOND1 + XCGCCPF + XCOND0
   @ prow()   ,38  say left(XCONTATO,9)
   @ prow()   ,52  say XTELEFONE

   @ prow()+3 ,05 say alltrim(XENDERECO) + "  " + XNUMERO + "  " + alltrim(XCOMPL)
   @ prow()+3 ,05 say alltrim(XBAIRRO)

   CGM->(dbseek(XCGM))
   @ prow()   ,35 say CGM->Municipio
   @ prow()   ,62 say CGM->Estado
   @ prow()   ,69 say XCEP

   @ prow()+2,00 say ""

   GRPS->(dbseek(XANOMES+FUN->Grps))

   @ prow()+4 ,05 say GRPS->Cod_fpas
   @ prow()   ,20 say iif(CONFIG->Gr_simples=="N","1 ","2 ")
   @ prow()   ,40 say CONFIG->Cnae

   @ prow()+04,05 say FUN->Nome
   @ prow()+03,05 say FUN->Pis_num
   @ prow()   ,19 say dtoc(FUN->Data_adm)
   do case
      case cCATEG == "A"
           @ prow()  ,31 say "01"
      case cCATEG == "B"
           @ prow()  ,31 say "02"
      case cCATEG == "C"
           @ prow()  ,31 say "03"
      case cCATEG == "D"
           @ prow()  ,31 say "04"
      case cCATEG == "E"
           @ prow()  ,31 say "05"
      case cCATEG == "F"
           @ prow()  ,31 say "11"
      case cCATEG == "G"
           @ prow()  ,31 say "12"
      case cCATEG == "H"
           @ prow()  ,31 say "13"
      case cCATEG == "I"
           @ prow()  ,31 say "14"
      case cCATEG == "J"
           @ prow()  ,31 say "15"
      case cCATEG == "K"
           @ prow()  ,31 say "16"
   endcase

   SITUA->(dbseek(FUN->Matricula))
   @ prow()   ,36 say dtoc(SITUA->Af_ini)

   AFAST->(dbseek(SITUA->Af_cod))
   @ prow()   ,47 say AFAST->COD_RE
   @ prow()   ,54 say cAVISO
//   @ prow()   ,65 say cDISSI

   @ prow()+3 ,04 say dtoc(FUN->Data_nasc)
   @ prow()   ,20 say FUN->Cp_num + "/" + FUN->Cp_serie
   @ prow()   ,48 say dtoc(FUN->Fgts_dat)

   @ prow()+4 ,04 say iif(nCAM_25 <> 0,transform(nCAM_25,"@r 9,999,999.99")," ")
   @ prow()   ,19 say iif(nCAM_26 <> 0,transform(nCAM_26,"@r 9,999,999.99")," ")
   @ prow()   ,33 say iif(nCAM_27 <> 0,transform(nCAM_27,"@r 9,999,999.99")," ")
   @ prow()   ,48 say iif(nCAM_28 <> 0,transform(nCAM_28,"@r 9,999,999.99")," ")
   @ prow()   ,64 say iif(nCAM_29 <> 0,transform(nCAM_29,"@r 9,999,999.99")," ")

   @ prow()+9 ,04 say iif(nCAM_30 <> 0,transform(nCAM_30,"@r 9,999,999.99")," ")
   @ prow()   ,19 say iif(nCAM_31 <> 0,transform(nCAM_31,"@r 9,999,999.99")," ")
   @ prow()   ,33 say iif(nCAM_32 <> 0,transform(nCAM_32,"@r 9,999,999.99")," ")
   @ prow()   ,48 say iif(nCAM_33 <> 0,transform(nCAM_33,"@r 9,999,999.99")," ")
   @ prow()   ,64 say iif(nCAM_34 <> 0,transform(nCAM_34,"@r 9,999,999.99")," ")
   @ prow()+4,05 say "CURITIBA, " + dtoc(SITUA->Af_ini)


   qstopprn()

   nCAM_25 := 0
   nCAM_26 := 0
   nCAM_27 := 0
   nCAM_28 := 0
   nCAM_29 := 0
   nCAM_30 := 0
   nCAM_31 := 0
   nCAM_32 := 0
   nCAM_33 := 0
   nCAM_34 := 0
   nDED    := 0

return

static function i_Form

   if ! qinitprn() ; return ; endif
   if ! qlineprn() ; return ; endif
   @ prow(),pcol() say XCOND1
   @ prow()+1 ,15  say "GRFC - Guia de Recolhimento Rescisorio do FGTS e de Contribuicao Social"
   @ prow()+2 ,90  say "³00 - Para uso da CAIXA                ³"
   @ prow()+1 ,90  say "³                                      ³"
   @ prow()+1 ,90  say "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
   @ prow()+1 ,00  say "DADOS DO EMPREGADOR"+replicate(" ",71)+"³01 - Carimbo CIEF                     ³"
   @ prow()+1 ,00  say "³02 - Razao Social / Firma"+replicate(" ",64)+"³                                      ³"
   @ prow()+1 ,00  say "³"+left(XRAZAO,50)+replicate(" ",39)+"³                                      ³"
   @ prow()+1 ,00  say "Ã"+replicate("Ä",39)+"Â"+replicate("Ä",49)+"´                                      ³"
   @ prow()+1 ,00  say "³03 - CNPJ/CEI                          "+"³04-Pessoa para contato/DDD/Telefone              ³                                      ³"
   @ prow()+1 ,00  say "³ "+ XCGCCPF + replicate(" ",20)+"³ "+left(XCONTATO,15)+" "+XTELEFONE+"                     "+"³                                      ³"
   @ prow()+1 ,00  say "Ã"+replicate("Ä",39)+"Á"+replicate("Ä",49)+"´                                      ³"
   @ prow()+1 ,00  say "³05 - Endereco(logradouro, andar, apartamento"+replicate(" ",45)+"³                                      ³"
   @ prow()+1 ,00  say "³ "+(XENDERECO) + "  " + XNUMERO + "  " + alltrim(XCOMPL)+"                         ³                                      ³"
   @ prow()+1 ,00  say "Ã"+replicate("Ä",40)+"Â"+replicate("Ä",39)+"Â"+replicate("Ä",8)+"Á"+replicate("Ä",8)+"Â"+replicate("Ä",29)+"´"
   CGM->(dbseek(XCGM))
   @ prow()+1 ,00  say "³06 - Bairro/Distrito"+space(20)+"³07 - Municipio"+space(25)+"³08 - UF          "+"³09 - CEP                     ³"
   @ prow()+1 ,00  say "³ "+left(XBAIRRO,25)+space(19)+"³ "+left(CGM->Municipio,30)+space(8)+"³ "+CGM->Estado+space(14)+"³ "+XCEP+"                    ³"
   @ prow()+1 ,00  say "Ã"+replicate("Ä",40)+"ÁÄÂ"+replicate("Ä",37)+"Á"+replicate("Ä",17)+"Á"+replicate("Ä",29)+"´"
   @ prow()+1 ,00  say "³10 - Tomador de servico(CNPJ/CEI)"+space(9)+"³11 - Tomador de servico (Razao Social)"+space(46)+" ³"
   @ prow()+1 ,00  say "³                                 "+space(9)+"³                                      "+space(46)+" ³"
   GRPS->(dbseek(XANOMES+FUN->Grps))
   @ prow()+1 ,00  say "Ã"+replicate("Ä",18)+"Â"+replicate("Ä",19)+"ÂÄÄÄÁ"+replicate("Ä",23)+"Â"+replicate("Ä",31)+"Ä"+replicate("Ä",29)+"Ù"
   @ prow()+1 ,00  say "³12 - FPAS         "+"³13 - Simples       "+"³14 - CNAE                  ³"
   @ prow()+1 ,00  say "³ "+ GRPS->Cod_fpas+space(14)+"³ "+iif(CONFIG->Gr_simples=="N","1 ","2 ")+space(16)+"³ "+CONFIG->Cnae+space(15)+ "  ³"
   @ prow()+1 ,00  say "À"+replicate("Ä",18)+"Á"+replicate("Ä",19)+"ÁÄÄÄ"+replicate("Ä",24)+"Ù"
   @ prow()+2 ,00  say "DADOS DO TRABALHADOR"
   @ prow()+1 ,00  say "³15 - Nome do trabalhador"+space(104)+"³"
   @ prow()+1 ,00  say "³ "+FUN->Nome+space(57)+"³"
   do case
      case cCATEG == "A"
           cIMP := "01"
      case cCATEG == "B"
           cIMP := "02"
      case cCATEG == "C"
           cIMP := "03"
      case cCATEG == "D"
           cIMP := "04"
      case cCATEG == "E"
           cIMP := "05"
      case cCATEG == "F"
           cIMP :=  "11"
      case cCATEG == "G"
           cIMP :=  "12"
      case cCATEG == "H"
           cIMP :=  "13"
      case cCATEG == "I"
           cIMP :=  "14"
      case cCATEG == "J"
           cIMP :=  "15"
      case cCATEG == "K"
           cIMP := "16"
   endcase
   SITUA->(dbseek(FUN->Matricula))
   AFAST->(dbseek(SITUA->Af_cod))

   @ prow()+1 ,00  say "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + "ÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÂÄÄÄÄÄÄÄÄÄ"+"ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄ"+"ÂÄÄÄÄÄÄÄÄÄÄÄ"+"ÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
   @ prow()+1 ,00  say "³16 - No. do PIS/PASEP " + " ³17 - Data de admissao "+"³18 - Cat "+"³19 - Data movimentacao "+"  Cod. "+"³20-Av.prev "+"³1-Trabalhad³21-Rec.diss/Acor³"
   @ prow()+1 ,00  say "³ "+FUN->Pis_num+space(10)+" ³ "+dtoc(FUN->Data_adm)+space(11)+"³ "+cIMP+space(6)+"³ "+dtoc(SITUA->Af_ini)+space(12)+"³  "+AFAST->Cod_re+"  ³     "+cAVISO+"     ³"+"2-Indenizad³"+"                ³"
   @ prow()+1 ,00  say "ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + "ÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÁÄÄÄÄÄÄÄÄÄ"+"ÁÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ"+"ÁÄÄÄÄÄÄ"+"ÁÄÄÄÄÄÄÂÄÄÄÄ"+"ÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
   @ prow()+1 ,00  say "³22-Data de Nascimento " + " ³23 - Carteira de trabalho(No./Serie)         "+"³24 - Data opcao         ³ Campo obrigatorio para "
   @ prow()+1 ,00  say "³ "+dtoc(FUN->Data_nasc)+space(12)+"³ "+FUN->Cp_num + "/" + FUN->Cp_serie+space(31)+"³ "+dtoc(FUN->Fgts_dat)+space(13)+"³ admissao anterior a 05/10/1998"
   @ prow()+1 ,00  say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + "ÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄÙ"

   @ prow()+2 ,00  say "Informcao de remuneracao/saldo para fins rescisorios"
   @ prow()+1 ,00  say "³25-Mes ant. a rescisao" + " ³26-Mes de Rescisao     "+"³27-Av. Previo Inden.³28-Saldo p/ fins rescisorios³29-Soma (campos 25 a 28)      ³"
   @ prow()+1 ,00  say "³"

   @ prow()   ,11 say iif(nCAM_25 <> 0,transform(nCAM_25,"@r 9,999,999.99")," ") +" ³"
   @ prow()   ,35 say iif(nCAM_26 <> 0,transform(nCAM_26,"@r 9,999,999.99")," ") +" ³"
   @ prow()   ,56 say iif(nCAM_27 <> 0,transform(nCAM_27,"@r 9,999,999.99")," ") +" ³"
   @ prow()   ,85 say iif(nCAM_28 <> 0,transform(nCAM_28,"@r 9,999,999.99")," ") +" ³"
   @ prow()   ,115 say iif(nCAM_29 <> 0,transform(nCAM_29,"@r 9,999,999.99")," ") +"  ³"

   @ prow()+1 ,00  say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + "ÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"

   @ prow()+1 ,00  say "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
   @ prow()+1 ,00  say "³Os valores lancados no" + "s campos abaixo devem con"+"templar, alem daqueles devidos ao trabalhador, a Contribuicao Social de que trata³"
   @ prow()+1 ,00  say "³a lei complementar 110" + "/2001, bem como todos os "+"encargos legais por recolhimeto em atraso, quando for o caso.                    ³"
   @ prow()+1 ,00  say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"

   @ prow()+2 ,00  say "³Valores a recolher"
   @ prow()+1 ,00  say "³30-Mes ant. a rescisao" + " ³31-Mes de Rescisao     "+"³32-Av. Previo Inden.³33 - Multa rescisoria       ³34 - Total a recolher         ³"
   @ prow()+1 ,00  say "³"
   @ prow()   ,11 say iif(nCAM_30 <> 0,transform(nCAM_30,"@r 9,999,999.99")," ") +" ³"
   @ prow()   ,35 say iif(nCAM_31 <> 0,transform(nCAM_31,"@r 9,999,999.99")," ") +" ³"
   @ prow()   ,56 say iif(nCAM_32 <> 0,transform(nCAM_32,"@r 9,999,999.99")," ") +" ³"
   @ prow()   ,85 say iif(nCAM_33 <> 0,transform(nCAM_33,"@r 9,999,999.99")," ") +" ³"
   @ prow()   ,115 say iif(nCAM_34 <> 0,transform(nCAM_34,"@r 9,999,999.99")," ") +"  ³"


   @ prow()+1 ,00  say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + "ÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+"ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"



   @ prow()+2,10  say "CURITIBA, " + dtoc(SITUA->Af_ini)
   @ prow()+1,02  say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   @ prow()+1,02  say "    Local e data                                                           ³ Autenticacao mecanica                             ³"
   @ prow()+1,02  say "                                                                           ³                                                   ³"
   @ prow()+1,02  say "                                                                           ³                                                   ³"
   @ prow()+1,02  say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                         ³                                                   ³"
   @ prow()+1,02  say "    Assinatura                                                             ³                                                   ³"
                                                                                            
   qstopprn()

   nCAM_25 := 0
   nCAM_26 := 0
   nCAM_27 := 0
   nCAM_28 := 0
   nCAM_29 := 0
   nCAM_30 := 0
   nCAM_31 := 0
   nCAM_32 := 0
   nCAM_33 := 0
   nCAM_34 := 0
   nDED    := 0

return

