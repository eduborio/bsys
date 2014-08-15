
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE TABELA DE INSS DO FUNCIONARIO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

private sBLOCO := qsbloc(10,38,15,77)

qpublicfields()
keyboard chr(6)

TBIF->(qview({{"Anomes/Ref.",1},;
              {"f141x()/Mˆs",0}},;
              "08012234BS",;
              {NIL,"f142a","f142b",NIL},;
              NIL,;
              q_msg_acesso_usr()+"/<D>uplica"))

qreleasefields()

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f142a
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
      qcopyfields()
   endif

   // LOOP __________________________________________________________________

   for nCONT := 1 to 6
       if nCONT != 1
          qsay(nCONT+9,42,nLIMITE+0.01,"@E 999,999.99")
       endif
       cMACRO := "fIF_LIM" + str(nCONT,1)
       zTMP := &cMACRO
       zTMP := iif(zTMP>999999,0,zTMP)
       qmensa("Digite 0 para finalizar...")
       qgetx(nCONT+9,59,@zTMP,"@K@E 999,999.99","@==0.or.@>nLIMITE",.T.)
       &cMACRO := zTMP

       if &cMACRO == 0
          do while nCONT < 7
             cMACRO  := "fIF_LIM" + str(nCONT,1)
             &cMACRO := 999999.99
             cMACRO  := "fIF_ALI" + str(nCONT,1)
             &cMACRO := 0
             nCONT++
          enddo
          exit
       else
          nLIMITE := zTMP
          cMACRO  := "fIF_ALI" + str(nCONT,1)
          zTMP := &cMACRO
          qmensa("Digite a aliquota...")
          qgetx(nCONT+9,73,@zTMP,"@K@E 99.99",NIL,.T.)
          nALIQUO := &cMACRO := zTMP
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

   fIF_TETO = nLIMITE
   fIF_ALIQ = nALIQUO

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

function f142b
   local cMACRO, nCONT, nLIMITE := 0

   qrbloc(10,38,sBLOCO)

   for nCONT := 1 to 6
      if nCONT != 1
         qsay(nCONT+9,42,nLIMITE+0.01,"@E 999,999.99")
      endif
      cMACRO := "IF_LIM" + str(nCONT,1)
      if &cMACRO >= 999999.99
         qsay(nCONT+9,42,space(10))
         qsay(nCONT+9,59,space(10))
         exit
      else
         nLIMITE := &cMACRO
         qsay(nCONT+9,59,&cMACRO,"@E 999,999.99")
         cMACRO  := "IF_ALI" + str(nCONT,1)
         qsay(nCONT+9,73,&cMACRO,"@E 99.99")
      endif
   next
return

