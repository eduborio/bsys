/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA CLARI - AGUA MINERAL
// OBJETIVO...: LISTAGEM DE CLIENTES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: NOVEMBRO de 2006
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

function cl557
local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private sBLOC2  := qlbloc("B501B","QBLOC.GLO") // Ordem Codigo ou Razao

private cTITULO          // titulo do relatorio
private cTIPO            // Relatorio morto ou clientes ativos
private cORDEM           // Ordem do Relatorio
private cMODELO          // Modelo de impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private cALIAS           // alias para os arquivos
private cFILIAL          // filial
private cCOMPAC          // define tipo de compatacao
private cVEND            // define vendedor do cliente
private cAREA            // define Area de Venda do cliente
private cCGM             // define Cidade
private cREPRES          // define Representante
private cSETOR           // define Representante
private cUFS             // define Representante

//fu_abre_ccusto()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_area(-1,0,@cAREA ,"@!"  )}, "AREA"    })
aadd(aEDICAO,{{ || NIL                           },  NIL      }) // descricao da Area de Venda
aadd(aEDICAO,{{ || view_vend(-1,0,@cVEND ,"99999")},"VEND"  })
aadd(aEDICAO,{{ || NIL                           },NIL        }) // descricao do Vendedor
aadd(aEDICAO,{{ || view_repres(-1,0,@cREPRES ,"99999")},"REPRES"  })
aadd(aEDICAO,{{ || NIL                           },NIL        }) // descricao do Representante
aadd(aEDICAO,{{ || view_Cgm(-1,0,@cCGM ,"999999")},"CGM"  })
aadd(aEDICAO,{{ || NIL                           },NIL        }) // descricao do Cgm
aadd(aEDICAO,{{ || view_setor(-1,0,@cSETOR,"99999")},"SETOR"  })
aadd(aEDICAO,{{ || NIL                           },NIL        }) // descricao do Cgm
aadd(aEDICAO,{{ || view_ufs(-1,0,@cUFS,"99")},"UFS"  })
aadd(aEDICAO,{{ || NIL                           },NIL        }) // descricao do Cgm



aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL)   } , "FILIAL" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao da filial

do while .T.

   qlbloc(5,0,"B557A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   cORDEM  := " "
   cTIPO   := " "
   cFILIAL := "    "
   cVEND   := space(5)
   cAREA   := space(2)
   cCGM    := space(6)
   cREPRES := space(5)
   cSETOR  := space(5)
   cUFS    := space(2)
   cALIAS  := "CLI1"

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "FILIAL"
           if ! empty(cFILIAL)
              qrsay ( XNIVEL , cFILIAL := strzero(val(cFILIAL),4) )
              if FILIAL->(dbseek(cFILIAL))
                 qrsay(XNIVEL+1,left(FILIAL->Razao,40))
              else
                 qmensa("Filial n„o encontrado !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "AREA"
           if empty(cAREA)
              qrsay( XNIVEL+1, "Todas as Areas de Venda...")
           else
              if ! AREA->(dbseek(cAREA))
                 qmensa("Area de Venda n„o Cadastrada ! ")
                 return .F.
              endif
              qrsay( XNIVEL , cAREA              )
              qrsay( XNIVEL+1,left(AREA->Descricao,25))
           endif

      case cCAMPO == "VEND"
           if empty(cVEND)
              qrsay( XNIVEL+1, "Todos os Vendedores...")
           else
              if ! VEND->(dbseek(cVEND:=strzero(val(cVEND),5)))
                 qmensa("Vendedor n„o Cadastrado ! ")
                 return .F.
              endif
              qrsay( XNIVEL , cVEND              )
              qrsay( XNIVEL+1,left(VEND->Nome,25))
           endif

      case cCAMPO == "REPRES"
           if empty(cREPRES)
              qrsay( XNIVEL+1, "Todos os Representates...")
           else
              if ! REPRES->(dbseek(cREPRES:=strzero(val(cREPRES),5)))
                 qmensa("Representante n„o Cadastrado ! ")
                 return .F.
              endif
              qrsay( XNIVEL , cREPRES              )
              qrsay( XNIVEL+1,left(REPRES->Razao,25))
           endif

      case cCAMPO == "CGM"
           if empty(cCGM)
              qrsay( XNIVEL+1, "Todos os Municipios...")
           else
              if ! CGM->(dbseek(cCGM:=strzero(val(cCGM),6)))
                 qmensa("Municipio n„o Cadastrado ! ")
                 return .F.
              endif
              qrsay( XNIVEL , cCGM              )
              qrsay( XNIVEL+1,left(CGM->Municipio,25))
           endif

      case cCAMPO == "SETOR"
           if empty(cSETOR)
              qrsay( XNIVEL+1, "Todos os Setores...")
           else
              if ! SETOR->(dbseek(cSETOR:=strzero(val(cSETOR),5)))
                 qmensa("Setor n„o Cadastrado ! ")
                 return .F.
              endif
              qrsay( XNIVEL , cSETOR              )
              qrsay( XNIVEL+1,left(SETOR->Descricao,25))
           endif

      case cCAMPO == "UFS"
           if empty(cUFS)
              qrsay( XNIVEL+1, "Todos os Estados...")
           else
              if ! UFS->(dbseek(cUFS:=strzero(val(cUFS),5)))
                 qmensa("Estado n„o Cadastrado ! ")
                 return .F.
              endif
              qrsay( XNIVEL , cUFS              )
              qrsay( XNIVEL+1,left(ESTADO->Descricao,25))
           endif





   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________




   cTITULO := "LISTAGEM GERAL DE CLIENTES "

   // SELECIONA ORDEM DO ARQUIVO CLIENTE ____________________________________

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

return .T.

static function i_impressao
   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
//;      i_impre_xls()
   else
      i_impre_prn()
   endif


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

   local cMUN_ENT , cMUN_COB , cEST_ENT , cEST_COB

   local nMAXLIN := 53

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   //if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   do while ! (cALIAS)->(eof()) // condicao principal de loop

      if ! qlineprn() ; exit ; endif

      if ! empty(cVEND) .and. (cALIAS)->(Cod_vend) <> cVEND
         (cALIAS)->(dbskip())
         loop
      endif

      if ! empty(cAREA) .and. (cALIAS)->(Cod_area) <> cAREA
         (cALIAS)->(dbskip())
         loop
      endif

      if ! empty(cREPRES) .and. (cALIAS)->(Cod_repres) <> cREPRES
         (cALIAS)->(dbskip())
         loop
      endif

      if ! empty(cCGM) .and. (cALIAS)->(Cgm_ent) <> cCGM
         (cALIAS)->(dbskip())
         loop
      endif

      if ! empty(cSETOR) .and. (cALIAS)->(Cod_setor) <> cSETOR
         (cALIAS)->(dbskip())
         loop
      endif

      CGM->(dbseek(CLI1->Cgm_ent))
      
      if ! empty(cUFS) .and. CGM->Estado <> cUFS
         (cALIAS)->(dbskip())
         loop
      endif



      if XPAGINA == 0 .or. prow() > nMAXLIN
         qpageprn()
         qcabecprn(cTITULO,135)
      endif
   
      CGM->(dbseek((cALIAS)->Cgm_ent))
      cMUN_ENT := CGM->Municipio
      cEST_ENT := CGM->Estado
      CGM->(dbseek((cALIAS)->Cgm_cob))
      FILIAL->(dbseek((cALIAS)->Filial))
      VEND->(dbseek(CLI1->Cod_vend))
      AREA->(dbseek(CLI1->Cod_area))

      qmensa("Imprimindo Cliente...: "+(cALIAS)->Codigo+" / Raz„o: "+(cALIAS)->Razao)

      @ prow()+1,0 say "CODIGO: "  +  (cALIAS)->Codigo  + space(5)      + "RAZAO: " + left((cALIAS)->Razao,50) +;
                        space (3) +  "FANTASIA: "      + (cALIAS)->Fantasia
      @ prow()+1,0 say "CNPJ/CPF: " +  fu_conv_cgccpf((cALIAS)->Cgccpf)   + space(9)  + "INSCRICAO: "   + (cALIAS)->Inscricao +;
                        space(9)   +  "ENDERECO ENT.: " + (cALIAS)->End_ent
      @ prow()+1,0 say "MUNICIPIO ENT.: " + left(cMUN_ENT,24) + space(2) + "UF: "    + cEST_ENT +;
                        space(2)   +  "CEP ENT.: " + transform((cALIAS)->Cep_ent,"@R 99999-999")+;
                        space(1)   +  "BAIRRO.: " +(cALIAS)->Bairro_ent

      @ prow()+1,0 say "TELEF.-1: " + (cALIAS)->Fone1 + space(2) + "RAMAL: " + (cALIAS)->Ramal1 +;
                        space(4)   +  "TELEF.-2: " + (cALIAS)->Fone2
      @ prow()+1,0 say  "FAX: "  + (cALIAS)->Fax +;
                        space(2)   +  "CONT. COMER.: "  + (cALIAS)->Contato_c   + space(2)  + "CONT. FINAN.: " + (cALIAS)->Contato_f

      @ prow()+1,0 say  "COD.: "  + (cALIAS)->Cod_vend + " VENDEDOR.: "+ VEND->Nome +;
                        space(5) + "COD: " + CLI1->Cod_area +space(2)+ "AREA DE VENDA.: " + left(AREA->Descricao,25)


      @ prow()+1,0 say "FILIA.........: " + (cALIAS)->Filial + "-"  + left(FILIAL->Razao,40)
      @ prow()+1,000 say ""

      (cALIAS)->(dbskip())
   enddo

   qstopprn()

return

static function i_impre_xls

return
