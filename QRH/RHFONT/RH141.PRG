
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE TABELA DE SALARIO FAMILIA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

private sBLOCO := qsbloc(10,29,17,78)

qpublicfields()
keyboard chr(6)

TBSF->(qview({{"Anomes/Ref.",1},;
              {"f141x()/Mˆs",0}},;
              "08012226BS",;
              {NIL,"f141a","f141b",NIL},;
              NIL,;
              q_msg_acesso_usr()+"/<D>uplica"))

qreleasefields()

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f141a
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
      qrbloc(10,29,sBLOCO)
   else
      qcopyfields()
   endif

   // LOOP __________________________________________________________________

   for nCONT := 1 to 6
       if nCONT != 1
          qsay(nCONT+9,34,nLIMITE+0.01,"@E 999,999.99")
       endif
       cMACRO   := "fSF_LIM" + str(nCONT,1)
       zTMP     := &cMACRO
       qmensa("Digite 0 para finalizar...")
       qgetx(nCONT+9,51,@zTMP,"@K@E 999,999.99")
       &cMACRO  := nLIMITE := zTMP

       if nLIMITE == 0 .or. nLIMITE == 999999.99
          nLIMITE := 999999.99
          &cMACRO := 999999.99
          qsay(nCONT+9,51,nLIMITE,"@E 999,999.99")
       endif

       cMACRO   := "fSF_VAL" + str(nCONT,1)
       zTMP := &cMACRO
       qmensa("Digite o valor do salario familia a pagar...")
       qgetx(nCONT+9,68,@zTMP,"@K@E 999,999.99")
       &cMACRO  := zTMP

       if nLIMITE > 999999
          do while ++nCONT < 7
             &("fSF_LIM" + str(nCONT,1)) := 0
             &("fSF_VAL" + str(nCONT,1)) := 0
          enddo
          exit
       endif
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

function f141b
   local cMACRO, nCONT, nLIMITE := 0

   qrbloc(10,29,sBLOCO)

   for nCONT := 1 to 6
      cMACRO := "SF_LIM" + str(nCONT,1)
      qsay(nCONT+9,34,nLIMITE+0.01,"@E 999,999.99")
      nLIMITE := &cMACRO
      qsay(nCONT+9,51,&cMACRO,"@E 999,999.99")
      cMACRO  := "SF_VAL" + str(nCONT,1)
      qsay(nCONT+9,68,&cMACRO,"@E 999,999.99")
      if nLIMITE >= 999999
         exit
      endif
   next
return
