/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELATORIO DA RAIS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: FEVEREIRO DE 1996
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private cTITULO       // titulo do relatorio

// ABRE ARQUIVO RAIS.DBF ____________________________________________________

if ! quse(XDRV_RHX,"RAIS",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo RAIS.DBF !! Tente novamente.")
   return
endif

RAIS->(dbskip())

qlbloc(5,0,"B581A","QBLOC.GLO")

qmensa("Imprimindo RAIS de " + subs(RAIS->Linha,250,4))

if (i_inicializacao() , i_impressao() , NIL)

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // ESTABELECE TITULO PARA RELATORIO ______________________________________

   cTITULO := "RELACAO ANUAL DE INFORMACOES SOCIAIS - RAIS/ANO BASE: "
   cTITULO += subs(RAIS->Linha,250,4)

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow()+1,000 say XCOND1

   do while subs(RAIS->Linha,23,1) != "9" .and. qcontprn()

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN .or. subs(RAIS->Linha,23,1) == "1"
         qpageprn()
         qcabecprn(cTITULO,220)
         if subs(RAIS->Linha,23,1) == "1"
            @ prow()+2,000 say XAEXPAN + padc("DADOS DA EMPRESA",100) + XDEXPAN
            @ prow()+2,007 say "EMPRESA: "            + subs(RAIS->Linha,24,52)
            @ prow()  ,072 say "CGC/CEI: "            + transform(subs(RAIS->Linha,7,14),iif(subs(RAIS->Linha,207,1) == "1","@R 99.999.999/9999-99","@R 99999999999999"))
            @ prow()  ,103 say "ENDERECO: "           + subs(RAIS->Linha,76,40)
            @ prow()  ,169 say "BAIRRO: "             + subs(RAIS->Linha,143,19)
            @ prow()  ,199 say "CEP: "                + transform(subs(RAIS->Linha,162,8),"@R 99999-999")
            @ prow()+1,007 say "MUNICIPIO: "          + subs(RAIS->Linha,177,31)
            @ prow()  ,052 say "U.F.: "               + subs(RAIS->Linha,207,2)
            @ prow()  ,064 say "CNAE: "               + transform(subs(RAIS->Linha,209,5),"@R 9999-9")
            @ prow()  ,081 say "NATUREZA JURIDICA: "  + transform(subs(RAIS->Linha,214,4),"@R 999-9")
            @ prow()  ,109 say "PROPRIETARIOS: "      + subs(RAIS->Linha,218,2)
            @ prow()  ,131 say "DATA BASE: "          + subs(RAIS->Linha,220,2)
            @ prow()  ,152 say "TIPO DE RAIS: "       + iif(subs(RAIS->Linha,223,1) == "0","NORMAL","NEGATIVA")
            @ prow()  ,180 say "ALTEROU ENDERECO NO ANO BASE: " + iif(subs(RAIS->Linha,224,1) == "0","NAO","SIM")
            @ prow()+2,000 say XAEXPAN + padc("DADOS DOS FUNCIONARIOS",100) + XDEXPAN
         endif

//       if subs(RAIS->Linha,208,1) == "0"
//          @ prow()+1,000 say ""
//          if subs(RAIS->Linha,23,1) == "1"
//             RAIS->(dbskip())
//          endif
//       endif
      endif

//    if subs(RAIS->Linha,208,1) != "0"
//       setprc(100,0)
//       RAIS->(dbskip())
//       loop
//    endif

      if subs(RAIS->Linha,23,1) == "2"

         @ prow()+1,000 say "NOME: "              + subs(RAIS->Linha,35,30)
         @ prow()  ,040 say "PIS/PASEP: "         + subs(RAIS->Linha,24,11)
         @ prow()  ,066 say "NASC.: "             + subs(RAIS->Linha,65,2) + "/" + subs(RAIS->Linha,67,2) + "/" + subs(RAIS->Linha,69,4)
         @ prow()  ,085 say "CPF.: "              + transform(subs(RAIS->Linha,80,11),"@R 999.999.999/99")
         @ prow()  ,110 say "ADMISSAO: "          + subs(RAIS->Linha,102,2) + "/" + subs(RAIS->Linha,104,2) + "/" + subs(RAIS->Linha,106,4)
         @ prow()  ,132 say "SAL. CONT.: "        + transform(val(subs(RAIS->Linha,111,7) + "." + subs(RAIS->Linha,118,2)),"@E 9,999,999.99")
         @ prow()  ,160 say "HRS. SEM.: "         + subs(RAIS->Linha,121,2)
         @ prow()  ,178 say "COD. DESL.: "        + subs(RAIS->Linha,130,2)
         @ prow()  ,196 say "DIA/MES DESL.: "     + subs(RAIS->Linha,132,2) + "/" + subs(RAIS->Linha,134,2)
         @ prow()+1,000 say "JAN: "               + transform(val(subs(RAIS->Linha,136,7) + "." + subs(RAIS->Linha,143,2)),"@E 9,999,999.99")
         @ prow()  ,019 say "FEV: "               + transform(val(subs(RAIS->Linha,145,7) + "." + subs(RAIS->Linha,152,2)),"@E 9,999,999.99")
         @ prow()  ,038 say "MAR: "               + transform(val(subs(RAIS->Linha,154,7) + "." + subs(RAIS->Linha,161,2)),"@E 9,999,999.99")
         @ prow()  ,056 say "ABR: "               + transform(val(subs(RAIS->Linha,163,7) + "." + subs(RAIS->Linha,170,2)),"@E 9,999,999.99")
         @ prow()  ,074 say "MAI: "               + transform(val(subs(RAIS->Linha,172,7) + "." + subs(RAIS->Linha,179,2)),"@E 9,999,999.99")
         @ prow()  ,092 say "JUN: "               + transform(val(subs(RAIS->Linha,181,7) + "." + subs(RAIS->Linha,188,2)),"@E 9,999,999.99")
         @ prow()  ,110 say "JUL: "               + transform(val(subs(RAIS->Linha,190,7) + "." + subs(RAIS->Linha,197,2)),"@E 9,999,999.99")
         @ prow()  ,128 say "AGO: "               + transform(val(subs(RAIS->Linha,199,7) + "." + subs(RAIS->Linha,206,2)),"@E 9,999,999.99")
         @ prow()  ,147 say "SET: "               + transform(val(subs(RAIS->Linha,208,7) + "." + subs(RAIS->Linha,215,2)),"@E 9,999,999.99")
         @ prow()  ,165 say "OUT: "               + transform(val(subs(RAIS->Linha,217,7) + "." + subs(RAIS->Linha,224,2)),"@E 9,999,999.99")
         @ prow()  ,183 say "NOV: "               + transform(val(subs(RAIS->Linha,226,7) + "." + subs(RAIS->Linha,233,2)),"@E 9,999,999.99")
         @ prow()  ,203 say "DEZ: "               + transform(val(subs(RAIS->Linha,235,7) + "." + subs(RAIS->Linha,242,2)),"@E 9,999,999.99")
         @ prow()+1,050 say "ADT. 13. SALARIO: "  + transform(val(subs(RAIS->Linha,244,7) + "." + subs(RAIS->Linha,251,2)),"@E 9,999,999.99")
         @ prow()  ,090 say "MES ADT. 13.: "      + subs(RAIS->Linha,253,2)
         @ prow()  ,120 say "13. SALARIO FINAL: " + transform(val(subs(RAIS->Linha,255,7) + "." + subs(RAIS->Linha,262,2)),"@E 9,999,999.99")
         @ prow()  ,160 say "MES 13. FINAL: "     + subs(RAIS->Linha,264,2)
         @ prow()+1,000 say ""

      endif

      RAIS->(dbskip())

   enddo

   qstopprn()

return
