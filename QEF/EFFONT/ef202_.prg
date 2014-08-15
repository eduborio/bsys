/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DAS NOTAS DE SAIDA
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JUNHO DE 1994
// OBS........:
// ALTERACOES.:
function ef202

#include "inkey.ch"
#include "ef.ch"

private nVALOR := 0     // Variavel temporario para guardar outras aliquotas
private cCOD_CLI1       // Codigo do cliente temporario
private mFILIAL

//fu_abre_ccusto()

// CONFIGURACOES ____________________________________________________________

if ! quse("","QCONFIG") ; return ; endif
private cVERIFICA := QCONFIG->Verifica
QCONFIG->(dbclosearea())

/////////////////////////////////////////////////////////////////////////////
// TIRA NOTAS DE BASE AJUSTADA QDO MAQ.REG. (@@ + ANO + MES) ________________

if XTIPOEMP $ "38"
   select SAI
   set filter to left(SAI->Num_Nf,2) <> "@@"
endif

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS NOTAS DE SAIDA ____________________________________________

SAI->(dbseek(XANOMES))

SAI->(qview({{"Data_Lanc/Data Lan‡.",2},;
             {"Num_Nf/Nota Fiscal"  ,1},;
             {"Serie/S‚rie"         ,0},;
             {"transform(Vlr_Cont,'@E 999,999,999.99')/Valor Cont.",0},;
             {"transform(Icm_base,'@E 999,999,999.99')/B. de C lculo",0},;
             {"transform(Icm_Vlr,'@E 999,999.99')/Valor ICM"       ,0},;
             {"Cfop/Cfop"     ,0}},"P",;
             {NIL,"i_202a",NIL,NIL},;
             {"qanomes(Data_lanc)==XANOMES",{||i202top()},{||i202bot()}},;
             "<ESC>-Sai/<A>lt/<E>xc/<I>nc/<C>on/Pesquisa <N>ota"))
return

function i202top
   SAI->(dbseek(dtos(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))),.T.))
return

function i202bot
   SAI->(qseekn(dtos(qfimmes(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))))))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_202a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO=="N",i_pesq_nota(),nil)

   if cOPCAO $ XUSRA
      do case

         // COMERCIO, PRESTACAO E MAQUINA C/ 3 DEPTOS _______________________

         case XTIPOEMP $ "12689"

              // SE USA VENDEDOR ____________________________________________

              if XUSA_VEND == "1"
                 qlbloc(5,2,"B202AV" ,"QBLOC.GLO",1)
              else
                 iif(val(left(CONFIG->Anomes,4)) > 2002,qlbloc(6,2,"B202N","QBLOC.GLO",1),qlbloc(5,2,"B202A","QBLOC.GLO",1))
              endif

         // MAQUINA REGISTRADORA   __________________________________________

         case XTIPOEMP $ "3"
              qlbloc(5,2,"B202B" ,"QBLOC.GLO",1)

         // INDUSTRIAS ______________________________________________________

         case XTIPOEMP $ "4570"

              // SE USA VENDEDOR ____________________________________________

              if XUSA_VEND == "1"
                 qlbloc(4,2,"B202CV","QBLOC.GLO",1)
              else
                 iif(val(left(CONFIG->Anomes,4)) > 2002,qlbloc(4,2,"B202M","QBLOC.GLO",1),qlbloc(4,2,"B202C","QBLOC.GLO",1))
              endif

      endcase

      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))

      i_edicao()

   endif
   setcursor(nCURSOR)
return ""

//////////////////////////////////////////////////////////////////////////////////
// PESQUISA PELO NUMERO DA NOTA __________________________________________________

static function i_pesq_nota

   local cNOTA := space(6), cSERIE := space(2) , cFILIAL := space(4)
   local nREC  := SAI->(recno())

   qmensa("Digite o numero da Nota p/ pesquisa:          ")
   qgetx(24,48,@cNOTA ,"999999")
   qmensa("Digite o numero da Filial p/ pesquisa:     ")
   qgetx(24,50,@cFILIAL ,"9999")

   cNOTA  := strzero(val(cNOTA),6)
   cFILIAL:= strzero(val(cFILIAL),4)

   SAI->(dbsetorder(7))
   if ! SAI->(dbseek(cNOTA+cFILIAL))
        SAI->(dbsetorder(2))
        if SAI->(eof())
           qmensa("Nota n„o encontrada !","B")
           SAI->(dbgoto(nREC))
           return
        endif
   else
        SAI->(dbsetorder(2))
        if qanomes(SAI->Data_lanc) <> XANOMES
           qmensa("Nota encontrada em: " + dtoc(SAI->Data_lanc) + ". Utilize op‡„o <803> !","B")
           SAI->(dbgoto(nREC))
           return
        endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   Local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   local sBLOC1 := qlbloc("B202D","QBLOC.GLO") // especie
   local sBLOC2 := qlbloc("B202E","QBLOC.GLO") // isentos ICMS
   local sBLOC3 := qlbloc("B202F","QBLOC.GLO") // outras ICMS

   local sBLOC4 := qlbloc("B202J","QBLOC.GLO") // isentos ICMS
   local sBLOC5 := qlbloc("B202K","QBLOC.GLO") // outras ICMS

   local sBLOC6 := qlbloc("B202L","QBLOC.GLO") // tabela para identificacao de cigarro para 1996

   // DATA TEMPORARIAS PARA MUDANCA DE NOTA FISCAL NA INCLUSAO ______________

   private dTEMP_LANC
   private dTEMP_EMIS

   // INICIA VARIAVEIS DE OUTRAS ALIQUOTAS __________________________________

   private zFILIAL  := "    "
   private zESPECIE := "  "
   private zCFOP   := "     "
   private zTPO    := space(6)
   private cTEMP_SERI := "  "
   private cTEMP_EST  := "  "
   private cTEMP_C_FI := "   "
   private cTEMP_C_VD := "   "
   private cTEMP_ICM  := " "
   private cTEMP_CONT := "      "
   private nBASE_1    := 0
   private nBASE_2    := 0
   private nBASE_3    := 0
   private nBASE_4    := 0
   private nBASE_5    := 0
   private nALIQ_1    := 0
   private nALIQ_2    := 0
   private nALIQ_3    := 0
   private nALIQ_4    := 0
   private nALIQ_5    := 0
   private nICM_1     := 0
   private nICM_2     := 0
   private nICM_3     := 0
   private nICM_4     := 0
   private nICM_5     := 0

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

   private nNOTAS     := 0   // PARA VERIFICAR SE JA FOI LANCADA UMA NOTA ___

   private aOUTALIQ   := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
   
   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , SAI->Filial                  ) ; FILIAL->(dbseek(SAI->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)       )

      qrsay ( XNIVEL++ , SAI->Data_lanc , "@D"        )
      qrsay ( XNIVEL++ , SAI->Num_nf    , "@R 999999" )
      qrsay ( XNIVEL++ , SAI->Serie                   ) ;SERIE->(dbseek(SAI->Serie))
if XTIPOEMP $ "3"
      qrsay ( XNIVEL++ , SERIE->Descricao, "@!"       )
Endif
      // SE NAO FOR MAQUINA REGISTRADORA ____________________________________

//    if XTIPOEMP $ "1245678"
//       if val(left(CONFIG->Anomes,4)) = 1995
//          qrsay( XNIVEL++ ,qabrev(SAI->Especie,"123456",{"Nota Fiscal","Luz","Telefone","Telex","Transportes","CMR(Maq.Reg.)"}))
//       else
//          qrsay( XNIVEL++ ,qabrev(SAI->Especie,"12345678",{"Nota Fiscal","Luz","Telefone","Telex","Transportes","CMR(Maq.Reg.)","N.F.(Cigarro)","CMR(Cigarro)"}))
//       endif
//    endif
      qrsay ( XNIVEL++ , SAI->Especie                 ) ; ESPECIE->(dbseek(SAI->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,15)  )
      qrsay ( XNIVEL++ , SAI->Data_Emis  , "@D"        )
      qrsay ( XNIVEL++ , SAI->Num_Ult_Nf , "@R 999999" )

      // SE NAO FOR MAQUINA REGISTRADORA ____________________________________

      if XTIPOEMP $ "124567890"
         qrsay ( XNIVEL++ , SAI->Cod_cli                ) ;CLI1->(dbseek(SAI->Cod_cli))
         qrsay ( XNIVEL++ , left(CLI1->Razao,30)        )
         qrsay ( XNIVEL++ , SAI->Estado                 ) ;ESTADO->(dbseek(SAI->Estado ))
         qrsay ( XNIVEL++ , ESTADO->Est_Desc            )

         if val(left(CONFIG->Anomes,4)) > 2002
            qrsay ( XNIVEL++ , SAI->Cfop   , "@R 9.999"            ) ;CFOP->(dbseek(SAI->Cfop))
            qrsay ( XNIVEL++ , left(CFOP->Nat_Desc,40)             )
         else
            qrsay ( XNIVEL++ , SAI->Cod_fisc   , "@R 9.99" ) ;NATOP->(dbseek(SAI->Cod_fisc))
            qrsay ( XNIVEL++ , NATOP->Nat_Desc             )
         endif

         qrsay ( XNIVEL++ , SAI->Tipo_cont               ) ;TIPOCONT->(dbseek(SAI->Tipo_cont))
         qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,30) )

         qrsay ( XNIVEL++ , SAI->Cod_Cont               ) ;CONTA->(dbseek(SAI->Cod_cont))
         qrsay ( XNIVEL++ , CONTA->Descricao            )

         // SE USA VENDEDOR _________________________________________________

    //     if XUSA_VEND == "1"
    //        qrsay ( XNIVEL++ , SAI->Cod_Vend            ) ;VEND->(dbseek(SAI->Cod_Vend))
    //       qrsay ( XNIVEL++ , VEND->Nome               )
    //     else
    //        if XTIPOEMP $ "4570"
    //           XNIVEL ++
    //           XNIVEL ++
    //        endif
    //     endif
      endif
      qrsay ( XNIVEL++ , SAI->Vlr_Cont , "@E 999,999,999.99" )

      // SE NAO FOR MAQUINA REGISTRADORA ____________________________________

      if XTIPOEMP $ "124567890"
         qrsay ( XNIVEL++ , SAI->Icm_Base  , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , SAI->Icm_Red   , "@E 99.999"         )
         qrsay ( XNIVEL++ , SAI->Icm_Aliq  , "@E 99.99"          )
         qrsay ( XNIVEL++ , SAI->Icm_Vlr   , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , SAI->Icm_Isen  , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , SAI->Icm_Out   , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , SAI->Icm_bc_s  , "@E 999,999,999.99" )    // Incluido para resumo no livro
         qrsay ( XNIVEL++ , SAI->Icm_Subst , "@E 999,999,999.99" )    // Incluido para resumo no livro

         // INDUSTRIAS ______________________________________________________

         if XTIPOEMP $ "4570"
            qrsay ( XNIVEL++ , SAI->Ipi_Base , "@E 999,999,999.99" )
            qrsay ( XNIVEL++ , SAI->Ipi_Vlr  , "@E 999,999,999.99" )
            qrsay ( XNIVEL++ , SAI->Ipi_Isen , "@E 999,999,999.99" )
            qrsay ( XNIVEL++ , SAI->Ipi_Out  , "@E 999,999,999.99" )
            qrsay ( XNIVEL++ , SAI->Ipi_Desc , "@E 999,999,999.99" )
         endif

         if val(left(CONFIG->Anomes,4)) = 1995
            qrsay ( XNIVEL++ , qabrev(SAI->Icm_Cod,"123457",{"Normal","Isentas","Outras","Diferidas","Outras Subst.Trib.","Cigarros"}) )
         else
            if SAI->Vlr_cont <> 0
//               qrsay ( XNIVEL++ , SAI->Icm_cod                          ) ;ICMS->(dbseek(SAI->Icm_Cod))
//               qrsay ( XNIVEL++ , ICMS->Descricao                       )

               qrsay ( XNIVEL++ ,qabrev(SAI->Icm_Cod,"012345679",{"Trib. Integ.","Trib. c/ Cobr. do ICMS por Sub. Trib.",;
                                                      "Com Red. de Base de Calc.","Isenta/N„o Trib. e c/ Cob. do ICMS por S.T",;
                                                      "Isenta ou N„o Tributada","Com Susp. ou Diferimento","ICMS Cobrado Anter. por S.T",;
                                                      "Com Red.de Base de Calc.e Cob.do ICMS por S.T","Outras"}) )
            else
               XNIVEL ++
            Endif
         endif

         qrsay ( XNIVEL++ , SAI->Obs         , "@!"                )
      endif
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if XTIPOEMP = "3" // MAQUINA REGISTRADORA
      if cOPCAO == "C" ; qwait()      ; return ; endif
   else
      if cOPCAO == "C" ; i_consulta() ; return ; endif
   endif

   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL ,"@!"                ) } ,"FILIAL"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do filial

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC , "@D" , NIL ) } , "DATA_LANC" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_NF    , "@9" , NIL ) } , "NUM_NF"    })
   aadd(aEDICAO,{{ || view_serie(-1,0,@fSERIE, "@9"       ) } , "SERIE"     })
if XTIPOEMP = "3" // MAQUINA REGISTRADORA
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da serie
Endif
   // SE NAO FOR MAQUINA REGISTRADORA _______________________________________

// if XTIPOEMP $ "1245678"
//    if val(left(CONFIG->Anomes,4)) = 1995
//       aadd(aEDICAO,{{ || qesco(-1,0,@fESPECIE , sBLOC1 ) } , "ESPECIE"   })
//    else
//       aadd(aEDICAO,{{ || qesco(-1,0,@fESPECIE , sBLOC6 ) } , "ESPECIE"   })
//    endif
// endif

   aadd(aEDICAO,{{ || view_especie(-1,0,@fESPECIE  ,"99"         ) } ,"ESPECIE"    })
   aadd(aEDICAO,{{ || NIL                                          } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMIS , "@D"       ) } , "DATA_EMIS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_ULT_NF, "@9"       ) } , "NUM_ULT_NF"})

   // SE NAO FOR MAQUINA REGISTRADORA _______________________________________

   if XTIPOEMP $ "124567890"
      aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_CLI          ) } , "COD_CLI"   })
      aadd(aEDICAO,{{ || NIL                                } , NIL         })
      aadd(aEDICAO,{{ || view_estado(-1,0,@fESTADO        ) } , "ESTADO"    })
      aadd(aEDICAO,{{ || NIL                                } , NIL         })

      if val(left(CONFIG->Anomes,4)) > 2002
        aadd(aEDICAO,{{ || view_cfop(-1,0,@fCFOP                         ) } ,"CFOP"  })
        aadd(aEDICAO,{{ || NIL                                             } ,NIL         })
      else
        aadd(aEDICAO,{{ || view_natop(-1,0,@fCOD_FISC       ) } , "COD_FISC"  })
        aadd(aEDICAO,{{ || NIL                                } , NIL         })
      endif

      aadd(aEDICAO,{{ || view_tpo(-1,0,@fTIPO_CONT        ) } ,"TIPO_CONT" })
      aadd(aEDICAO,{{ || NIL                                } ,NIL         })
      aadd(aEDICAO,{{ || view_conta(-1,0,@fCOD_CONT       ) } , "COD_CONT"  })
      aadd(aEDICAO,{{ || NIL                                } , NIL         })

      // SE USA VENDEDOR ____________________________________________________

    //  if XUSA_VEND == "1"
    //     aadd(aEDICAO,{{ || view_vend(-1,0,@fCOD_VEND     ) } , "COD_VEND"  })
    //     aadd(aEDICAO,{{ || NIL                             } , NIL         })
    //  else
    //     if XTIPOEMP $ "4570"
    //        aadd(aEDICAO,{{ || NIL                             } , NIL         })
    //        aadd(aEDICAO,{{ || NIL                             } , NIL         })
    //     endif
    //  endif
   endif

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_CONT , "@E 999,999,999.99" ) } , "VLR_CONT"  })
//   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // SE NAO FOR MAQUINA REGISTRADORA _______________________________________

   if XTIPOEMP $ "124567890"
      aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_BASE  ,"@E 999,999,999.99" ) } , "ICM_BASE"  })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_RED   ,"@E 99.999"         ) } , "ICM_RED"   })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_ALIQ  ,"@E 99.99"          ) } , "ICM_ALIQ"  })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_VLR   ,"@E 999,999,999.99" ) } , "ICM_VLR"   })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_ISEN  ,"@E 999,999,999.99" ) } , "ICM_ISEN"  })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_OUT   ,"@E 999,999,999.99" ) } , "ICM_OUT"   })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_BC_S  ,"@E 999,999,999.99" ) } , "ICM_BC_S"  })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fICM_SUBST ,"@E 999,999,999.99" ) } , "ICM_SUBST" })

      // INDUSTRIAS _________________________________________________________

      if XTIPOEMP $ "4570"
         aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_BASE,"@E 999,999,999.99" ) } , "IPI_BASE"  })
         aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_VLR ,"@E 999,999,999.99" ) } , "IPI_VLR"   })
         aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_ISEN,"@E 999,999,999.99" ) } , "IPI_ISEN"  })
         aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_OUT ,"@E 999,999,999.99" ) } , "IPI_OUT"   })
         aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI_DESC,"@E 999,999,999.99" ) } , "IPI_DESC"  })
      endif

      if val(left(CONFIG->Anomes,4)) = 1995
         aadd(aEDICAO,{{ || qesco(16,if(XTIPOEMP $ "4570",22,22),@fICM_COD,if(!empty(fICM_ISEN),sBLOC2,sBLOC3)) } ,"ICM_COD" })
      else
//         aadd(aEDICAO,{{ || view_icms(-1,0,@fICM_COD                      ) } ,"ICM_COD"   })
//         aadd(aEDICAO,{{ || NIL                                             } ,NIL         })

          aadd(aEDICAO,{{ || qesco(14,if(XTIPOEMP $ "4570",22,22),@fICM_COD,if(!empty(fICM_ISEN),sBLOC4,sBLOC5)) } ,"ICM_COD" })
      endif
      aadd(aEDICAO,{{ || view_obs(-1,0,@fOBS     , "@!"               ) } , "OBS"       })  // foi modificado 08/10/96
   endif

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   do while .T.

      if cOPCAO == "I"
         do case

            // COMERCIO, PRESTACAO E MAQUINA C/ 3 DEPTOS ____________________

            case XTIPOEMP $ "12689"

                 // SE USA VENDEDOR _________________________________________

                 if XUSA_VEND == "1"
                    qlbloc(5,2,"B202AV" ,"QBLOC.GLO",1)
                 else
                    iif(val(left(CONFIG->Anomes,4)) > 2002,qlbloc(6,2,"B202N","QBLOC.GLO",1),qlbloc(6,2,"B202A","QBLOC.GLO",1))

                 endif

            // MAQUINA REGISTRADORA _________________________________________

            case XTIPOEMP $ "3"
                 qlbloc(5,2,"B202B" ,"QBLOC.GLO",1)

            // INDUSTRIA ____________________________________________________

            case XTIPOEMP $ "4570"

                 // SE USA VENDEDOR _________________________________________

                 if XUSA_VEND == "1"
                    qlbloc(4,2,"B202CV","QBLOC.GLO",1)
                 else
                    iif(val(left(CONFIG->Anomes,4)) > 2002,qlbloc(4,2,"B202M","QBLOC.GLO",1),qlbloc(4,2,"B202C","QBLOC.GLO",1))

                 endif
         endcase

      endif

      SAI->(qpublicfields())

      if cOPCAO=="I"

         SAI->(qinitfields())

         if val(left(CONFIG->Anomes,4)) = 1995
            fICM_COD  := "1"
         else
            fICM_COD  := "0"
         endif

         if XTIPOEMP $ "38"
            fCOD_FISC := "512"
            fESTADO   := "PR"
         endif

         if nNOTAS = 0
            fDATA_LANC := qfimmes(ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4)))
            fDATA_EMIS := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
            fSERIE     := "01"
         else
            fDATA_LANC := dTEMP_LANC
            fDATA_EMIS := dTEMP_EMIS
            fFILIAL    := zFILIAL
            fESPECIE   := zESPECIE
            fCFOP      := zCFOP
            fTIPO_CONT := zTPO
            fSERIE     := cTEMP_SERI
            fESTADO    := cTEMP_EST
            fCOD_FISC  := cTEMP_C_FI
            fCOD_VEND  := cTEMP_C_VD
            fICM_COD   := cTEMP_ICM
            fCOD_CONT  := cTEMP_CONT
         endif

         fICM_ALIQ := 17
         nBASE_1   := 0
         nBASE_2   := 0
         nBASE_3   := 0
         nBASE_4   := 0
         nBASE_4   := 0
         nALIQ_1   := 0
         nALIQ_2   := 0
         nALIQ_3   := 0
         nALIQ_4   := 0
         nALIQ_5   := 0
         nICM_1    := 0
         nICM_2    := 0
         nICM_3    := 0
         nICM_4    := 0
         nICM_5    := 0
         aOUTALIQ  := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
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

      else

         SAI->(qcopyfields())

      endif

      XNIVEL := 1
      XFLAG := .T.

      // SE ALTERACAO , ENTAO INICIALIZA O VETOR DE OUTRAS ALIQUOTAS ________

      if cOPCAO == "A" ; i_init_out_aliq() ; endif
      if CONFIG->Exig_ccust == "S" ; i_int_ccusto() ; endif

      // LOOP PARA SAIDA DOS CAMPOS _________________________________________

      Public CAMPO
      CAMPO := len(aEDICAO) - 2

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );SAI->(qreleasefields());OUTSAI->(qreleasefields());SAICUST->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      // GRAVACAO ___________________________________________________________

      if ! lCONF ; return ; endif

      if OUTSAI->(qflock()) .and. SAI->(iif(cOPCAO=="I",qappend(),qrlock()))

         fNUM_NF := pad(fNUM_NF,6)
         i_grava_outras()
          if CONFIG->Exig_ccust =="S"
            i_grav_centro()
          endif

         SAI->(qreplacefields())
         SAI->(qunlock())
         OUTSAI->(qunlock())

         // REINICIALIZA EDICAO DAS NOTAS NO PRIMEIRO CAMPO _________________

         if val(left(CONFIG->Anomes,4)) = 1995
            fICM_COD   := "1"
         else
            fICM_COD   := "0"
         endif

         dTEMP_LANC := fDATA_LANC
         dTEMP_EMIS := fDATA_EMIS
         zFILIAL    := fFILIAL
         zESPECIE   := fESPECIE
         zTPO       := fTIPO_CONT
         zCFOP      := fCFOP
         cTEMP_SERI := fSERIE
         cTEMP_EST  := fESTADO
         cTEMP_C_FI := fCOD_FISC
         cTEMP_C_VD := fCOD_VEND
         cTEMP_ICM  := fICM_COD
         cTEMP_CONT := fCOD_CONT

         nNOTAS++
         XNIVEL := 1
         XFLAG := .T.

         if cOPCAO == "I"
            fICM_ALIQ  := 17
         endif

      else

         iif(cOPCAO=="I",qm1(),qm2())

      endif

      if cOPCAO $ "IAE"     // TRAVA NA HORA DE EMITIR A OPCAO 507 E 508, QUANDO FOR INCLUIDA/ALTERADA/EXCLUIDA
         lAPURADO_E := lAPURADO_S := .F.
         dDATA_INI := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
         if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(qfimmes(dDATA_INI))+ alltrim(fFILIAL)))
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

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   local nDIFERENCA, cESTADO
   local nREC  := SAI->(recno())

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "FILIAL"

           qrsay(XNIVEL,fFILIAL:=strzero(val(fFILIAL),4))

           if FILIAL->(dbseek(fFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,40))
           else
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif

      case cCAMPO == "DATA_LANC" .and. cOPCAO == "I"
           if empty(fDATA_LANC) ; return .F. ; endif
           mFILIAL := fFILIAL

           if substr(dtoc(fDATA_LANC),4,2) <> right(XANOMES,2)
              qmensa("Mes de Lancamento da Nota Fiscal n„o est  correto !","B")
              return .F.
           endif

           if nNOTAS = 0
              fDATA_EMIS := fDATA_LANC
           else
              fDATA_EMIS := dTEMP_EMIS
           endif

      case cCAMPO == "DATA_LANC" .and. cOPCAO == "A"
           if empty(fDATA_LANC) ; return .F. ; endif

      case cCAMPO == "DATA_EMIS"
           if empty(fDATA_EMIS) ; return .F. ; endif

           if fDATA_EMIS > fDATA_LANC
              qmensa("Data de Emiss„o n„o pode ser maior que a Data de Lancamento !","B")
              return .F.
           endif

      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI)

           else
              qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))

             if ! CLI1->(dbseek( strzero(val(fCOD_CLI),5) ))
                if ! qconf("Cliente n„o Cadastrado ! Incluir agora ?")
                   qmensa("")
                   return .F.
                endif
                if ! i_inc_cliente()
                   return .F.
                else
                   fCOD_CLI := cCOD_CLI1
                   seekb_sl("L")
                   qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))
                   CLI1->(dbseek(fCOD_CLI))
                endif

                fFILIAL := mFILIAL
             endif

             qrsay(XNIVEL+1,left(CLI1->Razao,40))

              qrsay(XNIVEL,fCOD_CLI)

              CLI1->(dbseek(fCOD_CLI))



              qrsay(XNIVEL+1,left(CLI1->Razao,40))

              // PEGA CODIGO DE CGM NO CLIENTE ___________________________________

              cESTADO := CLI1->Cgm_ent

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
           endif
      case cCAMPO == "NUM_NF"
           if empty(fNUM_NF) ; return .F. ; endif
           qrsay(XNIVEL,fNUM_NF:=strzero(val(fNUM_NF),6))

      case cCAMPO == "NUM_ULT_NF"
           if empty(fNUM_ULT_NF) ; return .T. ; endif
           qrsay(XNIVEL,fNUM_ULT_NF:=strzero(val(fNUM_ULT_NF),6))

           if val(fNUM_ULT_NF) < val(fNUM_NF)
              qmensa("Numero Ultima Nota Fiscal deve ser maior que Numero Nota Fiscal !","B")
              return .F.
           endif

      case cCAMPO == "SERIE" .and. cOPCAO == "I"

           // ALTERA PARA ORDEM DE NUMERO + SERIE ___________________________

           SAI->(dbsetorder(1))
           qrsay(XNIVEL,fSERIE := strzero(val(fSERIE),2))
      if XTIPOEMP $ "3"
           qrsay(XNIVEL+1,SERIE->Descricao)
      Endif
           if ! SERIE->(dbseek(fSERIE))

              qmensa("S‚rie Inv lida !","B")

              // RETORNA ORDEM PARA DATA DE LANCAMENTO ______________________

              SAI->(dbsetorder(2))
              SAI->(dbgoto(nREC))
              return .F.

           endif

           if SAI->(dbseek(fNUM_NF + fSERIE)) .and. fFILIAL == alltrim(SAI->Filial)
              qmensa("ATENCŽO: Nota Fiscal j  cadastrada em "+dtoc(SAI->DATA_LANC)+".","B")
              XNIVEL--
           endif

           // RETORNA ORDEM PARA DATA DE LANCAMENTO _________________________

           SAI->(dbsetorder(2))
           SAI->(dbgoto(nREC))

      case cCAMPO == "SERIE" .and. cOPCAO == "A"
           qrsay(XNIVEL,fSERIE := strzero(val(fSERIE),2))

           if !SERIE->(dbseek(fSERIE))
              qmensa("S‚rie Inv lida !","B") ; return .F.
           endif

      case cCAMPO == "COD_VEND"
           if empty(fCOD_VEND); return .T.; endif                   // Incluido no dia 19/03/96

           fCOD_VEND := strzero(val(fCOD_VEND),3)

           if !VEND->(dbseek(fCOD_VEND))
              qmensa("Vendedor n„o cadastrado !","B") ; return .F.
           endif

           qrsay(XNIVEL  ,fCOD_VEND)
           qrsay(XNIVEL+1,VEND->Nome)

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

      case cCAMPO == "COD_FISC"

           // PEGA ESTADO NO CGM ____________________________________________

           if CGM->(dbseek(FILIAL->CGM))
              cESTADO := CGM->Estado
           endif

           if ! NATOP->(dbseek(fCOD_FISC))
              qmensa("C¢digo Fiscal Inv lido !","B") ; return .F.
           endif

           if substr(fCOD_FISC,1,1) $ "123"
              qmensa("Codigo Fiscal Inv lido para Sa¡da das Notas !","B")
              return .F.
           endif

           if right(fCOD_FISC,1) $ "0"
              qmensa("Codigo Fiscal de Grupo, n„o Permitido !","B")
              return .F.
           endif

           if fESTADO = cESTADO
              if left(fCOD_FISC,1) <> "5" .and. left(fCOD_FISC,1) <> "7"
                 qmensa("Codigo Fiscal Inv lido Dentro do Estado !","B")
                 return .F.
              endif
           else
              if ! left(fCOD_FISC,1) $ "67"
                 qmensa("Codigo Fiscal Inv lido Para Fora do Estado !","B")
                 return .F.
              endif
           endif

           qrsay(XNIVEL+1,NATOP->Nat_Desc)
           fTIPO_CONT := NATOP->Tip_cont

      case cCAMPO == "CFOP"

           if CGM->(dbseek(FILIAL->CGM))
              cESTADO := CGM->Estado
           endif

           if ! CFOP->(dbseek(fCFOP))
              qmensa("C¢digo fiscal inv lido !","B") ; return .F.
           endif


           if substr(fCFOP,1,1) $ "123"
              qmensa("Codigo Fiscal Inv lido para Sa¡da das Notas !","B")
              return .F.
           endif

           if right(fCFOP,1) == "00"
              qmensa("Codigo Fiscal de Grupo, n„o Permitido !","B")
              return .F.
           endif

           if fESTADO = cESTADO
              if left(fCFOP,1) <> "5" .and. left(fCFOP,1) <> "7"
                 qmensa("Codigo Fiscal Inv lido Dentro do Estado !","B")
                 return .F.
              endif
           else
              if ! left(fCFOP,1) $ "67"
                 qmensa("Codigo Fiscal Inv lido Para Fora do Estado !","B")
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

//           if XTIPOEMP $ "4570"     // INDUSTRIA
//              if (fCOD_FISC) == "199" .or. (fCOD_FISC) == "299" .or. (fCOD_FISC) == "191"  .or. (fCOD_FISC) == "291"
//                 qrsay(XNIVEL+10,fVLR_CONT, "@E 999,999,999.99")
//              endif
//           endif

           // SE NAO FOR MAQUINA REGISTRADORA _______________________________

           if XTIPOEMP $ "124567890"
              fICM_BASE := fVLR_CONT
              qrsay(XNIVEL+1,fICM_BASE,"@E 999,999,999.99")
              if empty(fVLR_CONT)
                if XTIPOEMP $ "45780"
                  fOBS := "## NF CANCELADA"
                  aOUTALIQ   := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
                  XNIVEL := 35  // quando emite nota cancelada aceita valor nulo
                  XNIVEL := CAMPO  // quando emite nota cancelada aceita valor nulo
                  qrsay(35,fOBS)
                else
                  fOBS := "## NF CANCELADA"
                  aOUTALIQ   := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
                    XNIVEL := 30  // quando emite nota cancelada aceita valor nulo
                    XNIVEL := CAMPO  // quando emite nota cancelada aceita valor nulo
                    qrsay(30,fOBS)
               endif
             endif
           endif
      case cCAMPO == "VLR_CONT" .and. cOPCAO == "A"
           if empty(fVLR_CONT)
              fICM_BASE :=  fICM_RED  :=  fICM_ALIQ :=  fICM_VLR  := fICM_ISEN := fICM_OUT :=  ;
              fICM_SUBST := fICM_BC_S := 0
              OUTSAI->(Dbgotop())
              OUTSAI->(Dbseek(fNUM_NF + fSERIE + fFILIAL))
              do while ! OUTSAI->(eof()) .and. OUTSAI->Num_nf == fNUM_NF .and. OUTSAI->Serie == fSERIE .and. OUTSAI->Filial == fFILIAL
                 if OUTSAI->(qrlock())
                    OUTSAI->(dbdelete())
                    OUTSAI->(qunlock())
                 endif
                 OUTSAI->(dbskip())
              enddo
              if XTIPOEMP $ "124567890"
                 if XTIPOEMP $ "45780"
                    //fOBS := "## NF CANCELADA"
                    aOUTALIQ   := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
                    //XNIVEL := 35  // quando emite nota cancelada aceita valor nulo
                    //XNIVEL := CAMPO  // quando emite nota cancelada aceita valor nulo
                    qrsay(35,fOBS)
                  else
                    //fOBS := "## NF CANCELADA"
                    aOUTALIQ   := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
                    //XNIVEL := 30  // quando emite nota cancelada aceita valor nulo
                    //XNIVEL := CAMPO  // quando emite nota cancelada aceita valor nulo
                    qrsay(30,fOBS)
                  endif
              endif
          endif

      case cCAMPO == "ICM_VLR" .and. cOPCAO == "I"
           nDIFERENCA := abs(fICM_VLR - ((fICM_ALIQ * fICM_BASE) / 100))

           if cVERIFICA == "1"
              if round(nDIFERENCA,2) >= 0.02
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

           qrsay(XNIVEL+4,fICM_ISEN,"@E 999,999,999.99")

           // SE MAQUINA COM 3 DEPTOS, ZERA ALIQUOTA e SALTA PARA ISENTAS ___

           if XTIPOEMP $ "8"
              fICM_ALIQ := 0
              if fVLR_CONT = fICM_BASE
                 qrsay(6+XNIVEL,"Normal")
                 XNIVEL += 6
              else
                 XNIVEL += 3
              endif
           endif

           if XTIPOEMP $ "4570"
              fIPI_BASE := fICM_BASE
              fIPI_VLR  := fVLR_CONT - fICM_BASE
              qrsay(XNIVEL+8,fIPI_BASE,"@E 999,999,999.99")
              qrsay(XNIVEL+9,fIPI_VLR ,"@E 999,999,999.99")
           endif

           if XTIPOEMP $ "25"
//            fICM_BC_S := fICM_BASE
              fICM_BC_S := fICM_BASE + (fICM_BASE * (CONFIG->Perc_subtr/100))
           endif

      case cCAMPO == "ICM_BASE" .and. cOPCAO == "I"
//           if fICM_RED = 0
//              fICM_ISEN := fVLR_CONT - fICM_BASE
//           endif
//           qrsay(XNIVEL+4,fICM_ISEN,"@E 999,999,999.99")

           // SE MAQUINA COM 3 DEPTOS, ZERA ALIQUOTA e SALTA PARA ISENTAS ___

           if XTIPOEMP $ "8"
              fICM_ALIQ := 0
              if fVLR_CONT = fICM_BASE
                 qrsay(6+XNIVEL,"Normal")
                 XNIVEL += 6
              else
                 XNIVEL += 3
              endif
           endif

           if XTIPOEMP $ "4570"
              fIPI_BASE := fICM_BASE
              fIPI_VLR  := fVLR_CONT - fICM_BASE
              qrsay(XNIVEL+7,fIPI_BASE,"@E 999,999,999.99")
              qrsay(XNIVEL+8,fIPI_VLR ,"@E 999,999,999.99")
           endif

      case cCAMPO == "ICM_ISEN" .and. cOPCAO == "I"
           if fICM_ISEN = 0 .and. fICM_RED = 0
              fICM_OUT := fVLR_CONT - fICM_BASE
           endif

           fICM_OUT := round(fVLR_CONT,2) - round(fICM_BASE,2) - round(fICM_ISEN,2)
           qrsay(XNIVEL+1,fICM_OUT,"@E 999,999,999.99")

           if round(fICM_ISEN,2) <> 0 .and. cOPCAO == "I"

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

           // SE EXISTE DIFERENCA ENTRA PARA EDITAR OUTRAS ALIQUOTAS ________

           nDIFERENCA := (fVLR_CONT - (fICM_BASE + fICM_ISEN + fICM_OUT))

           if round(nDIFERENCA,2) >= 0.02
              if cOPCAO == "I"
                 nBASE_1 := (fVLR_CONT - (fICM_BASE + fICM_ISEN + fICM_OUT))
                 nVALOR := nBASE_1
              endif
              i_outras_aliq()
           else
              if cOPCAO == "A"
                 if(XTIPOEMP $ "3", aOUTALIQ := {{0,0,0,""},{0,0,0,""},{0,0,0,""}},aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}})
              endif
           endif

           // VALOR CONTABIL = BASE, SALTA O CODIGO DE ICMS _________________

           if round(fICM_OUT,2) <> 0 .and. cOPCAO == "I"

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

           if fICM_BASE == 0 .and. XTIPOEMP $ "4570"
              fIPI_BASE := fICM_OUT
              fIPI_VLR  := fVLR_CONT - fIPI_BASE
              qrsay(XNIVEL+3,fIPI_BASE,"@E 999,999,999.99")
              qrsay(XNIVEL+4,fIPI_VLR ,"@E 999,999,999.99")
           endif

      case cCAMPO == "ICM_OUT" .and. cOPCAO == "A"

           i_outras_aliq()

           // VALOR CONTABIL = BASE, SALTA O CODIGO DE ICMS _________________

//         if round(fICM_OUT,2) <> 0 .and. cOPCAO == "I"
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

           if fICM_BASE == 0 .and. XTIPOEMP $ "4570"
              fIPI_BASE := fICM_OUT
              fIPI_VLR  := fVLR_CONT - fIPI_BASE
              qrsay(XNIVEL+3,fIPI_BASE,"@E 999,999,999.99")
              qrsay(XNIVEL+4,fIPI_VLR ,"@E 999,999,999.99")
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
                                                        "Com Red. de Base de Calc.","Isenta/N„o Trib. e c/ Cob. do ICMS por S.T",;
                                                        "Isenta ou N„o Tributada","Com Susp. ou Diferimento","ICMS Cobrado Anter. por S.T",;
                                                        "Com Red.de Base de Calc.e Cob.do ICMS por S.T","Outras"}) )
              else
                 XNIVEL ++
              endif
           endif
           if CONFIG->Exig_ccust == "S" ; i_centro() ;endif

      case cCAMPO == "IPI_VLR" .and. cOPCAO == "I"
         /*  nDIFER_IPI := abs(fIPI_VLR - (fVLR_CONT - fICM_BASE))
           if cVERIFICA = "1"
              if round(nDIFER_IPI,2) >= 0.02
                 qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
                 XNIVEL -= 2
              endif
           endif     */

           if empty(fIPI_VLR)
              fIPI_ISEN := fIPI_BASE
              fIPI_OUT  := fIPI_BASE
              fIPI_BASE := 0
              qrsay(XNIVEL-1,fIPI_BASE , "@E 999,999,999.99")
              qrsay(XNIVEL+1,fIPI_ISEN , "@E 999,999,999.99")
           endif

      case cCAMPO == "IPI_BASE" .and. cOPCAO == "I"
//           fIPI_BASE := fICM_BASE
//           qrsay(XNIVEL,fIPI_BASE , "@E 999,999,999.99")
           fIPI_VLR := fVLR_CONT - fIPI_BASE
           qrsay(XNIVEL+1,fIPI_VLR , "@E 999,999,999.99")

      case cCAMPO == "IPI_ISEN" .and. cOPCAO == "I"
           if !empty(fIPI_ISEN)
              fIPI_OUT  := 0
           endif

//    case cCAMPO == "IPI_DESC"
//       nDIFERENCA := abs(fVLR_CONT - abs(fIPI_BASE + fIPI_VLR + fIPI_ISEN + fIPI_OUT - fIPI_DESC))
//       if cVERIFICA == "1"
//          if round(nDIFERENCA,2) >= 0.02
//             qmensa("Valor do IPI n„o est  correto","B")
//             XNIVEL -= 5
//             return .F.
//          endif
//       endif

      case cCAMPO == "ESTADO" .and. cOPCAO == "I"

           // CONVERTE NUMERO DO ESTADO PARA A SIGLA CORRESPONDENTE _________

           fESTADO := i_sigla_uf(fESTADO)

           if ! ESTADO->(dbseek(fESTADO))
              qmensa("Estado Invalido !","B") ; return .F.
           endif

           qrsay(XNIVEL+1,ESTADO->Est_Desc)
           fICM_ALIQ := ESTADO->Aliq_Dest

           if XUSA_VEND == "1"
              qrsay(XNIVEL+11,fICM_ALIQ , "@R 99.99")
           else
              qrsay(XNIVEL+9 ,fICM_ALIQ , "@R 99.99")
           endif

           qrsay(XNIVEL,fESTADO)

      case cCAMPO == "ESTADO"

           // CONVERTE NUMERO DO ESTADO PARA A SIGLA CORRESPONDENTE _________

           fESTADO := i_sigla_uf(fESTADO)
           if ! ESTADO->(dbseek(fESTADO))
              qmensa("Estado Invalido !","B") ; return .F.
           endif
           qrsay(XNIVEL+1,ESTADO->Est_Desc)
           qrsay(XNIVEL,fESTADO)

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR NOTAS FISCAIS DE SAIDA________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta nota fiscal ?")
      if OUTSAI->(qflock()) .and. SAI->(qrlock())
         SAICUST->(qrlock())
         i_grava_outras()
         if CONFIG->Exig_ccust =="S"
            i_grav_centro()
         endif

         SAI->(dbdelete())
         SAI->(qunlock())
         OUTSAI->(qunlock())
         SAICUST->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// LANCAMENTOS DE OUTRAS ALIQUOTAS __________________________________________

static function i_outras_aliq

   local nNIVEL  := XNIVEL
   local sBLOC   := qsbloc(5,0,24,79)
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG)}

   qlbloc(5,0,"B202O","QBLOC.GLO")
   XNIVEL := 1

   // ATUALIZA A TELA _______________________________________________________

   qrsay(XNIVEL++ , nBASE_1 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_1 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_1  , "@E 999,999,999.99" )

   qrsay(XNIVEL++ , nBASE_2 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_2 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_2  , "@E 999,999,999.99" )

   qrsay(XNIVEL++ , nBASE_3 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_3 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_3  , "@E 999,999,999.99" )

   qrsay(XNIVEL++ , nBASE_4 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_4 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_4  , "@E 999,999,999.99" )

   qrsay(XNIVEL++ , nBASE_5 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQ_5 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICM_5  , "@E 999,999,999.99" )



   XNIVEL := 1

   // CALCULO DAS OUTRAS ALIQUOTAS __________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_1 , "@E 999,999,999.99") } ,"BASE_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_1 , "@E 99.99"         ) } ,"ALIQ_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_1  , "@E 999,999,999.99") } ,"ICM_1"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_2 , "@E 999,999,999.99") } ,"BASE_2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_2 , "@E 99.99"         ) } ,"ALIQ_2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_2  , "@E 999,999,999.99") } ,"ICM_2"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_3 , "@E 999,999,999.99") } ,"BASE_3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_3 , "@E 99.99"         ) } ,"ALIQ_3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_3  , "@E 999,999,999.99") } ,"ICM_3"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_4 , "@E 999,999,999.99") } ,"BASE_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_4 , "@E 99.99"         ) } ,"ALIQ_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_4  , "@E 999,999,999.99") } ,"ICM_4"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASE_5 , "@E 999,999,999.99") } ,"BASE_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_5 , "@E 99.99"         ) } ,"ALIQ_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICM_5  , "@E 999,999,999.99") } ,"ICM_5"  })



   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE )
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

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_3 ( cCAMPO )

   local nDIFERE := 0

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "ICM_1"
           nDIFERE := abs(nICM_1 - ((nBASE_1 * nALIQ_1) / 100))
           if cVERIFICA == "1"
              if round(nDIFERE,2) >= 0.02 .and. cOPCAO == "I"
                 qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
                 XNIVEL -= 3
              endif
           endif
           if cOPCAO == "I"
              nBASE_2 := nVALOR - nBASE_1
              qrsay(XNIVEL+1,nBASE_2,"@E 999,999,999.99")
              nVALOR  := nBASE_2
           endif

      case cCAMPO == "ICM_2"
           nDIFERE := abs(nICM_2 - ((nBASE_2 * nALIQ_2) / 100))
           if cVERIFICA == "1"
              if round(nDIFERE,2) >= 0.02 .and. cOPCAO == "I"
                 qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
                 XNIVEL -= 3
              endif
           endif

           if cOPCAO == "I"
              nBASE_3 := nVALOR - nBASE_2
              qrsay(XNIVEL+1,nBASE_3,"@E 999,999,999.99")
              nVALOR  := nBASE_3

           endif

      case cCAMPO == "ICM_3"
           nDIFERE := abs(nICM_3 - ((nBASE_3 * nALIQ_3) / 100))
           if cVERIFICA == "1"
              if round(nDIFERE,2) >= 0.02 .and. cOPCAO == "I"
                 qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
                 XNIVEL -= 3
              endif
           endif

           if cOPCAO == "I"
              nBASE_4 := nVALOR - nBASE_3
              qrsay(XNIVEL+1,nBASE_4,"@E 999,999,999.99")
              nVALOR  := nBASE_4

           endif

      case cCAMPO == "ICM_4"
           nDIFERE := abs(nICM_4 - ((nBASE_4 * nALIQ_4) / 100))
           if cVERIFICA == "1"
              if round(nDIFERE,2) >= 0.02 .and. cOPCAO == "I"
                 qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
                 XNIVEL -= 3
              endif
           endif

           if cOPCAO == "I"
              nBASE_5 := nVALOR - nBASE_4
              qrsay(XNIVEL+1,nBASE_5,"@E 999,999,999.99")
              nVALOR  := nBASE_5

           endif



      case cCAMPO == "ICM_5"
           nDIFERE := abs(nICM_5 - ((nBASE_5 * nALIQ_5) / 100))
           if cVERIFICA == "1"
              if round(nDIFERE,2) >= 0.02 .and. cOPCAO == "I"
                 qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
                 XNIVEL -= 3
              endif
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

/////////////////////////////////////////////////////////////////////////////
// PARA CONSULTAR SE POSSUI OUTRAS ALIQUOTAS ________________________________

static function i_consulta

   local nTECLA, nCONT

   setpos(24,79)

   qmensa("<ESC> p/ voltar ou <O>utras Aliquotas,<L>anc p/ Centro de Custos")

   do while .T.
      nTECLA := qinkey()
      if nTECLA == K_ESC ; exit ; endif

      if upper(chr(nTECLA)) == "O"
         i_init_out_aliq()
         XNIVEL := 1
         qlbloc(5,0,"B202O","QBLOC.GLO")

         for nCONT := 1 to 5
             qrsay(XNIVEL++,aOUTALIQ[nCONT,1],"@E 999,999,999.99")
             qrsay(XNIVEL++,aOUTALIQ[nCONT,2],"@E 99.99")
             qrsay(XNIVEL++,aOUTALIQ[nCONT,3],"@E 999,999,999.99")
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

/////////////////////////////////////////////////////////////////////////////
// PARA INICIAR VALORES DE OUTRAS ALIQUOTAS _________________________________

static function i_init_out_aliq

   if OUTSAI->(dbseek(dtos(SAI->DATA_LANC) + SAI->NUM_NF+ SAI->SERIE + SAI->FILIAL))
      for nCONT := 1 to 5
           aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
           aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
           aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr
           OUTSAI->(dbskip())

           if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
              exit
           endif
      next
   else
      return
   endif

   // INICIA VARIAVEIS PARA EDICAO __________________________________________

   nBASE_1 := aOUTALIQ[1,1]
   nBASE_2 := aOUTALIQ[2,1]
   nBASE_3 := aOUTALIQ[3,1]
   nBASE_4 := aOUTALIQ[4,1]
   nBASE_5 := aOUTALIQ[5,1]
   nALIQ_1 := aOUTALIQ[1,2]
   nALIQ_2 := aOUTALIQ[2,2]
   nALIQ_3 := aOUTALIQ[3,2]
   nALIQ_4 := aOUTALIQ[4,2]
   nALIQ_5 := aOUTALIQ[5,2]
   nICM_1  := aOUTALIQ[1,3]
   nICM_2  := aOUTALIQ[2,3]
   nICM_3  := aOUTALIQ[3,3]
   nICM_4  := aOUTALIQ[4,3]
   nICM_5  := aOUTALIQ[5,3]

return

/////////////////////////////////////////////////////////////////////////////
// GRAVA AS OUTRAS ALIQUOTAS ________________________________________________

static function i_grava_outras

   do while OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial))
      OUTSAI->(dbdelete())
   enddo

   // OBS. UTILIZADA TAMBEM PARA EXCLUSAO DE LANCAMENTO, QUANDO O VETOR
   // VAI ESTAR VAZIO E NAO VAI ENTRAR NO for ABAIXO...

   for nCONT := 1 to 5

       if empty(aOUTALIQ[nCONT,1]) ; exit ; endif

       OUTSAI->(qappend())

       replace OUTSAI->Data_Lanc with fDATA_LANC
       replace OUTSAI->Num_Nf    with fNUM_NF
       replace OUTSAI->Serie     with fSERIE
       replace OUTSAI->Filial    with fFILIAL
       replace OUTSAI->Icm_Base  with aOUTALIQ[nCONT,1]
       replace OUTSAI->Icm_Aliq  with aOUTALIQ[nCONT,2]
       replace OUTSAI->Icm_Vlr   with aOUTALIQ[nCONT,3]

       OUTSAI->(dbskip())
   next

return

/////////////////////////////////////////////////////////////////////////////
// CONVERTE NUMERO DO ESTADO PARA A SIGLA CORRESPONDENTE ____________________

static function i_sigla_uf(fESTADO)

   do case
      case fESTADO  =  "01"
           fESTADO  := "AC" // ACRE
      case fESTADO  =  "02"
           fESTADO  := "AL" // ALAGOAS
      case fESTADO  =  "03"
           fESTADO  := "AP" // AMAPA
      case fESTADO  =  "04"
           fESTADO  := "AM" // AMAZONAS
      case fESTADO  =  "05"
           fESTADO  := "BA" // BAHIA
      case fESTADO  =  "06"
           fESTADO  := "CE" // CEARA
      case fESTADO  =  "07"
           fESTADO  := "DF" // DISTRITO FEDERAL
      case fESTADO  =  "08"
           fESTADO  := "ES" // ESPIRITO SANTO
      case fESTADO  =  "09"
           fESTADO  := "FN" // FERNANDO DE NORONHA
      case fESTADO  =  "10"
           fESTADO  := "GO" // GOIAS
      case fESTADO  =  "11"
           fESTADO  := "TO" // TOCANTINS
      case fESTADO  =  "12"
           fESTADO  := "MA" // MARANHAO
      case fESTADO  =  "13"
           fESTADO  := "MT" // MATO GROSSO
      case fESTADO  =  "14"
           fESTADO  := "MG" // MINAS GERAIS
      case fESTADO  =  "15"
           fESTADO  := "PA" // PARA
      case fESTADO  =  "16"
           fESTADO  := "PB" // PARAIBA
      case fESTADO  =  "17"
           fESTADO  := "PR" // PARANA
      case fESTADO  =  "18"
           fESTADO  := "PE" // PERNANBUCO
      case fESTADO  =  "19"
           fESTADO  := "PI" // PIAUI
      case fESTADO  =  "20"
           fESTADO  := "RN" // RIO GRANDE DO N.
      case fESTADO  =  "21"
           fESTADO  := "RS" // RIO GRANDE DO S.
      case fESTADO  =  "22"
           fESTADO  := "RJ" // RIO DE JANEIRO
      case fESTADO  =  "23"
           fESTADO  := "RO" // RONDONIA
      case fESTADO  =  "24"
           fESTADO  := "RR" // RORAIMA
      case fESTADO  =  "25"
           fESTADO  := "SC" // SANTA CATARINA
      case fESTADO  =  "26"
           fESTADO  := "SP" // SAO PAULO
      case fESTADO  =  "l27"
           fESTADO  := "SE" // SERGIPE
      case fESTADO  =  "28"
           fESTADO  := "MS" // MATO GROSSO DO SUL

   endcase

return fESTADO

//////////////////////////////////////////////////////////////////////////////////
// PARA INICIAR VALORES DE CENTRO DE CUSTOS ______________________________________

static function i_int_ccusto

   if SAICUST->(dbseek(dtos(SAI->Data_lanc)+SAI->Num_nf + SAI->Serie + SAI->Filial))
      for nCONT := 1 to 5
           aCCUSTO[nCONT,1] := SAICUST->Icm_Base
           aCCUSTO[nCONT,2] := SAICUST->Icm_Aliq
           aCCUSTO[nCONT,3] := SAICUST->Icm_Vlr
           aCCUSTO[nCONT,4] := SAICUST->Centro
           SAICUST->(dbskip())
           if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(SAICUST->Data_lanc) + SAICUST->Num_nf + SAICUST->Serie + SAICUST->Filial
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

   do while SAICUST->(dbseek(dtos(SAI->Data_lanc)+SAI->Num_nf+SAI->Serie + SAI->Filial))
      SAICUST->(qrlock())
      SAICUST->(dbdelete())
      SAICUST->(qunlock())

   enddo

   // OBS. UTILIZADA TAMBEM PARA EXCLUSAO DE LANCAMENTO, QUANDO O VETOR
   // VAI ESTAR VAZIO E NAO VAI ENTRAR NO for ABAIXO...

   for nCONT := 1 to 5

       if empty(aCCUSTO[nCONT,1]) ; exit ; endif

       SAICUST->(qappend())
       replace SAICUST->Data_Lanc with fDATA_LANC
       replace SAICUST->Num_Nf    with fNUM_NF
       replace SAICUST->Serie     with fSERIE
       replace SAICUST->Especie   with fESPECIE
       replace SAICUST->Filial    with fFILIAL
       replace SAICUST->Icm_Base  with aCCUSTO[nCONT,1]
       replace SAICUST->Icm_Aliq  with aCCUSTO[nCONT,2]
       replace SAICUST->Icm_Vlr   with aCCUSTO[nCONT,3]
       replace SAICUST->Centro    with aCCUSTO[nCONT,4]


       SAICUST->(dbskip())

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
//         qrbloc(14,32,sBLOC)
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

//           if cOPCAO == "I"
//              nBASECC_2 := fVALOR - nBASECC_1
//              qrsay(XNIVEL+2,nBASECC_2,"@E 999,999,999.99")
//              fVALOR  := nBASECC_2
//           endif
//
      case cCAMPO == "ICMCC_2"
           nDIFERE := (nICMCC_2 - ((nBASECC_2 * nALIQCC_2) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif
//
//           if cOPCAO == "I"
//              nBASECC_3 := fVALOR - nBASECC_2
//              qrsay(XNIVEL+2,nBASECC_3,"@E 999,999,999.99")
//              fVALOR  := nBASECC_3
//
//           endif
//
      case cCAMPO == "ICMCC_3"
           nDIFERE := (nICMCC_3 - ((nBASECC_3 * nALIQCC_3) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif
//
//           if cOPCAO == "I"
//              nBASECC_4 := fVALOR - nBASECC_3
//              qrsay(XNIVEL+2,nBASECC_4,"@E 999,999,999.99")
//              fVALOR  := nBASECC_4
//
//           endif
//
      case cCAMPO == "ICMCC_4"
           nDIFERE := (nICMCC_4 - ((nBASECC_4 * nALIQCC_4) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif
//
//           if cOPCAO == "I"
//              nBASECC_5 := fVALOR - nBASECC_4
//              qrsay(XNIVEL+2,nBASECC_5,"@E 999,999,999.99")
//              fVALOR  := nBASECC_5
//
//           endif
//
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

 //////////////////////////////////////////////////////////////////////////////////
 // INCLUI CLIENTE NO LANCAMENTO DA NOTA FISCAL ________________________________

function i_inc_cliente

    local nNIVEL  := XNIVEL
    local nORDER  := CLI1->(dbsetorder(1))
    local sBLOC   := qsbloc(0,0,24,79)
    local nCURS   := setcursor(1)
    //local fCODIGO

    XNIVEL        := 2

    CLI1->(qpublicfields())
    CLI1->(qinitfields())

    i_inc_c2()

    CLI1->(dbsetorder(nORDER))

    XNIVEL := nNIVEL

    setcursor(nCURS)

    if qconf("Confirma inclus„o deste cliente ?","B")

       if CLI1->(qappend()) .and. CONFIG->(qrlock())
          replace CONFIG->Cod_cli with CONFIG->Cod_cli + 1
          qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_cli,5) )
          qmensa("C¢digo Gerado: "+fCODIGO,"B")
          cCOD_CLI1 := fCODIGO

          CLI1->(qreplacefields())

          select SAI

          qrbloc(0,0,sBLOC)
          return .T.

       else

          if empty(CLI1->Codigo) .and. empty(CLI1->Razao) .and. empty(CLI1->Cgccpf)
             CLI1->(dbdelete())
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

//static function i_trava_tipovar

//   if ! TIPOVAR->(qappend())
//      return .F.
//   endif

//return .T.

 //////////////////////////////////////////////////////////////////////////////////
 // FAZ A EDICAO DOS CAMPOS PARA INCLUSAO DO CLIENTE __________________________

 function i_inc_c2

    local aEDICAO := {}
    local bESCAPE := {||empty(fRAZAO).or.(XNIVEL==2.and.!XFLAG)}

    qlbloc(6,2,"B201G","QBLOC.GLO",1)

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
       if eval ( bESCAPE ) ; CLI1->(qreleasefields()) ; return ; endif
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

