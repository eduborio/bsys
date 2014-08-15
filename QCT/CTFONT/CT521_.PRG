/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: BALANCO PATRIMONIAL
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: SETEMBRO DE 1995
// OBS........:
// ALTERACOES.:

function ct521

#include "inkey.ch"
#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27}

set century on

if empty(CONFIG->Exercicio) .or. len(alltrim(CONFIG->Exercicio)) < 4
    qmensa("Sistema sem o ano do Exerc¡cio informado !! Execute a op‡„o 803 !")
    return
endif

private sBLOCO1  := qlbloc("B521B","QBLOC.GLO") // tipo de relatorio
private sBLOCO2  := qlbloc("B521C","QBLOC.GLO") // mensagem de alerta

private aEDICAO  := {}                // vetor para os campos
private cTITULO1                      // titulo 1 do relatorio
private cTITULO2                      // titulo 2 do relatorio
private dDATA                         // data do fechamento
private cDATA                         // data da Abertura quando tipo == 3
private cMESI                         // mes inicial do periodo
private cMESF                         // mes final do periodo
private cNIVEL                        // nivel das contas para impressao
private cTIPO                         // tipo de relatorio
private nPAG                          // pagina
private cREDAPU                       // conta reduzida para apuracao do resultado
private cREDLUPR := CONFIG->Ctalupr   // conta reduzida de lucros/prejuizos acumulados do exercicio
private nNIVEL                        // nivel da conta
private cDEB                          // variavel auxiliar p/ macro
private CCRE                          // variavel auxiliar p/ macro
private nTOTAL                        // total de ATIVO ou PASSIVO
private nCTAGER                       // valor da cta. lucros ou prej. p/gerencial
private nCTAACU                       // resultado acumulado ate periodo informado
private nSALDANT                      // saldo do periodo informado
private nSALDACU                      // saldo anterior ao periodo informado
private nSALDATU                      // saldo atual
private lACHOU                        // flag verifica se houve movimento nos meses
private nCTALP                        // conta contabil da conta de apuracao
private cDESLP                        // descricao da conta de apuracao
private nCTALUPR                      // conta contabil da conta lucros/prejuizos acumulados do exercicio
private cDESLUPR                      // descricao da conta lucros/prejuizos acumulados do exercicio
private nCTAMAER                      // conta contabil da conta mae da conta de apuracao
private cMAERESU                      // descricao da conta mae da conta de apuracao

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO   ,sBLOCO1 )},"TIPO"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA            )},"DATA"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@cMESI   ,"99"    )},"MESI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@cMESF   ,"99"    )},"MESF"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@cNIVEL  ,"9"     )},"NIVEL"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nPAG    ,"9999"   )},"PAG"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@cDATA   ,"@D"    )},"xDATA"   })

do while .T.

   qlbloc(5,0,"B521A","QBLOC.GLO")
   qmensa()
   XNIVEL   := 1
   XFLAG    := .T.
   lACHOU   := .F.
   dDATA    :=  ctod("")
   cDATA    :=  ctod("")
   cMESI    := "  "
   cMESF    := "  "
   cNIVEL   := "4"
   cTIPO    := "1"
   nPAG     := 1
   cPERIODO := "M"
   cREDAPU  := space(6)
   nCTALP   := space(12)
   nCTAGER  := nCTAACU := nTOTAL := 0
   
   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if i_inicializacao()
      if cTIPO == "4"
         i_impr4()
      else
         i_impr123()
      endif
   endif

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "TIPO"
           if empty(cTIPO)
              qmensa("Campo TIPO DO RELATORIO ‚ obrigat¢rio !","B")
              return .F.
           endif
           qrsay(XNIVEL,qabrev(cTIPO,"1234",{"Balan‡o Gerencial","Balan‡o Fiscal","Balan‡o Abertura","Balan‡o (Deb/Cred)"}))
           do case
              case cTIPO $ "14"
                   XNIVEL++
              case cTIPO == "3"
                   XNIVEL+=3
           endcase
      case cCAMPO == "DATA"
           if empty(dDATA) .and. cTIPO == "2"
              qmensa("Campo DATA DE FECHAMENTO ‚ obrigat¢rio !","B")
              return .F.
           endif
           dDATA := qfimmes(dDATA)
           qrsay(XNIVEL,dDATA)
           if cTIPO == "2"
              XNIVEL+=2
           endif
      case cCAMPO == "MESI"
           if val(cMESI) = 0 .or. val(cMESI) > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           qrsay(XNIVEL,cMESI := strzero(val(cMESI),2))
      case cCAMPO == "MESF"
           if val(cMESF) = 0 .or. val(cMESF) > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           qrsay(XNIVEL,cMESF := strzero(val(cMESF),2))
           dDATA := qfimmes(ctod("10/" + cMESF + "/" + right(CONFIG->Exercicio,4)))
      case cCAMPO == "NIVEL"
           if ! cNIVEL $ "345"
              qmensa("N¡vel de Conta irregular !","B")
              return .F.
           endif
      case cCAMPO == "PAG"
           if empty(nPAG)
              qmensa("Campo PAGINA n„o pode ser igual a zero !","B")
              return .F.
           endif
           qrsay(XNIVEL,strzero(nPAG,4))
           if cTIPO <> "3"
              XNIVEL++
           endif
      case cCAMPO == "xDATA"
           if empty(cDATA)
              qmensa("Campo DATA DE ABERTURA n„o pode estar vazia !","B")
              qmensa("")
              return .F.
           else
              dDATA := cDATA
              Return .T.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
   local sTELA , cBLOQ

   if cTIPO == "2"
      if CONFIG->Zerou_resu == "S"
         lACHOU := .T.
      else
         sTELA := qsbloc(07,05,20,74)
         qrbloc(07,05,sBLOCO2)
         if ! qconf("Reconfirma emiss„o do Balan‡o Fiscal ?") ; return .F. ; endif
         qrbloc(07,05,sTELA)
      endif
      cBLOQ := strzero(month(dDATA),2)
      cBLOQ := "TRAV_" + cBLOQ
      if CONFIG->&cBLOQ == "S"
         qmensa("Mes bloqueado para lan‡amentos !!","B")
         qmensa()
         return .F.
      endif
   else
      do case
         case cTIPO == "1"
              if CONFIG->Zerou_resu == "S"
                 qmensa("Exerc¡cio j  apurado ! Balan‡o Gerencial n„o dispon¡vel !","B")
                 qmensa()
                 return .F.
              endif
         case cTIPO == "4"
              if CONFIG->Zerou_resu == "S"
                 PLAN->(dbgotop())
                 lACHOU := .T.
              endif
      endcase
   endif

   if cTIPO $ "124" .and. CONFIG->Zerou_resu $ "N "

      // SIMULA LANCAMENTOS E DETERMINA CTA DE EXERCICIO CONFORME CONFIGURACAO ____

      PLAN->(dbseek("3"))

      do while ! PLAN->(eof())

         i_puxares()

         if right(PLAN->Codigo,5) != "     "
            nCTAACU += nSALDACU
         endif
         
         if nSALDANT + PLAN->&cDEB + PLAN->&cCRE = 0.00
            PLAN->(dbskip())
            loop
         endif

         nSALDATU := nSALDANT + PLAN->&cDEB + PLAN->&cCRE

         if right(PLAN->Codigo,5) != "     "
            nCTAGER += nSALDATU
         endif

         PLAN->(dbskip())

      enddo

      if nCTAGER >= 0
         cREDAPU  := CONFIG->Ctapreju
         cREDLUPR := CONFIG->Ctapracum
      else
         cREDAPU  := CONFIG->Ctalucro
         cREDLUPR := CONFIG->Ctalupr
      endif

      // PEGA DEMAIS DADOS DA CONTA DE APURACAO DO EXERCICIO E DA CONTA LUCROS/
      // PREJUIZOS ACUMULADOS DO EXERCICIO ____________________________________

      PLAN->(dbsetorder(3))

      PLAN->(dbseek(cREDAPU))
      nCTALP   := alltrim(PLAN->Codigo)
      cDESLP   := PLAN->Descricao
      qsay(16,16,ct_convcod(cREDAPU))
      qsay(16,25,cDESLP)

      PLAN->(dbsetorder(1))
      PLAN->(dbseek(left(nCTALP,7)))
      nCTAMAER := alltrim(PLAN->Codigo)
      cMAERESU := PLAN->Descricao
      
      PLAN->(dbsetorder(3))
      PLAN->(dbseek(cREDLUPR))
      nCTALUPR := alltrim(PLAN->Codigo)
      cDESLUPR := PLAN->Descricao

      PLAN->(dbsetorder(1))
   endif

   if cTIPO == "1" .or. (cTIPO $ "24" .and. CONFIG->Zerou_resu $ "N ")

      // ZERA CAMPO DRE EM TODOS OS REGISTROS MAS GUARDA SALDO DA CTA. RESULTADO

      PLAN->(dbgotop())

      if ! PLAN->(qflock())
         qmensa("N„o foi poss¡vel abrir arquivo PLAN.DBF !! Tente novamente.")
         return .F.
      else
         qmensa("Zerando campos do DRE...")
         PLAN->(dbseek("3"))
         do while ! PLAN->(eof())
            qgirabarra()
            if PLAN->Reduzido == cREDAPU
               i_puxares()
               nSALDATU := nSALDANT + PLAN->&cDEB + PLAN->&cCRE
               PLAN->Saldo_dre := nSALDATU
            else
               PLAN->Saldo_dre := 0
            endif
            PLAN->(dbskip())
         enddo
      endif

      qmensa()

      // GUARDA SALDOS NO CAMPO DRE E ZERA CONTAS DE RESULTADO SE TIPO == 2 ____

      PLAN->(dbseek("3"))

      do while ! PLAN->(eof())
         i_puxares()

         if nSALDANT + PLAN->&cDEB + PLAN->&cCRE = 0.00
            PLAN->(dbskip())
            loop
         endif

         lACHOU := .T.

         if cTIPO == "2" .and. CONFIG->Zerou_resu $ "N "
            qmensa("Gerando lan‡amentos da Conta: "+ct_convcod(PLAN->Codigo))
         endif

         if cTIPO $ "14"
            qmensa("Simulando lan‡amentos da Conta: "+ct_convcod(PLAN->Codigo))
         endif

         nSALDATU := nSALDANT + PLAN->&cDEB + PLAN->&cCRE

         if cTIPO == "2" .and. CONFIG->Zerou_resu $ "N "
            if right(PLAN->Codigo,5) != "     "
               if LANC->(qappend())
                  LANC->Data_lanc := dDATA
                  if nSALDATU < 0.00
                     LANC->Cont_db := PLAN->Reduzido
                     LANC->Cont_cr := cREDAPU
                  else
                     LANC->Cont_cr := PLAN->Reduzido
                     LANC->Cont_db := cREDAPU
                  endif
                  iif(nSALDATU>0.00,LANC->Valor := nSALDATU,LANC->Valor := nSALDATU*-1)
                  LANC->Num_lote  := "*FECHA"
                  LANC->Num_lanc  := strzero(CONFIG->Num_lanc + 1,5)
                  LANC->Hist_comp := "VALOR TRANSF P/ FECHAMENTO DO BALANCO GERAL"

                  if ct_trava_prop(LANC->Cont_db,LANC->Cont_cr) .and. CONFIG->(qrlock())
                     if ! empty(LANC->Cont_db)
                        ct_prop_saldo(LANC->Cont_db,LANC->Valor,"DB"+strzero(month(LANC->Data_lanc),2))
                        CONFIG->&("DB"+strzero(month(LANC->Data_lanc),2))+=LANC->Valor
                     endif

                     if ! empty(LANC->Cont_cr)
                        ct_prop_saldo(LANC->Cont_cr,LANC->Valor,"CR"+strzero(month(LANC->Data_lanc),2))
                        CONFIG->&("CR"+strzero(month(LANC->Data_lanc),2))+=LANC->Valor * -1
                     endif

                     replace CONFIG->Num_lanc with CONFIG->Num_lanc + 1
                  endif
               endif
            endif
         endif

         if PLAN->(qrlock())
            if cTIPO $ "14" .or. (cTIPO == "2" .and. CONFIG->Zerou_resu $ "N ") .and. PLAN->Reduzido != cREDAPU
               PLAN->Saldo_dre := nSALDATU
            endif
         endif

         PLAN->(dbskip())

      enddo

      if CONFIG->(qflock())
         if cTIPO == "2"
            CONFIG->Zerou_resu := "S"
         endif
      endif

      CONFIG->(qunlock())

   endif
// situacao 3 abertura ............................................
   if cTIPO == "3"
      select PLAN
      PLAN->(dbsetorder(1))
//      if nCTAGER >= 0
         cREDAPU := CONFIG->Ctapreju
//      else
//         cREDAPU := CONFIG->Ctalucro
//      endif
      qmensa("Filtrando Lan‡amentos de Abertura. Aguarde...")
      if PLAN->(qflock())
         replace all PLAN->Dbab with 0,PLAN->Crab with 0
         PLAN->(qunlock())
      endif
      select LANC
      LANC->(dbgotop())
      set filter to dtoc(LANC->Data_lanc) == dtoc(dDATA)
      LANC->(dbSetFilter({|| dtoc(data_lanc) == dtoc(dDATA)},"dtoc(data_lanc) == dtoc(dDATA)"))
      qmensa()
      if ! LANC->(eof())
         i_atuaaber()
      else
         qmensa("Sem Lan‡amentos de Abertura para o Exerc¡cio !!","B")
         return .F.
      endif
   endif

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   do case
      case cTIPO $ "14"
           cTITULO1 := "* BALANCO PATRIMONIAL"
      case cTIPO == "2"
           cTITULO1 := "BALANCO PATRIMONIAL"
      case cTIPO == "3"
           cTITULO1 := "BALANCO PATRIMONIAL DE ABERTURA EM "+StrZero(day(dDATA),2)+" DE "+qnomemes(dDATA)+" DE " + StrZero(year(dDATA),4)
   endcase

   if cTIPO != "3"
      cTITULO1 += " ENCERRADO EM " + strzero(day(dDATA),2) + " DE "  +  ;
                   alltrim(qnomemes(dDATA)) + " DE " + strzero(year(dDATA),4)
   endif

   cTITULO2 := "C.N.P.J. " + XCGCCPF

   PLAN->(dbgotop())

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO DE IMPRESSAO PARA BALANCOS TIPO 1, 2 OU 3 _________________________

static function i_impr123

   // INICIALIZACOES DIVERSAS _______________________________________________

   local nCOL1 , nCOL2 , lSOMOU := .F., lIMPMAE := .F.

   nNIVEL := nSALDANT := nSALDATU := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   // LOOP __________________________________________________________________

   do while ! PLAN->(eof()) .and. qcontprn()

      if ! lACHOU .and. cTIPO != "3"
         exit
      endif

      qgirabarra()

      if ! qlineprn() ; return ; endif

      // CABECALHO SE NECESSARIO ____________________________________________

      i_impcab()

      // DADOS DE UMA LINHA _________________________________________________

      if val(left(PLAN->Codigo,1)) >= 3
         exit
      endif

      qmensa("Processando Conta: " + ct_convcod(PLAN->Codigo))

      if cTIPO $ "1*2*3"

         i_puxaatps()
         nSALDATU := nSALDANT + PLAN->&cDEB + PLAN->&cCRE

         if cTIPO $ "1*3"
            if PLAN->Reduzido != cREDAPU .and. round(nSALDATU,2) == 0 //.or. nSALDATU = 0
               PLAN->(dbskip())
               loop
            endif
         else
            if PLAN->Reduzido != cREDAPU .and. round(nSALDATU,2) == 0 .or. round(nSALDATU,2) == 0
               PLAN->(dbskip())
               loop
            endif
         endif
      else
         nSALDATU := PLAN->Crab + PLAN->Dbab

         if nSALDATU = 0
            PLAN->(dbskip())
            loop
         endif
      endif

      if ! alltrim(PLAN->Codigo) $ "1-2"
         if PLAN->Reduzido != cREDAPU
            do case
               case cNIVEL == "3"
                    if right(PLAN->Codigo,7) != "       " ; PLAN->(dbskip()) ; loop ; endif
               case cNIVEL == "4"
                    if right(PLAN->Codigo,5) != "     "    ; PLAN->(dbskip()) ; loop ; endif
            endcase
         endif
      endif

      i_nivelcta()

      do case
         case nNIVEL = 2
              nCOL1 := 2
              nCOL2 := 114
         case nNIVEL = 3
              nCOL1 := 10
              nCOL2 := 097
         case nNIVEL = 4
              nCOL1 := 18
              nCOL2 := 079
         case nNIVEL = 5
              nCOL1 := 26
              nCOL2 := 065
      endcase
      do case
         case alltrim(PLAN->Codigo) == "1"
              @ prow()+2,000 say padc("A T I V O",132)
              @ prow()+1,000 say padc("=========",132)
              @ prow()+1,000 say ""
              PLAN->(dbskip())
              loop
         case alltrim(PLAN->Codigo) == "2"
              @ prow()+1,116 say "----------------"
              @ prow()+1,067 say "T O T A L   D O   A T I V O"
              @ prow()  ,116 say transform(nTOTAL,"@E@) 9,999,999,999.99")
              @ prow()+1,116 say "================"
              nTOTAL := 0.00
              @ prow()+3,000 say padc("P A S S I V O",132)
              @ prow()+1,000 say padc("=============",132)
              @ prow()+1,000 say ""
              PLAN->(dbskip())
              loop
      endcase

      if PLAN->Reduzido != cREDAPU .or. (PLAN->Reduzido == cREDAPU .and. cTIPO == "2") .and. cNIVEL == "5"
         @ prow()+1,nCOL1 say left(PLAN->Descricao,37)
         if PLAN->Codigo == nCTAMAER
            lIMPMAE := .T.
         endif
      endif
      
      // SE CONTAS DO PATRIMONIO LIQUIDO, SOMA RESULTADO APURADO ____________

      if cTIPO == "1" .and. (alltrim(PLAN->Codigo) == (left(nCTALP,3)) .or. ;
         alltrim(PLAN->Codigo) == (left(nCTALP,5) ) .or. alltrim(PLAN->Codigo) == (left(nCTALP,7)))
         @ prow(),nCOL2 say ct_convpic(nSALDATU + nCTAGER)
         if ! lSOMOU
            nTOTAL   += nCTAGER + nCTAACU
            lSOMOU   := .T.
         endif
      else
         if PLAN->Reduzido != cREDAPU .or. (PLAN->Reduzido == cREDAPU .and. cTIPO == "2") .and. cNIVEL == "5"
            @ prow(),nCOL2 say ct_convpic(nSALDATU)
         endif
      endif

      // FORCA IMPRESSAO DE CONTA DE APURACAO NO GERENCIAL __________________

      if cTIPO == "1" .and. PLAN->Reduzido == cREDAPU .and. int(nCTAGER) != 0 .and. cNIVEL == "5"
         if ! empty(cREDLUPR) .and. ! lIMPMAE
            @ prow()+1,018    say cMAERESU
         endif
         @ prow()+1,nCOL1     say cDESLP
         @ prow()  ,(nCOL2+2) say transform((nSALDATU+nCTAGER)*-1,"@E@) 9,999,999,999.99")

         if nCTAACU != 0
            @ prow()+1,nCOL1     say cDESLUPR
            @ prow()  ,(nCOL2+2) say transform(nCTAACU*-1,"@E@) 9,999,999,999.99")
         endif
      endif

      if nNIVEL = 2
         nTOTAL += nSALDATU
      endif

      PLAN->(dbskip())

   enddo

   i_imprfim()

return

/////////////////////////////////////////////////////////////////////////////
// MODULO DE IMPRESSAO PARA BALANCO TIPO 4 __________________________________

static function i_impr4

   // INICIALIZACOES DIVERSAS _______________________________________________

   local nCOL , lPRIM := .T., lIMPMAE := .F.

   nNIVEL   := 0
   nSALDANT := nSALDATU := 0.00

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   // LOOP __________________________________________________________________

   do while ! PLAN->(eof()) .and. qcontprn()

      if ! lACHOU
         exit
      endif

      qgirabarra()

      if ! qlineprn() ; return ; endif

      // CABECALHO SE NECESSARIO ____________________________________________

      i_impcab()

      // DADOS DE UMA LINHA _________________________________________________

      i_puxaatps()

      nSALDATU := nSALDANT + PLAN->&cDEB + PLAN->&cCRE
      
      if val(left(PLAN->Codigo,1)) >= 3
         exit
      endif

      qmensa("Processando Conta: " + ct_convcod(PLAN->Codigo))

      if PLAN->Reduzido != cREDAPU .and. nSALDATU = 0
         PLAN->(dbskip())
         loop
      endif

      if right(PLAN->Codigo,5) == "     " .and. ! PLAN->(eof()) .and. ! lPRIM
         @ prow()+1,000 say ""
      endif

      if ! alltrim(PLAN->Codigo) $ "1-2"
         if PLAN->Reduzido != cREDAPU
            do case
               case cNIVEL == "3"
                    if right(PLAN->Codigo,7) != "       " ; PLAN->(dbskip()) ; loop ; endif
               case cNIVEL == "4"
                    if right(PLAN->Codigo,5) != "     "    ; PLAN->(dbskip()) ; loop ; endif
            endcase
         endif
      endif

      i_nivelcta()
      
      do case
         case alltrim(PLAN->Codigo) == "1"
              @ prow()+2,000 say padc("A T I V O",132)
              @ prow()+1,000 say padc("=========",132)
              @ prow()+1,000 say ""
              PLAN->(dbskip())
              loop
         case alltrim(PLAN->Codigo) == "2"
              @ prow()+1,116 say "----------------"
              @ prow()+1,067 say "T O T A L   D O   A T I V O"
              @ prow()  ,116 say transform(nTOTAL,"@E@) 9,999,999,999.99")
              @ prow()+1,116 say "================"
              nTOTAL := 0
              @ prow()+3,000 say padc("P A S S I V O",132)
              @ prow()+1,000 say padc("=============",132)
              @ prow()+1,000 say ""
              PLAN->(dbskip())
              loop
      endcase

      iif(alltrim(PLAN->Codigo) == "1",nCOL := 79,nCOL := 114)

      if PLAN->Reduzido != cREDAPU .or. (PLAN->Reduzido == cREDAPU .and. cTIPO == "2") .and. cNIVEL == "5"
         @ prow()+1,000 say ct_convcod(PLAN->Codigo)
         if right(PLAN->Codigo,5) != "     "
            @ prow(),020 say ct_convcod(PLAN->Reduzido)
         endif
         @ prow(),030 say PLAN->Descricao
         if PLAN->Codigo == nCTAMAER
            lIMPMAE := .T.
         endif
         lPRIM := .F.
      endif
      
      // SE CONTAS DO PATRIMONIO LIQUIDO, SOMA RESULTADO APURADO ____________

      if alltrim(PLAN->Codigo) == (left(nCTALP,3)) .or. ;
         alltrim(PLAN->Codigo) == (left(nCTALP,5)) .or. ;
         alltrim(PLAN->Codigo) == (left(nCTALP,7))
         if right(PLAN->Codigo,5) != "     "
            @ prow(),nCOL say ct_convpic(nSALDATU + nCTAGER)
         endif
      else
         if PLAN->Reduzido != cREDAPU .or. (PLAN->Reduzido == cREDAPU .and. cTIPO == "2") .and. cNIVEL == "5"
            if right(PLAN->Codigo,5) != "     "
               @ prow(),nCOL say ct_convpic(nSALDATU)
            endif
         endif
      endif

      // FORCA IMPRESSAO DE CONTA DE APURACAO NO GERENCIAL __________________

      if PLAN->Reduzido == cREDAPU .and. int(nCTAGER) != 0 .and. cNIVEL == "5"
         if ! empty(cREDLUPR) .and. ! lIMPMAE
            @ prow()+2,000 say ct_convcod(nCTAMAER)
            @ prow()  ,030 say cMAERESU
            @ prow()+1,000 say ""
         endif

         @ prow()+1,000      say ct_convcod(nCTALP) + space(5) + ct_convcod(cREDAPU)
         @ prow()  ,030      say cDESLP
         @ prow()  ,(nCOL+2) say transform((nSALDATU+nCTAGER)*-1,"@E@) 9,999,999,999.99")

         if nCTAACU != 0
            @ prow()+1,000      say ct_convcod(nCTALUPR) + space(5) + ct_convcod(cREDLUPR)
            @ prow()  ,030      say cDESLUPR
            @ prow()  ,(nCOL+2) say transform(nCTAACU*-1,"@E@) 9,999,999,999.99")
         endif

         nTOTAL += nCTAGER + nCTAACU

      endif

      if nNIVEL = 5
         nTOTAL += nSALDATU
      endif

      PLAN->(dbskip())

   enddo

   i_imprfim()

return

/////////////////////////////////////////////////////////////////////////////
// MODULO DE IMPRESSAO DE CABECALHO _________________________________________

static function i_impcab

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      if XPAGINA == 0
         if nPAG <= 0
            XPAGINA := 1
         else
            XPAGINA := --nPAG
         endif
      endif
      if prow() > K_MAX_LIN
         @ prow()+1,116 say "----------------"
         @ prow()+1,085 say "A TRANSPORTAR"
         @ prow()  ,116 say transform(abs(nTOTAL),"@E 9,999,999,999.99")
      endif
      qpageprn()
      qcabecprn(cTITULO1,134,.F.,cTITULO2)
      if cTIPO == "4"
         @ prow()+2,002 say "CODIFICACAO"
         @ prow()  ,030 say "DESCRICAO DA CONTA"
         @ prow()  ,090 say "DEBITOS"
         @ prow()  ,124 say "CREDITOS"
      endif
      if nTOTAL != 0.00
         if cTIPO == "4"
            @ prow()+1,000 say ""
         endif
         @ prow()+1,088 say "TRANSPORTADO"
         @ prow()  ,116 say transform(abs(nTOTAL),"@E 9,999,999,999.99")
         @ prow()+1,000 say ""
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// MODULO DE IMPRESSAO DE FINALIZACAO DE RELATORIO (PARA OS 4 TIPOS) ________

static function i_imprfim

   if ! lACHOU .and. cTIPO != "3"
      return
   endif

   @ prow()+1,116 say "----------------"
   @ prow()+1,067 say "T O T A L   D O   P A S S I V O"
   @ prow()  ,116 say transform(nTOTAL*-1,"@E@) 9,999,999,999.99")
   @ prow()+1,116 say "================"

   if prow() > 50
      qpageprn()
      qcabecprn(cTITULO1,134,.F.,cTITULO2)
   endif

   nEXTENSO := len(qextenso(nTOTAL))
   nTOTAL := iif(nTOTAL < 0, nTOTAL * -1 , nTOTAL)

   if cTIPO != "3"
      @ prow()+3,007 say "Reconhecemos a exatidao do presente BALANCO PATRIMONIAL, em que o ATIVO se equivale ao PASSIVO em R$ " + transform(nTOTAL,"@E 9,999,999,999.99")
      @ prow()+1,007 say "(" + qextenso(nTOTAL) + repl("*",112-nEXTENSO) + "),"
      @ prow()+1,007 say "bem como a DEMONSTRACAO DO RESULTADO DO EXERCICIO e a DEMONSTRACAO DE LUCROS OU PREJUIZOS ACUMULADOS, para o exercicio"
      @ prow()+1,007 say "findo nesta data, conforme elementos fornecidos pela empresa."
   else
      @ prow()+3,007 say "Reconhecemos a exatidao do presente BALANCO PATRIMONIAL DE ABERTURA, que o ATIVO equivale ao PASSIVO em R$ " + transform(nTOTAL,"@E 9,999,999,999.99")
      @ prow()+1,007 say "(" + qextenso(nTOTAL) + repl("*",112-nEXTENSO) + "),"
   endif

   CGM->(dbseek(XCGM))

   @ prow()+2,011 say alltrim(CGM->Municipio) + ", " + strzero(day(dDATA),2) + " de " + qnomemes(dDATA) + " de " + strzero(year(dDATA),4)

   @ prow()+3,011 say "___________________________________                                     ____________________________________"
   @ prow()+1,015 say FILIAL->Contador
   @ prow()  ,090 say CONFIG->Diretor
   @ prow()+1,015 say FILIAL->Crc
   @ prow()  ,090 say CONFIG->Cpf_Direto

   qmensa()

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// PUXA MOVIMENTO DA FAIXA INFORMADA (RESULTADO) ____________________________

static function i_puxares
   local nCONT, nINI, nFIM

   nSALDANT := nSALDACU := PLAN->Saldo_ant

   if cTIPO $ "14"
      nINI := val(cMESI)
      nFIM := val(cMESF)
   else
      nINI := 1
      nFIM := month(dDATA)
   endif

   for nCONT = 1 to (nINI - 1)
       cDEB := "DB"+strzero(nCONT,2)                // VERIFICA RESULTADO
       cCRE := "CR"+strzero(nCONT,2)                // ACUMULADO ANTES DO
       nSALDACU += PLAN->&cDEB + PLAN->&cCRE        // PERIODO INFORMADO
   next

   for nCONT = nINI to nFIM
       cDEB := "DB"+strzero(nCONT,2)                // VERIFICA RESULTADO
       cCRE := "CR"+strzero(nCONT,2)                // APENAS DO PERIODO
       if nCONT != month(dDATA)                     // INFORMADO
          nSALDANT += PLAN->&cDEB + PLAN->&cCRE
       endif
   next
return

/////////////////////////////////////////////////////////////////////////////
// PUXA SALDO ATE MES DE FECHAMENTO (ATIVO E PASSIVO) _______________________

static function i_puxaatps
   local nCONT

   nSALDANT := PLAN->Saldo_ant
   for nCONT = 1 to month(dDATA)
       cDEB := "DB"+strzero(nCONT,2)
       cCRE := "CR"+strzero(nCONT,2)
       if nCONT != month(dDATA)
          nSALDANT += PLAN->&cDEB + PLAN->&cCRE
       endif
   next
return

/////////////////////////////////////////////////////////////////////////////
// ATUALIZA SALDOS SOMENTE DOS LANCAMENTOS DA DATA INFORMADA (BALANCO DE ABERTURA)

static function i_atuaaber
   local nREC := PLAN->(recno())
   local nORD := PLAN->(indexord())
   dbunlockall()

   PLAN->(dbgotop())
   PLAN->(dbsetorder(3))

   select LANC
   LANC->(dbgotop())
   LANC->(dbSetFilter({|| dtoc(data_lanc) == dtoc(dDATA)},"dtoc(data_lanc) == dtoc(dDATA)"))

   do while ! LANC->(eof())

      qgirabarra()

      // ATUALIZA SALDO CONTA DEBITO ________________________________________

      if ! empty(LANC->Cont_db)
         PLAN->(dbseek(LANC->Cont_db))

         if ! PLAN->(eof())
            if right(PLAN->Codigo,5) != "     "
               qmensa("Apurando o Saldo da Conta: " + ct_convcod(PLAN->Codigo))
            else
               LANC->(dbskip())
               loop
            endif

            ct_prop_ab(PLAN->Codigo,LANC->Valor,"DBAB")

            dbunlockall()
         endif
      endif

      // ATUALIZA SALDO CONTA CREDITO _______________________________________

      if ! empty(LANC->Cont_cr)
         PLAN->(dbseek(LANC->Cont_cr))

         if ! PLAN->(eof())
            if right(PLAN->Codigo,5) != "     "
               qmensa("Apurando o Saldo da Conta: " + ct_convcod(PLAN->Codigo))
            else
               LANC->(dbskip())
               loop
            endif

            ct_prop_ab(PLAN->Codigo,LANC->Valor,"CRAB")

            dbunlockall()
         endif
      endif

      LANC->(dbskip())

   enddo

   PLAN->(dbsetorder(nORD))
   PLAN->(dbgoto(nREC))

return

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO DE SALDOS PARA RELATORIO DE ABERTURA __________________________

function ct_prop_ab ( cCONTA , nVALOR , cMACRO )
   local nREC := PLAN->(recno())
   local nORD := PLAN->(indexord())
   local nNEG

   PLAN->(dbsetorder(1))

   cCONTA := alltrim(cCONTA)

   iif(len(cCONTA)==5,cCONTA:=ct_conv_re(cCONTA),)

   nNEG := iif(cMACRO == "CRAB",-1,1)

   if PLAN->(dbseek(cCONTA))
      if PLAN->(qrlock(recno()))
         PLAN->&(cMACRO) := PLAN->&(cMACRO) + nVALOR * nNEG
         PLAN->(dbrunlock(recno()))
      endif
   endif

   do case
      case len(cCONTA) == 12 ; ct_prop_ab ( left(cCONTA,7) , nVALOR , cMACRO )
      case len(cCONTA) == 7  ; ct_prop_ab ( left(cCONTA,4) , nVALOR , cMACRO )
      case len(cCONTA) == 5  ; ct_prop_ab ( left(cCONTA,2) , nVALOR , cMACRO )
      case len(cCONTA) == 3  ; ct_prop_ab ( left(cCONTA,1) , nVALOR , cMACRO )
   endcase

   PLAN->(dbsetorder(nORD))
   PLAN->(dbgoto(nREC))

return

/////////////////////////////////////////////////////////////////////////////
// VERIFICA NIVEL DE CONTA __________________________________________________

static function i_nivelcta
   local nCONT

   for nCONT = 12 to 1 step -1
       if subs(PLAN->Codigo,nCONT,1) != " "
          do case
             case nCONT == 1
                  nNIVEL :=  1
             case nCONT == 2 .or. nCONT == 3
                  nNIVEL :=  2
             case nCONT == 4 .or. nCONT == 5
                  nNIVEL :=  3
             case nCONT == 6 .or. nCONT == 7
                  nNIVEL :=  4
             case nCONT == 8 .or. nCONT == 9 .or. nCONT == 10 .or. nCONT == 11 .or. nCONT == 12
                  nNIVEL :=  5
          endcase
          exit
       endif
   next
return

