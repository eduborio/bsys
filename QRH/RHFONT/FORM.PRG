/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: FUNCOES DIVERSAS PARA AS FORMULAS DE CALCULO DA FOLHA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....:
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CALCULAR A COMBINACAO ________________________________________

// ESTA FUNCAO VERIFICA SE EXISTEM EVENTOS QUE FORMAM A BASE DE
// CALCULO PARA O EVENTO CORRENTE VERIFICANDO SE O CAMPO "COMBINA"
// DO ARQUIVO EVENTOS NAO ESTA VAZIO.

function jcombeve
   local nLA_RECNO   := LANC->(recno())
   local cCOMBINA    := EVENT->Combina
   local nLENCOMB    := len(cCOMBINA)
   local nVALOR_COMB := 0
   local nVALOR_TRAN := 0
   local nCONT, cSINAL, cEVENTO

   if ! empty(cCOMBINA)
      for nCONT := 1 to nLENCOMB step 4
          cSINAL  := substr(cCOMBINA,nCONT,1)
          if empty(cSINAL) ; exit ; endif
          cEVENTO := substr(cCOMBINA,nCONT+1,3)
          if LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE+cEVENTO))
             nVALOR_TRAN := LANC->Valor
          else
             do case
                case cEVENTO == "@SC"
                     if SITUA->Categoria == "5"
                        nVALOR_TRAN := SITUA->Salario * FUN->Hor_trab
                     else
                        nVALOR_TRAN := SITUA->Salario
                     endif
                other
                     nVALOR_TRAN := 0
             endcase
          endif
          if cSINAL == "+"
             nVALOR_COMB += nVALOR_TRAN
          else
             nVALOR_COMB -= nVALOR_TRAN
          endif
      next
   endif

   LANC->(dbgoto(nLA_RECNO))

return iif ( round(nVALOR_COMB,2) < 0 , 0 , nVALOR_COMB )

/////////////////////////////////////////////////////////////////////////////
// MOSTRA INFORMACAO NO VIDEO DE DENTRO DE UMA FORMULA ______________________

function jvideo ( C_CONTEUDO )
   local sBLOCO := qsbloc(00,00,04,79)
   local cCOR   := setcolor("W+/N")
   clear_sl(00,00,04,79,7)
   @ 00,00 to 04,79 double
   @ 01,02 say "Informa‡„o solicitada na f¢rmula " + cFORMULA + ":"
   @ 01,41 say C_CONTEUDO
   @ 03,44 say "<qualquer tecla para continuar...>"
   //flash_sl(03,44,03,78)
   qinkey(0)
   qrbloc(0,0,sBLOCO)
   setcolor(cCOR)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CHAMADAS DENTRO DAS FORMULAS _________________________________

function jform ( nNUM_FORM , zPARM1 , zPARM2 )
   local cRETORNO, cFORM_ANTERIOR := cFORMULA // cFORMULA e' private no prg
                                              // rh401 (calculo)...
   cFORMULA := strzero(nNUM_FORM,4)
   busca_binaria()
   cRETORNO := eval ( aFORMULAS[nMEIO,2] , zPARM1 , zPARM2 )
   cFORMULA := cFORM_ANTERIOR
return cRETORNO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETIRAR O DIA DE UMA DATA ____________________________________

function jdia ( dDATA )
return day(dDATA)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETIRAR O MES DE UMA DATA ____________________________________

function jmes ( dDATA )
return month(dDATA)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETIRAR O ANO DE UMA DATA ____________________________________

function jano ( dDATA )
return year(dDATA)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR VALOR OU FRACAO DE UM EVENTO __________________________

function jvaleve ( cEVENTO , cAMB )
return jbuscaeve("V",cEVENTO,cAMB)

function jfraeve ( cEVENTO , cAMB )
return jbuscaeve("F",cEVENTO,cAMB)

function jeveper ( cEVENTO , cAMB )
return jfix("V",cEVENTO,cAMB)

function jbuscaeve ( cTIPO , cEVENTO , cAMB )
   local nRET, nRECNO := LANC->(recno())

   iif ( valtype(cEVENTO) = "N" , cEVENTO := strzero(cEVENTO,3) , NIL )
   iif ( valtype(cAMB) != "C" , cAMB := cAMBIENTE , cAMB )

   LANC->(dbseek(cANOMES+FUN->Matricula+cAMB+cEVENTO))
   nRET := iif ( cTIPO == "F" , LANC->Fracao , LANC->Valor )
   LANC->(dbgoto(nRECNO))

return nRET

function jfix ( cTIPO , cEVENTO , cAMB )
   local nRET, nRECNO := LANC->(recno())

   iif ( valtype(cEVENTO) = "N" , cEVENTO := strzero(cEVENTO,3) , NIL )
   iif ( valtype(cAMB) != "C" , cAMB := cAMBIENTE , cAMB )

   LANC->(dbseek("FIXO  "+FUN->Matricula+cAMB+cEVENTO))
   nRET := iif ( cTIPO == "F" , LANC->Fracao , LANC->Valor )
   LANC->(dbgoto(nRECNO))

return nRET

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR A DATA INICIAL DO MES _______________________________

function jimes ( zDATA )
return qinimes ( zDATA )

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR A DATA FINAL DO MES _________________________________

function jfmes ( zDATA )
return qfimmes ( zDATA )

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ARREDONDAMENTO _______________________________________________

function jarredon ( nVALOR , nCASAS )
   iif(nCASAS==NIL,nCASAS:=0,)
return round ( nVALOR , nCASAS )

// FUNCAO PARA MEDIAS DA FINANCEIRA _________________________________________

function jficha ( dINI , dFIM , cAMB , cEVE , cVALFRA , cMEDSOM , cTPMED )
   local nCONT := 0, cAMI, cAMF, nRESULT := 0.00, nMES, nANO, nREC := LANC->(recno())

   iif ( valtype(cTPMED) != "C" , cTPMED := "I" , cTPMED )

   if valtype(dINI) == "N"
      nMES := val(right(cANOMES,2)) - 1
      nANO := val(left(cANOMES,4))
      if nMES == 0
         nMES := 12
         nANO--
      endif
      cAMF := strzero(nANO,4) + strzero(nMES,2)
   else
//    cAMI := strzero(year(dINI)-1900,4) + strzero(month(dINI),2)
//    cAMF := strzero(year(dFIM)-1900,4) + strzero(month(dFIM),2)
      cAMI := str(year(dINI),4) + strzero(month(dINI),2)
      cAMF := str(year(dFIM),4) + strzero(month(dFIM),2)
   endif

   do while .T.
      if cTPMED == "I"
         nCONT++
      endif
      if LANC->(dbseek(cAMF+FUN->Matricula+cAMB+cEVE))
         nRESULT += LANC->(iif(cVALFRA=="V",Valor,Fracao))
         if cTPMED == "P"
            nCONT++
         endif
      endif
      nMES := val(right(cAMF,2)) - 1
//    nANO := val(left(cAMF,2))
      nANO := val(left(cAMF,4))
      if nMES == 0
         nMES := 12
         nANO--
      endif
      if valtype(dINI) == "N"
         if nCONT == dINI ; exit ; endif
      else
         if ( cAMF := strzero(nANO,4) + strzero(nMES,2) ) < cAMI .or. nCONT > 24
            exit
         endif
      endif
   enddo

   if cMEDSOM == "M" .and. nCONT > 0
      nRESULT /= nCONT
   endif

   LANC->(dbgoto(nREC))

return nRESULT

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONVERTER HORA+MINUTO PARA CENTESIMAL ________________________

function qhmtoc ( nVALOR )
   local nMINUTO
   nMINUTO := nVALOR - int(nVALOR)
   nMINUTO := ( nMINUTO * 100 ) / 60
return int(nVALOR) + nMINUTO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONVERTER CENTESIMAL PARA HORA+MINUTO ________________________

function qctohm ( nHORA )
   local nMINUTO
   nMINUTO := nHORA - int(nHORA)
   nMINUTO := ( nMINUTO * 60 ) / 100
   nMINUTO := round(nMINUTO,2)
   nHORA   := int(nHORA)
   if nMINUTO == .60
      nHORA++
      nMINUTO := 0
   endif
return nHORA + nMINUTO

****** FUNCOES PARA OS MNEMONICOS *******

/////////////////////////////////////////////////////////////////////////////
// FUNCAO P/ FAZER SEEK EM BASES_AC NO REGISTRO DO MES ______________________

function rh_sk_bcm ( C_ANOMES )
   BC->(dbseek(FU->Matricula+C_ANOMES))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO P/ FAZER SEEK EM BASES_AC NO REGISTRO DE FERIAS ___________________

function rh_sk_bcf ( C_ANOMES )
   if BC->(dbseek(FU->Matricula+C_ANOMES))
      do while .T.
         if BC->Tipo == "F" ; return ; endif
         if BC->Matricula <> FU->Matricula .or. ;
            BC->Mes_ano <> C_ANOMES
            BC->(dbgobottom())
            BC->(dbskip())
            return
         endif
         BC->(dbskip())
      enddo
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FIXAR VALOR E FRACAO _________________________________________

function rh_fixa ( C_VALOR , C_FRACAO )
   iif ( C_VALOR  == NIL , C_VALOR  := 0 , NIL )
   iif ( C_FRACAO == NIL , C_FRACAO := 0 , NIL )
   replace GR->Valor  with C_VALOR
   replace GR->Fracao with C_FRACAO
   replace GR->Fixa   with .T.
return GR->Valor

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA POSICIONAR TABELAS EM OUTROS PERIODOS ________________________

function rh_tb ( C_TIPO , C_DATA )
   do case
      case C_TIPO == "GE" ; TB_GERAL->(dbseek(dtos(C_DATA),.T.))
      case C_TIPO == "IR" ;  TB_IRRF->(dbseek(dtos(C_DATA),.T.))
      case C_TIPO == "IN" ; TB_IAPA1->(dbseek(dtos(C_DATA),.T.))
      case C_TIPO == "SF" ; TB_SAFAM->(dbseek(dtos(C_DATA),.T.))
   endcase
return


//////////////////////////////////////////////////////////////////////////////
// FUNCAO CRIADA ESPECIFICAMENTE PARA ATENDER A NESSECIDADE DE CALCULO
// DE MEDIA DE COMISSOES ATUALIZADA PELO INDICE DE INFLACAO, --  QUALQUER
// DUVIDA FALAR COM EDUARDO
// DATA: 23/12/99

function jficha2 ( dINI , dFIM , cAMB , cEVE , cVALFRA , cMEDSOM , cTPMED )
   local nCONT := 0, cAMI, cAMF, nRESULT := 0.00, nMES, nANO, nREC := LANC->(recno())

   if ! ("TBGR")->(used())
  //  iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"TBGR",{"TBGR"},'E') ; return .F. ; endif
   endif

   nREC_TBGR := TBGR->(recno())

   iif ( valtype(cTPMED) != "C" , cTPMED := "I" , cTPMED )

   if valtype(dINI) == "N"
      nMES := val(right(cANOMES,2)) - 1
      nANO := val(left(cANOMES,4))
      if nMES == 0
         nMES := 12
         nANO--
      endif
      cAMF := strzero(nANO,4) + strzero(nMES,2)
   else
//    cAMI := strzero(year(dINI)-1900,4) + strzero(month(dINI),2)
//    cAMF := strzero(year(dFIM)-1900,4) + strzero(month(dFIM),2)
      cAMI := str(year(dINI),4) + strzero(month(dINI),2)
      cAMF := str(year(dFIM),4) + strzero(month(dFIM),2)
   endif

   do while .T.
      if cTPMED == "I"
         nCONT++
      endif
      if LANC->(dbseek(cAMF+FUN->Matricula+cAMB+cEVE))
         TBGR->(dbseek(cAMF))                                     //mudanca

         nRESULT += LANC->Valor * TBGR->ind_corrig                //mudanca

******         iif(cVALFRA=="V",Valor,Fracao))
         if cTPMED == "P"
            nCONT++
         endif
      endif
      nMES := val(right(cAMF,2)) - 1
//    nANO := val(left(cAMF,2))
      nANO := val(left(cAMF,4))
      if nMES == 0
         nMES := 12
         nANO--
      endif
      if valtype(dINI) == "N"
         if nCONT == dINI ; exit ; endif
      else
         if ( cAMF := strzero(nANO,4) + strzero(nMES,2) ) < cAMI .or. nCONT > 24
            exit
         endif
      endif
   enddo

   if cMEDSOM == "M" .and. nCONT > 0
      nRESULT /= nCONT
   endif

   LANC->(dbgoto(nREC))
   TBGR->(dbgoto(nREC_TBGR))
   TBGR->(dbclosearea())
return nRESULT

