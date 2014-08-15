/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE CHEQUES PRE-DATADOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function ts501

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private sBLOC1  := qlbloc("B501E","QBLOC.GLO")
private cTITULO                                 // titulo do relatorio

private bFILTRO                                 // code block de filtro
private aEDICAO   := {}                         // vetor para os campos de entrada de dados
private dDATA_INI := ctod("")
private dDATA_FIM := ctod("")
private dDIA      := ctod("")
private nDIA      := 0
private nTOT      := 0
private fBAIXA    := ""
private cCOND     := ""
private dBANCO    := space(5)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI     ,"@D"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM     ,"@D"     ,NIL,NIL) } ,"DATA_FIM"})
aadd(aEDICAO,{{ || qesco(-1,0,@fBAIXA ,sBLOC1                    )} ,"BAIXA" })

do while .T.

   qlbloc(5,0,"B501A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   dDATA_INI  := ctod("01/" + right(qanomes(date()),2) + "/" + left(qanomes(date()),4))
   dDATA_FIM  := qfimmes(dDATA_INI)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   set softseek off

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
      case cCAMPO == "BAIXA"
           if empty(fBAIXA) ; return .F. ; endif
           qsay(-1,0,qabrev(fBAIXA,"SN",{"Sim","N„o"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE CHEQUES PRE-DATADOS DE: " + dtoc(dDATA_INI) + " ATE " + dtoc(dDATA_FIM)
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   BANCO->(Dbsetorder(3))

   if fBAIXA = "N"
      CHEQUES->(dbsetorder(7))         // DTOS(DATA_VENC) + COD_BANCO
      CHEQUES->(dbSetFilter({|| empty(DATA_BX) }, 'empty(DATA_BX)'))
      set softseek on
      CHEQUES->(Dbseek(dDATA_INI))
      cCOND  := "! CHEQUES->(eof()) .and. CHEQUES->Data_venc >= dDATA_INI .and. CHEQUES->Data_venc <= dDATA_FIM"
      dDIA   := CHEQUES->Data_venc
      dBANCO := CHEQUES->Cod_banco
   else
      CHEQUES->(dbsetorder(8))         // DTOS(DATA_BX) + COD_BANCO
      CHEQUES->(dbSetFilter({|| ! empty(DATA_BX) }, '! empty(DATA_BX)'))
      set softseek on
      CHEQUES->(Dbseek(dDATA_INI))
      cCOND  := "! CHEQUES->(eof()) .and. CHEQUES->Data_bx >= dDATA_INI .and. CHEQUES->Data_bx <= dDATA_FIM"
      dDIA   := CHEQUES->Data_bx
      dBANCO := CHEQUES->Cod_banco
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

function i_impressao
   local cPIC1 := "@E 9,999,999.99"
   nTOT := 0


   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while &cCOND .and. qcontprn()

      if ! qlineprn() ; exit ; endif

      qgirabarra()

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow(),pcol() say XCOND0
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "BANCO :"+CHEQUES->Cod_banco +" - "+iif( BANCO->(Dbseek(CHEQUES->Cod_banco)), BANCO->Descricao, space(40) )
         @ prow()+1,0 say "CODIGO EMITENTE                       VCTO       CHEQUE        VALOR"
         if fBAIXA = "S"
            @ prow(),70 say "BAIXA"
         endif
         @ prow()+1,0 say replicate("-",80)
      endif

      @ prow()+1,00  say CHEQUES->Codigo
      @ prow()  ,07  say left(CHEQUES->Emitente,25)
      @ prow()  ,38  say dtoc(CHEQUES->Data_venc)
      @ prow()  ,49 say CHEQUES->Cheque
      @ prow()  ,56 say transform(CHEQUES->Valor, "@e 9,999,999.99")

      if fBAIXA = "S"
         @ prow() ,70 say dtoc(CHEQUES->Data_bx)
      endif

      nTOT += CHEQUES->Valor
      nDIA += CHEQUES->Valor

      CHEQUES->(dbskip())

      if fBAIXA = "N"
         if CHEQUES->Data_venc <> dDIA   // totaliza cada vencimento
            @ prow()+1,44 say "Total do Dia.> "+transform(nDIA, "@e 9,999,999.99")
            nDIA := 0
            dDIA := CHEQUES->Data_venc
         endif
      else
         if CHEQUES->Data_bx <> dDIA   // totaliza cada baixa
            @ prow()+1,44 say "Total do Dia.> "+transform(nDIA, "@e 9,999,999.99")
            nDIA := 0
            dDIA := CHEQUES->Data_bx
         endif
      endif

      if ! CHEQUES->(eof()) .and. CHEQUES->Cod_banco <> dBANCO
         @ prow()+1,0 say "BANCO :"+CHEQUES->Cod_banco +" - "+iif( BANCO->(Dbseek(CHEQUES->Cod_banco)), BANCO->Descricao, space(40) )
         @ prow()+1,0 say "CODIGO EMITENTE                       VCTO       CHEQUE        VALOR"
         if fBAIXA = "S"
            @ prow(),70 say "BAIXA"
         endif
         @ prow()+1,0 say replicate("-",80)
         dBANCO := CHEQUES->Cod_banco
      endif

   enddo

   @ prow()+1,0   say replicate("-",80)
   @ prow()+1,43 say "Total Geral..> "+transform(nTOT, "@e 99,999,999.99")
   @ prow()+1,0   say replicate("-",80)

   qstopprn()

return
