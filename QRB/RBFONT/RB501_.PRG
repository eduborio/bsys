/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: LISTAGEM DE CONTAS A RECEBER
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MARCO DE 1997
// OBS........:
function rb501

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||lastkey()==27}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nTOT    := 0
private nTOT_DIA:= 0
private cPEDINI := space(10)
private cPEDFIM := space(10)
private cDOC    := space(2)
private cBANCO  := space(5)
private cDESC   := space(30)
private cORDEM  := space(1)
private nOrdem  := 0
private SBLOC1  := qlbloc("B501B","QBLOC.GLO")

fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cOrdem   ,sBLOC1             )} ,"ORDEM"   })

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })

aadd(aEDICAO,{{ || qgetx(-1,0,@cPEDINI                     ) } ,"PEDINI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPEDFIM                     ) } ,"PEDFIM" })

aadd(aEDICAO,{{ || view_doc(-1,0,@cDOC                       ) } ,"DOC"       })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do cliente

aadd(aEDICAO,{{ || view_banco(-1,0,@cBANCO                       ) } ,"BANCO"       })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do cliente


do while .T.

   qlbloc(05,0,"B501A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cBANCO := space(5)
   cORDEM := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "DATA_INI"
           //if empty(dDATA_INI) ; return .F. ; endif
           if ! empty(dDATA_INI)
              dDATA_FIM := qfimmes(dDATA_INI)
              qrsay(XNIVEL+1,dDATA_FIM)
           endif


      case cCAMPO == "ORDEM"

           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"VE",{"Vencimento","Emissao"}))


      case cCAMPO == "DATA_FIM"
           if ! empty(dDATA_FIM) .and. ! empty(dDATA_INI)
              if dDATA_INI > dDATA_FIM
                 qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "DOC"

           qrsay(XNIVEL,strzero(val(cDOC),2))

           if empty(cDOC)
              qrsay(XNIVEL+1, "Todos os Documentos.......")
              cDESC := " Todos os Tipos de Documentos "
           else
              if ! TIPO_DOC->(Dbseek(cDOC:=strzero(val(cDOC),2)))
                 qmensa("Tipo de Documento n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(TIPO_DOC->Descricao,30))
                 cDESC := left(TIPO_DOC->Descricao,30)
              endif
           endif

      case cCAMPO == "BANCO"

           BANCO->(Dbsetorder(3))

           qrsay(XNIVEL,strzero(val(cBANCO),5))

           if empty(cBANCO)
              qrsay(XNIVEL+1, "Todos os Bancos.......")
              cDESC := " Todos os Bancos "
           else
              if ! BANCO->(Dbseek(cBANCO:=strzero(val(cBANCO),5)))
                 qmensa("Banco n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(BANCO->Descricao,30))
                 cDESC := left(BANCO->Descricao,30)
              endif
           endif



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTAS A RECEBER " + cDESC

   //if empty(cPEDINI)

   if cOrdem == "V"
      RECEBER->(dbclearfilter())
      RECEBER->(dbsetfilter({|| Data_Venc >= dDATA_INI .and. Data_venc <= dDATA_FIM .and. iif(!empty(cBANCO),Receber->Cod_Banco == cBanco,)}))
      RECEBER->(dbsetorder(2))  // DATA_VENC
      RECEBER->(dbgotop())
   else
      RECEBER->(dbclearfilter())
      RECEBER->(dbsetfilter({|| Data_emiss >= dDATA_INI .and. Data_emiss <= dDATA_FIM .and. iif(!empty(cBANCO),Receber->Cod_Banco == cBanco,)}))
      RECEBER->(dbsetorder(4))  // DATA_VENC
      RECEBER->(dbgotop())
   endif

   //else
   //   cPEDINI := "PED "+alltrim(cPEDINI)
   //   cPEDFIM := "PED "+alltrim(cPEDFIM)
   //   RECEBER->(dbsetfilter({|| Fatura >= cPEDINI .and. Fatura <= cPEDFIM .and.  iif(!empty(cDOC),Tipo_doc == cDOC,)}))
   //   RECEBER->(dbsetorder(11))  // DATA_VENC
   //   RECEBER->(dbgotop())
   //endif
   
   qmensa("")

return .T.

static function i_impressao

   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      if ! empty(cPEDINI)
         i_impre_ped()
      else
         i_impre_prn()
      endif
   endif

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

   local nMAXLIN := 55
   nTOT    := 0
   nTOT_DIA:= 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")

   RECEBER->(dbgotop())

   if cORdem == "V"
      dVENC := RECEBER->Data_venc
   else
      dVENC := RECEBER->Data_emiss
   endif
   
   do while ! RECEBER->(eof()) //.and. RECEBER->Data_venc >= dDATA_INI .and. RECEBER->Data_venc <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if mod(RECEBER->(recno()),35) == 1
          if ! qlineprn() ; exit ; endif
       endif

       @ prow(),pcol() say XCOND1

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,132)
          @ prow()+1, 0 say "DT. VCTO   DT.EMISS     DOCTO       VALOR    CLIENTE                       HISTORICO                      BANCO   TIPO"
          @ prow()+1, 0 say replicate("-",132)
       endif

       CLI1->(Dbseek(RECEBER->Cod_cli))
       SITUA->(dbseek(RECEBER->Situacao))

       @ prow()+1,00  say dtoc(RECEBER->Data_venc)         + " " +;
                          dtoc(RECEBER->Data_Emiss)        + " " +;
                          RECEBER->Fatura
                          
       @ prow()  ,31  say transform(RECEBER->Valor_liq, "@E 999,999.99")
       @ prow()  ,45  say left(CLI1->Razao,28)
       @ prow()  ,75  say strtran(left(RECEBER->Historico,28),'"','')
       @ prow()  ,106 say i_MantraBank()
       @ prow()  ,114 say i_MantraBoleto()

       nTOT_DIA := nTOT_DIA + RECEBER->Valor_liq
       nTOT := nTOT + RECEBER->Valor_liq

       RECEBER->(dbskip())

       if cOrdem == "V"

          if RECEBER->Data_venc != dVENC
             @ prow()+1,0 say XAENFAT+"Total do dia................: "+transform(nTOT_DIA, "@E 999,999.99")+XDENFAT
             nTOT_DIA := 0
             dVENC := RECEBER->Data_venc
          endif
       else

          if RECEBER->Data_emiss != dVENC
             @ prow()+1,0 say XAENFAT+"Total do dia................: "+transform(nTOT_DIA, "@E 999,999.99")+XDENFAT
             nTOT_DIA := 0
             dVENC := RECEBER->Data_emiss
          endif
       endif
   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say XAENFAT + "Total do dia...............: " + transform(nTOT_DIA, "@E 999,999.99")+XDENFAT
      nTOT_DIA := 0
      if cOrdem == "V"
         dVENC := RECEBER->Data_venc
      else
         dVENC := RECEBER->Data_emiss
      endif
   endif

   @ prow()+1, 0 say replicate("-",132)
   @ prow()+1,0 say XAENFAT +       "Total Geral............... " + transform(nTOT, "@E 99,999,999.99") + XDENFAT
   @ prow()+1, 0 say ""


   nTOT     := 0
   nTOT_DIA := 0
   
   qstopprn()

return


static function i_impre_ped

   local nMAXLIN := 55
   nTOT    := 0
   nTOT_DIA:= 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")

   RECEBER->(dbgotop())

  // dVENC := RECEBER->Data_venc
   
   do while ! RECEBER->(eof()) //.and. RECEBER->Data_venc >= dDATA_INI .and. RECEBER->Data_venc <= dDATA_FIM .and. qcontprn()  // condicao principal de loop

       if mod(RECEBER->(recno()),35) == 1
          if ! qlineprn() ; exit ; endif
       endif

       @ prow(),pcol() say XCOND1

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,132)
          @ prow()+1, 0 say "DT. VCTO   DT.EMISS     DOCTO       VALOR    CLIENTE                                                 HISTORICO         "
          @ prow()+1, 0 say replicate("-",132)
       endif

       CLI1->(Dbseek(RECEBER->Cod_cli))
       SITUA->(dbseek(RECEBER->Situacao))

       @ prow()+1,00  say dtoc(RECEBER->Data_venc)         + " " +;
                          dtoc(RECEBER->Data_Emiss)        + " " +;
                          RECEBER->Fatura
                          
       @ prow()  ,31  say transform(RECEBER->Valor_liq, "@E 999,999.99")
       @ prow()  ,45  say left(CLI1->Razao,38)
       @ prow()  ,85  say strtran(left(RECEBER->Historico,38),'"','')

       nTOT_DIA := nTOT_DIA + RECEBER->Valor_liq
       nTOT := nTOT + RECEBER->Valor_liq

       RECEBER->(dbskip())

//       if RECEBER->Data_venc != dVENC
//          @ prow()+1,0 say XAENFAT+"Total do dia................: "+transform(nTOT_DIA, "@E 999,999.99")+XDENFAT
//          nTOT_DIA := 0
//          dVENC := RECEBER->Data_venc
//       endif

   enddo
//   if nTOT_DIA <> 0
//      @ prow()+1,0 say XAENFAT + "Total do dia...............: " + transform(nTOT_DIA, "@E 999,999.99")+XDENFAT
//      nTOT_DIA := 0
//      dVENC := RECEBER->Data_venc
//   endif

   @ prow()+1, 0 say replicate("-",132)
   @ prow()+1,0 say XAENFAT +       "Total Geral............... " + transform(nTOT, "@E 99,999,999.99") + XDENFAT
   @ prow()+1, 0 say ""


   nTOT     := 0
   nTOT_DIA := 0
   
   qstopprn()

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls

   local nMAXLIN := 55
   nTOT    := 0
   nTOT_DIA:= 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")

   RECEBER->(dbgotop())

   if cOrdem == "V"
      dVENC := RECEBER->Data_venc
   else
      dVENC := RECEBER->Data_emiss
   endif
   
   do while ! RECEBER->(eof()) //.and. RECEBER->Data_venc >= dDATA_INI .and. RECEBER->Data_venc <= dDATA_FIM .and. qcontprn()  // condicao principal de loop


       if mod(RECEBER->(Recno()),150) == 1
          if ! qlineprn() ; exit ; endif
       endif

       @ prow(),pcol() say XCOND1

       if XPAGINA == 0 //.or. prow() > K_MAX_LIN
          qpageprn()
          @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+chr(9)+cTITULO
          @ prow()+1, 0 say "Vencimento"+chr(9)+"Emissao"+chr(9)+"Documento"+chr(9)+ "Valor"+chr(9)+"Cliente"+chr(9)+"Historico"+chr(9)+"Banco"+chr(9)+"Tipo Boleto"+Chr(9)+ "Representante"
          @ prow()+1, 0 say ""
       endif

       CLI1->(Dbseek(RECEBER->Cod_cli))
	   REPRES->(dbseek(CLI1->Cod_repres))
       SITUA->(dbseek(RECEBER->Situacao))

       @ prow()+1,00  say dtoc(RECEBER->Data_venc)         + chr(9) +;
                          dtoc(RECEBER->Data_Emiss)        + chr(9) +;
                          RECEBER->Fatura +chr(9)
                          
       @ prow()  ,pcol()  say transform(RECEBER->Valor_liq, "@E 999,999.99")
       @ prow()  ,pcol()  say chr(9)+left(CLI1->Razao,38)
       @ prow()  ,pcol()  say chr(9)+strtran(left(RECEBER->Historico,38),'"','')
       @ prow()  ,pcol()  say chr(9)+i_mantraBank()
       @ prow()  ,pcol()  say chr(9)+i_mantraBoleto()
	   @ prow()  ,pcol()  say chr(9)+left(REPRES->Razao,25)

       nTOT_DIA := nTOT_DIA + RECEBER->Valor_liq
       nTOT := nTOT + RECEBER->Valor_liq

       RECEBER->(dbskip())

       if cOrdem == "V"

          if RECEBER->Data_venc != dVENC
             @ prow()+1,0 say chr(9)+chr(9)+"Total do dia:"+chr(9)+transform(nTOT_DIA, "@E 999,999.99")
             @ prow()+1, 0 say ""

             nTOT_DIA := 0
             dVENC := RECEBER->Data_venc
          endif

       else
          if RECEBER->Data_emiss != dVENC
             @ prow()+1,0 say chr(9)+chr(9)+"Total do dia:"+chr(9)+transform(nTOT_DIA, "@E 999,999.99")
             @ prow()+1, 0 say ""

             nTOT_DIA := 0
             dVENC := RECEBER->Data_emiss
          endif

       endif

   enddo
   if nTOT_DIA <> 0
      @ prow()+1,0 say chr(9)+chr(9)+"Total do dia"+chr(9)+transform(nTOT_DIA, "@E 999,999.99")
      nTOT_DIA := 0
      if cOrdem == "V"
         dVENC := RECEBER->Data_venc
      else
         dVENC := RECEBER->Data_emiss
      endif
   endif

   @ prow()+1, 0 say ""
   @ prow()+1,0  say chr(9)+chr(9)+"Total Geral"+chr(9)+transform(nTOT, "@E 9,999,999.99")
   @ prow()+1, 0 say ""


   nTOT     := 0
   nTOT_DIA := 0
   
   qstopprn()

return

static function i_MantraBank
local cRet := "    "
   if BANCO->(dbseek(RECEBER->Cod_Banco))
      cRet := rtrim(BANCO->Banco)

      if cRet == "0356"
         cRET := "REAL"
      endif
	  
	  if cRet == "0033"
         cRET := "SANT"
      endif

      if cRet == "0001"
         cRET := "BB"
      endif

      if cRet == "0341"
         cRET := "ITAU"
      endif

      if cRet == "0399"
         cRET := "HSBC"
      endif
	  
	  if cRet == "0246"
         cRET := "ABC "
      endif



   else
      cRet := "    "
   endif

return cRet

function i_MantraBoleto
local cRET := "     "

   FAT->(dbsetorder(9))
   if  FAT->(dbseek(left(RECEBER->Fatura,6)+"55"))
       do while ! FAT->(eof()) .and. (FAT->num_fatura == left(RECEBER->Fatura,6) )
	      
		  if FAT->Dt_emissao == RECEBER->data_emiss   .and. FAT->Es =="S"
		     cRet := qabrev(FAT->Boleto,"123456789", {"Boleto","Vist Bol","Vist Dep","Antecip","Nulo","Plano Mkt","Abater Cr","Segurar","Praz Dep"})
		  endif	 
	   
	      FAT->(dbskip())
	   enddo
       
   else
       if FAT->(dbseek(left(RECEBER->Fatura,6)+"01"))
          cRet := qabrev(FAT->Boleto,"123456789", {"Boleto","Vist Bol","Vist Dep","Antecip","Nulo","Plano Mkt","Abater Cr","Segurar","Praz Dep"})
       else
          cRet := "         "
       endif
   endif
return cRet //qabrev(FAT->Boleto,"123456789", {"Boleto","Vist Bol","Vist Dep","Antecip","Nulo","Plano Mkt","Abater Cr","Segurar","Praz Dep"})


