/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: INTERFACE CONTABIL
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: 
// INICIO.....: 
// OBS........:
function realtime


private nHISTORICO := ""
private nTOT_CRE   := 0
private nTOT_DEB   := 0
private nNUM_LANC  := 0
private cLOTE      := space(10)

if ! quse( XDRV_CT,"CONFIG")
   qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
   return
endif

if ! quse( XDRV_CT,"LOTE",{"LOTE_NUM"})
   qmensa("N„o foi poss¡vel abrir arquivo LOTE.DBF !! Tente novamente.")
   CONFIG->(dbclosearea())
   return
endif

//if LOTE->(qflock())
//   LOTE->(__DbPack())
//endif

if ! quse( XDRV_CT,"PLAN",{"PL_CODIG","PL_DESCR","PL_REDUZ"})
   qmensa("N„o foi poss¡vel abrir arquivo PLAN.DBF !! Tente novamente.")
   CONFIG->(dbclosearea())
   LOTE->(dbclosearea())
   PLAN->(dbclosearea())
   return
endif

if ! quse( XDRV_CT,"CCUSTO",{"CC_CODIG","CC_DESCR","CC_SUPER","CC_CODRD"})
   qmensa("N„o foi poss¡vel abrir arquivo CCUSTO.DBF !! Tente novamente.")
   CONFIG->(dbclosearea())
   LOTE->(dbclosearea())
   PLAN->(dbclosearea())
   return
endif

if ! quse( XDRV_CT,"LANC",{"LA_DATA","LA_DBDAT","LA_CRDAT","LA_NLANC","LA_LOLAN","LA_CEDBD","LA_CECRD","LA_DTFIL","LA_FICTD","LA_FICTC","LA_DTNUM","LANC_FAT","LANC_DOC"})
   qmensa("N„o foi poss¡vel abrir arquivo LOTE.DBF !! Tente novamente.")
   CONFIG->(dbclosearea())
   LOTE->(dbclosearea())
   return
endif

if ! quse( XDRV_CTX,"HIST",{"HI_CODIG","HI_DESCR"})
   qmensa("N„o foi poss¡vel abrir arquivo LOTE.DBF !! Tente novamente.")
   CONFIG->(dbclosearea())
   LOTE->(dbclosearea())
   return
endif

if ! quse( XDRV_CT,"REFER",{"CODIGO","DESCRICAO"})
   qmensa("N„o foi poss¡vel abrir arquivo REFER.DBF !! Tente novamente.")
   CONFIG->(dbclosearea())
   LOTE->(dbclosearea())
   return
endif

   if CONFIG->Inter_fisc == "S" // INTERFACE SOMENTE COM A ESCRITA FISCAL

   //if ! quse( XDRV_EF,"SH_EFCON",NIL)
   //   qmensa("N„o foi poss¡vel abrir arquivo SH_EFCON.DBF !! Tente novamente.")
   //   CONFIG->(dbclosearea())
   //   LOTE->(dbclosearea())
   //   HIST->(dbclosearea())
   //   return
   //endif

   //i_qef()

else

   if ! quse( XDRV_CT,"SH_PROCT",NIL)
      qmensa("N„o foi poss¡vel abrir arquivo SH_PROCT.DBF !! Tente novamente.")
      CONFIG->(dbclosearea())
      LOTE->(dbclosearea())
      HIST->(dbclosearea())
      return
   endif

   //if ! quse( XDRV_EF,"SH_EFCON",NIL,"E")
    //  qmensa("N„o foi poss¡vel abrir arquivo SH_EFCON.DBF !! Tente novamente.")
     // CONFIG->(dbclosearea())
     // /LOTE->(dbclosearea())
     // HIST->(dbclosearea())
     // SH_PROCT->(dbclosearea())
     // return
   //endif

   //SH_PROCT->(__dbPack())

   i_interface()  // INTERFACE COM ENTRADAS E SAIDAS
      
   //if XEMPRESA == "001"
   //  i_RecebimentosWeb()
   //endif	  
   
   i_ImportaTxtWeb()
   i_Referenciado()
   
   dbcloseall()

   return

endif

/////////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA FAZER A INTEGRACAO COM O QEF _______________________________

function i_qef

   SH_EFCON->(Dbgotop())

   while ! SH_EFCON->(eof())

      if SH_EFCON->Valor <> 0

         if LOTE->(qrlock()) .and. LOTE->(qappend())

            replace LOTE->Data_lanc with SH_EFCON->Data_lanc
            replace LOTE->Cont_cr   with SH_EFCON->Cont_cr
            replace LOTE->Cont_db   with SH_EFCON->Cont_db
            replace LOTE->Filial    with SH_EFCON->Filial
            replace LOTE->Centro    with SH_EFCON->Centro
            replace LOTE->Valor     with SH_EFCON->Valor
            replace LOTE->Num_lote  with SH_EFCON->Num_lote
            replace LOTE->Num_doc   with SH_EFCON->Num_doc

            i_hist("SH_EFCON")  // montagem do historico

            replace LOTE->Hist_comp with nHISTORICO

            cLOTE := SH_EFCON->Num_Lote
            do case
               case empty(SH_EFCON->Cont_db) .and. ! empty(SH_EFCON->Cont_cr)
                    nTOT_CRE += SH_EFCON->Valor
               case ! empty(SH_EFCON->Cont_db) .and. empty(SH_EFCON->Cont_cr)
                    nTOT_DEB += SH_EFCON->Valor
               case ! empty(SH_EFCON->Cont_db) .and. ! empty(SH_EFCON->Cont_cr)
                    nTOT_DEB += SH_EFCON->Valor
                    nTOT_CRE += SH_EFCON->Valor
            endcase

         endif
      endif

      if SH_EFCON->(qrlock())
         SH_EFCON->(dbdelete())
         SH_EFCON->(qunlock())
      endif

      SH_EFCON->(Dbskip())

   enddo

   if nTOT_DEB <> nTOT_CRE

      alert("LOTE Nr. " + cLOTE + " n„o est  fechado ! ;; Verifique na op‡„o <203> !",{"OK"})

   else

      nNUM_LANC := CONFIG->Num_lanc

      qmensa("Aguarde... Integrando Lote cont bil nr. " + cLOTE)

      LOTE->(dbgotop())
      LOTE->(dbseek(cLOTE))

      do while ! LOTE->(eof()) .and. LOTE->Num_lote == cLOTE

         qgirabarra()

         if LANC->(qrlock()) .and. LANC->(qappend())

            replace LANC->Data_lanc with LOTE->Data_lanc
            replace LANC->Cont_cr   with LOTE->Cont_cr
            replace LANC->Cont_db   with LOTE->Cont_db
            replace LANC->Filial    with LOTE->Filial
            replace LANC->Centro    with LOTE->Centro
            replace LANC->Valor     with LOTE->Valor
            replace LANC->Num_lote  with LOTE->Num_lote
            replace LANC->Num_lanc  with strzero(nNUM_LANC:=nNUM_LANC + 1,5)  // numero do lancamento
            replace LANC->Num_doc   with LOTE->Num_doc
            replace LANC->Hist_comp with LOTE->Hist_comp

            if ct_trava_prop(LOTE->Cont_db,LOTE->Cont_cr)
               i_propaga("I")
            endif

            LANC->(qunlock())

            if LOTE->(qrlock())
               LOTE->(dbdelete())
               LOTE->(qunlock())
            endif

         endif

         LOTE->(Dbskip())

      enddo

      if CONFIG->(qrlock())
         replace CONFIG->Num_lanc with nNUM_LANC
         CONFIG->(qunlock())
      endif

      qmensa("")

   endif

   Dbcloseall()

return

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO GERAL DE SALDO ________________________________________________

static function i_propaga ( cOPT )

  // ATUALIZA SALDOS NA INCLUSAO ________________________________________

  if CONFIG->(qrlock())
     if ! empty(LOTE->Cont_db)
        ct_prop_saldo(LOTE->Cont_db,LOTE->Valor,"DB"+strzero(month(LOTE->Data_lanc),2))
        CONFIG->&("DB"+strzero(month(LOTE->Data_lanc),2))+=LOTE->Valor
     endif
     if ! empty(LOTE->Cont_cr)
        ct_prop_saldo(LOTE->Cont_cr,LOTE->Valor,"CR"+strzero(month(LOTE->Data_lanc),2))
        CONFIG->&("CR"+strzero(month(LOTE->Data_lanc),2))+=LOTE->Valor*-1
     endif
     CONFIG->(qunlock())
  endif

return

static function i_propaga_web ( conta_db, conta_cr, data,valor )

  // ATUALIZA SALDOS NA INCLUSAO ________________________________________

  if CONFIG->(qrlock())
     if ! empty(conta_db)
        ct_prop_saldo(conta_db,valor,"DB"+strzero(month(data),2))
        CONFIG->&("DB"+strzero(month(data),2) )+= valor
     endif
     if ! empty(conta_cr)
        ct_prop_saldo(conta_cr,valor,"CR"+strzero(month(data),2))
        CONFIG->&("CR"+strzero(month(data),2))+=valor*-1
     endif
     CONFIG->(qunlock())
  endif

return

/////////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA FAZER A INTEGRACAO COM ENTRADAS E SAIDAS ____________________

function i_interface

local nNUM_LOTE

   SH_PROCT->(Dbgotop())

   nNUM_LOTE := SH_PROCT->Num_lote

   while ! SH_PROCT->(eof())

      if empty(SH_PROCT->Data_lanc)
         SH_PROCT->(dbskip())
         loop
      endif

      if SH_PROCT->Valor == 0
         SH_PROCT->(dbskip())
         loop
      endif

      if empty(SH_PROCT->Cont_cr) .and. empty(SH_PROCT->cont_db)
         SH_PROCT->(dbskip())
         loop
      endif



      if LOTE->(qrlock()) .and. LOTE->(qappend())

         replace LOTE->Data_lanc with SH_PROCT->Data_lanc
         replace LOTE->Cont_cr   with SH_PROCT->Cont_cr
         replace LOTE->Cont_db   with SH_PROCT->Cont_db
         replace LOTE->Filial    with SH_PROCT->Filial
         if len(SH_PROCT->Centro) == 4
            CCUSTO->(dbsetorder(4))
            CCUSTO->(Dbseek(SH_PROCT->Centro))
            replace LOTE->Centro    with CCUSTO->Codigo
         else
            replace LOTE->Centro    with SH_PROCT->Centro
         endif
         replace LOTE->Valor     with SH_PROCT->Valor
         replace LOTE->Num_lote  with SH_PROCT->Num_lote
         replace LOTE->Num_doc   with SH_PROCT->Num_doc
         replace LOTE->Cod_fat   with SH_PROCT->Cod_fat

         i_hist("SH_PROCT")  // montagem do historico

         if ! empty(nHISTORICO)
            replace LOTE->Hist_comp with nHISTORICO + " " + SH_PROCT->Historico
         else
            replace LOTE->Hist_comp with SH_PROCT->Historico
         endif

         cLOTE := SH_PROCT->Num_Lote

         do case
            case empty(SH_PROCT->Cont_db) .and. ! empty(SH_PROCT->Cont_cr)
                 nTOT_CRE += SH_PROCT->Valor
            case ! empty(SH_PROCT->Cont_db) .and. empty(SH_PROCT->Cont_cr)
                 nTOT_DEB += SH_PROCT->Valor
            case ! empty(SH_PROCT->Cont_db) .and. ! empty(SH_PROCT->Cont_cr)
                 nTOT_DEB += SH_PROCT->Valor
                 nTOT_CRE += SH_PROCT->Valor
         endcase

      endif

      if SH_PROCT->(qrlock())
         SH_PROCT->(dbdelete())
         SH_PROCT->(qunlock())
      endif

      SH_PROCT->(Dbskip())

   enddo

   if nTOT_DEB <> nTOT_CRE

      alert("LOTE Nr." + cLOTE + " n„o est  fechado !  ;; Verifique na op‡„o <203> ! ", {"OK"})

   else

      nNUM_LANC := CONFIG->Num_lanc

      qmensa("Aguarde... Integrando Lote cont bil nr. " + cLOTE )

      LOTE->(dbgotop())
      LOTE->(dbseek(cLOTE))

      do while ! LOTE->(eof()) .and. LOTE->Num_lote == cLOTE

         qgirabarra()

         if LANC->(qrlock()) .and. LANC->(qappend())

            replace LANC->Data_lanc with LOTE->Data_lanc
            replace LANC->Cont_cr   with LOTE->Cont_cr
            replace LANC->Cont_db   with LOTE->Cont_db
            replace LANC->Filial    with LOTE->Filial
            replace LANC->Centro    with LOTE->Centro
            replace LANC->Valor     with LOTE->Valor
            replace LANC->Num_lote  with LOTE->Num_lote
            replace LANC->Num_lanc  with strzero(nNUM_LANC:=nNUM_LANC + 1,5)  // numero do lancamento
            replace LANC->Num_doc   with LOTE->Num_doc
            replace LANC->Hist_comp with LOTE->Hist_comp
            replace LANC->Cod_fat   with LOTE->Cod_fat

            if ct_trava_prop(LOTE->Cont_db,LOTE->Cont_cr)
               i_propaga("I")
            endif

            LANC->(qunlock())

            if LOTE->(qrlock())
               LOTE->(dbdelete())
               LOTE->(qunlock())
            endif

         endif

         LOTE->(Dbskip())

      enddo

      if CONFIG->(qrlock())
         replace CONFIG->Num_lanc with nNUM_LANC
         CONFIG->(qunlock())
      endif

      qmensa("")

   endif

   /*
   SH_EFCON->(Dbgotop())

   while ! SH_EFCON->(eof())

      if LOTE->(qrlock()) .and. LOTE->(qappend())

         replace LOTE->Data_lanc with SH_EFCON->Data_lanc
         replace LOTE->Cont_cr   with SH_EFCON->Cont_cr
         replace LOTE->Cont_db   with SH_EFCON->Cont_db
         replace LOTE->Filial    with SH_EFCON->Filial
         replace LOTE->Centro    with SH_EFCON->Centro
         replace LOTE->Valor     with SH_EFCON->Valor
         replace LOTE->Num_lote  with SH_EFCON->Num_lote
         replace LOTE->Num_doc   with SH_EFCON->Num_doc

         i_hist("SH_EFCON")  // montagem do historico

         replace LOTE->Hist_comp with nHISTORICO

         cLOTE := SH_EFCON->Num_Lote
         do case
            case empty(SH_EFCON->Cont_db) .and. ! empty(SH_EFCON->Cont_cr)
                 nTOT_CRE += SH_EFCON->Valor
            case ! empty(SH_EFCON->Cont_db) .and. empty(SH_EFCON->Cont_cr)
                 nTOT_DEB += SH_EFCON->Valor
            case ! empty(SH_EFCON->Cont_db) .and. ! empty(SH_EFCON->Cont_cr)
                 nTOT_DEB += SH_EFCON->Valor
                 nTOT_CRE += SH_EFCON->Valor
         endcase

      endif

      if SH_EFCON->(qrlock())
         SH_EFCON->(dbdelete())
         SH_EFCON->(qunlock())
      endif

      SH_EFCON->(Dbskip())

   enddo
 */
   if nTOT_DEB <> nTOT_CRE

      alert("LOTE Nr. " + cLOTE + " n„o est  fechado ! ;; Verifique na op‡„o <203> !",{"OK"})

   else

      nNUM_LANC := CONFIG->Num_lanc

      qmensa("Aguarde... Integrando Lote cont bil nr. " + cLOTE)

      LOTE->(dbgotop())
      LOTE->(dbseek(cLOTE))

      do while ! LOTE->(eof()) .and. LOTE->Num_lote == cLOTE

         qgirabarra()

         if LANC->(qrlock()) .and. LANC->(qappend())

            replace LANC->Data_lanc with LOTE->Data_lanc
            replace LANC->Cont_cr   with LOTE->Cont_cr
            replace LANC->Cont_db   with LOTE->Cont_db
            replace LANC->Filial    with LOTE->Filial
            replace LANC->Centro    with LOTE->Centro
            replace LANC->Valor     with LOTE->Valor
            replace LANC->Num_lote  with LOTE->Num_lote
            replace LANC->Num_lanc  with strzero(nNUM_LANC:=nNUM_LANC + 1,5)  // numero do lancamento
            replace LANC->Num_doc   with LOTE->Num_doc
            replace LANC->Hist_comp with LOTE->Hist_comp

            if ct_trava_prop(LOTE->Cont_db,LOTE->Cont_cr)
               i_propaga("I")
            endif

            LANC->(qunlock())

            if LOTE->(qrlock())
               LOTE->(dbdelete())
               LOTE->(qunlock())
            endif

         endif

         LOTE->(Dbskip())

      enddo

      if CONFIG->(qrlock())
         replace CONFIG->Num_lanc with nNUM_LANC
         CONFIG->(qunlock())
      endif

      qmensa("")

   endif
   

return

///////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A MONTAGEM DO HISTORICO PADRAO _______

function i_hist(cARQ)

local lTEM := .F.

   HIST->(dbseek((cARQ)->Cod_hist))
   nHIST := HIST->Descricao

   nHISTORICO := ""

   for nCONT := 1 to len(nHIST)

       if ( nPOS := at("[",nHIST) )  <> 0

          iif(nPOS <> 1 ,nHISTORICO += substr(nHIST,1,nPOS-1),)

          nPOS += 2  // para ignorar os simbolos [@

          lTEM := .T.
          do case

             case substr(nHIST,nPOS,2) == "CA"
                  nHISTORICO += alltrim((cARQ)->Ca) + " "
             case substr(nHIST,nPOS,3) == "CGC"
                  nHISTORICO += transform((cARQ)->Cgc,"@R 99.999.999/9999-99")
             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO += dtos((cARQ)->Da)    + " "
             case substr(nHIST,nPOS,2) == "DP"
                  nHISTORICO += alltrim((cARQ)->Dp) + " "
             case substr(nHIST,nPOS,2) == "FA"
                  nHISTORICO += alltrim((cARQ)->Fa) + " "
             case substr(nHIST,nPOS,2) == "NF"
                  nHISTORICO += alltrim((cARQ)->Nf) + " "
             case substr(nHIST,nPOS,2) == "EP"
                  nHISTORICO += alltrim((cARQ)->Ep) + " "
             case substr(nHIST,nPOS,2) == "SE"
                  nHISTORICO += alltrim((cARQ)->Se) + " "
             case substr(nHIST,nPOS,2) == "BC"
                  nHISTORICO += alltrim((cARQ)->Bc) + " "
             case substr(nHIST,nPOS,2) == "CH"
                  nHISTORICO += alltrim((cARQ)->Ch) + " "
             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO += alltrim((cARQ)->Da) + " "
             case substr(nHIST,nPOS,2) == "HO"
                  nHISTORICO += alltrim((cARQ)->Ho) + " "
             case substr(nHIST,nPOS,2) == "HP"
                  nHISTORICO += alltrim((cARQ)->Hp) + " "
             case substr(nHIST,nPOS,2) == "ND"
                  nHISTORICO += alltrim((cARQ)->Nd) + " "
             case substr(nHIST,nPOS,2) == "NT"
                  nHISTORICO += alltrim((cARQ)->Nt) + " "
          endcase

          nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

       else

         if ! lTEM
            nHISTORICO := HIST->Descricao
         endif

         exit

       endif

   next

return

function i_RecebimentosWeb()

local oServer, oRow
local oQuery
local nCont := 0
local cQuery :=  ""
		
		 oServer := TMySQLServer():New(XSERVER, "root", "borios")
		 if oServer:NetErr()
			Alert(oServer:Error())
		 endif

		 oServer:SelectDB("comercial")	
		 
		 cQuery := " select rec.id as recId, rec.*,b.conta_contabil, cli.conta_contabil as cli_conta, cli.nome as cli_nome from receber rec "
		 cQuery += " left outer join bancos b on b.id = rec.banco_id "
		 cQuery += " left outer join clientes cli on cli.id = rec.cliente_id "
		 cQuery += " where recebido = 1 and contabil_baixa = 0 "
		 
		 oQuery := oServer:Query(cQuery)
		 
		  if oQuery:NetErr()
		    Alert(oQuery:Error())
	     endif
   
         nCont := 1
   
  	     do while nCont <= oQuery:LastRec() 	
			row := oQuery:getRow(nCont)
			
			processaRecebimento(row)
			processaJuros(row)
			processaDesconto(row)
			marcaComoContabilizado(oServer,get(row,'recId'))
				
			nCont++
		 enddo

		 //CONFIG->(dbclosearea())		
return

static function processaRecebimento(row)
	local conta_db := ""
	local conta_cr := ""
	nNUM_LANC := CONFIG->Num_lanc
	
	if LANC->(qrlock()) .and. LANC->(qappend())
       replace LANC->Data_lanc with get(row,'recebimento')
	   
       replace LANC->Cont_cr   with get(row,'cli_conta')
	   conta_cr := get(row,'cli_conta')
	   
	   //alert(VALTYPE(get(row,'tipo')))
	   
	   //tipo := str(get(row,'tipo'))
	   
	   if get(row,'tipo') == 2
		  replace LANC->Cont_db   with "001392"
		  conta_db := "001392"
       else 
		  replace LANC->Cont_db   with get(row,'conta_contabil')
		  conta_db := get(row,'conta_contabil')	
	   endif	  
	  
       replace LANC->Filial    with "0001"
       replace LANC->Centro    with ""
       replace LANC->Valor     with get(row,'valor')
       replace LANC->Num_lote  with "WB"+strzero(day(date()),2)+strzero(month(date()),2)+strzero(year(date()),4)
       replace LANC->Num_lanc  with strzero(nNUM_LANC:=nNUM_LANC + 1,5)  // numero do lancamento
       replace LANC->Num_doc   with substr(get(row,'fatura'),3,10)
       replace LANC->Hist_comp with "REC " + substr(get(row,'fatura'),3,10) + " "+left(get(row,'cli_nome'),40)
	   replace LANC->web_tab   with "receber"
	   replace LANC->web_id    with get(row,'id')

       //if ct_trava_prop(conta_db,conta_cr)
          i_propaga_web(conta_db,conta_cr,get(row,'recebimento'),get(row,'valor'))
       //endif

       LANC->(qunlock())
    endif
	
	if CONFIG->(qrlock())
         replace CONFIG->Num_lanc with nNUM_LANC
         CONFIG->(qunlock())
    endif
return

static function processaJuros(row)

	local conta_db := ""
	local conta_cr := ""
	
	if get(row,'juros') > 0
		
		nNUM_LANC := CONFIG->Num_lanc
		
		if LANC->(qrlock()) .and. LANC->(qappend())
		   replace LANC->Data_lanc with get(row,'recebimento')
		   
		   replace LANC->Cont_cr   with "032190"
		   conta_cr := "032190"
		   
		   if get(row,'tipo') == 2
			  replace LANC->Cont_db   with "001392"
			  conta_db := "001392"
		   else
			  replace LANC->Cont_db   with get(row,'conta_contabil')	
			  conta_db := get(row,'conta_contabil')	
		   endif
		   
		   replace LANC->Filial    with "0001"
		   replace LANC->Centro    with ""
		   replace LANC->Valor     with get(row,'juros')
		   replace LANC->Num_lote  with "WB"+strzero(day(date()),2)+strzero(month(date()),2)+strzero(year(date()),4)
		   replace LANC->Num_lanc  with strzero(nNUM_LANC:=nNUM_LANC + 1,5)  // numero do lancamento
		   replace LANC->Num_doc   with substr(get(row,'fatura'),3,10)
		   replace LANC->Hist_comp with "REC JUROS NF " + substr(get(row,'fatura'),3,10) + " "+left(get(row,'cli_nome'),40)
		   replace LANC->web_tab   with "receber"
	       replace LANC->web_id    with get(row,'id')

		   //if ct_trava_prop(conta_db,conta_cr)
			  i_propaga_web(conta_db,conta_cr,get(row,'recebimento'),get(row,'desconto'))
		   //endif

		   LANC->(qunlock())
		endif
		
		if CONFIG->(qrlock())
			 replace CONFIG->Num_lanc with nNUM_LANC
			 CONFIG->(qunlock())
		endif
	endif	
return

static function processaDesconto(row)

	local conta_db := ""
	local conta_cr := ""
	
	if(get(row,'desconto') > 0)
		
		nNUM_LANC := CONFIG->Num_lanc
		
		if LANC->(qrlock()) .and. LANC->(qappend())
		
		   
		   
		   replace LANC->Data_lanc with get(row,'recebimento')
		   
		   replace LANC->Cont_cr   with get(row,'cli_conta')
		   conta_cr := get(row,'cli_conta')
		   
 		   replace LANC->Cont_db   with "006602"
		   conta_db := "006602"
		   
		   replace LANC->Filial    with "0001"
		   replace LANC->Centro    with ""
		   replace LANC->Valor     with get(row,'desconto')
		   replace LANC->Num_lote  with "WB"+strzero(day(date()),2)+strzero(month(date()),2)+strzero(year(date()),4)
		   replace LANC->Num_lanc  with strzero(nNUM_LANC:=nNUM_LANC + 1,5)  // numero do lancamento
		   replace LANC->Num_doc   with substr(get(row,'fatura'),3,10)
		   replace LANC->Hist_comp with "DESC. NF " + substr(get(row,'fatura'),3,10) + " "+left(get(row,'cli_nome'),40)
		   replace LANC->web_tab   with "receber"
	       replace LANC->web_id    with get(row,'id')

		   //if ct_trava_prop(conta_db,conta_cr)
			  i_propaga_web(conta_db,conta_cr,get(row,'recebimento'),get(row,'desconto'))
		   //endif

		   LANC->(qunlock())
		endif
		
		if CONFIG->(qrlock())
			 replace CONFIG->Num_lanc with nNUM_LANC
			 CONFIG->(qunlock())
		endif
	endif	
return

static function marcaComoContabilizado(oServer,id)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   
   cQuery := " update receber set contabil_baixa = 1 "
   cQuery += " where id =" + alltrim(str(id))
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
return

function i_ImportaTxtWeb()

local oServer, oRow
local oQuery
local nCont := 0
local cQuery :=  ""
		
		 oServer := TMySQLServer():New(XSERVER, "root", "borios")
		 if oServer:NetErr()
			Alert(oServer:Error())
		 endif

		 oServer:SelectDB("comercial")	
		 
		 cQuery := " select * from contabilidade cont "
		 cQuery += " where contabilizado = 0 "
		 
		 oQuery := oServer:Query(cQuery)
		 
		  if oQuery:NetErr()
		    Alert(oQuery:Error())
	     endif
   
         nCont := 1
   
  	     do while nCont <= oQuery:LastRec() 	
			
			row := oQuery:getRow(nCont)
			
			if year(get(row,'lancamento')) == 2018 .and. XEMPRESA == "001"
			   processaContabilidade(row)
			   marcaComoContabilizadoTxt(oServer,get(row,'id'))
			endif   
			
			if year(get(row,'lancamento')) == 2017 .and. XEMPRESA == "017"
			   processaContabilidade(row)
			   marcaComoContabilizadoTxt(oServer,get(row,'id'))
			endif
				
			nCont++
		 enddo

		 CONFIG->(dbclosearea())		
return

static function processaContabilidade(row)
	local conta_db := ""
	local conta_cr := ""
	nNUM_LANC := CONFIG->Num_lanc
	
	if LANC->(qrlock()) .and. LANC->(qappend())
       replace LANC->Data_lanc with get(row,'lancamento')
	   
       replace LANC->Cont_db   with get(row,'contaDebito')
  	   replace LANC->Cont_cr   with get(row,'contaCred')
	  
       replace LANC->Filial    with strzero(val(get(row,'empresa')),4)
       replace LANC->Centro    with ""
       replace LANC->Valor     with get(row,'valor')
       replace LANC->Num_lote  with "WB"+strzero(day(date()),2)+strzero(month(date()),2)+strzero(year(date()),4)
       replace LANC->Num_lanc  with strzero(nNUM_LANC:=nNUM_LANC + 1,5)  // numero do lancamento
       replace LANC->Num_doc   with ""
       replace LANC->Hist_comp with get(row,'historico')
	   replace LANC->web_tab   with "contabilidade"
	   replace LANC->web_id    with get(row,'id')

       LANC->(qunlock())
    endif
	
	LANC->(dbcommit())
	
	//if ct_trava_prop(LANC->cont_db,LANC->cont_cr)
       i_propaga_web(LANC->cont_db,LANC->cont_cr,LANC->Data_lanc,LANC->Valor)
    //endif
	
	if CONFIG->(qrlock())
         replace CONFIG->Num_lanc with nNUM_LANC
         CONFIG->(qunlock())
    endif
return

static function marcaComoContabilizadoTxt(oServer,id)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   
   cQuery := " update contabilidade set contabilizado = 1 "
   cQuery += " where id =" + alltrim(str(id))
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
return



function i_Referenciado()

local oServer, oRow
local oQuery
local nCont := 0
local cQuery :=  ""
		
		 oServer := TMySQLServer():New(XSERVER, "root", "borios")
		 if oServer:NetErr()
			Alert(oServer:Error())
		 endif

		 oServer:SelectDB("comercial")	
		 
		 cQuery := " select * from plano_referencial ref where importado = 0 "
		 
		 oQuery := oServer:Query(cQuery)
		 
		  if oQuery:NetErr()
		    Alert(oQuery:Error())
	     endif
   
         nCont := 1
   
  	     do while nCont <= oQuery:LastRec() 	
			
			row := oQuery:getRow(nCont)
			qmensa(get(row,'codigo')) 
			processaReferenciado (row)
			marcaReferenciadoComoImportado(oServer,get(row,'id'))
				
			nCont++
		 enddo

return

static function processaReferenciado(row)
	
	if REFER->(qrlock()) .and. REFER->(qappend())

		replace REFER->Codigo    with get(row,'codigo')
		replace REFER->Descricao with get(row,'descricao')
		replace REFER->Dt_ini    with get(row,'dt_ini')
		replace REFER->Dt_fim    with get(row,'dt_fim')
		replace REFER->Tipo      with get(row,'tipo')
		replace REFER->Superior  with get(row,'conta_superior')
		replace REFER->Nivel     with get(row,'nivel')
		replace REFER->Natureza  with get(row,'natureza')
		replace REFER->Orient    with get(row,'obs')

        REFER->(qunlock())
    endif
	
	REFER->(dbcommit())
	
return

static function marcaReferenciadoComoImportado(oServer,id)
   local cQuery := ""
   local oQuery
   local row
   local nCont := 1
   
   cQuery := " update plano_referencial set importado = 1 "
   cQuery += " where id =" + alltrim(str(id))
   oQuery := oServer:Query(cQuery)
   
   if oQuery:NetErr()
      Alert(oQuery:Error())
   endif
   
return

static function get(row,campo)
return  row:fieldget(campo)