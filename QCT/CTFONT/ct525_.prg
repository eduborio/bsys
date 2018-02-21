/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: CONFERENCIA DE LANCAMENTOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 1995
// OBS........:
// ALTERACOES.:
function ct525

#include "inkey.ch"
#define K_MAX_LIN 57
#define K9 chr(9)

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {|| lastkey() = 27}

private aEDICAO := {}                          // vetor para os campos
private cHIST                                  // historico
private cTIPOR                                 // tipo de totalizacao
private cTITULO                                // titulo do relatorio
private dINI    := dFIM := CTOD("")            // datas inicio e final

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || NIL           } , NIL   })
aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)           } , "INI"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)           } , "FIM"   })

do while .T.

   qlbloc(5,0,"B525A","QBLOC.GLO")
   XNIVEL  := 1
   XFLAG   := .T.
   cTIPOR  := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "INI"
           if empty(dINI)
              return .F.
           endif
           dFIM := dINI
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao


   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   local dDATALANC
   private nTOTSUB := 0.00
   private nTOTGER := 0.00
   

		if ! qinitprn() ; return ; endif

		 oServer := TMySQLServer():New(XSERVER, "root", "borios")
		 if oServer:NetErr()
			Alert(oServer:Error())
		 endif

		 oServer:SelectDB("comercial")
		 
		 cQuery := " select distinct(nf.id), if(nf.tipo_nota = 0, 'entrada','saida') as tipo,  nf.id, nf.data_emissao , nf.empresa_id, item.cfop_id as cfop_id, nf.numero_nota,cli.nome as cliNome, "
		 cQuery += " sum(item.valor_unitario * item.quantidade) as produtos, "
		 cQuery += " sum(item.valor_ipi) as valorIpi, "
		 cQuery += " sum(item.valor_icmsst) as valorST "
		 cQuery += " from nota_fiscal nf "
		 cQuery += " join item_nota_fiscal item on item.nota_fiscal_id = nf.id "
		 cQuery += " join clientes cli on cli.id = nf.cliente_id "
		 cQuery += " where nf.data_emissao between "+ dtos(dIni) + " and " + dtos(dFim)
		 cQuery += " and nf.cancelada = 0 "
		 cQuery += " group by nf.id "
		 cQuery += " order by nf.empresa_id, nf.tipo_nota, nf.data_emissao, nf.numero_nota "
		 
         oQuery := oServer:Query(cQuery)
   
	     if oQuery:NetErr()
		    Alert(oQuery:Error())
	     endif
   
		 alert(oQuery:LastRec())
   
         nCont := 1
		 nContLanc := 0
		 cDoc := "000000"
		 
		LANC->(dbsetorder(13))
		LANC->(dbgotop())
		PLAN->(dbsetorder(3))
   
  	     do while nCont <= oQuery:LastRec() 	 
		    row := oQuery:getRow(nCont)
			
			
			if mod(nCont,100) == 0
				if ! qlineprn() ; return ; endif
			endif

			if XPAGINA == 0 
				@ prow()+1,0    say 'Empresa' 
				@ prow(),pcol() say chr(9) +'Tipo'
				@ prow(),pcol() say chr(9) +'Emissao'
				@ prow(),pcol() say chr(9) +'Nota Fiscal'
				@ prow(),pcol() say chr(9) +'Cfop'
				@ prow(),pcol() say chr(9) +'Cliente'
				@ prow(),pcol() say chr(9) +'Valor Total'
				@ prow(),pcol() say chr(9) +'Icms ST'
				@ prow(),pcol() say chr(9) +''
				@ prow(),pcol() say chr(9) +'Numero Lcto'
				@ prow(),pcol() say chr(9) +'Documento'
				@ prow(),pcol() say chr(9) +'Cod. Debito'
				@ prow(),pcol() say chr(9) +'Debito'
				@ prow(),pcol() say chr(9) +'Cod. Credito'
				@ prow(),pcol() say chr(9) +'Credito'
				@ prow(),pcol() say chr(9) +'Historico'
				@ prow(),pcol() say chr(9) +'Valor Contabil'
				qpageprn()
			endif
		    
			@ prow()+1,0    say get(row,'empresa_id')   
			@ prow(),pcol() say K9 + get(row,'tipo')
			@ prow(),pcol() say K9 + dtoc(get(row,'data_emissao'))
			@ prow(),pcol() say K9 + get(row,'numero_nota')
			@ prow(),pcol() say K9 + str(get(row,'cfop_id'))
			@ prow(),pcol() say K9 + get(row,'cliNome')
			@ prow(),pcol() say K9 + transform(abs(get(row,'produtos')),"@E 9,999,999,999.99")
			@ prow(),pcol() say K9 + transform(abs(get(row,'valorST')),"@E 9,999,999,999.99")
			@ prow(),pcol() say K9 + " "
			
			cDoc := strzero(val(get(row,'numero_nota')),6)
					
			if LANC->(dbseek(cDoc))
				nContLanc := 0
												
				do while ! LANC->(eof()) .and. trim(LANC->Num_doc) == cDoc
					
					if nContLanc > 0 
						@ prow()+1,0    say ' ' 
						@ prow(),pcol() say K9 +' '
						@ prow(),pcol() say K9 +' '
						@ prow(),pcol() say K9 +' '
						@ prow(),pcol() say K9 +' '
						@ prow(),pcol() say K9 +' '
						@ prow(),pcol() say K9 +' '
						@ prow(),pcol() say K9 +' '
						@ prow(),pcol() say K9 +' ' 
					endif
					
					@ prow(), pcol() say K9 + LANC->Num_lanc
					@ prow(), pcol() say K9 + LANC->Num_doc
					@ prow(), pcol() say K9 + LANC->Cont_db
					PLAN->(dbseek(LANC->Cont_db))
					@ prow(), pcol() say K9 + PLAN->Descricao
					@ prow(), pcol() say K9 + LANC->Cont_cr
					PLAN->(dbseek(LANC->Cont_db))
					@ prow(), pcol() say K9 + PLAN->Descricao
					@ prow(), pcol() say K9 + LANC->Hist_comp
					@ prow(), pcol() say K9+transform(abs(LANC->Valor),"@E 9,999,999,999.99")

					nContLanc++
					LANC->(dbskip())
				enddo
			else
					@ prow(), pcol() say K9 + ""
					@ prow(), pcol() say K9 + ""
					@ prow(), pcol() say K9 + ""
					PLAN->(dbseek(LANC->Cont_db))
					@ prow(), pcol() say K9 + ""
					@ prow(), pcol() say K9 + ""
					PLAN->(dbseek(LANC->Cont_db))
					@ prow(), pcol() say K9 + ""
					@ prow(), pcol() say K9 + ""
					@ prow(), pcol() say K9 + ""
					@ prow(), pcol() say K9 + "Nao Contabilizou"
					@ prow(), pcol() say K9 + cDoc
			endif	
			
		    nCont++
	     enddo 	
		 
		 qstopprn(.F.)
		 
	oServer:close()

   //LANC->(dbseek(dINI,.T.))
   //dDATALANC := LANC->Data_lanc

 /*//  do while ! LANC->(eof()) .and. LANC->Data_lanc <= dFIM


      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 
         qpageprn()
         @ prow()+1,0 say "  Data        Ct.Db.    Descricao da Conta Deb.                    Documento          Valor"
      endif


   //qstopprn()*/

return

/////////////////////////////////////////////////////////////////////////////
// FORMATA O HISTORICO DO LANCAMENTO PARA O RELATORIO _______________________

static function i_historico
   cHIST := ""
   if (HIST->(dbseek(LANC->Hp1)),cHIST := rtrim(HIST->Descricao),NIL)
   if (HIST->(dbseek(LANC->Hp2)),cHIST += rtrim(HIST->Descricao),NIL)
   if (HIST->(dbseek(LANC->Hp3)),cHIST += rtrim(HIST->Descricao),NIL)
   cHIST += rtrim(LANC->Hist_comp)
return left(cHIST,65)

static function get(row,campo)
return  row:fieldget(campo)

