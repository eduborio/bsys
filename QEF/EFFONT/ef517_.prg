/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: RELACAO DE NOTAS POR CODIGO CONTABIL
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function ef517

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }
local sBLOCO1 := qlbloc("B517B","QBLOC.GLO") // Entrada/Saida

private cPIC1   := "@E 99,999,999.99"
private cTITULO                   // titulo do relatorio
private bENT_FILTRO               // code block de filtro entrada
private bSAI_FILTRO               // code block de filtro saida
private aEDICAO := {}             // vetor para os campos de entrada de dados
private cCOD_CONT                 // Codigo contabil
private dDATA_INI                 // Data inicial
private dDATA_FIM                 // Data final

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_conta(-1,0,@cCOD_CONT  ,"999999"     ) } , "COD_CONT"})
aadd(aEDICAO,{{ || NIL                                         } , NIL       })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO           ,sBLOCO1      ) } , "TIPO"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI       ,"@D" ,NIL,NIL) } , "DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM       ,"@D" ,NIL,NIL) } , "DATA_FIM"})

do while .T.

   qlbloc(5,0,"B517A","QBLOC.GLO",1)

   XNIVEL    := 1
   XFLAG     := .T.
   cCOD_CONT := "      "
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
      case cCAMPO == "COD_CONT"
           if empty(cCOD_CONT) ; return .F. ; endif
           qrsay(XNIVEL , cCOD_CONT := strzero(val(cCOD_CONT),6))
           if CONTA->(dbseek(cCOD_CONT))
              qrsay ( XNIVEL+1 , CONTA->Descricao )
           else
              qmensa("Conta n„o existente !","B")
              return .F.
           endif

      case cCAMPO == "TIPO"
           if empty(cTIPO); return .F.; endif
           qrsay(XNIVEL,qabrev(cTIPO,"ES",{"Entrada","Saida"}))

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
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // SELECIONA A ORDEM DO ARQUIVO ENT/SAI __________________________________

   do case
      case cTIPO == "E"
           cTITULO := "RELACAO DE NOTAS POR CODIGO CONTABIL - ENTRADA"
           ENT->(dbsetorder(6))                 // Codigo Contabil
           ENT->(dbgotop())
           ENT->(dbseek(cCOD_CONT))
      case cTIPO == "S"
           cTITULO := "RELACAO DE NOTAS POR CODIGO CONTABIL - SAIDA"
           SAI->(dbsetorder(6))                 // Codigo Contabil
           SAI->(dbgotop())
           SAI->(dbseek(cCOD_CONT))
   endcase

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bENT_FILTRO := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nTOTAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do case

      case cTIPO == "E"
           if ENT->(dbseek(cCOD_CONT))

              do while ! ENT->(eof()) .and. ENT->Cod_cont == cCOD_CONT .and. qcontprn()    // condicao principal de loop

                 qmensa("Nota: " + ENT->Num_nf + " / Serie: " + ENT->Serie)

                 if ! qlineprn() ; exit ; endif

                 @ prow(),pcol() say XCOND0

                 if XPAGINA == 0 .or. prow() > K_MAX_LIN

                    qpageprn()

                    qcabecprn(cTITULO,80)

                    @ prow()+1,0 say "Conta: " + cCOD_CONT + "-" + CONTA->Descricao
                    @ prow()+1,0 say replicate("-",80)
                    @ prow()+1,0 say " Nota  Serie Especie  Dt. Lanc.  Dt. Emis.  Cod. Fisc.               Val. Cont."
                    @ prow()+1,0 say replicate("-",80)

                 endif

                 if eval(bENT_FILTRO)

                    @ prow()+1,0 say ENT->Num_nf          + "  "     + ENT->Serie           + "    " +;
                                     ENT->Especie         + "    "  + dtoc(ENT->Data_lanc) + "   " +;
                                     dtoc(ENT->Data_emis) + "    " + ENT->Cod_fisc        + space(17) +;
                                     transform(ENT->Vlr_cont,cPIC1)

                 nTOTAL += ENT->Vlr_cont

                 endif

                 ENT->(dbskip())

              enddo

              @ prow()+1,0  say replicate("-",80)
              @ prow()+1,60 say "Total: " + transform(nTOTAL,cPIC1)

           endif

      case cTIPO == "S"
           if SAI->(dbseek(cCOD_CONT))

              do while ! SAI->(eof()) .and. SAI->Cod_cont == cCOD_CONT .and. qcontprn()    // condicao principal de loop

                 qmensa("Nota: " + SAI->Num_nf + " / Serie: " + SAI->Serie)

                 if ! qlineprn() ; exit ; endif

                 @ prow(),pcol() say XCOND0

                 if XPAGINA == 0 .or. prow() > K_MAX_LIN

                    qpageprn()

                    qcabecprn(cTITULO,80)

                    @ prow()+1,0 say "Conta: " + cCOD_CONT + "-" + CONTA->Descricao
                    @ prow()+1,0 say replicate("-",80)
                    @ prow()+1,0 say " Nota  Serie Especie  Dt. Lanc.  Dt. Emis.  Cod. Fisc.               Val. Cont."
                    @ prow()+1,0 say replicate("-",80)

                 endif

                 if eval(bSAI_FILTRO)

                    @ prow()+1,0 say SAI->Num_nf          + "  "     + SAI->Serie           + "      "  +;
                                     SAI->Especie         + "     "  + dtoc(SAI->Data_lanc) + "   "     +;
                                     dtoc(SAI->Data_emis) + "      " + SAI->Cod_fisc        + space(17) +;
                                     transform(SAI->Vlr_cont,cPIC1)

                 nTOTAL += SAI->Vlr_cont

                 endif

                 SAI->(dbskip())

              enddo

              @ prow()+1,0  say replicate("-",80)
              @ prow()+1,60 say "Total: " + transform(nTOTAL,cPIC1)

           endif

   endcase

   qstopprn()

return
