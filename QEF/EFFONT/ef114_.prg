/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE CODIGOS FISCAIS
// ANALISTA...: LUIS ANTONIO
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MAIO DE 1994
// OBS........:
// ALTERACOES.:
function ef114

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE CODIGOS FISCAIS_____________________________________________

CFOP->(qview({{"Nat_Cod/C¢digo"     ,1} ,;
               {"Nat_Desc/Descri‡„o" ,2}},"P",;
               {NIL,"i_114a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_114a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(9,10,"B114A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fNAT_COD).or.(XNIVEL==1.and.!XFLAG).or.!empty(fNAT_COD).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , CFOP->Nat_Cod  , "@R 9.999" )
      qrsay ( XNIVEL++ , CFOP->Nat_Desc             )

      qrsay ( XNIVEL++ , CFOP->Tipo_cont            ) ;TIPOCONT->(dbseek(CFOP->Tipo_cont))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,30)           )


   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ ||       qgetx(-1,0,@fNAT_COD   ,"@R 9.999",NIL,cOPCAO=="I") } ,"NAT_COD"   })
   aadd(aEDICAO,{{ ||       qgetx(-1,0,@fNAT_DESC  ,"@!"                     ) } ,"NAT_DESC"  })

   aadd(aEDICAO,{{ || view_tpo(-1,0,@fTIPO_CONT                     ) } ,"TIPO_CONT" })
   aadd(aEDICAO,{{ || NIL                                             } ,NIL         })



   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CFOP->(qpublicfields())

   iif(cOPCAO=="I",CFOP->(qinitfields()),CFOP->(qcopyfields()))

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CFOP->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CFOP->(iif(cOPCAO=="I",qappend(),qrlock()))
      CFOP->(qreplacefields())
      CFOP->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )


   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "NAT_COD" .and. cOPCAO == "I"
           if CFOP->(dbseek(fNAT_COD))
              qmensa("Codigo Fiscal j  cadastrado !","B")
              return .F.
           endif


      case cCAMPO == "TIPO_CONT"
           if empty(fTIPO_CONT); return .T.; endif
           if ! TIPOCONT->(dbseek(fTIPO_CONT))
               qmensa("C¢digo do T.P.O n„o Encontrado...!","B")
               Return .F.
           else
               qrsay(XNIVEL+1,left(TIPOCONT->Descricao,30))
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CODIGOS FISCAIS_______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o do Codigo Fiscal ?")
      if CFOP->(qrlock())
         CFOP->(dbdelete())
         CFOP->(qunlock())
      else
         qm3()
      endif
   endif

return
