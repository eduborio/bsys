 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: MANUTENCAO DE BANCO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function ts101

PLAN->(Dbsetorder(3))

BANCO->(qview({{"Codigo/C¢digo"                          ,0},;
               {"Banco/Banco"                            ,1},;
               {"left(Descricao,20)/Nome"                ,2},;
               {"c101b()/Nr. Conta"                      ,0},;
               {"Agencia/Agˆncia"                        ,0},;
               {"Telefone/Telefone"                      ,0},;
               {"Gerente/Gerente"                        ,0}},"P",;
               {NIL,"c101a",NIL,NIL},;
                NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c101a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(9,4,"B101A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETRNAR A MASCARA DA CONTA ___________________________________

function c101b
return transform(BANCO->Conta,"@R 999999999-99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fDESCRICAO).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDESCRICAO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , BANCO->Codigo     )
      qrsay ( XNIVEL++ , BANCO->Descricao  )
      qrsay ( XNIVEL++ , BANCO->Banco      )
      qrsay ( XNIVEL++ , BANCO->Agencia    )
      qrsay ( XNIVEL++ , transform(BANCO->Conta,"@R 999999999-99"))
      qrsay ( XNIVEL++ , BANCO->End_agenc  )
      qrsay ( XNIVEL++ , BANCO->Cod_cgm    ) ; CGM->(Dbseek(BANCO->Cod_cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,48))
      qrsay ( XNIVEL++ , BANCO->CEP        )
      qrsay ( XNIVEL++ , BANCO->Telefone   )
      qrsay ( XNIVEL++ , transform(BANCO->Conta_cont, "@R 99999-9")) ; PLAN->(Dbseek(BANCO->Conta_cont))
      qrsay ( XNIVEL++ , left(PLAN->Descricao,39))
      qrsay ( XNIVEL++ , BANCO->Filial     ) ; FILIAL->(Dbseek(BANCO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,36))
      qrsay ( XNIVEL++ , BANCO->Gerente    )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"@!")                    },"CODIGO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    ,"@!")                    },"DESCRICAO"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBANCO        ,"@!")                    },"BANCO"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fAGENCIA      ,"@!")                    },"AGENCIA"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTA        ,"@R 999999999-99")       },"CONTA"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_AGENC    ,"@!")                    },"END_AGENC"  })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCOD_CGM)                            },"COD_CGM"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP          ,"99999-999")             },"CEP"        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTELEFONE     ,"@!")                    },"TELEFONE"   })
   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONT)                        },"CONTA_CONT" })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"     })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fGERENTE      ,"@!")                    },"GERENTE"    })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   BANCO->(qpublicfields())
   iif(cOPCAO=="I",BANCO->(qinitfields()),BANCO->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; BANCO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if BANCO->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DO BANCO ____________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_banco with CONFIG->Cod_banco+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_banco,5),"B")
         fCODIGO := strzero(CONFIG->Cod_banco,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      BANCO->(qreplacefields())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "BANCO"

           if empty(fBANCO) ; return .F. ; endif

      case cCAMPO == "AGENCIA"

           if empty(fAGENCIA) ; return .F. ; endif

      case cCAMPO == "COD_CGM"

           if empty(fCOD_CGM) ; return .F. ; endif

           if  ! CGM->(dbseek(fCOD_CGM))
               qmensa("Munic¡pio n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(CGM->Municipio,48))

      case cCAMPO == "CONTA_CONT"

           if ! empty(fCONTA_CONT)
              if  ! PLAN->(dbseek(fCONTA_CONT))
                  qmensa("Conta Cont bil n„o Encontrada !","B")
                  return .F.
              endif

              qrsay(XNIVEL+1,left(PLAN->Descricao,39))
           endif

      case cCAMPO == "FILIAL"

           if ! empty(fFILIAL)
              if  ! FILIAL->(dbseek(fFILIAL))
                  qmensa("Filial n„o Encontrada !","B")
                  return .F.
              endif

              qrsay(XNIVEL+1,left(FILIAL->Razao,36))
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR BANCO ________________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Banco ?")
      if BANCO->(qrlock())
         BANCO->(dbdelete())
         BANCO->(qunlock())
      else
         qm3()
      endif
   endif
return
