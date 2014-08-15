/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: INTERFACE CONTABIL
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: ABRIL DE 1998
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

if CONFIG->Inter_fisc == "S" // INTERFACE SOMENTE COM A ESCRITA FISCAL

   if ! quse( XDRV_EF,"SH_EFCON",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo SH_EFCON.DBF !! Tente novamente.")
      CONFIG->(dbclosearea())
      LOTE->(dbclosearea())
      HIST->(dbclosearea())
      return
   endif

   i_qef()

else

   if ! quse( XDRV_CT,"SH_PROCT",NIL)
      qmensa("N„o foi poss¡vel abrir arquivo SH_PROCT.DBF !! Tente novamente.")
      CONFIG->(dbclosearea())
      LOTE->(dbclosearea())
      HIST->(dbclosearea())
      return
   endif

   if ! quse( XDRV_EF,"SH_EFCON",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo SH_EFCON.DBF !! Tente novamente.")
      CONFIG->(dbclosearea())
      LOTE->(dbclosearea())
      HIST->(dbclosearea())
      SH_PROCT->(dbclosearea())
      return
   endif

   //SH_PROCT->(__dbPack())

   i_interface()  // INTERFACE COM ENTRADAS E SAIDAS

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
