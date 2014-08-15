/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA CLARI - AGUA MINERAL
// OBJETIVO...: LISTAGEM DE CLIENTES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: JULHO de 2009
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

function cl303
//local   bESCAPE := {|| lastkey()==27}
local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27}

private cPROD  
private cCLI          // Codigo do Produto
private lNFOK := .F.
private XDRV_HB := "C:\QSYSTXT\"
private aReservas := {}

private aEDICAO := {}    // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________


aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI             )},"CLI"    })
aadd(aEDICAO,{{ || NIL                              },NIL       }) 
aadd(aEDICAO,{{ || NIL                              },NIL       })
aadd(aEDICAO,{{ || NIL                              },NIL       })
 
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD           )},"PROD"    })
aadd(aEDICAO,{{ || NIL                              },NIL       }) 
aadd(aEDICAO,{{ || NIL                              },NIL       }) 
aadd(aEDICAO,{{ || NIL                              },NIL       }) 
aadd(aEDICAO,{{ || NIL                              },NIL       }) //L1
aadd(aEDICAO,{{ || NIL                              },NIL       }) 
aadd(aEDICAO,{{ || NIL                              },NIL       }) 
aadd(aEDICAO,{{ || NIL                              },NIL       }) //L2
aadd(aEDICAO,{{ || NIL                              },NIL       }) 
aadd(aEDICAO,{{ || NIL                              },NIL       }) 
aadd(aEDICAO,{{ || NIL                              },NIL       }) //Local
aadd(aEDICAO,{{ || NIL                              },NIL       }) //Avariado
aadd(aEDICAO,{{ || NIL                              },NIL       }) //Avariado
aadd(aEDICAO,{{ || NIL                              },NIL       }) //Avariado
aadd(aEDICAO,{{ || NIL                              },NIL       }) //Avariado
aadd(aEDICAO,{{ || NIL                              },NIL       }) //Avariado
//aadd(aEDICAO,{{ || qconf("Pressione Esc pra sair...")},NIL       }) 


do while .T.

   qlbloc(5,0,"B303A","QBLOC.GLO",1)

   cPROD    := space(5)
   cCLI     := space(5)
   XNIVEL   := 1
   XFLAG    := .T.
   aReserva := {}

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

local cCOD_ASS := ""
local cExclusive1 := ""
local cExclusive2 := ""
local cExclusive3 := ""
local cExclusive4 := ""



   do case
      case cCAMPO == "CLI"

           if !empty(cCLI)
           //   qmensa("campo obrigatorio!!!","BL")
           //   return .F.			  
           //else		   
              qrsay(XNIVEL,cCLI:=strzero(val(cCLI),5))

              if ! CLI1->(dbseek(cCLI))
                 qmensa("Cliente nao encontrado !","B")
                 return .F.
              endif
			  qrsay(XNIVEL+1,left(CLI1->Razao,50))
			  CGM->(dbseek(CLI1->cgm_ent))
			  qrsay(XNIVEL+2,rtrim(CGM->municipio)+"/"+CGM->Estado)
			  
			  if AREA_EXC->(dbseek(CLI1->Cod_exc))
			     qrsay(XNIVEL+3,left(AREA_EXC->Descricao,23))
			  else
				 qrsay(XNIVEL+3,"")
			  endif	 
		   endif  

      case cCAMPO == "PROD"
           if ! empty(cPROD)
              if CONFIG->Modelo_fat == "1"
                 PROD->(dbsetorder(5))
                 if PROD->(dbseek(cPROD))
                    cPROD := right(PROD->Codigo,5)
                 else
                    PROD->(dbsetorder(3))
                    if PROD->(dbseek(cPROD))
                       fCPROD := right(PROD->Codigo,5)
                    endif
                 endif
                 PROD->(dbsetorder(4))
              endif
			  
			  cCOD_ASS := PROD->Cod_ass
			  
			  
			  
		   lExisteArea  := existeArea(CLI1->Cgm_ent)
		   lTemVinculo := iif(empty(CLI1->Cod_exc),.F.,.T.)
		 		
		   if lExisteArea .and. lTemVinculo
		      EXCLUSIV->(dbsetorder(4))
              if EXCLUSIV->(dbseek(CLI1->Cgm_ent + CLI1->Cod_exc + cPROD))
		         AREA_EXC->(dbseek(CLI1->Cod_exc))
				 cExclusive1 := alltrim(cCOD_ASS)
				 cExclusive2 := rtrim(EXCLUSIV->Cliente)
				 cExclusive3 := rtrim(EXCLUSIV->Desc_cid)+"/"+EXCLUSIV->Uf
				 cExclusive4 := left(AREA_EXC->Descricao,20)
			  endif	
		
		  else

              EXCLUSIV->(dbsetorder(3))

              if EXCLUSIV->(dbseek(CLI1->CGM_ENT + cPROD))
			     cExclusive1 := alltrim(cCOD_ASS)
				 cExclusive2 := rtrim(EXCLUSIV->Cliente)
				 cExclusive3 := rtrim(EXCLUSIV->Desc_cid)+"/"+EXCLUSIV->Uf
				 cExclusive4 := ""
              endif
		   endif

              if ! empty(cPROD)
                 qrsay(XNIVEL,cPROD:=strzero(val(cPROD),5))

                 if ! PROD->(dbseek(cPROD))
                    qmensa("Produto n„o encontrado !","B")
                    return .F.
                 endif

                 if CONFIG->Modelo_fat == "1"
                    qrsay ( XNIVEL+1 , left(PROD->Descricao,25) )
					qrsay ( XNIVEL+2 , left(PROD->Cod_fabr,6) )
					qrsay ( XNIVEL+3 , PROD->Marca )
                 else
                    qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )
                 endif
				 
				 limpaDados(XNIVEL)
				 preencheCampos(XNIVEL,cExclusive1,cExclusive2,cExclusive3,cExclusive4)

              endif
           endif

   endcase

return .T.

static function limpaDados( nNivel )
  
   qrsay(nNivel+4,"  ")
   qrsay(nNivel+5,"  ")
   qrsay(nNivel+6,"  ")
   qrsay(nNivel+7,"  ")
   qrsay(nNivel+8,"  ")
   qrsay(nNivel+9,"  ")
   qrsay(nNivel+10,"        ")
   qrsay(nNivel+11,"        ")
   qrsay(nNivel+12,"        ")
   qrsay(nNivel+13,"        ")
   qrsay(nNivel+14,"        ")
   qrsay(nNivel+15,"        ")
   qrsay(nNivel+16,"        ")
   qrsay(nNivel+17,"        ")
   qrsay(nNivel+18,"        ")
   qrsay(nNivel+19,"        ")
   qrsay(nNivel+20,"        ")

return

static function preencheCampos( nNivel,cExclusive1,cExclusive2,cExclusive3,cExclusive4 )

local aFaturas := {}
local nResto := 0
local nCont := 0

   if ! empty(CONFIG->qsysoff)
      qmensa("Opção desabilitada!!","BL")
	  return .F.
   endif
   

   i_reserva()
   INVENT->(dbsetorder(4))
   INVENT->(dbseek(right(PROD->Codigo,5)))
   nLocal    := INVENT->Quant_atu
   nAvariado := INVENT->Quant_defe
   nReserva  := buscaReservas(right(PROD->Codigo,5)) 
   nShowRoom := INVENT->Quant_show
   nTotal := nLocal + nReserva + nAvariado + nShowRoom
  
   qrsay(nNivel+4,PROD->Corredor + " " +PROD->Estante+" "+PROD->Prateleira)
   qrsay(nNivel+5,PROD->Corredor2 + " " +PROD->Estante2+" "+PROD->Prateleir2)
   qrsay(nNivel+6,transf(nLocal,"@R 9999999999") )
   qrsay(nNivel+7,transf(nReserva,"@R 9999999999") )
   qrsay(nNivel+8,transf(nAvariado,"@R 9999999999") )
   qrsay(nNivel+9,transf(nShowRoom,"@R 9999999999") )
   qrsay(nNivel+10,transf(nTotal,"@R 9999999999") )
   qrsay(nNivel+11,transf(PROD->Preco_cons,"@E 999,999.99") )
   qrsay(nNivel+12,transf(PROD->Ipi,"@E 99.99") )
   
   
   aFaturas := i_getReceber(cCLI)
   
   qrsay(nNivel+13 ,cExclusive1 )
   qrsay(nNivel+15,cExclusive2 )
   qrsay(nNivel+17,cExclusive3 )
   qrsay(nNivel+19,cExclusive4 )
   
   
   
   for nCont := 1 to len(aFaturas)
   
       if nCont <= 4
	      qrsay(nNivel+12+(nCont*2) ,left(aFaturas[nCont,1],9) + " " + dtoc(aFaturas[nCont,2]) + " " + transf(aFaturas[nCont,3],"@E 999,999.99") )
       endif
   
   
   
   next
   
   //qrsay(nNivel+12,cExclusive2 )
   //qrsay(nNivel+14,cExclusive3 )
   //qrsay(nNivel+16,cExclusive4 )
  
  qwait()

return

static function existeArea(fCidade)
local nReg := 0
local nIndex := 0
local lExisteArea := .F.

        nREG   := AREA_EXC->(recno())
        nINDEX := AREA_EXC->(IndexOrd())
		
		AREA_EXC->(dbsetorder(3))

        if AREA_EXC->(dbseek(fCIDADE))
		   lExisteArea := .T.
		endif
		
		AREA_EXC->(dbgoto(nREG))
        AREA_EXC->(dbsetorder(nINDEX))


return lExisteArea

static function i_getReceber(pCod_cli)
local aVencidas := {}

RECEBER->(Dbsetorder(5))
if RECEBER->(Dbseek(pCOD_CLI))
   do while ! RECEBER->(Eof()) .and. RECEBER->Cod_cli == pCod_cli
      if RECEBER->Data_venc < date()
         aadd(aVencidas,{RECEBER->Fatura,RECEBER->Data_venc,RECEBER->Valor_liq})
      endif
      RECEBER->(Dbskip())
   enddo
endif

return aVencidas

static function i_reserva
local aPED := {}
local aPEDS := {}
local lTEM := .F.
local cLOTE   := space(10)
local cFILIAL := space(4)
local nQTY    := 0
local cPROD   := space(5)
local nCONT   := 1

aReservas := {}

ITEN_FAT->(dbsetorder(2))
FAT->(dbsetorder(11))
FAT->(dbgotop())

Do while ! FAT->(eof()) .and. empty(FAT->Num_fatura)

   //alert(FAT->Codigo)
   
   qmensa("Data da Reserva.: "+ dtoc(FAT->dt_emissao),"L")

   if FAT->es != "S"
      FAT->(dbskip())
	  loop
   endif
   
   if left(FAT->Cod_cfop,4) $ "5905-6905"
      FAT->(dbskip())
	  loop
   endif

   ITEN_FAT->(Dbseek(FAT->Codigo))

   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      aadd(aPED,{ITEN_FAT->Cod_prod,FAT->Filial,ITEN_FAT->Num_Lote,ITEN_FAT->Quantidade})
      lTEM := .T.
      ITEN_FAT->(dbskip())
   enddo


   FAT->(Dbskip())
enddo

asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

if lTEM
    cPROD   := asPED[1,1]
    cFILIAL := asPED[1,2]
    cLOTE   := asPED[1,3]
    nQTY    := 0

    nCONT := 1
    do while  nCONT <= len(asPED)

        nQTY += asPED[nCONT,4]

        nCONT++
        if nCONT > len(asPED)
           nCONT := len(asPED)
           exit
        endif

        if asPED[nCONT,1] != cPROD
		   
		   aadd(aReservas,{cPROD,cFILIAL,cLOTE,nQTY})

           cPROD   := asPED[nCONT,1]
           cFILIAL := asPED[nCONT,2]
           cLOTE   := asPED[nCONT,3]
           nQTY    := 0
        endif
    enddo
	
	aadd(aReservas,{cPROD,cFILIAL,cLOTE,nQTY})

endif

aPED := {}
asPED := {}

return

static function buscaReservas(cPROD)
local nKey := 0

       nKey := ascan(aReservas,{|ckey| cKey[1] == cPROD})

       if nKey > 0
          return aReservas[nKey,4] 
       endif

return 0





