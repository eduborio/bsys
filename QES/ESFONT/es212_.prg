 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE ENTRADAS SEM CONTABILIZACAO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: SETEMBRO DE 2006
// OBS........:
// ALTERACOES.:
function es212

cDATA := Date()
cFILIAL := "0001"

PROD->(dbsetorder(4))

MOV_PROJ->(dbSetFilter({|| Tipo == "EA" }, 'Tipo == "EA" '))

MOV_PROJ->(qview({{"Data/Data"                    ,2},;
                  {"Cod_Prod/Cod"                 ,3},;
                  {"c212b()/Produto"              ,4},;
                  {"c212d()/Projeto"              ,5},;
                  {"Quantidade/Quantidade"        ,0}},"P",;
                  {NIL,"c212c",NIL,NIL},;
                   NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DA FILIAL ________________________________

function c212d
  PROJET->(dbseek(MOV_PROJ->Cod_proj))
return left(PROJET->Descricao,15)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO _______________________________

function c212b
  PROD->(dbseek(MOV_PROJ->(Cod_Prod)))
return left(PROD->Descricao,25)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c212c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "I*E*C"
      qlbloc(11,6,"B212A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , MOV_PROJ->Data       )
      qrsay ( XNIVEL++ , MOV_PROJ->Filial     ) ; FILIAL->(dbseek(MOV_PROJ->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,30))

      qrsay ( XNIVEL++ , MOV_PROJ->Cod_proj   ) ; PROJET->(dbseek(MOV_PROJ->Cod_proj))
      qrsay ( XNIVEL++ , left(PROJET->Descricao,50)) ; EVENTOS->(Dbseek(PROJET->Cod_eve))
      qrsay ( XNIVEL++ , EVENTOS->Codigo      )
      qrsay ( XNIVEL++ , left(EVENTOS->Nome,50))


      qrsay ( XNIVEL++ , MOV_PROJ->Cod_prod   ) ; PROD->(dbseek(MOV_PROJ->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,50)) //+" "+left(PROD->Cod_fabr,4)  )
      qrsay ( XNIVEL++ , MOV_PROJ->Quantidade,"@R 9999999.999" )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   fDATA  := cDATA
   fFILIAL:= cFILIAL


   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@cDATA         ,"@D")                    },"DATA"       })
   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL)                          },"FILIAL"     })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })

   aadd(aEDICAO,{{ || view_proj(-1,0,@fCOD_PROJ)                          },"COD_PROJ"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })

   aadd(aEDICAO,{{ || view_prod1(-1,0,@fCOD_PROD)                          },"COD_PROD"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE    ,"9999999.999")          },"QUANTIDADE" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MOV_PROJ->(qpublicfields())
   iif(cOPCAO=="I",MOV_PROJ->(qinitfields()),MOV_PROJ->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; MOV_PROJ->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if MOV_PROJ->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fES    := "E"       // para determinar que a operacao ‚ de entrada
      fTIPO  := "EA"      //ENTRADA de Aluguel
      fDATA  := cDATA
      fFILIAL:= cFILIAL

      if cOPCAO == "I"
         if CONFIG->(Qrlock())
            replace CONFIG->Cod_Movpro with CONFIG->Cod_movpro + 1
            //qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_movpro,7) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
            CONFIG->(qunlock())
         endif
      endif


      MOV_PROJ->(qreplacefields())
      PROD->(DbSeek(MOV_PROJ->Cod_prod))

      INVENT->(Dbsetorder(4))
      INVENT->(Dbseek(MOV_PROJ->Cod_prod))

      INVENT->(Dbsetorder(4))
      if INVENT->(Dbseek(MOV_PROJ->Cod_prod)) .and. INVENT->(qrlock()) .and. MOV_PROJ->(qrlock())
         replace INVENT->Quant_atu    with ( INVENT->Quant_atu  + MOV_PROJ->Quantidade )
      else
        qmensa("Produto n„o encontrado...","B")
        return
      endif

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

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DATA"
           fFILIAL := "0001"
           qrsay(XNIVEL+1,fFILIAL)

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
           qrsay(XNIVEL,fCOD_PROD)

           if ! PROD->(dbseek(fCOD_PROD:=strzero(val(fCOD_PROD),5)))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(PROD->Descricao,50)) //"\"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
           fDESC_PROD := PROD->Descricao

      case cCAMPO == "COD_PROJ"

           if empty(fCOD_PROJ) ; return .F. ; endif
           qrsay(XNIVEL,fCOD_PROJ)

           if ! PROJET->(dbseek(fCOD_PROJ:=strzero(val(fCOD_PROJ),5)))
              qmensa("Projeto n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(PROJET->Descricao,50))
           fDESC_PROJ := PROJET->Descricao

           if EVENTOS->(Dbseek(PROJET->Cod_eve))
              qrsay(XNIVEL+2,left(EVENTOS->Codigo,5))
              qrsay(XNIVEL+3,left(EVENTOS->Nome,50))
           endif


      case cCAMPO == "QUANTIDADE"
           if empty(fQUANTIDADE) ; return .F. ; endif

   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ENTRADA ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Entrada de Aluguel ?")
      if MOV_PROJ->(qrlock())
         PROD->(Dbsetorder(4))
         INVENT->(Dbsetorder(4))

         if INVENT->(Dbseek(MOV_PROJ->Cod_prod)) .and. INVENT->(qrlock())
            replace INVENT->Quant_atu    with ( INVENT->Quant_atu  - MOV_PROJ->Quantidade )
         endif

         MOV_PROJ->(dbdelete())
         INVENT->(qunlock())
         MOV_PROJ->(qunlock())
      else
         qm3()
      endif
   endif
return
