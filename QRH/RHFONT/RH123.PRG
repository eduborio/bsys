
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE VINCULACAO DE KITS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

// ESCOLHE O NIVEL DA VINCULACAO ____________________________________________

local sBLOC := qlbloc("B123B","QBLOC.GLO")
private cVINC

SITUA->(dbSetFilter({|| Anomes == XANOMES .and. Situacao != 'H'},"Anomes == XANOMES .and. Situacao != 'H'"))

do while .T.
   qlbloc(5,0,"B123A","QBLOC.GLO")
   if empty(cVINC := qachoice(10,27,sBLOC,cVINC,1)) ; return ; endif
   i_view_arq(cVINC)
enddo

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR VIEW INICIAL NO ARQUIVO DE VINCULACAO ESCOLHIDO _____

static function i_view_arq
   local cMENSA := "<ESC> / <ALT-O> / <ALT-P>"

   iif("A"$XUSRA,cMENSA+=" / <A>lterar",NIL)
   iif("C"$XUSRA,cMENSA+=" / <C>onsultar",NIL)

   do case
      case cVINC == "1" ; select CONFIG ; i_123a(65)
      case cVINC == "2" ; CCUSTO->(qview({{"transform(Codigo,'@R 99.99.9999')/C¢digo",1},{"Descricao/Centro de Custo",2},{"i123x()/Kit's",0}},"P",{NIL,"i_123a",NIL,NIL},NIL,cMENSA))
      case cVINC == "3" ; FILIAL->(qview({{"Codigo/C¢digo",1},{"left(Razao,30)/Filial",2},{"i123x()/Kit's",0}},"P",{NIL,"i_123a",NIL,NIL},NIL,cMENSA))
      case cVINC == "4" ; SIND->(qview({{"Codigo/C¢digo",1},{"Descricao/Sindicato",2},{"i123x()/Kit's",0}},"P",{NIL,"i_123a",NIL,NIL},NIL,cMENSA))
      case cVINC == "5" ; CARGO->(qview({{"Codigo/C¢digo",1},{"Descricao/Cargo",2},{"i123x()/Kit's",0}},"P",{NIL,"i_123a",NIL,NIL},NIL,cMENSA))
      case cVINC == "6" ; SITUA->(qview({{"Matricula",1},{"i123q()/Nome",0},{"i123x()/Kit's",0}},"P",{NIL,"i_123a",NIL,NIL},NIL,cMENSA))
   endcase

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NO VIEW O NOME DO FUNCIONARIO ________________________

function i123q
   select SITUA
   SITUA->(dbgoto(recno()))
   FUN->(dbseek(SITUA->Matricula))
return(left(FUN->Nome,30))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NO VIEW SE EXISTE VINCULACAO DE KIT __________________

function i123x
return(Kit_i_ms+Kit_e_ms+Kit_i_fr+Kit_e_fr+Kit_i_ad+Kit_e_ad+Kit_i_dt+Kit_e_dt )

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EDITAR AS VINCULACOES DOS KITS _______________________________

function i_123a
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   FUN->(dbseek(SITUA->MATRICULA))
   if cOPCAO $ XUSRA .and. cOPCAO $ "AC"
      setcursor(1)
      qlbloc(5,0,"B123C","QBLOC.GLO")
      do case
         case cVINC == "1" ; qsay(7,3,"Vincula‡„o de Kits para a Empresa !")
                             qsay(8,3,XRAZAO)
         case cVINC == "2" ; qsay(7,3,"Centro.....: "+transform(Codigo,"@R 99.99.9999"))
                             qsay(8,3,"Descri‡„o..: "+Descricao)
         case cVINC == "3" ; qsay(7,3,"Filial.....: "+Codigo)
                             qsay(8,3,"Descri‡„o..: "+left(Razao,60))
         case cVINC == "4" ; qsay(7,3,"Sindicato..: "+Codigo)
                             qsay(8,3,"Descri‡„o..: "+Descricao)
         case cVINC == "5" ; qsay(7,3,"Cargo......: "+Codigo)
                             qsay(8,3,"Descri‡„o..: "+Descricao)
         case cVINC == "6" ; qsay(7,3,"Matricula..: "+Matricula)
                             qsay(8,3,"Nome.......: "+left(FUN->Nome,30))
      endcase
      i_edita()
      qmensa()
      setcursor(0)
   endif
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO ____________________________________________

// obs: foi utilizado a variavel cALIAS na edicao porque deve-se assumir o
//      arquivo selecionado na escolha da vinculacao..., ou seja, conforme
//      o view, deve-se estar selecionado em:
//      CONFIG, CCUSTO, FILIAL, SIND, CARGO ou SITUA

static function i_edita
   local lCONF
   local aEDICAO  := {}
   local bESCAPE  := { || XNIVEL==1 .and. (!XFLAG .or. lastkey()==27) }
   private cALIAS := iif(cVINC=="6","SITUA",alias())

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1
   qrsay ( XNIVEL++ , (cALIAS)->Kit_i_ms ) ; KIT->(dbseek((cALIAS)->Kit_i_ms))
   qrsay ( XNIVEL++ , KIT->Descricao )
   qrsay ( XNIVEL++ , (cALIAS)->Kit_e_ms ) ; KIT->(dbseek((cALIAS)->Kit_e_ms))
   qrsay ( XNIVEL++ , KIT->Descricao )
   qrsay ( XNIVEL++ , (cALIAS)->Kit_i_fr ) ; KIT->(dbseek((cALIAS)->Kit_i_fr))
   qrsay ( XNIVEL++ , KIT->Descricao )
   qrsay ( XNIVEL++ , (cALIAS)->Kit_e_fr ) ; KIT->(dbseek((cALIAS)->Kit_e_fr))
   qrsay ( XNIVEL++ , KIT->Descricao )
   qrsay ( XNIVEL++ , (cALIAS)->Kit_i_ad ) ; KIT->(dbseek((cALIAS)->Kit_i_ad))
   qrsay ( XNIVEL++ , KIT->Descricao )
   qrsay ( XNIVEL++ , (cALIAS)->Kit_e_ad ) ; KIT->(dbseek((cALIAS)->Kit_e_ad))
   qrsay ( XNIVEL++ , KIT->Descricao )
   qrsay ( XNIVEL++ , (cALIAS)->Kit_i_dt ) ; KIT->(dbseek((cALIAS)->Kit_i_dt))
   qrsay ( XNIVEL++ , KIT->Descricao )
   qrsay ( XNIVEL++ , (cALIAS)->Kit_e_dt ) ; KIT->(dbseek((cALIAS)->Kit_e_dt))
   qrsay ( XNIVEL++ , KIT->Descricao )

   if cOPCAO == "C" ; qwait() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_kit(-1,0,@fKIT_I_MS) } ,"KIT_I_MS" })
   aadd(aEDICAO,{{ || NIL } , NIL })
   aadd(aEDICAO,{{ || view_kit(-1,0,@fKIT_E_MS) } ,"KIT_E_MS" })
   aadd(aEDICAO,{{ || NIL } , NIL })
   aadd(aEDICAO,{{ || view_kit(-1,0,@fKIT_I_FR) } ,"KIT_I_FR" })
   aadd(aEDICAO,{{ || NIL } , NIL })
   aadd(aEDICAO,{{ || view_kit(-1,0,@fKIT_E_FR) } ,"KIT_E_FR" })
   aadd(aEDICAO,{{ || NIL } , NIL })
   aadd(aEDICAO,{{ || view_kit(-1,0,@fKIT_I_AD) } ,"KIT_I_AD" })
   aadd(aEDICAO,{{ || NIL } , NIL })
   aadd(aEDICAO,{{ || view_kit(-1,0,@fKIT_E_AD) } ,"KIT_E_AD" })
   aadd(aEDICAO,{{ || NIL } , NIL })
   aadd(aEDICAO,{{ || view_kit(-1,0,@fKIT_I_DT) } ,"KIT_I_DT" })
   aadd(aEDICAO,{{ || NIL } , NIL })
   aadd(aEDICAO,{{ || view_kit(-1,0,@fKIT_E_DT) } ,"KIT_E_DT" })
   aadd(aEDICAO,{{ || NIL } , NIL })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   fKIT_I_MS := (cALIAS)->Kit_i_ms
   fKIT_E_MS := (cALIAS)->Kit_e_ms
   fKIT_I_FR := (cALIAS)->Kit_i_fr
   fKIT_E_FR := (cALIAS)->Kit_e_fr
   fKIT_I_AD := (cALIAS)->Kit_i_ad
   fKIT_E_AD := (cALIAS)->Kit_e_ad
   fKIT_I_DT := (cALIAS)->Kit_i_dt
   fKIT_E_DT := (cALIAS)->Kit_e_dt

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CARGO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if (cALIAS)->(qrlock())
      replace (cALIAS)->Kit_i_ms with fKIT_I_MS
      replace (cALIAS)->Kit_e_ms with fKIT_E_MS
      replace (cALIAS)->Kit_i_fr with fKIT_I_FR
      replace (cALIAS)->Kit_e_fr with fKIT_E_FR
      replace (cALIAS)->Kit_i_ad with fKIT_I_AD
      replace (cALIAS)->Kit_e_ad with fKIT_E_AD
      replace (cALIAS)->Kit_i_dt with fKIT_I_DT
      replace (cALIAS)->Kit_e_dt with fKIT_E_DT
      (cALIAS)->(qunlock())
   else
      qm2()
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case "KIT_" $ cCAMPO
           cCAMPO := "f"+cCAMPO
           KIT->(dbseek(&cCAMPO))
           qrsay(XNIVEL+1,KIT->Descricao)
   endcase
return .T.

