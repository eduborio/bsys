 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE ENTRADAS DE PRODUTOS ACABADOS
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: JANEIRO DE 2003
// OBS........:
// ALTERACOES.:
function es406

PROD->(dbsetorder(4))

CUSTOS->(qview({{"Data/Data"                    ,3},;
                 {"c406b()/Produto"              ,2},;
                 {"Quantidade/Quantidade"        ,0}},"P",;
                 {NIL,"c406c",NIL,NIL},;
                  NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DA FILIAL ________________________________


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO _______________________________

function c406b
  PROD->(dbseek(CUSTOS->(Cod_Prod)))
return left(PROD->Descricao,16)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c406c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "I*A*E*C"
      qlbloc(11,6,"B406A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   if cOPCAO == "P"
      i_impressao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local cFATOR  := 1
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==1.and.!XFLAG).or.!empty(fDATA).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , CUSTOS->Data       )
      qrsay ( XNIVEL++ , CUSTOS->Filial     ) ; FILIAL->(dbseek(CUSTOS->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,30))
      qrsay ( XNIVEL++ , CUSTOS->Cod_prod   ) ; PROD->(dbseek(CUSTOS->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,20))
      qrsay ( XNIVEL++ , CUSTOS->Quantidade )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif
   if cOPCAO == "P" ; i_impressao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA         ,"@D")                    },"DATA"       })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"     })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD)                          },"COD_PROD"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE    ,"999999")          },"QUANTIDADE" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CUSTOS->(qpublicfields())
   iif(cOPCAO=="I",CUSTOS->(qinitfields()),CUSTOS->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CUSTOS->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CUSTOS->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      CUSTOS->(qreplacefields())
      if cOPCAO == "I"

      ITEN_ACA->(dbsetorder(1))
      ITEN_ACA->(dbgotop())
      ITEN_ACA->(dbseek(ACABADO->Codigo))


      endif
   else

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

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(XNIVEL,fFILIAL)

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,30))


      case cCAMPO == "COD_PROD"

           if empty(fCOD_PROD) ; return .F. ; endif
           qsay(XNIVEL,fCOD_PROD)

           if ! ACABADO->(dbseek(fCOD_PROD:=strzero(val(fCOD_PROD),5)))
              qmensa("Produto acabado n„o encontrado !","B")
              return .F.
           endif
           PROD->(dbseek(ACABADO->Codigo))
           qrsay(XNIVEL+1,left(PROD->Descricao,20))

      case cCAMPO == "QUANTIDADE"
           if empty(fQUANTIDADE) ; return .F. ; endif

   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ENTRADA ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Entrada ?")
      if CUSTOS->(qrlock())
         PROD->(Dbsetorder(4))


         ACABADO->(dbsetorder(1))
         ACABADO->(dbgotop())

         ACABADO->(Dbseek(CUSTOS->Cod_prod))

         ITEN_ACA->(dbsetorder(1))
         ITEN_ACA->(dbgotop())
         ITEN_ACA->(dbseek(ACABADO->Codigo))


         CUSTOS->(dbdelete())
         INVENT->(qunlock())
         CUSTOS->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_impressao
   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0
   local nTOTAL := 0

   cTITULO := "CALCULO DO CUSTO DE UM PRODUTO "+"  Data.: "+dtoc(CUSTOS->Data)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,80)
      ACABADO->(dbseek(CUSTOS->Cod_prod))
      @ prow()+1,0 say "Produto.: "+ ACABADO->Desc_acab
      @ prow()+1,0 say "Quantidade Produzida: "+transf(CUSTOS->Quantidade,"@E 9999999")

      @ prow()+1,0 say replicate("-",80)
   endif

   @ prow()+1,0 say XCOND1+"Produto                                                        Quantidade         Preco Unitario           Total       "
   @ prow()+1,0 say replicate("-",136)

   ITEN_ACA->(Dbseek(CUSTOS->Cod_prod))

   do while ! ITEN_ACA->(eof()) .and. ITEN_ACA->Cod_aca == ACABADO->Codigo

      PROD->(Dbseek(right(ITEN_ACA->produto,5)))
      @ prow()+1,0   say PROD->Descricao
      @ prow()  ,60  say transform(ITEN_ACA->Quantidade*CUSTOS->Quantidade, "@E 9999999.999")
      @ prow()  ,80  say transform(ITEN_ACA->Preco, "@E 99,999,999.99")
      @ prow()  ,100  say transform(ITEN_ACA->Quantidade*ITEN_ACA->Preco*CUSTOS->Quantidade, "@E 99,999,999.99")
      nTOTAL += ITEN_ACA->Quantidade*CUSTOS->quantidade*ITEN_ACA->Preco
      ITEN_ACA->(Dbskip())

   enddo

   @ prow()+1,0 say replicate("-",136)
   @ prow()+1,0 say "Valor Total..: " + transform(nTOTAL,"@E 99,999,999.99")
   @ prow()+1,0 say "Quantidade Produzida......: " + transform(CUSTOS->Quantidade,"@R 999999")
   @ prow()+1,0 say "Custo Unitario do Produto.: " + transform(nTOTAL/CUSTOS->Quantidade,"@E 99,999,999.99")
   nTOTAL := 0
   qstopprn()
return

