
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: LISTAGEM DE TRIBUTOS FISCAIS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........:
// ALTERACOES.:
function ef504

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM) .or. lastkey() = 27}

// CONFIGURACOES ____________________________________________________________

if !quse(XDRV_EF,"CONFIG") ; return ; endif
private cTRIB_SINC := CONFIG->Trib_Sinc
CONFIG->(dbclosearea())

// SE TRIBUTOS FOREM SINCRONIZADOS, PEGA DA E001 ____________________________

if cTRIB_SINC == "1"
   if !quse(XDRV_EFX,"TRIB",{"TRIB_COD","TRIB_DES"}) ; return ; endif
else
   if !quse(XDRV_EF ,"TRIB",{"TRIB_COD","TRIB_DES"}) ; return ; endif
endif

private sBLOC1 := qlbloc("B504B","QBLOC.GLO")   // ordem de impressao

private cTITULO                                 // titulo do relatorio
private cORDEM := " "                          // ordem de impressao (codigo/descricao)
private bTRIB_FILTRO                            // code block de filtro
private aEDICAO := {}                           // vetor para os campos de entrada de dados
private dDATA_INI                               // Inicio do periodo do relatorio
private dDATA_FIM                               // Fim do periodo do relatorio

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOC1)  } , "ORDEM" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!" ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!" ,NIL,NIL) } ,"DATA_FIM"})

do while .T.

   qlbloc(5,0,"B504A","QBLOC.GLO",1)

   XNIVEL    := 1
   XFLAG     := .T.
   cORDEM    := " "
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

   local nMES, nANO

   do case
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"12",{"C¢digo","Descric„o"}))

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

   cTITULO := "LISTAGEM GERAL DE TRIBUTOS"

   // SELECIONA ORDEM DO ARQUIVO TRIB _______________________________________

   do case
      case cORDEM == "1" ; TRIB->(dbsetorder(1)) // codigo
      case cORDEM == "2" ; TRIB->(dbsetorder(2)) // descricao
   endcase

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   dDATA_INI := qanomes(dDATA_INI)
   dDATA_FIM := qanomes(dDATA_FIM)

   bTRIB_FILTRO := { || TRIB->ANOMES >= dDATA_INI .and. TRIB->ANOMES <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select TRIB

   TRIB->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! TRIB->(eof()) .and. qcontprn()        // condicao principal de loop

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,74)
         @ prow()+1,0 say "ANO/MES  CODIGO  DESCRICAO TRIBUTO                         ALIQUOTA  VENC."
         @ prow()+1,0 say replicate("-",74)
      endif

      if eval(bTRIB_FILTRO)

         qmensa("Imprimindo Tributo: "+TRIB->Codigo+" / Descricao: "+TRIB->Descricao)

         @ prow()+1,0 say TRIB->Anomes            + space(5) +;
                          TRIB->Codigo            + space(2) +;
                          TRIB->Descricao         + space(2) +;
                          str(TRIB->Aliquota,6,2) + space(5) +;
                          TRIB->Dia_venc

      endif

      TRIB->(dbskip())

   enddo

   qstopprn()

return
