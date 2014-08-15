/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: ROTINA DE REAJUSTE DE SALARIOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: 1994
// OBS........:
// ALTERACOES.:

#include "inkey.ch"

private cPARM

SITUA->(dbSetFilter({|| Anomes == XANOMES .and. Situacao != 'H'},"Anomes == XANOMES .and. Situacao != 'H'"))

do while .T.
   qlbloc(5,0,"B412A","QBLOC.GLO")
   qmensa()
   cPARM := alert("Reajuste de Sal rio de...",{"FUNCIONARIOS","CARGOS"})
   if empty(cPARM) ; exit ; endif
   cPARM := iif(cPARM==1,"F","C")
   qsay(6,34,iif(cPARM=="F","FUNCIONARIOS","CARGOS"))
   i_proc()
enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL PARA PROCESSAR REAJUSTES ________________________________

static function i_proc

   // DECLARACAO DE VARIAVEIS __________________________________________________

   private cEXT, aPROP := {{space(6),space(30),0,0,0}}

   // CHAMA FUNCAO DE BROWSE ___________________________________________________

   setcursor(0)
   if cPARM == "C"
      select CARGO
      cEXT := "PRC"
   else
      select FUN
      cEXT := "PRF"
   endif

   i_edita_vetor()
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EDITAR VETOR DE REAJUSTE _____________________________________

static function i_edita_vetor

   // DEFINICAO E INICIALIZACAO DE VARIAVEIS ________________________________

   local   zTMP         // VARIAVEL TEMPORARIA
   local   oVIEW        // OBJETO BROWSE
   local   nTECLA       // USADO PARA PEGAR TECLA PRESSIONADA
   local   cTECLA       // TECLA JA CONVERTIDA
   private nROW := 1    // POINTER PARA AS LINHAS DO BROWSE

   setcolor("N/BG")

   // CRIA OBJETO BROWSE E CONFIGURA AMBIENTE _______________________________

   oVIEW := tbrowsenew ( 08 , 01 , 22 , 78 )

   oVIEW:headsep       := "Ä"
   oVIEW:colsep        := "³"
   oVIEW:autolite      := .F.
   oVIEW:skipblock     := { |x| x := askip(x,aPROP) }
   oVIEW:GoTopBlock    := { || nROW := 1 }
   oVIEW:GoBottomBlock := { || nROW := len(aPROP) }

   // ADICIONA AS COLUNAS DO BROWSE _________________________________________

   if cPARM == "C"
      oVIEW:AddColumn(TBColumnNew("Cargo"    ,{ || aPROP[nROW,1]                         } ))
      oVIEW:AddColumn(TBColumnNew("Descri‡„o",{ || aPROP[nROW,2]                         } ))
   else
      oVIEW:AddColumn(TBColumnNew("Matr."    ,{ || aPROP[nROW,1]                         } ))
      oVIEW:AddColumn(TBColumnNew("Nome"     ,{ || aPROP[nROW,2]                         } ))
   endif
   oVIEW:AddColumn(TBColumnNew("Sal.Atual",{ || transform(aPROP[nROW,3],"@E 999,999.99") } ))
   oVIEW:AddColumn(TBColumnNew("Reajuste" ,{ || transform(aPROP[nROW,5],"@E 999.999")    } ))
   oVIEW:AddColumn(TBColumnNew("Proposto" ,{ || transform(aPROP[nROW,4],"@E 999,999.99") } ))

   // INICIA EXIBICAO DO BROWSE _____________________________________________

   do while .T.

      // ESTABILIZA E/OU ESPERA POR TECLA ___________________________________

      do while ! oVIEW:stabilize() ; enddo

      qmensa("Restaura/Salva/Inc/Exc/Alt/Listar/Tot/Ordem/Man/Confirma/Zera/<Esc>")
      qsay(06,72,str(len(aPROP),4))

      nTECLA := 0

      qinver(row(),1,78)
      do while (nTECLA := qinkey()) == 0 ; enddo
      qinver(row(),1,78)

      if ! oVIEW:stable ; loop ; endif

      cTECLA := upper(chr(nTECLA))

      do case

         // MOVIMENTACAO PADRAO _____________________________________________

         case nTECLA == K_UP    ; oVIEW:Up()
         case nTECLA == K_DOWN  ; oVIEW:Down()
         case nTECLA == K_LEFT  ; oVIEW:Left()
         case nTECLA == K_RIGHT ; oVIEW:Right()
         case nTECLA == K_PGUP  ; oVIEW:pageup()
         case nTECLA == K_PGDN  ; oVIEW:pagedown()
         case nTECLA == K_HOME  ; oVIEW:gotop()
         case nTECLA == K_END   ; oVIEW:gobottom()

         // RECUPERA PROPOSTA _______________________________________________

         case cTECLA == "R"
              setcursor(1)
              i_restaura_arquivo()
              setcursor(0)
              oVIEW:refreshall()

         // SALVA PROPOSTA __________________________________________________

         case cTECLA == "S"
              setcursor(1)
              i_salva_arquivo()
              setcursor(0)
              oVIEW:refreshall()

         // INCLUI __________________________________________________________

         case cTECLA == "I"
              setcursor(1)
              i_inclui_funcs()
              setcursor(0)
              oVIEW:refreshall()

         // EXCLUI __________________________________________________________

         case cTECLA == "E"
              if qconf(iif(cPARM=="C",;
                           "Confirma exclus„o deste cargo na proposta ?",;
                           "Confirma exclus„o deste funcion rio na proposta ?"))
                 adel(aPROP,nROW)
                 asize(aPROP,len(aPROP)-1)
                 iif ( len(aPROP) == 0 , aPROP := {{space(6),space(30),0,0,0}} , NIL )
                 oVIEW:refreshall()
              endif

         // ALTERA SALARIO PROPOSTO _________________________________________

         case cTECLA == "A"
              setcursor(1)
              i_altera_proposta()
              setcursor(0)
              oVIEW:refreshall()

         // LISTAGEM DA PROPOSTA ____________________________________________

         case cTECLA == "L"
              i_emite_proposta()
              oVIEW:refreshall()

         // TOTAL DA PROPOSTA COM ESTATISTICA _______________________________

         case cTECLA == "T"
              i_calcula_total()
              oVIEW:refreshall()

         // ORDENACAO DA PROPOSTA ___________________________________________

         case cTECLA == "O"
              if cPARM == "C"
                 zTMP := alert("Ordena a proposta por...",{"Cargo","Descri‡„o"})
              else
                 zTMP := alert("Ordena a proposta por...",{"Matricula","Nome"})
              endif
              if zTMP == 1 .or. zTMP == 2
                 qmensa("Aguarde... ordenando vetor !")
                 asort ( aPROP ,,, { |x,y| x[zTMP]<y[zTMP] } )
                 oVIEW:refreshall()
              endif

         // MANUTENCAO DAS PROPOSTAS EM DISCO _______________________________

         case cTECLA == "M"
              setcursor(1)
              i_manutencao()
              setcursor(0)
              oVIEW:refreshall()

         // CONFIRMACAO DA PROPOSTA _________________________________________

         case cTECLA == "C"
              setcursor(1)
              i_confirmacao()
              setcursor(0)

         // ZERAR PROPOSTA ATUAL ____________________________________________

         case cTECLA == "Z"
              setcursor(1)
              if qconf("Confirma <ZERAR> a proposta atual ?")
                 aPROP := {{space(6),space(30),0,0,0}}
              endif
              setcursor(0)
              oVIEW:refreshall()

         // ESC _____________________________________________________________

         case nTECLA == K_ESC
              exit

      endcase

   enddo
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER O SKIP DO VETOR ________________________________________

static function askip ( nTO_JUMP, aPROP )

   local nJUMPED := 0

   if nROW + nTO_JUMP < 1
      nJUMPED := -nROW + 1
      nROW    := 1
   elseif nROW + nTO_JUMP > len(aPROP)
      nJUMPED := len(aPROP) - nROW
      nROW    := len(aPROP)
   else
      nJUMPED := nTO_JUMP
      nROW    += nTO_JUMP
   endif

return nJUMPED

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONFIRMACAO DA PROPOSTA ________________________________________

static function i_confirmacao
   local nOPCAO, nTIPO

   nTIPO := alert(">>> REAJUSTE DE SALARIO <<<;;"+;
                   "Escolha qual sal rio sera reajustado:",{"PROXIMO","ATUAL"})

   nOPCAO := alert("*** CONFIRMACAO DO REAJUSTE " + iif (nTIPO==1,"DO PROXIMO MES","DESTE MES") + " ***;;"+;
                    "Caso confirme esta proposta, todos os funcion rios desta;"+;
                    "ser„o atualizados, sendo que n„o havera possibilidade;"+;
                    "de retorno ao sal rio anterior !;;"+;
                    "Confirma o processamento ?",{"NŽO","SIM"})
   if nOPCAO == 2
      if qconf("Favor reconfirmar sua inten‡„o !")
         i_processa_confirmacao(nTIPO)
      endif
   endif

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA PROCESSAR A CONFIRMACAO ______________________________________

static function i_processa_confirmacao (nTIPO)
   local nCONT, lFALHA := .F.

   for nCONT := 1 to len(aPROP)

       // REAJUSTE POR CARGOS _______________________________________________

       if cPARM == "C"

          if CARGO->(dbseek(aPROP[nCONT,1]))
             qmensa("Processando: "+aPROP[nCONT,1]+"/"+aPROP[nCONT,2])
             if CARGO->(qrlock())
                CARGO->Salario := aPROP[nCONT,4]
                CARGO->(qunlock())
             else
                qmensa("Cargo n„o atualizado: "+CARGO->Codigo)
                lFALHA := .T.
                qbeep()
                qinkey(0)
             endif
          endif

       // REAJUSTE POR FUNCIONARIOS _________________________________________

       else

          if SITUA->(dbseek(aPROP[nCONT,1]))
             qmensa("Processando: "+aPROP[nCONT,1]+"/"+aPROP[nCONT,2])
             if SITUA->(qrlock())
                if nTIPO == 1
                   replace SITUA->Salariopm with aPROP[nCONT,4]
                else
                   replace SITUA->Salario   with aPROP[nCONT,4]
                   replace SITUA->Salarioma with aPROP[nCONT,3]
                endif
                SITUA->(qunlock())
             else
                qmensa("Funcionario n„o atualizado: "+aPROP[nCONT,1])
                lFALHA := .T.
                qbeep()
                qinkey(0)
             endif
          else
             qmensa("Funcionario n„o encontrado: "+aPROP[nCONT,1])
             lFALHA := .T.
             qbeep()
             qinkey(0)
          endif

       endif
   next

   // SE REAJUSTE POR CARGO, SINCRONIZA AGORA OS FUNCIONARIOS _______________

   if cPARM == "C"

      SITUA->(dbgotop())
      do while ! SITUA->(eof())

         FUN->(dbseek(SITUA->Matricula))

         qmensa("Processando: "+SITUA->Matricula+"/"+left(FUN->Nome,30))
         if ( nCONT := ascan(aPROP,{|x|x[1]==FUN->Cargo}) ) <> 0
            if SITUA->(qrlock())
               if nTIPO == 1
                  replace SITUA->Salariopm with aPROP[nCONT,4]
               else
                  replace SITUA->Salario   with aPROP[nCONT,4]
                  replace SITUA->Salarioma with aPROP[nCONT,3]
               endif
               SITUA->(qunlock())
            else
               qmensa("Funcionario n„o atualizado: "+SITUA->Matricula)
               lFALHA := .T.
               qbeep()
               qinkey(0)
            endif
         endif

         SITUA->(dbskip())

      enddo
   endif

   if lFALHA
      qmensa("PROCESSO NŽO FOI COMPLETADO ! EXECUTE NOVAMENTE...")
   else
      qmensa("PROCESSAMENTO COMPLETO COM SUCESSO !")
   endif

   qbeep()
   qinkey(0)

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CALCULAR O TOTAL DO REAJUSTE _________________________________

static function i_calcula_total

   local nCONT                 // contador para for-next
   local nTOTAL_ANTERIOR := 0  // total de salarios anterior
   local nTOTAL_PROPOSTO := 0  // total de salarios proposto
   local nREAJUSTE_MEDIO       // reajuste medio da proposta
   local nVARIACAO_FOLHA       // variacao da folha
   local zTMP1 := zTMP2 := 0   // variaveis temporarias

   qlbloc(12,03,"B412G","QBLOC.GLO")
   qmensa("aguarde... totalizando proposta !")

   // CALCULANDO REAJUSTE MEDIO (MEDIA PONDERADA) ___________________________

   for nCONT := 1 to len(aPROP)
       qsay ( 15 , 22 , len(aPROP)-nCONT , "9999" )
       if aPROP[nCONT,3] > 0
          zTMP1 += aPROP[nCONT,4] * aPROP[nCONT,5]
          zTMP2 += aPROP[nCONT,4]
       endif
   next
   nREAJUSTE_MEDIO := zTMP1 / zTMP2

   // CALCULANDO VARIACAO DA FOLHA __________________________________________

   for nCONT := 1 to len(aPROP)
       qsay ( 15 , 22 , len(aPROP)-nCONT , "9999" )
       nTOTAL_ANTERIOR += aPROP[nCONT,3]
       nTOTAL_PROPOSTO += aPROP[nCONT,4]
   next
   nVARIACAO_FOLHA := (nTOTAL_PROPOSTO / nTOTAL_ANTERIOR) * 100 - 100

   qsay(15,22,len(aPROP)     ,"9999"         )
   qsay(16,22,nTOTAL_ANTERIOR,"@E 999,999.99")
   qsay(17,22,nTOTAL_PROPOSTO,"@E 999,999.99")
   qsay(18,22,nREAJUSTE_MEDIO,"@E 999.999"   )
   qsay(19,22,nVARIACAO_FOLHA,"@E 999.999"   )

   qwait()

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ALTERAR A PROPOSTA ___________________________________________

static function i_altera_proposta
   local nPROPOSTA := aPROP[nROW,4]
   local nREAJUSTE := aPROP[nROW,5]

   qlbloc(14,04,"B412D","QBLOC.GLO")
   qsay(18,25,nREAJUSTE,"@E 999.999")
   qgetx(17,25,@nPROPOSTA,"@E 999,999.99")
   if lastkey() == 27 ; return NIL ; endif
   qgetx(18,25,@nREAJUSTE,"@E 999.999")

   do case
      case lastkey() == 27
           return NIL
      case nPROPOSTA != aPROP[nROW,4]
           aPROP[nROW,4] := nPROPOSTA
           aPROP[nROW,5] := nPROPOSTA/aPROP[nROW,3]*100-100
      case nREAJUSTE != aPROP[nROW,5]
           aPROP[nROW,4] := aPROP[nROW,3]*nREAJUSTE/100+aPROP[nROW,3]
           aPROP[nROW,5] := nREAJUSTE
   endcase

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA SALVAR ARQUIVO DE PROPOSTA ___________________________________

static function i_salva_arquivo
   local cFILE := space(8)
   local nHANDLE, nCONT
   qlbloc(15,04,"B412E","QBLOC.GLO")
   qgetx(18,14,@cFILE,"@!")
   if empty(cFILE) .or. lastkey()==27 ; return NIL ; endif
   cFILE := XDRV_RH + alltrim(cFILE) + "." + cEXT
   if file(cFILE)
      qbeep()
      if ! qconf("Arquivo j  existe ! grava por cima ?") ; return NIL ; endif
   endif
   qmensa("Gravando proposta "+cFILE+"...")
   nHANDLE := fcreate(cFILE)
   for nCONT := 1 to len(aPROP)
       fwrite(nHANDLE,aPROP[nCONT,1])
       fwrite(nHANDLE,aPROP[nCONT,2])
       fwrite(nHANDLE,str(aPROP[nCONT,3],13,2))
       fwrite(nHANDLE,str(aPROP[nCONT,4],13,2))
       fwrite(nHANDLE,str(aPROP[nCONT,5],7,3))
   next
   fclose(nHANDLE)
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RESTAURAR ARQUIVO DE PROPOSTA ________________________________

static function i_restaura_arquivo
   local aDIR := directory(XDRV_RH+"*."+cEXT)
   local zTMP, nHANDLE, nKEY, nCONT, aPRO := {}
   qlbloc(09,04,"B412F","QBLOC.GLO")
   for nCONT := 1 to len(aDIR)
       aadd(aPRO,aDIR[nCONT,1])
   next
   if len(aPRO) == 0
      qmensa("N„o h  propostas no disco !","B")
      return NIL
   endif
   qmensa("escolha a proposta a ser restaurada...")
   if (nKEY:=achoice(12,10,18,21,aPRO)) == 0 ; return NIL ; endif
   if ! qconf("Proposta atual sera perdida, confirma ?") ; return NIL ; endif
   aPROP := {} // limpa vetor principal
   nHANDLE := fopen(XDRV_RH+aPRO[nKEY])
   do while .T.
      zTMP := space(69)
      if (fread(nHANDLE,@zTMP,69)) != 69 ; exit ; endif
      aadd(aPROP,{substr(zTMP,01,06),;
                  substr(zTMP,07,30),;
                  val(substr(zTMP,37,13)),;
                  val(substr(zTMP,50,13)),;
                  val(substr(zTMP,63,7))})
   enddo
   fclose(nHANDLE)
   iif ( len(aPROP) == 0 , aPROP := {{space(6),space(30),0,0,0}} , NIL )
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A MANUTENCAO DAS PROPOSTA EM DISCO _____________________

static function i_manutencao
   local aDIR := directory(XDRV_RH+"*."+cEXT)
   local aPRO := {}
   local nKEY
   qlbloc(09,04,"B412F","QBLOC.GLO")
   qsay(10,06,"EXCLUSŽO DE PROPOSTAS")
   for nCONT := 1 to len(aDIR)
       aadd(aPRO,aDIR[nCONT,1])
   next
   if len(aPRO) == 0
      qmensa("N„o h  propostas no disco !","B")
      return NIL
   endif
   qmensa("ESCOLHA A PROPOSTA A SER EXCLUIDA !")
   if (nKEY:=achoice(12,10,18,21,aPRO)) == 0 ; return NIL ; endif
   if qconf("CONFIRMA ELIMINAR ESTA PROPOSTA ?")
      delete file (XDRV_RH+aPRO[nKEY])
   endif
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EMITIR UM RELATORIO DA PROPOSTA ______________________________

static function i_emite_proposta
   local nCONT
   local nTOTAL_ANTERIOR := nTOTAL_PROPOSTO := 0
   local nREAJUSTE_MEDIO, nVARIACAO_FOLHA
   local zTMP1 := zTMP2 := 0

   if ! qinitprn() ; return ; endif

   // LOOP PRINCIPAL ________________________________________________________

   for nCONT := 1 to len(aPROP)

      if ! qlineprn() ; return ; endif

      // CABECALHO __________________________________________________________

      if prow() > 50 .or. XPAGINA == 0
         qpageprn()
         qcabecprn("PROPOSTA DE REAJUSTE DE SALARIOS",80)
         if cPARM == "C"
            @ prow()+2,00 say "CARGO  DESCRICAO                          SAL.ANTERIOR     SAL.PROPOSTO  REAJUS."
         else
            @ prow()+2,00 say "MATRI. NOME                               SAL.ANTERIOR     SAL.PROPOSTO  REAJUS."
         endif
         @ prow()+1,00 say " "
         XPAGINA++
      endif

      // CORPO DA LISTAGEM __________________________________________________

      @ prow()+1,0        say aPROP[nCONT,1]
      @ prow()  ,pcol()+1 say aPROP[nCONT,2]
      @ prow()  ,pcol()+7 say aPROP[nCONT,3] picture "@E 999,999.99"
      @ prow()  ,pcol()+7 say aPROP[nCONT,4] picture "@E 999,999.99"
      @ prow()  ,pcol()+2 say aPROP[nCONT,5] picture "@E 999.999"

   next

   // CALCULANDO REAJUSTE MEDIO (MEDIA PONDERADA) ___________________________

   for nCONT := 1 to len(aPROP)
       if aPROP[nCONT,3] > 0
          zTMP1 += aPROP[nCONT,4] * aPROP[nCONT,5]
          zTMP2 += aPROP[nCONT,4]
       endif
   next
   nREAJUSTE_MEDIO := zTMP1 / zTMP2

   // CALCULANDO VARIACAO DA FOLHA __________________________________________

   for nCONT := 1 to len(aPROP)
       nTOTAL_ANTERIOR += aPROP[nCONT,3]
       nTOTAL_PROPOSTO += aPROP[nCONT,4]
   next
   nVARIACAO_FOLHA := (nTOTAL_PROPOSTO / nTOTAL_ANTERIOR) * 100 - 100

   // TOTALIZACAO ___________________________________________________________

   @ prow()+2,0        say "TOTAL.....................................:"
   @ prow()  ,pcol()+1 say nTOTAL_ANTERIOR picture "@E 999,999.99"
   @ prow()  ,pcol()+7 say nTOTAL_PROPOSTO picture "@E 999,999.99"

   @ prow()+2,0        say "REAJUSTE MEDIO....: " + transform(nREAJUSTE_MEDIO,"@E 999,999.999") + " %"
   @ prow()+1,0        say "VARIACAO DA FOLHA.: " + transform(nVARIACAO_FOLHA,"@E 999,999.999") + " %"

   // FINAL DA LISTAGEM _____________________________________________________

   qstopprn()

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INCLUIR MAIS FUNCIONARIOS NA PROPOSTA ________________________

static function i_inclui_funcs

   local zTMP1, zTMP2, cMACRO_LOOP, cMACRO_SKIP
   qlbloc(8,6,iif(cPARM=="C","B412C","B412B"),"QBLOC.GLO")

   private cFILTRO    := space(50)
   private cREAJUSTE  := space(50)
   private cMATRICULA := "      "
   private cCENTRO    := space(8)
   private cFILIAL    := space(4)
   private cCBO       := "       "
   private cCARGO     := "      "
   private cSIND      := "    "

   cMACRO_LOOP := iif ( cPARM == "C" , "! CARGO->(eof())"  , "! FUN->(eof())"  )
   cMACRO_SKIP := iif ( cPARM == "C" , "CARGO->(dbskip())" , "FUN->(dbskip())" )

   if cPARM == "F"
      qsay(09,20,cMATRICULA) ; qsay(09,42,iif(FUN->(dbseek(cMATRICULA)),left(FUN->Nome,30),space(30)))
      qsay(10,20,cCENTRO   ) ; qsay(10,42,iif(CCUSTO->(dbseek(cCENTRO)),CCUSTO->Descricao,space(30)))
      qsay(11,20,cFILIAL   ) ; qsay(11,42,iif(FILIAL->(dbseek(cFILIAL)),left(FILIAL->Razao,30),space(30)))
      qsay(12,20,cCBO      ) ; qsay(12,42,iif(CBO->(dbseek(cCBO))      ,CBO->Descricao   ,space(30)))
      qsay(13,20,cCARGO    ) ; qsay(13,42,iif(CARGO->(dbseek(cCARGO))  ,CARGO->Descricao ,space(30)))
      qsay(14,20,cSIND     ) ; qsay(15,42,iif(SIND->(dbseek(cSIND))    ,SIND->Descricao  ,space(30)))
      qsay(16,20,cFILTRO   )
      qsay(18,20,cREAJUSTE )
   else
      qsay(09,20,cCARGO    ) ; qsay(13,42,iif(CARGO->(dbseek(cCARGO))  ,CARGO->Descricao ,space(30)))
      qsay(11,20,cFILTRO   )
      qsay(13,20,cREAJUSTE )
   endif

   if cPARM == "F"
      dbSetFilter( {|| FUN->Data_adm <= qfimmes(XDATASYS)}, "FUN->Data_adm <= qfimmes(XDATASYS)" )
      view_fun(09,20,@cMATRICULA)
      if Lastkey()==27; Return; Endif
      cMATRICULA := iif( val(cMATRICULA)==0 , space(6) , strzero(val(cMATRICULA),6) )
      SITUA->(dbseek(cMATRICULA))
      qsay(09,20,cMATRICULA)
      qsay(09,42,iif(FUN->(dbseek(cMATRICULA)),left(FUN->Nome,30),space(30)))
      qmensa("<Pressione ESC para Cancelar...>")
      do while .T.
         view_ccusto(10,20,@cCENTRO)
         if Lastkey()==27; Exit; Endif
         if ! empty(cCENTRO)
//          if empty(right(cCENTRO,4))
            if empty(cCENTRO)
               qmensa("Centro de Custo n„o Anal¡tico !!","B")
               loop
            endif
            if ! CCUSTO->(dbseek(cCENTRO))
               qmensa("Centro de Custo n„o Cadastrado !!","B")
               loop
            endif
            qsay(10,42,left(CCUSTO->Descricao,30))
            exit
         else
            qsay(10,42,space(30))
            exit
         endif
      enddo

      view_filia(11,20,@cFILIAL)
      if Lastkey()==27; Return; Endif
      qsay(11,42,iif(FILIAL->(dbseek(cFILIAL)),left(FILIAL->Razao,30),space(30)))
      view_cbo(12,20,@cCBO)
      if Lastkey()==27; Return; Endif
      qsay(12,42,iif(CBO->(dbseek(cCBO)),left(CBO->Descricao,30),space(30)))
      view_cargo(13,20,@cCARGO)
      if Lastkey()==27; Return; Endif
      qsay(13,42,iif(CARGO->(dbseek(cCARGO)),left(CARGO->Descricao,30),space(30)))
      view_sind(14,20,@cSIND)
      if Lastkey()==27; Return; Endif
      qsay(14,42,iif(SIND->(dbseek(cSIND)),left(SIND->Descricao,30),space(30)))
   else
      view_cargo(09,20,@cCARGO)
      if Lastkey()==27; Return; Endif
      qsay(09,42,iif(CARGO->(dbseek(cCARGO)),left(CARGO->Descricao,30),space(30)))
   endif

   do while .T.
      qgetx(iif(cPARM=="C",11,16),20,@cFILTRO,"@!@S52")
      if len(alltrim(cFILTRO)) == 4 .and. FORM->(dbseek(alltrim(cFILTRO)))
         cFILTRO := FORM->Formula
         qsay(iif(cPARM=="C",11,16),25,FORM->Descricao)
      endif
      if empty(cFILTRO) .or. ! "U" $ valtype("&cFILTRO")
         exit
      endif
      qmensa("Erro de Sintaxe na f¢rmula de filtro !","B")
   enddo
   do while .T.
      qgetx(iif(cPARM=="C",13,18),20,@cREAJUSTE,"@!@S52")
      if len(alltrim(cREAJUSTE)) == 4 .and. FORM->(dbseek(alltrim(cREAJUSTE)))
         cREAJUSTE := FORM->Formula
         qsay(iif(cPARM=="C",13,18),25,FORM->Descricao)
      endif
      if empty(cREAJUSTE) .or. ! "U" $ valtype("&cREAJUSTE")
         exit
      endif
      qmensa("Erro de Sintaxe na f¢rmula de reajuste !","B")
   enddo

   iif(empty(cFILTRO),cFILTRO:=".T.",NIL)
   iif(empty(cREAJUSTE),cREAJUSTE:="SITUA->SALARIO",NIL)

   cFILTRO := &(rh_expan(cFILTRO))
   cREAJUSTE := &(rh_expan(cREAJUSTE))

   if qconf("Confirma inclus”es ?")

      if cPARM == "C"
         iif ( empty(cCARGO)     , CARGO->(dbgotop()) , NIL )
      else
         iif ( empty(cMATRICULA) , FUN->(dbgotop()) , NIL )
      endif

      do while &cMACRO_LOOP

         SITUA->(dbseek(FUN->Matricula))

         qmensa(iif(cPARM=="C",;
                    CARGO->Codigo+"-"+CARGO->Descricao,;
                    FUN->Matricula+"-"+left(FUN->Nome,30)))

         do while .T.
            if cPARM == "F"
               if FUN->Situacao == "H"                             ; exit ; endif
//             if ! empty(cCENTRO) .and. cCENTRO != FUN->Centro    ; exit ; endif
               if ! empty(cCENTRO) .and. cCENTRO != SITUA->Ccusto  ; exit ; endif
               if ! empty(cFILIAL) .and. cFILIAL != FUN->Filial    ; exit ; endif
               if ! empty(cCBO   ) .and. cCBO    != SITUA->Cbo     ; exit ; endif
               if ! empty(cCARGO ) .and. cCARGO  != SITUA->Cargo   ; exit ; endif
               if ! empty(cSIND  ) .and. cSIND   != FUN->Sindicato ; exit ; endif
            else
               if ! empty(cCARGO ) .and. cCARGO  != CARGO->Codigo  ; exit ; endif
            endif

            if ! empty(cFILTRO ) .and. ! eval(cFILTRO)           ; exit ; endif

            if cPARM == "C"
               if ascan(aPROP,{|x| x[1]==CARGO->Codigo }) != 0 ; exit ; endif
               zTMP1 := eval(cREAJUSTE)
               zTMP2 := zTMP1 / CARGO->Salario * 100 - 100
               aadd(aPROP,{CARGO->Codigo,left(CARGO->Descricao,30),CARGO->Salario,zTMP1,zTMP2})
            else
               if ascan(aPROP,{|x| x[1]==FUN->Matricula}) != 0 ; exit ; endif
               zTMP1 := eval(cREAJUSTE)
               zTMP2 := zTMP1 / SITUA->Salario * 100 - 100
               aadd(aPROP,{FUN->Matricula,left(FUN->Nome,30),SITUA->Salario,zTMP1,zTMP2})
            endif
            exit
         enddo

         if cPARM == "C"
            if ! empty(cCARGO)     ; exit ; endif
         else
            if ! empty(cMATRICULA) ; exit ; endif
         endif

         zTMP1 := &cMACRO_SKIP

      enddo
   endif

   if aPROP[1,1] = "  " .and. len(aPROP) > 1 // para eliminar o primeiro registro em branco
      adel(aPROP,1)
      asize(aPROP,len(aPROP)-1)
   endif

return NIL
