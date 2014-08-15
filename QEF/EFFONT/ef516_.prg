/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: RELACAO DE NOTAS POR FORNECEDOR
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function ef516

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private cPIC1      := "@E 99,999,999.99"
private cTITULO                   // titulo do relatorio
private bFILTRO                   // code block de filtro
private aEDICAO := {}             // vetor para os campos de entrada de dados
private cCOD_FORN                 // Fornecedor
private dDATA_INI                 // Data inicial
private dDATA_FIM                 // Data final

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_forn(-1,0,@cCOD_FORN   ,"99999"      ) } , "COD_FORN"})
aadd(aEDICAO,{{ || NIL                                         } , NIL       })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI       ,"@D" ,NIL,NIL) } , "DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM       ,"@D" ,NIL,NIL) } , "DATA_FIM"})

do while .T.

   qlbloc(5,0,"B516A","QBLOC.GLO",1)

   XNIVEL    := 1
   XFLAG     := .T.
   cCOD_FORN := "     "
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
      case cCAMPO == "COD_FORN"
           if empty(cCOD_FORN) ; return .F. ; endif
           qrsay(XNIVEL , cCOD_FORN := strzero(val(cCOD_FORN),5))
           if FORN->(dbseek(cCOD_FORN))
              qrsay ( XNIVEL+1 , left(FORN->Razao,25) )
           else
              qmensa("Fornecedor n„o existente !","B")
              return .F.
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
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELACAO DE NOTAS POR FORNECEDOR"

   // SELECIONA A ORDEM DO ARQUIVO FORN _______________________________________

   ENT->(dbsetorder(5))                 // Fornecedor
   ENT->(dbgotop())
   ENT->(dbseek(cCOD_FORN))

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bFILTRO := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nTOTAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ENT->(dbseek(cCOD_FORN))

      do while ! ENT->(eof()) .and. ENT->Cod_forn == cCOD_FORN .and. qcontprn()    // condicao principal de loop

         qmensa("Nota: " + ENT->Num_nf + " / Serie: " + ENT->Serie)

         if ! qlineprn() ; exit ; endif

         @ prow(),pcol() say XCOND0

         if XPAGINA == 0 .or. prow() > K_MAX_LIN

            qpageprn()

            qcabecprn(cTITULO,80)

            @ prow()+1,0 say "Fornecedor: " + cCOD_FORN + "-" + FORN->Razao
            @ prow()+1,0 say replicate("-",80)
            @ prow()+1,0 say " Nota  Serie Especie  Dt. Lanc.  Dt. Emis.  Cod. Fisc.  Cod. Cont.   Val. Cont."
            @ prow()+1,0 say replicate("-",80)

         endif

         if eval(bFILTRO)

            @ prow()+1,0 say ENT->Num_nf          + "  "     + ENT->Serie           + "      " +;
                             ENT->Especie         + "   "  + dtoc(ENT->Data_lanc) + "  " +;
                             dtoc(ENT->Data_emis) + "    " + ENT->Cod_fisc        + "        " +;
                             ENT->Cod_cont        + "   "    + transform(ENT->Vlr_cont,cPIC1)
         nTOTAL += ENT->Vlr_cont

         endif

         ENT->(dbskip())

      enddo

      @ prow()+1,0  say replicate("-",80)
      @ prow()+1,60 say "Total: " + transform(nTOTAL,cPIC1)

   endif

   qstopprn()

return
