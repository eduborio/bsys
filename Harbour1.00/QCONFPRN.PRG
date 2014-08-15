
// CONFIGURACAO DE IMPRESSORA PADRAO PARA O SISTEMA _________________________


function qconfprn
private cDESCPRN

if ! quse(XDRV_SH,"QPRN") ; return .F. ; endif
if ! quse("","QCONFIG") ; return .F. ; endif

select QPRN
locate for Codigo == XCOD_PRN

cDESCPRN := QPRN->Descricao

qlbloc(05,32,"ESCOLPRN",XDRV_SH+"QSBLOC.GLO")

QPRN->(qview({{"Codigo/C¢digo"      ,0},;
              {"Descricao/Descri‡„o",0}},"10322379",;
              {"i_conf_prn_escol","i_test_prn","i_tela_prn",NIL},;
              NIL,"<ESC> p/ voltar / <ENTER> p/ selecionar / <T>esta impress„o !"))

QPRN->(dbclosearea())
QCONFIG->(dbclosearea())

return

function i_tela_prn
   qsay(07,43,XCOD_PRN+" - "+cDESCPRN)
return

function i_conf_prn_escol
   if qconf("Confirma "+alltrim(QPRN->Descricao)+" como padr„o ?")
      if QCONFIG->(qrlock())
         XCOD_PRN := QPRN->Codigo
         replace QCONFIG->Cod_prn with QPRN->Codigo
         QCONFIG->(qunlock())
         cDESCPRN := QPRN->Descricao
      endif
   endif
return ""

function i_test_prn ( nOPCAO )
   if upper(chr(nOPCAO))=="T" .and. qconf("Confirma teste de impress„o ?")
      QPRN->(dbclosearea())
      if qinitprn()
         @ prow()+2,0 say XCOND1 + "IMPRESSAO EM MODO CONDENSADO 1" + XCOND0
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XCOND2 + "IMPRESSAO EM MODO CONDENSADO 2" + XCOND0
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XAEXPAN + "IMPRESSAO EM MODO EXPANDIDO" + XDEXPAN
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XASUBLI + "IMPRESSAO EM MODO SUBLINHADO" + XDSUBLI
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XAITALI + "IMPRESSAO EM MODO ITALICO" + XDITALI
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XAENFAT + "IMPRESSAO EM MODO ENFATIZADO" + XDENFAT
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XAINDIC + "IMPRESSAO EM MODO INDICE" + XDINDIC
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XAEXPOE + "IMPRESSAO EM MODO EXPOENTE" + XDEXPOE
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XACARTA + "IMPRESSAO EM MODO QUALIDADE CARTA" + XDCARTA
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"

         @ prow()+2,0 say XCOND1 + XASUBLI + "COMBINANDO CONDENSADO + SUBLINHADO" + XDSUBLI + XCOND0
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XCOND1 + XAITALI + "COMBINANDO CONDENSADO + ITALICO" + XDITALI + XCOND0
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XCOND1 + XAINDIC + "COMBINANDO CONDENSADO + INDICE" + XDINDIC + XCOND0
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"

         @ prow()+2,0 say XAEXPAN + XASUBLI + "COMBINANDO EXPANDIDO + SUBLINHADO" + XDSUBLI + XDEXPAN
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XAEXPAN + XAITALI + "COMBINANDO EXPANDIDO + ITALICO" + XDITALI + XDEXPAN
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"
         @ prow()+2,0 say XAEXPAN + XAINDIC + "COMBINANDO EXPANDIDO + INDICE" + XDINDIC + XDEXPAN
         @ prow()+1,0 say "RETORNO AO MODO NORMAL"

         @ prow()+3,0 say "TESTE CONCLUIDO, VERIFIQUE SE TUDO ESTA CORRETO !"
         @ prow()+1,0 say "CASO CONTRARIO, TENTE OUTRA IMPRESSORA OU COMUNIQUE-SE COM A Q-SYS !"
         qstopprn()
      endif
      if ! quse(XDRV_SH,"QPRN") ; return .F. ; endif
   endif
return

