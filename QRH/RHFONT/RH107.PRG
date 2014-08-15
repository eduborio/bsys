/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE SINDICATOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

SIND->(qview({{"Codigo/C¢digo"      ,1},;
              {"left(Descricao,30)/Descri‡„o",2}},"P",;
              {NIL,"c107a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c107a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(9,5,"B107A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , SIND->Codigo    )
      qrsay ( XNIVEL++ , left(SIND->Descricao,40))
      qrsay ( XNIVEL++ , SIND->Cnpj )
      qrsay ( XNIVEL++ , SIND->Cod_entid )
      qrsay ( XNIVEL++ , SIND->Contato   )
      qrsay ( XNIVEL++ , SIND->Piso      , "@E 9999999999.99" )
      qrsay ( XNIVEL++ , SIND->Endereco  )
      qrsay ( XNIVEL++ , SIND->Bairro    )
      qrsay ( XNIVEL++ , SIND->Cep       )
      qrsay ( XNIVEL++ , SIND->Cgm       ) ; CGM->(dbseek(SIND->Cgm))
      qrsay ( XNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
      qrsay ( XNIVEL++ , SIND->DDD       )
      qrsay ( XNIVEL++ , SIND->Telefone  )
      qrsay ( XNIVEL++ , SIND->Data_Base )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!",NIL,cOPCAO=="I") }         ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!S40",NIL,.T.    ) }         ,"DESCRICAO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCNPJ,"99.999.999/9999-99"     ) }         ,"CNPJ"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_ENTID,"999.999.99999-9"   ) }         ,"COD_ENTID"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO  ,"@!",NIL,.T.) },"CONTATO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPISO     ,"9999999999.99",NIL,.T.) },"PISO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fENDERECO ,"@!",NIL,.T.) },"ENDERECO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO   ,"@!",NIL,.T.) },"BAIRRO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP      ,"@!",NIL,.T.) },"CEP"      })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM) },"CGM"})
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao da municipio do sindicato
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDDD      ,"@!",NIL,.T.) },"DDD"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTELEFONE ,"@!",NIL,.T.) },"TELEFONE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_BASE,NIL ,NIL,.T.) },"DATA_BASE"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   SIND->(qpublicfields())
   iif(cOPCAO=="I",SIND->(qinitfields()),SIND->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; SIND->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if SIND->(iif(cOPCAO=="I",qappend(),qrlock()))
      SIND->(qreplacefields())
      SIND->(qunlock())
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
           if SIND->(dbseek(fCODIGO))
              qmensa("Sindicato j  cadastrado !","B")
              return .F.
           endif
      case cCAMPO == "CGM"
           if ! CGM->(dbseek(fCGM))
              qmensa("CGM n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,CGM->Municipio+"/"+CGM->Estado)
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR SINDICATO ____________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Sindicato ?")
      if SIND->(qrlock())
         SIND->(dbdelete())
         SIND->(qunlock())
      else
         qm3()
      endif
   endif
return

