function iq_debug
local   C_TYPE, C_TELA, C_PONTO, GETLIST := {}
private M_VAR, M_RESULT, M_LEN

C_TELA := copac_sl(savev_sl())

clear_sl(00,00,03,79)
saysc_sl(00,00,replicate("Ä",80),7)
saysc_sl(03,00,replicate("Ä",80),7)

do while .T.

   M_VAR   := space(77)
   C_PONTO := .F.

   @ 01,02 get M_VAR
   read

   if lastkey() == 27
      restv_sl(depac_sl(C_TELA))
      return
   endif

   clear_sl(00,00,03,79)
   saysc_sl(00,00,replicate("Ä",80),7)
   saysc_sl(03,00,replicate("Ä",80),7)

   if M_VAR = "."
      C_PONTO := .T.
      M_VAR   := substr(M_VAR,2)
   endif

   M_LEN := ""
   C_TYPE := type("&M_VAR.")

   if "U" $ C_TYPE .and. !C_PONTO
      saysc_sl(02,02,"variavel n„o definida !",7)
      loop
   else
      M_RESULT := &M_VAR.
   endif

   do case
      case C_TYPE == "C"
           M_LEN := alltrim(str(len(M_RESULT)))
      case C_TYPE == "N"
           M_RESULT := str(M_RESULT)
      case C_TYPE == "D"
           M_RESULT := dtoc(M_RESULT)
      case C_TYPE == "L"
           M_RESULT := iif(M_RESULT,".T.",".F.")
      case C_TYPE == "A"
           M_RESULT := "{...}"
   endcase

   saysc_sl(02,02,C_TYPE+"/"+M_LEN+"/"+M_RESULT,7)

enddo


