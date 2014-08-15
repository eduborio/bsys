/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE PRODUTOS
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1999
// OBS........:
// ALTERACOES.:

function cp102
private sBLOC1  := qlbloc("B102B","QBLOC.GLO")
if ! quse(XDRV_CL,"CONFIG",{},,"CONCL")
   qmensa("NÑo foi poss°vel abrir arquivo CONFIG.DBF !! Tente novamente.")
   return .F.
endif

private cMODELO_2 := CONCL->Modelo_2
private cModelo_fat := CONCL->Modelo_fat
CONCL->(dbclosearea())
PROD->(qview({{"transform(Codigo,'@R 99.99.99999')/C¢digo" ,1},;
              {"c102b()/DescriáÑo"                         ,2},;
              {"left(Marca,8)/Marca"                       ,8},;
              {"left(Cod_fabr,8)/C¢d. Fabr"                ,5},;
              {"fDesign()   /Designer"                     ,0},;
              {"right(Codigo,5)/C¢d. Qsys"                 ,4}},"P",;
              {NIL,"c102a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESLOCAR EM ARVORE A DESCRICAO DOS PRODUTOS __________________

function c102b
   local cDESCRICAO := PROD->Descricao + "    "

   if cModelo_fat == "1"
      do case
         case len(alltrim(PROD->Codigo)) == 2 ; cDESCRICAO := left(PROD->Descricao,22)+"    "
         case len(alltrim(PROD->Codigo)) == 4 ; cDESCRICAO := "  "+left(PROD->Descricao,22)+"  "
         case len(alltrim(PROD->Codigo)) == 9 ; cDESCRICAO := "    "+left(PROD->Descricao,22)
      endcase
   else
      do case
         case len(alltrim(PROD->Codigo)) == 2 ; cDESCRICAO := left(PROD->Descricao,35)+"    "
         case len(alltrim(PROD->Codigo)) == 4 ; cDESCRICAO := "  "+left(PROD->Descricao,35)+"  "
         case len(alltrim(PROD->Codigo)) == 9 ; cDESCRICAO := "    "+left(PROD->Descricao,35)
      endcase
   endif

return left(cDESCRICAO,30)


function fDesign
local cResult := space(3)

      if PROD->Designer != "000" .and. PROD->Designer != "   "
         cREsult := "Sim"
      endif


return cResult

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c102a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   
   if cOPCAO == "S"
      sqlMaker()
   endif
   
   if cOPCAO $ XUSRA

      if cModelo_2 == "9"
         qlbloc(09,07,"B102K","QBLOC.GLO",1)
      else
         qlbloc(05,00,"B102A","QBLOC.GLO",1)
      endif

      qmensa(qabrev(cOPCAO,"IA",{"InclusÑo... <ESC - Cancela>","AlteraáÑo... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO) .and. Lastkey()==27 .or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}
   local nREC

   local sBLOC1 := qlbloc("B102B","QBLOC.GLO") // Sim/Nao
   local sBLOC2 := qlbloc("B102C","QBLOC.GLO") // Consumivel/Permanente
   local sBLOC3 := qlbloc("B102D","QBLOC.GLO") // Produto Acabado/Materia Prima/Material/Embalagens/Vazios/Outros


   private nTIPO := 0

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PROD->Codigo , "@R 99.99.99999"                    )
      qrsay ( XNIVEL++ , PROD->Cod_ass                                      )
      qrsay ( XNIVEL++ , PROD->Cod_barras                                      )
      qrsay ( XNIVEL++ , PROD->Cod_fabr                                     )
      qrsay ( XNIVEL++ , PROD->Marca                                        )
      qrsay ( XNIVEL++ , PROD->Descricao                                    )

//      qrsay ( XNIVEL++ , PROD->Desc2                                        )
//      qrsay ( XNIVEL++ , PROD->Desc3                                        )

      qrsay ( XNIVEL++ , qabrev(PROD->Prod_iss,"SN",{"Sim","NÑo"})          )
      qrsay ( XNIVEL++ , PROD->Aliq_iss                                     )
      qrsay ( XNIVEL++ , transform(PROD->Ipi,"@E 99.99")                    )
      qrsay ( XNIVEL++ , transform(PROD->Icms,"@E 99.99")                   )

      qrsay ( XNIVEL++ , PROD->Unidade                                      ) ; UNIDADE->(dbseek(PROD->Unidade))
      qrsay ( XNIVEL++ , UNIDADE->Sigla                                     )

//      qrsay ( XNIVEL++ , qabrev(PROD->Lista,"SN", {"Sim","NÑo"})            )
//      qrsay ( XNIVEL++ , qabrev(PROD->Tributa,"SN", {"Sim","NÑo"})          )

      qrsay ( XNIVEL++ , PROD->Cod_class                                    ) ; CLASSIF->(dbseek(PROD->Cod_class))
      qrsay ( XNIVEL++ , CLASSIF->Descricao                                 )

//      qrsay ( XNIVEL++ , qabrev(PROD->Consumivel,"CP", {"Consumivel","Permanente"})          )

      qrsay ( XNIVEL++ , qabrev(PROD->Tipo      ,"123456", {"Produto Acabado","Matria prima","Material","Embalagens","Vazios","Outros"}) )
      qrsay ( XNIVEL++ , PROD->BC_subst   , "@E 999,999.99"                 )


//      qrsay ( XNIVEL++ , transform(PROD->Preco_unit,"@E 99,999,999.99999"  ))
//      qrsay ( XNIVEL++ , PROD->Desconto   , "@E 99.99"                      )
      qrsay ( XNIVEL++ , PROD->Preco_cust , "@E 999,999.9999"                 )
      qrsay ( XNIVEL++ , PROD->Cust_dolar , "@E 999,999.99"                 )
      qrsay ( XNIVEL++ , PROD->Cust_ren   , "@E 999,999.99"                 )

      qrsay ( XNIVEL++ , PROD->Preco_cons , "@E 999,999.99"             )
      qrsay ( XNIVEL++ , PROD->vend_dolar , "@E 999,999.99"             )
      qrsay ( XNIVEL++ , PROD->vend_ren   , "@E 999,999.99"             )

//      qrsay ( XNIVEL++ , PROD->Preco_alug , "@E 999,999.99"                 )
      qrsay ( XNIVEL++ , PROD->Peso         , "@E 999999.999"                 )
      qrsay ( XNIVEL++ , PROD->Peso_bruto   , "@E 999999.999"                 )
      qrsay ( XNIVEL++ , PROD->Cubagem      , "@E 999999.999"                 )
      qrsay ( XNIVEL++ , PROD->Cx_master  , "@E 999"                        )

      qrsay ( XNIVEL++ , qabrev(PROD->FimDeVida ,"SN " ,{"Sim","Nao","Nao"})          )
      qrsay ( XNIVEL++ , qabrev(PROD->Fora_Linha,"SN ", {"Sim","Nao","Nao"})          )


      qrsay ( XNIVEL++ , PROD->Cod_Fornec                                   ) ; FORN->(Dbseek(PROD->Cod_fornec))
      qrsay ( XNIVEL++ , left(FORN->Razao,20)                               )

      qrsay ( XNIVEL++ , PROD->Fabr                                         ) ; FABRICA->(Dbseek(PROD->Fabr))
      qrsay ( XNIVEL++ , left(FABRICA->Razao,20)                            )

      qrsay ( XNIVEL++ , qabrev(PROD->Inspecao,"SN ", {"Sim","Nao","Nao"})          )

      qrsay ( XNIVEL++ , PROD->Designer                                     ) ; DESIGNER->(Dbseek(PROD->Designer))
      qrsay ( XNIVEL++ , left(DESIGNER->Nome,30)                            )


   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"@R 99.99")                },"CODIGO"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_ASS      ,"@!"      )                },"COD_ASS"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_BARRAS   ,"9999999999999")           },"COD_BARRAS"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_FABR     ,"@!")                      },"COD_FABR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMARCA        ,"@!")                      },"MARCA"        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    ,"@!")                      },"DESCRICAO"    })
//   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC2        ,"@!")                      },"DESC2"        })
//   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC3        ,"@!")                      },"DESC3"        })

   aadd(aEDICAO,{{ || qesco(-1,0,@fPROD_ISS     ,sBLOC1                   ) },"PROD_ISS"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_ISS     ,"@R 99.99")                },"ALIQ_ISS"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI          ,"@E 99.99")                },"IPI"          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICMS         ,"@E 99.99")                },"ICMS"         })

   aadd(aEDICAO,{{ || view_uni(-1,0,@fUNIDADE)                              },"UNIDADE"      })
   aadd(aEDICAO,{{ || NIL                                                   },NIL            })
//   aadd(aEDICAO,{{ || qesco(-1,0,@fLISTA ,sBLOC1                           )} ,"LISTA"       })
//   aadd(aEDICAO,{{ || qesco(-1,0,@fTRIBUTA ,sBLOC1                          )} ,"TRIBUTA"    })
   aadd(aEDICAO,{{ || view_class(-1,0,@fCOD_CLASS)                         },"COD_CLASS"    })
   aadd(aEDICAO,{{ || NIL                                                   },NIL            })
//   aadd(aEDICAO,{{ || qesco(-1,0,@fCONSUMIVEL ,sBLOC2                       )} ,"CONSUMIVEL" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fTIPO       ,sBLOC3                       )} ,"TIPO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBC_SUBST  ,"@E 999,999.99")              },"BC_SUBST"   })


//   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_UNIT,"@E 99,999,999.99999")        },"PRECO_UNIT"   })
//   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCONTO,"@E 99.99")                     },"DESCONTO"     })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_CUST,"@E 999,999.9999")              },"PRECO_CUST"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCUST_DOLAR,"@E 999,999.99")              },"CUST_DOLAR"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCUST_REN,"@E 999,999.99")                },"CUST_REN"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_CONS,"@E 999,999.99")          },"PRECO_CONS"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVEND_DOLAR,"@E 999,999.99")              },"VEND_DOLAR"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVEND_REN,"@E 999,999.99")                },"VEND_REN"   })

//   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_ALUG,"@E 999,999.99")              },"PRECO_ALUG"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPESO      ,"@E 999999.999")             },"PESO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPESO_BRUTO,"@E 999999.999")             },"PESO_B" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCUBAGEM,"@E 999999.999")                },"CUBAGEM" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCX_MASTER,"@E 999")                     },"CX_MASTER" })

   aadd(aEDICAO,{{ || qesco(-1,0,@fFIMDEVIDA,XSN                          )}  ,"FDV" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fFORA_LINHA,XSN                          )} ,"FORA" })



   aadd(aEDICAO,{{ || view_forn1(-1,0,@fCOD_FORNEC)                         },"COD_FORNEC"   })
   aadd(aEDICAO,{{ || NIL                                                   },NIL            })

   aadd(aEDICAO,{{ || view_fabr(-1,0,@fFABR)                                },"FABR"   })
   aadd(aEDICAO,{{ || NIL                                                   },NIL            })

   aadd(aEDICAO,{{ || qesco(-1,0,@fINSPECAO,XSN                             )} ,"INSPECAO" })

   aadd(aEDICAO,{{ || view_designer(-1,0,@fDesigner)                        },"DESIGNER"   })
   aadd(aEDICAO,{{ || NIL                                                   },NIL            })




   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclusÑo","alteraáÑo")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PROD->(qpublicfields())
   iif(cOPCAO=="I",PROD->(qinitfields()),PROD->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.
   fPROD_ISS := iif(cOPCAO=="I","N",fPROD_ISS)

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PROD->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. PROD->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO PRODUTO __________________________________

      if cOPCAO == "I"
         if nTIPO == 1 //len(alltrim(fCODIGO)) == 9
            replace CONFIG->Cod_prod with CONFIG->Cod_prod + 1
            fCODIGO := alltrim(fCODIGO) + strzero(CONFIG->Cod_prod,5)
            qrsay ( 1 , transform(fCODIGO,"@R 99.99.99999") )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")

         //   if PROD->(dbseek(fCODIGO)) .and. cOPCAO == "I"
         //      qmensa("Produto j† cadastrado !","B")
         //      fCODIGO := ""
         //      return .F.
         //   endif

         endif
      endif

      PROD->(qreplacefields())

      //lCONF := qconf("Deseja lanáar Garantia deste Produto?")

      //if lCONF .and. cOPCAO == "I"
      //   lanc_garan(right(fCODIGO,5))
      //   select PROD
      //   PROD->(Dbsetorder(1))
      //endif

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()


return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREC

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO"
           if empty(fFIMDEVIDA)
              fFIMDEVIDA := "N"
           endif

           if empty(fINSPECAO)
              fINSPECAO := "N"
           endif


           if empty(fFORA_LINHA)
              fFORA_LINHA := "N"
           endif

           do case
              case len(alltrim(fCODIGO)) == 2
                   if cOPCAO == "I"
                      if PROD->(dbseek(fCODIGO))
                         qmensa("Grupo j† cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      XNIVEL := 4
                   else
                      XNIVEL := 4
                   endif



              case len(alltrim(fCODIGO)) == 4

                   if cOPCAO == "I"
                      i_tipo_inc()
                   else
                      nTIPO := 2
                   endif

                   if nTIPO == 1
                      //fCODIGO := alltrim(fCODIGO) + strzero(CONFIG->Cod_prod+1,5)
                      if ! PROD->(dbseek(left(fCODIGO,4))) .and. cOPCAO == "I"
                         qmensa("Sub-grupo nÑo cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
           //           if PROD->(dbseek(fCODIGO)) .and. cOPCAO == "I"
           //              qmensa("Produto j† cadastrado !","B")
           //              fCODIGO := ""
           //              return .F.
           //           endif
                   else
                      if cOPCAO == "I"
                         if PROD->(dbseek(fCODIGO))
                            qmensa("Sub-grupo j† cadastrado !","B")
                            fCODIGO := ""
                            return .F.
                         endif
                         if ! PROD->(dbseek(left(fCODIGO,2)))
                            qmensa("Grupo nÑo cadastrado !","B")
                            fCODIGO := ""
                            return .F.
                         endif
                      endif
                   endif

                   if nTIPO == 1 //len(alltrim(fCODIGO)) <> 9
                      XNIVEL := 1
                   endif

                   if nTIPO == 2 //len(alltrim(fCODIGO)) <> 9
                      XNIVEL := 4
                   endif


           endcase

      case cCAMPO == "DESCRICAO"
           if nTIPO == 2 //len(alltrim(fCODIGO)) <> 9
              XNIVEL := 10
           endif

      case cCAMPO == "PROD_ISS"

           qrsay(XNIVEL,qabrev(fPROD_ISS,"SN",{"Sim","NÑo"}))
           if XFLAG
              if fPROD_ISS <> "S" .and. cOPCAO == "I"
                 XNIVEL++
              Elseif fPROD_ISS == "N" .and. cOPCAO == "A"
                 fALIQ_ISS := 0
                 XNIVEL++
              Endif
           Endif

      case cCAMPO == "IPI"
           if fIPI < 0  ; return .F. ; endif

      case cCAMPO == "UNIDADE"
           if ! UNIDADE->(dbseek(fUNIDADE))
              qmensa("Unidade nÑo encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,UNIDADE->Sigla)

      case cCAMPO == "COD_CLASS"
           if ! CLASSIF->(dbseek(fCOD_CLASS))
              qmensa("Cl. Fiscal nÑo encontrada !","B")
              //return .F.
           endif

           qrsay(XNIVEL+1,CLASSIF->Descricao)


      case cCAMPO == "LISTA"
           if empty(fLISTA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fLISTA,"SN",{"Sim","NÑo"}))


      case cCAMPO == "FORA"
           if empty(fFORA_LINHA)
              fFORA_LINHA := "N"
           endif
           qrsay(XNIVEL,qabrev(fFORA_LINHA,"SN",{"Sim","Nao"}))

      case cCAMPO == "FDV"
           if empty(fFIMDEVIDA)
              fFIMDEVIDA := "N"
           endif
           qrsay(XNIVEL,qabrev(fFIMDEVIDA,"SN",{"Sim","Nao"}))



      case cCAMPO == "CONSUMIVEL"
           if empty(fCONSUMIVEL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fCONSUMIVEL,"CP",{"Consumivel","Permanente"}))

      case cCAMPO == "TIPO"
           if empty(fTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fTIPO,"123456", {"Produto Acabado","Matria prima","Material","Embalagens","Vazios","Outros"}))


      case cCAMPO == "TRIBUTA"
           if empty(fTRIBUTA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fTRIBUTA,"SN",{"Sim","NÑo"}))

      case cCAMPO == "DESCONTO"
          // nPRECO_CUST := fPRECO_UNIT - ( fPRECO_UNIT * (fDESCONTO/100) )
          // fPRECO_CUST := nPRECO_CUST
          // fPRECO_CONS := fPRECO_UNIT  // valor fixo da tabela de precos dos produtos da farmacia
           qrsay(XNIVEL+1,transform(fPRECO_CUST, "@E 999,999.99"))
           qrsay(XNIVEL+1,transform(fPRECO_CONS, "@E 999,999.99"))

      case cCAMPO == "COD_FORNEC"

           if FORN->(dbseek(fCOD_FORNEC:=strzero(val(fCOD_FORNEC),5) ))
              qrsay(XNIVEL+1,left(FORN->Razao,20))
           endif

      case cCAMPO == "FABR"

           if FABRICA->(dbseek(fFABR:=strzero(val(fFABR),5) ))
              qrsay(XNIVEL+1,left(FABRICA->Razao,20))
           endif


      case cCAMPO == "DESIGNER"

           if DESIGNER->(dbseek(fDesigner:=strzero(val(fDesigner),3) ))
              qrsay(XNIVEL+1,left(DESIGNER->Nome,30))
           endif


      case cCAMPO == "COD_ASS"

          if empty(fCod_barras)
             fcod_ass := alltrim(fCod_Ass)
             if len(fCod_ass) == 4
                    fCod_barras := "84351532"+left(fcod_ass,4)

                 if len(fCod_barras) == 12
                    fCod_barras := fCod_barras + Ean13CheckSum(fCOD_BARRAS)
                    qrsay(XNIVEL+1,fCOD_BARRAS)
                 endif
             endif
			 
			 if len(fCod_ass) == 5
                    fCod_barras := "8435153"+left(fcod_ass,5)

                 if len(fCod_barras) == 12
                    fCod_barras := fCod_barras + Ean13CheckSum(fCOD_BARRAS)
                    qrsay(XNIVEL+1,fCOD_BARRAS)
                 endif
             endif
          endif



      case cCAMPO == "INSPECAO"
           if empty(fINSPECAO)
              fINSPECAO := "N"
           endif
           qrsay(XNIVEL,qabrev(fINSPECAO,"SN",{"Sim","Nao"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR PRODUTO ______________________________________________

static function i_exclusao
   if qconf("Confirma exclusÑo deste Produto ?")
      if PROD->(qrlock())
         PROD->(dbdelete())
         PROD->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHER TIPO DE INCLUSAO ____________________________________

function i_tipo_inc
   nTIPO := alert("Voce est† incluindo...",{"PRODUTO","SUB-GRUPO"})
return

static function Ean13CheckSum(cEAN13)
local lOdd    := .F.
local ndigito := 0
local nCONT   := 0
local nResult := 0

  nCONT := len(cEAN13)
  lOdd := .T.

  do while nCONT > 0

      if lOdd
         nDigito := nDigito + val(substr(cEAN13,nCONT,1)) * 3
      else
         nDigito := nDigito + val(substr(cEAN13,nCONT,1))
      endif

      if lOdd
         lOdd := .F.
      else
         lOdd := .T.
      endif

      nCONT--

  enddo

  nResult := 0

  do while mod(nDigito + nResult,10) <> 0
     nResult ++
  enddo

  //alert("digito verificador "+strzero(nResult,1)+" BAR "+PROD->cod_barras)


return strzero(nResult,1)

static function sqlMaker
local nFile := 0
local nReg := 0
local nIndex := 0
local cSQl := ""
local eol  := chr(13) + chr(10)

     nReg := PROD->(recno())
     nIndex := PROD->(IndexOrd())	 
     PROD->(dbsetfilter({|| right(codigo,5) != "     "}))  
	 PROD->(dbsetorder(4))
     PROD->(dbgotop())
	 
	 cSQl := "Lock tables produtos write;"+eol
	 cSQl += "insert into produtos (id,descricao,preco,preco_custo,referencia_brasil,referencia_espanha,colecao,codigo_barras) values " + eol
	 
     do while ! PROD->(eof())
	    
		
		id := alltrim(str(val(right(PROD->Codigo,5))))
		cSql += "(" + id + ",'" + i_trocachr(rtrim(PROD->Descricao)) + "'," + alltrim(transf(PROD->preco_cons,"@R 99999999.99")) + "," + alltrim(transf(PROD->preco_cust  ,"@R 999999999.99")) + ",'" + rtrim(PROD->Cod_fabr) + "','" + rtrim(PROD->Cod_ass) + "','" + rtrim(PROD->marca) + "','" + PROD->cod_barras + "')," + eol
	  
	 
		PROD->(dbskip())
	 enddo
	 
	 cSql += "unlock tables;" + eol
	 
	 nFile := fcreate("C:\qsystxt\produtos.sql",0)
	 fwrite(nFile,cSql,len(cSql))
	 fClose(nFile)
	 alert("sql de produtos gerado")
	 prod->(dbclearfilter())
	 prod->(dbsetorder(nindex))
	 prod->(dbgoto(nreg))


return

static function i_trocachr(cTROCADO)

   cTROCADO := strtran(cTROCADO,"'","\'")
   cTROCADO := strtran(cTROCADO,"Ä","C")
   cTROCADO := strtran(cTROCADO,"á","C")
   cTROCADO := strtran(cTROCADO,"ß",".")
   cTROCADO := strtran(cTROCADO,"¶","A")
   cTROCADO := strtran(cTROCADO,"Ç","A")
   cTROCADO := strtran(cTROCADO,"É","A")
   cTROCADO := strtran(cTROCADO,"Ñ","A")
   cTROCADO := strtran(cTROCADO,"Ö","A")
   cTROCADO := strtran(cTROCADO,"Ü","A")
   cTROCADO := strtran(cTROCADO,"à","E")
   cTROCADO := strtran(cTROCADO,"â","E")
   cTROCADO := strtran(cTROCADO,"ä","E")
   cTROCADO := strtran(cTROCADO,"ã","I")
   cTROCADO := strtran(cTROCADO,"å","I")
   cTROCADO := strtran(cTROCADO,"ç","I")
   cTROCADO := strtran(cTROCADO,"ì","O")
   cTROCADO := strtran(cTROCADO,"é","A")
   cTROCADO := strtran(cTROCADO,"è","A")
   cTROCADO := strtran(cTROCADO,"ê","E")
   cTROCADO := strtran(cTROCADO,"ì","O")
   cTROCADO := strtran(cTROCADO,"î","O")
   cTROCADO := strtran(cTROCADO,"ï","O")
   cTROCADO := strtran(cTROCADO,"ñ","O")
   cTROCADO := strtran(cTROCADO,"ó","O")
   cTROCADO := strtran(cTROCADO,"ô","O")
   cTROCADO := strtran(cTROCADO,"ö","U")
   cTROCADO := strtran(cTROCADO,"†","A")
   cTROCADO := strtran(cTROCADO,"°","I")
   cTROCADO := strtran(cTROCADO,"¢","O")
   cTROCADO := strtran(cTROCADO,"£","U")
   cTROCADO := strtran(cTROCADO,"§","N")
   cTROCADO := strtran(cTROCADO,"&","E")
   cTROCADO := strtran(cTROCADO,"¯",".")

return(cTROCADO)



