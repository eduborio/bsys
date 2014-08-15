
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE UNIDADES
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function cp105

UNIDADE->(qview({{"Codigo/C¢digo"             ,1},;
                 {"Sigla/Sigla"               ,2},;
                 {"Descricao/Descri‡„o"       ,3},;
                 {"Fator/Fator"               ,0},;
                 {"c105b()/Sigla"             ,0}},"P",;
                 {NIL,"c105a",NIL,NIL            },;
                  NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR A EMPRESA CENTRALIZADA NO VIEW ______________________

function c105b
   local nREC := UNIDADE->(recno())
   local cDESCRICAO

   UNIDADE->(dbseek(UNIDADE->Cod_uni))
   cDESCRICAO := UNIDADE->Sigla
   UNIDADE->(dbgoto(nREC))

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c105a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(08,22,"B105A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF   := .F.
   local cNome
   local aEDICAO := {}
   local bESCAPE := {||empty(fSIGLA).or.(XNIVEL==2.and.!XFLAG).or.!empty(fSIGLA).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}
   local nREC

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , UNIDADE->Codigo     )
      qrsay ( XNIVEL++ , UNIDADE->Sigla      )
      qrsay ( XNIVEL++ , UNIDADE->Descricao  )
      qrsay ( XNIVEL++ , transform(UNIDADE->Fator,"@E 999,999") )
      qrsay ( XNIVEL++ , UNIDADE->Cod_uni    )

      nREC := UNIDADE->(recno())
      UNIDADE->(dbseek(UNIDADE->Cod_uni))
      qrsay ( XNIVEL++ , UNIDADE->Sigla      )
      UNIDADE->(dbgoto(nREC))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                               },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSIGLA,"@!")          },"SIGLA"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFATOR,"@E 999,999")  },"FATOR"     })
   aadd(aEDICAO,{{ || view_uni(-1,0,@fCOD_UNI)          },"COD_UNI"   })
   aadd(aEDICAO,{{ || NIL                               },NIL         })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   UNIDADE->(qpublicfields())
   iif(cOPCAO=="I",UNIDADE->(qinitfields()),UNIDADE->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   if cOPCAO == "I"
      fFATOR := 1
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; UNIDADE->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

     // AGORA INCREMENTA CODIGO DO COMPRADOR ________________________________

   if CONFIG->(qrlock()) .and. UNIDADE->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         replace CONFIG->Cod_uni with CONFIG->Cod_uni + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_uni,3) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      UNIDADE->(qreplacefields())
      UNIDADE->(dbgotop())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREC

   if ! XFLAG ; return .T. ; endif

   qmensa()

   do case

      case cCAMPO == "SIGLA"
           if empty(fSIGLA) ; return .F. ; endif

      case cCAMPO == "DESCRICAO"
           if empty(fDESCRICAO) ; return .F. ; endif

      case cCAMPO == "FATOR"
           if fFATOR <= 0 ; return .F. ; endif

      case cCAMPO == "COD_UNI"

           if ! empty(fCOD_UNI)
              qrsay(XNIVEL,fCOD_UNI:=strzero(val(fCOD_UNI),3))
              nREC := UNIDADE->(recno())

              if ! UNIDADE->(dbseek(fCOD_UNI))
                 qmensa("Unidade n„o Cadastrado !","B")
                 UNIDADE->(dbgoto(nREC))
                 return .F.
              endif

              qrsay(XNIVEL+1,UNIDADE->Sigla)
              UNIDADE->(dbgoto(nREC))
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR COMPRADOR ____________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Comprador ?")
      if UNIDADE->(qrlock())
         UNIDADE->(dbdelete())
         UNIDADE->(qunlock())
      else
         qm3()
      endif
   endif
return

