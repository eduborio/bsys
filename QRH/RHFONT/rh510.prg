/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: RELATORIO DE PARTICIPACAO NOS RESULTADOS
// OBJETIVO...: VALORES A PAGAR COM BASE NOS RESULTADOS DA EMPRESA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2001
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. lastkey()==27)}

private sBLOCO1 := qlbloc("B510A","QBLOC.GLO") // bloco basico

private cTITULO                // titulo do relatorio
private cCCUSTO                // Centro de custo para Filtro de Dados
private nPREMIO                // Valor Total do Premio
private nMESES                 // Meses Trabalhados pelo Funcionario no periodo
private nCENT                  // Percentual do Total Premio em relacao ao funcionario
private nMEDIA                 // Media p/ calculo de salario no periodo
private nTOTAL                 // Total dos salarios
private nSAL                   // Total dos salarios
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cPERI                  // periodo inicial
private cPERF                  // periodo final
private dINI                   // periodo final
private dFIM                   // periodo final


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cPERI,"@R 99/9999") }   , "PERI"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPERF,"@R 99/9999") }   , "PERF"      })
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCCUSTO   )}      , "CCUSTO" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do Centro de Custo
aadd(aEDICAO,{{ || qgetx(-1,0,@nPREMIO,"@E 9,999,999.99")}, "PREMIO" })

do while .T.

   qlbloc(5,0,"B510A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cCCUSTO    := space(8)
   cPERI      := space(6)
   cPERF      := space(6)
   cANOMESI   := space(6)
   cANOMESF   := space(6)
   nPREMIO    := 0
   nMEDIA     := 0
   nMESES     := 0
   nTOTAL     := 0
   nCENT      := 0
   cTITULO    := ""
   dINI       := space(6)
   dFIM       := space(6)
   qmensa()

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   if XFLAG
      do case
         case cCAMPO == "CCUSTO"
              if empty(cCCUSTO); return .F.; endif
              if ! empty(cCCUSTO)
                 if ! CCUSTO->(dbseek(cCCUSTO))
                   qmensa("Centro de Custo Nao Cadastrado!!!","B")
                   return .F.
                 endif
                 qrsay(XNIVEL+1,left(CCUSTO->Descricao,30))
              endif
      endcase
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTITULO := "PARTICIPACAO NOS RESULTADOS - "+alltrim(CCUSTO->Descricao)
   qmensa()
   dINI := right(strzero(val(cPERI),6),4) + left(strzero(val(cPERI),6),2)
   dFIM := right(strzero(val(cPERF),6),4) + left(strzero(val(cPERF),6),2)

   FUN->(dbsetorder(1))
   SITUA->(Dbsetorder(4))
   SITUA->(dbSetFilter({|| CCUSTO == cCCUSTO .and. ANOMES >= dINI .and. ANOMES <= dFIM},'Ccusto == cCCUSTO .and. ANOMES >= dINI .and. ANOMES <= dFIM'))

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   //select LANC
   //et relation to Evento into EVENT



   FUN->(dbgotop())
   SITUA->(dbgotop())
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nCONT := 0
   local nSAL  := 0
   local nMESES:= 0
   local nMEDIA:= 0
   local nCENT := 0
   local cCOND

      // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   cPERI := val(subs(cPERI,3,4) + subs(cPERI,1,2))
   cPERF := val(subs(cPERF,3,4) + subs(cPERF,1,2))

   i_tot_salario()

   FUN->(dbgotop())
   SITUA->(dbgotop())
   nCONT := 0

   do while ! FUN->(eof()) .and. qcontprn() //Condicao principal de loop
       if ! qlineprn() ; return ; endif

        qmensa(FUN->Matricula+" "+left(FUN->Nome,40))

       if FUN->Data_adm > ctod("30/"+ right(strzero(cPERF,6),2)+"/"+left(strzero(cPERF,6),4))
          FUN->(dbskip())
          loop
       endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,80)

          @ prow()+1,0 say "MAT.   NOME                                    SALARIO         %         PREMIO"
          @ prow()+1,0 say replicate("-",80)
       endif


      if SITUA->(dbseek(FUN->Matricula+str(cPERF)))

         if SITUA->Categoria == "5"
            nSAL := SITUA->Salario * 220
         else
            nSAL := SITUA->Salario
         endif
      elseif SITUA->(dbseek(FUN->Matricula+str(cPERF-1,6))) //5 11

         if SITUA->Categoria == "5"
            nSAL := SITUA->Salario * 220
         else
            nSAL := SITUA->Salario
         endif
      elseif SITUA->(dbseek(FUN->Matricula+str(cPERF-2,6))) //4 10

         if SITUA->Categoria == "5"
            nSAL := SITUA->Salario * 220
         else
            nSAL := SITUA->Salario
         endif
      elseif SITUA->(dbseek(FUN->Matricula+str(cPERF-3,6))) //3 9

         if SITUA->Categoria == "5"
            nSAL := SITUA->Salario * 220
         else
            nSAL := SITUA->Salario
         endif
      elseif SITUA->(dbseek(FUN->Matricula+str(cPERF-4,6))) //2 8

         if SITUA->Categoria == "5"
            nSAL := SITUA->Salario * 220
         else
            nSAL := SITUA->Salario
         endif

      elseif SITUA->(dbseek(FUN->Matricula+str(cPERI,6)))

         if SITUA->Categoria == "5"
            nSAL := SITUA->Salario * 220
         else
            nSAL := SITUA->Salario
         endif
      else
         FUN->(dbskip())
         loop
      endif

      for nCONT = cPERI to cPERF

          nMEDIA ++
          if subs(str(nCONT,6),5,2) == "13"
             nCONT += 87
             loop
          endif
          if SITUA->(dbseek(FUN->Matricula+str(nCONT,6)))
             if SITUA->Ccusto != cCCUSTO
                loop
             endif

             nMESES ++
             if SITUA->Situacao == "D" .or. SITUA->Situacao == "H" .or. SITUA->Situacao == "A"
                nMESES --
             endif
          endif
      next
      nSAL  := (nSAL / nMEDIA) * nMESES
      nCENT := (nSAL * 100) / nTOTAL

      @ prow()+1,00  say FUN->Matricula
      @ prow()  ,07  say left(FUN->Nome,35)
      @ prow()  ,45  say transform(nSAL,"@E 999,999.99")
      @ prow()  ,60  say transform(nCENT,"@E 99.99") + " %"
      @ prow()  ,69 say transform((nPREMIO*nCENT)/100,"@E 999,999.99")

      nSAL := 0
      nMESES:=0
      nMEDIA:=0
      nCENT :=0
      nCONT :=0
      FUN->(dbskip())
   enddo

   @ prow()+1,0 say  replicate("-",80)
   @ prow()+1,00  say "TOTAL ------------------------------->"
   @ prow()  ,45  say transform(nTOTAL,"@E 999,999.99")
   @ prow()  ,59 say "100,00% "
   @ prow()  ,69 say transform(nPREMIO,"@E 999,999.99")

   qmensa("")
   qstopprn()

return

static function i_tot_salario

do while ! FUN->(eof())

   qmensa(FUN->Matricula+" "+left(FUN->Nome,40))
   if FUN->Data_adm > ctod("30/"+ right(strzero(cPERF,6),2)+"/"+left(strzero(cPERF,6),4))
      FUN->(dbskip())
      loop
   endif

   if SITUA->(dbseek(FUN->Matricula+str(cPERF,6)))

      if SITUA->Categoria == "5"
         nSAL := SITUA->Salario * 220
      else
         nSAL := SITUA->Salario
      endif
   elseif SITUA->(dbseek(FUN->Matricula+str(cPERF-1,6))) //5 11

      if SITUA->Categoria == "5"
         nSAL := SITUA->Salario * 220
      else
         nSAL := SITUA->Salario
      endif
   elseif SITUA->(dbseek(FUN->Matricula+str(cPERF-2,6))) //4 10

      if SITUA->Categoria == "5"
         nSAL := SITUA->Salario * 220
      else
         nSAL := SITUA->Salario
      endif
   elseif SITUA->(dbseek(FUN->Matricula+str(cPERF-3,6))) //3 9
      if SITUA->Categoria == "5"
         nSAL := SITUA->Salario * 220
      else
         nSAL := SITUA->Salario
      endif
   elseif SITUA->(dbseek(FUN->Matricula+str(cPERF-4,6))) //2 8
      if SITUA->Categoria == "5"
         nSAL := SITUA->Salario * 220
      else
         nSAL := SITUA->Salario
      endif

   elseif SITUA->(dbseek(FUN->Matricula+str(cPERI,6)))

      if SITUA->Categoria == "5"
         nSAL := SITUA->Salario * 220
      else
         nSAL := SITUA->Salario
      endif
   else
      FUN->(dbskip())
      loop
   endif

   for nCONT = cPERI to cPERF

       nMEDIA ++
       if subs(str(nCONT,6),5,2) == "13"
          nCONT += 87
          loop
       endif

       if SITUA->(dbseek(FUN->Matricula+str(nCONT,6)))
          if SITUA->Ccusto != cCCUSTO
             loop
          endif
          nMESES ++

          if SITUA->Situacao == "D" .or. SITUA->Situacao == "H" .or. SITUA->Situacao == "A"
             nMESES --
          endif
       endif

   next

   nSAL := (nSAL / nMEDIA) * nMESES
   nTOTAL += nSAL
   nSAL  := 0
   nMEDIA:= 0
   nMESES:= 0
   FUN->(dbskip())
enddo
return
