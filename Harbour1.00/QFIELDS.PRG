
function qpublicfields ( cPREFIX )
    local nCONT, cMACRO
    iif(cPREFIX==NIL,cPREFIX:="f",NIL)
    for nCONT = 1 to fcount()
        cMACRO := cPREFIX + fieldname(nCONT)
        public &cMACRO.
    next
return

function qreleasefields ( cPREFIX )
    local nCONT, cMACRO
    iif(cPREFIX==NIL,cPREFIX:="f",NIL)
    for nCONT = 1 to fcount()
        cMACRO := cPREFIX + fieldname(nCONT)
        release &cMACRO.
    next
return

function qinitfields ( cPREFIX )
    local nCONT
    private cMACRO
    iif(cPREFIX==NIL,cPREFIX:="f",NIL)
    for nCONT = 1 to fcount()
        cMACRO := fieldname(nCONT)
        do case
           case type("&cMACRO") $ "Cc"
                &( cPREFIX + cMACRO ) := space(len(&cMACRO))
           case type("&cMACRO") $ "NFnf"
                &( cPREFIX + cMACRO ) := 0
           case type("&cMACRO") $ "Ll"
                &( cPREFIX + cMACRO ) := .f.
           case type("&cMACRO") $ "Dd"
                &( cPREFIX + cMACRO ) := ctod("")
           case type("&cMACRO") $ "Mm"
                &( cPREFIX + cMACRO ) := " "
        endcase
    next
return

function qcopyfields ( cPREFIX )
    local nCONT
    iif(cPREFIX==NIL,cPREFIX:="f",NIL)
    for nCONT = 1 to fcount()
        &( cPREFIX + fieldname(nCONT) ) := &(field(nCONT))
    next
return

function qreplacefields ( cPREFIX )
    local nCONT
    iif(cPREFIX==NIL,cPREFIX:="f",NIL)
    for nCONT = 1 to fcount()
        replace &(fieldname(nCONT)) with &( cPREFIX + fieldname(nCONT) )
    next

    //if rddName() == "MEDNTX"
    //   qmensa("Apenas um teste pra ver Coeh!!!")
    //   qinkey(0)
    //endif


return

