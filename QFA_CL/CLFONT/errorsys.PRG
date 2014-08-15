
// ERRORSYS.PRG
//
// ADAPTADO PARA Q-SYSTEM POR LUIS ANTONIO ORLANDO PEREIRA
//
// 10.06.90 - INICIO DO CODIGO (BAURU-SP)
// 29.04.92 - ADAPTACOES DIVERSAS
// 11.01.93 - CORRECAO DE PEQUENOS BUGS
// 24.01.94 - REAVALIACAO PARA Q-SYSTEME - CURITIBA
// 13.04.95 - REVISAO P/ Q-SYS - PROTECAO NO FUNCAO ERRORSYS()
// 06.09.96 - INIBIDA VERIFICACAO DE ERRO EM "DATA_LANC" (i_prot_adic()) - KAKA

// ERROS SEVEROS (e:severity) _______________________________________________

#define ES_WHOCARES          0
#define ES_WARNING           1
#define ES_ERROR             2
#define ES_CATASTROPHIC      3

// ERROS GENERICOS (e:genCode) ______________________________________________

#define EG_ARG               1
#define EG_BOUND             2
#define EG_STROVERFLOW       3
#define EG_NUMOVERFLOW       4
#define EG_ZERODIV           5      // divisao por zero
#define EG_NUMERR            6
#define EG_SYNTAX            7
#define EG_COMPLEXITY        8

#define EG_MEM               11     // pouca memoria
#define EG_NOFUNC            12
#define EG_NOMETHOD          13
#define EG_NOVAR             14
#define EG_NOALIAS           15
#define EG_NOVARMETHOD       16

#define EG_CREATE            20
#define EG_OPEN              21
#define EG_CLOSE             22
#define EG_READ              23
#define EG_WRITE             24
#define EG_PRINT             25

#define EG_UNSUPPORTED       30
#define EG_LIMIT             31
#define EG_CORRUPTION        32
#define EG_DATATYPE          33
#define EG_DATAWIDTH         34
#define EG_NOTABLE           35
#define EG_NOORDER           36
#define EG_SHARED            37
#define EG_UNLOCKED          38
#define EG_READONLY          39
#define EG_APPENDLOCK        40

// ENVIA MENSAGENS PARA "STDERR" ____________________________________________

#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

// USADO ABAIXO _____________________________________________________________

#define NTRIM(n)		( LTrim(Str(n)) )

/////////////////////////////////////////////////////////////////////////////
// PROCEDURE ERRORSYS - EXECUTADA AUTOMATICAMENTE NO INICIO DO CODIGO _______

procedure ErrorSys()

   i_protec()

   errorblock ( { |e| q_error(e) } )

return



/////////////////////////////////////////////////////////////////////////////
// CONTROLE DE ERROS PADRAO Q-SYS ___________________________________________

static function q_error ( e )

   local nCONT1, nLINHA, cMESSAGE, cCHOICE, cTECLAS
   local nPOINTER, cDEVICE, cPORTA, cPRINTER
   local sBLOC := qsbloc(5,0,23,79)

   if empty(XDRV_SH)
      return ca_error(e)
   endif

   // DIVISAO POR ZERO VAI RETORNAR ZERO ____________________________________

   if e:gencode == EG_ZERODIV ; return (0) ; endif

   // RESTAURA SET'S ________________________________________________________

   cDEVICE  := set(20,"SCREEN")  // assume video...
   cPRINTER := set(23,"off")     // desliga impressora...
   cPORTA   := set(24,"")        // desabilita porta...

   if "U" $ type("XNOMEUSER")
      private XNOMEUSER := "   "
   endif

   if "U" $ type("XPROG")
      private XPROG := "???"
   endif

   if empty(XNOMEUSER)
      XNOMEUSER := "  LOGOUT  "
   endif

   // SITUACAO DE MEMORIA BAIXA (MEMORY LOW) IRA PARA "DEFAULT" _____________

   if e:gencode == EG_MEM
      if "M" $ getenv("QERRSYS")
         qsay(0,0,strzero(memory(0),3),15)
         return .F.
      endif
   endif

   // OPEN ERROR ____________________________________________________________

   if e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault
      NetErr (.T.)
      return (.F.)
   endif

   // LOCK IN APPEND BLANK ERROR ____________________________________________

   if e:genCode == EG_APPENDLOCK .and. e:canDefault
      NetErr (.T.)
      return (.F.)
   endif

   // SE EXCESSO DE ARQUIVOS ABERTOS, FECHA TUDO ___________________________

   if e:osCode == 4 ; dbcloseall() ; endif

   // PREPARA BLOCOS ________________________________________________________

   qlbloc(06,04,"BLOCERR1",XDRV_SH+"QSBLOC.GLO",1)
   qlbloc(06,49,"BLOCERR2",XDRV_SH+"QSBLOC.GLO",1)
   qlbloc(19,04,"BLOCERR3",XDRV_SH+"QSBLOC.GLO",1)

   cCHOICE := "<C>ontinuar - <F>inalizar"

   cTECLAS := "CF"

   if e:canRetry
      cCHOICE += " - <R>epetir"
      cTECLAS += "R"
   endif

   if e:canDefault
      cCHOICE += " - <I>gnorar"
      cTECLAS += "I"
   endif

   qsay ( 20 , 15 , cCHOICE )

   // MOSTRA MENSAGEM NA TELA _______________________________________________

   cMENSAGEM := iif( e:severity > ES_WARNING , "Erro " , "Advertˆncia " )
   cMENSAGEM += iif( valtype(e:subsystem)=="C" , e:subsystem() , "???" )
   cMENSAGEM += iif( valtype(e:subcode)=="N" , "/" + NTRIM(e:subcode) , "/???" )
   qsay ( 08 , 08 , cMENSAGEM )

   if valtype(e:description) == "C" ; qsay ( 09 , 08 , i_traduz_erro(e) ) ; endif

   do case
      case ! Empty(e:filename)  ; qsay ( 10 , 08 , e:filename )
      case ! Empty(e:operation) ; qsay ( 10 , 08 , e:operation )
   endcase

   cMessage := ErrorMessage(e)

   if ! empty(e:osCode)
      qsay ( 11 , 08 , "Erro do DOS: " + NTRIM(e:osCode) )
      cMessage += ";(Erro do DOS: " + NTRIM(e:osCode) + ")"
   endif

   // GRAVA MENSAGEM DE ERRO NO ARQUIVO QERRSYS.LOG _________________________

   set alternate to qerrsys.log additive
   set alternate on
   set console off
   qout(dtos(date())+left(time(),5)+XNOMEUSER+pad(XPROG,3)+pad(cMessage,55))
   nCONT1 := 2
   nLINHA := 9
   do while ! empty(procname(nCONT1))
      if ! "LOCKERRHAN" $ trim(procname(nCONT1)) .and. ! "INITHANDL$" $ trim(procname(nCONT1))
         qqout("Linha: "+str(procline(nCONT1),4)+" da Rotina: "+trim(procname(nCONT1))+chr(255))
         if nLINHA < 16
            qsay(nLINHA  ,53,str(procline(nCONT1),4))
            qsay(nLINHA++,60,trim(procname(nCONT1)))
         endif
      endif
      nCONT1++
   enddo
   set console on
   set alternate off
   set alternate to

   // SOLICITA OPCAO E FACA COMO INSTRUIDO PELO USUARIO _____________________

   do while .T.

      cCHOICE := upper(chr(qinkey(0)))

      if lastkey() == 27 ; cCHOICE := "C" ; endif

      if cCHOICE $ cTECLAS
         do case
            case cCHOICE == "C"         // CONTINUAR
                 break(e)
            case cCHOICE == "R"         // REPETIR OPERACAO
                 set(20,cDEVICE)
                 set(23,cPRINTER)
                 set(24,cPORTA)
                 qrbloc(5,0,sBLOC)
                 return (.T.)
            case cCHOICE == "I"         // IGNORAR
                 qrbloc(5,0,sBLOC)
                 return (.F.)
            case cCHOICE == "F"         // FINALIZAR
                 @ 23,00 say ""
                 errorlevel(1)
                 quit
         endcase
      endif

   enddo

return .F.






/////////////////////////////////////////////////////////////////////////////
// FUNCAO ERRORMESSAGE() ____________________________________________________

static function errormessage ( e )
   local cMENSAGEM, cDESCRICAO

   // ERRO OU ADVERTENCIA ___________________________________________________

   cMENSAGEM := if( e:severity > ES_WARNING, "Erro ", "Advertˆncia " )

   // NOME DO SISTEMA (SE DISPONIVEL) _______________________________________

   if ValType(e:subsystem) == "C"
      cMENSAGEM += e:subsystem()
   else
      cMENSAGEM += "???"
   endif

   // CODIGO DE ERRO SE DISPONIVEL __________________________________________

   if ValType(e:subCode) == "N"
      cMENSAGEM += ("/" + NTRIM(e:subCode))
   else
      cMENSAGEM += "/???"
   endif

   // DESCRICAO DO ERRO SE DISPONIVEL _______________________________________

   if ValType(e:description) == "C"
      cDESCRICAO := i_traduz_erro(e)
      cMENSAGEM += (";  " + cDESCRICAO)
   endif

   // NOME DE ARQUIVO OU NOME DA OPERACAO ___________________________________

   do case
      case ! Empty(e:filename)
           cMENSAGEM += (": " + e:filename)
      case ! Empty(e:operation)
           cMENSAGEM += (": " + e:operation)
   endcase

return (cMENSAGEM)




/////////////////////////////////////////////////////////////////////////////
// TRADUTOR DE MENSAGENS DE ERROS PARA O PORTUGUES __________________________

function i_traduz_erro ( oERRO )
   local cMENSAGEM
   do case
      case oERRO:gencode == 01 ; cMENSAGEM := "erro de argumento"
      case oERRO:gencode == 05 ; cMENSAGEM := "divis„o por zero"
      case oERRO:gencode == 07 ; cMENSAGEM := "erro de sintaxe"
      case oERRO:gencode == 08 ; cMENSAGEM := "erro de complexidade"
      case oERRO:gencode == 11 ; cMENSAGEM := "pouca mem¢ria !"
      case oERRO:gencode == 12 ; cMENSAGEM := "fun‡„o n„o definida"
      case oERRO:gencode == 14 ; cMENSAGEM := "vari vel n†o definida"
      case oERRO:gencode == 15 ; cMENSAGEM := "alias n„o existente"
      case oERRO:gencode == 18 ; cMENSAGEM := "alias ja esta em uso"
      case oERRO:gencode == 20 ; cMENSAGEM := "erro de cria‡„o de arquivo"
      case oERRO:gencode == 21 ; cMENSAGEM := "erro de abertura de arquivo"
      case oERRO:gencode == 23 ; cMENSAGEM := "erro de leitura"
      case oERRO:gencode == 24 ; cMENSAGEM := "erro de escrita"
      case oERRO:gencode == 25 ; cMENSAGEM := "erro de impress„o"
      case oERRO:gencode == 32 ; cMENSAGEM := "corrup‡„o detectada"
      case oERRO:gencode == 33 ; cMENSAGEM := "tipo de dado incompativel"
      case oERRO:gencode == 34 ; cMENSAGEM := "overflow de campo"
      otherwise                ; cMENSAGEM := "Erro: " + strzero(oERRO:gencode,2) + "/" + oERRO:description
   endcase

return cMENSAGEM





/////////////////////////////////////////////////////////////////////////////
// CONTROLE DE ERROS PADRAO C.A. ____________________________________________

static function ca_error ( e )

   local I, cMESSAGE, aOPTIONS, nCHOICE, nPOINTER, cDEVICE, cPORTA, cPRINTER

   // DIVISAO POR ZERO VAI RETORNAR ZERO ____________________________________

   if e:gencode == EG_ZERODIV ; return (0) ; endif

   cDEVICE  := set(20,"SCREEN")  // assume video...
   cPRINTER := set(23,"off")     // desliga impressora...
   cPORTA   := set(24,"")        // desabilita porta...

   if "U" $ type("XNOMEUSER")
      private XNOMEUSER := "   "
   endif

   if "U" $ type("XPROG")
      private XPROG := "???"
   endif

   if empty(XNOMEUSER)
      XNOMEUSER := "  LOGOUT  "
   endif

   // SITUACAO DE MEMORIA BAIXA (MEMORY LOW) IRA PARA "DEFAULT" _____________

   if e:gencode == EG_MEM
      if "M" $ getenv("QERRSYS")
         qsay(0,0,strzero(memory(0),3),15)
         return .F.
      endif
   endif

   // OPEN ERROR ____________________________________________________________

   if e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault
      NetErr (.t.)
      return (.f.)
   endif

   // LOCK IN APPEND BLANK ERROR ____________________________________________

   if e:genCode == EG_APPENDLOCK .and. e:canDefault
      NetErr (.t.)
      return (.f.)
   endif

   // BUILD OPTIONS ARRAY ___________________________________________________

   aOptions := {"Continua","Finaliza"}

   if e:canRetry
      aadd(aOptions, "Repete Opera‡„o")
   endif

   if e:canDefault
      aadd(aOptions, "Ignora")
   endif

   // PREPARA MENSAGEM ______________________________________________________

   cMessage := ErrorMessage(e)
   if !empty(e:osCode)
      cMessage += ";(Erro do DOS: " + NTRIM(e:osCode) + ")"
   endif

   // GRAVA MENSAGEM DE ERRO NO ARQUIVO QERRSYS.LOG _________________________

   if e:osCode == 4  // erro 4 = excesso de arquivos abertos...
      dbcloseall()
   endif

   set alternate to qerrsys.log additive
   set alternate on
   set console off
   qout(dtos(date())+left(time(),5)+XNOMEUSER+pad(XPROG,3)+pad(cMessage,55))
   i := 2
   do while ! empty(procname(i))
      if ! "LOCKERRHAN" $ trim(procname(i)) .and. ! "INITHANDL$" $ trim(procname(i))
         qqout("Linha: "+str(procline(i),4)+" da Rotina: "+trim(procname(i))+chr(255))
      endif
      i++
   enddo
   set console on
   set alternate off
   set alternate to

   // APRESENTACAO DA MENSAGEM E OPCOES _____________________________________

   nChoice := 0
   do while nChoice == 0
      if (nChoice := Alert( cMessage, aOptions )) == NIL
         exit
      endif
   enddo

   // FACA COMO INTRUIDO PELO USUARIO _______________________________________

   if ! Empty(nChoice)
      do case
         case aOptions[nChoice] == "Continua"
              Break(e)
         case aOptions[nChoice] == "Repete Opera‡„o"
              set(20,cDEVICE)   // reassume padroes...
              set(23,cPRINTER)  //
              set(24,cPORTA)    //
              return (.t.)
         case aOptions[nChoice] == "Ignora"
              return (.f.)
      endcase
   endif

   // MOSTRA MENSAGEM E TRACE DE EXECUCAO ___________________________________

   ? errormessage(e)
   ?
   i := 2

   do while ! empty(procname(i))
      if ! "LOCKERRHAN" $ trim(procname(i)) .and. ! "INITHANDL$" $ trim(procname(i))
         ? "Linha " + str(procline(i),4) + " - " + trim(procname(i))
      endif
      i++
   enddo

   // GIVE UP

   errorlevel(1)
   quit

return (.F.)






/////////////////////////////////////////////////////////////////////////////
// PROTECAO Q-SYS ___________________________________________________________

static function i_protec

   local nHANDLE, cBUFFER

   public y_q_sys_y := "*** CONTROLE DE PROTECAO ! - BIBLIOTECA DE PROPRIEDADE DA Q-SYS INFORMATICA LTDA."

   set date brit

   if ( nHANDLE := fopen("QSYS.CFG") ) == -1 .and. date() > ctod("17/12/96")
      // fcreate("QSYS.CFG",2)                                                                       //
      // nHANDLE := fopen("QSYS.CFG")                                                                // liberado em
      // cBUFFER := "CFG"+chr(1)+chr(27)+chr(13)+chr(3)+chr(5)+chr(20)+chr(9)+chr(7)+chr(13)+chr(2)  //   06.09.96
      // fwrite(nHANDLE,cBUFFER)                                                                     //
   endif

   if nHANDLE <> -1 .and. ! file("QSYS"+chr(255)+".DAT")
      fclose(nHANDLE)
      // ? "Internal Error 9371: conventional memory exhausted !" // janeiro 96
      // ? "(" + alltrim(str(nHANDLE)) + ") " + "Internal Error 5320: VMM IAMBS Manager Error..."    // 17/07/96
      // ? "(" + alltrim(str(nHANDLE)) + ") " + "Internal Error 4001: Virtual memory exhausted..."   // liberado em 06.09.96
      // quit
   endif

return



/////////////////////////////////////////////////////////////////////////////
// PROTECAO ADICIONAL _______________________________________________________

function i_prot_adic

   static nSEQ := 1

   local dDAT, cVAR := getenv("QSYS")

   local cS := strtran ( "K%8%.%1%0%0%}%a%F%G%7%2%L%*%W%z%0%?%V%3%5%/%Y%E%R%S%K%" , "%" , "" )

   nSEQ++

   if nSEQ > 2 ; nSEQ := 1 ; endif

   do case
      case nSEQ == 1 .and. type("XDATASYS") == "D"  ; dDAT := XDATASYS
//      case nSEQ == 2 .and. type("Data_lanc") == "D" ; dDAT := Data_lanc    // INIBIDO EM 06.09.96
      otherwise ; return
   endcase

   do case
      case dDAT > ctod("15/06/97") ; if left(cS,27) $ cVAR ; return ; else ; _rescue() ; endif
      case dDAT > ctod("15/05/97") ; if left(cS,24) $ cVAR ; return ; else ; _rescue() ; endif
      case dDAT > ctod("15/04/97") ; if left(cS,21) $ cVAR ; return ; else ; _rescue() ; endif
      case dDAT > ctod("15/03/97") ; if left(cS,18) $ cVAR ; return ; else ; _rescue() ; endif
      case dDAT > ctod("15/02/97") ; if left(cS,15) $ cVAR ; return ; else ; _rescue() ; endif
      case dDAT > ctod("15/01/97") ; if left(cS,12) $ cVAR ; return ; else ; _rescue() ; endif
      case dDAT > ctod("15/12/96") ; if left(cS,09) $ cVAR ; return ; else ; _rescue() ; endif
      case dDAT > ctod("15/11/96") ; if left(cS,06) $ cVAR ; return ; else ; _rescue() ; endif
      case dDAT > ctod("15/10/96") ; if left(cS,03) $ cVAR ; return ; else ; _rescue() ; endif
   endcase

return

function _rescue

//   @ 0,0 say ""
//   quit

return

