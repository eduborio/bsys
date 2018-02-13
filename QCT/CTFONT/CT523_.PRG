/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: BALANCETE GERAL
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: SETEMBRO DE 1995
// OBS........:
// ALTERACOES.:
function ct523

#include "inkey.ch"
#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1  := qlbloc("B523B","QBLOC.GLO") // tipo de impressao

private aEDICAO  := {}                   // vetor para os campos
private cTITULO                          // titulo do relatorio
private cTIPO                            // tipo de relatorio
private cCENTRO                          // centro de custo
private cFILIAL                          // filial
private cPLANO                           // Plano
private nMES     := 1                    // mes de referencia
private cDEB     := "DB01"               // variavel auxiliar p/ macro
private CCRE     := "CR01"               // variavel auxiliar p/ macro
private nPAG     := 0                    // pagina inicial para impressao
private nNIVEL                           // nivel da conta
private nSALDANT , nSALDATU , nTOTANT    // variaveis totalizadoras
private nTOTDB   , nTOTCR   , nTOTATU    // variaveis totalizadoras
private nS_TOTDB, nS_TOTCR, nS_TOTATU    // variaveis totalizadoras

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@nMES,"99"      )},"MES"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@nPAG,"9999"    )},"PAG"   })
aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL        )},"FILIAL" })
aadd(aEDICAO,{{ || NIL} , NIL }) // descricao do filial
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO  )},"CENTRO"})
aadd(aEDICAO,{{ || NIL} , NIL }) // descricao do centro
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOCO1  )},"TIPO"  })
aadd(aEDICAO,{{ || view_plan7(-1,0,@cPLAN  )},"PLANO"})
aadd(aEDICAO,{{ || NIL} , NIL }) // descricao do centro


do while .T.

   qlbloc(5,0,"B523A","QBLOC.GLO")
   qmensa()
   XNIVEL  := 1
   XFLAG   := .T.
   cORDEM  := " "
   cCENTRO := space(10)
   cFILIAL := space(4)
   cPLAN   := space(7)
   nPAG    := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif ( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   if ! XFLAG ; return .T. ; endif
   do case
      case cCAMPO == "MES"
           if nMES = 0 .OR. nMES > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           qrsay(XNIVEL,strzero(nMES,2))
      case cCAMPO == "PAG"
           //if CONFIG->Lanccent != "S"
           //   XNIVEL+=2
           //endif
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
      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO,"AS",{"Anal¡tico","Sint‚tico"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
   local lACHOU := .F.

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "BALANCETE - " + ltrim(qnomemes(nMES)) + " DE " + CONFIG->Exercicio

   if ! empty(cCENTRO)
      cTITULO += " / CENTRO: " + CCUSTO->Codigo + "-" + CCUSTO->Descricao
   endif

   if ! empty(cFILIAL)
      cTITULO += " / FILIAL: " + FILIAL->Codigo + "-" + alltrim(FILIAL->Razao)
   endif

   PLAN->(dbgotop())

   qmensa()

   //if ! empty(cCENTRO)
  //    select PLAN
 //     qmensa("Filtrando Lan‡amentos com Centro de Custo. Aguarde...")
 //     if PLAN->(qflock())
  //       replace all PLAN->Saantce with 0,PLAN->Dbce with 0,PLAN->Crce with 0
  //       PLAN->(qunlock())
   //   endif
   //   if ! empty(cCENTRO)
   //      LANC->(dbsetorder(6))
   //      LANC->(dbseek(cCENTRO))
   //   endif
   //
   //   do while ! LANC->(eof()) .and. LANC->Centro == cCENTRO
   //      if month(LANC->Data_lanc) == nMES
   //         lACHOU := .T.
  //          exit
  //       endif
  //       LANC->(dbskip())
  //    enddo

  //    if lACHOU
  //       i_saldcent()
  //    else
  //       qmensa("Sem Lan‡amentos por Centro de Custo para o Exerc¡cio !!","B")
  //       return .F.
  //    endif
  //
  // endif
 //
   if ! empty(cFILIAL)
      select PLAN
      qmensa("Filtrando Lan‡amentos com Filial. Aguarde...")
      if PLAN->(qflock())
         replace all PLAN->Saantce with 0,PLAN->Dbce with 0,PLAN->Crce with 0
         PLAN->(qunlock())
      endif
      
	  if ! empty(cFILIAL)
         LANC->(dbsetorder(9))
         LANC->(dbseek(cFILIAL))
      endif
  
      //do while ! LANC->(eof()) .and. LANC->Filial == cFILIAL
      //   if month(LANC->Data_lanc) == nMES
      //      lACHOU := .T.
      //     exit
      //   endif
      //   LANC->(dbskip())
      //enddo
 
      //if lACHOU
         i_saldfil()
	  //else
      //   qmensa("Sem Lan‡amentos por Filial para o Exerc¡cio !!","B")
      //   return .F.
      //endif
 
   endif
 
   qmensa()

return .T.

static function i_imprime

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      if XLOCALIMP == "S"
         i_impre_spool()
      else
         i_impre_prn()
      endif
   endif


return





/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_impre_prn

   // INICIALIZACOES DIVERSAS _______________________________________________

   local nCOL , nTAM , lPRIM := .T.
   nNIVEL   := 0
   nSALDANT := nSALDATU := nTOTANT := nTOTDB := nTOTCR := nTOTATU := nS_TOTDB := nS_TOTCR := nS_TOTATU := 0.00

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! empty(cPLAN)
      PLAN->(dbsetfilter({|| left(PLAN->Codigo,7) == cPLAN}))
   endif


   PLAN->(dbgotop())

  // if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   // LOOP __________________________________________________________________

   do while ! PLAN->(eof())

//      if ! empty(cCENTRO)
//         if left(PLAN->Codigo,1) $ "12"
//            PLAN->(dbskip())
//            loop
//        endif
//      endif

      if mod(PLAN->(recno()),200) == 0
         if ! qlineprn() ; return ; endif
     	 qgirabarra()
		 qmensa("Imprimindo Conta: " + ct_convcod(PLAN->Codigo))
	  endif

      // CABECALHO SE NECESSARIO ____________________________________________

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         if XPAGINA == 0
            if nPAG <= 0
               XPAGINA := 1
            else
               XPAGINA := --nPAG
            endif
         endif
         qpageprn()
         qcabecprn(cTITULO,132,.F.)
         @ prow()+1,0 say "     CONTA       |        DESCRICAO DA CONTA           |  SALDO ANTERIOR  |      DEBITO      |     CREDITO      |     SALDO ATUAL    "
         @ prow()+1,0 say replicate("-",132)
      endif

      // DADOS DE UMA LINHA _________________________________________________

      if empty(cCENTRO) .and. empty(cFILIAL)
         i_puxasaldo()

         if nSALDANT = 0.00 .and. PLAN->&cDEB = 0.00 .and. PLAN->&cCRE = 0.00
            PLAN->(dbskip())
            loop
         endif
      else
         if PLAN->Saantce + PLAN->Crce + PLAN->Dbce = 0
            PLAN->(dbskip())
            loop
         endif
      endif

      if right(PLAN->Codigo,5) == " " .and. ! PLAN->(eof()) .and. ! lPRIM
         @ prow()+1,000 say ""
      endif
      
      

      if empty(cCENTRO) .and. empty(cFILIAL)
         nSALDATU := nSALDANT + PLAN->&cDEB + PLAN->&cCRE
      else
         nSALDATU := PLAN->Saantce + PLAN->Crce + PLAN->Dbce
      endif

      if cTIPO == "A" .or. (cTIPO == "S" .and. ! right(PLAN->Codigo,5) != " ")
         if ! lPRIM
            i_novo_grupo()
         endif

         @ prow()+1,00 say ct_convcod(PLAN->Codigo)
         lPRIM := .F.

      endif

      i_nivelcta()

      do case
         case nNIVEL = 1
              nCOL := 17 ; nTAM := 39
         case nNIVEL = 2
              nCOL := 20 ; nTAM := 36
         case nNIVEL = 3
              nCOL := 23 ; nTAM := 33
         case nNIVEL = 4
              nCOL := 26 ; nTAM := 30
         case nNIVEL = 5
              nCOL := 29 ; nTAM := 27
      endcase

      if cTIPO == "A" .or. (cTIPO == "S" .and. ! right(PLAN->Codigo,5) != " ")

      // @ prow(),nCOL say subs(PLAN->Descricao,1,nTAM)
         @ prow(),nCOL say iif( (len(alltrim(PLAN->Codigo)) >= 1 .and. len(alltrim(PLAN->Codigo)) <= 7), XAENFAT + subs(PLAN->Descricao,1,nTAM) + XDENFAT , subs(PLAN->Descricao,1,nTAM))

         @ prow()  ,056 say ct_convpic(iif(! empty(cCENTRO).or.! empty(cFILIAL),PLAN->Saantce,nSALDANT))
         @ prow()  ,075 say transform(abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB)),"@E 999,999,999,999.99")
         @ prow()  ,094 say transform(abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE)),"@E 999,999,999,999.99")
         @ prow()  ,113 say ct_convpic(nSALDATU)

         if right(PLAN->Codigo,5) <> " " .and. cTIPO == "A"
            nTOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nS_TOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nTOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
            nS_TOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
         endif

         if right(PLAN->Codigo,7) <> " " .and. cTIPO == "S"
            nTOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nS_TOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nTOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
            nS_TOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
         endif

      endif

      PLAN->(dbskip())
      
   enddo

   @ prow()+1,0 say replicate("-",132)
   @ prow()+1,0 say space(61) + "SUB-TOTAIS..: " + transform(nS_TOTDB,"@E 999,999,999,999.99") + " " + transform(nS_TOTCR,"@E 999,999,999,999.99")
   nS_TOTDB := nS_TOTCR := 0
   @ prow()+1,0 say replicate("-",132)
   @ prow()+1,0 say space(60) + "TOTAIS GERAIS: " + transform(nTOTDB,"@E 999,999,999,999.99") + " " + transform(nTOTCR,"@E 999,999,999,999.99")

   // FINALIZA ______________________________________________________________
   @ prow()+3,011 say "___________________________________                                     ____________________________________"
   @ prow()+1,015 say FILIAL->Contador
   @ prow()  ,090 say CONFIG->Diretor
   @ prow()+1,015 say FILIAL->Crc
   @ prow()  ,090 say CONFIG->Cpf_Direto

   qstopprn()

return

static function i_impre_spool

   // INICIALIZACOES DIVERSAS _______________________________________________

   local nCOL , nTAM , lPRIM := .T.
   nNIVEL   := 0
   nSALDANT := nSALDATU := nTOTANT := nTOTDB := nTOTCR := nTOTATU := nS_TOTDB := nS_TOTCR := nS_TOTATU := 0.00

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! empty(cPLAN)
      PLAN->(dbsetfilter({|| left(PLAN->Codigo,7) == cPLAN}))
   endif


   PLAN->(dbgotop())

  // if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   // LOOP __________________________________________________________________

   do while ! PLAN->(eof())

   //   if ! empty(cCENTRO)
   //      if left(PLAN->Codigo,1) $ "12"
   //         PLAN->(dbskip())
   //         loop
   //      endif
   //   endif

      qgirabarra()

      //if ! qlineprn() ; return ; endif
	  
	  if mod(PLAN->(recno()),200) == 0
         if ! qlineprn() ; return ; endif
     	 qgirabarra()
		 qmensa("Imprimindo Conta: " + ct_convcod(PLAN->Codigo))
	  endif

      // CABECALHO SE NECESSARIO ____________________________________________

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         if XPAGINA == 0
            if nPAG <= 0
               XPAGINA := 1
            else
               XPAGINA := --nPAG
            endif
         endif
         qpageprn()
         qcabecprn(cTITULO,132,.F.)
         @ prow()+1,0 say "     CONTA       |        DESCRICAO DA CONTA           |  SALDO ANTERIOR  |      DEBITO      |     CREDITO      |     SALDO ATUAL    "
         @ prow()+1,0 say replicate("-",132)
      endif

      // DADOS DE UMA LINHA _________________________________________________

      if empty(cCENTRO) .and. empty(cFILIAL)
         i_puxasaldo()

         if nSALDANT = 0.00 .and. PLAN->&cDEB = 0.00 .and. PLAN->&cCRE = 0.00
            PLAN->(dbskip())
            loop
         endif
      else
         if PLAN->Saantce + PLAN->Crce + PLAN->Dbce = 0
            PLAN->(dbskip())
            loop
         endif
      endif

      if right(PLAN->Codigo,5) == " " .and. ! PLAN->(eof()) .and. ! lPRIM
         @ prow()+1,000 say ""
      endif
      

      if empty(cCENTRO) .and. empty(cFILIAL)
         nSALDATU := nSALDANT + PLAN->&cDEB + PLAN->&cCRE
      else
         nSALDATU := PLAN->Saantce + PLAN->Crce + PLAN->Dbce
      endif

      if cTIPO == "A" .or. (cTIPO == "S" .and. ! right(PLAN->Codigo,5) != " ")
         if ! lPRIM
            i_novo_grupo()
         endif

         @ prow()+1,00 say ct_convcod(PLAN->Codigo)
         lPRIM := .F.

      endif

      i_nivelcta()

      do case
         case nNIVEL = 1
              nCOL := 17 ; nTAM := 39
         case nNIVEL = 2
              nCOL := 20 ; nTAM := 36
         case nNIVEL = 3
              nCOL := 23 ; nTAM := 33
         case nNIVEL = 4
              nCOL := 26 ; nTAM := 30
         case nNIVEL = 5
              nCOL := 29 ; nTAM := 27
      endcase

      if cTIPO == "A" .or. (cTIPO == "S" .and. ! right(PLAN->Codigo,5) != " ")

      // @ prow(),nCOL say subs(PLAN->Descricao,1,nTAM)
         @ prow(),nCOL say iif( (len(alltrim(PLAN->Codigo)) >= 1 .and. len(alltrim(PLAN->Codigo)) <= 7), XAENFAT + subs(PLAN->Descricao,1,nTAM) + XDENFAT , subs(PLAN->Descricao,1,nTAM))

         @ prow()  ,060 say ct_convpic(iif(! empty(cCENTRO).or.! empty(cFILIAL),PLAN->Saantce,nSALDANT))
         @ prow()  ,075 say transform(abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB)),"@E 999,999,999,999.99")
         @ prow()  ,094 say transform(abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE)),"@E 999,999,999,999.99")
         @ prow()  ,117 say ct_convpic(nSALDATU)

         if right(PLAN->Codigo,5) <> " " .and. cTIPO == "A"
            nTOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nS_TOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nTOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
            nS_TOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
         endif

         if right(PLAN->Codigo,7) <> " " .and. cTIPO == "S"
            nTOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nS_TOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nTOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
            nS_TOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
         endif

      endif

      PLAN->(dbskip())
      
   enddo

   @ prow()+1,0 say replicate("-",132)
   @ prow()+1,0 say space(61) + "SUB-TOTAIS..: " + transform(nS_TOTDB,"@E 999,999,999,999.99") + " " + transform(nS_TOTCR,"@E 999,999,999,999.99")
   nS_TOTDB := nS_TOTCR := 0
   @ prow()+1,0 say replicate("-",132)
   @ prow()+1,0 say space(60) + "TOTAIS GERAIS: " + transform(nTOTDB,"@E 999,999,999,999.99") + " " + transform(nTOTCR,"@E 999,999,999,999.99")

   // FINALIZA ______________________________________________________________
   @ prow()+3,011 say "___________________________________                                     ____________________________________"
   @ prow()+1,015 say FILIAL->Contador
   @ prow()  ,090 say CONFIG->Diretor
   @ prow()+1,015 say FILIAL->Crc
   @ prow()  ,090 say CONFIG->Cpf_Direto

   qstopprn(.F.)

return


/////////////////////////////////////////////////////////////////////////////
// PUXA SALDO ATE MES REQUERIDO _____________________________________________

static function i_puxasaldo

       local  nCONT

       nSALDANT := PLAN->Saldo_ant
       for nCONT = 1 to nMES
           cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)
           if nCONT != nMES
              nSALDANT := nSALDANT + PLAN->&cDEB + PLAN->&cCRE
           endif
       next
return

static function i_puxasaldoFili

       local  nCONT

       nSALDANT := PLAN->Saldo_ant
       for nCONT = 1 to nMES
           cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)
           if nCONT != nMES
              nSALDANT := nSALDANT + PLAN->&cDEB + PLAN->&cCRE
           endif
       next
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
// NOVO GRUPO _______________________________________________________________

static function i_novo_grupo

   if len(alltrim(PLAN->Codigo)) == 1
      @ prow()+1,0 say replicate("-",132)
      @ prow()+1,0 say space(61) + "SUB-TOTAIS..: " + transform(nS_TOTDB,"@E 999,999,999,999.99") + " " + transform(nS_TOTCR,"@E 999,999,999,999.99")
      nS_TOTDB := nS_TOTCR := 0
      qpageprn()
      qcabecprn(cTITULO,132,.F.)
      @ prow()+1,0 say "     CONTA       |        DESCRICAO DA CONTA           |  SALDO ANTERIOR  |      DEBITO      |     CREDITO      |     SALDO ATUAL    "
      @ prow()+1,0 say replicate("-",132)
   endif

return

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO EXCEL____________________________________________

static function i_impre_xls

   // INICIALIZACOES DIVERSAS _______________________________________________

   local nCOL , nTAM , lPRIM := .T.
   nNIVEL   := 0
   nSALDANT := nSALDATU := nTOTANT := nTOTDB := nTOTCR := nTOTATU := nS_TOTDB := nS_TOTCR := nS_TOTATU := 0.00

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   
   //if CONFIG->Mantra == "S"
   //   if ! quse(XDRV_CL,"CLI1",{})
   //	      qmensa("Nao foi possivel abrri Arquivo dos clientes","BL")
   //	  return .F.
	//  endif
	 // CLI1->(dbsetorder(6)) //Conta Contabil Reduzida
   
  // endif

   if ! empty(cPLAN)
      PLAN->(dbsetfilter({|| left(PLAN->Codigo,7) == cPLAN}))
   endif

   PLAN->(dbgotop())

  // if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   // LOOP __________________________________________________________________

   do while ! PLAN->(eof()) .and. qcontprn()

   //   if ! empty(cCENTRO)
   //      if left(PLAN->Codigo,1) $ "12"
   //         PLAN->(dbskip())
  //          loop
  //       endif
  //    endif

      qgirabarra()

	  if mod(PLAN->(recno()),200) == 0
         if ! qlineprn() ; return ; endif
     	 qgirabarra()
		 qmensa("Imprimindo Conta: " + ct_convcod(PLAN->Codigo))
	  endif
	  


      // CABECALHO SE NECESSARIO ____________________________________________

      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         //if XPAGINA == 0
          //  if nPAG <= 0
          //     XPAGINA := 1
          //  else
          //     XPAGINA := --nPAG
          //  endif
         //endif
         qpageprn()
         //qcabecprn(cTITULO,132)
         @ prow()+1,0 say " "+chr(9)+chr(9)+cTITULO
         @ prow()+1,0 say "CONTA"+chr(9)+"COD. REDUZIDO"+chr(9)+"DESCRICAO DA CONTA"+chr(9)+"SALDO ANTERIOR"+chr(9)+"DEBITO"+chr(9)+"CREDITO"+chr(9)+"SALDO ATUAL"
         //@ prow()+1,0 say replicate("-",132)
      endif

      // DADOS DE UMA LINHA _________________________________________________

      if empty(cCENTRO) .and. empty(cFILIAL)
         i_puxasaldo()

         if nSALDANT = 0.00 .and. PLAN->&cDEB = 0.00 .and. PLAN->&cCRE = 0.00
            PLAN->(dbskip())
            loop
         endif
      else
         if PLAN->Saantce + PLAN->Crce + PLAN->Dbce = 0
            PLAN->(dbskip())
            loop
         endif
      endif

      if right(PLAN->Codigo,5) == " " .and. ! PLAN->(eof()) .and. ! lPRIM
         @ prow()+1,000 say ""
      endif
      
      qmensa("Imprimindo Conta: " + ct_convcod(PLAN->Codigo))

      if empty(cCENTRO) .and. empty(cFILIAL)
         nSALDATU := nSALDANT + PLAN->&cDEB + PLAN->&cCRE
      else
         nSALDATU := PLAN->Saantce + PLAN->Crce + PLAN->Dbce
      endif

      if cTIPO == "A" .or. (cTIPO == "S" .and. ! right(PLAN->Codigo,5) != " ")
         if ! lPRIM
            i_grupo_xls()
         endif

         @ prow()+1,00 say ct_convcod(PLAN->Codigo) + chr(9) + PLAN->Reduzido //+ iif( ( CONFIG->Mantra == "S" .and. CLI1->(dbseek(PLAN->Reduzido))  ),  " - Cod. Cli.: "+CLI1->Codigo ,"")
         lPRIM := .F.

      endif

      i_nivelcta()

      do case
         case nNIVEL = 1
              nCOL := 17 ; nTAM := 45
         case nNIVEL = 2
              nCOL := 20 ; nTAM := 45
         case nNIVEL = 3
              nCOL := 23 ; nTAM := 45
         case nNIVEL = 4
              nCOL := 26 ; nTAM := 45
         case nNIVEL = 5
              nCOL := 29 ; nTAM := 45
      endcase

      if cTIPO == "A" .or. (cTIPO == "S" .and. ! right(PLAN->Codigo,5) != " ")

         @ prow()  ,pcol() say chr(9)+space(nCOL-17)+iif( (len(alltrim(PLAN->Codigo)) >= 1 .and. len(alltrim(PLAN->Codigo)) <= 7), subs(PLAN->Descricao,1,nTAM), subs(PLAN->Descricao,1,nTAM))

         @ prow()  ,pcol() say chr(9)+ct_convpic(iif(! empty(cCENTRO).or.! empty(cFILIAL),PLAN->Saantce,nSALDANT))
         @ prow()  ,pcol() say chr(9)+transform(abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB)),"@E 999,999,999,999.99")
         @ prow()  ,pcol() say chr(9)+transform(abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE)),"@E 999,999,999,999.99")
         @ prow()  ,pcol() say chr(9)+ct_convpic(nSALDATU)

         if right(PLAN->Codigo,5) <> " " .and. cTIPO == "A"
            nTOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nS_TOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nTOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
            nS_TOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
         endif

         if right(PLAN->Codigo,7) <> " " .and. cTIPO == "S"
            nTOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nS_TOTDB += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Dbce,PLAN->&cDEB))
            nTOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
            nS_TOTCR += abs(iif(! empty(cCENTRO).or.!empty(cFILIAL),PLAN->Crce,PLAN->&cCRE))
         endif

      endif

      PLAN->(dbskip())
      
   enddo

   @ prow()+1,0 say ""
   @ prow()+1,0 say " "+chr(9) + chr(9)+"SUB-TOTAIS..: " + chr(9)+""+chr(9)+transform(nS_TOTDB,"@E 999,999,999,999.99") + chr(9) + transform(nS_TOTCR,"@E 999,999,999,999.99")
   nS_TOTDB := nS_TOTCR := 0
   @ prow()+1,0 say ""
   @ prow()+1,0 say "" +chr(9)+ chr(9)+"TOTAIS GERAIS: " +chr(9)+""+chr(9)+ transform(nTOTDB,"@E 999,999,999,999.99") + chr(9) + transform(nTOTCR,"@E 999,999,999,999.99")

   // FINALIZA ______________________________________________________________
   //@ prow()+3,011 say "___________________________________                                     ____________________________________"
   //@ prow()+1,015 say FILIAL->Contador
   //@ prow()  ,090 say CONFIG->Diretor
   //@ prow()+1,015 say FILIAL->Crc
   //@ prow()  ,090 say CONFIG->Cpf_Direto

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// NOVO GRUPO EXCEL_______________________________________________________________

static function i_grupo_xls

   if len(alltrim(PLAN->Codigo)) == 1
      @ prow()+1,0 say ""
      @ prow()+1,0 say ""+chr(9)+ "SUB-TOTAIS..: " + chr(9)+chr(9)+transform(nS_TOTDB,"@E 999,999,999,999.99") + chr(9) + transform(nS_TOTCR,"@E 999,999,999,999.99")
      nS_TOTDB := nS_TOTCR := 0
      qpageprn()
      @ prow()+1,0 say "CONTA"+chr(9)+"Cod. Reduzido" + chr(9)+ "DESCRICAO DA CONTA"+chr(9)+"SALDO ANTERIOR"+chr(9)+"DEBITO"+chr(9)+"CREDITO"+chr(9)+"SALDO ATUAL"
      @ prow()+1,0 say ""
   endif

return



