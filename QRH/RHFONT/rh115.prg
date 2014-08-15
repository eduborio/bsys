/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE CBO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: 2005
// OBS........:
// ALTERACOES.:

COD_SAQ->(qview({{"Codigo/C¢digo"      ,1},;
             {"Benef/Beneficiario",0},;
             {"left(Espec1,35)/Especificacao",0}},"P",;
             {NIL,"c115a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c115a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(12,3,"B115A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fCODIGO) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , COD_SAQ->Codigo    )
      qrsay ( XNIVEL++ , COD_SAQ->Benef     )
      qrsay ( XNIVEL++ , COD_SAQ->Espec1    )
      qrsay ( XNIVEL++ , COD_SAQ->Espec2    )
      qrsay ( XNIVEL++ , COD_SAQ->Espec3    )
      qrsay ( XNIVEL++ , COD_SAQ->Espec4    )
      qrsay ( XNIVEL++ , COD_SAQ->Espec5    )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"99",NIL,cOPCAO=="I") }    ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBENEF,"@!"     ,NIL,.T.        ) }  , "BENEF"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fESPEC1,"@!"             ) }  , "ESPEC1"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fESPEC2,"@!"             ) }  , "ESPEC2"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fESPEC3,"@!"             ) }  , "ESPEC3"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fESPEC4,"@!"             ) }  , "ESPEC4"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fESPEC5,"@!"             ) }  , "ESPEC5"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   COD_SAQ->(qpublicfields())
   iif(cOPCAO=="I",COD_SAQ->(qinitfields()),COD_SAQ->(qcopyfields()))
       XNIVEL := 1
       XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )

      if eval ( bESCAPE ) ; COD_SAQ->(qreleasefields()) ; return ; endif

      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif

      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if COD_SAQ->(iif(cOPCAO=="I",qappend(),qrlock()))
      COD_SAQ->(qreplacefields())
      COD_SAQ->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"

//           if COD_SAQ->(dbseek(fCODIGO))
//              qmensa("C.B.O. j  cadastrado !","B")
//              return .F.
//           endif
      endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR C.B.O. _______________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste c.b.o. ?")

      if COD_SAQ->(qrlock())
         COD_SAQ->(dbdelete())
         COD_SAQ->(qunlock())
      else
         qm3()
      endif
   endif
return

