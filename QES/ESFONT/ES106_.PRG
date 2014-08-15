/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE LOCALIZACAO DOS PRODUTOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:
function es106

PROD->(qview({{"left(Cod_fabr,7)/Cod. Fabr." ,5},;
              {"left(Cod_ass,7)/Cod. Assoc." ,3},;
              {"left(Descricao,20)/Descricao",2},;
              {"Corredor/Corredor"           ,0},;
              {"Estante/Estante"             ,0},;
              {"Prateleira/Prateleira"       ,0}},"P",;
              {NIL,"c106a",NIL,NIL},;
              NIL,"<ESC>-Sai/<L>ocaliza‡„o"))


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c106a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "L"
      qlbloc(11,9,"B106A","QBLOC.GLO",1)
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
                       (XNIVEL==3.and.cOPCAO=="L".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO ==  "L"

      XNIVEL := 1

      qrsay ( XNIVEL++ , PROD->Codigo             )
      qrsay ( XNIVEL++ , left(PROD->Descricao,32) )
      qrsay ( XNIVEL++ , PROD->Corredor           )
      qrsay ( XNIVEL++ , PROD->Estante            )
      qrsay ( XNIVEL++ , PROD->Prateleira         )
      qrsay ( XNIVEL++ , PROD->Corredor2          )
      qrsay ( XNIVEL++ , PROD->Estante2           )
      qrsay ( XNIVEL++ , PROD->Prateleir2         )


   endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                },"CODIGO"     })
   aadd(aEDICAO,{{ || NIL                                                },"DESCRICAO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCORREDOR   ,"@!")                     },"CORREDOR"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fESTANTE    ,"@!")                     },"ESTANTE"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRATELEIRA ,"@!")                     },"PRATELEIRA" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCORREDOR2   ,"@!")                     },"CORREDOR2"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fESTANTE2    ,"@!")                     },"ESTANTE2"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRATELEIR2 ,"@!")                     },"PRATELEIR2" })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   do while .T.

       PROD->(qpublicfields())

       if cOPCAO == "L" ; PROD->(qcopyfields()) ; endif

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

          if cOPCAO=="L" ; qm1() ; endif

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
