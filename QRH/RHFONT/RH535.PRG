/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: REQUERIMENTO DE SEGURO-DESEMPREGO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS ____________

local bESCAPE    := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

private lCONF
private sBLOC1   := qlbloc("B535B","QBLOC.GLO")

private cMATRICULA           // matricula p/ impressao individual
private aEDICAO  := {}       // vetor para os campos de entrada de dados
private nTOTSAL  := 0.00     // soma dos tres ultimos salarios
private nVALOR1  := 0.00     // valor do antepenultimo mes/ano
private nVALOR2  := 0.00     // valor do penultimo mes/ano
private nVALOR3  := 0.00     // valor do ultimo mes/ano
private cMESANO1 := "  /    "  // antepenultimo mes/ano
private cMESANO2 := "  /    "  // penultimo mes/ano
private cMESANO3 := "  /    "  // ultimo mes/ano
private nMES36   := 0        // meses trabalhados nos ultimos 36 meses
private cTIPO    := " "

private sBLOCO1 := qlbloc("B535C","QBLOC.GLO") // ordem de classificacao


do case
   case month(XDATASYS) = 2
        cMESANO3 := "12/" + right(str(year(XDATASYS)-1),4)
   case month(XDATASYS) = 1
        cMESANO3 := "11/" + right(str(year(XDATASYS)-1),4)
   other
        cMESANO3 := strzero(month(XDATASYS)-2,2) + "/" + right(str(year(XDATASYS)),4)
endcase

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// RELACAO DE ARQUIVOS ______________________________________________________

LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO     ,sBLOCO1)} , "TIPO"    })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA,sBLOC1)}         ,"MATRICULA"})
aadd(aEDICAO,{{ || NIL },NIL})   // nome do funcionario
aadd(aEDICAO,{{ || qgetx(-1,0,@cMESANO3  ,"99/9999"        )} ,"MESANO3"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@cMESANO2  ,"99/9999"        )} ,"MESANO2"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@cMESANO1  ,"99/9999"        )} ,"MESANO1"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR3   ,"@E 9,999,999.99")} ,"VALOR3"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR2   ,"@E 9,999,999.99")} ,"VALOR2"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR1   ,"@E 9,999,999.99")} ,"VALOR1"   })
aadd(aEDICAO,{{ || NIL },NIL})   // plota total dos tre meses
aadd(aEDICAO,{{ || qgetx(-1,0,@nMES36    ,"99")}              ,"MES36"    })
aadd(aEDICAO,{{ || lCONF := qconf("Confirma impress„o ?")},NIL})

do while .T.

   qlbloc(5,0,"B535A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   cGRUPO     := space(4)
   cTIPO      := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! empty(cMATRICULA) .or. ! empty(cGRUPO)
      i_impressao()
   endif

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   if XFLAG
      do case
         case cCAMPO == "MATRICULA"
              if ! empty(cMATRICULA)
                 qrsay(XNIVEL,cMATRICULA := strzero(val(cMATRICULA),6))
                 if ! FUN->(dbseek(cMATRICULA))
                    qmensa("Funcionario n„o encontrado...","B")
                    return .F.
                 endif
                 if FUN->Situacao <> "D"
                    qmensa("Funcionario n„o esta demitido...","B")
                    return .F.
                 endif
                 qrsay(++XNIVEL,left(FUN->Nome,30))
                 SITUA->(dbseek(FUN->Matricula))
              else
                 qmensa("Campo MATRICULA ‚ obrigat¢rio !","B")
                 return .F.
              endif

              nVALOR2 := nVALOR3 := nTOTSAL := 0.00

              qrsay(++XNIVEL,cMESANO3)

              if left(cMESANO3,2) == "12"
                 cMESANO2 := "01/" + strzero(val(right(cMESANO3,4))+1,4)
              else
                 cMESANO2 := strzero(val(left(cMESANO3,2))+1,2) + "/" + right(cMESANO3,4)
              endif

              qrsay(++XNIVEL,cMESANO2)

              if left(cMESANO2,2) == "12"
                 cMESANO1 := "01/" + strzero(val(right(cMESANO2,4))+1,4)
              else
                 cMESANO1 := strzero(val(left(cMESANO2,2))+1,2) + "/" + right(cMESANO2,4)
              endif

              qrsay(++XNIVEL,cMESANO1)

              qmensa("Aguarde... Levantando Valores...")

              if LANC->(dbseek(right(cMESANO3,4)+left(cMESANO3,2)+FUN->Matricula))
                 do while ! LANC->(eof()) .and. LANC->Matricula == cMATRICULA .and. ;
                                   LANC->Anomes == right(cMESANO3,4)+left(cMESANO3,2)
                    if EVENT->Finalidade == "P" .and. ((LANC->Ambiente == "MS" .and. EVENT->Inssms == "S");
                                                 .or.  (LANC->Ambiente == "FR" .and. EVENT->Inssfr == "S"))
                       do case
                          case LANC->Anomes == right(cMESANO3,4)+left(cMESANO3,2)
                               nVALOR3 += LANC->Valor
                       endcase
                    endif
                    LANC->(dbskip())
                 enddo
              endif

              if LANC->(dbseek(right(cMESANO2,4)+left(cMESANO2,2)+FUN->Matricula))
                 do while ! LANC->(eof()) .and. LANC->Matricula == cMATRICULA .and. ;
                                   LANC->Anomes == right(cMESANO2,4)+left(cMESANO2,2)
                    if EVENT->Finalidade == "P" .and. ((LANC->Ambiente == "MS" .and. EVENT->Inssms == "S");
                                                 .or.  (LANC->Ambiente == "FR" .and. EVENT->Inssfr == "S"))
                       do case
                          case LANC->Anomes == right(cMESANO2,4)+left(cMESANO2,2)
                               nVALOR2 += LANC->Valor
                       endcase
                    endif
                    LANC->(dbskip())
                 enddo
              endif

              nVALOR1 := SITUA->Salario
              qsay(14,27,transform(nVALOR3,"@E 9,999,999.99"))
              qsay(14,40,transform(nVALOR2,"@E 9,999,999.99"))
              qsay(14,53,transform(nVALOR1,"@E 9,999,999.99"))
              nTOTSAL := nVALOR3 + nVALOR2 + nVALOR1
              qsay(17,50,transform(nTOTSAL,"@E 9,999,999.99"))
         case cCAMPO == "VALOR3"
              nTOTSAL := nVALOR3 + nVALOR2 + nVALOR1
              qsay(17,50,transform(nTOTSAL,"@E 9,999,999.99"))
         case cCAMPO == "VALOR2"
              nTOTSAL := nVALOR3 + nVALOR2 + nVALOR1
              qsay(17,50,transform(nTOTSAL,"@E 9,999,999.99"))
         case cCAMPO == "VALOR1"
              nTOTSAL := nVALOR3 + nVALOR2 + nVALOR1
              qsay(17,50,transform(nTOTSAL,"@E 9,999,999.99"))

         case cCAMPO == "TIPO"
              if empty(cTIPO) ; return .F. ; endif
              qrsay(XNIVEL,qabrev(cTIPO,"BF",{"Bloco","Formul rio Cont¡nuo"}))

      endcase
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! lCONF
      return
   endif

   if ! qinitprn() ; return ; endif
   
   if FUN->(dbseek(cMATRICULA)) .and. FUN->Data_adm < qfimmes(XDATASYS)
      i_emite()
   endif

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO PRE-IMPRESSO ________________________________________________

static function i_emite
  if cTIPO == "F"
     i_formulario()
  else
     i_bloco()
  endif

return

static function i_formulario
   local cSERIE := FUN->Cp_serie

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,30))
   setprc(0,0)

   @ prow()+3,0        say XCOND0

   @ prow()+3,4        say qintchr(alltrim(left(FUN->Nome,37)))

   @ prow()+3,4        say qintchr(left(FUN->Nome_mae,37))

   @ prow()+3,4        say qintchr(left(FUN->Endereco,37))

   @ prow()+3,4        say qintchr(left(FUN->Bairro,14))

   @ prow(),pcol()+3   say qintchr(left(FUN->Cep,5)) + "   " + qintchr(right(FUN->Cep,3))

   CGM->(dbseek(FUN->Resid_cgm))

   @ prow(),pcol()+3   say qintchr(CGM->Estado) + "   " + qintchr(FUN->Telefone)

   @ prow()+3,4        say qintchr(FUN->Pis_num)

   CGM->(dbseek(FUN->Cp_cgm))

   if right(cSERIE,2) == "  "
      cSERIE := left(cSERIE,3)
   else
      cSERIE := right(cSERIE,3)
   endif

   @ prow(),pcol()+5   say qintchr(strzero(val(FUN->Cp_num),7)+cSERIE+CGM->Estado)

   @ prow(),pcol()+5   say qintchr(qtiraponto(FUN->Cpf_num))

   FILIAL->(dbseek(FUN->Filial))


   @ prow()+3,12       say FILIAL->Tipo_insc

   @ prow(),pcol()+4   say qintchr(FILIAL->Cgccpf)

   @ prow(),pcol()+4   say qintchr(left(qtiraponto(CONFIG->Cnae),5))

   @ prow(),pcol()+4   say XCOND1 + XAEXPAN + FILIAL->Cgccpf + XDEXPAN + XCOND0

   @ prow()+1,61       say XCOND2 + left(FILIAL->Razao,34) + XCOND0

   @ prow()+1,61       say XCOND2 + rtrim(left(FILIAL->Endereco,32)) +", "+str(FILIAL->numero,5) + XCOND0

   CBO->(dbseek(SITUA->Cbo))
   CARGO->(Dbseek(SITUA->Cargo))
   @ prow()+1,4        say qintchr(qtiraponto(left(SITUA->Cbo,4)))+" - "+qintchr(right(SITUA->Cbo,2))+ " " + left(CARGO->Descricao,36)
   @ prow(),pcol()+07  say XCOND2 + transform(FILIAL->Cep,"@R 99.999-999") + XCOND0

   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,61       say XCOND2 + alltrim(CGM->Municipio) + " - " + CGM->Estado + XCOND0



set century off
   @ prow()+5,4        say qintchr(qtiraponto(FUN->Data_adm))
   @ prow(),pcol()+4   say qintchr(qtiraponto(SITUA->Af_ini))
set century on

   @ prow(),pcol()+12  say iif(FUN->Sexo=="M","1","2")

   @ prow(),pcol()+11   say FUN->Instrucao
set century off
   @ prow(),pcol()+4   say qintchr(qtiraponto(FUN->Data_nasc))
set century on
   @ prow(),pcol()+4   say qintchr(strzero(FUN->Hor_sema,2))

   @ prow()+3,4        say qintchr(left(cMESANO3,2)) + "  " + qintchr(qtiraponto(transform(nVALOR3,"@E 99999999.99")))

   @ prow(),pcol()+2   say qintchr(left(cMESANO2,2)) + "  " + qintchr(qtiraponto(transform(nVALOR2,"@E 99999999.99")))

   @ prow(),pcol()+2   say qintchr(left(cMESANO1,2)) + "  " + qintchr(qtiraponto(transform(nVALOR1,"@E 99999999.99")))

   // SOMA DOS ULTIMOS 3 SALARIOS + DOMICILIO BANCARIO ______________________

   @ prow()+3,4        say qintchr(str(nTOTSAL*100,10))

   @ prow(),pcol()+9   say qintchr("10414818")

   @ prow(),pcol()+30   say qintchr(strzero(nMES36,2))


   // FINAL _________________________________________________________________

   LANC->(dbseek(right(cMESANO1,4)+left(cMESANO1,2)+FUN->Matricula+"MS150"))

   @ prow()+3,24  say "1"

   @ prow(),pcol()+18  say + iif(LANC->Valor<>0,"1","2")

  // @ prow()+30,4 say qintchr(FUN->Pis_num)

  // @ prow()+3 ,4 say qintchr(alltrim(left(FUN->Nome,50)))

   @ prow()+27,00 say " "

return


static function i_Bloco
   local cSERIE := FUN->Cp_serie

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,30))
   setprc(0,0)

   @ prow()+3,0        say XCOND0 + XQLINHA

   @ prow()+4,4        say qintchr(alltrim(left(FUN->Nome,37)))

   @ prow()+4,4        say qintchr(left(FUN->Nome_mae,37))

   @ prow()+4,4        say qintchr(left(FUN->Endereco,37))

   @ prow()+4,4        say qintchr(left(FUN->Bairro,14))

   @ prow(),pcol()+3   say qintchr(left(FUN->Cep,5)) + "  " + qintchr(right(FUN->Cep,3))

   CGM->(dbseek(FUN->Resid_cgm))

   @ prow(),pcol()+2   say qintchr(CGM->Estado) + "  " + qintchr(FUN->Telefone)

   @ prow()+4,4        say qintchr(FUN->Pis_num)

   CGM->(dbseek(FUN->Cp_cgm))

   if right(cSERIE,2) == "  "
      cSERIE := left(cSERIE,3)
   else
      cSERIE := right(cSERIE,3)
   endif

   @ prow(),pcol()+4   say qintchr(strzero(val(FUN->Cp_num),7)+cSERIE+CGM->Estado)

   @ prow(),pcol()+3   say qintchr(qtiraponto(FUN->Cpf_num))

   FILIAL->(dbseek(FUN->Filial))


   @ prow()+5,13       say FILIAL->Tipo_insc

   @ prow(),pcol()+2   say qintchr(FILIAL->Cgccpf)

   @ prow(),pcol()+2   say qintchr(left(qtiraponto(CONFIG->Cnae),5))

   @ prow(),pcol()+2   say XCOND1 + XAEXPAN + FILIAL->Cgccpf + XDEXPAN + XCOND0

   @ prow()+1,57       say XCOND2 + left(FILIAL->Razao,34) + XCOND0

   @ prow()+1,57       say XCOND2 + rtrim(left(FILIAL->Endereco,32)) +", "+str(FILIAL->numero,5) + XCOND0

   @ prow()+1,57  say XCOND2 + transform(FILIAL->Cep,"@R 99.999-999") + XCOND0

   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,57       say XCOND2 + alltrim(CGM->Municipio) + " - " + CGM->Estado + XCOND0


   CBO->(dbseek(SITUA->Cbo))
   CARGO->(Dbseek(SITUA->Cargo))
   @ prow()+1,4        say qintchr(qtiraponto(left(SITUA->Cbo,4)))+" - "+qintchr(right(SITUA->Cbo,2))+ " " + left(CARGO->Descricao,36)


set century off
   @ prow()+7,4        say qintchr(qtiraponto(FUN->Data_adm))
   @ prow(),pcol()+3   say qintchr(qtiraponto(SITUA->Af_ini))
set century on

   @ prow(),pcol()+10  say iif(FUN->Sexo=="M","1","2")

   @ prow(),pcol()+8   say FUN->Instrucao
set century off
   @ prow(),pcol()+4   say qintchr(qtiraponto(FUN->Data_nasc))
set century on
   @ prow(),pcol()+4   say qintchr(strzero(FUN->Hor_sema,2))

   @ prow()+4,3        say qintchr(left(cMESANO3,2)) + "  " + qintchr(qtiraponto(transform(nVALOR3,"@E 9999999.99")))

   @ prow(),pcol()+3   say qintchr(left(cMESANO2,2)) + "  " + qintchr(qtiraponto(transform(nVALOR2,"@E 999999.99")))

   @ prow(),pcol()+3   say qintchr(left(cMESANO1,2)) + " " + qintchr(qtiraponto(transform(nVALOR1,"@E 9999999.99")))

   // SOMA DOS ULTIMOS 3 SALARIOS + DOMICILIO BANCARIO ______________________

   @ prow()+4,3        say qintchr(str(nTOTSAL*100,10))

   @ prow(),pcol()+5   say qintchr("10414818")

   @ prow(),pcol()+26   say qintchr(strzero(nMES36,2))


   // FINAL _________________________________________________________________

   LANC->(dbseek(right(cMESANO1,4)+left(cMESANO1,2)+FUN->Matricula+"MS150"))

   @ prow()+4,21  say "1"

   @ prow(),pcol()+18  say + iif(LANC->Valor<>0,"1","2")

   @ prow()+27,00 say " " + XRESET

return

