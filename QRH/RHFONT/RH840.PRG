
//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FOLHA DE PAGAMENTO
// OBJETIVO...: ZERAR OS ARQUIVOS POR PERIODO
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: OUTUBRO DE 1997
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS _______________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27)}

private sBLOC1 := qlbloc("B840A","QBLOC.GLO") // Periodo da delecao
private dDATA_INI                             // Inicio do periodo da delecao
private dDATA_FIM                             // Fim do periodo da delecao
private aEDICAO    := {}                      // vetor para os campos de entrada de dados

private bLANC_FILTRO                          // code block de filtro
private bBASE_FILTRO                          // code block de filtro
private bBENEF_FILTRO                         // code block de filtro
private bSITUA_FILTRO                         // code block de filtro

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

   qlbloc(5,0,"B840A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@D"     ,NIL,NIL) } ,"DATA_INI"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@D"     ,NIL,NIL) } ,"DATA_FIM"})

do while .T.

   qlbloc(5,0,"B840A","QBLOC.GLO")
   XNIVEL      := 1
   dDATA_INI   := ctod("01/01/" + left(XANOMES,4))
   dDATA_FIM   := ctod("31/12/" + left(XANOMES,4))

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo
   if qconf("Confirma a Dele‡„o de arquivos ?","B")
      if alert("Antes de DELETAR os arquivos,; favor verificar se foi feito o BACKUP; Deseja DELETAR ?",{"NAO","SIM"}) == 2
         if qmensa("Senha para processar dele‡„o...:"),qgetsenha(24,44,9) == "BORBOLETA"
            if (i_inicia() , i_delecao() , NIL)
         endif
      endif
   endif
enddo

return

//////////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA __________________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif
   endcase
return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DELECAO DE ARQUIVOS _______________________________________________

static function i_delecao

       do while ! LANC->(eof())
          qmensa("Excluindo o arquivo LANC.DBF !, * AGUARDE *")
          if LANC->(qrlock()) .and. eval(bLANC_FILTRO)
             qgirabarra()
             LANC->(dbdelete())
             LANC->(qunlock())
          endif
          LANC->(dbskip())
       enddo

       do while ! BASE->(eof())
          qmensa("Excluindo o arquivo BASE.DBF !, * AGUARDE *")
          if BASE->(qrlock()) .and. eval(bBASE_FILTRO)
             qgirabarra()
             BASE->(dbdelete())
             BASE->(qunlock())
          endif
          BASE->(dbskip())
       enddo

       do while ! BENEF->(eof())
          qmensa("Excluindo o arquivo BENEF.DBF !, * AGUARDE *")
          if BENEF->(qrlock()) .and. eval(bBENEF_FILTRO)
             qgirabarra()
             BENEF->(dbdelete())
             BENEF->(qunlock())
          endif
          BENEF->(dbskip())
       enddo

       do while ! SITUA->(eof())
          qmensa("Excluindo o arquivo SITUA.DBF !, * AGUARDE *")
          if SITUA->(qrlock()) .and. eval(bSITUA_FILTRO)
             qgirabarra()
             SITUA->(dbdelete())
             SITUA->(qunlock())
          endif
          SITUA->(dbskip())
       enddo

return .T.
/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicia

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bLANC_FILTRO  := { || val(LANC->Anomes)  >= val(qanomes(dDATA_INI)) .and. val(LANC->Anomes)  <= val(qanomes(dDATA_FIM)) }
   bBASE_FILTRO  := { || val(BASE->Anomes)  >= val(qanomes(dDATA_INI)) .and. val(BASE->Anomes)  <= val(qanomes(dDATA_FIM)) }
   bBENEF_FILTRO := { || val(BENEF->Anomes) >= val(qanomes(dDATA_INI)) .and. val(BENEF->Anomes) <= val(qanomes(dDATA_FIM)) }
   bSITUA_FILTRO := { || val(SITUA->Anomes) >= val(qanomes(dDATA_INI)) .and. val(SITUA->Anomes) <= val(qanomes(dDATA_FIM)) }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select LANC                          // LANC.DBF
   LANC->(dbsetorder(1))
   LANC->(dbgotop())

   select BASE                          // BASE.DBF
   BASE->(dbsetorder(1))
   BASE->(dbgotop())

   select BENEF                         // BENEF.DBF
   BENEF->(dbsetorder(1))
   BENEF->(dbgotop())

   select SITUA                         // SITUA.DBF
   SITUA->(dbsetorder(1))
   SITUA->(dbgotop())

return .T.

