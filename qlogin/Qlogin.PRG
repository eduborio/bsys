function main()
private nFile  := 0
private cCaminho := "C:\QSYS\QLOGIN\"
private dIni := ctod("01/01/2013")
private nQuant := 0
private cProg := ""

REQUEST DBFCDX
RDDSETDEFAULT("DBFCDX")
DBSETDRIVER("DBFCDX")

set deleted ON

clear
private cReport := ""

   
   
   quse("Z:\QSYS_G\QTS\","QPROGS",{})

   quse(cCaminho,"QLOGIN")
   select Qlogin
   index on prog tag UM
   dbsetindex("qlogin")
   
   qlogin->(dbsetfilter({|| datalog >= dIni }))

   qlogin->(dbgotop())
   
   cPROG := qlogin->Prog
   
   nQuant := 0
  
   do while ! Qlogin->(eof())
      nQuant++
	  
	     
      qlogin->(dbskip())
	  if alltrim(qlogin->prog) != alltrim(cProg)
	      qprogs->(dbseek(cPROG)) 
	      cReport += cProg +chr(9) + transf(nQuant,"@R 999999999") + chr(9)+ i_trocachr(qprogs->descricao)  +chr(13) + chr(10)
	      cProg := qlogin->Prog
		  nQuant := 0
	  endif
	  
   enddo
   
   nFile := fcreate("qlogin.xls",0)
   fwrite(nfile,cReport,len(cReport))
   fclose(nfile)
   qsay(0,0,"done.")

return

static function i_trocachr(cTROCADO)

   cTROCADO := strtran(cTROCADO,"'"," ")
   cTROCADO := strtran(cTROCADO,"�","C")
   cTROCADO := strtran(cTROCADO,"�","c")
   cTROCADO := strtran(cTROCADO,"�",".")
   cTROCADO := strtran(cTROCADO,"�","a")
   cTROCADO := strtran(cTROCADO,"�","e")
   cTROCADO := strtran(cTROCADO,"�","a")
   cTROCADO := strtran(cTROCADO,"�","a")
   cTROCADO := strtran(cTROCADO,"�","a")
   cTROCADO := strtran(cTROCADO,"�","a")
   cTROCADO := strtran(cTROCADO,"�","e")
   cTROCADO := strtran(cTROCADO,"�","e")
   cTROCADO := strtran(cTROCADO,"�","e")
   cTROCADO := strtran(cTROCADO,"�","i")
   cTROCADO := strtran(cTROCADO,"�","i")
   cTROCADO := strtran(cTROCADO,"�","i")
   cTROCADO := strtran(cTROCADO,"�","o")
   cTROCADO := strtran(cTROCADO,"�","A")
   cTROCADO := strtran(cTROCADO,"�","A")
   cTROCADO := strtran(cTROCADO,"�","E")
   cTROCADO := strtran(cTROCADO,"�","o")
   cTROCADO := strtran(cTROCADO,"�","o")
   cTROCADO := strtran(cTROCADO,"�","o")
   cTROCADO := strtran(cTROCADO,"�","u")
   cTROCADO := strtran(cTROCADO,"�","u")
   cTROCADO := strtran(cTROCADO,"�","o")
   cTROCADO := strtran(cTROCADO,"�","U")
   cTROCADO := strtran(cTROCADO,"�","a")
   cTROCADO := strtran(cTROCADO,"�","i")
   cTROCADO := strtran(cTROCADO,"�","o")
   cTROCADO := strtran(cTROCADO,"�","u")
   cTROCADO := strtran(cTROCADO,"�","n")
   cTROCADO := strtran(cTROCADO,"&","e")
   cTROCADO := strtran(cTROCADO,"-"," ")
   cTROCADO := strtran(cTROCADO,"="," ")
   cTROCADO := strtran(cTROCADO,"_"," ")
   cTROCADO := strtran(cTROCADO,"�",".")

return(cTROCADO)

