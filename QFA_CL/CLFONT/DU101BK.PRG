      qrsay ( XNIVEL++ , (cALIAS)->Codigo                                 )
      qrsay ( XNIVEL++ , fu_conv_cgccpf( (cALIAS)->Cgccpf )               )
      qrsay ( XNIVEL++ , (cALIAS)->Inscricao                              )
      qrsay ( XNIVEL++ , (cALIAS)->Razao                                  )
      qrsay ( XNIVEL++ , (cALIAS)->Fantasia                               )
      qrsay ( XNIVEL++ , (cALIAS)->Rg                                           )

      if lAGUA
         qrsay ( XNIVEL++ , iif(CLI1->Final $ " N","N„o","Sim")             )
      else
         qrsay ( XNIVEL++ , iif(CLI1->Isento $ " N","N„o","Sim")             )
      endif

      qrsay ( XNIVEL++ , left((cALIAS)->End_ent,48)                       )
      qrsay ( XNIVEL++ , (cALIAS)->Numero                                 )
      qrsay ( XNIVEL++ , (cALIAS)->Cgm_ent                                ) ; CGM->(dbseek((cALIAS)->Cgm_ent))
      qrsay ( XNIVEL++ , CGM->Municipio                                   )
      qrsay ( XNIVEL++ , CGM->Estado                                      )
      qrsay ( XNIVEL++ , (cALIAS)->Cep_ent , "@R 99.999-999"              )
      qrsay ( XNIVEL++ , (cALIAS)->Bairro_ent, "@!"                       )
      qrsay ( XNIVEL++ , (cALIAS)->Compl     , "@!"                       )

      if ! lAGUA
         qrsay ( XNIVEL++ , (cALIAS)->End_cob                                )
         qrsay ( XNIVEL++ , (cALIAS)->Cgm_cob                                ) ; CGM->(dbseek((cALIAS)->Cgm_cob))
         qrsay ( XNIVEL++ , CGM->Municipio                                   )
         qrsay ( XNIVEL++ , CGM->Estado                                      )
         qrsay ( XNIVEL++ , (cALIAS)->Cep_cob , "@R 99.999-999"              )
         qrsay ( XNIVEL++ , (cALIAS)->Bairro_cob, "@!"                       )
      endif

      qrsay ( XNIVEL++ , (cALIAS)->Fax                                    )
      qrsay ( XNIVEL++ , (cALIAS)->Fone1                                  )

      if ! lAGUA
         if CONFIG->Modelo_2 == "5"
            qrsay ( XNIVEL++ , (cALIAS)->Ramal1                              )
            qrsay ( XNIVEL++ , (cALIAS)->Fone2                               )
            qrsay ( XNIVEL++ , (cALIAS)->Ramal2                              )
            qrsay ( XNIVEL++ , (cALIAS)->Foner                               )
         else
            qrsay ( XNIVEL++ , (cALIAS)->Fone2                               )
            qrsay ( XNIVEL++ , (cALIAS)->Data_ent                            )
            qrsay ( XNIVEL++ , (cALIAS)->Foner                               )
         endif
      endif

      qrsay ( XNIVEL++ , (cALIAS)->Cod_setor                              ) ; SETOR->(Dbseek((cALIAS)->Cod_setor))
      qrsay ( XNIVEL++ , left(SETOR->Descricao,15)                        )
      qrsay ( XNIVEL++ , (cALIAS)->Cod_vend                               ) ; VEND->(Dbseek((cALIAS)->Cod_vend))
      qrsay ( XNIVEL++ , left(VEND->Nome,12)                              )

      if ! lAGUA
         if CONFIG->Modelo_fat == "1"
            qrsay ( XNIVEL++ , (cALIAS)->Cod_territ                               ) ; TERRIT->(Dbseek((cALIAS)->Cod_territ))
            qrsay ( XNIVEL++ , left(TERRIT->Descricao,17)                         )
         endif
      endif


      qrsay ( XNIVEL++ , (cALIAS)->Cod_Repres                             ) ; REPRES->(Dbseek((cALIAS)->Cod_repres))
      qrsay ( XNIVEL++ , left(REPRES->Razao,20)                           )
      qrsay ( XNIVEL++ , (cALIAS)->Comis_Repr,"@E 99.99"                  )

      qrsay ( XNIVEL++ , left((cALIAS)->Contato_c,20)                     )

      if ! lAGUA
         qrsay ( XNIVEL++ , (cALIAS)->Contato_f                              )
         qrsay ( XNIVEL++ , (cALIAS)->Conta_cont, "@R 99999-9"               ) ; PLAN->(Dbseek((cALIAS)->Conta_cont))
         qrsay ( XNIVEL++ , iif((cALIAS)->Conta_cont <> space(6),PLAN->Descricao," "))
      endif

      qrsay ( XNIVEL++ , (cALIAS)->Filial    ) ; FILIAL->(dbseek((cALIAS)->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)                           )
      if CONFIG->Modelo_2 == "5"
         qrsay ( XNIVEL++ , CLI1->Email  )
      endif
      if ! lAGUA
         if config->modelo_fat == "1"
            qrsay ( XNIVEL++ , CLI1->Dt_aniver, "99/99")
         endif
      endif

      if lAGUA
         qrsay ( XNIVEL++ , fultcom() )
         qrsay ( XNIVEL++ , CLI1->Cod_rota );ROTA->(dbseek(CLI1->Cod_rota))
         qrsay ( XNIVEL++ , left(ROTA->Descricao,25))
         qrsay ( XNIVEL++ , CLI1->Tipo_doc );TIPO_DOC->(dbseek(CLI1->Tipo_doc))
         qrsay ( XNIVEL++ , left(TIPO_DOC->Descricao,25) )
         qrsay ( XNIVEL++ , Transform(CLI1->Dias,"@R 99") )
         i_getReceber(CLI1->Codigo)
         qrsay (XNIVEL++  , cDebito        )
         qrsay (XNIVEL++  , cNOTAFISCAL    )
         qrsay (XNIVEL++  , dtoc(cDT_VENC) )
         qrsay (XNIVEL++  , transform(nVAL_DEB,"@E 999,999.99") )
         qrsay (XNIVEL++  , transform(nTOT_DEB,"@E 999,999.99") )
      else
         if CONFIG->Modelo_fat == "1"
            qrsay ( XNIVEL++ , CLI1->Cod_transp,"99999");TRANSP->(DbSeek(CLI1->Cod_transp))
            qrsay ( XNIVEL++ , left(TRANSP->Razao,30))
            qrsay ( XNIVEL++ , CLI1->Voltagem, "999")
         endif
      endif

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF       ,"@R 99.999.999/9999-99") },"CGCCPF"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO    ,"@!")                    },"INSCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA     ,"@!")                    },"FANTASIA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRG           ,"@X!")                   },"RG"        })

   if lAGUA
      aadd(aEDICAO,{{ || qesco(-1,0,@fFINAL,XSN)                            },"FINAL"    })
   else
      aadd(aEDICAO,{{ || qesco(-1,0,@fISENTO,XSN)                            },"ISENTO"    })
   endif

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_ENT      ,"@!S48")                 },"END_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUMERO       ,"9999999")                },"NUMERO"    })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT)                            },"CGM_ENT"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_ENT      ,"@R 99.999-999")         },"CEP_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO_ENT      ,"@!")                 },"BAIRRO_ENT"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMPL           ,"@!")                 },"COMPL"})

   if ! lAGUA
//      aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_ASS           )                    },"COD_ASS"   })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_COB      ,"@!")                    },"END_COB"   })
      aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_COB)                            },"CGM_COB"   })
      aadd(aEDICAO,{{ || NIL                                                 },NIL         })
      aadd(aEDICAO,{{ || NIL                                                 },NIL         })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_COB      ,"@R 99.999-999")         },"CEP_COB"   })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO_COB      ,"@!")                 },"BAIRRO_COB"})
   endif

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1        ,"@!")                    },"FONE1"     })

   if ! lAGUA
      aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE2        ,"@!")                    },"FONE2"     })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_ENT     ,"@D")                    },"DATA_ENT"  })

   //   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL1       ,"@!")                    },"RAMAL1"    })
   //   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL2       ,"@!")                    },"RAMAL2"    })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fFONER        ,"@!")                    },"FONER"     })
   endif

   aadd(aEDICAO,{{ || view_setor(-1,0,@fCOD_SETOR)                        },"COD_SETOR" })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_vend(-1,0,@fCOD_VEND)                          },"COD_VEND"  })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   if ! lAGUA
      aadd(aEDICAO,{{ || view_territ(-1,0,@fCOD_TERRIT)                          },"COD_TERRIT"  })
      aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   endif

   aadd(aEDICAO,{{ || view_repres(-1,0,@fCOD_REPRES)                        },"COD_REPRES"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMIS_REPR,"@E 99.99"  )               },"COD_REPRES"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C    ,"@!")                    },"CONTATO_C" })

   if ! lAGUA
      aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_F    ,"@!")                    },"CONTATO_F" })
      aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONT ,"@R 99999-9")          },"CONTA_CONT"})
      aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   endif

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fEMAIL    )                             },"EMAIL" })

   if ! lAGUA
      aadd(aEDICAO,{{ || qgetx(-1,0,@fDT_ANIVER,"99/99"    )                 },"DT_ANIVER" })
   endif

   if lAGUA
      aadd(aEDICAO,{{ || NIL                                                 },"ULTIMA"  })

      aadd(aEDICAO,{{ || view_rota(-1,0,@fCOD_ROTA)                          },"COD_ROTA" })
      aadd(aEDICAO,{{ || NIL                                                 },NIL         })

      aadd(aEDICAO,{{ || view_doc(-1,0,@fTIPO_DOC)                           },"TIPO_DOC" })
      aadd(aEDICAO,{{ || NIL                                                 },NIL         })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS     )                             },"DIAS" })
   else
      aadd(aEDICAO,{{ || view_transp(-1,0,@fCOD_TRANSP,"99999"    )          },"COD_TRANSP" })
      aadd(aEDICAO,{{ || NIL                                                 },NIL         })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fVOLTAGEM,"999"    )                    },"VOLTAGEM" })
   endif



   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

