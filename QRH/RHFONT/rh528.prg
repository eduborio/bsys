////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DA GUIA DE INSS (GPS)
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1994
// OBS........:
// ALTERACOES.:

#include "rh.ch"
#include "inkey.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   nCONT

private sBLOCO1   := qlbloc("B514B","QBLOC.GLO") // bloco ambiente

private lPAUSA    := .T.
private cLOCALIMP := ""
private cMENSA1
private cMENSA2
private nAUTO
private cAMBIENTE := "M"
private cANOMES
private cMESANO   := right(XANOMES,2) + left(XANOMES,4)
private cPAGTO    := space(4)  // codigo de pagamento
private cCLASSE   := space(2)
private cFUN      := space(6)
private nJUROS    := 0
qmensa("<Pressione ESC para Cancelar>")

// LOOP INICIAL PARA PERMANECER DENTRO DA OPCAO _____________________________

do while .T.

   qesco(08,15,@cAMBIENTE,sBLOCO1)

   if lastkey() == K_ESC ; exit ; endif

   qsay(08,15,qabrev(cAMBIENTE,"M1",{"Mensal","13. Sal rio"}))

   if lastkey() == K_ESC ; exit ; endif

   qgetx(08,39,@cMESANO,"@R 99/9999")

   if lastkey() == K_ESC ; exit ; endif

   cANOMES  := right(cMESANO,4) + left(cMESANO,2)

   view_pagto(08,70,@cPAGTO,"9999")

   if lastkey() == K_ESC ; exit ; endif

   if ! quse(XDRV_RH,"FUN"       ,{"FU_GRPS","FU_MATRI"},"R") ; return .F. ; endif
   if cPAGTO == "1007"
      qmensa("Informe a classe de 1 a 10 conforme Tabela INSS Autonomos","B")
      qgetx(09,27,@cCLASSE,"@!")
      qmensa("")
      view_fun(09,44,@cFUN)
      FUN->(dbsetorder(2))
      FUN->(dbseek(cFUN))
      qsay(09,53,left(FUN->Nome,10))
   endif
   qgetx(10,27,@nJUROS,"@E 999,999.99")

   cLOCALIMP := ""

   // VAI FAZER SELECAO DE EMPRESAS ? _______________________________________

   private aEMP := qmarcaemp()

   if lastkey() == K_ESC ; exit ; endif

   // REALIZA PAUSA P/ SOLICITAR DADOS INDIVIDUAIS ? ________________________

   if alert("Quer informar Valor p/ Aut“nomos;e mensagens individualmente ?",{"SIM","NŽO"}) == 2
      lPAUSA := .F.
   endif

   if lastkey() == K_ESC ; loop ; endif

   // ACIONA IMPRESSOES _____________________________________________________

   if cPAGTO == "1007"
      if ! quse(XDRV_RH,"TBIA") ; return .F. ; endif
      TBIA->(dbSetFilter({|| Anomes == cANOMES},"Anomes == cANOMES"))
      i_onorario()
      TBIA->(dbclosearea())
      FUN->(dbclosearea())
   else
      if empty(aEMP)
         i_guia_emi()
      else
         for nCONT := 1 to len(aEMP)
             qseldirect(aEMP[nCONT])
             i_guia_emi()
         next
      endif
   endif

enddo

return

/////////////////////////////////////////////////////////////////////////////
// EMISSAO DAS GUIAS SELECIONADAS ___________________________________________

function i_guia_emi

   local lEMISSAO_OK := .T.

   // ABRE OS ARQUIVOS MANUALMENTE __________________________________________

   if ! quse(XDRV_RH,"SITUA"     ,{"SI_MATRI"},"R") ; return .F. ; endif
   if ! quse(XDRV_RH,"BASE"      ,{"BA_MATRI"},"R") ; return .F. ; endif
   if ! quse(XDRV_RH,"LANC"      ,{"LA_MATRI"},"R") ; return .F. ; endif
   if ! quse(XDRV_RH,"GRPS"      ,{"GR_CODIG"},"R") ; return .F. ; endif
   if ! quse(XDRV_RH,"GPS_ACU"   ,{"GPSA_COD"}) ; return .F. ; endif
   if ! quse(XDRV_RH,"CONFIG") ; return .F. ; endif
   
   SITUA->(dbSetFilter({|| Anomes == cANOMES},"Anomes == cANOMES"))

   GRPS->(dbSetFilter({|| Anomes == cANOMES},"Anomes == cANOMES"))

   
   // RELACIONAMENTO ________________________________________________________

   FUN->(dbSetRelation( "BASE" , {|| Matricula+cANOMES}, "Matricula+cANOMES" ))

//   GRPS->(dbSetRelation( "FUN" , {|| Codigo}, "Codigo" ))

   GRPS->(dbgotop())
   GRPS->(dbseek(cANOMES+"9999"))

   // LOOP DE GRPS E SOLICITACAO DE DADOS ___________________________________

   qrsay(1,XRAZAO)
   qrsay(2,GRPS->Descricao)

   XNIVEL  := 3
   nAUTO   := 0
   cMENSA1 := GRPS->Mensa_1
   cMENSA2 := GRPS->Mensa_2

   if lPAUSA
      qgetx(-1,0,@nAUTO,"@E 999,999.99")
      if lastkey() == K_ESC
         lEMISSAO_OK := .F.
         keyboard chr(13)+chr(13)
      endif
      XNIVEL++
      qgetx(-1,0,@cMENSA1)
      if lastkey() == K_ESC
         lEMISSAO_OK := .F.
         keyboard chr(13)
      endif
      XNIVEL++
      qgetx(-1,0,@cMENSA2)
      if lastkey() == K_ESC
         lEMISSAO_OK := .F.
      endif
   endif

//   if ! lEMISSAO_OK ; exit ; endif

   i_emissao()   // emissao de guia individual...


   // FECHA OS ARQUIVOS MANUALMENTE E RETORNA _______________________________

   FUN->(dbclosearea())
   SITUA->(dbclosearea())
   BASE->(dbclosearea())
   LANC->(dbclosearea())
   GRPS->(dbclosearea())
   CONFIG->(dbclosearea())
   GPS_ACU->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// EMISSAO DO GPS ___________________________________________________________

static function i_emissao

   local nTOTSEG := nTOTEMP := nTOTTER := nTOTDED :=nTOTSAT:= nTOTLIQ := 0

   local nSOMA, nQUANTFUN := nTBASE1 := nTBASE2 := 0

   local cCOMPET, cPIC := "@E 9,999,999.99"
   local cTITULO := space(80)
   cCOMPET := subs(cANOMES,5,1) + subs(cANOMES,6,1) + "/"
   cCOMPET += Left(cANOMES,4)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn(0,cLOCALIMP) ; return ; endif
   qmensa("imprimindo...")

   if empty(cLOCALIMP)
      cLOCALIMP := XLOCALIMP
   endif

   // LOOP NOS FUNCIONARIOS PARA TOTALIZACOES _______________________________

   do while ! FUN->(eof()) //.and. FUN->Grps == GRPS->Codigo
      SITUA->(dbseek(FUN->Matricula))

      qgirabarra()

      qmensa("Aguarde...Verificando dados para impress„o...")

      // SALTA FUNCIONARIOS HOMOLOGADOS OU ADMITIDOS POSTERIORMENTE _________

      if SITUA->Situacao $ " H" .or. FUN->Data_Adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         loop
      endif

      if SITUA->Vinculo $ "G"
         FUN->(dbskip())
         loop
      endif

      // SALTA FUNCIONARIOS TRANSFERIDOS PARA OUTRA EMPRESA _________________

      if SITUA->Af_cod == "40"
         FUN->(dbskip())
         loop
      endif

      // SOMA QUANTIDADE DE FUNCIONARIOS ATIVOS _____________________________

      if SITUA->Vinculo <> K_DIRETOR
         nQUANTFUN++
      endif

      // TOTALIZA BASE ______________________________________________________

      // FUNCIONARIO AFASTADO POR LICENCA MATERNIDADE_________________________
      // QUANDO EMPRESA NAO OPTANTE PELO SIMPLES SOMA NA BASE OS PERCENTUAIS DA EMPRESA, ACID. TRABALHO
      // E TOTAL DE TERCEIROS_________________________________________________

//      if SITUA->Af_cod == "03"
//         nTBASE1 += iif(SITUA->Categoria <> "5",SITUA->Salario,SITUA->Salario * FUN->Hor_trab)
//      endif

      if SITUA->Af_cod == "FR" .and. LANC->(dbseek(cANOMES+FUN->Matricula+"MS103"))
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS161"))
            nTBASE1 += LANC->Valor
         endif
      endif

      if LANC->(dbseek(cANOMES+FUN->Matricula+"MS105"))
         if cAMBIENTE == "M"
              nTBASE2 += LANC->Valor
         //   nTBASE1 += LANC->Valor
         else
            nTBASE2 := 0.00
         endif
      else
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS106"))
            if cAMBIENTE == "M"
               nTBASE2 += LANC->Valor
            else
               nTBASE2 := 0.00
            endif
         else
            if cAMBIENTE == "M"
               nTBASE1 += BASE->T_inssms + BASE->T_inssfr + BASE->T_inssdt
            else
               nTBASE1 += BASE->T_inss13
            endif
         endif
      endif

      // TOTALIZA VALOR DESCONTADO EM FOLHA _________________________________

      if cAMBIENTE == "M"
         nTOTSEG += BASE->V_inssms + BASE->V_inssfr + BASE->V_inssdt
      else
         nTOTSEG += BASE->V_inss13
      endif

      // TOTALIZA VALOR A DESCONTAR NA GUIA _________________________________
      
      if cAMBIENTE == "M"
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS901")) // SAL.FAM. DO MES
            nTOTDED += LANC->Valor
         endif

         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS902")) // SAL.FAM. MESES ANT.
            nTOTDED += LANC->Valor
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS161")) // SAL. MATERNIDADE MENSAL
            nTOTDED += LANC->Valor //- nVALOR
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS281")) // SAL. MATERNIDADE HORA/AULA CURSINHO
            nTOTDED += LANC->Valor //- nVALOR
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS282")) // SAL. MATERNIDADE HORA/AULA R1
            nTOTDED += LANC->Valor //- nVALOR
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS283")) // SAL. MATERNIDADE HORA/AULA R2
            nTOTDED += LANC->Valor //- nVALOR
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS284")) // SAL. MATERNIDADE HORA/AULA R2-1
            nTOTDED += LANC->Valor //- nVALOR
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS285")) // SAL. MATERNIDADE HORA/AULA R2-2
            nTOTDED += LANC->Valor //- nVALOR
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS286")) // SAL. MATERNIDADE HORA/AULA R3
            nTOTDED += LANC->Valor //- nVALOR
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS287")) // SAL. MATERNIDADE HORA/AULA S1
            nTOTDED += LANC->Valor //- nVALOR
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS288")) // SAL. MATERNIDADE HORA/AULA S2
            nTOTDED += LANC->Valor //- nVALOR
         endif

//         nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS289")) // SAL. MATERNIDADE HORA/AULA TST
            nTOTDED += LANC->Valor //- nVALOR
         endif

         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS290")) // DSR SOBRE SALARIO MATERNIDADE HORA/AULA
            nTOTDED += LANC->Valor
         endif

         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS291")) // PRODUTIVIDADE SOBRE SALARIO MATERNIDADE HORA/AULA
            nTOTDED += LANC->Valor
         endif

         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS292")) // HORA ATIVIDADE SOBRE SALARIO MATERNIDADE HORA/AULA
            nTOTDED += LANC->Valor
         endif

         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS480")) // AUXILIO NATALIDADE
            nTOTDED += LANC->Valor
         endif

         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS413")) // ADICIONAL PERICULOSIDADE SOBRE SALARIO MATERNIDADE
            nTOTDED += LANC->Valor
         endif

         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS422")) // ADICIONAL DEINSALUBRIDADE SOBRE SALARIO MATERNIDADE
            nTOTDED += LANC->Valor
         endif

      endif

      FUN->(dbskip())

   enddo

   qmensa()

   // TOTALIZA AUTONOMOS, EMPRESA E TERCEIROS _______________________________
   cTITULO := "INFORMACOES P/ INSS - " + left(cMESANO,2) + "/" + right(cMESANO,4)
   nTOTEMP := nTBASE1 * GRPS->Perc_empr / 100
   nTOTEMP += nTBASE2 * GRPS->Perc_prol / 100
   nTOTEMP += nAUTO   * GRPS->Perc_auto / 100
   nTBASE2 += nAUTO
   nTOTTER := nTBASE1 * GRPS->Perc_terc / 100
   nTOTSAT := nTBASE1 * GRPS->Perc_acid / 100

   // APLICA ROUND PARA EVITAR PROBLEMAS DE ERRO NA SOMA ____________________

   nTOTSEG := round(nTOTSEG,2)
   nTOTEMP := round(nTOTEMP,2)
   nTOTTER := round(nTOTTER,2)
   nTOTSAT := round(nTOTSAT,2)
   nTOTDED := round(nTOTDED,2)

   if CONFIG->Gr_simples == "S"
      nACUMULA := nTOTSEG - nTOTDED
   else
      nACUMULA := nTOTSEG + nTOTEMP + nTOTTER - nTOTDED
   endif
   
   if nACUMULA <= 29.00   // se a guia for menor que R$ 29,00 acumula

      if ! GPS_ACU->(dbseek(GRPS->Codigo))  // senao achar grava o valor do mes e nao imprime

         if CONFIG->Verif_grps == .F.

            if GPS_ACU->(qappend())
               if GPS_ACU->(qrlock()) .and. CONFIG->(qrlock())
                  if CONFIG->Gr_simples == "N"
                     replace GPS_ACU->Cod_gps    with GRPS->Codigo
                     replace GPS_ACU->Valor_acum with nACUMULA
                     replace GPS_ACU->Tot_seg    with nTOTSEG
                     replace GPS_ACU->Tot_emp    with nTOTEMP
                     replace GPS_ACU->Tot_ter    with nTOTTER
                     replace GPS_ACU->Tot_ded    with nTOTDED
                     replace GPS_ACU->Tot_sal    with nTBASE1
                  else
                     replace GPS_ACU->Cod_gps    with GRPS->Codigo
                     replace GPS_ACU->Valor_acum with nACUMULA
                     replace GPS_ACU->Tot_seg    with nTOTSEG
                     replace GPS_ACU->Tot_ded    with nTOTDED
                     replace GPS_ACU->Tot_sal    with nTBASE1
                  endif
               endif
               replace CONFIG->Verif_grps  with .T.
               GPS_ACU->(qunlock())
               CONFIG->(qunlock())
            else
               qm1();return
            endif

         else
            qmensa("A guia da GPS j  foi emitida neste mˆs...")
         endif

         qmensa("Esta Guia ‚ menor que R$ 29,00 !!","B")

         nACUMULA := 0

         return

      else

         if (GPS_ACU->Valor_acum + nACUMULA) <= 29.00 .and. (GPS_ACU->Valor_acum + nACUMULA) > 0 // se achar e a soma nao chegar no valor acumula e nao imprime

            if CONFIG->Verif_grps == .F.

               if GPS_ACU->(qrlock()) .and. CONFIG->(qrlock())
                  if CONFIG->Gr_simples == "N"
                     replace GPS_ACU->Valor_acum with ( GPS_ACU->Valor_acum + nACUMULA )
                     replace GPS_ACU->Tot_seg    with ( GPS_ACU->Tot_seg + nTOTSEG)
                     replace GPS_ACU->Tot_emp    with ( GPS_ACU->Tot_emp + nTOTEMP)
                     replace GPS_ACU->Tot_ter    with ( GPS_ACU->Tot_ter + nTOTTER)
                     replace GPS_ACU->Tot_ded    with ( GPS_ACU->Tot_ded + nTOTDED)
                     replace GPS_ACU->Tot_sal    with ( GPS_ACU->Tot_sal + nTBASE1)
                  else
                     replace GPS_ACU->Valor_acum with ( GPS_ACU->Valor_acum + nACUMULA )
                     replace GPS_ACU->Tot_seg    with ( GPS_ACU->Tot_seg + nTOTSEG)
                     replace GPS_ACU->Tot_ded    with ( GPS_ACU->Tot_ded + nTOTDED)
                     replace GPS_ACU->Tot_sal    with ( GPS_ACU->Tot_sal + nTBASE1)
                  endif
                  replace CONFIG->Verif_grps  with .T.
                  GPS_ACU->(qunlock())
                  CONFIG->(qunlock())
               else
                  qm1();return
               endif

            else
               qmensa("A guia da GRPS j  foi emitida neste mˆs...")
            endif

            qmensa("Esta Guia ‚ menor que R$ 29,00 !!","B")

            nACUMULA := 0

            return


         else  // se achar e a soma chegar no valor imprime o valor acumulado e zera o acumulo gerado

            nACUMULA := GPS_ACU->Valor_acum

            nTOTSEG  += GPS_ACU->Tot_seg
            nTOTEMP  += GPS_ACU->Tot_emp
            nTOTTER  += GPS_ACU->Tot_ter
            nTOTDED  += GPS_ACU->Tot_ded
            nTBASE1  += GPS_ACU->Tot_sal

            if GPS_ACU->(qrlock())
               replace GPS_ACU->Valor_acum with 0
               replace GPS_ACU->Tot_seg    with 0
               replace GPS_ACU->Tot_emp    with 0
               replace GPS_ACU->Tot_ter    with 0
               replace GPS_ACU->Tot_ded    with 0
               replace GPS_ACU->Tot_sal    with 0
               GPS_ACU->(qunlock())
            endif

         endif

      endif

   else  // se a guia for maior que R$ 29,00 e achar valor acumulado, soma, imprime e zera o acumulo gerado

      if GPS_ACU->(dbseek(GRPS->Codigo))

         nACUMULA := GPS_ACU->Valor_acum

         nTOTSEG  += GPS_ACU->Tot_seg
         nTOTDED  += GPS_ACU->Tot_ded
         nTOTEMP  += GPS_ACU->Tot_emp
         nTOTTER  += GPS_ACU->Tot_ter
         nTBASE1  += GPS_ACU->Tot_sal

         if GPS_ACU->(qrlock())

            replace GPS_ACU->Valor_acum with 0
            replace GPS_ACU->Tot_seg    with 0
            replace GPS_ACU->Tot_emp    with 0
            replace GPS_ACU->Tot_ter    with 0
            replace GPS_ACU->Tot_ded    with 0
            replace GPS_ACU->Tot_sal    with 0

            GPS_ACU->(qunlock())

         endif

      else

         nACUMULA := 0

      endif

   endif

   // IMPRESSAO DA GUIA _____________________________________________________

   if ! qlineprn() ; return ; endif
   qcabecprn(cTITULO,80)
   @ prow()+1,000 say XCOND1
   @ prow()+1,01 say "Departamento.: " + GRPS->Descricao
   @ prow()+1,01 say "CNPJ.....: " + GRPS->Cgc
   @ prow()+1,01 say "Razao....: " + XRAZAO
   @ prow()+1,01 say "Endereco.: " + GRPS->Endereco
   @ prow()+1,01 say "Bairro...: " + GRPS->Bairro
   @ prow()+1,01 say "Telefone.: " + GRPS->Telefone

   @ prow()+1,01 say "Cep......: " + transform(GRPS->Cep,"@R 99.999-999")
   CGM->(dbseek(GRPS->Cgm))
   @ prow()+1,01 say "Municipio: " + alltrim(CGM->Municipio) + " - " + CGM->Estado

   @ prow()+2,01 say "Codigo de FPAS......: " + GRPS->Cod_fpas
   @ prow()+1,01 say "Codigo de Terceiros.: " + GRPS->Cod_terc

   @ prow()+2,01 say "Valor dos Segurados............: " + transform(nTOTSEG,cPIC)

   if CONFIG->Gr_simples != "S"
      @ prow()+1,01 say "Valor de Terceiros.............: " + transform(nTOTTER,cPIC)
   else
      @ prow()+1,0 say space(1)
   endif

   if CONFIG->Gr_simples != "S"
      @ prow()+1,01 say "Valor de R.A.T. ...............: " + transform(nTOTSAT,cPIC)
   else
      @ prow()+1,0 say space(1)
   endif

   if CONFIG->Gr_simples != "S"
      @ prow()+1,01 say "INSS Empresa...................: " + transform(nTOTEMP,cPIC)
   else
      @ prow()+1,0 say space(1)
   endif

      @ prow()+1,01 say "Salario Familia................: " + transform(nTOTDED,cPIC)

   if CONFIG->Gr_simples == "S"
      nSOMA :=  nTOTSEG - nTOTDED
   else
      nSOMA :=  nTOTSEG + nTOTEMP + nTOTTER + nTOTSAT - nTOTDED
   endif

   @ prow()+1,01 say "Multa e Juros ................: " + transform(nJUROS,cPIC)
   @ prow()+1,01 say "Total..........................: " + transform(nSOMA+nJUROS,cPIC)

   @ prow()+2,01 say "Total de Funcionarios..........: " + transform(nQUANTFUN,"@E 999")

   @ prow()+2,01 say "Base de Calculo................: " + transform(nTBASE1,cPIC)

   if nTBASE2 <> 0
      @ prow()+2,01 say "Contribuinte individual.......: "+ transform(nTBASE2 ,cPIC)
   else
      @ prow()+2,0 say space(1)
   endif

   @ prow()+2,01 say "Aliquota de Acidente de Trabalho.: "+ GRPS->Cod_sat
   @ prow()+1,01 say "Codigo de Pagamento da GPS.......: "+ GRPS->Cod_gps

   @ prow()+2,005 say cMENSA1
   @ prow()+1,005 say cMENSA2

   eject

   @ prow()+1,00 say XCOND1+"|"+replicate("-",115)+"|"
   @ prow()+1,00 say "|"+"  MINISTERIO DA PREVIDENCIA E ASSISTENCIA - MPAS         "+"|"+"3. CODIGO DE PAGAMENTO  |         " +cPAGTO   +"                   |"
   @ prow()+1,00 say "|"+"  INSTITUTO NACIONAL DO SEGURO SOCIAL - INSS             "+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"    GUIA DA PREVIDENCIA SOCIAL - GPS                     "+"|"+"4. COMPETENCIA          |         " +cCOMPET+"                |"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"5. IDENTIFICADOR        |         "+ GRPS->Cgc+" "+"    |"
   @ prow()+1,00 say "|"+"---------------------------------------------------------"+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"1. NOME ou RAZAO SOCIAL/FONE/ENDERECO                    "+"|"+"6. VALOR DO INSS        |         "+transf(nTOTSEG+nTOTEMP+nTOTSAT-nTOTDED,"@E 999,999,999.99")+"         |"
   @ prow()+1,00 say "|"+ left(XRAZAO,50)+space(7)                               +"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+ left(GRPS->Endereco,50)+space(7)                          +"|"+"7.                      |                                |"
   @ prow()+1,00 say "|"+ "BAIRRO.: "+GRPS->Bairro + "                            |"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+ "CEP - "+transf(GRPS->Cep,"@R 99.999-999") +"   Telefone - "+GRPS->Telefone+ "                 |"+ "8.                      |                                |"
   @ prow()+1,00 say "|"+ alltrim(CGM->Municipio)+ " - " +CGM->Estado +space(44)+ "|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"---------------------------------------------------------"+"|"+"9. VALOR DE OUTRAS      |                                |"
   @ prow()+1,00 say "|"+"2. VENCIMENTO                                            "+"|"+"   ENTIDADES            |         "+transf(nTOTTER,"@E 999,999,999.99")+" "+"        |"
   @ prow()+1,00 say "|"+"(Uso exclusivo INSS)                                     "+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"10. ATM/MULTA E JUROS   |         "+transf(nJUROS,"@E 999,999,999.99")+" "+"        |"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"11. TOTAL               |         "+transf(nSOMA+nJUROS,"@E 999,999,999.99")+" "+"        |"
   @ prow()+1,00 say "|"+"---------------------------------------------------------"+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"12. AUTENTICACAO BANCARIA                                "+" "+"                                                         |"
   @ prow()+1,00 say "|"+"                                                         "+" "+"                                                         |"
   @ prow()+1,00 say "|"+"                                                         "+" "+"                                                         |"
   @ prow()+1,00 say "|"+replicate("-",115)+"|"

   @ prow()+1,00 say ""

   @ prow()+1,00 say XCOND1+"|"+replicate("-",115)+"|"
   @ prow()+1,00 say "|"+"  MINISTERIO DA PREVIDENCIA E ASSISTENCIA - MPAS         "+"|"+"3. CODIGO DE PAGAMENTO  |         " +cPAGTO   +"                   |"
   @ prow()+1,00 say "|"+"  INSTITUTO NACIONAL DO SEGURO SOCIAL - INSS             "+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"    GUIA DA PREVIDENCIA SOCIAL - GPS                     "+"|"+"4. COMPETENCIA          |         " +cCOMPET+"                |"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"5. IDENTIFICADOR        |         "+ GRPS->Cgc+" "+"    |"
   @ prow()+1,00 say "|"+"---------------------------------------------------------"+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"1. NOME ou RAZAO SOCIAL/FONE/ENDERECO                    "+"|"+"6. VALOR DO INSS        |         "+transf(nTOTSEG+nTOTEMP+nTOTSAT-nTOTDED,"@E 999,999,999.99")+"         |"
   @ prow()+1,00 say "|"+ left(XRAZAO,50)+space(7)                               +"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+ left(GRPS->Endereco,50)+space(7)                          +"|"+"7.                      |                                |"
   @ prow()+1,00 say "|"+ "BAIRRO.: "+GRPS->Bairro + "                            |"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+ "CEP - "+transf(GRPS->Cep,"@R 99.999-999") +"   Telefone - "+GRPS->Telefone+ "                 |"+ "8.                      |                                |"
   @ prow()+1,00 say "|"+ alltrim(CGM->Municipio)+ " - " +CGM->Estado +space(44)+ "|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"---------------------------------------------------------"+"|"+"9. VALOR DE OUTRAS      |                                |"
   @ prow()+1,00 say "|"+"2. VENCIMENTO                                            "+"|"+"   ENTIDADES            |         "+transf(nTOTTER,"@E 999,999,999.99")+" "+"        |"
   @ prow()+1,00 say "|"+"(Uso exclusivo INSS)                                     "+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"10. ATM/MULTA E JUROS   |         "+transf(nJUROS,"@E 999,999,999.99")+" "+"        |"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"                                                         "+"|"+"11. TOTAL               |         "+transf(nSOMA+nJUROS,"@E 999,999,999.99")+" "+"        |"
   @ prow()+1,00 say "|"+"---------------------------------------------------------"+"|"+"---------------------------------------------------------|"
   @ prow()+1,00 say "|"+"12. AUTENTICACAO BANCARIA                                "+" "+"                                                         |"
   @ prow()+1,00 say "|"+"                                                         "+" "+"                                                         |"
   @ prow()+1,00 say "|"+"                                                         "+" "+"                                                         |"
   @ prow()+1,00 say "|"+replicate("-",115)+"|"

   qstopprn()

return

////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR GPS DE AUTONOMOS ___________________
function i_onorario

   local cCOMPET, cPIC := "@E 9,999,999.99"

   cCOMPET := subs(cANOMES,5,1) + subs(cANOMES,6,1) + "/"
   cCOMPET += Left(cANOMES,4)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn(0,cLOCALIMP) ; return ; endif
   qmensa("imprimindo...")

   if empty(cLOCALIMP)
      cLOCALIMP := XLOCALIMP
   endif

   if ! qlineprn() ; return ; endif

   @ prow()  ,000 say XCOND1+XACARTA
   @ prow()  ,105 say cPAGTO
   if cAMBIENTE == "M"
      @ prow()+2 ,090 say cCOMPET
   else
      @ prow()+2 ,090 say "13/" + left(cANOMES,4)
   endif
   
   @ prow()+2,090 say FUN->Pis_num

   @ prow()+2,002 say left(FUN->Nome,30)

//Campo 6-VALOR DO INSS .........................................
   
   nVALOR := "TBIA->Ia_con" + strzero(val(cCLASSE),2)

   @ prow()  ,105 say &nVALOR picture cPIC
//...............................................................

   @ prow()+1,002 say FUN->Endereco
   @ prow()+1,002 say "Bairro - " + FUN->Bairro
   @ prow()+1,002 say "Cep - " + transform(FUN->Cep,"@R 99.999-999") + " Telefone - " + FUN->Telefone

   CGM->(dbseek(FUN->Resid_cgm))

   @ prow()+1,002 say alltrim(CGM->Municipio) + " - " + CGM->Estado

   @ prow()+2,0 say  ""

//Campo 11-TOTAL......................................
   @ prow()+4,105 say round(&nVALOR,2) picture cPIC
//....................................................

   @ prow()+8,000 say ""

   qstopprn(.F.)
return
