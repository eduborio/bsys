/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE PONTO DE REPOSICAO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:
function es105

PROD->(qview({{"Codigo/C¢digo"               ,1},;
              {"Descricao/Descricao"         ,2},;
              {"transform(Quant_min, '@e 99999.9999')/Quant.Min" ,0}},"P",;
              {NIL,"c105a",NIL,NIL},;
              NIL,"<ESC>-Sai/<Q>uantidade"))


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c105a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "Q"
      qlbloc(11,9,"B105A","QBLOC.GLO",1)
      qmensa("<Pressione ESC para Cancela>")
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==3.and.!XFLAG).or.XNIVEL==3.and.Lastkey()==27.or.;
                       (XNIVEL==3.and.cOPCAO=="Q".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO ==  "Q"

      XNIVEL := 1

      qrsay ( XNIVEL++ , PROD->Codigo             )
      qrsay ( XNIVEL++ , left(PROD->Descricao,32) )
      qrsay ( XNIVEL++ , transform(PROD->Quant_min, "@E 99999.9999"))

   endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                },"CODIGO"     })
   aadd(aEDICAO,{{ || NIL                                                },"DESCRICAO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANT_MIN   ,"@E 99999.9999")         },"QUANT_MIN"   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   do while .T.

       PROD->(qpublicfields())

       if cOPCAO == "Q" ; PROD->(qcopyfields()) ; endif

       XNIVEL  := 1
       XFLAG   := .T.

       // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

       do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
          eval ( aEDICAO [XNIVEL,1] )
          if eval ( bESCAPE ) ; PROD->(qreleasefields()) ; return ; endif
          if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
          iif ( XFLAG , XNIVEL++ , XNIVEL-- )
       enddo

       // GRAVACAO ______________________________________________________________

       if ! lCONF ; return ; endif

       if PROD->(qrlock())

          PROD->(qreplacefields())
          exit

       else

          if cOPCAO=="Q" ; qm1() ; endif

       endif

       dbunlockall()

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

   endcase

return .T.

return
