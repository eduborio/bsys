/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: MIVMENTO DO PROJETO
// ANALISTA...: Eduardo Borio
// PROGRAMADOR: Eduardo Borio
// INICIO.....: OUTUBRO de 2006
// OBS........:
// ALTERACOES.:
function es512

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cTITULO                // titulo do relatorio
private aEDICAO   := {}        // vetor para os campos
private cCOD_PROJ := space(5)  // produto
private cFILIAL   := space(4)  // filial

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"@R 9999"   )},"FILIAL"  })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
aadd(aEDICAO,{{ || view_proj(-1,0,@cCOD_PROJ,"@R 99999"  )},"COD_PROJ"})
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto

do while .T.

   qlbloc(5,0,"B512A","QBLOC.GLO")

   XNIVEL     := 1
   XFLAG      := .T.
   cFILIAL    := space(4)
   cCOD_PROJ  := space(5)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   do case

      case cCAMPO == "COD_PROJ"

           if empty(cCOD_PROJ)
              qmensa("Campo Obrigatorio!","B")
              return .F.
              qmensa("")
           else

              if ! PROJET->(dbseek(cCOD_PROJ:=strzero(val(cCOD_PROJ),5)))
                 qmensa("Projeto n„o cadastrado !","B")
                 return .F.
              endif

              qrsay(XNIVEL+1,left(PROJET->Descricao,36))

           endif

      case cCAMPO == "FILIAL"

           if empty(cFILIAL) ; return .F. ; endif

           qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))

           if ! FILIAL->(dbseek(cFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,30))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ____________________________

static function i_inicializacao

   cTITULO := "LISTAGEM DO MOVIMENTO DO PROJETO - " + Left(PROJET->Descricao,30)

   PROD->(dbsetorder(4)) // right(Codigo,5)


   qmensa()

return .T.

static function i_impressao

   MOV_PROJ->(DbClearFilter())
   MOV_PROJ->(DbSetFilter({||MOV_PROJ->Cod_Proj == cCOD_PROJ}))

   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return


/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_impre_prn

local cTIPO := ""
local nTOTAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   @ prow(),pcol() say XCOND1

   do while ! MOV_PROJ->(eof()) .and. qcontprn()

      if ! qlineprn() ; exit ; endif

      qgirabarra()

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,136)
         @ prow()+1,0 say "Data      Produto                        Tipo          Tipodo Movimento       Quantidade       Valor Unit.         Total"
         @ prow()+1,0 say replicate("-",136)
      endif


      @ prow()+1,00 say dtoc(MOV_PROJ->Data) ; PROD->(Dbseek(MOV_PROJ->Cod_Prod))
      @ prow()  ,13 say left(PROD->Descricao,30)
      @ prow()  ,38 say iif(PROD->Consumivel == "C","Consumivel","Permanente")
      do case
         case MOV_PROJ->Tipo == "EA"
              cTIPO := "Entrada de Aluguel"

         case MOV_PROJ->Tipo == "SA"
              cTIPO := "Saida de Aluguel"
              nTOTAL += MOV_PROJ->Quantidade*MOV_PROJ->Preco_alug


         case MOV_PROJ->Tipo == "SC"
              cTIPO := "Saida"
              nTOTAL += MOV_PROJ->Quantidade*PROD->Preco_cust

         case MOV_PROJ->Tipo == "EC"
              cTIPO := "Estorno/Sobra"
              nTOTAL -= MOV_PROJ->Quantidade*PROD->Preco_cust


      endcase

      @ prow()  ,62  say cTIPO
      @ prow()  ,90  say transf(MOV_PROJ->Quantidade,"@R 999999.999")

      if MOV_PROJ->Tipo == "SC"  .or. MOV_PROJ->Tipo == "EC"
         @ prow()  ,103  say transf(PROD->Preco_cust,"@E 999,999.99")
         @ prow()  ,115 say transf(MOV_PROJ->Quantidade*PROD->Preco_cust,"@E 999,999.99")
      else
         @ prow()  ,103  say transf(MOV_PROJ->Preco_alug,"@E 999,999.99")
         @ prow()  ,115 say transf(MOV_PROJ->Quantidade*PROD->Preco_alug,"@E 999,999.99")
      endif


      MOV_PROJ->(dbskip())

   enddo

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_impre_xls

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do while ! PROD->(eof()) 
      qgirabarra()

      if ! empty(cCOD_PROD)
         if right(PROD->Codigo,5) <> cCOD_PROD
            exit
         endif
      endif

      if XPAGINA == 0
         qpageprn()
         @ prow()+1,0 say chr(9)+chr(9)+cTITULO+chr(9)+"507"
         @ prow()+1,0 say "Ref."+chr(9)+"Cod assoc."+Chr(9)+"Descricao"+chr(9)+"Marca"+chr(9)+"Em Estoque"+chr(9)+"Preco Unitario"
         @ prow()+1,0 say ""
      endif

      INVENT->(dbgotop())

      if empty(cCOD_PROD)
         if ! INVENT->(dbseek(cFILIAL+right(PROD->Codigo,5)))
            PROD->(dbskip())
            loop
         endif
      else
         INVENT->(dbseek(cFILIAL+cCOD_PROD))
         PROD->(dbsetorder(4))
         PROD->(dbseek(cCOD_PROD))
         PROD->(dbsetorder(1))
      endif

//    PROD->(dbseek(INVENT->Cod_prod))

      // rotina que localiza todos os produtos lancados no inventario de lotes distintos
      nQUANT := 0
      do while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
         nQUANT+= INVENT->Quant_atu
         INVENT->(dbskip())
      enddo

      @ prow()+1,00 say left(PROD->Cod_fabr,7) +  chr(9)  + PROD->Cod_ass +chr(9)+ left(PROD->Descricao,18)+chr(9)+left(PROD->Marca,12)   +chr(9)+;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT,"@E 999,999.99") + chr(9) +;
                        transform(PROD->Preco_cons,"@E 999,999.99") , "")

      PROD->(dbskip())

   enddo

   qstopprn()

return

