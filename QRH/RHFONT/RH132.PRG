
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE FORMACAO ACADEMICA
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
             {"f132a",NIL,NIL,NIL},;
             NIL,"<ESC> / ALT-P / ALT-O / <ENTER> PARA FORMACOES"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO DEPENTENTE ________________________________________

function f132a
   ACAD->(qview({{"Descricao/Descri‡„o"  ,1},;
                 {"Data_forma/Data Form.",0}},"15002379",;
                 {NIL,"f132b",NIL,NIL},;
                 {"ACAD->Matricula==FUN->Matricula",{||top132()},{||bot132()}},;
                 q_msg_acesso_usr()))
return

function top132
   ACAD->(dbseek(FUN->Matricula))
return

function bot132
   ACAD->(qseekn(FUN->Matricula))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f132b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "I" .or. (cOPCAO $ "ACE" .and. ACAD->Matricula == FUN->Matricula)
      if cOPCAO $ XUSRA
         qlbloc(10,7,"B132A","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
         i_edicao()
      endif
      if ACAD->Matricula <> FUN->Matricula
         ACAD->(dbseek(FUN->Matricula))
      endif
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||XNIVEL==3.and.(empty(fDESCRICAO).or.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1
   qrsay ( XNIVEL++ , FUN->Matricula  )
   qrsay ( XNIVEL++ , left(FUN->Nome,30))
   if cOPCAO <> "I"
      qrsay ( XNIVEL++ , ACAD->Descricao  )
      qrsay ( XNIVEL++ , ACAD->Escola     )
      qrsay ( XNIVEL++ , ACAD->Cgm_forma  ) ; CGM->(dbseek(ACAD->Cgm_forma))
      qrsay ( XNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
      qrsay ( XNIVEL++ , ACAD->Obs        )
      qrsay ( XNIVEL++ , ACAD->Data_Forma )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL },NIL}) // matricula do funcionario
   aadd(aEDICAO,{{ || NIL },NIL}) // nome      do funcionario
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO ,"@!",NIL,.T.) },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fESCOLA    ,"@!",NIL,.T.) },"ESCOLA"    })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_FORMA) }           ,"CGM_FORMA" })
   aadd(aEDICAO,{{ || NIL },NIL}) // municipio/uf de formacao
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS       ,"@!",NIL,.T.) },"OBS"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_FORMA,"@!",NIL,.T.) },"DATA_FORMA"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ACAD->(qpublicfields())
   iif(cOPCAO=="I",ACAD->(qinitfields()),ACAD->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ACAD->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if ACAD->(iif(cOPCAO=="I",qappend(),qrlock()))
      fMATRICULA := FUN->Matricula
      ACAD->(qreplacefields())
      ACAD->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CGM_FORMA"
           if CGM->(dbseek(fCGM_FORMA))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR FORMACAO ACADEMICA ___________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Forma‡„o Acadˆmica ?")
      if ACAD->(qrlock())
         ACAD->(dbdelete())
         ACAD->(qunlock())
      else
         qm3()
      endif
   endif
return

