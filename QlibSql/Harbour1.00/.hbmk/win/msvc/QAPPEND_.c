/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QAPPEND_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QAPPEND );
HB_FUNC_EXTERN( VALTYPE );
HB_FUNC_EXTERN( DBAPPEND );
HB_FUNC_EXTERN( NETERR );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QAPPEND_ )
{ "QAPPEND", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QAPPEND )}, NULL },
{ "VALTYPE", {HB_FS_PUBLIC}, {HB_FUNCNAME( VALTYPE )}, NULL },
{ "DBAPPEND", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBAPPEND )}, NULL },
{ "NETERR", {HB_FS_PUBLIC}, {HB_FUNCNAME( NETERR )}, NULL },
{ "XTIMEA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QAPPEND_, "QAPPEND_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QAPPEND_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QAPPEND_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QAPPEND )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,5,0,176,1,0,95,1,12,1,106,
		2,76,0,69,28,5,120,80,1,36,7,0,122,165,
		80,2,25,31,36,8,0,176,2,0,95,1,20,1,
		36,9,0,176,3,0,12,0,31,5,120,110,7,36,
		7,0,175,2,0,109,4,0,15,28,223,36,12,0,
		9,110,7
	};

	hb_vmExecute( pcode, symbols );
}

