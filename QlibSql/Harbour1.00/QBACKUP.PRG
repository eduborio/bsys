/////////////////////////////////////////////////////////////////////////////
// ROTINA PRINCIPAL DE BACKUP/RESTORE _______________________________________
// LUIS ANTONIO - ABRIL DE 1995

function qbackup
#include "inkey.ch"

local sBLOCX := qsbloc(09,11,23,70)
local sBLOC1 := qlbloc("QBACKUP1",XDRV_SH+"QSBLOC.GLO")
local sBLOC2 := qlbloc("QBACKUP2",XDRV_SH+"QSBLOC.GLO")
local sTELA, cEMPR, cTIPO, nSPACE := 0

private cARQARC, cMASCARA, cDRIVE, cFILEREST

// SELECAO DE TIPO E DRIVE __________________________________________________

do while .T.
   qmensa("Escolha Backup ou Restore ou <ESC> p/ cancelar...")

   qlbloc(09,11,"QBACKUP",XDRV_SH+"QSBLOC.GLO",1)

   // ESCOLHE SE "BACKUP" OU "RESTORE" ______________________________________

   cTIPO := "B"
   qesco(13,45,@cTIPO,sBLOC1,1)
   if lastkey() == K_ESC ; exit ; endif

   qsay(13,45,qabrev(cTIPO,"BR",{"Backup","Restore"}))

   // ESCOLHE DRIVE E VERIFICA ESPACO _______________________________________

   do while .T.
      qmensa("Coloque o disco no drive desejado...")
      cDRIVE := "A"
      qesco(14,45,@cDRIVE,sBLOC2,1)
      if lastkey() == K_ESC ; return ; endif
      qsay(14,45,qabrev(cDRIVE,"AB",{"Drive A:","Drive B:"}))
      qmensa("Aguarde, verificando disquete...")
      if ! qdrive(iif(cDRIVE=="A",0,1))
         qmensa("Disquete com erro ou ausente ! Verifique...","B")
      else
         if cTIPO == "B"
            nSPACE := diskspace(iif(cDRIVE=="A",1,2))
            qsay(15,45,nSPACE,"@E 999,999,999")
            if nSPACE < 1000
               qmensa("Disco cheio ! Troque por outro disco...","B")
            else
               exit
            endif
         else
            cFILEREST := cDRIVE+":\"+left(XSIGLA,2)+XEMPRESA+".ARC"
            qsay(15,14,"Restore do arquivo...........:")
            qsay(15,45,cFILEREST+"      ")
            if ! file(cFILEREST)
               qmensa("Arquivo n„o se encontra neste disco !","B")
            else
               exit
            endif
         endif
      endif
   enddo

   // PREPARA VARIAVEL E ACIONA ROTINA ESPECIFICA ___________________________

   cARQARC  := ".\E" + XEMPRESA + "\" + left(XSIGLA,2) + XEMPRESA + ".ARC"
   cMASCARA := ".\E" + XEMPRESA + "\*.DB?"
   cDRIVE   += ":\"

   sTELA := qsbloc(0,0,24,79)

   iif(cTIPO=="B",i_backup(),i_restore())

   qrbloc(0,0,sTELA)

enddo

qrbloc(09,11,sBLOCX)

return

/////////////////////////////////////////////////////////////////////////////
// ROTINA DE BACKUP _________________________________________________________

static function i_backup
   if ! qconf("Confirma BACKUP dos arquivos desta empresa ?")
      return .F.
   endif
   clear screen
   ? "EXCLUINDO ARQUIVO DE BACKUP ANTERIOR..."
   ?
   run del &cARQARC.
   ?
   ? "COMPACTANDO ARQUIVOS DA EMPRESA " + XEMPRESA + "..."
   ?
   run pkzip &cARQARC. &cMASCARA. -ex
   ?
   ? "COPIANDO ARQUIVO PARA O DRIVE " + cDRIVE + "..."
   ?
   run copy &cARQARC. &cDRIVE.
   ?
   run dir &cDRIVE. /O:D
   ?
   ? "<qualquer tecla p/ retornar>..."
   qinkey(0)
   keyboard chr(27) + chr(27)
return .T.

/////////////////////////////////////////////////////////////////////////////
// ROTINA DE RESTORE ________________________________________________________

static function i_restore
   if ! qconf("Confirma RESTORE dos arquivos desta empresa ?")
      return .F.
   endif
   if ! qconf("OS ARQUIVOS ATUAIS SERAO PERDIDOS ! Reconfirma ?")
      return .F.
   endif
   clear screen
   ? "DESCOMPACTANDO ARQUIVOS DO BACKUP..."
   ?
   cMASCARA := strtran(cMASCARA,"\*.DB?","")
   run pkunzip -o &cFILEREST. &cMASCARA.
   ?
   ? "ARQUIVOS DESCOMPACTADOS !"
   ? ">>>> DEVE-SE OBRIGATORIAMENTE INDEXAR ESTA EMPRESA !!!"
   ?
   ? "<qualquer tecla p/ retornar>..."
   qinkey(0)
   keyboard chr(27) + chr(27)
return .T.

