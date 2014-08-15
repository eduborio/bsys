/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE PONTOS POR REPRES
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: ABRIL DE 2010
// OBS........:
// ALTERACOES.:

function cl111
METAS->(qview({{"Codigo/Codigo"               ,1},;
             {"Cod_repres/Cod. Repres"         ,2},;
             {"left(Repres,30)/Razao"          ,3},;
             {"Ano/Ano"          ,0},;
             {"transform(Meta,'@E 999,999,999.99')/Meta anual",0}},"P",;
             {NIL,"c111a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c111a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "I*E*C*A"

      qlbloc(5,0,"B111A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao()

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_REPRES).or.(XNIVEL==2.and.!XFLAG).or.!empty(fCOD_REPRES).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , METAS->Codigo     )
      qrsay ( XNIVEL++ , METAS->Cod_repres );REPRES->(Dbseek(METAS->Cod_repres))
      qrsay ( XNIVEL++ , left(REPRES->Razao,50))
      qrsay ( XNIVEL++ , METAS->Ano)
      qrsay ( XNIVEL++ , METAS->Meta,"@E 999,999,999.99")
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"})
   aadd(aEDICAO,{{ || view_repres(-1,0,@fCOD_REPRES,"@!")                 },"COD_REPRES"})
   aadd(aEDICAO,{{ || NIL                                                 },"RAZAO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fANO,"9999")                            },"ANO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMETA   ,"@E 999,999,999.99")           },"META"})



   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   METAS->(qpublicfields())
   iif(cOPCAO=="I",METAS->(qinitfields()),METAS->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; METAS->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. METAS->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO REPRESENTANTE __________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_meta with CONFIG->Cod_meta + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_meta,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif
      fCODIGO:=strzero(val(fCODIGO),5)

      METAS->(qreplacefields())

   else

      if empty(METAS->Codigo) .and. empty(METAS->Cod_repres)
         METAS->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()


return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREG,nINDEX := 0

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "COD_REPRES"

         if empty(fCOD_REPRES) ; return .F. ; endif
         qrsay(XNIVEL,fCOD_REPRES:=strzero(val(fCOD_REPRES),5))

         nREG := METAS->(Recno())
         nINDEX := METAS->(Indexord())
         METAS->(Dbsetorder(2))

         if cOPCAO == "I"
            if METAS->(dbseek(fCOD_REPRES))
               qmensa("Representante ja cadastrado !","B")
               return .F.
            endif
         endif


         if ! REPRES->(dbseek(fCOD_REPRES))
            qmensa("Representante n„o encontrado !","B")
            return .F.
         endif

         qrsay(XNIVEL+1,left(REPRES->Razao,40))

         fREPRES := REPRES->Razao

         METAS->(Dbgoto(nREG))
         METAS->(Dbsetorder(nINDEX))
         //fDATA_INI := date()
         //qrsay(XNIVEL+2,fDATA_INI)


   endcase

return .T.



static function i_exclusao

   alert("A Exclusao deste lancamento eliminara todos os pontos deste Representante...")

   if qconf("Confirma Exclus„o ?")
      if METAS->(qrlock())
         METAS->(dbdelete())
         METAS->(qunlock())
      else
         qm3()
      endif
   endif
return


