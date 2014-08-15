/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE FATURAMENTO POR PREPOSTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2001
// OBS........:
// ALTERACOES.:

function cl521
#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cPREP
private cPREP_DESC
private nVALOR
private aEDICAO := {}             // vetor para os campos de entrada de dados

ITEN_FAT->(dbsetorder(4)) // Numero da fatura + preposto

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prep(-1,0,@cPREP)       } ,"PREP"    })
aadd(aEDICAO,{{ || NIL                          } ,NIL       })

do while .T.

   qlbloc(5,0,"B521A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cPREP  := space(5)
   cPREP_DESC := space(45)
   dINI := dFIM := ctod("")
   nVALOR := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "PREP"
           if empty(cPREP) ; return .F. ; endif
           qrsay(XNIVEL,cPREP:=strzero(val(cPREP),5))
           if ! PREP->(dbseek(cPREP))
               qmensa("Preposto inv lido !","B")
               return .F.
           else
              qrsay(XNIVEL+1,left(PREP->Descricao,38))
              cPREP_DESC := left(PREP->Descricao,45)
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "PREPOSTO...: " + left(cPREP_DESC,30) + " de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local lTEM := .F.
   local nTOT_VAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "Pedido     Cod    Cliente                                         Emissao                   Valor"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      if ITEN_FAT->(Dbseek(FAT->Codigo+cPREP))
         lTEM := .T.
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ITEN_FAT->Prep_cod == cPREP
            nVALOR += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
            ITEN_FAT->(Dbskip())
         enddo
      else
        FAT->(dbskip())
        loop
      endif

      if lTEM
         @ prow()+1,00  say XCOND1 + FAT->Codigo
         CLI1->(dbseek(FAT->Cod_cli))
         @ prow()  ,12  say CLI1->Codigo
         @ prow()  ,19  say left(CLI1->Razao,45)
         @ prow()  ,66  say dtoc(FAT->Dt_emissao)
         @ prow()  ,85  say transform(nVALOR, "@E 9,999,999.99")
   
         nTOT_VAL += nVALOR

         nVALOR := 0

         lTEM := .F.

         @ prow(),pcol() say XCOND0

      endif
   
      FAT->(dbskip())

   enddo

   @ prow()+1,00 say replicate("-",80)
   @ prow(),pcol() say XCOND1

   @ prow()+1,40 say "TOTAL------------------>"+space(20)+transform(nTOT_VAL,"@E 9,999,999.99")
   @ prow(),pcol() say XCOND0
   qstopprn()

return
