/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE SALARIO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: 1994
// OBS........:
// ALTERACOES.:

// SETA RELACIONAMENTO E ENTRA NO VIEW ______________________________________

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

FUN->(dbSetFilter({|| Situacao != "H"},"Situacao != 'H'"))

FUN->(dbsetrelation("SIND",{||FUN->Sind_cod},"FUN->Sind_cod"))

FUN->(dbgotop())

FUN->(qview({{"Matricula"            ,1},;
             {"left(Nome,30)/Nome"            ,2},;
             {"FUN->Mat_ass/Mat.Ass.",9},;
             {"c411a()/Salario",0}},"P",;
             {NIL,"c411b",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR SALARIO DO FUNCIONARIO ___________________________________

function c411a
   SITUA->(dbseek(FUN->Matricula))
return(transform(SITUA->Salario,'@E 999,999.99'))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c411b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "IE" ; return "" ; endif   // somente neste caso
   if cOPCAO $ XUSRA
      qlbloc(10,15,"B411A","QBLOC.GLO",1)
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
   local bESCAPE := {||XNIVEL==1.and.(!XFLAG.or.lastkey()==27)}
   private fSALARIO, fSALARIOMA, fSALARIOPM, fSALARIOIN, fDATA_AUMEN

   SITUA->(dbseek(FUN->Matricula))

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      qsay ( 11 , 29 , FUN->Matricula )
      qsay ( 12 , 29 , left(FUN->Nome,30)      )
      XNIVEL := 1
      qrsay ( XNIVEL++ , SITUA->Salario   ,"@E 999,999.99" )
      qrsay ( XNIVEL++ , SITUA->Salarioma ,"@E 999,999.99" )
      qrsay ( XNIVEL++ , SITUA->Salariopm ,"@E 999,999.99" )
      qrsay ( XNIVEL++ , SITUA->Salarioin ,"@E 999,999.99" )
      qrsay ( XNIVEL++ , SITUA->Data_aumen )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fSALARIO   ,"@E 999,999.99") },"SALARIO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSALARIOMA ,"@E 999,999.99") },"SALARIOMA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSALARIOPM ,"@E 999,999.99") },"SALARIOPM"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSALARIOIN ,"@E 999,999.99") },"SALARIOIN"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_AUMEN,NIL                  ) },"DATA_AUMEN" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   fSALARIO    := SITUA->Salario
   fSALARIOMA  := SITUA->Salarioma
   fSALARIOPM  := SITUA->Salariopm
   fSALARIOIN  := SITUA->Salarioin
   fDATA_AUMEN := SITUA->Data_aumen
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if SITUA->(qrlock())
      replace SITUA->Salario    with fSALARIO
      replace SITUA->Salarioma  with fSALARIOMA
      replace SITUA->Salariopm  with fSALARIOPM
      replace SITUA->Salarioin  with fSALARIOIN
      replace SITUA->Data_aumen with fDATA_AUMEN
      if CONFIG->Datasys < CONFIG->Data_atual
         nREGS := SITUA->(recno())
         SITUA->(Dbclearfil())
         SITUA->(dbsetorder(4))
         SITUA->(dbseek(FUN->Matricula+qanomes(CONFIG->Data_atual)))
         if SITUA->(qrlock())
            replace SITUA->Salario    with fSALARIO
            replace SITUA->Salarioma  with fSALARIOMA
            replace SITUA->Salariopm  with fSALARIOPM
            replace SITUA->Salarioin  with fSALARIOIN
            replace SITUA->Data_aumen with fDATA_AUMEN

            SITUA->(dbsetorder(1))
            SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
            SITUA->(dbgoto(nREGS))
         endif
         SITUA->(qunlock())
      endif
      SITUA->(qunlock())
   else
      qm2()
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "SALARIO"
           if (SITUA->Categoria == "5" .and. fSALARIO * FUN->Hor_trab < SIND->Piso) .or. ;
              (SITUA->Categoria <> "5" .and. fSALARIO < SIND->Piso)
              qmensa("Salario abaixo do Piso do Sindicato !","B")
              return .F.
           endif
   endcase
return .T.
