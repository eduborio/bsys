/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: RELATORIO EXTRATO BANCARIO DO DIA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR:
// INICIO.....: JANEIRO DE 1998
// OBS........:
// ALTERACOES.: EDUARDO AUGUSTO BORIO
function ts511

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
private cDESCRICAO  := 0
private dINI := dFIM := ctod("")
private sBloc1 := qlbloc("B511B","QBLOC.GLO")
private cTIPO := space(1)
BANCO->(Dbsetorder(3))  // codigo do banco

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI                   ) } ,"dINI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM                   ) } ,"dFIM" })
aadd(aEDICAO,{{ || view_banco(-1,0,@cBANCO ,"9999")              } ,"BANCO" })
aadd(aEDICAO,{{ || NIL                                           } ,NIL     })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO , sBLOC1                   ) } ,"TIPO"       })



do while .T.

   qlbloc(5,0,"B511A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cTIPO := " "

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
      case cCAMPO == "INI"
           if empty(dINI) ; return .F. ; endif
           //dFIM := qfimmes(dINI)
           //qrsay(XNIVEL+1,dFIM)

      case cCAMPO == "FIM"
           if empty(dFIM) ; return .F. ; endif
           if dINI > dFIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "BANCO"
           if empty(cBANCO)
              qrsay(XNIVEL+1,"Todos os Bancos...")
           else
              qrsay(XNIVEL,cBANCO := strzero(val(cBANCO),5) )

              if ! BANCO->(dbseek(cBANCO))
                 qmensa("Banco nao cadastrado ! ","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(BANCO->Descricao,40))
              cDESCRICAO := BANCO->Descricao
           endif

      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ;endif
           qrsay(XNIVEL,qabrev(cTIPO,"NC",{"Normal","Conciliado"}))
           if cTIPO == "N"
              zTIPO := " Normal"
           else
              zTipo := " Conciliado"
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE EXTRATO BANCARIO DE: " + dtoc(dINI)+" a "+dtoc(dFIM)

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

  quse(XDRV_CL,"CONFIG",NIL,NIL,"FATCFG")

//  if FATCFG->Modelo_NF == "01"
     i_mayn()
//  else
//     i_clari()
//  endif

  FATCFG->(dbclosearea())
return


static function i_mayn
   local nMAXLIN := 55
   local nCONT := 0
   local dATU
   local nDIA := 0
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   SALD_BAN->(dbsetorder(1))

   //if ! empty()


   if ! empty(cBANCO)
      set softseek on
      SALD_BAN->(dbseek(dtos(dINI)+cBANCO))
      set softseek off
      nSALD_ANTER := SALD_BAN->Saldo
   else
      SALD_BAN->(Dbgotop())
   endif


//   if ! empty(cBANCO)
//      MOV_BANC->(dbseek(cBANCO))
//   else
//      MOV_BANC->(Dbgotop())
//   endif

   if cTIPO == "N"
      MOV_BANC->(dbsetfilter({|| MOV_BANC->Data >= dINI .and. MOV_BANC->Data <= dFIM .and. MOV_BANC->Cod_banco == cBANCO}))
      MOV_BANC->(dbsetorder(1))
      MOV_BANC->(dbgotop())
      dATU     := MOV_BANC->Data

   else
      MOV_BANC->(dbsetfilter({|| MOV_BANC->Data_comp >= dINI .and. MOV_BANC->Data_comp <= dFIM .and. MOV_BANC->Cod_banco == cBANCO .and. MOV_BANC->Concilia == "2"}))
      MOV_BANC->(dbsetorder(5))
      MOV_BANC->(dbgotop())
      dATU     := MOV_BANC->Data_comp
   endif

   nSLD_DIA := nSALD_Anter

   do while ! MOV_BANC->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND1
          qcabecprn(cTITULO,135)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "BANCO...........: " +  cDESCRICAO +"SALDO ANTERIOR......: " + transform(nSALD_ANTER,"@E 9,999,999.99")
          @ prow()+2, 0 say "Pedido    Data        Historico                                                     Entrada             Saida     Docto        Saldo"
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say replicate("-",135)
       endif

       cATUAL := MOV_BANC->Cod_banco

       @ prow(),pcol() say XCOND1

       //@ prow()+1,00   say iif  (  FORM_PGT->(dbseek(MOV_BANC->Form_pgto))  ,   left(FORM_PGT->Descricao,15) , space(15) )

       @ prow()+1,00   say MOV_BANC->PedComp

       //CCUSTO->(dbsetorder(4))
       //if CCUSTO->(dbseek(MOV_BANC->Ccusto))
       //   @ prow()  ,07   say left(CCUSTO->Descricao,15)
       //endif

       if cTipo == "N"
          @ prow()  ,10   say dtoc(MOV_BANC->Data)
       else
          @ prow()  ,10   say dtoc(MOV_BANC->Data_comp)
       endif
       do case
          case left(MOV_BANC->Internal,4) == "PG00"
               PAGOS->(dbseek(right(MOV_BANC->Internal,7)))
               FORN->(Dbseek(PAGOS->Cod_forn))
               if len(alltrim(MOV_BANC->Fornec_cod)) == 5

                   @ prow()  ,22     say "PG "+left(PAGOS->Fatura,8) + " " +left(FORN->Razao,25)

                   do case
                      case PAGOS->Tipo $ "124"
                           @ prow()  ,pcol()+1 say " "+iif(PAGOS->Nr_cheque!="0000000","CH "+PAGOS->Nr_cheque,"")

                      case PAGOS->Tipo == "3"
                           @ prow()  ,pcol()+1 say " Deb. c/c"

                      case PAGOS->Tipo == "5"
                           @ prow()  ,pcol()+1 say " Ordem Pagto"

                      case PAGOS->Tipo == "7"
                           @ prow()  ,pcol()+1 say " Pagto On Line"

                   endcase
               else
                   @ prow()  ,22   say left(MOV_BANC->Historico,50)
               endif

          otherwise
             @ prow()  ,22  say left(MOV_BANC->Historico,50)

       endcase

       if left(MOV_BANC->Internal,4) == "RE00"
          if MOV_BANC->Entrada == 0
             RECEBIDO->(dbseek(right(MOV_BANC->Internal,7)))
             @ prow()  , 75  say transform(RECEBIDO->Valor,"@E 999,999,999.99")
             nTOT_ENT += RECEBIDO->Valor
             nSLD_Dia += RECEBIDO->Valor
          else
             @ prow()  ,75  say transform(MOV_BANC->Entrada,"@E 999,999,999.99")
          endif
       else
          @ prow()  ,75  say transform(MOV_BANC->Entrada,"@E 999,999,999.99")
       endif


       @ prow()  ,95   say transform(MOV_BANC->Saida,"@E 999,999,999.99")


       @ prow()  ,112  say MOV_BANC->Num_docto

       nSLD_DIA += MOV_BANC->Entrada
       nSLD_DIA -= MOV_BANC->Saida

       @ prow()  ,120 say transform(nSLD_DIA,"@E 9,999,999.99")


       if len(alltrim(MOV_BANC->Fornec_cod)) == 5
         // teste
       else

          if ! empty(MOV_BANC->Fornec_cod)
             for nCONT := 0 to 23
                 if substr(MOV_BANC->Fornec_cod,(nCONT*5)+1,5) == "     "
                    nCONT := 0
                    exit
                 endif
                 FORN->(Dbseek(substr(MOV_BANC->Fornec_cod,(nCONT*5)+1,5)))
                 @ prow()+1 ,22   say left(FORN->Razao,39)
                 @ prow()   ,75   say transf(val(substr(MOV_BANC->Valores,(nCONT*10)+1,10))/100,"@E 999,999,999.99")
             next
             @ prow()+1,00 say ""
          endif
       endif


       nTOT_ENT += MOV_BANC->Entrada
       nTOT_SAI += MOV_BANC->Saida

       MOV_BANC->(dbskip())

       if cTIPO == "N"
          if MOV_BANC->Data != dATU
             @ prow()+1 ,102 say "Saldo em " + dtoc(dATU) + transform(nSLD_DIA,"@E 9,999,999.99")
             @ prow()+1 ,00  say ""
             dATU :=  MOV_BANC->Data
          endif
       else

          if MOV_BANC->Data_comp != dATU
             @ prow()+1 ,102 say "Saldo em " + dtoc(dATU) + transform(nSLD_DIA,"@E 9,999,999.99")
             @ prow()+1 ,00  say ""
             dATU :=  MOV_BANC->Data_comp
          endif
       endif

       if empty(cBANCO) .and. MOV_BANC->Cod_banco <> cATUAL .and. ! MOV_BANC->(eof())
          @ prow()+2, 0  say "TOTAIS..........: "
          @ prow()  ,91  say transform(nTOT_ENT,"@R 9,999,999,999.99")
          @ prow()  ,108 say transform(nTOT_SAI,"@R 9,999,999,999.99")

          if SALD_BAN->(dbseek(dtos(dINI)+cATUAL))
             nSALD_ANTER := SALD_BAN->Saldo
          endif
          @ prow()+2, 0 say "BANCO...........: " + cDESCRICAO + "SALDO ANTERIOR.......: " + transf(nSALD_ANTER,"@E 99,999,999.99")
          @ prow()+1, 0  say replicate("-",135)
          @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 99,999,999.99")
          @ prow()+1, 0  say replicate("=",135)

          nTOT_ENT := nTOT_SAI := 0
       elseif ! empty(cBANCO)
          if cBANCO <> MOV_BANC->Cod_banco
             exit
          endif
       endif

   enddo
  //if MOV_BANC_>Data != dATU
  //   @ prow()+1 ,100 say "Saldo em " + dtoc(dATU) + transform(nSLD_DIA,"@E 9,999,999.99")
 //    @ prow()+1 ,00  say ""
 //    dATU :=  MOV_BANC->Data
  //endif

   if nTOT_ENT == 0  .and. nTOT_SAI == 0
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,135)
      @ prow(),pcol() say XCOND1
      @ prow()+1, 0   say "BANCO...........: " + cDESCRICAO +"SALDO ANTERIOR......: " + transform(nSALD_ANTER,"@E 99,999,999.99")
      @ prow()+1, 0   say replicate("=",135)
      @ prow()+2, 0   say "TOTAIS..........: "
      @ prow()  ,91   say transform(nTOT_ENT,"@R 9,999,999,999.99")
      @ prow()  ,108  say transform(nTOT_SAI,"@R 9,999,999,999.99")

      @ prow(),pcol() say XCOND0
      @ prow()+1, 0  say replicate("-",135)
      @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 99,999,999.99")
      @ prow()+1, 0  say replicate("=",135)
   endif
   if nTOT_ENT <> 0 .or. nTOT_SAI <> 0
      @ prow()+2, 0  say "TOTAIS..........: "
      @ prow()  ,91  say transform(nTOT_ENT,"@R 9,999,999,999.99")
      @ prow()  ,108 say transform(nTOT_SAI,"@R 9,999,999,999.99")


      @ prow(),pcol() say XCOND0
      @ prow()+1, 0  say replicate("-",135)
      @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 9,999,999.99")
      @ prow()+1, 0  say replicate("=",135)
   endif
   nSALD_ANTER := nTOT_ENT := NTOT_SAI := 0
   @ prow(),pcol() say XCOND0

   qstopprn(.F.)



return



static function i_clari

   local nMAXLIN := 55
   local nCONT := 0
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   MOV_BANC->(dbsetorder(3))
   SALD_BAN->(dbsetorder(1))

   //if ! empty()


   if ! empty(cBANCO)
      set softseek on
      SALD_BAN->(dbseek(dtos(dINI)+cBANCO))
      set softseek off
      nSALD_ANTER := SALD_BAN->Saldo
   else
      SALD_BAN->(Dbgotop())
   endif


   if ! empty(cBANCO)
      MOV_BANC->(dbseek(cBANCO))
   else
      MOV_BANC->(Dbgotop())
   endif

   MOV_BANC->(dbsetfilter({ MOV_BANC->Data >= dINI .and. MOV_BANC->Data <= dFIM .and. MOV_BANC->Cod_banco == cBANCO}))

   do while ! MOV_BANC->(eof()) .and. qcontprn()  // condicao principal de loop

      if MOV_BANC->Data < dINI .or. MOV_BANC->Data > dFIM
         MOV_BANC->(Dbskip())
         loop
      endif

      if MOV_BANC->Cod_banco != cBANCO
         MOV_BANC->(dbskip())
         loop
      endif

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND1
          qcabecprn(cTITULO,135)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "BANCO...........: " +  cDESCRICAO +"SALDO ANTERIOR......: " + transform(nSALD_ANTER,"@E 9,999,999.99")
          @ prow()+2, 0 say "Ped.Compra C.Custo     Data          Historico                                                       Saida         Entrada        Docto"
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say replicate("-",135)
       endif

       cATUAL := MOV_BANC->Cod_banco

       @ prow(),pcol() say XCOND1

       //@ prow()+1,00   say iif  (  FORM_PGT->(dbseek(MOV_BANC->Form_pgto))  ,   left(FORM_PGT->Descricao,15) , space(15) )

       @ prow()+1,00   say MOV_BANC->PedComp

       CCUSTO->(dbsetorder(4))
       if CCUSTO->(dbseek(MOV_BANC->Ccusto))
          @ prow()  ,07   say left(CCUSTO->Descricao,15)
       endif

       @ prow()  ,23   say dtoc(MOV_BANC->Data)
       @ prow()  ,36   say left(MOV_BANC->Historico,50)
       @ prow()  ,93   say transform(MOV_BANC->Saida,"@E 999,999,999.99")
       @ prow()  ,110  say transform(MOV_BANC->Entrada,"@E 999,999,999.99")
       @ prow()  ,125  say MOV_BANC->Num_docto
       if ! empty(MOV_BANC->Fornec_cod)
          for nCONT := 0 to 23
              if substr(MOV_BANC->Fornec_cod,(nCONT*5)+1,5) == "     "
                 nCONT := 0
                 exit
              endif
              FORN->(Dbseek(substr(MOV_BANC->Fornec_cod,(nCONT*5)+1,5)))
              @ prow()+1 ,36   say left(FORN->Razao,39)
              @ prow()   ,93   say transf(val(substr(MOV_BANC->Valores,(nCONT*10)+1,10))/100,"@E 999,999,999.99")
          next
          @ prow()+1,00 say ""
       endif

       nTOT_ENT += MOV_BANC->Entrada
       nTOT_SAI += MOV_BANC->Saida

       MOV_BANC->(dbskip())

       if empty(cBANCO) .and. MOV_BANC->Cod_banco <> cATUAL .and. ! MOV_BANC->(eof())
          @ prow()+2, 0  say "TOTAIS..........: "
          @ prow()  ,91  say transform(nTOT_SAI,"@R 9,999,999,999.99")
          @ prow()  ,108 say transform(nTOT_ENT,"@R 9,999,999,999.99")
          if SALD_BAN->(dbseek(dtos(dINI)+cATUAL))
             nSALD_ANTER := SALD_BAN->Saldo
          endif
          @ prow()+2, 0 say "BANCO...........: " + cDESCRICAO + "SALDO ANTERIOR.......: " + transf(nSALD_ANTER,"@E 99,999,999.99")
          @ prow()+1, 0  say replicate("-",135)
          @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 99,999,999.99")
          @ prow()+1, 0  say replicate("=",135)

          nTOT_ENT := nTOT_SAI := 0
       elseif ! empty(cBANCO)
          if cBANCO <> MOV_BANC->Cod_banco
             exit
          endif
       endif

   enddo
   if nTOT_ENT == 0  .and. nTOT_SAI == 0
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,135)
      @ prow(),pcol() say XCOND1
      @ prow()+1, 0 say "BANCO...........: " + cDESCRICAO +"SALDO ANTERIOR......: " + transform(nSALD_ANTER,"@E 99,999,999.99")
      @ prow()+1, 0  say replicate("=",135)

      @ prow()+2, 0  say "TOTAIS..........: "
      @ prow()  ,91  say transform(nTOT_SAI,"@R 9,999,999,999.99")
      @ prow()  ,108 say transform(nTOT_ENT,"@R 9,999,999,999.99")

      @ prow(),pcol() say XCOND0
      @ prow()+1, 0  say replicate("-",135)
      @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 99,999,999.99")
      @ prow()+1, 0  say replicate("=",135)

   endif
   if nTOT_ENT <> 0 .or. nTOT_SAI <> 0
      @ prow()+2, 0  say "TOTAIS..........: "
      @ prow()  ,91  say transform(nTOT_SAI,"@R 9,999,999,999.99")
      @ prow()  ,108 say transform(nTOT_ENT,"@R 9,999,999,999.99")

      @ prow(),pcol() say XCOND0
      @ prow()+1, 0  say replicate("-",135)
      @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 9,999,999.99")
      @ prow()+1, 0  say replicate("=",135)
   endif
   nSALD_ANTER := nTOT_ENT := NTOT_SAI := 0
   @ prow(),pcol() say XCOND0

   qstopprn()

return
