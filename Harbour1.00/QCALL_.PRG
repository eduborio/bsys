
// FUNCAO QUE REALIZA A EXECUCAO DO <PROG> SELECIONADO
// REALIZANDO TODAS AS VERIFICACOES DE PERMISSAO DE ACESSO...
// REALIZANDO TODAS AS ATUALIZACOES SOBRE A ATIVIDADE EXECUTADA...
// * LEMBRE-SE QUE NO QGETPROG() HA UM DBCLOSEALL()
//   PORTANTO NAO HA NECESSIDADE DE FECHAR ARQUIVOS AQUI...

function qcall
   local bCALL, cOBJETO, cMENSA := 0, cHORA, cRECNO := 0
   private cPARAME

   // OPCAO TEM QUE SER 3 DIGITOS COMPLETOS _________________________________

   if len(alltrim(XPROG)) <> 3 ; return .F. ; endif


   // SEM USUARIO NAO TEM CONVERSA ! ________________________________________

   if empty(XUSRIDT) .and. ! XPASSWORD
      qmensa("N„o ha usuario ativo ! Acesso negado !","B")
      return .F.
   endif

   // ABRE QPROGS PARA VERIFICAR O PROGRAMA ACIONADO ________________________

   if ! quse("","QPROGS",{"QPROGS"}) ; return .F. ; endif

   QPROGS->(Dbsetorder(1))

   if ! QPROGS->(dbseek(XPROG))
      qmensa("<PROG> n„o encontrado...","B")
      return .F.
   endif

   // ABRE ARQUIVOS PARA VERIFICACOES _______________________________________

   if ! quse(XDRV_SH,"QUSERS",{"QUSERS2"})                     ; return .F. ; endif
   if ! quse(""     ,"QACESS",{"QACESS1"})                     ; return .F. ; endif
   if ! quse(""     ,"QLOGIN",{"QLOGIN1","QLOGIN2","QLOGIN3"}) ; return .F. ; endif
   if ! quse(""     ,"QINDEX")                                 ; return .F. ; endif

   cHORA := left(time(),2)

   // VERIFICA SE USUARIO ESTA LIBERADO PARA TRABALHAR ______________________

   QUSERS->(Dbsetorder(1))

   if ! XPASSWORD .and. QUSERS->(dbseek(XUSRNUM))
      if QUSERS->Prog <> "LOG" .and. XTIPOSENHA == "T"
         qmensa("Usuario ativo no <Prog> "+QUSERS->Prog+"...","B")
         return .F.
      endif
   endif

   // SE CONFIGURACAO INDICAR NIVEL <M>INIMO, ENTAO LIBERA __________________

   if XPASSWORD .or. XTIPOSENHA == "M"

      XUSRA := "IACE"
      XUSRD := "1234567"
      XUSRH := "00~24"

   else

   // VERIFICA PERMISSOES PARA O USUARIO ATIVO ______________________________

      do case
         case ! QACESS->(dbseek(XEMPRESA+XUSRNUM+XPROG))
              cMENSA := 1
         case empty(QACESS->Acesso)
              cMENSA := 1
         case ! str(dow(date()),1) $ QACESS->Dias
              cMENSA := 2
         case cHORA < left(QACESS->Horario,2) .or. cHORA > right(QACESS->Horario,2)
              cMENSA := 3
      endcase

      // MENSAGEM DE BLOQUEIO SE HOUVER _____________________________________

      iif(cMENSA<>0,dbcloseall(),NIL)
      do case
         case cMENSA == 1 ; qmensa("Acesso n„o autorizado para este <PROG> !","B") ; return .F.
         case cMENSA == 2 ; qmensa("Dia n„o autorizado para este <PROG> !","B") ; return .F.
         case cMENSA == 3 ; qmensa("Horario n„o autorizado para este <PROG> !","B") ; return .F.
      endcase

      XUSRA := strtran(QACESS->Acesso,"X","") // a letra X e' utilizada
      XUSRD := QACESS->Dias                   // apenas para nao ficar com
      XUSRH := QACESS->Horario                // o campo vazio...

   endif

   // SE NECESSARIO UTILIZA BLOCO DO QPROGS _________________________________

   if ! empty(QPROGS->Bloco)
      qlbloc(5,0,QPROGS->Bloco,"QBLOC.GLO")
   endif

   // TENTA ABRIR OS ARQUIVOS DO <PROG> E SAI SE NAO CONSEGUIR ______________

   if ! qopen() ; return .F. ; endif

   QINDEX->(dbclosearea())
   QACESS->(dbclosearea())

   // REALIZA ATUALIZACAO DA ATIVIDADE QUE VAI SER EXECUTADA ________________

   if ! XPASSWORD .and. QLOGIN->(qappend())
      cRECNO := QLOGIN->(recno())
      replace QLOGIN->Empresa  with XEMPRESA
      replace QLOGIN->Usrnum   with XUSRNUM
      replace QLOGIN->Prog     with XPROG
      replace QLOGIN->Datalog  with date()
      replace QLOGIN->Inicio   with time()
   endif
   QLOGIN->(dbclosearea())

   // PEGA PROG A SER EXECUTADO E ATUALIZA VIDEO ____________________________

   cOBJETO := QPROGS->Objeto
   cPARAME := alltrim(QPROGS->Parametro)
   qsay(3,18,QPROGS->Descricao+" / "+QPROGS->Prog)
   QPROGS->(dbclosearea())

   // REALIZA BLOQUEIO DO USUARIO NA ATIVIDADE ESCOLHIDA ____________________

   if ! XPASSWORD .and. QUSERS->(dbseek(XUSRNUM))
      if QUSERS->(qrlock())
         replace QUSERS->Prog    with XPROG
         replace QUSERS->Datalog with date()
         replace QUSERS->Inicio  with time()
      endif
   endif
   QUSERS->(dbclosearea())

   // EXECUTA O PROG SELECIONADO E NO FINAL FECHA TODOS OS ARQUIVOS _________

   if ! empty(cPARAME)
      bCALL := &("{||" + cOBJETO + "(cPARAME)}")
   else
      bCALL := &("{||" + cOBJETO + "()}")
   endif
   eval(bCALL)

   dbcloseall()

   // REALIZA ATUALIZACAO DO FINAL DA ATIVIDADE DO USUARIO __________________

   if ! XPASSWORD .and. cRECNO <> 0 .and. quse("","QLOGIN") // no ntx !
      QLOGIN->(dbgoto(cRECNO))
      if QLOGIN->(qrlock())
         replace QLOGIN->Final with time()
      endif
   endif

   // REALIZA DESBLOQUEIO DA ATIVIDADE DO USUARIO ___________________________

   if ! XPASSWORD .and. quse(XDRV_SH,"QUSERS",{"QUSERS2"})
      if QUSERS->(dbseek(XUSRNUM))
         if QUSERS->(qrlock())
            replace QUSERS->Prog    with "LOG"
            replace QUSERS->Datalog with ctod("")
            replace QUSERS->Inicio  with ""
         endif
      endif
   endif

   XUSRA := XUSRD := XUSRH := ""

return .T.


