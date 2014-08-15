/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS RECEBER
// OBJETIVO...: CONSULTA DE REPRESENTANTE COMERCIAL
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function rb308

REPRES->(qview({{"Codigo/C¢digo"              ,1},;
              {"left(Razao,47)/Raz„o"         ,2},;
              {"fu_conv_cgccpf(CGCCPF)/C.G.C.",3}},"P",;
              {NIL,"c308a",NIL,NIL},;
               NIL,"ESC/ALT-P/ALT-O/<C>onsulta"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c308a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "C"
      qlbloc(6,0,"B308A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
      i_consulta()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , REPRES->Codigo    )

      qrsay ( XNIVEL++ , fu_conv_cgccpf( REPRES->Cgccpf ) )

      qrsay ( XNIVEL++ , REPRES->Inscricao )
      qrsay ( XNIVEL++ , REPRES->Razao     )
      qrsay ( XNIVEL++ , REPRES->Fantasia  )

      qrsay ( XNIVEL++ , REPRES->End_ent   )
      qrsay ( XNIVEL++ , REPRES->Cgm_ent   ) ; CGM->(dbseek(REPRES->Cgm_ent))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , REPRES->Cep_ent , "@R 99.999-999" )

      qrsay ( XNIVEL++ , REPRES->End_cob   )
      qrsay ( XNIVEL++ , REPRES->Cgm_cob   ) ; CGM->(dbseek(REPRES->Cgm_cob))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , REPRES->Cep_cob , "@R 99.999-999" )

      qrsay ( XNIVEL++ , REPRES->Fone1     )
      qrsay ( XNIVEL++ , REPRES->Ramal1    )
      qrsay ( XNIVEL++ , REPRES->Fone2     )
      qrsay ( XNIVEL++ , REPRES->Ramal2    )
      qrsay ( XNIVEL++ , REPRES->Fax       )
      qrsay ( XNIVEL++ , REPRES->Foner     )
      qrsay ( XNIVEL++ , REPRES->Contato_c )
      qrsay ( XNIVEL++ , REPRES->Contato_f )
   endif

   qwait()

return
