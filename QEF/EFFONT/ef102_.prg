/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE CODIGOS FISCAIS
// ANALISTA...: LUIS ANTONIO
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MAIO DE 1994
// OBS........:
// ALTERACOES.:

function ef102

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE CODIGOS FISCAIS_____________________________________________

NATOP->(qview({{"Nat_Cod/C¢digo"     ,1} ,;
               {"Nat_Desc/Descri‡„o" ,2} ,;
               {"Tip_cont/T.P.O"     ,0}},"P",;
               {NIL,"i_102a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_102a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(9,10,"B102A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , NATOP->Nat_Cod  , "@R 9.99" )
      qrsay ( XNIVEL++ , NATOP->Nat_Desc             )
      qrsay ( XNIVEL++ , NATOP->Tip_cont             )
      qrsay ( XNIVEL++ , left(NATOP->Dado1,42)       )
      qrsay ( XNIVEL++ , left(NATOP->Dado2,42)       )
      qrsay ( XNIVEL++ , left(NATOP->Dado3,42)       )
      qrsay ( XNIVEL++ , left(NATOP->Dado4,42)       )
      qrsay ( XNIVEL++ , left(NATOP->Dado5,42)       )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ ||       qgetx(-1,0,@fNAT_COD   ,"@R 9.99",NIL,cOPCAO=="I") } ,"NAT_COD"   })
   aadd(aEDICAO,{{ ||       qgetx(-1,0,@fNAT_DESC  ,"@!"                     ) } ,"NAT_DESC"  })
   aadd(aEDICAO,{{ ||   view_tpo(-1,0,@fTIP_CONT  ,"@!"                      ) } ,"TIP_CONT"  })
   aadd(aEDICAO,{{ ||       qgetx(-1,0,@fDADO1    ,"@!@S42"                  ) } ,"DADO1"     })
   aadd(aEDICAO,{{ ||       qgetx(-1,0,@fDADO2    ,"@!@S42"                  ) } ,"DADO2"     })
   aadd(aEDICAO,{{ ||       qgetx(-1,0,@fDADO3    ,"@!@S42"                  ) } ,"DADO3"     })
   aadd(aEDICAO,{{ ||       qgetx(-1,0,@fDADO4    ,"@!@S42"                  ) } ,"DADO4"     })
   aadd(aEDICAO,{{ ||       qgetx(-1,0,@fDADO5    ,"@!@S42"                  ) } ,"DADO5"     })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   NATOP->(qpublicfields())

   iif(cOPCAO=="I",NATOP->(qinitfields()),NATOP->(qcopyfields()))

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; NATOP->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if NATOP->(iif(cOPCAO=="I",qappend(),qrlock()))
      NATOP->(qreplacefields())
      NATOP->(qunlock())
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
           if NATOP->(dbseek(fNAT_COD))
              qmensa("Codigo Fiscal j  cadastrado !","B")
              return .F.
           endif
      case cCAMPO == "TIP_CONT"
           if ! empty(fTIP_CONT)
             if right(TIPOCONT->Codigo,4) <> "    "
                if ! TIPOCONT->(dbseek(fTIP_CONT))
                     qmensa("Tipo Cont bil n„o encontrado...","B")
                     fTIP_CONT := space(6)
                     return .F.
                endif
             else
                qmensa("C¢digo n„o Valido, ou n„o encontrado...","B")
                fTIP_CONT := space(6)
                return .F.
             endif
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CODIGOS FISCAIS_______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o do Codigo Fiscal ?")
      if NATOP->(qrlock())
         NATOP->(dbdelete())
         NATOP->(qunlock())
      else
         qm3()
      endif
   endif

return
