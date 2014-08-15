
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE FORMACAO PROFISSIONAL
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

// CARREGA BLOCO COMPLEMENTO INFERIOR DA TELA PARA VIEW

qlbloc(5,0,"B131C","QBLOC.GLO")

FUN->(qview({{"Matricula"         ,1},;
             {"left(Nome,30)/Nome",2},;
             {"Mat_Ass/Mat.Assoc.",3}},"05001579",;
             {"f133a",NIL,NIL,NIL},;
             NIL,"<ESC> / ALT-P / ALT-O / <ENTER> PARA FORMACOES"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO DEPENTENTE ________________________________________

function f133a
   PROF->(qview({{"Empresa"          ,1},;
                 {"Admissao/Admiss„o",0},;
                 {"Demissao/Demiss„o",0}},"15002379",;
                 {NIL,"f133b",NIL,NIL},;
                 {"PROF->Matricula==FUN->Matricula",{||top133()},{||bot133()}},;
                 q_msg_acesso_usr()))
return

function top133
   PROF->(dbseek(FUN->Matricula))
return

function bot133
   PROF->(qseekn(FUN->Matricula))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f133b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "I" .or. (cOPCAO $ "ACE" .and. PROF->Matricula == FUN->Matricula)
      if cOPCAO $ XUSRA
         qlbloc(5,0,"B133A","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
         i_edicao()
      endif
      if PROF->Matricula <> FUN->Matricula
         PROF->(dbseek(FUN->Matricula))
      endif
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||XNIVEL==3.and.(empty(fEMPRESA).or.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1
   qrsay ( XNIVEL++ , FUN->Matricula  )
   qrsay ( XNIVEL++ , left(FUN->Nome,30))
   if cOPCAO <> "I"
      qrsay ( XNIVEL++ , PROF->Empresa    )
      qrsay ( XNIVEL++ , PROF->Endereco   )
      qrsay ( XNIVEL++ , PROF->Bairro     )
      qrsay ( XNIVEL++ , PROF->Cgm_trab  ) ; CGM->(dbseek(PROF->Cgm_trab))
      qrsay ( XNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
      qrsay ( XNIVEL++ , PROF->Cep        )
      qrsay ( XNIVEL++ , PROF->DDD        )
      qrsay ( XNIVEL++ , PROF->Telefone   )
      qrsay ( XNIVEL++ , PROF->Admissao   )
      qrsay ( XNIVEL++ , PROF->Demissao   )
      C_TMP := PROF->Demissao - PROF->Admissao
      C_ANO := int ( C_TMP / 365.25 )
      C_TMP -= ( C_ANO * 365.25 )
      C_MES := int ( C_TMP / 30.41666 )
      C_TMP -= ( C_MES * 30.41666 )
      C_DIA := int ( C_TMP )
      qrsay ( XNIVEL++ , C_ANO , "99" )
      qrsay ( XNIVEL++ , C_MES , "99" )
      qrsay ( XNIVEL++ , C_DIA , "99" )
      qrsay ( XNIVEL++ , PROF->Atividade  )
      qrsay ( XNIVEL++ , PROF->Motivo     )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL },NIL}) // matricula do funcionario
   aadd(aEDICAO,{{ || NIL },NIL}) // nome      do funcionario
   aadd(aEDICAO,{{ || qgetx(-1,0,@fEMPRESA   ,"@!",NIL,.T.) },"EMPRESA" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fENDERECO  ,"@!",NIL,.T.) },"ENDERECO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO    ,"@!",NIL,.T.) },"BAIRRO"  })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_TRAB) }             ,"CGM_TRAB"})
   aadd(aEDICAO,{{ || NIL },NIL}) // municipio/uf da formacao profissional
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP       ,"@!",NIL,.T.) },"CEP"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDDD       ,"@!",NIL,.T.) },"DDD"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTELEFONE  ,"@!",NIL,.T.) },"TELEFONE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fADMISSAO  ,"@!",NIL,.T.) },"ADMISSAO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDEMISSAO  ,"@!",NIL,.T.) },"DEMISSAO"})
   aadd(aEDICAO,{{ || NIL },NIL}) // anos  trabalhados
   aadd(aEDICAO,{{ || NIL },NIL}) // meses trabalhados
   aadd(aEDICAO,{{ || NIL },NIL}) // dias  trabalhados
   aadd(aEDICAO,{{ || qgetx(-1,0,@fATIVIDADE ,"@!",NIL,.T.) },"ATIVIDADE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMOTIVO    ,"@!",NIL,.T.) },"MOTIVO"   })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PROF->(qpublicfields())
   iif(cOPCAO=="I",PROF->(qinitfields()),PROF->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PROF->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if PROF->(iif(cOPCAO=="I",qappend(),qrlock()))
      fMATRICULA := FUN->Matricula
      PROF->(qreplacefields())
      PROF->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   local nTMP, nANO, nMES, nDIA
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CGM_TRAB"
           if CGM->(dbseek(fCGM_TRAB))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
      case cCAMPO == "DEMISSAO"
           nTMP := fDEMISSAO - fADMISSAO
           nANO := int ( nTMP / 365.25 )
           nTMP -= ( nANO * 365.25 )
           nMES := int ( nTMP / 30.41666 )
           nTMP -= ( nMES * 30.41666 )
           nDIA := int ( nTMP )
           qrsay ( XNIVEL+1 , nANO , "99" )
           qrsay ( XNIVEL+2 , nMES , "99" )
           qrsay ( XNIVEL+3 , nDIA , "99" )
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR FORMACAO PROFISSIONAL ________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Forma‡„o Profissional ?")
      if PROF->(qrlock())
         PROF->(dbdelete())
         PROF->(qunlock())
      else
         qm3()
      endif
   endif
return

