
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE TABELA DE PARAMETROS GERAIS GERAL
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

private sBLOCO := qsbloc(08,63,19,78)

qpublicfields()
keyboard chr(6)

TBGR->(qview({{"Anomes/Ref.",1},;
              {"f141x()/Mˆs",0}},;
              "08012220BS",;
              {NIL,"f144a","f144b",NIL},;
              NIL,;
              q_msg_acesso_usr()+"/<D>uplica"+"/<R>ecalcula"))

qreleasefields()

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f144a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA + "D" + "R"
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXECUTAR NO ENTER DO BROWSE __________________________________

static function i_edicao

   // SE CONSULTA, RETORNA SEM FAZER NADA ___________________________________

   if cOPCAO == "C" ; return ; endif

   // SE DUPLICACAO, ENTAO ACIONA ROTINA E RETORNA __________________________

    if cOPCAO == "D" ; i_dup_tab() ; return ; endif

    if cOPCAO == "R" ; i_calc_ind() ; return ; endif


   // SE EXCLUSAO, CONFIRMA, EXCLUI E SAI ___________________________________

   if cOPCAO == "E"
      if qconf("Confirma exclus„o desta tabela ?")
         if qrlock()
            dbdelete()
            qunlock()
         else
            qm3()
         endif
      endif
      return
   endif

   // INICIALIZACAO DA INCLUSAO/ALTERACAO ___________________________________

   qpublicfields()

   if cOPCAO == "I"
      qinitfields()
      qrbloc(08,63,sBLOCO)
   else
      qcopyfields()
   endif

   // ENTRADA DE DADOS ______________________________________________________

   qmensa("Digite os dados conforme solicitado...")
   qgetx(08,68,@fGR_SEGVID ,"@E 999,999.99")
   qgetx(09,68,@fGR_INDAUX ,"@E 999,999.99")
   qgetx(10,68,@fGR_CESTA  ,"@E 999,999.99")
   qgetx(11,68,@fGR_SALMIN ,"@E 999,999.99")
   qgetx(12,68,@fGR_NATALI ,"@E 999,999.99")
   qgetx(14,73,@fGR_FGTS   ,"@E 99.99"     )
   qgetx(16,72,@fGR_TICKET ,"@E 999.99"    )
   qgetx(18,76,@fGR_D_UTIL ,"@E 99"        )
   qgetx(19,76,@fGR_D_DESC ,"@E 99"        )
   qgetx(20,73,@fIND_INFLAC,'@E 99.99'     )

   // PEDE A DATA E ATUALIZA TETO ___________________________________________

   zTMP := recno()
   do while .T.
      f141y()
      dbseek(fANOMES)
      if eof() .or. cOPCAO == "A"
         exit
      else
         qmensa("J  existe um Tabela para este mes !","B")
      endif
   enddo
   go zTMP

   // CONFIRMA E GRAVA ______________________________________________________

   if qconf("Confirma grava‡„o desta tabela ?")
      if iif(cOPCAO=="I",qappend(),qrlock())
         qreplacefields()
         qunlock()
      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXECUTAR A CADA MOVIMENTACAO DO BROWSE _______________________

function f144b
   qrbloc(08,63,sBLOCO)
   qsay(08,68,Gr_Segvid ,"@E 999,999.99")
   qsay(09,68,Gr_Indaux ,"@E 999,999.99")
   qsay(10,68,Gr_Cesta  ,"@E 999,999.99")
   qsay(11,68,Gr_Salmin ,"@E 999,999.99")
   qsay(12,68,Gr_Natali ,"@E 999,999.99")
   qsay(14,73,Gr_Fgts   ,"@E 99.99"     )
   qsay(16,72,Gr_ticket ,"@E 999.99"    )
   qsay(18,76,Gr_d_util ,"@E 99"        )
   qsay(19,76,Gr_d_desc ,"@E 99"        )
   qsay(20,73,ind_inflac,'@E 99.99'   )
   qsay(21,71,ind_corrig,'@E 99.9999'   )

return

function i_calc_ind()
 // TBGR->(dbgobottom())
    nINDCORRIGIDO = TBGR->ind_inflac / 100 + 1
    TBGR->(qrlock())
    replace TBGR->ind_corrig with nINDCORRIGIDO
    TBGR->(qunlock())

    for a = 1 to 12
      skip -1
      if TBGR->Ind_inflac < 0
        TBGR->(qrlock())
        replace TBGR->Ind_corrig with 1
        TBGR->(qunlock())
      else
        nINDCORRIGIDO = (TBGR->Ind_inflac/100+1) * nINDCORRIGIDO
        nINDCORRIGIDO = round(nINDCORRIGIDO,4)
        TBGR->(qrlock())
        replace TBGR->Ind_corrig with nINDCORRIGIDO
        TBGR->(qunlock())
      endif
    next
    TBGR->(dbgobottom())
return
