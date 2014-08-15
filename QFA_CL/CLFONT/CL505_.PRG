//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl505

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cDesigner := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aFAT := {}
private aDesigner := {}
private aImpressao := {}
private sBLOC1  := qlbloc("B505B","QBLOC.GLO")
private cTIPO := ""

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_designer(-1,0,@cDesigner)     } , "DESIGNER"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTipo,sBLOC1  )  } , "TIPO"  })

do while .T.

   qlbloc(5,0,"B505A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cTIPO := "C"

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

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

      case cCAMPO == "DESIGNER"

           qrsay(XNIVEL,cDESIGNER)

           if empty(cDESIGNER)
              qrsay(XNIVEL+1, "Todos os Setores.......")
           else
              if ! DESIGNER->(Dbseek(cDESIGNER:=strzero(val(cDESIGNER),5)))
                 qmensa("DESIGNER n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(DESIGNER->Descricao,30))
              endif
           endif
		   
	  case cCAMPO == "TIPO"

           if empty(cTipo) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"CP",{"Colecao","Produto"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "FATURAMENTO POR DESIGNER" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.


static function i_impressao

   getDados()

   if ! qinitprn() ; return ; endif

   if XLOCALIMP ==  "A"
      alert("Relatorio disponivel somente em excell !")
   endif

   if XLOCALIMP == "X"
      if cTIPO == "C"
	     totalizaPorColecao()
         i_impre_xls_Colecao()
	  endif	 
	  
	  if cTIPO == "P"
		 totalizaPorProduto()
         i_impre_xls_peca()
	  endif	
		 
   endif



return


static function getDados


   aFat := {}
   PROD->(dbsetorder(4))

   do while ! FAT->(eof())

      CLI1->(dbseek(FAT->Cod_cli))

      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(Dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220-540-541-640-641-530-531-630-631"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      if FAT->Dt_emissao < dINI .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
         PROD->(dbseek(ITEN_FAT->Cod_prod))
         if ! empty(PROD->Designer)
		    if FAT->Es == "S"
               aadd(aFAT,{PROD->Designer,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,0,ITEN_FAT->vl_unitar,PROD->Marca,ITEN_FAT->Preco_vend})
			else
			    aadd(aFAT,{PROD->Designer,ITEN_FAT->Cod_prod,0,ITEN_FAT->Quantidade,ITEN_FAT->vl_unitar,PROD->Marca,ITEN_FAT->Preco_vend})
			endif
			   
         endif

         ITEN_FAT->(dbskip())
      enddo


      FAT->(dbskip())

  enddo

return



static function totalizaPorColecao
local cDesigner := ""
local cColecao  := ""
local nTotal     := 0

   aDesigner := {}

   asFAT := asort(aFAT,,,{|x,y| x[1]+x[6] < y[1]+y[6] })
   if len(asFAT) > 0
       cDesigner := asFAT[1,1]
       cColecao  := asFAT[1,6]

       nCONT := 1
       do while  nCONT <= len(asFAT)


          nTotal += (asFat[nCont,3] * asFat[nCont,5])
		  nTotal -= (asFat[nCont,4] * asFat[nCont,5])    //devolucoes

          nCONT++
          if nCONT > len(asFAT)
             nCONT := len(asFAT)
             exit
          endif

          if asFAT[nCONT,1] + asFAT[nCont,6] != cDesigner + cColecao
             PROD->(dbsetorder(4))		  		    
			 

             aadd(aDesigner,{cDesigner,cColecao,nTotal})
             cDesigner := asFat[nCont,1]
             cColecao  := asFat[nCont,6]
             nTotal     := 0
          endif
       enddo

       if nTotal > 0
	      PROD->(dbsetorder(4))		  		    
		 
          aadd(aDesigner,{cDesigner,cColecao,nTotal})
          cDesigner := asFat[nCont,1]
          cColecao  := asFat[nCont,6]
          nTotal    := 0
       endif


   endif

return

static function i_impre_xls_colecao
local cDesigner := ""
local nQtde     := 0
local nTotal    := 0
local nCom      := 0


   @ prow()+1, 00 say cTitulo + "    505"
   @ prow()+1, 00 say "Colecao"+chr(9)+"Total"+chr(9)+"Comissao"
   @ prow()+1, 00 say ""

   asDesigner := asort(aDesigner,,,{|x,y| x[1] + x[2] < y[1] + y[2]})
   if len(asDesigner) > 0
       cDesigner := asDesigner[1,1]

       nCONT := 1
       do while  nCONT <= len(asDesigner)
           
           @ prow()+1,00   say asDesigner[nCont,2]+chr(9)
           @ prow(),pcol() say transf(asDesigner[nCont,3],"@E 999,999,999.99")+chr(9)
           @ prow(),pcol() say transf( asDesigner[nCont,3]*0.01,"@E 999,999,999.99")

          
           nTotal += asDesigner[nCont,3]
           nCom   += ( asDesigner[nCont,3] * 0.01 )

           nCONT++
           if nCONT > len(asDesigner)
              nCONT := len(asDesigner)
              exit
           endif

           if asDesigner[nCONT,1] != cDesigner
              Designer->(dbseek(cDesigner))
              @ prow()+1,00   say "Total do Designer.: "+Designer->Nome+chr(9)
		      @ prow(),pcol() say transf(nTotal,"@E 999,999,999.99")+chr(9)
              @ prow(),pcol() say transf(nCom,"@E 999,999,999.99")

              @ prow()+1,00   say ""

              cDesigner := asDesigner[nCont,1]
              nCom   := 0
              nTotal := 0
           endif
       enddo

       if nTotal > 0
          Designer->(dbseek(cDesigner))
          @ prow()+1,00   say "Total do Designer.: "+Designer->Nome+chr(9)
          @ prow(),pcol() say transf(nTotal,"@E 999,999,999.99")+chr(9)
          @ prow(),pcol() say transf(nCom,"@E 999,999,999.99")

          @ prow()+1,00   say ""

       endif


   endif

   qstopprn(.F.)

return

static function totalizaPorProduto
local cDesigner := ""
local cProd     := ""
local nQtde     := 0
local nDevol    := 0
local nQtdeDevol  := 0
local nValorVenda := 0 
local nValorDevol := 0

   aDesigner := {}

   asFAT := asort(aFAT,,,{|x,y| x[1]+x[2] < y[1]+y[2] })
   if len(asFAT) > 0
       cDesigner := asFAT[1,1]
       cProd     := asFAT[1,2]

       nCONT := 1
       do while  nCONT <= len(asFAT)


          nQtde      += asFat[nCont,3] 
		  nQtdeDevol += asFat[nCont,4]
		  
		  nValorVenda += (asFat[nCont,3] * asFat[nCont,5])
		  nValorDevol += (asFat[nCont,4] * asFat[nCont,5])

          nCONT++
          if nCONT > len(asFAT)
             nCONT := len(asFAT)
             exit
          endif

          if asFAT[nCONT,1]+asFAT[nCont,2] != cDesigner +cProd
             PROD->(dbsetorder(4))		  		    
			 PROD->(dbseek(cPROD))

             aadd(aDesigner,{cDesigner,cProd,PROD->Cod_fabr,nQtde,nQtdeDevol,nValorVenda,nValorDevol,PROD->Marca})
             cDesigner   := asFat[nCont,1]
             cProd       := asFat[nCont,2]
             nQtde       := 0
		     nQtdeDevol  := 0
		     nValorVenda := 0 
		     nValorDevol := 0
          endif
       enddo

       if nQtde > 0
	      PROD->(dbsetorder(4))		  		    
		  PROD->(dbseek(cPROD))
		  aadd(aDesigner,{cDesigner,cProd,PROD->Cod_fabr,nQtde,nQtdeDevol,nValorVenda,nValorDevol,PROD->Marca})
          cDesigner   := asFat[nCont,1]
          cProd       := asFat[nCont,2]
          nQtde       := 0
		  nQtdeDevol  := 0
		  nValorVenda := 0 
		  nValorDevol := 0
       endif


   endif

return


static function i_impre_xls_peca
local cDesigner := ""
local nQtde     := 0
local nTotal    := 0
local nCom      := 0
local nTotalDev    := 0
local nTotalTabela := 0
local nTotalVenda  := 0
local nTotalDif    := 0


   @ prow()+1, 00 say cTitulo + "    505"
   @ prow()+1, 00 say "Descricao"+chr(9)+"Ref."+chr(9)+"Ref."+chr(9)+"Colecao"+chr(9)+"Qtde" + chr(9)+"Preço Tabela" +chr(9)+"Total"+chr(9)+chr(9)+"Qtde Vendida"+chr(9)+"Qtde Devolvida"+chr(9)+"Preço Medio na Venda"+chr(9)+"Total"+chr(9)+"Diferença"+chr(9)+chr(9)+ "Comissao Anterior"+chr(9)+"Comissao Correta" + Chr(9)+ "Diferença"
   @ prow()+1, 00 say ""

   asDesigner := asort(aDesigner,,,{|x,y| x[1] + x[8] + x[3] < y[1] + y[8] + y[3] })
   if len(asDesigner) > 0
       cDesigner := asDesigner[1,1]

       nCONT := 1
       do while  nCONT <= len(asDesigner)
           PROD->(dbseek(asDesigner[nCont,2]))

           @ prow()+1,00   say PROD->Descricao+chr(9)
           @ prow(),pcol() say PROD->Cod_ass+chr(9)
           @ prow(),pcol() say PROD->Cod_fabr+chr(9)
		   @ prow(),pcol() say PROD->Marca+chr(9)
           @ prow(),pcol() say transf(asDesigner[nCont,4],"@R 99999999")+chr(9)
           @ prow(),pcol() say transf(PROD->Preco_cons,"@E 999,999,999.99")+chr(9)
           @ prow(),pcol() say transf(asDesigner[nCont,4]*PROD->Preco_cons,"@E 999,999,999.99")+chr(9)+chr(9)
		   
		   @ prow(),pcol() say transf(asDesigner[nCont,4],"@R 999999999")+chr(9) //Vendido
		   @ prow(),pcol() say transf(asDesigner[nCont,5],"@R 999999999")+chr(9) //Devolvido 
		   
		   nPrecoMedio := (asDesigner[nCont,6]-asDesigner[nCont,7]) / ( asDesigner[nCont,4] - asDesigner[nCont,5] )
		   
		   @ prow(),pcol() say transf(nPrecoMedio,"@E 999,999,999.99")+chr(9)
		   
		   @ prow(),pcol() say transf(asDesigner[nCont,6]-asDesigner[nCont,7],"@E 999,999,999.99")+chr(9)
		   
		   nDiferenca := ( asDesigner[nCont,4]*PROD->Preco_cons) - (asDesigner[nCont,6]-asDesigner[nCont,7])
		   
		   @ prow(),pcol() say transf(nDiferenca,"@E 999,999,999.99")+chr(9)+chr(9)
		   
           @ prow(),pcol() say transf( (asDesigner[nCont,4]*PROD->Preco_cons)*0.01,"@E 999,999,999.99")+chr(9)
		   @ prow(),pcol() say transf( (asDesigner[nCont,6]-asDesigner[nCont,7])*0.01,"@E 999,999,999.99")+chr(9)
		   @ prow(),pcol() say transf( ((asDesigner[nCont,4]*PROD->Preco_cons)*0.01) - ((asDesigner[nCont,6]-asDesigner[nCont,7])*0.01),"@E 999,999,999.99")
		   

           nQtde        += asDesigner[nCont,4]
		   nTotalDev    += asDesigner[nCont,5]
           nTotalTabela += (asDesigner[nCont,4]*PROD->Preco_cons)
		   nTotalVenda  += (asDesigner[nCont,6]-asDesigner[nCont,7])
		   nTotalDif    += nDiferenca
		   
           nCom   += ( (asDesigner[nCont,4]*PROD->Preco_cons)*0.01)

           nCONT++
           if nCONT > len(asDesigner)
              nCONT := len(asDesigner)
              exit
           endif

           if asDesigner[nCONT,1] != cDesigner
              Designer->(dbseek(cDesigner))
              @ prow()+1,00   say "Total do Designer.: "+Designer->Nome+chr(9)
              @ prow(),pcol() say chr(9)+chr(9)+chr(9)
              @ prow(),pcol() say transf(nQtde,"@R 9999999999")+chr(9)
              @ prow(),pcol() say chr(9)
              @ prow(),pcol() say transf(nTotalTabela,"@E 999,999,999.99")+chr(9)+chr(9)
			  @ prow(),pcol() say transf(nQtde,"@R 9999999999")+chr(9)
			  @ prow(),pcol() say transf(nTotalDev,"@E 999,999,999.99")+chr(9)+chr(9)
			  @ prow(),pcol() say transf(nTotalVenda,"@E 999,999,999.99")+chr(9)
			  @ prow(),pcol() say transf(nTotalDif,"@E 999,999,999.99")+chr(9)+chr(9)
              @ prow(),pcol() say transf(nTotalTabela * 0.01,"@E 999,999,999.99")+chr(9)
			  @ prow(),pcol() say transf(nTotalVenda  * 0.01,"@E 999,999,999.99")+chr(9)
			  @ prow(),pcol() say transf(nTotalDif  * 0.01,"@E 999,999,999.99")+chr(9)
			  

              @ prow()+1,00   say ""

              cDesigner := asDesigner[nCont,1]
              nQtde  := 0
              nCom   := 0
              nTotal := 0
			  nTotalDev    := 0
              nTotalTabela := 0
		      nTotalVenda  := 0
       	      nTotalDif    := 0
           endif
       enddo

       if nQtde > 0
          Designer->(dbseek(cDesigner))
          @ prow()+1,00   say "Total do Designer.: "+Designer->Nome+chr(9)
          @ prow(),pcol() say chr(9)+chr(9)+chr(9)
          @ prow(),pcol() say transf(nQtde,"@R 9999999999")+chr(9)
          @ prow(),pcol() say chr(9)
          @ prow(),pcol() say transf(nTotalTabela,"@E 999,999,999.99")+chr(9)+chr(9)
          @ prow(),pcol() say transf(nQtde,"@R 9999999999")+chr(9)
		  @ prow(),pcol() say transf(nTotalDev,"@E 999,999,999.99")+chr(9)+chr(9)
		  @ prow(),pcol() say transf(nTotalVenda,"@E 999,999,999.99")+chr(9)
		  @ prow(),pcol() say transf(nTotalDif,"@E 999,999,999.99")+chr(9)+chr(9)
		  @ prow(),pcol() say transf(nTotalTabela * 0.01,"@E 999,999,999.99")+chr(9)
		  @ prow(),pcol() say transf(nTotalVenda  * 0.01,"@E 999,999,999.99")+chr(9)
		  @ prow(),pcol() say transf(nTotalDif  * 0.01,"@E 999,999,999.99")+chr(9)

          @ prow()+1,00   say ""

       endif

   endif

   qstopprn(.F.)

return


