/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE FORNECEDORES
// ANALISTA...: LUIS ANTONIO
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MAIO DE 1994
// OBS........:
// ALTERACOES.:

function ef101

PLAN->(dbsetorder(3)) // codigo reduzido

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE FORNECEDORES _______________________________________________

FORN->(qview({{"Codigo/C¢digo",1},;
              {"Razao/Raz„o"  ,2}},"P",;
              {NIL,"i_101a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_101a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(6,2,"B101A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , FORN->Codigo   )
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , left(FORN->End_ent,40))
      qrsay ( XNIVEL++ , FORN->Cep_ent ,"@R 99999-999")
      qrsay ( XNIVEL++ , FORN->Cgm_ent ) ; CGM->(dbseek(FORN->Cgm_ent))
      qrsay ( XNIVEL++ , left(CGM->Municipio,15)+"/"+CGM->Estado )
      qrsay ( XNIVEL++ , FORN->Fone1    )
      qrsay ( XNIVEL++ , FORN->Fax      )
      qrsay ( XNIVEL++ , FORN->Cgccpf   ,"@R 99.999.999/9999-99")
      qrsay ( XNIVEL++ , FORN->Inscricao)
      qrsay ( XNIVEL++ , transform(FORN->Conta_cont,"@R 99999-9")) ; PLAN->(dbseek(FORN->Conta_cont))
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
         qlbloc(6,2,"B101A","QBLOC.GLO",1)
      endif

      FORN->(qpublicfields())

      iif(cOPCAO=="I",FORN->(qinitfields()),FORN->(qcopyfields()))

      XNIVEL := 2
      XFLAG  := .T.

      // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; FORN->(qreleasefields()) ; return ; endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif
      Area:=Select()
      if ! quse( XDRV_CP ,"CONFIG",NIL,NIL,NIL)
         qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
         return
      else
         if FORN->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())
            if cOPCAO == "I"
               replace CONFIG->Cod_forn with CONFIG->Cod_forn + 1
               qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_forn,5) )
               qmensa("C¢digo Gerado: "+fCODIGO,"B")
               CONFIG->(qunlock())
               CONFIG->(dbclosearea())
               Select(Area)
            endif
            FORN->(qreplacefields())
            FORN->(qunlock())
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
              if FORN->(dbseek(fCODIGO))
                 qmensa("Fornecedor j  cadastrado !","B")
                 return .F.
              endif
         case cCAMPO == "CGM_ENT"
              if ! CGM->(dbseek(fCGM_ENT))
                 qmensa("Municipio n„o encontrado !","B")
                 return .F.
              endif
              qrsay ( XNIVEL+1 , left(CGM->Municipio,15) + "/" + CGM->Estado )
         case cCAMPO == "CGCCPF" .and. cOPCAO == "I"
              FORN->(dbsetorder(3))
              if FORN->(dbseek(fCGCCPF))
                 qmensa("C.N.P.J. j  cadastrado !","B")
                 FORN->(dbsetorder(1))
                 return .F.
              endif
              FORN->(dbsetorder(1))
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
// FUNCAO PARA EXCLUIR FORNECEDORES _________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste fornecedor ?")
      if FORN->(qrlock())
         FORN->(dbdelete())
         FORN->(qunlock())
      else
         qm3()
      endif
   endif

return
