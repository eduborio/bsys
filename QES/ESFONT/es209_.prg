 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: BAIXA - PERDAS NO PROCESSO PRODUTIVO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JULHO DE 1999
// OBS........:
// ALTERACOES.:
function es209

PROD->(dbsetorder(4))

PERDAS->(qview({{"Data/Data"                    ,1},;
                {"Cod_prod/C¢digo"              ,3},;
                {"Descricao/Produto"            ,4},;
                {"Filial/Filial"                ,2},;
                {"Quant/Quantidade"             ,0}},"P",;
                {NIL,"c209c",NIL,NIL},;
                 NIL,"<ESC>-sai/<ALT-O>/<ALT-P>/<I>nclui/<C>onsulta/<E>xclui"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c209c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "ICE"
      qlbloc(11,6,"B209A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local nSALDO_ANT := 0
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==1.and.!XFLAG).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PERDAS->Data, "@D"                       )
      qrsay ( XNIVEL++ , PERDAS->Filial                           ) ; FILIAL->(dbseek(PERDAS->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,30                   ))
      qrsay ( XNIVEL++ , PERDAS->Cod_prod                         ) ; PROD->(dbseek(PERDAS->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,30                 ))
      qrsay ( XNIVEL++ , PERDAS->Quant, "@R 9999999.999"             )
      qrsay ( XNIVEL++ , transform(PERDAS->Lote, "9999999999"     ))
      qrsay ( XNIVEL++ , left(PERDAS->Obs,50) )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA         ,"@D")                    },"DATA"       })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL      )                    },"FILIAL"     })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD      )                    },"COD_PROD"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANT         ,"999999.999")                },"QUANT"      })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fLOTE       ,"9999999999")              },"LOTE"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS       ,"@!S50")                    },"OBS"        })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PERDAS->(qpublicfields())
   iif(cOPCAO=="I",PERDAS->(qinitfields()),PERDAS->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PERDAS->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if PERDAS->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      PERDAS->(qreplacefields())

      if INVENT->(Dbseek(PERDAS->Filial+PERDAS->Cod_prod+PERDAS->Lote)) .and. INVENT->(qrlock()) .and. PERDAS->(qrlock())
         nSALDO_ANT := INVENT->Quant_atu
         replace INVENT->Quant_atu    with ( INVENT->Quant_atu - PERDAS->Quant )

      else

        qmensa("Produto n„o possui Inventario nesta Filial... Verifique...","B")
        return
      endif

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

//   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qrsay(XNIVEL,fFILIAL)

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,30))

      case cCAMPO == "COD_PROD"

           if empty(fCOD_PROD) ; return .F. ; endif
           qrsay(XNIVEL,fCOD_PROD)

           if ! PROD->(dbseek(fCOD_PROD:=strzero(val(fCOD_PROD),5)))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif
           fDESCRICAO := PROD->Descricao

           INVENT->(dbSetFilter({|| Cod_Prod == fCOD_PROD .and. Filial == fFILIAL }, 'Cod_Prod == fCOD_PROD .and. Filial == fFilial'))


           qrsay(XNIVEL+1,left(PROD->Descricao,20))

      case cCAMPO == "QUANT"
           if empty(fQUANT) ; return .F. ; endif

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
              qmensa("Produto sem Inventario. Verifique...","B")
              return .F.
           else
              if INVENT->Quant_atu < fQUANT
                 qmensa("Estoque Insuficiente...","B")
                 return .F.
              endif
           endif



   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ENTRADA ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Baixa ?")
      if PERDAS->(qrlock())
         PROD->(Dbsetorder(4))

         if INVENT->(Dbseek(PERDAS->Filial+PERDAS->Cod_prod+PERDAS->Lote)) .and. INVENT->(qrlock()) .and. PERDAS->(qrlock())
            replace INVENT->Quant_atu    with ( INVENT->Quant_atu + PERDAS->Quant )
         endif

         PERDAS->(dbdelete())
         INVENT->(qunlock())
         PERDAS->(qunlock())
      else
         qm3()
      endif
   endif
return
