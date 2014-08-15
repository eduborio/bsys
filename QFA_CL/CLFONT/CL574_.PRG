//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2007
// OBS........:
// ALTERACOES.:

function cl574
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cCLI := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aDados := {}

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
//aadd(aEDICAO,{{ || view_cli2(-1,0,@cCLI)        } , "CLI"  })
//aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B519A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   keyboard chr(27)

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

      case cCAMPO == "CLI"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL++, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cSETOR:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(CLI1->Razao,30))
              endif
           endif
     endcase


return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PRODUTOS DEVOLVIDOS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetfilter({|| Es == "E" .and. Dt_emissao >= dINI  .and. Dt_emissao <= dFIM .and. !Cancelado }))
   ITEN_FAT->(dbsetorder(2))
   FAT->(dbgotop())

return .T.


static function i_impressao

   i_get_dados()
   FAT->(dbgotop())
   alert("Arquivo gerado na pasta C:\Qsystxt  !")


//   if ! qinitprn() ; return ; endif

//   if XLOCALIMP == "X"
//      i_impre_xls()
//   else
//      i_impre_prn()
//   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nQtyMotivo := 0
    local nQtyProd   := 0
    local nQtyTotal  := 0

    local nVlrMotivo := 0
    local nVlrProd   := 0
    local nVlrTotal  := 0
    local nVALOR     := 0

    local nCONT      := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local zPROD := space(50)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())  

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nVALOR += q_soma_st()

             aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->cod_Motdev,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR})

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
   if lTEM

       cPROD    := asFAT[1,1]
       cMOTIVO  := asFAT[1,2]
       PROD->(dbseek(cPROD))
       MOTDEV->(dbseek(cMOTIVO))
       zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
       zMOTIVO := left(MOTDEV->Descricao,25)


       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,132)
              @ prow()+1,0 say "Produto                               Motivo                 Qtde            Valor "
              @ prow()+1,0 say replicate("-",134)
           endif

           nQtyMotivo += asFAT[nCONT,3]
           nQtyProd   += asFAT[nCONT,3]
           nQtyTotal  += asFAT[nCONT,3]

           nVlrMotivo += asFAT[nCONT,5]
           nVlrProd   += asFAT[nCONT,5]
           nVlrTotal  += asFAT[nCONT,5]

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,2] != cMOTIVO
              @ prow()+1,00 say zPROD
              @ prow()  ,50 say zMOTIVO
              @ prow()  ,80 say transf(nQtyMotivo,"@R 999999")
              @ prow()  ,90 say transf(nVlrMotivo,"@E 99,999,999.99")

              cPROD   := asFAT[nCONT,1]
              cMOTIVO := asFAT[nCONT,2]
              PROD->(dbseek(cPROD))
              zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
              MOTDEV->(dbseek(cMOTIVO))
              zMOTIVO := left(MOTDEV->Descricao,25)

              nQtyMotivo   := 0
              nVlrMotivo   := 0
           endif


           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say "Total do Produto.: "+zPROD
              @ prow()  ,80 say transf(nQtyProd,"@R 999999")
              @ prow()  ,90 say transf(nVlrProd,"@E 99,999,999.99")

              cPROD   := asFAT[nCONT,1]
              cMOTIVO := asFAT[nCONT,2]
              PROD->(dbseek(cPROD))
              zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
              MOTDEV->(dbseek(cMOTIVO))
              zMOTIVO := left(MOTDEV->Descricao,25)

              nQtyProd  := 0
              nQtyValor := 0
              nQtyMotivo   := 0
              nVlrMotivo   := 0
           endif
       enddo

          @ prow()+1,00 say zPROD
          @ prow()  ,50 say zMOTIVO
          @ prow()  ,80 say transf(nQtyMotivo,"@R 999999")
          @ prow()  ,90 say transf(nVlrMotivo,"@E 99,999,999.99")

          cPROD   := asFAT[nCONT,1]
          cMOTIVO := asFAT[nCONT,2]
          PROD->(dbseek(cPROD))
          zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
          MOTDEV->(dbseek(cMOTIVO))
          zMOTIVO := left(MOTDEV->Descricao,25)

          nQtyMotivo   := 0
          nVlrMotivo   := 0

          @ prow()+1,00 say "Total do Produto.: "+zPROD
          @ prow()  ,80 say transf(nQtyProd,"@R 999999")
          @ prow()  ,90 say transf(nVlrProd,"@E 99,999,999.99")

          cPROD   := asFAT[nCONT,1]
          cMOTIVO := asFAT[nCONT,2]
          PROD->(dbseek(cPROD))
          zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
          MOTDEV->(dbseek(cMOTIVO))
          zMOTIVO := left(MOTDEV->Descricao,25)

          nQtyProd  := 0
          nQtyValor := 0
          nQtyMotivo   := 0
          nVlrMotivo   := 0


   endif

   nQtyProd  := 0
   nQtyValor := 0
   nQtyMotivo   := 0
   nVlrMotivo   := 0


   qstopprn(.f.)

return



static function i_get_dados

   aDados := {}

   aadd(aDados,{"HEADER","MOT","SUB","DEF",0})

   do while ! FAT->(eof())

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek(FAT->Cod_cli))

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          separa_dados(ITEN_FAT->Cod_prod,ITEN_FAT->Cod_motdev,ITEN_FAT->Cod_subsys,ITEN_FAT->cod_defe,ITEN_FAT->Quantidade)

          ITEN_FAT->(Dbskip())
      enddo
      FAT->(dbskip())

   enddo

   gera_arquivo()

return

static function separa_dados(cProd,cMot,cSub,cDefe,nquant)
local nKey := 0
local nQty := 0
local nFile := 0
local cBuffer := 0
local cFileName := ""
local cPROD_ATU := ""


   PROD->(dbsetorder(4))

   //nFile := fcreate("C:\qsystxt\"+cFileName,0)


   if !empty(cPROD)
       nKey := 0
       nKey := ascan(aDados,{|ckey| cKey[1] == cPROD+"P"})

       if nKey > 0
          aDados[nKey,2] += nQuant
       else
          aadd(aDados,{cPROD+"P",nQuant,cPROD})
       endif
    endif

    if ! empty(cPROD) .and. ! empty(cMOT)
       nKey := 0
       nKey := ascan(aDados,{|ckey| cKey[1] == cPROD + "M" + cMot})

       if nKey > 0
          aDados[nKey,2] += nQuant
       else
          aadd(aDados,{cPROD+"M"+cMot,nQuant,cPROD+cMot})
       endif
    endif

    if ! empty(cPROD) .and. ! empty(cMOT) .and. ! empty(cSub)

       nKey := 0
       nKey := ascan(aDados,{|ckey| cKey[1] == cPROD+cMot+"S"+cSUB})

       if nKey > 0
          aDados[nKey,2] += nQuant
       else
          aadd(aDados,{cPROD+cMot+"S"+cSUB,nQuant,cPROD+cMot+cSUB})
       endif
    endif

    if !empty(cPROD) .and. !empty(cMOT) .and. ! empty(cSub) .and. ! empty(cDefe)

       nKey := 0
       nKey := ascan(aDados,{|ckey| cKey[1] == cPROD+cMot+cSub+"D"+cDefe})

       if nKey > 0
          aDados[nKey,2] += nQuant
       else
          aadd(aDados,{cPROD+cMot+cSub+"D"+cDefe,nQuant,cPROD+cMot+cSub+cDefe})
       endif
    endif


return



static function gera_arquivo

local nCONT := 1
local cBuffer := ""
local cPROD_ATU := ""
local nFile := 0
local cFileName := ""

   cFileName := "Rel 574 - "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".xls"

   aDados := aSort(aDados,,,{|x,y| x[3]  < y[3] })

   cPROD_ATU := left(aDados[1,1],5)

   cBuffer := Chr(9)+Chr(9)+"Relatorio de analise de Devolucoes de "+dtoc(dINI)+" a " + dtoc(dFIM)+chr(9)+"574"
   cBuffer += Chr(9)+Chr(9)+""+chr(13)+chr(10)

   cBuffer += "Ref."+Chr(9)+"Ref"+Chr(9)+"Produto/Motivo/ sub Sistema / Defeito"+chr(9)+"Quantidade"
   cBuffer += Chr(9)+Chr(9)+""+chr(13)+chr(10)



   nCONT := 1
   do while  nCONT <= len(aDados)


      if at("P",aDados[nCOnt,1]) > 0
         PROD->(dbseek(substr(aDados[nCont,3],1,5)))
         cBuffer += PROD->Cod_ass+chr(9)+PROD->Cod_fabr+chr(9)+PROD->Descricao+chr(9)+transf(aDados[nCont,2],"@R 9999999")
         cBuffer += chr(13)+chr(10)
         //fwrite(nFile,cBuffer,len(cBuffer))
      endif


      if at("M",aDados[nCont,1]) > 0
         PROD->(dbseek(substr(aDados[nCont,3],1,5)))
         MOTDEV->(dbseek(substr(aDados[nCont,3],6,2)))
         cBuffer += PROD->Cod_ass+chr(9)+PROD->Cod_fabr+chr(9)+"    "+MOTDEV->Descricao+chr(9)+transf(aDados[nCont,2],"@R 9999999")
         cBuffer += chr(13)+chr(10)
         //fwrite(nFile,cBuffer,len(cBuffer))
      endif

      if at("S",aDados[nCont,1]) > 0
         PROD->(dbseek(substr(aDados[nCont,3],1,5)))
         SUBSYS->(dbseek(substr(aDados[nCont,3],8,2)))
         cBuffer += PROD->Cod_ass+chr(9)+PROD->Cod_fabr+chr(9)+"        "+SUBSYS->Descricao+chr(9)+transf(aDados[nCont,2],"@R 9999999")
         cBuffer += chr(13)+chr(10)
         //fwrite(nFile,cBuffer,len(cBuffer))
      endif

      if at("D",aDados[nCont,1]) > 0
         PROD->(dbseek(substr(aDados[nCont,3],1,5)))
         DEFEITO->(dbseek(substr(aDados[nCont,3],10,2)))
         cBuffer += PROD->Cod_ass+chr(9)+PROD->Cod_fabr+chr(9)+"             "+DEFEITO->Descricao+chr(9)+transf(aDados[nCont,2],"@R 9999999")
         cBuffer += chr(13)+chr(10)
         //fwrite(nFile,cBuffer,len(cBuffer))
      endif

      nCONT++
      if nCONT > len(aDados)
         nCONT := len(aDados)
         exit
      endif


      if left(aDados[nCont,1],5) != cPROD_ATU
         cBuffer += ""
         cBuffer += chr(13)+chr(10)
         //fwrite(nFile,cBuffer,len(cBuffer))
         cPROD_ATU := left(aDados[nCont,1],5)
      endif


   enddo

   nFile := fcreate("C:\qsystxt\"+cFileName,0)

   fWrite(nfile,cBuffer,len(cBuffer))

   fclose(nfile)





return



static function i_impre_xls
    local nQtyMotivo := 0
    local nQtyProd   := 0
    local nQtyTotal  := 0

    local nVlrMotivo := 0
    local nVlrProd   := 0
    local nVlrTotal  := 0
    local nVALOR     := 0

    local nCONT       := 0
    local cPROD       := 0
    local aFAT        := {}
    local asFAT       := {}
    local aSub    := {}
    local aDef    := {}

    local lTEM := .T.
    local zPROD := space(50)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())  

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nVALOR += q_soma_st()

             aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->cod_Motdev,ITEN_FAT->Quantidade})
//             aadd(aSUB,{right(PROD->Codigo,5),ITEN_FAT->cod_Motdev,ITEN_FAT->Quantidade})

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
   if lTEM

       cPROD    := asFAT[1,1]
       cMOTIVO  := asFAT[1,2]
       PROD->(dbseek(cPROD))
       MOTDEV->(dbseek(cMOTIVO))
       zPROD   := left(PROD->Cod_fabr,6)+chr(9)+PROD->Cod_ass+chr(9)+left(PROD->Descricao,30)
       zMOTIVO := left(MOTDEV->Descricao,25)


       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              @prow()+1,0 say ""
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO + " "+"574"
              @ prow()+1,0 say "Ref1"+chr(9)+"Ref2"+chr(9)+"Descricao"+chr(9)+"Motivo da Devolucao"+chr(9)+"Qtde"+chr(9)+"Valor Total"
              @ prow()+1,0 say ""
           endif

           nQtyProd   += asFAT[nCONT,3]


           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1]+asFAT[nCONT,2] != cPROD+cMOTIVO
              @ prow()+1,00 say zPROD
              @ prow()  ,pcol() say chr(9)+zMOTIVO
              @ prow()  ,pcol() say chr(9)+transf(nQtyMotivo,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nVlrMotivo,"@E 99,999,999.99")

              cMOTIVO := asFAT[nCONT,2]
              MOTDEV->(dbseek(cMOTIVO))
              zMOTIVO := left(MOTDEV->Descricao,25)

              nQtyMotivo   := 0
              nVlrMotivo   := 0
           endif


           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00     say zPROD
              @ prow()  ,pcol() say chr(9)+"Total do Produto"
              @ prow()  ,pcol() say chr(9)+transf(nQtyProd,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nVlrProd,"@E 99,999,999.99")
              @ prow()+1,00     say " "

              cPROD   := asFAT[nCONT,1]
              cMOTIVO := asFAT[nCONT,2]
              PROD->(dbseek(cPROD))
              zPROD   := left(PROD->Cod_fabr,6)+chr(9)+PROD->Cod_ass+chr(9)+left(PROD->Descricao,30)
              MOTDEV->(dbseek(cMOTIVO))
              zMOTIVO := left(MOTDEV->Descricao,25)

              nQtyProd     := 0
              nVlrProd     := 0
              nQtyMotivo   := 0
              nVlrMotivo   := 0
           endif
       enddo

       //   @ prow()+1,00 say zPROD
       //   @ prow()  ,pcol() say chr(9)+zMOTIVO
       //   @ prow()  ,pcol() say chr(9)+transf(nQtyMotivo,"@R 999999")
       //   @ prow()  ,pcol() say chr(9)+transf(nVlrMotivo,"@E 99,999,999.99")
       // /
       //   cPROD   := asFAT[nCONT,1]
       //   cMOTIVO := asFAT[nCONT,2]
       //   PROD->(dbseek(cPROD))
       //   zPROD   := left(PROD->Cod_fabr,6)+chr(9)+PROD->Cod_ass+chr(9)+left(PROD->Descricao,30)
       //   MOTDEV->(dbseek(cMOTIVO))
       //   zMOTIVO := left(MOTDEV->Descricao,25)
       //
       //   nQtyMotivo   := 0
       //   nVlrMotivo   := 0
       //
       //   @ prow()+1,00 say zPROD
       //   @ prow()  ,pcol() say chr(9)+"Total do Produto"
       //   @ prow()  ,pcol() say chr(9)+transf(nQtyProd,"@R 999999")
       //   @ prow()  ,pcol() say chr(9)+transf(nVlrProd,"@E 99,999,999.99")
       //
       //   cPROD   := asFAT[nCONT,1]
       //   cMOTIVO := asFAT[nCONT,2]
       //   PROD->(dbseek(cPROD))
       //   zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
       //   MOTDEV->(dbseek(cMOTIVO))
       //   zMOTIVO := left(MOTDEV->Descricao,25)
       //
          nQtyProd  := 0
          nQtyValor := 0
          nQtyMotivo   := 0
          nVlrMotivo   := 0


   endif

   nQtyProd  := 0
   nQtyValor := 0
   nQtyMotivo   := 0
   nVlrMotivo   := 0


   qstopprn(.f.)

return



