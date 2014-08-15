/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: LISTAGEM DE CONTAS A PAGAR A TERCEIROS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MARCO DE 1997
// OBS........:
function pg504

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO     := {}    // vetor para os campos de entrada de dados
private cTERC       := space(5)
private cTERC_ATU   := space(5)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                     ) } ,"DATA_INI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                     ) } ,"DATA_FIM"  })
aadd(aEDICAO,{{ || view_terc(-1,0,@cTERC                     ) } ,"TERC"      })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do terceiro

do while .T.

   qlbloc(05,0,"B504A","QBLOC.GLO",1)

   XNIVEL     := 1
   XFLAG      := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cTERC      := space(5)
   cTERC_ATU  := space(5)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

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

      case cCAMPO == "TERC"

           qrsay(XNIVEL,cTERC)

           if empty(cTERC)
              qrsay(XNIVEL++, "Todos os Terceiros.......")
           else
              if ! TERCEIRO->(Dbseek(cTERC:=strzero(val(cTERC),5)))
                 qmensa("Terceiro n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(TERCEIRO->Nome,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTAS A PAGAR DE TERCEIROS"

   if ! empty(cTERC)
      LCTO_TER->(dbsetorder(4))  // COD_TERC + DATA_VCTO
      qmensa("")
   else
      LCTO_TER->(dbsetorder(3))  // DATA_VCTO
      qmensa("")
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55
   local dVENC   := ctod("")

   local nTOT_APAG := 0
   local nTOT_PAGO := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")
   
   if ! empty(cTERC)
      LCTO_TER->(Dbsetorder(4))
      LCTO_TER->(Dbseek(cTERC))
   else
      LCTO_TER->(Dbsetorder(3))
      LCTO_TER->(dbgotop())
   endif

   cTERC_ATU := LCTO_TER->Cod_terc
   dVENC     := LCTO_TER->Data_vcto

   do while ! LCTO_TER->(eof())  .and. qcontprn()  // condicao principal de loop

      if LCTO_TER->Data_vcto < dDATA_INI .or. LCTO_TER->Data_vcto > dDATA_FIM
         LCTO_TER->(Dbskip(1))
         loop
      endif

      if ! empty(cTERC) .and. LCTO_TER->Cod_terc <> cTERC
         LCTO_TER->(Dbskip(1))
         loop
      endif

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,123)
         @ prow()+1, 0 say "TERCEIRO                                          A.F.  CONHEC. NR.    DT. VCTO   DT.EMISS   FRETE       VALOR    DT.PAGTO"
         @ prow()+1, 0 say replicate("-",123)
      endif

      TERCEIRO->(dbseek(LCTO_TER->Cod_terc))
      @ prow()+1,00  say left(TERCEIRO->Nome,45)
      @ prow()  ,49  say LCTO_TER->Nr_af
      @ prow()  ,58  say LCTO_TER->Conhe_nr
      @ prow()  ,71  say dtoc(LCTO_TER->Data_vcto)
      @ prow()  ,82  say dtoc(LCTO_TER->Data_emiss)
      @ prow()  ,93  say str(LCTO_TER->Fr_numero,6)
      @ prow()  ,100 say transform(LCTO_TER->Valor_terc, "@E 999,999.99")
      @ prow()  ,113 say dtoc(LCTO_TER->Data_pgto)

      if empty(LCTO_TER->Data_pgto)
         nTOT_APAG += LCTO_TER->Valor_terc
      else
         nTOT_PAGO += LCTO_TER->Valor_terc
      endif

      LCTO_TER->(dbskip())

   enddo

   if nTOT_PAGO <> 0 .or. nTOT_APAG <> 0
      @ prow()+2,0 say XAENFAT + "Total a Pagar ............... " + transform(nTOT_APAG, "@E 999,999.99") + XDENFAT
      @ prow()+1,0 say XAENFAT + "Total Pago    ............... " + transform(nTOT_PAGO, "@E 999,999.99") + XDENFAT
   endif

   @ prow()+1, 0 say replicate("-",123)

   qstopprn()

return
