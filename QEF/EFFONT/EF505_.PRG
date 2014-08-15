/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: TERMO DE ABERTURA E ENCERRAMENTO
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MARCO DE 1995
// OBS........:
// ALTERACOES.:
function ef505

#define K_MAX_LIN 55

//fu_abre_ccusto()

// DADOS DO CONTADOR _______________________________________________________

if ! quse("","QCONFIG") ; return ; endif

if ! quse(XDRV_CT,"CONFIG",NIL,NIL,"CFGCT") ;return; endif

private cCONT_NOME := QCONFIG->Cont_Nome
private cCONT_CRC  := QCONFIG->Cont_Crc

private cDIR_NOME := CFGCT->Diretor
private cDIR_CPF  := CFGCT->Cpf_direto

CFGCT->(dbclosearea())
QCONFIG->(dbclosearea())

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private sBLOC1  := qlbloc("B505B","QBLOC.GLO") // Tipo: Abertura ou Encerramento
private sBLOC2  := qlbloc("B505C","QBLOC.GLO") // Periodo de impressao
private sBLOC3  := qlbloc("B505D","QBLOC.GLO") // Junta/Cart¢rio
private aEDICAO := {}                          // vetor para os campos de entrada de dados

private nORDEM                                 // Numero de ordem do  livro
private nPAGINAS                               // Numero de paginas do livro
private dDATA_TERMO                            // Data do livro
private cEXTENSO                               // Extenso do numero de paginas
private cTIPO1                                 // Abertura ou encerramento
private cTIPO2                                 // Abertura ou encerramento
private cTIPO_REG                              // Tipo de registro (Junta/Cartorio)
private cREGISTRO                              // Entrada ou saida
private cTITULO                                // Titulo do relatorio
private cNUMERO := CONFIG->Num_regist          // Numero registro na junta comercial
private cFILIAL                                // Filial
private cDT_CONST := CONFIG->Dt_const

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

   qlbloc(5,0,"B505A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL ,"9999"        ) } ,"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL         }) // descricao do filial
   aadd(aEDICAO,{{ || qesco(-1,0,@cREGISTRO   ,sBLOC1          ) } ,"REGISTRO"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO1      ,sBLOC2          ) } ,"TIPO1"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nORDEM      ,"999"  ,NIL,NIL ) } ,"ORDEM"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_TERMO ,"@!"   ,NIL,NIL ) } ,"DATA_TERMO"})
   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO_REG   ,sBLOC3          ) } ,"TIPO_REG"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNUMERO     ,"@!"            ) } ,"NUMERO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nFOLHAS     ,"999"  ,NIL,NIL ) } ,"FOLHAS"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nPAGINAS    ,"999"  ,NIL,NIL ) } ,"PAGINAS"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cEXTENSO    ,"@!"            ) } ,"EXTENSO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cDT_CONST   ,"@D"            ) } ,"DT_CONST"  })

do while .T.

   XNIVEL := 1
   XFLAG  := .T.

   nORDEM      := 0                         // Numero de ordem do  livro
   nFOLHAS     := 0                         // Numero de sequencia das folhas
   nPAGINAS    := 0                         // Numero de paginas do livro
   dDATA_TERMO := date()                    // Data do livro
   cEXTENSO    := space(34)                 // Extenso do numero de paginas
   cTIPO1      := "1"                       // Abertura ou Encerramento
   cTIPO2      := space(25)                 // Abertura ou Encerramento
   cTIPO_REG   := "J"                       // Junta/Cartorio
   cREGISTRO   := "1"                       // Entrada ou saida
   cTITULO     := space(80)                 // Titulo do relatorio
   cFILIAL    := "    "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_impressao()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FILIAL"

           if empty(cFILIAL) ; return .F. ; endif

           qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))

           if FILIAL->(dbseek(cFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,31))
           else
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif

      case cCAMPO == "REGISTRO"
           if empty(cREGISTRO); return .F.; endif
           qrsay(XNIVEL,qabrev(cREGISTRO,"12345",{"Livro de Entrada","Livro de Sa¡da","Apura‡„o ICMS","Livro de Servi‡os","Apura‡„o IPI"}))
           do case
              case cREGISTRO = "1"
                   cTITULO := "R E G I S T R O   D E   E N T R A D A S"
              case cREGISTRO = "2"
                   cTITULO := "R E G I S T R O   D E   S A I D A S"
              case cREGISTRO = "3"
                   cTITULO := "REGISTRO DE APURACAO DO ICMS"
              case cREGISTRO = "4"
                   cTITULO := "REGISTRO DOS SERVICOS PRESTADOSe Controle de Pagamento do Imposto Sobre Servicos"
              case cREGISTRO = "5"
                   cTITULO := "REGISTRO DE APURACAO DO IPI"
           endcase

      case cCAMPO == "TIPO1"
           if empty(cTIPO1); return .F.; endif
           qrsay(XNIVEL,qabrev(cTIPO1,"12",{"Abertura","Encerramento"}))
           do case
              case cTIPO1 = "1"
                   cTIPO2 = "    T E R M O   D E   A B E R T U R A"
              case cTIPO1 = "2"
                   cTIPO2 = "T E R M O   D E   E N C E R R A M E N T O"
           endcase

      case cCAMPO == "TIPO_REG"
           if empty(cTIPO_REG); return .F.; endif
           qrsay(XNIVEL,qabrev(cTIPO_REG,"JC",{"Junta","Cart¢rio"}))

      case cCAMPO == "NUMERO"
           if CONFIG->(qrlock())
              replace CONFIG->Num_regist with cNUMERO
              CONFIG->(qunlock())
           endif

//    case cCAMPO == "ORDEM"
//         if empty(nORDEM) ; return .F. ; endif
//         qrsay(XNIVEL,strzero(nORDEM,3))
//    case cCAMPO == "dDATA_TERMO"
//         if empty(dDATA_TERMO) ; return .F. ; endif
//    case cCAMPO == "PAGINAS"
//         if empty(nPAGINAS) ; return .F. ; endif
//         qrsay(XNIVEL,strzero(nPAGINAS,3))
//         qrsay(XNIVEL+1,cEXTENSO)
//         cEXTENSO := padr(strtran(qextenso(nPAGINAS)," REAIS","*"),34,"*")
//    case cCAMPO == "EXTENSO"
//         if empty(cEXTENSO) ; return .F. ; endif
//    case cCAMPO == "FOLHAS"
//         if empty(nFOLHAS) ; return .F. ; endif
//         qrsay(XNIVEL,strzero(nFOLHAS,3))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   // POSICIONA NO MUNICIPIO E ESTADO DA EMPRESA

   CGM->(dbseek(FILIAL->CGM))

   if ! qinitprn() ; return ; endif

   set marg to 10

   @ prow()+2,60 Say XCOND1 + "Folha...:" + strzero(nFOLHAS,3) + XCOND0

   if cREGISTRO == "4"
      @ prow()+2,00 Say padc(substr(cTITULO,1,31) ,80)
      @ prow()+1,00 Say padc(substr(cTITULO,32,80),80)
   else
      @ prow()+2,00 Say padc(cTITULO,80)
   endif

   @ prow()+3,00 Say padc("Numero de Ordem " +  strzero(nORDEM,3) ,80)

   @ prow()+3,00 Say padc(cTIPO2,80)

   @ prow()+3,10 Say "Contem este livro " +  strzero(nPAGINAS,3) + " (" +;
                        rtrim(cEXTENSO)+  "  )"

// @ prow()+2,05 Say "numeradas,do numero " +  +strzero(nFOLHAS,3)+ + " ao numero " +;
//                    strzero(nFOLHAS + nPAGINAS,3)+ " e servira para o lancamento"

   @ prow()+2,05 Say "folhas  numeradas, do numero" + " 001" +  " ao numero " +;
                      strzero(nPAGINAS,3)  + " e  "+iif(cTIPO1 == "1","servira","serviu ")+"  para o"

   @ prow()+2,05 Say "lancamento das operacoes proprias do estabelecimento  do  contribuinte"
   
   @ prow()+2,05 Say "abaixo identificado :"

   @ prow()+2,05 Say "Nome      " +  FILIAL->Razao 

   @ prow()+2,05 Say "Endereco  " +  rtrim(FILIAL->ENDERECO)+", "+alltrim(str(FILIAL->Numero)) 

   @ prow()+2,05 Say "Municipio " +  CGM->Municipio + " Estado " +  CGM->ESTADO 

   if cREGISTRO == "4"
      @ prow()+2,10 Say "Inscricao Municipal No. " + FILIAL->INSC_MUNIC 
   endif

   @ prow()+2,05 Say "Inscricao Estadual No. " +  FILIAL->INSC_ESTAD 

   @ prow()+2,05 Say "C. N. P.  J.    No.    "

   @ prow()  ,33 Say  transform(FILIAL->CGCCPF,"@R 99.999.999/9999-99") 

   @ prow()+2,05 say "Registrado n" + iif(cTIPO_REG=="J","a Junta Comercial ","o Cartorio de Titulos e Documentos ") + "sob No. " +  cNUMERO 

 //  @ prow()+2,05 say "Data de Constituicao da Empresa " +  dtoc(cDT_CONST) + 

// @ prow()+2,05 Say "Registrado na Junta Comercial sob No. " +  cNUMERO + 

   @ prow()+6,05 Say "Curitiba, " + Str(Day(dDATA_TERMO),2) + " de " + alltrim(qnomemes(dDATA_TERMO)) + " de " + Str(Year(dDATA_TERMO),4) + "."

 //  @ prow()+6,11 Say Replicate("_",55)

 //  @ prow()+1,11 Say "(Assinatura do Contribuinte ou seu Representante Legal)"

   //if cTIPO1 == "2"
   //   @ prow()+3,14 Say cCONT_NOME
   //   @ prow()+1,14 Say "CRC No. " + cCONT_CRC
   @ prow()+1,00  say XCOND1
   @ prow()+5,011 say "___________________________________                                     ____________________________________"
   @ prow()+1,011 say "Contador : "+FILIAL->Contador
   @ prow()  ,090 say "Diretor  : "+cDir_NOME
   @ prow()+1,011 say "CRC  : "+FILIAL->Crc
   @ prow()  ,090 say "CPF  : "+cDir_Cpf
   @ prow()+1,00  say XCOND0


   //endif

   set marg to 0

   qstopprn(.F.)

return
