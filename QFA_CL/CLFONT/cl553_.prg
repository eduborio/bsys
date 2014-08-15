/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: janeiro DE 2006
// OBS........:
// ALTERACOES.:

function cl553
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27 }

private cTITULO                   // titulo do relatorio
private cCLI := space(5)
private cRAZAO := space(40)

private aEDICAO := {}             // vetor para os campos de entrada de dados

if ! quse(XDRV_CL,"PROD_TMP",{"TMPCDPRD"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_Cli(-1,0,@cCLI)         } , "CLIENTE"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })


do while .T.

   qlbloc(5,0,"B553A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cCLI := space(5)
   cRAZAO := space(40)


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

      case cCAMPO == "CLIENTE"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              //qrsay(XNIVEL+1, "Todos Clientes.......")
              qmensa("Campo Obrigat¢rio !!!","B")
              return .F.
           else
              if ! CLI1->(Dbseek(cCLI:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CLI1->Razao,40))
                 cRAZAO := left(CLI1->Razao,40)
              endif
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "Lista de Pecas nao Compradas - "+left(cRAZAO,30)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(1)) // Codigo
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(3))
   ITEN_FAT->(dbGotop())

return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif

   //if XLOCALIMP == "X"
   //   i_impre_xls()
   //else
      i_impre_prn()
   //endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
local  cPROD := space(5)
local aPROD  := {}
local asPROD := {}

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   PROD_TMP->(__dbzap())

   ITEN_FAT->(dbsetorder(3))
   ITEN_FAT->(dbGotop())
   cPROD := ITEN_FAT->Cod_prod

   do while ! ITEN_FAT->(eof())

      FAT->(dbseek(ITEN_FAT->Num_fat))

      if FAT->Cod_cli != cCLI
         ITEN_FAT->(Dbskip())
         loop
      endif

      if FAT->Cancelado
         ITEN_FAT->(dbskip())
         loop
      endif

      if FAT->Es != "S"
         ITEN_FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      ITEN_FAT->(dbskip())

      if ITEN_FAT->Cod_prod != cPROD

         PROD->(dbseek(cPROD))
         PROD_TMP->(qappend())
         replace PROD_TMP->Cod_prod    with cPROD
         replace PROD_TMP->Preco       with PROD->Preco_cons
         PROD_TMP->(DbCommit())

         cPROD := ITEN_FAT->Cod_prod

         nQUANT := 0
         nTOTAL := 0
      endif

      qmensa("Aguarde... Processando ...")

   enddo

   PROD->(dbseek(cPROD))
   PROD_TMP->(qappend())
   replace PROD_TMP->Cod_prod    with cPROD
   replace PROD_TMP->Preco       with PROD->Preco_cons

   PROD->(dbCommit())


   nQUANT := 0
   nTOTAL := 0
   nPERC  := 0


   PROD->(Dbgotop())
   do While ! PROD->(eof())

      if right(PROD->Codigo,5) == "     "
         PROD->(Dbskip())
         loop
      endif

      if ! PROD_TMP->(dbseek(right(PROD->Codigo,5)))
         aadd(aPROD,{right(PROD->Codigo,5),left(PROD->Descricao,30),PROD->Cod_fabr,PROD->Cod_ass,PROD->Marca,PROD->Preco_cons})
      endif

      PROD->(dbskip())
   enddo


   asPROD := asort(aPROD,,,{|x,y|  x[1] <  y[1] })

   nCONT := 1
   do while  nCONT <= len(asPROD)

      if ! qlineprn() ; exit ; endif
      if XLOCALIMP == "X"
         if XPAGINA == 0 //.or. prow() > K_MAX_LIN
            qpageprn()
            @ prow()+1,0 say chr(9)+cTITULO+ " 553"
            @ prow()+1,0 say "Descricao" +chr(9)+ "Cod.Fab" +chr(9)+ "Cod.Ass."+chr(9)+"Marca"+chr(9)+"Preco Venda"
            @ prow()+1,0 say ""
         endif
      else
        if XPAGINA == 0 .or. prow() > K_MAX_LIN
            @prow()+1,0 say XCOND0
            qpageprn()
            qcabecprn(cTITULO,80)
            @ prow()+1,0 say XCOND1 + "Descricao                          Cod.Fab   Cod.Ass.  Marca              Preco Venda          "
            @ prow()+1,0 say replicate("-",134)
         endif
      endif


      if XLOCALIMP == "X"
         @ prow()+1,00      say left(asPROD[nCONT,2],30)+chr(9)  //Descricao
         @ prow()  ,pcol()  say " "+left(asPROD[nCONT,3],8)+chr(9)  //Cod_fabr
         @ prow()  ,pcol()  say " "+asPROD[nCONT,4]+chr(9)  //Cod_ass
         @ prow()  ,pcol()  say asPROD[nCONT,5]+chr(9)             //Marca
         @ prow()  ,pcol()  say transf(asPROD[nCONT,6],"@E 999,999.99")  //Preco de Venda
      else
         @ prow()+1,00  say left(asPROD[nCONT,2],30)  //Descricao
         @ prow()  ,35  say left(asPROD[nCONT,3],8)  //Cod_fabr
         @ prow()  ,45  say asPROD[nCONT,4]  //Cod_ass
         @ prow()  ,55  say asPROD[nCONT,5]  //Marca
         @ prow()  ,85  say transf(asPROD[nCONT,6],"@E 999,999.99")  //Preco de Venda
      endif

      nCONT++

      if nCONT > len(asPROD)
         nCONT := len(asPROD)
         exit
      endif

   enddo
   qstopprn()
return


