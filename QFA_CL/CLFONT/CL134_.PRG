/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE SITUACAO TRIBUTARIA
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO 2010
// OBS........:
// ALTERACOES.:

function cl134
SUBSYS->(qview({{"Codigo/Codigo"         ,1},;
          {"Descricao/Descricao"          ,2}},"P",;
             {NIL,"c134a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c134a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B134A","QBLOC.GLO",1)
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
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or. Lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , SUBSYS->Codigo                     )
      qrsay ( XNIVEL++ , SUBSYS->Descricao                  )
      qrsay ( XNIVEL++ , SUBSYS->Cod_mot                    );MOTDEV->(dbseek(SUBSYS->Cod_mot))
      qrsay ( XNIVEL++ , MOTDEV->Descricao                  )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif


   endif
   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"99")        },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    ,"@!")        },"DESCRICAO" })
   aadd(aEDICAO,{{ || view_motdev(-1,0,@fCOD_MOT)             },"COD_MOT"   })
   aadd(aEDICAO,{{ || NIL                                     },NIL         })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   SUBSYS->(qpublicfields())
   iif(cOPCAO=="I",SUBSYS->(qinitfields()),SUBSYS->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; SUBSYS->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if SUBSYS->(iif(cOPCAO=="I",qappend(),qrlock()))
      SUBSYS->(qreplacefields())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   i_proc_item()


return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO"

           if cOPCAO == "I"
              if SUBSYS->(dbseek(fCODIGO))
                 qmensa("codigo ja utilizado!","BL")
                 return .F.
              endif
           endif

      case cCAMPO == "COD_MOT"

           if empty(fCOD_MOT)
              qmensa("Campo Obrigatorio!","BL")
              return .F.
           endif

           if ! empty(fCOD_MOT)
              fCOD_MOT:=strzero(val(fCOD_MOT),2)
           endif

           qrsay(XNIVEL,fCOD_MOT)

           if ! MOTDEV->(dbseek(fCOD_MOT))
              qmensa("Motivo de Devolucao n„o encontrado !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(MOTDEV->Descricao,30) )


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR TRANSPORTADORA _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Sub-Sistema ?")

      if DEFEITO->(Dbseek(SUBSYS->Codigo)).and. DEFEITO->(qflock())
         do while ! DEFEITO->(eof()) .and. DEFEITO->cod_subsys == SUBSYS->Codigo
            DEFEITO->(dbdelete())
            DEFEITO->(dbskip())
         enddo
      endif

      if SUBSYS->(qrlock())
         SUBSYS->(dbdelete())
         SUBSYS->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_proc_item


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

 DEFEITO->(qview({{"Codigo/Codigo"                                       ,3},;
                  {"Descricao/Descricao"                                 ,0}},;
                  "12002179S",;
                  {NIL,"f134d",NIL,NIL},;
                  {"DEFEITO->cod_subsys == SUBSYS->Codigo",{||f134top()},{||f134bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f134top
   DEFEITO->(dbsetorder(3))
   DEFEITO->(dbseek(SUBSYS->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f134bot
   DEFEITO->(dbsetorder(3))
   DEFEITO->(qseekn(SUBSYS->Codigo))
return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f134d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(05,08,"B134B","QBLOC.GLO",1)
      i_edicao_iten()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_edicao_iten

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}


   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , DEFEITO->Codigo                    )
      qrsay ( XNIVEL++ , DEFEITO->Descricao                 )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_cl() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO                          ) } ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO     ,"@!"             ) } ,"DESCRICAO"})


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   DEFEITO->(qpublicfields())

   iif(cOPCAO=="I",DEFEITO->(qinitfields()),DEFEITO->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 2
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; DEFEITO->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if SUBSYS->(qrlock()) .and. DEFEITO->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fCOD_SUBSYS := SUBSYS->Codigo
         fCOD_MOT    := SUBSYS->Cod_mot
      endif

      DEFEITO->(qreplacefields())
      DEFEITO->(qunlock())

   else
      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "CODIGO"
           qrsay(XNIVEL,fCODIGO)
           DEFEITO->(dbsetorder(1))

           if DEFEITO->(dbseek(fCODIGO))
              qmensa("Codigo ja cadastrado !","B")
              return .F.
           endif

   endcase

return .T.

static function i_exc_itens_cl

   if qconf("Confirma exclus„o do Defeito ?")

      if DEFEITO->(qrlock())
         DEFEITO->(dbdelete())
         DEFEITO->(qunlock())
      else
         qm3()
      endif
   endif

return

static function i_atu_lanc
setcolor("W/B")

 DEFEITO->(qview({{"Codigo/Codigo"                                       ,0},;
                  {"Descricao/Descri‡„o"                                 ,0}},;
                  "12002179S",;
                  {NIL,NIL,NIL,NIL},;
                  {"DEFEITO->Cod_subsys == SUBSYS->Codigo",{||f134top()},{||f134bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))
return



