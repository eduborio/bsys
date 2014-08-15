/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: LISTAGEM DE CONTAS A RECEBER POR CLIENTES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: AGOSTO DE 2011
// OBS........:
function rb513

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dINI        // define data inicial para impressao
private dFIM        // define datao final para impressao
private aEDICAO       := {}    // vetor para os campos de entrada de dados
private aPainelDiario := {}
private aPainelMensal := {}


//fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI                          ) } ,"INI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM                          ) } ,"FIM"  })

do while .T.

   qlbloc(05,0,"B513A","QBLOC.GLO",1)

   XNIVEL     := 1
   XFLAG      := .T.
   dINI  := ctod("")
   dFIN  := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_gera_rpt()
   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "INI"
           if empty(dINI) ; return .F. ; endif
           dFIM := qfimmes(dINI)
           qrsay(XNIVEL+1,dFIM)

      case cCAMPO == "FIM"
           if empty(dFIM) ; return .F. ; endif
           if dINI > dFIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "CLIENTE"

           qrsay(XNIVEL,strzero(val(cCLIENTE),5))

           if empty(cCLIENTE)
              qrsay(XNIVEL+1, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cCLIENTE:=strzero(val(cCLIENTE),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CLI1->Razao,30))
              endif
           endif

   endcase

return .T.

static function i_gera_rpt

    get_receber()
    //get_recebidos()
    geraxls()
    alert("Arquivo Gerado com sucesso... em c:\qsystxt ")
return

static function Get_receber

   aPainelMensal := {}
   aPainelDiario := {}
   aadd(aPainelMensal,{"MENSAL",0,0,0})
   aadd(aPainelDiario,{"DIARIO",0,0,0})

   RECEBER->(dbsetfilter({|| Data_venc >= ctod("01/01/2012") .and. Data_venc <= dFIM }))
   RECEBER->(dbsetorder(2))
   RECEBER->(dbgotop())


   do While ! RECEBER->(eof())

      i_SeparaPorMes(RECEBER->Data_venc,RECEBER->Valor,"RECEBER")


      if RECEBER->Data_venc >= dINI
         i_SeparaPorDia(RECEBER->Data_venc,RECEBER->Valor,"RECEBER")
      endif


      RECEBER->(dbskip())
   enddo


   RECEBIDO->(dbclearfilter())
   RECEBIDO->(dbsetfilter({|| Data_venc >= ctod("01/01/2012") .and. Data_venc <= dFIM }))
   RECEBIDO->(dbsetorder(2))

   RECEBIDO->(dbgotop())


   do While ! RECEBIDO->(eof())

      i_SeparaPorMes(RECEBIDO->Data_venc,RECEBIDO->Valor,"RECEBER")

      if RECEBIDO->Data_venc >= dINI
         i_SeparaPorDia(RECEBIDO->Data_venc,RECEBIDO->Valor,"RECEBER")
      endif

      RECEBIDO->(dbskip())
   enddo

   RECEBIDO->(dbclearfilter())
   RECEBIDO->(dbsetfilter({|| Data_pagto >= ctod("01/01/2012") .and. Data_pagto <= dFIM }))
   RECEBIDO->(dbsetorder(6))

   RECEBIDO->(dbgotop())


   do While ! RECEBIDO->(eof())

      i_SeparaPorMes(RECEBIDO->Data_pagto,RECEBIDO->Valor,"RECEBIDO")

      if RECEBIDO->Data_pagto >= dINI
         i_SeparaPorDia(RECEBIDO->Data_pagto,RECEBIDO->Valor,"RECEBIDO")
      endif

      RECEBIDO->(dbskip())
   enddo



return

static function i_SeparaPorMes(dData,nValor,cTipo)
local nKey := 0
local cAnoMes := dtoAm(dData)

      nKey := ascan(aPainelMensal,{|ckey| cKey[1] == cAnoMes})

      if nKey > 0
         if cTipo == "RECEBER"
            aPainelMensal[nKey,2] += nValor
            aPainelMensal[nKey,4] -= nValor
         else
            aPainelMensal[nKey,3] += nValor
            aPainelMensal[nKey,4] += nValor
         endif
      else
         if cTIPO == "RECEBER"
            aadd(aPainelMensal,{cAnomes,nValor,0,nValor*(-1)})
         else
            aadd(aPainelMensal,{cAnomes,0,nValor,nValor})
         endif
      endif


return


static function geraXls
local nCont := 1
local nFile := 0
local cFileName := ""
local cBuffer := ""
local nRec, nPag, nDif := 0
local nvenc := 0

     nRec := 0
     nPag := 0
     nDif := 0

     cFileName := "Painel Financeiro 513 - "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".xls"

     cBuffer := "Painel de Controle Financeiro - 513" +chr(13)+chr(10)

     aPainelMensal := asort(aPainelMensal,,,{|x,y| x[1] < y[1]})
     aPainelDiario := asort(aPainelDiario,,,{|x,y| x[1] < y[1]})

         //cBuffer += aPainelMensal[nCont,1] +chr(9)+transform(aPainelMensal[nCont,2],"@E 99,999,999.99")+chr(9)+transform(aPainelMensal[nCont,3],"@E 99,999,999.99")+chr(9)+transform(aPainelMensal[nCont,4],"@E 99,999,999.99")+chr(13)+chr(10)



     cBuffer += chr(9)

     for nCONT := 1 to len(aPainelDiario)-1
         cBuffer += qnomemes(left(aPainelDiario[nCont,1],2))+right(aPainelDiario[nCONT,1],2)+chr(9)
     next

     cBuffer += chr(13)+chr(10)
     cBuffer += "A Receber"+chr(9)

     for nCONT := 1 to len(aPainelDiario)-1
         cBuffer += transform(aPainelDiario[nCont,2],"@E 999,999,999.99")+chr(9)
     next

     cBuffer += chr(13)+chr(10)
     cBuffer += "Recebido"+chr(9)

     for nCONT := 1 to len(aPainelDiario)-1
         cBuffer += transform(aPainelDiario[nCont,3],"@E 999,999,999.99")+chr(9)
     next

     cBuffer += chr(13)+chr(10)
     cBuffer += "Diferenca"+chr(9)

     for nCONT := 1 to len(aPainelDiario)-1
         cBuffer += transform(aPainelDiario[nCont,4],"@E 999,999,999.99")+chr(9)
     next

     cBuffer += chr(13)+chr(10)
     cBuffer += chr(13)+chr(10)+chr(9)

     for nCont := 1 to len(aPainelMensal)-1
         cBuffer += qnomemes(right(aPainelMensal[nCont,1],2))+"/"+left(aPainelMensal[nCont,1],4)+chr(9)
     next

     cBuffer += "Totais"+chr(13)+chr(10)+"a Receber"+chr(9)


     for nCont := 1 to len(aPainelMensal)-1
         cBuffer += transform(aPainelMensal[nCont,2],"@E 99,999,999.99")+chr(9)
         nRec += aPainelMensal[nCont,2]
     next

     cBuffer += transf(nRec,"@E 99,999,999.99")+chr(13)+chr(10)+"Recebido"+chr(9)


     for nCont := 1 to len(aPainelMensal)-1
         cBuffer += transform(aPainelMensal[nCont,3],"@E 99,999,999.99")+chr(9)
         nPag += aPainelMensal[nCont,3]

     next

     cBuffer += transform(nPag,"@E 99,999,999.99")+chr(13)+chr(10)+"Diferenca"+chr(9)

     for nCont := 1 to len(aPainelMensal)-1
         cBuffer += transform(aPainelMensal[nCont,4],"@E 99,999,999.99")+chr(9)
         nDif += aPainelMensal[nCont,4]
     next

     cBuffer += transform(nDif,"@E 99,999,999.99")+chr(13)+chr(10)

     cBuffer += chr(13)+chr(10)

     nVenc := getVencidos()

     cBuffer += "Vencidos ate 31/12/2011.: "+chr(9)
     cBuffer += transf(nVenc,"@E 999,999,999.99")+chr(13)+chr(10)
     cBuffer += "Vencidos ate "+ dtoc(dFim)+".: "+chr(9)
     cBuffer += transform(nDif*(-1),"@E 99,999,999.99")+chr(13)+chr(10)
     cBuffer += "Total.: "+chr(9)
     cBuffer += transform((nDif*(-1))+nVenc,"@E 99,999,999.99")+chr(13)+chr(10)


    //// for nCONT := 1 to len(aPainelDiario)-1
    //     cBuffer += aPainelDiario[nCont,1] +chr(9)+transform(aPaineldiario[nCont,2],"@E 99,999,999.99")+chr(9)+transform(aPainelDiario[nCont,3],"@E 99,999,999.99")+chr(9)+transform(aPainelDiario[nCont,4],"@E 99,999,999.99")+chr(13)+chr(10)
    // next


     nFile := fCreate("C:\Qsystxt\"+cFileName)
     fWrite(nFile,cBuffer,len(cBuffer))
     fClose(nFile)


return

static function i_separaPorDia(dData,nValor,cTipo)
local nKey := 0
local cMesDia := dtodm(dData)

      nKey := ascan(aPainelDiario,{|ckey| cKey[1] == cMesDia})

      if nKey > 0
         if cTipo == "RECEBER"
            aPainelDiario[nKey,2] += nValor
            aPainelDiario[nKey,4] -= nValor
         else
            aPainelDiario[nKey,3] += nValor
            aPainelDiario[nKey,4] += nValor
         endif
      else
         if cTIPO == "RECEBER"
            aadd(aPainelDiario,{cmesdia,nValor,0,nValor*(-1)})
         else
            aadd(aPainelDiario,{cmesdia,0,nValor,nValor})
         endif
      endif



return



static function dtoAm(dData)
return  strzero(year(dData),4) + strzero(month(dData),2)

static function dtodm(dData)
return  strzero(month(dData),2) + strzero(day(dData),2)

static function GetVencidos
local nTot_venc := 0

   RECEBER->(dbclearfilter())
   RECEBER->(dbsetfilter({|| Data_venc <= ctod("31/12/2011")  }))
   RECEBER->(dbsetorder(2))
   RECEBER->(dbgotop())


   do While ! RECEBER->(eof())

      nTot_venc += RECEBER->Valor_liq

      RECEBER->(dbskip())
   enddo



return ntot_venc



