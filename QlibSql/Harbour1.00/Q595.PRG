
function q595
#define K_LENBUF 8096      // tamanho do buffer de leitura
#define K_JANELA 15        // linhas da janela de edicao

/////////////////////////////////////////////////////////////////////////////
// EDITOR PARA ARQUIVOS .PRN

parameters cFILE_PRN

private nESCOLHA := 1
private aNAMES   := {}
private aSTRINGS := {}

if cFILE_PRN == NIL ; cFILE_PRN := "" ; endif

set printer to  // para fechar arquivo de impressao

if ! empty(cFILE_PRN)
   edita( cFILE_PRN , cFILE_PRN , .F. )
   return
endif

do while .T.
   aNAMES   := {}
   aSTRINGS := {}
   i_le_dir ( aNAMES , aSTRINGS )
   qlbloc(5,0,"B595A",XDRV_SH+"QSBLOC.GLO")
   //setcolor(atcsc_sl(06,01))
   setcleara("N/W")
   setcolor("N/W")
   keyboard chr(255)
//   if ( nESCOLHA := achoice(08,01,14,78,aSTRINGS,.T.,"i_ctrl595") ) == 0
   if ( nESCOLHA := achoice(08,01,14,78,aSTRINGS) ) == 0
      return
   endif
   edita( aNAMES[nESCOLHA] , aSTRINGS[nESCOLHA] , .F. )
enddo

return

/////////////////////////////////////////////////////////////////////////////
// CONTROLE DO ACHOICE ______________________________________________________

function i_ctrl595 ( nMODO, nITEM, nLINHA )
   local cMARCA, nCONT, nRETORNO := 2
   static nLASTLIN := -1
   static lCTRL := .T.

   iif ( nLASTLIN <> nLINHA , lCTRL := .T. , NIL )

   do case

      // ESC ABORTA A INDEXACAO ____________________________________________

      case lastkey() == 27  ;  nRETORNO := 0

      // ENTER SAI DO ACHOICE E INICIA A INDEXACAO _________________________

      case lastkey() == 13  ;  nRETORNO := 1

      // HOME VAI PARA O INICIO DA LISTA ___________________________________

      case lastkey() == 1
           keyboard chr(31) // ctrl+pgup
           nRETORNO := 2

      // END VAI PARA O FIM DA LISTA _______________________________________

      case lastkey() == 6
           keyboard chr(30) // ctrl+pgdw
           nRETORNO := 2

   endcase

   if nRETORNO == 2
      edita( aNAMES[nLINHA] , aSTRINGS[nLINHA] , .T. )
      if lCTRL
         lCTRL := .F.
         keyboard chr(255)
      endif
   endif

return nRETORNO

/////////////////////////////////////////////////////////////////////////////
// EDICAO DO ARQUIVO ________________________________________________________

function edita ( cFILE , cDESCRICAO , lPEDACO )
   local nLINX     := iif(lPEDACO,8,0)
   local aLINES    := {}
   local nPOINTER  := 0
   local nCONT     := 0
   local nKEY      := 0
   local nINI      := 1
   local nHANDLE
   local cBUFFER
   local cSTRING
   local nBYTES

   if ! lPEDACO
      qlbloc(5,0,"B595B",XDRV_SH+"QSBLOC.GLO")
      qsay(06,11,alltrim(cDESCRICAO))
   endif

   // ABRE ARQUIVO SOMENTE PARA LEITURA _____________________________________

   if (nHANDLE := fopen(cFILE,0)) < 0
      qmensa("Erro ao abrir arquivo "+cFILE+"...","B")
      return NIL
   endif

   // TRANSFERE O ARQUIVO PARA O VETOR DE LINHAS ____________________________

   do while .T.
      cBUFFER := space(K_LENBUF)
      nBYTES  := fread(nHANDLE,@cBUFFER,K_LENBUF)
      if ! atualiza_vetor(aLINES,cBUFFER,lPEDACO)
         qmensa("Arquivo foi lido at‚ o limite m ximo permitido !","B")
         exit
      endif
      if nBYTES != K_LENBUF .or. lPEDACO
         exit
      endif
   enddo
   if !fclose(nHANDLE)
      qmensa("Erro ao fechar arquivo !","B")
      return NIL
   endif

   nPOINTER := 0

   // LOOP DE ESCRITA EM TELA E TRATAMENTO DE TECLADO _______________________

   do while .T.
      setcleara("N/W")
      //clear_sl(08+nLINX,01,22,78,atnsc_sl(08+nLINX,01))
      clear_sl(08+nLINX,01,22,78)
      if nLINX == 0
         qsay(06,66,nPOINTER,"9999")
         qsay(06,74,nINI,"999")
      endif
      for nCONT := 1 to iif(len(aLINES)<K_JANELA,len(aLINES)-nLINX,K_JANELA-nLINX)
          qsay(nCONT+7+nLINX,0,chr(186)+substr(aLINES[nPOINTER+nCONT],nINI,78))
      next
      nKEY := qinkey(0)
      do case
         case nKEY == 27 .or. lPEDACO                     // ESC
              exit
         case nKEY == 05                                  // UP
              iif ( nPOINTER > 0 , nPOINTER-- , .F. )
         case nKEY == 24                                  // DOWN
              iif ( nPOINTER < len(aLINES)-K_JANELA , nPOINTER++ , .F. )
         case nKEY == 19                                  // LEFT
              iif ( nINI > 1 , nINI-- , .F. )
         case nKEY == 04                                  // RIGHT
              nINI++
         case nKEY == 01                                  // HOME
              nINI := 1
         case nKEY == 06                                  // END
              for nCONT := 1 to iif(len(aLINES)<K_JANELA,len(aLINES),K_JANELA)
                  if len(aLINES[nPOINTER+nCONT]) >= 77
                     if nINI <  len(rtrim(aLINES[nPOINTER+nCONT]))-77
                        nINI := len(rtrim(aLINES[nPOINTER+nCONT]))-77
                     endif
                  endif
              next
              nINI := iif ( nINI < 1 , 1 , nINI )
         case nKEY == 18                                  // PAGE UP
              nPOINTER -= K_JANELA
         case nKEY == 03                                  // PAGE DOWN
              nPOINTER += K_JANELA
              nPOINTER := iif ( nPOINTER > len(aLINES)-K_JANELA , len(aLINES)-K_JANELA , nPOINTER )
         case nKEY == 31                                  // CTRL PAGE UP
              nPOINTER := 1
         case nKEY == 30                                  // CTRL PAGE DOWN
              nPOINTER := len(aLINES)-K_JANELA
         case nKEY == 09                                  // TAB
              nINI += 10
         case nKEY == 271                                 // SHIFT TAB
              nINI -= 10
              nINI := iif ( nINI < 1 , 1 , nINI )
         case nKEY == 07                                  // DEL
              delete file (cFILE)
              exit
         case nKEY == 28
              faz_help()
      endcase
      if nPOINTER < 0 .or. len(aLINES) < K_JANELA
         nPOINTER := 0
      endif
   enddo

return NIL

/////////////////////////////////////////////////////////////////////////////
// TELA DE HELP _____________________________________________________________

function faz_help()
   local C_LIN := 5, C_COL := 5
   qsay(C_LIN+01,C_COL,"°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°")
   qsay(C_LIN+02,C_COL,"°°                                                                      °°")
   qsay(C_LIN+03,C_COL,"°°  setas...... movimenta‡„o do relat¢rio (horizontal e vertical)       °°")
   qsay(C_LIN+04,C_COL,"°°  home....... primeira coluna do relat¢rio                            °°")
   qsay(C_LIN+05,C_COL,"°°  end........ £ltima coluna do relat¢rio                              °°")
   qsay(C_LIN+06,C_COL,"°°                                                                      °°")
   qsay(C_LIN+07,C_COL,"°°  pgup....... avan‡a o relat¢rio de 15 em 15 linhas                   °°")
   qsay(C_LIN+08,C_COL,"°°  pgdw....... retrocede o relat¢rio de 15 em 15 linhas                °°")
   qsay(C_LIN+09,C_COL,"°°                                                                      °°")
   qsay(C_LIN+10,C_COL,"°°  ctrl+pgup.. move-se para o in¡cio do relat¢rio (primeira linha)     °°")
   qsay(C_LIN+11,C_COL,"°°  ctrl+pgdw.. move-se para o fim do relat¢rio    (£ltima linha)       °°")
   qsay(C_LIN+12,C_COL,"°°  tab........ move o relat¢rio para esquerda de 10 em 10 colunas      °°")
   qsay(C_LIN+13,C_COL,"°°  shift+tab.. move o relat¢rio para direita de 10 em 10 colunas       °°")
   qsay(C_LIN+14,C_COL,"°°                                                                      °°")
   qsay(C_LIN+15,C_COL,"°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°")
   qinkey(0)
   qsay(C_LIN+01,C_COL,"°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°")
   qsay(C_LIN+02,C_COL,"°°                                                                      °°")
   qsay(C_LIN+03,C_COL,"°°  del........ elimina o relat¢rio selecionado                         °°")
   qsay(C_LIN+04,C_COL,"°°  ins........ insere caracteres especiais para impressora             °°")
   qsay(C_LIN+05,C_COL,"°°                                                                      °°")
   qsay(C_LIN+06,C_COL,"°°                                                                      °°")
   qsay(C_LIN+07,C_COL,"°°  alt+I...... marca inicio da impress„o                               °°")
   qsay(C_LIN+08,C_COL,"°°  alt+F...... marca fim da impress„o                                  °°")
   qsay(C_LIN+09,C_COL,"°°                                                                      °°")
   qsay(C_LIN+10,C_COL,"°°  alt+P...... imprime o relat¢rio                                     °°")
   qsay(C_LIN+11,C_COL,"°°                                                                      °°")
   qsay(C_LIN+12,C_COL,"°°                                                                      °°")
   qsay(C_LIN+13,C_COL,"°°                                                                      °°")
   qsay(C_LIN+14,C_COL,"°°                                                                      °°")
   qsay(C_LIN+15,C_COL,"°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°")
   qinkey(0)
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA LER O DIRETORIO E ATUALIZAR OS VETORES _______________________

static function i_le_dir ( aNAMES , aSTRINGS )
   local aFILES, nCONT, cMASCARA

   cMASCARA := "R" + iif(XUSRNUM=="000","???",XUSRNUM) + "???.PRN"

   aFILES := directory(cMASCARA)

   for nCONT := 1 to len(aFILES)
       aadd ( aNAMES   , aFILES[nCONT,1] )
       zTMP := aFILES[nCONT,1]    + "      " + ;
           str(aFILES[nCONT,2],6) + "      " + ;
          dtoc(aFILES[nCONT,3])   + "      " + ;
          left(aFILES[nCONT,4],5)
       aadd ( aSTRINGS , padc(zTMP,78) )
   next

   // CONTEUDO DOS VETORES:
   // aNAMES   := NOMES DO ARQUIVO COM EXTENSAO
   // aSTRINGS := DESCRICAO COMPLETA PARA FAZER ACHOICE

   asort(aNAMES  ,,,{|x,y|x>y})  // DESCEND ORDER
   asort(aSTRINGS,,,{|x,y|x>y})  // DESCEND ORDER
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR VETOR ______________________________________________

static function atualiza_vetor ( aLINES , cPARCIAL , lPEDACO )
   static cBUFFER := ""
   local  nPOINTER

   iif ( empty(aLINES) , cBUFFER := "" , NIL ) // para limpar no inicio

   cBUFFER += cPARCIAL

   do while .T.
      iif(lPEDACO,NIL,qsay(08,01,"Linhas lidas: "+str(len(aLINES))))

      if ( nPOINTER := at(chr(13),cBUFFER) ) == 0 ; exit ; endif

      aadd ( aLINES , substr(cBUFFER,1,nPOINTER-1) )

      if substr(cBUFFER,nPOINTER+1,1) == chr(10)
         cBUFFER := substr( cBUFFER , nPOINTER+2 )
      else
         cBUFFER := substr( cBUFFER , nPOINTER+1 )
      endif

      if memory(0) < 5 .or. len(aLINES) == 4096
         return .F.
      endif
   enddo

return .T.

