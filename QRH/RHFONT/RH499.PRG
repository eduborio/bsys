/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONVERSAO DE SISTEMAS - NOVA VERSAO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1996
// OBS........:
// ALTERACOES.:

#include "rh.ch"

if ! qconf("Confirma Convers„o de Sistemas ?")
   return
endif

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private cPATH1   // caminho da empresa E001 do QRH
private cPATH2   // caminho para empresa do QFOLHA (origem)
private cPATH3   // caminho para empresa do QRH    (destino)
private cDATASYS // ultima data (DATASYS) do CONFIG.DBF do QFOLHA

// ABRE ARQUIVO QINST.DBF, FILTRA E CRIA BASE PARA QRH ______________________

if ! quse(XDRV_SH,"QINST",{"QINST1"})
   qmensa("N„o foi poss¡vel abrir arquivo QINST.DBF !! Tente novamente.")
   return
endif

QINST->(dbSetFilter({|| Empresa <> "000"}, 'Empresa <> "000"'))

QINST->(dbgotop())

do while ! QINST->(eof())
   qgirabarra()

   if "FP" $ QINST->Sistemas .and. (! "RH" $ QINST->Sistemas .or. ("RH" $ QINST->Sistemas .and. QINST->Empresa == "001"))

       // LIBERA EMPRESA PARA TRABALHAR NO QRH ______________________________

       if QINST->(qrlock())
          if QINST->Empresa != "001"
             replace QINST->Sistemas with alltrim(QINST->Sistemas) + "RH."
          endif
          QINST->(dbunlock())
       endif

       // CRIA PATH'S ORIGEM E DESTINO PARA SISTEMA QRH _____________________

       cPATH1 := "\QSYS_G\QRH\E001\"
       cPATH2 := "\QSYS\QFOLHA\E" + QINST->Empresa + "\"
       cPATH3 := "\QSYS_G\QRH\E" + QINST->Empresa + "\"

       qsay(13,28,QINST->Empresa)
       qsay(13,34,left(QINST->Razao,38))

       // ABRE CONFIG E GUARDA O MES ATUAL DO QFOLHA ________________________

       if quse(cPATH2,"CONFIG",NIL,"R")
          cDATASYS := CONFIG->Datasys
          CONFIG->(dbclosearea())
       else
          qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
          return
       endif

       // VERIFICA EXISTENCIA DO DIRETORIO NO QRH, SENAO CRIA _______________

       if QINST->Empresa != "001"
          if ! qmdir("E" + QINST->Empresa)
             qmensa("N„o foi poss¡vel criar diret¢rio E" + QINST->Empresa + " !! Verifique.","B")
             return
          endif
       endif

       // PRIMEIRO ARQUIVOS FPX PARA RHX (SOMENTE EMPRESA 001) ______________

       if QINST->Empresa == "001"
          qgirabarra()

          copy file (cPATH2+"AFAST.DBF")   to (cPATH3+"AFAST.DBF")
          qgirabarra()
          copy file (cPATH2+"CARGO.DBF")   to (cPATH3+"CARGO.DBF")
          qgirabarra()
          copy file (cPATH2+"CAGED.DBF")   to (cPATH3+"CAGED.DBF")
          qgirabarra()
          copy file (cPATH2+"CBO.DBF")     to (cPATH3+"CBO.DBF")
          qgirabarra()
          copy file (cPATH2+"CFGDISQ.DBF") to (cPATH3+"CFGDISQ.DBF")
          qgirabarra()
          copy file (cPATH2+"DIRF.DBF")    to (cPATH3+"DIRF.DBF")
          qgirabarra()
          copy file (cPATH2+"KIT.DBF")     to (cPATH3+"KIT.DBF")
          qgirabarra()
          copy file (cPATH2+"INTBANC.DBF") to (cPATH3+"INTBANC.DBF")
          qgirabarra()
          copy file (cPATH2+"PTCFG.DBF")   to (cPATH3+"PTCFG.DBF")
          qgirabarra()
          copy file (cPATH2+"RAIS.DBF")    to (cPATH3+"RAIS.DBF")
          qgirabarra()
          copy file (cPATH2+"REFGTSM.DBF") to (cPATH3+"REFGTSM.DBF")
          qgirabarra()
          copy file (cPATH2+"REFGTSU.DBF") to (cPATH3+"REFGTSU.DBF")
          qgirabarra()
          copy file (cPATH2+"SIND.DBF")    to (cPATH3+"SIND.DBF")
          qgirabarra()
          copy file (cPATH2+"TBGR.DBF")    to (cPATH3+"TBGR.DBF")
          qgirabarra()
          copy file (cPATH2+"TBIF.DBF")    to (cPATH3+"TBIF.DBF")
          qgirabarra()
          copy file (cPATH2+"TBIR.DBF")    to (cPATH3+"TBIR.DBF")
          qgirabarra()
          copy file (cPATH2+"TBSF.DBF")    to (cPATH3+"TBSF.DBF")
       endif
       
       // DEMAIS ARQUIVOS (FP PARA RH) ______________________________________

       if QINST->Empresa != "001"
          copy file (cPATH1+"VALE.DBF") to (cPATH3+"VALE.DBF")
       endif

       if quse(cPATH3,"VALE",NIL,"E")
          VALE->(__dbzap())
          append from (cPATH2 + "VALE.DBF")
          VALE->(dbgotop())
          do while ! VALE->(eof())
             qgirabarra()
             replace VALE->Anomes with "9801"
             VALE->(dbskip())
          enddo
          if month(cDATASYS) == 2 .or.;
             month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9802"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9803"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9804"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9805"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9806"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9807"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9808"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9809"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9810"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9811"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9812"
                endif
                VALE->(dbskip())
             enddo
          endif
          append from (cPATH2 + "VALE.DBF")
          VALE->(dbgotop())
          do while ! VALE->(eof())
             qgirabarra()
             if empty(VALE->Anomes)
                replace VALE->Anomes with "9901"
             endif
             VALE->(dbskip())
          enddo
          if month(cDATASYS) == 2 .or.;
             month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9902"
                endif
                VALE->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "VALE")
             VALE->(dbgotop())
             do while ! VALE->(eof())
                qgirabarra()
                if empty(VALE->Anomes)
                   replace VALE->Anomes with "9903"
                endif
                VALE->(dbskip())
             enddo
          endif
          VALE->(dbclosearea())
       else
          qmensa("N„o foi poss¡vel abrir arquivo VALE.DBF !! Verifique.")
       endif

       if QINST->Empresa != "001"
          copy file (cPATH1+"CONFIG.DBF") to (cPATH3+"CONFIG.DBF")
       endif

       if quse(cPATH3,"CONFIG",NIL,"E")
          CONFIG->(__dbzap())
          append from (cPATH2 + "CONFIG")
          replace CONFIG->Data_atual with CONFIG->Datasys
          CONFIG->(dbclosearea())
       else
          qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Verifique.")
       endif

       qgirabarra()

       if QINST->Empresa != "001"
          copy file (cPATH1+"DEPART.DBF") to (cPATH3+"DEPART.DBF")
       endif

       copy file (cPATH2+"ACAD.DBF")    to (cPATH3+"ACAD.DBF")
       qgirabarra()
       copy file (cPATH2+"BASE.DBF")    to (cPATH3+"BASE.DBF")
       qgirabarra()
       copy file (cPATH2+"DEPE.DBF")    to (cPATH3+"DEPE.DBF")
       qgirabarra()
       copy file (cPATH2+"DISC.DBF")    to (cPATH3+"DISC.DBF")
       qgirabarra()
       copy file (cPATH2+"DISC.DBT")    to (cPATH3+"DISC.DBT")
       qgirabarra()
       copy file (cPATH2+"EVCFG.DBF")   to (cPATH3+"EVCFG.DBF")
       qgirabarra()
       copy file (cPATH2+"EVCONT.DBF")  to (cPATH3+"EVCONT.DBF")
       qgirabarra()
       copy file (cPATH2+"GRUPOC.DBF")  to (cPATH3+"GRUPOC.DBF")
       qgirabarra()
       copy file (cPATH2+"GRUPOV.DBF")  to (cPATH3+"GRUPOV.DBF")
       qgirabarra()
       copy file (cPATH2+"HIST.DBF")    to (cPATH3+"HIST.DBF")
       qgirabarra()
       copy file (cPATH2+"INTEGRA.DBF") to (cPATH3+"INTEGRA.DBF")
       qgirabarra()
       copy file (cPATH2+"LANC.DBF")    to (cPATH3+"LANC.DBF")
       qgirabarra()
       copy file (cPATH2+"PROF.DBF")    to (cPATH3+"PROF.DBF")

       if QINST->Empresa != "001"
          copy file (cPATH1+"BENEF.DBF") to (cPATH3+"BENEF.DBF")
       endif

       if quse(cPATH3,"BENEF",NIL,"E")
          BENEF->(__dbzap())
          append from (cPATH2 + "BENEF")
          BENEF->(dbgotop())
          do while ! BENEF->(eof())
             qgirabarra()
             replace BENEF->Anomes with "9801"
             BENEF->(dbskip())
          enddo
          if month(cDATASYS) == 2 .or.;
             month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9802"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9803"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9804"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9805"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9806"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9807"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9808"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9809"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9810"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9811"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9812"
                endif
                BENEF->(dbskip())
             enddo
          endif
          append from (cPATH2 + "BENEF")
          BENEF->(dbgotop())
          do while ! BENEF->(eof())
             qgirabarra()
             if empty(BENEF->Anomes)
                replace BENEF->Anomes with "9901"
             endif
             BENEF->(dbskip())
          enddo
          if month(cDATASYS) == 2 .or.;
             month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9902"
                endif
                BENEF->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "BENEF")
             BENEF->(dbgotop())
             do while ! BENEF->(eof())
                qgirabarra()
                if empty(BENEF->Anomes)
                   replace BENEF->Anomes with "9903"
                endif
                BENEF->(dbskip())
             enddo
          endif
          BENEF->(dbclosearea())
       else
          qmensa("N„o foi poss¡vel abrir arquivo BENEF.DBF !! Verifique.")
       endif

       if QINST->Empresa != "001"
          copy file (cPATH1+"GRPS.DBF") to (cPATH3+"GRPS.DBF")
       endif

       if quse(cPATH3,"GRPS",NIL,"E")
          GRPS->(__dbzap())
          append from (cPATH2 + "GRPS")
          GRPS->(dbgotop())
          do while ! GRPS->(eof())
             qgirabarra()
             replace GRPS->Anomes with "9801"
             GRPS->(dbskip())
          enddo
          if month(cDATASYS) == 2 .or.;
             month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9802"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9803"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9804"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9805"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9806"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9807"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9808"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9809"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9810"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9811"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9812"
                endif
                GRPS->(dbskip())
             enddo
          endif
          append from (cPATH2 + "GRPS")
          GRPS->(dbgotop())
          do while ! GRPS->(eof())
             qgirabarra()
             if empty(GRPS->Anomes)
                replace GRPS->Anomes with "9901"
             endif
             GRPS->(dbskip())
          enddo
          if month(cDATASYS) == 2 .or.;
             month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9902"
                endif
                GRPS->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "GRPS")
             GRPS->(dbgotop())
             do while ! GRPS->(eof())
                qgirabarra()
                if empty(GRPS->Anomes)
                   replace GRPS->Anomes with "9903"
                endif
                GRPS->(dbskip())
             enddo
          endif
          GRPS->(dbclosearea())
       else
          qmensa("N„o foi poss¡vel abrir arquivo GRPS.DBF !! Verifique.")
       endif

       if QINST->Empresa != "001"
          copy file (cPATH1+"FUN.DBF") to (cPATH3+"FUN.DBF")
       endif

       qgirabarra()

       if quse(cPATH3,"FUN",NIL,"E")
          FUN->(__dbzap())
          FUN->(dbCreateIndex( (cPATH3 + "FU_MATRI"), "Matricula", {|| Matricula}, if( .F., .T., NIL )))
          append from (cPATH2 + "FUN")
       else
          qmensa("N„o foi poss¡vel abrir arquivo FUN.DBF !! Verifique.")
       endif

       if QINST->Empresa != "001"
          copy file (cPATH1+"SITUA.DBF") to (cPATH3+"SITUA.DBF")
       endif
       
       if quse(cPATH3,"SITUA",NIL,"E")
          SITUA->(__dbzap())
          append from (cPATH2 + "FUN")
          SITUA->(dbgotop())
          do while ! SITUA->(eof())
             qgirabarra()
             replace SITUA->Anomes with "9801"
             do case
                case SITUA->Vinculo == "1"
                     replace SITUA->Vinculo with "A"
                case SITUA->Vinculo == "2"
                     replace SITUA->Vinculo with "E"
                case SITUA->Vinculo == "3"
                     replace SITUA->Vinculo with "G"
                case SITUA->Vinculo == "4"
                     replace SITUA->Vinculo with "H"
                case SITUA->Vinculo == "5"
                     replace SITUA->Vinculo with "I"
                case SITUA->Vinculo == "6"
                     replace SITUA->Vinculo with "D"
                case SITUA->Vinculo == "7"
                     replace SITUA->Vinculo with "N"
                case SITUA->Vinculo == "8"
                     replace SITUA->Vinculo with "F"
                case SITUA->Vinculo == "9"
                     replace SITUA->Vinculo with "B"
                case SITUA->Vinculo == "0"
                     replace SITUA->Vinculo with "C"
             endcase
             SITUA->(dbskip())
          enddo
          if month(cDATASYS) == 2 .or.;
             month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9802"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 1
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 2
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 2
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif

                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9803"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 2
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 3
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 3
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9804"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 3
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 4
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 4
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9805"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 4
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 5
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 5
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9806"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 5
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 6
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 6
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9807"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 6
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 7
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 7
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9808"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 7
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 8
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 8
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9809"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 8
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 9
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 9
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9810"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 9
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 10
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 10
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9811"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 10
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 11
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 11
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9812"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1998 .and. month(SITUA->Af_ini) == 11
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 12
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1998 .and. month(SITUA->Af_ret) == 12
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          append from (cPATH2 + "FUN")
          SITUA->(dbgotop())
          do while ! SITUA->(eof())
             qgirabarra()
             if empty(SITUA->Anomes)
                replace SITUA->Anomes with "9901"
                do case
                   case SITUA->Vinculo == "1"
                        replace SITUA->Vinculo with "A"
                   case SITUA->Vinculo == "2"
                        replace SITUA->Vinculo with "E"
                   case SITUA->Vinculo == "3"
                        replace SITUA->Vinculo with "G"
                   case SITUA->Vinculo == "4"
                        replace SITUA->Vinculo with "H"
                   case SITUA->Vinculo == "5"
                        replace SITUA->Vinculo with "I"
                   case SITUA->Vinculo == "6"
                        replace SITUA->Vinculo with "D"
                   case SITUA->Vinculo == "7"
                        replace SITUA->Vinculo with "N"
                   case SITUA->Vinculo == "8"
                        replace SITUA->Vinculo with "F"
                   case SITUA->Vinculo == "9"
                        replace SITUA->Vinculo with "B"
                   case SITUA->Vinculo == "0"
                        replace SITUA->Vinculo with "C"
                endcase
                do case
                   case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1999 .and. month(SITUA->Af_ini) == 1
                        replace SITUA->Situacao with "H"
                        if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                           replace FUN->Situacao with "H"
                           FUN->(qunlock())
                        endif
                   case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1999 .and. month(SITUA->Af_ret) == 2
                        replace SITUA->Situacao with "T"
                        replace SITUA->Af_ini   with ctod("")
                        replace SITUA->Af_ret   with ctod("")
                        if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                           replace FUN->Situacao with "T"
                           FUN->(qunlock())
                        endif
                   case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1999 .and. month(SITUA->Af_ret) == 2
                        replace SITUA->Situacao with "T"
                        replace SITUA->Af_cod   with space(2)
                        replace SITUA->Af_ini   with ctod("")
                        replace SITUA->Af_ret   with ctod("")
                        if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                           replace FUN->Situacao with "T"
                           FUN->(qunlock())
                        endif
                endcase
             endif
             SITUA->(dbskip())
          enddo
          if month(cDATASYS) == 2 .or.;
             month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9902"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1999 .and. month(SITUA->Af_ini) == 1
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1999 .and. month(SITUA->Af_ret) == 2
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1999 .and. month(SITUA->Af_ret) == 2
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif
          if month(cDATASYS) == 3 .or.;
             month(cDATASYS) == 4 .or.;
             month(cDATASYS) == 5 .or.;
             month(cDATASYS) == 6 .or.;
             month(cDATASYS) == 7 .or.;
             month(cDATASYS) == 8 .or.;
             month(cDATASYS) == 9 .or.;
             month(cDATASYS) == 10 .or.;
             month(cDATASYS) == 11 .or.;
             month(cDATASYS) == 12
             append from (cPATH2 + "FUN")
             SITUA->(dbgotop())
             do while ! SITUA->(eof())
                qgirabarra()
                if empty(SITUA->Anomes)
                   replace SITUA->Anomes with "9903"
                   do case
                      case SITUA->Vinculo == "1"
                           replace SITUA->Vinculo with "A"
                      case SITUA->Vinculo == "2"
                           replace SITUA->Vinculo with "E"
                      case SITUA->Vinculo == "3"
                           replace SITUA->Vinculo with "G"
                      case SITUA->Vinculo == "4"
                           replace SITUA->Vinculo with "H"
                      case SITUA->Vinculo == "5"
                           replace SITUA->Vinculo with "I"
                      case SITUA->Vinculo == "6"
                           replace SITUA->Vinculo with "D"
                      case SITUA->Vinculo == "7"
                           replace SITUA->Vinculo with "N"
                      case SITUA->Vinculo == "8"
                           replace SITUA->Vinculo with "F"
                      case SITUA->Vinculo == "9"
                           replace SITUA->Vinculo with "B"
                      case SITUA->Vinculo == "0"
                           replace SITUA->Vinculo with "C"
                   endcase
                   do case
                      case SITUA->Situacao == "D" .and. year(SITUA->Af_ini) == 1999 .and. month(SITUA->Af_ini) == 2
                           replace SITUA->Situacao with "H"
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "H"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "F" .and. year(SITUA->Af_ret) == 1999 .and. month(SITUA->Af_ret) == 3
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                      case SITUA->Situacao == "A" .and. year(SITUA->Af_ret) == 1999 .and. month(SITUA->Af_ret) == 3
                           replace SITUA->Situacao with "T"
                           replace SITUA->Af_cod   with space(2)
                           replace SITUA->Af_ini   with ctod("")
                           replace SITUA->Af_ret   with ctod("")
                           if FUN->(dbseek(SITUA->Matricula)) .and. FUN->(qrlock())
                              replace FUN->Situacao with "T"
                              FUN->(qunlock())
                           endif
                   endcase
                endif
                SITUA->(dbskip())
             enddo
          endif

          SITUA->(dbclosearea())
          FUN->(dbclosearea())
       else
          qmensa("N„o foi poss¡vel abrir arquivo SITUA.DBF !! Verifique.")
       endif
   endif

   QINST->(dbskip())

enddo

return
