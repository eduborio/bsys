/////////////////////////////////////////////////////////////////////////////
// ROTINAS DIVERSAS PARA IMPRESSAO __________________________________________

// qinitprn - inicializacao da impressora ou arquivo
// qpageprn - mudanca de pagina
// qlineprn - mudanca de linha
// qstopprn - finalizacao do relatorio
// qcontprn - flag de continuacao para os loops

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZACAO DA IMPRESSORA ANTES DO RELATORIO _______________

#include "inkey.ch"

function qinitprn ( nMARGEM , cWHERE ,cNOME)
   local sBLOC := qlbloc("PRN_INIT",XDRV_SH+"QSBLOC.GLO")
   local cONDE := "I"
   local cPORT := "1"
   local cPR   := ""
   local nTECLA, cTECLA, nLIN, nCOL, cDESCRPRN, cALIAS := alias()

   public XNOMEPRN, XBLOCTELA, XPAGINA, XLOCALIMP, XTEMPO, XCONTPRN, XPRIPAG := .T.

   if valtype(nMARGEM) <> "N"
      nMARGEM := 0
   endif

   if ! empty(cWHERE)
      keyboard cWHERE+chr(13)
   endif

   set margin to nMARGEM

   if ! quse(XDRV_SH,"QPRN") ; return .F. ; endif
   locate for XCOD_PRN == QPRN->Codigo
   cDESCRPRN := left(QPRN->Descricao,11)
   QPRN->(dbclosearea())

   if ! empty(cALIAS) ; select (cALIAS) ; endif

   XBLOCTELA := qsbloc(5,0,23,79)

   set key 28 to qhelpprn()

   do while .T.
      //iif(XMOUSEOK,qmousecu(0),NIL)
      qrbloc(07,24,sBLOC,1)
      qsay(09,32,cPORT)
      qsay(12,27,cDESCRPRN)

      iif ( cONDE == "I" , qinverc(08,26,12,38) , qinverc(08,41,12,53) )

      do while .T.
         //iif(XMOUSEOK,qmousecu(1),NIL)
         nTECLA := qinkey()
         cTECLA := upper(chr(nTECLA))
         do case
            case nTECLA == K_UP .or. nTECLA == K_DOWN .or. nTECLA == K_LEFT .or. nTECLA == K_RIGHT
                 cONDE := iif(cONDE=="I","A","I") ; exit
            case nTECLA == K_ENTER .or. nTECLA == K_ESC ; exit
            case cTECLA == "1" ; cPORT := "1" ; exit
            case cTECLA == "2" ; cPORT := "2" ; exit
            case cTECLA == "3" ; cPORT := "3" ; exit
            case cTECLA == "I" ; cONDE := "I" ; exit
            case cTECLA == "A" ; cONDE := "A" ; exit
            case cTECLA == "X" ; cONDE := "X" ; qsay(12,44," Excel ") ; exit
            case cTECLA == "S" ; cONDE := "S" ; qsay(12,44," Spool ") ; exit
            case cTECLA == "T" ; cONDE := "T" ; qsay(12,44," TxT   ") ; exit
            case cTECLA == "D" ; cONDE := "D" ; qsay(12,44," Word  ") ; exit
            //case XMOUSEOK .and. qmousebo() == 1
            //     do while .T.
            //        if qmousebo() == 0 ; exit ; endif
            //     enddo
            //     nLIN := qmouseli()
            //     nCOL := qmouseco()
            //     do case
            //        case nLIN == 09 .and. nCOL == 32 .and. cONDE == "I"
            //             cPORT := iif(cPORT=="1","2","1") ; exit
            //        case nLIN >= 8 .and. nLIN <=12 .and. nCOL >= 26 .and. nCOL <= 38
             //            cONDE := "I" ; exit
             //       case nLIN >= 8 .and. nLIN <=12 .and. nCOL >= 41 .and. nCOL <= 53
             //            cONDE := "A" ; exit
            //        case nLIN == 14 .and. nCOL >= 27 .and. nCOL <= 31
            //             nTECLA := K_ENTER ; exit
            //        case nLIN == 14 .and. nCOL >= 42 .and. nCOL <= 44
            //             nTECLA := K_ESC   ; exit
            //     endcase
         endcase
      enddo

      if nTECLA == K_ENTER .or. nTECLA == K_ESC ; exit ; endif

   enddo

   //iif(XMOUSEOK,qmousecu(0),NIL)

   if nTECLA == K_ESC
      qrbloc(5,0,XBLOCTELA)
      release XNOMEPRN, XBLOCTELA, XPAGINA, XLOCALIMP, XTEMPO, XCONTPRN, XPRIPAG
      return .F.
   endif

   XPAGINA   := 0
   XCONTPRN  := .T.
   XTEMPO    := time()

   XLOCALIMP := iif(cONDE=="I",cPORT,cONDE)

   if cONDE == "A"
      XNOMEPRN := i_ret_nome_prn()
      qsay(12,44,XNOMEPRN)
      set printer to (XNOMEPRN)
   elseif cONDE == "X"

      if ! quse(XDRV_SH,"QOUT") ; return .F. ; endif
      XNOMEPRN := rtrim(QOUT->Output) + i_xls()
      QOUT->(DbCloseArea())
      cPR  := XCOD_PRN
      XCOD_PRN := "20"
      qsay(12,44,"Excel")
      set printer to (XNOMEPRN)
      XCOD_PRN := cPR


   elseif cONDE == "S"
      if ! quse(XDRV_SH,"QOUT") ; return .F. ; endif
      XNOMEPRN := rtrim(QOUT->Output) + i_spool()
      QOUT->(DbCloseArea())
      cPR  := XCOD_PRN
      XCOD_PRN := "11"
      qsay(12,44,"Spooler")
      set printer to (XNOMEPRN)
      XCOD_PRN := cPR

   elseif cONDE == "D"
      if ! quse(XDRV_SH,"QOUT") ; return .F. ; endif
      XNOMEPRN := rtrim(QOUT->Output) + i_doc()
      QOUT->(DbCloseArea())

      XCOD_PRN := "20"
      qsay(12,44,"Word")
      set printer to (XNOMEPRN)

   elseif cONDE == "T"

      if ! quse(XDRV_SH,"QOUT") ; return .F. ; endif
      XNOMEPRN := rtrim(QOUT->Output) + i_txt()
      QOUT->(DbCloseArea())

      qsay(12,44,"TxT")
      set printer to (XNOMEPRN)

   else
      if cPORT == "1"
         set printer to LPT1
      elseif cPORT == "2"
         set printer to LPT2
      else
         set printer to LPT3
      endif
   endif

   qsay(16,30,strzero(XPAGINA,4))

   set device to printer

   i_cod_prn(.T.)

   @ prow(),pcol() say XRESET

   setprc(0,0)

   if ! empty(cALIAS) ; select (cALIAS) ; endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CALCULAR O NOME DO ARQUIVO PARA IMPRESSAO EM DISCO ___________

static function i_ret_nome_prn
   local aDIR, nCONT, cNOME

   aDIR := directory("R???.PRN")
   if empty(aDIR)
      aDIR := { { "R000.PRN" } }
   endif
   for nCONT := 1 to len(aDIR)
       aDIR[nCONT] := aDIR[nCONT,1]
   next
   aDIR := asort(aDIR)
// cNOME := "R" + XUSRNUM + strzero(val(substr(aDIR[len(aDIR)],5,3))+1,3) + ".PRN"
   cNOME := "R" + strzero(val(substr(aDIR[len(aDIR)],2,3))+1,3) + ".PRN"
return cNOME


static function i_spool
   local aDIR, nCONT, cNOME
   local aDIROUT := {}, mCONT := 0
   local Caminho := ""
   local isDigit := .F.

   Caminho := rtrim(QOUT->Output)


   aDIR := directory(Caminho+"R???.PRN",NIL)


   if empty(aDIR)
      aDIR := { { "R000.PRN" } }
   endif

   for nCONT := 1 to len(aDIR)
       for mCONT := 2 to 4
           if isDigit(substr(aDIR[nCONT,1],mCONT,1))
              isDigit := .T.
           else
              isDigit := .F.
              exit
           endif
       next

       if isDigit
          aadd(aDIROUT,aDIR[nCONT,1])
       endif

       isDigit := .F.
   next
   aDIROUT := asort(aDIROUT)

   cNOME := "R" + strzero(val(substr(aDIROUT[len(aDIROUT)],2,3))+1,3) + ".PRN"

return cNOME


static function i_txt
   local aDIR, nCONT, cNOME
   local aDIROUT := {}, mCONT := 0
   local Caminho := ""
   local isDigit := .F.

   Caminho := rtrim(QOUT->Output)


   aDIR := directory(Caminho+"R???.TXT",NIL)


   if empty(aDIR)
      aDIR := { { "R000.TXT" } }
   endif

   for nCONT := 1 to len(aDIR)
       for mCONT := 2 to 4
           if isDigit(substr(aDIR[nCONT,1],mCONT,1))
              isDigit := .T.
           else
              isDigit := .F.
              exit
           endif
       next

       if isDigit
          aadd(aDIROUT,aDIR[nCONT,1])
       endif

       isDigit := .F.
   next
   aDIROUT := asort(aDIROUT)

   cNOME := "R" + strzero(val(substr(aDIROUT[len(aDIROUT)],2,3))+1,3) + ".TXT"

return cNOME


static function i_doc
   local aDIR, nCONT, cNOME
   local aDIROUT := {}, mCONT := 0
   local Caminho := ""
   local isDigit := .F.

   Caminho := rtrim(QOUT->Output)


   aDIR := directory(Caminho+"R???.DOC",NIL)


   if empty(aDIR)
      aDIR := { { "R000.DOC" } }
   endif

   for nCONT := 1 to len(aDIR)
       for mCONT := 2 to 4
           if isDigit(substr(aDIR[nCONT,1],mCONT,1))
              isDigit := .T.
           else
              isDigit := .F.
              exit
           endif
       next

       if isDigit
          aadd(aDIROUT,aDIR[nCONT,1])
       endif

       isDigit := .F.
   next
   aDIROUT := asort(aDIROUT)

   cNOME := "R" + strzero(val(substr(aDIROUT[len(aDIROUT)],2,3))+1,3) + ".DOC"

return cNOME




static function i_xls
   local aDIR, nCONT, cNOME
   local aDIROUT := {}, mCONT := 0
   local Caminho := ""
   local isDigit := .F.

   Caminho := rtrim(QOUT->Output)


   aDIR := directory(Caminho+"R???.XLS",NIL)


   if empty(aDIR)
      aDIR := { { "R000.XLS" } }
   endif

   for nCONT := 1 to len(aDIR)
       for mCONT := 2 to 4
           if isDigit(substr(aDIR[nCONT,1],mCONT,1))
              isDigit := .T.
           else
              isDigit := .F.
              exit
           endif
       next

       if isDigit
          aadd(aDIROUT,aDIR[nCONT,1])
       endif

       isDigit := .F.
   next
   aDIROUT := asort(aDIROUT)

   cNOME := "R" + strzero(val(substr(aDIROUT[len(aDIROUT)],2,3))+1,3) + ".XLS"

return cNOME



/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA QUEBRA DE PAGINA _____________________________________________

function qpageprn

//   if XPAGINA <> 0 ; eject ; endif

   if XPRIPAG
      XPRIPAG := .F.
   else
      eject
   endif

   qsay(16,30,strzero(++XPAGINA,4))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TRACE DA IMPRESSAO LINHA A LINHA _____________________________

function qlineprn
   local nTECLA := qinkey()

   qsay(16,39,strzero(prow(),4))
   qsay(16,48,left(qdifhora(XTEMPO,time()),5))

   if nTECLA == K_ESC
      if alert("<ESC> PRESSIONADO",{"Continuar","Interromper"}) == 2
         XCONTPRN := .F.
      endif
   endif

return XCONTPRN

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FINALIZACAO DA IMPRESSAO _____________________________________

function qstopprn ( lEJECT , lEDICAO )
   set key 28 to qhelp

   iif ( lEJECT == NIL , lEJECT := .T. , )

   iif ( lEDICAO == NIL , lEDICAO := .T. , )

   if lEJECT ; eject ; endif

   if XLOCALIMP == "A"
      @ prow()+1,0 say chr(26)       // para fechar o arquivo em disco
   endif

   set margin to 0
   set printer to
   set device to screen

   iif ( XLOCALIMP == "A" .and. lEDICAO , q595(XNOMEPRN) , NIL )

   qrbloc(5,0,XBLOCTELA)

   release XNOMEPRN, XBLOCTELA, XPAGINA, XLOCALIMP, XTEMPO, XCONTPRN, XPRIPAG

   i_cod_prn(.F.)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONTROLE DE LOOP E INTERRUPCAO DO RELATORIO __________________

function qcontprn
return XCONTPRN

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR HELP DA TELA DE IMPRESSAO ____________________________

function qhelpprn
   local sTELA := qsbloc(00,00,24,79)
   set key 28 to
   qlbloc(00,00,"PRNHELP1",XDRV_SH+"QSBLOC.GLO")
   qlbloc(00,58,"PRNHELP2",XDRV_SH+"QSBLOC.GLO")
   qlbloc(18,00,"PRNHELP3",XDRV_SH+"QSBLOC.GLO")
   qinkey(0)
   qrbloc(00,00,sTELA)
   set key 28 to qhelpprn
return

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER O HEADER E CENTRALIZAR O TITULO NO RELATORIO ____________

function qcabecprn ( cSTRING, nLENGHT, dDATA , cSTRING2 )

   local lCOMDATA := .T.

   if valtype(dDATA) == "L"

      if dDATA == .F.
         lCOMDATA := .F.
      endif

      dDATA := date()

   endif

   dDATA := iif ( dDATA == NIL , date(), dDATA )

   @ prow()  ,0                              say XRAZAO

   if lCOMDATA
      @ prow()  ,nLENGHT-31                     say XPROG
      @ prow()  ,nLENGHT-27                     say dDATA
      @ prow()  ,nLENGHT-16                     say left(time(),5)
   endif

   @ prow()  ,nLENGHT-11                     say "Fls.: "
   @ prow()  ,nLENGHT-04                     say strzero(XPAGINA,4,0)
   @ prow()+1,0                              say replicate("=",nLENGHT)
   @ prow()+1,0                              say "|"
   @ prow()  ,int((nLENGHT-len(cSTRING))/2)  say cSTRING
   @ prow()  ,nLENGHT-01                     say "|"
   if cSTRING2 <> NIL
      @ prow()+1,0                               say "|"
      @ prow()  ,int((nLENGHT-len(cSTRING2))/2)  say cSTRING2
      @ prow()  ,nLENGHT-01                      say "|"
   endif
   @ prow()+1,0                              say replicate("=",nLENGHT)
return NIL

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA OU ELIMINA AS VARIAVEIS DE IMPRESSAO __________________________

function i_cod_prn ( lATIVA )
   if lATIVA
      if ! quse(XDRV_SH,"QPRN") ; return .F. ; endif
      locate for XCOD_PRN == QPRN->Codigo
      public XRESET  := iif(empty(QPRN->Reset ),"",&(QPRN->Reset ))
      public XQLINHA := iif(empty(QPRN->Qlinha),"",&(QPRN->Qlinha))
      public XCOND0  := iif(empty(QPRN->Cond0 ),"",&(QPRN->Cond0 ))
      public XCOND1  := iif(empty(QPRN->Cond1 ),"",&(QPRN->Cond1 ))
      public XCOND2  := iif(empty(QPRN->Cond2 ),"",&(QPRN->Cond2 ))
      public XAEXPAN := iif(empty(QPRN->Aexpan),"",&(QPRN->Aexpan))
      public XDEXPAN := iif(empty(QPRN->Dexpan),"",&(QPRN->Dexpan))
      public XAITALI := iif(empty(QPRN->Aitali),"",&(QPRN->Aitali))
      public XDITALI := iif(empty(QPRN->Ditali),"",&(QPRN->Ditali))
      public XASUBLI := iif(empty(QPRN->Asubli),"",&(QPRN->Asubli))
      public XDSUBLI := iif(empty(QPRN->Dsubli),"",&(QPRN->Dsubli))
      public XAINDIC := iif(empty(QPRN->Aindic),"",&(QPRN->Aindic))
      public XDINDIC := iif(empty(QPRN->Dindic),"",&(QPRN->Dindic))
      public XAEXPOE := iif(empty(QPRN->Aexpoe),"",&(QPRN->Aexpoe))
      public XDEXPOE := iif(empty(QPRN->Dexpoe),"",&(QPRN->Dexpoe))
      public XACARTA := iif(empty(QPRN->Acarta),"",&(QPRN->Acarta))
      public XDCARTA := iif(empty(QPRN->Dcarta),"",&(QPRN->Dcarta))
      public XAENFAT := iif(empty(QPRN->Aenfat),"",&(QPRN->Aenfat))
      public XDENFAT := iif(empty(QPRN->Denfat),"",&(QPRN->Denfat))
      QPRN->(dbclosearea())
   else
      release XRESET , XQLINHA, XCOND0 , XCOND1 , XCOND2
      release XAEXPAN, XDEXPAN, XAITALI, XDITALI, XACARTA, XDCARTA
      release XASUBLI, XDSUBLI, XAINDIC, XDINDIC, XAEXPOE, XDEXPOE
      release XAENFAT, XDENFAT
   endif
return .T.

