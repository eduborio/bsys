/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: LANCAMENTOS DE COTA€™ES
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCIANO DA SILVA GORSKI
// INICIO.....: ABRIL DE 1998
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE COTACOES____________________________________________________

function cp110

COTACAO->(qview({{"Codigo/C¢digo\Cota‡„o"       ,1},;
                {"Data_Cad/Data Cadastro"  ,0}},"P",;
                {NIL,"i_110b",NIL,NIL},;
                NIL,q_msg_acesso_usr()+"/Im<P>rimir"))

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_110b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      if cOPCAO <> "P"
         qlbloc(05,00,"B110A","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
         i_edicao()
      endif
   elseif cOPCAO == "P"
      qlbloc(07,05,"B110B","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"P",{"Inprimir..."}))
      i_imprimir()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fdata_cad).or.(XNIVEL==1.and.!XFLAG).or.!empty(fdata_cad).and.Lastkey()==27}

   XNIVEL := 1

   if cOPCAO <> "I"
      qrsay ( XNIVEL++ , COTACAO->Codigo ,"@R 99999" )
      qrsay ( XNIVEL++ , COTACAO->Data_cad, "@D"     )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; lanc_produ(); return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                           } ,"CODIGO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_CAD, "@D" )                                 } ,"DATA_CAD"   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   COTACAO->(qpublicfields())
   iif(cOPCAO=="I",COTACAO->(qinitfields()),COTACAO->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; COTACAO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. COTACAO->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO PRODUTO __________________________________

      if cOPCAO == "I"
            replace CONFIG->Cod_cota with CONFIG->Cod_cota + 1
            qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_cota,5) )
            qmensa("C¢digo Gerado: "+fCODIGO)
      endif

      COTACAO->(qreplacefields())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

//  lCONF := qconf("Deseja lan‡ar produtos agora ?")

//  if lCONF
     lanc_produ()
     COTACAO->(Dbsetorder(1))
//  endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   do case
      case cCAMPO == "DATA_CAD"
      //     if ctod(space(8)) ; return .F. ; endif
           qrsay(XNIVEL,fDATA_CAD)
   endcase

return .t.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR COTACAO ______________________________________________

function i_exclusao

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR LANCAR PRODUTOS NA COTACAO ______________________________________________

ITENS_CT->(qview({{"Cod_Produt/C¢digo\Produto"                               ,1},;
                  {"e_110a()/Descri‡„o do Produto"                           ,0},;
                  {"Quantidade/Quantidade"                                   ,0}},;
                  "14002379S",;
                  {NIL,"e_deleta",NIL,NIL},;
                  {"ITENS_CT->CODIGO == COTACAO->Codigo",{||e201top()},{||e201bot()}},;
                  "Confirma exclus„o desta Cota‡„o? Pressione <E>cluir <ESC> Cancelar..."))

return ""
/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function e201top
   ITENS_CT->(dbsetorder(1))
   ITENS_CT->(dbseek(COTACAO->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function e201bot
   ITENS_CT->(dbsetorder(1))
   ITENS_CT->(qseekn(COTACAO->Codigo))
return


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO PRODUTO ___________________________________________

function e_110a
   PROD->(dbsetorder(4))
if PROD->(dbseek(ITENS_CT->Cod_produt))
   return left(PROD->descricao,30)
else
   return space(30)
endif

function e_deleta
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "E"
         if COTACAO->(qrlock())
            COTACAO->(dbdelete())
            ITENS_CT->(qflock())
          //  ITENS_CT->(dbgotop())
            do while ! ITENS_CT->(eof())
               if COTACAO->Codigo == ITENS_CT->Codigo
                  ITENS_CT->(dbdelete())
                  ITENS_CT->(dbskip())
               else
                  ITENS_CT->(dbskip())
               endif
            enddo
            COTACAO->(qunlock()); ITENS_CT->(qunlock())
            keyboard + chr(27)
            return
         else
            qm3()
         endif
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA LANCAR PRODUTOS NA COTACAO ______________________________________________

function Lanc_produ

ITENS_CT->(qview({{"Cod_Produt/C¢digo\Produto"                               ,1},;
                  {"L_110a()/Descri‡„o do Produto"                           ,0},;
                  {"Quantidade/Quantidade"                                   ,0}},;
                  "14002379S",;
                  {NIL,"l_110b",NIL,NIL},;
                  {"ITENS_CT->CODIGO == COTACAO->Codigo",{||a201top()},{||a201bot()}},;
                  "ESC-volta /<I>nclus„o /<A>ltera‡„o /<C>onsulta /<E>xclus„o"))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function a201top
   ITENS_CT->(dbsetorder(1))
   ITENS_CT->(dbseek(COTACAO->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function a201bot
   ITENS_CT->(dbsetorder(1))
   ITENS_CT->(qseekn(COTACAO->Codigo))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO PRODUTO ___________________________________________

function L_110a
   PROD->(dbsetorder(4))
if PROD->(dbseek(ITENS_CT->Cod_produt))
   return left(PROD->descricao,30)
else
   return space(30)
endif

// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function l_110b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      l_edicao()
      fCOD_PRODUT := space(5)
      fQUANTIDADE := space(5)
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function l_edicao

   local lCONF    := .F.
   local aEDICAOx := {}
   local bESCAPE  := {||empty(fCod_produt).or.(XNIVEL==5.and.!XFLAG)}

   if cOPCAO <> "I"
      PROD->(dbsetorder(4))
      qrsay ( 3 , right(ITENS_CT->Cod_produt,5) ,"@R 99999" ); PROD->(dbseek(right(ITENS_CT->Cod_produt,5)))
      qrsay ( 4 , left(PROD->Descricao,30)                  )
      qrsay ( 5 , ITENS_CT->Quantidade, "@R 999,999.9999"   )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; l_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAOx,{{ || NIL                                                       } , NIL         })
   aadd(aEDICAOx,{{ || view_produt(11,19,@fCOD_PRODUT , "@R 99999"        )      } ,"COD_PRODUT" })
   aadd(aEDICAOx,{{ || NIL                                                       } , NIL         })
   aadd(aEDICAOx,{{ ||       qgetx(13,19,@fQUANTIDADE , "@R 999,999.9999" )      } ,"QUANTIDADE" })

   aadd(aEDICAOx,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})


   // INICIALIZACAO DA EDICAO _______________________________________________

   ITENS_CT->(qpublicfields())
   iif(cOPCAO=="I",ITENS_CT->(qinitfields()),ITENS_CT->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAOx)
      eval ( aEDICAOx [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITENS_CT->(qreleasefields()) ; return ; endif
      if ! l_critica( aEDICAOx[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if ITENS_CT->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO PRODUTO __________________________________

      if cOPCAO == "I"
            qrsay ( 1 , fCODIGO := COTACAO->Codigo )
      endif

      ITENS_CT->(qreplacefields())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()
return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function l_critica ( cCAMPO )

   qmensa("")

   do case
      case cCAMPO == "COD_PRODUT"
           PROD->(dbsetorder(4))
           if empty(fCOD_PRODUT) ; return .F. ; endif
           if ! PROD->(dbseek(fCOD_PRODUT))
              qmensa("Codigo do produto n„o encontrado !","B")
              return .F.
           endif
           qrsay( 3,fCOD_PRODUT)
           qrsay( 4,left(PROD->Descricao,30))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS_CT ______________________________________________

static function l_exclusao
   if qconf("Confirma exclus„o deste Produto ?")
      if ITENS_CT->(qrlock())
         ITENS_CT->(dbdelete())
         ITENS_CT->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR COTACAO ______________________________________________

static function i_imprimir

   fCAMPO1 := space(5)
   fCAMPO2 := space(5)
/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

   Private lCONF   := .F.
   Private aEDICAO := {}
   Private XFLAG   := .F.
   Private bESCAPE := {||empty(fCAMPO1).or.(XNIVEL==1.and.!XFLAG)}

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_forn1(-1,0,@fCAMPO1 , "@R 99999"        )      } ,"CAMPO1" })
   aadd(aEDICAO,{{ || view_forn1(-1,0,@fCAMPO2 , "@R 99999"        )      } ,"CAMPO2" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma imprimir  ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITENS_CT->(qreleasefields()) ; return ; endif
      if ! p_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF; return; endif
     if cOPCAO == "P"
        imprime()
     endif

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function p_critica ( cCAMPO )

   qmensa("")

   do case
      case cCAMPO == "CAMPO1"
           FORN->(dbsetorder(1))
           if empty(fCAMPO1) ; return .F. ; endif
           if ! FORN->(dbseek(fCAMPO1))
              qmensa("Codigo do Fornecedor n„o encontrado !","B")
              return .F.
           endif
           qrsay( XNIVEL,fCAMPO1)

      case cCAMPO == "CAMPO2"
           if fCAMPO1 <= fCAMPO2
              FORN->(dbsetorder(1))
              if empty(fCAMPO2) ; return .F. ; endif
              if ! FORN->(dbseek(fCAMPO2))
                 qmensa("Codigo do Fornecedor n„o encontrado !","B")
                 return .F.
              endif
              qrsay( XNIVEL,fCAMPO2)
           else
              qmensa("Fornecedor Final deve ser maior ou igual h  Inicial...")
              fCAMPO2 := space(5)
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

function imprime

#define K_MAX_LIN 55

// CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "COTACAO DE PRODUTOS"

   if ! qinitprn() ; return ; endif

   FORN->(dbseek(fCAMPO1))

   do while ! FORN->(eof()) .and. FORN->Codigo <= fCAMPO2

         if ! qlineprn() ; exit ; endif

            qpageprn()
            qcabecprn(cTITULO,80)
            @ prow()+1,0 say "Fornecedor.:"
            @ prow() ,14 say  left(FORN->Razao,30)
            @ prow() ,60 say "Codigo.......:"
            @ prow() ,75 say  FORN->Codigo
            @ prow()+1,0 say "CGC\CPF....:"
            @ prow() ,14 say  FORN->cgccpf
            @ prow() ,60 say "Cod.Cotacao..:"
            @ prow() ,75 say  COTACAO->Codigo
            @ prow()+1,0 say replicate("-",80)
            @ prow()+1,0 say "CODIG.DESCRICAO                     QTD.UNIT. VAL.UNIT. DESC.  IPI%  ICMS% TOTAL"
            @ prow()+1,0 say replicate("-",80)
            @ prow()+1,0 say ""

           ITENS_CT->(dbgotop())

      do while ! ITENS_CT->(eof())

         if COTACAO->Codigo == ITENS_CT->Codigo
            qmensa("Imprimindo Cota‡”es...: " + ITENS_CT->Codigo)

            @ prow()+1,0  say ITENS_CT->Cod_produt ; PROD->(dbseek(right(ITENS_CT->Cod_produt,5)))
            @ prow() ,06  say left(e_110a(),28)
            @ prow() ,35  say transform(ITENS_CT->quantidade,"@R 9,999.9999")
            @ prow() ,47  say "________"
            @ prow() ,56  say "______"
            @ prow() ,63  say "_____"
            @ prow() ,69  say "_____"
            @ prow() ,75  say "_____"

         endif

         ITENS_CT->(dbskip())

      enddo

      @ prow()+1,0  say ""
      @ prow()+1,0  say "Data de Retorno..: ___/___/___."
      @ prow()  ,59 say "Total---->"
      @ prow()  ,75 say "_____"
      @ prow()+1, 0 say ""

      FORN->(dbskip())

   enddo
   qstopprn()

return

