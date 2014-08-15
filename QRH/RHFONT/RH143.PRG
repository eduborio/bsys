
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE TABELA DE IRRF
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

private sBLOCO := qsbloc(10,23,15,78)

qpublicfields()
keyboard chr(6)

TBIR->(qview({{"Anomes/Ref.",1},;
              {"f141x()/Mˆs",0}},;
              "08012220BS",;
              {NIL,"f143a","f143b",NIL},;
              NIL,;
              q_msg_acesso_usr()+"/<D>uplica"))

qreleasefields()

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f143a
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
      qrbloc(10,23,sBLOCO)
   else
      qcopyfields()
   endif

   // LOOP __________________________________________________________________

   for nCONT := 1 to 6
       if nCONT != 1
          qsay(nCONT+9,28,nLIMITE+0.01,"@E 999,999.99")
       endif
       cMACRO   := "fIR_LIM" + str(nCONT,1)
       zTMP := &cMACRO
       qmensa("Digite 0 para finalizar...")
       qgetx(nCONT+9,45,@zTMP,"@K@E 999,999.99")
       &cMACRO  := nLIMITE := zTMP

       if nLIMITE == 0
          nLIMITE := 999999.99
          &cMACRO := 999999.99
          qsay(nCONT+9,45,nLIMITE,"@E 999,999.99")
       endif

       cMACRO   := "fIR_ALI" + str(nCONT,1)
       zTMP := &cMACRO
       qmensa("Digite a aliquota...")
       qgetx(nCONT+9,57,@zTMP,"@K@E 99.99")
       &cMACRO  := zTMP

       cMACRO   := "fIR_DED" + str(nCONT,1)
       zTMP := &cMACRO
       qmensa("Digite a dedu‡„o...")
       qgetx(nCONT+9,68,@zTMP,"@K@E 999,999.99")
       &cMACRO  := zTMP

       if nLIMITE > 999999
          do while ++nCONT < 7
             &("fIR_LIM" + str(nCONT,1)) := 0
             &("fIR_ALI" + str(nCONT,1)) := 0
             &("fIR_DED" + str(nCONT,1)) := 0
          enddo
          exit
       endif
   next
   qgetx(22,68,@fIR_DESC,"@K@E 999,999.99",NIL,.T.)

   // PEDE A DATA E ATUALIZA TETO ___________________________________________

   zTMP := recno()
   do while .T.
      f141y()
      dbseek(fANOMEs)
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
         qm2()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXECUTAR A CADA MOVIMENTACAO DO BROWSE _______________________

function f143b
   local cMACRO, nCONT, nLIMITE := 0

   qrbloc(10,23,sBLOCO)

   for nCONT := 1 to 6
      cMACRO := "IR_LIM" + str(nCONT,1)
      qsay(nCONT+9,28,nLIMITE+0.01,"@E 999,999.99")
      nLIMITE := &cMACRO
      qsay(nCONT+9,45,&cMACRO,"@E 999,999.99")
      cMACRO  := "IR_ALI" + str(nCONT,1)
      qsay(nCONT+9,57,&cMACRO,"@E 99.99")
      cMACRO  := "IR_DED" + str(nCONT,1)
      qsay(nCONT+9,68,&cMACRO,"@E 999,999.99")
      if nLIMITE >= 999999
         exit
      endif
   next
   qsay(22,68,IR_DESC,"@E 999,999.99")
return

