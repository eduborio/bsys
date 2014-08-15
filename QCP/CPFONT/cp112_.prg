/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE REPRESENTANTE COMERCIAL
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: JULHO DE 2006
// OBS........:
// ALTERACOES.:

function cp112

PROJET->(qview({{"Codigo/C¢digo"              ,1},;
              {"left(Descricao,47)/Descricao" ,2}},"P",;
              {NIL,"c112a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c112a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(6,0,"B112A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fDescricao).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDescricao).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PROJET->Codigo    )
      qrsay ( XNIVEL++ , PROJET->Descricao )
      qrsay ( XNIVEL++ , PROJET->Previsao,"@E 99,999,999.99"   )
      qrsay ( XNIVEL++ , PROJET->Cod_Cli ) ; CLI1->(dbseek(PROJET->Cod_Cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40) )
      qrsay ( XNIVEL++ , PROJET->Cod_fun  ); FUN->(Dbseek(PROJET->Cod_fun))
      qrsay ( XNIVEL++ , left(FUN->Nome,40))
      qrsay ( XNIVEL++ , PROJET->Cod_eve ) ; EVENTOS->(dbseek(PROJET->Cod_eve))
      qrsay ( XNIVEL++ , left(EVENTOS->Nome,40) )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDescricao        ,"@!"   ,"!empty(@)",.T.)  },"DESCRICAO"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPREVISAO       ,"@E 99,999,999.99")         },"PREVISAO"   })
   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_CLI)                            },"COD_CLI"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_fun(-1,0,@fCOD_FUN)                            },"COD_FUN"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_eve(-1,0,@fCOD_EVE)                            },"COD_EVE"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PROJET->(qpublicfields())
   iif(cOPCAO=="I",PROJET->(qinitfields()),PROJET->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PROJET->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. PROJET->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO REPRESENTANTE _____________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_proj with CONFIG->Cod_proj + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_proj,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      PROJET->(qreplacefields())

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

           if PROJET->(dbseek(fCODIGO))
              qmensa("Evento j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "COD_CLI"

           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(CLI1->Razao,40))

      case cCAMPO == "COD_FUN"

           if ! FUN->(dbseek(fCOD_FUN))
              qmensa("Funcionario n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FUN->Nome,40))

      case cCAMPO == "COD_EVE"

           if ! EVENTOS->(dbseek(fCOD_EVE))
              qmensa("Evento n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(EVENTOS->Nome,40))




   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR REPRESENTANTE _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Projeto ?")
      if PROJET->(qrlock())
         PROJET->(dbdelete())
         PROJET->(qunlock())
      else
         qm3()
      endif
   endif
return

