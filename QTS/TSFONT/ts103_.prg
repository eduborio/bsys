 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: MANUTENCAO DE BANCO
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: JULHO DE 2006
// OBS........:
// ALTERACOES.:
function ts103

PLAN->(Dbsetorder(3))

INSTITU->(qview({{"Codigo/C¢digo"                          ,1},;
               {"left(Nome,30)/Nome"                ,2},;
               {"Telefone/Telefone"                      ,0},;
               {"Gerente/Gerente"                        ,0}},"P",;
               {NIL,"c103a",NIL,NIL},;
                NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c103a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(9,4,"B103A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETRNAR A MASCARA DA CONTA ___________________________________

function c103b
return transform(INSTITU->Conta,"@R 999999999-99")

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
      qrsay ( XNIVEL++ , INSTITU->Codigo     )
      qrsay ( XNIVEL++ , INSTITU->Nome       )
      qrsay ( XNIVEL++ , INSTITU->Telefone   )
      qrsay ( XNIVEL++ , transform(INSTITU->Conta_cont, "@R 99999-9")) ; PLAN->(Dbseek(INSTITU->Conta_cont))
      qrsay ( XNIVEL++ , left(PLAN->Descricao,39))
      qrsay ( XNIVEL++ , INSTITU->Filial     ) ; FILIAL->(Dbseek(INSTITU->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,36))
      qrsay ( XNIVEL++ , INSTITU->Gerente    )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"@!")                    },"CODIGO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOME         ,"@!")                    },"NOME"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTELEFONE     ,"@!")                    },"TELEFONE"   })
   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONT)                        },"CONTA_CONT" })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"     })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fGERENTE      ,"@!")                    },"GERENTE"    })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   INSTITU->(qpublicfields())
   iif(cOPCAO=="I",INSTITU->(qinitfields()),INSTITU->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; INSTITU->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if INSTITU->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DO BANCO ____________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_inst with CONFIG->Cod_inst+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_inst,5),"B")
         fCODIGO := strzero(CONFIG->Cod_inst,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      INSTITU->(qreplacefields())

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
   if qconf("Confirma exclus„o desta Institui‡Æo Financeira ?")
      if INSTITU->(qrlock())
         INSTITU->(dbdelete())
         INSTITU->(qunlock())
      else
         qm3()
      endif
   endif
return
