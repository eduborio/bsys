
// RETORNA O NOME DO MES_____________________________________________________

function qnomemes ( zPARM )

   do case
      case valtype(zPARM) == "D"
           zPARM := month(zPARM)
      case valtype(zPARM) == "C"
           zPARM := val(zPARM)
      case valtype(zPARM) <> "N"
           zPARM := 0
   endcase

   do case
      case zPARM == 01 ; return "JANEIRO  "
      case zPARM == 02 ; return "FEVEREIRO"
      case zPARM == 03 ; return "MARCO    "
      case zPARM == 04 ; return "ABRIL    "
      case zPARM == 05 ; return "MAIO     "
      case zPARM == 06 ; return "JUNHO    "
      case zPARM == 07 ; return "JULHO    "
      case zPARM == 08 ; return "AGOSTO   "
      case zPARM == 09 ; return "SETEMBRO "
      case zPARM == 10 ; return "OUTUBRO  "
      case zPARM == 11 ; return "NOVEMBRO "
      case zPARM == 12 ; return "DEZEMBRO "
   endcase
return "         "

/*
RETURN(RTRIM(SUBSTR('Janeiro  FevereiroMarco    Abril    Maio     ' + ;
       'Junho    Julho    Agosto   Setembro Outubro  Novembro Dezembro', ;
       MONTH(var1) * 9 - 8, 9)))
*/


// RETORNA O NOME DO DIA DA SEMANA __________________________________________

function qnomesemana ( zPARM , lCOMPLETO )
   if valtype(lCOMPLETO) <> "L"
      lCOMPLETO := .F.
   endif
   if valtype(zPARM) == "D"
      zPARM := dow(zPARM)
   endif
   if valtype(zPARM) == "C"
      zPARM := val(zPARM)
   endif
   if valtype(zPARM) <> "N"
      zPARM := 0
   endif
   if lCOMPLETO
      do case
         case zPARM == 1 ; return "DOMINGO      "
         case zPARM == 2 ; return "SEGUNDA-FEIRA"
         case zPARM == 3 ; return "TERCA-FEIRA  "
         case zPARM == 4 ; return "QUARTA-FEIRA "
         case zPARM == 5 ; return "QUINTA-FEIRA "
         case zPARM == 6 ; return "SEXTA-FEIRA  "
         case zPARM == 7 ; return "SABADO       "
      endcase
   else
      do case
         case zPARM == 1 ; return "DOMINGO"
         case zPARM == 2 ; return "SEGUNDA"
         case zPARM == 3 ; return "TERCA  "
         case zPARM == 4 ; return "QUARTA "
         case zPARM == 5 ; return "QUINTA "
         case zPARM == 6 ; return "SEXTA  "
         case zPARM == 7 ; return "SABADO "
      endcase
   endif
return "         "

// RETORNA O NOME POR EXTENSO DO ESTADO _____________________________________

function qnomeestado ( zPARM )
   if valtype(zPARM) <> "C" ; zPARM := "" ; endif
   do case
      case zPARM == "AC" ; return "ACRE               "
      case zPARM == "AL" ; return "ALAGOAS            "
      case zPARM == "AP" ; return "AMAPA              "
      case zPARM == "AM" ; return "AMAZONAS           "
      case zPARM == "BA" ; return "BAHIA              "
      case zPARM == "CE" ; return "CEARA              "
      case zPARM == "DF" ; return "DISTRITO FEDERAL   "
      case zPARM == "ES" ; return "ESPIRITO SANTO     "
      case zPARM == "FN" ; return "FERNANDO DE NORONHA"
      case zPARM == "GO" ; return "GOIAS              "
      case zPARM == "TO" ; return "TOCANTINS          "
      case zPARM == "MA" ; return "MARANHAO           "
      case zPARM == "MT" ; return "MATO GROSSO        "
      case zPARM == "MS" ; return "MATO GROSSO DO SUL "
      case zPARM == "MG" ; return "MINAS GERAIS       "
      case zPARM == "PA" ; return "PARA               "
      case zPARM == "PB" ; return "PARAIBA            "
      case zPARM == "PR" ; return "PARANA             "
      case zPARM == "PE" ; return "PERNANBUCO         "
      case zPARM == "PI" ; return "PIAUI              "
      case zPARM == "RN" ; return "RIO GRANDE DO NORTE"
      case zPARM == "RS" ; return "RIO GRANDE DO SUL  "
      case zPARM == "RJ" ; return "RIO DE JANEIRO     "
      case zPARM == "RO" ; return "RONDONIA           "
      case zPARM == "RR" ; return "RORAIMA            "
      case zPARM == "SC" ; return "SANTA CATARINA     "
      case zPARM == "SP" ; return "SAO PAULO          "
      case zPARM == "SE" ; return "SERGIPE            "
   endcase
return space(19)

