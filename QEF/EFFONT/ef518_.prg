/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: RELACAO DE CONFERENCIA NOTAS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: JUNHO DE 1998
// OBS........:
// ALTERACOES.:
function ef518

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }
local sBLOCO1 := qlbloc("B518B","QBLOC.GLO") // Entrada/Saida

private cPIC1   := "@E 99,999,999.99"
private cTITULO                   // titulo do relatorio
private bENT_FILTRO               // code block de filtro entrada
private bSAI_FILTRO               // code block de filtro saida
private bSAI_CFOP                 // code block de filtro saida
private bCFOP_FIL                 // code block de filtro saida
private aEDICAO := {}             // vetor para os campos de entrada de dados
private cCOD_CONT                 // Codigo contabil
private dDATA_INI                 // Data inicial
private dDATA_FIM                 // Data final
private nTOT_CONT := 0
private nTOT_BASE := 0
private nTOT_ISEN := 0
private nTOT_OUT  := 0
private nTOT_VLR  := 0
private nTOT_ST  := 0

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"9999"          ) } , "FILIAL"  })
aadd(aEDICAO,{{ || NIL                                         } , NIL       })

if val(CONFIG->Anomes) > 200212
  aadd(aEDICAO,{{ || view_cfop(-1,0,@cCFOP    ,"@R 9999"   ) } ,"CFOP"})
  aadd(aEDICAO,{{ || NIL                                         } , NIL       })
else
  aadd(aEDICAO,{{ || view_natop(-1,0,@cCOD_FISC    ,"@R 9.99"   ) } , "COD_FISC"})
  aadd(aEDICAO,{{ || NIL                                         } , NIL       })
endif

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO           ,sBLOCO1      ) } , "TIPO"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI       ,"@D" ,NIL,NIL) } , "DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM       ,"@D" ,NIL,NIL) } , "DATA_FIM"})

do while .T.

   qlbloc(5,0,"B518A","QBLOC.GLO",1)

   XNIVEL    := 1
   XFLAG     := .T.
   cFILIAL   := space(4)
   cCOD_FISC := space(4)
   cCFOP := space(5)
   cTIPO     := "E"
   dDATA_INI := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM := qfimmes(dDATA_INI)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "COD_FISC"
           if ! empty(cCOD_FISC)
              qrsay(XNIVEL , cCOD_FISC)
              if NATOP->(dbseek(cCOD_FISC))
                 qrsay ( XNIVEL+1 , left(NATOP->Nat_desc,20) )
              else
                 qmensa("C¢digo Fiscal n„o existe !","B")
                 return .F.
              endif
           else
             qrsay(XNIVEL+1,"Todos os Codigos Fiscais")
           endif

      case cCAMPO == "CFOP"
           if ! empty(cCFOP)
              qrsay(XNIVEL , cCFOP)
              if CFOP->(dbseek(cCFOP))
                 qrsay ( XNIVEL+1 , left(CFOP->Nat_desc,20) )
              else
                 qmensa("C¢digo Fiscal n„o existe !","B")
                 return .F.
              endif
           else
             qrsay(XNIVEL+1,"Todos os Codigos Fiscais")
           endif


      case cCAMPO == "FILIAL"
           if ! empty(cFILIAL)
              qrsay(XNIVEL , cFILIAL:=strzero(val(cFILIAL),4))
              if FILIAL->(dbseek(cFILIAL))
                 qrsay ( XNIVEL+1 , left(FILIAL->Razao,30) )
              else
                 qmensa("Filial n„o existe !","B")
                 return .F.
              endif
           else
              qrsay(XNIVEL+1,"Todas as Filiais...")
           endif

      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif
      case cCAMPO == "TIPO"
           if empty(cTIPO); return .F.; endif
           qrsay(XNIVEL,qabrev(cTIPO,"ES",{"Entrada","Saida"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // SELECIONA A ORDEM DO ARQUIVO ENT/SAI __________________________________

   cTITULO := "RELACAO DE CONFERENCIA DE NOTAS FISCAIS -"

   ENT->(dbsetorder(2))                 // Nota Fiscal
   ENT->(dbgotop())

   SAI->(dbsetorder(9))                 // Nota Fiscal
   SAI->(dbgotop())

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bENT_FILTRO := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }
   if val(CONFIG->Anomes) > 200212
      bCFOP_FIL := {|| iif( !empty(cCFOP),ENT->Cfop == alltrim(cCFOP),.T.)             }
      bSAI_CFOP := {|| iif( !empty(cCFOP),SAI->Cfop == alltrim(cCFOP),.T.)             }
   else
      bCFOP_FIL := {|| iif( !empty(cCOD_FISC),ENT->Cod_fisc == alltrim(cCOD_FISC),.T.) }
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   if ! qinitprn() ; return ; endif
   
   if XLOCALIMP == "X"
		i_impre_xls()
   else	  
		i_impre_prn()	
   endif

return



static function i_impre_prn
 local nCONT_CFOP := 0
 local nBASE_CFOP := 0
 local nISEN_CFOP := 0
 local nOUT_CFOP  := 0
 local nICM_CFOP  := 0
 local cATU  := space(4)


   local nTOTAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do case

      case cTIPO == "E"

           do while ! ENT->(eof()) .and. qcontprn()    // condicao principal de loop

              if eval(bENT_FILTRO) .and. ( eval(bCFOP_FIL)  .and. iif(!empty(cFILIAL),ENT->Filial == cFILIAL,.T.) )

                 qmensa("Nota: " + ENT->Num_nf + " / Serie: " + ENT->Serie)

                 if ! qlineprn() ; exit ; endif

                 @ prow(),pcol() say XCOND0

                 if XPAGINA == 0 .or. prow() > K_MAX_LIN

                    qpageprn()

                    qcabecprn(cTITULO+" ENTRADAS",80)

                    @ prow()+1,0 say XAENFAT + "Filial: " + FILIAL->Codigo + "-" + left(FILIAL->Razao,25) + space(5) + "Codigo Fiscal: " + cCFOP + XDENFAT
                    @ prow()+1,0 say XCOND0 + replicate("-",80)
                    @ prow()+1,0 say XCOND1 + " Cfop  Nota    Data         Serie   Dt. Emis.   UF   Vl. Contabil         Base        Isentas        Outras         Icms"
                    @ prow()+1,0 say XCOND0 + replicate("-",80)

                 endif

                 @ prow()+1,00  say XCOND1 + ENT->Cfop
                 @ prow()  ,06  say ENT->Num_nf
                 @ prow()  ,13  say dtoc(ENT->Data_lanc)
                 @ prow()  ,25  say ENT->Serie
                 @ prow()  ,30  say dtoc(ENT->Data_emis) ; FORN->(dbseek(ENT->Cod_forn)) ; CGM->(dbseek(FORN->Cgm_cob))
                 @ prow()  ,42  say CGM->Estado
                 @ prow()  ,46  say transform(ENT->Vlr_cont,cPIC1)
                 @ prow()  ,60  say transform(ENT->Icm_base,cPIC1)
                 @ prow()  ,74  say transform(ENT->Icm_isen,cPIC1)
                 @ prow()  ,88  say transform(ENT->Icm_out,cPIC1)
                 @ prow()  ,102 say transform(ENT->Icm_vlr,cPIC1)

                 OUTENT->(Dbgotop())   // verifica a existencia de outras aliquotas
                 if OUTENT->(dbseek(dtos(ENT->Data_lanc) + ENT->Num_nf + ENT->Serie + ENT->Filial))
                    do while ! OUTENT->(eof()) .and. (OUTENT->Data_lanc == ENT->Data_lanc .and. OUTENT->Num_nf == ENT->Num_nf .and. OUTENT->Serie == ENT->Serie .and. OUTENT->Filial == ENT->Filial)
                       @ prow()+1,60  say transform(OUTENT->Icm_base,cPIC1)
                       @ prow()  ,102 say transform(OUTENT->Icm_vlr,cPIC1)
                       nTOT_BASE += OUTENT->Icm_base
                       nTOT_VLR  += OUTENT->Icm_vlr
                       OUTENT->(Dbskip())
                    enddo
                 endif

                 nTOT_CONT += ENT->Vlr_cont
                 nTOT_BASE += ENT->Icm_base
                 nTOT_ISEN += ENT->Icm_isen
                 nTOT_OUT  += ENT->Icm_out
                 nTOT_VLR  += ENT->Icm_vlr

              endif

              ENT->(dbskip())

           enddo

           if nTOT_CONT <> 0
              @ prow()+1,0   say XCOND0 + replicate("-",80) + XCOND1
              @ prow()+1,46  say transform(nTOT_CONT,cPIC1)
              @ prow()  ,60  say transform(nTOT_BASE,cPIC1)
              @ prow()  ,74  say transform(nTOT_ISEN,cPIC1)
              @ prow()  ,88  say transform(nTOT_OUT,cPIC1)
              @ prow()  ,102 say transform(nTOT_VLR,cPIC1)
           endif

           nTOT_CONT := 0
           nTOT_BASE := 0
           nTOT_ISEN := 0
           nTOT_OUT  := 0
           nTOT_VLR  := 0

      case cTIPO == "S"
           cATU := SAI->Cfop
           do while ! SAI->(eof()) .and. qcontprn()    // condicao principal de loop

              if eval(bSAI_FILTRO) .and. (eval(bSAI_CFOP)  .and. iif(!empty(cFILIAL),SAI->Filial == cFILIAL,.T.) )
                 qmensa("Nota: " + SAI->Num_nf + " / Serie: " + SAI->Serie)

                 if ! qlineprn() ; exit ; endif

                 @ prow(),pcol() say XCOND0

                 if XPAGINA == 0 .or. prow() > K_MAX_LIN

                    qpageprn()

                    qcabecprn(cTITULO+" SAIDAS",80)

                    @ prow()+1,0 say XAENFAT + "Filial: " + cFILIAL + "-" + left(FILIAL->Razao,25) + space(5) + "Codigo Fiscal: " + cCFOP + XDENFAT
                    @ prow()+1,0 say XCOND0 + replicate("-",80)
                    @ prow()+1,0 say XCOND1 + "Cfop Data       Serie   Dt. Emis.   UF   Vl. Contabil     Base        Isentas        Outras         Icms"
                    @ prow()+1,0 say replicate("-",80)

                 endif

                 @ prow()+1,00  say XCOND1 + SAI->Cfop
                 @ prow()  ,06  say SAI->Num_nf
                 @ prow()  ,14  say dtoc(SAI->Data_lanc)
                 @ prow()  ,26  say SAI->Serie
                 @ prow()  ,30  say dtoc(SAI->Data_emis)
                 @ prow()  ,42  say SAI->Estado
                 @ prow()  ,46  say transform(SAI->Vlr_cont,cPIC1)
                 @ prow()  ,60  say transform(SAI->Icm_base,cPIC1)
                 @ prow()  ,74  say transform(SAI->Icm_isen,cPIC1)
                 @ prow()  ,88  say transform(SAI->Icm_out,cPIC1)
                 @ prow()  ,102 say transform(SAI->Icm_vlr,cPIC1)

                 OUTSAI->(Dbgotop())   // verifica a existencia de outras aliquotas
                 if OUTSAI->(dbseek(dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial))
                    do while ! OUTSAI->(eof()) .and. (OUTSAI->Data_lanc == SAI->Data_lanc .and. OUTSAI->Num_nf == SAI->Num_nf .and. OUTSAI->Serie == SAI->Serie .and. OUTSAI->Filial == SAI->Filial)
                       @ prow()+1,60  say transform(OUTSAI->Icm_base,cPIC1)
                       @ prow()  ,102 say transform(OUTSAI->Icm_vlr,cPIC1)
                       nTOT_BASE += OUTSAI->Icm_base
                       nTOT_VLR  += OUTSAI->Icm_vlr
                       OUTSAI->(Dbskip())
                    enddo
                 endif

                 nTOT_CONT += SAI->Vlr_cont
                 nTOT_BASE += SAI->Icm_base
                 nTOT_ISEN += SAI->Icm_isen
                 nTOT_OUT  += SAI->Icm_out
                 nTOT_VLR  += SAI->Icm_vlr

                 nCONT_CFOP += SAI->Vlr_cont
                 nBASE_CFOP += SAI->Icm_base
                 nISEN_CFOP += SAI->Icm_isen
                 nOUT_CFOP  += SAI->Icm_out
                 nICM_CFOP  += SAI->Icm_vlr


              endif

              SAI->(dbskip())

              //qmensa("Cfop Atual:"+cATU+ "!!!!  CFOP no Arquivo SAI.DBF "+SAI->Cfop)
              //qinkey(0)

              if alltrim(SAI->Cfop) != alltrim(cATU)
                 if nCONT_CFOP <> 0
                    @ Prow()+2,00 say "Totais do Cfop : " +cATU
                    @ Prow() , 01 say transf(nCONT_CFOP,cPIC1)
                 endif

                 cATU := alltrim(SAI->Cfop)

                 nCONT_CFOP := 0
                 nBASE_CFOP := 0
                 nISEN_CFOP := 0
                 nOUT_CFOP  := 0
                 nICM_CFOP  := 0


              endif

           enddo

           if nTOT_CONT <> 0
              @ prow()+1,0   say XCOND0 + replicate("-",80) + XCOND1
              @ prow()+1,46  say transform(nTOT_CONT,cPIC1)
              @ prow()  ,60  say transform(nTOT_BASE,cPIC1)
              @ prow()  ,74  say transform(nTOT_ISEN,cPIC1)
              @ prow()  ,88  say transform(nTOT_OUT,cPIC1)
              @ prow()  ,102 say transform(nTOT_VLR,cPIC1)
           endif

           nTOT_CONT := 0
           nTOT_BASE := 0
           nTOT_ISEN := 0
           nTOT_OUT  := 0
           nTOT_VLR  := 0

   endcase

   qstopprn()

return

static function i_impre_xls
 local nCONT_CFOP := 0
 local nBASE_CFOP := 0
 local nISEN_CFOP := 0
 local nOUT_CFOP  := 0
 local nICM_CFOP  := 0
 local cATU  := space(4)


   local nTOTAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do case

      case cTIPO == "E"

           do while ! ENT->(eof()) .and. qcontprn()    // condicao principal de loop

              if eval(bENT_FILTRO) .and. ( eval(bCFOP_FIL)  .and. iif(!empty(cFILIAL),ENT->Filial == cFILIAL,.T.) )

                 if mod(ENT->(recno()),500) == 0
					if ! qlineprn() ; return ; endif
					qgirabarra()
				endif

                 if XPAGINA == 0 

                    qpageprn()

                    @ prow()+1,0 say left(FILIAL->Razao,25) + space(5) + "Codigo Fiscal: " + cCFOP 
                    @ prow()+1,0 say "Cfop" + chr(9) + "Nota"  + chr(9) + "Data" + chr(9) + "Serie" + chr(9) + "Dt. Emis." + chr(9) + "UF" + chr(9) + "Vl. Contabil" + chr(9) + "Base" + chr(9)+ "Isentas" + chr(9) + "Outras" + chr(9) + "Icms" + chr(9) + "Ipi" +chr(9)+ "Base ST" + chr(9) + "Icms.ST"
                    @ prow()+1,0 say ""

                 endif

                 @ prow()+1,00      say ENT->Cfop + chr(9)
                 @ prow()  ,pcol()  say ENT->Num_nf + chr(9)
                 @ prow()  ,pcol()  say dtoc(ENT->Data_lanc) + chr(9)
                 @ prow()  ,pcol()  say ENT->Serie + chr(9)
                 @ prow()  ,pcol()  say dtoc(ENT->Data_emis) + chr(9) ; FORN->(dbseek(ENT->Cod_forn)) ; CGM->(dbseek(FORN->Cgm_cob)) 
                 @ prow()  ,pcol()  say CGM->Estado + chr(9)
                 @ prow()  ,pcol()  say transform(ENT->Vlr_cont,cPIC1) + chr(9)
                 @ prow()  ,pcol()  say transform(ENT->Icm_base,cPIC1) + chr(9)
                 @ prow()  ,pcol()  say transform(ENT->Icm_isen,cPIC1) + chr(9)
                 @ prow()  ,pcol()  say transform(ENT->Icm_out,cPIC1) + chr(9)
                 @ prow()  ,pcol() say transform(ENT->Icm_vlr,cPIC1) + chr(9)
                 @ prow()  ,pcol() say transform(ENT->Ipi_vlr,cPIC1) + chr(9)
                 @ prow()  ,pcol() say transform(ENT->Icm_Bc_s,cPIC1) + chr(9)
				 @ prow()  ,pcol() say transform(ENT->Icm_subst,cPIC1)
				 

                 nTOT_CONT += ENT->Vlr_cont
                 nTOT_BASE += ENT->Icm_base
                 nTOT_ISEN += ENT->Icm_isen
                 nTOT_OUT  += ENT->Icm_out
                 nTOT_VLR  += ENT->Icm_vlr
                 nTOT_ST   += ENT->Icm_subst

              endif

              ENT->(dbskip())

           enddo

           if nTOT_CONT <> 0
              @ prow()+1,0   say ""
              @ prow()+1,00  say transform(nTOT_CONT,cPIC1) + chr(9)
              @ prow()  ,pcol()  say transform(nTOT_BASE,cPIC1) + chr(9)
              @ prow()  ,pcol()  say transform(nTOT_ISEN,cPIC1) + chr(9)
              @ prow()  ,pcol()  say transform(nTOT_OUT,cPIC1) + chr(9)
              @ prow()  ,pcol() say transform(nTOT_VLR,cPIC1) + chr(9)
              @ prow()  ,pcol() say transform(nTOT_ST,cPIC1)
           endif

           nTOT_CONT := 0
           nTOT_BASE := 0
           nTOT_ISEN := 0
           nTOT_OUT  := 0
           nTOT_VLR  := 0

      case cTIPO == "S"
           cATU := SAI->Cfop
           do while ! SAI->(eof()) .and. qcontprn()    // condicao principal de loop

              if eval(bSAI_FILTRO) .and. (eval(bSAI_CFOP)  .and. iif(!empty(cFILIAL),SAI->Filial == cFILIAL,.T.) )
				 
				 if mod(SAI->(recno()),500) == 0
					if ! qlineprn() ; return ; endif
					qgirabarra()
				endif

                 if XPAGINA == 0 
                    qpageprn()

                    @ prow()+1,0 say left(FILIAL->Razao,25) + space(5) + "Codigo Fiscal: " + cCFOP 
                    @ prow()+1,0 say "Cfop" + chr(9) + "Nota"  + chr(9) + "Data" + chr(9) + "Serie" + chr(9) + "Dt. Emis." + chr(9) + "UF" + chr(9) + "Vl. Contabil" + chr(9) + "Base" + chr(9)+ "Isentas" + chr(9) + "Outras" + chr(9) + "Icms" + chr(9) + "Ipi" +chr(9)+ "Base ST" + chr(9) + "Icms.ST"
                    @ prow()+1,0 say ""

                 endif

                 @ prow()+1,00      say SAI->Cfop  + chr(9)
                 @ prow()  ,pcol()  say SAI->Num_nf + chr(9)
                 @ prow()  ,pcol()  say dtoc(SAI->Data_lanc) + chr(9)
                 @ prow()  ,pcol()  say SAI->Serie + chr(9)
                 @ prow()  ,pcol()  say dtoc(SAI->Data_emis) + chr(9)
                 @ prow()  ,pcol()  say SAI->Estado + chr(9)
                 @ prow()  ,pcol()  say transform(SAI->Vlr_cont,cPIC1) + chr(9)
                 @ prow()  ,pcol()  say transform(SAI->Icm_base,cPIC1) + chr(9)
                 @ prow()  ,pcol()  say transform(SAI->Icm_isen,cPIC1) + chr(9)
                 @ prow()  ,pcol()  say transform(SAI->Icm_out,cPIC1) + chr(9)
                 @ prow()  ,pcol() say transform(SAI->Icm_vlr,cPIC1) + chr(9)
				 @ prow()  ,pcol() say transform(SAI->Ipi_vlr,cPIC1) + chr(9)
                 @ prow()  ,pcol() say transform(SAI->Icm_Bc_s,cPIC1) + chr(9)
                 @ prow()  ,pcol() say transform(SAI->Icm_subst,cPIC1)

                 nTOT_CONT += SAI->Vlr_cont
                 nTOT_BASE += SAI->Icm_base
                 nTOT_ISEN += SAI->Icm_isen
                 nTOT_OUT  += SAI->Icm_out
                 nTOT_VLR  += SAI->Icm_vlr
				 nTOT_ST   += SAI->Icm_subst

                 nCONT_CFOP += SAI->Vlr_cont
                 nBASE_CFOP += SAI->Icm_base
                 nISEN_CFOP += SAI->Icm_isen
                 nOUT_CFOP  += SAI->Icm_out
                 nICM_CFOP  += SAI->Icm_vlr

              endif

              SAI->(dbskip())

              //qmensa("Cfop Atual:"+cATU+ "!!!!  CFOP no Arquivo SAI.DBF "+SAI->Cfop)
              //qinkey(0)

              if alltrim(SAI->Cfop) != alltrim(cATU)
                 if nCONT_CFOP <> 0
                    @ Prow()+2,00 say "Totais do Cfop : " +cATU
                    @ Prow() , 01 say transf(nCONT_CFOP,cPIC1)
                 endif

                 cATU := alltrim(SAI->Cfop)

                 nCONT_CFOP := 0
                 nBASE_CFOP := 0
                 nISEN_CFOP := 0
                 nOUT_CFOP  := 0
                 nICM_CFOP  := 0

              endif

           enddo

           if nTOT_CONT <> 0
              @ prow()+1,0   say ""
              @ prow()+1,00     say chr(9) + chr(9) + chr(9) + chr(9) + chr(9) + chr(9) + transform(nTOT_CONT,cPIC1) + chr(9)
              @ prow()  ,pcol() say transform(nTOT_BASE,cPIC1) + chr(9)
              @ prow()  ,pcol() say transform(nTOT_ISEN,cPIC1) + chr(9)
              @ prow()  ,pcol() say transform(nTOT_OUT,cPIC1) + chr(9)
              @ prow()  ,pcol() say transform(nTOT_VLR,cPIC1) + chr(9)
			  @ prow()  ,pcol() say transform(nTOT_ST,cPIC1)
           endif

           nTOT_CONT := 0
           nTOT_BASE := 0
           nTOT_ISEN := 0
           nTOT_OUT  := 0
           nTOT_VLR  := 0

   endcase

   qstopprn(.F.)

return
