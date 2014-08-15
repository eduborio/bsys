function main

#include "directry.ch"
#include "dbstruct.ch"


local aDir    := {}
local aStruct := {}
local nCONT := 1
local zCONT := 1
local cFILE := ""
local rbfileName := ""
private XCOR_MENSA := "W/G"

//set auto_open off


clear

   aDir := Directory("*.dbf")

   rbFileName := "c:\users\admin\desktop\"+dtos(date())+left(time(),2)+substr(time(),4,2)+right(time(),2) +"_"+"createdataBase.rb"

   set printer to (rbfileName)
   set device to printer
   set margin to 0
   setprc(0,0)

   @ prow(),pcol() say "class CreateDatabase < ActiveRecord::Migration"
   @ prow()+1,03   say "def self.up"

   do while nCONT <=  len(aDir)


      clear
      cFILE := upper(alltrim(aDir[nCONT,F_NAME]))

      cFILE := left(cFILE,len(cFILE)-4)

      if ! quse(XDRV_CLX,cFILE,{""},NIL,"CURFILE")
         qmensa("file no open !")
         return .F.
      endif

      aStruct :=  CURFILE->(dbstruct())

      genMigrationClass(cFILE,aStruct)

      CURFILE->(dbclosearea())

      nCONT ++


      if nCONT > len(aDIR)
         nCONT := len(aDIR)
         exit
      endif


   enddo

   @ prow()+1,03 say "end"
   @ prow()+1,03 say "def self.down"
   @ prow()+1,03 say "end"
   @ prow()+1,00 say "end"


   set printer to
   set device to screen

return






