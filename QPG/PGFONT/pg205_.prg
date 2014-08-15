/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A /PAGAR
// OBJETIVO...: INCLUSAO DE LANCAMENTO DE DESPESAS A PAGAR
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: OUTUBRO DE 1997
// OBS........:
// ALTERACOES.:

//#include "inkey.ch"
//#include "setcurs.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

// VIEW INICIAL _____________________________________________________________

function pg205

LACTOS->(qview({{"Codigo/C¢digo"             ,1},;
               {"Vencto/Vencimento"          ,0},;
               {"f_205b()/Despesa"           ,0}},"P",;
               {NIL,"f205a",NIL,NIL},;
                NIL,"ESC/ALT-P/ALT-O/<I>nc/<A>lt/<E>xc/<C>on"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DA DESPESA __________________________________________

function f_205b
  DESPESAS->(dbseek(LACTOS->Cod_desp))
return left(DESPESAS->Descricao,55)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f205a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(11,06,"B205A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.!empty(fDATA_LANC).and.XNIVEL==2.and.Lastkey()==27.or.;
                         (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if ! cOPCAO $ "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , LACTOS->Codigo         )
      qrsay ( XNIVEL++ , dtoc(LACTOS->Data_lanc))
      qrsay ( XNIVEL++ , LACTOS->Cod_desp       ) ; DESPESAS->(dbseek(LACTOS->Cod_desp))
      qrsay ( XNIVEL++ , left(DESPESAS->Descricao,40))
      qrsay ( XNIVEL++ , dtoc(LACTOS->Vencto)   )
      qrsay ( XNIVEL++ , transform(LACTOS->Valor,"@E 9,999,999.99" ))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL }                                         ,NIL         })  // codigo nao pode ser editado
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC                    ) } ,"DATA_LANC" })
   aadd(aEDICAO,{{ || view_desp(-1,0,@fCOD_DESP                 ) } ,"COD_DESP"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVENCTO                       ) } ,"VENCTO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    ,"@E 9,999,999.99"  ) } ,"VALOR"     })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   LACTOS->(qpublicfields())
   iif(cOPCAO=="I",LACTOS->(qinitfields()),LACTOS->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   if cOPCAO == "I"
      fCODIGO := strzero(CONFIG->Cod_lcto + 1,5)
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; LACTOS->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if LACTOS->(iif(cOPCAO=="I",qappend(),qrlock()))
      LACTOS->(qreplacefields())
      LACTOS->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Cod_lcto with val(fCODIGO)
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case

      case cCAMPO == "COD_DESP"

           if ! empty(fCOD_DESP)

              if ! DESPESAS->(Dbseek(fCOD_DESP:=strzero(val(fCOD_DESP),5)))

                 qmensa("Despesa n„o Econtrada !!!","B")

                 return .F.

              else

                 qrsay(XNIVEL+1,left(DESPESAS->Descricao,40))

              endif

           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CONTAS A LACTOS _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Lancamento ?")
      if LACTOS->(qrlock())
         LACTOS->(dbdelete())
         LACTOS->(qunlock())
      else
         qm3()
      endif
   endif
return
