/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DA GUIA DE INSS (GRPS) - ACUMULADA
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: SETEMBRO DE 1998
// OBS........:
// ALTERACOES.:

#include "rh.ch"
#include "inkey.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   nCONT

private sBLOCO1   := qlbloc("B518B","QBLOC.GLO") // bloco ambiente

private lPAUSA    := .T.
private cLOCALIMP := ""
private cMENSA1
private cMENSA2
private nAUTO
private cAMBIENTE := "M"
private cANOMES   := space(6)
private cMESANO   := right(XANOMES,2) + left(XANOMES,4)

// LOOP INICIAL PARA PERMANECER DENTRO DA OPCAO _____________________________

do while .T.

   qlbloc(5,0,"B518A","QBLOC.GLO")

   qmensa("<Pressione ESC para Cancelar>")

   qesco(08,15,@cAMBIENTE,sBLOCO1)

   qsay(08,15,qabrev(cAMBIENTE,"M1",{"Mensal","13. Sal rio"}))

   if lastkey() == K_ESC ; Exit ; endif

   qgetx(08,39,@cMESANO,"@R 99/9999")

   if lastkey() == K_ESC ; Exit ; endif

   cANOMES  := right(cMESANO,4) + left(cMESANO,2)

   cLOCALIMP := ""

   // VAI FAZER SELECAO DE EMPRESAS ? _______________________________________

   private aEMP := qmarcaemp()

   if lastkey() == K_ESC ; exit ; endif

   // REALIZA PAUSA P/ SOLICITAR DADOS INDIVIDUAIS ? ________________________

   qmensa("<Pressione ESC para refazer>")

   if alert("Quer informar Valor p/ Aut“nomos;e mensagens individualmente ?",{"SIM","NŽO"}) == 2
      lPAUSA := .F.
   endif

   if lastkey() == K_ESC ; loop ; endif

   // ACIONA IMPRESSOES _____________________________________________________

   if empty(aEMP)
      i_guia()
   else
      for nCONT := 1 to len(aEMP)
          qseldirect(aEMP[nCONT])
          i_guia()
      next
   endif

enddo

return

/////////////////////////////////////////////////////////////////////////////
// EMISSAO DAS GUIAS SELECIONADAS ___________________________________________

function i_guia

   local lEMISSAO_OK := .T.

   // ABRE OS ARQUIVOS MANUALMENTE __________________________________________

   if ! quse(XDRV_RH,"FUN"      ,{"FU_GRPS" },"R") ; return .F. ; endif
   if ! quse(XDRV_RH,"SITUA"    ,{"SI_MATRI"},"R") ; return .F. ; endif
   if ! quse(XDRV_RH,"BASE"     ,{"BA_MATRI"},"R") ; return .F. ; endif
   if ! quse(XDRV_RH,"LANC"     ,{"LA_MATRI"},"R") ; return .F. ; endif
   if ! quse(XDRV_RH,"GRPS"     ,{"GR_CODIG"},"E") ; return .F. ; endif
// if ! quse(XDRV_RH,"GRPS_ACU" ,{"GRPSA_CO"}) ; return .F. ; endif
   if ! quse(XDRV_RH,"CONFIG") ; return .F. ; endif
   
   SITUA->(dbSetFilter({|| Anomes == cANOMES},"Anomes == cANOMES"))

   GRPS->(dbSetFilter({|| Anomes == cANOMES},"Anomes == cANOMES"))
   
   // RELACIONAMENTO ________________________________________________________

   FUN->(dbSetRelation( "BASE" , {|| Matricula+cANOMES}, "Matricula+cANOMES" ))

   GRPS->(dbSetRelation( "FUN" , {|| Codigo}, "Codigo" ))

   GRPS->(dbgotop())

   // LOOP DE GRPS E SOLICITACAO DE DADOS ___________________________________

   do while ! GRPS->(eof())

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

      if ! lEMISSAO_OK ; exit ; endif

      i_emissao1()   // emissao de guia individual...

      GRPS->(dbskip())

   enddo

   // FECHA OS ARQUIVOS MANUALMENTE E RETORNA _______________________________

   FUN->(dbclosearea())
   SITUA->(dbclosearea())
   BASE->(dbclosearea())
   LANC->(dbclosearea())
   GRPS->(dbclosearea())
// GRPS_ACU->(dbclosearea())
   CONFIG->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// EMISSAO DO GRPS __________________________________________________________

static function i_emissao1

   local nTOTSEG := nTOTEMP := nTOTTER := nTOTDED := nTOTLIQ := nTOTSAT:= 0

   local nSOMA, nQUANTFUN := nTBASE1 := nTBASE2 := nACUMULA := 0

   local cCOMPET, cPIC := "@E 9,999,999.99"
   local cTITULO := space(80)
   cCOMPET := subs(cANOMES,5,1) + "    " + subs(cANOMES,6,1) + "    "
   cCOMPET += subs(cANOMES,3,1)   + "    " + subs(cANOMES,4,1)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn(0,cLOCALIMP) ; return ; endif
   qmensa("imprimindo...")

   if empty(cLOCALIMP)
      cLOCALIMP := XLOCALIMP
   endif

   // LOOP NOS FUNCIONARIOS PARA TOTALIZACOES _______________________________

   do while ! FUN->(eof()) .and. FUN->Grps == GRPS->Codigo
      SITUA->(dbseek(FUN->Matricula))

      qgirabarra()

      qmensa("Aguarde...Verificando dados para impress„o...")

      // SALTA FUNCIONARIOS HOMOLOGADOS OU ADMITIDOS POSTERIORMENTE _________

      if SITUA->Situacao $ " H" .or. FUN->Data_Adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         loop
      endif

      // SALTA FUNCIONARIOS TRANSFERIDOS PARA OUTRA EMPRESA _________________

      if SITUA->Af_cod == "40"
         FUN->(dbskip())
         loop
      endif

      // SOMA QUANTIDADE DE FUNCIONARIOS ATIVOS _____________________________

      if SITUA->Vinculo <> K_DIRETOR .and. SITUA->Vinculo <> "F"
         nQUANTFUN++
      endif

      // TOTALIZA BASE ______________________________________________________

//      if SITUA->Af_cod == "03"
//         nTBASE1 += iif(SITUA->Categoria <> "5",SITUA->Salario,SITUA->Salario * FUN->Hor_trab)
//      endif

      if SITUA->Af_cod == "FR" .and. LANC->(dbseek(cANOMES+FUN->Matricula+"MS103"))
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS161"))
            nTBASE1 += LANC->Valor
         endif
      endif


      if LANC->(dbseek(cANOMES+FUN->Matricula+"MS105")) //.or. LANC->(dbseek(cANOMES+FUN->Matricula+"MS641"))
         if cAMBIENTE == "M"
              nTBASE2 += LANC->Valor
          //  nTBASE1 += LANC->Valor
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
            if SITUA->vinculo $ "G*F"

               nTBASE2 += BASE->T_inssms
            else
               if cAMBIENTE == "M"
                  nTBASE1 += BASE->T_inssms + BASE->T_inssfr + BASE->T_inssdt
               else
                  nTBASE1 += BASE->T_inss13
               endif
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

//       nVALOR:= i_inss(FUN->Matricula)
         if LANC->(dbseek(cANOMES+FUN->Matricula+"MS161")) // SAL. MATERNIDADE MENSAL
//            if SITUA->Af_ini >= ctod("01/09/2003")
               nTOTDED += LANC->Valor //- nVALOR
//            endif
         endif


      endif

      FUN->(dbskip())

   enddo

   qmensa()

   // TOTALIZA AUTONOMOS, EMPRESA E TERCEIROS _______________________________
   cTITULO := "INFORMACOES P/ INSS - " + left(cMESANO,2) + "/" + right(cMESANO,4)
   nTOTEMP := nTBASE1 * (GRPS->Perc_empr ) / 100
   nTOTEMP += nTBASE2 * GRPS->Perc_prol / 100
   nTOTEMP += nAUTO   * GRPS->Perc_auto / 100

   nTOTSAT := nTBASE1 * (GRPS->Perc_acid ) / 100



   nTBASE2 += nAUTO
   nTOTTER := nTBASE1 * GRPS->Perc_terc / 100

   // APLICA ROUND PARA EVITAR PROBLEMAS DE ERRO NA SOMA ____________________

   nTOTSEG := round(nTOTSEG,2)
   nTOTEMP := round(nTOTEMP,2)
   nTOTTER := round(nTOTTER,2)
   nTOTSAT := round(nTOTSAT,2)
   nTOTDED := round(nTOTDED,2)


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

   @ prow()+1,01 say "Total..........................: " + transform(nSOMA,cPIC)

   @ prow()+2,01 say "Total de Funcionarios..........: " + transform(nQUANTFUN,"@E 999")

   @ prow()+2,01 say "Base de Calculo................: " + transform(nTBASE1,cPIC)

   if nTBASE2 <> 0
      @ prow()+2,01 say "Contribuinte Individual............: "+ transform(nTBASE2 ,cPIC)
   else
      @ prow()+2,0 say space(1)
   endif

   @ prow()+2,01 say "Aliquota de Acidente de Trabalho.: "+ GRPS->Cod_sat
   @ prow()+1,01 say "Codigo de Pagamento da GPS.......: "+ GRPS->Cod_gps

   @ prow()+2,005 say cMENSA1
   @ prow()+1,005 say cMENSA2

   @ prow()+5,000 say ""

   if GRPS->(qrlock())
      replace GRPS->Segurados  with  nTOTSEG
      replace GRPS->Total      with  nSOMA
      GRPS->(qunlock())
   endif

   qstopprn()

return


Function i_inss
Parameters cMATRICULA
LANC->(dbgotop())
if LANC->(dbseek(cANOMES+cMATRICULA+"MS910")) // LOCALIZAR SAL. INSS DO MES
   return LANC->Valor
else
   return 0
endif
