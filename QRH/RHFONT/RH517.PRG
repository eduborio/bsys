/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DA GUIA DE RECOLHIMENTO CONTRIBUICAO SINDICAL(GRSC)
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 2002
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE    := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO   := {}        // vetor para entrada de dados

private nCAM_33  := 0
private nCAM_34  := 0
private nCAM_35  := 0
private nCAM_36  := 0
private nCAM_37  := 0
private nCAM_38  := 0
private nCAM_39  := 0
private nCAM_40  := 0
private nCAM_41  := 0
private nCAM_42  := 0
private nCAM_43  := 0
private nCAM_44  := 0
private nCAM_45  := 0
private nCAM_46  := 0
private cSIND := space(2) // matricula do funcionario
private dDATA_INI := ctod("")
// POSICIONA ARQUIVO CGM EM RELACAO A CIDADE DA EMPRESA _____________________


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_sind(-1,0,@cSIND                      )}, "SIND" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI ,"!D"                )} , "DATA_INI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_33 ,"9999999.99"         )} , "CAM_33"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_34 ,"9999999.99"         )} , "CAM_34"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_35 ,"9999999.99"         )} , "CAM_35"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_36 ,"9999999.99"         )} , "CAM_36"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_37 ,"9999999.99"         )} , "CAM_37"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_38 ,"999999999"          )} , "CAM_38"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_39 ,"9999999.99"         )} , "CAM_39"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_40 ,"9999999.99"         )} , "CAM_40"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_41 ,"9999999.99"         )} , "CAM_41"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_42 ,"9999999.99"         )} , "CAM_42"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_43 ,"9999999.99"         )} , "CAM_43"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_44 ,"9999999.99"         )} , "CAM_44"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_45 ,"9999999.99"         )} , "CAM_45"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCAM_46 ,"9999999.99"         )} , "CAM_46"  })

do while .T.

   qlbloc(5,0,"B517A","QBLOC.GLO")
   qmensa()
   XNIVEL   := 1
   XFLAG    := .T.

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
      case cCAMPO == "SIND"
           if empty(cSIND) ; return .F. ; endif
           if ! SIND->(dbseek(cSIND:=strzero(val(cSIND),2)))
              qmensa("Sindicato n„o Encontrado !","B")
              qmensa("")
              return .F.
           else
             qrsay(XNIVEL+1,left(SIND->Descricao,40))
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao




return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE IMPRESSAO _________________________________________

static function i_impressao

   if ! qinitprn() ; return ; endif
   CGM->(dbseek(XCGM))
   @ prow()   ,01  say XCOND1
   @ prow()   ,75  say XCGCCPF
   @ prow()+02,75  say XRAZAO
   @ prow()+01,75  say left(XENDERECO,30) + XNUMERO + XCOMPL
   @ prow()+01,75  say XBAIRRO + " - " + XCEP
   @ prow()+01,75  say CGM->Municipio + " - " + CGM->Estado
   @ prow()   ,130 say XCGCCPF

   @ prow()+02,130 say "31/01/2003" + "            " + "2003"

   SIND->(dbseek(cSIND))
   CGM->(dbseek(SIND->Cgm))

   @ prow()+03,01 say SIND->Descricao
   @ prow()   ,130 say SIND->Cod_entid
   @ prow()+02,01 say SIND->Endereco
   @ prow()   ,130 say SIND->Cnpj
   @ prow()+02,01 say SIND->Bairro
   @ prow()   ,65 say SIND->Cep
   @ prow()   ,89 say CGM->Municipio
   @ prow()   ,150 say CGM->Estado

   CGM->(dbseek(XCGM))
   @ prow()+03,01  say XRAZAO
   @ prow()+02,01  say XENDERECO
   @ prow()   ,75  say XNUMERO
   @ prow()   ,85  say XCOMPL
   @ prow()   ,130 say dtoc(dDATA_INI)

   @ prow()+02,01  say XCEP
   @ prow()   ,31  say CGM->Municipio
   @ prow()   ,89  say XBAIRRO
   @ prow()   ,150 say CGM->Estado

   CNAE->(dbseek(CONFIG->Cnae))
   @ prow()+02,01 say left(CNAE->Descricao,35)
   @ prow()   ,42 say CNAE->Codigo

   @ prow()+03,04 say "X"

   @ prow() ,140 say transform(nCAM_42,"@E 9,999,999.99")


   @ prow()+02 ,25 say transform(nCAM_33,"@E 9,999,999.99")
   @ prow()    ,79 say transform(nCAM_38,"@E 999999999")
   @ prow()   ,140 say transform(nCAM_43,"@E 9,999,999.99")

   @ prow()+02 ,25 say transform(nCAM_34,"@E 9,999,999.99")
   @ prow()    ,76 say transform(nCAM_39,"@E 9,999,999.99")
   @ prow()   ,140 say transform(nCAM_44,"@E 9,999,999.99")

   @ prow()+02 ,25 say transform(nCAM_35,"@E 9,999,999.99")
   @ prow()    ,76 say transform(nCAM_40,"@E 9,999,999.99")
   @ prow()   ,140 say transform(nCAM_45,"@E 9,999,999.99")

   @ prow()+02 ,25 say transform(nCAM_36,"@E 9,999,999.99")
   @ prow()    ,76 say transform(nCAM_41,"@E 9,999,999.99")
   @ prow()   ,140 say transform(nCAM_46,"@E 9,999,999.99")

   @ prow()+02 ,25 say transform(nCAM_37,"@E 9,999,999.99")


   @ prow()+2,01  say "CURITIBA,                                    " + dtoc(date())

   qstopprn()

return
