/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: CONSULTA DE FORNECEDOR
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: DEZEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function pg306

PLAN->(Dbsetorder(3)) // codigo reduzido

FORN->(qview({{"Codigo/C¢digo"                ,1},;
              {"left(Razao,47)/Raz„o"         ,2},;
              {"fu_conv_cgccpf(CGCCPF)/C.G.C.",3}},"P",;
              {NIL,"c306a",NIL,NIL},;
               NIL,"<ESC> para Sair / <C>onsulta"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c306a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "C"
      qlbloc(5,0,"B306A","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , FORN->Codigo    )

      qrsay ( XNIVEL++ , fu_conv_cgccpf( FORN->Cgccpf ) )

      qrsay ( XNIVEL++ , FORN->Inscricao )
      qrsay ( XNIVEL++ , FORN->Razao     )
      qrsay ( XNIVEL++ , FORN->Fantasia  )

      qrsay ( XNIVEL++ , FORN->End_ent   )
      qrsay ( XNIVEL++ , FORN->Cgm_ent   ) ; CGM->(dbseek(FORN->Cgm_ent))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , FORN->Cep_ent , "@R 99.999-999" )

      qrsay ( XNIVEL++ , FORN->End_cob   )
      qrsay ( XNIVEL++ , FORN->Cgm_cob   ) ; CGM->(dbseek(FORN->Cgm_cob))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , FORN->Cep_cob , "@R 99.999-999" )

      qrsay ( XNIVEL++ , FORN->Fone1     )
      qrsay ( XNIVEL++ , FORN->Ramal1    )
      qrsay ( XNIVEL++ , FORN->Fone2     )
      qrsay ( XNIVEL++ , FORN->Ramal2    )
      qrsay ( XNIVEL++ , FORN->Fax       )
      qrsay ( XNIVEL++ , FORN->Foner     )
      qrsay ( XNIVEL++ , FORN->Contato_c )
      qrsay ( XNIVEL++ , FORN->Contato_f )

      qrsay ( XNIVEL++ , FORN->Conta_cont, "@R 99999-9"               ) ; PLAN->(Dbseek(FORN->Conta_cont))
      qrsay ( XNIVEL++ , iif(FORN->Conta_cont <> space(6),PLAN->Descricao," "))

      qrsay ( XNIVEL++ , FORN->Filial    ) ; FILIAL->(dbseek(FORN->Filial))
      qrsay ( XNIVEL++ , left(Filial->Razao,48))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

return
