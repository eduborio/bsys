 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: EDICAO DE LAY-OUT DE CHEQUES
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function ts401

private fCODIGO
private lEXISTE := .F.
private fLINHA:=fVALOR:=fEXTENSO:=fNOMINAL:=fCIDADE:=fDIA:=fMES:=fANO:=space(3)

PLAN->(Dbsetorder(3))

BANCO->(qview({{"Codigo/C¢digo"                          ,0},;
               {"Banco/Banco"                            ,1},;
               {"left(Descricao,20)/Nome"                ,2},;
               {"c401b()/Nr. Conta"                      ,0},;
               {"Agencia/Agˆncia"                        ,0},;
               {"Telefone/Telefone"                      ,0},;
               {"Gerente/Gerente"                        ,0}},"P",;
                {NIL,"c401a",NIL,NIL},;
                NIL,"<ESC>-Sai/<C>onsulta/<E>dita/<T>estar Impressao"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETRNAR A MASCARA DA CONTA ___________________________________

function c401b
  local cCONTA
  cCONTA := transform(BANCO->Conta,"@R 999999-9")
return cCONTA

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c401a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "C"
      qlbloc(9,4,"B401A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_consulta()
   else

     if cOPCAO == "E"

        qlbloc(9,5,"B401B","QBLOC.GLO",1)

        fCODIGO := BANCO->Codigo

        if POS_CHEQ->(dbseek(fCODIGO))

           fVALOR   := POS_CHEQ->Valor
           fEXTENSO := POS_CHEQ->Extenso
           fLINHA   := POS_CHEQ->Linha
           fNOMINAL := POS_CHEQ->Nominal
           fCIDADE  := POS_CHEQ->Cidade
           fDIA     := POS_CHEQ->Dia
           fMES     := POS_CHEQ->Mes
           fANO     := POS_CHEQ->Ano
           lEXISTE := .T.

        endif

        i_edita()

     endif

     if cOPCAO == "T"
        i_imp_cheq()
     endif

   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A CONSULTA _________________________________________

static function i_consulta

   if cOPCAO == "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , BANCO->Codigo     )
      qrsay ( XNIVEL++ , BANCO->Descricao  )
      qrsay ( XNIVEL++ , BANCO->Banco      )
      qrsay ( XNIVEL++ , BANCO->Agencia    )
      qrsay ( XNIVEL++ , transform(BANCO->Conta,"@R 999999-9"))
      qrsay ( XNIVEL++ , BANCO->End_agenc  )
      qrsay ( XNIVEL++ , BANCO->Cod_cgm    ) ; CGM->(Dbseek(BANCO->Cod_cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,48))
      qrsay ( XNIVEL++ , BANCO->CEP        )
      qrsay ( XNIVEL++ , BANCO->Telefone   )
      qrsay ( XNIVEL++ , transform(BANCO->Conta_cont, "@R 99999-9")) ; PLAN->(Dbseek(BANCO->Conta_cont))
      qrsay ( XNIVEL++ , left(PLAN->Descricao,39))
      qrsay ( XNIVEL++ , BANCO->Filial     ) ; FILIAL->(Dbseek(BANCO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,36))
      qrsay ( XNIVEL++ , BANCO->Gerente    )
   endif

   qwait()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EDICAO DE CHEQUES  ___________________________________________

function i_edita

    local lCONF := .F.
    local aEDICAO := {}

    local bESCAPE := {|| empty(fVALOR).or.(XNIVEL==1.and.!XFLAG) .or.;
                        (XNIVEL==1.and.lastkey()==27)}
    XNIVEL := 1
    XFLAG  := .T.

    // PREENCHE O VETOR DE EDICAO ___________________________________________

    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR   ,"999"               ) } ,"VALOR"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fEXTENSO ,"999"               ) } ,"EXTENSO" })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA   ,"999"               ) } ,"LINHA"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fNOMINAL ,"999"               ) } ,"NOMINAL" })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fCIDADE  ,"999"               ) } ,"CIDADE"  })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA     ,"999"               ) } ,"DIA"     })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fMES     ,"999"               ) } ,"MES"     })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fANO     ,"999"               ) } ,"ANO"     })

    aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

    if ! lEXISTE
       POS_CHEQ->(qpublicfields())
    endif

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE ) ; POS_CHEQ->(qreleasefields()) ; return ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
    enddo

    // GRAVACAO ______________________________________________________________

    if ! lCONF ; return ; endif

    if POS_CHEQ->(qrlock())

       if ! lEXISTE
          POS_CHEQ->(qappend())
       endif

       replace POS_CHEQ->Cod_banco with fCODIGO
       replace POS_CHEQ->Valor     with fVALOR
       replace POS_CHEQ->Extenso   with fEXTENSO
       replace POS_CHEQ->Linha     with fLINHA
       replace POS_CHEQ->Nominal   with fNOMINAL
       replace POS_CHEQ->Cidade    with fCIDADE
       replace POS_CHEQ->Dia       with fDIA
       replace POS_CHEQ->Mes       with fMES
       replace POS_CHEQ->Ano       with fANO

       POS_CHEQ->(qunlock())

    endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TESTAR A EMITISSAO DO CHEQUE _________________________________

function i_imp_cheq()

   local cEXTENSO

   if POS_CHEQ->(Dbseek(BANCO->Codigo))

      if ! qinitprn() ; return ; endif

      @ prow()+1,val(POS_CHEQ->Valor)   say "999,999,999.99"

      cEXTENSO := qextenso(99999.99)

      nTAM := len(cEXTENSO)

      @ prow()+2,val(POS_CHEQ->Extenso)  say iif( nTAM >= val(POS_CHEQ->Linha) , left(cEXTENSO, val(POS_CHEQ->Linha) ) , cEXTENSO )

      if nTAM > val(POS_CHEQ->Linha)
         @ prow()+1,val(POS_CHEQ->Extenso) say substr( cEXTENSO, val(POS_CHEQ->Linha)+1, nTAM )
      else
         @ prow()+1,0 say ""
      endif

      @ prow()+2,val(POS_CHEQ->Nominal) say replicate("X",20)
      @ prow()+3,val(POS_CHEQ->Cidade)  say replicate("X",10)
      @ prow()  ,val(POS_CHEQ->Dia)     say "99"
      @ prow()  ,val(POS_CHEQ->Mes)     say replicate("X",9)
      @ prow()  ,val(POS_CHEQ->Ano)     say "99"

      @ prow()+3,0 say ""

      qstopprn(.F.)

   endif
return

