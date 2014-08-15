/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE FLUXO DE CAIXA (3)
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: FEVEREIRO DE 2003
// OBS........:
function ts520

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}
private cTITULO          // titulo do relatorio
private aEDICAO := {}    // vetor para os campos de entrada de dados
private dDATA_INI  := ctod("")
private dDATA_FIN  := ctod("")

sBLOC1 :=  qlbloc("B520B","QBLOC.GLO",1)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })

do while .T.

   qlbloc(05,0,"B520A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   dDATA_INI  := ctod("")
   dDATA_2    := ctod("")
   dDATA_FIM  := ctod("")
   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)
           dDATA_2 := dDATA_INI

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial nÑo pode ser maior que a Data Final !","B")
              return .F.
           endif
   endcase

return .T.


// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE FLUXO DE CAIXA  "

   RECEBER->(dbsetorder(2))
   RECEBER->(dbgotop())

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55
   local nSALDO := nENTRADA := nSAIDA := nSLD := nATUAL:= 0
   local nDSEMANA := 0
   local nCONT    := 0
   local nSALDO_INI := 0.00
   local nSALDO_TOT := 0.00
   local nSALDO_CAI := 0.00
   local nVISTA     := 0.00
   local nPRAZO     := 0.00
   local dVENC     := ctod("")
   local cMACRO1   := ""
   local cMACRO2   := ""
   local cANT_ENT  := ""
   local cANT_SAI  := ""
   local aFORN     := {}
   local aiFORN    := {}
   local aTIPO     := {}
   local aiTIPO    := {}
   ////////////////////////////////////////////////////////////////////////
   // Funcao pra criar variaveis p/cada data da semana_____________________
   i_cria_var()
   i_forn_var()
   i_inic_var()

   nD_SEMANA := dDATA_FIM - dDATA_2

   if ! qinitprn() ; return ; endif

   dVENC := RECEBER->Data_venc
   do while ! RECEBER->(eof()) .and. qcontprn()

       if RECEBER->Data_venc < dDATA_2 .or. RECEBER->Data_venc > dDATA_FIM
          RECEBER->(dbskip())
          loop
       endif

       if RECEBER->Data_venc == RECEBER->Data_emiss  // VENDAS A VISTA
          for nCONT := 0 to nD_SEMANA
              if RECEBER->Data_venc - dDATA_2 == nCONT
                 cMACRO1 := "nVISTA_" + strzero(nCONT,2)
                 cMACRO2 := "nENT_"+strzero(nCONT,2)
                 &cMACRO1 := &cMACRO1 + RECEBER->Valor_liq
                 &cMACRO2 := &cMACRO2 + RECEBER->Valor_liq
              endif
          next
       endif

       if RECEBER->Data_venc > RECEBER->Data_emiss  // VENDAS A VISTA
          for nCONT := 0 to nD_SEMANA
              if RECEBER->Data_venc - dDATA_2 == nCONT
                 cMACRO1 := "nPRAZO_" + strzero(nCONT,2)
                 cMACRO2 := "nENT_"+strzero(nCONT,2)
                 &cMACRO1 := &cMACRO1 + RECEBER->Valor_liq
                 &cMACRO2 := &cMACRO2 + RECEBER->Valor_liq
              endif
          next
       endif

       RECEBER->(dbskip())

   enddo
   cMACRO1 := ""
   cMACRO2 := ""
   PAGAR->(dbsetorder(2))
   PAGAR->(dbgotop())
   do while ! PAGAR->(eof())

       if PAGAR->Data_venc < dDATA_2 .or. PAGAR->Data_venc > dDATA_FIM
          PAGAR->(dbskip())
          loop
       endif

       for nCONT := 0 to nD_SEMANA
           if PAGAR->Data_venc - dDATA_2 == nCONT
              cMACRO1 := "nSAI_" + strzero(nCONT,2)
              &cMACRO1 := &cMACRO1 + PAGAR->Valor_liq
           endif
       next


       if FORN->(dbseek(PAGAR->Cod_forn))
          if FORN->Tipo == "01"
             for nCONT := 0 to nD_SEMANA
                 if PAGAR->Data_venc - dDATA_2 == nCONT
                    cMACRO1 := "nMAT_" + strzero(nCONT,2)
                    &cMACRO1 := &cMACRO1 + PAGAR->Valor_liq
                 endif
             next
             aadd(aFORN,{PAGAR->Cod_forn,PAGAR->Data_venc,PAGAR->Valor_liq})
          else
             aadd(aTIPO,{FORN->Tipo,PAGAR->Data_venc,PAGAR->Valor_liq})
          endif
       endif
       PAGAR->(dbskip())

   enddo

   PEDIDO->(dbsetorder(1))
   PEDIDO->(dbgotop())
   do while ! PEDIDO->(eof())

      if PEDIDO->Interface
         PEDIDO->(dbskip())
         loop
      endif

      if PEDIDO->Data_ped < dDATA_2 .or. PEDIDO->Data_ped > dDATA_FIM
         PEDIDO->(dbskip())
         loop
      endif

      for nCONT := 0 to nD_SEMANA
          if PEDIDO->Data_ped - dDATA_2 == nCONT
             cMACRO1 := "nSAI_" + strzero(nCONT,2)
             &cMACRO1 := &cMACRO1 + PEDIDO->Val_liq
          endif
      next


      if FORN->(dbseek(PEDIDO->Cod_forn))
         if FORN->Tipo == "01"
            for nCONT := 0 to nD_SEMANA
                if PEDIDO->Data_ped - dDATA_2 == nCONT
                   cMACRO1 := "nMAT_" + strzero(nCONT,2)
                   &cMACRO1 := &cMACRO1 + PEDIDO->Val_liq
                endif
            next
            aadd(aFORN,{PEDIDO->Cod_forn,PEDIDO->Data_ped,PEDIDO->Val_liq})
         else
            aadd(aTIPO,{FORN->Tipo,PEDIDO->Data_ped,PEDIDO->Val_liq})
         endif
      endif
      PEDIDO->(dbskip())

   enddo

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,80)
      @ prow(),pcol() say XCOND1
      @ prow()+1, 0 say "FLUXO DE CAIXA       "
      for nCONT := 0 to nD_SEMANA
          if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
             //nao imprime
          else
             @ prow() , pcol()+15 say qnomesemana(dDATA_INI)
          endif
          dDATA_INI ++
      next
      dDATA_INI := dDATA_2
      @ prow()+1, 0 say "                        "
      for nCONT := 0 to nD_SEMANA
          if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
             //nao imprme
          else
             @ prow() , pcol()+12 say dtoc(dDATA_INI)
          endif
          dDATA_INI ++
      next

      @ prow()+1, 0 say replicate("-",132)
   endif

   dDATA_INI := dDATA_2
   nATUAL := 0
   @ prow()+1,00 say "SALDO                 "
   for nCONT := 0 to nD_SEMANA
       cMACRO1 := "nENT_" + strzero(nCONT,2)
       cMACRO2 := "nSAI_" + strzero(nCONT,2)
       if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
          //nao imprime
       else
          if dDATA_INI < XDATA
             @ prow(),pcol()+9 say transf(i_banco(),"@E 99,999,999.99")
          else
             if dDATA_INI == XDATA
                nATUAL += i_ult_ban() //+ &cMACRO1) - &cMACRO2
                @ prow(),pcol()+9 say transf(nATUAL,"@E 99,999,999.99")
                nATUAL += &cMACRO1 - &cMACRO2
             else

                @ prow(),pcol()+9 say transf(nATUAL,"@E 99,999,999.99")
                nATUAL += &cMACRO1 - &cMACRO2
             endif
          endif
       endif
       dDATA_INI++
   next

   @ prow()+1,00 say "ENTRADAS              "
   dDATA_INI := dDATA_2

   @ prow(),22 say ""
   for nCONT := 0 to nD_SEMANA
        cMACRO1 := "nENT_" + strzero(nCONT,2)
        zTMP := &cMACRO1
        if qnomesemana(dDATA_INI) == "SEGUNDA" //Acumula valores de sabado e domingo p/ segunda feira
           cMACRO1 := "nENT_" + strzero(nCONT-1,2)
           cMACRO2 := "nENT_" + strzero(nCONT-2,2)
           zTMP+= &cMACRO1 + &cMACRO2
        endif
        if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
          //n∆o imprime
        else
           @ prow(),pcol()+9 say iif(zTMP <> 0 ,transf(zTMP,"@E 99,999,999.99"),"     --------" )
           zTMP := 0
        endif
        dDATA_INI++

   next
   @ prow()+1, 0 say replicate("-",132)
   dDATA_INI := dDATA_2

   @ prow()+1, 0 say "VENDA A VISTA         "
   for nCONT := 0 to nD_SEMANA
        cMACRO1 := "nVISTA_" + strzero(nCONT,2)
        zTMP := &cMACRO1
        if qnomesemana(dDATA_INI) == "SEGUNDA" //Acumula valores de sabado e domingo p/ segunda feira
           cMACRO1 := "nVISTA_" + strzero(nCONT-1,2)
           cMACRO2 := "nVISTA_" + strzero(nCONT-2,2)
           zTMP+= &cMACRO1 + &cMACRO2
        endif
        if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
          //n∆o imprime
        else
           @ prow(),pcol()+9 say iif(zTMP <> 0 ,transf(zTMP,"@E 99,999,999.99"),"     --------" )
           zTMP := 0
        endif
        dDATA_INI++
   next

   @ prow()+1,00 say "VENDA A PRAZO         "
   dDATA_INI := dDATA_2

   for nCONT := 0 to nD_SEMANA
        cMACRO1 := "nPRAZO_" + strzero(nCONT,2)
        zTMP := &cMACRO1
        if qnomesemana(dDATA_INI) == "SEGUNDA" //Acumula valores de sabado e domingo p/ segunda feira
           cMACRO1 := "nPRAZO_" + strzero(nCONT-1,2)
           cMACRO2 := "nPRAZO_" + strzero(nCONT-2,2)
           zTMP+= &cMACRO1 + &cMACRO2
        endif
        if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
          //n∆o imprime
        else
           @ prow(),pcol()+9 say iif(zTMP <> 0 ,transf(zTMP,"@E 99,999,999.99"),"     --------" )
           zTMP := 0
        endif
        dDATA_INI++
   next
   @ prow()+1, 0 say replicate("-",132)

   dDATA_INI := dDATA_2

   @ prow()+1,00 say "SAIDAS                "
   @ prow(),22 say ""
   for nCONT := 0 to nD_SEMANA
        cMACRO1 := "nSAI_" + strzero(nCONT,2)
        zTMP := &cMACRO1
        if qnomesemana(dDATA_INI) == "SEGUNDA" //Acumula valores de sabado e domingo p/ segunda feira
           cMACRO1 := "nSAI_" + strzero(nCONT-1,2)
           cMACRO2 := "nSAI_" + strzero(nCONT-2,2)
           zTMP+= &cMACRO1 + &cMACRO2
        endif
        if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
          //n∆o imprime
        else
           @ prow(),pcol()+9 say iif(zTMP <> 0 ,transf(zTMP,"@E 99,999,999.99"),"     --------" )
           zTMP := 0
        endif
        dDATA_INI++
   next
   dDATA_INI := dDATA_2

   @ prow()+1,00 say "MATERIA PRIMA         "
   @ prow(),22 say ""
   for nCONT := 0 to nD_SEMANA
        cMACRO1 := "nMAT_" + strzero(nCONT,2)
        zTMP := &cMACRO1
        if qnomesemana(dDATA_INI) == "SEGUNDA" //Acumula valores de sabado e domingo p/ segunda feira
           cMACRO1 := "nMAT_" + strzero(nCONT-1,2)
           cMACRO2 := "nMAT_" + strzero(nCONT-2,2)
           zTMP+= &cMACRO1 + &cMACRO2
        endif
        if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
          //n∆o imprime
        else
           @ prow(),pcol()+9 say iif(zTMP <> 0 ,transf(zTMP,"@E 99,999,999.99"),"     --------" )
           zTMP := 0
        endif
        dDATA_INI++
   next
   @ prow()+1, 0 say replicate("-",132)

   ///////////////////////////////////////////////////////////////////////////
   //INICIA IMPRESSAO DE FORNECEDORES DE MATERIA PRIMA (SOMENTE TIPO 01)_________

   aiFORN := asort(aFORN,,,{|x,y| x[1] + dtos(x[2]) < y[1] + dtos(y[2]) })
   if !empty(aiFORN)
      cFORN := aiFORN[1,1]
      nCONT := 1
      do while  nCONT <= len(aiFORN)

         for zCONT := 0 to nD_SEMANA
             if aiFORN[nCONT,2] - dDATA_2 == zCONT
                cMACRO1 := "nFORN_" + strzero(zCONT,2)
                &cMACRO1 := &cMACRO1 + aiFORN[nCONT,3]
             endif
         next

         nCONT++
         if nCONT > len(aiFORN)
            nCONT := len(aiFORN)
            exit
         endif

         if aiFORN[nCONT,1] != cFORN
            FORN->(dbseek(cFORN))
            @ prow()+1,00 say left(FORN->Razao,22)
            dDATA_INI := dDATA_2
            for zCONT := 0 to nD_SEMANA
                 cMACRO1 := "nFORN_" + strzero(zCONT,2)
                 zTMP := &cMACRO1
                 if qnomesemana(dDATA_INI) == "SEGUNDA" //Acumula valores de sabado e domingo p/ segunda feira
                    cMACRO1 := "nFORN_" + strzero(zCONT-1,2)
                    cMACRO2 := "nFORN_" + strzero(zCONT-2,2)
                    zTMP+= &cMACRO1 + &cMACRO2
                 endif
                 if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
                   //n∆o imprime
                 else
                    @ prow(),pcol()+9 say iif(zTMP <> 0 ,transf(zTMP,"@E 99,999,999.99"),"     --------" )
                    zTMP := 0
                 endif
                 dDATA_INI++
            next
            cFORN := aiFORN[nCONT,1]
            i_zera_var()
         endif

      enddo

      for zCONT := 0 to nD_SEMANA
           cMACRO1 := "nFORN_" + strzero(zCONT,2)
           zTMP += &cMACRO1
      next

      if zTMP <> 0
         zTMP := 0
         FORN->(dbseek(cFORN))
         @ prow()+1,00 say left(FORN->Razao,22)
         dDATA_INI := dDATA_2
         for zCONT := 0 to nD_SEMANA
              cMACRO1 := "nFORN_" + strzero(zCONT,2)
              zTMP := &cMACRO1
              if qnomesemana(dDATA_INI) == "SEGUNDA" //Acumula valores de sabado e domingo p/ segunda feira
                 cMACRO1 := "nFORN_" + strzero(zCONT-1,2)
                 cMACRO2 := "nFORN_" + strzero(zCONT-2,2)
                 zTMP+= &cMACRO1 + &cMACRO2
              endif
              if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
                //n∆o imprime
              else
                 @ prow(),pcol()+9 say iif(zTMP <> 0 ,transf(zTMP,"@E 99,999,999.99"),"     --------" )
                 zTMP := 0
              endif
              dDATA_INI++
         next
      endif
      zTMP := 0
      i_zera_var()
   endif

   ///////////////////////////////////////////////////////////////////////////
   //INICIA IMPRESSAO DE VALORES POR TIPO_____________________________________

   aiTIPO := asort(aTIPO,,,{|x,y| x[1] + dtos(x[2]) < y[1] + dtos(y[2]) })
   if !empty(aiTIPO)
      cTIPO := aiTIPO[1,1]
      nCONT := 1
      do while  nCONT <= len(aiTIPO)

         for zCONT := 0 to nD_SEMANA
             if aiTIPO[nCONT,2] - dDATA_2 == zCONT
                cMACRO1 := "nFORN_" + strzero(zCONT,2)
                &cMACRO1 := &cMACRO1 + aiTIPO[nCONT,3]
             endif
         next

         nCONT++
         if nCONT > len(aiTIPO)
            nCONT := len(aiTIPO)
            exit
         endif

         if aiTIPO[nCONT,1] != cTIPO
            TIPO->(dbseek(cTIPO))
            @ prow()+1,00 say left(TIPO->Descricao,22)
            dDATA_INI :=  dDATA_2
            for zCONT := 0 to nD_SEMANA
                 cMACRO1 := "nFORN_" + strzero(zCONT,2)
                 zTMP := &cMACRO1
                 if qnomesemana(dDATA_INI) == "SEGUNDA" //Acumula valores de sabado e domingo p/ segunda feira
                    cMACRO1 := "nFORN_" + strzero(zCONT-1,2)
                    cMACRO2 := "nFORN_" + strzero(zCONT-2,2)
                    zTMP+= &cMACRO1 + &cMACRO2
                 endif
                 if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
                   //n∆o imprime
                 else
                    @ prow(),pcol()+9 say iif(zTMP <> 0 ,transf(zTMP,"@E 99,999,999.99"),"     --------" )
                    zTMP := 0
                 endif
                 dDATA_INI++
            next
            cTIPO := aiTIPO[nCONT,1]
            i_zera_var()
         endif

      enddo

      for zCONT := 0 to nD_SEMANA
           cMACRO1 := "nFORN_" + strzero(zCONT,2)
           zTMP += &cMACRO1
      next

      if zTMP <> 0
         zTMP := 0
         TIPO->(dbseek(cTIPO))
         @ prow()+1,00 say left(TIPO->Descricao,22)

         dDATA_INI := dDATA_2
         for zCONT := 0 to nD_SEMANA
              cMACRO1 := "nFORN_" + strzero(zCONT,2)
              zTMP := &cMACRO1
              if qnomesemana(dDATA_INI) == "SEGUNDA" //Acumula valores de sabado e domingo p/ segunda feira
                 cMACRO1 := "nFORN_" + strzero(zCONT-1,2)
                 cMACRO2 := "nFORN_" + strzero(zCONT-2,2)
                 zTMP+= &cMACRO1 + &cMACRO2
              endif
              if qnomesemana(dDATA_INI) == "SABADO " .or. qnomesemana(dDATA_INI) == "DOMINGO"
                //n∆o imprime
              else
                 @ prow(),pcol()+9 say iif(zTMP <> 0 ,transf(zTMP,"@E 99,999,999.99"),"     --------" )
                 zTMP := 0
              endif
              dDATA_INI++
         next
      endif
   endif
   zTMP := 0
   i_zera_var()

   i_inic_var()
   qstopprn()
return

/////////////////////////////////////////////////////////////////////////////
//CALCULA SALDO DE TODOS OS BANCOS___________________________________________
static function i_banco
     nSALDO_SUB := 0
     nSALDO := 0
     nCONCENT := nCONCSAI := 0
     SALD_BAN->(Dbsetorder(1))
     SALD_BAN->(Dbgotop())

     BANCO->(dbgotop())

     MOV_BANC->(Dbsetorder(2))
     MOV_BANC->(Dbgotop())

     do while ! BANCO->(eof())

        do while ! MOV_BANC->(eof()) .and. qcontprn()

           if MOV_BANC->Data <> XDATA
              if MOV_BANC->Cod_banco == BANCO->Codigo .and. MOV_BANC->concilia != "2"
                 nCONCENT += MOV_BANC->Entrada
                 nCONCSAI += MOV_BANC->Saida
              endif
           endif
           MOV_BANC->(Dbskip())
        enddo

        MOV_BANC->(dbsetfilter({||CONCILIA == "2" },'CONCILIA == "2"'))
        MOV_BANC->(dbsetorder(2))
        SALD_BAN->(dbsetorder(1))

        MOV_BANC->(dbgotop())

        if ! SALD_BAN->(dbseek(dtos(dDATA_INI)+BANCO->Codigo))
           nSALDO := 0  // final de semana ?
        else
           if SALD_BAN->Cod_banco != "99999"
              nSALDO := SALD_BAN->Saldo - (nCONCENT - nCONCSAI)
           endif
        endif

        set softseek on
        MOV_BANC->(Dbseek(BANCO->Codigo+dtos(dDATA_INI)))
        set softseek off

        do while ! MOV_BANC->(eof()) .and. MOV_BANC->Cod_banco = BANCO->Codigo .and. MOV_BANC->Data = dDATA_INI
           do case
              case ! empty(MOV_BANC->Entrada)
                   nSALDO += MOV_BANC->Entrada
              case ! empty(MOV_BANC->Saida)
                   nSALDO -= MOV_BANC->Saida
           endcase

           MOV_BANC->(Dbskip())
        enddo
        nSALDO_SUB += nSALDO
        nSALDO := 0
        BANCO->(dbskip())
        if BANCO->Codigo == "99999" //NAO CACULAR SALDO CAIXA JUNTO COM OUTROS BANCOS
           BANCO->(dbskip())
        endif

     enddo
return nSALDO_SUB

/////////////////////////////////////////////////////////////////////////////
//CALCULA SALDO DE TODOS OS BANCOS___________________________________________
static function i_ult_ban
     nULT_SALD := 0
     nSALDO := 0
     nCONCENT := nCONCSAI := 0
     SALD_BAN->(Dbsetorder(1))
     SALD_BAN->(Dbgotop())

     BANCO->(dbgotop())
     MOV_BANC->(dbclearfilter())
     MOV_BANC->(Dbsetorder(2))
     MOV_BANC->(Dbgotop())

     do while ! BANCO->(eof())

        do while ! MOV_BANC->(eof()) .and. qcontprn()
           if MOV_BANC->Data < XDATA
              if MOV_BANC->Cod_banco == BANCO->Codigo .and. MOV_BANC->concilia != "2"
                 nCONCENT += MOV_BANC->Entrada
                 nCONCSAI += MOV_BANC->Saida
              endif
           endif
           MOV_BANC->(Dbskip())
        enddo

        MOV_BANC->(dbgotop())

        if ! SALD_BAN->(dbseek(dtos(XDATA)+BANCO->Codigo))
           nSALDO := 0  // final de semana ?
        else
           if SALD_BAN->Cod_banco != "99999"
              nSALDO := SALD_BAN->Saldo - (nCONCENT - nCONCSAI)
           endif
        endif

        nULT_SALD += nSALDO
        nSALDO := 0
        BANCO->(dbskip())
        if BANCO->Codigo == "99999" //NAO CACULAR SALDO CAIXA JUNTO COM OUTROS BANCOS
           BANCO->(dbskip())
        endif

     enddo
return nULT_SALD

/////////////////////////////////////////////////////////////////////////////
//CALCULA SALDO DE CAIXA ____________________________________________________
static function i_cai
  nSALDO_CAI := 0
  SALD_CAI->(Dbsetorder(1))
  SALD_CAI->(Dbgotop())

  if ! SALD_CAI->(dbseek(dtos(XDATA)))
     nSALDO_CAI := 0  // final de semana ?
  else
     nSALDO_CAI := SALD_CAI->Saldo
  endif


  MOV_CAIX->(Dbsetorder(1))
  MOV_CAIX->(Dbgotop())
  set softseek on
  MOV_CAIX->(Dbseek(XDATA))
  set softseek off

  do while ! MOV_CAIX->(eof()) .and. MOV_CAIX->Data = XDATA

     if ! empty(MOV_CAIX->Entrada)
        nSALDO_CAI += MOV_CAIX->Entrada
     endif

     if ! empty(MOV_CAIX->Saida)
        nSALDO_CAI -= MOV_CAIX->Saida
     endif

     MOV_CAIX->(Dbskip())

  enddo


return nSALDO_CAI

static function i_cria_var
    local nDIA, zMACRO1,zMACRO2,zMACRO3,zMACRO4,nCONT
    nDIA := dDATA_FIM - dDATA_2
    for nCONT := 0 to nDIA
        zMACRO1 := "nVISTA_" + strzero(nCONT,2)
        zMACRO2 := "nPRAZO_" + strzero(nCONT,2)
        zMACRO3 := "nENT_" + strzero(nCONT,2)
        zMACRO4 := "nSALDO_" + strzero(nCONT,2)

        public &zMACRO1.
        public &zMACRO2.
        public &zMACRO3.
        public &zMACRO4.
    next
return

static function i_forn_var
    local nDIA, fMACRO1,fMACRO2,fMACRO3,nCONT
    nDIA := dDATA_FIM - dDATA_2
    for nCONT := 0 to nDIA
        fMACRO1 := "nFORN_" + strzero(nCONT,2)
        fMACRO2 := "nMAT_" + strzero(nCONT,2)
        fMACRO3 := "nSAI_" + strzero(nCONT,2)

        public &fMACRO1.
        public &fMACRO2.
        public &fMACRO3.
    next
return


static function i_inic_var

  local nDIA   := 0
  local gMACRO1 := ""
  local gMACRO2 := ""
  local gMACRO3 := ""
  local gMACRO4 := ""
  local gMACRO5 := ""
  local gMACRO6 := ""
  local gMACRO7 := ""
  local nCONT  := 0
  nDIA := dDATA_FIM - dDATA_2
  for nCONT := 0 to nDIA
      gMACRO1 := "nVISTA_"+ strzero(nCONT,2)
      gMACRO2 := "nPRAZO_"+ strzero(nCONT,2)
      gMACRO3 := "nENT_"+ strzero(nCONT,2)
      gMACRO4 := "nFORN_" + strzero(nCONT,2)
      gMACRO5 := "nSAI_" + strzero(nCONT,2)
      gMACRO6 := "nMAT_" + strzero(nCONT,2)
      gMACRO7 := "nSALDO_" + strzero(nCONT,2)

      &gMACRO1 := 0
      &gMACRO2 := 0
      &gMACRO3 := 0
      &gMACRO4 := 0
      &gMACRO5 := 0
      &gMACRO6 := 0
      &gMACRO7 := 0

  next
return

static function i_zera_var

  local nDIA   := 0
  local gMACRO1 := ""
  local nCONT  := 0
  nDIA := dDATA_FIM - dDATA_2
  for nCONT := 0 to nDIA
      gMACRO1 := "nFORN_"+ strzero(nCONT,2)

      &gMACRO1 := 0

  next
return

