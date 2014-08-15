/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO USIMIX
// OBJETIVO...: MANUTENCAO DE INVENTARIO INICIAL
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MAIO DE 1997
// OBS........:
// ALTERACOES.:

function cp107

private lPRI_REG := .T.
cDATA  := Date()
cFILIAL:= "0000"

PROD->(dbsetorder(4))
FILIAL->(dbsetorder(1))

INVENT->(qview({{"Data/Data"                                      ,2},;
              {"Filial/Filial"                                    ,1},;
              {"Lote/Lote"                                        ,0},;
              {"Cod_prod/C¢digo"                                  ,4},;
              {"f107as()/REF1"                                    ,0},;
              {"c107c()/Produto"                                  ,0},;
              {"transform(Quant_atu ,'@E 999999.99')/Saldo Atual" ,0},;
              {"transform(Val_invent, '@E 99,999.99')/Valor"     ,0}},"P",;
              {NIL,"c107a",NIL,NIL},;
              NIL,"<I>nclus„o / <E>xclus„o / <C>onsulta"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESCRICAOD DO PRODUTO ________________________________________

function c107c
  PROD->(Dbseek(INVENT->Cod_prod))
return left(PROD->Descricao,23)

function f107as
  PROD->(Dbseek(INVENT->Cod_prod))
return left(PROD->Cod_ass,6)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c107a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "IC"
      qlbloc(10,07,"B107A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"I",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
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

      qrsay ( XNIVEL++ , INVENT->Data,"@D" )
      qrsay ( XNIVEL++ , INVENT->Filial    ) ; FILIAL->(Dbseek(INVENT->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,30))
      qrsay ( XNIVEL++ , INVENT->Cod_prod  ) ; PROD->(Dbseek(INVENT->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,30))
      qrsay ( XNIVEL++ , INVENT->Quantidade,"@R 999,999.99999")
      qrsay ( XNIVEL++ , INVENT->Val_invent,"@R 999,999.99999")
      qrsay ( XNIVEL++ , INVENT->Lote,"@R 9999999999")

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   //if cOPCAO == "E" ; i_exclusao() ; return ; endif

   fDATA  := cDATA
   fFILIAL:= cFILIAL

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@cDATA     ,"@D")                       },"DATA"      })
   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL                         )} ,"FILIAL"   })
   aadd(aEDICAO,{{ || NIL                                                } ,NIL        }) // descricao da filial
   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                         )} ,"COD_PROD" })
   aadd(aEDICAO,{{ || NIL                                                } ,NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE, "@R 999,999.99999")       },"QUANTIDADE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVAL_INVENT   , "@R 999,999.99999")    },"VAL_INVENT"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLOTE   , "@R 9999999999")             },"LOTE"      })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   INVENT->(qpublicfields())

   if cOPCAO=="I"
      INVENT->(qinitfields())
   else
      INVENT->(dbsetorder(1))
      INVENT->(qcopyfields())
   endif

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; INVENT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   INVENT->(dbsetorder(1)) // filial + produto + lote
   INVENT->(dbgotop())

   if INVENT->(Dbseek(cFILIAL+fCOD_PROD+fLOTE)) .and. cOPCAO == "I"
      qmensa("Produto j  Existe nesta Filial com este n£mero de lote !!", "B")
      return .F.
   endif

   fDATA  := cDATA
   fFILIAL:= cFILIAL

   if INVENT->(iif(cOPCAO=="I",qappend(),qrlock()))

      INVENT->(qreplacefields())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   cDATA  := fDATA
   cFILIAL:= fFILIAL

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

    do case

      case cCAMPO == "FILIAL"
           if empty(cFILIAL) ; return .F. ; endif
           qrsay(XNIVEL,left(cFILIAL,4))
           if ! FILIAL->(dbseek(cFILIAL))
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(FILIAL->Razao,30))

      case cCAMPO == "COD_PROD"

           qrsay(XNIVEL,fCOD_PROD := strzero(val(fCOD_PROD),5))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           qrsay ( XNIVEL+1 , left(PROD->Descricao,30) )

      case cCAMPO == "QUANTIDADE"

           //  if empty(fQUANTIDADE) ; return .F. ; endif


           if cOPCAO == "I" ; fQUANT_ATU := fQUANTIDADE ;  endif

      case cCAMPO == "VAL_INVENT"

           if empty(fVAL_INVENT) ; return .F. ; endif
           if cOPCAO == "I" ; fPRECO_UNI := fVAL_INVENT ;  endif

      case cCAMPO == "LOTE"
           if empty(fLOTE)
              fLOTE := "0000000000"
              qrsay(XNIVEL,fLOTE)
              return .T.
           else
              fLOTE := strzero(Val(fLOTE),10)
              qrsay(XNIVEL,fLOTE)
              return .T.
           endif


    endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR INVENTARIO ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Inventario ?")
      if INVENT->(qrlock())
         INVENT->(dbdelete())
         INVENT->(qunlock())
         if LOTES->(dbseek(INVENT->Cod_prod+INVENT->Filial+INVENT->Lote)) .and. LOTES->(qrlock())
            LOTES->(dbdelete())
            LOTES->(qunlock())
         endif
      else
         qm3()
      endif
   endif
return
