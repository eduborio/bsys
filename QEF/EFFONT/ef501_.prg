//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: DOCUMENTO ARRECADACAO DE RECEITAS FEDERAIS - DARF
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: ABRIL DE 1995
// OBS........:
// ALTERACOES.:
function ef501

#include "ef.ch"

// POSICIONA NO MUNICIPIO E ESTADO DA EMPRESA ____________________________________

CGM->(dbseek(XCGM))

// CONFIGURACOES _________________________________________________________________

// if !quse(XDRV_EF,"CONFIG") ; return ; endif
// private cTRIB_SINC := CONFIG->Trib_Sinc
// CONFIG->(dbclosearea())

// SE TRIBUTOS FOREM SINCRONIZADOS, PEGA DA E001 _________________________________

// if cTRIB_SINC == "1"

private cDTA_VENC   := ctod("")

if CONFIG->Trib_sinc == "1"
   if !quse(XDRV_EFX,"TRIB",{"TRIB_COD","TRIB_DES"}) ; return ; endif
else
   if !quse(XDRV_EF ,"TRIB",{"TRIB_COD","TRIB_DES"}) ; return ; endif
endif

// VERIFICA SE ESTA UTILIZANDO UFIR ______________________________________________

if ! quse("","QCONFIG") ; return ; endif
private cUSA_UFIR := QCONFIG->Usa_Ufir
QCONFIG->(dbclosearea())

// FAZ RELACIONAMENTO, POSICIONA E ACIONA VIEW ___________________________________

DARF->(dbsetrelation("TRIB",{||XANOMES+DARF->Cod_Trib},"|DARF->Cod_Trib"))

DARF->(dbseek(dtos(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))),.T.))

DARF->(qview({{"Cod_Trib/C¢d."                               ,1},;
              {"substr(TRIB->Descricao,1,30)/Descri‡„o"      ,0},;
              {"Data_Ini/In¡cio"                             ,0},;
              {"Data_Fim/Fim"                                ,0},;
              {"transform(DARF->Valor,'@E 999,999.99')/Valor",0},;
              {"transform(DARF->Valor_Ufir,'@E 999,999.99')/Ufir",0}},;
              "P",;
              {NIL,"i501a",NIL,NIL},;
              {"qanomes(Data_ini)==XANOMES",{||i501top()},{||i501bot()}},;
              "<I>nc/<A>lt/<E>xc/im<P>/<T>odos/<S>em Valor/Todos Sem <V>alor/E<D>ita"))

return

function i501top
   DARF->(dbseek(dtos(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))),.T.))
return

function i501bot
   DARF->(qseekn(dtos(qfimmes(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))))))
return

//////////////////////////////////////////////////////////////////////////////////
// TRATAMENTO DAS TECLAS PRESSIONADAS ____________________________________________

function i501a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "PTASVEID"
      qmensa("")
      do case
         case cOPCAO $ "PS" ; i_individual()
         case cOPCAO $ "TV" ; i_total()
         case cOPCAO $  "A" ; i_alteracao()
         case cOPCAO $  "E" ; i_exclusao()
         case cOPCAO $  "I" ; i_inclusao()
         case cOPCAO $  "D" ; i_edita()
      endcase
   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// EDICAO DA ALTERACAO ___________________________________________________________

static function i_alteracao

   local aEDICAO     := {}

   local cOBS        := DARF->Obs
   local cCOD_TRIB   := DARF->Cod_Trib
   local dDATA_INI   := DARF->Data_Ini
   local dDATA_FIM   := DARF->Data_Fim
   local nVALOR_UFIR := DARF->Valor_UFir
   local nVALOR      := DARF->Valor
   local nJUROS      := DARF->Juros
   local nMULTA      := DARF->Multa
   local bESCAPE     := {||(XNIVEL==5.and.!XFLAG) .or. (XNIVEL==5.and.lastkey()==27)}

   // CRIACAO DO VETOR DE BLOCOS _________________________________________________
   cDTA_VENC := ctod("")
   qlbloc(5,0,"B501A","QBLOC.GLO",1)

   XNIVEL := 1

   qrsay ( XNIVEL++ , DARF->Cod_Trib  , "@R 9999"      )
   qrsay ( XNIVEL++ , TRIB->Descricao , "@!"           )
   qrsay ( XNIVEL++ , DARF->Data_ini  )
   qrsay ( XNIVEL++ , DARF->Data_fim  )
   qrsay ( XNIVEL++ , DARF->Valor_Ufir, "@E 999,999,999.99")
   qrsay ( XNIVEL++ , DARF->Valor     , "@E 999,999,999.99")
   qrsay ( XNIVEL++ , DARF->Multa     , "@E 999,999,999.99")
   qrsay ( XNIVEL++ , DARF->Juros     , "@E 999,999,999.99")
   qrsay ( XNIVEL++ , TRIB->Dia_venc  , "99" )
   qrsay ( XNIVEL   , cOBS            , "@!@S40"       )

   aadd(aEDICAO,{{ || view_trib(-1,0,@cCOD_TRIB,"@R 9999"          ) } , "CODIGO"    })
   aadd(aEDICAO,{{ || NIL                                            } ,  NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@D"                ) } , "DATA_INI"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@D"                ) } , "DATA_FIM"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR_UFIR ,"@E 999,999,999.99" ) } , "VALOR_UFIR"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR      ,"@E 999,999,999.99" ) } , "VALOR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nMULTA      ,"@E 999,999,999.99" ) } , "MULTA"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nJUROS      ,"@E 999,999,999.99" ) } , "JUROS"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cDTA_VENC   ,"@D"                ) } , "DTA_VENC"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cOBS        ,"@!@S40"            ) } , "OBS"       })

   // EDITAR SOMENTE A PARTIR DO VALOR ___________________________________________

   XNIVEL := 3

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ); return ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      qmensa("")
   enddo

   if !qconf("Confirma altera‡„o dos dados ?",)
      return
   endif

   if DARF->(qrlock())

      replace DARF->Data_ini   with dDATA_INI
      replace DARF->Data_fim   with dDATA_FIM
      replace DARF->Valor_Ufir with nVALOR_UFIR
      replace DARF->Valor      with nVALOR
      replace DARF->Juros      with nJUROS
      replace DARF->Multa      with nMULTA
      replace DARF->Obs        with cOBS
      replace DARF->Data_venc  with cDTA_VENC
      DARF->(qunlock())

   endif

//   if TRIB->(qrlock())
//      replace TRIB->Dia_venc with cDTA_VENC
//      TRIB->(qunlock())
//   endif

return

//////////////////////////////////////////////////////////////////////////////////
// EDICAO DA INCLUSAO ____________________________________________________________

static function i_inclusao

local bESCAPE := {||empty(fCOD_TRIB).or.(XNIVEL==1.and.!XFLAG).or.;
                                        (XNIVEL==1.and.lastkey()==27)}
   private aEDICAO := {}                // vetor para os campos de entrada de dados

   DARF->(qpublicfields())
   DARF->(qinitfields())

   fCOD_TRIB   := space(4)
   fOBS        := space(80)
   fVALOR_UFIR := 0
   fVALOR      := 0
   fJUROS      := 0
   fMULTA      := 0
   fDATA_INI   := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   fDATA_FIM   := qfimmes(ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4)))


   qlbloc(5,0,"B501B","QBLOC.GLO",1)

   XNIVEL := 1

   aadd(aEDICAO,{{ || view_trib(-1,0,@fCOD_TRIB,"@R 9999"          ) } , "CODIGO"    })
   aadd(aEDICAO,{{ || NIL                                            } ,  NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_INI   ,"@D"                ) } , "DATA_INI"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_FIM   ,"@D"                ) } , "DATA_FIM"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_UFIR ,"@E 999,999,999.99" ) } , "VALOR_UFIR"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR      ,"@E 999,999,999.99" ) } , "VALOR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMULTA      ,"@E 999,999,999.99" ) } , "MULTA"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fJUROS      ,"@E 999,999,999.99" ) } , "JUROS"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS        ,"@!@S40"            ) } , "OBS"       })

   // LOOP PARA ENTRADA DOS CAMPOS _______________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE );DARF->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      qmensa("")
   enddo

   if qconf("Confirma inclus„o do Darf ?",)

      if DARF->(qappend())
         DARF->(qreplacefields())
         DARF->(qunlock())
      endif

   endif

return

//////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ___________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP, nMES

   qmensa("")

   do case
      case cCAMPO == "CODIGO"

           qrsay(XNIVEL,fCOD_TRIB:=strzero(val(fCOD_TRIB),4))

           if val(fCOD_TRIB) = 0
              return .F.
           endif

           if ! TRIB->(dbseek(XANOMES+fCOD_TRIB))
              qmensa("C¢digo de Tributo Inv lido !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,TRIB->Descricao)

      case cCAMPO == "DTA_VENC"

  //         nMES := val(right(XANOMES,2))

 //          iif ( ++nMES == 13 , nMES := 1 , )

 //          zTMP := qfimmes(ctod("01/" + strzero(nMES,2) + "/" + left(XANOMES,4)))

//           if val(cDTA_VENC) > day(zTMP)
//              return .F.
//           endif

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _______________________________

static function i_individual

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   // IMPRIME DARF INDIVIDUAL ____________________________________________________

   i_imp_1()

   qstopprn(.F.)

return

//////////////////////////////////////////////////////////////////////////////////
// IMPRIME TOTAS AS DARF DO VIEW _________________________________________________

static function i_total

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   i501top()

   do while qanomes(DARF->Data_ini) == XANOMES
      i_imp_1()
      DARF->(dbskip())
   enddo

   i501top()

   qstopprn(.F.)

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR DARF ______________________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste registro ?")
      if DARF->(qrlock())
         DARF->(dbdelete())
         DARF->(qunlock())
      else
         qm3()
      endif
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// IMPRIME AS DARF DO VIEW UMA A UMA _____________________________________________

static function i_imp_1

   local nMES := val(right(XANOMES,2)), nANO := val(left(XANOMES,4)), nUFIR_1, nUFIR_2

   if cOPCAO $ "PT" .and. DARF->Valor = 0
      return
   endif

   if DARF->Valor < 10.00
      return
   endif

   // INCREMENTA MES DO VENCIMENTO _______________________________________________

   nMES++

   // VOLTA AO MES DO MOVIMENTO CASO SEJA IPI, E ESTEJA NA 1¦ ou 2¦ DEZENA _______

   if DARF->Cod_Trib == K_IPI .and. strzero(day(DARF->Data_Ini),2) $ "01_11" .and. CONFIG->Ipi_desc $ "S "
      nMES--
   endif

   // INCREMENTA ANO _____________________________________________________________

   if nMES = 13
      nMES := 1
      nANO++
   endif

   @ prow()  ,000 say XCOND0

   @ prow()  ,67 say dtoc(DARF->Data_fim)
   @ prow()+2,58 say XCGCCPF
   @ prow()+2,60 say DARF->Cod_Trib

   @ prow()+4,01 say XCOND1 + XRAZAO + space(1) + XTELEFONE + XCOND0
   if empty(DARF->Data_venc)
      @ prow()  ,60 say TRIB->Dia_Venc + "/" + strzero(nMES,2)+ "/" + strzero(nANO,4)
   else
      @ prow()  ,60 say dtoc(DARF->Data_Venc) //+ "/" + strzero(nMES,2)+ "/" + strzero(nANO,4)
   endif

   // IMPRESSAO COM VALOR, INDIVIDUAL OU GERAL ___________________________________

   if cOPCAO $ "PT"
      @ prow()+2 ,60 say DARF->Valor picture "@E 999,999,999.99"

      // IMPRIME MULTA E JUROS, CASO EXISTAM _____________________________________

      if DARF->Multa > 0 .or. DARF->Juros > 0
         @ prow()+2,60 say DARF->Multa picture "@E 999,999,999.99"
         @ prow()+2,60 say DARF->Juros picture "@E 999,999,999.99"
      else
        @ prow()+4,00 say ""
      endif
   endif

   // IMPRIME O TOTAL, CASO EXISTAM MULTA E JUROS ________________________________

   @ prow()+2,60 say (DARF->Valor + DARF->Multa + DARF->Juros) picture "@E 999,999,999.99"

   @ prow()+8 ,000 say ""

return

//////////////////////////////////////////////////////////////////////////////////
// EDICAO PARA IMPRESSAO SEM GRAVAR NO ARQUIVO ___________________________________

static function i_edita

   local aEDICAO     := {}
  // local dDTA_VENC   := ctod("")
   local cOBS        := space(40)
   local cCOD_TRIB   := "    "
   local dDATA_INI   := ctod("")
   local dDATA_FIM   := ctod("")
   local nVALOR_UFIR := 0
   local nVALOR      := 0
   local nJUROS      := 0
   local nMULTA      := 0
   local nIMP        := 1                           // Quantidade de impressao
   local bESCAPE     := {||(XNIVEL==5.and.!XFLAG) .or. (XNIVEL==5.and.lastkey()==27)}

   // CRIACAO DO VETOR DE BLOCOS _________________________________________________

   qlbloc(5,0,"B501C","QBLOC.GLO",1)

   view_trib(8,16,@cCOD_TRIB,"@R 9999"           ) ; TRIB->(dbseek(XANOMES+cCOD_TRIB))
   qsay(8,33,TRIB->Descricao)
   qgetx(10,23,@dDATA_INI   ,"@D"                )
   qgetx(10,59,@dDATA_FIM   ,"@D"                )
   qgetx(12,23,@nVALOR_UFIR ,"@E 999,999,999.99" )
   qgetx(12,59,@nVALOR      ,"@E 999,999,999.99" )
   qgetx(14,23,@nMULTA      ,"@E 999,999,999.99" )
   qgetx(14,59,@nJUROS      ,"@E 999,999,999.99" )
   qgetx(16,23,@dDTA_VENC   ,"@D"                )
   qgetx(18,23,@cOBS        ,"@!@S40"            )
   qgetx(18,71,@nIMP        ,"99"                )

   for nCONT = 1 to nIMP

       if ! qconf("Confirma impress„o ?")
          return
       endif

       //////////////////////////////////////////////////////////////////////////////////
       // IMPRIME DARF __________________________________________________________________

       if ! qinitprn() ; return ; endif

       @ prow()  ,000 say XCOND0
       @ prow()  ,057 say dtoc(dDTA_VENC)
       @ prow()+1,026 say XCOND1 + XAEXPAN + XCGCCPF + XDEXPAN + XCOND0
       @ prow()+1,057 say XCGCCPF

       @ prow()+1,026 say XCOND2 + XRAZAO + XCOND0
       @ prow()+1,057 say cCOD_TRIB

       @ prow()+1,026 say XCOND2 + XENDERECO + XCOND0

       @ prow()+1,026 say XCOND2 + transform(XCEP,"@R 99.999-999") + " - " + Alltrim(CGM->Municipio) + " - " + CGM->Estado + XCOND0

       @ prow()+4,003 say XCOND1 + XRAZAO + space(18) + XTELEFONE + XCOND0

       // IMPRESSAO COM VALOR, INDIVIDUAL OU GERAL ___________________________________

       @ prow(),pcol()+10 say nVALOR picture "@E 999,999,999.99"

       // IMPRIME MULTA E JUROS, CASO EXISTAM _____________________________________

       if nMULTA > 0 .or. nJUROS > 0
          @ prow()+2,059  say nMULTA picture "@E 999,999,999.99"
          if cUSA_UFIR = "1"
             @ prow()+1,000 say "Valor em R$   " + transform(nValor     , "@E 999,999,999.99")
             @ prow()+1,000 say "Valor em Ufir " + transform(nValor_Ufir, "@E 999,999,999.99")
          else
             @ prow()+2,000 say "Valor em R$   " + transform(nValor     , "@E 999,999,999.99")
          endif
       else
          if cUSA_UFIR = "1"
             @ prow()+3,000 say "Valor em R$   " + transform(nValor     , "@E 999,999,999.99")
             @ prow()+1,000 say "Valor em Ufir " + transform(nValor_Ufir, "@E 999,999,999.99")
          else
             @ prow()+4,000 say "Valor em R$   " + transform(nValor     , "@E 999,999,999.99")
          endif
       endif

       if nMulta > 0 .or. nJuros > 0
          @ prow(),59 say nJuros picture "@E 999,999,999.99"
       endif

       @ prow()+1,000 say TRIB->Descricao

       @ prow()+1,000 say "Referencia : " + dtOc(dDATA_INI) + " a " + dtoc(dDATA_FIM)

       // IMPRIME O TOTAL, CASO EXISTAM MULTA E JUROS ________________________________

       if nMulta > 0 .or. nJuros > 0
          @ prow(),59 say (nValor + nMulta + nJuros) picture "@E 999,999,999.99"
       endif

       @ prow()+1,pcol() say XCOND1

       @ prow()  ,005 say Substr(cObs,1,40)
       @ prow()+1,005 say Substr(cObs,41,80)
       @ prow()+6,000 say ""

       qstopprn(.F.)

   next

return
