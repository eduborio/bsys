/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE FATURAMENTO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: AGOSTO DE 2000
// OBS........:
// ALTERACOES.:

function cl403

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cPROD
private cPROD_DESC
private cFABR
private cCLI
private nVALOR
private nVAL_UNI
private nCUSTO
private nQUANT
private aEDICAO := {}             // vetor para os campos de entrada de dados


PROD->(dbsetorder(4)) // codigo reduzido

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD)       } ,"PROD"    })
aadd(aEDICAO,{{ || NIL                          } ,NIL       })

do while .T.

   qlbloc(5,0,"B522A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cPROD  := space(5)
   dINI := dFIM := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_processa() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "PROD"
           if empty(cPROD) ; return .F. ; endif
           qrsay(XNIVEL,cPROD:=strzero(val(cPROD),5))
           if ! PROD->(dbseek(cPROD))
               qmensa("Produto inv lido !","B")
               return .F.
           else
              qrsay(XNIVEL+1,left(PROD->Descricao,38))
              cPROD_DESC := left(PROD->Descricao,45)
              cFABR := left(PROD->Cod_fabr,4)
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off

return .T.

static function i_processa()
    local nVAL_PED := 0
    local nVAL_PTS := 0
    local nTT_PTS  := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local nVAL_UNI := 0
    local lFIRST   := .F.

    if  ! qconf("Confirma ajuste de pontos para este Produto?","B")
       return .f.
    endif

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   FAT->(dbsetorder(2))
   set softseek on
   FAT->(dbseek(dINI))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      //if empty(FAT->Num_fatura) .and. FAT->Es == "S"
      //   FAT->(dbskip())
      //   loop
      //endif

      CLI1->(Dbseek(FAT->Cod_cli))

      if ! left(FAT->Cod_cfop,3) $ "510-511-610-611-120-220"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ... "+left(CLI1->Razao,30))

      ITEN_FAT->(Dbgotop())
      nVAL_PTS := 0
      if ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

            if ITEN_FAT->Cod_prod != cPROD
               ITEN_FAT->(dbskip())
               loop
            endif

            PROD->(dbsetorder(4))
            if PROD->(dbseek(ITEN_FAT->Cod_prod))
               if ITEN_FAT->(qrlock())
                  replace ITEN_FAT->Pontos with PROD->Pontos
                  ITEN_FAT->(Qunlock())
               endif
            endif

            ITEN_FAT->(Dbskip())
        enddo
      endif


      FAT->(dbskip())

   enddo



return


