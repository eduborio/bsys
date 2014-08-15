/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE NOTAS FISCAIS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: setembro de 2006
// OBS........:
// ALTERACOES.:

function cl401
if ! qconf("Recalcula Pontos do Representantes ?")
   return .F.
endif

MILHAS->(dbsetorder(2))

REPRES->(dbgoTop())
Do while ! REPRES->(Eof())

   if MILHAS->(Dbseek(REPRES->Codigo))
      qmensa("Calculando "+Repres->Razao)
      i_inicializacao(MILHAS->Cod_repres)
   endif
   REPRES->(Dbskip())
enddo

static function i_inicializacao(cCOD_REPRES)

   if MILHAS->(qrlock())
      replace  MILHAS->Pontos with i_impressao(cCOD_REPRES)
      MILHAS->(qunlock())
   endif

   FAT->(DbclearFilter())
return .T.



static function i_impressao(cREPRES)
    local nVAL_PED := 0
    local nVAL_PTS := 0
    local nTT_PTS  := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local nVAL_UNI := 0
    local lFIRST   := .F.

    FAT->(dbclearfilter())
    FAT->(dbsetfilter({|| FAT->Cod_repres == cREPRES}))
    FAT->(dbsetorder(2)) // data de emissao
    FAT->(dbgotop())
    set softseek on
    FAT->(Dbseek(dtos(MILHAS->Data_ini)))
    set softseek off
    ITEN_FAT->(dbsetorder(2))


   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= MILHAS->Data_ini .and. FAT->Dt_emissao <= ctod("30/04/2013")  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif


      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      //REPRES->(Dbseek(FAT->cod_repres))

      //if MILHAS->(dbseek(REPRES->Codigo))
      //   if FAT->Dt_emissao < MILHAS->Data_ini
      //      FAT->(Dbskip())
      //      loop
      //   endif
      //else
      //   FAT->(dbskip())
      //   loop
      //endif

      //
      //CLI1->(Dbseek(FAT->Cod_cli))

      //if ! empty(cREPRES)
      // /  if FAT->cod_repres != cREPRES
      //      FAT->(dbskip())
      //      loop
      //   endif
      //endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-610-611-120-220"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()


      ITEN_FAT->(Dbgotop())
      nVAL_PTS := 0
      if ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

            if ITEN_FAT->Pontos == 0
               PROD->(dbsetorder(4))
               if PROD->(dbseek(ITEN_FAT->Cod_prod))

                  if ITEN_FAT->(qrlock())
                     replace ITEN_FAT->Pontos with PROD->Pontos
                     ITEN_FAT->(Qunlock())
                  endif
                endif
            endif

            nVAL_PTS += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar * ITEN_FAT->Pontos)
            ITEN_FAT->(Dbskip())
        enddo
      endif

      if FAT->Es == "E"
         nTT_PTS  -= nVAL_PTS
      else
         nTT_PTS  += nVAL_PTS
      endif

      nVAL_PTS := 0

      FAT->(dbskip())

   enddo

   PREMIO->(dbsetorder(2))
   MILHAS->(dbseek(cREPRES))
   if PREMIO->(dbseek(cREPRES))
      do while ! PREMIO->(eof()) .and. PREMIO->Cod_repres == cREPRES
         if PREMIO->Data >= MILHAS->Data_ini .and. PREMIO->Data <= MILHAS->Data_ini + 1825
            nTT_PTS -= PREMIO->Pontos
         endif
         PREMIO->(dbskip())
      enddo
   endif


return  nTT_PTS

