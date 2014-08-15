/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: RELATORIO DE LOTES DIGITADOS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function ct517

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cTITULO                 // titulo do relatorio
private aEDICAO  := {}          // vetor para os campos de entrada de dados
private cCOD_LOTE:= space(10)
private nTOT     := 0
private nTOT1    := 0
private nTOTDB   := 0
private nTOTDB1  := 0
private nTOTCR   := 0
private nTOTCR1  := 0
private nTOTLO   := 0
private cLOTE_INI:= space(10)
private cLOTE_FIM:= space(10)
private lPRI     := .T.
set softseek off
LANC->(dbsetorder(5))
PLAN->(dbsetorder(3))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{||qgetx(-1,0,@cLOTE_INI      ,"@!") } , "LOTE_INI" })
aadd(aEDICAO,{{||qgetx(-1,0,@cLOTE_FIM      ,"@!") } , "LOTE_FIM" })

do while .T.

   qlbloc(5,0,"B517A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.
   LANC->(Dbgobottom())
   cLOTE_FIM:= LANC->Num_lote

   LANC->(Dbgotop())
   cLOTE_INI:= LANC->Num_lote

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

      case cCAMPO == "LOTE_INI"

         if  empty(cLOTE_INI) ; return .F. ; endif

      case cCAMPO == "LOTE_FIM"

         if  empty(cLOTE_FIM) ; return .F. ; endif

         if cLOTE_FIM < cLOTE_INI
            qmensa("O Lote Final n„o Pode ser Inferior ao Inicial")
            return .F.
         endif

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "RELACAO DE LOTES DIGITADOS"

   // SELECIONA ORDEM DO ARQUIVO LANC _______________________________________

   LANC->(dbgotop())

   LANC->(dbseek(cLOTE_INI))

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("Imprimindo...")

   cCOD_LOTE := LANC->Num_lote

   do while ! LANC->(eof()) .and. LANC->Num_lote >= cLOTE_INI .and. LANC->Num_lote <= cLOTE_FIM .and. qcontprn()   // condicao principal de loop

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @ prow(),pcol() say xcond1
         qpageprn()
         qcabecprn(cTITULO,137)
         @ prow()+2,0 say "Conta............  N.Lanc  C.Custo.. Filial Historico...................................................  Valor Debito..   Valor Credito."
         @ prow()+1,0 say replicate("-",137)
      endif

      if lPRI
         @ prow()+1,30 say "Inicio do lote N."+LANC->Num_lote+" - "+dtoc(LANC->Data_lanc)
         @ prow()+1,0  say ""
         lPRI := .F.
      endif
      qmensa("Imprimindo. Lote n§ " + LANC->Num_lote)

      if ! empty(LANC->Cont_db)
         @ prow()+1,00 say ct_convcod(ct_conv_re(LANC->Cont_db))+"  "+;
                           LANC->Num_lanc+"   "+ LANC->Centro+" "+LANC->Filial+"  "+;
                           left(LANC->Hist_comp,60)+"  "+transform(LANC->Valor,"@E 999,999,999.99")
         nTOTDB += LANC->Valor
      endif

      if ! empty(LANC->Cont_cr)
         @ prow()+1,00 say ct_convcod(ct_conv_re(LANC->Cont_cr))+"  "+;
                           LANC->Num_lanc+"   "+LANC->Centro+" "+LANC->Filial+"  "+;
                           left(LANC->Hist_comp,60)+"  "+ space(14)+"   "+transform(LANC->Valor,"@E 999,999,999.99")
         nTOTCR += LANC->Valor
      endif

      nTOT+= 1

      LANC->(dbskip())

      if  ! LANC->(eof()) .and. cCOD_LOTE <> LANC->Num_lote
          lote_dif()
      endif

   enddo
   if nTOT1 <> 0
      @ prow()+2,30 say "Total do lote "+cCOD_LOTE+":" +transform(nTOT, "@E 999")+;
                        " Lancamento(s)."+space(37)+transform(nTOTDB,"@E 999,999,999.99")+"   "+;
                        transform(nTOTCR,"@E 999,999,999.99")
      @ prow()+1,00 say replicate("-",137)
      @ prow()+1,30 say "Total de lancamentos:"+transform(nTOT1, "@E 999,999")+"      "+;
                        "Total de lotes :"+transform(nTOTLO, "@E 999,999")+space(17)+;
                        transform(nTOTDB1, "@E 9,999,999,999.99")+" "+;
                        transform(nTOTCR1, "@E 9,999,999,999.99")
   endif
   qstopprn()
   qmensa()

return



static function lote_dif                         // quando muda o codigo do lote
  @ prow()+2,30 say "Total do lote "+cCOD_LOTE+":" +transform(nTOT, "@E 999")+;
                    " Lancamento(s)."+space(37)+transform(nTOTDB,"@E 999,999,999.99")+"   "+;
                    transform(nTOTCR,"@E 999,999,999.99")
  @ prow()+1,00 say replicate("-",137)
  @ prow()+1,30 say "Inicio do lote N."+LANC->Num_lote+" - "+dtoc(LANC->Data_lanc)
  @ prow()+1,0  say ""

  nTOT1    += nTOT
  nTOTCR1  += nTOTCR
  nTOTDB1  += nTOTDB
  nTOTLO   += 1
  nTOT     := 0
  nTOTCR   := 0
  nTOTDB   := 0
  cCOD_LOTE:= LANC->Num_lote

return
