
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: ENCERRAMENTO DO MES DE TRABALHO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....:
// OBS........:
// ALTERACOES.:

local   nREC
private cANOMES   := qanomes(XDATASYS)
private cDATASYS  := qfimmes(XDATASYS + 15)
private XNIVEL    := 1
private cNUM_LOTE
private nDOCNUM   := 1
private cCENTANT
private nTOTEVE
private nPOINTER
private aEVENTOS  := {}

qrsay(1,cDATASYS)

qrsay(2,qnomemes(month(cDATASYS)))
qrsay(3,str(year(cDATASYS),4))

if qconf("Confirma abertura de novo mˆs ?")
   if XDATASYS != CONFIG->Data_atual
      qmensa("Per¡odo ja foi aberto !! Utilize a op‡„o 820 ","B")
      return
   endif

   if CONFIG->(qrlock())
      cNUM_LOTE := "RH" + strzero(CONFIG->Lote_inter + 1,3)
      replace CONFIG->Lote_inter with CONFIG->Lote_inter + 1
      replace CONFIG->Datasys    with cDATASYS
      replace CONFIG->Data_atual with cDATASYS
      CONFIG->(qunlock())
      XANOMES := qanomes(cDATASYS)
   endif
else
   return
endif

// ABRE ARQUIVO DE INTEGRACAO E PLANO DE CONTAS DA IQ _______________________

fu_abre_share()
fu_abre_plan()

// GERA TABELA GERAL PARA NOVO MES __________________________________________

if ! TBGR->(dbseek(XANOMES))
   TBGR->(dbseek(cANOMES))
   TBGR->(qpublicfields())
   TBGR->(qcopyfields())
   fANOMES := XANOMES
   TBGR->(dbgobottom())
   if ! TBGR->(qappend())
      qmensa("N„o foi poss¡vel gerar TABELA GERAL para novo mˆs !!","B")
      return
   else
      TBGR->(qreplacefields())
      TBGR->(qreleasefields())
   endif
endif

TBGR->(dbclosearea())

// GERA TABELA DO INSS DO EMPREGADO PARA NOVO MES ___________________________

if ! TBIF->(dbseek(XANOMES))
   TBIF->(dbseek(cANOMES))
   TBIF->(qpublicfields())
   TBIF->(qcopyfields())
   fANOMES := XANOMES
   TBIF->(dbgobottom())
   if ! TBIF->(qappend())
      qmensa("N„o foi poss¡vel gerar TABELA DE INSS para novo mˆs !!","B")
      return
   else
      TBIF->(qreplacefields())
      TBIF->(qreleasefields())
   endif
endif

TBIF->(dbclosearea())

// GERA TABELA DO IMPOSTO DE RENDA RETIDO NA FONTE PARA NOVO MES ____________

if ! TBIR->(dbseek(XANOMES))
   TBIR->(dbseek(cANOMES))
   TBIR->(qpublicfields())
   TBIR->(qcopyfields())
   fANOMES := XANOMES
   TBIR->(dbgobottom())
   if ! TBIR->(qappend())
      qmensa("N„o foi poss¡vel gerar TABELA DE IRRF para novo mˆs !!","B")
      return
   else
      TBIR->(qreplacefields())
      TBIR->(qreleasefields())
   endif
endif

TBIR->(dbclosearea())

// GERA TABELA DO SALARIO FAMILIA PARA NOVO MES _____________________________

if ! TBSF->(dbseek(XANOMES))
   TBSF->(dbseek(cANOMES))
   TBSF->(qpublicfields())
   TBSF->(qcopyfields())
   fANOMES := XANOMES
   TBSF->(dbgobottom())
   if ! TBSF->(qappend())
      qmensa("N„o foi poss¡vel gerar TABELA DE S. FAMILIA para novo mˆs !!","B")
      return
   else
      TBSF->(qreplacefields())
      TBSF->(qreleasefields())
   endif
endif

TBSF->(dbclosearea())

// GERA NOVA GRPS PARA O NOVO MES ___________________________________________

if ! GRPS->(dbseek(XANOMES))
   GRPS->(dbgotop())
   do while ! GRPS->(eof())
      if cANOMES == GRPS->Anomes
         GRPS->(qpublicfields())
         GRPS->(qcopyfields())
         fANOMES := XANOMES
         nREC := GRPS->(recno())
         GRPS->(dbgobottom())
         if ! GRPS->(qappend())
            qmensa("N„o foi poss¡vel gerar GRPS para novo mˆs !!","B")
            return
         else
            GRPS->(qreplacefields())
            GRPS->(qreleasefields())
         endif
         GRPS->(dbgoto(nREC))
      endif
      GRPS->(dbskip())
   enddo
endif

GRPS->(dbclosearea())

// GERA NOVA LINHA DE VALE TRANSPORTE PARA O NOVO MES _______________________

if ! VALE->(dbseek(XANOMES))
   VALE->(dbgotop())
   do while ! VALE->(eof())
      if cANOMES == VALE->Anomes
         VALE->(qpublicfields())
         VALE->(qcopyfields())
         fANOMES := XANOMES
         nREC := VALE->(recno())
         VALE->(dbgobottom())
         if ! VALE->(qappend())
            qmensa("N„o foi poss¡vel gerar LINHA DE VALE TRANSPORTE para novo mˆs !!","B")
            return
         else
            VALE->(qreplacefields())
            VALE->(qreleasefields())
         endif
         VALE->(dbgoto(nREC))
      endif
      VALE->(dbskip())
   enddo
endif

VALE->(dbclosearea())

// INTERFACE COM A CONTABILIDADE ____________________________________________

FUN->(dbsetorder(7))  // ordem de centro + matricula

FUN->(dbgotop())

do while ! FUN->(eof())
   qgirabarra()

   if FUN->Situacao == "H" .or. empty(FUN->Centro)
      FUN->(dbskip())
      loop
   endif

   cCENTANT := FUN->Centro

   aEVENTOS := {}

   do while ! FUN->(eof()) .and. FUN->Centro == cCENTANT
      qgirabarra()

      qmensa("Interface do Centro: " + transform(FUN->Centro,"@R 99.99.9999"))

      if LANC->(dbseek(cANOMES+FUN->Matricula))

         do while ! LANC->(eof()) .and. LANC->Anomes == cANOMES .and. LANC->Matricula == FUN->Matricula
            if ! LANC->Ambiente $ "MS_FR_DT_AD" .or. LANC->Interface == "S" // MUDEI NO DIA 14/05/97, ESTAVA ASSIM "MS_FR_DT"
               LANC->(dbskip())
               loop
            endif

            if(nPOINTER := ascan(aEVENTOS,{|x| x[1] == LANC->Evento})) == 0
               EVENT->(dbseek(LANC->Evento))
               if EVENT->Finalidade $ "PD" .or. EVENT->Evento $ "930-931-936-938-941"
                  if LANC->(qrlock())
                     replace LANC->Interface with "S"
                  endif
                  aadd(aEVENTOS,{LANC->Evento,LANC->Valor})
               endif
            else
               aEVENTOS[nPOINTER,2] += LANC->Valor
            endif

            LANC->(dbskip())

         enddo

      endif

      FUN->(dbskip())

   enddo

   for nCONT = 1 to len(aEVENTOS)
       if empty(aEVENTOS[nCONT,2])
          loop
       endif

       EVENT->(dbseek(aEVENTOS[nCONT,1]))
       EVCONT->(dbseek(aEVENTOS[nCONT,1]))

       if ART_PROF->(qappend())
          replace ART_PROF->Historico1 with EVENT->Descricao
          replace ART_PROF->Data       with XDATASYS
          replace ART_PROF->Valor      with aEVENTOS[nCONT,2]
          replace ART_PROF->Contad     with EVCONT->Contad

          PLAN->(dbseek(EVCONT->Contad))

          replace ART_PROF->Digcontad  with PLAN->Digconta
          replace ART_PROF->Contac     with EVCONT->Contac

          PLAN->(dbseek(EVCONT->Contac))

          replace ART_PROF->Digcontac  with PLAN->Digconta

          if left(ART_PROF->Contad,1) $ "34" .or. left(ART_PROF->Contac,1) $ "34"
             replace ART_PROF->Centro with right(cCENTANT,4)
          endif

          replace ART_PROF->Lote       with cNUM_LOTE
          replace ART_PROF->Docnum     with nDOCNUM++
       endif
   next

   ART_PROF->(dbunlock())

enddo

// LOOP PARA TODO O ARQUIVO FUN ABRINDO NOVO MES DE TRABALHO ________________

FUN->(dbsetorder(1))  // ordem de matricula

FUN->(dbgotop())

do while ! FUN->(eof())

   if FUN->Situacao == "H"
      FUN->(dbskip())
      loop
   endif

   qmensa("Funcion rio processado: " + FUN->Matricula + " / " + FUN->Nome)

   SITUA->(qseekn(FUN->Matricula))

   if FUN->(qrlock())

      SITUA->(qpublicfields())
      SITUA->(qcopyfields())

      if SITUA->(qappend())
         fANOMES := XANOMES

         SITUA->(qreplacefields())

         // ANALIZADOR DAS CARACTERISTICAS DIVERSAS DO FUNCIONARIO ________________

         // SITUACAO INDEFINIDA ? _________________________________________________

         if empty(FUN->Situacao)
            replace FUN->Situacao with "T"
            replace SITUA->Situacao with "T"
         endif

         // APOSENTADO INDEFINIDO _________________________________________________

         if empty(FUN->Aposentado)
            replace FUN->Aposentado with "N"
         endif

         // HORAS DE TRABALHO NAO DEFINIDAS, ENTAO ASSUME 220 _____________________

         if FUN->Hor_trab == 0
            replace FUN->Hor_trab with 220
            replace FUN->Hor_sema with 44
         endif

         // JA PASSOU TERMINO DO CONTRATO _________________________________________

         if ! empty(FUN->Data_fctr) .and. FUN->Situacao == "T" .and. ;
            SITUA->Vinculo == "I" .and. FUN->Data_fctr < qinimes(cDATASYS)
            replace SITUA->Vinculo with "A"
         endif

         // CODSAQFGTS IRREGULAR ? ________________________________________________

         if FUN->Situacao <> "D" .and. ! empty(SITUA->Codsaqfgts)
            replace SITUA->Codsaqfgts with "  "
         endif

         // VERIFICA SE DEVE EXCLUIR COTA DE SALARIO FAMILIA ______________________

         if SITUA->Dep_fam <> 0
            DEPE->(dbseek(FUN->Matricula))
            do while DEPE->Matricula == FUN->Matricula
               if ! empty(DEPE->Data_nasc) .and. (qinimes(cDATASYS)-DEPE->Data_nasc) / 365 >= 14 .and. ;
                  month(cDATASYS) <> month(DEPE->Data_nasc) .and. ;
                  DEPE->Sal_fam == "S" .and. DEPE->(qrlock())
                  replace DEPE->Sal_fam with "N"
                  replace SITUA->Dep_fam with SITUA->Dep_fam - 1
                  DEPE->(dbunlock())
               endif
               DEPE->(dbskip())
            enddo
            if SITUA->Dep_fam < 0
               replace SITUA->Dep_fam with 0
            endif
         endif

         // GERA BENEFICIO PARA NOVO MES _____________________________________________

         BENEF->(dbsetorder(2))
         if ! BENEF->(dbseek(XANOMES+FUN->Matricula))
            BENEF->(dbseek(cANOMES+FUN->Matricula))
            do while BENEF->Anomes == cANOMES .and. BENEF->Matricula == FUN->Matricula
               BENEF->(qpublicfields())
               BENEF->(qcopyfields())
               fANOMES := XANOMES
               nREC := BENEF->(recno())
               BENEF->(dbgobottom())
               if ! BENEF->(qappend())
                  qmensa("N„o foi poss¡vel copiar BENEFICIO do mes anterior !","B")
                  return
               else
                  BENEF->(qreplacefields())
                  BENEF->(qreleasefields())
               endif
               BENEF->(dbgoto(nREC))
               BENEF->(dbskip())
            enddo
         endif
         BENEF->(dbsetorder(1))

         // SE DEMITIDO NO MES ANTERIOR, ENTAO PASSA PARA HOMOLOGADO ______________

         if FUN->Situacao == "D" .and. SITUA->Af_ini < qinimes(cDATASYS)
            replace FUN->Situacao with "H"
            replace SITUA->Situacao with "H"

            // EXCLUI BENEFICIOS SE HOUVER ________________________________________

            BENEF->(dbsetorder(2))
            BENEF->(dbseek(XANOMES + FUN->Matricula))
            do while BENEF->Matricula == FUN->Matricula .and. ! BENEF->(eof())
               if BENEF->(qrlock())
                  BENEF->(dbdelete())
                  BENEF->(qunlock())
               endif
               BENEF->(dbskip())
            enddo
            BENEF->(dbsetorder(1))
         endif

         // RETORNO DE AFASTAMENTO ________________________________________________

         if FUN->Situacao == "A" .and. ! empty(SITUA->Af_ret) .and. SITUA->Af_ret < qinimes(cDATASYS)
            replace FUN->Situacao     with "T"
            replace SITUA->Situacao   with "T"
            replace SITUA->Af_ini     with ctod("")
            replace SITUA->Af_ret     with ctod("")
            replace SITUA->Af_cod     with space(2)
            replace SITUA->Codsaqfgts with space(2)
         endif

         // RETORNO DE FERIAS _____________________________________________________

         if FUN->Situacao == "F" .and. ! empty(SITUA->Af_ret) .and. SITUA->Af_ret < qinimes(cDATASYS)
            replace FUN->Situacao     with "T"
            replace SITUA->Situacao   with "T"
            replace SITUA->Di_ferias  with ctod(left(dtoc(SITUA->Di_Ferias),6) + strzero(year(SITUA->Di_Ferias)+1,4))
            replace SITUA->Df_ferias  with ctod(left(dtoc(SITUA->Df_Ferias),6) + strzero(year(SITUA->Df_Ferias)+1,4))
            replace SITUA->Af_ini     with ctod("")
            replace SITUA->Af_ret     with ctod("")
            replace SITUA->Af_cod     with space(2)
            replace SITUA->Codsaqfgts with space(2)
         endif

         SITUA->(dbunlock())

      endif

      FUN->(qreleasefields())
      SITUA->(qreleasefields())

      FUN->(dbunlock())

   endif
      
   FUN->(dbskip())
    
enddo

return

