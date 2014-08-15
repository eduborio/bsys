/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: TABELA DE PRECOS - HOSPITALAR
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: SETEMBRO DE 1998
// OBS........:
// ALTERACOES.:

function cl105
PROD->(Dbsetorder(4))

TAB->(qview({{"Cod_prod/Codigo"                  ,1},;
             {"Cod_ass/Assoc."                   ,2},;
             {"c105b()/Produto"                  ,0},;
             {"transform(Preco_sus, '@e 99,999.99')/SUS" ,0},;
             {"transform(Preco_part, '@e 99,999.99')/Particular" ,0},;
             {"transform(Preco_loc, '@e 99,999.99')/Locacao" ,0}},"P",;
             {NIL,"c105a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO ______________________________

function c105b
  PROD->(dbseek(TAB->Cod_prod))
return left(PROD->Descricao,30)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c105a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(10,5,"B105A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCOD_PROD).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO $ "AC"

      XNIVEL := 1

      qrsay ( XNIVEL++ , TAB->Cod_prod                     ) ; PROD->(Dbseek(TAB->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)          )
      qrsay ( XNIVEL++ , TAB->Cod_ass                      )
      qrsay ( XNIVEL++ , TAB->Preco_sus  , "@E 999,999.99" )
      qrsay ( XNIVEL++ , TAB->Preco_part , "@E 999,999.99" )
      qrsay ( XNIVEL++ , TAB->Preco_loc  , "@E 999,999.99" )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_ASS)                         },"COD_ASS"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_SUS,"999,999.99")          },"PRECO_SUS"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_PART,"999,999.99")         },"PRECO_PART"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_LOC,"999,999.99")          },"PRECO_LOC"   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   TAB->(qpublicfields())

   iif(cOPCAO=="I",TAB->(qinitfields()),TAB->(qcopyfields()))

   iif( cOPCAO == "A" , XNIVEL := 3 , XNIVEL  := 1)
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; TAB->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if TAB->(iif(cOPCAO=="I",qappend(),qrlock()))
      TAB->(qreplacefields())
   endif

   dbunlockall()

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "COD_PROD"
           if ! empty(fCOD_PROD) .and. cOPCAO == "I"
              if ! PROD->(dbseek(fCOD_PROD:=strzero(val(fCOD_PROD),5)))
                 qmensa("Produto n„o encontrado !","B")
                 return .F.
              else
                 if TAB->(dbseek(fCOD_PROD))
                    qmensa("Produto j  existe na Tabela. Verifique !","B")
                    return .F.
                 endif
                 qrsay(XNIVEL+1,left(PROD->Descricao,30))
                 fCOD_ASS := PROD->Cod_ass
              endif

           endif
   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR PRODUTOS DA TABELA __________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Produto da Tabela ?")
      if TAB->(qrlock())
         TAB->(dbdelete())
         TAB->(qunlock())
      else
         qm3()
      endif
   endif
return
