/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE NOTAS FISCAIS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2010
// OBS........:
// ALTERACOES.:

function cl580
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR  := space(5)
private cES     := ""
//private sBLOC1  := qlbloc("B513B","QBLOC.GLO")

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
//aadd(aEDICAO,{{ || qesco(-1,0,@cES,sBLOC1)       } , "FIM"    })
aadd(aEDICAO,{{ || view_setor(-1,0,@cSETOR)     } , "SETOR"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })


do while .T.

   qlbloc(5,0,"B519A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cES := ""

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

   cTITULO := "LISTAGEM DE NOTAS FISCAIS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   //FAT->(dbSetFilter({|| !empty(FAT->Num_fatura) }, '!empty(FAT->Num_fatura)'))

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   PROD->(dbsetorder(4))
return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif
   
   if XLOCALIMP == "X"
		i_impre_xls()
   else	  
		alert("Suporte somente para excell!!")
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local aVend    := {}
    local aCli     := {}
    local aITENS   := {}
	local nEntSt := nSaiST := nTotEnt := nTotSai := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if FAT->No_nf
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif
	  
	  if FAT->St == 0
         FAT->(dbskip())
         loop  
      endif	  

      CLI1->(dbseek(FAT->Cod_cli))
	  
	  if mod(FAT->(recno()),500) == 0
					
	     if ! qlineprn() ; return ; endif
		 qgirabarra()
	  endif

      if XPAGINA == 0 
         qpageprn()

         @ prow()+1,0 say "Cfop" + chr(9) + "Nota"  + chr(9) + "Cliente" +  chr(9) + "Emissao" + chr(9) + "Saida" + Chr(9) + "ST Saida" + chr(9) + "Entrada" +chr(9) + "ST Entrada"
         @ prow()+1,0 say ""

      endif
	  
	  nTotal := 0
	  
	  ITEN_FAT->(dbseek(FAT->Codigo))
	  
	  Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->num_fat == FAT->Codigo
		  nTotal +=  (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
		  ITEN_FAT->(dbskip())
	  enddo
	  
	  @ prow()+1,00    say FAT->Cod_cfop + chr(9)
	  @ prow(), pcol() say FAT->Num_fatura  + chr(9)
	  @ prow(), pcol() say CLI1->razao  + chr(9)
	  @ prow(), pcol() say dtoc(FAT->Dt_emissao)  + chr(9)
	  
	  if FAT->Es ==  "S"
	     @ prow(), pcol() say transform(nTotal,"@E 9,999,999.99") + chr(9)
	     @ prow(), pcol() say transform(FAT->St,"@E 9,999,999.99")
		 nTotSai += nTotal
		 nSaiSt  += FAT->St
	  else
         @ prow(), pcol() say chr(9) + chr(9) + transform(nTotal,"@E 9,999,999.99") + chr(9)
	     @ prow(), pcol() say transform(FAT->St,"@E 9,999,999.99")
		 nTotEnt += nTotal
		 nEntSt  += FAT->St
      endif	  
	  
	  nTotal := 0

      FAT->(dbskip())

   enddo
   
   @ prow() + 1,00  say Chr(9) + Chr(9) + Chr(9) + Chr(9) + transform(nTotSai,"@E 9,999,999.99") + chr(9) + transform(nSaiSt,"@E 9,999,999.99") + chr(9)
   @ prow(), pcol() say transform(nTotEnt,"@E 9,999,999.99") + chr(9) + transform(nEntSt,"@E 9,999,999.99")

   qstopprn(.F.)

return
