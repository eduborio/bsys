/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DO RECIBO DE FERIAS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1994
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. (XNIVEL==1 .and. lastkey()==27) .or. empty(cTIPO)}

private cMATRICULA             // matricula p/ impressao individual
private cCENTRO                // centro de custo p/ impressao geral
private cGRUPO                 // grupo de funcionarios
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cTIPO                  // tipo = "pre-impresso ou formulario"
private nFALTAS := 0           // numero de faltas para ferias
private nVIAS   := 1           // numero de vias para impressao
private dDT_AVISO := ctod("")  // data de aviso de f‚rias
private dDT_RECIB := ctod("")  // data de recibo de f‚rias

private sBLOC1  := qlbloc("B534B","QBLOC.GLO")

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// ESTABELECE RELACAO ENTRE OS ARQUIVOS _____________________________________

LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))
FUN->(dbSetRelation("LANC",{|| XANOMES+Matricula+"MS"},"XANOMES+Matricula+'MS'"))
FUN->(dbSetRelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))
SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
SITUA->(dbSetRelation("AFAST",{|| Af_cod},"Af_cod"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOC1)}        , "TIPO"      })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_grupoc(-1,0,@cGRUPO)}        , "GRUPO"     })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do grupo
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_AVISO)}           , "DT_AVISO"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_RECIB)}          , "DT_RECIBO"  })

do while .T.

   qlbloc(5,0,"B534A","QBLOC.GLO")
   qmensa()
   XNIVEL := 1
   XFLAG  := .T.
   cMATRICULA := space(6)
   cGRUPO     := space(4)
   cTIPO      := " "
   cCENTRO    := space(10)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! empty(cCENTRO)
      if ! qinitprn() ; return ; endif
      i_impcentro()
   endif

   if ! empty(cMATRICULA) .or. ! empty(cGRUPO)
      i_impressao()
   endif

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   if XFLAG
      do case
         case cCAMPO == "TIPO"
              qrsay(XNIVEL,qabrev(cTIPO,"PF",{"Pre-impresso","Formulario Continuo"}))
         case cCAMPO == "MATRICULA"
              if ! empty(cMATRICULA)
                 qrsay(XNIVEL,cMATRICULA := strzero(val(cMATRICULA),6))
                 if ! FUN->(dbseek(cMATRICULA)) .or. ! SITUA->(dbseek(cMATRICULA))
                    qmensa("Funcionario n„o encontrado...","B")
                    return .F.
                 endif
                 if FUN->Situacao <> "F"
                    qmensa("Funcionario n„o esta em f‚rias...","B")
                    return .F.
                 endif
                 qrsay(XNIVEL+1,left(FUN->Nome,30))
              endif
         case cCAMPO == "GRUPO"
              if ! empty(cGRUPO)
                 if ! GRUPOC->(dbseek(cGRUPO))
                    qmensa("Grupo nao encontrado...","B")
                    return .F.
                 else
                    qrsay(XNIVEL+1,GRUPOC->Descricao)
                 endif
              endif

         case cCAMPO == "CENTRO"
              if ! empty(cCENTRO)
                 if ! CCUSTO->(dbseek(cCENTRO))
                    qmensa("Centro de Custo nao encontrado...","B")
                    return .F.
                 else
                    qrsay(XNIVEL+1,left(CCUSTO->Descricao,20))
                 endif
              endif

         case cCAMPO == "DT_RECIBO"
           if cTIPO == "F" .and. empty(cCENTRO)
              XNIVEL+=1
              qgetx(-1,0,@nVIAS,"9")
           endif
      endcase
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! empty(cGRUPO)
      GRUPOV->(dbseek(cGRUPO))
      do while ! GRUPOV->(eof()) .and. GRUPOV->Codigo == cGRUPO
         if FUN->(dbseek(GRUPOV->Matricula)) .and. SITUA->(dbseek(cMATRICULA))
            FILIAL->(dbseek(FUN->Filial))
            if cTIPO=="P"
               i_emite_p()
            else
               for nCONT = 1 to nVIAS
                   i_emite_f()
               next
            endif
         endif
         GRUPOV->(dbskip())
      enddo
   else
      if FUN->(dbseek(cMATRICULA)) .and. SITUA->(dbseek(cMATRICULA))
         FILIAL->(dbseek(FUN->Filial))
         if cTIPO=="P"
            i_emite_p()
         else
            for nCONT = 1 to nVIAS
                if XCOD_PRN == "15"
                   i_emite_hp()
                else
                   i_emite_f()
                endif
            next
         endif
      endif
   endif

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO PRE-IMPRESSO ________________________________________________

static function i_emite_p
   local nLIQ := nABONO := nTOTPROV := nTOTDESC := 0
   local cKEY := XANOMES + FUN->Matricula + "FR"
   local cEXT

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,30))
   setprc(0,0)

   @ prow()+1,0        say XCOND1
   @ prow()+1,21       say left(FUN->Nome,60) + space(18) + FUN->Cp_num + space(18) + FUN->Cp_serie
   @ prow()+2,52       say CARGO->Descricao + "    " + dtoc(FUN->Data_adm) + space(17) + FUN->Matricula

   @ prow()+3,25        say strzero(day(SITUA->Di_ferias),2)
   @ prow()  ,pcol()+6  say qnomemes(SITUA->Di_ferias)
   @ prow()  ,pcol()+11 say strzero(year(SITUA->Di_ferias),4)
   @ prow()  ,pcol()+14 say strzero(day(SITUA->Df_ferias),2)
   @ prow()  ,pcol()+5  say qnomemes(SITUA->Df_ferias)
   @ prow()  ,pcol()+15 say strzero(year(SITUA->Df_ferias),4)

   if ! empty(SITUA->Bi_ferias) .and. ! empty(SITUA->Bf_ferias)
      @ prow()+2,25        say strzero(day(SITUA->Bi_ferias),2)
      @ prow()  ,pcol()+6  say qnomemes(SITUA->Bi_ferias)
      @ prow()  ,pcol()+11 say strzero(year(SITUA->Bi_ferias),4)
      @ prow()  ,pcol()+14 say strzero(day(SITUA->Bf_ferias),2)
      @ prow()  ,pcol()+5  say qnomemes(SITUA->Bf_ferias)
      @ prow()  ,pcol()+15 say strzero(year(SITUA->Bf_ferias),4)
   else
      @ prow()+2,25 say ""
   endif

   @ prow()+2,25        say strzero(day(SITUA->Af_ini),2)
   @ prow()  ,pcol()+6  say qnomemes(SITUA->Af_ini)
   @ prow()  ,pcol()+11 say strzero(year(SITUA->Af_ini),4)
   @ prow()  ,pcol()+14 say strzero(day(SITUA->Af_ret),2)
   @ prow()  ,pcol()+5  say qnomemes(SITUA->Af_ret)
   @ prow()  ,pcol()+15 say strzero(year(SITUA->Af_ret),4)

   // BUSCA FALTAS PARA FERIAS FERIAS _______________________________________

   nFALTAS := 0

   if LANC->(dbseek(cKEY+"225"))
      nFALTAS := LANC->Fracao
   endif
              
   @ prow()+3,25        say transform(nFALTAS,"999") + space(9)
   @ prow()  ,pcol()+10 say "R$ " + transform(SITUA->Salario,"@E 9,999.99")
   @ prow()  ,pcol()+40 say "R$ " + transform(SITUA->Salario,"@E 9,999.99")

   // FERIAS ________________________________________________________________

   LANC->(dbseek(cKEY+"180"))
   @ prow()+3,57       say transform(LANC->Valor,"@E 9,999.99")

   // ABONO PECUNIARIO ______________________________________________________

   LANC->(dbseek(cKEY+"191"))
   nABONO += LANC->Valor

   // 1/3 DO ABONO PECUNIARIO _______________________________________________

   LANC->(dbseek(cKEY+"192"))
   @ prow()+1,57       say transform(nABONO+LANC->Valor,"@E 9,999.99")

   // 1/3 DAS FERIAS ________________________________________________________

   LANC->(dbseek(cKEY+"181"))
   @ prow()+1,57       say transform(LANC->Valor,"@E 9,999.99")
   @ prow()  ,105      say transform(BASE->Prov_fr,"@E 9,999.99")

   // INSS SOBRE FERIAS _____________________________________________________

   LANC->(dbseek(cKEY+"911"))
   @ prow()+3,57       say transform(LANC->Valor,"@E 9,999.99")

   // IRRF SOBRE FERIAS _____________________________________________________

   LANC->(dbseek(cKEY+"921"))
   @ prow()+1,57       say transform(LANC->Valor,"@E 9,999.99")
   @ prow()+1,105      say transform(BASE->Desc_fr,"@E 9,999.99")

   // LIQUIDO A RECEBER _____________________________________________________

   nLIQ := BASE->Prov_fr - BASE->Desc_fr

   @ prow()+3,105      say transform(nLIQ,"@E 9,999.99")

   cEXT := qextenso(nLIQ)
   cEXT := pad(cEXT+" ",330,"x")

   @ prow()+3,21       say left(cEXT,110)
   @ prow()+1,21       say subs(cEXT,111,110)
   @ prow()+1,21       say subs(cEXT,221)
   @ prow()+2,100      say dtoc(dDT_AVISO)  // imprime data do aviso de ferias (informada)

   // EMPRESA + ENDERECO ____________________________________________________

   CGM->(dbseek(FILIAL->Cgm))

// @ prow()+13,17      say FILIAL->Razao
   @ prow()+11,17      say FILIAL->Razao
   @ prow()+1,4        say FILIAL->Endereco + space(53) + alltrim(CGM->Municipio) + "/" + CGM->Estado
   @ prow()+1,24       say transform(nLIQ,"@E 9,999.99")

   @ prow()+1,21       say left(cEXT,110)
   @ prow()+1,21       say subs(cEXT,111,110)
   @ prow()+1,21       say subs(cEXT,221)
   @ prow()+6,45       say dtoc(dDT_RECIB)  // imprime a data de recibo de ferias (informada)

// @ prow()+22,0       say "" // somente para saltar para o inicio do proximo recibo
   @ prow()+16,0       say "" // somente para saltar para o inicio do proximo recibo

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO EM FORMULARIO CONTINUO ______________________________________

static function i_emite_f
   local nLIQ    := nABONO := nTOTPROV := nTOTDESC := 0
   local cKEY    := XANOMES + FUN->Matricula + "FR"
   local cEXT
   local cLINHA1 := "*" + replicate("-",135) + "*"
   local cLINHA2 := "|" + space(135) + "|"
   local nCONTP  := nCONTD := 1
   local lDESC   := lPROV  := .T.
   local aPROV   := {{},{}}
   local aDESC   := {{},{}}

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)

   // CABECALHO INICIAL _____________________________________________________

   @ prow()+1,0        say XCOND1 + cLINHA1
   @ prow()+1,0        say XAENFAT + "|" + space(26) + XCOND0 + XAEXPAN + "AVISO E RECIBO DE FERIAS" + XDEXPAN + XCOND1 + space(25) + "|"
   @ prow()+1,0        say "|        CAPITULO VI - TITULO II DA C.L.T. - DEC.LEI.No. 5452 DE 01/05/1943, COM AS ALTERACOES DO DEC.LEI.No. 1535 DE 13/04/1977        |"
   @ prow()+1,0        say cLINHA1
   @ prow()+1,0        say "|" + space(30) + XCOND0 + XAEXPAN + "AVISO PREVIO DE FERIAS" + XDEXPAN + " " + XCOND1 + space(28) + "|"
   @ prow()+1,0        say "|                         DE ACORDO COM O ART. 135 DA C.L.T., PARTICIPANDO NO MINIMO COM 30 DIAS DE ANTECEDENCIA                        |"
   @ prow()+1,0        say cLINHA1

   // NOTIFICACAO E DADOS CADASTRAIS DO FUNCIONARIO _________________________

   @ prow()+1,0        say "|" + space(49) + XCOND0 + XAEXPAN + "NOTIFICACAO" + XDEXPAN + XCOND1 + space(48) + "|" + XDENFAT
   @ prow()+1,0        say cLINHA1
   @ prow()+1,0        say "|  Nome do empregado: " + XCOND0 + left(FUN->Nome,30) + XCOND1 + " |  No.Cart.Trabalho: "
   @ prow(),pcol()     say XCOND0 + FUN->Cp_num + XCOND1 + "     |  Serie: " + XCOND0 + FUN->Cp_serie + XCOND1 + "     |"
   @ prow()+1,0        say cLINHA1
// @ prow()+1,0        say "|  No. Registro: " + space(13) + "|  Cargo: " + XCOND0 + left(CARGO->Descricao,37) + XCOND1
   @ prow()+1,0        say "|  No. Registro: " + FUN->Matricula + space(7) + "|  Cargo: " + XCOND0 + left(CARGO->Descricao,37) + XCOND1
   @ prow(),pcol()     say " |Admitido em: " + XCOND0 + dtoc(FUN->Data_adm) + XCOND1 + "|"
   @ prow()+1,0        say cLINHA1

   // DESCRIMINACOES DOS PERIODOS ___________________________________________

   @ prow()+1,0        say "|  Periodo de Aquisicao..............: " + XCOND0 + pad(qdataexten(SITUA->Di_ferias) + " A " + qdataexten(SITUA->Df_ferias),56) + XCOND1 + " |"
   if empty(SITUA->Bi_ferias)
   @ prow()+1,0        say "|  Periodo do 1/3 de Abono Pecuniario: " + space(97) + "|"
   else
   @ prow()+1,0        say "|  Periodo do 1/3 de Abono Pecuniario: " + XCOND0 + pad(qdataexten(SITUA->Bi_ferias) + " A " + qdataexten(SITUA->Bf_ferias),56) + XCOND1 + " |"
   endif
   @ prow()+1,0        say "|  Periodo de Gozo das Ferias........: " + XCOND0 + pad(qdataexten(SITUA->Af_ini   ) + " A " + qdataexten(SITUA->Af_ret   ),56) + XCOND1 + " |"
   @ prow()+1,0        say cLINHA1

   // BASE DE CALCULO _______________________________________________________

   @ prow()+1,0        say XAENFAT + "|" + space(12) + XCOND0 + XAEXPAN + "BASE DE CALCULO PARA REMUNERACAO" + XDEXPAN + " " + XCOND1 + space(11) + "|" + XDENFAT
   @ prow()+1,0        say cLINHA1

   nFALTAS := 0

   if LANC->(dbseek(XANOMES+FUN->Matricula+"FR225"))  // BUSCA FALTAS PARA FERIAS (EVENTO 225)
      nFALTAS := LANC->Fracao
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"FR180"))  // BUSCA VALOR DAS FERIAS (EVENTO 180)
      nFERIAS := LANC->Valor
   endif

   @ prow()+1,0        say "|  Faltas nao justificadas: " + XCOND0 + space(2) + transform(nFALTAS,"99") + space(2) + XCOND1 + "  |  Salario Base: "
   @ prow(),pcol()     say XCOND0 + "R$ " + transform(SITUA->Salario,"@E 9,999.99") + XCOND1 + "           | Base de Calculo: "
   @ prow(),pcol()     say XCOND0 + "R$ " + transform(nFERIAS,"@E 9,999.99") + XCOND1 + "           |"
   @ prow()+1,0        say cLINHA1
   @ prow()+1,0        say XAENFAT + "|" + space(18) + XCOND0 + XAEXPAN + "PROVENTOS" + XDEXPAN + XCOND1 + space(18)
   @ prow(),pcol()     say "|" + space(18) + XCOND0 + XAEXPAN + "DEDUCOES " + XDEXPAN + XCOND1 + space(18) + "|" + XDENFAT
   @ prow()+1,0        say cLINHA1

   // PROVENTOS E DESCONTOS - CRIA VETORES E IMPRIME ________________________

   LANC->(dbseek(XANOMES+FUN->Matricula+"FR"))

   do while LANC->Anomes == XANOMES .and. LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "FR"
      if LANC->Valor <> 0.00
         do case
            case EVENT->Finalidade == "P"
                 aadd ( aPROV[1] , {LANC->Evento,left(EVENT->Descricao,34),LANC->Fracao,LANC->Valor} )
            case EVENT->Finalidade == "D"
                 aadd ( aDESC[1] , {LANC->Evento,left(EVENT->Descricao,34),LANC->Fracao,LANC->Valor} )
         endcase
      endif
      LANC->(dbskip())
   enddo

   @ prow()+1,000 say "| EVENTO DESCRICAO------------------------- REFERENCIA ------- VALOR EVENTO DESCRICAO------------------------- REFERENCIA ------- VALOR |"

   do while .T.
      if ! lPROV .and. ! lDESC
         exit
      endif
      @ prow()+1,0 say "|"
      if nCONTP <= len(aPROV[1])
         @ prow(),003 say aPROV[1,nCONTP,1]
         @ prow(),008 say aPROV[1,nCONTP,2]
         @ prow(),045 say aPROV[1,nCONTP,3]
         @ prow(),055 say aPROV[1,nCONTP,4]
         nCONTP++
      else
         lPROV := .F.
      endif

      if nCONTD <= len(aDESC[1])
         @ prow(),071 say aDESC[1,nCONTD,1]
         @ prow(),076 say aDESC[1,nCONTD,2]
         @ prow(),113 say aDESC[1,nCONTD,3]
         @ prow(),122 say aDESC[1,nCONTD,4]
         nCONTD++
      else
         lDESC := .F.
      endif
      @ prow(),136 say "|"
   enddo

   // TOTAIS ________________________________________________________________

   @ prow()+1,0        say cLINHA1
   @ prow()+1,0        say "|  T o t a l   d e   P r o v e n t o s...........: " + XCOND0 + transform(BASE->Prov_fr,"@E 9,999.99") + XCOND1 + "    "
   @ prow(),pcol()     say "|  T o t a l   d e   D e d u c o e s.............: " + XCOND0 + transform(BASE->Desc_fr,"@E 9,999.99") + XCOND1 + "  |"
   @ prow()+1,0        say cLINHA1

   nLIQ := BASE->Prov_fr - BASE->Desc_fr

   cEXT := qextenso(nLIQ)
   cEXT := pad(cEXT+" ",198,"x")
   cEXT := strtran(cEXT,"xx","x-")

   // COMUNICACAO E LIQUIDO POR EXTENSO _____________________________________

   @ prow()+1,0        say "|     Pelo presente comunicamos-lhe que, de acordo com a lei, ser-lhe-ao concedidas ferias relativas ao periodo acima descrito e a sua  |"
   @ prow()+1,0        say "|  disposicao fica a importancia liquida de R$ " + XCOND0 + transform(nLIQ,"@E 9,999.99") + XCOND1
   @ prow(),pcol()     say "   ( " + left(cEXT,68) + "  |"
   @ prow()+1,0        say "|  " + subs(cEXT,69) + ")  |"
   @ prow()+1,0        say "|  a ser paga adiantadamente." + space(107) + "|"
   @ prow()+1,0        say "|                                                                                                                                       |"
   @ prow()+1,0        say "|                                                                                                                                       |"
   @ prow()+1,0        say "| _________________,"+dtoc(dDT_AVISO)+"          _______________________________________________    ___________________________________________  |"
   @ prow()+1,0        say "|           Local e Data                         Assinatura do Empregado                            Assinatura do Empregador            |"

   // CABECALHO DO RECIBO DE FERIAS _________________________________________

   @ prow()+1,0        say cLINHA1
   @ prow()+1,0        say XAENFAT + "|" + space(40) + XCOND0 + XAEXPAN + "RECIBO DE FERIAS" + XDEXPAN + XCOND1 + space(40) + "|"
   @ prow()+1,0        say "|                                        DE ACORDO COM O PARAGRAFO UNICO DO ARTIGO 145 DA C.L.T.                                        |" + XDENFAT
   @ prow()+1,0        say "|     Recebi da firma " + FILIAL->Razao + "                               , estabelecida a  |"
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,0        say "|  " + FILIAL->Endereco + "      em       " + CGM->Municipio + "/" + CGM->Estado + "                                             |"
   @ prow()+1,0        say "|  a importancia de R$ " + XCOND0 + transform(nLIQ,"@E 9,999.99") + XCOND1
   @ prow(),pcol()     say "   ( " + left(cEXT,92) + "  |"
   @ prow()+1,0        say "|  " + subs(cEXT,69) + ")  |"
   @ prow()+1,0        say "|  que me e paga antecipadamente por motivo das minhas ferias regulamentares, ora concedidas e que vou gozar de acordo com a descricao  |"
   @ prow()+1,0        say "|  acima, tudo conforme o aviso que recebi em tempo, no qual dei o meu CIENTE.                                                          |"
   @ prow()+1,0        say "|     Para clareza e documento, firmo o presente recibo, dando a firma plena e geral quitacao.                                          |"
   @ prow()+1,0        say "|                                                                                                                                       |"
   @ prow()+1,0        say "|  _________________________________________,"+dtoc(dDT_RECIB)+"                 ______________________________________________________________  |"
   @ prow()+1,0        say "|                        Local e Data                                                        Assinatura do Empregado                    |"


   // OBSERVACAO FINAL ______________________________________________________

   @ prow()+1,0        say cLINHA1
   @ prow()+1,0        say XAENFAT + "|  OBSERVACOES: Paragrafo 1o. do Art. 135 da C.L.T.: O empregado nao podera entrar em gozo das  ferias sem que apresente ao empregador  |"
   @ prow()+1,0        say "|               sua carteira profissional, para que nela seja anotada a respectiva concessao.                                           |" + XDENFAT
   @ prow()+1,0        say cLINHA1

   __eject()

return

static function i_emite_hp
   local nLIQ    := nABONO := nTOTPROV := nTOTDESC := 0
   local cKEY    := XANOMES + FUN->Matricula + "FR"
   local cEXT
   local cLINHA1 := "*" + replicate("-",135) + "*"
   local cLINHA2 := "|" + space(135) + "|"
   local nCONTP  := nCONTD := 1
   local lDESC   := lPROV  := .T.
   local aPROV   := {{},{}}
   local aDESC   := {{},{}}

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)

   // CABECALHO INICIAL _____________________________________________________

   @ prow()+1,05        say XCOND1 + cLINHA1
   @ prow()+1,10        say XAENFAT + "|" + space(26) + XCOND0 + XAEXPAN + "AVISO E RECIBO DE FERIAS" + XDEXPAN + XCOND1 + space(29) + "|"
   @ prow()+1,10        say "|        CAPITULO VI - TITULO II DA C.L.T. - DEC.LEI.No. 5452 DE 01/05/1943, COM AS ALTERACOES DO DEC.LEI.No. 1535 DE 13/04/1977        |"
   @ prow()+1,10        say cLINHA1
   @ prow()+1,10        say "|" + space(30) + XCOND0 + XAEXPAN + "AVISO PREVIO DE FERIAS" + XDEXPAN + " " + XCOND1 + space(30) + "|"
   @ prow()+1,10        say "|                         DE ACORDO COM O ART. 135 DA C.L.T., PARTICIPANDO NO MINIMO COM 30 DIAS DE ANTECEDENCIA                        |"
   @ prow()+1,10        say cLINHA1

   // NOTIFICACAO E DADOS CADASTRAIS DO FUNCIONARIO _________________________

   @ prow()+1,10        say "|" + space(49) +XCOND0+ XAEXPAN + "NOTIFICACAO" + XDEXPAN  + XCOND1+space(49) + "|" + XDENFAT
   @ prow()+1,10        say cLINHA1
   @ prow()+1,10        say "|  Nome do empregado: " + XCOND0 + left(FUN->Nome,30) + XCOND1 + " |  No.Cart.Trabalho: "
   @ prow(),pcol()     say XCOND0 + FUN->Cp_num + XCOND1 + "     |  Serie: " + XCOND0 + FUN->Cp_serie + XCOND1 + "       |"
   @ prow()+1,10        say cLINHA1
// @ prow()+1,10        say "|  No. Registro: " + space(13) + "|  Cargo: " + XCOND0 + left(CARGO->Descricao,37) + XCOND1
   @ prow()+1,10        say "|  No. Registro: " + FUN->Matricula + space(7) + "|  Cargo: " + XCOND0 + left(CARGO->Descricao,37) + XCOND1
   @ prow(),pcol()     say " |Admitido em: " + XCOND0 + dtoc(FUN->Data_adm) + XCOND1 + "   |"
   @ prow()+1,10        say cLINHA1

   // DESCRIMINACOES DOS PERIODOS ___________________________________________

   @ prow()+1,10        say "|  Periodo de Aquisicao..............: " +  pad(qdataexten(SITUA->Di_ferias) + " A " + qdataexten(SITUA->Df_ferias),56) +space(37)+ "    |"
   if empty(SITUA->Bi_ferias)
   @ prow()+1,10        say "|  Periodo do 1/3 de Abono Pecuniario: " + space(97) + "|"
   else
   @ prow()+1,10        say "|  Periodo do 1/3 de Abono Pecuniario: " + pad(qdataexten(SITUA->Bi_ferias) + " A " + qdataexten(SITUA->Bf_ferias),56) + " |"
   endif
   @ prow()+1,10        say "|  Periodo de Gozo das Ferias........: "  + pad(qdataexten(SITUA->Af_ini   ) + " A " + qdataexten(SITUA->Af_ret   ),56) +space(37)+  "    |"
   @ prow()+1,10        say cLINHA1

   // BASE DE CALCULO _______________________________________________________

   @ prow()+1,10        say XAENFAT + "|" + space(12) + XCOND0 + XAEXPAN + "BASE DE CALCULO PARA REMUNERACAO" + XDEXPAN + " " + XCOND1 + space(15) + "|" + XDENFAT
   @ prow()+1,10        say cLINHA1

   nFALTAS := 0

   if LANC->(dbseek(XANOMES+FUN->Matricula+"FR225"))  // BUSCA FALTAS PARA FERIAS (EVENTO 225)
      nFALTAS := LANC->Fracao
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"FR180"))  // BUSCA VALOR DAS FERIAS (EVENTO 180)
      nFERIAS := LANC->Valor
   endif

   @ prow()+1,10        say "|  Faltas nao justificadas: " + XCOND0 + space(2) + transform(nFALTAS,"99") + space(2) + XCOND1 + "  |  Salario Base: "
   @ prow(),pcol()     say XCOND0 + "R$ " + transform(SITUA->Salario,"@E 9,999.99") + XCOND1 + "           | Base de Calculo: "
   @ prow(),pcol()     say XCOND0 + "R$ " + transform(nFERIAS,"@E 9,999.99") + XCOND1 + "            |"
   @ prow()+1,10        say cLINHA1
   @ prow()+1,10        say XAENFAT + "|" + space(18) + XCOND0 + XAEXPAN + "PROVENTOS" + XDEXPAN + XCOND1 + space(18)
   @ prow(),pcol()     say "|" + space(18) + XCOND0 + XAEXPAN + "DEDUCOES " + XDEXPAN + XCOND1 + space(20) + "|" + XDENFAT
   @ prow()+1,10        say cLINHA1

   // PROVENTOS E DESCONTOS - CRIA VETORES E IMPRIME ________________________

   LANC->(dbseek(XANOMES+FUN->Matricula+"FR"))

   do while LANC->Anomes == XANOMES .and. LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "FR"
      if LANC->Valor <> 0.00
         do case
            case EVENT->Finalidade == "P"
                 aadd ( aPROV[1] , {LANC->Evento,left(EVENT->Descricao,34),LANC->Fracao,LANC->Valor} )
            case EVENT->Finalidade == "D"
                 aadd ( aDESC[1] , {LANC->Evento,left(EVENT->Descricao,34),LANC->Fracao,LANC->Valor} )
         endcase
      endif
      LANC->(dbskip())
   enddo

   @ prow()+1,0010 say "| EVENTO DESCRICAO------------------------- REFERENCIA ------- VALOR EVENTO DESCRICAO------------------------- REFERENCIA ------- VALOR |"

   do while .T.
      if ! lPROV .and. ! lDESC
         exit
      endif
      @ prow()+1,10 say "|"
      if nCONTP <= len(aPROV[1])
         @ prow(),013 say aPROV[1,nCONTP,1]
         @ prow(),018 say aPROV[1,nCONTP,2]
         @ prow(),055 say aPROV[1,nCONTP,3]
         @ prow(),065 say aPROV[1,nCONTP,4]
         nCONTP++
      else
         lPROV := .F.
      endif

      if nCONTD <= len(aDESC[1])
         @ prow(),081 say aDESC[1,nCONTD,1]
         @ prow(),086 say aDESC[1,nCONTD,2]
         @ prow(),123 say aDESC[1,nCONTD,3]
         @ prow(),132 say aDESC[1,nCONTD,4]
         nCONTD++
      else
         lDESC := .F.
      endif
      @ prow(),146 say "|"
   enddo

   // TOTAIS ________________________________________________________________

   @ prow()+1,10        say cLINHA1
   @ prow()+1,10        say "|  T o t a l   d e   P r o v e n t o s...........: " + XCOND0 + transform(BASE->Prov_fr,"@E 9,999.99") + XCOND1 + "    "
   @ prow(),pcol()     say "|  T o t a l   d e   D e d u c o e s.............: " + XCOND0 + transform(BASE->Desc_fr,"@E 9,999.99") + XCOND1 + "   |"
   @ prow()+1,10        say cLINHA1

   nLIQ := BASE->Prov_fr - BASE->Desc_fr

   cEXT := qextenso(nLIQ)
   cEXT := pad(cEXT+" ",198,"x")
   cEXT := strtran(cEXT,"xx","x-")

   // COMUNICACAO E LIQUIDO POR EXTENSO _____________________________________

   @ prow()+1,10        say "|     Pelo presente comunicamos-lhe que, de acordo com a lei, ser-lhe-ao concedidas ferias relativas ao periodo acima descrito e a sua  |"
   @ prow()+1,10        say "|  disposicao fica a importancia liquida de R$ " +  transform(nLIQ,"@E 9,999.99")
   @ prow(),pcol()     say "   ( " + left(cEXT,68) + "        |"
   @ prow()+1,10        say "|  " + subs(cEXT,69) + ")  |"
   @ prow()+1,10        say "|  a ser paga adiantadamente." + space(107) + "|"
   @ prow()+1,10        say "|                                                                                                                                       |"
   @ prow()+1,10        say "|                                                                                                                                       |"
   @ prow()+1,10        say "| _________________,"+dtoc(dDT_AVISO)+"          _______________________________________________    ___________________________________________  |"
   @ prow()+1,10        say "|           Local e Data                         Assinatura do Empregado                            Assinatura do Empregador            |"

   // CABECALHO DO RECIBO DE FERIAS _________________________________________

   @ prow()+1,10        say cLINHA1
   @ prow()+1,10        say XAENFAT + "|" + space(40) + XCOND0 + XAEXPAN + "RECIBO DE FERIAS" + XDEXPAN + XCOND1 + space(40) +XCOND2+" "+XCOND1+ " |"
   @ prow()+1,10        say "|                                        DE ACORDO COM O PARAGRAFO UNICO DO ARTIGO 145 DA C.L.T.                                        |" + XDENFAT
   @ prow()+1,10        say "|     Recebi da firma " + FILIAL->Razao + "                               , estabelecida a  |"
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,10        say "|  " + FILIAL->Endereco + "      em       " + CGM->Municipio + "/" + CGM->Estado + "                                             |"
   @ prow()+1,10        say "|  a importancia de R$ " + transform(nLIQ,"@E 9,999.99")
   @ prow(),pcol()     say "   ( " + left(cEXT,92) + "        |"
   @ prow()+1,10        say "|  " + subs(cEXT,69) + ")  |"
   @ prow()+1,10        say "|  que me e paga antecipadamente por motivo das minhas ferias regulamentares, ora concedidas e que vou gozar de acordo com a descricao  |"
   @ prow()+1,10        say "|  acima, tudo conforme o aviso que recebi em tempo, no qual dei o meu CIENTE.                                                          |"
   @ prow()+1,10        say "|     Para clareza e documento, firmo o presente recibo, dando a firma plena e geral quitacao.                                          |"
   @ prow()+1,10        say "|                                                                                                                                       |"
   @ prow()+1,10        say "|  _________________________________________,"+dtoc(dDT_RECIB)+"                 ______________________________________________________________  |"
   @ prow()+1,10        say "|                        Local e Data                                                        Assinatura do Empregado                    |"


   // OBSERVACAO FINAL ______________________________________________________

   @ prow()+1,10        say cLINHA1
   @ prow()+1,10        say XAENFAT + "|  OBSERVACOES: Paragrafo 1o. do Art. 135 da C.L.T.: O empregado nao podera entrar em gozo das  ferias sem que apresente ao empregador  |"
   @ prow()+1,10        say "|               sua carteira profissional, para que nela seja anotada a respectiva concessao.                                           |" + XDENFAT
   @ prow()+1,10        say cLINHA1

   __eject()

return



/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impcentro

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   local nLIQ
   local cKEY
   local cEXT
   local cLINHA1
   local cLINHA2
   local nCONTP
   local lDESC
   local aPROV
   local aDESC

   FUN->(dbsetorder(1))
   FUN->(dbgotop())

   do while ! FUN->(eof())

      nLIQ    := nABONO := nTOTPROV := nTOTDESC := 0
      cKEY    := XANOMES + FUN->Matricula + "FR"
      cLINHA1 := "*" + replicate("-",135) + "*"
      cLINHA2 := "|" + space(135) + "|"
      nCONTP  := nCONTD := 1
      lDESC   := lPROV  := .T.
      aPROV   := {{},{}}
      aDESC   := {{},{}}

      if ! SITUA->(dbseek(FUN->Matricula))
         FUN->(dbskip())
         loop
      endif

      if SITUA->Ccusto <> cCENTRO .and. FUN->Situacao <> "F"
         FUN->(dbskip())
         loop
      endif

      qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))

      setprc(0,0)

       // CABECALHO INICIAL _____________________________________________________

       @ prow()+1,0        say XCOND1 + cLINHA1
       @ prow()+1,0        say XAENFAT + "|" + space(26) + XCOND0 + XAEXPAN + "AVISO E RECIBO DE FERIAS" + XDEXPAN + XCOND1 + space(27) + "|"
       @ prow()+1,0        say "|        CAPITULO VI - TITULO II DA C.L.T. - DEC.LEI.No. 5452 DE 01/05/1943, COM AS ALTERACOES DO DEC.LEI.No. 1535 DE 13/04/1977        |"
       @ prow()+1,0        say cLINHA1
       @ prow()+1,0        say "|" + space(30) + XCOND0 + XAEXPAN + "AVISO PREVIO DE FERIAS" + XDEXPAN + " " + XCOND1 + space(28) + "|"
       @ prow()+1,0        say "|                         DE ACORDO COM O ART. 135 DA C.L.T., PARTICIPANDO NO MINIMO COM 30 DIAS DE ANTECEDENCIA                        |"
       @ prow()+1,0        say cLINHA1

       // NOTIFICACAO E DADOS CADASTRAIS DO FUNCIONARIO _________________________

       @ prow()+1,0        say "|" + space(49) + XCOND0 + XAEXPAN + "NOTIFICACAO" + XDEXPAN + XCOND1 + space(48) + "|" + XDENFAT + XCOND1
       @ prow()+1,0        say cLINHA1
       @ prow()+1,0        say "|  Nome do empregado: " + XCOND0 + left(FUN->Nome,30) + XCOND1 + " |  No.Cart.Trabalho: "
       @ prow(),pcol()     say XCOND0 + FUN->Cp_num + XCOND1 + "     |  Serie: " + XCOND0 + FUN->Cp_serie + XCOND1 + "       |"
       @ prow()+1,0        say cLINHA1
    // @ prow()+1,0        say "|  No. Registro: " + space(13) + "|  Cargo: " + XCOND0 + left(CARGO->Descricao,37) + XCOND1
       @ prow()+1,0        say "|  No. Registro: " + FUN->Matricula + space(7) + "|  Cargo: " + XCOND0 + left(CARGO->Descricao,37) + XCOND1
       @ prow(),pcol()     say " |  Admitido em: " + XCOND0 + dtoc(FUN->Data_adm) + XCOND1 + "  |"
       @ prow()+1,0        say cLINHA1

       // DESCRIMINACOES DOS PERIODOS ___________________________________________

       @ prow()+1,0        say "|  Periodo de Aquisicao..............: " + XCOND0 + pad(qdataexten(SITUA->Di_ferias) + " A " + qdataexten(SITUA->Df_ferias),56) + XCOND1 + " |"
       if empty(SITUA->Bi_ferias)
       @ prow()+1,0        say "|  Periodo do 1/3 de Abono Pecuniario: " + space(97) + "|"
       else
       @ prow()+1,0        say "|  Periodo do 1/3 de Abono Pecuniario: " + XCOND0 + pad(qdataexten(SITUA->Bi_ferias) + " A " + qdataexten(SITUA->Bf_ferias),56) + XCOND1 + " |"
       endif
       @ prow()+1,0        say "|  Periodo de Gozo das Ferias........: " + XCOND0 + pad(qdataexten(SITUA->Af_ini   ) + " A " + qdataexten(SITUA->Af_ret   ),56) + XCOND1 + " |"
       @ prow()+1,0        say cLINHA1

       // BASE DE CALCULO _______________________________________________________

       @ prow()+1,0        say XAENFAT + "|" + space(12) + XCOND0 + XAEXPAN + "BASE DE CALCULO PARA REMUNERACAO" + XDEXPAN + " " + XCOND1 + space(12) + "|" + XDENFAT
       @ prow()+1,0        say cLINHA1

       nFALTAS := 0

       if LANC->(dbseek(XANOMES+FUN->Matricula+"FR225"))  // BUSCA FALTAS PARA FERIAS (EVENTO 225)
          nFALTAS := LANC->Fracao
       endif

       @ prow()+1,0        say "|  Faltas nao justificadas: " + XCOND0 + space(2) + transform(nFALTAS,"99") + space(2) + XCOND1 + "  |  Salario Base: "
       @ prow(),pcol()     say XCOND0 + "R$ " + transform(SITUA->Salario,"@E 9,999.99") + XCOND1 + "           | Base de Calculo: "
       @ prow(),pcol()     say XCOND0 + "R$ " + transform(SITUA->Salario,"@E 9,999.99") + XCOND1 + "           |"
       @ prow()+1,0        say cLINHA1
       @ prow()+1,0        say XAENFAT + "|" + space(18) + XCOND0 + XAEXPAN + "PROVENTOS" + XDEXPAN + XCOND1 + space(18)
       @ prow(),pcol()     say "|" + space(18) + XCOND0 + XAEXPAN + "DEDUCOES " + XDEXPAN + XCOND1 + space(18) + "|" + XDENFAT
       @ prow()+1,0        say cLINHA1

       // PROVENTOS E DESCONTOS - CRIA VETORES E IMPRIME ________________________

       LANC->(dbseek(XANOMES+FUN->Matricula+"FR"))

       do while LANC->Anomes == XANOMES .and. LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "FR"
          if LANC->Valor <> 0.00
             do case
                case EVENT->Finalidade == "P"
                     aadd ( aPROV[1] , {LANC->Evento,left(EVENT->Descricao,34),LANC->Fracao,LANC->Valor} )
                case EVENT->Finalidade == "D"
                     aadd ( aDESC[1] , {LANC->Evento,left(EVENT->Descricao,34),LANC->Fracao,LANC->Valor} )
             endcase
          endif
          LANC->(dbskip())
       enddo

       @ prow()+1,000 say "| EVENTO DESCRICAO------------------------- REFERENCIA ------- VALOR EVENTO DESCRICAO------------------------- REFERENCIA ------- VALOR |"

       do while .T.
          if ! lPROV .and. ! lDESC
             exit
          endif
          @ prow()+1,0 say "|"
          if nCONTP <= len(aPROV[1])
             @ prow(),003 say aPROV[1,nCONTP,1]
             @ prow(),008 say aPROV[1,nCONTP,2]
             @ prow(),045 say aPROV[1,nCONTP,3]
             @ prow(),055 say aPROV[1,nCONTP,4]
             nCONTP++
          else
             lPROV := .F.
          endif

          if nCONTD <= len(aDESC[1])
             @ prow(),071 say aDESC[1,nCONTD,1]
             @ prow(),076 say aDESC[1,nCONTD,2]
             @ prow(),113 say aDESC[1,nCONTD,3]
             @ prow(),122 say aDESC[1,nCONTD,4]
             nCONTD++
          else
             lDESC := .F.
          endif
          @ prow(),136 say "|"
       enddo

       // TOTAIS ________________________________________________________________

       @ prow()+1,0        say cLINHA1
       @ prow()+1,0        say "|  T o t a l   d e   P r o v e n t o s...........: " + XCOND0 + transform(BASE->Prov_fr,"@E 9,999.99") + XCOND1 + "    "
       @ prow(),pcol()     say "|  T o t a l   d e   D e d u c o e s.............: " + XCOND0 + transform(BASE->Desc_fr,"@E 9,999.99") + XCOND1 + "   |"
       @ prow()+1,0        say cLINHA1

       nLIQ := BASE->Prov_fr - BASE->Desc_fr

       cEXT := qextenso(nLIQ)
       cEXT := pad(cEXT+" ",198,"x")
       cEXT := strtran(cEXT,"xx","x-")

       // COMUNICACAO E LIQUIDO POR EXTENSO _____________________________________

       @ prow()+1,0        say "|     Pelo presente comunicamos-lhe que, de acordo com a lei, ser-lhe-ao concedidas ferias relativas ao periodo acima descrito e a sua  |"
       @ prow()+1,0        say "|  disposicao fica a importancia liquida de R$ " + XCOND0 + transform(nLIQ,"@E 9,999.99") + XCOND1
       @ prow(),pcol()     say "   ( " + left(cEXT,68) + "  |"
       @ prow()+1,0        say "|  " + subs(cEXT,69) + ")  |"
       @ prow()+1,0        say "|  a ser paga adiantadamente." + space(107) + "|"
       @ prow()+1,0        say "|                                                                                                                                       |"
       @ prow()+1,0        say "|                                                                                                                                       |"
       @ prow()+1,0        say "| _________________,"+dtoc(dDT_AVISO)+"          _______________________________________________    _____________________________________________  |"
       @ prow()+1,0        say "|           Local e Data                         Assinatura do Empregado                            Assinatura do Empregador            |"

       // CABECALHO DO RECIBO DE FERIAS _________________________________________

       @ prow()+1,0        say cLINHA1
       @ prow()+1,0        say XAENFAT + "|" + space(40) + XCOND0 + XAEXPAN + "RECIBO DE FERIAS" + XDEXPAN + XCOND1 + space(40) + "|"
       @ prow()+1,0        say "|                                        DE ACORDO COM O PARAGRAFO UNICO DO ARTIGO 145 DA C.L.T.                                        |" + XDENFAT
       @ prow()+1,0        say "|     Recebi da firma " + FILIAL->Razao + "                               , estabelecida a  |"
       CGM->(dbseek(FILIAL->Cgm))
       @ prow()+1,0        say "|  " + FILIAL->Endereco + "      em       " + CGM->Municipio + "/" + CGM->Estado + "                                   |"
       @ prow()+1,0        say "|  a importancia de R$ " + XCOND0 + transform(nLIQ,"@E 9,999.99") + XCOND1
       @ prow(),pcol()     say "   ( " + left(cEXT,92) + "  |"
       @ prow()+1,0        say "|  " + subs(cEXT,69) + ")  |"
       @ prow()+1,0        say "|  que me e paga antecipadamente por motivo das minhas ferias regulamentares, ora concedidas e que vou gozar de acordo com a descricao  |"
       @ prow()+1,0        say "|  acima, tudo conforme o aviso que recebi em tempo, no qual dei o meu CIENTE.                                                          |"
       @ prow()+1,0        say "|     Para clareza e documento, firmo o presente recibo, dando a firma plena e geral quitacao.                                          |"
       @ prow()+1,0        say "|                                                                                                                                       |"
       @ prow()+1,0        say "|                                                                                                                                       |"
       @ prow()+1,0        say "|  ___________________________________________,"+dtoc(dDT_RECIB)+"                 ______________________________________________________________  |"
       @ prow()+1,0        say "|                        Local e Data                                                        Assinatura do Empregado                    |"


       // OBSERVACAO FINAL ______________________________________________________

       @ prow()+1,0        say cLINHA1
       @ prow()+1,0        say XAENFAT + "|  OBSERVACOES: Paragrafo 1o. do Art. 135 da C.L.T.: O empregado nao podera entrar em gozo das  ferias sem que apresente ao empregador  |"
       @ prow()+1,0        say "|               sua carteira profissional, para que nela seja anotada a respectiva concessao.                                           |" + XDENFAT
       @ prow()+1,0        say cLINHA1

       __eject()

       FUN->(dbskip())

   enddo

   qstopprn(.F.)

return
