
// ----------------------------------------------------------------------------
// Funcao para a escolha de um arquivos
//
// Parametro = extensao do arquivo (C). ex: "DBF"
//

Function IQ_ESDBF

parameters C_PEXTENSAO

private M_DRI
private V_DRI := {}
private M_TELA1
private M_CURDIR := curdir()
private M_PATH_COMPLETO := ""

set color to W+/B                   // 31 na screen.lib
M_TELA1 := copac_sl(savev_sl())     // salva tela atual
f_esc_dri()                         // chama funcao de escolha
restv_sl(depac_sl(M_TELA1))         // restaura tela
iq_cd(M_CURDIR)                     // reposiciona no diretorio
return M_PATH_COMPLETO              // retorna string

// ----------------------------------------------------------------------------
// FUNCAO PARA ESCOLHA DO DRIVE 
//

Static Function F_ESC_DRI
   local C_CONTADOR
   local C_ESCOLHA
   local C_CURDIR := curdir()

   for C_CONTADOR := 3 to 26
       if iq_cd(chr(C_CONTADOR+64)+":\")
          aadd(V_DRI,"  "+chr(C_CONTADOR+64)+":"+"  ")
       endif
   next
   iq_cd(C_CURDIR)

   restb_sl("ESDBF1.RRB","GS",06,02,P_DRIVE_PU+"IQ_DIVER.RRG")
   iq_shadow(06,02,14,09,7)
   C_ESCOLHA := achoice(07,03,13,08,V_DRI,.T.,"f_esc_dbf")
return

// ----------------------------------------------------------------------------
// FUNCAO PARA ESCOLHA DO DIRETORIO
//

function f_esc_dbf ( C_MOD , C_ELE , C_POS )

   local C_CONTADOR, C_ESCOLHA, C_PATH_ATUAL, C_TMP
   local V_DIR1 := {}
   local V_DIR2 := {}

   if lastkey() == 27 ; return 0 ; endif
   if lastkey() != 13 ; return 2 ; endif

   M_DRI := alltrim(V_DRI[C_ELE])

   C_PATH_ATUAL := M_DRI+"\"

   V_DIR1 := directory(C_PATH_ATUAL,"D")
   for C_CONTADOR := 1 to len(V_DIR1)
       do case
          case V_DIR1[C_CONTADOR,5] == "D" .and. V_DIR1[C_CONTADOR,1] != "."
               aadd(V_DIR2,lower(V_DIR1[C_CONTADOR,1]))
          case right(V_DIR1[C_CONTADOR,1],3) == C_PEXTENSAO
               aadd(V_DIR2,upper(V_DIR1[C_CONTADOR,1]))
       endcase
   next
   asort(V_DIR2)

   restb_sl("ESDBF2.RRB","GS",06,16,P_DRIVE_PU+"IQ_DIVER.RRG")
   iq_shadow(06,16,14,31,7)
   restb_sl("ESDBF3.RRB","GS",17,02,P_DRIVE_PU+"IQ_DIVER.RRG")
   iq_shadow(17,02,19,62,7)

   do while .T.
      iq_say(18,04,left(C_PATH_ATUAL+space(60),60))
      clear_sl(07,17,13,30,31)
      C_ESCOLHA := achoice(07,18,13,29,V_DIR2,.T.)
      do case
         case lastkey() == 27 .and. len(C_PATH_ATUAL) <= 3
              return 0
         case lastkey() == 13 .and. isupper(V_DIR2[C_ESCOLHA])
              M_PATH_COMPLETO := upper(C_PATH_ATUAL+V_DIR2[C_ESCOLHA])
              return 0
         case lastkey() == 13 .and. islower(V_DIR2[C_ESCOLHA])
              C_PATH_ATUAL += V_DIR2[C_ESCOLHA] + "\"
              V_DIR1 := directory(C_PATH_ATUAL,"D")
              V_DIR2 := {}
              for C_CONTADOR := 1 to len(V_DIR1)
                  do case
                     case V_DIR1[C_CONTADOR,5] == "D" .and. V_DIR1[C_CONTADOR,1] != "."
                          aadd(V_DIR2,lower(V_DIR1[C_CONTADOR,1]))
                     case right(V_DIR1[C_CONTADOR,1],3) == C_PEXTENSAO
                          aadd(V_DIR2,upper(V_DIR1[C_CONTADOR,1]))
                  endcase
              next
              asort(V_DIR2)
         case lastkey() == 27 .and. len(C_PATH_ATUAL) > 3
              if len(C_PATH_ATUAL) != 3
                 C_PATH_ATUAL := substr(C_PATH_ATUAL,1,len(C_PATH_ATUAL)-1)
                 C_TMP := rat("\",C_PATH_ATUAL)
                 C_PATH_ATUAL := substr(C_PATH_ATUAL,1,C_TMP)
              endif
              V_DIR1 := directory(C_PATH_ATUAL,"D")
              V_DIR2 := {}
              for C_CONTADOR := 1 to len(V_DIR1)
                  do case
                     case V_DIR1[C_CONTADOR,5] == "D" .and. V_DIR1[C_CONTADOR,1] != "."
                          aadd(V_DIR2,lower(V_DIR1[C_CONTADOR,1]))
                     case right(V_DIR1[C_CONTADOR,1],3) == C_PEXTENSAO
                          aadd(V_DIR2,upper(V_DIR1[C_CONTADOR,1]))
                  endcase
              next
              asort(V_DIR2)
      endcase
   enddo

return

