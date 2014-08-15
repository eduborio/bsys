 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE ENTRADAS SEM CONTABILIZACAO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: JANEIRO DE 1999
// OBS........:
// ALTERACOES.:
function es102

cDATA := Date()

PROD->(dbsetorder(4))

MOVIMENT->(dbSetFilter({|| Tipo == "E".and. Contabil == .F. }, 'Tipo == "E" .and. Contabil == .F.'))

MOVIMENT->(qview({{"Data/Data"                    ,3},;
                  {"c102a()/Cod"                  ,0},;
                  {"c102b()/Produto"              ,0},;
                  {"c102d()/Ref.   "              ,0},;
                  {"Quantidade/Quantidade"        ,0},;
                  {"transform(Val_uni, '@e 999,999.99')/Valor"  ,0}},"P",;
                  {NIL,"c102c",NIL,NIL},;
                   NIL,"<I>ncluir / <C>onsulta "))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DA FILIAL ________________________________

function c102d
  PROD->(dbseek(MOVIMENT->Cod_prod))
return left(PROD->Cod_fabr,6)

function c102a
  PROD->(dbseek(MOVIMENT->Cod_prod))
return left(PROD->Cod_ass,7)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO _______________________________

function c102b
  PROD->(dbseek(MOVIMENT->(Cod_Prod)))
return left(PROD->Descricao,20) + left(PROD->Marca,10)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c102c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "I-C"
      qlbloc(11,6,"B102A","QBLOC.GLO",1)
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
   local cFATOR  := 1
   local bESCAPE := {||empty(cDATA).or.(XNIVEL==1.and.!XFLAG).or.!empty(cDATA).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , MOVIMENT->Data       )
      qrsay ( XNIVEL++ , MOVIMENT->Filial     ) ; FILIAL->(dbseek(MOVIMENT->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,30))
      qrsay ( XNIVEL++ , MOVIMENT->Cod_prod   ) ; PROD->(dbseek(MOVIMENT->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,20)+" "+left(PROD->Cod_fabr,4)  )
      qrsay ( XNIVEL++ , MOVIMENT->Quantidade )
      qrsay ( XNIVEL++ , transform(MOVIMENT->Val_uni, "@r 999,999.99"))
      qrsay ( XNIVEL++ , transform(MOVIMENT->Lote, "@R 9999999999"))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   fDATA  := cDATA


   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@cDATA         ,"@D")                    },"DATA"       })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"     })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD)                          },"COD_PROD"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE    ,"999999.999")          },"QUANTIDADE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVAL_UNI       ,"999,999.99")           },"VAL_UNI"    })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fLOTE   ,"@R 9999999999")           },"LOTE"       })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MOVIMENT->(qpublicfields())
   iif(cOPCAO=="I",MOVIMENT->(qinitfields()),MOVIMENT->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; MOVIMENT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if MOVIMENT->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fTIPO := "E"       // para determinar que a operacao ‚ de entrada
      fCONTABIL := .F.   // entrada sem contabilizacao

      fDATA  := cDATA


      MOVIMENT->(qreplacefields())
      PROD->(DbSeek(MOVIMENT->Cod_prod))

      INVENT->(Dbsetorder(1))
      if INVENT->(Dbseek(MOVIMENT->Filial+MOVIMENT->Cod_prod+MOVIMENT->Lote)) .and. INVENT->(qrlock()) .and. MOVIMENT->(qrlock())

         replace MOVIMENT->Saldo_ant  with   INVENT->Quant_atu   // saldo anterior
         replace INVENT->Quant_atu    with ( INVENT->Quant_atu  + MOVIMENT->Quantidade )
         replace INVENT->Preco_uni    with ( INVENT->Preco_uni  + MOVIMENT->Val_uni    ) / 2

      else
        qmensa("Produto n„o encontrado...","B")
        return
      endif

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

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DATA"
           fFILIAL := "0001"
           qrsay(XNIVEL+1,fFILIAL)

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qrsay(XNIVEL,fFILIAL)

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,30))

      case cCAMPO == "COD_PROD"
           INVENT->(DbClearFilter())

           if empty(fCOD_PROD) ; return .F. ; endif
           qrsay(XNIVEL,fCOD_PROD)

           if ! PROD->(dbseek(fCOD_PROD:=strzero(val(fCOD_PROD),5)))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           INVENT->(Dbsetfilter({|| Cod_prod == fCOD_PROD},'Cod_prod == fCOD_PROD'))

           qrsay(XNIVEL+1,left(PROD->Descricao,20)+"\"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )

      case cCAMPO == "QUANTIDADE"
           if empty(fQUANTIDADE) ; return .F. ; endif

      case cCAMPO == "LOTE"

           if empty(fLOTE)
              fLOTE := "0000000000"
              qrsay(XNIVEL,fLOTE)
           else
              fLOTE := strzero(val(fLOTE),10)
              qrsay(XNIVEL,fLOTE)
           endif

           INVENT->(Dbsetorder(1))
           if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fLOTE))
              qmensa("N£mero de Lote deste Produto nÆo encontrado...","B")
              fLOTE := "          "
              return .F.
           endif

   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ENTRADA ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Entrada ?")
      if MOVIMENT->(qrlock())
         PROD->(Dbsetorder(4))

//       if PROD->(Dbseek(MOVIMENT->Cod_prod)) .and. PROD->(qrlock()) .and. MOVIMENT->(qrlock())
//          iif (UNIDADE->(Dbseek(PROD->Unidade)), cFATOR:=UNIDADE->Fator ,)  // fator multiplicador da unidade *****
//          replace PROD->Qtn_estoq  with ( PROD->Qtn_estoq  - ( MOVIMENT->Quantidade * cFATOR ))
//       endif

         if INVENT->(Dbseek(MOVIMENT->Filial+MOVIMENT->Cod_prod+MOVIMENT->Lote)) .and. INVENT->(qrlock()) .and. MOVIMENT->(qrlock())
            replace INVENT->Quant_atu    with ( INVENT->Quant_atu  - MOVIMENT->Quantidade )
            replace INVENT->Preco_uni    with ( INVENT->Preco_uni  - MOVIMENT->Val_uni    ) / 2

            if LOTES->(dbseek(MOVIMENT->Cod_prod+MOVIMENT->Filial+MOVIMENT->Lote)) .and. LOTES->(qrlock())
               Replace LOTES->Quantidade With (LOTES->Quantidade - MOVIMENT->Quantidade)
               LOTES->(qunlock())
            endif
         endif
         MOVIMENT->(dbdelete())
         INVENT->(qunlock())
         LOTES->(qunlock())
         MOVIMENT->(qunlock())
      else
         qm3()
      endif
   endif
return
