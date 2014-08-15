/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: RELATORIO EXTRATO BANCARIO DO DIA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: AGOSTO DE 2002
// OBS........:
// ALTERACOES.: EDUARDO AUGUSTO BORIO

function ts514
#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private cTITULO                                 // titulo do relatorio

private bFILTRO                                 // code block de filtro
private aEDICAO   := {}                         // vetor para os campos de entrada de dados
private dDATA_INI := ctod("")
private dDATA_FIM := ctod("")
private cBANCO    := space(5)                   // codigo do banco
private cATUAL    := space(5)                   // codigo do banco
private nTOT_ENT  := 0
private nTOT_SAI  := 0
private nSALD_ANTER := 0
private nSALD_ATUAL := 0

BANCO->(Dbsetorder(3))  // codigo do banco

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_banco(-1,0,@cBANCO ,"9999")              } ,"BANCO" })
aadd(aEDICAO,{{ || NIL                                           } ,NIL     })

do while .T.

   qlbloc(5,0,"B511A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   set softseek off

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "BANCO"
           if empty(cBANCO)
              qrsay(XNIVEL+1,"Todos os Bancos...")
           else
              if ! BANCO->(dbseek(cBANCO))
                 qmensa("Banco nao cadastrado ! ","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(BANCO->Descricao,40))
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE EXTRATO BANCARIO EM: " + dtoc(XDATA)
   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55
   local nCONT := nCONCENT := nCONCSAI := 0
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   do while ! MOV_BANC->(eof()) .and. qcontprn()

      if MOV_BANC->Data <> XDATA
         if MOV_BANC->Cod_banco == cBANCO .and. MOV_BANC->concilia != "2"
            nCONCENT += MOV_BANC->Entrada
            nCONCSAI += MOV_BANC->Saida
         endif
      endif
      MOV_BANC->(Dbskip())
   enddo
   MOV_BANC->(dbgotop())

   MOV_BANC->(dbsetfilter({||CONCILIA == "2" },'CONCILIA == "2"'))
   MOV_BANC->(dbsetorder(3))
   SALD_BAN->(dbsetorder(1))


   if ! empty(cBANCO)
      SALD_BAN->(dbseek(dtos(XDATA)+cBANCO))
      nSALD_ANTER := SALD_BAN->Saldo + (nCONCSAI-nCONCENT)
   else
      SALD_BAN->(Dbgotop())
   endif


   if ! empty(cBANCO)
      MOV_BANC->(dbseek(cBANCO))
   else
      MOV_BANC->(Dbgotop())
   endif

   do while ! MOV_BANC->(eof()) .and. qcontprn()  // condicao principal de loop

      if MOV_BANC->Data <> XDATA
         MOV_BANC->(Dbskip())
         loop
      endif

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "BANCO...........: " + iif ( BANCO->(dbseek(MOV_BANC->Cod_banco)) , BANCO->Descricao , space(10) ) +"SALDO ANTERIOR......: " + transform(nSALD_ANTER,"@E 9,999,999.99")
          @ prow()+2, 0 say "FORMA DE PAGAMENTO             HISTORICO                                                       SAIDA         ENTRADA        DOCTO"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       cATUAL := MOV_BANC->Cod_banco

       @ prow(),pcol() say XCOND1

       @ prow()+1,00   say iif  (  FORM_PGT->(dbseek(MOV_BANC->Form_pgto))  ,   FORM_PGT->Descricao , space(10) )
       @ prow()  ,31   say left(MOV_BANC->Historico,50)
       @ prow()  ,88   say transform(MOV_BANC->Saida,"@E 999,999,999.99")
       @ prow()  ,105  say transform(MOV_BANC->Entrada,"@E 999,999,999.99")
       @ prow()  ,124  say MOV_BANC->Num_docto
       if ! empty(MOV_BANC->Fornec_cod)
          for nCONT := 0 to 11
              if substr(MOV_BANC->Fornec_cod,(nCONT*5)+1,5) == "     "
                 nCONT := 0
                 exit
              endif
              FORN->(Dbseek(substr(MOV_BANC->Fornec_cod,(nCONT*5)+1,5)))
              @ prow()+1 ,42   say left(FORN->Razao,39)
              @ prow()   ,88   say transf(val(substr(MOV_BANC->Valores,(nCONT*10)+1,10))/100,"@E 999,999,999.99")
          next
          @ prow()+1,00 say ""
       endif

       nTOT_ENT += MOV_BANC->Entrada
       nTOT_SAI += MOV_BANC->Saida

       MOV_BANC->(dbskip())

       if empty(cBANCO) .and. MOV_BANC->Cod_banco <> cATUAL .and. ! MOV_BANC->(eof())
          @ prow()+2, 0  say "TOTAIS..........: "
          @ prow()  ,86  say transform(nTOT_SAI,"@R 9,999,999,999.99")
          @ prow()  ,103 say transform(nTOT_ENT,"@R 9,999,999,999.99")
          if SALD_BAN->(dbseek(dtos(XDATA)+cATUAL))
             nSALD_ANTER := SALD_BAN->Saldo
          endif
          @ prow()+2, 0 say "BANCO...........: " + iif ( BANCO->(dbseek(MOV_BANC->Cod_banco)) , BANCO->Descricao ,) + "SALDO ANTERIOR.......: " + transf(nSALD_ANTER,"@E 9,999,999.99")
          @ prow()+1, 0  say replicate("-",80)
          @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 9,999,999.99")
          @ prow()+1, 0  say replicate("=",80)

          nTOT_ENT := nTOT_SAI := 0
       elseif ! empty(cBANCO)
          if cBANCO <> MOV_BANC->Cod_banco
             exit
          endif
       endif

   enddo
   if nTOT_ENT == 0  .and. nTOT_SAI == 0
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,80)
      @ prow(),pcol() say XCOND1
      @ prow()+1, 0 say "BANCO...........: " + iif ( BANCO->(dbseek(MOV_BANC->Cod_banco)) , BANCO->Descricao , space(10) ) +"SALDO ANTERIOR......: " + transform(nSALD_ANTER,"@E 9,999,999.99")
      @ prow()+1, 0  say replicate("=",80)

      @ prow()+2, 0  say "TOTAIS..........: "
      @ prow()  ,86  say transform(nTOT_SAI,"@R 9,999,999,999.99")
      @ prow()  ,103 say transform(nTOT_ENT,"@R 9,999,999,999.99")

      @ prow(),pcol() say XCOND0
      @ prow()+1, 0  say replicate("-",80)
      @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 9,999,999.99")
      @ prow()+1, 0  say replicate("=",80)

   endif

   if nTOT_ENT <> 0 .or. nTOT_SAI <> 0
      @ prow()+2, 0  say "TOTAIS..........: "
      @ prow()  ,86  say transform(nTOT_SAI,"@R 9,999,999,999.99")
      @ prow()  ,103 say transform(nTOT_ENT,"@R 9,999,999,999.99")

      @ prow(),pcol() say XCOND0
      @ prow()+1, 0  say replicate("-",80)
      @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 9,999,999.99")
      @ prow()+1, 0  say replicate("=",80)
   endif
   nSALD_ANTER := nTOT_ENT := NTOT_SAI := 0
   @ prow(),pcol() say XCOND0

   qstopprn()

return
