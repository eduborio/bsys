 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE ENTRADAS DE PRODUTOS ACABADOS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: AGOSTO DE 1999
// OBS........:
// ALTERACOES.:
function es210

private lOK := .F.
PROD->(dbsetorder(4))

ENT_ACA->(qview({{"Data/Data"                    ,1},;
                 {"c210b()/Produto"              ,2},;
                 {"Lote/Lote"                    ,0},;
                 {"Quantidade/Quantidade"        ,0}},"P",;
                 {NIL,"c210c",NIL,NIL},;
                  NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DA FILIAL ________________________________

function c210a
  CLI1->(dbseek(ENT_ACA->(Cod_cli)))
return left(CLI1->Razao,20)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO PRODUTO _______________________________

function c210b
  PROD->(dbseek(ENT_ACA->(Cod_Prod)))
return left(PROD->Descricao,16)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c210c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "I*E*C"
      qlbloc(6,6,"B210A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   if cOPCAO == "P"
      i_impressao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local cFATOR  := 1
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==1.and.!XFLAG).or.!empty(fDATA).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , ENT_ACA->Data       )
      qrsay ( XNIVEL++ , ENT_ACA->Filial     ) ; FILIAL->(dbseek(ENT_ACA->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,30))
      qrsay ( XNIVEL++ , ENT_ACA->Cod_prod   ) ; PROD->(dbseek(ENT_ACA->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40))
      qrsay ( XNIVEL++ , ENT_ACA->Quantidade )
      qrsay ( XNIVEL++ , ENT_ACA->Lote )
      qrsay ( XNIVEL++ , ENT_ACA->Obs )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif
   if cOPCAO == "P" ; i_impressao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA         ,"@D")                    },"DATA"       })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"     })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })

   aadd(aEDICAO,{{ || view_prod1(-1,0,@fCOD_PROD)                          },"COD_PROD"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE    ,"999999")          },"QUANTIDADE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLOTE   ,"@!")                      },"LOTE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS    ,"@!")                          },"OBS" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ENT_ACA->(qpublicfields())
   iif(cOPCAO=="I",ENT_ACA->(qinitfields()),ENT_ACA->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ENT_ACA->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if ENT_ACA->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      //ENT_ACA->(qreplacefields())
      if cOPCAO == "I"

         INVENT->(dbsetorder(1))
         if INVENT->(Dbseek(fFilial+fCod_prod+"0000000000")) .and. INVENT->(qrlock())

            ACABADO->(dbsetorder(1))
            ACABADO->(dbgotop())

            if ! ACABADO->(Dbseek(fCod_prod))
               qmensa("N„o existe este Produto Acabado !","B")
               return .F.
            else
               replace INVENT->Quant_atu    with ( INVENT->Quant_atu  + fQuantidade )
            endif

            INVENT->(qunlock())

         else
            if INVENT->(Qappend()) .and. INVENT->(Qrlock())
               ACABADO->(dbsetorder(1))
               ACABADO->(dbgotop())

               if ! ACABADO->(Dbseek(fCod_prod))
                  qmensa("N„o existe este Produto Acabado !","B")
                  return .F.
               else
                  replace INVENT->Filial       with fFILIAL
                  replace INVENT->Data         with fDATA
                  replace INVENT->Cod_prod     with fCOD_PROD
                  replace INVENT->Quantidade   with fQUANTIDADE
                  replace INVENT->Quant_atu    with fQuantidade
                  replace INVENT->Preco_uni    with 0
                  replace INVENT->Quant_min    with 0
                  replace INVENT->Lote         with "0000000000"
               endif
               INVENT->(Qunlock())
            endif
         endif

         ITEN_ACA->(dbsetorder(1))
         ITEN_ACA->(dbgotop())
         ITEN_ACA->(dbseek(ACABADO->Codigo))

         do while ! ITEN_ACA->(eof()) .and. ITEN_ACA->Cod_aca == ACABADO->Codigo
            INVENT->(dbsetorder(4))
            if INVENT->(Dbseek(right(ITEN_ACA->Produto,5))) .and. INVENT->(qrlock())
               replace INVENT->Quant_atu    with ( INVENT->Quant_atu  - (ITEN_ACA->Quantidade * fQuantidade))
            endif

            INVENT->(qunlock())

            ITEN_ACA->(dbskip())

         enddo

      endif
      ENT_ACA->(qreplacefields())
   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qrsay(XNIVEL,fFILIAL)

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,30))

      case cCAMPO == "COD_PROD"

           if empty(fCOD_PROD) ; return .F. ; endif
           qrsay(XNIVEL,fCOD_PROD)

           if ! ACABADO->(dbseek(fCOD_PROD:=strzero(val(fCOD_PROD),5)))
              qmensa("Produto acabado n„o encontrado !","B")
              return .F.
           endif
           PROD->(dbseek(ACABADO->Codigo))
           qrsay(XNIVEL+1,left(PROD->Descricao,40))

      case cCAMPO == "QUANTIDADE"
           if empty(fQUANTIDADE) ; return .F. ; endif
           lOK := .T.
           ITEN_ACA->(dbsetorder(1))
           ITEN_ACA->(dbgotop())
           ITEN_ACA->(dbseek(fCOD_PROD))

           do while ! ITEN_ACA->(eof()) .and. ITEN_ACA->Cod_aca == fCOD_PROD
              INVENT->(dbsetorder(4))
              if INVENT->(Dbseek(right(ITEN_ACA->Produto,5)))
                 if (fQUANTIDADE*ITEN_ACA->Quantidade) > INVENT->Quant_atu
                    lOK := .F.
                 endif
              endif

              ITEN_ACA->(dbskip())
           enddo

           if lOK == .F.
             qmensa("Estoque insufuciente p/ compor este produto!")
             return .F.
           endif

      case cCAMPO == "LOTE"

           if empty(fLOTE)
              fLOTE := "0000000000"
              qrsay(XNIVEL,fLOTE)
           else
              fLOTE := strzero(val(fLOTE),10)
              qrsay(XNIVEL,fLOTE)
           endif

//           INVENT->(Dbsetorder(1))
//           if INVENT->(dbseek(fFILIAL+fCOD_PROD+fLOTE))
//              qmensa("Este N£mero de Lote ja existe para este produto...","B")
//              fLOTE := "          "
//              return .F.
//           endif



   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ENTRADA ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Entrada ?")
      if ENT_ACA->(qrlock())
         PROD->(Dbsetorder(4))
         INVENT->(dbsetorder(1))
         if INVENT->(Dbseek(ENT_ACA->Filial+ENT_ACA->Cod_prod+"0000000000")) .and. INVENT->(qrlock())
            replace INVENT->Quant_atu    with ( INVENT->Quant_atu  - ENT_ACA->Quantidade )
         endif

         ACABADO->(dbsetorder(1))
         ACABADO->(dbgotop())

         ACABADO->(Dbseek(ENT_ACA->Cod_prod))

         ITEN_ACA->(dbsetorder(1))
         ITEN_ACA->(dbgotop())
         ITEN_ACA->(dbseek(ACABADO->Codigo))

         do while ! ITEN_ACA->(eof()) .and. ITEN_ACA->Cod_aca == ACABADO->Codigo
            INVENT->(Dbsetorder(4))
            if INVENT->(Dbseek(right(ITEN_ACA->Produto,5))) .and. INVENT->(qrlock())
               replace INVENT->Quant_atu    with ( INVENT->Quant_atu  + (ITEN_ACA->Quantidade*ENT_ACA->Quantidade ))
            endif

            INVENT->(qunlock())

            ITEN_ACA->(dbskip())

         enddo

         ENT_ACA->(dbdelete())
         INVENT->(qunlock())
         ENT_ACA->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_impressao
   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0

   cTITULO := "ORDEM DE PRODUCAO No."+ENT_ACA->Num_ord+"   Data.: "+dtoc(ENT_ACA->Data)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,80)
      CLI1->(Dbseek(ENT_ACA->Cod_cli))
      ACABADO->(dbseek(ENT_ACA->Cod_prod))
      @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + CLI1->Razao
      @ prow()+1,0 say "Fantasia: "+CLI1->Fantasia
      @ prow()+1,0 say "Endereco: "+ CLI1->End_cob
      @ prow()+1,0 say "Produto.: "+ ACABADO->Desc_acab
      @ prow()+1,0 say "Quantidade a Produzir: "+transf(ENT_ACA->Quantidade,"@E 9999999")
      @ prow()+1,0 say "Codigo da Cor: "+ENT_ACA->Cod_cor + "  Cor.: " + ENT_ACA->Cor + "Telefone: "+ CLI1->Fone1

      @ prow()+1,0 say replicate("-",80)
   endif

   @ prow()+1,0 say "Produto                                                        Quantidade"
   @ prow()+1,0 say replicate("-",80)

   ITEN_ACA->(Dbseek(ENT_ACA->Cod_prod))

   do while ! ITEN_ACA->(eof()) .and. ITEN_ACA->Cod_aca == ACABADO->Codigo

      PROD->(Dbseek(right(ITEN_ACA->produto,5)))
      @ prow()+1,0   say PROD->Descricao
      @ prow()  ,60  say transform(ITEN_ACA->Quantidade*ENT_ACA->Quantidade, "@E 999999.999")

      ITEN_ACA->(Dbskip())

   enddo

   @ prow()+1,0 say replicate("-",80)

   qstopprn()
return

