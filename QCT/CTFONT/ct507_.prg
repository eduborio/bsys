/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: EMISSAO DO CADASTRO DE TIPOS CONTABEIS
// ANALISTA...:
// PROGRAMADOR: ANDERSON EDUARDO DE LIMA
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function ct507

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1 := qlbloc("B507B","QBLOC.GLO") // tipo de impressao
private sBLOCO2 := qlbloc("B507C","QBLOC.GLO") // ordem de impressao

private cTITULO                // titulo do relatorio
private cORDEM  := "1"         // ordem de impressao (Codigo/Descricao)
private cTIPO   := "1"         // tipo de impressao (Sintetico/Analitico)
private aEDICAO := {}          // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOCO1) } , "TIPO"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO2) } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B507A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.

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
      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"Sint‚tico","Anal¡tico"}))
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cORDEM,"12",{"C¢digo","Descric„o"}))

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "RELACAO DO CADASTRO TIPOS CONTABEIS "

   // SELECIONA ORDEM DO ARQUIVO CCUSTO _____________________________________

   if cORDEM == "1"
      TIPOCONT->(dbsetorder(1)) // codigo
   elseif cORDEM == "2"
      TIPOCONT->(dbsetorder(2)) // descricao
   endif

   if cTIPO  == "1"
      cTITULO += "SINTETICO"
   elseif cTIPO  == "2"
      cTITULO += "ANALITICO"
   endif

   TIPOCONT->(dbgotop())
   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   do while ! TIPOCONT->(eof()) .and. qcontprn()     // condicao principal de loop

      do case
         case cORDEM == "1"
              qmensa(transform(TIPOCONT->Codigo,'@R 99.9999')+" / "+alltrim(TIPOCONT->Descricao))
         case cORDEM == "2"
              qmensa(alltrim(TIPOCONT->Descricao)+" / "+transform(TIPOCONT->Codigo,'@R 99.9999'))
      endcase

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         do case
            case cORDEM == "1" .and. cTIPO == "1"
                                 //123456 123456789012345678901234567890123456789012345678901234567890
                 @ prow()+1,0 say "Cod....  Descricao......................................."
                 @ prow()+1,0         say replicate("-",80)
            case cORDEM == "2" .and. cTIPO == "1"
                 @ prow()+1,0 say "Descricao.........................................  Cod...."
                 @ prow()+1,0         say replicate("-",80)
            case cORDEM == "1" .and. cTIPO == "2"
            case cORDEM == "2" .and. cTIPO == "2"
         endcase

      endif

      do case
         case cORDEM == "1" .and. cTIPO == "1"
           if len(alltrim(TIPOCONT->Codigo)) == 2
              @ prow()+1,0 say XAENFAT+c507b(1)+XDENFAT
           else
              @ prow()+1,0 say c507b(1)       //Funcao para expansao da arvore
           endif
         case cORDEM == "2" .and. cTIPO == "1"
           if len(alltrim(TIPOCONT->Codigo)) == 2
              @ prow()+1,0 say XAENFAT+c507b(2)+XDENFAT
           else
              @ prow()+1,0 say c507b(2)       //Funcao para expansao da arvore
           endif



         case cORDEM == "1" .and. cTIPO == "2" .or. cORDEM == "2" .and. cTIPO == "2"
           if len(alltrim(TIPOCONT->Codigo)) == 2
              @ prow()+1,0 say XAENFAT+transform(TIPOCONT->Codigo,'@R 99.9999')+"   Descricao: "+TIPOCONT->Descricao+XDENFAT

           else
              @ prow()+1,0 say ""
              @ prow()+1,0 say transform(TIPOCONT->Codigo,'@R 99.9999')+"   Descricao: "+TIPOCONT->Descricao
              @ prow()+1,0 say "Motivo: "+c507c(1)+"     Nota fiscal: "+c507c(2)+"     Aviso de Cob.: "+c507c(3)
              @ prow()+1,0 say "Regime: "+c507c(4)
              @ prow()  ,0 say replicate("_",80)

              if TIPOCONT->Regime_ope == "2"        //Regime de Caixa
                @ prow()+1,0 say "Conta provisao (D) : "+ct_convcod(TIPOCONT->Ct_ct_p_dv)+"                        Conta provisao (C) : "+ct_convcod(TIPOCONT->Ct_ct_p_cr)
                @ prow()+1,0 say "Hist. do Lanc. de Provisao: "+TIPOCONT->Hist_l_pr
                @ prow()+1,0 say "Hist. do Lanc. de liquidacao (Pgto.): "+TIPOCONT->Hist_l_1
                @ prow()+1,0 say "Hist. do Lanc. de liquidacao (Rec.): "+TIPOCONT->Hist_l_2

              elseif TIPOCONT->Regime_ope == "1"    //Regime de Competencia
                @ prow()+1,0 say "Conta liquidacao : "+c507c(5)
                @ prow()+1,0 say "Conta : "+ct_convcod(TIPOCONT->Ct_ct_liq)
                @ prow()+1,0 say "Historico do lancamento de liquidacao (Pgto.): "+TIPOCONT->hi_l_liq1
                @ prow()+1,0 say "Historico do lancamento de liquidacao (Rec.): "+TIPOCONT->hi_l_liq2
              endif
              c507d()       // funcao p/ imprimir 2§ tela do cad.
           endif

           @ prow()+1,0         say replicate("-",80)

      endcase

      TIPOCONT->(dbskip())

   enddo

   qstopprn()
   qmensa()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESLOCAR EM ARVORE A DESCRICAO DOS TIPOS CONTABEIS____________

function c507b(nTIP)
   local cDESCRICAO := TIPOCONT->Descricao + "    "

   if     len(alltrim(TIPOCONT->Codigo)) == 2 ; cDESCRICAO := TIPOCONT->Descricao
   elseif len(alltrim(TIPOCONT->Codigo)) == 6 ; cDESCRICAO := "  "+TIPOCONT->Descricao
   endif

   if     nTIP == 1  // Codigo + Descricao
       return transform(TIPOCONT->Codigo,'@R 99.9999')+"  "+cDESCRICAO
   elseif nTIP == 2  // Descricao + Codigo
       return TIPOCONT->Descricao+"  "+transform(TIPOCONT->Codigo,'@R 99.9999')
   elseif nTIP == 3  // Codigo + Descricao30
       return transform(TIPOCONT->Codigo,'@R 99.9999')+" "+left(cDESCRICAO,30)
   elseif nTIP == 4  // Descricao30 + Codigo
       return left(TIPOCONT->Descricao,30)+" "+transform(TIPOCONT->Codigo,'@R 99.9999')
   endif


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXPANDIR OS CODIGOS___________________________________________

function c507c(nMOD)
if nMOD == 1       //Motivo
  if TIPOCONT->Motivo == "1"
    return("Recolhimento")
  elseif TIPOCONT->Motivo == "2"
    return("Pagamento   ")
  elseif TIPOCONT->Motivo == "3"
    return("Ambos       ")
  else
    return("Nao Consta  ")
  endif

elseif nMOD == 2   //Nota fiscal
  if TIPOCONT->Nota_fisc == "1"
    return("Obrigatoria")
  elseif TIPOCONT->Nota_fisc == "2"
    return("Facultativa")
  endif

elseif nMOD == 3   //Aviso de Cobranca
  if TIPOCONT->Aviso_cob == "1"
    return("Obrigatorio")
  elseif TIPOCONT->Aviso_cob == "2"
    return("Facultativo")
  endif

elseif nMOD == 4   //Regime da operacao
  if TIPOCONT->Regime_ope == "1"
    return("Caixa      ")
  elseif TIPOCONT->Regime_ope == "2"
    return("Competencia")
  endif

elseif nMOD == 5   //Conta liquidacao
  if TIPOCONT->Conta_liq == "1"
    return("Informada ")
  elseif TIPOCONT->Conta_liq == "2"
    return("C.Auxiliar")
  endif

else               //Se nao informado o numereo correto
  return("Rotina nao implementada")
endif

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESPANDIR A  2§ TELA DO CADASTRO_______________________________

function c507d()
local nCONT := 1

do while nCONT <= 13
   if !empty(TIPOCONT->&("Hi_comp"+alltrim(str(nCONT))))
     @ prow()+1, 00 say "Hist.: "+TIPOCONT->&("Hi_comp"+alltrim(str(nCONT)))+" Conta Cont.: "+;
                        iif(TIPOCONT->&("Ct_liq_"+alltrim(str(nCONT))) == "1","Informada","Cad.Aux. ")+;
                        " Conta: "+ct_convcod(TIPOCONT->&("Ct_comp"+alltrim(str(nCONT))))+" F.Contabil: "

     if TIPOCONT->&("Fu_comp"+alltrim(str(nCONT))) == "1"
        @ prow(), pcol() say "Ded.da Partida"
     elseif TIPOCONT->&("Fu_comp"+alltrim(str(nCONT))) == "2"
        @ prow(), pcol() say "Ded. C.Partida"
     elseif TIPOCONT->&("Fu_comp"+alltrim(str(nCONT))) == "3"
        @ prow(), pcol() say "Correcao      "
     elseif TIPOCONT->&("Fu_comp"+alltrim(str(nCONT))) == "4"
        @ prow(), pcol() say "Debito        "
     elseif TIPOCONT->&("Fu_comp"+alltrim(str(nCONT))) == "5"
        @ prow(), pcol() say "Credito       "
     elseif TIPOCONT->&("Fu_comp"+alltrim(str(nCONT))) == "6"
        @ prow(), pcol() say "Acr. de Liq.  "
     elseif TIPOCONT->&("Fu_comp"+alltrim(str(nCONT))) == "7"
        @ prow(), pcol() say "Decr.de Liqu. "
     endif

   else
     return

   endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      qcabecprn(cTITULO,80)
   endif

   nCONT++

enddo
