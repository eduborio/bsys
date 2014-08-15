/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO MANTRA
// OBJETIVO...: LISTAGEM DE CLIENTES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: JULHO de 2009
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

function cl302
local   bESCAPE := {|| lastkey()==27}

private fTOTAL           // No do Pedido
private cFILE            // No do Pedido
private cITEM            // No do Pedido
private cDUP             // No do Pedido

private cPEDIDO          // No do Pedido
private cREPPED          // No do Pedido no Representante
private cNF              // No da NF
private cCLI             // Codigo do Cliente
private cRazao           // Razao do Cliente
private dINI             // Data do Pedido/NF
private dFIM             // Cod do Produto
private lNFOK := .F.
private XDRV_HB := "C:\QSYSTXT\"
private nDIA,fDIA,nVALOR,fVALOR := 0
private fDIA1    := 0
private fDIA2    := 0
private fDIA3    := 0
private fDIA4    := 0
private fDIA5    := 0
private fDIA6    := 0
private fDIA7    := 0
private fVALOR1  := 0
private fVALOR2  := 0
private fVALOR3  := 0
private fVALOR4  := 0
private fVALOR5  := 0
private fVALOR6  := 0
private fVALOR7  := 0

private aEDICAO := {}    // vetor para os campos de entrada de dados


//   if ! quse(XDRV_CL,"DUP_PEN",{""})
//      qmensa("Nao foi possivel abrir arquivo de Pedidos!!!","BL")
//      return .F.
//   endif


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cPEDIDO            )}, "PEDIDO" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cREPPED            )}, "REPPED" })
//aadd(aEDICAO,{{ || qgetx(-1,0,@cNF                )}, "NF"     })
aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI            )},"CLI"     })
aadd(aEDICAO,{{ || NIL                             },NIL       }) // descricao do Representante
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD          )},"PROD"    })
aadd(aEDICAO,{{ || NIL                             },NIL       }) // descricao do Representante

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI       )},"INI"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM       )},"FIM"     })

do while .T.

   qlbloc(5,0,"B302A","QBLOC.GLO",1)

   cPEDIDO  := space(5)
   cREPPED  := space(6)
   cNF      := space(6)
   cCLI     := space(5)
   cRazao   := ""
   dINI     := ctod("")
   dFIM     := ctod("")
   cPROD    := space(5)
   XNIVEL   := 1
   XFLAG    := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   //if (i_getDados(),i_unique() , NIL )

   i_getDados()

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "CLI"
           if ! empty(cCLI)

              if !empty(cPEDIDO) .or. !empty(cREPPED)
                 qmensa("Informacao n tera efeito na consulta!","BL")
                 return .F.
              endif

              qrsay ( XNIVEL , cCLI := strzero(val(cCLI),5) )
              if CLI1->(dbseek(cCLI))
                 qrsay(XNIVEL+1,left(CLI1->Razao,30))
                 cRAZAO := CLI1->Razao
              else
                 qmensa("Cliente n„o encontrado !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "PEDIDO"
           if ! empty(cPEDIDO)
              if !empty(cREPPED)
                 qmensa("Informacao n tera efeito na consulta!","BL")
                 return .F.
              endif
              qrsay(XNIVEL,cPEDIDO:= strzero(val(cPEDIDO),5) )

              XNIVEL := 10
           endif


      case cCAMPO == "REPPED"
           if !empty(cREPPED)
              if !empty(cPEDIDO)
                 qmensa("Informacao n tera efeito na consulta!","BL")
                 return .F.
              endif
              XNIVEL := 10
           endif

      case cCAMPO == "INI"
           if ! empty(dINI)
              if !empty(cPEDIDO) .or. !empty(cREPPED)
                 qmensa("Informacao n tera efeito na consulta!","BL")
                 return .F.
              endif
           endif

      case cCAMPO == "FIM"
           if !empty(dFIM)
              if !empty(cPEDIDO) .or. !empty(cREPPED)
                 qmensa("Informacao n tera efeito na consulta!","BL")
                 return .F.
              endif

              if dFIM < dINI
                 qmensa("Data Final nao pode ser menor que a Inicial!","BL")
                 return .F.
              endif
           endif

      case cCAMPO == "PROD"
           if ! empty(cPROD)
              if CONFIG->Modelo_fat == "1"
                 PROD->(dbsetorder(5))
                 if PROD->(dbseek(cPROD))
                    cPROD := right(PROD->Codigo,5)
                 else
                    PROD->(dbsetorder(3))
                    if PROD->(dbseek(cPROD))
                       fCPROD := right(PROD->Codigo,5)
                    endif
                 endif
                 PROD->(dbsetorder(4))
              endif

              if ! empty(cPROD)
                 qrsay(XNIVEL,cPROD:=strzero(val(cPROD),5))

                 if ! PROD->(dbseek(cPROD))
                    qmensa("Produto n„o encontrado !","B")
                    return .F.
                 endif

                 if CONFIG->Modelo_fat == "1"
                    qrsay ( XNIVEL+1 , left(PROD->Descricao,15)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
                 else
                    qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )
                 endif

              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_getDados
local cTIPO  := ""
local cDATA  := ""

if !empty(cREPPED) .or. !empty(cPEDIDO)
   cTIPO := "UNICO"    //Retorna um registro so
else
   cTIPO := "LISTA"
endif

if ! empty(dINI)
   cDATA := "SIM"   //Com Data
   if empty(dFIM)
      dFIM := dINI
   endif
else
   cDATA := "NAO"   //Sem Data
endif



do case
   case cTIPO == "UNICO"
        i_unique()

   case cTIPO == "LISTA"
        i_lista(cDATA)

endcase



return .T.

static function i_unique
local nOrdem := 0
local cKey   := ""

   if !empty(cREPPED)
      nOrdem := 6
      cKEY   := cREPPED
   endif

   if !empty(cPEDIDO)
      nOrdem := 1
      cKEY   := cPEDIDO
   endif


   geraNomes()
   eraseFiles()
   abreFats()
   criaStructs()
   abreQuerys()

   if ! empty(cREPPED)
      i_Pedido(nOrdem,cKEY)
   else
      i_NF(nOrdem,cKey)
   endif

   indexa()
   fechaFats()
   i_showp((cFILE),(cITEM))

   eraseFiles()


return

static function i_Lista(cDATA)
local nOrdem := 0
local cKey   := ""

   if !empty(dINI) .and. empty(cCLI)
      nOrdem := 2
      cKey   := dtos(dINI)
   endif

   geraNomes()
   eraseFiles()
   abreFats()
   criaStructs()
   abreQuerys()


   if ! empty(cCLI)
      nOrdem := 5
      cKEY   := cCLI
      i_Cliente(nOrdem,cKEY,cDATA)
   endif

   if !empty(dINI) .and. empty(cCLI)
      nOrdem := 2
      cKey   := dtos(dINI)
      i_Data(nOrdem,cKEY,cDATA)
   endif

   indexa()
   fechaFats()
   i_showp((cFILE),(cITEM))

   eraseFiles()



static function i_Pedido(nOrdem,cKEY)

   PEND->(dbsetorder(nOrdem))
   if PEND->(dbseek(cKEY))
      do while ! PEND->(eof()) .and. alltrim(PEND->Pedido) == alltrim(cREPPED)

         geraVenda()
         geraItens()

         PEND->(dbskip())
     enddo

   endif

return

static function i_NF(nOrdem,cKEY)

   PEND->(dbsetorder(nOrdem))
   if PEND->(dbseek(cKEY))
      geraVenda()
      geraItens()
   endif

return


static function i_Cliente(nOrdem,cKEY,cDATA)

   PEND->(dbsetorder(nOrdem))
   if PEND->(dbseek(cKEY))
      do while ! PEND->(eof()) .and. PEND->cod_cli == cCLI
         if cDATA == "SIM"
            if PEND->Dt_Emissao < dINI .or. PEND->Dt_Emissao > dFIM
               PEND->(dbskip())
               loop
            endif
         endif

         geraItens(@lNFOK)
         geraVenda(@lNFOK)

         PEND->(dbskip())
      enddo
   endif

return

static function i_DATA(nOrdem,cKEY,cDATA)

   PEND->(dbsetorder(nOrdem))
   PEND->(dbgotop())
   //set softseek on
   PEND->(dbseek(cKEY,.T.))
   do while ! PEND->(eof())

      if PEND->Dt_emissao < dINI .or. PEND->Dt_Emissao > dFIM
         PEND->(dbskip())
         loop
      endif

      geraItens(@lNFOK)
      geraVenda(@lNFOK)

      PEND->(dbskip())
   enddo

return







static function sayAll

      qsay ( 06,17 , (cFILE)->Codigo           )
      qsay ( 06,42 , dtoc((cFILE)->Dt_Emissao) )
      qsay ( 06,68 , dtoc((cFILE)->Data_ped  ) )
      qsay ( 07,24 , (cFILE)->Cod_Cli          ) ; CLI1->(dbseek((cFILE)->Cod_cli))
      qsay ( 07,32 , left(CLI1->Razao,30)  )

      if CONFIG->Modelo_fat != "8"
         qsay ( 08,17 , (cFILE)->Cod_vended       ) ; VEND->(dbseek((cFILE)->Cod_vended))
         qsay ( 08,25 , left(VEND->Nome,16)   )
      else
         qsay ( 08,24 , (cFILE)->Cod_vended       ) ; VEND->(dbseek((cFILE)->Cod_vended))
         qsay ( 08,32 , left(VEND->Nome,25)   )
      endif

      if CONFIG->Modelo_fat != "8"
         qsay ( 08,51 , (cFILE)->Cod_repres       ) ; REPRES->(dbseek((cFILE)->Cod_repres))
         qsay ( 08,57 , left(REPRES->Razao,21)   )
      endif

      if CONFIG->Modelo_fat == "1"
         qsay ( 09,24,  qabrev((cFILE)->Boleto,"12345", {"Boleto","Pgto a Vista - Boleto","Pgto a Vista - Deposito","Antecipado","Nulo"}))

      else
         qsay ( 09,24 , (cFILE)->Filial           ) ; FILIAL->(dbseek((cFILE)->Filial))
         qsay ( 09,31 , left(FILIAL->Razao,30))
      endif


      qsay ( 10,24 , (cFILE)->C_custo          ) ; CCUSTO->(dbseek((cFILE)->C_custo))
      qsay ( 10,31 , left(CCUSTO->Descricao,15))

      if CONFIG->Modelo_2 $ "9"
         PROD->(dbsetorder(1))
         qsay ( 10,61 , (cFILE)->Cod_di            ) ; PROD->(dbseek((cFILE)->Cod_Di))
         qsay ( 10,66 , left(PROD->Descricao,12) )
      else
         qsay ( 10,71 , (cFILE)->Pedido )
      endif

      qsay ( 11,24 , (cFILE)->Cod_transp       ) ; TRANSP->(dbseek((cFILE)->Cod_transp))
      qsay ( 11,32 , left(TRANSP->Razao,20))

      if CONFIG->Modelo_2 == "7"
         qsay ( 11,61 , (cFILE)->Tipo_doc         ) ; TIPO_DOC->(dbseek((cFILE)->Tipo_doc))
         qsay ( 11,66 , left(TIPO_DOC->Descricao,11))
      endif

      qsay ( 12,24 , transform((cFILE)->Cod_cfop,"@R 9.999")) ; CFOP->(dbseek((cFILE)->Cod_cfop))
      qsay ( 12,32 , left(CFOP->Nat_desc,38))

      if  CONFIG->Modelo_fat == "8"
        qsay ( 13,24 , transform((cFILE)->cfop2,"@R 9.999")) ; CFOP->(dbseek((cFILE)->cfop2))
        qsay ( 13,32 , left(CFOP->Nat_desc,38))
      else
        if CONFIG->Modelo_2 == "2"
           qsay( 13,24,(cFILE)->Condic) ; COND->(dbseek((cFILE)->Condic))
           qsay( 13,29,COND->Descricao )
        else
           qsay ( 13,21 , (cFILE)->Tiposub          ) ; TIPOCONT->(dbseek((cFILE)->Tiposub))
           qsay ( 13,30,  alltrim(TIPOCONT->Descricao))
        endif
      endif

      qsay ( 14,27,  qabrev((cFILE)->Desc_sn,"SN", {"Sim","N„o"}))
      qsay ( 14,50,  qabrev((cFILE)->Es     ,"SC", {"Saida","C.Icms"}))

      if CONFIG->Modelo_2 == "2"
         qsay ( 14,71, transform((cFILE)->Aliq_desc,"@E 9999.99")    )
      else
         qsay ( 14,73, transform((cFILE)->Aliq_desc,"@E 99.99")    )
      endif
      qsay ( 15,14 , Left((cFILE)->Obs,43)             )
      qsay ( 15,70,  qabrev((cFILE)->Frete    ,"12", {"1 - Cif","2 - Fob"}))

      //qwait()
return


static function i_showp(cFILE)

   (cFILE)->(qview({{"Codigo/Pedido"      ,0},;
             {"Dt_emissao/Emissao"        ,0},;
             {"i_302obs()/Obs"            ,0},;
             {"left(Cliente,25)/Cliente"  ,0},;
             {"Num_fatura/No. NF ",11}},"P",;
             {NIL,"i_302a",NIL,NIL},;
              NIL,"<C>onsulta   /   <D>uplicatas   / <O>bservacao "))

   (cFILE)->(dbcloseArea())
   (cITEM)->(dbcloseArea())

return

function i_302obs
    OBSERVAC->(dbseek((cFILE)->Codigo))
return iif(!empty(OBSERVAC->Obs1),"Sim","   ")


function i_302a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))


   if cOPCAO == "C"
      qlbloc(5,0,"B201AM","QBLOC.GLO",1) //Mantraco

      XNIVEL := 1

      sayaLL()
      i_atu_lanc()
   endif

   if cOPCAO == "D"
      qlbloc(8,2,"B201C","QBLOC.GLO",1)
      i_faturas()
   endif

     iif(cOPCAO == "O", i_Observacao(),)



   setcursor(nCURSOR)

return ""

static function i_atu_lanc
   (cITEM)->(qview({{"f302m1()/Cod."                                       ,0},;
                     {"f302mar()/Faturar"                                   ,0},;
                     {"f302a()/Descri‡„o"                                    ,0},;
                     {"f302m()/Ref."                                         ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f302b()/Un."                                          ,0},;
                     {"f302c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,"showp",NIL,NIL},;
                     {"(cITEM)->cod_pend == (cFILE)->Codigo",{||f302top()},{||f302bot()}},;
                    "<C>onsulta   /   <D>uplicatas  " ))

return ""


function showp

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "C"
      qlbloc(05,05,"B201B1","QBLOC.GLO",1)
      sayItens()
      qwait()
   endif

   if cOPCAO == "D"
      qlbloc(8,2,"B201C","QBLOC.GLO",1)
      i_faturas()
   endif

   setcursor(nCURSOR)

return

function f302top
   (cITEM)->(dbsetorder(1))
   (cITEM)->(dbseek((cFILE)->Codigo))
   //i_totaliza_pedido()
   //qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f302bot
   (cITEM)->(dbsetorder(1))
   (cITEM)->(qseekn((cFILE)->Codigo))
   //i_totaliza_pedido()
   //qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return

function f302mar
local cMAR := ""
local cDESCRICAO := ""

cMAR := (cITEM)->Marcado
   if cMAR == "*"
      cDESCRICAO := "BAIXADO"
   elseif cMAR $ "P"
      cDESCRICAO := "PENDENTE"
   elseif cMAR $ "Q"
      cDESCRICAO := "PARCIAL"
   elseif cMAR $ " "
      cDESCRICAO := "ABERTO"
   endif
return cDESCRICAO


function f302m
   local cFABR := space(4)

   PROD->(Dbsetorder(4))
   if ! empty((cITEM)->Cod_prod)
      PROD->(dbseek(left((cITEM)->Cod_prod,5)))
      cFABR := left(PROD->Cod_fabr,4)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   rtrim(cFABR)

return cFABR


function f302m1
   local cASS := space(7)

   PROD->(Dbsetorder(4))
   if ! empty((cITEM)->Cod_prod)
      PROD->(dbseek(left((cITEM)->Cod_prod,5)))
      cASS := left(PROD->Cod_ass,7)
   endif
   //i_totaliza_pedido()
   //qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   rtrim(cASS)

return cASS


/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f302b
   PROD->(dbseek(left((cITEM)->Cod_prod,5)))
   UNIDADE->(dbseek(PROD->Unidade))
   //i_totaliza_pedido()
   //qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f302c
local nRET
      nRET :=  transform((cITEM)->Vl_unitar * (cITEM)->Quantidade,"@E 999,999.99")

   //qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return nRET


static function i_totaliza_pedido

   local nREC   := (cITEM)->(recno())
   local nINDEX := (cITEM)->(indexord())
   nITENS := 0
   nICMS_PROPRIO  := 0
   nICMS_ST       := 0
   nTOT_PED := 0
   fTOTAL   := 0
   fSERVICO := 0
   fPEDIDO := 0
   nTOT_PROD := 0
   nTOT_IPI  := 0
   nDESC := 0
   nTOT_DESC := 0
   (cITEM)->(dbsetorder(1))
   (cITEM)->(dbgotop())
   (cITEM)->(dbseek((cFILE)->Codigo))

   do while ! (cITEM)->(eof()) .and. (cITEM)->cod_pend == (cFILE)->Codigo
      PROD->(dbsetorder(4))
      PROD->(dbseek((cITEM)->Cod_prod))

      if CONFIG->Modelo_fat == "1"
  //       if (cITEM)->Marcado $ "*-Q"
            if (cITEM)->Icms <> 0
               nTOT_IPI := nTOT_IPI + ( ( ((cITEM)->Quantidade*(cITEM)->Vl_unitar) * (cITEM)->Ipi) / 100)
            endif
            fTOTAL    := fTOTAL + ((cITEM)->Quantidade*(cITEM)->Vl_unitar)
            fPEDIDO   := fPEDIDO + ((cITEM)->Quantidade*(cITEM)->Vl_unitar)

//         endif
      elseIF     CONFIG->Modelo_fat == "2"
          if PROD->pROD_ISS == "S"
             fSERVICO += (cITEM)->Vl_unitar

          ENDIF

          fTOTAL += (cITEM)->Vl_unitar

      ELSE
         if CONFIG->Modelo_fat == "5"
            if (cITEM)->Tot_ped > 0
               fTOTAL    := fTOTAL + ((cITEM)->Tot_ped)
            else
               fTOTAL    := fTOTAL + ((cITEM)->Quantidade*(cITEM)->Vl_unitar)
            endif
         else
            if (cITEM)->Bc_subst > 0 .and. CLI1->Final $ " -N"
               nICMS_ST      +=  ( ((cITEM)->Quantidade*(cITEM)->Bc_subst) * ((cITEM)->Icms /100))
               if (cFILE)->Dt_emissao >= ctod("04/02/2008")
                  nICMS_PROPRIO +=  ( ( (cITEM)->Quantidade * (cITEM)->vl_unitar ) * ( 7 / 100 ) )
               else
                  nICMS_PROPRIO +=  ( ( (cITEM)->Quantidade * (cITEM)->Vl_unitar ) * ( (cITEM)->Icms / 100 ) )
               endif
            endif

            nTOT_IPI := nTOT_IPI + ( ( ((cITEM)->Quantidade*(cITEM)->Vl_unitar) * (cITEM)->Ipi) / 100)
            fTOTAL    := fTOTAL + ((cITEM)->Quantidade*(cITEM)->Vl_unitar)
         endif
         //nITENS++
      endif
      nITENS++
      (cITEM)->(Dbskip())


   enddo


   if CONFIG->Modelo_fat == "1"
      fTOTAL := fTOTAL + nTOT_IPI
   else
      nDESC := (cFILE)->Aliq_desc
      nTOT_DESC := (fTOTAL + nTOT_IPI) * (nDESC/100)
      fTOTAL := ((fTOTAL + nTOT_IPI)+(nICMS_ST - nICMS_PROPRIO)) - nTOT_DESC
   endif

   fTOTAL  := round(fTOTAL,2)
   fPEDIDO := round(fPEDIDO,2)

   (cITEM)->(dbsetorder(nINDEX))
   (cITEM)->(dbgoto(nREC))

return

function f302a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty((cITEM)->Cod_prod)
      PROD->(dbseek(left((cITEM)->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,30)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return cDESCRICAO

static function abreFats

   if ! quse(XDRV_CL,"PEND",{""})
      qmensa("Nao foi possivel abrir arquivo de Pedidos!!!","BL")
      return .F.
   endif

   if ! quse(XDRV_CL,"ITEM_PEN",{""})
      qmensa("Nao foi possivel abrir arquivo de Itens!!!","BL")
      return .F.
   endif


return

static function fechaFats

   PEND->(dbclosearea())
   ITEM_PEN->(dbclosearea())


return

static function criaStructs
   dbCreate(XDRV_HB+cFILE,PEND->(dbStruct()))
   dbCreate(XDRV_HB+cITEM,ITEM_PEN->(dbStruct()))
return

static function abreQuerys
   USE (XDRV_HB+cITEM) SHARED NEW alias (cITEM)
   USE (XDRV_HB+cFILE) SHARED NEW alias (cFILE)
return

static function eraseFiles
   if file(XDRV_HB+cFile+".DBF")
      erase(XDRV_HB+cFile+".DBF")
   endif

   if file(XDRV_HB+cITEM+".DBF")
      erase(XDRV_HB+cITEM+".DBF")
   endif

   if file(XDRV_HB+cITEM+".CDX")
      erase(XDRV_HB+cITEM+".CDX")
   endif

   if file(XDRV_HB+cFILE+".CDX")
      erase(XDRV_HB+cFILE+".CDX")
   endif



return


static function geraNomes

   cFILE := left(alltrim(XUSRIDT),7) +"1"
   cITEM := left(alltrim(XUSRIDT),7) +"2"
return

static function indexa

   if file(XDRV_HB+cITEM+".CDX")
      erase(XDRV_HB+cITEM+".CDX")
   endif

   select (cITEM)
   index on cod_pend tag UM
   dbsetindex(XDRV_HB+cITEM)

return

static function geraItens(lNFOK)
     lNFOK := .F.

     if ! empty(cPROD)
        ITEM_PEN->(dbsetorder(1))
        if ITEM_PEN->(dbseek(PEND->Codigo))
           do while ! ITEM_PEN->(eof()) .and. ITEM_PEN->cod_pend == PEND->Codigo

              if ITEM_PEN->Cod_prod == cPROD
                 ITEM_PEN->(qpublicfields())
                 ITEM_PEN->(qcopyfields())
                 if (cITEM)->(qAppend())
                    (cITEM)->(qreplacefields())
                 endif
                 lNFOK := .T.
              endif

              ITEM_PEN->(dbskip())
           enddo
        endif
     else
        ITEM_PEN->(dbsetorder(1))
        if ITEM_PEN->(dbseek(PEND->Codigo))
           do while ! ITEM_PEN->(eof()) .and. ITEM_PEN->cod_pend == PEND->Codigo
              ITEM_PEN->(qpublicfields())
              ITEM_PEN->(qcopyfields())

              if (cITEM)->(qAppend())
                 (cITEM)->(qreplacefields())
              endif

              ITEM_PEN->(dbskip())
           enddo
        endif
     endif

return


static function geraVenda(lNKOK)

     if ! empty(cPROD)
        if lNFOK
           PEND->(qpublicfields())
           PEND->(qcopyfields())
           if (cFILE)->(QAppend())
              (cFILE)->(qreplacefields())
           endif
        endif
     else
        PEND->(qpublicfields())
        PEND->(qcopyfields())
        if (cFILE)->(QAppend())
           (cFILE)->(qreplacefields())
        endif
     endif

     lNFOK := .F.


return

static function sayItens
    XNIVEL := 1
    qrsay ( XNIVEL++ , (cITEM)->Cod_prod            , "@R 99999"                    ) ; PROD->(dbseek(left((cITEM)->Cod_prod,5)))
    qrsay ( XNIVEL++ , left(PROD->Descricao,40)                                      )
    qrsay ( XNIVEL++ , (cITEM)->Num_lote                                            )
    qrsay ( XNIVEL++ , qabrev((cITEM)->Prod_ser,"12", {"N„o","Sim"})                )

    qrsay ( XNIVEL++ , (cITEM)->Preco_vend, "@E 999,999.999"        )
    qrsay ( XNIVEL++ , (cITEM)->Desc_prod, "@E 99.99"     )
    qrsay ( XNIVEL++ , (cITEM)->Vlr_Desc , "@E 9999,999.99"                       )

    qrsay ( XNIVEL++ , (cITEM)->Vl_unitar, "@E 9,999,999.999"                    )

    if CONFIG->Modelo_fat == "1"
       qrsay ( XNIVEL++ , (cITEM)->Quant_Ped                                       )
    endif

    qrsay ( XNIVEL++ , (cITEM)->Quantidade                                          )

    if CONFIG->Modelo_fat == "1"
       qrsay ( XNIVEL++ , (cITEM)->Quant_pen                                        )
    endif
    qrsay ( XNIVEL++ , transform((cITEM)->Icms,"@E 99.99")                          )
    qrsay ( XNIVEL++ , transform((cITEM)->Ipi, "@E 99.99")                              )

    qrsay ( XNIVEL++ , (cITEM)->Vl_unitar * (cITEM)->Quantidade, "@E 9,999,999.99" )

    qrsay ( XNIVEL++ , transform((cITEM)->Comissao, "@E 99.99" )                    )

    if CONFIG->Modelo_fat == "1"
       qrsay ( XNIVEL++ , transform((cITEM)->Comi_repre, "@E 99.99" )                    )
    endif

    if CONFIG->Modelo_fat != "B"
       qrsay ( XNIVEL++ , (cITEM)->Cod_sit          ,"@R 999"   )//;SIT_TRIB->(dbseek((cITEM)->Cod_sit))
       //qrsay ( XNIVEL++ , left(SIT_TRIB->Descricao,30)                                  )
       qrsay ( XNIVEL++ , (cITEM)->Classif                  )
    endif
return


static function i_faturas

    i_parcela()
    i_mostra_dupli()
    qwait()

return

static function i_parcela
   local nCONT := 0

   if ! DUP_PEN->(Dbseek((cFILE)->Codigo+"01"))
      qmensa("Pedido Nao Possui Duplicatas")
      return .F.
   endif

   for nCONT := 1 to 7

       if ! DUP_PEN->(eof()) .and. left(DUP_PEN->Num_pen,5) == (cFILE)->Codigo

          nDIA   := "fDIA"+str(nCONT,1)
          nVALOR := "fVALOR"+str(nCONT,1)

          if DUP_PEN->Dias == 0
             &nDIA   := DUP_PEN->Data_venc - (cFILE)->DT_EMISSAO
          else
             &nDIA   := DUP_PEN->Dias
          endif

          &nVALOR := DUP_PEN->Valor
          DUP_PEN->(Dbskip())

       endif

   next

return


static function i_mostra_dupli
   local zNIVEL := XNIVEL
   local nCONT := 0


    XNIVEL := 1


   Qrsay(xNIVEL++,(cFILE)->Vezes)


   for nCONT := 1 to 7

       nDIA   := "fDIA"+str(nCONT,1)
       nVALOR := "fVALOR"+str(nCONT,1)

       if (&nDIA) > 0
          Qrsay(xNIVEL++,&nDIA,"999")
          Qrsay(xNIVEL++,iif(&nDIA > 0,dtoc((cFILE)->Dt_emissao + (&nDIA)),"") )
          Qrsay(xNIVEL++,&nValor,"@E 99,999,999.99")
       else
          Qrsay(xNIVEL++,&nDIA,"999")
          Qrsay(xNIVEL++,iif(&nValor > 0,dtoc((cFILE)->Dt_emissao + (&nDIA)),"") )
          Qrsay(xNIVEL++,&nValor,"@E 99,999,999.99")
       endif

   next
   XNIVEL := zNIVEL

return

static function i_Observacao


    qlbloc(8,2,"B201O","QBLOC.GLO",1)


    XNIVEL := 1
    XFLAG  := .T.


    if OBSERVAC->(dbseek((cFILE)->Codigo))
       OBSERVAC->(qpublicfields())
       OBSERVAC->(qinitfields())
       OBSERVAC->(qcopyfields())

       qrsay(XNIVEL  ,OBSERVAC->Obs1)
       qrsay(XNIVEL+1,fObs2)
       qrsay(XNIVEL+2,fObs3)
       qrsay(XNIVEL+3,fObs4)
       qrsay(XNIVEL+4,fObs5)
    endif

    qwait()

return ""





