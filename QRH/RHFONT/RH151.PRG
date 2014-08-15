
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE TIPOS DE AFASTAMENTOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

AFAST->(qview({{"Codigo/C¢digo"      ,1},;
               {"Descricao/Descri‡„o",2},;
               {"Formula/F¢rmula"    ,0},;
               {"Kit"                ,0}},"P",;
               {NIL,"c151a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c151a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,6,"B151A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fCODIGO) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , AFAST->Codigo    )
      qrsay ( XNIVEL++ , AFAST->Descricao )
      qrsay ( XNIVEL++ , AFAST->Formula   ) ; FORM->(dbseek(AFAST->Formula))
      qrsay ( XNIVEL++ , FORM->Descricao )
      qrsay ( XNIVEL++ , AFAST->Kit       ) ; KIT->(dbseek(AFAST->Kit))
      qrsay ( XNIVEL++ , KIT->Descricao )
      qrsay ( XNIVEL++ , qabrev(AFAST->Retorno,"SN",{"Sim","N„o"}) )
      qrsay ( XNIVEL++ , AFAST->Cod_rais  )
      qrsay ( XNIVEL++ , AFAST->Cod_re    )
      qrsay ( XNIVEL++ , AFAST->Cod_caged )
      qrsay ( XNIVEL++ , AFAST->Cod_retorn)
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!",NIL,cOPCAO=="I"  )} ,"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!"     ,NIL,.T.     )} ,"DESCRICAO" })
   aadd(aEDICAO,{{ || view_form(-1,0,@fFORMULA                     )} ,"FORMULA"   })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL         }) // descricao da formula
   aadd(aEDICAO,{{ || view_kit(-1,0,@fKIT                          )} ,"KIT"       })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL         }) // descricao do kit de inclusao
   aadd(aEDICAO,{{ || qesco(-1,0,@fRETORNO,XSN                     )} ,"RETORNO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_RAIS ,"99"     ,NIL,.T.     )} ,"COD_RAIS"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_RE   ,"@X!"    ,NIL,.T.     )} ,"COD_RE"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_CAGED,"99"     ,NIL,.T.     )} ,"COD_CAGED" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_RETORN,"@X!"   ,NIL,.T.     )} ,"COD_RETORN"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   AFAST->(qpublicfields())
   iif(cOPCAO=="I",AFAST->(qinitfields()),AFAST->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; AFAST->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if AFAST->(iif(cOPCAO=="I",qappend(),qrlock()))
      AFAST->(qreplacefields())
      AFAST->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           if AFAST->(dbseek(fCODIGO))
              qmensa("Afastamento j  cadastrado !","B")
              return .F.
           endif
      case cCAMPO == "FORMULA"
           if FORM->(dbseek(fFORMULA))
              qrsay ( XNIVEL+1 , FORM->Descricao )
           else
              qmensa("F¢rmula n„o encontrada !","B")
              return .F.
           endif
      case cCAMPO == "KIT"
           if KIT->(dbseek(fKIT))
              qrsay ( XNIVEL+1 , KIT->Descricao )
           else
              qmensa("Kit n„o encontrado !","B")
              return .F.
           endif
      case cCAMPO == "RETORNO"
           qrsay ( XNIVEL , qabrev(fRETORNO,"SN",{"Sim","N„o"}) )
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR AFASTAMENTO __________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Afastamento ?")
      if AFAST->(qrlock())
         AFAST->(dbdelete())
         AFAST->(qunlock())
      else
         qm3()
      endif
   endif
return

