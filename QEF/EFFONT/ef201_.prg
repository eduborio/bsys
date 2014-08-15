/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DAS NOTAS DE ENTRADA
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JUNHO DE 1994
// OBS........:
// ALTERACOES.:
function ef201

#include "inkey.ch"
#include "ef.ch"

private nVALOR := 0     // Variavel temporario para guardar outras aliquotas
private cCOD_FORN       // Codigo do fornecedor temporario
private mFILIAL

// CONFIGURACOES _________________________________________________________

private cFILIAL
private zFILIAL  := space(4)
private zSERIE   := space(2)
private zESPECIE := space(2)
private zCFOP    := space(5)
private zTPO     := space(6)
private zCOD_CONT:= space(5)


PLAN->(dbsetorder(3)) // codigo reduzido

if ! quse("","QCONFIG") ; return ; endif
private cVERIFICA := QCONFIG->Verifica
QCONFIG->(dbclosearea())

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS NOTAS DE ENTRADA __________________________________________

ENT->(dbseek(XANOMES))

ENT->(qview({{"Data_Lanc/Data Lan‡.",2},;
             {"Num_Nf/Nota Fiscal"  ,1},;
             {"Serie/S‚rie"         ,0},;
             {"transform(Vlr_Cont,'@E 999,999,999.99')/Valor Cont.",0},;
             {"transform(Icm_base,'@E 999,999,999.99')/B. de C lculo",0},;
             {"transform(Icm_Vlr, '@E 999,999.99'    )/Valor ICM"  ,0},;
             {"Cfop/Cfop"     ,0}},"P",;
             {NIL,"i_201a",NIL,NIL},;
             {"qanomes(Data_lanc)==XANOMES",{||i201top()},{||i201bot()}},;
             "<ESC>-Sai/<A>lt/<E>xc/<I>nc/<C>on/Pesquisa <N>ota"))

return

function i201top
   ENT->(dbseek(dtos(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))),.T.))
return

function i201bot
   ENT->(qseekn(dtos(qfimmes(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))))))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_201a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO=="N",i_pesq_nota(),nil)

   if cOPCAO $ XUSRA
      do case
         // COMERCIO, PRESTACAO E MAQUINA REGISTRADORA ___________________________
         case XTIPOEMP $ "1269"
              iif(val(left(CONFIG->Anomes,4)) > 2002,qlbloc(6,2,"B201N","QBLOC.GLO",1),qlbloc(6,2,"B201A","QBLOC.GLO",1))
         case XTIPOEMP $ "38"
              qlbloc(5,2,"B201B","QBLOC.GLO",1)
         case XTIPOEMP $ "4570"
              iif(val(left(CONFIG->Anomes,4)) > 2002,qlbloc(6,2,"B201M","QBLOC.GLO",1),qlbloc(6,2,"B201C","QBLOC.GLO",1))

      endcase
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif

// FOI COLOCADO NA FUNCAO EDICAO DEPOIS DE CONFIRMAR SE FOI INCLUIDA/ALTERADA/EXCLUIDA

// if cOPCAO $ "IAE"    // TRAVA NA HORA DE EMITIR A OPCAO 507 E 508, QUANDO FOR INCLUIDA/ALTERADA/EXCLUIDA
//    lAPURADO_E := lAPURADO_S := .F.
//    dDATA_INI := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
//    if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(qfimmes(dDATA_INI))))
//       if IMP->(qrlock())
//          replace IMP->Apurado_e with lAPURADO_E
//          replace IMP->Apurado_s with lAPURADO_S
//          IMP->(qunlock())
//       endif
//    endif
// endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// PESQUISA PELO NUMERO DA NOTA __________________________________________________

static function i_pesq_nota

   local cNOTA := space(6), cSERIE := space(2) , cFILIAL := space(4)
   local nREC  := ENT->(recno())

   qmensa("Digite o numero da Nota p/ pesquisa:          ")
   qgetx(24,48,@cNOTA ,"999999")
   qmensa("Digite o numero da Filial p/ pesquisa:     ")
   qgetx(24,50,@cFILIAL ,"9999")

   cNOTA  := strzero(val(cNOTA),6)
   cFILIAL:= strzero(val(cFILIAL),4)

   ENT->(dbsetorder(7))
   if ! ENT->(dbseek(cNOTA+cFILIAL))
        ENT->(dbsetorder(2))
        if ENT->(eof())
           qmensa("Nota n„o encontrada !","B")
           ENT->(dbgoto(nREC))
           return
        endif
   else
        ENT->(dbsetorder(2))
        if qanomes(ENT->Data_lanc) <> XANOMES
           qmensa("Nota encontrada em: " + dtoc(ENT->Data_lanc) + ". Utilize op‡„o <803> !","B")
           ENT->(dbgoto(nREC))
           return
        endif
   endif
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG) .or. (XNIVEL==1.and.lastkey()==27)}
   local sBLOC1 := qlbloc("B201D","QBLOC.GLO") // Especie
   local sBLOC2 := qlbloc("B201E","QBLOC.GLO") // Isentos ICMS para 1995
   local sBLOC3 := qlbloc("B201F","QBLOC.GLO") // Outras ICMS para 1995
   local sBLOC4 := qlbloc("B201J","QBLOC.GLO") // Isentos ICMS para 1996
   local sBLOC5 := qlbloc("B201K","QBLOC.GLO") // Outras ICMS para 1996
   local sBLOC6 := qlbloc("B201CC","QBLOC.GLO") // Lancamentos por Centro de Custos

   // ESTADO DO CADASTRO DA EMPRESA ______________________________________________

   private fESTADO

   // ESTADO DO CADASTRO DO FORNECEDOR ___________________________________________

   private cESTADO
   // DATA TEMPORARIAS PARA MUDANCA DE NOTA FISCAL NA INCLUSAO ___________________
   private dTEMP_LANC

   // INICIA VARIAVEIS DE OUTRAS ALIQUOTAS _______________________________________

   private nBASE_1 := 0
   private nBASE_2 := 0
   private nBASE_3 := 0
   private nBASE_4 := 0
   private nBASE_5 := 0
   private nALIQ_1 := 0
   private nALIQ_2 := 0
   private nALIQ_3 := 0
   private nALIQ_4 := 0
   private nALIQ_5 := 0
   private nICM_1  := 0
   private nICM_2  := 0
   private nICM_3  := 0
   private nICM_4  := 0
   private nICM_5  := 0
   private nNOTAS  := 0   // PARA VERIFICAR SE JA FOI LANCADA UMA NOTA ___________

   // LANCAMENTOS POR CENTRO DE CUSTO_____________________________________________
   if CONFIG->Exig_ccust =="S"
      private nBASECC_1 := 0
      private nBASECC_2 := 0
      private nBASECC_3 := 0
      private nBASECC_4 := 0
      private nBASECC_5 := 0
      private nALIQCC_1 := 0
      private nALIQCC_2 := 0
      private nALIQCC_3 := 0
      private nALIQCC_4 := 0
      private nALIQCC_5 := 0
      private nICMCC_1  := 0
      private nICMCC_2  := 0
      private nICMCC_3  := 0
      private nICMCC_4  := 0
      private nICMCC_5  := 0
      private cCENTRO_1 := space(8)
      private cCENTRO_2 := space(8)
      private cCENTRO_3 := space(8)
      private cCENTRO_4 := space(8)
      private cCENTRO_5 := space(8)
      private aCCUSTO   := {{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "}}

   endif
   // CODIGOS PARA MAQUINA REGISTRADORA __________________________________________

   if XTIPOEMP $ "38"
      private cCOD_1 := ""
      private cCOD_2 := ""
      private cCOD_3 := ""
   endif

   if XTIPOEMP $ "38"
      private aOUTALIQ := {{0,0,0,"  "},{0,0,0,"  "},{0,0,0,"  "}}
   else
      private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
   endif

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , ENT->Filial                  ) ; FILIAL->(dbseek(ENT->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)       )
      qrsay ( XNIVEL++ , ENT->Data_Lanc  , "@D"       )
      qrsay ( XNIVEL++ , ENT->Num_Nf     , "@R 999999")
      qrsay ( XNIVEL++ , ENT->Serie                   ) ; SERIE->(dbseek(ENT->Serie  ))
      qrsay ( XNIVEL++ , ENT->Especie                 ) ; ESPECIE->(dbseek(ENT->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,15)  )
      qrsay ( XNIVEL++ , ENT->Data_Emis  , "@D"       )

      // MAQUINA REGISTRADORA ____________________________________________________

      if XTIPOEMP $ "38"  // MAQUINA REGISTRADORA
         qrsay ( XNIVEL++ , ENT->Cod_Maq , "@R 99"              ) ;MAQ->(dbseek(ENT->Cod_Maq))
         qrsay ( XNIVEL++ , MAQ->Maq_Desc                       )
      endif
      qrsay ( XNIVEL++ , ENT->Cod_Forn  , "@R 99999"            ) ;FORN->(dbseek(ENT->Cod_Forn ))
      qrsay ( XNIVEL++ , left(FORN->Razao,40)                   )
      if val(left(CONFIG->Anomes,4)) > 2002
         qrsay ( XNIVEL++ , ENT->Cfop   , "@R 9.999"            ) ;CFOP->(dbseek(ENT->Cfop))
         qrsay ( XNIVEL++ , left(CFOP->Nat_Desc,40)             )
      else
         qrsay ( XNIVEL++ , ENT->Cod_Fisc   , "@R 9.99"            ) ;NATOP->(dbseek(ENT->Cod_Fisc))
         qrsay ( XNIVEL++ , NATOP->Nat_Desc                        )
      endif
      qrsay ( XNIVEL++ , ENT->Tipo_cont                         ) ;TIPOCONT->(dbseek(ENT->Tipo_cont))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,30)           )
      qrsay ( XNIVEL++ , ENT->Cod_Cont                          ) ;CONTA->(dbseek(ENT->Cod_Cont))
      qrsay ( XNIVEL++ , CONTA->Descricao                       )
      qrsay ( XNIVEL++ , ENT->Vlr_Cont   ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_Base   ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_Red    ,  "@E 99.999"         )
      qrsay ( XNIVEL++ , ENT->Icm_Aliq   ,  "@E 99.99"          )
      qrsay ( XNIVEL++ , ENT->Icm_Vlr    ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_Isen   ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_Out    ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_bc_s   ,  "@E 999,999,999.99" )    // Foi incluido p/ resumo no final do livro

      qrsay ( XNIVEL++ , ENT->Icm_Subst  ,  "@E 999,999,999.99" )    // Foi incluido p/ resumo no final do livro

      // INDUTRIA GERAL , INDUSTRIA COM SUBSTITUICAO TRIBUTARIA __________________

      if XTIPOEMP $ "4570" // INDUSTRIA
         qrsay ( XNIVEL++ , ENT->Ipi_Base , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , ENT->Ipi_Vlr  , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , ENT->Ipi_Isen , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , ENT->Ipi_Out  , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , ENT->Ipi_Desc , "@E 999,999,999.99" )
      endif

      if val(left(CONFIG->Anomes,4)) = 1995
         qrsay ( XNIVEL++ , qabrev(ENT->Icm_Cod,"123457",{"Normal","Isentas","Outras","Diferidas","Outras Subst.Trib.","Cigarros"}) )
      else
         if ENT->Vlr_cont <> 0
//            qrsay ( XNIVEL++ , ENT->Icm_cod                          ) ;ICMS->(dbseek(ENT->Icm_Cod))
//            qrsay ( XNIVEL++ , ICMS->Descricao                       )



            qrsay ( XNIVEL++ , qabrev(ENT->Icm_Cod,"012345679",{"Trib. Integ.","Trib. c/ Cobr. do ICMS por Sub. Trib.",;
                                                  "Com Red. de Base de Calc.","Isenta/N„o Trib. e c/Cob. do ICMS por S.T.",;
                                                   "Isenta ou N„o Tributada","Com Susp. ou Diferimento","ICMS Cobrado Anter. por S.T",;
                                                   "Com Red.de Base de Calc.e Cob.do ICMS por S.T","Outras"}) )
         else
            XNIVEL ++
         endif
      endif
      qrsay ( XNIVEL++ , ENT->Obs , "@!" )
   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; i_consulta() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL ,"@!"                ) } ,"FILIAL"   })
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        }) // descricao do filial
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC    ,"@D",NIL            ) } ,"DATA_LANC"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_NF       ,"@9",NIL            ) } ,"NUM_NF"   })
   aadd(aEDICAO,{{ || view_serie(-1,0,@fSERIE   ,"99"                ) } ,"SERIE"    })
   aadd(aEDICAO,{{ || view_especie(-1,0,@fESPECIE  ,"99"             ) } ,"ESPECIE"  })
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMIS    ,"@D"                ) } ,"DATA_EMIS"})

   // MAQUINA REGISTRADORA _______________________________________________________

   if XTIPOEMP $ "38"
      aadd(aEDICAO,{{ || view_maq(-1,0,@fCOD_MAQ                    ) } ,"COD_MAQ"   })
      aadd(aEDICAO,{{ || NIL                                          } ,NIL         })
   endif
   aadd(aEDICAO,{{ || view_forn(-1,0,@fCOD_FORN                     ) } ,"COD_FORN"  })
   aadd(aEDICAO,{{ || NIL                                             } ,NIL         })
   if val(left(CONFIG->Anomes,4)) > 2002
     aadd(aEDICAO,{{ || view_cfop(-1,0,@fCFOP                         ) } ,"CFOP"  })
     aadd(aEDICAO,{{ || NIL                                             } ,NIL         })
   else
     aadd(aEDICAO,{{ || view_natop(-1,0,@fCOD_FISC                    ) } ,"COD_FISC"  })
     aadd(aEDICAO,{{ || NIL                                             } ,NIL         })
   endif
   aadd(aEDICAO,{{ || view_tpo(-1,0,@fTIPO_CONT                     ) } ,"TIPO_CONT" })
   aadd(aEDICAO,{{ || NIL                                             } ,NIL         })
   aadd(aEDICAO,{{ || view_conta(-1,0,@fCOD_CONT                    ) } ,"COD_CONT"  })
   aadd(aEDICAO,{{ || NIL                                             } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_CONT    ,"@E 999,999,999.99" ) } ,"VLR_CONT"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_BASE    ,"@E 999,999,999.99" ) } ,"ICM_BASE"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_RED     ,"@E 99.999"         ) } ,"ICM_RED"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_ALIQ    ,"@E 99.99"          ) } ,"ICM_ALIQ"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_VLR     ,"@E 999,999,999.99" ) } ,"ICM_VLR"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_ISEN    ,"@E 999,999,999.99" ) } ,"ICM_ISEN"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_OUT     ,"@E 999,999,999.99" ) } ,"ICM_OUT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_BC_S    ,"@E 999,999,999.99" ) } ,"ICM_BC_S"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_SUBST   ,"@E 999,999,999.99" ) } ,"ICM_SUBST" })

   // INDUTRIA GERAL , INDUSTRIA COM SUBSTITUICAO TRIBUTARIA _____________________

   if XTIPOEMP $ "4570"
      aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_BASE ,"@E 999,999,999.99" ) } ,"IPI_BASE" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_VLR  ,"@E 999,999,999.99" ) } ,"IPI_VLR"  })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_ISEN ,"@E 999,999,999.99" ) } ,"IPI_ISEN" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_OUT  ,"@E 999,999,999.99" ) } ,"IPI_OUT"  })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_DESC ,"@E 999,999,999.99" ) } ,"IPI_DESC" })
   endif

   if val(left(CONFIG->Anomes,4)) = 1995
      aadd(aEDICAO,{{ || qesco(16,if(XTIPOEMP $ "4570",22,22),@fICM_COD,if(!empty(fICM_ISEN),sBLOC2,sBLOC3)) } ,"ICM_COD" })
   else
//      aadd(aEDICAO,{{ || view_icms(-1,0,@fICM_COD                      ) } ,"ICM_COD"   })
//      aadd(aEDICAO,{{ || NIL                                             } ,NIL         })
      aadd(aEDICAO,{{ || qesco(14,if(XTIPOEMP $ "4570",22,22),@fICM_COD,if(!empty(fICM_ISEN),sBLOC4,sBLOC5)) } ,"ICM_COD" })
   endif

// aadd(aEDICAO,{{ || view_obs(-1,0,@fOBS      , "",NIL,cOPCAO=="I" ) } ,"OBS"       })
   aadd(aEDICAO,{{ || view_obs(-1,0,@fOBS      , "@!"               ) } ,"OBS"       })  // foi modificado 08/10/96

   // EDITA CODIGO PARA ISENTAS E OUTRAS, QUANDO UM OU AMBOS <> 0 ________________


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.

      if cOPCAO == "I"
         do case
            case XTIPOEMP $ "1269"     // COMERCIO
                 iif(val(left(CONFIG->Anomes,4)) > 2002,qlbloc(6,2,"B201N","QBLOC.GLO",1),qlbloc(6,2,"B201A","QBLOC.GLO",1))
            case XTIPOEMP $ "38"      // COMERCIO MAQ.REGISTRADORA
                 qlbloc(5,2,"B201B","QBLOC.GLO",1)
            case XTIPOEMP $ "4570"     // INDUSTRIA
                 iif(val(left(CONFIG->Anomes,4)) > 2002,qlbloc(6,2,"B201M","QBLOC.GLO",1),qlbloc(6,2,"B201C","QBLOC.GLO",1))

         endcase
      endif

      ENT->(qpublicfields())

      if cOPCAO=="I"
         ENT->(qinitfields())
         if val(left(CONFIG->Anomes,4)) = 1995
            fICM_COD   := "1"
         else
            fICM_COD   := "0"
         endif

         if nNOTAS = 0
            fDATA_LANC := qfimmes(ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4)))
            fDATA_EMIS := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
         else
            fDATA_LANC := dTEMP_LANC
            fFILIAL    := zFILIAL
            fSERIE     := zSERIE
            fESPECIE   := zESPECIE
            fCFOP      := zCFOP
            fTIPO_CONT := zTPO
            fCOD_CONT  := zCOD_CONT
         endif

        // fICM_ALIQ  := ESTADO->Aliq_Orig

         nBASE_1 := 0
         nBASE_2 := 0
         nBASE_3 := 0
         nBASE_4 := 0
         nBASE_5 := 0
         nALIQ_1 := 0
         nALIQ_2 := 0
         nALIQ_3 := 0
         nALIQ_4 := 0
         nALIQ_5 := 0
         nICM_1  := 0
         nICM_2  := 0
         nICM_3  := 0
         nICM_4  := 0
         nICM_5  := 0

         if CONFIG->Exig_ccust =="S"
             nBASECC_1 := 0
             nBASECC_2 := 0
             nBASECC_3 := 0
             nBASECC_4 := 0
             nBASECC_5 := 0
             nALIQCC_1 := 0
             nALIQCC_2 := 0
             nALIQCC_3 := 0
             nALIQCC_4 := 0
             nALIQCC_5 := 0
             nICMCC_1  := 0
             nICMCC_2  := 0
             nICMCC_3  := 0
             nICMCC_4  := 0
             nICMCC_5  := 0
             cCENTRO_1 := space(8)
             cCENTRO_2 := space(8)
             cCENTRO_3 := space(8)
             cCENTRO_4 := space(8)
             cCENTRO_5 := space(8)
             aCCUSTO   := {{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "}}
         endif

         if XTIPOEMP $ "38"
            aOUTALIQ := {{0,0,0,"  "},{0,0,0,"  "},{0,0,0,"  "}}
            cCOD_1 := ""
            cCOD_2 := ""
            cCOD_3 := ""
         else
            aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
         endif

      else
         ENT->(qcopyfields())
      endif

      XNIVEL := 1
      XFLAG := .T.

      // SE ALTERACAO , ENTAO INICIALIZA O VETOR DE OUTRAS ALIQUOTAS _____________

      if cOPCAO == "A" ; i_init_out_aliq() ; endif
      if CONFIG->Exig_ccust == "S" ; i_int_ccusto() ; endif

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );ENT->(qreleasefields());OUTENT->(qreleasefields());ENTCUST->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      // GRAVACAO ________________________________________________________________

      if ! lCONF ; return ; endif

      if OUTENT->(qflock()) .and. ENT->(iif(cOPCAO=="I",qappend(),qrlock()))
         fNUM_NF := pad(fNUM_NF,6)
         i_grava_outras()
          if CONFIG->Exig_ccust =="S"
            i_grav_centro()
          endif
         ENT->(qreplacefields())
         ENT->(qunlock())
         OUTENT->(qunlock())
         dTEMP_LANC := fDATA_LANC
         zFILIAL    := fFILIAL
         zSERIE     := fSERIE
         zESPECIE   := fESPECIE
         zTPO       := fTIPO_CONT
         zCFOP      := fCFOP
         zCOD_CONT  := fCOD_CONT

         nNOTAS++
         XNIVEL := 1
         XFLAG := .T.
      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      if cOPCAO $ "IAE"    // TRAVA NA HORA DE EMITIR A OPCAO 507 E 508, QUANDO FOR INCLUIDA/ALTERADA/EXCLUIDA
         lAPURADO_E := lAPURADO_S := .F.
         dDATA_INI := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
         if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(qfimmes(dDATA_INI))+alltrim(fFILIAL)))
            if IMP->(qrlock())
               replace IMP->Apurado_e with lAPURADO_E
               replace IMP->Apurado_s with lAPURADO_S
               IMP->(qunlock())
            endif
         endif
      endif

      if cOPCAO == "A"
         exit
      endif
   enddo

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

   local nDIFERENCA
   local nDIFER_IPI
   local nREC  := ENT->(recno())

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "FILIAL"

           qrsay(XNIVEL,fFILIAL:=strzero(val(fFILIAL),4))

           if FILIAL->(dbseek(fFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,40))
           else
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

      case cCAMPO == "DATA_LANC" .and. cOPCAO == "I"

           if empty(fDATA_LANC) ; return .F. ; endif
           mFILIAL := fFILIAL


           if substr(dtoc(fDATA_LANC),4,2) <> right(XANOMES,2)
              qmensa("Mes de Lancamento da Nota Fiscal n„o est  correto !","B")
              return .F.
           endif

           fDATA_EMIS := fDATA_LANC

      case cCAMPO == "DATA_LANC" .and. cOPCAO == "A"

           if empty(fDATA_LANC) ; return .F. ; endif

      case cCAMPO == "DATA_EMIS"

           if empty(fDATA_EMIS) ; return .F. ; endif

           if fDATA_EMIS > fDATA_LANC
              qmensa("Data de Emiss„o n„o pode ser maior que a Data de Lancamento !","B")
              return .F.
           endif

      case cCAMPO == "COD_FORN"

           if empty(fCOD_FORN) ; return .F. ; endif
           qrsay(XNIVEL,fCOD_FORN:=strzero(val(fCOD_FORN),5))

           if ! FORN->(dbseek(fCOD_FORN))
              if ! qconf("Fornecedor n„o Cadastrado ! Incluir agora ?")
                 qmensa("")
                 return .F.
              endif

              if ! i_inc_fornec()
                 return .F.
              else
                 fCOD_FORN := cCOD_FORN
                 seekb_sl("L")
                 qrsay(XNIVEL,fCOD_FORN:=strzero(val(fCOD_FORN),5))
                 FORN->(dbseek(fCOD_FORN))
              endif
              fFILIAL := mFILIAL
           endif

           qrsay(XNIVEL+1,left(FORN->Razao,40))

           // PEGA CODIGO DE CGM NO FORNECEDOR ___________________________________

           cESTADO := FORN->Cgm_ent

           // PEGA ESTADO NO CGM _________________________________________________

           if CGM->(dbseek(cESTADO))
              cESTADO := CGM->Estado
           endif

           // INICIA ALIQUOTA DE ICMS (EM CASO DE INCLUSAO) ______________________

           if cOPCAO == "I"
              if ESTADO->(dbseek(cESTADO))
                 fICM_ALIQ := ESTADO->ALiq_Orig
              endif
              qrsay(XNIVEL+9,fICM_ALIQ , "@R 99.99")
           endif

      case cCAMPO == "NUM_NF"

           if empty(fNUM_NF) ; return .F. ; endif

           qrsay(XNIVEL,fNUM_NF:=strzero(val(fNUM_NF),6))

      case cCAMPO == "SERIE" .and. cOPCAO == "I"

           // ALTERA PARA ORDEM DE NUMERO + SERIE ________________________________

           ENT->(dbsetorder(1))

           qrsay(XNIVEL,fSERIE := strzero(val(fSERIE),2))

           if ! SERIE->(dbseek(fSERIE))

              qmensa("S‚rie Invalida !","B")

              // RETORNA ORDEM PARA DATA DE LANCAMENTO ___________________________

              ENT->(dbsetorder(2))
              ENT->(dbgoto(nREC))
              return .F.

           endif

           if ENT->(dbseek(fNUM_NF + fSERIE)) .and. fFILIAL == alltrim(ENT->Filial)

              if ! qconf("ATENCŽO: Nota Fiscal j  cadastrada em "+dtoc(ENT->DATA_LANC)+". Incluir Outra ?","B")
                 XNIVEL--
              endif

           endif

           // RETORNA ORDEM PARA DATA DE LANCAMENTO ______________________________

           ENT->(dbsetorder(2))
           ENT->(dbgoto(nREC))

      case cCAMPO == "SERIE" .and. cOPCAO == "A"

           qrsay(XNIVEL,fSERIE := strzero(val(fSERIE),2))

           if ! SERIE->(dbseek(fSERIE))
              qmensa("S‚rie Inv lida !","B") ; return .F.
           endif

      case cCAMPO == "COD_FISC"

           // PEGA ESTADO NO CGM _________________________________________________

           if CGM->(dbseek(FILIAL->CGM))
              fESTADO := CGM->Estado
           endif

           if ! NATOP->(dbseek(fCOD_FISC))
              qmensa("C¢digo fiscal inv lido !","B") ; return .F.
           endif

           if substr(fCOD_FISC,1,1) $ "567"
              qmensa("Codigo fiscal inv lido para entrada das notas !","B")
              return .F.
           endif

           if right(fCOD_FISC,1) $ "0"
              qmensa("C¢digo fiscal de grupo, n„o permitido !","B")
              return .F.
           endif

           if right(fCOD_FISC,2) $ "11" .and. XTIPOEMP $ "123689"
              qmensa("C¢digo fiscal inv lido para Com‚rcio !","B")
              return .F.
           endif

           if fESTADO = cESTADO

              if left(fCOD_FISC,1) <> "1" .and. left(fCOD_FISC,1) <> "3"
                 qmensa("C¢digo Inv lido Dentro do Estado! Ver Estado do Fornecedor <101>","B")
//                 if qconf("C¢digo Inv lido Dentro do Estado! Quer alterar Fornecedor ?")
//                    ef_altera_forn()
//                 endif
                 return .F.
              endif

           else

              if !left(fCOD_FISC,1) $ "23"
                 qmensa("C¢digo Inv lido Dentro do Estado! Ver Estado do Fornecedor <101>","B")
//                 if qconf("C¢digo Inv lido Fora do Estado! Quer alterar Fornecedor ?")
//                    ef_altera_forn()
//                 endif
                 return .F.
              endif

           endif

           qrsay(XNIVEL+1,NATOP->Nat_Desc)
           fTIPO_CONT := NATOP->Tip_cont

      case cCAMPO == "CFOP"

           if CGM->(dbseek(FILIAL->CGM))
              fESTADO := CGM->Estado
           endif

           if ! CFOP->(dbseek(fCFOP))
              qmensa("C¢digo fiscal inv lido !","B") ; return .F.
           endif

           if substr(fCFOP,1,1) $ "567"
              qmensa("Codigo fiscal inv lido para entrada das notas !","B")
              return .F.
           endif

           if right(fCFOP,1) == "00"
              qmensa("C¢digo fiscal de grupo, n„o permitido !","B")
              return .F.
           endif

           if fESTADO = cESTADO

              if left(fCFOP,1) <> "1" .and. left(fCFOP,1) <> "3"
                 qmensa("C¢digo Inv lido Dentro do Estado! Ver Estado do Fornecedor <101>","B")
                 return .F.
              endif

           else

              if !left(fCFOP,1) $ "23"
                 qmensa("C¢digo Inv lido Dentro do Estado! Ver Estado do Fornecedor <101>","B")
                 return .F.
              endif

           endif


           qrsay(XNIVEL+1,left(CFOP->Nat_Desc,40))


      case cCAMPO == "TIPO_CONT"
           if empty(fTIPO_CONT); return .T.; endif
           if ! TIPOCONT->(dbseek(fTIPO_CONT))
               qmensa("C¢digo do T.P.O n„o Encontrado...!","B")
               Return .F.
           else
               qrsay(XNIVEL+1,left(TIPOCONT->Descricao,30))
           endif

      case cCAMPO == "COD_CONT"

           if empty(fCOD_CONT); return .T.; endif

           fCOD_CONT := strzero(val(fCOD_CONT),6)

           if CONTA->(dbseek(fCOD_CONT))
               qrsay(XNIVEL,fCOD_CONT)
               qrsay(XNIVEL+1,CONTA->Descricao)
           else
               qmensa("C¢digo Cont bil n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL  ,fCOD_CONT)
           qrsay(XNIVEL+1,CONTA->Descricao)

      case cCAMPO == "ESPECIE"

           qrsay(XNIVEL,fESPECIE:=strzero(val(fESPECIE),2))

           if ESPECIE->(dbseek(fESPECIE))
              qrsay(XNIVEL+1,left(ESPECIE->Descricao,15))
           else
              qmensa("Especie n„o encontrado !","B")
              return .F.
           endif

      case cCAMPO == "ICM_ALIQ" // .and. cOPCAO == "I"

           fICM_VLR := ((fICM_BASE * fICM_ALIQ) / 100)

           qrsay(XNIVEL+1,fICM_VLR,"@E 999,999,999.99")

      case cCAMPO == "ICM_RED" .and. cOPCAO == "I"

           if ! fICM_RED = 0
              fICM_BASE := fICM_BASE - (fICM_BASE * fICM_RED) / 100
              qrsay(XNIVEL-1,fICM_BASE,"@E 999,999,999.99")
              fICM_ISEN := round(fVLR_CONT,2) - round(fICM_BASE,2)
              qrsay(XNIVEL+3,fICM_ISEN,"@E 999,999,999.99")
           endif

           if !empty(fICM_RED)
              fOBS := "B.C.RED.EM " + transform(fICM_RED,"@E 99.999") + "%                  "
           endif

      case cCAMPO == "VLR_CONT" .and. cOPCAO == "I"

           if empty(fVLR_CONT)
              if XTIPOEMP $ "45780"
                 fOBS := "## NF CANCELADA"
                 XNIVEL := 32  // quando emite nota cancelada aceita valor nulo
                 qrsay(32,fOBS)
              else
                 fOBS := "## NF CANCELADA"
                 XNIVEL := 27  // quando emite nota cancelada aceita valor nulo
                 qrsay(27,fOBS)
              endif
           endif

           fICM_BASE := fVLR_CONT

           qrsay(XNIVEL+1,fICM_BASE,"@E 999,999,999.99")

      case cCAMPO == "VLR_CONT" .and. cOPCAO == "A"
           if CONFIG->Exig_ccust =="S"
               private aCCUSTO   := {{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "}}
           endif

           if empty(fVLR_CONT)
              fICM_BASE :=  fICM_RED  :=  fICM_ALIQ :=  fICM_VLR  := fICM_ISEN := fICM_OUT :=  ;
              fICM_SUBST := fICM_BC_S := 0
              OUTENT->(dbgotop())
              OUTENT->(Dbseek(dtos(fDATA_LANC) + fNUM_NF + fSERIE + fFILIAL))
              do while ! OUTENT->(eof()) .and. OUTENT->Data_lanc == fDATA_LANC .and. OUTENT->Num_nf == fNUM_NF .and. OUTENT->Serie == fSERIE .and. OUTENT->Filial == fFILIAL
                 if OUTENT->(qrlock())
                    OUTENT->(dbdelete())
                    OUTENT->(qunlock())
                 endif
                 OUTENT->(dbskip())
              enddo
              fOBS := "## NF CANCELADA"
              if XTIPOEMP $ "38"
                 aOUTALIQ := {{0,0,0,"  "},{0,0,0,"  "},{0,0,0,"  "}}
              else
                 aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}

              endif
              if XTIPOEMP $ "45780"
                 fOBS := "## NF CANCELADA"
                 XNIVEL := 32  // quando emite nota cancelada aceita valor nulo
                 qrsay(32,fOBS)
              else
                 XNIVEL := 27  // quando emite nota cancelada aceita valor nulo
                 qrsay(27,fOBS)
              endif
           endif

      case cCAMPO == "ICM_VLR" .and. cOPCAO == "I"

           nDIFERENCA := (fICM_VLR - ((fICM_ALIQ * fICM_BASE) / 100))

           if cVERIFICA = "1"
              if round(nDIFERENCA,2) >= 0.02 .or. round(nDIFERENCA,2) <= -0.02
                 qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
                 XNIVEL -= 4
              endif
           endif

           if XTIPOEMP $ "25"
              fICM_SUBST := (fICM_BC_S * (fICM_ALIQ/100)) - fICM_VLR
           endif

      case cCAMPO == "ICM_BASE" .and. cOPCAO == "I"

           if fICM_BASE == 0
              fICM_ALIQ := 0
              qrsay(XNIVEL+2,fICM_ALIQ , "@R 99.99")
           endif

           if fICM_RED = 0
              fICM_ISEN := fVLR_CONT - fICM_BASE
           endif

//           if XTIPOEMP $ "4570" .and. fICM_BASE = 0    // INDUSTRIA
//              if (fCOD_FISC) == "199" .or. (fCOD_FISC) == "299" .or. (fCOD_FISC) == "191"  .or. (fCOD_FISC) == "291"
//                 qrsay(XNIVEL+9,fVLR_CONT, "@E 999,999,999.99")
//              endif
//           endif

           qrsay(XNIVEL+4,fICM_ISEN,"@E 999,999,999.99")

           if XTIPOEMP $ "4570"
              fIPI_BASE := fICM_BASE
              fIPI_VLR  := fVLR_CONT - fICM_BASE
              qrsay(XNIVEL+8,fIPI_BASE,"@E 999,999,999.99")
              qrsay(XNIVEL+9,fIPI_VLR ,"@E 999,999,999.99")
           endif

           if XTIPOEMP $ "25"
              fICM_BC_S := fICM_BASE + (fICM_BASE * (CONFIG->Perc_subtr/100))
           endif

      case cCAMPO == "ICM_ISEN" .and. cOPCAO == "I"

           if fICM_ISEN = 0 .and. fICM_RED = 0
              fICM_OUT := fVLR_CONT - fICM_BASE
           endif

           fICM_OUT := round(fVLR_CONT,2) - round(fICM_BASE,2) - round(fICM_ISEN,2)

           qrsay(XNIVEL+1,fICM_OUT,"@E 999,999,999.99")

           if fICM_ISEN <> 0 .and. cOPCAO == "I"

              if val(left(CONFIG->Anomes,4)) = 1995
                 fICM_COD := "2"
              else
                 fICM_COD := "4"
              endif

           endif

           if fICM_ISEN > fVLR_CONT
              qmensa("Isentos n„o pode ser Maior que o Valor Cont bil !!","B")
              return .F.
           endif

      case cCAMPO == "ICM_ISEN" .and. cOPCAO == "A"
//           if fICM_ISEN = 0 .and. fICM_RED = 0
//              fICM_OUT := fVLR_CONT - fICM_BASE
//           endif
//           qrsay(XNIVEL+1,fICM_OUT,"@E 999,999,999.99")

           if fICM_ISEN <> 0 .and. cOPCAO == "A"
              if val(left(CONFIG->Anomes,4)) = 1995
                 fICM_COD := "2"
              else
                 fICM_COD := "4"
              endif
           endif

           if fICM_ISEN > fVLR_CONT
              qmensa("Isentos n„o pode ser Maior que o Valor Cont bil !!","B")
              return .F.
           endif

      case cCAMPO == "ICM_OUT" .and. cOPCAO == "I"
           if CONFIG->Exig_ccust =="S"
                aCCUSTO   := {{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "}}
           endif

           // SE EXISTE DIFERENCA ENTRA PARA EDITAR OUTRAS ALIQUOTAS _____________

           nDIFERENCA := (fVLR_CONT - (fICM_BASE + fICM_ISEN + fICM_OUT))

           if round(nDIFERENCA,2) >= 0.02 .or. round(nDIFERENCA,2) <= -0.02
              if cOPCAO == "I"
                 nBASE_1 := (fVLR_CONT - (fICM_BASE + fICM_ISEN + fICM_OUT))
                 nVALOR := nBASE_1
              endif
              i_outras_aliq()
           else
              if cOPCAO == "A"
                 if(XTIPOEMP $ "38", aOUTALIQ := {{0,0,0,""},{0,0,0,""},{0,0,0,""}},aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}})
              endif
           endif

           if round(fICM_OUT,2) <> 0

              if val(left(CONFIG->Anomes,4)) = 1995
                 fICM_COD := "3"
              else
                 fICM_COD := "9"
              endif

           endif

           if fICM_OUT > fVLR_CONT
              qmensa("Outras n„o pode ser Maior que o Valor Cont bil !!","B")
              return .F.
           endif

      case cCAMPO == "ICM_OUT" .and. cOPCAO == "A"

           i_outras_aliq()

//         if round(fICM_OUT,2) <> 0
//
//            if val(left(CONFIG->Anomes,4)) = 1995
//               fICM_COD := "3"
//            else
//               fICM_COD := "9"
//            endif
//
//         endif

           if fICM_OUT > fVLR_CONT
              qmensa("Outras n„o pode ser Maior que o Valor Cont bil !!","B")
              return .F.
           endif


      case cCAMPO == "ICM_BC_S"

           if fICM_BC_S <> 0 .and. XTIPOEMP $ "25"
              fOBS := "B.C. ST:" + transform(fICM_BC_S,"@E 999,999.99")
           endif

      case cCAMPO == "ICM_SUBST"

           if fICM_BC_S <> 0 .and. XTIPOEMP $ "25"
              fOBS := fOBS + "ICMS ST:" + transform(fICM_SUBST,"@E 999,999.99")
           endif

      case cCAMPO == "ICM_COD"

           if empty(fICM_COD) ; return .F. ; endif

           if val(left(CONFIG->Anomes,4)) = 1995
              qrsay(XNIVEL,qabrev(fICM_COD,"123457",{"Normal","Isentas","Outras","Diferidas","Outras Subst.Trib.","Cigarros"}))
           else
              if fVLR_CONT <> 0
              //   if ICMS->(dbseek(fICM_COD))
              //      qrsay(XNIVEL+1,left(ICMS->Descricao,40))
              //   else
              //      qmensa("Codigo do ICMS n„o encontrado !","B")
              //      return .F.
              //   endif



                 qrsay (XNIVEL,qabrev(fICM_COD,"012345679",{"Trib. Integ.","Trib. c/ Cobr. do ICMS por Sub. Trib.",;
                                                        "Com Red. de Base de Calc.","Isenta/N„o Trib.e c/Cob.do ICMS por S.T.",;
                                                        "Isenta ou N„o Tributada","Com Susp. ou Diferimento","ICMS Cobrado Anter. por S.T",;
                                                        "Com Red.de Base de Calc.e Cob.do ICMS por S.T","Outras"}) )
              else
                 XNIVEL ++
              endif
           endif
           if CONFIG->Exig_ccust == "S" ; i_centro() ;endif

      case cCAMPO == "IPI_VLR" .and. cOPCAO == "I"

           /* nDIFER_IPI := (fIPI_VLR - (fVLR_CONT - fICM_BASE))
           if cVERIFICA = "1"
              if round(nDIFER_IPI,2) >= 0.02 .or. round(nDIFER_IPI,2) <= -0.02
                 qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
                 XNIVEL -= 2
              endif
           endif  */

           if empty(fIPI_VLR)
              fIPI_ISEN := fIPI_BASE
              fIPI_OUT  := fIPI_BASE
              fIPI_BASE := 0
              qrsay(XNIVEL-1,fIPI_BASE , "@E 999,999,999.99")
              qrsay(XNIVEL+1,fIPI_ISEN , "@E 999,999,999.99")
           endif

      case cCAMPO == "IPI_VLR" .and. cOPCAO == "I"

           /* nDIFER_IPI := (fIPI_VLR - (fVLR_CONT - fICM_BASE))
           if cVERIFICA = "1"
              if round(nDIFER_IPI,2) >= 0.02 .or. round(nDIFER_PIP,2) <= -0.02
                 qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
                 XNIVEL -= 2
              endif
           endif   */

           if empty(fIPI_VLR)
//            fIPI_ISEN := fIPI_BASE
              fIPI_OUT  := fIPI_BASE
              fIPI_BASE := 0
              qrsay(XNIVEL-1,fIPI_BASE , "@E 999,999,999.99")
              qrsay(XNIVEL+1,fIPI_ISEN , "@E 999,999,999.99")
           endif

//      case cCAMPO == "IPI_BASE" .and. cOPCAO == "I"
//           fIPI_BASE := fICM_BASE
//           qrsay(XNIVEL,fIPI_BASE , "@E 999,999,999.99")

      case cCAMPO == "IPI_ISEN" .and. cOPCAO == "I"

           if !empty(fIPI_ISEN)
              fIPI_OUT  := 0
           endif

      case cCAMPO == "IPI_DESC"
//         nDIFERENCA := (fVLR_CONT - (fIPI_BASE + fIPI_VLR + fIPI_ISEN + fIPI_OUT - fIPI_DESC))
//         if cVERIFICA == "1"
//            if round(nDIFERENCA,2) >= 0.02 .or. round(nDIFERENCA,2) <= -0.02
//               qmensa("Valor do IPI n„o est  correto","B")
//               XNIVEL -= 5
//               return .F.
//            endif
//         endif

      case cCAMPO == "COD_MAQ"

           if ! MAQ->(dbseek(fCOD_MAQ))
              qmensa("Codigo de Sa¡da Inv lido !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,MAQ->Maq_Desc)

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR NOTAS FISCAIS DE ENTRADA___________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta nota fiscal ?")
      if OUTENT->(qflock()) .and. ENT->(qrlock())
         ENTCUST->(qrlock())
         i_grava_outras()
         if CONFIG->Exig_ccust =="S"
            i_grav_centro()
         endif
         ENT->(dbdelete())
         ENT->(qunlock())
         OUTENT->(qunlock())
         ENTCUST->(qunlock())
      else
         qm3()
      endif
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// LANCAMENTOS DE OUTRAS ALIQUOTAS _______________________________________________

static function i_outras_aliq

   local nNIVEL  := XNIVEL
   local sBLOC := qsbloc(5,0,24,79)
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG)}

   if XTIPOEMP $ "38"
      qlbloc(5,0,"B201H","QBLOC.GLO")
   else
      qlbloc(5,0,"B201O","QBLOC.GLO")
   endif

   XNIVEL := 1

   // ATUALIZA A TELA ____________________________________________________________

   qrsay(XNIVEL++ , nBASE_1 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_1 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_1  , "@E 999,999,999.99" )

   if XTIPOEMP $ "38"
      qrsay(XNIVEL++ , cCOD_1  , "99"             )
   endif

   qrsay(XNIVEL++ , nBASE_2 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_2 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_2  , "@E 999,999,999.99" )
                            
   if XTIPOEMP $ "38"
      qrsay(XNIVEL++ , cCOD_2  , "99"             )
   endif

   qrsay(XNIVEL++ , nBASE_3 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_3 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_3  , "@E 999,999,999.99" )

   qrsay(XNIVEL++ , nBASE_4 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_4 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_4  , "@E 999,999,999.99" )

   qrsay(XNIVEL++ , nBASE_5 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_5 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_5  , "@E 999,999,999.99" )


   if XTIPOEMP $ "38"
      qrsay(XNIVEL++ , cCOD_3  , "99"             )
   endif

   XNIVEL := 1

   // CALCULO DAS OUTRAS ALIQUOTAS _______________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_1   , "@E 999,999,999.99") } ,"BASE_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_1   , "@E 99.99"         ) } ,"ALIQ_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_1    , "@E 999,999,999.99") } ,"ICM_1"  })

   if XTIPOEMP $ "38"
      aadd(aEDICAO,{{ || view_maq(-1,0,@cCOD_1 , "99"            ) } ,"COD_1"  })
   endif

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_2   , "@E 999,999,999.99") } ,"BASE_2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_2   , "@E 99.99"         ) } ,"ALIQ_2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_2    , "@E 999,999,999.99") } ,"ICM_2"  })

   if XTIPOEMP $ "38"
      aadd(aEDICAO,{{ || view_maq(-1,0,@cCOD_2 , "99"            ) } ,"COD_2"  })
   endif

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_3   , "@E 999,999,999.99") } ,"BASE_3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_3   , "@E 99.99"         ) } ,"ALIQ_3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_3    , "@E 999,999,999.99") } ,"ICM_3"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_4   , "@E 999,999,999.99") } ,"BASE_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_4   , "@E 99.99"         ) } ,"ALIQ_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_4    , "@E 999,999,999.99") } ,"ICM_4"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_5   , "@E 999,999,999.99") } ,"BASE_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_5   , "@E 99.99"         ) } ,"ALIQ_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_5    , "@E 999,999,999.99") } ,"ICM_5"  })



   if XTIPOEMP $ "38"
      aadd(aEDICAO,{{ || view_maq(-1,0,@cCOD_3 , "99"            ) } ,"COD_3"  })
   endif

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE )
//         qrbloc(14,32,sBLOC)
         qrbloc(5,0,sBLOC)
         XNIVEL := nNIVEL
         return
      endif
      if ! i_crit_3( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   XNIVEL := nNIVEL
   qrbloc(5,0,sBLOC)

   aOUTALIQ[1,1] := nBASE_1
   aOUTALIQ[2,1] := nBASE_2
   aOUTALIQ[3,1] := nBASE_3
   aOUTALIQ[4,1] := nBASE_4
   aOUTALIQ[5,1] := nBASE_5
   aOUTALIQ[1,2] := nALIQ_1
   aOUTALIQ[2,2] := nALIQ_2
   aOUTALIQ[3,2] := nALIQ_3
   aOUTALIQ[4,2] := nALIQ_4
   aOUTALIQ[5,2] := nALIQ_5
   aOUTALIQ[1,3] := nICM_1
   aOUTALIQ[2,3] := nICM_2
   aOUTALIQ[3,3] := nICM_3
   aOUTALIQ[4,3] := nICM_4
   aOUTALIQ[5,3] := nICM_5



   if XTIPOEMP $ "38"
      aOUTALIQ[1,4] := cCOD_1
      aOUTALIQ[2,4] := cCOD_2
      aOUTALIQ[3,4] := cCOD_3
   endif

return

////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA _________________________________________________________

static function i_crit_3 ( cCAMPO )

   local nDIFERE := 0

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "ICM_1"
           nDIFERE := (nICM_1 - ((nBASE_1 * nALIQ_1) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 3
           endif

           if cOPCAO == "I"
              nBASE_2 := nVALOR - nBASE_1
              qrsay(XNIVEL+1,nBASE_2,"@E 999,999,999.99")
              nVALOR  := nBASE_2
           endif

      case cCAMPO == "ICM_2"
           nDIFERE := (nICM_2 - ((nBASE_2 * nALIQ_2) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 3
           endif

           if cOPCAO == "I"
              nBASE_3 := nVALOR - nBASE_2
              qrsay(XNIVEL+1,nBASE_3,"@E 999,999,999.99")
              nVALOR  := nBASE_3
           endif

      case cCAMPO == "ICM_3"
           nDIFERE := (nICM_3 - ((nBASE_3 * nALIQ_3) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 3
           endif

           if cOPCAO == "I"
              nBASE_4 := nVALOR - nBASE_3
              qrsay(XNIVEL+1,nBASE_4,"@E 999,999,999.99")
              nVALOR  := nBASE_4

           endif

      case cCAMPO == "ICM_4"
           nDIFERE := (nICM_4 - ((nBASE_4 * nALIQ_4) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 3
           endif

           if cOPCAO == "I"
              nBASE_5 := nVALOR - nBASE_4
              qrsay(XNIVEL+1,nBASE_5,"@E 999,999,999.99")
              nVALOR  := nBASE_5

           endif


      case cCAMPO == "ICM_5"
           nDIFERE := (nICM_5 - ((nBASE_5 * nALIQ_5) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 3
           endif

      case cCAMPO == "ALIQ_1" .and. cOPCAO $ "IA"
           nICM_1 := (nBASE_1 * nALIQ_1) / 100
           qrsay(XNIVEL+1, nICM_1 , "@E 999,999,999.99")

      case cCAMPO == "ALIQ_2" .and. cOPCAO $ "IA"
           nICM_2 := (nBASE_2 * nALIQ_2) / 100
           qrsay(XNIVEL+1, nICM_2 , "@E 999,999,999.99")

      case cCAMPO == "ALIQ_3" .and. cOPCAO $ "IA"
           nICM_3 := (nBASE_3 * nALIQ_3) / 100
           qrsay(XNIVEL+1, nICM_3 , "@E 999,999,999.99")

      case cCAMPO == "ALIQ_4" .and. cOPCAO $ "IA"
           nICM_4 := (nBASE_4 * nALIQ_4) / 100
           qrsay(XNIVEL+1, nICM_4 , "@E 999,999,999.99")

      case cCAMPO == "ALIQ_5" .and. cOPCAO $ "IA"
           nICM_5 := (nBASE_5 * nALIQ_5) / 100
           qrsay(XNIVEL+1, nICM_5 , "@E 999,999,999.99")



   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// PARA CONSULTAR SE POSSUI OUTRAS ALIQUOTAS _____________________________________

static function i_consulta

   local nTECLA, nCONT

   setpos(24,79)

   qmensa("<ESC> p/ voltar ou <O>utras Aliquotas, <L>anc p/ Centro de Custos")

   do while .T.

      nTECLA := qinkey()

      if nTECLA == K_ESC ; exit ; endif

      if upper(chr(nTECLA)) == "O"
         i_init_out_aliq()
         XNIVEL := 1

         if XTIPOEMP $ "38"
            qlbloc(5,0,"B201H","QBLOC.GLO")
         else
            qlbloc(5,0,"B201O","QBLOC.GLO")
         endif

         for nCONT := 1 to 5
             qrsay(XNIVEL++,aOUTALIQ[nCONT,1],"@E 999,999,999.99")
             qrsay(XNIVEL++,aOUTALIQ[nCONT,2],"@E 99.99")
             qrsay(XNIVEL++,aOUTALIQ[nCONT,3],"@E 999,999,999.99")
             if XTIPOEMP $ "38"
                qrsay(XNIVEL++,aOUTALIQ[nCONT,4],"99")
             endif
         next

         qwait()

         exit

      endif

      if upper(chr(nTECLA)) == "L"
         i_int_ccusto()
         XNIVEL := 1
            qlbloc(5,0,"B202CC","QBLOC.GLO")

         for nCONT := 1 to 5
             qrsay(XNIVEL++,aCCUSTO[nCONT,1],"@E 999,999,999.99")
             qrsay(XNIVEL++,aCCUSTO[nCONT,2],"@E 99.99")
             qrsay(XNIVEL++,aCCUSTO[nCONT,3],"@E 999,999,999.99")
             qrsay(XNIVEL++,aCCUSTO[nCONT,4],"99999999")
         next

         qwait()

         exit

      endif

   enddo

return

//////////////////////////////////////////////////////////////////////////////////
// PARA INICIAR VALORES DE OUTRAS ALIQUOTAS ______________________________________

static function i_init_out_aliq

   if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ ENT->Num_nf + ENT->Serie + ENT->Filial))
 //if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ ENT->Num_nf + ENT->Serie + ENT->Filial + ENT->Icm_cod))
      for nCONT := 1 to 5
           aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
           aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
           aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr
           if XTIPOEMP $ "38"
              aOUTALIQ[nCONT,4] := OUTENT->Cod_Maq
           endif
           OUTENT->(dbskip())
           if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
//         if ENT->Num_nf + ENT->Serie + ENT->Filial + ENT->Icm_cod <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial + OUTENT->Icm_cod
              exit
           endif
      next
   else
      return
   endif

   // INICIA VARIAVEIS PARA EDICAO _______________________________________________

   nBASE_1 := aOUTALIQ[1,1]
   nBASE_2 := aOUTALIQ[2,1]
   nBASE_3 := aOUTALIQ[3,1]
   nBASE_4 := aOUTALIQ[4,1]
   nBASE_5 := aOUTALIQ[5,1]
   nALIQ_1 := aOUTALIQ[1,2]
   nALIQ_2 := aOUTALIQ[2,2]
   nALIQ_3 := aOUTALIQ[3,2]
   nALIQ_4 := aOUTALIQ[5,2]
   nALIQ_5 := aOUTALIQ[5,2]
   nICM_1  := aOUTALIQ[1,3]
   nICM_2  := aOUTALIQ[2,3]
   nICM_3  := aOUTALIQ[3,3]
   nICM_4  := aOUTALIQ[4,3]
   nICM_5  := aOUTALIQ[5,3]

   if XTIPOEMP $ "38"
      cCOD_1 := aOUTALIQ[1,4]
      cCOD_2 := aOUTALIQ[2,4]
      cCOD_3 := aOUTALIQ[3,4]
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// GRAVA AS OUTRAS ALIQUOTAS _____________________________________________________

static function i_grava_outras

   do while OUTENT->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie + ENT->Filial))
      OUTENT->(dbdelete())
   enddo

   // OBS. UTILIZADA TAMBEM PARA EXCLUSAO DE LANCAMENTO, QUANDO O VETOR
   // VAI ESTAR VAZIO E NAO VAI ENTRAR NO for ABAIXO...

   for nCONT := 1 to 5

       if empty(aOUTALIQ[nCONT,1]) ; exit ; endif

       OUTENT->(qappend())
       replace OUTENT->Data_Lanc with fDATA_LANC
       replace OUTENT->Num_Nf    with fNUM_NF
       replace OUTENT->Serie     with fSERIE
       replace OUTENT->Filial    with fFILIAL
       replace OUTENT->Icm_Base  with aOUTALIQ[nCONT,1]
       replace OUTENT->Icm_Aliq  with aOUTALIQ[nCONT,2]
       replace OUTENT->Icm_Vlr   with aOUTALIQ[nCONT,3]
//     replace OUTENT->Icm_Cod   with fICM_COD

       if XTIPOEMP $ "38"
          replace OUTENT->Cod_Maq   with aOUTALIQ[nCONT,4]
       endif

       OUTENT->(dbskip())

   next

return

 //////////////////////////////////////////////////////////////////////////////////
 // INCLUI FORNECEDOR NO LANCAMENTO DA NOTA FISCAL ________________________________

function i_inc_fornec

    local nNIVEL  := XNIVEL
    local nORDER  := FORN->(dbsetorder(1))
    local sBLOC   := qsbloc(0,0,24,79)
    local nCURS   := setcursor(1)
    //local fCODIGO

    XNIVEL        := 2

    FORN->(qpublicfields())
    FORN->(qinitfields())

    i_inc_f2()

    FORN->(dbsetorder(nORDER))

    XNIVEL := nNIVEL

    setcursor(nCURS)

    if qconf("Confirma inclus„o deste fornecedor ?","B")

        if ! quse(XDRV_CP,"CONFIG",{},"E","PROV")
           qmensa("N„o foi possivel abrir CONFIG.DBF do Compras !","B")
           return .F.
        endif

       if FORN->(qappend()) .and. PROV->(qrlock())
          replace PROV->Cod_forn with PROV->Cod_forn + 1
          qrsay ( 1 , fCODIGO := strzero(PROV->Cod_forn,5) )
          qmensa("C¢digo Gerado: "+fCODIGO,"B")
          cCOD_FORN := fCODIGO

          FORN->(qreplacefields())

          PROV->(qunlock())
          PROV->(dbclosearea())

          select ENT

          qrbloc(0,0,sBLOC)
          return .T.

       else

          if empty(FORN->Codigo) .and. empty(FORN->Razao) .and. empty(FORN->Cgccpf)
             FORN->(dbdelete())
          endif
          iif(cOPCAO=="I",qm1(),qm2())

       endif

       qrbloc(0,0,sBLOC)
       return .T.

    endif

    qrbloc(0,0,sBLOC)

 return .F.

/////////////////////////////////////////////////////////////////////////////
// TRAVA OU APPEND NO ARQUIVO TIPOVAR _______________________________________

static function i_trava_tipovar

   if ! TIPOVAR->(qappend())
      return .F.
   endif

return .T.

 //////////////////////////////////////////////////////////////////////////////////
 // FAZ A EDICAO DOS CAMPOS PARA INCLULSAO DO FORNECEDOR __________________________

 // static function i_inc_f2
 function i_inc_f2

    local aEDICAO := {}
    local bESCAPE := {||empty(fRAZAO).or.(XNIVEL==2.and.!XFLAG)}

    qlbloc(6,2,"B201G","QBLOC.GLO",1)

//  fCODIGO := fCOD_FORN
//  fFILIAL := cFILIAL

//  qrsay(XNIVEL-1,fCODIGO:=strzero(val(fCODIGO),5))

    aadd(aEDICAO,{{ || NIL                                             } ,NIL         })
//  aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!"                    )} ,"CODIGO"    })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO    ,"@!"                    )} ,"RAZAO"     })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_ENT  ,"@!"                    )} ,"END_ENT"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_ENT  ,"@R 99999-999"          )} ,"CEP_ENT"   })
    aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT                        )} ,"CGM_ENT"   })
    aadd(aEDICAO,{{ || NIL                                             } ,NIL         })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1    ,"@9"                    )} ,"FONE1"     })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX      ,"@9"                    )} ,"FAX"       })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF   ,"@R 99.999.999/9999-99" )} ,"CGCCPF"    })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO,"@!"                    )} ,"INSCRICAO" })
    aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONTA ,"@R 99999-9"     )} ,"CONTA_CONT"})
    aadd(aEDICAO,{{ || NIL                                             } ,NIL         })

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE ) ; FORN->(qreleasefields()) ; return ; endif
       if ! i_crit_2( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
    enddo

 return

 ////////////////////////////////////////////////////////////////////////////////
 // CRITICAS NA DESCIDA _________________________________________________________

 static function i_crit_2 ( cCAMPO )

    iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

    if ! XFLAG ; return .T. ; endif

    do case
       case cCAMPO == "CGM_ENT"
            if ! CGM->(dbseek(fCGM_ENT))
               qmensa("Municipio n„o encontrado !","B")
               return .F.
            endif
            qrsay ( XNIVEL+1 , left(CGM->Municipio,15) + "/" + CGM->Estado )

      case cCAMPO == "CONTA_CONT"
           if ! empty(fCONTA_CONT)
              if ! PLAN->(dbseek(fCONTA_CONT))
                 qmensa("C¢digo da Conta Cont bil n„o encontrada !","B")
                 fCONTA_CONT := space(7)
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN->Descricao,38))
           endif

    endcase

 return .T.

//////////////////////////////////////////////////////////////////////////////////
// PARA INICIAR VALORES DE CENTRO DE CUSTOS ______________________________________

static function i_int_ccusto

   if ENTCUST->(dbseek(dtos(ENT->Data_lanc)+ ENT->Num_nf + ENT->Serie + ENT->Filial))
      for nCONT := 1 to 5
           aCCUSTO[nCONT,1] := ENTCUST->Icm_Base
           aCCUSTO[nCONT,2] := ENTCUST->Icm_Aliq
           aCCUSTO[nCONT,3] := ENTCUST->Icm_Vlr
           aCCUSTO[nCONT,4] := ENTCUST->Centro
           ENTCUST->(dbskip())
           if ENT->Num_nf + ENT->Serie + ENT->Filial <> ENTCUST->Num_nf + ENTCUST->Serie + ENTCUST->Filial
              exit
           endif
      next
   else
      return
   endif

   // INICIA VARIAVEIS PARA EDICAO _______________________________________________

   nBASECC_1 := aCCUSTO[1,1]
   nBASECC_2 := aCCUSTO[2,1]
   nBASECC_3 := aCCUSTO[3,1]
   nBASECC_4 := aCCUSTO[4,1]
   nBASECC_5 := aCCUSTO[5,1]

   nALIQCC_1 := aCCUSTO[1,2]
   nALIQCC_2 := aCCUSTO[2,2]
   nALIQCC_3 := aCCUSTO[3,2]
   nALIQCC_4 := aCCUSTO[4,2]
   nALIQCC_5 := aCCUSTO[5,2]

   nICMCC_1  := aCCUSTO[1,3]
   nICMCC_2  := aCCUSTO[2,3]
   nICMCC_3  := aCCUSTO[3,3]
   nICMCC_4  := aCCUSTO[4,3]
   nICMCC_5  := aCCUSTO[5,3]

   cCENTRO_1  := aCCUSTO[1,4]
   cCENTRO_2  := aCCUSTO[2,4]
   cCENTRO_3  := aCCUSTO[3,4]
   cCENTRO_4  := aCCUSTO[4,4]
   cCENTRO_5  := aCCUSTO[5,4]


return

//////////////////////////////////////////////////////////////////////////////////
// GRAVA LANCAMENTOS POR CENTRO DE CUSTOS_________________________________________

static function i_grav_centro

   do while ENTCUST->(dbseek(dtos(ENT->Data_lanc)+ENT->Num_nf+ENT->Serie + ENT->Filial))
      ENTCUST->(qrlock())
      ENTCUST->(dbdelete())
      ENTCUST->(qunlock())

   enddo

   // OBS. UTILIZADA TAMBEM PARA EXCLUSAO DE LANCAMENTO, QUANDO O VETOR
   // VAI ESTAR VAZIO E NAO VAI ENTRAR NO for ABAIXO...

   for nCONT := 1 to 5

       if empty(aCCUSTO[nCONT,1]) ; exit ; endif

       ENTCUST->(qappend())
       replace ENTCUST->Data_Lanc with fDATA_LANC
       replace ENTCUST->Num_Nf    with fNUM_NF
       replace ENTCUST->Serie     with fSERIE
       replace ENTCUST->Filial    with fFILIAL
       replace ENTCUST->Especie   with fESPECIE
       replace ENTCUST->Icm_Base  with aCCUSTO[nCONT,1]
       replace ENTCUST->Icm_Aliq  with aCCUSTO[nCONT,2]
       replace ENTCUST->Icm_Vlr   with aCCUSTO[nCONT,3]
       replace ENTCUST->Centro    with aCCUSTO[nCONT,4]


       ENTCUST->(dbskip())

   next

return

//////////////////////////////////////////////////////////////////////////////////
// LANCAMENTOS POR CENTRO DE CUSTOS_______________________________________________

static function i_centro

   local nNIVEL  := XNIVEL
   local sBLOC := qsbloc(5,0,24,79)
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG)}
   if cOPCAO =="I"
       nBASECC_1 := 0
       nBASECC_2 := 0
       nBASECC_3 := 0
       nBASECC_4 := 0
       nBASECC_5 := 0
       nALIQCC_1 := 0
       nALIQCC_2 := 0
       nALIQCC_3 := 0
       nALIQCC_4 := 0
       nALIQCC_5 := 0
       nICMCC_1  := 0
       nICMCC_2  := 0
       nICMCC_3  := 0
       nICMCC_4  := 0
       nICMCC_5  := 0
       cCENTRO_1 := space(8)
       cCENTRO_2 := space(8)
       cCENTRO_3 := space(8)
       cCENTRO_4 := space(8)
       cCENTRO_5 := space(8)
       aCCUSTO   := {{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "}}
   endif
   qlbloc(5,0,"B201CC","QBLOC.GLO")

   XNIVEL := 1

   // ATUALIZA A TELA ____________________________________________________________

   qrsay(XNIVEL++ , nBASECC_1 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_1 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_1  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_1 , "99999999" )


   qrsay(XNIVEL++ , nBASECC_2 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_2 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_2  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_2 , "99999999" )
                            

   qrsay(XNIVEL++ , nBASECC_3 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_3 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_3  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_3 , "99999999" )

   qrsay(XNIVEL++ , nBASECC_4 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_4 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_4  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_4 , "99999999" )

   qrsay(XNIVEL++ , nBASECC_5 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_5 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_5  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_5 , "99999999" )

   XNIVEL := 1

   // CALCULO DE LANCAMENTOS POR CENTRO DE CUSTOS___________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_1            , "@E 999,999,999.99") } ,"BASECC_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_1            , "@E 99.99"         ) } ,"ALIQCC_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_1             , "@E 999,999,999.99") } ,"ICMCC_1"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_1      , "@R 99999999"      ) } ,"CENTRO_1" })


   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_2          , "@E 999,999,999.99") } ,"BASECC_2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_2          , "@E 99.99"         ) } ,"ALIQCC_2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_2           , "@E 999,999,999.99") } ,"ICMCC_2"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_2    , "@R 99999999"       ) } ,"CENTRO_2" })


   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_3            , "@E 999,999,999.99") } ,"BASECC_3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_3            , "@E 99.99"         ) } ,"ALIQCC_3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_3             , "@E 999,999,999.99") } ,"ICMCC_3"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_3      , "@R 99999999"      ) } ,"CENTRO_3" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_4          , "@E 999,999,999.99") } ,"BASECC_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_4          , "@E 99.99"         ) } ,"ALIQCC_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_4           , "@E 999,999,999.99") } ,"ICMCC_4"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_4    , "@R 99999999"      ) } ,"CENTRO_4" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_5          , "@E 999,999,999.99") } ,"BASECC_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_5          , "@E 99.99"         ) } ,"ALIQCC_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_5           , "@E 999,999,999.99") } ,"ICMCC_5"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_5    , "@R 99999999"      ) } ,"CENTRO_5" })


   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE )
         qrbloc(5,0,sBLOC)
         XNIVEL := nNIVEL
         return
      endif
      if ! i_crit_4( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   XNIVEL := nNIVEL
   qrbloc(5,0,sBLOC)

   aCCUSTO[1,1] := nBASECC_1
   aCCUSTO[2,1] := nBASECC_2
   aCCUSTO[3,1] := nBASECC_3
   aCCUSTO[4,1] := nBASECC_4
   aCCUSTO[5,1] := nBASECC_5
   aCCUSTO[1,2] := nALIQCC_1
   aCCUSTO[2,2] := nALIQCC_2
   aCCUSTO[3,2] := nALIQCC_3
   aCCUSTO[4,2] := nALIQCC_4
   aCCUSTO[5,2] := nALIQCC_5
   aCCUSTO[1,3] := nICMCC_1
   aCCUSTO[2,3] := nICMCC_2
   aCCUSTO[3,3] := nICMCC_3
   aCCUSTO[4,3] := nICMCC_4
   aCCUSTO[5,3] := nICMCC_5

   aCCUSTO[1,4] := cCENTRO_1
   aCCUSTO[2,4] := cCENTRO_2
   aCCUSTO[3,4] := cCENTRO_3
   aCCUSTO[4,4] := cCENTRO_4
   aCCUSTO[5,4] := cCENTRO_5


return

////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA _________________________________________________________

static function i_crit_4 ( cCAMPO )

   local nDIFERE := 0
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "ICM_1CC"
           nDIFERE := (nICMCC_1 - ((nBASECC_1 * nALIQCC_1) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "ICMCC_2"
           nDIFERE := (nICMCC_2 - ((nBASECC_2 * nALIQCC_2) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "ICMCC_3"
           nDIFERE := (nICMCC_3 - ((nBASECC_3 * nALIQCC_3) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "ICMCC_4"
           nDIFERE := (nICMCC_4 - ((nBASECC_4 * nALIQCC_4) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "ICMCC_5"
           nDIFERE := (nICMCC_5 - ((nBASECC_5 * nALIQCC_5) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "ALIQCC_1" .and. cOPCAO $ "IA"
           nICMCC_1 := (nBASECC_1 * nALIQCC_1) / 100
           qrsay(XNIVEL+1, nICMCC_1 , "@E 999,999,999.99")

      case cCAMPO == "ALIQCC_2" .and. cOPCAO $ "IA"
           nICMCC_2 := (nBASECC_2 * nALIQCC_2) / 100
           qrsay(XNIVEL+1, nICMCC_2 , "@E 999,999,999.99")

      case cCAMPO == "ALIQCC_3" .and. cOPCAO $ "IA"
           nICMCC_3 := (nBASECC_3 * nALIQCC_3) / 100
           qrsay(XNIVEL+1, nICMCC_3 , "@E 999,999,999.99")

      case cCAMPO == "ALIQCC_4" .and. cOPCAO $ "IA"
           nICMCC_4 := (nBASECC_4 * nALIQCC_4) / 100
           qrsay(XNIVEL+1, nICMCC_4 , "@E 999,999,999.99")

      case cCAMPO == "ALIQCC_5" .and. cOPCAO $ "IA"
           nICMCC_5 := (nBASECC_5 * nALIQCC_5) / 100
           qrsay(XNIVEL+1, nICMCC_5 , "@E 999,999,999.99")

   endcase

return .T.

