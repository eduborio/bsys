
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE CADASTRO DISCIPLINAR
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
             {"f134a",NIL,NIL,NIL},;
             NIL,"<ESC> / ALT-P / ALT-O / <ENTER> PARA DISCIPLINAS"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO DEPENTENTE ________________________________________

function f134a
   DISC->(qview({{"Descricao/Descri‡„o"  ,1},;
                 {"Data_ocorr/Data Ocor.",0},;
                 {"Hora_ocorr/Hora Ocor.",0}},"15002379",;
                 {NIL,"f134b",NIL,NIL},;
                 {"DISC->Matricula==FUN->Matricula",{||top134()},{||bot134()}},;
                 q_msg_acesso_usr()))
return

function top134
   DISC->(dbseek(FUN->Matricula))
return

function bot134
   DISC->(qseekn(FUN->Matricula))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f134b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "I" .or. (cOPCAO $ "ACE" .and. DISC->Matricula == FUN->Matricula)
      if cOPCAO $ XUSRA
         qlbloc(8,7,"B134A","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
         i_edicao()
      endif
      if DISC->Matricula <> FUN->Matricula
         DISC->(dbseek(FUN->Matricula))
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
   qrsay ( XNIVEL++ , left(FUN->Nome,30)       )
   if cOPCAO <> "I"
      qrsay ( XNIVEL++ , DISC->Descricao  )
      qrsay ( XNIVEL++ , DISC->Data_Ocorr )
      qrsay ( XNIVEL++ , DISC->Hora_Ocorr )
      i_mostra_memo()
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL },NIL}) // matricula do funcionario
   aadd(aEDICAO,{{ || NIL },NIL}) // nome      do funcionario
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO ,"@!") },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_OCORR,NIL) },"DATA_OCORR"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHORA_OCORR,"99:99") },"HORA_OCORR"})
   aadd(aEDICAO,{{ || fTEXTO := i_edita_memo() },"TEXTO"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   DISC->(qpublicfields())
   iif(cOPCAO=="I",DISC->(qinitfields()),DISC->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; DISC->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if DISC->(iif(cOPCAO=="I",qappend(),qrlock()))
      fMATRICULA := FUN->Matricula
      DISC->(qreplacefields())
      DISC->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CADASTRO DISCIPLINAR _________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Cadastro Disciplinar ?")
      if DISC->(qrlock())
         DISC->(dbdelete())
         DISC->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRA CAMPO MEMO ____________________________________________

function i_mostra_memo
   keyboard chr(27)
   memoedit ( DISC->Texto , 15 , 09 , 20 , 70 , .T. )
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EDITAR MEMO __________________________________________________

function i_edita_memo
   local cMEMO := iif ( cOPCAO == "I" , "" , DISC->Texto )
   qmensa("CRTL-W para sair da edi‡„o !")
return ( memoedit ( cMEMO , 15 , 09 , 20 , 70 , .T. ) )

