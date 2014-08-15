/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: RAZAO MENSAL
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:
function ct589

#include "inkey.ch"
#define K_LEN_HIST 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1  := qlbloc("B522B","QBLOC.GLO") // tipo de impressao

private aEDICAO  := {}         // vetor para os campos
private aLANC    := {}         // array de lancamentos
private nCONT                  // contador para vetor
private nCONT1                 // contador para vetor
private cHIST                  // historico completo
private cMESANOI               // mes inicial na faixa
private cMESANOF               // mes final na faixa
private nMES                   // mes inicial do razao
private cCENTRO                // centro de custo
private cTIPO    := "T"        // tipo de impressao (c/movim. ou sem no mes)
private cREDUI   := space(6)   // conta reduzida inicial da faixa
private cREDUF   := space(6)   // conta reduzida final da faixa
private cCONTAI                // conta inicial da faixa
private cCONTAF                // conta final da faixa
private cDEB     := "DB"       // variavel auxiliar
private CCRE     := "CR"       // variavel auxiliar
private cDEBM                  // variavel auxiliar p/macro
private CCREM                  // variavel auxiliar p/macro
private nNIVEL                 // nivel da conta
private nSALDOINI , nSALDOFIM  // variaveis totalizadoras
private nTOTDB , nTOTCR        // variaveis totalizadoras
private lPRIMEIRA              // se primeira impressao da conta
private cTITULO                // titulo do relatorio
private nPAG                   // pagina
private nFOLHA:= 1             // folha

cMESANOI := "01/" + right(CONFIG->Exercicio,4)
cMESANOF := "12/" + right(CONFIG->Exercicio,4)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_plredu(-1,0,@cREDUI,"99999-9")},"REDUI"  })
aadd(aEDICAO,{{ || view_plredu(-1,0,@cREDUF,"99999-9")},"REDUF"  })
aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL        )},"FILIAL" })
aadd(aEDICAO,{{ || NIL} , NIL }) // descricao do filial
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO        )},"CENTRO" })
aadd(aEDICAO,{{ || NIL} , NIL }) // descricao do centro
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO       ,sBLOCO1 )},"TIPO"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@cMESANOI  ,"99/9999" )},"MESANOI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@cMESANOF  ,"99/9999" )},"MESANOF"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nPAG        ,"999"   )},"PAG"    })

do while .T.

   qlbloc(5,0,"B522A","QBLOC.GLO")
   PLAN->(dbsetorder(03))         // reduzido
   XNIVEL  := 1
   XFLAG   := .T.
   nPAG    := 1
   cREDUI  := cREDUF := space(6)
   cORDEM  := " "
   cFILIAL := space(4)
   cCENTRO := space(10)
   nNIVEL  := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "REDUI"
           if empty(cREDUI)
              PLAN->(dbgotop())
              do while ! PLAN->(eof())
                 i_nivelcta()
                 if nNIVEL = 5
                    cREDUI := PLAN->Reduzido
                    exit
                 endif
                 PLAN->(dbskip())
              enddo
           endif
           cREDUI := strzero(val(cREDUI),6)
           qsay(09,07,cREDUI,"@R 99999-9")
           if PLAN->(dbseek(qtiraponto(cREDUI)))
              i_nivelcta()
              if nNIVEL != 5
                 qmensa("Conta nao ‚ anal¡tica !","B")
                 return .F.
              endif
              qsay(09,15,ct_convcod(PLAN->Codigo))
              qsay(09,33,left(PLAN->Descricao,38))
           else
              qmensa("Conta nao cadastrada !","B")
              return .F.
           endif
           cCONTAI := PLAN->Codigo
      case cCAMPO == "REDUF"
           if empty(cREDUF)
              PLAN->(dbgobottom())
              do while ! PLAN->(bof())
                 i_nivelcta()
                 if nNIVEL = 5
                    cREDUF := PLAN->Reduzido
                    exit
                 endif
                 PLAN->(dbskip(-1))
              enddo
           endif
           cREDUF := strzero(val(cREDUF),6)
           qsay(13,07,cREDUF,"@R 99999-9")
           if PLAN->(dbseek(qtiraponto(cREDUF)))
              i_nivelcta()
              if nNIVEL != 5
                 qmensa("Conta nao ‚ anal¡tica !","B")
                 return .F.
              endif
              qsay(13,15,ct_convcod(PLAN->Codigo))
              qsay(13,33,left(PLAN->Descricao,38))
           else
              qmensa("Conta nao cadastrada !","B")
              return .F.
           endif
           cCONTAF := PLAN->Codigo
           if val(cCONTAF) < val(cCONTAI)
              qmensa("Conta Final Inferior a Conta Inicial !","B")
              XNIVEL--
              return .F.
           endif
           if CONFIG->Lanccent != "S"
              XNIVEL+=2
           endif
      case cCAMPO == "CENTRO"
           if ! empty(cCENTRO)
              if ! CCUSTO->(dbseek(cCENTRO))
                 qmensa("Centro de Custo n„o cadastrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(CCUSTO->Descricao,38))
           else
              qrsay(XNIVEL+1,"Todos os Centros de Custo...")
           endif
      case cCAMPO == "FILIAL"
           if ! empty(cFILIAL)
              if ! FILIAL->(dbseek(cFILIAL))
                 qmensa("Filial n„o cadastrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->Razao,44))
              XNIVEL:=XNIVEL+2
           else
              qrsay(XNIVEL+1,"Todas as Filiais...")
           endif
      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO,"ST",{"Somente as com Movimenta‡„o no Mes","Todas as Contas"}))
           iif(cTIPO == "T",lPRIMEIRA := .T.,lPRIMEIRA := .F.)
      case cCAMPO == "MESANOI"
           if val(left(cMESANOI,2)) = 0 .or. val(left(cMESANOI,2)) > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           cMESANOF := cMESANOI
           nMES := val(left(cMESANOI,2))
      case cCAMPO == "MESANOF"
           if val(left(cMESANOF,2)) = 0 .or. val(left(cMESANOF,2)) > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           if right(cMESANOF,2) != right(cMESANOI,2)
              qmensa("Anos diferem !","B")
              return .F.
           endif
      case cCAMPO == "PAG"
           if empty(nPAG)
              qmensa("Campo PAGINA n„o pode ser igual a zero !","B")
              return .F.
           endif
           qrsay(XNIVEL,strzero(nPAG,3))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   cTITULO := "RAZAO DAS CONTAS DE " +cMESANOI+ " ATE "+cMESANOF+"."

   if ! empty(cCENTRO)
      cTITULO := "RAZAO DAS CONTAS POR CENTRO: " + CCUSTO->Codigo + "-" + alltrim(CCUSTO->Descricao)+"DE " +cMESANOI+ " ATE "+cMESANOF+"."
   endif

   if ! empty(cFILIAL)
      cTITULO := "RAZAO DAS CONTAS POR FILIAL: " + FILIAL->Codigo + "-" + alltrim(FILIAL->Razao)+"DE " +cMESANOI+ " ATE "+cMESANOF+"."
   endif

   // SELECIONA ORDEM DO ARQUIVO PLAN _______________________________________

   PLAN->(dbsetorder(01))   // codigo

   if ! empty(cCENTRO)
      qmensa("Filtrando Lan‡amentos com Centro de Custo. Aguarde...")
      if PLAN->(qflock())
         select PLAN
         replace all PLAN->Saantce with 0,PLAN->Dbce with 0,PLAN->Crce with 0
         PLAN->(qunlock())
      endif
      if ! empty(cCENTRO)
         LANC->(dbsetorder(6))
         LANC->(dbseek(cCENTRO))
         
         if LANC->(eof())
            qmensa("Sem Lan‡amentos por Centro de Custo para o Exerc¡cio !!","B")
            return .F.
         endif

         PLAN->(dbsetorder(3))

         i_saldoce1()

         PLAN->(dbsetorder(1))

         LANC->(dbseek(cCENTRO))

      endif
   endif

   if ! empty(cFILIAL)
      qmensa("Filtrando Lan‡amentos com Filial. Aguarde...")
      if PLAN->(qflock())
         select PLAN
         replace all PLAN->Saantce with 0,PLAN->Dbce with 0,PLAN->Crce with 0
         PLAN->(qunlock())
      endif
      if ! empty(cFILIAL)
         LANC->(dbsetorder(9))
         LANC->(dbseek(cFILIAL))
         
         if LANC->(eof())
            qmensa("Sem Lan‡amentos por Filial para o Exerc¡cio !!","B")
            return .F.
         endif

         PLAN->(dbsetorder(3))

         i_saldofil1()

         PLAN->(dbsetorder(1))

         LANC->(dbseek(cFILIAL))

      endif
   endif
   PLAN->(dbseek(qtiraponto(cCONTAI)))

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime
   // INICIALIZACOES DIVERSAS _______________________________________________

   private nCOL, nTAM, dDATAATU, lACHOU1 := .F., lACHOU2 := .F.
   private lMUDOUCTA := .T., nNIVEL   := 0, cMESANOATU, dDATAFIM
   private nSALDANT := nSALDATU := nTOTDB := nTOTCR := 0.00
   private cCOND, lZERADO1, lZERADO2, cAUX

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   // LOOP ENQUANTO NAO FOR A CONTA FINAL INFORMADA ______________________

   do while ! PLAN->(eof()) .and. val(PLAN->Codigo) <= val(qtiraponto(cCONTAF)) .and. qcontprn()

      qgirabarra()

      if ! empty(cCENTRO)
         if left(PLAN->Codigo,1) $ "12"
            PLAN->(dbskip())
            loop
         endif
         nSALDATU := nSALDANT := PLAN->Saantce
      endif

//     if ! empty(cFILIAL)
//        if left(PLAN->Codigo,1) $ "12"
//           PLAN->(dbskip())
//           loop
//        endif
//        nSALDATU := nSALDANT := PLAN->Saantce
//     endif

      // LOOP ENQUANTO NAO FOR MES FINAL INFORMADO _______________________

      cMESANOATU := cMESANOI

      do while ! PLAN->(eof()) .and. cMESANOATU <= cMESANOF .and. qcontprn()

         if ! qlineprn() ; return ; endif

         qgirabarra()

         dDATAATU := ctod("01/" + cMESANOATU)

         cDEBM := cDEB + left(cMESANOATU,2)
         cCREM := cCRE + left(cMESANOATU,2)

         // PUXA SALDO ATE MES DE CMESANOATU _____________________________

         lZERADO1 := .F.
         lZERADO2 := .F.

         if empty(cCENTRO) .and. empty(cFILIAL)
            i_puxasaldo()

            if cTIPO == "T"
               if nSALDANT = 0.00 .and. PLAN->&cDEBM = 0.00 .and. PLAN->&cCREM = 0.00
                  lZERADO1 := .T.
               endif
            else
               if PLAN->&cDEBM = 0.00 .and. PLAN->&cCREM = 0.00
                  lZERADO1 := .T.
               endif
            endif
         else
            if cTIPO == "T"
               if nSALDATU == 0.00
                  lZERADO2 := .T.
               endif
            else
               if LANC->(eof())
                  lZERADO2 := .T.
               endif
            endif
         endif

         if lZERADO1 .and. lZERADO2
            cMESANOATU := strzero(val(left(cMESANOATU,2))+1,2) + right(cMESANOATU,3)
            loop
         endif

         // LOOP ENQUANTO NAO FOR FIM DE MES ________________________________

         dDATAFIM := qfimmes(dDATAATU)

         if empty(cCENTRO) .and. empty(cFILIAL)
            cCOND := "PLAN->&cDEBM != 0.00 .or. PLAN->&cCREM != 0.00"
         else
            cCOND := ".T."
         endif

         if &cCOND
            do while dDATAATU <= dDATAFIM .and. qcontprn()

               qgirabarra()

               if empty(cCENTRO) .and. empty(cFILIAL)
                  LANC->(dbsetorder(2))
                  LANC->(dbseek(PLAN->Reduzido+dtos(dDATAATU)))
               endif

               if ! empty(cCENTRO)
                  LANC->(dbsetorder(6))
                  LANC->(dbseek(cCENTRO+PLAN->Reduzido+dtos(dDATAATU)))
               endif

               if ! empty(cFILIAL)
                  LANC->(dbsetorder(9))
                  LANC->(dbseek(cFILIAL+PLAN->Reduzido+dtos(dDATAATU)))
               endif

               lZERADO1 := .F.
               lZERADO2 := .F.

               if ! empty(cCENTRO)
                  if cTIPO == "T"
                     if nSALDATU == 0.00 .and. LANC->(eof())
                        lZERADO1 := .T.
                     endif
                  else
                     if LANC->(eof())
                        lZERADO1 := .T.
                     endif
                  endif
               endif
               
               if ! empty(cFILIAL)
                  if cTIPO == "T"
                     if nSALDATU == 0.00 .and. LANC->(eof())
                        lZERADO1 := .T.
                     endif
                  else
                     if LANC->(eof())
                        lZERADO1 := .T.
                     endif
                  endif
               endif

               lACHOU1 := .F.

               if ! LANC->(eof())
                  lACHOU1 := .T.

                  // LOOP GUARDANDO LANCAMENTOS EM VETOR _______________________

                  do while ! LANC->(eof()) .and. LANC->Cont_db == PLAN->Reduzido .and. right(dtoc(LANC->Data_lanc),5) == right(dtoc(dDATAATU),5)
                     qgirabarra()  //      1                 2           3               4                5            6       7        8
                     aadd(aLANC,{dtoc(LANC->Data_lanc), LANC->Arq, LANC->Num_lanc, LANC->Num_doc, i_historico(), LANC->Valor, "D", LANC->Cont_cr})
                     LANC->(dbskip())
                  enddo
               endif

               if empty(cCENTRO) .and. empty(cFILIAL)
                  LANC->(dbsetorder(3))
                  LANC->(dbseek(PLAN->Reduzido+dtos(dDATAATU)))
               endif

               if ! empty(cCENTRO)
                  LANC->(dbsetorder(7))
                  LANC->(dbseek(cCENTRO+PLAN->Reduzido+dtos(dDATAATU)))
               endif

               if ! empty(cFILIAL)
                  LANC->(dbsetorder(10))
                  LANC->(dbseek(cFILIAL+PLAN->Reduzido+dtos(dDATAATU)))
               endif

               if ! empty(cCENTRO)
                  if cTIPO == "T"
                     if nSALDATU == 0.00 .and. LANC->(eof())
                        lZERADO2 := .T.
                     endif
                  else
                     if LANC->(eof())
                        lZERADO2 := .T.
                     endif
                  endif
               endif
               
               if ! empty(cFILIAL)
                  if cTIPO == "T"
                     if nSALDATU == 0.00 .and. LANC->(eof())
                        lZERADO2 := .T.
                     endif
                  else
                     if LANC->(eof())
                        lZERADO2 := .T.
                     endif
                  endif
               endif

               if lZERADO1 .and. lZERADO2
                  dDATAATU++
                  loop
               endif

               if ! LANC->(eof())
                  lACHOU1 := .T.

                  // LOOP GUARDANDO LANCAMENTOS EM VETOR _______________________

                  do while ! LANC->(eof()) .and. LANC->Cont_cr == PLAN->Reduzido .and. right(dtoc(LANC->Data_lanc),5) == right(dtoc(dDATAATU),5)
                    qgirabarra() //       1                2           3               4                 5               6         7        8
                     aadd(aLANC,{dtoc(LANC->Data_lanc), LANC->Arq, LANC->Num_lanc, LANC->Num_doc, i_historico(), (LANC->Valor*-1), "C", LANC->Cont_db})
                     LANC->(dbskip())
                  enddo
               endif

               asort ( aLANC ,,, { |x,y| x[1] < y[1] } )

               // IMPRIME O CONTEUDO DO VETOR (LANCAMENTOS) ____________________

               if lACHOU1
                  i_imp_lanc()
                  lACHOU2 := .T.
               endif

               aLANC := {}
               dDATAATU++

            enddo

         endif

         // IMPRESSAO DOS TOTAIS DO MES _____________________________________

         if lACHOU2 .and. qcontprn()
//            i_imp_mes()
            lACHOU2 := .F.
         else
            if nSALDANT != 0.00 .and. cTIPO == "T"
               lMUDOUCTA := .T.
               //i_subcabec()
               //i_imp_mes()
               lMUDOUCTA := .F.
            endif
         endif

         cMESANOATU := strzero(val(left(cMESANOATU,2))+1,2) + right(cMESANOATU,3)
         nTOTDB     := nTOTCR := 0.00

      enddo

      lMUDOUCTA := .T.

      // BUSCA PROXIMA CONTA ANALITICA ______________________________________

      do while ! PLAN->(eof())
         PLAN->(dbskip())
         i_nivelcta()
         if nNIVEL == 5
            exit
         endif
      enddo

   enddo

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// SUB-CABECALHO ____________________________________________________________

static function i_subcabec
   qmensa("Imprimindo Conta: " + ct_convcod(PLAN->Codigo)+"/"+PLAN->Descricao)

   @ prow()+1,00 say XCOND0+""
   @ prow()+1,08 say "007/001   "+ct_convcod(PLAN->Reduzido)+"    "+;
                     left(s_conta(PLAN->Codigo),30)+" "+left(PLAN->Descricao,30)+" "+;
                     "  5  S  *  "+left(qnomemes(month(dDATAATU)),3)+"/"+right(alltrim(str(year(dDATAATU))),2)+"    "+;
                     strzero(nFOLHA,4)
   @ prow()+1,00 say ""
   @ prow()+1,00 say ""

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DE UM LANCAMENTO _______________________________________________

static function i_imp_lanc
   local nCONT , nCONTA

   for nCONT1 = 0 to len(aLANC) step 12
     i_subcabec()
     for nCONT := (nCONT1+1) to (nCONT1 + 12)

       if lMUDOUCTA
          //i_subcabec()
          lMUDOUCTA:= .f.
       endif

       @ prow()+1,008 say ltrim(aLANC[nCONT,1])+"  "+aLANC[nCONT,2]+"  "+aLANC[nCONT,3]+"   "+;
                          ct_convcod(aLANC[nCONT,8])+"      "

       @ prow()  ,041 say subs(aLANC[nCONT,5], 1,32)
       @ prow()  ,074 say aLANC[nCONT,4]

       if aLANC[nCONT,7] == "D"
          @ prow(),84  say transform(abs(aLANC[nCONT,6]),"@E 9,999,999,999.99")
       else
          @ prow(),101 say transform(abs(aLANC[nCONT,6]),"@E 9,999,999,999.99")
       endif

       if aLANC[nCONT,7] == "D"
          nTOTDB+=aLANC[nCONT,6]
       else
          nTOTCR+=aLANC[nCONT,6]
       endif                   

       nSALDATU+=aLANC[nCONT,6]

       if ! empty(cCENTRO)
          nSALDANT+=aLANC[nCONT,6]
       endif

       if ! empty(cFILIAL)
          nSALDANT+=aLANC[nCONT,6]
       endif

       if nCONT >= len(aLANC)
          @ prow()+(12-int(len(aLANC)-nCONT1))-1,00 say ""
          i_imp_mes()
          nFOLHA:= 1
          return
       endif
     next
     @ prow()+6, 00 say ""
     nFOLHA ++
   next
return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DA TOTALIZACAO DA CONTA ________________________________________

static function i_imp_mes

   if nSALDANT > 0
      @ prow()+3,08 say transform(nSALDANT*-1,"@E@X 999,999,999,999.99")
   else
      @ prow()+3,08 say transform(nSALDANT*-1,"@E@C 999,999,999,999.99")
   endif

   @ prow(),032 say transform(abs(nTOTDB)  ,"@E 999,999,999,999.99")
   @ prow(),055 say transform(abs(nTOTCR)  ,"@E 999,999,999,999.99")

   if (nTOTDB+nTOTCR) >= 0
      @ prow(),075 say transform((nTOTDB+nTOTCR)*-1,"@E@X 999,999,999,999.99")
   else
      @ prow(),075 say transform((nTOTDB+nTOTCR)*-1,"@E@C 999,999,999,999.99")
   endif

   if nSALDATU >= 0
      @ prow(),96 say transform(nSALDATU*-1,"@E@X 999,999,999,999.99")
   else
      @ prow(),96 say transform(nSALDATU*-1,"@E@C 999,999,999,999.99")
   endif

   @ prow()+4,000 say ""
return

/////////////////////////////////////////////////////////////////////////////
// PUXA SALDO ATE MES QUE ESTA TRABALHANDO __________________________________

static function i_puxasaldo
   local nCONT, cDEBITO, cCREDITO

   nSALDANT := PLAN->Saldo_ant
   for nCONT = 1 to val(left(cMESANOATU,2))
       cDEBITO  := "DB" + strzero(nCONT,2)
       cCREDITO := "CR" + strzero(nCONT,2)
       if nCONT != val(left(cMESANOATU,2))
          nSALDANT := nSALDANT + PLAN->&cDEBITO + PLAN->&cCREDITO
       endif
   next
   nSALDATU := nSALDANT
return

/////////////////////////////////////////////////////////////////////////////
// PUXA SALDO ANTERIOR PARA EMISSAO POR CENTRO DE CUSTO _____________________

static function i_saldoce1
   do while ! LANC->(eof()) .and. LANC->Centro == cCENTRO
      if month(LANC->Data_lanc) < nMES
         if ! empty(LANC->Cont_cr)
            PLAN->(dbseek(LANC->Cont_cr))
            if ! left(PLAN->Codigo,1) $ "12" .and. PLAN->(qrlock())
               replace PLAN->Saantce with PLAN->Saantce + LANC->Valor * -1
               PLAN->(qunlock())
            endif
         endif
         if ! empty(LANC->Cont_db)
            PLAN->(dbseek(LANC->Cont_db))
            if ! left(PLAN->Codigo,1) $ "12" .and. PLAN->(qrlock())
               replace PLAN->Saantce with PLAN->Saantce + LANC->Valor
               PLAN->(qunlock())
            endif
         endif
      endif
      LANC->(dbskip())
   enddo
return

/////////////////////////////////////////////////////////////////////////////
// PUXA SALDO ANTERIOR PARA EMISSAO POR FILIAL ______________________________

static function i_saldofil1
   do while ! LANC->(eof()) .and. LANC->Filial == cFILIAL
      if month(LANC->Data_lanc) < nMES
         if ! empty(LANC->Cont_cr)
            PLAN->(dbseek(LANC->Cont_cr))
            if ! left(PLAN->Codigo,1) $ "12" .and. PLAN->(qrlock())
               replace PLAN->Saantce with PLAN->Saantce + LANC->Valor * -1
               PLAN->(qunlock())
            endif
         endif
         if ! empty(LANC->Cont_db)
            PLAN->(dbseek(LANC->Cont_db))
            if ! left(PLAN->Codigo,1) $ "12" .and. PLAN->(qrlock())
               replace PLAN->Saantce with PLAN->Saantce + LANC->Valor
               PLAN->(qunlock())
            endif
         endif
      endif
      LANC->(dbskip())
   enddo
return

/////////////////////////////////////////////////////////////////////////////
// VERIFICA NIVEL DE CONTA __________________________________________________

static function i_nivelcta
   local nCONT

   for nCONT = 11 to 1 step -1
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

/////////////////////////////////////////////////////////////////////////////
// FORMATA O HISTORICO DO LANCAMENTO PARA O RELATORIO _______________________

static function i_historico
   cHIST := ""
   if (HIST->(dbseek(LANC->Hp1)),cHIST := rtrim(HIST->Descricao)+" ",NIL)
   if (HIST->(dbseek(LANC->Hp2)),cHIST += rtrim(HIST->Descricao)+" ",NIL)
   if (HIST->(dbseek(LANC->Hp3)),cHIST += rtrim(HIST->Descricao)+" ",NIL)
   cHIST += rtrim(LANC->Hist_comp)
return alltrim(cHIST)

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS RETORNANDO CODIGO REDUZIDO ______________

static function view_plredu (XX,YY,ZZ)
   PLAN->(dbSetFilter({|| right(PLAN->Codigo,5) <> " "}, 'right(PLAN->Codigo,5) <> " "'))

   PLAN->(qview(XX,YY,@ZZ,"@K@R 99999-9",NIL,.T.,NIL,;
         {{"ct_convcod(Reduzido)/Cod.Red." ,3},;
          {"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Codigo)/C¢digo"     ,1}},;
          "C",{"keyb(Reduzido)",NIL,NIL,NIL}))

   PLAN->(dbClearFilter())
return


/////////////////////////////////////////////////////////////////////////////
// MOSTRA SUB-CONTA__________________________________________________________

function s_conta ( cCONTA )
   local nREC := PLAN->(recno())
   local nORD := PLAN->(indexord())
   local cCONV

   PLAN->(dbsetorder(1))

   PLAN->(dbseek(left(cCONTA,7)))

   cCONV := PLAN->Descricao

   PLAN->(dbsetorder(nORD))
   PLAN->(dbgoto(nREC))
return cCONV




static function saldo_ant

   if lMUDOUCTA
      @ prow()+1,085 say "Saldo do mes anterior:"

      if nSALDANT > 0
         @ prow(),116 say transform(nSALDANT*-1,"@E@X 9,999,999,999.99")
      else
         @ prow(),116 say transform(nSALDANT*-1,"@E@C 9,999,999,999.99")
      endif

      lMUDOUCTA := .F.
   else
      @ prow()+1,085 say "Saldo transportado:"

      if nSALDATU > 0
         @ prow(),116 say transform(nSALDATU*-1,"@E@X 9,999,999,999.99")
      else
         @ prow(),116 say transform(nSALDATU*-1,"@E@C 9,999,999,999.99")
      endif
   endif

