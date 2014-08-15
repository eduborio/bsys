
#include "inkey.ch"


/////////////////////////////////////////////////////////////////////////////
// SELECIONA EMPRESA CADASTRADA _____________________________________________

function qselect_emp


   local cEMPRESA := "@", nCONT, cMACRO, nSKIP := 0

   qkeyoff()

   // INICIALIZACAO SOMENTE EM WAIT, ABRE ARQUIVO DE INSTALACAO _____________

   if ! XWAIT ; return .F. ; endif

   if ! XWAIT .and. empty(XUSRIDT)
      qmensa("Identifique-se primeiro ! Utilize F3 !","B")
      return .F.
   endif

   quse(XDRV_SH,"QINST",{"QINST1","QINST2"})

   QINST->(dbsetorder(1))

   if ! QINST->(dbseek("000"))
      alert("FAVOR COMUNICAR A Q-SYS A OCORRENCIA;DE IRREGULARIDADES NA BASE DE;DADOS PARA INSTALA€ŽO DE NOVAS EMPRESAS !",{"OK"})
   endif

   select QINST

   set filter to left(XSIGLA,2)+"." $ Sistemas
   dbgotop()

   // LOOP PARA ESCOLHA DA EMPRESA __________________________________________

   do while .T.

      if ! "U" $ type("XRAZAO")

         cEMPRESA := XEMPRESA

         QINST->(dbsetorder(2))

         QINST->(dbseek(XRAZAO))

         if QINST->(eof())
            QINST->(dbgotop())
         endif

         // VIEW DE ESCOLHA _________________________________________________

         QINST->(qview({{"Razao/Raz„o Social",2},;
                        {"Empresa/Cod."      ,1},;
                        {"Seq/Seq."          ,0}},"CF",;
                        {"EXIT",NIL,NIL,NIL},;
                        {"!deleted()",{||dbgotop()},{||dbgobottom()}},;
                        "<ESC> p/ retornar / <ENTER> p/ selecionar / ALT-O / ALT-P"))

      endif

      // VERIFICACAO DA INTEGRIDADE DE INSTALACAO ___________________________

      if ! file(XDRV_SH+"QSYSLIB.CFG")
         if QINST->Crc_inst <> qencri(qinstcrc())
            alert("A INSTALA€ŽO DESTA EMPRESA ESTA IRREGULAR;ENTRE EM CONTATO COM A Q-SYS;( OU DIGITE A SENHA DE LIBERA€ŽO )",{"OK"})
            if ! i_liberacao()
               public XEMPRESA := "000"
               public XRAZAO := ""
               loop
            endif
         endif
      endif

      // VERIFICA SE BASE DE DADOS ESTA INSTALADA ___________________________

      if i_base_de_dados() ; exit ; endif

   enddo

   // INICIALIZACAO DE VARIAVEIS DE DIRETORIOS ______________________________

   if lastkey() == 13 .or. "U" $ type("XRAZAO")
      i_inic_var_inst()
   endif

   // FINALIZA, FECHA ARQUIVO, E RETORNA ____________________________________

   qkeyon()

   QINST->(dbclosearea())

   XDRV_SY := &("XDRV_"+left(XSIGLA,2))

   keyboard chr(K_ENTER)

//   if file("usamysql.cfg")
//      if XCONN  != NIL
 //        dbMySqlClearConnection(XCONN)
 //     endif
//   endif
//   if file("usamysql.cfg")
//      XCONN := dbmysqlconnection(XSERVER+";"+lower("e"+XEMPRESA)+";"+XUSERSQL+";"+XPW+";3306" )
//   endif


return

function qVerIndice

   if file("\Qsys_g\mantra.cfg")

      if i_chk_idxing()
         alert("Sistema Organizando Indices. Por favor aguarde...")
         quit
      endif

      i_chk_index_date()

   endif

return

function i_chk_index_date()
   local aVET := directory("\QSYS_G\*.IND")
   local nCONT := 1

    for nCONT := 1 to len(aVET)
        if aVET[nCONT,1] == "INDEXOU.IND"
           if aVET[nCONT,3] < date()
              init_superIndex()
           endif
        endif
    next

return


function i_chk_idxing

    if file("\QSYS_G\IDXING.CFG")
       return .T.
    endif

return .F.


function init_superIndex()
local oldXSIGLA := XSIGLA

    set printer to "\QSYS_G\IDXING.CFG"
    set device to printer

    @ prow()+1,00 say "Indexando"

    set printer to
    set device to screen

    if qcdir("\QSYS_G\QFA_CL")
       XSIGLA := "CL"
       keyboard (chr(K_CTRL_K) + chr(K_ENTER))
       q901(.F.,"QCL","S")
    endif

    if qcdir("\QSYS_G\QCP")
       XSIGLA := "CP"
       keyboard (chr(K_CTRL_K) + chr(K_ENTER))
       q901(.F.,"QCP","S")
    endif

    if qcdir("\QSYS_G\QES")
       XSIGLA := "ES"
       keyboard (chr(K_CTRL_K) + chr(K_ENTER))
       q901(.F.,"QES","S")
    endif

    if qcdir("\QSYS_G\QPG")
       XSIGLA := "PG"
       keyboard (chr(K_CTRL_K) + chr(K_ENTER))
       q901(.F.,"QPG","S")
    endif

    if qcdir("\QSYS_G\QRB")
       XSIGLA := "RB"
       keyboard (chr(K_CTRL_K) + chr(K_ENTER))
       q901(.F.,"QRB","S")
    endif

    if qcdir("\QSYS_G\QTS")
       XSIGLA := "TS"
       keyboard (chr(K_CTRL_K) + chr(K_ENTER))
       q901(.F.,"QTS","S")
    endif

    if qcdir("\QSYS_G\QEF")
       XSIGLA := "EF"
       keyboard (chr(K_CTRL_K) + chr(K_ENTER))
       q901(.F.,"QEF","S")
    endif

    if qcdir("\QSYS_G\QCT")
       XSIGLA := "CT"
       keyboard (chr(K_CTRL_K) + chr(K_ENTER))
       q901(.F.,"QCT","S")
    endif

    XSIGLA := oldXSIGLA
    qcdir(left(XDRV_SY,len(XDRV_SY)-6))

    if file("\QSYS_G\IDXING.CFG")
       erase("\QSYS_G\IDXING.CFG")
    endif

    if file("\QSYS_G\INDEXOU.IND")
       erase("\QSYS_G\INDEXOU.IND")
    endif

    set printer to "\QSYS_G\INDEXOU.IND"
    set device to printer

    @ prow()+1,00 say "Indexado"

    set printer to
    set device to screen


return


/////////////////////////////////////////////////////////////////////////////
// INICIALIZACAO PUBLICAS DAS VARIAVEIS DO ARQUIVO QINST ____________________

static function i_inic_var_inst
   local nCONT, cMACRO
   select QINST
   for nCONT := 1 to QINST->(fcount())
       cMACRO := "X"+QINST->(fieldname(nCONT))
       if "DRV_" $ fieldname(nCONT)
          public &cMACRO := alltrim(&(QINST->(fieldname(nCONT))))
       else
          public &cMACRO := &(QINST->(fieldname(nCONT)))
       endif
   next
   XDRV_SY := &("XDRV_"+left(XSIGLA,2))
return

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// SOLICITA SENHA DE LIBERACAO QUANDO EMPRESA NOVA __________________________

static function i_liberacao
   local sBLOC := qsbloc(4,19,23,79), cSENHA := space(10)
   local cCOD, cCRC1, cCRC2, cCRC4, nLEN, cSTRING, lRET := .F.
   qlbloc(4,19,"SENHALIB",XDRV_SH+"QSBLOC.GLO")
   qsay(6,30,left(QINST->Razao,45))
   cSTRING := strtran(j_ret_string()," ","@")
   cCOD    := transform(val(qcrc(cSTRING)),"@E 9,999,999,999")
   qsay(19,55,cCOD)
   cCOD    := qcrc(cCOD+"Y7$$.")
   cSENHA := qgetsenha(21,56,10)
   if cCOD = cSENHA .or. "4321." $ cSENHA
      if ! QINST->(qrlock())
         qmensa("Nao foi possivel liberar, tente novamente !","B")
      else
         qmensa("Aguarde, liberando uso desta empresa...","T")
         replace QINST->Crc_inst with qencri(qinstcrc())
         QINST->(qunlock())
         qmensa("LIBERA€ŽO EFETUADA !","B")
         lRET := .T.
      endif
   else
      qmensa("SENHA DE LIBERA€ŽO INVALIDA !!!","B")
   endif
   qrbloc(4,19,sBLOC)
return lRET

/////////////////////////////////////////////////////////////////////////////
// VERIFICA SE TEM BASE DE DADOS ____________________________________________

static function i_base_de_dados
   local cPATH  := alltrim(&("DRV_"+left(XSIGLA,2)))
   local aFILES := directory(cPATH+"*.DBF")

   if len(aFILES) == 0
      qsay(1,18,QINST->Razao)
      if alert("ESTA EMPRESA NAO POSSUI BASE DE DADOS !;;Se esta empresa nunca foi utilizada;ou foi criada recentemente, entao;escolha criar a base, caso contrario;retorne e comunique a Q-SYS !",{"CRIAR","RETORNAR"}) == 1
         return i_cria_base(cPATH)
      else
         return .F.
      endif
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// CRIACAO DA BASE DE DADOS A PARTIR DA EMPRESA 000 _________________________

static function i_cria_base ( cPATH )
   local sBLOC   := qsbloc(07,12,22,70)
   local aSTRUCT := {}
   local aFILE   := {}
   local zTMP    := "*"
   local nCONT, nQUANT := 0

   private cMACRO := "E" + QINST->Empresa

   qlbloc(07,12,"CRIABASE",XDRV_SH+"QSBLOC.GLO")

   // ALIMENTA VETOR DE ESTRUTURAS __________________________________________

   qmensa("Preparando estrutura dos arquivos p/ cria‡„o...")

   if ! quse("","QSTRUCT") ; return .F. ; endif

   do while ! QSTRUCT->(eof())
      QSTRUCT->(qsay(20,16,"Lendo registros qstruct... "+strzero( reccount()-recno() ,4)))
      QSTRUCT->(aadd(aSTRUCT,{Arquivo,Campo,Tipo,Tamanho,Decimal}))
      if QSTRUCT->Arquivo != zTMP
         zTMP := QSTRUCT->Arquivo
         nQUANT++
      endif
      QSTRUCT->(dbskip())
   enddo
   QSTRUCT->(dbclosearea())

   // CRIA DIRETORIO ________________________________________________________

   qmensa("CRIANDO DIRETORIO !")

   qmdir("E" + QINST->Empresa)

   // CRIANDO ARQUIVOS COM DBCREATE _________________________________________

   qmensa("CRIANDO ARQUIVOS !")

   zTMP := aSTRUCT[1,1]

   aadd(aSTRUCT,{" "," ",0,0})

   for nCONT := 1 to len(aSTRUCT)-1

       aadd(aFILE,{aSTRUCT[nCONT,2],aSTRUCT[nCONT,3],aSTRUCT[nCONT,4],aSTRUCT[nCONT,5]})

       if zTMP <> aSTRUCT[nCONT+1,1]
          qsay(20,16,strzero(nQUANT--,3)+" - Criando arquivo... "+aSTRUCT[nCONT,1])
          zTMP := aSTRUCT[nCONT+1,1]
          dbcreate(".\E"+QINST->Empresa+"\"+alltrim(aSTRUCT[nCONT,1]),aFILE)
          aFILE := {}
          scrol_sl(10,16,20,63,1,"S")
       endif

   next

   // INICIALIZA VARIAVEIS, INDEXACAO E PROCEDIMENTOS DA NOVA EMPRESA _______

   i_inic_var_inst()    // inicializa as variaves do arquivo qinst.dbf
   i_index_seletivo()   // indexacao seletiva somente dos arquivos da empresa
   new_emp()            // procedimentos personalizados para a nova empresa

   select QINST

   qmensa("INSTALA€ŽO DA BASE DE DADOS COMPLETA !","B")
   qwait()
   qrbloc(07,12,sBLOC)

return .T.

/////////////////////////////////////////////////////////////////////////////
// INDEX SELETIVO QUANDO DA CRIACAO DA BASE DE DADOS ________________________

static function i_index_seletivo
   local sBLOC := qsbloc(05,00,23,79)
   local nREC  := QINST->(recno())
   QINST->(dbclosearea())
   keyboard (chr(K_CTRL_K) + chr(K_ENTER))
   q901(.F.,XSISTEMA)
   quse(XDRV_SH,"QINST",{"QINST1","QINST2"})
   QINST->(dbgoto(nREC))
   qrbloc(05,00,sBLOC)
return

// SELECIONA AUTOMATICAMENTE PARA USO DO INDEX TOTAL ________________________

function qseldirect ( cPARM1 )
   local nCONT, cMACRO

   quse(XDRV_SH,"QINST",{"QINST2"},"R")
   QINST->(dbseek(cPARM1))

   for nCONT := 1 to QINST->(fcount())
       cMACRO := "X"+QINST->(fieldname(nCONT))
       public &cMACRO := alltrim(&(QINST->(fieldname(nCONT))))
   next

   QINST->(dbclosearea())

   XDRV_SY := &("XDRV_"+left(XSIGLA,2))

return .T.

/////////////////////////////////////////////////////////////////////////////
// MARCA AS EMPRESAS PARA IMPRESSOES E PROCESSAMENTOS MULTIPLOS _____________

function qmarcaemp

   local nCONT
   local aSELEC := {}
   private aEMP := {}
   private lTOT := .F.

   if alert("Esta op‡„o permite sele‡„o;autom tica de empresas !;",;
      {"Somente Atual","Realizar Sele‡„o"}) == 1 .or. lastkey() == K_ESC
      return aSELEC
   endif

   if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R") ; return aSELEC ; endif
   set filter to left(XSIGLA,2)+"." $ Sistemas
   QINST->(dbsetorder(2))
   QINST->(dbgotop())

   qmensa("Aguarde, lendo empresas instaladas...")

   do while ! QINST->(eof())
      aadd(aEMP,QINST->Razao)
      QINST->(dbskip())
   enddo

   QINST->(dbgotop())
   QINST->(qview({{"Razao/Selecione as Empresas desejadas...",2},;
                  {"Empresa/Cod."      ,1},;
                  {"Seq/Seq."          ,0},;
                  {"i_tem255()/SN?"    ,0}},"CF",;
                  {"EXIT","i_marc_sn",NIL,NIL},;
                  {"!deleted()",{||dbgotop()},{||dbgobottom()}},;
                  "<ESC> / ALT-O / ALT-P / <ENTER> / <ESPA€O> / <TAB>"))

   qmensa("Aguarde, verificando sele‡„o...")

   for nCONT := 1 to len(aEMP)
       qgirabarra()
       if chr(255) $ aEMP[nCONT]
          aadd(aSELEC,aEMP[nCONT])
       endif
   next

   QINST->(dbclosearea())

   qmensa()

return aSELEC

/////////////////////////////////////////////////////////////////////////////
// RETORNA SIM OU NAO PARA EMPRESAS MARCADAS ________________________________

function i_tem255
   local nPOINTER
   if ( nPOINTER := ascan(aEMP,QINST->Razao) ) <> 0
      return iif(chr(255)$aEMP[nPOINTER],"SIM","   ")
   endif
return "   "

/////////////////////////////////////////////////////////////////////////////
// MARCA/DESMARCA EMPRESAS __________________________________________________

function i_marc_sn ( nTECLA )

   local nCONT

   qmensa("Aguarde...")

   if nTECLA == K_TAB
      if lTOT
         lTOT := .F.
         for nCONT := 1 to len(aEMP)
             qgirabarra()
             aEMP[nCONT] := strtran(aEMP[nCONT],chr(255),"")
         next
      else
         lTOT := .T.
         for nCONT := 1 to len(aEMP)
             qgirabarra()
             if ! chr(255) $ aEMP[nCONT]
                aEMP[nCONT] += chr(255)
             endif
         next
      endif
   endif

   if nTECLA == K_SPACE
      lTOT := .F.
      if ( nCONT := ascan(aEMP,QINST->Razao) ) <> 0
         if chr(255) $ aEMP[nCONT]
            aEMP[nCONT] := strtran(aEMP[nCONT],chr(255),"")
         else
            aEMP[nCONT] += chr(255)
         endif
      endif
   endif

return

