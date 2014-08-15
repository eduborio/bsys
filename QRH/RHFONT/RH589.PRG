/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE RECURSOS HUMANOS
// OBJETIVO...: EMISSAO DE PROTOCOLO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2002
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {|| (XNIVEL==1 .and. !XFLAG) .or. lastkey()==27 }


private aEDICAO := {}    // vetor para os campos de entrada de dados
private cDEPART := space(40)
private cASSUNTO  := space(30)
private cPARA  := space(30)
private cNUM  := space(6)


private cLINHA1 := space(40)
private cLINHA2 := space(40)
private cLINHA3 := space(40)
private cLINHA4 := space(40)
private cLINHA5 := space(40)
private cLINHA6 := space(40)


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cDEPART ,"@!"                    )} ,"DEPART" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPARA   ,"@!"                    )} ,"PARA" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cASSUNTO,"@!"                    )} ,"ASSUNTO" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA1,"@!"                     )} ,"LINHA1" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA2,"@!"                     )} ,"LINHA2" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA3,"@!"                     )} ,"LINHA3" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA4,"@!"                     )} ,"LINHA4" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA5,"@!"                     )} ,"LINHA5" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA6,"@!"                     )} ,"LINHA6" })

do while .T.

   qlbloc(5,0,"B589A","QBLOC.GLO")

   XNIVEL  := 1
   XFLAG   := .T.

   cLINHA1 := space(40)
   cLINHA2 := space(40)
   cLINHA3 := space(40)
   cLINHA4 := space(40)
   cLINHA5 := space(40)
   cLINHA6 := space(40)
   cDEPART := space(40)
   cPARA   := space(30)
   cASSUNTO := space(30)
   cNUM := space(6)
   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_impressao()

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "ASSUNTO"

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
    cNUM := strzero(CONFIG->Cod_proto,6)
    @ prow()  ,00 say XCOND1
    @ prow()+2,00 say replicate("=",80)
    @ prow()+1,00 say "±±±±±±±±±±±±±±±±±±±±±±±" + "  << ENTREGA DE DOCUMENTOS >>      No." + cNUM
    @ prow()+1,00 say "±±                   ±±                                        1a. Via"
    @ prow()+1,00 say "±± P R O T O C O L O ±±" + " Data: "+ dtoc(date())
    @ prow()+1,00 say "±±                   ±±" + " Remetente.: RESCON CONTABILIDADE S/C LTDA"
    @ prow()+1,00 say "±±±±±±±±±±±±±±±±±±±±±±±" + " RUA IZABEL A REDENTORA, 622"

    @ prow()+2,00 say "(041) XX 383-8369    383-8369"
    @ prow()+1,00 say "Departamento: "+ cDEPART + "Hora: "+left(time(),8)
    @ prow()+1,00 say replicate("-",80)
    @ prow()+1,00 say "                     *** DESTINTARIO ***"
    @ prow()+1,00 say left(XRAZAO,50) + "     " + XCGCCPF
    @ prow()+1,00 say left(XENDERECO,50) + " " + XNUMERO + " "+ XBAIRRO

    @ prow()+2,00 say "Para: "+ cPARA
    @ prow()+1,00 say "                      Assunto: "+ cASSUNTO
    @ prow()+1,00 say replicate("-",80)
    @ prow()+1,00 say "Descricao                                    "
    @ prow()+1,00 say replicate("-",80)
    @ prow()+1,00 say cLINHA1
    @ prow()+1,00 say cLINHA2
    @ prow()+1,00 say cLINHA3
    @ prow()+1,00 say cLINHA4
    @ prow()+1,00 say cLINHA5
    @ prow()+1,00 say cLINHA6
    @ prow()+1,00 say replicate("-",80)
    @ prow()+1,00 say "S.J.P DOS PINHAIS,                      Hora:"
    @ prow()+2,00 say "Nome Legivel:                     Assinatura:"
    @ prow()+2,00 say replicate("=",80)

    @ prow()+2,00 say replicate("=",80)
    @ prow()+1,00 say "±±±±±±±±±±±±±±±±±±±±±±±" + "  << ENTREGA DE DOCUMENTOS >>      No."+ cNUM
    @ prow()+1,00 say "±±                   ±±                                        2a. Via"
    @ prow()+1,00 say "±± P R O T O C O L O ±±" + " Data: "+ dtoc(date())
    @ prow()+1,00 say "±±                   ±±" + " Remetente.: RESCON CONTABILIDADE S/C LTDA"
    @ prow()+1,00 say "±±±±±±±±±±±±±±±±±±±±±±±" + " RUA IZABEL A REDENTORA, 622"

    @ prow()+2,00 say "(041) XX 383-8369    383-8369"
    @ prow()+1,00 say "Departamento: "+ cDEPART + "Hora: "+left(time(),8)
    @ prow()+1,00 say replicate("-",80)
    @ prow()+1,00 say "                     *** DESTINTARIO ***"
    @ prow()+1,00 say left(XRAZAO,50) + "     " + XCGCCPF
    @ prow()+1,00 say left(XENDERECO,50) + " " + XNUMERO + " "+ XBAIRRO

    @ prow()+2,00 say "Para: "+ cPARA
    @ prow()+1,00 say "                      Assunto: "+ cASSUNTO
    @ prow()+1,00 say replicate("-",80)
    @ prow()+1,00 say "Descricao                                    "
    @ prow()+1,00 say replicate("-",80)
    @ prow()+1,00 say cLINHA1
    @ prow()+1,00 say cLINHA2
    @ prow()+1,00 say cLINHA3
    @ prow()+1,00 say cLINHA4
    @ prow()+1,00 say cLINHA5
    @ prow()+1,00 say cLINHA6
    @ prow()+1,00 say replicate("-",80)
    @ prow()+1,00 say "S.J.P DOS PINHAIS,                      Hora:"
    @ prow()+2,00 say "Nome Legivel:                     Assinatura:"
    @ prow()+2,00 say replicate("=",80)
    if CONFIG->(qrlock())
       replace CONFIG->Cod_proto with val(cNUM) + 1
       CONFIG->(qunlock())
    endif
   qstopprn()

return
