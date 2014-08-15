/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: INFORME DE RENDIMENTOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1996
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE    := {||(XNIVEL==1 .and. !XFLAG) .or. (XNIVEL==1 .and. lastkey()==27)}

private sBLOCO1    := qlbloc("B583A","QBLOC.GLO") // bloco tipo de relatorio

private cANOBASE   := space(4)
private cMATRICULA              // matricula p/ impressao individual
private cRESP      := space(38) // nome do reponsavel
private aEDICAO    := {}        // vetor para os campos de entrada de dados
private cTITULO    := "COMPROVANTE DE RENDIMENTOS PAGOS E DE RETENCAO DE IR NA FONTE"
private cTITULO2   := "ANO CALENDARIO "

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA )}, "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || qgetx(-1,0,@cRESP  , "@!" )}, "RESP"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@cANOBASE, "@9")}, "ANOBASE"   })

do while .T.

   qlbloc(5,0,"B583A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_impressao()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "MATRICULA"
           if ! empty(cMATRICULA)
              qrsay(XNIVEL,cMATRICULA := strzero(val(cMATRICULA),6))
              if ! FUN->(dbseek(cMATRICULA))
                 qmensa("Funcion rio nao encontrado...","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(FUN->Nome,30))
              endif
           else
              qrsay(XNIVEL+1,"*** Todos os funcion rios ***")
           endif
      case cCAMPO == "RESP"
           if empty(cRESP)
              qmensa("Campo RESPONSAVEL ‚ obrigat¢rio...","B")
              return .F.
           endif
      case cCAMPO == "ANOBASE"
           if empty(cANOBASE)
              qmensa("Campo ANO BASE ‚ obrigat¢rio...","B")
              return .F.
           endif
           cTITULO2 := "ANO CALENDARIO "+cANOBASE
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRESSAO ____________________________________________________

static function i_impressao
   local nTOTREND := nCONTPREV := nPENSAO := nIRRF := nSALFAM := nDECTERC := 0
   local dDTINI   := ctod("01/01/" + right(cANOBASE,4))
   local dDTFIM   := ctod("31/12/" + right(cANOBASE,4))
   local nLUCRO   := 0
   local nCONTA   := 0
   local nTOT_UNIMED := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   if ! empty(cMATRICULA)
      FUN->(dbseek(cMATRICULA))
   else
      FUN->(dbgotop())
   endif

   do while ! FUN->(eof()) .and. qcontprn()     // condicao principal de loop

      BASE->(dbseek(FUN->Matricula + right(cANOBASE,4)))

      SITUA->(Qseekn(FUN->Matricula))
      if SITUA->Vinculo == "G"
         FUN->(DbSkip())
         Loop
      endif

      if ! BASE->(eof())
         do while ! BASE->(eof()) .and. BASE->Matricula == FUN->Matricula .and. left(BASE->Anomes,4) == right(cANOBASE,4)
            nTOTREND  += BASE->B_irrfms + BASE->B_irrffr + BASE->V_inssms + BASE->V_inssfr
            nCONTPREV += BASE->V_inssms + BASE->V_inssfr //+ BASE->V_inss13 + BASE->V_inssdt
            nPENSAO   += BASE->Pensao_jud
            nIRRF     += BASE->V_irrfms + BASE->V_irrffr //+ BASE->V_irrf13 + BASE->V_irrfdt
            nSALFAM   += BASE->V_salfam

//          nDECTERC  += BASE->B_inss13 + BASE->B_inssdt - BASE->V_irrf13 - BASE->V_irrfdt - BASE->V_inss13 - BASE->V_inssdt - nPENSAO

            nDECTERC  += BASE->B_irrf13 + BASE->B_irrfdt

            BASE->(dbskip())
         enddo

         for nCONTA = 1 to 12
             LANC->(dbseek(left(cANOBASE,4) + strzero(nCONTA,2) + FUN->Matricula))
             do while LANC->Anomes == left(cANOBASE,4) + strzero(nCONTA,2) .and. LANC->Matricula == FUN->Matricula

                if LANC->Evento $ "621-623-624"
                   nTOT_UNIMED += LANC->Valor
                endif

                LANC->(dbskip())

             enddo
         next



         nTOTREND    := round(nTOTREND,2)
         nCONTPREV   := round(nCONTPREV,2)
         nPENSAO     := round(nPENSAO,2)
         nIRRF       := round(nIRRF,2)
         nSALFAM     := round(nSALFAM,2)
         nDECTERC    := round(nDECTERC,2)
         nTOT_UNIMED := round(nTOT_UNIMED,2)
         qmensa("Funcion rio: "+FUN->Matricula+" / "+left(FUN->Nome,30))

         if ! qlineprn() ; return ; endif

         if XPAGINA == 0 .or. prow() > K_MAX_LIN
            qpageprn()
            qcabecprn(cTITULO,132,,cTITULO2)
         endif

         CGM->(dbseek(XCGM))
   
         @ prow()+2,000 say "1 - FONTE PAGADORA PESSOA JURIDICA OU PESSOA FISICA"
         @ prow()+1,005 say "Nome Empresarial/Nome.: "+ XRAZAO+ "   "+ "CGC/CPF: "  + XCGCCPF
         @ prow()+2,000 say repl("-",132)

         @ prow()+2,000 say "2 - PESSOA FISICA BENEFICIARIA DOS RENDIMENTOS"
         @ prow()+1,005 say "CPF.: "+ transf(FUN->CPf_num,"@R 999.999.999-99")+ "   "+ "Nome Completo.: " + left(FUN->Nome,30)
         @ prow()+1,005 say "NATUREZA DO RENDIMENTO: Rendimentos do Trabalho Assalariado"

         @ prow()+2,000 say repl("-",132)

         @ prow()+2,000 say "3 - RENDIMENTOS TRIBUTAVEIS, DEDUCOES E IMPOSTO RETIDO NA FONTE"
         @ prow()+1,005 say "01 - Total dos Rendimentos (inclusive ferias)............................................................R$"
         @ prow()  ,115 say transform(nTOTREND,"@E 9,999,999.99")
         @ prow()+1,005 say "02 - Contribuicao Previdenciaria Oficial.................................................................R$"
         @ prow()  ,115 say transform(nCONTPREV,"@E 9,999,999.99")
         @ prow()+1,005 say "03 - Contribuicao a Previdencia Privada e ao Fundo de Aposentadoria Programada Individual - FAPI.........R$"
         @ prow()  ,115 say transform(0,"@E 9,999,999.99")

         @ prow()+1,005 say "04 - Pensao Judicial (informar o beneficiario no quadro 06)..............................................R$"
         @ prow()  ,115 say transform(nPENSAO,"@E 9,999,999.99")
         @ prow()+1,005 say "05 - Imposto Retido na Fonte.............................................................................R$"
         @ prow()  ,115 say transform(nIRRF,"@E 9,999,999.99")

         @ prow()+2,000 say repl("-",132)

         @ prow()+2,000 say "4 - RENDIMENTOS ISENTOS E NAO TRIBUTAVEIS"
         @ prow()+1,005 say "01 - Parcela Isenta dos Proventos de Aposentadoria, Reserva, Reforma e Pensao (65 anos ou mais)..........R$"
         @ prow()  ,115 say transform(0.00,"@E 9,999,999.99")
         @ prow()+1,005 say "02 - Diarias e Ajudas de Custo...........................................................................R$"
         @ prow()  ,115 say transform(0.00,"@E 9,999,999.99")
         @ prow()+1,005 say "03 - Pensao, Prov. de Aposent. ou Reforma por Molestia Grave e Aposent. ou Reforma por Acid. em Servico..R$"
         @ prow()  ,115 say transform(0.00,"@E 9,999,999.99")
         @ prow()+1,005 say "04 - Lucro e Dividendo Apurado a partir de 1996 pago por PJ(Lucro Real,Presumido ou Arbitrado)...........R$"
         @ prow()  ,115 say transform(0.00,"@E 9,999,999.99")
         @ prow()+1,005 say "05 - Valores Pagos ao Titular ou Socio de Microempresa ou Empresa de Pequeno Porte, exceto Pro-labore,     "
         @ prow()+1,005 say "Alugueis ou Servicos Prestados...........................................................................R$"
         @ prow()  ,115 say transform(0.00,"@E 9,999,999.99")
         @ prow()+1,005 say "06 - Indenizacoes por rescisao de contarto de trabalho,inclusive a titulo de PDV, e acid. de trabalho....R$"
         @ prow()  ,115 say transform(0.00,"@E 9,999,999.99")
         @ prow()+1,005 say "07 - Outros (especificar)................................................................................R$"
         @ prow()  ,115 say transform(0.00,"@E 9,999,999.99")

         nLUCRO := jficha(dDTINI,dDTFIM,"MS","125","V","S")

//         if empty(nLUCRO)
//            @ prow()+1,005 say "05 - Outros .............................................................................................R$"
//            @ prow()  ,115 say transform(0.00,"@E 9,999,999.99")
//         else
//            @ prow()+1,005 say "05 - Outros (Lucro Presumido)............................................................................R$"
//            @ prow()  ,115 say transform(nLUCRO,"@E 9,999,999.99")
//         endif

         @ prow()+2,000 say repl("-",132)

         @ prow()+2,000 say "5 - RENDIMENTOS SUJEITOS A TRIBUTACAO EXCLUSIVA (RENDIMENTO LIQUIDO)"
         @ prow()+1,005 say "01 - Decimo Terceiro Salario.............................................................................R$"
         @ prow()  ,115 say transform(nDECTERC,"@E 9,999,999.99")
         @ prow()+1,005 say "02 - Outros .............................................................................................R$"
         @ prow()  ,115 say transform(0.00,"@E 9,999,999.99")

         @ prow()+2,000 say repl("-",132)

         @ prow()+2,000 say "6 - INFORMACOES COMPLEMENTARES"
         if nTOT_UNIMED > 0
            @ prow()+1,000 say "01 - Assistencia Medica (UniMed).........................................................................R$"
            @ prow()  ,115 say transform(nTOT_UNIMED,"@E 9,999,999.99")
         else
            @ prow()+1,000 say ""
         endif

         @ prow()+4,000 say repl("-",132)

         @ prow()+2,000 say "7 - RESPONSAVEL PELAS INFORMACOES"
         @ prow()+1,005 say "NOME: " + cRESP
         @ prow()+2,005 say "DATA:   /     /     "
         @ prow()  ,040 say "ASSINATURA:____________________________________________________________________________ "
      endif

      nTOTREND := nTOT_UNIMED := nCONTPREV := nPENSAO := nIRRF := nSALFAM := nDECTERC := 0

      if ! empty(cMATRICULA)
         exit
      endif

      FUN->(dbskip())

   enddo

   qstopprn()

return

