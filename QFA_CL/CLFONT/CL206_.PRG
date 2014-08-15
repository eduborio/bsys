/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LANCAMENTO DE PEDIDO DE VENDA
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: FEVEREIRO 2004
// OBS........:
// ALTERACOES.:

function cl206
#include "inkey.ch"

private fTOTAL := 0
private lALT   := .F.

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE PEDIDO DE VENDA ___________________________________________

ROMANEIO->(qview({{"Codigo/Codigo"         ,1},;
             {"Data/Data"               ,2},;
             {"left(Obs,40)/Observacao"          ,0}},"P",;
             {NIL,"i_206c",NIL,NIL},;
              NIL,q_msg_acesso_usr()+"/im<P>rime"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_206c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO == "P", i_imprime(),)

   if cOPCAO $ XUSRA

      qlbloc(5,0,"B206A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancelar>","Altera‡„o... <ESC - Cancelar>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

   fTOTAL := 0
   nCOMISSAO:= 0
   fPARC  := 0

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,14 , ROMANEIO->Codigo           )
      qsay ( 08,14 , dtoc(ROMANEIO->Data)       )
      qsay ( 10,14 , Left(ROMANEIO->Filial,4)   );FILIAL->(dbseek(ROMANEIO->Filial))
      qsay ( 10,21 , left(FILIAL->Razao,40)     )
      qsay ( 12,14 , Left(ROMANEIO->Obs,64)     )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO" })
   aadd(aEDICAO,{{ || qgetx(8,14,@fDATA,"@D",                          )} ,"DATA"   })

   aadd(aEDICAO,{{ || view_filial(10,14,@fFILIAL                        )} ,"FILIAL" })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial

   aadd(aEDICAO,{{ || qgetx(12,14,@fOBS,"@!S64",NIL                    )}   ,"OBS"        })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      ROMANEIO->(qpublicfields())

      iif(cOPCAO=="I", ROMANEIO->(qinitfields()), ROMANEIO->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );ROMANEIO->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock())

         // AQUI INCREMENTA CODIGO DO PEDIDO DE VENDA ____________

         if cOPCAO == "I"
            replace CONFIG->Cod_roma with CONFIG->Cod_roma + 1
            qsay(6,14,fCODIGO := strzero(CONFIG->Cod_roma,6) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif

      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif
      CONFIG->(qunlock())
      if ROMANEIO->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________


         ROMANEIO->(qreplacefields())
      endif

      dbunlockall()

      i_6proc_lanc()
      keyboard chr(27)

   enddo

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DT_EMISSAO"
           if empty(fDATA) ; return .F. ; endif

      case cCAMPO == "FILIAL"

           //FAT->(dbclearfilter())

           if ! empty(fFILIAL)
              qsay(10,14,fFILIAL)
              if ! FILIAL->(dbseek(fFILIAL))
                 qmensa("Filial n„o encontrado !","B")
                 return .F.
              endif
              qsay(10,21,left(FILIAL->Razao,40))
              //FAT->(dbsetfilter({|| FAT->Filial == fFILIAL}))
           endif


   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR PEDIDO DE VENDA __________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Romaneio ?")

      ITEN_ROM->(Dbgotop())
      ITEN_ROM->(Dbseek(ROMANEIO->Codigo))


      if ITEN_ROM->(qflock()) .and. ROMANEIO->(qrlock())

         ITEN_ROM->(dbseek(ROMANEIO->Codigo))

         do while ! ITEN_ROM->(eof()) .and. ITEN_ROM->Cod_roma == ROMANEIO->Codigo
            ITEN_ROM->(dbdelete())
            ITEN_ROM->(dbskip())
         enddo

         ROMANEIO->(dbdelete())
         ROMANEIO->(qunlock())
         ITEN_ROM->(qunlock())

      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_6proc_lanc


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

if cOPCAO == "A"
   fTOTAL := 0
endif


ITEN_ROM->(qview({{"f206cod()/Ped. Conv."                                        ,2},;
                  {"f206a()/Cliente"                                           ,0},;
                  {"f206c()/Nota Fiscal"                                       ,0}},;
                  "13002179S",;
                  {NIL,"f206d",NIL,NIL},;
                  {"ITEN_ROM->Cod_roma == ROMANEIO->Codigo",{||f206top()},{||f206bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f206top
   ITEN_ROM->(dbsetorder(1))
   ITEN_ROM->(dbseek(ROMANEIO->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f206bot
   ITEN_ROM->(dbsetorder(1))
   ITEN_ROM->(qseekn(ROMANEIO->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f206cod
local cCod := ""
    if ! empty(ITEN_ROM->cod_fat)
       cCod := ITEN_ROM->Cod_fat
    else
       if ! empty(ITEN_ROM->Cod_conv)
          cCod := ITEN_ROM->Cod_conv
       endif
    endif



return cCod

function f206a
   local cDESCRICAO := space(40)
   CLI1->(Dbsetorder(1))
   FAT->(Dbsetorder(1))

   if ! empty(ITEN_ROM->Cod_fat)
      FAT->(Dbseek(ITEN_ROM->Cod_fat))
      CLI1->(dbseek(FAT->Cod_cli))
      cDESCRICAO := left(CLI1->Razao,50)
   endif

   if ! empty(ITEN_ROM->Cod_conv)
      CONVENIO->(Dbseek(ITEN_ROM->Cod_conv))
      CLI1->(dbseek(CONVENIO->Cod_cli))
      cDESCRICAO := left(CLI1->Razao,50)
   endif


return cDESCRICAO

function f206c
   local cDESCRICAO := space(6)
   FAT->(Dbsetorder(1))
   if ! empty(ITEN_ROM->Cod_fat)
      FAT->(Dbseek(ITEN_ROM->Cod_fat))
      cDESCRICAO := left(FAT->Num_fatura,6)
   endif

   if ! empty(ITEN_ROM->Cod_conv)
      cDESCRICAO := "Convenio"
   endif


return cDESCRICAO


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f206d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(08,08,"B206B","QBLOC.GLO",1)
      i_6processa_acao()
   endif


   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_6processa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_ROM->Cod_fat            , "@R 99999"           )
      FAT->(Dbseek(ITEN_ROM->Cod_fat))
      CLI1->(dbseek(FAT->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40)                                )
      qrsay ( XNIVEL++ , FAT->Num_fatura                                     )


      qrsay ( XNIVEL++ , ITEN_ROM->Cod_conv            , "@R 99999"           )
      CONVENIO->(Dbseek(ITEN_ROM->Cod_conv))
      CLI1->(dbseek(CONVENIO->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40)                                )


   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_fat() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_fat(-1,0,@fCOD_FAT                      ) } ,"COD_FAT"})
   aadd(aEDICAO,{{ || NIL                                            } ,NIL     })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL     })

   aadd(aEDICAO,{{ || view_conv(-1,0,@fCOD_CONV                     ) } ,"COD_CONV"})
   aadd(aEDICAO,{{ || NIL                                            } ,NIL     })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL     })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_ROM->(qpublicfields())

   iif(cOPCAO=="I",ITEN_ROM->(qinitfields()),ITEN_ROM->(qcopyfields()))

   XNIVEL := 1

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_ROM->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if ROMANEIO->(qrlock()) .and. ITEN_ROM->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_ROMA := fCODIGO
      endif

      ITEN_ROM->(qreplacefields())
      ITEN_ROM->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "COD_FAT"
           if ! empty(fCod_conv).and. ! empty(fCod_fat)
                qmensa("Nao e permitida de inclusao de NF + Convenio...")
                return .f.
           endif

           if ! empty(fCOD_FAT)
              qrsay(XNIVEL,fCOD_FAT:=strzero(val(fCOD_FAT),5))

              if ! FAT->(dbseek(fCOD_FAT))
                 qmensa("Pedido n„o encontrado !","B")
                 return .F.
               else
                 if ! CLI1->(Dbseek(FAT->Cod_cli))
                    qmensa("Cliente n„o encontrado !","B")
                    return .F.
                 endif
              endif
              qrsay ( XNIVEL+1 , left(CLI1->Razao,40) )
              qrsay ( XNIVEL+2 , left(FAT->Num_fatura,6) )
           endif

      case cCAMPO == "COD_CONV"

           if ! empty(fCod_conv).and. ! empty(fCod_fat)
                qmensa("Nao e permitida de inclusao de NF + Convenio...")
                return .f.
           endif


           if ! empty(fCOD_CONV)
              qrsay(XNIVEL,fCOD_CONV:=strzero(val(fCOD_CONV),5))

              if ! CONVENIO->(dbseek(fCOD_CONV))
                 qmensa("convenio n„o encontrado !","B")
                 return .F.
               else
                 if ! CLI1->(Dbseek(CONVENIO->Cod_cli))
                    qmensa("Cliente n„o encontrado !","B")
                    return .F.
                 endif
              endif
              qrsay ( XNIVEL+1 , left(CLI1->Razao,40) )
//              qrsay ( XNIVEL+2 , left(CONVENIO->Codigo,5) )
           endif



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO PEDIDO  _____________________________________

static function i_exc_itens_fat

   if qconf("Confirma exclus„o do Produto ?")

      // rotina que volta a quantidade em estoque pois foi baixa no pedido

      if ITEN_ROM->(qrlock())
         ITEN_ROM->(dbdelete())
         ITEN_ROM->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEVOLUCAO de ITENS DO PEDIDO  _____________________________________


////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc

ITEN_ROM->(qview({{"Cod_Prod/Cod."                                        ,2},;
                  {"f206a()/Descri‡„o"                                    ,0},;
                  {"f206c()/Nota Fiscal"                                  ,0}},;
                  "13002179S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_ROM->cod_roma == ROMANEIO->Codigo",{||f206top()},{||f206bot()}},;
                 "<ESC> para sair" ))

return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR PEDIDO ________________________________________________

static function i_imprime

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0
   local aFAT :=  {}
   local asFAT := {}
   local lTEM := .F.
   local cPROD := space(5)
   local nQUANT := 0
   local cNOTAS := ""
   local cCONV  := ""
   local nTOT_NF := 0

   cTITULO := "ROMANEIO No.: "+CODIGO+"   DATA...: "+dtoc(ROMANEIO->Data)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   ITEN_FAT->(Dbsetorder(2))
   PROD->(Dbsetorder(4))
   CONVENIO->(dbsetorder(1))
   FAT->(dbsetorder(1))


   ITEN_ROM->(Dbseek(ROMANEIO->Codigo))

   do while ! ITEN_ROM->(eof()) .and. ITEN_ROM->Cod_roma == ROMANEIO->Codigo


      if ! empty(ITEN_ROM->Cod_fat)
         FAT->(Dbseek(ITEN_ROM->Cod_fat))

         ITEN_FAT->(dbsetorder(2))
         ITEN_FAT->(Dbseek(FAT->Codigo))

         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
            aadd(aFAT,{ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade})
            lTEM := .T.
            ITEN_FAT->(Dbskip())
         enddo

         cNOTAS := cNOTAS + FAT->Num_fatura + "/ "
      endif

      if ! empty(ITEN_ROM->Cod_conv)
         CONVENIO->(Dbseek(ITEN_ROM->Cod_conv))

         ITEN_CON->(dbsetorder(1))
         ITEN_CON->(Dbseek(CONVENIO->Codigo))

         do while ITEN_CON->cod_conv == CONVENIO->Codigo .and. ! ITEN_CON->(eof())
            aadd(aFAT,{ITEN_CON->Cod_prod,ITEN_CON->Quantidade})
            lTEM := .T.
            ITEN_CON->(Dbskip())
         enddo

         cCONV  := cCONV  + CONVENIO->Codigo

      endif

      ITEN_ROM->(Dbskip())
   enddo


   nQUANT := 0

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM

       if ! qinitprn() ; return ; endif

       cPROD := asFAT[1,1]

       nCONT := 1
       do while  nCONT <= len(asFAT)

          if ! qlineprn() ; exit ; endif

          if XPAGINA == 0 .or. prow() > 56
             qpageprn()
             @ prow(),pcol() say XCOND0
             qcabecprn(cTITULO,80)
             @ prow()+1,0 say "CODIGO....: " + ROMANEIO->Codigo + " - DATA....: " + dtoc(ROMANEIO->Data)
             @ prow()+1,0 say "OBSERVACAO: " + left(ROMANEIO->Obs,50)
             @ prow()+1,0 say replicate("-",80)
             @ prow(),pcol() say XCOND0
             @ prow()+1,0 say "Codigo  Produto                                                            Qtde"
             @ prow()+1,0 say replicate("-",80)
          endif

          nQUANT += asFAT[nCONT,2]

          nCONT++
          if nCONT > len(asFAT)
             nCONT := len(asFAT)
             exit
          endif

          if asFAT[nCONT,1] != cPROD
             @ prow()+1,00 say cPROD
             PROD->(Dbseek(cPROD))
             @ prow()  ,08 say PROD->Descricao
             @ prow()  ,72 say transf(nQUANT,"@R 9999999")

             cPROD := asFAT[nCONT,1]
             nQUANT     := 0
          endif
       enddo

       @ prow()+1,00 say cPROD
       PROD->(Dbseek(cPROD))
       @ prow()  ,08 say PROD->Descricao
       @ prow()  ,72 say transf(nQUANT,"@R 9999999")

       nQUANT     := 0
   endif

   @ prow()+1,0 say replicate("-",80)

   qpageprn()

   qcabecprn("RELACAO DE NOTAS",80)
   @ prow()+1,0 say "CODIGO....: " + ROMANEIO->Codigo + " - DATA....: " + dtoc(ROMANEIO->Data)
   @ prow()+1,0 say "OBSERVACAO: " + left(ROMANEIO->Obs,50)
   @ prow()+1,0 say replicate("-",80)
   @ prow(),pcol() say XCOND0
  // @ prow()+1,0 say "Pedido    Cliente                                        Nota Fiscal       Valor"
   @ prow()+1,0 say "Pedido    Cliente                              N.F.       Valor Horario Visto"
   @ prow()+1,0 say "                                                                Entrega      "


   @ prow()+1,0 say replicate("-",80)


   ITEN_ROM->(Dbseek(ROMANEIO->Codigo))

   do while ! ITEN_ROM->(eof()) .and. ITEN_ROM->Cod_roma == ROMANEIO->Codigo

      if XPAGINA == 0 .or. prow() > 56
         qpageprn()
         @ prow(),pcol() say XCOND0
         qcabecprn("RELACAO DE NOTAS",80)
         @ prow()+1,0 say "CODIGO....: " + ROMANEIO->Codigo + " - DATA....: " + dtoc(ROMANEIO->Data)
         @ prow()+1,0 say "OBSERVACAO: " + left(ROMANEIO->Obs,50)
         @ prow()+1,0 say replicate("-",80)
         @ prow(),pcol() say XCOND0
         @ prow()+1,0 say replicate("-",80)
      endif

      if empty(ITEN_ROM->Cod_fat)
         ITEN_ROM->(dbskip())
         loop
      endif

      FAT->(Dbseek(ITEN_ROM->Cod_fat))
      ITEN_FAT->(dbsetorder(2))
      ITEN_FAT->(Dbseek(FAT->Codigo))
      nTOT_NF := 0

      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(Eof())
        nTOT_NF += ITEN_FAT->Quantidade * ITEN_FAT->Vl_Unitar
        ITEN_FAT->(Dbskip())
      enddo

      CLI1->(dbseek(FAT->Cod_cli))
      @ prow()+1,00 say ITEN_ROM->Cod_fat
      @ prow()  ,10 say left(CLI1->Razao,35)
      @ prow()  ,47 say FAT->Num_fatura
      @ prow()  ,54 say transform(nTOT_NF,"@E 999,999.99")
      @ prow()  ,66 say "__:__"
      @ prow()  ,71 say " ________"


      nTOT_NF := 0

      ITEN_ROM->(Dbskip())

   enddo

   @ prow()+1,0 say replicate("-",80)

   qpageprn()

   qcabecprn("RELACAO DE CONVENIOS",80)
   @ prow()+1,0 say "CODIGO....: " + ROMANEIO->Codigo + " - DATA....: " + dtoc(ROMANEIO->Data)
   @ prow()+1,0 say "OBSERVACAO: " + left(ROMANEIO->Obs,50)
   @ prow()+1,0 say replicate("-",80)
   @ prow(),pcol() say XCOND0
   @ prow()+1,0 say "Codigo    Cliente                                         Valor Horario Visto"
   @ prow()+1,0 say "                                                                Entrega      "


   @ prow()+1,0 say replicate("-",80)


   ITEN_ROM->(Dbseek(ROMANEIO->Codigo))

   do while ! ITEN_ROM->(eof()) .and. ITEN_ROM->Cod_roma == ROMANEIO->Codigo

      if XPAGINA == 0 .or. prow() > 56
         qpageprn()
         @ prow(),pcol() say XCOND0
         qcabecprn("RELACAO DE CONVENIOS",80)
         @ prow()+1,0 say "CODIGO....: " + ROMANEIO->Codigo + " - DATA....: " + dtoc(ROMANEIO->Data)
         @ prow()+1,0 say "OBSERVACAO: " + left(ROMANEIO->Obs,50)
         @ prow()+1,0 say replicate("-",80)
         @ prow(),pcol() say XCOND0
         @ prow()+1,0 say replicate("-",80)
      endif

      if empty(ITEN_ROM->cod_conv)
         ITEN_ROM->(dbskip())
         loop
      endif

      CONVENIO->(Dbseek(ITEN_ROM->Cod_conv))
      ITEN_CON->(dbsetorder(1))
      ITEN_CON->(Dbseek(CONVENIO->Codigo))
      nTOT_NF := 0

      do while ITEN_CON->Cod_conv == CONVENIO->Codigo .and. ! ITEN_CON->(Eof())
        nTOT_NF += ITEN_CON->Quantidade * ITEN_CON->Vl_Unitar
        ITEN_CON->(Dbskip())
      enddo

      CLI1->(dbseek(CONVENIO->Cod_cli))
      @ prow()+1,00 say ITEN_ROM->Cod_conv
      @ prow()  ,10 say left(CLI1->Razao,35)
      @ prow()  ,47 say ""//FAT->Num_fatura
      @ prow()  ,54 say transform(nTOT_NF,"@E 999,999.99")
      @ prow()  ,66 say "__:__"
      @ prow()  ,71 say " ________"


      nTOT_NF := 0

      ITEN_ROM->(Dbskip())

   enddo

   @ prow()+1,0 say replicate("-",80)




   qstopprn()

return



