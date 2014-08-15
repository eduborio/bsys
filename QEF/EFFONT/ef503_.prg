/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: LISTAGEM DE CLIENTES
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MAIO DE 1995
// OBS........:
// ALTERACOES.:
function ef503

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOC1 := qlbloc("B513B","QBLOC.GLO") // ordem de impressao

private cTITULO                   // titulo do relatorio
private cORDEM                    // ordem de impressao (codigo/descricao)
private bFILTRO                   // code block de filtro
private aEDICAO := {}             // vetor para os campos de entrada de dados
private nFOLHA                    // numero da Folha

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOC1)  }    , "ORDEM" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nFOLHA     ,"@E 9999", NIL,NIL )} ,"FOLHA"  })

do while .T.

   qlbloc(5,0,"B513A","QBLOC.GLO",1)
   XNIVEL := 1
   XFLAG  := .T.
   cORDEM := " "

   nFOLHA := 0

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
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"12",{"C¢digo","Descric„o"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM GERAL DE CLIENTES"

   // SELECIONA ORDEM DO ARQUIVO CLI1 _______________________________________

   do case
      case cORDEM == "1" ; CLI1->(dbsetorder(1)) // codigo
      case cORDEM == "2" ; CLI1->(dbsetorder(2)) // descricao
   endcase

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bFILTRO := { || .T. }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select CLI1

   CLI1->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! CLI1->(eof()) .and. qcontprn()    // condicao principal de loop

      qmensa("Imprimindo CLIENTE: " + CLI1->Codigo+" / Raz„o: " + CLI1->Razao)

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND2

      if XPAGINA == 0 .or. prow() > K_MAX_LIN

         qpageprn()

         // ALTERAR NUMERO DE FOLHA, CASO SEJA INFORMADA__________________________

         if nFOLHA <> 0
            XPAGINA = nFOLHA
            nFOLHA  = 0
         endif

         qcabecprn(cTITULO,151)

         @ prow()+1,0 say "Cod.  Nome Cliente                           Endereco                                  Cep     "+;
                          "Estado  Fone           Insc. CGC/CPF   Insc. Estadual"
         @ prow()+1,0 say replicate("-",151)

      endif

      if eval(bFILTRO)

         CGM->(dbseek(CLI1->Cgm_ent))

         @ prow()+1,0 say CLI1->Codigo   + space(1) + left(CLI1->Razao,40)  + space(2) +;
                          left(CLI1->End_ent,40) + space(2) + CLI1->Cep_ent + space(2) +;
                          CGM->Estado    + space(2) + CLI1->Fone1   + space(2) +;
                          CLI1->Cgccpf   + space(2) + CLI1->Inscricao

      endif

      CLI1->(dbskip())

   enddo

   qstopprn()

return
