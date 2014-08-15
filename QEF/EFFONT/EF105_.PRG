/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE ALIQUOTAS DE ICMS POR ESTADOS
// ANALISTA...: LUIS ANTONIO
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........:
// ALTERACOES.:
function ef105

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE ALIQUOTAS DE ICMS POR ESTADO________________________________

ESTADO->(qview({{"Est_Sig/Sigla"       ,1} ,;
              {"Est_Desc/Descri‡„o"    ,2},;
              {"ALiq_Orig/Aliq.Origem" ,0},;
              {"Aliq_Dest/Aliq.Destino",0},;
              {"Aliq_inter/Aliq.Interna",0}},"P",;
              {NIL,"i_105a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_105a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(9,8,"B105A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fEST_SIG).or.(XNIVEL==1.and.!XFLAG).or.!empty(fEST_SIG).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ESTADO->Est_Sig     , "@!"         )
      qrsay ( XNIVEL++ , ESTADO->Est_Desc    , "@!"         )
      qrsay ( XNIVEL++ , ESTADO->Aliq_Orig   , "@R 99.99"   )
      qrsay ( XNIVEL++ , ESTADO->Aliq_Dest   , "@R 99.99"   )
      qrsay ( XNIVEL++ , ESTADO->Aliq_inter  , "@R 99.99"   )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEST_SIG  , "@!", NIL,cOPCAO=="I" ) } ,"EST_SIG"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fEST_DESC , "@!"                  ) } ,"EST_DESC"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_ORIG, "@R 99.99"            ) } ,"ALIQ_ORIG" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_DEST, "@R 99.99"            ) } ,"ALIQ_DEST" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_INTER, "@R 99.99"            ) } ,"ALIQ_INTER" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ESTADO->(qpublicfields())

   iif(cOPCAO=="I",ESTADO->(qinitfields()),ESTADO->(qcopyfields()))

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ESTADO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if ESTADO->(iif(cOPCAO=="I",qappend(),qrlock()))
      ESTADO->(qreplacefields())
      ESTADO->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "EST_SIG" .and. cOPCAO == "I"
           if ESTADO->(dbseek(fEST_SIG))
              qmensa("Estado j  cadastrado !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ESTADO DA FEDERACAO___________________________________

static function i_exclusao

   if qconf("Confirma exclus„o do Estado ?")
      if ESTADO->(qrlock())
         ESTADO->(dbdelete())
         ESTADO->(qunlock())
      else
         qm3()
      endif
   endif

return
