
#include "inkey.ch"
#include "setcurs.ch"

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER QGET, E SETAR F9 PARA FAZER BROWSE _____________________

/* DOCUMENTACAO DOS PARAMETROS:

nLIN - linha para o qget
nCOL - coluna para o qget
zGET - variavel get por referencia
cPIC - picture
cVAL - valid
cWHE - when
cCOR - cor
aVET - vetor de campos
cARE - area
        <T>otal
        <P>arcial
        <C>entralizado
        <I>nversao
        <B>loco automatico
        <S>alva tela
        <E>nter p/ pesquisa
        <F>iltro ?

aFUN - funcao de controle
cFIL - filtro de selecao
cMEN - mensagem
cKOR - cor para o browse


*/


function duview ( nLIN ,; // linha  para qget                 (n)
                 nCOL ,; // coluna para qget                 (n)
                 zGET ,; // variavel get por referencia      (?)
                 cPIC ,; // picture                          (c)
                 cVAL ,; // valid                            (c)
                 cWHE ,; // when                             (l)
                 cCOR ,; // cor                              (n,c)
                 aVET ,; // vetor de campos para o browse    (a)
                 cARE ,; // area                             (c)
                 aFUN ,; // funcao para ser acionada         (c)
                 cFIL ,; // filtro de selecao                (c)
                 cMEN ,; // mensagem - qmensa()              (c)
                 cKOR )  // cor para o browse                (c)

   local sMENSAGEM := qsbloc(24,07,24,78)

   XFLAG := .T.

   // CASO PRIMEIRO PARAMETRO VETOR, ENTAO PASSA DIRETO P/ VIEWX ____________

   if valtype(nLIN) == "A"
      duviewx(nLIN,nCOL,zGET,cPIC,cVAL,cWHE)
      return NIL
   endif

   // UTILIZA "F9" PARA FAZER BROWSE ________________________________________

   setkey( -8 , { || duviewx(aVET,cARE,aFUN,cFIL,cMEN,cKOR) } )
   qmensa("F9 para view na tabela associada...")
   qgetx(nLIN,nCOL,@zGET,cPIC,cVAL,cWHE,cCOR)

   // RESTAURA MENSAGEM E DESATIVA SET KEY __________________________________

   qrbloc(24,07,sMENSAGEM)
   setkey( -8 , NIL )

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ENTRAR DIRETO NO VIEW ________________________________________

function duviewx (aESTRUCT,cAREA,aFUNCOES,cFILTRO,cMENSAGEM,cKOLOR)

   local nTOP     := 8    // topo do browse
   local nBOTTOM  := 20   // base do browse
   local nLEFT    := 0    // esquerda do browse
   local nRIGHT   := 0    // direita do browse
   local sTELA1           // salva tela quando entra em browse
   local sTELA2           // salva tela quando executa funcao
   local zTMP             // variavel temporaria
   local oVIEW            // objeto browse
   local nCURSOR          // situacao do cursor
   local cCOLOR           // salva cor anterior
   local nORDER_OLD       // salva set order anterior
   local cMEN             // salva mensagem
   local nCOLUMN          // objeto coluna
   local nCONTADOR        // contador para for/next
   local lBOTAO   := .F.  // .T. quando o botao pressionado
   local nLINHA           // linha da barra de posicionamento
   private cSEEK          // get para seek (private p/ code block)
   private nTECLA         // tecla pressionada

   // VERIFICA QUANTIDADE DE INDEXADORES ASSOCIADOS _________________________

   zTMP := 0
   for nCONTADOR := 1 to len(aESTRUCT)
       if aESTRUCT[nCONTADOR,2] != 0 ; zTMP++ ; endif
   next

   // INICIALIZACOES DIVERSAS _______________________________________________

   cAREA   := iif ( "U" $ upper(valtype(cAREA))   , "C" , cAREA   )
   if aESTRUCT != NIL ; private aVETCOL := aESTRUCT ; endif

   // PROCESSA VETOR DE FUNCOES _____________________________________________
   // 1: funcao para ser acionada com enter
   // 2: funcao para tratar qualquer tipo de tecla
   // 3: funcao de atualizacao de tela
   // 4: funcao para processar a string de pesquisa

   if ! "A" $ upper(valtype(aFUNCOES))
      aFUNCOES := array(4)
   endif

   if "C" $ upper(valtype(aFUNCOES[1]))
      if aFUNCOES[1] == "EXIT"
         aFUNCOES[1] := { || "EXIT" }
      else
         if "(" $ aFUNCOES[1]
            aFUNCOES[1] := &( "{||" + aFUNCOES[1] + "}" )
         else
            aFUNCOES[1] := &( "{||" + aFUNCOES[1] + "()" + "}" )
         endif
      endif
   endif

   if "C" $ upper(valtype(aFUNCOES[2]))
      if aFUNCOES[2] == "EXIT"
         aFUNCOES[2] := { || "EXIT" }
      else
         aFUNCOES[2] := &( "{||" + aFUNCOES[2] + "(nTECLA)" + "}" )
      endif
   endif

   if "C" $ upper(valtype(aFUNCOES[3]))
      aFUNCOES[3] := &( "{||" + aFUNCOES[3] + "()" + "}" )
   endif

   if "C" $ upper(valtype(aFUNCOES[4]))
      aFUNCOES[4] := &( "{||" + aFUNCOES[4] + "(cSEEK)" + "}" )
   endif

   // CONFIGURA MENSAGEM DE ACORDO COM AMBIENTE SETADO ______________________

   if "U" $ upper(valtype(cMENSAGEM))        // somente se nao passou mensagem
      cMENSAGEM := "<ESC>-Retorna "          // <esc> sempre aparece
      if ! empty(aFUNCOES[1])                // verifica <enter>
         cMENSAGEM += "<ENTER>-Escolha "
      endif
      if zTMP >= 2                           // verifica ordens disponiveis
         cMENSAGEM += "<ALT_O>rdem "
      endif
      cMENSAGEM += "<ALT_P>esquisa "
   endif

   if zTMP < 2 .and. "ALT-O/" $ cMENSAGEM
      cMENSAGEM := strtran(cMENSAGEM,"ALT-O/","")
   endif

   // CALCULA DIMENSOES DO BROWSE ___________________________________________

   do case
      case cAREA = "C"
           ducentraview ( aVETCOL , @nLEFT , @nRIGHT )
      case cAREA = "P"
           nTOP := 05 ; nBOTTOM := 23 ; nLEFT := 00 ; nRIGHT := 79
      case cAREA = "T"
           nTOP := 00 ; nBOTTOM := 23 ; nLEFT := 00 ; nRIGHT := 79
      otherwise
           nTOP    := val(substr(cAREA,1,2))
           nLEFT   := val(substr(cAREA,3,2))
           nBOTTOM := val(substr(cAREA,5,2))
           nRIGHT  := val(substr(cAREA,7,2))
   endcase

   // SALVA BLOCO, CURSOR, COR, ORDER, MENSAGEM _____________________________

   if ! "S" $ cAREA
      sTELA1  := qsbloc ( nTOP, nLEFT, nBOTTOM, nRIGHT )
      if cKOLOR == NIL
         cCOLOR := setcolor(XVIEWCOLOR)
      else
         cCOLOR := setcolor(cKOLOR)
      endif
   else
      cCOLOR  := setcolor(atcsc_sl(nTOP,nLEFT))
   endif
   nCURSOR    := SetCursor(0)
   cMEN       := qsbloc(23,20,23,78)

   nORDER_OLD := indexord()
   dbsetorder ( aVETCOL[1,2] )

   // SE NAO CONTIVER FILTRO VAI PARA O INICIO DO ARQUIVO __________________

   if ! "F" $ cAREA
      if empty(cFILTRO)
         //dbgotop()
      else
         zTMP := eval(cFILTRO[2])
      endif
   endif

   // CONSTROI BLOCO ________________________________________________________

   if ! "B" $ cAREA
      dumontaview ( nTOP , nLEFT , nBOTTOM , nRIGHT )
   endif

   // CRIA OBJETO TBROWSE ___________________________________________________

   if "B" $ cAREA
      oVIEW := tbrowsedb ( nTOP    , nLEFT    , nBOTTOM    , nRIGHT     )
   else
      oVIEW := tbrowsedb ( nTOP + 1, nLEFT + 2, nBOTTOM - 1, nRIGHT - 2 )
   endif

   oVIEW:headsep  := "Ä"
   oVIEW:colsep   := "³"

   if ! "I" $ cAREA ; oVIEW:autolite := .F. ; endif

   // CONTROLE DE FILTRO ____________________________________________________

   if ! empty(cFILTRO)
      if "C" $ upper(valtype(cFILTRO[1]))
         oVIEW:skipblock := { |X| duskipper(X,cFILTRO[1]) }
      endif
      oVIEW:GoTopBlock    := cFILTRO[2]
      oVIEW:GoBottomBlock := cFILTRO[3]
   endif

   // ADICIONA OS CAMPOS SOLICITADOS ________________________________________

   for nCONTADOR = 1 to len(aVETCOL)
       oVIEW:addcolumn( tbcolumnnew(boblock(aVETCOL[nCONTADOR,1]), dublock(aVETCOL[nCONTADOR,1])) )
   next

   // INICIALIZA MOUSE SE ESTIVER INSTALADO _________________________________

   if XMOUSEOK
      qmousecu(1)
      lBOTAO   := .T.
   endif

   // INICIALIZA BROWSE _____________________________________________________

   if ( eof() , dbgotop() , NIL )

   do while .T.

      qmensa(cMENSAGEM)
      iif ( XMOUSEOK , qmousecu(0) , NIL )
      oVIEW:ForceStable()
      iif ( XMOUSEOK , qmousecu(1) , NIL )
      nLINHA := row()

      if ! "I" $ cAREA ; qinver(nLINHA,nLEFT+2,nRIGHT-nLEFT-3) ; endif

      iif ( aFUNCOES[3] != NIL , eval(aFUNCOES[3]) , NIL )

      do while (nTECLA := qinkey()) == 0

         iif ( XMOUSEOK , qmousecu(1) , NIL )

         // REFRESH NO ARQUIVO ______________________________________________

         if int(seconds()) % XREFRESH == 0
            if (nTECLA := qinkey(0.7)) != 0 ; exit ; endif
            iif ( aFUNCOES[3] != NIL , eval(aFUNCOES[3]) , NIL )
            oVIEW:refreshall()
            iif ( ! "I" $ cAREA , qinver(nLINHA,nLEFT+2,nRIGHT-nLEFT-3) , NIL )
            oVIEW:ForceStable()
            //do while !oVIEW:stabilize() ; enddo
            iif ( ! "I" $ cAREA , qinver(nLINHA,nLEFT+2,nRIGHT-nLEFT-3) , NIL )
         endif

         // VERIFICA BOTAO DO MOUSE _________________________________________

         if XMOUSEOK .and. lBOTAO .and. qmousebo() == 2
            do while .T.
               if qmousebo() == 0 ; exit ; endif
            enddo
            keyboard chr(27)
         endif

         if XMOUSEOK .and. lBOTAO .and. qmousebo() == 1
            lBOTAO := .F.
            zTMP := chrsc_sl(qmouseli(),qmouseco(),"S")
            if chrsc_sl(qmouseli(),qmouseco()-1,"S") == "º"
               do case
                  case zTMP == "I" ; nTECLA := K_HOME  ; exit
                  case zTMP == "C" ; nTECLA := K_PGUP  ; exit
                  case zTMP == "" ; nTECLA := K_UP    ; exit
                  case zTMP == "" ; nTECLA := K_DOWN  ; exit
                  case zTMP == "B" ; nTECLA := K_PGDN  ; exit
                  case zTMP == "F" ; nTECLA := K_END   ; exit
               endcase
            endif
            if chrsc_sl(qmouseli(),qmouseco()+1,"S") == "º"
               do case
                  case zTMP == "E" ; nTECLA := K_ESC   ; exit
                  case zTMP == "P" ; nTECLA := K_ALT_P ; exit
                  case zTMP == "O" ; nTECLA := K_ALT_O ; exit
                  case zTMP == "X" ; nTECLA := K_ENTER ; exit
               endcase
            endif
            if isdigit(zTMP) .or. (isalpha(zTMP).and.isupper(zTMP))
               if qmouseli() == 24 .and. qmouseco() > 11
                  keyboard zTMP
               endif
            endif
            if qmouseli() > nTOP+2 .and. qmouseli() < nBOTTOM
               if qmouseco() > nLEFT .and. qmouseco() < nRIGHT
                  if oVIEW:RowPos <> qmouseli() - nTOP - 2
                     oVIEW:RowPos := qmouseli() - nTOP - 2
                     oVIEW:RefreshCurrent()
                     oVIEW:ForceStable()
                     exit
                  endif
               endif
            endif
         endif

         if ! lBOTAO .and. qmousebo() == 0
            lBOTAO := .T.
         endif

      enddo

      iif ( ! "I" $ cAREA , qinver(nLINHA,nLEFT+2,nRIGHT-nLEFT-3) , NIL )

      // CONTROLE DE TECLAS _________________________________________________

      do case
         case nTECLA == K_UP                   ; oVIEW:up()
         case nTECLA == K_DOWN                 ; oVIEW:down()
         case nTECLA == K_PGUP                 ; oVIEW:pageUp()
         case nTECLA == K_PGDN                 ; oVIEW:pageDown()
         case nTECLA == K_LEFT                 ; oVIEW:left()
         case nTECLA == K_RIGHT                ; oVIEW:right()
         case nTECLA == K_HOME                 ; oVIEW:goTop()
         case nTECLA == K_END                  ; oVIEW:goBottom()
         case nTECLA == K_ESC                  ; exit
         case nTECLA == K_CTRL_ENTER           ; exit

         case nTECLA == K_ENTER
              if aFUNCOES[1] != NIL
                 sTELA2 := qsbloc(0,0,24,79)
                 if ! "I" $ cAREA ; qinver(nLINHA,nLEFT+2,nRIGHT-nLEFT-3) ; endif
                 //qinver(nLINHA,nLEFT+2,nRIGHT-nLEFT-3)
                 if eval(aFUNCOES[1]) == "EXIT" ; exit ; endif
                 qrbloc(0,0,sTELA2)
//////////////// if aFUNCOES[1] == "DO_GET"
////////////////    do_get ( oVIEW )
//////////////// endif
                 oVIEW:refreshall()
              endif
         case nTECLA == K_ALT_O     // ALTERA SET ORDER ____________________

              // ALTERA O VETOR (PRIMEIRO ELEMENTO PASSA P/ ULTIMO) ______

              do while .T.
                 zTMP := aVETCOL[1]
                 adel ( aVETCOL , 1 )
                 aVETCOL[len(aVETCOL)] := zTMP
                 if aVETCOL[1,2] != 0
                    exit
                 endif
              enddo

              // ELIMINA AS COLUNAS ATUAIS __________________________________

              for zTMP = 1 to len(aVETCOL)
                  oVIEW:delcolumn(1)
              next

              // INSERE AS COLUNAS COM AS ORDENS TROCADAS ___________________

              for zTMP = 1 to len(aVETCOL)
                  oVIEW:addcolumn(tbcolumnnew(boblock(aVETCOL[zTMP,1]), dublock(aVETCOL[zTMP,1])))
              next

              // ALTERA O SET ORDER DE ACORDO COM PRIMEIRO ELEMENTO _________

              dbsetorder ( aVETCOL[1,2] )

              // FAZ REFRESH TOTAL DE TELA __________________________________

              oVIEW:configure()
              oVIEW:refreshall()

         case nTECLA == K_ALT_P     // PESQUISA (SEEK) _____________________

              if aVETCOL[1,2] <> 0
                 sTELA2 := qsbloc ( 21, 35, 23, 79 )
                 du_pesq(oVIEW,aFUNCOES,cAREA,nLEFT,nRIGHT)
                 qrbloc ( 21 , 35 , sTELA2 )
              endif

         otherwise

              if ! empty(aFUNCOES[2])
                 sTELA2 := qsbloc(0,0,24,79)
                 zTMP := eval(aFUNCOES[2])
                 iif(empty(zTMP),zTMP:=" ",NIL)
                 if zTMP == "EXIT" ; exit ; endif
                 qrbloc(0,0,sTELA2)
                 oVIEW:refreshall()
              endif

      endcase

      if deleted()
         dbskip()
         oVIEW:ForceStable()
      endif

   enddo

   // REESTABELECE SITUACAO ANTERIOR ________________________________________

   iif ( XMOUSEOK , qmousecu(0) , NIL )
   setcursor  ( nCURSOR )
   setcolor   ( cCOLOR )
   dbsetorder ( nORDER_OLD )
   qrbloc ( 23,20,cMEN )

   if ! "S" $ cAREA
      qrbloc( nTOP, nLEFT, sTELA1 )
   endif

return (.T.)

/////////////////////////////////////////////////////////////////////////////
// PESQUISA COM REFRESH AUTOMATICO __________________________________________

static function du_pesq ( oVIEW , aFUNCOES , cAREA , nLEFT , nRIGHT )
   local cSEEK2, zTMP, nTECLA, cTECLA, nCOL, nREC := recno(), nROW := row()

   cSEEK := ""
   qsay(22,78," ")

   do while .T.
      @ 21,35 clear to 23,79
      @ 21,35 to 23,79 double color "W+/N"
      qsay(22,36," Pesquisar: ","",15)
      qsay(22,48,pad(cSEEK,30),"",112)
      nCOL := 48 + len(cSEEK)

      setcursor(2)
      setpos(22,nCOL)

      iif ( ! "I" $ cAREA , qinver(nROW,nLEFT+2,nRIGHT-nLEFT-3) , NIL )
      nTECLA := qinkey(0)
      iif ( ! "I" $ cAREA , qinver(nROW,nLEFT+2,nRIGHT-nLEFT-3) , NIL )

      cTECLA := upper(chr(nTECLA))

      if nTECLA == 8 .or. nTECLA == 19
         cSEEK := left(cSEEK,len(cSEEK)-1)
      endif

      if isdigit(cTECLA) .or. isalpha(cTECLA) .or. cTECLA $ " /.-\=,"
         cSEEK += cTECLA
      endif

      if empty(aFUNCOES[4])
         cSEEK2 := cSEEK
      else
         cSEEK2 := eval(aFUNCOES[4])
      endif
      setcursor(0)

      if nTECLA == 27 .or. nTECLA == 13
         if nTECLA==27
            dbgoto(nREC)
            oVIEW:refreshall()
         endif
         exit
      endif

      if ! "E" $ cAREA

         dbseek(alltrim(cSEEK2),.T.)
         zTMP := recno()
         oVIEW:gotop()
         dbgoto(zTMP)
         if ( eof() , dbskip(-1) , NIL )
         oVIEW:refreshall()
         oVIEW:forcestable()

         nROW := row()

      endif

   enddo

   if "E" $ cAREA

       dbseek(alltrim(cSEEK2),.T.)
       zTMP := recno()
       oVIEW:gotop()
       dbgoto(zTMP)
       if ( eof() , dbskip(-1) , NIL )
       oVIEW:refreshall()
       oVIEW:forcestable()

       nROW := row()

   endif

   setpos(nROW,0)

      // zTMP := getnew(22,48,{|x|if(x!=NIL,cSEEK:=x,cSEEK)},"cSEEK","@!","W+/N")
      // readmodal ( { zTMP } )

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CRIAR BLOCO DE RECUPERACAO DOS DBF'S DO BROWSE
// UTILIZA FIELDWBLOCK QUANDO ALIAS FOR PASSADO JUNTO COM NOME DO CAMPO _____

function dublock ( cFIELD )

   local   nPOS
   private cMACRO

   // ELIMINA CABECALHO APOS A BARRA "/" ____________________________________

   if ( nPOS := at("/",cFIELD) ) != 0
      cFIELD := left(cFIELD,--nPOS)
   endif

   // MONTA CODE BLOCK PARA EXPRESSAO COMPLEXA ______________________________

   if at("(",cFIELD) != 0
      cMACRO := "{||" + cFIELD + "}"
      return &cMACRO.
   endif

   // FAZ "FIELDBLOCK" PARA CAMPOS __________________________________________

   if ( nPOS := at ( "->" , cFIELD ) ) == 0
      return fieldblock ( cFIELD )
   else
      return fieldwblock( substr(cFIELD,nPOS+2) , select(left(cFIELD,nPOS-1)) )
   endif

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ELIMINAR O ALIAS DO NOME DO CAMPO NO CABECALHO DO BROWSE _____

function boblock ( cFIELD )
   local nPOINTER
   if ( nPOINTER := at ( "/" , cFIELD ) ) != 0
      return substr(cFIELD,nPOINTER+1)
   endif
   if ( nPOINTER := at ( "->" , cFIELD ) ) != 0
      return substr(cFIELD,nPOINTER+2)
   endif
return cFIELD

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONTROLAR A MOVIMENTACAO DE REGISTROS ________________________

function duskipper ( n , cFILT )

   local   i := 0

   private cFILTRO := cFILT

   do case
      case n == 0 .or. lastrec() == 0
           skip 0
      case n > 0 .and. recno() != lastrec() + 1
           do while i < n
              skip +1
              if eof() .or. ! (&cFILTRO.)
                 skip -1
                 exit
              endif
              i++
           enddo
      case n < 0
           do while i > n
              skip -1
              if bof() ; exit ; endif
              if ! (&cFILTRO)
                 skip +1
                 exit
              endif
              i--
           enddo
   endcase

   if ! (&cFILTRO)
      dbgobottom()
      dbskip()
      return 0
   endif

return i

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EDITAR OS CAMPOS EM BROWSE ___________________________________

function dudo_get ( oVIEW )
   local bIns, lScore, lExit
   local col, get, nKey
   local lAppend, xOldKey, xNewKey

   lAppend := .F.

   oVIEW:ForceStable()
   //do while ! oVIEW:stabilize() ; enddo

   // Save the current record's key value (or NIL)
   // (for an explanation, refer to the rambling note below)
   xOldKey := iif( empty(indexkey()), NIL, &(indexkey()) )

   // Save global state
   lScore := Set(_SET_SCOREBOARD, .F.)
   lExit  := Set(_SET_EXIT, .T.)
   bIns   := SetKey(K_INS)

   // Set insert key to toggle insert mode and cursor shape
   SetKey( K_INS, {|| duinstoggle()} )

   // Set initial cursor shape
   SetCursor( IF(ReadInsert(), SC_INSERT, SC_NORMAL) )

   // Get the current column object from the browse
   col := oVIEW:getColumn(oVIEW:colPos)

   // Create a corresponding GET
   get := GetNew(Row(), Col(), col:block, col:heading,, oVIEW:colorSpec)

   // Read it using the standard reader
   // NOTE: for a shared database, an RLOCK() is required here
   if qrlock()
      ReadModal( {get} )
   else
      qmensa("n„o foi possivel travar o registro, tente novamente!","B")
   endif

   // Restore state
   SetCursor(0)
   Set(_SET_SCOREBOARD, lScore)
   Set(_SET_EXIT, lExit)
   SetKey(K_INS, bIns)

   // Get the record's key value (or NIL) after the GET
   xNewKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )

   // If the key has changed (or if this is a new record)
   if ! (xNewKey == xOldKey) .or. (lAppend .and. xNewKey != NIL)

       // Do a complete refresh
       oVIEW:refreshAll()
       oVIEW:ForceStable()
       //do while ! oVIEW:stabilize() ; enddo

       // Make sure we're still on the right record after stabilizing
       do while &(indexkey()) > xNewKey .and. ! oVIEW:hitTop()
           oVIEW:up()
           oVIEW:ForceStable()
           //do while ! oVIEW:stabilize() ; enddo
       enddo

   endif

   nKey := lastkey()
   if nKey==K_UP .or. nKey==K_DOWN .or. nKey==K_PGUP .or. nKey==K_PGDN
      keyboard chr ( nKey )
   endif

return NIL

/////////////////////////////////////////////////////////////////////////////
// ALTERA CURSOR QUANDO INSERT PRESSIONADO __________________________________

static function duinstoggle()
   if readinsert()
      readinsert(.f.)
      setcursor(sc_normal)
   else
      readinsert(.t.)
      setcursor(sc_insert)
   endif
return NIL

/////////////////////////////////////////////////////////////////////////////
// CALCULA DIMENSOES LATERAIS PARA O BROWSE CENTRALIZADO ____________________

function ducentraview ( aVETOR , nLEFT , nRIGHT )
   local nCONTADOR, nLEN, zTMP, nHEADER
   private cEXPRESSAO

   for nCONTADOR = 1 to len(aVETOR)

       if ( zTMP := at ( "/" , aVETOR[nCONTADOR,1] ) ) != 0
          nHEADER    := len ( substr ( aVETOR[nCONTADOR,1] , zTMP+1 ) )
          cEXPRESSAO := left ( aVETOR[nCONTADOR,1] , zTMP-1 )
       else
          nHEADER    := len ( aVETOR[nCONTADOR,1] )
          cEXPRESSAO := aVETOR[nCONTADOR,1]
       endif

       nLEN := 10
       do case
          case valtype(&cEXPRESSAO.) == "C"
               nLEN := len(&cEXPRESSAO.)
          case valtype(&cEXPRESSAO.) == "D"
               nLEN := 8
          case valtype(&cEXPRESSAO.) == "L"
               nLEN := 1
       endcase

       nLEFT += iif ( nHEADER > nLEN , nHEADER , nLEN)
   next

   nLEFT += ( len(aVETOR) + 5 )   // alterei de 3 para 5 em 23/03/94

   if nLEFT < 77
      nLEFT  := ( 80 - nLEFT ) / 2 + 1
      nRIGHT := 80 - nLEFT - 1
   else
      nLEFT  := 2
      nRIGHT := 77
   endif

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MONTAR O BLOCO DE APRESENTACAO DO BROWSE _____________________

function dumontaview ( nTOP , nLEFT , nBOTTOM , nRIGHT )
   local nATRIB, zTMP, sBLOCO, nCONT
   zTMP := qsbloc(00,00,01,01)
   @ 00,00 say "É" color XVIEWCOLOR
   nATRIB := atnsc_sl(00,00)
   qrbloc(00,00,zTMP)

   // DESENHA O BLOCO PRINCIPAL _____________________________________________

   qsay(nTOP   ,nLEFT,"°É"+repl("Í",nRIGHT-nLEFT-3)+"»°","",nATRIB)
   for nCONT := nTOP+1 to nBOTTOM-1
       qsay(nCONT,nLEFT,"°º","",nATRIB)
       qsay(nCONT,nRIGHT-1,"º°","",nATRIB)
   next
   qsay(nBOTTOM,nLEFT,"°È"+repl("Í",nRIGHT-nLEFT-3)+"¼°","",nATRIB)

   // COLOCA OS CARACTERES DE CONTROLE ______________________________________

   zTMP := nBOTTOM-1
   qsay(  zTMP,nRIGHT,"F","",nATRIB)           // final do arquivo
   qsay(  zTMP,nLEFT ,"X","",nATRIB)           // enter
   qsay(--zTMP,nRIGHT,"B","",nATRIB)           // baixo (pgdn)
   qsay(--zTMP,nRIGHT,"","",nATRIB)           // para baixo
   qsay(  zTMP,nLEFT ,"P","",nATRIB)           // pesquisa
   qsay(--zTMP,nRIGHT,"","",nATRIB)           // para cima
   qsay(--zTMP,nRIGHT,"C","",nATRIB)           // cima (pgup)
   qsay(  zTMP,nLEFT ,"O","",nATRIB)           // ordem
   qsay(--zTMP,nRIGHT,"I","",nATRIB)           // inicio do arquivo
   qsay(--zTMP,nLEFT ,"E","",nATRIB)           // escape
return NIL

