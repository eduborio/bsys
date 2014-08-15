/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO
// OBJETIVO...: PROPAGACAO DE SALDOS (SOMENTE NAS SAIDAS)
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2005
// OBS........:
// ALTERACOES.:

function cl406
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

do while .T.

   qlbloc(5,0,"B406A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := ctod("")
   dFIM := ctod("")
   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_gravacao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PROD->(dbsetorder(4))
   PROD->(Dbgotop())

   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dINI))
   set softseek off

   ITEN_FAT->(dbsetorder(2))


   //FAT->(Dbsetfilter({||FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. FAT->Es == "S"},'FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM.and. FAT->Es == "S" ' ))

return .T.

static function i_gravacao

local nCONT,nTOTAL  := 0
local nVALOR := 0
local nALIQ  := 0
local nDESC  := 0
local cLINHA  := ""
local cNOMEARQ := ""

if ! quse(XDRV_CL,"TRANSFER",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo TRANSFER.DBF !! Tente novamente.")
   return
endif

TRANSFER->(__dbzap())


nCONT  := 0
nVALOR := 0
nALIQ  := 0
nDESC  := 0


do while ! FAT->(eof()).and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM

   if FAT->Cancelado
      FAT->(Dbskip())
      loop
   endif

   if FAT->Es != "S"
      FAT->(Dbskip())
      loop
   endif

   if ! FAT->Dt_emissao >= dINI .and. ! FAT->Dt_emissao <= dFIM
      FAT->(Dbskip())
      loop
   endif


   CLI1->(Dbseek(FAT->Cod_cli))


   qgirabarra()
   qmensa(FAT->Num_fatura +"  Cli.: "+left(CLI1->Razao,55) )
      ITEN_FAT->(DbSetorder(2))
      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          PROD->(Dbseek(ITEN_FAT->Cod_prod))

          nTOTAL += ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
          ITEN_FAT->(Dbskip())

      enddo
      FILIAL->(Dbseek(FAT->Filial))
      cLINHA := "1"+";"+FILIAL->Cgccpf+";"+left(qtiraponto(FILIAL->Insc_estad),10)+";"+FAT->Num_fatura+";"+CONFIG->Serie+";"+dtoc(FAT->dt_emissao)+";"+left(FAT->Cod_cfop,4)+";"+transform(nTOTAL,"@E 999999999.99")+";"+space(12)+";"+space(12)+";"+space(12)+";"+FAT->Despacho+";"+space(50)+";"+space(12)+";"+space(53)+";"+space(14)+";"+space(14)+";"+space(11)+";"+left(CLI1->Razao,55)+";"+space(30)+";"+"EX"
      TRANSFER->(Qappend())
      TRANSFER->Linha := cLINHA
      cLINHA := ""
      nTOTAL := 0




   FAT->(dbskip())

enddo

    cNOMARQ := "A:"+dtos(date())+".TxT" //
    TRANSFER->(dbgotop())

    TRANSFER->(__dbSDF( .T., CNOMARQ , { },,,,, .F. ) )

    if TRANSFER->(qflock())
       TRANSFER->(__dbzap())
    endif

return
