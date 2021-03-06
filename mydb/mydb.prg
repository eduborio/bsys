function main(server)
   public oServer, oRow
   public oQuery
   public ncont
   public cQuery := ""
   private XCOR_MENSA := "N/G"
   
    
	//if query == NIL
	//	OUTSTD("Nenhum parametro informado")
	//	return
	//endif   
	
	//public where := filtro
    //public macro := funcao + "(where)"
	
	REQUEST DBFCDX
    RDDSETDEFAULT("DBFCDX")
    DBSETDRIVER("DBFCDX")
	
	set scor off
    set bell off
    set safe off
    set dele on
    set inte on
    set date brit
    set conf on
    set excl off
	
	clear 

	oServer := TMySQLServer():New(server, "root", "borios")
   
   if oServer:NetErr()
      Alert(oServer:Error())
   else  
	  oServer:SelectDB("comercial")
	  
	  cQuery := "SELECT * from clientes as cli order by id desc limit 1" 
	  oQuery := oServer:Query(cQuery)
   
	   if oQuery:NetErr()
		  Alert(oQuery:Error())
	   endif
	   
	   nCont := 1
	   
	   do while nCont <= oQuery:LastRec() 	 
		  row := oQuery:getRow(nCont)
		  //@ prow()+1,00 say get(row,'id')
		  //@ prow()  ,10 say get(row,'nome')
		  outstd(get(row,'nome'))

		  nCont++
	   enddo 	  
	  
	  
   endif

   
	
	//OUTSTD(&(macro))
	
	//if error()
	//   OUTSTD("Erro OPA")
    //endif	
    
	//@ saprow()+1,00 say getReceberPorId(filtro)
    //@ prow()+2,00 say &(macro)
	
	//outstd(" On "+server)

return

function get(row,campo)
return  row:fieldget(campo)	  

function getReceberPorId(filtro)
return "{id: '25',nome:'Eduaro Borio',filtro:'"+filtro+"'}"

function getDuds(filtro)
return "Eduardo Borio Here, filtrado por: " +filtro

function getReceber(id)

  json := "receberList:["  

  cCli := strzero(val(id),5)
  
  if ! quse("\QSYS_G\QRB\E004\","RECEBER")
	 outstd("{erro:Error ao conectar ao sistema Cntas a Receber - Receber!}")
     return 
  endif	
   
  RECEBER->(dbsetorder(5))
  
  if RECEBER->(dbseek(cCli))

	  do while ! RECEBER->(eof()) .and. RECEBER->cod_cli == cCli

		 //if RECEBER->Data_venc < date()
			//nTotalVencido += RECEBER->Valor_liq
		 //endif
		 
		 json += "{nome:"+left(RECEBER->Cliente,20)+",valor:"+alltrim(transform(RECEBER->Valor_liq,"@R 99999999.99"))+",Vencimento:"+ dtoc(RECEBER->Data_venc)+"},"

		 RECEBER->(dbskip())

	  enddo
	  
  endif	  
  
  json += "]"

  RECEBER->(dbCloseArea())
   
return json

function getReceberVencido(id)

  json := "receberList:["  

  cCli := strzero(val(id),5)
  
  if ! quse("\QSYS_G\QRB\E004\","RECEBER")
	 outstd("{erro:Error ao conectar ao sistema Cntas a Receber - Receber!}")
     return 
  endif	
   
  RECEBER->(dbsetorder(5))
  
  if RECEBER->(dbseek(cCli))

	  do while ! RECEBER->(eof()) .and. RECEBER->cod_cli == cCli

		 if RECEBER->Data_venc < date()
			//nTotalVencido += RECEBER->Valor_liq
			json += "{nome:"+left(RECEBER->Cliente,20)+",valor:"+alltrim(transform(RECEBER->Valor_liq,"@R 99999999.99"))+",Vencimento:"+ dtoc(RECEBER->Data_venc)+"},"
		 endif

		 RECEBER->(dbskip())

	  enddo
	  
  endif	  
  
  json += "]"

  RECEBER->(dbCloseArea())
   
return json


function getDevolucoes(cCli)

	cCli := strzero(val(id),5)
	
	json := ""
  
    if ! quse("\QSYS_G\QCT\E004\","LANC")
	  outstd("{erro:Error ao conectar ao sistema contabil - Lanc!}")
	  return 
    endif	
	
	if ! quse("\QSYS_G\QCT\E004\","PLAN")
	   outstd("{erro:Error ao conectar ao sistema contabil - Plan!}")
	  return "Erro ao abrir"
    endif	
	
	LANC->(dbsetorder(1))
	PLAN->(dbseek(dbsetorder(1)))
	
	if PLAN->(dbseek("2010502"))
	    LANC->(dbsetorder(1))
		LANC->(dbgotop())
	    
		do while ! PLAN->(eof()) .and. left(PLAN->Codigo,7) == "02010502" // Todas Devolucoes
		
		    if LANC->(dbseek(PLAN->Reduzido))
			   do while ! LANC->(eof()) .and. LANC->Cont_cr == PLAN->Reduzido
			      json+="{"+PLAN->Descricao + transform(LANC->Valor,"@R 9999999.99")+"}"
			      LANC->(dbskip())
			   enddo
			   
      		   json += transform(LANC->Valor,"@ 99999999.99")
			endif	
				
			PLAN->(dbskip())
		enddo	
    endif
	
	LANC->(dbcloseArea())
	PLAN->(dbcloseArea())
return json

procedure ErrorSys()

   errorblock ( { |e| berror(e) } )

return

static function berror( e )
	OUTSTD(e:description," ",e:operation)	
return .F.

