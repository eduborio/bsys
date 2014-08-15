 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE TABELA DE INSS AUTONOMO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM WIECZORKOVSKI
// PROGRAMADOR: A MESMA
// INICIO.....: SETEMBRO DE 1999
// OBS........:
// ALTERACOES.:

private sBLOCO := qsbloc(10,38,15,77)

qpublicfields()
keyboard chr(6)

TBIA->(qview({{"Anomes/Ref.",1},;
              {"f141x()/Mˆs",0}},;
              "08012220BS",;
              {NIL,"f145a","f145b",NIL},;
              NIL,;
              q_msg_acesso_usr()+"/<D>uplica"))

qreleasefields()

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f145a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA + "D"
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXECUTAR NO ENTER DO BROWSE __________________________________

static function i_edicao

   // VARIAVEIS _____________________________________________________________

   local nCONT, zTMP, cMACRO
   private nLIMITE := nALIQUO := 0

   // SE CONSULTA, RETORNA SEM FAZER NADA ___________________________________

   if cOPCAO == "C" ; return ; endif

   // SE DUPLICACAO, ENTAO ACIONA ROTINA E RETORNA __________________________

   if cOPCAO == "D" ; i_dup_tab() ; return ; endif

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
      qrbloc(10,38,sBLOCO)
   else
      qinitfields()
      qcopyfields()
   endif

   // LOOP __________________________________________________________________

   for nCONT := 1 to 10

//     if nCONT != 1
//        qsay(nCONT+9,42,nLIMITE+0.01,"@E 999,999.99")
//     endif

       cMACRO := "fIA_CLA" + strzero(nCONT,2)
       zTMP := &cMACRO
       qgetx(nCONT+9,25,@zTMP,"@!")
       &cMACRO := zTMP

       cMACRO   := "fIA_MES" + strzero(nCONT,2)
       zTMP := &cMACRO
       qgetx(nCONT+9,34,@zTMP,"@!")
       &cMACRO  := zTMP

       cMACRO   := "fIA_BAS" + strzero(nCONT,2)
       zTMP := &cMACRO
       qgetx(nCONT+9,43,@zTMP,"@R 999,999.99")
       &cMACRO  := zTMP

       cMACRO   := "fIA_ALI" + strzero(nCONT,2)
       zTMP := &cMACRO
       qgetx(nCONT+9,57,@zTMP,"@R 99.99")
       &cMACRO  := zTMP

       cMACRO   := "fIA_CON" + strzero(nCONT,2)
       zTMP := &cMACRO
       qgetx(nCONT+9,67,@zTMP,"@R 999,999.99")
       &cMACRO  := zTMP

   next


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

function f145b
   local cMACRO, nCONT, nLIMITE := 0

   qrbloc(10,38,sBLOCO)

   qinitfields()
   qcopyfields()

   for nCONT := 1 to 10

       cMACRO := "fIA_CLA" + strzero(nCONT,2)
       qsay(nCONT+9,25,&cMACRO)

       cMACRO   := "fIA_MES" + strzero(nCONT,2)
       qsay(nCONT+9,34,&cMACRO)

       cMACRO   := "fIA_BAS" + strzero(nCONT,2)
       qsay(nCONT+9,43,&cMACRO,"@R 999,999.99")

       cMACRO   := "fIA_ALI" + strzero(nCONT,2)
       qsay(nCONT+9,57,&cMACRO,"@R 99.99")

       cMACRO   := "fIA_CON" + strzero(nCONT,2)
       qsay(nCONT+9,67,&cMACRO,"@R 999,999.99")

   next

return
