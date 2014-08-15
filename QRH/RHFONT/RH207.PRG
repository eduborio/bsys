/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: LANCAMENTOS DE BENEFICIOS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: IDEM
// INICIO.....: DEZEMBRO DE 1998
// OBS........:
// ALTERACOES.:

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

local   zTMP                            // variavel temporaria
private cEVENTO                         // codigo do evento
private aBENEF := {}                    // vetor com os beneficios
private cAMBIENTE                       // ambiente sendo trabalhado
private cMATRICULA := space(6)          // matricula do funcionario

FUN->(dbsetorder(1))

cAMBIENTE := rh_escolhe_amb() // "MS","AD","DT","FR","PV"

if empty(cAMBIENTE) ; return ; endif

i_inic_207()

release XTB_GR*

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL PARA LANCAMENTOS ________________________________________

static function i_inic_207

setcolor("W/B")

do while .T.

   qlbloc(5,0,"B207A","QBLOC.GLO")
   qsay(06,07,cAMBIENTE)
   cEVENTO := space(3)

   // SOLICITA CODIGO DO BENEFICIO (EVENTO) _________________________________

   qmensa("F9 para view dos eventos disponiveis...")
   view_event(06,22,@cEVENTO,"999",NIL,.T.)
   qmensa()
   if val(cEVENTO) == 0 ; exit ; endif
   qsay(06,22,cEVENTO := strzero(val(cEVENTO),3))

   if !EVENT->(dbseek(cEVENTO))
      qmensa("Evento n„o encontrado...     ","B")
      loop
   endif

   // PROCURA EVENTO ________________________________________________________

   if ! EVENT->(dbseek(cEVENTO))
      qmensa("Evento n„o cadastrado !","B") ; loop
   endif

   qsay(06,38,EVENT->Descricao)

   // ACIONA BROWSE DE VINCULACAO DE LANCAMENTOS DE FUNCIONARIOS ___________________________

   LAN_OBRA->(dbSetFilter({|| Evento == cEVENTO},'Evento == cEVENTO'))

   LAN_OBRA->(qview({{"Matricula/Matri."                              ,1},;
                  {"c207matr()/Nome do Funcion rio"                   ,0},;
                  {"transform(Centro,'@R 99.99.9999')/Centro de Custo",0},;
                  {"Transform(Horas,'@R 999.9999 ')/Horas"            ,0}},;
                  "07002379",;
                  {NIL,"f207a",NIL,NIL},;
                   NIL,"<I>ncluir/<E>xcluir/<C>onsultar"))
enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function c207matr
   iif(FUN->(dbseek(LAN_OBRA->Matricula)),xVOLTA:=(left(FUN->Nome,42)),xVOLTA:=(Space(42)))
return xVOLTA

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

function f207a

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "IEC"
      qlbloc(10,10,"B207B","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif
   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fMATRICULA).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , LAN_OBRA->Matricula ) ; FUN->(dbseek(LAN_OBRA->Matricula))
      qrsay ( XNIVEL++ , left(FUN->Nome,30)           )
      qrsay ( XNIVEL++ , transform(LAN_OBRA->Centro,"@R 99.99.9999")) ; CCUSTO->(dbseek(LAN_OBRA->Centro))
      qrsay ( XNIVEL++ , CCUSTO->Descricao   )
      qrsay ( XNIVEL++ , LAN_OBRA->Horas  , "@E 999.9999" )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_fun(-1,0,@fMATRICULA)                  },"MATRICULA" })
   aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO)                     },"CENTRO"    })
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHORAS     ,"999.9999",NIL,.T.) },"HORAS"     })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   LAN_OBRA->(qpublicfields())
   iif(cOPCAO=="I",LAN_OBRA->(qinitfields()),LAN_OBRA->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; LAN_OBRA->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if LAN_OBRA->(iif(cOPCAO=="I",qappend(),qrlock()))
      fANOMES := XANOMES
      fEVENTO := cEVENTO
      fAMBIENTE := cAMBIENTE
      LAN_OBRA->(qreplacefields())
      LAN_OBRA->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   LANC->(dbseek(fANOMES+fMATRICULA+cAMBIENTE+cEVENTO))

   if cOPCAO == "I"
      if LANC->(eof())
         LANC->(dbappend())
         replace LANC->Anomes    with fANOMES
         replace LANC->Matricula with fMATRICULA
         replace LANC->Ambiente  with cAMBIENTE
         replace LANC->Evento    with cEVENTO
         replace LANC->Fracao    with fHORAS
      else
        if LANC->(qrlock())
           replace LANC->Fracao with ( LANC->Fracao + fHORAS )
           LANC->(qunlock())
        endif
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   local nSOMA
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "MATRICULA"
           if ! FUN->(dbseek(fMATRICULA:=strzero(val(fMATRICULA),6)))
              qmensa("Funcionario n„o Cadastrado !","B")
              return .F.
           else
             if FUN->Situacao <> "T"
                qmensa("Funcionario n„o Est  Trabalhando !","B")
                return .F.
             endif
           endif
           qrsay(XNIVEL,fMATRICULA)
           qrsay(XNIVEL+1,left(FUN->Nome,30))

      case cCAMPO == "CENTRO"
           if ! CCUSTO->(dbseek(fCENTRO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           else
              if right(fCENTRO,4) == "    "
                 qmensa("Centro de Custo n„o ‚ Valido, Verifique...","B")
                 Return .F.
              Endif
           endif
           qrsay(XNIVEL+1,CCUSTO->Descricao)
           if LAN_OBRA->(dbseek(fMATRICULA+XANOMES+cAMBIENTE+fCENTRO)) .and. cOPCAO == "I"
              qmensa("Existe lan‡amento neste Centro de Custo !","B")
              return .F.
           endif
      case cCAMPO == "HORAS"
           if fHORAS <= 0 ; return .F. ; endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR LANCAMENTOS _______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Lan‡amento ?")

      if LANC->(dbseek(LAN_OBRA->Anomes+LAN_OBRA->Matricula+LAN_OBRA->Ambiente+LAN_OBRA->Evento))
         if LANC->Fracao <> 0
            if LANC->(qrlock())
               replace LANC->Fracao with (LANC->Fracao - LAN_OBRA->Horas)
            endif
         else
            if LANC->(qrlock())
               LANC->(dbdelete())
            endif
         endif
         LANC->(qunlock())
      endif

      if LAN_OBRA->(qrlock())
         LAN_OBRA->(dbdelete())
         LAN_OBRA->(qunlock())
      else
         qm3()
      endif
   endif
return
