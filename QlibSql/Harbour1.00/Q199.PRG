
// MANUTENCAO GERAL DE INDICES MONETARIOS ___________________________________

function q199
static cIND := ""

if ! quse(XDRV_SH,"INDC",{"IC_INDIC","IC_DESCR"}) ; return ; endif
if ! quse(XDRV_SH,"INDV",{"IV_INDIC"})            ; return ; endif

qlbloc(5,0,"B199A",XDRV_SH+"QSBLOC.GLO")

INDC->(qview({{"Descricao/Descri‡„o",2},;
              {"Indice/C¢d."        ,1},;
              {"Periodo/P."         ,0},;
              {"Tipo/T."            ,0}},;
              "05002344",;
              {"f199a","f199b",NIL,NIL} ))

INDC->(dbclosearea())
INDV->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// VIEW DOS VALORES DO INDICE SELECIONADO ___________________________________

function f199a
   private cIND := INDC->Indice
   INDV->(dbseek(cIND))
   INDV->(qview({{"Data_ref/Data",1},;
                 {"transform(Valor,'@E 999,999,999.9999')/Valor",0}},;
                 "05452379",;
                 {NIL,"f199c",NIL,NIL},;
                 {"Indice==cIND",;
                 {||dbseek(cIND)},{||qseekn(cIND)}},;
                 "ALT-P / <I>ncluir / <A>lterar / <E>xcluir / ESC"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f199b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
//   if cOPCAO $ XUSRA
      qlbloc(15,10,"B199B",XDRV_SH+"QSBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
//   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local sBLOC1  := qlbloc("B199C",XDRV_SH+"QSBLOC.GLO")
   local sBLOC2  := qlbloc("B199D",XDRV_SH+"QSBLOC.GLO")
   local bESCAPE := {||empty(fINDICE).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , INDC->Indice    )
      qrsay ( XNIVEL++ , INDC->Descricao )
      qrsay ( XNIVEL++ , qabrev(INDC->Periodo,"MD",{"MENSAL","DIARIO"}) )
      qrsay ( XNIVEL++ , qabrev(INDC->Tipo,"FT",{"FATOR","TAXA"}) )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fINDICE   ,"@!",NIL,cOPCAO=="I") } ,"INDICE"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!") }                 ,"DESCRICAO"})
   aadd(aEDICAO,{{ || qesco(-1,0,@fPERIODO,sBLOC1) }                 ,"PERIODO"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fTIPO,sBLOC2) }                    ,"TIPO"     })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   INDC->(qpublicfields())
   iif(cOPCAO=="I",INDC->(qinitfields()),INDC->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; INDC->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if INDC->(iif(cOPCAO=="I",qappend(),qrlock()))
      INDC->(qreplacefields())
      INDC->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "INDICE" .and. cOPCAO == "I"
           if INDC->(dbseek(fINDICE))
              qmensa("C¢digo j  cadastrado !","B")
              return .F.
           endif
      case cCAMPO == "PERIODO"
           if empty(fPERIODO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fPERIODO,"MD",{"MENSAL","DIARIO"}))
      case cCAMPO == "TIPO"
           if empty(fTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fTIPO,"FT",{"FATOR","TAXA"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// EXECUTA EXCLUSOES ________________________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste indice ?")
      if INDC->(qrlock())
         INDC->(dbdelete())
         INDC->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// INCLUSAO/ALTERACAO/EXCLUSAO DOS VALORES DO INDICE ATUAL __________________

function f199c
   local nCURSOR := setcursor(1)
   local dDATAREF, nVALOR, nROW := row()
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
//   if cOPCAO $ XUSRA
      do case
         case cOPCAO == "I"
              scroll(08,47,22,77,1)
              dDATAREF := ctod("")
              nVALOR   := 0
              qgetx(22,50,@dDATAREF)
              qgetx(22,59,@nVALOR,"@E 999,999,999.9999")
              if qconf("Confirma inclus„o ?") .and. INDV->(qappend())
                 replace INDV->Indice   with cIND
                 replace INDV->Data_ref with dDATAREF
                 replace INDV->Valor    with nVALOR
                 INDV->(qunlock())
              endif
         case cOPCAO == "A"
              dDATAREF := INDV->Data_ref
              nVALOR   := INDV->Valor
              qgetx(nROW,50,@dDATAREF)
              qgetx(nROW,59,@nVALOR,"@E 999,999,999.9999")
              if qconf("Confirma inclus„o ?") .and. INDV->(qrlock())
                 replace INDV->Data_ref with dDATAREF
                 replace INDV->Valor    with nVALOR
                 INDV->(qunlock())
              endif
         case cOPCAO == "E"
              if qconf("Confirma exclus„o ?") .and. INDV->(qrlock())
                 INDV->(dbdelete())
                 INDV->(qunlock())
              endif
      endcase
//   endif
   setcursor(nCURSOR)
return ""

