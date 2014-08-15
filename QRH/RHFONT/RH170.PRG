/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE RECURSO HIMANO
// OBJETIVO...: MANUTENCAO DE MECANICOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: AGOSTO DE 1997
// OBS........:
// ALTERACOES.:

MECANICO->(qview({{"Codigo/C¢digo"        ,1},;
                  {"Cod_fun/Matr¡cula"    ,0},;
                  {"Nome/Nome"            ,2},;
                  {"transform(Salario,'@E 999,999.99')/Salario",0}},"P",;
                  {NIL,"c170a",NIL,NIL       },;
                  NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c170a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,13,"B170A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fCODIGO) .and. XNIVEL==1 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , MECANICO->Codigo     )
      qrsay ( XNIVEL++ , MECANICO->Cod_fun    )
      qrsay ( XNIVEL++ , MECANICO->Nome       )
      qrsay ( XNIVEL++ , transform(MECANICO->Salario,"@E 999,999.99") )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"999999")                },"CODIGO"       })
   aadd(aEDICAO,{{ || view_fun(-1,0,@fCOD_FUN)                            },"COD_FUN"      })
   aadd(aEDICAO,{{ || NIL                                                 },NIL            })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSALARIO      ,"@E 99,999,999.99")      },"SALARIO"      })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MECANICO->(qpublicfields())
   iif(cOPCAO=="I",MECANICO->(qinitfields()),MECANICO->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; MECANICO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

     // AGORA INCREMENTA CODIGO DO COMPRADOR ________________________________

   if MECANICO->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      MECANICO->(qreplacefields())
      MECANICO->(dbgotop())

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

      case cCAMPO == "CODIGO"
           if cOPCAO == "I"
              if MECANICO->(dbseek(fCODIGO))
                 qmensa("Codigo j  Existe !" ,"B")
                 return .F.
              endif
           else
              if ! MECANICO->(dbseek(fCODIGO))
                 qmensa("Codigo n„o Existe !" ,"B")
                 return .F.
              endif
           endif

      case cCAMPO == "COD_FUN"
           if empty(fCOD_FUN) ; return .F. ; endif
           qrsay(XNIVEL,fCOD_FUN := strzero(val(fCOD_FUN),6))
           if ! FUN->(dbseek(fCOD_FUN))
              qmensa("Funcion rio n„o Cadastrado !","B")
              return .F.
           endif

           nREC := MECANICO->(recno())
           MECANICO->(dbsetorder(3))

           if MECANICO->(dbseek(fCOD_FUN)) .and. cOPCAO == "I"
             qmensa("Mecanico j  Existe !","B")
             return .F.
           endif

           MECANICO->(dbsetorder(1))
           MECANICO->(dbgoto(nREC))

           qrsay(XNIVEL+1,left(FUN->Nome,30))

           fNOME := FUN->Nome

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR COMPRADOR ____________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Mecanico ?")
      if MECANICO->(qrlock())
         MECANICO->(dbdelete())
         MECANICO->(qunlock())
      else
         qm3()
      endif
   endif
return

