/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A /PAGAR
// OBJETIVO...: INCLUSAO DE LANCAMENTO DE DESPESAS COM TERCEIROS A PAGAR
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: OUTUBRO DE 1997
// OBS........:
// ALTERACOES.:


function pg206
#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

// VIEW INICIAL _____________________________________________________________



LCTO_TER->(qview({{"Codigo/C¢digo"             ,1},;
                  {"Nr_af/A.F."                ,0},;
                  {"Conhe_nr/Conh.Nr."         ,0},;
                  {"Data_vcto/Vencimento"      ,0},;
                  {"Valor_terc/Valor"          ,0},;
                  {"f_206b()/Terceiro"         ,0},;
                  {"f_206c()/Pago"             ,0}},"P",;
                  {NIL,"f206a",NIL,NIL},;
                  NIL,"ESC/ALT-P/ALT-O/<I>nc/<A>lt/<E>xc/<C>on/<P>agar"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM SE ESTA PAGO OU NAO ________________________________
function f_206c
  if empty(LCTO_TER->Data_pgto)
     return "NAO"
  endif
return "SIM"

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DA DESPESA __________________________________________

function f_206b
  TERCEIRO->(dbseek(LCTO_TER->Cod_terc))
return left(TERCEIRO->Nome,26)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f206a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(11,06,"B206A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   if cOPCAO == "P"
      if ! empty(LCTO_TER->Data_pgto)
         qmensa("Lan‡amento ja foi pago...","B")
         return .F.
      endif
      i_paga()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fNR_AF).or.(XNIVEL==1.and.!XFLAG).or. !empty(fNR_AF).and.XNIVEL==2 .and. Lastkey()==27 .or.;
                         (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if ! cOPCAO $ "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , LCTO_TER->Codigo         )
      qrsay ( XNIVEL++ , LCTO_TER->Nr_af          )
      qrsay ( XNIVEL++ , LCTO_TER->Conhe_nr       )
      qrsay ( XNIVEL++ , transform(LCTO_TER->Valor_dup,"@E 9,999,999.99" ))
      qrsay ( XNIVEL++ , dtoc(LCTO_TER->Data_vcto))
      qrsay ( XNIVEL++ , LCTO_TER->Cod_terc       ) ; TERCEIRO->(Dbseek(LCTO_TER->Cod_terc))
      qrsay ( XNIVEL++ , left(TERCEIRO->Nome,30)  )
      qrsay ( XNIVEL++ , dtoc(LCTO_TER->Data_emiss))
      qrsay ( XNIVEL++ , transform(LCTO_TER->Aliquota,"@E 99.99"))
      qrsay ( XNIVEL++ , transform(LCTO_TER->Valor_terc,"@E 9,999,999.99" ))
      qrsay ( XNIVEL++ , transform(LCTO_TER->Fr_numero,"@E 999999" ))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL }                                         ,NIL         })  // codigo nao pode ser editado
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNR_AF                        ) } ,"NR_AF"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONHE_NR                     ) } ,"CONHE_NR"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_DUP,"@E 9,999,999.99"  ) } ,"VALOR_DUP" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_VCTO                    ) } ,"DATA_VCTO" })
   aadd(aEDICAO,{{ || view_terc(-1,0,@fCOD_TERC                 ) } ,"COD_TERC"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMISS                   ) } ,"DATA_EMISS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQUOTA ,"@E 99.99"         ) } ,"ALIQUOTA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_TERC,"@E 9,999,999.99" ) } ,"VALOR_TERC"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFR_NUMERO,"@E 999999"        ) } ,"FR_NUMERO" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   LCTO_TER->(qpublicfields())
   iif(cOPCAO=="I",LCTO_TER->(qinitfields()),LCTO_TER->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   if cOPCAO == "I"
      fCODIGO := strzero(CONFIG->Cod_terc + 1,5)
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; LCTO_TER->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if LCTO_TER->(iif(cOPCAO=="I",qappend(),qrlock()))
      LCTO_TER->(qreplacefields())
      LCTO_TER->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Cod_terc with val(fCODIGO)
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "COD_TERC"

           if ! empty(fCOD_TERC)

              if ! TERCEIRO->(Dbseek(fCOD_TERC:=strzero(val(fCOD_TERC),5)))

                 qmensa("Terceiro n„o Econtrado !!!","B")

                 return .F.

              else

                 qrsay(XNIVEL+1,left(TERCEIRO->Nome,30))

              endif

           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR O LCTO DE TERCEIRO ___________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Lancamento ?")
      if LCTO_TER->(qrlock())
         LCTO_TER->(dbdelete())
         LCTO_TER->(qunlock())
      else
         qm3()
      endif
   endif
return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DAR BAIXA NO LACTO __________________________________________

static function i_paga

   local lCONF

   lCONF :=  qconf("Confirma Pagamento ao Terceiro? ")

   if ! lCONF ; return .F. ; endif

   if LCTO_TER->(qrlock())
      replace LCTO_TER->Data_pgto with XDATASYS
      LCTO_TER->(qunlock())
   endif

return
