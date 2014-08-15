/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE CLIENTES
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JULHO DE 2001
// OBS........:
// ALTERACOES.:
function ef113

PLAN->(dbsetorder(3)) // codigo reduzido

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE FORNECEDORES _______________________________________________

CLI1->(qview({{"Codigo/C¢digo",1},;
              {"Razao/Raz„o"  ,2}},"P",;
              {NIL,"i_113a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_113a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(6,2,"B113A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fRAZAO).or.(XNIVEL==2.and.!XFLAG).or.!empty(fRAZAO).and.lastkey()==27.or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , CLI1->Codigo   )
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))
      qrsay ( XNIVEL++ , left(CLI1->End_ent,40))
      qrsay ( XNIVEL++ , CLI1->Cep_ent ,"@R 99999-999")
      qrsay ( XNIVEL++ , CLI1->Cgm_ent ) ; CGM->(dbseek(CLI1->Cgm_ent))
      qrsay ( XNIVEL++ , left(CGM->Municipio,15)+"/"+CGM->Estado )
      qrsay ( XNIVEL++ , CLI1->Fone1    )
      qrsay ( XNIVEL++ , CLI1->Fax      )
      qrsay ( XNIVEL++ , CLI1->Cgccpf   ,"@R 99.999.999/9999-99")
      qrsay ( XNIVEL++ , CLI1->Inscricao)
      qrsay ( XNIVEL++ , transform(CLI1->Conta_cont,"@R 99999-9")) ; PLAN->(dbseek(CLI1->Conta_cont))
      qrsay ( XNIVEL++ , PLAN->Descricao )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________
// aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!",NIL,cOPCAO=="I") } ,"CODIGO"   })
   aadd(aEDICAO,{{ || NIL                          }                 ,NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO    ,"@!") }                 ,"RAZAO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_ENT ,"@!") }                 ,"END_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_ENT ,"@R 99999-999") }       ,"CEP_ENT"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT      ) }              ,"CGM_ENT"   })
   aadd(aEDICAO,{{ || NIL                          }                 ,NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1    ,"@9") }                 ,"FONE1"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX      ,"@9") }                 ,"FAX"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF   ,"@R 99.999.999/9999-99") } ,"CGCCPF"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO,"@!") }                 ,"INSCRICAO"})
   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONT ,"@R 99999-9")    },"CONTA_CONT"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   do while .T.

      if cOPCAO == "I"
         qlbloc(6,2,"B113A","QBLOC.GLO",1)
      endif

      CLI1->(qpublicfields())

      iif(cOPCAO=="I",CLI1->(qinitfields()),CLI1->(qcopyfields()))

      XNIVEL := 2
      XFLAG  := .T.

      // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; CLI1->(qreleasefields()) ; return ; endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif
      Area:=Select()
      if ! quse( XDRV_EF ,"CONFIG",NIL,NIL,NIL)
         qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
         return
      else
         if CLI1->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())
            if cOPCAO == "I"
               replace CONFIG->Cod_cli with CONFIG->Cod_cli + 1
               qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_cli,5) )
               qmensa("C¢digo Gerado: "+fCODIGO,"B")
               CONFIG->(qunlock())
               CONFIG->(dbclosearea())
               Select(Area)
            endif
            CLI1->(qreplacefields())
            CLI1->(qunlock())
         else
            CONFIG->(qunlock())
            CONFIG->(dbclosearea())
            iif(cOPCAO=="I",qm1(),qm2())
         endif
      Endif

      if cOPCAO == "A"
         exit
      endif

   enddo
   Select(Area)
return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   if XFLAG
      do case
         case cCAMPO == "CODIGO" .and. cOPCAO == "I"
              qrsay(XNIVEL,fCODIGO:=strzero(val(fCODIGO),5))
              if CLI1->(dbseek(fCODIGO))
                 qmensa("Cliente j  cadastrado !","B")
                 return .F.
              endif
         case cCAMPO == "CGM_ENT"
              if ! CGM->(dbseek(fCGM_ENT))
                 qmensa("Municipio n„o encontrado !","B")
                 return .F.
              endif
              qrsay ( XNIVEL+1 , left(CGM->Municipio,15) + "/" + CGM->Estado )
         case cCAMPO == "CGCCPF" .and. cOPCAO == "I"
              CLI1->(dbsetorder(3))
              if CLI1->(dbseek(fCGCCPF))
                 qmensa("C.N.P.J j  cadastrado !","B")
                 CLI1->(dbsetorder(1))
                 return .F.
              endif
              CLI1->(dbsetorder(1))
      case cCAMPO == "CONTA_CONT"
           PLAN->(dbsetorder(3)) // codigo reduzido
           if ! empty(fCONTA_CONT)
              if ! PLAN->(dbseek(fCONTA_CONT))
                 qmensa("C¢digo da Conta Cont bil n„o encontrada !","B")
                 fCONTA_CONT := space(7)
                 return .F.
              else
                 qrsay(XNIVEL,fCONTA_CONT:=PLAN->Reduzido,"@R 99999-9")
                 qrsay(XNIVEL+1,left(PLAN->Descricao,38))
                 return .T.
              endif
           endif

      endcase

   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CLIENTES _________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Cliente ?")
      if CLI1->(qrlock())
         CLI1->(dbdelete())
         CLI1->(qunlock())
      else
         qm3()
      endif
   endif

return
