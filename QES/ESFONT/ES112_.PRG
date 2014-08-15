 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE ENTRADAS de Estoque (AVARIADO)
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: JANEIRO DE 2007
// OBS........:
// ALTERACOES.:
function es112

cDATA := Date()

PROD->(dbsetorder(4))

i_ref()


AVARIADO->(qview({{"Data/Data"                    ,3},;
                  {"c112b()/Produto"              ,0},;
                  {"Ref/Ref."                     ,8},;
                  {"Transf(Quantidade,'@R 999999.99')/Quantidade"        ,0},;
                  {"Left(Obs,25)/Observacao"      ,0}},"P",;
                  {NIL,"c112c",NIL,NIL},;
                   NIL,"<I>ncluir / <C>onsulta "))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DA FILIAL ________________________________

function c112d
  PROD->(dbseek(AVARIADO->Cod_prod))
return left(PROD->Cod_fabr,6)

function c112a
  PROD->(dbseek(AVARIADO->Cod_prod))
return left(PROD->Cod_ass,7)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO _______________________________

function c112b
  PROD->(dbseek(AVARIADO->(Cod_Prod)))
return left(PROD->Descricao,20)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c112c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "I*C*E"
      qlbloc(11,6,"B111A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , AVARIADO->Data       )
      qrsay ( XNIVEL++ , AVARIADO->Filial     ) ; FILIAL->(dbseek(AVARIADO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,30))
      qrsay ( XNIVEL++ , AVARIADO->Cod_prod   ) ; PROD->(dbseek(AVARIADO->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,20)+" "+left(PROD->Cod_fabr,4)  )
      qrsay ( XNIVEL++ , AVARIADO->Quantidade )
      qrsay ( XNIVEL++ , transform(AVARIADO->Val_uni, "@r 999,999.99"))
      qrsay ( XNIVEL++ , transform(AVARIADO->Lote, "@R 9999999999"))

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

   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE    ,"99999.99999")          },"QUANTIDADE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVAL_UNI       ,"999,999.99")           },"VAL_UNI"    })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fLOTE   ,"@R 9999999999")           },"LOTE"       })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   AVARIADO->(qpublicfields())
   iif(cOPCAO=="I",AVARIADO->(qinitfields()),AVARIADO->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; AVARIADO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if AVARIADO->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fTIPO := "B"       // para determinar que a operacao ‚ de entrada
      fCONTABIL := .F.   // entrada sem contabilizacao

      fDATA  := cDATA


      AVARIADO->(qreplacefields())
      PROD->(DbSeek(AVARIADO->Cod_prod))

      INVENT->(Dbsetorder(1))
      if INVENT->(Dbseek(AVARIADO->Filial+AVARIADO->Cod_prod+AVARIADO->Lote)) .and. INVENT->(qrlock()) .and. AVARIADO->(qrlock())
         replace INVENT->Quant_atu    with ( INVENT->Quant_atu  - AVARIADO->Quantidade )
         replace INVENT->Quant_defe   with ( INVENT->Quant_defe + AVARIADO->Quantidade )
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
		   INVENT->(Dbsetorder(1))
		   if INVENT->(Dbseek(fFilial+fCod_prod+"0000000000")) 
		       if INVENT->Quant_atu < fQUANTIDADE
			  	  qmensa("Saldo insuficiente!","BL")
				  return .F.
		       endif 
		   else
		       qmensa("Nao foi possivel localizar este produto no inventario!","BL")
			   return .F.
		   endif
           
      
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
   if qconf("Confirma exclus„o desta Entrada de Avariados ?")
      if AVARIADO->(qrlock())
         PROD->(Dbsetorder(4))
         INVENT->(Dbsetorder(1))
         if INVENT->(Dbseek(AVARIADO->Filial+AVARIADO->Cod_prod+AVARIADO->Lote)) .and. INVENT->(qrlock())
            if INVENT->Quant_defe > 0
               replace INVENT->Quant_atu    with ( INVENT->Quant_atu  + AVARIADO->Quantidade )
               replace INVENT->Quant_defe   with ( INVENT->Quant_defe - AVARIADO->Quantidade )
            else
              Qmensa("Opera‡Æo Negada!","B")
              return .F.
            endif

         endif

         AVARIADO->(dbdelete())
         INVENT->(qunlock())
         AVARIADO->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_ref()

  AVARIADO->(Dbgotop())

  do while ! AVARIADO->(Eof())

     if empty(AVARIADO->Ref)
        PROD->(dbseek(AVARIADO->(cod_prod)))
        if AVARIADO->(qrlock())
           replace AVARIADO->Ref with left(PROD->cod_fabr,6)
           AVARIADO->(qunlock())
        endif
     endif

     AVARIADO->(dbskip())
  enddo

  AVARIADO->(dbgotop())

return
