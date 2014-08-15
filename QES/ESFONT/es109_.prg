/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: MANUTENCAO DE COLABORADOS
// ANALISTA...: LUCIANO DA SILVA GORSKI
// PROGRAMADOR: LUCIANO DA SILVA GORSKI
// INICIO.....: MARCO DE 1999
// OBS........:
// ALTERACOES.:
function es109

COLABO->(qview({{"Codigo/Codigo"               ,1},;
               {"Nome/Nome"                    ,2},;
               {"Apelido/Apelido"              ,0}},"P",;
               {NIL,"c109a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c109a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(10,8,"B109A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao()

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , COLABO->Codigo     )
      qrsay ( XNIVEL++ , COLABO->Nome       )
      qrsay ( XNIVEL++ , COLABO->Apelido    )
      qrsay ( XNIVEL++ , COLABO->Funcao     )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO ,"@R 99999")           },"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOME   ,"@!X")                },"NOME"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fAPELIDO,"@!X")                },"APELIDO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFUNCAO ,"@!X")                },"FUNCAO"   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   COLABO->(qpublicfields())
   iif(cOPCAO=="I",COLABO->(qinitfields()),COLABO->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; COLABO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. COLABO->(iif(cOPCAO=="I",qappend(),qrlock()))

      fCODIGO:=StrZero(val(fCODIGO),5)

     // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      COLABO->(qreplacefields())

   else

      if empty(COLABO->Codigo)
         COLABO->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "CODIGO"
           qrsay(XNIVEL,StrZero(Val(fCODIGO),5))

      case cCAMPO == "NOME"
           if empty(fNOME) ; return .F. ; endif
   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR VENDEDORA  ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste(a) Vendedor(a) ?")
      if COLABO->(qrlock())
         COLABO->(dbdelete())
         COLABO->(qunlock())
      else
         qm3()
      endif
   endif
return
