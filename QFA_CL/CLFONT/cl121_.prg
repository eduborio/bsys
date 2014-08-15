/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO
// OBJETIVO...: MANUTENCAO DE SALDO INICIAL DE PRODUTOSW
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MAIO DE 2004
// OBS........:
// ALTERACOES.:

function cl121
private lPRI_REG := .T.
cDATA  := Date()

PROD->(dbsetorder(4))

ESTOQ->(qview({{"Data/Data"                                      ,2},;
              {"Cod_prod/C¢digo"                                 ,1},;
              {"c121c()/Produto"                                 ,0},;
              {"transform(Quant_ini,'@E 9999999.99')/Saldo Ini"  ,0},;
              {"transform(Quant_atu,'@E 9999999.99')/Saldo atual" ,0}},"P",;
              {NIL,"c121a",NIL,NIL},;
              NIL,"<I>nclus„o / <E>xclus„o / <C>onsulta"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESCRICAOD DO PRODUTO ________________________________________

function c121c
  PROD->(Dbseek(ESTOQ->Cod_prod))
return left(PROD->Descricao,23)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c121a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "ICE"
      qlbloc(10,07,"B121A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(cDATA).or.(lastkey()==27).or.(XNIVEL==1.and.!XFLAG).or.!empty(cDATA).and. Lastkey()==27 .or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , ESTOQ->Data,"@D" )
      qrsay ( XNIVEL++ , ESTOQ->Cod_prod  ) ; PROD->(Dbseek(ESTOQ->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,30))
      qrsay ( XNIVEL++ , ESTOQ->Quant_ini,"@R 999,999.99999")

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   fDATA  := cDATA

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@cDATA     ,"@D")                       },"DATA"      })
   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                         )} ,"COD_PROD" })
   aadd(aEDICAO,{{ || NIL                                                } ,NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANT_INI, "@R 999,999.99999")       },"QUANT_INI"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ESTOQ->(qpublicfields())

   if cOPCAO=="I"
      ESTOQ->(qinitfields())
   else
      ESTOQ->(dbsetorder(1))
      ESTOQ->(qcopyfields())
   endif

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ESTOQ->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   ESTOQ->(dbsetorder(1))
   ESTOQ->(dbgotop())

   if ESTOQ->(Dbseek(fCOD_PROD)) .and. cOPCAO == "I"
      qmensa("Produto j  Existe !!", "B")
      return .F.
   endif

   fDATA  := cDATA

   if ESTOQ->(iif(cOPCAO=="I",qappend(),qrlock()))

      ESTOQ->(qreplacefields())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   cDATA  := fDATA

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

    do case
      case cCAMPO == "COD_PROD"

           qrsay(XNIVEL,fCOD_PROD := strzero(val(fCOD_PROD),5))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           qrsay ( XNIVEL+1 , left(PROD->Descricao,30) )

      case cCAMPO == "QUANT_INI"

           //if empty(fQUANT_INI) ; return .F. ; endif
           if cOPCAO == "I" ; fQUANT_ATU := fQUANT_INI ;  endif

    endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR INVENTARIO ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o ?")
      if ESTOQ->(qrlock())
         ESTOQ->(dbdelete())
         ESTOQ->(qunlock())
      else
         qm3()
      endif
   endif
return
