/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE TABELA DE REGIME SIMPLIFICADO
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:
function ef116

private sBLOCO := qsbloc(10,23,22,78)

qpublicfields()
keyboard chr(6)

TBRS->(qview({{"Anomes/Ref.",1},;
              {"e116a()/Mˆs",0}},;
              "08012220BS",;
              {NIL,"f116a","f116b",NIL},;
              NIL,;
              q_msg_acesso_usr()+"/<D>uplica"))

qreleasefields()

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f116a
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
   nLIMITE := 1200000
   // LOOP __________________________________________________________________
   nFIM:=.T.
   for nCONT := 13 to 24
       if nCONT != 1
          qsay(nCONT-12+9,27,nLIMITE+0.01,"@E 9,999,999.99")
       endif
       cMACRO   := "fRS_LIM" + strzero(nCONT,2)
       zTMP := &cMACRO
       qmensa("Digite 0 para finalizar...")
       qgetx(nCONT-12+9,44,@zTMP,"@K@E 9,999,999.99")

       if Lastkey()==27;nFIM:=.F.;Exit;Endif

       &cMACRO  := nLIMITE := zTMP

       if nLIMITE == 0
          nLIMITE := 9999999.99
          &cMACRO := 9999999.99
          qsay(nCONT-12+9,44,nLIMITE,"@E 9,999,999.99")
       endif

       cMACRO   := "fRS_ALI" + strzero(nCONT,2)
       zTMP := &cMACRO
       qmensa("Digite a aliquota...")
       qgetx(nCONT-12+9,62,@zTMP,"@E 99.99")

       if Lastkey()==27;nFIM:=.F.;Exit;Endif

       &cMACRO  := zTMP

       cMACRO   := "fRS_IPI" + strzero(nCONT,2)
       zTMP := &cMACRO
       qmensa("Digite a dedu‡„o...")
       qgetx(nCONT-12+9,74,@zTMP,"@E 99.99")

       if Lastkey()==27;nFIM:=.F.;Exit;Endif

       &cMACRO  := zTMP

       if nLIMITE > 9999999
          do while ++nCONT < 24
             &("fRS_LIM" + strzero(nCONT,2)) := 0
             &("fRS_ALI" + strzero(nCONT,2)) := 0
             &("fRS_IPI" + strzero(nCONT,2)) := 0
          enddo
          exit
       endif
   next

   if ! nFIM; Return; Endif

   // PEDE A DATA E ATUALIZA TETO ___________________________________________

   zTMP := recno()
   do while .T.
      e116b()
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
         qm2()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXECUTAR A CADA MOVIMENTACAO DO BROWSE _______________________

function f116b
   local cMACRO, nCONT, nLIMITE := 0

   qrbloc(10,23,sBLOCO)
   nLIMITE := 1200000

   for nCONT := 13 to 24
      cMACRO := "RS_LIM" + strzero(nCONT,2)
      qsay(nCONT-12+9,27,nLIMITE+0.01,"@E 9,999,999.99")
      nLIMITE := &cMACRO
      qsay(nCONT-12+9,44,&cMACRO,"@E 9,999,999.99")
      cMACRO  := "RS_ALI" + strzero(nCONT,2)
      qsay(nCONT-12+9,62,&cMACRO,"@E 99.99")
      cMACRO  := "RS_IPI" + strzero(nCONT,2)
      qsay(nCONT-12+9,74,&cMACRO,"@E 99.99")
      if nLIMITE >= 9999999
         exit
      endif
   next
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA SOLICITACAO DE ANO MES _______________________________________

function e116a
return qnomemes(val(right(Anomes,2)))

static function e116b
   qmensa("Informe o ano e mes da tabela no formato AAAAMM...")
   qgetx(24,60,@fANOMES,"999999")
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DUPLICACAO DE REGISTRO DE TABELAS ____________________________

static function i_dup_tab
   local nMES := (alias())->(val(right(Anomes,2)))
   local nANO := (alias())->(val(left(Anomes,4)))

   if ! qconf("Confirma duplicar esta tabela p/ o proximo mˆs ?")
      return
   endif

   (alias())->(qpublicfields())
   (alias())->(qcopyfields())

   if ! (alias())->(qappend())
      qmensa("N„o foi possivel duplicar, tente novamente...","B")
   else
      nMES++
      if nMES > 12
         nMES := 1
         nANO++
      endif
      fANOMES := strzero(nANO,4) + strzero(nMES,2)
      (alias())->(qreplacefields())
   endif
   (alias())->(qreleasefields())
return

