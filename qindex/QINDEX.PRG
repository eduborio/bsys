function main()
clear
private cPrincipal := space(10)
private aSistemas  := {}
private aDrive     := {}
private aCaminho   := {}
private nCONT      := 1
private nIndexOf   := 0
private cCam       := ""
private kCaminho   := ""
private cMACRO1 := ""
private cMACRO2 := ""

aadd(aSistemas,"QFA_CL")
aadd(aSistemas,"QCP")
aadd(aSistemas,"QES")
aadd(aSistemas,"QPG")
aadd(aSistemas,"QRB")
aadd(aSistemas,"QTS")
aadd(aSistemas,"QCT")
aadd(aSistemas,"QEF")

aadd(aDrive,"XDRV_CL")
aadd(aDrive,"XDRV_CP")
aadd(aDrive,"XDRV_ES")
aadd(aDrive,"XDRV_PG")
aadd(aDrive,"XDRV_RB")
aadd(aDrive,"XDRV_TS")
aadd(aDrive,"XDRV_CT")
aadd(aDrive,"XDRV_EF")

aadd(aCaminho,"\QSYS_G\QFA_CL\")
aadd(aCaminho,"\Qsys_G\Qcp\")
aadd(aCaminho,"\QSYS_G\QES\")
aadd(aCaminho,"\Qsys_G\Qpg\")
aadd(aCaminho,"\Qsys_G\Qrb\")
aadd(aCaminho,"\Qsys_G\Qts\")
aadd(aCaminho,"\Qsys_G\Qct\")
aadd(aCaminho,"\Qsys_G\Qef\")


qsay (10,0,"Sistema Principal.: " )
qgetx(10,22,@cPrincipal)

nIndexOf := aScan(aSistemas,alltrim(cPrincipal))

   cCAM := aCaminho[nIndexOf]

   if file(cCAM  + "QINDEX.TMP")
      erase(cCAM + "QINDEX.TMP")
   endif

   use (cCAM + "QINDEX") alias "QINDEX" SHARED
   select QINDEX
   index on (ARQUIVO) to (cCAM +"QINDEX.TMP")
   dbsetindex(cCAM + "QINDEX.TMP")


QINDEX->(dbsetfilter({|| alltrim(left(caminho,7)) == aDrive[nIndexOf]}))
QINDEX->(dbsetorder(1))
QINDEX->(dbgotop())

nCONT := 1

for nCONT := 1 to len(aSistemas)

   if Alltrim(cPrincipal) == aSistemas[nCONT]
      nCONT++
   endif

   cFile := aSistemas[nCONT]
   kCaminho := aCaminho[nCONT]
   cFile := alltrim(cFile)
   clear

   quse(kCaminho,"QINDEX",,,"EDU")
   select EDU
   EDU->(dbsetfilter({|| alltrim(left(caminho,7)) == aDrive[nIndexOf]}))
   EDU->(dbgotop())


   do while ! EDU->(Eof())


      qsay(10,10,Edu->Caminho + "     "+Edu->Arquivo+"  "+cFILE)

      if QINDEX->(dbseek(Edu->Arquivo))
         qsay(11,10,QINDEX->Caminho + "     "+Qindex->Arquivo+"  "+cPrincipal)
      endif

      for zCONT := 1 to 12
          cMACRO1 := "KEY_" + strzero(zCONT,2)
          cMACRO2 := "NTX_" + strzero(zCONT,2)

          if QINDEX->&cMACRO1 != EDU->&cMACRO1
               qsay(12,10,   alltrim(EDU->(&cMACRO1))  + "     "+   cMACRO1  +"  ")
               qsay(13,10, alltrim(QINDEX->(&cMACRO1)) + "     "+   cMACRO1  +"  ")
               qsay(14,10,"Key nao confere")
               replace EDU->&cMacro1 with QINDEX->&cMacro1
               replace EDU->&cMacro2 with QINDEX->&cMacro2
               qinkey(0)
          endif

          if alltrim(QINDEX->(&cMACRO2)) != alltrim(EDU->(&cMACRO2))
               qsay(16,10,   alltrim(EDU->(&cMACRO2)) + "     "+   cMACRO2)
               qsay(17,10,alltrim(QINDEX->(&cMACRO2)) + "     "+   cMACRO2)
               qsay(18,10,"Tag nao confere")
               replace EDU->&cMacro2 with QINDEX->&cMacro2
               qinkey(0)
          endif

      next
      clear



      EDU->(dbskip())
   enddo

   EDU->(dbclosearea())

next

QINDEX->(dbclosearea())

return

//qinkey()

