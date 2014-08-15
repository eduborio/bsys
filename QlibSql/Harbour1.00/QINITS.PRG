
// TRANSFERENCIA DO QPATHS PARA CA EM JUNHO DE 1995

// INICIALIZAO PADRAO PARA AS APLICACOES Q-SYSTEM ___________________________

#include "inkey.ch"
#include "fileio.ch"

function qinit_sist

   // VERIFICA SET CLIPPER __________________________________________________
   // i_chk_set_clipper()

   // VERIFICA ESPACO EM DISCO ______________________________________________

   //i_chk_space()

   // VERIFICACAO DE ARQUIVOS OBRIGATORIOS __________________________________

   i_chk_file("QHELP.DBF")

   i_chk_file("QHELP.DBT")
   i_chk_file("QBLOC.GLO")
   i_chk_file("QPATHS.DBF")
   i_chk_file("QPROGS.DBF")
   i_chk_file("QACESS.DBF")
   i_chk_file("QINDEX.DBF")
   i_chk_file("QSTRUCT.DBF")
   i_chk_file("QCONFIG.DBF")

   // CONFIGURACAO DOS FLAGS ________________________________________________

   set scor off
   set bell off
   set safe off
   set dele on
   set inte on
   set date brit
   set conf on
   set excl off


   // INICIALIZACAO DAS TECLAS DE FUNCOES ___________________________________



   qkeyon()

   set key K_CTRL_ENTER to q_back_field     // CTRL-ENTER

   set key K_ALT_F10    to qshell           // ALT-F10

   set key K_ALT_V      to q_aux_prog       // AUXILIOS A PROGRAMACAO

   set key K_ALT_I      to qindexcontrol    // INDEXACAO Q-SYS

   // ACIONA VERIFICACAO E LIMPEZA DOS ARQUIVOS PRN _________________________


   i_limpa_prn()

   // ACIONA ATUALIZACAO DO QPATHS __________________________________________

   i_atua_paths()

   isIndexing()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CHECAR ARQUIVOS OBRIGATORIOS DO SISTEMA ______________________

function i_chk_file ( cFILE )
   if ! file(cFILE)
      alert("ERRO! N„o foi possivel encontrar o arquivo " + cFILE + "...",{"OK"})
      setcolor("W/N")
      @ 24,00 say ""
      ?
      quit
   endif
return


/////////////////////////////////////////////////////////////////////////////
// VERIFICACAO E LIMPEZA DE ARQUIVOS PRN ____________________________________

static function i_limpa_prn
   local aVET := directory("*.PRN")
   local nCONT

   for nCONT := 1 to len(aVET)
       if aVET[nCONT,3] < date()
          erase (aVET[nCONT,1])
       endif
   next

return

/////////////////////////////////////////////////////////////////////////////
// VERIFICA ESPACO EM DISCO _________________________________________________

static function i_chk_space
   local nBYTES := diskspace(0)

   if nBYTES < 10000000
      if alert("-C-U-I-D-A-D-O-;;O espa‡o fisico de seu disco rigido;est  abaixo do minimo recomendado.;;ESPA€O ATUAL: "+;
         alltrim(transform(nBYTES,"@E 999,999,999")),{"CONTINUAR","ENCERRAR"}) == 2
         clear screen
         quit
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// VERIFICA SET CLIPPER _____________________________________________________

static function i_chk_set_clipper

   local cSET := upper(getenv("CLIPPER"))
   local nPOS := at("//F",cSET)
   //local nFIL := val(subs(cSET,nPOS+3,3))

   if ! "//F" $ cSET .or. ! "//DYNF" $ cSET .or. ! "//SWAPK:" $ cSET .or. ! "//SWAPPATH:" $ cSET .or. ! "//SWAPPATH:" $ cSET //  .or. nFIL < 90

      nOPCAO := alert("-A-T-E-N-€-Ž-O-;;A configura‡„o 'set clipper' est  irregular;"+;
                "e pode ocasionar problemas no;funcionamento normal do sistema.;;",;
                {"CONTINUAR","ENCERRAR"})

      if nOPCAO == 2
         clear screen
         quit
      endif

   endif

return

/////////////////////////////////////////////////////////////////////////////
// ATUALIZACAO DOS PATHS VIA ARQUIVO QPATHS.DBF _____________________________

static function i_atua_paths
   local nCONT, aPATHS := {}

   private XTIMEF := XTIMEU := 1

   if ! quse("","QINDEX") ; return .F. ; endif
   if ! quse("","QPATHS") ; return .F. ; endif

   do while ! QPATHS->(eof())
      QPATHS->(aadd(aPATHS,Arquivo+Caminho))
      QPATHS->(dbskip())
   enddo

   if QINDEX->(qflock())
      do while ! QINDEX->(eof())
         qgirabarra()

         if ( nCONT := ascan(aPATHS,QINDEX->Arquivo) ) <> 0
            replace QINDEX->Caminho with right(aPATHS[nCONT],8)
         endif
         QINDEX->(dbskip())
      enddo
   endif

   QPATHS->(dbclosearea())
   QINDEX->(dbclosearea())

return .T.

static function isIndexing

   if file("\Qsys_g\mantra.cfg")

      if i_chk_idxing()
         alert("Sistema Organizando Indices. Por favor aguarde...")
         quit
      endif

   endif

return

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// CHAMADAS APENAS PARA LINK ________________________________________________

q901()
q199()
q198()
q590()
q595()
qnomemes()
qnomesemana()

