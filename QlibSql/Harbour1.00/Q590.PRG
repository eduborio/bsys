function q590
// EMISSAO DO GERADOR DE RELATORIOS

#define K_CONV_BLOC "AARQ_EIND_CIND_FILT_RELA_COMA"

// VERIFICA PRIMEIRO SE CODIGO JA FORNECIDO _________________________________

parameters cPATH, cCODIGO

setcursor(0)

iif ( empty(cCODIGO) , cCODIGO := "" , NIL )

if len(cCODIGO) == 4
   i590a(cPATH,cCODIGO)
   return
endif

// EXECUTA VIEW DOS RELATORIOS DISPONIVEIS __________________________________

if ! quse(".\RPT\","RPTCAT",{"RPTCAT_C","RPTCAT_D"}) ; return .F. ; endif

RPTCAT->(qview({{"Descricao/Descri‡„o",2},;
                {"Codigo/C¢digo"      ,1},;
                {"Tipo_eject/Ejct"    ,0},;
                {"Tipo_rel/T.R."      ,0},;
                {"Linhas/Ln"          ,0},;
                {"Margem/Mg"          ,0}},"05002379",;
                {NIL,"i590a",NIL,NIL},;
                NIL,"ALT-O / ALT-P / im<P>rimir / <S>incronizar / <ESC>"))

RPTCAT->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA O PROCESSO DE IMPRESSAO _______________________________________

function i590a ( cPATH, cCODIGO )
   local cNOMEREL
   local nRECNO := RPTCAT->(recno())
   local nORDER := RPTCAT->(indexord())
   local cDESCR := RPTCAT->Descricao
   local aVET   := {}  // vetor com estrutura do relatorio
   local aCAB   := {}  // vetor com estrutura do cabecalho
   local aROD   := {}  // vetor com estrutura do rodape
   local aDAD   := {}  // vetor com estrutura de dados

   private cTIPO_REL, cTIPO_EJECT, nLINHAS, nMARGEM

   // SE SINCRONISMO, ENTAO ACIONA E RETORNA ________________________________

   if valtype(cPATH) == "N" .and. upper(chr(cPATH)) == "S" .and. qconf("Confirma Sincronismo ?")
      i_sincronismo()
      return ""
   endif

   // VERIFICA E CARREGA O RELATORIO ________________________________________

   if empty(cCODIGO)
      if upper(chr(cPATH)) <> "P" ; return "" ; endif
      cPATH    := ".\RPT\"
      cNOMEREL := cPATH + "R" + RPTCAT->Codigo + ".RPT"
   else
      cNOMEREL := cPATH + "R" + cCODIGO + ".RPT"
   endif

   if ! file(cNOMEREL)
      qmensa("Relat¢rio n„o encontrado...") ; return .F.
   endif

   cTIPO_REL   := RPTCAT->Tipo_Rel
   cTIPO_EJECT := RPTCAT->Tipo_Eject
   nLINHAS     := RPTCAT->Linhas
   nMARGEM     := RPTCAT->Margem

   RPTCAT->(dbclosearea())
   aVET := i_loadrpt(cNOMEREL)

   // CONVERSAO E EXECUCAO DO RELATORIO _____________________________________

   if i_conv_vetor(aVET,aCAB,aROD,aDAD)
      i_exec_vetor(aVET,cDESCR,aCAB,aROD,aDAD)
   endif

   // RETORNA SITUACAO ANTERIOR DO ARQUIVO DE CATALOGO ______________________

   dbcloseall()
   quse(cPATH,"RPTCAT",{"RPTCAT_C","RPTCAT_D"})
   RPTCAT->(dbsetorder(nORDER))
   RPTCAT->(dbgoto(nRECNO))

return ""

/////////////////////////////////////////////////////////////////////////////
// SINCRONIZA DIRETORIO PESQUISANDO RELATORIOS NOVOS E/OU ALTERADOS _________

static function i_sincronismo
   local nCONT, aDIR, zTMP
   local nORDER := RPTCAT->(indexord())
   local nRECNO := RPTCAT->(recno())
   local cPATH  := ".\RPT\"

   RPTCAT->(dbsetorder(1))
   aDIR := directory(cPATH+"R*.RPT")

   // VERIFICA RELATORIOS ___________________________________________________

   for nCONT := 1 to len(aDIR)
       qmensa("Verificando "+aDIR[nCONT,1]+"...")
       zTMP := substr(aDIR[nCONT,1],2,4)
       iif(RPTCAT->(dbseek(zTMP)),i_sinc_inc(zTMP,.F.),i_sinc_inc(zTMP,.T.))
   next

   // RETORNA SITUACAO ANTERIOR _____________________________________________

   RPTCAT->(dbsetorder(nORDER))
   RPTCAT->(dbgoto(nRECNO))
   select RPTCAT
return

// INCLUSAO AUTOMATICA DE RELATORIO NOVO DURANTE O SINCRONISMO ______________

static function i_sinc_inc ( cNOMEREL , lINC )
   local lALTERAR := .T.
   local cPATH    := ".\RPT\"

   cNOMEREL := "R" + cNOMEREL + ".RPT"
   if ! quse(cPATH,cNOMEREL) ; return .F. ; endif

   // VERIFICA SE NECESSITA DE ALTERACAO ____________________________________

   if ! lINC .and. ;
      RPTCAT->Codigo     == substr(cNOMEREL,2,4) .and. ;
      RPTCAT->Tipo_eject == (cNOMEREL)->(substr(Descricao,1,1)) .and. ;
      RPTCAT->Tipo_rel   == (cNOMEREL)->(substr(Descricao,2,1)) .and. ;
      RPTCAT->Linhas     == (cNOMEREL)->(val(substr(Descricao,3,2))) .and. ;
      RPTCAT->Margem     == (cNOMEREL)->(val(substr(Descricao,5,2))) .and. ;
      alltrim(RPTCAT->Descricao) == alltrim((cNOMEREL)->(substr(Descricao,7)))
      lALTERAR := .F.
   endif

   // EXECUTA INCLUSAO OU ALTERACAO _________________________________________

   if lALTERAR .and. qconf("Confirma "+iif(lINC,"incluir ","alterar ")+cNOMEREL+" ?")
      qmensa(iif(lINC,"Incluindo ","Alterando ")+cNOMEREL+"...")
      if RPTCAT->(iif(lINC,qappend(),qrlock()))
         replace RPTCAT->Codigo     with substr(cNOMEREL,2,4)
         replace RPTCAT->Descricao  with (cNOMEREL)->(substr(Descricao,7))
         replace RPTCAT->Tipo_eject with (cNOMEREL)->(substr(Descricao,1,1))
         replace RPTCAT->Tipo_rel   with (cNOMEREL)->(substr(Descricao,2,1))
         replace RPTCAT->Linhas     with (cNOMEREL)->(val(substr(Descricao,3,2)))
         replace RPTCAT->Margem     with (cNOMEREL)->(val(substr(Descricao,5,2)))
      endif
      RPTCAT->(qunlock())
   endif

   (cNOMEREL)->(dbclosearea())
return .T.

/////////////////////////////////////////////////////////////////////////////
// CARREGA O RELATORIO PARA O VETOR (NAO USA ESTRUTURA ORIGINAL) ____________

static function i_loadrpt ( cNOME )
   local aVET := {}
   if ! quse("",cNOME) ; return .F. ; endif
   do while ! eof()
      iif ( Ctrl == "+" , dbskip() , )
      qgirabarra()
      aadd(aVET,{Ctrl,Tipo,Descricao,""})
      dbskip()
   enddo
   dbclosearea()
return aVET

/////////////////////////////////////////////////////////////////////////////
// TRANSFORMA VETOR _________________________________________________________

static function i_conv_vetor ( aVET , aCAB , aROD , aDAD )
   local nCONT, nRET, aLIN := {1}, zTMP, bERR

   iif ( XPROG == "101" , bERR := errorblock({|x|i_ctrl_erro(x)}) , )

   // NUMERA LINHAS PARA INFORMACOES QUANDO ERRO ____________________________

   nRET := 1
   for nCONT := 1 to len(aVET)
       zTMP := aVET[nCONT,1]
       aVET[nCONT,1] := strzero(aLIN[nRET],3) + alltrim(zTMP)
       do case
          case zTMP == " "
               aLIN[nRET]++
          case zTMP == "S"
               aLIN[nRET]++
               nRET++
               aadd(aLIN,1)
               aVET[nCONT,2] := alltrim(aVET[nCONT,2])
          case zTMP == "R"
               nRET--
               asize(aLIN,len(aLIN)-1)
       endcase
   next

   // ELIMINA OS COMENTARIOS ________________________________________________

   nRET := len(aVET)
   for nCONT := 1 to len(aVET)
       if aVET[nCONT] == NIL ; exit ; endif
       if aVET[nCONT,2] == "--->"
          adel(aVET,nCONT)
          nRET-- ; nCONT--
       endif
   next
   asize(aVET,nRET)

   // ALIMENTA VETOR DE DADOS E EXCLUI DO VETOR PRINCIPAL ___________________

   nRET := len(aVET)
   for nCONT := 1 to len(aVET)
       if aVET[nCONT] == NIL ; exit ; endif
       if aVET[nCONT,2] == "DADO"
          aadd(aDAD,aVET[nCONT])
          adel(aVET,nCONT)
          nRET-- ; nCONT--
       endif
   next
   asize(aVET,nRET)
   for nCONT := 1 to len(aDAD)
       qmensa("Expandindo: "+aDAD[nCONT,2]+" na linha "+aDAD[nCONT,1])
       aDAD[nCONT,3] := &("{||" + alltrim(aDAD[nCONT,3]) + "}")
   next

   // NUMERACAO ADICIONAL PARA CONTROLE DE CABECALHOS, LOOPS, ETC. __________

   for nCONT := 1 to len(aVET)
       aVET[nCONT,1] := left(aVET[nCONT,1],3) + strzero(nCONT,3) + substr(aVET[nCONT,1],4,1)
   next

   // ALIMENTA VETOR DE CABECALHO EXTERNO ___________________________________

   zTMP := "000"
   nRET := len(aVET)
   for nCONT := 1 to len(aVET)
       if aVET[nCONT] == NIL ; exit ; endif
       if aVET[nCONT,2] == "LOOP" ; zTMP := substr(aVET[nCONT,1],4,3) ; endif
       if aVET[nCONT,2] == "CABE"
          aadd(aCAB,{zTMP,aVET[nCONT,3]})
//          adel(aVET,nCONT)
//          nRET-- ; nCONT--
       endif
   next
//   asize(aVET,nRET)
   for nCONT := 1 to len(aCAB)
       qmensa("Expandindo: "+aCAB[nCONT,2]+" na linha "+aCAB[nCONT,1])
       aCAB[nCONT,2] := &("{||" + alltrim(aCAB[nCONT,2]) + "}")
   next

   // ALIMENTA VETOR DE RODAPE EXTERNO ______________________________________

   // MONTA CONTROLE DE CONDICAO ____________________________________________

   aLIN := {}
   for nCONT := 1 to len(aVET)
       if aVET[nCONT,2] $ "COND"                  // se condicao "push"
          aadd(aLIN,strzero(nCONT,3))
       endif
       if aVET[nCONT,2] $ "FIMC"                  // se fim condicao
          for zTMP := len(aLIN) to 1 step -1      // busca cond anterior
              if len(aLIN[zTMP]) == 3
                 aLIN[zTMP] += strzero(nCONT,3)
              endif
          next
       endif
   next
   for nCONT := 1 to len(aLIN)
       aVET[val(left(aLIN[nCONT],3)),4] := val(right(aLIN[nCONT],3)) + 1
       aVET[val(right(aLIN[nCONT],3)),4] := val(left(aLIN[nCONT],3))
   next

   // MONTA CONTROLE DE LOOP ________________________________________________

   aLIN := {}
   for nCONT := 1 to len(aVET)
       if aVET[nCONT,2] $ "LOOP"                  // se loop "push"
          aadd(aLIN,strzero(nCONT,3))
       endif
       if aVET[nCONT,2] $ "FIML"                  // se fim loop
          for zTMP := len(aLIN) to 1 step -1      // busca loop anterior
              if len(aLIN[zTMP]) == 3
                 aLIN[zTMP] += strzero(nCONT,3)
                 exit // assim que marcou sai fora do loop...
              endif
          next
       endif
   next
   for nCONT := 1 to len(aLIN)
       aVET[val(left(aLIN[nCONT],3)),4] := val(right(aLIN[nCONT],3)) + 1
       aVET[val(right(aLIN[nCONT],3)),4] := val(left(aLIN[nCONT],3))
   next

   // EXPANDE PARA CODE BLOCKS ______________________________________________

   begin sequence
      for nCONT := 1 to len(aVET)
          qmensa("Expandindo: "+aVET[nCONT,2]+" na linha "+aVET[nCONT,1])
          if aVET[nCONT,2] $ "AARQ_EIND_CIND_FILT_RELA_COMA_LOOP_COND_CABE_RODA_VARI"
             aVET[nCONT,3] := "{||" + alltrim(aVET[nCONT,3]) + "}"
             aVET[nCONT,3] := &(aVET[nCONT,3])
          endif
      next
   recover
      return .F.
   end sequence

   iif ( XPROG == "101" , errorblock(bERR) , )

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO BASICO DE EXECUCAO DO RELATORIO ___________________________________

static function i_exec_vetor ( aVET , cDESCR , aCAB , aROD , aDAD )
   local nCONT := 1              // contador indice para o vetor
   local cLINHA                  // numero da linha sendo executada
   local cTIPO                   // tipo de linha
   local bCODE                   // variavel para conter o code block
   local aLOOP := {"000"}        // vetor com estrutura de loops
   local aROT := {"",cDESCR}     // vetor com descricao das rotinas
   local bERR

   iif ( XPROG == "101" , bERR := errorblock({|x|i_ctrl_erro(x)}) , )

   // EXECUCAO DOS DADOS PRIMEIRO ___________________________________________

   qlbloc(19,4,"TRACERPT",XDRV_SH+"QSBLOC.GLO")
   setcursor(1)
   for nCONT := 1 to len(aDAD)
       qmensa("")
       qsay(20,15,left(aROT[len(aROT)],55))
       qsay(21,15,aDAD[nCONT,2])
       qsay(21,29,left(aDAD[nCONT,1],3))
       eval(aDAD[nCONT,3])
   next
   setcursor(0)

   // AGORA ATIVA IMPRESSORA OU ARQUIVO EM DISCO ____________________________

   qmensa("Escolha impressora ou disco !")
   if ! qinitprn() ; return ; endif

   if cTIPO_EJECT $ "IA" ; eject ; endif  // eject em "I"nicio ou "A"mbos

   setprc(0,0)
   qmensa("Imprimindo...")
   nCONT := 1

   qlbloc(19,4,"TRACERPT",XDRV_SH+"QSBLOC.GLO")

   begin sequence

   // LOOP PRINCIPAL ________________________________________________________

   do while .T.
      if ! qlineprn() .or. ! XCONTPRN ; exit ; endif

      // CONTROLA SALTO DE PAGINA E CABECALHO PRINCIPAL (EXTERNO) ___________

      if (prow() > nLINHAS .or. XPAGINA == 0) .and. nLINHAS <> 0
         aeval(aLOOP,{|x,y|aLOOP[y]:=left(x,3)})
         qpageprn()
         i_exec_cab ( aCAB , "000" )
      endif

      // ATUALIZA VARIAVEIS _________________________________________________

      cLINHA := left(aVET[nCONT,1],3)
      cTIPO  := aVET[nCONT,2]
      bCODE  := aVET[nCONT,3]

      // ENTRADA E SAIDA DE SUB-ROTINA ______________________________________

      do case
         case right(aVET[nCONT,1],1) == "S" ; aadd(aROT,aVET[nCONT,3])
         case right(aVET[nCONT,1],1) == "R" ; asize(aROT,len(aROT)-1)
      endcase

      // ATUALIZA TELA ______________________________________________________

      qsay(20,15,left(aROT[len(aROT)],55))
      qsay(21,15,cTIPO)
      qsay(21,29,cLINHA)

      // CASE PRINCIPAL DE EXECUCAO _________________________________________

      do case

         // TIPOS COMUNS DE EXECUCAO DIRETA _________________________________

         case cTIPO $ "AARQ_EIND_CIND_FILT_RELA_COMA_VARI"

              eval(bCODE)
              nCONT++

         // TESTA INICIO DE CONDICAO ________________________________________

         case cTIPO == "COND"

              if eval(bCODE)
                 nCONT++
              else
                 nCONT := aVET[nCONT,4]
              endif

         // TESTA INICIO DE LOOP ____________________________________________

         case cTIPO == "LOOP"

              if eval(bCODE)
                 if aLOOP[len(aLOOP)] <> substr(aVET[nCONT,1],4,3)
                    aadd(aLOOP,substr(aVET[nCONT,1],4,3))
                 endif
                 if right(aLOOP[len(aLOOP)],1) <> "@"
                    i_exec_cab(aCAB,aLOOP[len(aLOOP)])
                    aLOOP[len(aLOOP)] += "@"
                 endif
                 nCONT++
              else
                 nCONT := aVET[nCONT,4]
                 asize(aLOOP,len(aLOOP)-1)
              endif

         // TESTA FINAL DE LOOP _____________________________________________

         case cTIPO == "FIML"

              nCONT := aVET[nCONT,4]

         // SOMENTE INCREMENTA CONTADOR _____________________________________

         case cTIPO $ "FIMC_SUB*_CABE"

              nCONT++

      endcase

      // TESTA FIM DO RELATORIO _____________________________________________

      if nCONT > len(aVET) ; exit ; endif

   enddo

   recover

   end sequence

   qstopprn(iif(cTIPO_EJECT$"FA",.T.,.F.))  // eject "F"inal ou "A"mbos

   iif ( XPROG == "101" , errorblock(bERR) , )

   release V*   // elimina variaveis criadas pelo gerador...

return .T.

/////////////////////////////////////////////////////////////////////////////
// EXECUCAO DO CABECALHO CORRESPONDENTE AO LOOP _____________________________

function i_exec_cab ( aCAB , cNUM )
   local nCONT, nPOINTER
   if ( nPOINTER := ascan(aCAB,{|x|x[1]==cNUM}) ) <> 0
      for nCONT := nPOINTER to len(aCAB)
          if aCAB[nCONT,1] <> cNUM ; exit ; endif
          eval(aCAB[nCONT,2])
      next
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// CONTROLE DE ERROS DA CONVERSAO E EXECUCAO ________________________________

function i_ctrl_erro ( oERRO )
   local cMENSAGEM

   oERRO:cansubstitute := .T.

   cMENSAGEM := i_traduz_erro ( oERRO )

   do case
      case ! empty(oERRO:filename)  ; cMENSAGEM += ";" + oERRO:filename
      case ! empty(oERRO:operation) ; cMENSAGEM += ";" + oERRO:operation
   endcase

   qbeep()
   alert("Erro: "+cMENSAGEM,{"OK"})
   break

return


///////////////////////////////
// DOCUMENTACAO DOS VETORES: //
///////////////////////////////
//
//  O VETOR FINAL DE EXECUCAO:
//
//       NIV.1 - NIV.2
//
//       VETOR - NUMERO DA LINHA: nnnxxx@, nnn = numero fisico da linha
//                                         xxx = numero sequencial nao repetido
//                                         @   = utilizado quando emitiu cabecalho interno
//
//               TIPO DE LINHA
//               CODIGO EXECUTAVEL - convertido para code-block
//               AVANCO OU RETORNO - pointer para avanco ou retrocesso
//
//

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// FUNCOES DIVERSAS PARA SEREM UTILIZADAS NO GERADOR DE RELATORIOS __________

function gimp ( nLIN , nCOL , cSTR )
   do case
      case valtype(nLIN) == "C"
           cSTR := nLIN
           nCOL := pcol()
           nLIN := prow()
      case valtype(nLIN) == "N" .and. valtype(nCOL) == "C"
           cSTR := nCOL
           nCOL := pcol() + nLIN
           nLIN := prow()
      otherwise
           nLIN += prow()
   endcase

   @ nLIN,nCOL say cSTR
return

function gsalta
   eject
return

function ginicvar ( cVAR , zVAL )
   public &cVAR := zVAL
return

function ginforma ( nLINHA , nCOLUNA , cMENSAGEM , cVARIAVEL , zINIC , cPIC , cVALID , cCOLOR )
   local cOLDCOLOR := setcolor(atcsc_sl(nLINHA,nCOLUNA))
   public &cVARIAVEL := zINIC

   if empty(cVALID)
      cVALID := ".T."
   else
      cVALID := strtran(cVALID,"@",cVARIAVEL)
   endif

   do while .T.
      @ nLINHA, nCOLUNA say cMENSAGEM get &cVARIAVEL picture cPIC color cCOLOR
      read
      if ! &cVALID
         tone(2000,1)
      else
         exit
      endif
   enddo

   setcolor(cOLDCOLOR)
return

function gcentra ( cSTRING , nLENG )
return padc(cSTRING,nLENG)

function gfiltro ( cSTRING )
   set filter to &cSTRING
return .T.

function grelacao ( cCAMPO, cALIAS )
   set relation to &cCAMPO into (cALIAS) additive
return .T.

function gclear ( nLIN1, nCOL1, nLIN2, nCOL2 , cCOLOR )
   cOLDCOLOR := setcolor(cCOLOR)
   @ nLIN1,nCOL1 clear to nLIN2,nCOL2
   setcolor(cOLDCOLOR)
return

