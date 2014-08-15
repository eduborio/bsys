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
   cTROCADO := strtran(cTROCADO,"Ä","C")
   cTROCADO := strtran(cTROCADO,"á","c")
   cTROCADO := strtran(cTROCADO,"ß",".")
   cTROCADO := strtran(cTROCADO,"¶","a")
   cTROCADO := strtran(cTROCADO,"Ç","e")
   cTROCADO := strtran(cTROCADO,"É","a")
   cTROCADO := strtran(cTROCADO,"Ñ","a")
   cTROCADO := strtran(cTROCADO,"Ö","a")
   cTROCADO := strtran(cTROCADO,"Ü","a")
   cTROCADO := strtran(cTROCADO,"à","e")
   cTROCADO := strtran(cTROCADO,"â","e")
   cTROCADO := strtran(cTROCADO,"ä","e")
   cTROCADO := strtran(cTROCADO,"ã","i")
   cTROCADO := strtran(cTROCADO,"å","i")
   cTROCADO := strtran(cTROCADO,"ç","i")
   cTROCADO := strtran(cTROCADO,"ì","o")
   cTROCADO := strtran(cTROCADO,"é","A")
   cTROCADO := strtran(cTROCADO,"è","A")
   cTROCADO := strtran(cTROCADO,"ê","E")
   cTROCADO := strtran(cTROCADO,"ì","o")
   cTROCADO := strtran(cTROCADO,"î","o")
   cTROCADO := strtran(cTROCADO,"ï","o")
   cTROCADO := strtran(cTROCADO,"ñ","u")
   cTROCADO := strtran(cTROCADO,"ó","u")
   cTROCADO := strtran(cTROCADO,"ô","o")
   cTROCADO := strtran(cTROCADO,"ö","U")
   cTROCADO := strtran(cTROCADO,"†","a")
   cTROCADO := strtran(cTROCADO,"°","i")
   cTROCADO := strtran(cTROCADO,"¢","o")
   cTROCADO := strtran(cTROCADO,"£","u")
   cTROCADO := strtran(cTROCADO,"§","n")
   cTROCADO := strtran(cTROCADO,"&","e")
   cTROCADO := strtran(cTROCADO,"-"," ")
   cTROCADO := strtran(cTROCADO,"="," ")
   cTROCADO := strtran(cTROCADO,"_"," ")
   cTROCADO := strtran(cTROCADO,"¯",".")

return(cTROCADO)

