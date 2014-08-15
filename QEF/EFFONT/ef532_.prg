
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: DENUNCIA ESPONTANEA REFERENTE A FALTA DE LANCAMENTO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1996
// OBS........:
// ALTERACOES.:
function ef532

// POSICIONA NO MUNICIPIO E ESTADO DA EMPRESA ______________________________

CGM->(dbseek(XCGM))

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }
private aEDICAO := {}             // Vetor para os campos de entrada de dados

private cPIC1   := "@E 999,999,999.99"

private dDATA_1                   // Data da nota 1
private cNOTA_1                   // Numero da nota 1
private cSERIE_1                  // Serie da nota 1
private nV_CONT_1                 // Valor contabil da nota 1
private nB_CALC_1                 // Base de calculo da nota 1
private nICMS_1                   // ICMS da nota 1

private dDATA_2                   // Data da nota 2
private cNOTA_2                   // Numero da nota 2
private cSERIE_2                  // Serie da nota 2
private nV_CONT_2                 // Valor contabil da nota 2
private nB_CALC_2                 // Base de calculo da nota 2
private nICMS_2                   // ICMS da nota 2

private dDATA_3                   // Data da nota 3
private cNOTA_3                   // Numero da nota 3
private cSERIE_3                  // Serie da nota 3
private nV_CONT_3                 // Valor contabil da nota 3
private nB_CALC_3                 // Base de calculo da nota 3
private nICMS_3                   // ICMS da nota 3

private dDATA_4                   // Data da nota 4
private cNOTA_4                   // Numero da nota 4
private cSERIE_4                  // Serie da nota 4
private nV_CONT_4                 // Valor contabil da nota 4
private nB_CALC_4                 // Base de calculo da nota 4
private nICMS_4                   // ICMS da nota 4

private dDATA_5                   // Data da nota 5
private cNOTA_5                   // Numero da nota 5
private cSERIE_5                  // Serie da nota 5
private nV_CONT_5                 // Valor contabil da nota 5
private nB_CALC_5                 // Base de calculo da nota 5
private nICMS_5                   // ICMS da nota 5

private dDATA_REL                 // Data do relatorio

private nTOT_V_CONT               // Total do valor contabil
private nTOT_B_CALC               // Total de base de calculo
private nTOT_ICMS                 // Total de ICMS

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

   qlbloc(5,0,"B532A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_1   ,"@D"          ) } ,"DATA_1  " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNOTA_1   ,"@!"          ) } ,"NOTA_1  " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cSERIE_1  ,"@!"          ) } ,"SERIE_1 " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nV_CONT_1 ,cPIC1         ) } ,"V_CONT_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nB_CALC_1 ,cPIC1         ) } ,"B_CALC_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMS_1   ,cPIC1         ) } ,"ICMS_1  " })

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_2   ,"@d"          ) } ,"DATA_2   " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNOTA_2   ,"@!"          ) } ,"NOTA_2   " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cSERIE_2  ,"@!"          ) } ,"SERIE_2  " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nV_CONT_2 ,cPIC1         ) } ,"V_CONT_2 " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nB_CALC_2 ,cPIC1         ) } ,"B_CALC_2 " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMS_2   ,cPIC1         ) } ,"ICMS_2   " })

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_3   ,"@d"          ) } ,"DATA_3   " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNOTA_3   ,"@!"          ) } ,"NOTA_3   " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cSERIE_3  ,"@!"          ) } ,"SERIE_3  " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nV_CONT_3 ,cPIC1         ) } ,"V_CONT_3 " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nB_CALC_3 ,cPIC1         ) } ,"B_CALC_3 " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMS_3   ,cPIC1         ) } ,"ICMS_3   " })

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_4   ,"@d"          ) } ,"DATA_4  " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNOTA_4   ,"@!"          ) } ,"NOTA_4  " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cSERIE_4  ,"@!"          ) } ,"SERIE_4 " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nV_CONT_4 ,cPIC1         ) } ,"V_CONT_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nB_CALC_4 ,cPIC1         ) } ,"B_CALC_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMS_4   ,cPIC1         ) } ,"ICMS_41 " })

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_5   ,"@d"          ) } ,"DATA_5  " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNOTA_5   ,"@!"          ) } ,"NOTA_5  " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cSERIE_5  ,"@!"          ) } ,"SERIE_5 " })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nV_CONT_5 ,cPIC1         ) } ,"V_CONT_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nB_CALC_5 ,cPIC1         ) } ,"B_CALC_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMS_5   ,cPIC1         ) } ,"ICMS_5  " })

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_REL ,"@!" ,NIL,NIL ) } ,"DATA_REL" })

do while .T.

   XNIVEL      := 1
   XFLAG       := .T.

   dDATA_1     := ctod("")         // Data da nota 1
   cNOTA_1     := space(8)         // Numero da nota 1
   cSERIE_1    := space(8)         // Serie da nota 1
   nV_CONT_1   := 0                // Valor contabil da nota 1
   nB_CALC_1   := 0                // Base de calculo da nota 1
   nICMS_1     := 0                // ICMS da nota 1

   dDATA_2     := ctod("")         // Data da nota 2
   cNOTA_2     := space(8)         // Numero da nota 2
   cSERIE_2    := space(8)         // Serie da nota 2
   nV_CONT_2   := 0                // Valor contabil da nota 2
   nB_CALC_2   := 0                // Base de calculo da nota 2
   nICMS_2     := 0                // ICMS da nota 2

   dDATA_3     := ctod("")         // Data da nota 3
   cNOTA_3     := space(8)         // Numero da nota 3
   cSERIE_3    := space(8)         // Serie da nota 3
   nV_CONT_3   := 0                // Valor contabil da nota 3
   nB_CALC_3   := 0                // Base de calculo da nota 3
   nICMS_3     := 0                // ICMS da nota 3

   dDATA_4     := ctod("")         // Data da nota 4
   cNOTA_4     := space(8)         // Numero da nota 4
   cSERIE_4    := space(8)         // Serie da nota 4
   nV_CONT_4   := 0                // Valor contabil da nota 4
   nB_CALC_4   := 0                // Base de calculo da nota 4
   nICMS_4     := 0                // ICMS da nota 4

   dDATA_5     := ctod("")         // Data da nota 5
   cNOTA_5     := space(8)         // Numero da nota 5
   cSERIE_5    := space(8)         // Serie da nota 5
   nV_CONT_5   := 0                // Valor contabil da nota 5
   nB_CALC_5   := 0                // Base de calculo da nota 5
   nICMS_5     := 0                // ICMS da nota 5

   nTOT_V_CONT := 0                // Total do valor contabil
   nTOT_B_CALC := 0                // Total de base de calculo
   nTOT_ICMS   := 0                // Total de ICMS

   dDATA_REL   := date()           // Data do relatorio

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_impressao()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "DATA_REL"
           if empty(dDATA_REL); return .F.; endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   set marg to 10

   for nCONT = 1 TO 2

       nTOT_V_CONT := nV_CONT_1 + nV_CONT_2 + nV_CONT_3 + nV_CONT_4 + nV_CONT_5
       nTOT_B_CALC := nB_CALC_1 + nB_CALC_2 + nB_CALC_3 + nB_CALC_4 + nB_CALC_5
       nTOT_ICMS   := nICMS_1 + nICMS_2 + nICMS_3 + nICMS_4 + nICMS_5

       @ prow(),pcol() say XCOND0
       @ prow()+4,05 Say XAENFAT + "PARA A" + XDENFAT
       @ prow()+1,05 Say XAENFAT + "CHEFE DA AGENCIA DE RENDAS - CENTRO" + XDENFAT
       @ prow()+1,05 Say XAENFAT + "1o. DRR"
       @ prow()+4,10 Say XAENFAT + padr(alltrim(XRAZAO),50,"*") + "*********" + "," + XDENFAT
       @ prow()+2,05 Say "pessoa juridica de direito  privado,  com sede  em  Curitiba - PR"
       @ prow()+2,05 Say "inscrita no " + XAENFAT + padr(alltrim(XINSCR_EST),14,"*") + XDENFAT + ", vem respeitosamente apresentar denun-"
       @ prow()+2,05 Say "cia espontanea referente a falta de lancamento no " + XAENFAT + "LIVRO  REGISTRO"
       @ prow()+2,05 Say "DE SAIDAS DE MERCADORIAS." + XDENFAT + " Segue abaixo relacao das notas com seus"
       @ prow()+2,05 Say "respectivos valores, data de emissao e ICMS."
       @ prow()+3,05 Say XAENFAT + "DATA   No. N.F.   SERIE   VAL. CONTABIL    BASE CALCULO   ICMS" + XDENFAT
       @ prow(),pcol() say XCOND1

       if nV_CONT_1 <> 0
          @ prow()+2,15 Say dtoc(dDATA_1) + space(7) + cNOTA_1 + space(9) + cSERIE_1 + space(09) +;
                            transform(nV_CONT_1,cPIC1) + space(12) + transform(nB_CALC_1,cPIC1)  +;
                            space(5) + transform(nICMS_1,cPIC1)
       endif

       if nV_CONT_2 <> 0
          @ prow()+2,15 Say dtoc(dDATA_2) + space(7) + cNOTA_2 + space(9) + cSERIE_2 + space(09) +;
                            transform(nV_CONT_2,cPIC1) + space(12) + transform(nB_CALC_2,cPIC1)  +;
                            space(5) + transform(nICMS_2,cPIC1)
       endif

       if nV_CONT_3 <> 0
          @ prow()+2,15 Say dtoc(dDATA_3) + space(7) + cNOTA_3 + space(9) + cSERIE_3 + space(09) +;
                            transform(nV_CONT_3,cPIC1) + space(12) + transform(nB_CALC_3,cPIC1)  +;
                            space(5) + transform(nICMS_3,cPIC1)
       endif

       if nV_CONT_4 <> 0
          @ prow()+2,15 Say dtoc(dDATA_4) + space(7) + cNOTA_4 + space(9) + cSERIE_4 + space(09) +;
                            transform(nV_CONT_4,cPIC1) + space(12) + transform(nB_CALC_4,cPIC1)  +;
                            space(5) + transform(nICMS_4,cPIC1)
       endif

       if nV_CONT_5 <> 0
          @ prow()+2,15 Say dtoc(dDATA_5) + space(7) + cNOTA_5 + space(9) + cSERIE_5 + space(09) +;
                            transform(nV_CONT_5,cPIC1) + space(12) + transform(nB_CALC_5,cPIC1)  +;
                            space(5) + transform(nICMS_5,cPIC1)
       endif

       @ prow()+3,15 Say XCOND0 + XAENFAT + "TOTAL"  + XDENFAT + XCOND1 + space(41) +;
                         transform(nTOT_V_CONT,cPIC1) + space(12) + transform(nTOT_B_CALC,cPIC1) +;
                         space(5) + transform(nTOT_ICMS,cPIC1)

       @ prow(),pcol() say XCOND0

       @ prow()+5,11 Say "Curitiba, " + str(day(dDATA_REL),2) + " de " + alltrim(qnomemes(dDATA_REL)) +;
                         " de " + str(year(dDATA_REL),4) + "."

       @ prow()+4,11 Say Replicate("_",55)

       i_carimbo()

   next

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O CARIMBO DE CGC E INSC. EST. _______________________

static function i_carimbo

   @ prow(),pcol() say XCOND1
   @ prow()+03,027 say "+-" + space(41) + "-+"
   @ prow()   ,076 say "+-" + space(41) + "-+"
   @ prow()+01,027 say "|"
   @ prow()   ,035 say XAEXPAN + XINSCR_EST + XDEXPAN
   @ prow()   ,063 say "|"
   @ prow()   ,068 say "|"
   @ prow()   ,073 say XAEXPAN + XCGCCPF + XDEXPAN
   @ prow()   ,100 say "|"
   @ prow()+02,029 say Substr(XRAZAO,1,38)
   @ prow()   ,078 say Substr(XRAZAO,1,38)
   @ prow()+01,029 say Substr(XRAZAO,39,50)
   @ prow()   ,078 say Substr(XRAZAO,39,50)
   @ prow()+01,029 say XENDERECO
   @ prow()   ,078 say XENDERECO
   @ prow()+01,029 say XCEP + " - " + Alltrim(CGM->MUNICIPIO) + " - " + alltrim(CGM->ESTADO)
   @ prow()   ,078 say XCEP + " - " + Alltrim(CGM->MUNICIPIO) + " - " + alltrim(CGM->ESTADO)
   @ prow()+01,027 say "|"  + space(43) + "|"
   @ prow()   ,076 say "|"  + space(43) + "|"
   @ prow()+01,027 say "+-" + space(41) + "-+"
   @ prow()   ,076 say "+-" + space(41) + "-+"
   @ prow()+08,000 say ""

return
