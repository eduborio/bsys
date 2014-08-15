/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DE INTEGRACAO BANCARIA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: MAIO DE 1996
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private cTITULO           // para montar o titulo do relatorio

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

/////////////////////////////////////////////////////////////////////////////
// DEFINE QUAL O BANCO QUE SERA TRABALHADO __________________________________

INTBANC->(qview({{"Banco/Banco"      ,0},;
                 {"Cod_banco/C¢digo" ,0}},"P",;
                 {NIL,"f526",NIL,NIL},;
                 NIL,"<E>mitir Relatorio"))
return

///////////////////////////////////////////////////////?/////////////////////
// FUNCAO PARA DISTRIBUICAO CONFORME BANCO SELECIONADO ______________________

function f526

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   setcursor(nCURSOR)

   if cOPCAO == "E"
      i_edicao()
   endif

return ""


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ENTRADA DE DADOS _____________________________________________

static function i_edicao

   //////////////////////////////////////////////////////////////////////////
   // DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS _________

   local bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

   private sBLOCO1 := qlbloc("B526F","QBLOC.GLO")
   private sBLOCO3 := qlbloc("B526E","QBLOC.GLO")
   
   private aEDICAO := {}
   private cCODIGO
   private cTIPO
   private cCCUSTO
   private cDT_PGTO
   private cAMBIENTE
   private nNUMARQ := 0
   private lCONF
   private lACHOU  := .F.
   private cANOMES
   private cMESANO

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@cCODIGO  ,"999999999"   )}, "CODIGO"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@cAMBIENTE,SBLOCO3       )}, "AMBIENTE"})
   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO    ,SBLOCO1       )}, "TIPO"    })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCCUSTO)           }, "CCUSTO"  })
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro de custo
   aadd(aEDICAO,{{ || qgetx(-1,0,@cDT_PGTO  ,"@D"         )}, "DT_PGTO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cMESANO  ,"99/9999"       )}, "MESANO"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Relat¢rio ?")}, NIL       })

   do while .T.

      qlbloc(5,0,"B526G","QBLOC.GLO")
      qmensa()
      cDT_PGTO  := ctod("")
      cCODIGO   := space(9)
      cCCUSTO   := space(8)
      cAMBIENTE := " "
      XNIVEL    := 1
      cANOMES   := space(6)
      cMESANO   := space(7)

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit2 ( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if lCONF
         FUN->(Dbgotop())
//       FUN->(dbsetorder(8)) // centro + nome
//       if ! FUN->(Dbseek(cCCUSTO))
//          qmensa("N„o existem funcion rios Cadastrados neste Centro de Custo !","B")
//          return
//       endif
         if ( i_inicializacao() , i_impressao() , NIL )
      endif

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_crit2 ( cCAMPO )
    do case

      case cCAMPO == "AMBIENTE"
           qrsay(XNIVEL,qabrev(cAMBIENTE,"MADF",{"Mensal","Adiantamento","D‚cimo Terceiro","Ferias"}))

       case cCAMPO == "TIPO"
            if empty(cTIPO) ; return .F. ; endif
            qrsay(XNIVEL,qabrev(cTIPO,"123",{"Inclusao de Funcionario novo","Alteracao de Funcionario ja existente","Exclusao de funcionarios ja existentes"}))

         case cCAMPO == "DT_PGTO"
            if empty(cDT_PGTO)
               qmensa("Campo ‚ Obrigat¢rio !!","B")
               return .F.
            endif

      case cCAMPO == "MESANO"

           cANOMES := right(cMESANO,2) + left(cMESANO,4)

      case cCAMPO == "CCUSTO"

           if CCUSTO->(dbseek(cCCUSTO))
              qrsay ( XNIVEL+1 , left(CCUSTO->Descricao,40) )
           else
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif

    endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   cTITULO := "EMISSAO DE INTEGRACAO BANCARIA"

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EMITIR RELATORIO DE INTEGRACAO COM BANCO ____________________

static function i_impressao

   local nFUNCS := nTOTAL := 0

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   @ prow(),pcol() say XCOND0

// FUN->(dbsetorder(8))
   FUN->(dbsetorder(2)) // nome

   do while ! FUN->(eof())

      qgirabarra()

      SITUA->(dbseek(FUN->Matricula))

//    if FUN->Centro <> cCCUSTO .or. FUN->Situacao $ "DH "
      if SITUA->Ccusto <> cCCUSTO .or. FUN->Situacao $ "DH "
         FUN->(dbskip())
         loop
      endif

      BASE->(dbseek(FUN->Matricula + cANOMES))

      do case
         case cAMBIENTE == "M"
              nLIQ := BASE->Prov_ms - BASE->Desc_ms
         case cAMBIENTE == "A"
              nLIQ := BASE->Prov_ad - BASE->Desc_ad
         case cAMBIENTE == "D"
              nLIQ := BASE->Prov_dt - BASE->Desc_dt
         case cAMBIENTE == "F"
              nLIQ := BASE->Prov_fr - BASE->Desc_fr
      endcase

      if nLIQ <= 0
         FUN->(Dbskip())
         loop
      endif

      if ! qlineprn() ; return ; endif

      // CABECALHO SE NECESSARIO ____________________________________________

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow(),pcol() say XCOND0
         qcabecprn(cTITULO,80)
//       @ prow()+1,00 say "CCUSTO -> "+iif ( CCUSTO->(Dbseek(FUN->Centro)) , CCUSTO->Descricao, space(20) ) + " Data Pagamento: "+dtoc(cDT_PGTO)
         @ prow()+1,00 say "CCUSTO -> "+iif ( CCUSTO->(Dbseek(SITUA->Ccusto)) , CCUSTO->Descricao, space(20) ) + " Data Pagamento: "+dtoc(cDT_PGTO)
         @ prow()+1,00 say "MATRICULA NOME                                    SALARIO   BANCO     C/C"
         @ prow()+1,0 say replicate("-",80)
      endif

      @ prow()+1,00 say FUN->Matricula
      @ prow()  ,10 say left(FUN->Nome,30)

      @ prow()  ,45 say transform(nLIQ, "@E 9,999,999.99")
      @ prow()  ,60 say FUN->Csal_ban
      @ prow()  ,70 say FUN->Csal_num

      nTOTAL := nTOTAL + nLIQ
      nFUNCS += 1

      nLIQ := 0

      FUN->(dbskip())

   enddo

   @ prow()+1,0 say replicate("-",80)
   @ prow()+1,0 say "              TOTAL GERAL DOS SALARIOS............: "+transform(nTOTAL, "@E 99,999,999.99")
   @ prow()+1,0 say "              TOTAL GERAL DE FUNCIONARIOS.........: "+transform(nFUNCS, "@e 999")
   @ prow()+1,0 say replicate("-",80)

   qstopprn()

return
