///////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO
// OBJETIVO...: RELATORIO DE SUGESTAO DE COMPRAS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JULHO DE 1997
// OBS........:
// ALTERACOES.:

function cl523
#include "inkey.ch"
#define K_LEN_HIST 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO := {}    // vetor para os campos
private cTITULO          // titulo do relatorio
private cFORNECED := space(5) // fornecedor do relatorio
private nQUANT    := 0
private nMEDIA    := 0
private nMES      := 0
private dDATA1    := ctod("")
private cMESANO   := ""
private lPRIVEZ   := .T.
private lTEM      := .F.

private nTOTAL  := 0

INVENT->(Dbsetorder(4))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_forn1(-1,0,@cFORNECED, "@E 99999"          ) } ,"FORNECED" })
aadd(aEDICAO,{{ || NIL                                             } ,NIL      })

do while .T.

   qlbloc(5,0,"B523A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "FORNECED"

           if empty(cFORNECED) ; return .F. ; endif

           qrsay(XNIVEL,cFORNECED := strzero(val(cFORNECED),5))

           if ! FORN->(dbseek(cFORNECED))

               qmensa("Fornecedor inv lido !","B")

               return .F.

           else

              qrsay(XNIVEL+1,left(FORN->Razao,30))

           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // INICIALIZA cTITULO ____________________________________________________

   cTITULO := "CONSIDERA O MES ATUAL NA MEDIA"

   // RELACIONA ARQUIVOS ____________________________________________________

   qmensa("Filtrando dados...")

   PROD->(Dbsetorder(4))
   PROD->(Dbgotop())
//   PROD->(dbSetFilter({|| right(PROD->Codigo,5) <> "     " .and. Cod_fornec == cFORNECED }, 'Cod_fornec == cFORNECED .and. right(PROD->Codigo,5) <> "     " .and. Cod_fornec == cFORNECED'))
   PROD->(dbSetFilter({|| right(PROD->Codigo,5) <> "     " .and. Cod_fornec == cFORNECED }, 'right(PROD->Codigo,5) <> "     " .and. Cod_fornec == cFORNECED'))

   qmensa("")

   FAT->(dbsetorder(2)) // Data de emissao
//   PROD->(dbsetrelation("FORN",{|| Codigo},"Cod_fornec"))
   FAT->(dbsetrelation("ITEN_FAT",{|| Codigo},"Num_fat"))

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   nTOTAL := 0
   lPRI   := .T.
   dDATA  := XDATASYS + 30

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND0

   if ! qlineprn() ; return ; endif

   // CABECALHO PRINCIPAL _____________________________________________

   @ prow() ,00 say XCOND1

   if prow() = 0 .or. prow() > 60

      qpageprn()
      qcabecprn(cTITULO,140)
      @ prow()+1,0 say "Fone Fornecedor : " + FORN->Fone1 + "  " + FORN->Razao
      @ prow()+1,0 say "Pessoa Contato Fornecedor : " + FORN->Contato_c
      @ prow()+1,0 say replicate("-",140)

      @ prow()+1,0 say "Prod  Descricao                                 Pr.Fab."

      for nCONT1  := 1 to 6
          nMES1   := month(dDATA := dDATA - 30)
          dDATA1  := ctod( "01/" + str(nMES1,2) + "/" + left(qanomes(dDATA),4) )
          cMESANO := right(qanomes(dDATA1),2) + "/" + left(qanomes(dDATA),4)
          @ prow(),pcol()+1 say cMESANO
      next

      @ prow() ,pcol()+2 say "Media  Estoque     Previs. Sugestao"
      @ prow()+1,0 say replicate("-",140)

   endif

   dDATA := XDATASYS + 30

   do while ! PROD->(eof())

      if right(PROD->Codigo,5) == space(5)
         PROD->(Dbskip())
         loop
      endif

      qmensa( " Aguarde... " +  right(PROD->Codigo,5) + " - " + PROD->Descricao )

      nMEDIA := 0

      for nCONT := 1 to 6      // deve calcular somente os 6 meses anteriores a data de emissao do relatorio (XDATASYS)

          qgirabarra()

          nMES := month(dDATA := dDATA - 30)
          dDATA := ctod( "01/" + str(nMES,2) + "/" + left(qanomes(dDATA),4) )

          FAT->(dbSetFilter({|| Year(FAT->Dt_emissao) == Year(dDATA) }, 'Year(FAT->Dt_emissao) == Year(dDATA)'))

          FAT->(Dbsetorder(2))
          FAT->(Dbgotop())
          set softseek on
          FAT->(Dbseek(dtos(dDATA)))
          set softseek off

          nQUANT := 0

          do while ! FAT->(eof()) .and. qanomes(FAT->Dt_emissao) == qanomes(dDATA)

             if ! FAT->Cancelado

                ITEN_FAT->(dbsetorder(1))
                ITEN_FAT->(dbgotop())

                ITEN_FAT->(dbseek(FAT->Codigo+right(PROD->Codigo,5)))

                do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                   qgirabarra()

                   if ITEN_FAT->Cod_prod == right(PROD->Codigo,5)
                      lTEM := .T.  // tem fatura nesta data
                      nQUANT += ITEN_FAT->Quantidade
                   endif

                   ITEN_FAT->(Dbskip())

                enddo

             endif

             FAT->(Dbskip())

          enddo

          if lPRIVEZ

             @ prow()+1,00  say  right(PROD->Codigo,5)
             @ prow()  ,06  say  left(PROD->Descricao,35)
             @ prow()  ,45  say  transform(PROD->Preco_unit, "@E 99,999.99") + "    "
             @ prow()  ,pcol()   say transform(nQUANT,"@E 99999")

             lPRIVEZ := .F.

          else

            @ prow()  ,pcol()+3 say transform(nQUANT,"@E 99999")

          endif

          nMEDIA += nQUANT

      next

      @ prow() , pcol()+1  say transform( round(nMEDIA/6,0) ,"@R 99999")
      INVENT->(dbseek(FAT->Filial+PROD->Codigo+ITEN_FAT->Num_lote))
//    @ prow() , pcol()+1  say transform(PROD->Qtn_estoq, "@R 999999")
      @ prow() , pcol()+1  say transform(INVENT->Quant_atu, "@R 999999")
      @ prow() , pcol()+6  say transform( ( round(PROD->Qtn_estoq / (nMEDIA/6),0) ) , "@R 9999") + " Sem."
      @ prow() , pcol()+2  say transform( round(PROD->Qtn_estoq/(nMEDIA/6)*4,0) , "@R 99999")

      PROD->(Dbskip())

      nPROD   := PROD->Codigo
      lPRIVEZ := .T.

      if ! PROD->(eof())
         i_cab()
      endif

      dDATA := XDATASYS + 30

   enddo

   @ prow()+1,0 say replicate("-",140)

   qstopprn()

return

///////////////////////////////////////////////////////////////////////////////////////
function i_cab

   if prow() >= 60

      qpageprn()
      qcabecprn(cTITULO,130)
      @ prow()+1,0 say "Fone Fornecedor : " + FORN->Fone1 + "  " + FORN->Razao
      @ prow()+1,0 say "Pessoa Contato Fornecedor : " + FORN->Contato_c
      @ prow()+1,0 say replicate("-",140)

      @ prow()+1,0 say "Prod  Descricao                                 Pr.Fab."

      dDATA := XDATASYS  + 30

      for nCONT1  := 6 to 1 step -1
//        nMES1   := month(XDATASYS) - nCONT1
          nMES1   := month(dDATA := dDATA - 30)
          dDATA1  := ctod( "01/" + str(nMES1,2) + "/" + left(qanomes(dDATA),4) )
          cMESANO := right(qanomes(dDATA1),2) + "/" + right(dtoc(dDATA),4)
          @ prow(),pcol()+1 say cMESANO
      next

      @ prow() ,pcol()+2 say "Media  Estoque     Previs. Sugestao"
      @ prow()+1,0 say replicate("-",140)

   endif

return
