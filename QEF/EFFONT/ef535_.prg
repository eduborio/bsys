
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: NOTAS FALTANTES
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MARCO DE 1996
// OBS........:
// ALTERACOES.:
function ef535

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }

private sBLOC1 := qlbloc("B535B","QBLOC.GLO")            // Tipo de impressao

private cTITULO                   // Titulo do relatorio
private bFILTRO                   // Code block de filtro
private aEDICAO := {}             // Vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

private bSAI_FILTRO               // code block de filtro

private nQUANT                    // Conta as numero das notas faltantes
private dDATA_INI                 // Inicio do periodo do relatorio
private dDATA_FIM                 // Fim do periodo do relatorio
private nINTERV                   // Intervalo entre as sequencias
private cTIPO                     // Tipo de relatorio

qlbloc(5,0,"B535A","QBLOC.GLO",1)

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nINTERV     ,"999999" ,NIL,NIL) } ,"INTERV  "})
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO       ,sBLOC1           ) } ,"TIPO"    })

do while .T.

   XNIVEL    := 1
   XFLAG     := .T.
   nQUANT    := 0
   dDATA_INI := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
   dDATA_FIM := qfimmes(dDATA_INI)
   nINTERV   := 100

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
              qmensa("Data Inicial n�o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F.; endif  1
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"Normal","Vendedor"}))

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

   set softseek on

   select SAI

   do case
      case cTIPO == "1"                          // Data de lancamento
           SAI->(dbsetorder(2))
           SAI->(dbseek(dtos(dDATA_INI)))

      case cTIPO == "2"                          // Pela ordem dos vendedores
           SAI->(dbsetorder(4))
           SAI->(dbgotop())
   endcase

   select VEND
   VEND->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local cSTRING := ""
   local lVEND   := .F.
   local lREG    := .T.
   local nCONT1, nCONT2, nCONTX, nNOTAS_F

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do case

      case cTIPO == "1"

           qgirabarra()

           cSTRING  := ""
           lREG     := .T.
           nNOTAS_F := 0

           do while ! SAI->(eof())

              qgirabarra()

              if eval(bSAI_FILTRO)

                 if lREG
                    nCONT1 := nCONT2 := val(SAI->Num_nf)
                    lREG   := .F.
                 endif

                 if nCONT1+1 < nCONT2
                    cSTRING += i_dif(nCONT1,nCONT2)
                    lVEND   := .T.
                 endif

              endif

              SAI->(dbskip())

              nCONT1 := nCONT2
              nCONT2 := val(SAI->Num_nf)

           enddo

           // CABECALHO _______________________________________________________________

           if XPAGINA == 0 .or. prow() > K_MAX_LIN

              qpageprn()

              // IMPRESSAO DO CABECALHO _______________________________________________

              /////////////////////////////////////////////////////////////////////////
              // CABECALHO PARA NOTAS FALTANTES POR VENDEDOR __________________________

              cTITULO := "NOTAS FALTANTES - " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)
              @ prow(),pcol() say XCOND0
              qcabecprn(cTITULO,73)

           endif

           // LOOP PARA IMPRESSAO DA STRING ___________________________________________

           for nCONTX = 0 to 1000

               cLINHA := substr(cSTRING,nCONTX*72+1,72)

               if empty(cLINHA)
                  exit
               endif

               @ prow()+1,01 say cLINHA

           next

      case cTIPO == "2"

           VEND->(dbgotop())

           do while ! VEND->(eof())

              qgirabarra()

              cSTRING   := ""
              cVENDEDOR := VEND->Codigo
              cNOME     := VEND->Nome

              // SE NAO ENCONTROU VENDEDOR NA SAIDA ou VENDEDOR = " " _________________

              if ! SAI->(dbseek(cVENDEDOR)) .or. empty(cVENDEDOR)
                 VEND->(dbskip())
                 loop
              endif

              lREG := .T.

              do while SAI->COD_VEND = cVENDEDOR

                 qgirabarra()

                 if eval(bSAI_FILTRO)

                    if lREG
                       nCONT1 := nCONT2 := val(SAI->Num_nf)
                       lREG := .F.
                    endif

                    if nCONT1+1 < nCONT2
                       cSTRING += i_dif(nCONT1,nCONT2)
                       lVEND := .T.
                    endif

                 endif

                 SAI->(dbskip())

                 nCONT1 := nCONT2
                 nCONT2 := val(SAI->Num_nf)

              enddo

              // CABECALHO ____________________________________________________________

              if XPAGINA == 0 .or. prow() > K_MAX_LIN

                 qpageprn()

                 // CABECALHO PARA NOTAS FALTANTES POR VENDEDOR _______________________

                 cTITULO := "NOTAS FALTANTES POR VENDEDOR - " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)
                 @ prow(),pcol() say XCOND0
                 qcabecprn(cTITULO,73)

              endif

              // LOOP PARA IMPRESSAO DA STRING ________________________________________

              for nCONTX = 0 to 1000

                  cLINHA := substr(cSTRING,nCONTX*72+1,72)

                  if empty(cLINHA)
                     exit
                  endif

                  if lVEND
                     @ prow()+1,01 say cVENDEDOR + "-" + cNOME
                  endif

                  @ prow()+1,01 say cLINHA

                  // PARA IMPRESSAO DO CODIGO E NOME APENAS UMA VEZ ___________________

                  lVEND := .F.

              next

              VEND->(dbskip())

           enddo

   endcase

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ACHAR DIFERENCA ENTRE AS NOTAS  ______________________________

static function i_dif ( n1 , n2 )

   local cSTRING  := ""

//   if n1+1 == n2-1

//      cSTRING := strzero(n1+1,6) + "  "

//   else

   if nINTERV > (n2 - (n1+1))
      cSTRING := strzero(n1+1,6) + "-" + strzero(n2-1,6) + "(" + strzero(n2 - (n1+1),2) + ") "
   endif

//   endif

return cSTRING
