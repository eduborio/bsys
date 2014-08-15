/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE CARGOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

FUN->(qview({{"Matricula/Matr¡cula"      ,1},;
               {"left(Nome,40)/Nome",2},;
               {"Util/Qntde Util ",0},;
               {"Sabado/Qntde Sabado",0}},"P",;
               {NIL,"c171a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c171a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "A"
      qlbloc(07,0,"B171A","QBLOC.GLO",1)
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
   local bESCAPE := {||(XNIVEL==3.and.!XFLAG).or.Lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,FUN->Matricula)
      qrsay(XNIVEL++,left(FUN->Nome,30))
      qrsay(XNIVEL++,FUN->Util,  "@E 999")
      qrsay(XNIVEL++,FUN->Sabado,"@E 999")
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
//   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           } ,NIL  })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fUTIL      ,"@E 999")             } ,"SABADO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSABADO    ,"@E 999")             } ,"SABADO"  })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   FUN->(qpublicfields())

   FUN->(qcopyfields())
   XNIVEL := 3
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )

      if eval ( bESCAPE ) ; FUN->(qreleasefields()) ; return ; endif

      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif

      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if FUN->(qrlock())
      FUN->(qreplacefields())
      FUN->(qunlock())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case

   endcase

return .T.


