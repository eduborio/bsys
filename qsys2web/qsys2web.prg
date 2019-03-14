function main()

    private XCOR_MENSA := "N/G"
	clear
    
	nValor = 1240698.37
	
	OUTSTD(i_extenso(nValor))
	
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

return


procedure ErrorSys()

   errorblock ( { |e| berror(e) } )

return

static function berror( e )
	OUTSTD(e:description," ",e:operation)	
return .F.

static function i_extenso ( nVALOR , cTIPO )

   local cEXTENSO := "", nCONT, zTMP, cCENTENA, cCOMP
   local cSTRING := strtran(strzero(nVALOR,15,2),".","0")

   private aUNID := {"ZERO","UM","DOIS","TRES","QUATRO","CINCO","SEIS","SETE","OITO","NOVE","DEZ","ONZE","DOZE","TREZE","QUATORZE","QUINZE","DEZESSEIS","DEZESSETE","DEZOITO","DEZENOVE"}
   private aDEZE := {"VINTE","TRINTA","QUARENTA","CINQUENTA","SESSENTA","SETENTA","OITENTA","NOVENTA"}
   private aCENT := {"CENTO","DUZENTOS","TREZENTOS","QUATROCENTOS","QUINHENTOS","SEISCENTOS","SETECENTOS","OITOCENTOS","NOVECENTOS"}
   private aCASA := {"BILHOES","MILHOES","MIL","REAIS","CENTAVOS","BILHAO","MILHAO","MIL","REAL","CENTAVO"}


   for nCONT := 1 to 13 step 3
       cCENTENA := substr(cSTRING,nCONT,3)
	   
       cCOMP := ""
       if ! empty( zTMP := i_ext(cCENTENA) )
          cCOMP := zTMP + aCASA[int(nCONT/3+iif(val(cCENTENA)==1,6,1))]
       else
	   endif
       do case
          case nCONT == 10 .and. substr(cSTRING,7,6)  == "000000" .and. nVALOR > 999999
               cEXTENSO := left(cEXTENSO,len(cEXTENSO)-2)
               cCOMP += " DE REAIS"
          case nCONT == 10 .and. substr(cSTRING,10,3) == "000" .and. nVALOR > 999
               cEXTENSO := left(cEXTENSO,len(cEXTENSO)-2)
               cCOMP += " REAIS"
       endcase
       cCOMP += iif(nCONT<9.and.!empty(zTMP),", ","")
       iif(nCONT==13.and.nVALOR>1.and.!empty(zTMP),cCOMP:=" E "+cCOMP,NIL)
       cEXTENSO += cCOMP
   next

return cEXTENSO

static function i_ext ( cCENTENA )

   local nCONT, nINDIC, cEXTENSO
   declare aDIG[3]
   
   if cCENTENA == "000" ; return "" ; endif

   for nCONT = 1 to 3
       aDIG[nCONT] := val(substr(cCENTENA,nCONT,1))
   next

   ANT := .F.
   cEXTENSO := ""
   nINDIC := 1

   if aDIG[nINDIC] <> 0
      if aDIG[nINDIC] == 1 .and. aDIG[nINDIC+1] == 0 .and. aDIG[nINDIC+2] == 0
         cEXTENSO += "CEM "
         ANT := .T.
         return cEXTENSO
      else
         cEXTENSO += (trim(aCENT[aDIG[nINDIC]]) + " ")
         ANT := .T.
      endif
   endif

   if aDIG[nINDIC+1] <> 0
      if ANT
         cEXTENSO += "E "
         ANT := .F.
      endif
      if aDIG[nINDIC+1] == 1
         POS := val(str(aDIG[nINDIC+1],1)+str(aDIG[nINDIC+2],1))+1
         cEXTENSO += (trim(aUNID[POS]) + " ")
         return cEXTENSO
      else
         cEXTENSO += (trim(aDEZE[aDIG[nINDIC+1]-1]) + " ")
         ANT := .T.
      endif
   endif

   if aDIG[nINDIC+2] == 0
      return cEXTENSO
   else
      if ANT
         cEXTENSO += "E "
         ANT := .F.
      endif
      cEXTENSO += (trim(aUNID[(aDIG[nINDIC+2]+1)]) + " ")
   endif

return (cEXTENSO)

