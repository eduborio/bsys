
function ctrl_admin
   local sMENU := qlbloc("PW_MENU",XDRV_SH+"QSBLOC.GLO")
   local cOPCAO := "M"

   do while .T.
      qmensa("Menu de Controle do Administrador !")
      if empty(cOPCAO := qachoice(04,54,sMENU,cOPCAO)) ; exit ; endif
      do case
         case cOPCAO == "M" ; qad_manu()       /// manutencao de usuarios
         case cOPCAO == "P" ; qad_perm()       /// permissoes de acesso
         case cOPCAO == "H" ; qad_hist()       /// historico de atividade
         case cOPCAO == "E" ; qad_esta()       /// estatistica de acesso
         case cOPCAO == "L" ; qad_limp()       /// limpesa do historico
         case cOPCAO == "A" ; qad_senh()       /// altera senha do admin
         case cOPCAO == "C" ; qad_conf()       /// configuracao tecnica
      endcase
   enddo

return .T.

