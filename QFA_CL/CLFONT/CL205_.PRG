/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LANCAMENTO DE PEDIDO DE VENDA
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: Dezembro de 2006
// OBS........:

function cl205
#include "inkey.ch"

private fTOTAL := 0
private cTIPO  := ""
private nITENS := 0
private cES    := " "
private fPARC  := 0
private nCOMISSAO := 0
private lALT   := .F.
private sBLOC1  := qlbloc("B205D","QBLOC.GLO")

CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE PEDIDO DE VENDA ___________________________________________
FAT->(dbsetfilter({|| FAT->No_nf},'FAT->No_nF'))

FAT->(qview({{"Codigo/Pedido"           ,1},;
             {"Dt_emissao/Emissao"      ,2},;
             {"left(Cliente,35)/Cliente",7},;
             {"Imp205()/Impresso",0}},"P",;
             {NIL,"i_205c",NIL,NIL},;
              NIL,q_msg_acesso_usr()+"/im<P>rime "))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function i_205a
   CLI1->(dbseek(FAT->Cod_cli))
return left(CLI1->Razao,25)

function imp205
cRET := ""
if FAT->Impresso
   cRET := "SIM"
else
   cRET := "   "
endif

return cRET


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function i_205b
   CCUSTO->(dbseek(FAT->C_custo))
return left(CCUSTO->Descricao,18)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_205c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))


   iif(cOPCAO == "P", i_imprime(),)
   iif(cOPCAO == "R", i_cancela(),)

   if cOPCAO == "A" .and. FAT->Cancelado
      qmensa("Nao e possivel alterar Pedido Cancelado !","B")
      return .F.
   endif

   if cOPCAO == "A" .and. FAT->Impresso
      qmensa("Nao e possivel alterar Pedido Impresso !","B")
      return .F.
   endif


   if cOPCAO $ XUSRA

      iif(cOPCAO == "A", lALT := .T.,)

      qlbloc(5,0,"B205A","QBLOC.GLO",1)

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
   local bESCAPE := {||empty(fDT_EMISSAO).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

   fTOTAL := 0
   nCOMISSAO:= 0
   fPARC  := 0
   cES    := " "

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,17 , FAT->Codigo           )
      qsay ( 06,42 , dtoc(FAT->Dt_Emissao) )
      qsay ( 07,24 , FAT->Cod_Cli          ) ; CLI1->(dbseek(FAT->Cod_cli))
      qsay ( 07,32 , left(CLI1->Razao,35)  )
      qsay ( 08,24 , FAT->Cod_vended       ) ; VEND->(dbseek(FAT->Cod_vended))
      qsay ( 08,32 , left(VEND->Nome,35)   )
      qsay ( 09,24 , FAT->Cod_repres       ) ; REPRES->(dbseek(FAT->Cod_repres))
      qsay ( 09,32 , left(REPRES->Razao,35)   )
      qsay ( 10,24 , FAT->Filial           ) ; FILIAL->(dbseek(FAT->Filial))
      qsay ( 10,31 , left(FILIAL->Razao,35))
      qsay ( 11,24,  qabrev(FAT->Tipo,"123456789", {"Venda","Bonificacao","Doacao","Troca","Emprestimo","Amostra","Devolucao de Venda","Devolucao de Emprestimo","Transferencia"}))
      qsay ( 11,59,  FAT->Tipo_doc);TIPO_DOC->(dbseek(FAT->Tipo_doc))
      qsay ( 11,64,  left(Tipo_doc->Descricao,14))




      qsay ( 12,13, transform(FAT->Aliq_desc,"@E 99.99")    )
      qsay ( 13,14 , Left(FAT->Obs,43)             )


      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO"       })
   aadd(aEDICAO,{{ || qgetx(6,42,@fDT_EMISSAO,"@D",                    )} ,"DT_EMISSAO"   })

   aadd(aEDICAO,{{ || view_cli2(7,24,@fCOD_CLI                          )} ,"COD_CLI"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   aadd(aEDICAO,{{ || view_vend(8,24,@fCOD_VENDED                      )} ,"COD_VENDED"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor

   aadd(aEDICAO,{{ || view_repres(9,24,@fCOD_REPRES                      )} ,"COD_REPRES"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do representante


   aadd(aEDICAO,{{ || view_filial(10,24,@fFILIAL                        )} ,"FILIAL"       })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial

   aadd(aEDICAO,{{ || qesco(11,24,@fTIPO ,sBLOC1                       )}  ,"TIPO" })

   aadd(aEDICAO,{{ || view_doc(11,59,@fTIPO_DOC                    )} ,"TIPO_DOC"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do Tipo do Documento

   aadd(aEDICAO,{{ || qgetx(12,13,@fALIQ_DESC,"99.99",NIL              )}   ,"ALIQ_DESC"  })

   aadd(aEDICAO,{{ || qgetx(13,14,@fOBS,"@!S43",NIL                    )}   ,"OBS"        })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      FAT->(qpublicfields())

      iif(cOPCAO=="I", FAT->(qinitfields()), FAT->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________
      if cOPCAO == "A"
         cTIPO := fTIPO
      endif

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );FAT->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if NUM_PEDI->(qrlock())

         // AQUI INCREMENTA CODIGO DO PEDIDO DE VENDA ____________

         if cOPCAO == "I"
            replace NUM_PEDI->Pedido with NUM_PEDI->Pedido + 1
            qsay(6,17,fCODIGO := strzero(NUM_PEDI->Pedido,5) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif

      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      if cOPCAO == "I"
         if fTIPO == "1"
            fCOD_CFOP := "5102"
            fNUM_FATURA := "P"+fCODIGO
         endif

         if fTIPO == "7"
            fCOD_CFOP := "1202"
            fNUM_FATURA := "P"+fCODIGO
         endif

         if fTIPO == "9"
            fCOD_CFOP := "5152"
            fNUM_FATURA := "P"+fCODIGO
         endif

      endif


      if FAT->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         fFATURAR := .F.
         fUSER := XUSRIDT
         FAT->(qreplacefields())
         replace FAT->Cliente with fCLIENTE
      endif

      dbunlockall()

      i_proc_ped()
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

           if empty(fDT_EMISSAO) ; return .F. ; endif


      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI) ; return .F. ; endif
           qsay(7,24,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif

           qsay(7,32,left(CLI1->Razao,40))

           if cOPCAO == "I" ; fCOD_VENDED := CLI1->Cod_vend   ; endif
           if cOPCAO == "I" ; fCOD_REPRES := CLI1->Cod_repres ; endif
           fCLIENTE := CLI1->Razao
           fTIPO_DOC := CLI1->Tipo_doc

      case cCAMPO == "COD_REPRES"
           if empty(fCOD_REPRES) ; return .F. ; endif
           qsay(9,24,fCOD_REPRES:=strzero(val(fCOD_REPRES),5))
           if ! REPRES->(dbseek(fCOD_REPRES))
              qmensa("Representante n„o encontrado !","B")
              return .F.
           endif
           qsay(9,32,left(REPRES->Razao,35))

      case cCAMPO == "COD_VENDED"
           if empty(fCOD_VENDED) ; return .F. ; endif
           qsay(8,24,fCOD_VENDED:=strzero(val(fCOD_VENDED),5))
           if ! VEND->(dbseek(fCOD_VENDED))
              qmensa("Vendedor n„o encontrado !","B")
              return .F.
           endif
           nCOMISSAO := VEND->Comis
           qsay(8,32,left(VEND->Nome,35))


      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(10,24,fFILIAL)
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(10,31,left(FILIAL->Razao,40))


      case cCAMPO == "TIPO"
           if empty(fTIPO) ; return .F. ; endif
           if cOPCAO == "A"
              if fTIPO != cTIPO
                 Qmensa("Nao e permitido alterar o Tipo!","B")
                 return .F.
              endif
           endif
           qsay(11,24,qabrev(fTIPO,"123456789",{"Venda","Bonificacao","Doacao","Troca","Emprestimo","Amostra","Devolucao de Venda","Devolucao de Emprestimo","Transferencia"}))

           if fTIPO $ "1-2-3-4-5-6-9"
              cES := "S"
              fES := cES
           else
              cES := "E"
              fES := cES
           Endif

           fNO_NF := .T.


      case cCAMPO == "TIPO_DOC"

           if ! empty(fTIPO_DOC)
              qsay(11,59,fTIPO_DOC:=strzero(val(fTIPO_DOC),2))
           else
              return .F.
           endif

           if ! TIPO_DOC->(dbseek(fTIPO_DOC))
              qmensa("Tipo de Documento n„o encontrado !")
              return .F.
           endif
           qsay(11,64,left(TIPO_DOC->Descricao,14))
          

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR PEDIDO DE VENDA __________________________________________

static function i_exclusao

   if CONFIG->Modelo_NF != "01"
      if FAT->Cancelado
         Qmensa("Pedido cancelado, ExclusÆo Negada!!","B")
         return .f.
      endif

      if FAT->Impresso
         Qmensa("Pedido Impresso ! ExclusÆo Negada!!","B")
         return .f.
      endif
   endif


   if qconf("Confirma exclus„o deste Pedido de Venda ?")

      /// rotina para voltar o estoque dos produtos digitados no Pedido Deletado !

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      if FAT->Tipo $ "1-2-3-4-5-6-9"
         cES := "S"
      else
         cES := "E"
      Endif

      INVENT->(dbclearfilter())
      INVENT->(dbsetorder(1))

      do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo


         if FAT->Enviado == .F.   .and. CONFIG->Estoque =="S"
            if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote)) .and. INVENT->(qrlock())
               if cES == "S" //Se For saida Aumenta estoque senao diminui
                  replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_FAT->Quantidade)
               else
                  replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_FAT->Quantidade)
               endif
               INVENT->(qunlock())
            else
               qmensa("Lote nao encontrado !","B")
               return .F.
            endif
         Endif
         ITEN_FAT->(Dbskip())

      enddo

      if ITEN_FAT->(qflock()) .and. FAT->(qrlock())

         ITEN_FAT->(dbseek(FAT->Codigo))

         do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo // itens do pedido (produtos)
            ITEN_FAT->(dbdelete())
            ITEN_FAT->(dbskip())
         enddo

         DUP_FAT->(dbseek(FAT->Codigo+"01"))

         do while ! DUP_FAT->(eof()) .and. DUP_FAT->(qrlock()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo // duplicatas do pedido
            DUP_FAT->(dbdelete())
            DUP_FAT->(dbskip())
         enddo

         FAT->(dbdelete())
         FAT->(qunlock())
         ITEN_FAT->(qunlock())
         DUP_FAT->(qunlock())

      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc_ped


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

if cOPCAO == "A"
   fTOTAL := 0
   lALT := .T.
endif

PROD->(Dbsetorder(4))

if CONFIG->Modelo_fat == "1"
   ITEN_FAT->(qview({{"f205m1()/Cod."                                        ,0},;
                     {"f205mar()/Faturar"                                      ,0},;
                     {"f205a()/Descri‡„o"                                    ,0},;
                     {"f205m()/ref"                                          ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999')/Quant."           ,0},;
                     {"f205b()/Un."                                          ,0},;
                     {"f205c()/Val. Total"                                   ,0}},;
                     "14002179S",;
                     {NIL,"f205d",NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f205top()},{||f205bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc./<M>arcar/<D>uplicatas"))
else
   ITEN_FAT->(qview({{"Cod_prod/Cod."                                        ,2},;
                     {"f205a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f205b()/Un."                                          ,0},;
                     {"f205c()/Val. Total"                                   ,0}},;
                     "14002179S",;
                     {NIL,"f205d",NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f205top()},{||f205bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc./<D>uplicatas"))
endif
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f205top
   ITEN_FAT->(dbsetorder(1))
   ITEN_FAT->(dbseek(FAT->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f205bot
   ITEN_FAT->(dbsetorder(1))
   ITEN_FAT->(qseekn(FAT->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f205a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_FAT->Cod_prod)
      PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,30)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return cDESCRICAO


function f205mar

   local cDESCRICAO := space(3)
   if ITEN_FAT->Marcado == "*"
      cDESCRICAO := "SIM"
   else
      cDESCRICAO := "   "
   endif

return cDESCRICAO


function f205m
   local cFABR := space(4)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_FAT->Cod_prod)
      PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      cFABR := left(PROD->Cod_fabr,4)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   rtrim(cFABR)

return cFABR

function f205m1
   local cASS := space(7)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_FAT->Cod_prod)
      PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      cASS := left(PROD->Cod_ass,7)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   rtrim(cASS)

return cASS


/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f205b
   PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
   UNIDADE->(dbseek(PROD->Unidade))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f205c
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return transform(ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade,"@E 999,999.99")

function f205cl
   INVENT->(DbSeek(FAT->Filial+right(PROD->Codigo,5)+"0000000000" ))

return INVENT->Quant_Atu


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f205d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      if CONFIG->Modelo_fat == "B"
         qlbloc(08,08,"B205BG","QBLOC.GLO",1)
     elseif CONFIG->Modelo_2 $ "9"
         qlbloc(08,08,"B205BK","QBLOC.GLO",1)
     elseif CONFIG->Modelo_fat == "1"
         qlbloc(08,08,"B205B1","QBLOC.GLO",1)
     else
         qlbloc(08,08,"B205B","QBLOC.GLO",1)
     endif

     if cOPCAO == "A" .and. FAT->Impresso
        qmensa("Pedido Impresso, Proibida a Alteracao !","B")
        return .F.
     endif

     if cOPCAO == "I" .and. FAT->Impresso
        qmensa("Pedido Impresso, Proibida a Inclusao !","B")
        return .F.
     endif


      i_processa_item()
   endif


   setcursor(nCURSOR)

return ""






/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

function i_processa_item

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   if lALT  // se alteracao - zera o totalizador e refaz a soma das parcelas
      fPARC := 0
   endif

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_FAT->Cod_prod            , "@R 99999"                    ) ; PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                                      )
      qrsay ( XNIVEL++ , ITEN_FAT->Num_lote                                            )
      qrsay ( XNIVEL++ , qabrev(ITEN_FAT->Prod_ser,"12", {"N„o","Sim"})                )
      if CONFIG->Modelo_fat == "1"
         qrsay ( XNIVEL++ , ITEN_FAT->Preco_vend, "@E 999,999.99"        )
         qrsay ( XNIVEL++ , ITEN_FAT->Desc_prod, "@E 99.99"     )
         qrsay ( XNIVEL++ , ITEN_FAT->Vlr_Desc , "@E 999,999.99"                       )
      endif
      qrsay ( XNIVEL++ , ITEN_FAT->Vl_unitar, "@E 9,999,999.99999"                       )
      qrsay ( XNIVEL++ , ITEN_FAT->Quantidade                                          )
      qrsay ( XNIVEL++ , transform(ITEN_FAT->Icms,"@E 99.99")                          )
      qrsay ( XNIVEL++ , transform(PROD->Ipi, "@E 99.99")                              )
      qrsay ( XNIVEL++ , ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade, "@E 9,999,999.99" )
      qrsay ( XNIVEL++ , transform(ITEN_FAT->Comissao, "@E 99.99" )                    )
      if CONFIG->Modelo_fat == "1"
         qrsay ( XNIVEL++ , transform(ITEN_FAT->Comi_repre, "@E 99.99" )                    )
      endif
      if CONFIG->Modelo_fat != "B"
         qrsay ( XNIVEL++ , ITEN_FAT->Cod_sit          ,"@R 999"   );SIT_TRIB->(dbseek(ITEN_FAT->Cod_sit))
         qrsay ( XNIVEL++ , left(SIT_TRIB->Descricao,30)                                  )
         qrsay ( XNIVEL++ , ITEN_FAT->Classif                  )

         if CONFIG->Modelo_2 == "3"
            qrsay ( XNIVEL++ , ITEN_FAT->Num_nf                )
         endif
      endif

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_fat() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fNUM_LOTE, "@r 9999999999"   ) } ,"NUM_LOTE"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVL_UNITAR , "@e 9,999,999.99999") } ,"VL_UNITAR" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@r 99999.999"      ) } ,"QUANTIDADE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICMS, "99.99"                   ) } ,"ICMS"      })
   aadd(aEDICAO,{{ || NIL                                            } ,"IPI"       })
   aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMISSAO, "99.99"               ) } ,"COMISSAO"  })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_FAT->(qpublicfields())

   iif(cOPCAO=="I",ITEN_FAT->(qinitfields()),ITEN_FAT->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_FAT->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if FAT->(qrlock()) .and. ITEN_FAT->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fNUM_FAT := fCODIGO
         fDATA    := fDT_EMISSAO
      endif

      fDATA    := fDT_EMISSAO
      INVENT->(Dbsetorder(1))

      if CONFIG->Estoque == "S"
      if cOPCAO == "A" // volta o estoque anterior a alteracao, para baixar corretamente a quantidade
         if FAT->Enviado == .F.
            if INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE)) .and. INVENT->(qrlock())
               if FAT->Es == "S"
                  replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_FAT->Quantidade)
               else
                  replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_FAT->Quantidade)
               endif
               INVENT->(qunlock())
            else
               qmensa("Lote nao encontrado !","B")
               return .F.
            endif
         endif
      endif
      endif

      ITEN_FAT->(qreplacefields())
      ITEN_FAT->(qunlock())

      fTOTAL := fTOTAL + (ITEN_FAT->Vl_unitar*fQUANTIDADE)

      // rotina que baixa o produto do Estoque quando e' confirmado no pedido

      if CONFIG->Estoque == "S"
      if FAT->Enviado == .F.
         if INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE)) .and. INVENT->(qrlock())
            if FAT->Es == "S"
               replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_FAT->Quantidade)
            else
               replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_FAT->Quantidade)
            endif
            INVENT->(qunlock())
         else
            qmensa("Lote nao encontrado !","B")
            return .F.
         endif
      Endif
      endif
   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )
local nORDEM := 0
local nREG   := 0
local nVAL_UNI := 0

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "COD_PROD"

           INVENT->(dbClearFilter())
           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

           //nORDEM := ITEN_FAT->(Indexord())
           //nREG   := ITEN_FAT->(recno())

           //if ITEN_FAT->(dbseek(FAT->Codigo+fCOD_PROD))
           //   qmensa("Produto ja cadastrado, InclusÆo negada !","B")
           //   return .F.
           //endif

           //ITEN_FAT->(Dbsetorder(nORDEM))
           //ITEN_FAT->(Dbgoto(nREG))
           //nREG := 0
           //nORDEm := 0

           PROD->(Dbsetorder(4))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           INVENT->(DbSetFilter({|| INVENT->Cod_prod == fCOD_PROD },'Cod_prod == fCOD_PROD'))

           if CONFIG->Modelo_fat == "1"
              qrsay ( XNIVEL+1 , left(PROD->Descricao,20)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
           else
              qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )
           endif

           qrsay ( XNIVEL+3 , qabrev(PROD->Prod_iss,"SN", {"Sim","N„o"}))

           fPROD_SER:=qabrev(PROD->Prod_iss,"SN", {"2","1"})

           if CONFIG->Modelo_fat == "9"
              fVL_UNITAR := PROD->Preco_unit
              fPRECO_VEND := PROD->Preco_unit

           else
              if left(FAT->Cod_cfop,3) $ "510-610-511-611-512-612-710-711-712-220-221"
                 if CONFIG->Modelo_2 $ "8*5"
                   fVL_UNITAR := PROD->Preco_cons - (PROD->Preco_Cons * (CLI1->Comis_repr/100 ))
                 else
                   fVL_UNITAR  := PROD->Preco_cons
                   fPRECO_VEND := PROD->Preco_cons
                   fDESC_PROD  := FAT->Aliq_desc
                 endif
              endif

              if left(FAT->Cod_Cfop,4) $ "5910-5911-5912-5917-6910-6911-6912-6917"
                 fVL_UNITAR := PROD->Preco_cust
                 fPRECo_VEND:= PROD->Preco_cust
              endif
           endif

           //////////////////////////////////////////////////////////////////////////
           // TABELA DE PRECOS POR CLIENTE __________________________________________

           if CONFIG->Modelo_2 == "7"
              CLI_PR->(dbsetorder(2))
              if CLI_PR->(dbseek(FAT->Cod_cli))

                 ITEN_GP->(Dbsetorder(2))
                 if ITEN_GP->(DbSeek(CLI_PR->Cod_grupo+right(PROD->Codigo,5)))
                    fVL_UNITAR := ITEN_GP->Valor
                 else
                    fVL_UNITAR := PROD->Preco_cons
                 endif
              else
                 fVL_UNITAR := PROD->Preco_cons
              endif
           endif

           if ! empty(FAT->Num_fatura)
              fMARCADO := "*"
           endif

           fPRECO_CUST := PROD->Preco_cust

           Return .T.

      case cCAMPO == "DESC_PROD"
           if FAT->Aliq_desc <> 0 .and. fDESC_PROD <> FAT->Aliq_desc
              Qmensa("Desconto no Produto diferente da Aliquota do Pedido!!!","B")
              return .F.
           endif
           fVLR_DESC := fPRECO_VEND * (fDESC_PROD/100)
           fVL_UNITAR := fPRECO_VEND - fVLR_DESC
           qrsay(XNIVEL+1,fVLR_DESC,"@E 999,999.99")
           qrsay(XNIVEL+2,fVL_UNITAR,"@E 999,999.99999")

      case cCAMPO == "QUANTIDADE"

           if CONFIG->Modelo_2 != "0"
              if empty(fQUANTIDADE) ; return .F. ; endif
           endif

           if CONFIG->Estoque == "S" .and. (CONFIG->Modelo_fat != "1" .or. ! empty(FAT->Num_fatura) )
               INVENT->(dbsetorder(1))
               if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                  qmensa("N„o Existe este Produto em Estoque - Verifique o Inventario ! ","B")
                  return .F.
               endif

               if INVENT->Quant_atu < fQUANTIDADE
                  qmensa("No estoque tem "+ transform(INVENT->Quant_atu,"@E 999,999.99") + " Unidades","B")
                  if FAT->Tipo $ "1-2-3-4-5-6-9"
                     return .F.
                  endif
               endif
               Return .T.
           endif

      case cCAMPO == "VL_UNITAR"

           if CONFIG->Modelo_2 != "0"
             if empty(fVL_UNITAR) ; return .F. ; endif
           endif

           if CONFIG->Modelo_2 == "7"
              CLI_PR->(dbsetorder(2))
              if CLI_PR->(dbseek(FAT->Cod_cli))

                 ITEN_GP->(Dbsetorder(2))
                 if ITEN_GP->(DbSeek(CLI_PR->Cod_grupo+right(PROD->Codigo,5)))
                    fVAL_UNI := ITEN_GP->Valor
                 else
                    fVAL_UNI := PROD->Preco_cons
                 endif
              else
                 fVAL_UNI := PROD->Preco_cons
              endif
           endif

           if fVL_UNITAR < fVAL_UNI
              qmensa("Valor abaixo do preco de Tabela. Verifique!","B")
              return .F.
           endif

           if CONFIG->Estoque == "S"
             INVENT->(dbsetorder(1))
             if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                qmensa("N„o Existe Inventario deste produto !","B")
             else
                qmensa("No estoque tem "+ transform(INVENT->Quant_atu,"@E 999,999.99") + " Unidades","B")
             endif
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           ESTADO->(Dbseek(CGM->Estado))
           fICMS := ESTADO->Aliq_dest

           fCOMISSAO := nCOMISSAO
           if CONFIG->Modelo_2 == "1"
              fCOMISSAO := 7
           endif
           fCALC_DESC := "N"
           fICMS_SUBST := "N"
           fCOD_SIT   := "000"

           if cOPCAO == "I" .and. CONFIG->Modelo_fat == "1"
              fCOMI_REPRE := 10
           endif

           if cOPCAO == "I" .and. CONFIG->Modelo_2 == "7"
              fCOMI_REPRE := 3
           endif



           Return .t.

      case cCAMPO == "IPI"
           if fICMS <> 0
              qrsay ( XNIVEL , transform(PROD->IPI, "@E 99.99") )
           endif
           qrsay ( XNIVEL+1, transform(fVL_UNITAR*fQUANTIDADE,"@E 9,999,999.99"))
           Return .t.

      case cCAMPO == "CALC_DESC"
           qrsay(XNIVEL,qabrev(fCALC_DESC,"SN",{"Sim","N„o"}))
           Return .t.

      case cCAMPO == "ICMS_SUBST"
           qrsay(XNIVEL,qabrev(fICMS_SUBST,"SN",{"Sim","N„o"}))
           Return .t.

      case cCAMPO == "NUM_LOTE"
           if CONFIG->Estoque == "S"

              if empty(fNUM_LOTE)
                 fNUM_LOTE := "0000000000"
                 qrsay(XNIVEL,fNUM_LOTE)
              else
                 fNUM_LOTE := strzero(val(fNUM_LOTE),10)
                 qrsay(XNIVEL,fNUM_LOTE)
              endif

              INVENT->(Dbsetorder(1))
              if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                 qmensa("ccampo lote - N£mero de Lote deste Produto nÆo encontrado...","B")
                 fLOTE := "          "
                 return .F.
              endif

              if FAT->Tipo $ "1-2-3-4-5-6-9"
                 if INVENT->Quant_atu <= 0 .or. INVENT->Quant_atu < fQUANTIDADE
                    qmensa("Estoque Insufisciente !","B")
                    fLOTE := "          "
                    return .F.
                 endif
              endif

           endif

      case cCAMPO == "PREP_COD"

           qrsay(XNIVEL,fPREP_COD:=strzero(val(fPREP_COD),5))

           if ! PREP->(dbseek(fPREP_COD))
              qmensa("Preposto n„o encontrado !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(PREP->Descricao,40) )

      case cCAMPO == "COD_SIT"

           qrsay(XNIVEL,fCOD_SIT:=strzero(val(fCOD_SIT),3))

           if ! SIT_TRIB->(dbseek(fCOD_SIT))
              qmensa("Situacao Tributaria n„o encontrada !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(SIT_TRIB->Descricao,30) )

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO PEDIDO  _____________________________________

static function i_exc_itens_fat

   if FAT->Cancelado
      Qmensa("Pedido Cancelado! ExclusÆo Negada!!","B")
      return .f.
   endif

   if FAT->Impresso
      Qmensa("Pedido Impresso! ExclusÆo Negada!!","B")
      return .f.
   endif

   if qconf("Confirma exclus„o do Produto ?")

      INVENT->(Dbclearfilter())
      INVENT->(Dbsetorder(1))

      if CONFIG->Estoque == "S"
      // rotina que volta a quantidade em estoque pois foi baixa no pedido
      if FAT->Enviado == .F.
         if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote)) .and. INVENT->(qrlock())
            if FAT->Es == "S"
               replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_FAT->Quantidade)
            else
               replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_FAT->Quantidade)
            endif
            INVENT->(qunlock())
         else
            qmensa("Lote nao encontrado !","B")
            return .F.
         endif
      Endif
      endif

      if ITEN_FAT->(qrlock())
         ITEN_FAT->(dbdelete())
         ITEN_FAT->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEVOLUCAO de ITENS DO PEDIDO  _____________________________________


////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc
if CONFIG->Modelo_fat == "1"
   ITEN_FAT->(qview({{"f205m1()/Cod."                                       ,0},;
                     {"f205mar()/Faturar"                                      ,0},;
                     {"f205a()/Descri‡„o"                                    ,0},;
                     {"f205m()/Ref."                                         ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f205b()/Un."                                          ,0},;
                     {"f205c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f205top()},{||f205bot()}},;
                    "<ESC> para sair" ))
else
   ITEN_FAT->(qview({{"Cod_prod/Cod."                                       ,2},;
                     {"f205a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f205b()/Un."                                          ,0},;
                     {"f205c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f205top()},{||f205bot()}},;
                    "<ESC> para sair" ))

endif

return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR PEDIDO ________________________________________________

static function i_imprime

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0
   local nALIQ_ICMS := 0
   local nIPI := 0
   local nICMS := 0
   local cPESOBR := 0
   local cPESOLQ := 0
   cTITULO := "LISTAGEM DO PEDIDO No."+CODIGO+"   Data Emissao: "+dtoc(FAT->Dt_emissao)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,80)
      CLI1->(Dbseek(FAT->Cod_cli))
      REPRES->(Dbseek(FAT->Cod_repres))
      CGM->(Dbseek(CLI1->Cgm_ent))
      @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + left(CLI1->Razao,36) + "  Telefone: "+ CLI1->Fone1
      @ prow()+1,0 say "Fantasia: "+CLI1->Fantasia + " " + "Inscricao Estadual.: " + CLI1->Inscricao
      @ prow()+1,0 say "CNPJ....: "+fu_conv_cgccpf(CLI1->Cgccpf)
      @ prow()+1,0 say "Endereco: "+left(CLI1->End_ent,32) + " - " + left(CGM->Municipio,15) + " UF: "+CGM->Estado
      @ prow()+1,0 say "Bairro  : " + CLI1->Bairro_ent + "  CEP.: "+CLI1->Cep_ent
      @ prow()+1,0 say "Representante: "+ REPRES->Razao
      CFOP->(Dbseek(FAT->Cod_cfop))
      TIPO_DOC->(dbseek(FAT->Tipo_doc))
      @ prow()+1,0  say "Nat. de Operacao: " + qabrev(FAT->Tipo,"123456789", {"Venda","Bonificacao","Doacao","Troca","Emprestimo","Amostra","Devolucao de Venda","Devolucao de Emprestimo","Transferencia"})
      ROTA->(dbseek(CLI1->Cod_rota))
      @ prow()  ,45 say "Rota.: " + left(ROTA->Descricao,26)
      @ prow()+1,0 say "Observacao: "+left(FAT->Obs,70)
      @ prow()+1,0 say "Usuario(a) : "+FAT->User+" Tipo Pagto : "+FAT->Tipo_doc + " - "+ left(TIPO_DOC->Descricao,15)+" "+iif(CLI1->Dias > 0,strzero(CLI1->Dias,2)+" Dias.","")
      @ prow()+1,0 say replicate("-",80)
   endif

   @ prow(),pcol() say XCOND0
   @ prow()+1,0 say "Codigo  Qtde                  Produto                       Unitario       Total"
   @ prow()+1,0 say ""

   ITEN_FAT->(Dbseek(FAT->Codigo))

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(Dbseek(ITEN_FAT->Cod_prod))
      @ prow()+1,0  say left(PROD->Cod_fabr,4)
      @ prow()  ,6  say transform(ITEN_FAT->Quantidade, "@E 99999.99")
      @ prow()  ,16 say left(PROD->Descricao,18)
      @ prow()  ,36 say PROD->cOD_aSS
      if CONFIG->Modelo_NF == "01"
         @ prow()  ,46 say left(ITEN_FAT->Num_lote,10)
      else
         @ prow()  ,46 say left(PROD->Marca,10)
      endif

      if ! empty(PROD->Desconto) .and. ITEN_FAT->Calc_desc == "S"
         nDESC := PROD->Desconto/100
      else
         nDESC := 1
      endif

      @ prow()  ,58 say transform(round(ITEN_FAT->Vl_unitar * nDESC,2), "@E 999,999.99")
      @ prow()  ,70 say transform(ITEN_FAT->Quantidade * round(ITEN_FAT->Vl_unitar * nDESC,2), "@E 999,999.99")
      nTOT_PROD  := nTOT_PROD +  (ITEN_FAT->Quantidade * round(ITEN_FAT->Vl_unitar * nDESC,2))
      nALIQ_ICMS := ITEN_FAT->Icms

      nIPI  +=  ( ( ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar ) * ( PROD->Ipi / 100 ) )
      nICMS += ( ( ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar  ) * (ITEN_FAT->Icms/100) )
      cPESOBR := cPESOBR + (PROD->Peso_Bruto*ITEN_FAT->Quantidade)
      cPESOLQ := cPESOLQ + (PROD->Peso*ITEN_FAT->Quantidade)



      if ITEN_FAT->ICMS_SUBST == "S" // soma somente os produtos com icms subst. tributaria nos itens do pedido
         nICMS_SUBS := nICMS_SUBS +  (ITEN_FAT->Quantidade * round(ITEN_FAT->Vl_unitar * nDESC,2))
      endif

      nLIN++
      ITEN_FAT->(Dbskip())

   enddo

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())

   @ prow()+1,0 say replicate("-",80)

   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))
      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
         if DUP_FAT->Valor = 0
            exit
         endif
         @ prow()+1,00 say "Fatura No.: " + left(DUP_FAT->Num_fat,5)+"/"+Right(DUP_FAT->Num_fat,2)
         @ prow()  ,22 say "Vencimento: " + dtoc(DUP_FAT->Data_venc)
         @ prow()  ,62 say "Valor : "+ alltrim(transform(DUP_FAT->Valor , "@E 999,999,999.99"))
         DUP_FAT->(Dbskip())
      enddo
   endif

   @ prow()+1,0 say replicate("-",80)

   @ prow()+1,41 say " Valor dos Produtos      >"+transform(nTOT_PROD, "@E 99,999,999.99")
   @ prow()+1,41 say " Valor do  IPI           >"+transform(nIPI,  "@E 99,999,999.99")
   @ prow()+1,41 say " Valor do  ICMS          >"+transform(nICMS, "@E 99,999,999.99")
   @ prow()+1,0 say replicate("-",80)

   @ prow()+1,00 say " Peso Bruto----> "+transform(cPESOBR , "@R 999999999.999")
   @ prow()  ,41 say " Peso Liquido--> "+transform(cPESOLQ , "@R 999999999.999")
   @ prow()+1,0 say replicate("-",80)
      @ prow()+1,41 say " Valor do Pedido         >"+transform( nTOT_PROD+nIPI , "@E 99,999,999.99")

   if FAT->(Qrlock())
      replace FAT->Impresso with .T.
      FAT->(qunlock())
   endif
   qstopprn()

return

static function i_romaneio

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0

   cTITULO := "ROMANEIO DE CARGA DO PEDIDO No."+CODIGO+"   Data Emissao: "+dtoc(FAT->Dt_emissao)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,80)
      CLI1->(Dbseek(FAT->Cod_cli))
      VEND->(Dbseek(FAT->Cod_vended))
      CGM->(Dbseek(CLI1->Cgm_cob))
      @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + left(CLI1->Razao,36) + "  Telefone: "+ CLI1->Fone1
      @ prow()+1,0 say "Endereco: "+left(CLI1->End_cob,32) + " - " + left(CGM->Municipio,15) + " CGC: "+CLI1->Cgccpf
      @ prow()+1,0 say "Representante: "+VEND->Codigo + " - " + left(VEND->Nome,32)  + "      " + CLI1->Bairro_cob
      @ prow()+1,0 say replicate("-",80)
   endif

   @ prow(),pcol() say XCOND0
   @ prow()+1,0 say "Codigo  Qtde                  Produto                       "
   @ prow()+1,0 say ""

   ITEN_FAT->(Dbseek(FAT->Codigo))

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(Dbseek(ITEN_FAT->Cod_prod))
      @ prow()+1,0  say ITEN_FAT->Cod_prod
      @ prow()  ,6  say transform(ITEN_FAT->Quantidade, "@E 99999.99")
      @ prow()  ,16 say left(PROD->Descricao,27)



      nLIN++
      ITEN_FAT->(Dbskip())

   enddo

   @ prow()+1,0 say replicate("-",80)


   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR VARIAVEIS DO PEDIDO ________________________________

static function i_totaliza_pedido

   local nREC   := ITEN_FAT->(recno())
   local nINDEX := ITEN_FAT->(indexord())
   nITENS := 0
   nTOT_PED := 0
   fTOTAL := 0
   nTOT_PROD := 0
   nTOT_IPI  := 0
   nDESC := 0
   nTOT_DESC := 0
   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(dbgotop())
   ITEN_FAT->(dbseek(FAT->Codigo))

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_FAT->Cod_prod))
      if CONFIG->Modelo_fat == "1"
         if ITEN_FAT->Marcado == "*"
            if ITEN_FAT->Icms <> 0
               nTOT_IPI := nTOT_IPI + ( ( (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar) * PROD->Ipi) / 100)
            endif
            fTOTAL    := fTOTAL + (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar)

         endif
      else
         nTOT_IPI := nTOT_IPI + ( ( (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar) * PROD->Ipi) / 100)
         fTOTAL    := fTOTAL + (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar)
         //nITENS++
      endif
      nITENS++
      ITEN_FAT->(Dbskip())

   enddo
   if CONFIG->Modelo_fat == "1"
      fTOTAL := fTOTAL + nTOT_IPI
   else
      nDESC := FAT->Aliq_desc
      nTOT_DESC := (fTOTAL + nTOT_IPI) * (nDESC/100)
      fTOTAL := (fTOTAL + nTOT_IPI) - nTOT_DESC
   endif

   ITEN_FAT->(dbsetorder(nINDEX))
   ITEN_FAT->(dbgoto(nREC))

return

static function i_cancela

    if FAT->Cancelado
       qmensa("Pedido ja foi Cancelado!!!","B")
       return .F.
    endif

    if ! FAT->Impresso
       qmensa("Pedido ainda nao foi Impresso, impossivel Cancelar!!!","B")
       return .F.
    endif

    if qconf("Cofirma cancelamento do Pedido ?")
       if FAT->(qrlock())
          replace FAT->Cancelado with .T.
          replace FAT->Obs With "### PEDIDO CANCELADO ###"
          FAT->(qunlock())
       else
          qmensa("Nao foi possivel travar registro, Tente Novamente !","B")
          return .F.
       endif

       /// rotina para voltar o estoque dos produtos digitados no Pedido Cancelado!

       ITEN_FAT->(Dbgotop())
       ITEN_FAT->(Dbseek(FAT->Codigo))

       INVENT->(dbclearfilter())
       INVENT->(dbsetorder(1))

       do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

          if CONFIG->Modelo_fat == "1"
             if ITEN_FAT->Marcado $ "P- "
                ITEN_FAT->(Dbskip())
                loop
             endif
          endif

          if CONFIG->Estoque == "S"
          if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote)) .and. INVENT->(qrlock())
             if FAT->Es == "S"
                replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_FAT->Quantidade)
             else
                replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_FAT->Quantidade)
             endif
             INVENT->(qunlock())
          else
             qmensa("Lote nao encontrado ! ","B")
             return .F.
          endif
          endif
          ITEN_FAT->(Dbskip())

       enddo

       if FAT->Interface
          i_abre_receber()
          RECEBER->(dbsetorder(11))
          if  RECEBER->(dbseek("PED "+right(FAT->Num_fatura,5)))
              while ! RECEBER->(Eof()) .and. left(RECEBER->Fatura,9) == "PED "+right(FAT->Num_fatura,5)

                 if RECEBER->(qrlock())
                    RECEBER->(Dbdelete())
                    RECEBER->(Qunlock())
                 endif
                 RECEBER->(dbskip())
              enddo
          endif

          RECEBER->(dbclosearea())

          SELECT FAT
       endif


    endif
return

static function i_abre_receber()
local labriu := .F.

   if ! quse(XDRV_RB,"RECEBER",{"REC_COD","REC_VENC","REC_DUP","REC_DTEM","REC_CLIE","REC_LOTE","REC_BANC","REC_CLRZ","REC_CDCL","RB_DTVCL","REC_FATU","RECCLIVC"})
      Qmensa("Nao foi possivel abrir arquivo RECEBER.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu


