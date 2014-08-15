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
private XDRV_CLX    := "C:\QSYS_G\QFA_CL\E001\"

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

static function genMigrationClass(cFILE,aStruct)
local nCONT     := 1
local cCLIPTYPE := ""

  @ prow()+1,5 say "create_table :"+lower(cFILE)+ " do |t|"

  //alert(str(len(astruct)))

  for nCONT := 1 to len(aStruct)
      cCLIPTYPE := aStruct [nCONT] [DBS_TYPE]
      cCLIPTYPE := alltrim(cCLIPTYPE)

      //alert(cCLIPTYPE)

      do case
         case cCLIPTYPE == "C"
              @ prow()+1, 07 say "t.string  :"+padr(lower(alltrim(aStruct[nCONT,DBS_NAME])),10)+", :limit => "+str(aStruct[nCONT,DBS_LEN],3)

         case cCLIPTYPE == "N"
              @ prow()+1, 07 say "t.decimal :"+padr(lower(alltrim(aStruct[nCONT,DBS_NAME])),10)+", :precision => "+str(aStruct[nCONT,DBS_LEN],2)+", :scale => "+ str(astruct[nCONT,DBS_DEC],2)+", :default => 0"

         case cCLIPTYPE == "D"
              @ prow()+1, 07 say "t.date    :"+padr(lower(alltrim(aStruct[nCONT,DBS_NAME])),10)

         case cCLIPTYPE == "L"
              @ prow()+1, 07 say "t.boolean :"+padr(lower(alltrim(aStruct[nCONT,DBS_NAME])),10)

      endcase

  next

  @ prow()+1,5 say "end"
  @ prow()+1,00 say ""





return




