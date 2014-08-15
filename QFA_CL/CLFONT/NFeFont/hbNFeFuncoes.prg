****************************************************************************************************
* Funcoes e Classes Relativas a Funcoes NFE                                                        *
* Usado como Base o Projeto Open ACBR e Sites sobre XML, Certificados e Afins                      *
* Qualquer modificaÁ„o deve ser reportada para Fernando Athayde para manter a sincronia do projeto *
* Fernando Athayde 28/08/2011 fernando_athayde@yahoo.com.br                                        *
****************************************************************************************************
#include "common.ch"
#include "fileio.ch"
#include "hbclass.ch"
#ifndef __XHARBOUR__
   #include "hbcompat.ch"
#endif

CLASS hbNFeFuncoes
*  // Funcoes de Texto
   METHOD pegaTag(cXMLcXML, cTag)
   METHOD eliminaString(cString,cEliminar)
   METHOD parseEncode( cTexto, lExtendido )
   METHOD parseDecode( cTexto )
   METHOD strTostrval( cString )
*  // Funcoes de B.O.
   METHOD validaEAN(cCodigoBarras)
   METHOD validaPlaca(cPlaca)
*  // Funcoes de Data
   METHOD FormatDate(dData,cMascara)
*  // Funcoes de Valores
   METHOD ponto(nValor,nTamanho,nDecimais,cTipo,cSigla)
*  // Funcoes de Diretorios
   METHOD curDrive()
*  // Funcoes de Calculos
   METHOD modulo11(cStr,nPeso1,nPeso2)
   METHOD BringToDate(cStr)
ENDCLASS

METHOD BringToDate(cStr) CLASS hbNFeFuncoes
/*
   transforma a data do XML em formado data
   Mauricio Cruz - 09/10/2012
*/
LOCAL dRET:=CTOD(STRZERO(VAL(SUBSTR(cStr,9,2)),2)+'/'+STRZERO(VAL(SUBSTR(cStr,6,2)),2)+'/'+LEFT(cSTR,4))
RETURN(dRET)

METHOD eliminaString(cString,cEliminar) CLASS hbNFeFuncoes
LOCAL cRetorno, nI
   cRetorno := ""
   FOR nI=1 TO LEN(cString)
      IF !SUBS(cString,Ni,1) $ cEliminar
         cRetorno += SUBS(cString,Ni,1)
      ENDIF
   NEXT
RETURN(cRetorno)

METHOD pegaTag(cXML, cTag) CLASS hbNFeFuncoes
LOCAL cRetorno, cTagInicio,cTagFim
   cTagInicio := "<"+cTag //+">"
   cTagFim := "</"+cTag+">"
   cRetorno := SUBS( cXML, AT(cTagInicio,cXML)+LEN(cTagInicio)+1, AT(cTagFim,cXML)-(AT(cTagInicio,cXML)+LEN(cTagInicio)+1) )
RETURN(cRetorno)

METHOD FormatDate(dData,cMascara,cSeparador) CLASS hbNFeFuncoes
LOCAL cResultado
   IF cSeparador=Nil
      cSeparador="/"
   ENDIF
   cResultado:=""
   IF cMascara     == "DD"+cSeparador+"MM"+cSeparador+"YYYY"
      cResultado = SUBS(DTOC(dData),1,2)+cSeparador+SUBS(DTOC(dData),4,2)+cSeparador+SUBS(DTOC(dData),7,4)
   ELSEIF cMascara == "YYYY"+cSeparador+"MM"+cSeparador+"DD"
      cResultado = SUBS(DTOC(dData),7,4)+cSeparador+SUBS(DTOC(dData),4,2)+cSeparador+SUBS(DTOC(dData),1,2)
   ELSEIF cMascara == "YYYY"+cSeparador+"DD"+cSeparador+"MM"
      cResultado = SUBS(DTOC(dData),7,4)+cSeparador+SUBS(DTOC(dData),1,2)+cSeparador+SUBS(DTOC(dData),4,2)
   ELSEIF cMascara == "MM"+cSeparador+"YYYY"
      cResultado = SUBS(DTOC(dData),4,2)+cSeparador+SUBS(DTOC(dData),7,4)
   ELSEIF cMascara == "DD"+cSeparador+"MM"+cSeparador+"YY"
      cResultado = SUBS(DTOC(dData),1,2)+cSeparador+SUBS(DTOC(dData),4,2)+cSeparador+SUBS(DTOC(dData),9,2)
   ELSEIF cMascara == "YY"+cSeparador+"MM"+cSeparador+"DD"
      cResultado = SUBS(DTOC(dData),9,2)+cSeparador+SUBS(DTOC(dData),4,2)+cSeparador+SUBS(DTOC(dData),1,2)
   ELSEIF cMascara == "YY"+cSeparador+"DD"+cSeparador+"MM"
      cResultado = SUBS(DTOC(dData),9,2)+cSeparador+SUBS(DTOC(dData),1,2)+cSeparador+SUBS(DTOC(dData),4,2)
   ELSEIF cMascara == "MM"+cSeparador+"YY"
      cResultado = SUBS(DTOC(dData),4,2)+cSeparador+SUBS(DTOC(dData),9,2)
   ELSEIF cMascara == "DD"+cSeparador+"MM"
      cResultado = SUBS(DTOC(dData),1,2)+cSeparador+SUBS(DTOC(dData),4,2)
   ELSEIF cMascara == "YYYY"
      cResultado = SUBS(DTOC(dData),7,4)
   ELSEIF cMascara == "YY"
      cResultado = SUBS(DTOC(dData),9,2)
   ELSEIF cMascara == "YYMM"
      cResultado = SUBS(DTOC(dData),9,2)+SUBS(DTOC(dData),4,2)
   ELSEIF cMascara == "MM"
      cResultado = SUBS(DTOC(dData),4,2)
   ELSEIF cMascara == "YYMMDD"
      cResultado = SUBS(DTOC(dData),9,2)+SUBS(DTOC(dData),4,2)+SUBS(DTOC(dData),1,2)
   ELSEIF cMascara == "YYDDMM"
      cResultado = SUBS(DTOC(dData),9,2)+SUBS(DTOC(dData),1,2)+SUBS(DTOC(dData),4,2)
   ELSEIF cMascara == "DD"
      cResultado = SUBS(DTOC(dData),1,2)
   ENDIF
RETURN(cResultado)


********  PONTUACAO DE VALORES *********
METHOD ponto(nValor,nTamanho,nDecimais,cTipo,cSigla) CLASS hbNFeFuncoes
LOCAL cRetorno, nIncPonto, nQuantidadeMaior
  IF nTamanho = Nil
     nTamanho = 13
  ENDIF
  IF nDecimais = Nil
     nDecimais = 2
  ENDIF
  IF cTipo = Nil
     cTipo= "normal"
  ENDIF
  IF cSigla = Nil
     cSigla = ""
  ENDIF
  IF nValor = 0  .AND. cTipo="branco"
     cRetorno=SPACE(nTamanho)
  ELSE
     cRetorno=TRANSFORM(nValor,"@E 999,999,999,999,999.9999")
     &&                   999,999,999,999,999.9999
     &&                   123456789012346578901324
     &&      20.0         --------------------
     &&       5.0                       -----
     &&       9.0                   ---------
     &&      13.4                    -------------
     &&      13.2                  -------------
     &&      13.3                   -------------
     &&      16.0             ----------------
     &&      16.2               ----------------

     IF nDecimais = 0
        IF (LEN(ALLTRIM(cRetorno))-5) > nTamanho
           nQuantidadeMaior := (LEN(ALLTRIM(cRetorno))-5) - nTamanho
           FOR nIncPonto = 1 TO nQuantidadeMaior
              cRetorno := AtRepl( ".", cRetorno, "", 1 )
           NEXT
           cRetorno=SPAC(24-LEN(cRetorno))+cRetorno
        ENDIF
        cRetorno=SUBS(cRetorno,24-nTamanho-3-1,nTamanho)
        IF SUBS(cRetorno,nTamanho,1) == ","
           cRetorno := " "+SUBS(cRetorno,1,nTamanho-1)
        ENDIF
     ELSE
        IF (LEN(ALLTRIM(cRetorno))-(5-(nDecimais+1))) > nTamanho
           nQuantidadeMaior := (LEN(ALLTRIM(cRetorno))-(5-(nDecimais+1))) - nTamanho
           FOR nIncPonto = 1 TO nQuantidadeMaior
              cRetorno := AtRepl( ".", cRetorno, "", 1 )
           NEXT
           cRetorno=SPAC(24-LEN(cRetorno))+cRetorno
        ENDIF
        cRetorno=SUBS(cRetorno,24-nTamanho-3+nDecimais,nTamanho)
     ENDIF

     IF EMPTY(SUBS(cRetorno,1,2)) .AND. !EMPTY(cSigla)
        cRetorno=SUBS(cSigla,1,2)+SUBS(cRetorno,3, (nTamanho-2) )
     ELSEIF EMPTY(SUBS(cRetorno,1,1)) .AND. !EMPTY(cSigla)
        cRetorno=SUBS(cSigla,1,1)+SUBS(cRetorno,2, (nTamanho-1) )
     ENDIF

  ENDIF
RETURN(cRetorno)

METHOD curDrive() CLASS hbNFeFuncoes
#ifdef __XHARBOUR__
   RETURN( CURDRIVE() )
#else
   RETURN( HB_CURDRIVE() )
#endif

* modulo11 Baseado na funÁ„o modulo11 do maligno
METHOD modulo11(cStr,nPeso1,nPeso2) CLASS hbNFeFuncoes  // mÛdulo 11, com pesos nPeso1 (inicial) a nPeso2 (final), que
LOCAL nTot := 0                                         // ser„o utilizados no multiplicador dos dÌgitos, apanhados da
LOCAL nMul := nPeso1                                    // direita para a esquerda. Tal multiplicador ser· reciclado e
LOCAL i                                                 // voltar· para nPeso1, quando o limite (nPeso2) for atingido.

FOR i := Len(cStr) TO 1 STEP -1
  nTot += VAL(SubStr(cStr,i,1)) * nMul
  nMul := IF(nMul=nPeso2, nPeso1, nMul+1)
NEXT

RETURN IF(nTot%11 < 2, "0", STR(11-(nTot%11),1))

METHOD parseEncode( cTexto, lExtendido ) CLASS hbNFeFuncoes
LOCAL cRetorno, aFrom, aTo, aFromTo, nI, nI2
   // especiais
   if lExtendido=nil
      lExtendido:=.f.
   endif

   aFrom := { '&', 'Ä', 'á', 'â', '"', "'", '<', '>', '∫', '™' }
   aTo   := { '&amp;', '«', 'Á', 'Î', '&quot;', '&#39;', '&lt;', '&gt;', '&#176;', '&#170;' }
   cRetorno := cTexto
   FOR nI = 1 TO LEN(aFrom)
      if lExtendido
         if nI<>5 // para esse n„o deve remover
            cRetorno := STRTRAN( cRetorno, aFrom[nI], aTo[nI] )
         endif
      else
         cRetorno := STRTRAN( cRetorno, aFrom[nI], aTo[nI] )
      endif
   NEXT
   // normais
   aFromTo := { {'·„‰‡‚', 'a'},;
                {'¡√ƒ¿¬', 'A'},;
                {'ÈÎ‡Í' , 'e'},;
                {'…À» ' , 'E'},;
                {'ÌÔÏÓ' , 'i'},;
                {'ÕœÃŒ' , 'I'},;
                {'ÛıˆÚÙ', 'o'},;
                {'”’÷“‘', 'O'},;
                {'˙¸˘˚' , 'u'},;
                {'⁄‹Ÿ€' , 'U'},;
                {'«'    , 'C'},;
                {'Á'    , 'c'};
              }
   FOR nI = 1 TO LEN( aFromTo )
      FOR nI2 = 1 TO LEN( aFromTo[nI,1] )
         cRetorno := STRTRAN( cRetorno, SUBS(aFromTo[nI,1],nI2,1), aFromTo[nI,2] )
      NEXT nI2
   NEXT nI
RETURN(cRetorno)

METHOD parseDecode( cTexto ) CLASS hbNFeFuncoes
LOCAL cRetorno, aFrom, aTo, nI
   aTo := { '&', '"', "'", '<', '>', '∫', '™' }
   aFrom := { '&amp;', '&quot;', '&#39;', '&lt;', '&gt;', '&#176;', '&#170;' }
   FOR nI=1 TO LEN(aFrom)
      cRetorno := STRTRAN( cTexto, aFrom[nI], aTo[nI] )
   NEXT
RETURN(cRetorno)

METHOD strTostrval( cString, nCasas ) CLASS hbNFeFuncoes
LOCAL cRetorno
   IF nCasas = Nil
      nCasas = 2
   ENDIF
   cRetorno := STRTRAN( cString, ',' , '.' )
   cRetorno := VAL( cRetorno )
   cRetorno := ALLTRIM( STR( cRetorno ,20, nCasas) )
RETURN(cRetorno)

METHOD validaEAN(cCodigoBarras) CLASS hbNFeFuncoes // funÁ„o adaptada do Dr_Spock_Two do forum pctoledo
Local nInd := 0, nUnidade := 0, nDigito := 0, lRetorno   := .f., aPosicao[12], aRetorno
   IF STRZERO(LEN(TRIM(cCodigoBarras)), 2,0) $ "08 13 14"
      IF LEN(TRIM(cCodigoBarras)) == 8
         cCodigoBarras := STRZERO(LEN(ALLTRIM(cCodigoBarras)), 13, 0)
      ELSEIF LEN(TRIM(cCodigoBarras)) == 14
         cCodigoBarras := RIGHT(cCodigoBarras, 13)
      ENDIF
      FOR nInd := 1 TO 12
         aPosicao[nInd] := VAL(SUBS(cCodigoBarras, nInd, 1))
      NEXT
      nUnidade := VAL(RIGHT(STR(((aPosicao[2]+aPosicao[4]+aPosicao[6]+aPosicao[8]+aPosicao[10]+aPosicao[12])*3) + ( aPosicao[1]+aPosicao[3]+aPosicao[5]+aPosicao[7]+aPosicao[9]+aPosicao[11])), 1))
      nDigito  := IF((10-nUnidade ) > 9, 0, 10-nUnidade)
      lRetorno := nDigito = VAL(RIGHT(ALLTRIM(cCodigoBarras), 1))
      IF !lRetorno
         aRetorno[2] := "O digito verificador esta incorreto !"
      ENDIF   
   ELSE
      IF LEN( TRIM ( cCodigoBarras ) ) = 0
         lRetorno := .T.
      ELSE   
         aRetorno[2] := "O tamanho do campo devera conter 8, 13 ou 14 digitos !"
      ENDIF   
   ENDIF
   aRetorno[1] := lRetorno
RETURN (aRetorno)

METHOD validaPlaca(cPlaca) CLASS hbNFeFuncoes
LOCAL lRetorno := .T., nI
   IF LEN(cPlaca) = 7
      FOR nI = 1 TO LEN(cPlaca)
         IF nI <= 3 // letras
            IF SUBS( cPlaca, nI, 1 ) $ '0123456789'
               EXIT
            ENDIF
         ELSE
            IF !SUBS( cPlaca, nI, 1 ) $ '0123456789'
               EXIT
            ENDIF
         ENDIF
      NEXT
   ELSE
      lRetorno := .F.
   ENDIF
RETURN (lRetorno)
