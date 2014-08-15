
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: COMISSAO DOS VENDEDORES
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MARCO DE 1996
// OBS........:
// ALTERACOES.:
function ef514

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private sBLOC1 := qlbloc("B514B","QBLOC.GLO") // ordem de impressao

private cTITULO                      // titulo do relatorio
private cORDEM                       // ordem de impressao (codigo/descricao)
private bFILTRO                      // code block de filtro
private aEDICAO := {}                // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

private bSAI_FILTRO                  // code block de filtro

private nTOT_CONT                    // total valor contabil geral
private nVLR_CONT                    // total valor contabil por vendedor
private nTOT_COM                     // total valor das comissoes
private nVLR_COM                     // total valor da comissao por vendedor
private nPEDIDOS                     // Numero de pedidos por vendedor
private nTOT_PED                     // Numero total de pedidos
private dDATA_INI                    // Inicio do periodo do relatorio
private dDATA_FIM                    // Fim do periodo do relatorio
private cTIPO                        // Sintetico ou analitico

qlbloc(5,0,"B514A","QBLOC.GLO",1)

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO       ,sBLOC1           ) } ,"TIPO"    })

do while .T.

   XNIVEL    := 1
   XFLAG     := .T.
   nTOT_CONT := 0
   nVLR_CONT := 0
   nTOT_COM  := 0
   nVLR_COM  := 0
   nPEDIDOS  := 0
   nTOT_PED  := 0
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
           if empty(cTIPO); return .F.; endif  1
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"Sint‚tico","Anal¡tico"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   // ORDEM DE VENDEDORES ___________________________________________________

   select SAI
   SAI->(dbsetorder(4))
   SAI->(dbgotop())

   select VEND
   VEND->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do case
      case cTIPO == "1"
           i_sintetico()

      case cTIPO == "2"
           i_analitico()
   endcase

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// RELATORIO SINTETICO DE VENDEDORES ________________________________________

function i_sintetico

   VEND->(dbgotop())

   cTITULO := "COMISSAO DOS VENDEDORES"

   do while !SAI->(eof())

      nPEDIDOS  := 0
      nVLR_CONT := 0
      nVLR_COM  := 0
      cVENDEDOR := VEND->Codigo

      // SE NAO ENCONTROU VENDEDOR NA SAIDA ou VENDEDOR = " " _______________

      qgirabarra()

      if !SAI->(dbseek(cVENDEDOR)) .or. empty(cVENDEDOR)
         VEND->(dbskip())
         loop
      endif

      do while SAI->COD_VEND = cVENDEDOR
         qgirabarra()

         if eval(bSAI_FILTRO)
            nVLR_CONT += SAI->VLR_CONT
            nPEDIDOS++
         endif

         SAI->(dbskip())
      enddo

      // CABECALHO __________________________________________________________

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         // IMPRESSAO DO CABECALHO __________________________________________
         i_cabec_s()
         @ prow()+1,00 say "Codigo Nome" + space(32) + "Pedidos    V.Contabil        Comissao"
      endif

      @ prow()+1,00 say VEND->CODIGO
      @ prow()  ,07 say VEND->NOME
      @ prow()  ,38 say nPEDIDOS
      @ prow()  ,50 say nVLR_CONT pict "@E 999,999,999.99"

      // IMPRIME COMISSAO DO VENDEDOR _______________________________________

      nVLR_COM := nVLR_CONT * (VEND->COMISSAO / 100)

      @ prow()  ,67 say nVLR_COM pict "@E 99,999,999.99"

      nTOT_PED  += nPEDIDOS               // Total dos pedidos
      nTOT_CONT += nVLR_CONT              // Total do valor contabil
      nTOT_COM  += nVLR_COM               // Valor das comissoes

      VEND->(dbskip())

   enddo

   @ prow()+1,00 say replicate("-",80)
   @ prow()+1,20 say "Total..:"
   @ prow()  ,38 say nTOT_PED
   @ prow()  ,50 say nTOT_CONT pict "@E 999,999,999.99"
   @ prow()  ,66 say nTOT_COM  pict "@E 999,999,999.99"

return

/////////////////////////////////////////////////////////////////////////////
// RELATORIO ANALITICO DE VENDEDORES ________________________________________

function i_analitico

   local cSTRING := ""; lVEND := .F.

   cTITULO := "RELATORIO DOS VENDEDORES"

   VEND->(dbgotop())

   do while !SAI->(eof())

      nVLR_CONT := 0
      nVLR_COM  := 0
      cSTRING   := ""
      cVENDEDOR := VEND->Codigo
      cNOME     := VEND->Nome

      // SE NAO ENCONTROU VENDEDOR NA SAIDA ou VENDEDOR = " " _______________

      qgirabarra()

      if !SAI->(dbseek(cVENDEDOR)) .or. empty(cVENDEDOR)
         VEND->(dbskip())
         loop
      endif

      do while SAI->COD_VEND = cVENDEDOR
         qgirabarra()

         if eval(bSAI_FILTRO)
            cSTRING += " " + str(val(SAI->Num_Nf)) + " " + transform(SAI->VLR_CONT, "@E 999,999,999.99")
            lVEND   := .T.
         endif

         SAI->(dbskip())
      enddo

      // CABECALHO _____________________________________________________________

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         // IMPRESSAO DO CABECALHO _______________________________________________
         i_cabec_a()
         @ prow()+1,00 say XCOND1 + "Cod - Vendedor"
         @ prow()+1,06 say XCOND1 + "Nota          Valor   Nota          Valor   Nota          Valor   " +;
                                    "Nota          Valor   Nota          Valor   Nota          Valor" + XCOND0
         @ prow()+1,00 say XCOND1 + replicate("-",137) + XCOND0
      endif

      // LOOP PARA IMPRESSAO DA STRING ___________________________________________

      for nCONT = 0 to 1000
          qgirabarra()

          cLINHA := substr(cSTRING,nCONT*132+1,132)

          if empty(cLINHA)
             exit
          endif

          if lVEND
             @ prow()+1,00 say XCOND1 + cVENDEDOR + " - " + cNOME + XCOND0
          endif

          @ prow()+1,02 say XCOND1 + cLINHA + XCOND0

          // PARA IMPRESSAO DO CODIGO E NOME APENAS UMA VEZ _______________________

          lVEND := .F.
      next

      VEND->(dbskip())

   enddo

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO PARA COMISSAO DOS VENDEDORES / SINTETICA ____________________________

static function i_cabec_s

   qcabecprn(cTITULO,80)
   @ prow()+1,00 say "Periodo..: " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)
   @ prow()+1,00 say replicate("-",80)

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO PARA COMISSAO DOS VENDEDORES / ANALITICA ____________________________

static function i_cabec_a

   @ prow(),pcol() say XCOND1
   qcabecprn(cTITULO,137)
   @ prow()+1,00 say "Periodo..: " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)
   @ prow()+1,00 say replicate("-",137)

return
