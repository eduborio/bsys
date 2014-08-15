
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: PROCEDIMENTOS PARA NOVA EMPRESA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: 1994
// OBS........:
// ALTERACOES.:

local lTRAVA

if ! quse(XDRV_SY,"CONFIG") ; return .F. ; endif

if CONFIG->(eof())
   lTRAVA := CONFIG->(qappend())
else
   lTRAVA := CONFIG->(qrlock())
endif

if lTRAVA
// replace CONFIG->Datasys   with qfimmes(date())
   replace CONFIG->Tipo_mat  with "G"
   replace CONFIG->Matricula with 0
   replace CONFIG->Sinc_sal  with "N"
   replace CONFIG->Auto_ms   with "S"
   replace CONFIG->Campoadic with "SITUACAO"
   replace CONFIG->Fc_hora   with "C"
   replace CONFIG->Dias_ctr  with 30
   replace CONFIG->Kit_i_ms  with "B01"
   replace CONFIG->Kit_i_fr  with "F04"
   replace CONFIG->Kit_i_ad  with "X01"
   replace CONFIG->Pathshare with "\QSYS_G\QRH\"
endif

CONFIG->(dbclosearea())

return

