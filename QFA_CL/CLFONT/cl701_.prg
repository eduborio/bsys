/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: CONTROLE DE ESTOQUE ESPECIAL
// OBJETIVO...: GRAFICO REFEERENTE A LAN€AMENTO DE FATURAS
// ANALISTA...: LUCINEIDE V. POSSEBOM
// PROGRAMADOR: LUCIANO DA SILVA GORSKI
// INICIO.....: FEVEREIRO DE 1998
// OBS........:
// ALTERACOES.:

function cl701
fANO := 0
#define K_MAX_LIN 55

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

   qlbloc(5,0,"B701A","QBLOC.GLO")
   i_edicao()
   Return
/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fANO) .or. (XNIVEL==1.and.!XFLAG)}

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fANO ,"9999")                            },"ANO"        })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma geral gr fico referente a este ano?") },NIL})

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL > 0 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

 if lCONF
    cCONT01:= 0
    cCONT02:= 0
    cCONT03:= 0
    cCONT04:= 0
    cCONT05:= 0
    cCONT06:= 0
    cCONT07:= 0
    cCONT08:= 0
    cCONT09:= 0
    cCONT10:= 0
    cCONT11:= 0
    cCONT12:= 0
    cTOTAL := 0
    cANOMES:= ""
    cMES01 := 0
    cMES02 := 0
    cMES03 := 0
    cMES04 := 0
    cMES05 := 0
    cMES06 := 0
    cMES07 := 0
    cMES08 := 0
    cMES09 := 0
    cMES10 := 0
    cMES11 := 0
    cMES12 := 0
    cMES   := 0
    cITENS := 0
    fCODIGO := space(6)
    Set softseek on
    for cMES := 01 to 12
    FAT->(dbsetorder(2))
    FAT->(dbgotop())
    ITEN_FAT->(dbgotop())

    FAT->(dbseek(dtos(ctod("01/"+strzero(cMES,2)+"/"+str(fANO,4)))))
        qmensa("Aguarde... Gerando Mˆs "+strzero(cMES,2))
        Do While ! FAT->(eof())
           fCODIGO := FAT->Codigo
           if left(dtos(FAT->Dt_emissao),6) == str(fANO,4)+strzero(cMES,2)
              ITEN_FAT->(dbsetorder(1))
              ITEN_FAT->(dbseek(fCODIGO))
              do while ! ITEN_FAT->(eof())
                 if fCODIGO = ITEN_FAT->Num_fat
                    cITENS += ITEN_FAT->Vl_unitar
                    ITEN_FAT->(dbskip())
                    cTOTAL += cITENS
                    cITENS := 0
                    loop
                 else
                    ITEN_FAT->(dbskip())
                    loop
                 endif
              enddo
              FAT->(dbskip())
              loop
           else
              FAT->(dbskip())
              loop
           endif
        enddo
        cANOMES  := "cMES" + strzero(cMES,2)
        &cANOMES := cTOTAL
        cITENS   := 0
        cTOTAL   := 0

    nTOTAL := cMES01 + cMES02 + cMES03 + cMES04 + cMES05 + cMES06 + cMES07 + cMES08 + cMES09 + cMES10 + cMES11 + cMES12
    next

    cTOTAL := 0
    cANOMES:= ""
    cMES01 := 0
    cMES02 := 0
    cMES03 := 0
    cMES04 := 0
    cMES05 := 0
    cMES06 := 0
    cMES07 := 0
    cMES08 := 0
    cMES09 := 0
    cMES10 := 0
    cMES11 := 0
    cMES12 := 0
    cMES   := 0
    cITENS := 0
    fCODIGO := space(6)
    Set softseek on

    for cMES := 01 to 12
    FAT->(dbsetorder(2))
    FAT->(dbgotop())
    ITEN_FAT->(dbgotop())
    qmensa("Aguarde... Gerando Mˆs "+strzero(cMES,2))
    FAT->(dbseek(dtos(ctod("01/"+strzero(cMES,2)+"/"+str(fANO,4)))))
        Do While ! FAT->(eof())
           fCODIGO := FAT->Codigo
           if left(dtos(FAT->Dt_emissao),6) == str(fANO,4)+strzero(cMES,2)
              ITEN_FAT->(dbsetorder(1))
              ITEN_FAT->(dbseek(fCODIGO))
              do while ! ITEN_FAT->(eof())

                 if fCODIGO = ITEN_FAT->Num_fat
                    cITENS += ITEN_FAT->Vl_unitar
                    ITEN_FAT->(dbskip())
                    cTOTAL += cITENS
                    cITENS := 0
                    loop
                 else
                    ITEN_FAT->(dbskip())
                    loop
                 endif
              enddo
              FAT->(dbskip())
              loop
           else
              FAT->(dbskip())
              loop
           endif
        enddo

        cANOMES  := "cMES" + strzero(cMES,2)
        &cANOMES := cTOTAL

        cITENS   := 0
        cTOTAL   := 0

        qsay (06,31, cMES01  ,"@R 9,999,999.99"      )
        qsay (06,48, cMES02  ,"@R 9,999,999.99"      )
        qsay (06,65, cMES03  ,"@R 9,999,999.99"      )
        qsay (07,31, cMES04  ,"@R 9,999,999.99"      )
        qsay (07,48, cMES05  ,"@R 9,999,999.99"      )
        qsay (07,65, cMES06  ,"@R 9,999,999.99"      )
        qsay (08,31, cMES07  ,"@R 9,999,999.99"      )
        qsay (08,48, cMES08  ,"@R 9,999,999.99"      )
        qsay (08,65, cMES09  ,"@R 9,999,999.99"      )
        qsay (09,31, cMES10  ,"@R 9,999,999.99"      )
        qsay (09,48, cMES11  ,"@R 9,999,999.99"      )
        qsay (09,65, cMES12  ,"@R 9,999,999.99"      )

        if cMES01 <> 0
           cCONT01 := cMES01/nTOTAL*66-1
           qsay(10,12,replicate("þ",int(cCONT01)))
           qsay(10,12+cCONT01+1,transform(cMES01/nTOTAL*100,"@R 99.99"))
        endif

        if cMES02 <> 0
           cCONT02 := cMES02/nTOTAL*66-1
           qsay(11,12,replicate("þ",int(cCONT02)))
           qsay(11,12+cCONT02+1,transform(cMES02/nTOTAL*100,"@R 99.99"))
        endif

        if cMES03 <> 0
           cCONT03 := cMES03/nTOTAL*66-2
           qsay(12,12,replicate("þ",int(cCONT03)))
           qsay(12,12+cCONT03+1,transform(cMES03/nTOTAL*100,"@R 99.99"))
        endif

        if cMES04 <> 0
           cCONT04 := cMES04/nTOTAL*66-2
           qsay(13,12,replicate("þ",int(cCONT04)))
           qsay(13,12+cCONT04+1,transform(cMES04/nTOTAL*100,"@R 99.99"))
        endif

        if cMES05 <> 0
           cCONT05 := cMES05/nTOTAL*66-2
           qsay(14,12,replicate("þ",int(cCONT05)))
           qsay(14,12+cCONT05+1,transform(cMES05/nTOTAL*100,"@R 99.99"))
        endif

        if cMES06 <> 0
           cCONT06 := cMES06/nTOTAL*66-2
           qsay(15,12,replicate("þ",int(cCONT06)))
           qsay(15,12+cCONT06+1,transform(cMES06/nTOTAL*100,"@R 99.99"))
        endif

        if cMES07 <> 0
           cCONT07 := cMES07/nTOTAL*66-2
           qsay(16,12,replicate("þ",int(cCONT07)))
           qsay(16,12+cCONT07+1,transform(cMES07/nTOTAL*100,"@R 99.99"))
        endif

        if cMES08 <> 0
           cCONT08 := cMES08/nTOTAL*66-2
           qsay(17,12,replicate("þ",int(cCONT08)))
           qsay(17,12+cCONT08+1,transform(cMES08/nTOTAL*100,"@R 99.99"))
        endif

        if cMES09 <> 0
           cCONT09 := cMES09/nTOTAL*66-2
           qsay(18,12,replicate("þ",int(cCONT09)))
           qsay(18,12+cCONT09+1,transform(cMES09/nTOTAL*100,"@R 99.99"))
        endif

        if cMES10 <> 0
           cCONT10 := cMES10/nTOTAL*66-2
           qsay(19,12,replicate("þ",int(cCONT10)))
           qsay(19,12+cCONT10+1,transform(cMES10/nTOTAL*100,"@R 99.99"))
        endif

        if cMES11 <> 0
           cCONT11 := cMES11/nTOTAL*66-2
           qsay(20,12,replicate("þ",int(cCONT11)))
           qsay(20,12+cCONT11+1,transform(cMES11/nTOTAL*100,"@R 99.99"))
        endif

        if cMES12 <> 0
           cCONT12 := cMES12/nTOTAL*66-2
           qsay(21,12,replicate("þ",int(cCONT12)))
           qsay(21,12+cCONT12+1,transform(cMES12/nTOTAL*100,"@R 99.99"))
        endif

    next

    lCONF := qconf("Confirma imprimir gr fico referente a este ano?")

    if lCONF

       cTITULO := "GRAFICO REFERENTE A LANCAMENTOS DE FATURAS"

       // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

          if ! qinitprn() ; return ; endif

             if ! qlineprn() ; return ; endif

                qpageprn()

                qcabecprn(cTITULO,80)

                @ prow()+1,0 say "      JANEIRO    FEVEREIRO       MARCO       ABRIL        MAIO        JUNHO"
                @ prow()+1,0 say transform(cMES01,"@R 99,999,999.99")
                @ prow(),13  say transform(cMES02,"@R 99,999,999.99")
                @ prow(),27  say transform(cMES03,"@R 99,999,999.99")
                @ prow(),41  say transform(cMES04,"@R 99,999,999.99")
                @ prow(),54  say transform(cMES05,"@R 99,999,999.99")
                @ prow(),67  say transform(cMES06,"@R 99,999,999.99")
                @ prow()+1,0 say ""
                @ prow()+1,0 say "      JULHO      AGOSTO          SETEMBRO    OUTUBRO      NOVEMBRO    DEZEMBRO"
                @ prow()+1,0 say transform(cMES07,"@R 99,999,999.99")
                @ prow(),13  say transform(cMES08,"@R 99,999,999.99")
                @ prow(),27  say transform(cMES09,"@R 99,999,999.99")
                @ prow(),41  say transform(cMES10,"@R 99,999,999.99")
                @ prow(),54  say transform(cMES11,"@R 99,999,999.99")
                @ prow(),67  say transform(cMES12,"@R 99,999,999.99")
                @ prow()+1,0 say replicate("-",80)
                @ prow()+1,0 say ""

                @ prow()+1,0 say "Janeiro..:"
                @ prow(),12  say replicate("*",int(cCONT01))
                @ prow(),12+cCONT01+1 say transform(cMES01/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Fevereiro:"
                @ prow(),12  say replicate("*",int(cCONT02))
                @ prow(),12+cCONT02+1 say transform(cMES02/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Marco....:"
                @ prow(),12  say replicate("*",int(cCONT03))
                @ prow(),12+cCONT03+1 say transform(cMES03/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Abril....:"
                @ prow(),12  say replicate("*",int(cCONT04))
                @ prow(),12+cCONT04+1 say transform(cMES04/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Maio.....:"
                @ prow(),12  say replicate("*",int(cCONT05))
                @ prow(),12+cCONT05+1 say transform(cMES05/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Junho....:"
                @ prow(),12  say replicate("*",int(cCONT06))
                @ prow(),12+cCONT06+1 say transform(cMES06/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Julho....:"
                @ prow(),12  say replicate("*",int(cCONT07))
                @ prow(),12+cCONT07+1 say transform(cMES07/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Agosto...:"
                @ prow(),12  say replicate("*",int(cCONT08))
                @ prow(),12+cCONT08+1 say transform(cMES08/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Setembro.:"
                @ prow(),12  say replicate("*",int(cCONT09))
                @ prow(),12+cCONT09+1 say transform(cMES09/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Outubro..:"
                @ prow(),12  say replicate("*",int(cCONT10))
                @ prow(),12+cCONT10+1 say transform(cMES10/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Novembro.:"
                @ prow(),12  say replicate("*",int(cCONT11))
                @ prow(),12+cCONT11+1 say transform(cMES11/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say "Dezembro.:"
                @ prow(),12  say replicate("*",int(cCONT12))
                @ prow(),12+cCONT12+1 say transform(cMES12/nTOTAL*100,"@R 99.99")

                @ prow()+1,0 say ""
                @ prow()+1,0 say replicate("-",80)
                @ prow()+1,11 say "0%....|10%..|20%..|30%..|40%..|50%..|60%..|70%..|80%..|90%..|100%.."
          qstopprn()


    endif
 endif
/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "ANO"
           if fANO == 0 ; return .F. ; endif
           qsay(XNIVEL,fANO)

   endcase


return  .T.

