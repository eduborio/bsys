
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: PROCEDIMENTOS REAL-TIME
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: 1994
// OBS........:
// ALTERACOES.:

static nACAO := 1

local sBLOC := qsbloc(0,0,24,79)
qsay(02,06,time())


do case
   case nACAO == 1 ; f_1()
   case nACAO == 2 ; f_2()
   case nACAO == 3 ; f_3()
endcase

iif ( ++nACAO == 4 , nACAO := 1 , NIL )

qrbloc(0,0,sBLOC)

return

static function f_1
/*
   static nRECFUN := 1

   if ! quse(XDRV_RH,"FUN") ; return ; endif
*/
return

static function f_2
return

static function f_3
return

