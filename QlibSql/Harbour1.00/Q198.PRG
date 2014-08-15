// MANUTENCAO GERAL DE CADASTRO GERAL DE MUNICIPIOS
// LUIS ANTONIO - NOVEMBRO DE 1994

function q198

if ! quse(XDRV_SH,"CGM",{"CGM_COD","CGM_MUN"}) ; return .F. ; endif

CGM->(qview({{"Codigo/C¢digo"                        ,1},;
             {"Municipio"                            ,2},;
             {"Estado"                               ,0},;
             {"transform(Cep,'@R 99.999-999')/C.e.p.",0},;
             {"DDD"                                  ,0}},;
             "P",;
             {NIL,"c198a",NIL,NIL},;
             NIL,;
             "<ESC>, ALT-O, ALT-P, <I>nc, <A>lt, <C>on, <E>xc" ))

CGM->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c198a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA + "IACE"
      qlbloc(13,11,"B198A",XDRV_SH+"QSBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , CGM->Codigo    )
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->EStado    )
      qrsay ( XNIVEL++ , CGM->Cep , "@R 99.999-999" )
      qrsay ( XNIVEL++ , CGM->Ddd       )
      qrsay ( XNIVEL++ , CGM->Distancia , "9999" )
      qrsay ( XNIVEL++ , CGM->Cod_rais  )
      qrsay ( XNIVEL++ , CGM->Cod_icms  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ;  qwait()     ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!",NIL,cOPCAO=="I")}  ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMUNICIPIO,"@!") }                 ,"MUNICIPIO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fESTADO   ,"@!") }                 ,"ESTADO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP,"@R 99.999-999") }            ,"CEP"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDDD      ,"@9") }                 ,"DDD"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDISTANCIA,"9999")}                ,"DISTANCIA"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_RAIS ,"@!") }                 ,"COD_RAIS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_ICMS ,"@!") }                 ,"COD_ICMS" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CGM->(qpublicfields())
   iif(cOPCAO=="I",CGM->(qinitfields()),CGM->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CGM->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CGM->(iif(cOPCAO=="I",qappend(),qrlock()))
      CGM->(qreplacefields())
      CGM->(qunlock())
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
           if CGM->(dbseek(fCODIGO))
              qmensa("C¢digo j  cadastrado !","B")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR MUNICIPIO ____________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste municipio ?")
      if CGM->(qrlock())
         CGM->(dbdelete())
         CGM->(qunlock())
      else
         qm3()
      endif
   endif
return
