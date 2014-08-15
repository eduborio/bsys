/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO USIMIX
// OBJETIVO...: MANUTENCAO DE CLIENTES
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1995
// OBS........:
// ALTERACOES.:

function rb106

CLI1->(qview({{"Codigo/C¢digo"               ,1},;
                 {"left(Razao,35)/Raz„o"         ,2}},"P",;
                 {NIL,"c106a",NIL,NIL},;
                 NIL,;
                 q_msg_acesso_usr()))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c106a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(5,0,"B106A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fRAZAO).or.(XNIVEL==2.and.!XFLAG).or.!empty(fRAZAO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , CLI1->Codigo                                 )
      qrsay ( XNIVEL++ , CLI1->Razao                                  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CLI1->(qpublicfields())
   iif(cOPCAO=="I",CLI1->(qinitfields()),CLI1->(qcopyfields()))
   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CLI1->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if ! quse(XDRV_CL,"CONFIG",{},,"PROV")
      qmensa("N„o foi possivel abrir CONFIG.DBF do Faturamento !","B")
      return .F.
   endif

   if cOPCAO == "I"
      if PROV->(qrlock())
         replace PROV->Cod_cli with PROV->Cod_cli + 1
         qrsay ( 1 , fCODIGO := strzero(PROV->Cod_cli,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
         PROV->(qunlock())
      endif
   endif

   PROV->(dbclosearea())

   select CLI1

   if CLI1->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      CLI1->(qreplacefields())

   else

      if empty(CLI1->Codigo) .and. empty(CLI1->Razao)
         CLI1->(dbdelete())
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

      case cCAMPO == "CODIGO" .and. cOPCAO == "I"

           if CLI1->(dbseek(fCODIGO))
              qmensa("Cliente j  cadastrado !","B")
              return .F.
           endif


      case cCAMPO == "RAZAO"

           zTMP := .T.

           qrsay(XNIVEL,fRAZAO )

           return i_razao_dup()


   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// CHECAR CGC DUPLICADO _____________________________________________________

static function i_razao_dup

   local lFLAG, nRESP

   local nRECNO := CLI1->(recno())

   local nORDER := CLI1->(indexord())

   CLI1->(dbsetorder(2)) // muda para cgc...

   lFLAG := CLI1->(dbseek(fRAZAO))

   if cOPCAO == "A" .and. fCODIGO == CLI1->Codigo
      lFLAG := .F.
   endif

   CLI1->(dbsetorder(nORDER)) // retorna ao original...

   if ! lFLAG

      CLI1->(dbgoto(nRECNO))

   else

      do while .T.

         nRESP := alert("NOME DUPLICADO !",{"Corrigir","Aceitar","Localizar"})

         do case
            case nRESP == 1
                 CLI1->(dbgoto(nRECNO))
                 return .F.
            case nRESP == 2
                 CLI1->(dbgoto(nRECNO))
                 return .T.
            case nRESP == 3 // para acionar bESCAPE...
                 XNIVEL := -1
                 return .T.
            otherwise
                 loop
         endcase

      enddo

   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CLIENTE ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Cliente ?")
      if CLI1->(qrlock())
         CLI1->(dbdelete())
         CLI1->(qunlock())
      else
         qm3()
      endif
   endif
return

