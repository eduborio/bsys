
// CONTROLES DO ADMIN
// LIMPESA DO HISTORICO
function qad_limp


local sBLOC := qsbloc(11,39,17,79)
if ! quse("","QLOGIN",{"QLOGIN1","QLOGIN2","QLOGIN3"}) ; return .F. ; endif
qad_limp2()
QLOGIN->(dbclosearea())
qrbloc(11,39,sBLOC)
return

static function qad_limp2
   local dINICIO, dFINAL

   QLOGIN->(dbseek(XEMPRESA)) ; dINICIO := QLOGIN->Datalog
   QLOGIN->(qseekn(XEMPRESA)) ; dFINAL  := QLOGIN->Datalog

   qlbloc(11,39,"PW_LIMPE",XDRV_SH+"QSBLOC.GLO")

   qgetx(16,50,@dINICIO)
   if lastkey() == 27 ; return .F. ; endif

   qgetx(16,63,@dFINAL)
   if lastkey() == 27 ; return .F. ; endif

   if qconf("Confirma exclus„o desta faixa de registros ?")

      qmensa("Aguarde, realizando exclus„o...")

      QLOGIN->(dbseek(XEMPRESA+dtos(dINICIO)),.T.)

      do while ! QLOGIN->(eof()) .and. QLOGIN->Datalog <= dFINAL .and. QLOGIN->Empresa == XEMPRESA
         qgirabarra()
         if QLOGIN->(qrlock())
            QLOGIN->(dbdelete())
            QLOGIN->(qunlock())
         endif
         QLOGIN->(dbskip())
      enddo

   endif

return .T.


