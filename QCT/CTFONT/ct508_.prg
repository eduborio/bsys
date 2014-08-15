/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: Comparativo entre anos
// ANALISTA...: Eduardo Bório 
// PROGRAMADOR: 
// INICIO.....: 
// OBS........:
// ALTERACOES.:
function ct508

#include "inkey.ch"
#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1  := qlbloc("B523B","QBLOC.GLO") // tipo de impressao

private aEDICAO  := {}                   // vetor para os campos
private cTITULO                          // titulo do relatorio
private cTIPO                            // tipo de relatorio
private cPLANO                           // Plano
private nMES     := 1                    // mes de referencia
private cDEB     := "DB01"               // variavel auxiliar p/ macro
private CCRE     := "CR01"               // variavel auxiliar p/ macro
private nNIVEL                           // nivel da conta
private nSALDANT , nSALDATU , nTOTANT    // variaveis totalizadoras
private nTOTDB   , nTOTCR   , nTOTATU    // variaveis totalizadoras
private nS_TOTDB, nS_TOTCR, nS_TOTATU    // variaveis totalizadoras

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@nMES,"99"      )},"MES"   })

do while .T.

   qlbloc(5,0,"B508A","QBLOC.GLO")
   qmensa()
   XNIVEL  := 1
   XFLAG   := .T.
   cORDEM  := " "
   cCENTRO := space(10)
   cFILIAL := space(4)
   cPLAN   := space(7)
   nPAG    := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif ( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   if ! XFLAG ; return .T. ; endif
   do case
      case cCAMPO == "MES"
           if nMES > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
		   if nMES == 0
		      qrsay(XNIVEL,"ANUAL")
		   else
              qrsay(XNIVEL,strzero(nMES,2))
		   endif	  
	  endcase	   
      
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
   local lACHOU := .F.

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "Comparativo entre 2011 e 2012 - " + iif(nMes == 0,"Anual",ltrim(qnomemes(nMES)))

   qmensa()

return .T.

static function i_imprime

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   endif


return

static function i_impre_xls
   local nCOL , nTAM , lPRIM := .T.
   local XDRV_2011, XDRV_2012 := ""
   local nSaldo2011, nSaldo2012,nFat2011,nFat2012 := 0
   local nKey := 0

   nNIVEL   := 0

   XDRV_2011 := left(XDRV_CT,12) + "E011\" 
   XDRV_2012 := left(XDRV_CT,12) + "E012\"
   
   if ! quse(XDRV_2011,"PLAN",{},,"PL2011")
      qmensa("Não foi possivel abrir Plano de contas de 2011!","BL")
      return .F.
   endif	  
   
   if ! quse(XDRV_2012,"PLAN",{},,"PL2012")
      qmensa("Não foi possivel abrir Plano de contas de 2012!","BL")
      return .F.
   endif
   
   PL2011->(dbsetorder(3))
   PL2011->(dbseek("001686")) // Total Faturado
   nFat2011 := i_puxafat2011()
   
   if nFat2011 < 0 
      nFat2011 := nFat2011 *(-1)
   endif
   
   aPlan := {}
   
   PL2011->(dbsetorder(1))
   PL2011->(dbgotop())
   PL2011->(dbseek("3"))
   
   do while ! PL2011->(eof())

      aadd(aPlan,{PL2011->Codigo,PL2011->Descricao,PL2011->Reduzido,i_puxa2011(),0})
   
	  PL2011->(dbskip())
   enddo
   
   PL2012->(dbsetorder(1))
   PL2012->(dbgotop())
   PL2012->(dbseek("3"))
   
   do while ! PL2012->(eof())
      
	  nKey := ascan(aPlan,{|nRow| nRow[1] == PL2012->Codigo})
	  
	  if nKey > 0
         aPlan[nKey,5] := i_puxa2012() 	  
      else
         aadd(aPlan,{PL2012->Codigo,PL2012->Descricao,PL2012->Reduzido,0,i_puxa2012()})
	  endif	 
   
	  PL2012->(dbskip())
   enddo
   
   aPlan := aSort(aPlan,,,{|x,y| x[1] < y[1]})
   
   PL2011->(dbsetorder(1))
   PL2011->(dbgotop())
   
   PL2012->(dbsetorder(3))
   PL2012->(dbseek("001686")) // Total Faturado
   nFat2012 := i_puxasaldo("2012")
   
   if nFat2012 < 0 
      nFat2012 := nFat2012 *(-1)
   endif
   
   PL2012->(dbsetorder(1))
   PL2012->(dbgotop())
   PL2012->(dbseek("3"))

   for nCont := 1 to len(aPlan)

      if mod(nCont,200) == 0
         if ! qlineprn() ; return ; endif
		 qgirabarra()
	  endif

      if XPAGINA == 0 
         qpageprn()
         @ prow()+1,0 say " "+chr(9)+cTITULO
         @ prow()+1,0 say "Conta"+chr(9)+"Descricao da Conta"+chr(9)+"Reduzido"+chr(9)+"Saldo 2011"+chr(9)+"% Fat"+chr(9)+""+chr(9)+"Saldo 2012"+chr(9)+"% Fat" + chr(9) + " Diferenca entre % " 
         @ prow()+1,0 say ""
		 @ prow()+1,0 say chr(9) + "Faturamento 2011" + chr(9) + transf(nFat2011,"@E 999,999,999.99")
		 @ prow(),pcol() say chr(9) 
		 @ prow(),pcol() say chr(9) 
		 @ prow(),pcol() say chr(9) + "Faturamento 2012" + chr(9) + transf(nFat2012,"@E 999,999,999.99")
		 @ prow()+1,0 say ""
      endif
	  
      
	  i_nivelcta(aPlan[nCont,1])

      do case
         case nNIVEL = 1
              nCOL := 17 ; nTAM := 45
         case nNIVEL = 2
              nCOL := 20 ; nTAM := 45
         case nNIVEL = 3
              nCOL := 23 ; nTAM := 45
         case nNIVEL = 4
              nCOL := 26 ; nTAM := 45
         case nNIVEL = 5
              nCOL := 29 ; nTAM := 45
      endcase
	  
	  nSaldo2011 := aPlan[nCont,4] //i_puxasaldo("2011")
	  nSaldo2012 := aPlan[nCont,5] //i_puxasaldo("2012")
	  
	  cCodigo := aPlan[nCont,1]
	  
	  @ prow()+1,00 say ct_convcod(aPlan[nCont,1])

      @ prow()  ,pcol() say chr(9) + space(nCOL-17)+iif( (len(alltrim(cCodigo)) >= 1 .and. len(alltrim(cCodigo)) <= 7), subs(aPlan[nCont,2],1,nTAM), subs(aPlan[nCont,2],1,nTAM))
	  
	  @ prow()  ,pcol() say chr(9) + ct_convcod(aPlan[nCont,3])
	 
	  @ prow()  ,pcol() say chr(9) + ct_convpic2012(nSaldo2011)
	  
	  @ prow()  ,pcol() say chr(9) + ct_convperc(nSaldo2011/nFat2011 * 100)
	  
	  @ prow()  ,pcol() say chr(9)
	  
	  @ prow()  ,pcol() say chr(9) + ct_convpic2012(nSaldo2012)
	  
	  @ prow()  ,pcol() say chr(9) + ct_convperc(nSaldo2012/nFat2012 * 100)
     
   next

   qstopprn(.F.)

return

static function i_puxasaldo(cAno)
            
       local nCONT := 1       
	   local nSaldoTotal := 0 
	   
	   if cAno == "2011" 
	      PL2011->(dbsetorder(1))  
	      if ! PL2011->(dbseek(PL2012->Codigo))
	         return 0
		  endif	 
	   endif
	   
       nSaldoTotal := iif(cANO == "2011",PL2011->Saldo_ant,PL2012->Saldo_ant)
       for nCONT = 1 to 12
           cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)
           nSaldoTotal := nSaldoTotal + iif(cANO=="2011",PL2011->&cDEB + PL2011->&cCRE,PL2012->&cDEB + PL2012->&cCRE)
       next
return nSaldoTotal

static function i_puxa2011()
            
       local nCONT := 1       
	   local nSaldoTotal := 0 
	   
       nSaldoTotal := PL2011->Saldo_ant
       for nCONT = 1 to 12
           cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)
           nSaldoTotal := nSaldoTotal + PL2011->&cDEB + PL2011->&cCRE
       next
return nSaldoTotal

static function i_puxa2012()
            
       local nCONT := 1       
	   local nSaldoTotal := 0 
	   
       nSaldoTotal := PL2012->Saldo_ant
       for nCONT = 1 to 12
           cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)
           nSaldoTotal := nSaldoTotal + PL2012->&cDEB + PL2012->&cCRE
       next
return nSaldoTotal

static function i_nivelcta(cCodigo)
       local nCONT

       for nCONT = 11 to 1 step -1
           if subs(cCodigo,nCONT,1) != " "
              do case
                 case nCONT == 1
                      nNIVEL :=  1
                 case nCONT == 2 .or. nCONT == 3
                      nNIVEL :=  2
                 case nCONT == 4 .or. nCONT == 5
                      nNIVEL :=  3
                 case nCONT == 6 .or. nCONT == 7
                      nNIVEL :=  4
                 case nCONT == 8 .or. nCONT == 9 .or. nCONT == 10 .or. nCONT == 11 .or. nCONT == 12
                      nNIVEL :=  5
              endcase
              exit
           endif
       next
return

static function ct_convpic2012 ( nVAL )
   local nResult := nVal
      //return (transform(nVAL   ,"@E@) 999,999,999.99"))
      //return (transform(nVAL*-1,"@E@) 999,999,999.99"))
	  //iif(nResult < 0 ,nResult := nResult * (-1),)
return transform(nResult,"@E@) 999,999,999,999.99")


static function ct_convperc ( nVAL )
   if nVal < 0 
      nVal := nVal * (-1)
   endif	  

return transform(nVAL,"@R 999.99")

static function i_puxafat2011
            
       local nCONT := 1       
	   local nSaldoTotal := 0 
	   
       PL2011->(dbsetorder(3))  
	   PL2011->(dbseek("001686"))
	   
	   //alert("Saldo de 2011 -  conta" + PL2011->Descricao)
  
       nSaldoTotal := PL2011->Saldo_ant
       for nCONT = 1 to 12
	       cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)
           nSaldoTotal += (PL2011->&cDEB + PL2011->&cCRE)
		   alert(" Mes: " +strzero(ncont,2) + transf(nSaldoTotal,"@E 999,999,999,999.99"))
		   
       next
return nSaldoTotal

static function buscaPlan(cCodigo)
local nKey := 0

       nKey := ascan(aPlan,{|ckey| cKey[1] == cCodigo})

       if nKey > 0
          return aPlan[nKey] 
       endif

return NIL



