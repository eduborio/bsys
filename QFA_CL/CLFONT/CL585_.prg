//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2013
// OBS........:
// ALTERACOES.:

function cl585
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cCLI := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aDados := {}
private aFat   := {}
private cTipo := ""
private sBloco1 := qlbloc("B585B","QBLOC.GLO")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_cli2(-1,0,@cCLI)        } , "CLI"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTipo,sBloco1)   } , "TIPO" })

do while .T.

   qlbloc(5,0,"B585A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cTIPO := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   keyboard chr(27)

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FIM"
                   if dFIM < dINI
             return .F.
           endif

      case cCAMPO == "CLI"

           qrsay(XNIVEL,cCLI)
		   CLI1->(dbsetorder(1))

           if empty(cCLI)
              qrsay(XNIVEL+1, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cCLI:=strzero(val(cCLI),5)))
                 qmensa("Cliente nao Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CLI1->Razao,30))
              endif
           endif
		   
	 case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO,"DB",{"Devolucoes","Brindes"}))
     endcase


return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "Listagem de " + qabrev(cTipo,"DB",{"devolucoes","brindes"}) +" por cliente de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
   
   PROD->(dbsetorder(4))

return .T.


static function i_impressao

   i_get_dados()
   FAT->(dbgotop())
   alert("Arquivo gerado na pasta C:\Qsystxt  !")

return

static function i_get_dados

   aDados := {}

   do while ! FAT->(eof())
   
      if FAT->Cancelado 
	     FAT->(dbskip())
		 loop
	  endif
	  
	  if cTipo == "D"
	     if FAT->Es != "E"
	        FAT->(dbskip())
			loop
		 endif
		 
		 if ! left(FAT->cod_cfop,4) $ "1202-2202"
		    FAT->(dbskip())
			loop
		 endif	
	  
	  endif
	  
	  if cTipo == "B"
		 
		 if ! left(FAT->cod_cfop,4) $ "5910-6910"
		    FAT->(dbskip())
			loop
		 endif	
	  
	  endif
      
      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
         aadd(aDados,{FAT->Codigo,FAT->Cod_cli,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,ITEN_FAT->ipi})
         ITEN_FAT->(Dbskip())
      enddo
      FAT->(dbskip())

   enddo
   
   agrupaPorClienteEProduto()

   gera_arquivo()

return

static function agrupaPorClienteEProduto
local cProduto,cCliente := ""
local nTotal := 0
local nQtde  := 0
   PROD->(dbsetorder(4))

   aDados := aSort(aDados,,,{|x,y| x[2] + x[3]   < y[2] + y[3] })
   aFat := {}
   
   cCliente := aDados[1,2]
   cProduto := aDados[1,3]
     
   nCONT := 1
   do while  nCONT <= len(aDados)
   
      nQtde  += aDados[nCont,4]
	  nTotal += (  (aDados[nCont,4] * aDados[nCont,5]) + calcIpi(aDados[nCont])  )

      nCONT++
      if nCONT > len(aDados)
         nCONT := len(aDados)
         exit
      endif
	  
	  if aDados[nCont,2] + aDados[nCont,3] != cCliente + cProduto
	     
	     PROD->(dbseek(cProduto))
		 CLI1->(dbseek(cCliente))
	     aadd(aFat,{cCliente,cProduto,nQtde,nTotal,PROD->Cod_ass,left(CLI1->Razao,40)})
         cProduto := aDados[nCont,3]
         nQtde := 0
         nTotal := 0		 
	  endif
	  
	  if aDados[nCont,2] != cCliente
	     cCliente := aDados[nCont,2]  
	  endif
	  
   enddo	  
   
   if nQtde > 0
      PROD->(dbseek(cProduto))
	  CLI1->(dbseek(cCliente))
      aadd(aFat,{cCliente,cProduto,nQtde,nTotal,PROD->Cod_ass,left(CLI1->Razao,40)})
      cProduto := ""
      nQtde := 0
      nTotal := 0
   endif	  

return

static function calcIpi(aRow)
local ipi := 0
  ipi := (aRow[4] * aRow[5]) * (aRow[6] / 100)
return ipi



static function gera_arquivo

local nCONT := 1
local cBuffer := ""
local nFile := 0
local cFileName := ""
local cCliente  := ""
local nQtdeCli  := 0
local nValorCli := 0
local nQtdeTot  := 0
local nValorTot := 0

   cFileName := "Rel 585 - "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+" - " + qabrev(cTipo,"DB",{"Devolucoes","Brindes"}) + ".xls"

   aFat := aSort(aFat,,,{|x,y| x[6] + x[5] < y[6] + y[5] })

   cCliente := aFat[1,1]

   cBuffer := cTitulo+" 585"
   cBuffer += chr(13)+chr(10)

   cBuffer += "Cliente" + chr(9)+ "Ref" +chr(9)+ "Descricao" + chr(9) + "Quantidade" + Chr(9)+ "Valor Total(com Ipi)"
   cBuffer += Chr(9)+Chr(9)+""+chr(13)+chr(10)

   nCONT := 1
   do while  nCONT <= len(aFat)
   
      cBuffer += aFat[nCont,6]
      cBuffer += chr(9) + aFat[nCont,5]
	  PROD->(dbseek(aFat[nCont,2]))
	  cBuffer += chr(9) + PROD->Descricao
	  cBuffer += chr(9) + transform(aFat[nCont,3],"@R 999999999")
	  cBuffer += chr(9) + transform(aFat[nCont,4],"@E 999,999,999.99") + chr(13) + chr(10)
	  
	  nQtdeCli  += aFat[nCont,3]
	  nValorCli += aFat[nCont,4]
	  
	  nQtdeTot  += aFat[nCont,3]
	  nValorTot += aFat[nCont,4]
	  
      nCONT++
      if nCONT > len(aFat)
         nCONT := len(aFat)
         exit
      endif

      if aFat[nCont,1] != cCliente
         cBuffer += "Total"
		 cBuffer += chr(9) + ""
		 cBuffer += chr(9) + ""
		 cBuffer += chr(9) + transform(nQtdeCli,"@R 999999999")
		 cBuffer += chr(9) + transform(nValorCli,"@E 999,999,999.99") + chr(13) + chr(10)
		 cBUffer += chr(13) + chr(10)
		 
		 nQtdeCli := 0
		 nValorCli := 0
		 		 
         cCliente := aFat[nCont,1]
      endif
	  
   enddo
   
     if nQtdeCli > 0
         cBuffer += "Total"
		 cBuffer += chr(9) + ""
		 cBuffer += chr(9) + ""
		 cBuffer += chr(9) + transform(nQtdeCli,"@R 999999999")
		 cBuffer += chr(9) + transform(nValorCli,"@E 999,999,999.99") + chr(13) + chr(10)
		 cBUffer += chr(13) + chr(10)
		 
		 nQtdeCli := 0
		 nValorCli := 0
		 		 
      endif
	  
      if nQtdeTot > 0
		cBuffer += "Total Geral"
		cBuffer += chr(9) + ""
		cBuffer += chr(9) + ""
		cBuffer += chr(9) + transform(nQtdeTot,"@R 999999999")
		cBuffer += chr(9) + transform(nValorTot,"@E 999,999,999.99") + chr(13) + chr(10)
		cBUffer += chr(13) + chr(10)
	  endif	
	 
	  nQtdeCli := 0
	  nQtdeTot := 0
	  nValorCli := 0
	  nValorTot := 0
         

   nFile := fcreate("C:\qsystxt\"+cFileName,0)

   fWrite(nfile,cBuffer,len(cBuffer))

   fclose(nfile)
   aFat:={}
   aDados:={}

return
