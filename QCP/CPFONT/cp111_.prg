/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE REPRESENTANTE COMERCIAL
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function cp111

EVENTOS->(qview({{"Codigo/C¢digo"              ,1},;
              {"left(Nome,47)/Nome"         ,2}},"P",;
              {NIL,"c111a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c111a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(5,0,"B111A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fNOME).or.(XNIVEL==2.and.!XFLAG).or.!empty(fNOME).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , EVENTOS->Codigo    )
      qrsay ( XNIVEL++ , EVENTOS->Nome )
      qrsay ( XNIVEL++ , EVENTOS->Cod_pav ); PAVILHAO->(Dbseek(EVENTOS->Cod_pav))
      qrsay ( XNIVEL++ , left(PAVILHAO->Descricao,40) )
      qrsay ( XNIVEL++ , EVENTOS->Endereco )
      qrsay ( XNIVEL++ , EVENTOS->Compl   )
      qrsay ( XNIVEL++ , EVENTOS->Cgm ) ; CGM->(dbseek(EVENTOS->Cgm))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , EVENTOS->Bairro   )
      qrsay ( XNIVEL++ , EVENTOS->Cep , "@R 99.999-999" )
      qrsay ( XNIVEL++ , dtoc(EVENTOS->Data_ini)    )
      qrsay ( XNIVEL++ , dtoc(EVENTOS->Data_fim)    )
      qrsay ( XNIVEL++ , EVENTOS->Desc1    )
      qrsay ( XNIVEL++ , EVENTOS->Desc2    )
      qrsay ( XNIVEL++ , EVENTOS->Desc3    )
      qrsay ( XNIVEL++ , EVENTOS->Desc4    )
      qrsay ( XNIVEL++ , EVENTOS->Desc5    )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOME        ,"@!"   ,"!empty(@)",.T.)  },"NOME"      })

   aadd(aEDICAO,{{ || view_pav(-1,0,@fCOD_PAV)                            },"COD_PAV"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })


   aadd(aEDICAO,{{ || qgetx(-1,0,@fENDERECO     ,"@!")                    },"ENDERECO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMPL        ,"@!")                    },"COMPL"      })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM)                            },"CGM"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO       ,"@!")                    },"BAIRRO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP          ,"@R 99.999-999")         },"CEP"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_INI    ,"@D")                    },"DATA_INI" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_FIM    ,"@D")                    },"DATA_FIM" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC1       ,"@!")                    },"DESC1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC2       ,"@!")                    },"DESC2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC3       ,"@!")                    },"DESC3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC4       ,"@!")                    },"DESC4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC5       ,"@!")                    },"DESC5" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   EVENTOS->(qpublicfields())
   iif(cOPCAO=="I",EVENTOS->(qinitfields()),EVENTOS->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; EVENTOS->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. EVENTOS->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO REPRESENTANTE _____________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_eve with CONFIG->Cod_eve + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_eve,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      EVENTOS->(qreplacefields())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return


// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO" .and. cOPCAO == "I"

           if EVENTOS->(dbseek(fCODIGO))
              qmensa("Evento j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "CGM"

           if ! CGM->(dbseek(fCGM))
              qmensa("Cgm n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)

      case cCAMPO == "COD_PAV"

           if ! PAVILHAO->(dbseek(fCOD_PAV))
              qmensa("Pavilhao n„o encontrado !","B")
              return .F.
           endif

           fENDERECO := PAVILHAO->Endereco
           fCOMPL    := PAVILHAO->Compl
           fCGM      := PAVILHAO->Cgm
           fBAIRRO   := PAVILHAO->Bairro
           fCEP      := PAVILHAO->Cep

           qrsay(XNIVEL+1,PAVILHAO->Descricao)
           qrsay(XNIVEL+2,PAVILHAO->Endereco)
           qrsay(XNIVEL+3,PAVILHAO->Compl)
           qrsay(XNIVEL+4,PAVILHAO->Cgm)
           CGM->(dbseek(PAVILHAO->Cgm))
           qrsay(XNIVEL+5,CGM->Municipio)
           qrsay(XNIVEL+6,CGM->Estado)
           qrsay(XNIVEL+7,PAVILHAO->Bairro)
           qrsay(XNIVEL+8,PAVILHAO->Cep,"@R 99.999-999")





   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR REPRESENTANTE _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Evento ?")
      if EVENTOS->(qrlock())
         EVENTOS->(dbdelete())
         EVENTOS->(qunlock())
      else
         qm3()
      endif
   endif
return

