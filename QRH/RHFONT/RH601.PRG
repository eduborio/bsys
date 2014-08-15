/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: INTERFACE COM A CONTABILIDADE
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: 14/03/2009
// OBS........:
// ALTERACOES.:

local   nREC
private cANOMES    := qanomes(XDATASYS)
private cDATA_CONT := XDATASYS
private XNIVEL     := 1
private cNUM_LOTE
private nDOCNUM    := 1
private cCENTANT
private nTOTEVE
private nPOINTER
private aEVENTOS   := {}

if qconf("Confirma interface com a contabilidade ?")

   if CONFIG->(qrlock())
      cNUM_LOTE := "RH" + strzero(CONFIG->Lote_inter + 1,3)
      replace CONFIG->Lote_inter with CONFIG->Lote_inter + 1
      replace CONFIG->Lote_cont  with CONFIG->Lote_cont + 1
      CONFIG->(qunlock())
   endif
else
   return
endif

// ABRE ARQUIVO DE INTEGRACAO E PLANO DE CONTAS DA IQ _______________________

fu_abre_share()
fu_abre_plan()


FUN->(dbsetorder(1))  // ordem de matricula

i_FunContabiliza()

///////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA CONTABILIZAR LANCAMENTOS DO QRH PARA QCT _____

static function i_funContabiliza

    fu_provct()

    EVCONT->(Dbgotop())
    LANC->(dbsetorder(3))

    FUN->(dbgotop())

    do while ! FUN->(eof())

       if LANC->(dbseek(FUN->Matricula+XANOMES))
          do while ! LANC->(eof()) .and. LANC->Matricula == FUN->Matricula

             if LANC->Valor <= 0
                LANC->(dbskip())
                loop
             endif

             if LANC->Anomes != XANOMES
                LANC->(dbskip())
                loop
             endif

             if EVCONT->(dbseek(LANC->Evento))

                if EVCONT->Evento == "100"
                   if BASE->(dbseek(FUN->Matricula+cANOMES))
                      if SH_PROCT->(qappend())
                         replace SH_PROCT->Data_lanc  with cDATA_CONT
                         replace SH_PROCT->Cont_db    with EVCONT->Cont_db
                         replace SH_PROCT->Cont_cr    with EVCONT->Cont_cr
                         replace SH_PROCT->Valor      with BASE->B_InssMS
                         replace SH_PROCT->Num_lote   with "RH" + XUSRNUM + strzero(CONFIG->Lote_cont,5) // monta numero do lote
                         EVENT->(dbseek(EVCONT->Evento))
                         replace SH_PROCT->Historico  with "VR FOLHA PAGTO "+left(FUN->Nome,25)
                         replace SH_PROCT->Centro     with EVCONT->Ccusto
                      endif
                   endif
                elseif EVCONT->Evento == "811"
                   if BASE->(dbseek(FUN->Matricula+cANOMES))
                      if SH_PROCT->(qappend())
                         replace SH_PROCT->Data_lanc  with cDATA_CONT
                         replace SH_PROCT->Cont_db    with EVCONT->Cont_db
                         replace SH_PROCT->Cont_cr    with EVCONT->Cont_cr
                         replace SH_PROCT->Valor      with (BASE->PROV_DT - BASE->DESC_DT)
                         replace SH_PROCT->Num_lote   with "RH" + XUSRNUM + strzero(CONFIG->Lote_cont,5) // monta numero do lote
                         EVENT->(dbseek(EVCONT->Evento))
                         replace SH_PROCT->Historico  with "VR 13 1 PARCELA "+left(FUN->Nome,25)
                         replace SH_PROCT->Centro     with EVCONT->Ccusto
                      endif
                   endif
                elseif EVCONT->Evento == "812"
                  if BASE->(dbseek(FUN->Matricula+cANOMES))
                     if SH_PROCT->(qappend())
                        EVENT->(dbseek(EVCONT->Evento))

                        replace SH_PROCT->Data_lanc  with cDATA_CONT
                        replace SH_PROCT->Cont_db    with EVCONT->Cont_db
                        replace SH_PROCT->Cont_cr    with EVCONT->Cont_cr
                        replace SH_PROCT->Valor      with (BASE->Prov_dt - BASE->DESC_DT)
                        replace SH_PROCT->Num_lote   with "RH" + XUSRNUM + strzero(CONFIG->Lote_cont,5) // monta numero do lote
                        replace SH_PROCT->Historico  with "VR 13 2 PARCELA "+left(FUN->Nome,25)
                        replace SH_PROCT->Centro     with EVCONT->Ccusto
                     endif
                  endif

                elseif EVCONT->Evento == "913"
                  if BASE->(dbseek(FUN->Matricula+cANOMES))
                     if SH_PROCT->(qappend())
                        EVENT->(dbseek(EVCONT->Evento))
                        replace SH_PROCT->Data_lanc  with cDATA_CONT
                        replace SH_PROCT->Cont_db    with EVCONT->Cont_db
                        replace SH_PROCT->Cont_cr    with EVCONT->Cont_cr
                        replace SH_PROCT->Valor      with LANC->Valor
                        replace SH_PROCT->Num_lote   with "RH" + XUSRNUM + strzero(CONFIG->Lote_cont,5) // monta numero do lote
                        EVENT->(dbseek(EVCONT->Evento))
                        replace SH_PROCT->Historico  with "VR 13 2 PARCELA "+left(FUN->Nome,25)
                        replace SH_PROCT->Centro     with EVCONT->Ccusto
                     endif
                  endif

                elseif EVCONT->Evento == "180"
                  if BASE->(dbseek(FUN->Matricula+cANOMES))
                     if SH_PROCT->(qappend())
                        EVENT->(dbseek(EVCONT->Evento))
                        replace SH_PROCT->Data_lanc  with cDATA_CONT
                        replace SH_PROCT->Cont_db    with EVCONT->Cont_db
                        replace SH_PROCT->Cont_cr    with EVCONT->Cont_cr
                        replace SH_PROCT->Valor      with (BASE->Prov_fr - BASE->Desc_fr)
                        replace SH_PROCT->Num_lote   with "RH" + XUSRNUM + strzero(CONFIG->Lote_cont,5) // monta numero do lote
                        EVENT->(dbseek(EVCONT->Evento))
                        replace SH_PROCT->Historico  with "PG FERIAS "+left(FUN->Nome,25)
                        replace SH_PROCT->Centro     with EVCONT->Ccusto
                     endif
                  endif

                else
                   if SH_PROCT->(qappend())
                      replace SH_PROCT->Data_lanc  with cDATA_CONT
                      replace SH_PROCT->Cont_db    with EVCONT->Cont_db
                      replace SH_PROCT->Cont_cr    with EVCONT->Cont_cr
                      replace SH_PROCT->Valor      with LANC->Valor
                      replace SH_PROCT->Num_lote   with "RH" + XUSRNUM + strzero(CONFIG->Lote_cont,5) // monta numero do lote
                      EVENT->(dbseek(EVCONT->Evento))
                      replace SH_PROCT->Historico  with "VR "+rtrim(left(EVENT->Descricao,15))+" "+left(FUN->Nome,25)
                      replace SH_PROCT->Centro     with EVCONT->Ccusto
                   endif
                endif

             endif

             LANC->(dbskip())
          enddo
       endif

       FUN->(dbskip())

    enddo

    SH_PROCT->(Dbclosearea())

return
