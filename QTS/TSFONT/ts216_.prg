/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE PAGAMENTOS A VISTA
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....:
// OBS........:
// ALTERACOES.:
function ts216

#include "inkey.ch"
#include "setcurs.ch"

private sBLOC1  := qlbloc("B207B","QBLOC.GLO")

BANCO->(Dbsetorder(3))
CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

PAG_VIST->(qview({{"Codigo/C¢d."                        ,0},;
                  {"i_216b()/Tipo"                      ,0},;
                  {"Duplicata/Duplicata"                ,0},;
                  {"Valor/Valor"                        ,0}},"P",;
                  {NIL,"i_216a",NIL,NIL},;
                  {"Data==XDATA",{||i216top()},{||i216bot()}},;
                  "<I>ncluir <C>onsultar  E<M>itir Cheque   <A>lterar  <E>xcluir"))

return ""

function i216top
   PAG_VIST->(Dbsetorder(2))
   PAG_VIST->(dbseek(dtos(XDATA)))
return

function i216bot
   PAG_VIST->(Dbsetorder(2))
   PAG_VIST->(qseekn(dtos(XDATA)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_216b
  TIPOCONT->(Dbseek(PAG_VIST->Tipocont))
return left(TIPOCONT->Descricao,42)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_216a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. PAG_VIST->Data < CONFIG->Data_atual
   //   qmensa("Data encerrada. Permissao Negada!","B")
   //   return .F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif



   if cOPCAO $ "IAMCE"
      qlbloc(08,03,"B216A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_edicao

   local lCONF := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fTIPOCONT).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , PAG_VIST->Codigo            )
      qrsay ( XNIVEL++ , PAG_VIST->Tipocont          ) ; TIPOCONT->(Dbseek(PAG_VIST->Tipocont))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,15))
      qrsay ( XNIVEL++ , PAG_VIST->Data              )
      qrsay ( XNIVEL++ , PAG_VIST->Centro            ) ; CCUSTO->(Dbseek(PAG_VIST->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,15))
      qrsay ( XNIVEL++ , PAG_VIST->Filial            ) ; FILIAL->(Dbseek(PAG_VIST->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,15))
      qrsay ( XNIVEL++ , PAG_VIST->Serie             ) ; SERIE->(Dbseek(PAG_VIST->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,10)   )
      qrsay ( XNIVEL++ , PAG_VIST->Especie           ) ; ESPECIE->(Dbseek(PAG_VIST->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,10) )
      qrsay ( XNIVEL++ , PAG_VIST->Duplicata         )
      qrsay ( XNIVEL++ , PAG_VIST->Valor     , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , qabrev(PAG_VIST->Forma,"COE", {"Cheque","Ordem","Esp‚cie"}))
      qrsay ( XNIVEL++ , PAG_VIST->Banco             ) ; BANCO->(Dbseek(PAG_VIST->Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,10)   )
      qrsay ( XNIVEL++ , PAG_VIST->Num_cheque        )
      qrsay ( XNIVEL++ , PAG_VIST->Cod_fav           )
      qrsay ( XNIVEL++ , left(PAG_VIST->Favorecido,47)        )
      qrsay ( XNIVEL++ , left(PAG_VIST->Historico,40))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   if cOPCAO == "M"
      if ! qconf("Confirma emissao do Cheque??") ; return .F. ; endif

      i_cheque()

   endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_tipo(-1,0,@fTIPOCONT)                    },"TIPOCONT"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA, "@D")                      },"DATA"       })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO)                    },"CENTRO"     })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                    },"FILIAL"     })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_serie(-1,0,@fSERIE)                      },"SERIE"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_especie(-1,0,@fESPECIE)                  },"ESPECIE"    })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDUPLICATA                      ) } ,"DUPLICATA" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    , "@E 9,999,999.99"   ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@fFORMA ,sBLOC1                   )} ,"FORMA"     })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO)                      },"BANCO"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_CHEQUE                     ) } ,"NUM_CHEQUE"})
   aadd(aEDICAO,{{ || view_fun(-1,0,@fCOD_FAV)                  },"COD_FAV"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAVORECIDO , "@!S40"              ) } ,"FAVORECIDO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO , "@!@S40"           ) } ,"HISTORICO" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PAG_VIST->(qpublicfields())

   iif(cOPCAO=="I",PAG_VIST->(qinitfields()),PAG_VIST->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
   fDATA  := XDATA

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PAG_VIST->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if PAG_VIST->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_pag_vi with CONFIG->Cod_pag_vi+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_pag_vi,5),"B")
         fCODIGO := strzero(CONFIG->Cod_pag_vi,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fDATA := XDATA

      PAG_VIST->(qreplacefields())

      if fFORMA $ "CO"

         if cOPCAO == "I" .and. MOV_BANC->(qappend())
            replace MOV_BANC->Data with fDATA
            replace MOV_BANC->Cod_banco with fBANCO
            replace MOV_BANC->Historico with "PAGAMENTOS A VISTA" + iif(! empty(fNUM_CHEQUE), " CH. NR. " + fNUM_CHEQUE, "")
            replace MOV_BANC->Saida     with fVALOR
            replace MOV_BANC->Num_docto with left(fDUPLICATA,6)
            replace MOV_BANC->Concilia  with "0"
            replace MOV_BANC->Internal  with "VALE"+fCODIGO
         endif

         if cOPCAO == "A"
            MOV_BANC->(Dbsetorder(4))
            if MOV_BANC->(dbseek("VALE"+PAG_VIST->Codigo)) .and. MOV_BANC->(qrlock())
               replace MOV_BANC->Data with fDATA
               replace MOV_BANC->Cod_banco with fBANCO
               replace MOV_BANC->Historico with "PAGAMENTOS A VISTA" + iif(! empty(fNUM_CHEQUE), " CH. NR. " + fNUM_CHEQUE, "")
               replace MOV_BANC->Saida     with fVALOR
               replace MOV_BANC->Num_docto with left(fDUPLICATA,6)
               replace MOV_BANC->Concilia  with "0"
               MOV_BANC->(Qunlock())
            endif
         endif


      elseif fFORMA $ "E"

         if cOPCAO == "I" .and. MOV_CAIX->(qappend())
            replace MOV_CAIX->Data with fDATA
            replace MOV_CAIX->Cod_banco with fBANCO
            replace MOV_CAIX->Historico with "PAGAMENTOS A VISTA" + iif(! empty(fNUM_CHEQUE), " CH. NR. " + fNUM_CHEQUE, "")
            replace MOV_CAIX->Saida     with fVALOR
            replace MOV_CAIX->Num_docto with left(fDUPLICATA,6)
            replace MOV_CAIX->Internal  with "VALE"+fCODIGO
         endif

         if cOPCAO == "A"
            MOV_CAIX->(Dbsetorder(2))
            if MOV_CAIX->(Dbseek("VALE"+PAG_VIST->Codigo)) .and. MOV_CAIX->(Qrlock())
               replace MOV_CAIX->Data with fDATA
               replace MOV_CAIX->Cod_banco with fBANCO
               replace MOV_CAIX->Historico with "PAGAMENTOS A VISTA" + iif(! empty(fNUM_CHEQUE), " CH. NR. " + fNUM_CHEQUE, "")
               replace MOV_CAIX->Saida     with fVALOR
               replace MOV_CAIX->Num_docto with left(fDUPLICATA,6)
               MOV_CAIX->(qunlock())
            endif
         endif


      endif

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if TALOES->Ultimo_ch >= TALOES->Inter_fina   // grava ultimo numero do cheque, e verifica se o talao terminou
      if TALOES->(qrlock())
         TALOES->(Dbdelete())  // quando o talao acaba o registro e' excluido
      endif
   else
      if TALOES->(qrlock())
         replace TALOES->Ultimo_ch with (val(fNUM_CHEQUE) + 1)
      endif
   endif

   dbunlockall()

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   local nDIA := 0

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "VALOR"

           if fVALOR == 0 ; return .F. ; endif

      case cCAMPO == "BANCO"

           if empty(fBANCO) ; return .F. ; endif

           if ! BANCO->(dbseek(fBANCO:=strzero(val(fBANCO),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,20))
           if cOPCAO == "I"
              if fBANCO <> "99999"
                 TALOES->(dbsetorder(2))  // codigo do banco
                 TALOES->(dbgotop())

                 if TALOES->(dbseek(fBANCO))
                    fNUM_CHEQUE := strzero(TALOES->Ultimo_ch)
                 else
                   qmensa("N„o Existe Tal„o Cadastrado para este Banco !","B")
                   XNIVEL := 40 // para sair do loop principal
                   return .F.
                 endif
              endif
           endif


      case cCAMPO == "FORM_PGTO"

           if empty(fFORM_PGTO) ; return .F. ; endif

           if ! FORM_PGT->(dbseek(fFORM_PGTO:=strzero(val(fFORM_PGTO),5)))
               qmensa("Forma de Pagamento n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(FORM_PGT->Descricao,20))

      case cCAMPO == "TIPOCONT"

           if empty(fTIPOCONT) ; return .F. ; endif

           if ! TIPOCONT->(dbseek(fTIPOCONT))
               qmensa("Tipo Cont bil n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,20))

      case cCAMPO == "SERIE"

           if empty(fSERIE) ; return .F. ; endif

           if ! SERIE->(dbseek(fSERIE))
               qmensa("S‚rie n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(SERIE->Descricao,10))

      case cCAMPO == "ESPECIE"

           if empty(fESPECIE) ; return .F. ; endif

           if ! ESPECIE->(dbseek(fESPECIE))
               qmensa("Esp‚cie n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(ESPECIE->Descricao,10))

      case cCAMPO == "FILIAL"

           if empty(fFILIAL) ; return .F. ; endif

           if ! FILIAL->(dbseek(fFILIAL))
               qmensa("Filial n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,20))

      case cCAMPO == "CENTRO"

           if empty(fCENTRO) ; return .F. ; endif

           if ! CCUSTO->(dbseek(fCENTRO))
               qmensa("Centro de Custo n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(CCUSTO->Descricao,20))

      case cCAMPO == "FORMA"
           if empty(fFORMA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fFORMA,"COE",{"Cheque","Ordem","Especie"}))
           if fFORMA = "E"
              fBANCO := "99999"
           endif

      case  cCAMPO == "COD_FAV"


           if ! FUN->(dbseek(fCOD_FAV:=strzero(val(fCOD_FAV),6)))
               qmensa("Funcionario n„o Cadastrado !","B")
               qmensa("")
           else
               fFAVORECIDO := left(FUN->Nome,47)
               qrsay(XNIVEL+1,left(FUN->Nome,40))

           endif


   endcase

return .T.
////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA IMPRESSAO DO CHEQUE ______________________________
static function i_cheque()

   local cEXTENSO

   if POS_CHEQ->(Dbseek(PAG_VIST->Banco))

      if ! qinitprn() ; return ; endif

      @ prow()+1,val(POS_CHEQ->Valor) say "## " + transform(PAG_VIST->Valor,"@E 999,999.99") + " ##"

      cEXTENSO := qextenso(PAG_VIST->Valor)
      nTAM := len(cEXTENSO)

      @ prow()+2,val(POS_CHEQ->Extenso)      say iif( nTAM > val(POS_CHEQ->Linha) , left(cEXTENSO, val(POS_CHEQ->Linha) ) , cEXTENSO  )

      if nTAM > val(POS_CHEQ->Linha)
         @ prow()+1,val(POS_CHEQ->Extenso)-6   say substr( cEXTENSO, val(POS_CHEQ->Linha)+1, nTAM )
      else
         @ prow()+1,0 say ""
      endif

      @ prow()+2,val(POS_CHEQ->Nominal) say PAG_VIST->Favorecido
      @ prow()+3,val(POS_CHEQ->Cidade)  say iif( CGM-> (Dbseek("041000"))    , left(CGM->Municipio,10) , space(10) )
      @ prow()  ,val(POS_CHEQ->Dia)     say left(dtoc(XDATASYS),2)
      @ prow()  ,val(POS_CHEQ->Mes)     say qnomemes(XDATASYS)
      @ prow()  ,val(POS_CHEQ->Ano)     say right(dtoc(XDATASYS),2)

      @ prow()+3,0 say ""

      qstopprn()
   else
      qmensa("N„o existe lay-out de cheques ...","B")
      return .F.
   endif
return

static function i_exclusao

   if QConf("Confirma exclusao deste Pagamento a Vista?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("VALE"+PAG_VIST->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      MOV_CAIX->(Dbsetorder(2))
      if MOV_CAIX->(Dbseek("VALE"+PAG_VIST->Codigo))
         MOV_CAIX->(Qrlock())
         MOV_CAIX->(Dbdelete())
         MOV_CAIX->(Qunlock())
      endif

      PAG_VIST->(Qrlock())
      PAG_VIST->(Dbdelete())
      PAG_VIST->(Qunlock())
   endif
return


