/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE Almoxarifes/Coleta/Expedicao
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: Janeiro DE 2009
// OBS........:
// ALTERACOES.:

function cl570
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cALM := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_alm(-1,0,@cALM)         } , "ALM"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B570A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

      case cCAMPO == "ALM"
            if !empty(cALM)
               qrsay(XNIVEL,cALM := strzero(cALM,5))
               if ! ALMOXAR->(dbseek(cALM))
                  qmensa("Almoxarife nao encontrado!","BL")
                  return.F.
               endif
               qrsay(XNIVEL+1,left(ALMOXAR->Nome,30))

            else
               qrsay(XNIVEL+1,"*** Todos Almoxarifes ***")

            endif



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "RELATORIO DE COLETA/EXPEDICAO" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   FAT->(dbsetfilter({||Dt_emissao >= dINI .and. dt_emissao <= dFIM }))
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif



return


static function i_impre_prn
    local nCONT := 0
    local nCOLETA := 0
    local nExpedicao := 0
    local nQTDE := 0
    local larrayNaoVazia := .F.
    local aColeta   := {}
    local aResumo := {}
    local nTempo         := 0
    local nTempoColeta   := 0
    local nTempoExpedicao := 0

   do while ! FAT->(eof())

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Col_alm).and. empty(FAT->Exp_alm)
         FAT->(dbskip())
         loop
      endif


      qgirabarra()

      qmensa("Aguarde... Processando ... Data: "+dtoc(FAT->Dt_emissao))
   
      ITEN_FAT->(Dbseek(FAT->Codigo))

      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          nQTDE += ITEN_FAT->Quantidade
          ITEN_FAT->(Dbskip())
      enddo

      //1 Coleta
      //2 Expedicao

      if !empty(FAT->Col_alm)
         aadd(aColeta,{FAT->Col_alm,"1",FAT->Codigo,nQTDE,FAT->Col_ini,FAT->col_fim,FAT->col_time})
         lArrayNaoVazia := .T.
      endif

      if !empty(FAT->Exp_alm)
         aadd(aColeta,{FAT->exp_alm,"2",FAT->Codigo,nQTDE,FAT->Exp_ini,FAT->Exp_fim,FAT->Exp_time})
         lArrayNaoVazia := .T.
      endif

      nQtde := 0


      FAT->(dbskip())

   enddo

   asColeta := asort(aColeta,,,{|x,y| x[1]+x[2] < y[1]+y[2]} )



   if lArrayNaoVazia
       cALM  := asColeta[1,1]
       cTipo := asColeta[1,2]
       ALMOXAR->(dbseek(cALM))
       zNOME :=  left(ALMOXAR->Nome,30)

       nCONT := 1
       do while  nCONT <= len(asColeta)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,132)
              @ prow()+1,0  say "Nome"
              @ prow()  ,32 say "Emissao"
              @ prow()  ,44 say "Pedido"
              @ prow()  ,53 say "Qtde."
              @ prow()  ,60 say "Inicio"
              @ prow()  ,70 say "Fim"
              @ prow()  ,80 say "Tempo Total"

              @ prow()+1,0 say replicate("-",132)
           endif

           FAT->(dbseek(ascoleta[ncont,3]))

           @ prow()+1,00 say zNOME
           @ prow()  ,32 say dtoc(FAT->Dt_emissao)
           @ prow()  ,44 say FAT->Codigo
           @ prow()  ,52 say transform(asColeta[nCont,4],"@R 999999")
           @ prow()  ,60 say asColeta[nCONT,5]
           @ prow()  ,70 say asColeta[nCONT,6]
           @ prow()  ,80 say asColeta[nCONT,7]
           @ prow()  ,100 say iif(asColeta[nCONT,2] == "1","Coleta","Expedicao")

           ntempo := 0

           if asColeta[ncont,2] == "1"
              nColeta    += asColeta[nCont,4]
              nTempo := HoraToNumerico(asColeta[nCont,7])
              nTempoColeta += qhmtoc(nTempo)

           else
              nExpedicao += asColeta[nCont,4]
              nTempo := HoraToNumerico(asColeta[nCont,7])
              nTempoExpedicao += qhmtoc(nTempo)
           endif

           nCONT++
           if nCONT > len(asColeta)
              nCONT := len(asColeta)
              exit
           endif

           if asColeta[nCONT,1] != cALM
              @ prow()+1,00   say "Total.......:  "+transform(nColeta+nExpedicao,"@E 999999") + "    Coleta.:  "+transform(nColeta,"@R 999999")+ "     Expedicao.:  "+transform(nExpedicao,"@R 999999")
              @ prow()+1,00   say "Tempo Total.: "+NumericoToHora(qctohm(nTempoColeta+nTempoExpedicao)) + "    Coleta.: "+NumericoToHora(qctohm(nTempoColeta))+ "     Expedicao.: "+NumericoToHora(qctohm(nTempoExpedicao))
              ALMOXAR->(dbseek(cALM))
              zNOME := left(ALMOXAR->Nome,30)

              aadd(aResumo,{zNOME,(nColeta+nExpedicao),nColeta,nExpedicao,NumericoToHora(qctohm(nTempoColeta+nTempoExpedicao)),NumericoToHora(qctohm(nTempoColeta)),NumericoToHora(qctohm(nTempoExpedicao))})

              cALM := ascoleta[nCONT,1]
              ALMOXAR->(dbseek(cALM))
              zNOME := left(ALMOXAR->Nome,30)

              nColeta    := 0
              nExpedicao := 0
              nTempo     := 0
              nTempoColeta := 0
              nTempoExpedicao := 0
              @prow()+1,00 say replicate("-",132)
              @prow()+1,00 say ""
           endif
       enddo
   endif

   if (nColeta + nExpedicao) > 0

     @ prow()+1,00   say "Total.......:  "+transform(nColeta+nExpedicao,"@E 999999") + "    Coleta.:  "+transform(nColeta,"@R 999999")+ "     Expedicao.:  "+transform(nExpedicao,"@R 999999")
     @ prow()+1,00   say "Tempo Total.: "+NumericoToHora(qctohm(nTempoColeta+nTempoExpedicao)) + "    Coleta.: "+NumericoToHora(qctohm(nTempoColeta))+ "     Expedicao.: "+NumericoToHora(qctohm(nTempoExpedicao))
     ALMOXAR->(dbseek(cALM))
     zNOME := left(ALMOXAR->Nome,30)

     aadd(aResumo,{zNOME,nColeta+nExpedicao,nColeta,nExpedicao,NumericoToHora(qctohm(nTempoColeta+nTempoExpedicao)),NumericoToHora(qctohm(nTempoColeta)),NumericoToHora(qctohm(nTempoExpedicao))})

     cALM := ascoleta[nCONT,1]
     ALMOXAR->(dbseek(cALM))
     zNOME := left(ALMOXAR->Nome,30)

     nColeta    := 0
     nExpedicao := 0
     nTempo     := 0
     nTempoColeta := 0
     nTempoExpedicao := 0
     @ prow()+1,00 say replicate("-",132)
     @ prow()+1,00 say ""
   endif

   nColeta    := 0
   nExpedicao := 0
   nTempo     := 0
   nTempoColeta := 0
   nTempoExpedicao := 0

   i_ResumoPrn(aResumo)


   qstopprn(.f.)

return

static function i_impre_xls
    local nCONT := 0
    local nCOLETA := 0
    local nExpedicao := 0
    local nQTDE := 0
    local larrayNaoVazia := .F.
    local aColeta   := {}
    local aResumo := {}
    local nTempo         := 0
    local nTempoColeta   := 0
    local nTempoExpedicao := 0


   do while ! FAT->(eof())

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Col_alm).and. empty(FAT->Exp_alm)
         FAT->(dbskip())
         loop
      endif


      qgirabarra()

      qmensa("Aguarde... Processando ... Data: "+dtoc(FAT->Dt_emissao))
   
      ITEN_FAT->(Dbseek(FAT->Codigo))

      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          nQTDE += ITEN_FAT->Quantidade
          ITEN_FAT->(Dbskip())
      enddo

      //1 Coleta
      //2 Expedicao

      if !empty(FAT->Col_alm)
         aadd(aColeta,{FAT->Col_alm,"1",FAT->Codigo,nQTDE,FAT->Col_ini,FAT->col_fim,FAT->col_time})
         lArrayNaoVazia := .T.
      endif

      if !empty(FAT->Exp_alm)
         aadd(aColeta,{FAT->exp_alm,"2",FAT->Codigo,nQTDE,FAT->Exp_ini,FAT->Exp_fim,FAT->Exp_time})
         lArrayNaoVazia := .T.
      endif

      nQtde := 0


      FAT->(dbskip())

   enddo

   asColeta := asort(aColeta,,,{|x,y| x[1]+x[2] < y[1]+y[2]} )



   if lArrayNaoVazia
       cALM  := asColeta[1,1]
       cTipo := asColeta[1,2]
       ALMOXAR->(dbseek(cALM))
       zNOME :=  left(ALMOXAR->Nome,30)

       nCONT := 1
       do while  nCONT <= len(asColeta)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              qpageprn()
              @ prow()+1,0  say  cTITULO +" 570"
              @ prow()+2,0      say "Nome" +chr(9)
              @ prow()  ,pcol() say "Emissao" +chr(9)
              @ prow()  ,pcol() say "Pedido" +chr(9)
              @ prow()  ,pcol() say "Qtde."+chr(9)
              @ prow()  ,pcol() say "Inicio"+chr(9)
              @ prow()  ,pcol() say "Fim" +chr(9)
              @ prow()  ,pcol() say "Tempo Total"

              @ prow()+1,0 say ""
           endif

           FAT->(dbseek(ascoleta[ncont,3]))

           @ prow()+1,00 say zNOME +chr(9)
           @ prow()  ,pcol() say dtoc(FAT->Dt_emissao)+chr(9)
           @ prow()  ,pcol() say FAT->Codigo+chr(9)
           @ prow()  ,pcol() say transform(asColeta[nCont,4],"@R 999999")+chr(9)
           @ prow()  ,pcol() say asColeta[nCONT,5]+chr(9)
           @ prow()  ,pcol() say asColeta[nCONT,6]+chr(9)
           @ prow()  ,pcol() say asColeta[nCONT,7]+chr(9)
           @ prow()  ,pcol() say iif(asColeta[nCONT,2] == "1","Coleta","Expedicao")

           nTempo := 0

           if asColeta[ncont,2] == "1"
              nColeta    += asColeta[nCont,4]
              nTempo := HoraToNumerico(asColeta[nCont,7])
              nTempoColeta += qhmtoc(nTempo)

           else
              nExpedicao += asColeta[nCont,4]
              nTempo := HoraToNumerico(asColeta[nCont,7])
              nTempoExpedicao += qhmtoc(nTempo)

           endif

           nCONT++
           if nCONT > len(asColeta)
              nCONT := len(asColeta)
              exit
           endif

           if asColeta[nCONT,1] != cALM
              @ prow()+1,00 say "Total.: "+transform(nColeta+nExpedicao,"@E 999999") + "    Coleta.: "+transform(nColeta,"@R 999999")+ "     Expedicao.: "+transform(nExpedicao,"@R 999999")
              @ prow()+1,00   say "Tempo Total.: "+NumericoToHora(qctohm(nTempoColeta+nTempoExpedicao)) + "    Coleta.: "+NumericoToHora(qctohm(nTempoColeta))+ "     Expedicao.: "+NumericoToHora(qctohm(nTempoExpedicao))
              ALMOXAR->(dbseek(cALM))
              zNOME := left(ALMOXAR->Nome,30)

              aadd(aResumo,{zNOME,nColeta+nExpedicao,nColeta,nExpedicao,NumericoToHora(qctohm(nTempoColeta+nTempoExpedicao)),NumericoToHora(qctohm(nTempoColeta)),NumericoToHora(qctohm(nTempoExpedicao))})

              cALM := ascoleta[nCONT,1]
              ALMOXAR->(dbseek(cALM))
              zNOME := left(ALMOXAR->Nome,30)

              nColeta    := 0
              nExpedicao := 0
              @prow()+1,00 say ""
              @prow()+1,00 say ""
           endif
       enddo
   endif

   if (nColeta + nExpedicao) > 0

     @ prow()+1,00   say "Total.......:  "+transform(nColeta+nExpedicao,"@E 999999") + "    Coleta.:  "+transform(nColeta,"@R 999999")+ "     Expedicao.:  "+transform(nExpedicao,"@R 999999")
     @ prow()+1,00   say "Tempo Total.: "+NumericoToHora(qctohm(nTempoColeta+nTempoExpedicao)) + "    Coleta.: "+NumericoToHora(qctohm(nTempoColeta))+ "     Expedicao.: "+NumericoToHora(qctohm(nTempoExpedicao))
     ALMOXAR->(dbseek(cALM))
     zNOME := left(ALMOXAR->Nome,30)

     aadd(aResumo,{zNOME,nColeta+nExpedicao,nColeta,nExpedicao,NumericoToHora(qctohm(nTempoColeta+nTempoExpedicao)),NumericoToHora(qctohm(nTempoColeta)),NumericoToHora(qctohm(nTempoExpedicao))})

     cALM := ascoleta[nCONT,1]
     ALMOXAR->(dbseek(cALM))
     zNOME := left(ALMOXAR->Nome,30)

     nColeta    := 0
     nExpedicao := 0
     nTempo     := 0
     nTempoColeta := 0
     nTempoExpedicao := 0
   endif

   nColeta    := 0
   nExpedicao := 0
   nTempo     := 0
   nTempoColeta := 0
   nTempoExpedicao := 0

   if lArrayNaoVazia
      i_ResumoXls(aResumo)
   endif


   qstopprn(.f.)

return


static function i_ResumoPrn(aResumo)
local nCONT := 0

       XPAGINA := 0
       nCont := 1
       do while  nCONT <= len(aResumo)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+4,0 say ""
              qpageprn()
              qcabecprn("Resumo de Relatorio de Almoxarifes",132)
              @ prow()+1,0   say "Nome"
              @ prow()  ,32  say "Total"
              @ prow()  ,44  say "Coleta"
              @ prow()  ,53  say "Expedicao"

              @ prow()+1,0 say replicate("-",132)
           endif

           @ prow()+1,00 say aResumo[nCONT,1]
           @ prow()  ,32 say transf(aResumo[nCONT,2],"@R 9999999")
           @ prow()  ,42 say transf(aResumo[nCONT,3],"@R 9999999")
           @ prow()  ,52 say transf(aResumo[nCONT,4],"@R 9999999")
           @ prow()+1,00 say aResumo[nCONT,1]
           @ prow()  ,32 say aResumo[nCONT,5]
           @ prow()  ,42 say aResumo[nCONT,6]
           @ prow()  ,52 say aResumo[nCONT,7]
           @ prow()+1,00 say ""


           nCONT++
           if nCONT > len(aResumo)
              nCONT := len(aResumo)
              exit
           endif

       enddo


return



static function i_ResumoXls(aResumo)
local nCONT := 0

       XPAGINA := 0
       nCont := 1
       do while  nCONT <= len(aResumo)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              @ prow()+1,0 say ""
              qpageprn()
              @ prow()+1,0 say "Resumo de Relatorio de Almoxarifes 570"

              @ prow()+1,0   say "Nome"
              @ prow()  ,pcol()  say chr(9)+"Total"
              @ prow()  ,pcol()  say chr(9)+"Coleta"
              @ prow()  ,pcol()  say chr(9)+"Expedicao"

              @ prow()+1,0 say ""
           endif

           @ prow()+1,00 say aResumo[nCONT,1]
           @ prow()  ,pcol() say chr(9)+transf(aResumo[nCONT,2],"@R 9999999")
           @ prow()  ,pcol() say chr(9)+transf(aResumo[nCONT,3],"@R 9999999")
           @ prow()  ,pcol() say chr(9)+transf(aResumo[nCONT,4],"@R 9999999")
           @ prow()+1,00 say aResumo[nCONT,1]
           @ prow()  ,pcol() say chr(9)+aResumo[nCONT,5]
           @ prow()  ,pcol() say chr(9)+aResumo[nCONT,6]
           @ prow()  ,pcol() say chr(9)+aResumo[nCONT,7]
           @ prow()+1,00 say ""


           nCONT++
           if nCONT > len(aResumo)
              nCONT := len(aResumo)
              exit
           endif

       enddo






return




static function qhmtoc ( nVALOR )
   local nMINUTO
   nMINUTO := nVALOR - int(nVALOR)
   nMINUTO := ( nMINUTO * 100 ) / 60
return int(nVALOR) + nMINUTO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONVERTER CENTESIMAL PARA HORA+MINUTO ________________________

static function qctohm ( nHORA )
   local nMINUTO
   nMINUTO := nHORA - int(nHORA)
   nMINUTO := ( nMINUTO * 60 ) / 100
   nMINUTO := round(nMINUTO,2)
   nHORA   := int(nHORA)
   if nMINUTO == .60
      nHORA++
      nMINUTO := 0
   endif
return nHORA + nMINUTO

static function HoraToNumerico(cValor)
local nHora   := 0
local nMinuto := 0

      nHora   := val(left(cValor,2))
      nMinuto := round(val(right(cValor,2)) / 100,2)

return nHora + nMinuto

static function NumericoToHora(nValor)
local cHora   := ""
local cMinuto := ""

      cHora   := strzero(int(nValor),4)
      cMinuto := right(str(nValor - int(nValor),4,2),2)

return cHora +":"+cMinuto


