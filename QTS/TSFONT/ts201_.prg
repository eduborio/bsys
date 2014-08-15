/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE CHEQUES PRE-DATADOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function ts201

//#include "inkey.ch"
//#include "setcurs.ch"

BANCO->(Dbsetorder(3))
/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

CHEQUES->(qview({{"Codigo/C¢d."                        ,1},;
              {"fu_conv_cgccpf(CGCCPF)/CNPJ/CPF"        ,6},;
              {"left(Emitente,27)/Emitente"            ,2},;
              {"Data_venc/Venc."                       ,3},;
              {"Cheque/Cheque"                         ,4},;
              {"i_201b()/Banco"                        ,0},;
              {"Valor/Valor"                           ,0}},"P",;
              {NIL,"i_201a",NIL,NIL},;
              NIL,q_msg_acesso_usr()+"<B>aixa Todos"))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_201b
  BANCO->(Dbseek(CHEQUES->Cod_banco))
return left(BANCO->Descricao,20)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_201a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "B"
      qlbloc(10,07,"B201B","QBLOC.GLO",1)
      i_baixa()
   endif

   if cOPCAO $ XUSRA
      qlbloc(08,06,"B201A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_edicao

   local lCONF := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fCGCCPF).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , CHEQUES->Codigo            )
      qrsay ( XNIVEL++ , fu_conv_cgccpf(CHEQUES->Cgccpf))
      qrsay ( XNIVEL++ , CHEQUES->Cod_Emi           )
      qrsay ( XNIVEL++ , left(CHEQUES->Emitente,40)  )
      qrsay ( XNIVEL++ , CHEQUES->Data_venc , "@D"  )
      qrsay ( XNIVEL++ , CHEQUES->Cod_Banco         ) ; BANCO->(Dbseek(CHEQUES->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao           )
      qrsay ( XNIVEL++ , CHEQUES->Cheque            )
      qrsay ( XNIVEL++ , CHEQUES->Valor     , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , CHEQUES->Data_bx   , "@D"  )
      qrsay ( XNIVEL++ , CHEQUES->Obs_lanc          )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF, "@R 99.999.999/9999-99") } ,"CGCCPF"    })
   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_EMI)                      },"COD_EMI"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEMITENTE , "@!S40"                ) } ,"EMITENTE"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_VENC, "@D"                ) } ,"DATA_VENC" })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_BANCO)                  },"COD_BANCO"  })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCHEQUE   , "@!"                ) } ,"CHEQUE"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    , "@E 9,999,999.99"   ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_BX  , "@D"                ) } ,"DATA_BX"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS_LANC , "@!"                ) } ,"OBS_LANC"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CHEQUES->(qpublicfields())

   iif(cOPCAO=="I",CHEQUES->(qinitfields()),CHEQUES->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CHEQUES->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CHEQUES->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_cheq with CONFIG->Cod_cheq+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_cheq,5),"B")
         fCODIGO := strzero(CONFIG->Cod_cheq,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      CHEQUES->(qreplacefields())
      CHEQUES->(dbgotop())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   local nDIA := 0
   local nREG := 0
   local nORDEM := 0

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "CGCCPF"

           CHEQUES->(dbsetorder(6))

           if cOPCAO == "I" .and. CHEQUES->(dbseek(fCGCCPF) )
              fEMITENTE := CHEQUES->Emitente
           endif

           qrsay(XNIVEL,fu_conv_cgccpf(fCGCCPF) )

           CHEQUES->(dbsetorder(1))

      case cCAMPO == "DATA_VENC"

           if empty(fDATA_VENC) ; return .F. ; endif

      case cCAMPO == "VALOR"

           if fVALOR == 0 ; return .F. ; endif

           if cOPCAO == "I"
              nREG := CHEQUES->(Recno())
              nORDEM := CHEQUES->(Indexord())

              CHEQUES->(Dbsetorder(9))
              if CHEQUES->(Dbseek(Val(fCHEQUE)+fVALOR))
                 qmensa("Este Cheque ja foi Lan‡ado !","B")
                 return .F.
                 Qmensa("")
              endif

              CHEQUES->(Dbsetorder(nORDEM))
              CHEQUES->(Dbgoto(nREG))
           endif


      case cCAMPO == "COD_BANCO"

           if empty(fCOD_BANCO) ; return .F. ; endif

           if ! BANCO->(dbseek(fCOD_BANCO:=strzero(val(fCOD_BANCO),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,30))

      case cCAMPO == "COD_EMI"

           //if empty(fCOD_EMI) ; return .F. ; endif

           if ! CLI1->(dbseek(fCOD_EMI:=strzero(val(fCOD_EMI),5)))
               qmensa("Cliente n„o Cadastrado !","B")
               qmensa("")
           else
               qrsay(XNIVEL+1,left(CLI1->Razao,40))
               fEMITENTE := CLI1->Razao
           endif



   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR INCLUSAO DE CHEQUES _______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Movimento do Cheque ?")
      if CHEQUES->(qrlock())
         CHEQUES->(dbdelete())
         CHEQUES->(qunlock())
      else
         qm3()
      endif
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA BAIXAR CHEQUES PRE-DATADOS PELA DATA DO VENCIMENTO _______________

static function i_baixa

    private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}
    private XNIVEL := 1
    private XFLAG  := .T.
    private aEDICAO  := {}
    private dDATA_VENC  := ctod("")
    private dDATA_BAIXA := ctod("")
    private lCONF

    aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC  ,"@D"              ) } ,"DATA_VENC" })
    aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_BAIXA ,"@D"              ) } ,"DATA_BAIXA"})
    aadd(aEDICAO,{{ || lCONF := qconf("Confirma Data Vencimento ?") },NIL})

    // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE ) ; CONH_FRE->(qreleasefields()) ; return ; endif
       if ! i_crit_1( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
    enddo

    if ! lCONF ; return .F. ; endif

    qmensa("Aguarde... Baixando Lan‡amentos...")

    CHEQUES->(Dbsetorder(3))
    CHEQUES->(Dbgotop())
    set softseek on
    if CHEQUES->(Dbseek(dDATA_VENC))
       do while ! CHEQUES->(eof()) .and. CHEQUES->Data_venc >= dDATA_VENC .and. CHEQUES->Data_venc <= dDATA_VENC
          if CHEQUES->(qrlock()) .and. empty(CHEQUES->Data_bx)
             replace CHEQUES->Data_bx with dDATA_BAIXA
             CHEQUES->(qunlock())
          endif
          CHEQUES->(Dbskip())
       enddo
    else
       qmensa("N„o Existem lan‡amentos Nesta Data de Vencimento nem Superior !!","B")
    endif

    qmensa("")
    CHEQUES->(Dbsetorder(1))

return
