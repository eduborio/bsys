/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: CONSULTA DE SALDO BANCARIO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MAIO DE 2001
// OBS........:
// ALTERACOES.:
function ts311


// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO   := {}
local lCONF     := .F.

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1)}

private cCOD_BANCO := space(5)
private nSALDO_INI := 0.00
private nSALDO_SUB := 0.00
private nSALDO_TOT := 0.00
private nSALDO_CAI := 0.00
private nSALDO     := 0.00

PLAN->(Dbsetorder(3))  // codigo reduzido
BANCO->(Dbsetorder(3)) // codigo do registro

qlbloc(17,00,"B311B","QBLOC.GLO")
XNIVEL := 1
i_subtotal()
i_caixa()
qrsay ( XNIVEL++ ,transform(nSALDO_SUB,"@E 9,999,999.99") )
qrsay ( XNIVEL++ ,transform(nSALDO_CAI,"@E 9,999,999.99") )
qrsay ( XNIVEL++ ,transform(nSALDO_SUB+(nSALDO_CAI),"@E 9,999,999.99") )

BANCO->(dbsetfilter({||Codigo != "99999"},'Codigo != "99999"'))

BANCO->(qview({{"left(Descricao,30)/Nome"                ,3},;
               {"Agencia/Agˆncia"                        ,0},;
               {"i_calc()/Saldo"                         ,0}},"05001679",;
               {NIL,"c311a",NIL,NIL},;
                NIL,"<C>onsulta"))


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c311a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "C"
      qlbloc(9,4,"B311A","QBLOC.GLO",1)
      i_consulta()
   endif
   setcursor(nCURSOR)
return ""


/////////////////////////////////////////////////////////////////////////////
// CALCULO DO SALDO DO BANCO ________________________________________________
function i_calc

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
//CALCULA SALDO DE TODOS OS BANCOS___________________________________________
function i_subtotal

     SALD_BAN->(Dbsetorder(1))
     SALD_BAN->(Dbgotop())

     BANCO->(dbgotop())

     MOV_BANC->(Dbsetorder(2))
     MOV_BANC->(Dbgotop())

     do while ! BANCO->(eof())

        if ! SALD_BAN->(dbseek(dtos(XDATA)+BANCO->Codigo))
           nSALDO := 0  // final de semana ?
        else
           nSALDO := SALD_BAN->Saldo
        endif

        set softseek on
        MOV_BANC->(Dbseek(BANCO->Codigo+dtos(XDATA)))
        set softseek off

        do while ! MOV_BANC->(eof()) .and. MOV_BANC->Cod_banco = BANCO->Codigo .and. MOV_BANC->Data = XDATA
           do case
              case ! empty(MOV_BANC->Entrada)
                   nSALDO += MOV_BANC->Entrada
              case ! empty(MOV_BANC->Saida)
                   nSALDO -= MOV_BANC->Saida
           endcase

           MOV_BANC->(Dbskip())
        enddo
        nSALDO_SUB += nSALDO
        nSALDO := 0
        BANCO->(dbskip())
        if BANCO->Codigo == "99999" //NAO CACULAR SALDO CAIXA JUNTO COM OUTROS BANCOS
           BANCO->(dbskip())
        endif

     enddo
return nSALDO_SUB

/////////////////////////////////////////////////////////////////////////////
//CALCULA SALDO DE CAIXA ____________________________________________________
function i_caixa

  SALD_CAI->(Dbsetorder(1))
  SALD_CAI->(Dbgotop())

  if ! SALD_CAI->(dbseek(dtos(XDATA)))
     nSALDO_CAI := 0  // final de semana ?
  else
     nSALDO_CAI := SALD_CAI->Saldo
  endif


  MOV_CAIX->(Dbsetorder(1))
  MOV_CAIX->(Dbgotop())
  set softseek on
  MOV_CAIX->(Dbseek(XDATA))
  set softseek off

  do while ! MOV_CAIX->(eof()) .and. MOV_CAIX->Data = XDATA

     if ! empty(MOV_CAIX->Entrada)
        nSALDO_CAI += MOV_CAIX->Entrada
     endif

     if ! empty(MOV_CAIX->Saida)
        nSALDO_CAI -= MOV_CAIX->Saida
     endif

     MOV_CAIX->(Dbskip())

  enddo


return nSALDO_CAI

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
