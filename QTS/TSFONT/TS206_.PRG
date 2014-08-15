/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE OPERACOES DE MUTUO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: NOVEMBRO DE 1997
// OBS........:
// ALTERACOES.:
function ts206

#include "inkey.ch"
#include "setcurs.ch"

fu_abre_qinst()

private sBLOC1  := qlbloc("B206B","QBLOC.GLO")

BANCO->(Dbsetorder(3))
CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE MUTUO _____________________________________

MUTUO->(qview({{"Codigo/C¢d."                        ,0},;
               {"i_206b()/Tipo"                      ,0},;
               {"Data_venc/Vencimento"               ,0},;
               {"i_206c()/Valor"                     ,0}},"P",;
               {NIL,"i_206a",NIL,NIL},;
               {"Data==XDATA",{||i206top()},{||i206bot()}},;
               "<I>ncluir/<C>onsultar"))

return ""

function i206top
   MUTUO->(Dbsetorder(2))
   MUTUO->(dbseek(dtos(XDATA)))
return
function i206bot
   MUTUO->(Dbsetorder(2))
   MUTUO->(qseekn(dtos(XDATA)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR VALOR COM PICTURE ___________________________________

function i_206c
return transform(Valor,"@R 999,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_206b
  TIPOCONT->(Dbseek(MUTUO->Tpo_origem))
return left(TIPOCONT->Descricao,40)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_206a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "IC"
      qlbloc(06,01,"B206A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fDOCTO).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , MUTUO->Codigo            )
      qrsay ( XNIVEL++ , MUTUO->Docto             )
      qrsay ( XNIVEL++ , MUTUO->Emp_origem        ) ; QINST->(Dbseek(MUTUO->Emp_origem))
      qrsay ( XNIVEL++ , left(QINST->Razao,35))
      qrsay ( XNIVEL++ , MUTUO->Centro_ori        ) ; CCUSTO->(Dbseek(MUTUO->Centro_ori))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,35))
      qrsay ( XNIVEL++ , MUTUO->Tpo_origem        ) ; TIPOCONT->(Dbseek(MUTUO->Tpo_origem))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,35))
      qrsay ( XNIVEL++ , MUTUO->Banco_orig        ) ; BANCO->(Dbseek(MUTUO->Banco_orig))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20))
      qrsay ( XNIVEL++ , MUTUO->Form_pgto         ) ; FORM_PGT->(Dbseek(MUTUO->Form_pgto))
      qrsay ( XNIVEL++ , left(FORM_PGT->Descricao,20)   )

      qrsay ( XNIVEL++ , MUTUO->Emp_destin         ) ; QINST->(Dbseek(MUTUO->Emp_destin))
      qrsay ( XNIVEL++ , left(QINST->Razao,35)     )
      qrsay ( XNIVEL++ , MUTUO->Centro_des         ) ; CCUSTO->(Dbseek(MUTUO->Centro_des))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,35))
      qrsay ( XNIVEL++ , MUTUO->Tpo_destin         ) ; TIPOCONT->(Dbseek(MUTUO->Tpo_destin))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,35))
      qrsay ( XNIVEL++ , MUTUO->Banco_dest         ) ; BANCO->(Dbseek(MUTUO->Banco_dest))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20) )

      qrsay ( XNIVEL++ , MUTUO->Data_venc          )
      qrsay ( XNIVEL++ , MUTUO->Valor     , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , MUTUO->Juros     , "@E 99.99"  )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDOCTO, "@!")                     },"DOCTO"      })
   aadd(aEDICAO,{{ || view_emp(-1,0,@fEMP_ORIGEM)                   },"EMP_ORIGEM" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO_ORI)                },"CENTRO_ORI" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_tipo(-1,0,@fTPO_ORIGEM)                  },"TPO_ORIGEM" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO_ORIG)                 },"BANCO_ORIG" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_form(-1,0,@fFORM_PGTO)                  },"FORM_PGTO"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_emp(-1,0,@fEMP_DESTIN)                   },"EMP_DESTIN" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO_DES)                },"CENTRO_DES" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_tipo(-1,0,@fTPO_DESTIN)                  },"TPO_DESTIN" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO_DEST)                 },"BANCO_DEST" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_VENC, "@D")                 },"DATA_VENC"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    , "@E 9,999,999.99"   ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fJUROS    , "@E 99.99"          ) } ,"JUROS"     })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MUTUO->(qpublicfields())

   iif(cOPCAO=="I",MUTUO->(qinitfields()),MUTUO->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; MUTUO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if MUTUO->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_mutuo with CONFIG->Cod_mutuo+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_mutuo,5),"B")
         fCODIGO := strzero(CONFIG->Cod_mutuo,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fDATA := XDATA

      MUTUO->(qreplacefields())
      MUTUO->(dbgotop())

      if cOPCAO == "I"

         MOV_BANC->(qappend())  // origem

         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fBANCO_ORIG
         replace MOV_BANC->Form_pgto with fFORM_PGTO
         replace MOV_BANC->Historico with "OPERACAO DE MUTUO"
         replace MOV_BANC->Saida     with fVALOR
         replace MOV_BANC->Concilia  with "0"

         MOV_BANC->(qappend())    // destino

         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fBANCO_DEST
         replace MOV_BANC->Form_pgto with fFORM_PGTO
         replace MOV_BANC->Historico with "OPERACAO DE MUTUO"
         replace MOV_BANC->Entrada   with fVALOR
         replace MOV_BANC->Concilia  with "0"
      endif

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

// if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   local nDIA := 0

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "EMP_ORIGEM"

           if empty(fEMP_ORIGEM) ; return .F. ; endif

           if ! QINST->(dbseek(fEMP_ORIGEM:=strzero(val(fEMP_ORIGEM),3)))
               qmensa("Empresa n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(QINST->Razao,20))

      case cCAMPO == "EMP_DESTIN"

           if empty(fEMP_DESTIN) ; return .F. ; endif

           if ! QINST->(dbseek(fEMP_DESTIN:=strzero(val(fEMP_DESTIN),3)))
               qmensa("Empresa n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(QINST->Razao,20))

      case cCAMPO == "BANCO_ORIG"

           if empty(fBANCO_ORIG) ; return .F. ; endif

           if ! BANCO->(dbseek(fBANCO_ORIG:=strzero(val(fBANCO_ORIG),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,20))

      case cCAMPO == "BANCO_DEST"

           if empty(fBANCO_DEST) ; return .F. ; endif

           if ! BANCO->(dbseek(fBANCO_DEST:=strzero(val(fBANCO_DEST),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,20))

      case cCAMPO == "FORM_PGTO"

           if empty(fFORM_PGTO) ; return .F. ; endif

           if ! FORM_PGT->(dbseek(fFORM_PGTO:=strzero(val(fFORM_PGTO),5)))
               qmensa("Forma de Pagamento n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(FORM_PGT->Descricao,20))

      case cCAMPO == "TPO_ORIGEM"

           if empty(fTPO_ORIGEM) ; return .F. ; endif

           if ! TIPOCONT->(dbseek(fTPO_ORIGEM))
               qmensa("Tipo Cont bil n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,20))

      case cCAMPO == "TPO_DESTIN"

           if empty(fTPO_DESTIN) ; return .F. ; endif

           if ! TIPOCONT->(dbseek(fTPO_DESTIN))
               qmensa("Tipo Cont bil n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,20))

      case cCAMPO == "CENTRO_ORI"

           if empty(fCENTRO_ORI) ; return .F. ; endif

           if ! CCUSTO->(dbseek(fCENTRO_ORI))
               qmensa("Centro de Custo n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(CCUSTO->Descricao,20))

      case cCAMPO == "CENTRO_DES"

           if empty(fCENTRO_DES) ; return .F. ; endif

           if ! CCUSTO->(dbseek(fCENTRO_DES))
               qmensa("Centro de Custo n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(CCUSTO->Descricao,20))

   endcase

return .T.
