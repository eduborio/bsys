
function qindexcontrol
   local RDD := "DBFCDX"
   if ! XWAIT ; return ; endif

   qbeep()
   setpos(25,00)

   if file(XDRV_SH+"QUSERS.CDX")
      ferase(XDRV_SH+"QUSERS.CDX")
   endif

   if file(XDRV_SH+"QINST.CDX")
      ferase(XDRV_SH+"QINST.CDX")
   endif

   if file("QPROGS.CDX")
      ferase("QPROGS.CDX")
   endif

   if file("QACESS.CDX")
      ferase("QACESS.CDX")
   endif

   if file("QLOGIN.CDX")
      ferase("QLOGIN.CDX")
   endif

   if file("QHELP.CDX")
      ferase("QHELP.CDX")
   endif

   if RDD == "DBFCDX" .or. RDD == "SIXCDX" .or. RDD == "SIXNSX"
      qmensa("(6) - Aguarde, Indexando QUSERS...")
      if quse(XDRV_SH,"QUSERS",NIL,"E")
         index on subs(qdecri(Identific),11,10) tag LOGIN
         index on Usrnum                        tag CODUSER
         QUSERS->(dbclosearea())
      endif

      qmensa("(5) - Aguarde, Indexando QINST...")
      if quse(XDRV_SH,"QINST",NIL,"E")
         index on EMPRESA tag EMPRESA
         index on RAZAO   tag RAZAO
         QINST->(dbclosearea())
      endif

      qmensa("(4) - Aguarde, Indexando QPROGS...")
      if quse("","QPROGS",NIL,"E")
         index on PROG tag PROG
         QPROGS->(dbclosearea())
      endif

      qmensa("(3) - Aguarde, Indexando QACESS...")
      if quse("","QACESS",NIL,"E")
         index on Empresa + Usrnum + Prog tag EMPUSR
         index on Empresa + Prog + Usrnum tag EMPPRO
         QACESS->(dbclosearea())
      endif

      qmensa("(2) - Aguarde, Indexando QLOGIN...")
      if quse("","QLOGIN",NIL,"E")
         index on Empresa + dtos(Datalog) + Inicio tag QLOGIN1
         index on Empresa + Usrnum + dtos(Datalog) tag QLOGIN2
         index on Empresa + Prog + dtos(Datalog)   tag QLOGIN3
         QLOGIN->(dbclosearea())
      endif

      qmensa("(1) - Aguarde, Indexando QHELP...")
      if quse("","QHELP",NIL,"E")
         index on Prog tag PROG1
         QHELP->(dbclosearea())
      endif

   endif

   if RDD == "DBFNTX" .or. RDD == "SIXNTX" .or. RDD == "SDF"

      qmensa("(6) - Aguarde, Indexando QUSERS...")
      if quse(XDRV_SH,"QUSERS",NIL,"E")
         index on subs(qdecri(Identific),11,10) to (XDRV_SH+"QUSERS1")
         index on Usrnum                        to (XDRV_SH+"QUSERS2")
         QUSERS->(dbclosearea())
      endif

      qmensa("(5) - Aguarde, Indexando QINST...")
      if quse(XDRV_SH,"QINST",NIL,"E")
         index on EMPRESA to (XDRV_SH+"QINST1")
         index on RAZAO   to (XDRV_SH+"QINST2")
         QINST->(dbclosearea())
      endif

      qmensa("(4) - Aguarde, Indexando QPROGS...")
      if quse("","QPROGS",NIL,"E")
         index on PROG to ("QPROGS")
         QPROGS->(dbclosearea())
      endif

      qmensa("(3) - Aguarde, Indexando QACESS...")
      if quse("","QACESS",NIL,"E")
         index on Empresa + Usrnum + Prog to ("QACESS1")
         index on Empresa + Prog + Usrnum to ("QACESS2")
         QACESS->(dbclosearea())
      endif

      qmensa("(2) - Aguarde, Indexando QLOGIN...")
      if quse("","QLOGIN",NIL,"E")
         index on Empresa + dtos(Datalog) + Inicio to ("QLOGIN1")
         index on Empresa + Usrnum + dtos(Datalog) to ("QLOGIN2")
         index on Empresa + Prog + dtos(Datalog)   to ("QLOGIN3")
         QLOGIN->(dbclosearea())
      endif

      qmensa("(1) - Aguarde, Indexando QHELP...")
      if quse("","QHELP",NIL,"E")
         index on Prog to ("QHELP")
         QHELP->(dbclosearea())
      endif

   endif

   qsay(24,75,"(   )")

return

