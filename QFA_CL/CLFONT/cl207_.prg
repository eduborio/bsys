/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE SETORES
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MAIO DE 1998
// OBS........:
// ALTERACOES.:

function cl207
PREMIO->(qview({{"Data/Data"                      ,1},;
                {"f207repres()/Representante"     ,2},;
                {"left(Descricao,20)/Premio"      ,3},;
                {"Pontos/Pontos",0}},"P",;
                {NIL,"c207a",NIL,NIL},;
                NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c207a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(10,5,"B207A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

function f207repres
local cRazao

   REPRES->(dbseek(PREMIO->Cod_repres))
   cRazao := left(REPRES->Razao,30)


return cRazao

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao()

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDATA).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PREMIO->Codigo     )
      qrsay ( XNIVEL++ , PREMIO->Data ,"@D" )
      qrsay ( XNIVEL++ , PREMIO->Cod_repres );REPRES->(Dbseek(PREMIO->Cod_repres))
      qrsay ( XNIVEL++ , left(REPRES->Razao,50) )
      qrsay ( XNIVEL++ , PREMIO->Descricao  )
      qrsay ( XNIVEL++ , PREMIO->Pontos,"@E 99,999,999.99"  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA,"@D")                             },"DATA"})
   aadd(aEDICAO,{{ || view_repres(-1,0,@fCOD_REPRES,"99999")                    },"COD_REPRES"})
   aadd(aEDICAO,{{ || NIL                                                 },"RAZAO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")                        },"DESCRICAO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPONTOS,"@E 99,999,999.99")                           },"PONTOS"})


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PREMIO->(qpublicfields())
   iif(cOPCAO=="I",PREMIO->(qinitfields()),PREMIO->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PREMIO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. PREMIO->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      if cOPCAO == "I"
         replace CONFIG->cod_premio with CONFIG->cod_premio + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->cod_premio,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      fCODIGO:=strzero(val(fCODIGO),5)

      MILHAS->(dbsetorder(2))

      if cOPCAO == "A"

         if MILHAS->(Dbseek(fCod_repres)) .and. MILHAS->(qrlock())
            replace MILHAS->Pontos with MILHAS->Pontos + PREMIO->Pontos
            MILHAS->(Qunlock())
         else
            return .F.
         endif


      endif

      MILHAS->(dbsetorder(2))

      if MILHAS->(Dbseek(fCod_repres)) .and. MILHAS->(qrlock())
         replace MILHAS->Pontos with MILHAS->Pontos - fPONTOS
         MILHAS->(Qunlock())
      else
         return .F.
      endif

      PREMIO->(qreplacefields())

   else


      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DESCRICAO"
           if empty(fDESCRICAO) ; return .F. ; endif

      case cCAMPO == "COD_REPRES"

           qrsay(XNIVEL,fCOD_REPRES)

           if empty(fCOD_REPRES)
              Qmensa("Campo Obrigatorio...","B")
              return .F.
           else
              if ! REPRES->(Dbseek(fCOD_REPRES))
                 qmensa("Representante n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(REPRES->Razao,50))
              endif
              XNIVEL++
           endif

   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR SETOREDORA  ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste(a) Setor ?")

      MILHAS->(dbsetorder(2))

      if MILHAS->(Dbseek(PREMIO->Cod_repres)) .and. MILHAS->(qrlock())
         replace MILHAS->Pontos with MILHAS->Pontos + PREMIO->Pontos
         MILHAS->(Qunlock())
      else
         return .F.
      endif


      if PREMIO->(qrlock())
         PREMIO->(dbdelete())
         PREMIO->(qunlock())
      else
         qm3()
      endif
   endif
return
