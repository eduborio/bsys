
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE TRIBUTOS FISCAIS
// ANALISTA...: LUIS ANTONIO
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........:
// ALTERACOES.:
function ef104

// CONFIGURACOES ____________________________________________________________

if !quse(XDRV_EF,"CONFIG") ; return ; endif
private cTRIB_SINC := CONFIG->Trib_Sinc
private cANOMES := CONFIG->Anomes
CONFIG->(dbclosearea())

// SE TRIBUTOS FOREM SINCRONIZADOS, PEGA DA E001 ____________________________

if cTRIB_SINC == "1"
   qsay(6,63,"* Sincronizado")
   if ! quse(XDRV_EFX,"TRIB",{"TRIB_COD","TRIB_DES"}) ; return ; endif
else
   if ! quse(XDRV_EF ,"TRIB",{"TRIB_COD","TRIB_DES"}) ; return ; endif
endif

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE TRIBUTOS FISCAIS____________________________________________

TRIB->(dbseek(cANOMES))

TRIB->(qview({{"Codigo/C¢digo"                       ,1},;
              {"Descricao/Descri‡„o"                 ,2},;
              {"transform(Aliquota,'@E 999.99')/Al¡q",0},;
              {"Dia_venc/Venc."                      ,0}},;
              "07002379",;
              {NIL,"i_104a","i_104b",NIL},;
              {"Anomes==cANOMES",{||dbseek(cANOMES)},{||qseekn(cANOMES)}},;
              q_msg_acesso_usr()+"/<R>ef."))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_104a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "R" ; i_muda_ref() ; endif

   if cOPCAO $ XUSRA
      qlbloc(9,12,"B104B","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// ATUALIZA TELA A CADA REFRESH _____________________________________________

function i_104b
   qsay(6,25,right(cANOMES,2))
   qsay(6,31,left(cANOMES,4))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MUDANCA DE ANO E MES DO TRIBUTO ______________________________

static function i_muda_ref

   local cMES := right(cANOMES,2)
   local cANO := left(cANOMES,4)

   qgetx(6,25,@cMES,"99")

   if val(cMES) >= 13
      qmensa("Mˆs de referˆncia est  errado !","B")
      return .F.
   endif

   qgetx(6,31,@cANO,"9999")

   cANOMES := strzero(val(cANO),4) + strzero(val(cMES),2)

   TRIB->(dbseek(cANOMES))

   if TRIB->(eof()) ; i_dup_trib() ; endif

   TRIB->(dbseek(cANOMES))

return

/////////////////////////////////////////////////////////////////////////////
// DUPLICACAO DE TRIBUTOS PARA OUTRO ANO.MES ________________________________

static function i_dup_trib

   local cANOMES2, cMES := cANO := "    "

   if alert("TRIBUTOS NŽO CADASTRADOS PARA ESTE ANO/MES",{"DUPLICAR","IGNORAR"}) == 1

      qmensa("Duplicar tributos de qual referˆncia (mes/ano)? ")

      qgetx(24,60,@cMES,"99")
      qsay(24,62,"/")
      qgetx(24,63,@cANO,"9999")

      cANOMES2 := strzero(val(cANO),4) + strzero(val(cMES),2)

      if qconf("Confirma duplicar tributos ?") ; ef_exec_dup(cANOMES2,cANOMES) ; endif

   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , TRIB->Codigo   , "@R 9999"  )
      qrsay ( XNIVEL++ , TRIB->Descricao, "@!"       )
      qrsay ( XNIVEL++ , TRIB->Aliquota , "@R 999.99")
      qrsay ( XNIVEL++ , TRIB->Dia_Venc , "@9"       )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@R 9999",NIL,cOPCAO=="I") } ,"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!"                     ) } ,"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQUOTA ,"@R 999.99"              ) } ,"ALIQUOTA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA_VENC ,"@9"                     ) } ,"DIA_VENC"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   TRIB->(qpublicfields())

   iif(cOPCAO=="I",TRIB->(qinitfields()),TRIB->(qcopyfields()))

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; TRIB->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if TRIB->(iif(cOPCAO=="I",qappend(),qrlock()))
      replace TRIB->Anomes    with cANOMES
      replace TRIB->Codigo    with fCODIGO
      replace TRIB->Descricao with fDESCRICAO
      replace TRIB->Aliquota  with fALIQUOTA
      replace TRIB->Dia_venc  with fDIA_VENC
      TRIB->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   local zTMP, nMES

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           qrsay(XNIVEL,fCODIGO:=strzero(val(fCODIGO),4))
           if TRIB->(dbseek(fCODIGO))
              qmensa("Tributo Fiscal j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "DIA_VENC"

           nMES := val(right(XANOMES,2))

           iif ( ++nMES == 13 , nMES := 1 , )

           zTMP := "01/" + strzero(nMES,2) + "/" + left(XANOMES,4)
           zTMP := qfimmes(ctod(zTMP))

           if val(fDIA_VENC) > day(zTMP)
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR TRIBUTOS FISCAIS______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o do Tributo Fiscal ?")
      if TRIB->(qrlock())
         TRIB->(dbdelete())
         TRIB->(qunlock())
      else
         qm3()
      endif
   endif

return
