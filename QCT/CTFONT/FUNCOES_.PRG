/////////////////////////////////////////////////////////////////////////////
// FORMATA CGC OU CPF _______________________________________________________
function funcoes

function fu_conv_cgccpf ( cCGC )

   local nLENG := len(alltrim(cCGC))
   local cRET  := cCGC

   do case
      case nLENG == 14 ; cRET := transform(cCGC,"@R 99.999.999/9999-99")
      case nLENG == 11 ; cRET := transform(cCGC,"@R 999.999.999-99")
   endcase

return padl(cRET,18)


function view_planfin ( LL , CC , XX )
   PLAN_FIN->(dbsetfilter({|| right(PLAN_FIN->codigo,5) != "     " }))
   PLAN_FIN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"left(Descricao,40)/Descri‡„o",2},{"right(codigo,5)/C¢digo",3}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DOS MUNICIPIOS __________________________________________

function view_cgm ( LL , CC , XX )
   CGM->(qview(LL,CC,@XX,"@R 999999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Municipio/Municipio",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// NUMERO DOS LOTES EM ABERTO _________________________________________________

function view_lote ( LL , CC , XX )
   LOTE->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Num_lote/Lote",1}},"C",{"keyb(Num_lote)",NIL,NIL,NIL}))
return

// NUMERO DOS LOTES NOS LANCAMENTOS ____________________________________________

function view_lanc ( LL , CC , XX )
   LANC->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Num_lote/Lote",5}},"C",{"keyb(Num_lote)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA HISTORICOS ______________________________________________

function view_hist (XX,YY,ZZ)
   HIST->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FILIAL __________________________________________________
function view_filial (XX,YY,ZZ)
   FILIAL->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"left(RAZAO,30)/Raz„o",2},{"busca_mun()/Municipio",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR MUNICIPIO NO CGM ______________________________________

function busca_mun
    CGM->(dbseek(FILIAL->Cgm))
return(CGM->Municipio)

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA QINST.DBF ______________________________________________

function view_qinst (XX,YY,ZZ)
   QINST->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Empresa/Empresa",1},{"Razao/Raz„o Social",2}},"C",{"keyb(Empresa)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CENTRO DE CUSTO _________________________________________

function view_ccusto (XX,YY,ZZ)
   CCUSTO->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA NATEREZA DA CONTA _______________________________________

function view_n_conta (XX,YY,ZZ)
   NAT_CONT->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Sigla/Sigla",3},{"Descricao/Descri‡„o",2}},"C",{"keyb(Sigla)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS _________________________________________

function view_plan (XX,YY,ZZ)
   PLAN->(qview(XX,YY,@ZZ,"@K@R 99999-9",NIL,.T.,NIL,;
         {{"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Codigo)/C¢digo"     ,1},;
          {"ct_convcod(Reduzido)/Cod.Red." ,3}},;
          "C",{"keyb(Reduzido)",NIL,NIL,NIL}))
return

function view_plan7 (XX,YY,ZZ)
   PLAN->(qview(XX,YY,@ZZ,"9999999",NIL,.T.,NIL,;
         {{"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Codigo)/C¢digo"     ,1},;
          {"ct_convcod(Reduzido)/Cod.Red." ,3}},;
          "C",{"keyb(left(codigo,7))",NIL,NIL,NIL}))
return


/////////////////////////////////////////////////////////////////////////////
// CONVERTE PARA STRZERO3 ___________________________________________________

function str3 ( cCOD )
   if val(cCOD) <> 0
      return strzero(val(cCOD),3)
   endif
return cCOD

/////////////////////////////////////////////////////////////////////////////
// CONVERTE CODIGOS DE CONTA E REDUZIDO _____________________________________

function ct_convcod ( cCOD )
   if len(cCOD) == 12
      cCOD := transform(cCOD,"@R 9.99.99.99.9999-9")
   else
      cCOD := transform(cCOD,"@R 99999-9")
   endif
return cCOD

/////////////////////////////////////////////////////////////////////////////
// VERIFICA DIGITO __________________________________________________________

function ct_dig_ok ( cCOD )
   local cNUM, cDIG
   if ! empty(cCOD)
      cCOD := strtran(cCOD," ","")
      cNUM := left(cCOD,len(cCOD)-1)
      cDIG := right(cCOD,1)
      if qdigito(cNUM) <> cDIG
         return .F.
      endif
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// RETORNAR .T. SE A CONTA FOR SINTETICA ____________________________________

function ct_e_sint ( cCONTA )
   local nORDER := PLAN->(dbsetorder(3))

   if cCONTA <> NIL
      PLAN->(dbseek(cCONTA))
   endif

   if val(right(PLAN->Codigo,5)) == 0
      return .T.
   endif

   PLAN->(dbsetorder(nORDER))
return .F.

/////////////////////////////////////////////////////////////////////////////
// CONSULTA HISTORICO COMPLETO ______________________________________________

function ct_con_hist
   local nCONT, cHIST := ""
   local sBLOC := qsbloc(09,04,19,77)

   qlbloc(09,04,"B202C","QBLOC.GLO",1)

   HIST->(dbseek(LANC->Hp1)) ; cHIST += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp2)) ; cHIST += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp3)) ; cHIST += alltrim(HIST->Descricao) + " "

   cHIST += LANC->Hist_comp

   for nCONT := 1 to 6
       qsay(nCONT+11,6,subs(cHIST,(nCONT-1)*67+1,67))
   next

   qwait()

   qrbloc(09,04,sBLOC)

return


/////////////////////////////////////////////////////////////////////////////
// CONSULTA HISTORICO COMPLETO ______________________________________________

function ct_con_lote
   local nCONT, cHIST := ""
   local sBLOC := qsbloc(09,04,19,77)

   qlbloc(09,04,"B202C","QBLOC.GLO",1)

   HIST->(dbseek(LOTE->Hp1)) ; cHIST += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LOTE->Hp2)) ; cHIST += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LOTE->Hp3)) ; cHIST += alltrim(HIST->Descricao) + " "

   cHIST += LOTE->Hist_comp

   for nCONT := 1 to 6
       qsay(nCONT+11,6,subs(cHIST,(nCONT-1)*67+1,67))
   next

   qwait()

   qrbloc(09,04,sBLOC)

return

/////////////////////////////////////////////////////////////////////////////
// TRAVA REGISTROS PARA PROPAGACAO DE SALDOS ________________________________

function ct_trava_prop ( cCONTADB , cCONTACR )

   local aVET := {12,7,5,3,1}
   local nREC := PLAN->(recno())
   local nORD := PLAN->(indexord())
   local nCONT

   iif(len(cCONTADB)==6,cCONTADB:=ct_conv_re(cCONTADB),)
   iif(len(cCONTACR)==6,cCONTACR:=ct_conv_re(cCONTACR),)

   PLAN->(dbsetorder(1))

   for nCONT := 1 to 5

       if ! empty(cCONTADB)
          cCODDB := padr ( left(cCONTADB,aVET[nCONT]) + replicate(" " ,11) , 12 )
       else
          cCODDB := ""
       endif

       if ! empty(cCONTACR)
          cCODCR := padr ( left(cCONTACR,aVET[nCONT]) + replicate(" ",11) , 12 )
       else
          cCODCR := ""
       endif

       if ! empty(cCODDB) .and. cCODDB <> cCONTADB
          if ! PLAN->(dbseek(cCODDB))
             qmensa("Conta sintetica nao encontrada " + cCONTADB +" !","B")
             return .F.
          else
             if ! PLAN->(qrlock(recno()))
                return .F.
             endif
          endif
       endif

       if ! empty(cCODCR) .and. cCODCR <> cCONTACR
          if ! PLAN->(dbseek(cCODCR))
             qmensa("Conta sintetica nao encontrada "+ cCONTACR+" !","B")
             return .F.
          else
             if ! PLAN->(qrlock(recno()))
                return .F.
             endif
          endif
       endif

   next

   PLAN->(dbsetorder(nORD))
   PLAN->(dbgoto(nREC))
return .T.

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO DE SALDOS _____________________________________________________

function ct_prop_saldo ( cCONTA , nVALOR , cMACRO )
   local nREC := PLAN->(recno())
   local nORD := PLAN->(indexord())
   local nNEG

   PLAN->(dbsetorder(1))

   cCONTA := alltrim(cCONTA)

   iif(len(cCONTA)==6,cCONTA:=ct_conv_re(cCONTA),)

   if empty(cMACRO)
      nNEG := 1
   else
      nNEG := iif("CR"$cMACRO,-1,1)
   endif

   if empty(cMACRO) .or. "SALDO" $ cMACRO
      cMACRO := "SALDO_ANT"
   endif

   if cMACRO <> "SALDO_ANT" .or. (len(cCONTA) <> 12 .and. cMACRO == "SALDO_ANT")
      if PLAN->(dbseek(padr(cCONTA,12," ")))
         if PLAN->(qrlock(recno()))
            PLAN->&(cMACRO) := PLAN->&(cMACRO) + nVALOR * nNEG

            // no futuro mudar para qunlock(recno())

            PLAN->(dbrunlock(recno()))

         endif
      endif
   endif

   if "SALDO" $ cMACRO
      cMACRO := cMACRO + iif(nNEG<0,"_CR","_DB")
   endif

   do case
      case len(cCONTA) == 12 ; ct_prop_saldo ( left(cCONTA,7) , nVALOR , cMACRO )
      case len(cCONTA) == 7  ; ct_prop_saldo ( left(cCONTA,5) , nVALOR , cMACRO )
      case len(cCONTA) == 5  ; ct_prop_saldo ( left(cCONTA,3) , nVALOR , cMACRO )
      case len(cCONTA) == 3  ; ct_prop_saldo ( left(cCONTA,1) , nVALOR , cMACRO )
   endcase

   PLAN->(dbsetorder(nORD))
   PLAN->(dbgoto(nREC))
return

/////////////////////////////////////////////////////////////////////////////
// CONVERTE CODIGO REDUZIDO PARA EXTENDIDO __________________________________

function ct_conv_re ( cCONTA )
   local nREC := PLAN->(recno())
   local nORD := PLAN->(indexord())
   local cCONV

   PLAN->(dbsetorder(3))

   PLAN->(dbseek(cCONTA))

   cCONV := PLAN->Codigo

   PLAN->(dbsetorder(nORD))
   PLAN->(dbgoto(nREC))
return cCONV


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE RETORNO DE PICTURE CONFORME TIPO DE CONTA ______________________

function ct_convpic ( nVAL )
   if left(PLAN->Codigo,1) $ XCT_DEV
      return(transform(nVAL   ,"@E@) 999,999,999.99"))
   else
      return(transform(nVAL*-1,"@E@) 999,999,999.99"))
   endif

return

/////////////////////////////////////////////////////////////////////////////
// ATUALIZA SALDOS SOMENTE POR CENTRO DE CUSTO _____________________________

function i_saldcent
   dbunlockall()
   nREGIST := LANC->(recno())
   nORDEM  := LANC->(indexord())

   PLAN->(dbsetorder(3))
   LANC->(dbgotop())
   LANC->(dbseek(cCENTRO))
   do while ! LANC->(eof()) .and. LANC->Centro == cCENTRO


      qgirabarra()

      // ATUALIZA SALDO CONTA DEBITO ________________________________________

      if ! empty(LANC->Cont_db)
         PLAN->(dbseek(LANC->Cont_db))

         if ! PLAN->(eof())
            if right(PLAN->Codigo,5) != " "
               qmensa("Apurando o Saldo da Conta: " + ct_convcod(PLAN->Codigo))
            else
               LANC->(dbskip())
               loop
            endif

            ct_prop_ce(PLAN->Codigo,LANC->Valor,"DBCE")

            dbunlockall()
         endif
      endif

      // ATUALIZA SALDO CONTA CREDITO _______________________________________

      if ! empty(LANC->Cont_cr)
         PLAN->(dbseek(LANC->Cont_cr))

         if ! PLAN->(eof())
            if right(PLAN->Codigo,5) != " "
               qmensa("Apurando o Saldo da Conta: " + ct_convcod(PLAN->Codigo))
            else
               LANC->(dbskip())
               loop
            endif

            ct_prop_ce(PLAN->Codigo,LANC->Valor,"CRCE")

            dbunlockall()
         endif
      endif


      LANC->(dbskip())

   enddo

   PLAN->(dbsetorder(1))
   LANC->(dbsetorder(nORDEM))
   LANC->(dbgoto(nREGIST))

return

/////////////////////////////////////////////////////////////////////////////
// ATUALIZA SALDOS SOMENTE POR FILIAL _______________________________________

function i_saldfil
   dbunlockall()

   PLAN->(dbsetorder(3))

   do while ! LANC->(eof()) .and. LANC->Filial == cFILIAL

      //if month(LANC->Data_lanc) != nMES
      //  LANC->(dbskip())
      //   loop
      //endif

      qgirabarra()

      // ATUALIZA SALDO CONTA DEBITO ________________________________________

      if ! empty(LANC->Cont_db)
         PLAN->(dbseek(LANC->Cont_db))

         if ! PLAN->(eof())
            if right(PLAN->Codigo,5) != " "
               qmensa("Apurando o Saldo da Conta: " + ct_convcod(PLAN->Codigo))
            else
               LANC->(dbskip())
               loop
            endif

            ct_prop_ce(PLAN->Codigo,LANC->Valor,"DBCE")

            dbunlockall()
         endif
      endif

      // ATUALIZA SALDO CONTA CREDITO _______________________________________

      if ! empty(LANC->Cont_cr)
         PLAN->(dbseek(LANC->Cont_cr))

         if ! PLAN->(eof())
            if right(PLAN->Codigo,5) != " "
               qmensa("Apurando o Saldo da Conta: " + ct_convcod(PLAN->Codigo))
            else
               LANC->(dbskip())
               loop
            endif

            ct_prop_ce(PLAN->Codigo,LANC->Valor,"CRCE")

            dbunlockall()
         endif
      endif

      LANC->(dbskip())

   enddo

   PLAN->(dbsetorder(1))

return

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO DE SALDOS POR CENTRO DE CUSTO _________________________________

function ct_prop_ce ( cCONTA , nVALOR , cMACRO )
   local nREC := PLAN->(recno())
   local nORD := PLAN->(indexord())
   local nNEG

   PLAN->(dbsetorder(1))

   cCONTA := alltrim(cCONTA)

   nNEG := iif(cMACRO == "CRCE",-1,1)

   if PLAN->(dbseek(padr(cCONTA,12," ")))
      if PLAN->(qrlock(recno()))

         if (! empty(cCENTRO) .or. ! empty(cFILIAL) ).and. month(LANC->Data_lanc) != nMES
            if month(LANC->Data_lanc) < nMES
               PLAN->Saantce := PLAN->Saantce + nVALOR * nNEG
            endif
         else
            PLAN->&(cMACRO) := PLAN->&(cMACRO) + nVALOR * nNEG
         endif
         PLAN->(dbrunlock(recno()))
      endif
   endif

   do case
      case len(cCONTA) == 12 ; ct_prop_ce ( left(cCONTA,7) , nVALOR , cMACRO )
      case len(cCONTA) == 7  ; ct_prop_ce ( left(cCONTA,5) , nVALOR , cMACRO )
      case len(cCONTA) == 5  ; ct_prop_ce ( left(cCONTA,3) , nVALOR , cMACRO )
      case len(cCONTA) == 3  ; ct_prop_ce ( left(cCONTA,1) , nVALOR , cMACRO )
   endcase

   PLAN->(dbsetorder(nORD))
   PLAN->(dbgoto(nREC))

return

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO GERAL DE SALDO ________________________________________________

static function i_propagacao ( cOPT )

   do case

      // ATUALIZA SALDOS NA INCLUSAO E DUPLICACAO ___________________________

      case cOPT $ "ID"
           if ! empty(fCONT_DB)
              ct_prop_saldo(fCONT_DB,fVALOR,"DB"+strzero(month(fDATA_LANC),2))
              CONFIG->&("DB"+strzero(month(fDATA_LANC),2))+=fVALOR
           endif
           if ! empty(fCONT_CR)
              ct_prop_saldo(fCONT_CR,fVALOR,"CR"+strzero(month(fDATA_LANC),2))
              CONFIG->&("CR"+strzero(month(fDATA_LANC),2))+=fVALOR*-1
           endif

      // ATUALIZA SALDOS NA EXCLUSAO ________________________________________

      case cOPT == "E"
           if ! empty(LOTE->Cont_db)
              ct_prop_saldo(LOTE->Cont_db,LOTE->Valor*-1,"DB"+strzero(month(LOTE->Data_lanc),2))
              CONFIG->&("DB"+strzero(month(LOTE->Data_lanc),2))+=LOTE->Valor*-1
           endif
           if ! empty(LOTE->Cont_cr)
              ct_prop_saldo(LOTE->Cont_cr,LOTE->Valor*-1,"CR"+strzero(month(LOTE->Data_lanc),2))
              CONFIG->&("CR"+strzero(month(LOTE->Data_lanc),2))+=LOTE->Valor
           endif

      // RECURSIVAMENTE CHAMA EXCLUSAO E INCLUSAO ___________________________

      case cOPT == "A"
           i_propagacao("E")
           i_propagacao("I")

   endcase

return


