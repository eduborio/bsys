/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: AGOSTO DE 2004
// OBS........:
// ALTERACOES.:

function cl309
#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cTITULO                // titulo do relatorio
private aEDICAO   := {}        // vetor para os campos
private cCOD_PROD := space(5)  // produto
private dDT_INI                // data inicial na faixa
private dDT_FIM                // data final na faixa
private nSALDO     := 0
private nSALDO_ANT := 0
private l2ND       := .F.

private tDATA
private tCOD_PROD
private tCODIGO
private tCOD_ITEM
private tQTDE

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_INI    ,"@D"      )},"DT_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_FIM    ,"@D"      )},"DT_FIMF"})
aadd(aEDICAO,{{ || view_prod(-1,0,@cCOD_PROD,"@R 99999"  )},"PROD"  })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto

do while .T.

   qlbloc(5,0,"B309A","QBLOC.GLO")

   XNIVEL     := 1
   XFLAG      := .T.
   dDT_INI    := ctod("")
   dDT_FIM    := qfimmes(dDT_INI)
   cCOD_PROD  := space(5)
   nSALDO     := 0
   nSALDO_ANT := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif( i_inicializacao() , i_printer() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   do case

      case cCAMPO == "PROD"

           if empty(cCOD_PROD) ; return .F. ; endif

           PROD->(dbsetorder(4))

           if ! PROD->(dbseek(cCOD_PROD:=strzero(val(cCOD_PROD),5)))
              qmensa("Produto n„o cadastrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(PROD->Descricao,36))

//           ESTOQ->(dbseek(right(PROD->Codigo,5)))
             nSALDO_ANT := 0
             nSALDO     := 0
                            

      case cCAMPO == "DT_INI"

           if empty(dDT_INI) ; return .F. ; endif
           dDT_FIM := qfimmes(dDT_INI)
           qrsay(XNIVEL+1,dDT_FIM)

      case cCAMPO == "DT_FIM"

           if empty(dDT_FIM) ; return .F. ; endif
           if dDT_INI > cDT_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

   endcase
   XREFRESH := 9999
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ____________________________

static function i_inicializacao

   cTITULO := "RAZAO POR PRODUTO - " + dtoc(dDT_INI) + " ATE " + dtoc(dDT_FIM)

   ///////////////////////////////////////////////////////////////////////////
   // ENTRASDAS ______________________________________________________________

   qmensa()
   FAT->(Dbsetorder(2))
   FAT->(Dbgotop())

   ESTOQ->(Dbsetorder(1))
   ESTOQ->(Dbgotop())
   ESTOQ->(dbseek(cCOD_PROD))
   nSALDO_ANT := ESTOQ->Quant_ini
   nSALDO     := ESTOQ->Quant_ini


   do while ! FAT->(eof())

      qmensa(" Produto: " + cCod_prod + " Nota Fiscal: " + FAT->Num_fatura)


      if FAT->Dt_emissao < dDT_INI .and. FAT->Dt_emissao >= ESTOQ->Data
         ITEN_FAT->(Dbsetorder(2))
         ITEN_FAT->(dbgotop())
         if ITEN_FAT->(dbseek(FAT->Codigo))
            do while ! ITEN_FAT->(eof()) .and. FAT->Codigo == ITEN_FAT->num_fat

               qgirabarra()
               if FAT->Es == "E"
                  if ITEN_FAT->Cod_prod == cCod_prod
                     nSALDO_ANT := nSALDO_ANT + ITEN_FAT->Quantidade
                     nSALDO     := nSALDO + ITEN_FAT->Quantidade
                  endif
               endif
               ITEN_FAT->(dbskip())

            enddo
         endif
      endif

      FAT->(dbskip())

   enddo

   /////////////////////////////////////////////////////////////////////////////
   // SAIDAS ___________________________________________________________________

   FAT->(Dbsetorder(2))
   FAT->(Dbgotop())

   do while ! FAT->(eof())

      qmensa(" Produto: " + cCod_prod + " Nota Fiscal: " + FAT->Num_fatura)

      ESTOQ->(Dbsetorder(1))
      ESTOQ->(Dbgotop())
      ESTOQ->(dbseek(cCOD_PROD))
      if FAT->Dt_emissao < dDT_INI .and. FAT->Dt_emissao >= ESTOQ->Data
         ITEN_FAT->(Dbsetorder(2))
         ITEN_FAT->(dbgotop())
         if ITEN_FAT->(dbseek(FAT->Codigo))
            do while ! ITEN_FAT->(eof()) .and. FAT->Codigo == ITEN_FAT->num_fat

               qgirabarra()
               if FAT->Es == "S"
                  if ITEN_FAT->Cod_prod == cCod_prod
                     nSALDO_ANT := nSALDO_ANT - ITEN_FAT->Quantidade
                     nSALDO     := nSALDO - ITEN_FAT->Quantidade
                  endif
               endif
               ITEN_FAT->(dbskip())

            enddo
         endif
      endif

      FAT->(dbskip())

   enddo

   qrsay(XNIVEL,nSALDO_ANT,"@R 9999999999999.99")

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_printer
ITEN_FAT->(dbsetorder(2))
ITEN_FAT->(dbsetfilter({||Data >= dDT_INI .and. Data <= dDT_FIM .and. Cod_prod == cCOD_PROD},'Cod_prod == cCOD_PROD'))
ITEN_FAT-> (qview({{"iEmissao()/Data"                                     ,2},;
                  {"iPedido()/Pedido"                                     ,0},;
                  {"iEstoque()/Estoque"                                   ,0},;
                  {"iNf()/Nota Fiscal"                                    ,0},;
                  {"iEs()/Tipo"                                           ,0},;
                  {"transform(Quantidade,'@R 9999999.99')/Quant."         ,0},;
                  {"iSaldo()/Saldo Final"                                 ,0}},;
                  "09002179S",;
                  {NIL,NIL,NIL,NIL},;
                  {NIL,{||f309top()},{||f309bot()}},;
                  " "))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

static function f309top
   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(dbseek(FAT->Codigo))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

static function f309bot
   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(qseekn(FAT->Codigo))
return


function iSaldo

   if l2ND
      FAT->(dbsetorder(1))
      FAT->(dbgotop())
      FAT->(dbseek(ITEN_FAT->Num_fat))
      if FAT->ES == "S"
         nSALDO := nSALDO - ITEN_FAT->Quantidade
      else
         nSALDO := nSALDO + ITEN_FAT->Quantidade
      endif
   endif
   l2ND := .T.
   qrsay(XNIVEL+1,nSALDO,"@R 9999999999.99")
return transf(nSALDO,"@R 999999.99")

function iEs
   cTIPO := "        "
   FAT->(dbsetorder(1))
   FAT->(dbgotop())
   FAT->(dbseek(ITEN_FAT->Num_fat))
   if FAT->ES == "S"
      cTIPO := "Saida  "
   else
      cTIPO := "Entrada"
   endif
return cTIPO


function iEstoque
   nSALDO :=  nSALDO

return transf(nSALDO,"@R 9999999.99")


function iEmissao
   local dDATE := ctod("")
   FAT->(dbsetorder(1))
   FAT->(dbGotop())
   FAT->(Dbseek(ITEN_FAT->Num_fat))
return dtoc(FAT->Dt_emissao)

function iPedido
   FAT->(dbsetorder(1))
   FAT->(dbGotop())
   FAT->(Dbseek(ITEN_FAT->Num_fat))
return FAT->Codigo

function iNf
   FAT->(dbsetorder(1))
   FAT->(dbGotop())
   FAT->(Dbseek(ITEN_FAT->Num_fat))
return FAT->Num_fatura



