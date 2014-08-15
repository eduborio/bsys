/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: DEMONSTRACAO DAS ORIGENS E APLICACOES DE RECURSOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: DEZEMBRO DE 1995
// OBS........:
// ALTERACOES.:
function ct518

#include "inkey.ch"
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO := {}                    // vetor para os campos
private cTITULO1                         // titulo 1 do relatorio
private cTITULO2                         // titulo 2 do relatorio
private fLPLE                            // lucro (prejuizo) liquido do exercicio
private fDE                              // depreciacoes do exercicio
private fRCMB                            // resultado da correcao monetaria do balanco
private fREP                             // resultado da equivalencia patrimonial
private fVREF                            // variacoes nos resultados de exercicios futuros
private fRCS                             // realizacao do capital social
private fCRC                             // contribuicoes para reservas de capital
private fAPELP                           // aumento do passivo exigivel a longo prazo
private fRARLP                           // reducao do ativo realizavel a longo prazo
private fAIAI                            // alienacao de investimentos e do ativo imobilizado
private fDRQNTRE                         // dividendos recebidos - que nao transitaram no resultado do exercicio
private fDD                              // dividendos distribuidos
private fADAI                            // aquisicao de direitos so ativo imobilizado
private fAAI                             // aumento do ativo investimentos
private fAAD                             // aumento do ativo diferido
private fAARLP                           // aumento do ativo realizavel a longo prazo
private fRPELP                           // reducao do passivo exigivel a longo prazo
private nTOTORI                          // total de origens de recursos
private nTOTAPL                          // total de aplicacoes
private nARCCL                           // aumento ou reducao do capital circulante liquido
private nPAG   := 0                      // pagina inicial para impressao
private nNIVEL                           // nivel da conta
private cMES                             // mes de referencia
private cTELA                            // auxiliar
private cPIC   := "@E 9,999,999,999.99"  // picture generica

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B518A","QBLOC.GLO")

CONFIG->(qpublicfields())
CONFIG->(qcopyfields())

XNIVEL := 1

qrsay(XNIVEL++,@fLPLE   ,cPIC)
qrsay(XNIVEL++,@fDE     ,cPIC)
qrsay(XNIVEL++,@fRCMB   ,cPIC)
qrsay(XNIVEL++,@fREP    ,cPIC)
qrsay(XNIVEL++,@fVREF   ,cPIC)
qrsay(XNIVEL++,@fRCS    ,cPIC)
qrsay(XNIVEL++,@fCRC    ,cPIC)
qrsay(XNIVEL++,@fAPELP  ,cPIC)
qrsay(XNIVEL++,@fRARLP  ,cPIC)
qrsay(XNIVEL++,@fAIAI   ,cPIC)
qrsay(XNIVEL++,@fDRQNTRE,cPIC)
qrsay(XNIVEL++,@fDD     ,cPIC)
qrsay(XNIVEL++,@fADAI   ,cPIC)
qrsay(XNIVEL++,@fAAI    ,cPIC)
qrsay(XNIVEL++,@fAAD    ,cPIC)
qrsay(XNIVEL++,@fAARLP  ,cPIC)
qrsay(XNIVEL++,@fRPELP  ,cPIC)

nTOTORI := fLPLE + fDE   + fRCMB + fREP + fVREF  + fRCS + fCRC + fAPELP + fRARLP + fAIAI + fDRQNTRE
nTOTAPL := fDD   + fADAI + fAAI  + fAAD + fAARLP + fRPELP

nARCCL  := nTOTORI - nTOTAPL

qsay(23,63,@nARCCL,cPIC)

aadd(aEDICAO,{{ || qgetx(-1,0,@fLPLE   ,cPIC)},"LPLE"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fDE     ,cPIC)},"DE"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@fRCMB   ,cPIC)},"RCMB"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fREP    ,cPIC)},"REP"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@fVREF   ,cPIC)},"VREF"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fRCS    ,cPIC)},"RCS"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@fCRC    ,cPIC)},"CRC"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@fAPELP  ,cPIC)},"APELP"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@fRARLP  ,cPIC)},"RARLP"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@fAIAI   ,cPIC)},"AIAI"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fDRQNTRE,cPIC)},"DRQNTRE"})
aadd(aEDICAO,{{ || qgetx(-1,0,@fDD     ,cPIC)},"DD"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@fADAI   ,cPIC)},"ADAI"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fAAI    ,cPIC)},"AAI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@fAAD    ,cPIC)},"AAD"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@fAARLP  ,cPIC)},"AARLP"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@fRPELP  ,cPIC)},"RPELP"  })

do while .T.

   qmensa()
   XNIVEL := 1
   XFLAG  := .T.
   cMES   := "  "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CONFIG->(qreleasefields()) ; return ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if CONFIG->(qrlock())
      CONFIG->(qreplacefields())
      CONFIG->(qunlock())
   endif

   iif ( i_inicializacao() , i_imprime() , NIL )

   qrbloc(12,14,cTELA)

enddo

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
   local dDATA , cDIA

   nTOTORI := fLPLE + fDE   + fRCMB + fREP + fVREF  + fRCS + fCRC + fAPELP + fRARLP + fAIAI + fDRQNTRE
   nTOTAPL := fDD   + fADAI + fAAI  + fAAD + fAARLP + fRPELP

   nARCCL  := nTOTORI - nTOTAPL

   qsay(23,63,nARCCL,cPIC)
   
   cTELA := qsbloc(12,14,14,57)

   qlbloc(12,14,"B518B","QBLOC.GLO")

   qgetx(13,32,@cMES ,"99")
   
   if empty(cMES)
      qrbloc(12,14,cTELA)
      return .F.
   endif

   qsay(13,32,strzero(val(cMES),2))

   qgetx(13,52,@nPAG ,"9999")
   qsay(13,52,strzero(nPAG,4))

   dDATA := qfimmes(ctod("01/" + cMES + CONFIG->Exercicio))
   cDIA  := day(dDATA)

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO1 := "DEMONSTRACAO DAS ORIGENS E APLICACOES DE RECURSOS EM "
   cTITULO1 += strzero(cDIA,2) + " DE " + ltrim(qnomemes(cMES)) + " DE " + CONFIG->Exercicio

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
      qcabecprn(cTITULO1,132,.F.)
   endif

   // IMPRESSAO _____________________________________________________________

    @ prow()+2,020 say "1 - ORIGENS DE RECURSOS"

   if !empty(CONFIG->Inst_S_F)
      @ prow()+2,024 say "SUPERAVIT (DEFICIT) LIQUIDO DO EXERCICIO.............................:  R$ " + ;
      transform(fLPLE   ,cPIC)
   else
      @ prow()+2,024 say "LUCRO (PREJUZO) LIQUIDO DO EXERCICIO.................................:  R$ " + ;
      transform(fLPLE   ,cPIC)
   endif

   @ prow()+2,024 say "DEPRECIACOES, AMORTIZACOES E EXAUSTOES DO EXERCICIO..................:  R$ " + ;
   transform(fDE     ,cPIC)
   @ prow()+2,024 say "RESULTADO DA CORRECAO MONETARIA DO BALANCO...........................:  R$ " + ;
   transform(fRCMB   ,cPIC)
   @ prow()+2,024 say "RESULTADO DA EQUIVALENCIA PATRIMONIAL................................:  R$ " + ;
   transform(fREP    ,cPIC)
   @ prow()+2,024 say "VARIACOES NOS RESULTADOS DE EXERCICIO FUTUROS........................:  R$ " + ;
   transform(fVREF   ,cPIC)
   @ prow()+2,024 say "REALIZACAO DO CAPITAL SOCIAL.........................................:  R$ " + ;
   transform(fRCS    ,cPIC)
   @ prow()+2,024 say "CONTRIBUICOES PARA RESERVAS DE CAPITAL...............................:  R$ " + ;
   transform(fCRC    ,cPIC)
   @ prow()+2,024 say "AUMENTO DO PASSIVO EXIGIVEL  A LONGO PRAZO...........................:  R$ " + ;
   transform(fAPELP  ,cPIC)
   @ prow()+2,024 say "REDUCAO DO ATIVO REALIZAVEL A LONGO PRAZO............................:  R$ " + ;
   transform(fRARLP  ,cPIC)
   @ prow()+2,024 say "ALIENACAO DE INVESTIMENTOS E DO ATIVO IMOBILIZADO....................:  R$ " + ;
   transform(fAIAI   ,cPIC)
   @ prow()+2,024 say "DIVIDENDOS RECEBIDOS - QUE NAO TRANSITARAM NO RESULTADO DO EXERCICIO.:  R$ " + ;
   transform(fDRQNTRE,cPIC)

   @ prow()+1,099 say "________________"
   @ prow()+1,073 say "TOTAL DAS ORIGENS...:  R$ " + transform(nTOTORI,cPIC)

   @ prow()+2,020 say "2 - APLICACOES DE RECURSOS"
   
   @ prow()+2,024 say "DIVIDENDOS DISTRIBUIDOS..............................................:  R$ " + ;
   transform(fDD     ,cPIC)
   @ prow()+2,024 say "AQUISICAO DE DIREITOS DO ATIVO IMOBILIZADO...........................:  R$ " + ;
   transform(fADAI   ,cPIC)
   @ prow()+2,024 say "AUMENTO  DO ATIVO INVESTIMENTOS......................................:  R$ " + ;
   transform(fAAI    ,cPIC)
   @ prow()+2,024 say "AUMENTO DO ATIVO DIFERIDO............................................:  R$ " + ;
   transform(fAAD    ,cPIC)
   @ prow()+2,024 say "AUMENTO DO ATIVO REALIZAVEL A LONGO PRAZO............................:  R$ " + ;
   transform(fAARLP  ,cPIC)
   @ prow()+2,024 say "REDUCAO DO PASSIVO EXIGIVEL A LONGO PRAZO............................:  R$ " + ;
   transform(fRPELP  ,cPIC)
   
   @ prow()+1,099 say "________________"
   @ prow()+1,073 say "TOTAL DAS APLICACOES:  R$ " + transform(nTOTAPL,cPIC)

   @ prow()+2,020 say "3 - AUMENTO OU REDUCAO DO CAPITAL CIRCULANTE LIQUIDO.....................:  R$ " + transform(nARCCL,"@E@) 9,999,999,999.99")

   @ prow()+2,011 say "___________________________________                                     ____________________________________"
   @ prow()+1,015 say FILIAL->Contador
   @ prow()  ,090 say CONFIG->Diretor
   @ prow()+1,015 say FILIAL->Crc
   @ prow()  ,090 say CONFIG->Cpf_Direto

   qstopprn()

return

