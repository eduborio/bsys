/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: janeiro DE 2006
// OBS........:
// ALTERACOES.:

function cp520
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI).or. lastkey()== 27 }

private cTITULO                   // titulo do relatorio
private XDRV_HB := "C:\QSYSTXT\"
private cFILE   := alltrim(left(XUSRIDT,7))
private dINI := qinimes(date())
private dFIM := qfimmes(date())
private nLIM := 0

private aEDICAO := {}             // vetor para os campos de entrada de dados


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })


do while .T.

   qlbloc(5,0,"B520A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   //dINI := dFIM := ctod("")

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
      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "Controle de Pedidos de Importacao"

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________


   INVOICE->(dbsetorder(2)) // data de emissao
   INVOICE->(dbgotop())
   ITEN_INV->(dbsetorder(1))


   PED_FABR->(dbsetorder(2)) // data de emissao
   PED_FABR->(dbgotop())
   ITEN_PED->(dbsetorder(1))

   criaTmpFile()

return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif
   i_impre_prn()

return

static function i_impre_prn
local aPED   := {}
local asPED  := {}
local lTEM   := .F.
local cPROD  := "     "
local nQUANT := 0
local nCONT  := 0


   ////////////////////////////////////////////////////////////////////////////
   //PROCESSA PEDIDOS PENDENDES________________________________________________
   PED_FABR->(dbgotop())
   do while ! PED_FABR->(eof())

      qmensa("Aguarde... Processando ...")

      ITEN_PED->(Dbseek(PED_FABR->Codigo))
      do while ITEN_PED->Cod_ped == PED_FABR->Codigo .and. ! ITEN_PED->(eof())
          aadd(aPED,{ITEN_PED->Cod_prod,ITEN_PED->Quantidade})
          lTEM := .T.
          ITEN_PED->(Dbskip())
      enddo

      PED_FABR->(dbskip())
   enddo

   //classifica a matriz por descricao do produto
   asPED := asort(aPED,,,{|x,y| x[1] < y[1] })
   aPED := {}

   if lTEM
      cPROD := asPED[1,1]

      nCONT := 1
      do while  nCONT <= len(asPED)

         nQUANT += asPED[nCONT,2]

         nCONT++
         if nCONT > len(asPED)
            nCONT := len(asPED)
            exit
         endif

         if asPED[nCONT,1] != cPROD

            if (cFILE)->(dbseek(cPROD))
               replace (cFILE)->Pedidos       with nQUANT
            else
               (cFILE)->(qappend())
               replace (cFILE)->Cod_prod      with cPROD
               replace (cFILE)->Pedidos       with nQUANT
            endif

            cPROD := asPED[nCONT,1]
            nQUANT := 0
         endif
      enddo

      if (cFILE)->(dbseek(cPROD)) .and. qrlock()
         replace (cFILE)->Pedidos       with nQUANT
         qunlock()
      else
         (cFILE)->(qappend())
         replace (cFILE)->Cod_prod      with cPROD
         replace (cFILE)->Pedidos       with nQUANT
      endif

      nQUANT := 0
   endif

   lTEM := .F.
   asPED := {}
   aPED  := {}



   ////////////////////////////////////////////////////////////////////////////
   //PROCESSA PEDIDOS PENDENDES________________________________________________

   do while ! INVOICE->(eof())

      qmensa("Aguarde... Processando ...")


      ITEN_INV->(Dbgotop())
      ITEN_INV->(Dbseek(INVOICE->Codigo))
      do while ITEN_INV->Cod_inv == INVOICE->Codigo .and. ! ITEN_INV->(eof())

          aadd(aPED,{ITEN_INV->cod_prod,ITEN_INV->Quantidade})
          ITEN_INV->(Dbskip())
          lTEM := .T.
      enddo

      INVOICE->(dbskip())
   enddo

   //classifica a matriz por descricao do produto
   asPED := asort(aPED,,,{|x,y| x[1] < y[1] })
   aPED := {}

   if lTEM
      cPROD := asPED[1,1]

      nCONT := 1
      do while  nCONT <= len(asPED)

         nQUANT += asPED[nCONT,2]

         nCONT++
         if nCONT > len(asPED)
            nCONT := len(asPED)
            exit
         endif

         if asPED[nCONT,1] != cPROD

            if (cFILE)->(dbseek(cPROD)) .and. qrlock()
               replace (cFILE)->Transito     with nQUANT
               qunlock()
            else
               (cFILE)->(qappend())
               replace (cFILE)->Cod_prod    with cPROD
               replace (cFILE)->Transito    with nQUANT
            endif

            cPROD := asPED[nCONT,1]

            nQUANT := 0
         endif
      enddo

      if (cFILE)->(dbseek(cPROD)).and. qrlock()
         replace (cFILE)->Transito     with nQUANT
         qunlock()
      else
         (cFILE)->(qappend())
         replace (cFILE)->Cod_prod     with cPROD
         replace (cFILE)->Transito     with nQUANT
      endif

      nQUANT := 0
   endif

   lTEM := .F.
   asPED := {}
   aPED  := {}

   PROD->(dbsetorder(4))

   (cFILE)->(dbgotop())
   do while ! (cFILE)->(Eof())

      if mod((cFILE)->(Recno()),50) == 0
         if ! qlineprn() ; exit ; endif
      endif

      if XLOCALIMP == "X"
         if XPAGINA == 0
            qpageprn()
            @ prow()+1,0 say chr(9)+chr(9)+cTITULO+" 520"
            @ prow()+1,0 say "Ref."+chr(9)+"Ref."+chr(9)+"Descricao"+chr(9)+"Marca/Colecao"+chr(9)+"Pedido"+chr(9)+"Entregue"+chr(9)+"Pendente"
            @ prow()+1,0 say ""
         endif
      else
         if XPAGINA == 0 .or. prow() > K_MAX_LIN
            qpageprn()
            qcabecprn(cTITULO,134)
            @ prow()+1,0 say XCOND1 + "Produto                                                                          Pedido        Entregue       Pendente"
            @ prow()+1,0 say replicate("-",134)
         endif
      endif

      PROD->(dbseek((cFILE)->Cod_prod))

      if XLOCALIMP == "X"
         @ prow() +1, 00     say PROD->Cod_ass +chr(9)+left(PROD->Cod_fabr,6)+chr(9)+ left(PROD->Descricao,30)+chr(9)+left(PROD->Marca,15)
         @ prow()   , pcol() say chr(9)+transform((cFILE)->Pedidos  ,"@R 9999999")
         @ prow()   , pcol() say chr(9)+transform((cFILE)->Transito,"@R 9999999")
         @ prow()   , pcol() say chr(9)+transform((cFILE)->Pedidos-(cFILE)->Transito ,"@R 9999999")
      else
         @ prow() +1, 00  say PROD->Cod_ass +"  "+left(PROD->Cod_fabr,6)+" "+ left(PROD->Descricao,30)+" "+left(PROD->Marca,15)
         @ prow()   , 80  say transform((cFILE)->Pedidos  ,"@R 9999999")
         @ prow()   , 95  say transform((cFILE)->Transito,"@R 9999999")
         @ prow()   , 110 say transform((cFILE)->Pedidos-(cFILE)->Transito ,"@R 9999999")
      endif

      (cFILE)->(dbskip())
   enddo

   (cFile)->(dbclosearea())


   erasefiles()


   qstopprn(.F.)
return


static function criaTmpFile
  local aStruct := {}
  aStruct := {;
             {"COD_PROD"  ,"C",8 ,0},;
             {"PEDIDOS"    ,"N",7 ,0},;
             {"TRANSITO"  ,"N",7 ,0};
             }

   eraseFiles()

   dbCreate(XDRV_HB+cFILE,aStruct)

   if ! Quse(XDRV_HB,cFILE,{""})
      qmensa("Erro ao criar arquivo temporario!","BL")
      return .F.
   endif

   select (cFILE)
   index on (COD_PROD) tag Um
   dbsetindex(XDRV_HB+cFILE)


return

static function eraseFiles

   if file(XDRV_HB+cFILE+".DBF")
      erase(XDRV_HB+cFILE+".DBF")
   endif

   if file(XDRV_HB+cFILE+".CDX")
      erase(XDRV_HB+cFILE+".CDX")
   endif

return




