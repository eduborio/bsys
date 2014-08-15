/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: EMISSAO DO CADASTRO DO PLANO DE CONTAS
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function ct501

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1 := qlbloc("B501B","QBLOC.GLO") // ordem de impressao

private aEDICAO := {}  // vetor para os campos de entrada de dados
private cTITULO        // titulo do relatorio
private cORDEM  := "1" // ordem de impressao (codigo/codigo reduzido)
private nPAG    := 0   // pagina inicial para impressao
private cREDUI         // conta reduzida inicial da faixa
private cREDUF         // conta reduzida final da faixa
private cCONTAI        // conta contabil inicial
private cCONTAF        // conta contabil final
private nNIVEL         // nivel da conta
private lTITULO := .F. // p/ impresao do titulo apos a quebra de pagina

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1)            },"ORDEM" })

do while .T.

   qlbloc(5,0,"B501A","QBLOC.GLO")
   qmensa()
   PLAN->(dbsetorder(3))
   PLAN->(dbgotop())
   cREDUI  := PLAN->Reduzido
   PLAN->(dbgobottom())
   cREDUF  := PLAN->Reduzido
   PLAN->(dbsetorder(1))
   PLAN->(dbgotop())
   cCONTAI := ct_convcod(PLAN->Codigo)
   PLAN->(dbgobottom())
   cCONTAF := ct_convcod(PLAN->Codigo)
   PLAN->(dbgotop())
   XNIVEL  := 1
   XFLAG   := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] )
         qlbloc(5,0,"B501A","QBLOC.GLO")
         qmensa()
         loop
      endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cORDEM,"123",{"C¢digo","C¢digo Reduzido","Descri‡„o"}))
           qgetx(09,68,@nPAG,"9999")
           if cORDEM == "1"
              PLAN->(dbsetorder(01)) // codigo
              view_plcodi(13,14,@cCONTAI)
              if cCONTAI == " .  .  .  .    - "
                 qmensa("CONTA INICIAL ‚ obrigat¢ria !","B")
                 return .F.
              endif
              if PLAN->(dbseek(qtiraponto(cCONTAI)))
                 qsay(13,06,ct_convcod(PLAN->Reduzido))
                 qsay(13,32,PLAN->Descricao)
              else
                 qmensa("Conta n„o cadastrada !","B")
                 return .F.
              endif

              view_plcodi(17,14,@cCONTAF)
              if cCONTAF == " .  .  .  .    - "
                 qmensa("CONTA FINAL ‚ obrigat¢ria !","B")
                 return .F.
              endif
              if PLAN->(dbseek(qtiraponto(cCONTAF)))
                 qsay(17,06,ct_convcod(PLAN->Reduzido))
                 qsay(17,32,PLAN->Descricao)
              else
                 qmensa("Conta n„o cadastrada !","B")
                 return .F.
              endif

              if qtiraponto(cCONTAF) < qtiraponto(cCONTAI)
                 qmensa("Conta Final inferior a Conta Inicial !","B")
                 return .F.
              endif
           elseif cORDEM $ "23"

              PLAN->(dbsetorder(03)) // reduzido
              view_plredu(13,06,@cREDUI)
              if empty(cREDUI)
                 qmensa("CONTA INICIAL ‚ obrigat¢ria !","B")
                 return .F.
              endif
              cREDUI := strzero(val(cREDUI),6)
              qsay(13,06,cREDUI,"@R 99999-9")
              if PLAN->(dbseek(cREDUI))
                 qsay(13,14,ct_convcod(PLAN->Codigo))
                 qsay(13,32,PLAN->Descricao)
                 cCONTAI := PLAN->Codigo
              else
                 qmensa("Conta n„o cadastrada !","B")
                 return .F.
              endif

              view_plredu(17,06,@cREDUF)
              if empty(cREDUF)
                 qmensa("CONTA FINAL ‚ obrigat¢ria !","B")
                 return .F.
              endif
              cREDUF := strzero(val(cREDUF),6)
              qsay(17,06,cREDUF,"@R 99999-9")
              if PLAN->(dbseek(cREDUF))
                 qsay(17,14,ct_convcod(PLAN->Codigo))
                 qsay(17,32,PLAN->Descricao)
                 cCONTAF := PLAN->Codigo
              else
                 qmensa("Conta n„o cadastrada !","B")
                 return .F.
              endif

              if qtiraponto(cCONTAF) < qtiraponto(cCONTAI) .and. cORDEM <> "3"
                 qmensa("Conta Final inferior a Conta Inicial !","B")
                 return .F.
              endif
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   nNIVEL := 0

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "RELACAO DO CADASTRO DO PLANO DE CONTAS ORDENADO POR "

   // SELECIONA ORDEM DO ARQUIVO PLAN _______________________________________

   do case
      case cORDEM == "1"
           cTITULO += "CODIGO"
           PLAN->(dbseek(qtiraponto(cCONTAI)))
      case cORDEM == "2"
           cTITULO += "CODIGO REDUZIDO"
           PLAN->(dbseek(cREDUI))
      case cORDEM == "3"
           cTITULO += "DESCRICAO"
           PLAN->(dbseek(cREDUI))
           PLAN->(dbsetorder(2)) // descricao
   endcase

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   local cDESCRICAO

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

// do while ! PLAN->(eof()) .and. iif(cORDEM=="1",val(PLAN->Codigo)<=val(qtiraponto(cCONTAF)),;
//                                           val(PLAN->Reduzido)<=val(cREDUF)) .and. qcontprn()

   do while ! PLAN->(eof()) .and. qcontprn()

      if cORDEM=="1"
         if ! ( val(PLAN->Codigo)<=val(qtiraponto(cCONTAF)) )
            PLAN->(dbskip())
            loop
         endif
      elseif cORDEM == "2"
         if ! val(PLAN->Reduzido)<=val(cREDUF)
            PLAN->(dbskip())
            loop
         endif
      endif

      if cORDEM=="3" .and. empty(PLAN->Reduzido)
         PLAN->(Dbskip())
         loop
      endif

      do case
         case cORDEM == "1"
              qmensa("Conta: "+ct_convcod(PLAN->Codigo)+" / "+PLAN->Descricao)
         case cORDEM $ "23"
              qmensa(PLAN->Descricao+" / "+"Conta: "+ct_convcod(PLAN->Codigo))
      endcase

      if ! qlineprn() ; return ; endif

      cDESCRICAO := PLAN->Descricao

      do case
         case len(alltrim(PLAN->Codigo)) == 1  ; cDESCRICAO := PLAN->Descricao
         case len(alltrim(PLAN->Codigo)) == 3  ; cDESCRICAO := "   "+PLAN->Descricao
         case len(alltrim(PLAN->Codigo)) == 5  ; cDESCRICAO := "       "+PLAN->Descricao
         case len(alltrim(PLAN->Codigo)) == 7  ; cDESCRICAO := "           "+PLAN->Descricao
         case len(alltrim(PLAN->Codigo)) == 12 ; cDESCRICAO := "               "+PLAN->Descricao
      endcase

      if qtiraponto(PLAN->Codigo) >= qtiraponto(cCONTAI) .and. qtiraponto(PLAN->Codigo) <= qtiraponto(cCONTAF)

         if XPAGINA == 0 .or. prow() > K_MAX_LIN .or. lTITULO
            lTITULO := .F.
            if XPAGINA == 0
               if nPAG <= 0
                  XPAGINA := 1
               else
                  XPAGINA := --nPAG
               endif
            endif
            qpageprn()
            @ prow()+1,0         say XCOND1
            qcabecprn(cTITULO,128,.F.)
            do case
               case cORDEM == "1"
                    @ prow()+1,0         say XCOND1+"CODIGO"
                    @ prow()  ,pcol()+31 say "DESCRICAO DA CONTA"
                    @ prow()  ,pcol()+64 say "REDUZIDO"
               case cORDEM $ "23"
                    @ prow()+1,0         say XCOND1+"REDUZIDO"
                    @ prow()  ,pcol()+22  say "DESCRICAO DA CONTA"
                    @ prow()  ,pcol()+78 say "CODIGO"
            endcase

            @ prow()+1,0 say replicate("-",128)
         endif

   //    i_ctanivel()
   //
   //    do case
   //       case nNIVEL = 1
   //            nCOL := 3
   //       case nNIVEL = 2
   //            nCOL := 6
   //       case nNIVEL = 3
   //            nCOL := 9
   //       case nNIVEL = 4
   //            nCOL := 12
   //       case nNIVEL = 5
   //            nCOL := 15
   //    endcase

         do case
            case cORDEM == "1"
                 @ prow()+1,0           say ct_convcod(PLAN->Codigo)
                 @ prow()  ,pcol()+20   say iif ( right(PLAN->Codigo,5) == "     " , cDESCRICAO, cDESCRICAO )
                 @ prow()  ,118         say ct_convcod(PLAN->Reduzido)
            case cORDEM $ "23"
                 @ prow()+1,0           say ct_convcod(PLAN->Reduzido)
                 @ prow()  ,pcol()+19   say iif ( right(PLAN->Codigo,5) == "     " , PLAN->Descricao , PLAN->Descricao )
                 @ prow()  ,107         say ct_convcod(PLAN->Codigo)
         endcase

      endif

      PLAN->(dbskip())

//      if len(alltrim(PLAN->Codigo)) == 1; lTITULO := .T.; endif

   enddo

   qstopprn()
   qmensa()

return

/////////////////////////////////////////////////////////////////////////////
// VERIFICA NIVEL DE CONTA __________________________________________________

static function i_ctanivel
       local nCONT

       for nCONT = 11 to 1 step -1
           if subs(PLAN->Codigo,nCONT,1) != "0"
              do case
                 case nCONT == 1
                      nNIVEL :=  1
                 case nCONT == 2 .or. nCONT == 3
                      nNIVEL :=  2
                 case nCONT == 4 .or. nCONT == 5
                      nNIVEL :=  3
                 case nCONT == 6 .or. nCONT == 7
                      nNIVEL :=  4
                 case nCONT == 8 .or. nCONT == 9 .or. nCONT == 10 .or. nCONT == 11 .or. nCONT == 12
                      nNIVEL :=  5
              endcase
              exit
           endif
       next
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS RETORNANDO CODIGO REDUZIDO ______________

static function view_plredu (XX,YY,ZZ)
   PLAN->(dbSetFilter({|| ! empty(right(PLAN->Codigo,5))}, '! empty(right(PLAN->Codigo,5))'))

   PLAN->(qview(XX,YY,@ZZ,"@K@R 99999-9",NIL,.T.,NIL,;
         {{"ct_convcod(Reduzido)/Cod.Red." ,3},;
          {"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Codigo)/C¢digo"     ,1}},;
          "C",{"keyb(Reduzido)",NIL,NIL,NIL}))

   PLAN->(dbClearFilter())
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS RETORNANDO CODIGO CONTABIL ______________

static function view_plcodi (XX,YY,ZZ)
   PLAN->(qview(XX,YY,@ZZ,"9.99.99.99.9999-9",NIL,.T.,NIL,;
         {{"ct_convcod(Codigo)/C¢digo"     ,1},;
          {"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Reduzido)/Cod.Red." ,3}},;
          "C",{"keyb(Codigo)",NIL,NIL,NIL}))

   PLAN->(dbClearFilter())
return
