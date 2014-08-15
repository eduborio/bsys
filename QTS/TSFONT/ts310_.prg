/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: CONSULTA DE SALDO BANCARIO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1998
// OBS........:
// ALTERACOES.:
function ts310

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO   := {}
local lCONF     := .F.

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1)}

private cCOD_BANCO := space(5)
private nSALDO_INI := 0.00

PLAN->(Dbsetorder(3))  // codigo reduzido
BANCO->(Dbsetorder(3)) // codigo do registro

BANCO->(dbsetfilter({||Codigo != "99999"},'Codigo != "99999"'))

BANCO->(qview({{"Codigo/C¢digo"                          ,0},;
               {"Banco/Banco"                            ,1},;
               {"left(Descricao,30)/Nome"                ,2},;
               {"Conta/Nr. Conta"                        ,0},;
               {"Agencia/Agˆncia"                        ,0},;
               {"i_calcula()/Saldo"                      ,0}},"P",;
               {NIL,"c310a",NIL,NIL},;
                NIL,"<C>onsulta"))


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c310a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "C"
      qlbloc(9,4,"B310A","QBLOC.GLO",1)
      i_consulta()
   endif
   setcursor(nCURSOR)
return ""


/////////////////////////////////////////////////////////////////////////////
// CALCULO DO SALDO DO BANCO ________________________________________________
function i_calcula

     MOV_BANC->(Dbsetorder(2))
     MOV_BANC->(Dbgotop())
     SALD_BAN->(Dbsetorder(1))
     SALD_BAN->(Dbgotop())

     nSALDO_INI := 0.00

     if ! SALD_BAN->(dbseek(dtos(XDATA)+BANCO->Codigo))
        nSALDO_INI := 0  // final de semana ?
     else
        nSALDO_INI := SALD_BAN->Saldo
     endif

     set softseek on
     MOV_BANC->(Dbseek(BANCO->Codigo+dtos(XDATA)))
     set softseek off

     do while ! MOV_BANC->(eof()) .and. MOV_BANC->Cod_banco == BANCO->Codigo .and. MOV_BANC->Data = XDATA
        do case
           case ! empty(MOV_BANC->Entrada)
                nSALDO_INI += MOV_BANC->Entrada
           case ! empty(MOV_BANC->Saida)
                nSALDO_INI -= MOV_BANC->Saida
        endcase

        MOV_BANC->(Dbskip())

     enddo

return transform(nSALDO_INI,"@R 9,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A CONSULTA DA TELA _________________________________

static function i_consulta

      XNIVEL := 1
      qrsay ( XNIVEL++ , BANCO->Codigo     )
      qrsay ( XNIVEL++ , BANCO->Descricao  )
      qrsay ( XNIVEL++ , BANCO->Banco      )
      qrsay ( XNIVEL++ , BANCO->Agencia    )
      qrsay ( XNIVEL++ , transform(BANCO->Conta,"@R 999999-9"))
      qrsay ( XNIVEL++ , BANCO->End_agenc  )
      qrsay ( XNIVEL++ , BANCO->Cod_cgm    ) ; CGM->(Dbseek(BANCO->Cod_cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,48))
      qrsay ( XNIVEL++ , BANCO->CEP        )
      qrsay ( XNIVEL++ , BANCO->Telefone   )
      qrsay ( XNIVEL++ , transform(BANCO->Conta_cont, "@R 99999-9")) ; PLAN->(Dbseek(BANCO->Conta_cont))
      qrsay ( XNIVEL++ , left(PLAN->Descricao,39))
      qrsay ( XNIVEL++ , BANCO->Filial     ) ; FILIAL->(Dbseek(BANCO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,36))
      qrsay ( XNIVEL++ , BANCO->Gerente    )

      qwait()

return
