/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: RELATORIO DE COMPOSICAO DE HORAS EXTRAS
// OBJETIVO...: FICHA FINANCEIRA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO DE 2000
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. lastkey()==27)}

private sBLOCO1 := qlbloc("B508A","QBLOC.GLO") // bloco basico

private cTITULO                // titulo do relatorio
private cMATRICULA             // matricula p/ impressao individual
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cPERI                  // periodo inicial
private cPERF                  // periodo final


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cPERI,"@R 99/9999") }   , "PERI"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPERF,"@R 99/9999") }   , "PERF"      })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario

do while .T.

   qlbloc(5,0,"B508A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   cPERI      := space(6)
   cPERF      := space(6)

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
         case cCAMPO == "MATRICULA"
              if empty(cMATRICULA); return .F.; endif
              if ! empty(cMATRICULA)
                 if ! FUN->(dbseek(strzero(val(cMATRICULA),6)))
                   qmensa("Funcionario NÆo Cadastrado!!!","B")
                   return .F.
                 endif
                 qrsay(XNIVEL,cMATRICULA:=strzero(val(cMATRICULA),6))
              endif
      endcase
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________


//   cTITULO = "RELATORIO DE COMPOSICAO P/ MEDIA DE HORAS EXTRAS"



   // SELECIONA ORDEM DO ARQUIVO FUN _____________________________________


   qmensa()

   FUN->(dbsetorder(1))


   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select LANC
   set relation to Evento into EVENT



   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nCONT := 0
   local mCONT := -1
   local nTOTAL:= 0
   local cCOND
   local cANOMES := strzero(year(XDATASYS),4) + strzero(month(XDATASYS),2)

   local nTOT50 := nTOT55 := nTOT60 := nTOT65 := nTOT70 := nTOT75 := nTOT80 := nTOT85 := nTOT100 := nTOT125 := nTOT130 := nTOT150 := nTOT200 := 0
   local nTOT875:= nTOTINT50 := nTOTINT100 := nTOTINT875 := nTOTADNOT := nTOTANUENIO := nTOTDSR := 0
      // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),0    say XCOND0
   @ prow(),01 say qcabecprn("RELATORIO DE COMPOSICAO P/MEDIA DE HORAS EXTRAS",79)

   if ! empty(cMATRICULA)
      FUN->(dbseek(cMATRICULA))
   endif
   LANC->(dbsetorder(3))
   LANC->(dbgotop())
   cPERI := val(subs(cPERI,3,4) + subs(cPERI,1,2))
   cPERF := val(subs(cPERF,3,4) + subs(cPERF,1,2))

   @ prow()+1,0 say XCOND1+"Matricula..:" + FUN->Matricula + "  Nome..: " + left(FUN->Nome,30)
   @ prow()+1,0 say replicate("-",136)

   @ prow()+1,10 say "H.E 50%" + "   H.E 80%" + "  H.E 87,5" + "  H.E 100%" + "   I.J 50%" + "   IJ 87,5" +"   IJ 100%" + "   Ad.Not " + "  Anuenio " + "  D.S.R   " + "  H.E 130%" + "  H.E 150%" + "  H.E 200%"
   @ prow()+1,0 say replicate("-",136)

      for nCONT = cPERI to cPERF

          mCONT ++
          if subs(str(nCONT,6),5,2) == "13"
             nCONT += 87
             loop
          endif
          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "311"))
          @ prow() +1,0 say subs(str(nCONT,6),5,2)+"/"+subs(str(nCONT,6),1,4) + space(2) + transform(LANC->Fracao,"@E 999.9999")
          nTOT50 += LANC->Fracao

          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "318"))
          @ prow()   ,19 say  transform(LANC->Fracao,"@E 999.9999")
          nTOT80 += LANC->Fracao

          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "313"))
          @ prow()   ,29 say  transform(LANC->Fracao,"@E 999.9999")
          nTOT100 += LANC->Fracao

          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "335"))
          @ prow()   ,39 say  transform(LANC->Fracao,"@E 999.9999")
          nTOT875 += LANC->Fracao

          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "338"))
          @ prow()   ,49 say  transform(LANC->Fracao,"@E 999.9999")
          nTOTINT50 += LANC->Fracao

          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "336"))
          @ prow()   ,59 say  transform(LANC->Fracao,"@E 999.9999")
          nTOTINT875 += LANC->Fracao

          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "337"))
          @ prow()   ,69 say  transform(LANC->Fracao,"@E 999.9999")
          nTOTINT100 += LANC->Fracao

          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "412"))
          @ prow()   ,79 say  transform(LANC->Fracao,"@E 999.9999")
          nTOTADNOT += LANC->Fracao

          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "208"))
          @ prow()   ,89 say  transform(LANC->Valor,"@E 999.9999")
          nTOTANUENIO += LANC->Valor

          LANC->(dbseek(cMATRICULA  + str(nCONT,6) + "187"))
          @ prow()   ,99 say  transform(LANC->Valor,"@E 999.9999")
          nTOTDSR += LANC->Valor



          if ! qlineprn() ; return ; endif

      next
   
   @ prow()+1, 0 say replicate("-",136)
   @ prow()+1, 0 say "Total..: " + Transform(nTOT50,"@E 999.9999")
   @ prow()  , 19 say  Transform(nTOT80,"@E 999.9999")
   @ prow()  , 29 say  Transform(nTOT875,"@E 999.9999")
   @ prow()  , 39 say  Transform(nTOT100,"@E 999.9999")
   @ prow()  , 49 say  Transform(nTOTINT50,"@E 999.9999")
   @ prow()  , 59 say  Transform(nTOTINT875,"@E 999.9999")
   @ prow()  , 69 say  Transform(nTOTINT100,"@E 999.9999")
   @ prow()  , 79 say  Transform(nTOTADNOT,"@E 9999.9999")
   @ prow()  , 89 say  Transform(nTOTANUENIO,"@E 999.9999")
   @ prow()  , 99 say  Transform(nTOTDSR,"@E 999.9999")
   @ prow()  ,109 say  Transform(nTOT130,"@E 999.9999")
   @ prow()  ,119 say  Transform(nTOT150,"@E 999.9999")
   @ prow()  ,129 say  Transform(nTOT200,"@E 999.9999")

   @ prow()+1, 0 say replicate("-",136)
   @ prow()+1, 0 say "Media..: " + Transform(nTOT50/mCONT,"@E 999.9999")
   @ prow()  , 19 say  Transform( nTOT80/mCONT,"@E 999.9999")
   @ prow()  , 29 say  Transform( nTOT875/mCONT,"@E 999.9999")
   @ prow()  , 39 say  Transform( nTOT100/mCONT,"@E 999.9999")
   @ prow()  , 49 say  Transform( nTOTINT50/mCONT,"@E 999.9999")
   @ prow()  , 59 say  Transform( nTOTINT875/mCONT,"@E 999.9999")
   @ prow()  , 69 say  Transform( nTOTINT100/mCONT,"@E 999.9999")
   @ prow()  , 79 say  Transform( nTOTADNOT/mCONT,"@E 999.9999")
   @ prow()  , 89 say  Transform(nTOTANUENIO/mCONT,"@E 999.9999")
   @ prow()  , 99 say  Transform(nTOTDSR/mCONT,"@E 999.9999")
   @ prow()  ,109 say  Transform(nTOT130/mCONT,"@E 999.9999")
   @ prow()  ,119 say  Transform(nTOT150/mCONT,"@E 999.9999")
   @ prow()  ,129 say  Transform(nTOT200/mCONT,"@E 999.9999")

   SITUA->(dbsetorder(4))
   SITUA->(Dbseek(cMatricula + strzero(year(XDATASYS),4) + strzero(month(XDATASYS),2)))
   @ prow()+1, 0 say replicate("-",136)
   @ prow()+1, 0 say "Valor..: " + Transform(nTOT50 := ((SITUA->Salario/220)*(nTOT50/mCONT))*1.5,"@E 9,999.99")
   @ prow()  , 19 say  Transform(nTOT80      := (SITUA->Salario/220)*(nTOT80/mCONT)*1.80,"@E 9,999.99")
   @ prow()  , 29 say  Transform(nTOT875     := (SITUA->Salario/220)*(nTOT875/mCONT)*1.875,"@E 9,999.99")
   @ prow()  , 39 say  Transform(nTOT100     := (SITUA->Salario/220)*(nTOT100/mCONT)*2,"@E 9,999.99")
   @ prow()  , 49 say  Transform(nTOTINT50   := (SITUA->Salario/220)*(nTOTINT50/mCONT)*1.5,"@E 9,999.99")
   @ prow()  , 59 say  Transform(nTOTINT875  := (SITUA->Salario/220)*(nTOTINT875/mCONT)*1.875,"@E 9,999.99")
   @ prow()  , 69 say  Transform(nTOTINT100  := (SITUA->Salario/220)*(nTOTINT100/mCONT)*2,"@E 9,999.99")
   @ prow()  , 79 say  Transform(nTOTADNOT   := ((SITUA->Salario/220) * 0.30)*(nTOTADNOT/mCONT),"@E 9,999.99")
   @ prow()  , 89 say  Transform(nTOTANUENIO :=(nTOTANUENIO/mCONT),"@E 9,999.99")
   @ prow()  , 99 say  Transform(nTOTDSR     := (nTOTDSR/mCONT),"@E 9,999.99")
   @ prow()  ,109 say  Transform((SITUA->Salario/220)*(nTOT130/mCONT)*2.3,"@E 9,999.99")
   @ prow()  ,119 say  Transform((SITUA->Salario/220)*(nTOT150/mCONT)*2.5,"@E 9,999.99")
   @ prow()  ,129 say  Transform((SITUA->Salario/220)*(nTOT200/mCONT)*3,"@E 9,999.99")

   @ prow()+2,0 say "SALARIO HORA .................:              " + iif(SITUA->Categoria <> "5",transform(SITUA->Salario/220,"@E 9,999.99"),transform(SITUA->Salario,"@E 9,999.99"))
   @ prow()+1,0 say "Composicao da Base de Calculo.: "

   @ prow()+2,0 say "SALARIO BASE " + space(32) + iif(SITUA->Categoria <> "5",transform(SITUA->Salario,"@E 9,999.99"),transform(SITUA->Salario*220,"@E 9,999.99"))
   nTOTAL += iif(SITUA->Categoria != "5",SITUA->Salario,SITUA->Salario*220)

   LANC->(dbsetorder(3))
   LANC->(dbgotop())

   if  nTOT50 > 0
     nTOTAL += nTOT50
     @ prow()+1,0 say "Media de Horas Extras 50%   " + space(5) + transform(nTOT50,"@E 9,999.99")
   endif

   if  nTOT80 > 0
     nTOTAL += nTOT80
     @ prow()+1,0 say "Media de Horas Extras 80%   " + space(5) + transform(nTOT80,"@E 9,999.99")
   endif

   if  nTOT875 > 0
     nTOTAL += nTOT875
     @ prow()+1,0 say "Media de Horas Extras 87.5% " + space(5) + transform(nTOT875,"@E 9,999.99")
   endif

   if  nTOT100 > 0
     nTOTAL += nTOT100
     @ prow()+1,0 say "Media de Horas Extras 100%  " + space(5) + transform(nTOT100,"@E 9,999.99")
   endif

   if  nTOTINT50 > 0
     nTOTAL += nTOTINT50
     @ prow()+1,0 say "Media de Intra-Jornada 50%  " + space(5) + transform(nTOTINT50,"@E 9,999.99")
   endif

   if  nTOTINT875 > 0
     nTOTAL += nTOTINT875
     @ prow()+1,0 say "Media de Intra-Jornada 87.5% " + space(5) + transform(nTOTINT875,"@E 9,999.99")
   endif

   if  nTOTINT100 > 0
     nTOTAL += nTOTINT100
     @ prow()+1,0 say "Media de Intra-Jornada 100%  " + space(5) + transform(nTOTINT100,"@E 9,999.99")
   endif

   if  nTOTADNOT > 0
     nTOTAL += nTOTADNOT
     @ prow()+1,0 say "Media de Adicional Noturno   " + space(5) + transform(nTOTADNOT,"@E 9,999.99")
   endif

   if  nTOTANUENIO > 0
     nTOTAL += nTOTANUENIO
     @ prow()+1,0 say "Media de Anuenio             " + space(5) + transform(nTOTANUENIO,"@E 9,999.99")
   endif


   @ prow()+2,0 say "Total da Base de Calculo......:  " +space(12)+ transform(nTOTAL,"@E 9,999.99")
   eject
   qstopprn(.F.)

return

