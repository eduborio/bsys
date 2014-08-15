/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: DEMONSTRACAO DE LUCROS OU PREJUIZOS ACUMULADOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:
function ct519

#include "inkey.ch"
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cMES                               // mes para cabecario
private aEDICAO  := {}                     // vetor para os campos
private cTITULO1                           // titulo 1 do relatorio
private cTITULO2                           // titulo 2 do relatorio
private fSILPA                             // saldo inicial de lucros ou prejuizos acumulados
private fCMSI                              // correcao monetaria do saldo inicial
private fLAP                               // lucro apurado no periodo
private fPAP                               // prejuizo apurado no periodo
private fVICS                              // valor incorporado capital social
private fACEA                              // ajustes credores de exercicios anteriores
private fADEA                              // ajustes devedores de exercicios anteriores
private fRR                                // reversao de reservas
private fOR                                // outros recursos
private fTR                                // transferencias para reservas
private fOA                                // outras aplicacoes
private fDLD                               // dividendos ou lucros distribuidos
private nSFLPA                             // saldo final de lucros ou prejuizos acumulados
private nPAG     := 0                      // pagina inicial para impressao
private nNIVEL                             // nivel da conta
private cPIC     := "@E 9,999,999,999.99"  // picture generica

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B519A","QBLOC.GLO")

CONFIG->(qpublicfields())
CONFIG->(qcopyfields())

XNIVEL := 1

qrsay(XNIVEL++,@fSILPA,cPIC)
qrsay(XNIVEL++,@fCMSI ,cPIC)
qrsay(XNIVEL++,@fLAP  ,cPIC)
qrsay(XNIVEL++,@fPAP  ,cPIC)
qrsay(XNIVEL++,@fVICS ,cPIC)
qrsay(XNIVEL++,@fACEA ,cPIC)
qrsay(XNIVEL++,@fADEA ,cPIC)
qrsay(XNIVEL++,@fRR   ,cPIC)
qrsay(XNIVEL++,@fOR   ,cPIC)
qrsay(XNIVEL++,@fTR   ,cPIC)
qrsay(XNIVEL++,@fOA   ,cPIC)
qrsay(XNIVEL++,@fDLD  ,cPIC)

nSFLPA := fSILPA+fCMSI+fLAP+fPAP+fVICS+fACEA+fADEA+fRR+fOR+fTR+fOA+fDLD

qsay(20,60,@nSFLPA,cPIC)

aadd(aEDICAO,{{ || qgetx(-1,0,@fSILPA,cPIC  )},"SILPA"})
aadd(aEDICAO,{{ || qgetx(-1,0,@fCMSI ,cPIC  )},"CMSI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@fLAP  ,cPIC  )},"LAP"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@fPAP  ,cPIC  )},"PAP"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@fVICS ,cPIC  )},"VICS" })
aadd(aEDICAO,{{ || qgetx(-1,0,@fACEA ,cPIC  )},"ACEA" })
aadd(aEDICAO,{{ || qgetx(-1,0,@fADEA ,cPIC  )},"ADEA" })
aadd(aEDICAO,{{ || qgetx(-1,0,@fRR   ,cPIC  )},"RR"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fOR   ,cPIC  )},"OR"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fTR   ,cPIC  )},"TR"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fOA   ,cPIC  )},"OA"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fDLD  ,cPIC  )},"DLD"  })
aadd(aEDICAO,{{ || NIL                       },"SFLPA"})
aadd(aEDICAO,{{ || qgetx(-1,0,@cMES  ,"99"  )},"MES"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nPAG  ,"9999")},"PAG"  })

do while .T.

   qmensa()
   XNIVEL  := 1
   XFLAG   := .T.
   cMES    := "  "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CONFIG->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if CONFIG->(qrlock())
      CONFIG->(qreplacefields())
      CONFIG->(qunlock())
   endif

   iif ( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "SFLPA"
           nSFLPA := fSILPA+fCMSI+fLAP+fPAP+fVICS+fACEA+fADEA+fRR+fOR+fTR+fOA+fDLD
           qrsay(XNIVEL,@nSFLPA,cPIC)
      case cCAMPO == "MES"
           if val(cMES) = 0 .or. val(cMES) > 12
              qmensa("Mes irregular !","B")
              return .F.
           endif
           qrsay(XNIVEL,cMES := strzero(val(cMES),2))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________
   if !empty(CONFIG->Inst_S_F)
     cTITULO1 := "DEMONSTRACAO DAS MUTACOES DO PATRIMONIO SOCIAL " + ;
                 rtrim(qnomemes(cMES)) + " DE " + CONFIG->Exercicio
   else
     cTITULO1 := "DEMONSTRACAO DE LUCROS OU PREJUIZOS ACUMULADOS EM " + ;
                 rtrim(qnomemes(cMES)) + " DE " + CONFIG->Exercicio
   endif

   cTITULO2 := "C.N.P.J. " + XCGCCPF

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   // INICIALIZACOES DIVERSAS _______________________________________________

   local nCONT

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   if ! qlineprn() ; return ; endif

   // CABECALHO _____________________________________________________________

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      if XPAGINA == 0
         if nPAG <= 0
            XPAGINA := 1
         else
            XPAGINA := --nPAG
         endif
      endif
      qpageprn()
      qcabecprn(cTITULO1,134,.F.,cTITULO2)
   endif

   // IMPRESSAO _____________________________________________________________

   if !empty(CONFIG->Inst_S_F)
      @ prow()+3,029 say "(+/-) SALDO INICIAL DE SUPERAVIT/DEFICIT   ACUMULADOS:  R$ " + ;
      transform(fSILPA,"@E@) 9,999,999,999.99")
   else
      @ prow()+3,029 say "(+/-) SALDO INICIAL DE LUCROS OU PREJUIZOS ACUMULADOS:  R$ " + ;
      transform(fSILPA,"@E@) 9,999,999,999.99")
   endif

   @ prow()+2,031 say "(+) CORRECAO MONETARIA.............................:  R$ " + ;
   transform(fCMSI ,"@E@) 9,999,999,999.99")

   if !empty(CONFIG->Inst_S_F)
      @ prow()+2,031 say "(+) SUPERAVIT APURADO NO PERIODO...................:  R$ " + ;
      transform(fLAP  ,"@E@) 9,999,999,999.99")
   else
      @ prow()+2,031 say "(+) LUCRO APURADO NO PERIODO.......................:  R$ " + ;
      transform(fLAP  ,"@E@) 9,999,999,999.99")

   endif

   if !empty(CONFIG->Inst_S_F)
      @ prow()+2,031 say "(-) DEFICIT APURADO NO PERIODO.....................:  R$ " + ;
      transform(fPAP  ,"@E@) 9,999,999,999.99")
   else
      @ prow()+2,031 say "(-) PREJUIZO APURADO NO PERIODO....................:  R$ " + ;
      transform(fPAP  ,"@E@) 9,999,999,999.99")
   endif

   @ prow()+2,031 say "(-) VALOR INCORPORADO AO CAPITAL SOCIAL............:  R$ " + ;
   transform(fVICS ,"@E@) 9,999,999,999.99")
   @ prow()+2,031 say "(+) AJUSTES CREDORES DE EXERCICIOS ANTERIORES......:  R$ " + ;
   transform(fACEA,"@E@) 9,999,999,999.99")
   @ prow()+2,031 say "(-) AJUSTES DEVEDORES DE EXERCICIOS ANTERIORES.....:  R$ " + ;
   transform(fADEA,"@E@) 9,999,999,999.99")
   @ prow()+2,031 say "(+) REVERSAO DE RESERVAS...........................:  R$ " + ;
   transform(fRR   ,"@E@) 9,999,999,999.99")
   @ prow()+2,031 say "(+) OUTROS RECURSOS................................:  R$ " + ;
   transform(fOR   ,"@E@) 9,999,999,999.99")
   @ prow()+2,031 say "(-) TRANSFERENCIAS PARA RESERVAS...................:  R$ " + ;
   transform(fTR   ,"@E@) 9,999,999,999.99")
   @ prow()+2,031 say "(+) OUTRAS APLICACOES..............................:  R$ " + ;
   transform(fOA   ,"@E@) 9,999,999,999.99")
   @ prow()+2,031 say "(-) DIVIDENDOS OU LUCROS DISTRIBUIDOS..............:  R$ " + ;
   transform(fDLD  ,"@E@) 9,999,999,999.99")

   if !empty(CONFIG->Inst_S_F)
      @ prow()+2,031 say "(=) SALDO FINAL DE SUPERAVIT OU DEFICIT ACUMULADOS.:  R$ " + ;
      transform(nSFLPA,"@E@) 9,999,999,999.99")
   else
      @ prow()+2,031 say "(=) SALDO FINAL DE LUCROS OU PREJUIZOS ACUMULADOS..:  R$ " + ;
      transform(nSFLPA,"@E@) 9,999,999,999.99")
   endif

   @ prow()+6,011 say "___________________________________                                     ____________________________________"
   @ prow()+1,015 say FILIAL->Contador
   @ prow()  ,090 say CONFIG->Diretor
   @ prow()+1,015 say FILIAL->Crc
   @ prow()  ,090 say CONFIG->Cpf_Direto


   qstopprn()

return

