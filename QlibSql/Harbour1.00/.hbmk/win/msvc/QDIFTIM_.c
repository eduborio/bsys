/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QDIFTIM_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QDIFTIME );
HB_FUNC_EXTERN( TSTRING );
HB_FUNC_EXTERN( SECS );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QDIFTIM_ )
{ "QDIFTIME", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QDIFTIME )}, NULL },
{ "TSTRING", {HB_FS_PUBLIC}, {HB_FUNCNAME( TSTRING )}, NULL },
{ "SECS", {HB_FS_PUBLIC}, {HB_FUNCNAME( SECS )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QDIFTIM_, "QDIFTIM_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QDIFTIM_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QDIFTIM_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QDIFTIME )
{
	static const HB_BYTE pcode[] =
	{
		13,0,2,36,25,0,176,1,0,95,2,95,1,35,
		28,9,97,128,81,1,0,25,3,121,176,2,0,95,
		2,12,1,72,176,2,0,95,1,12,1,49,20,1,
		7
	};

	hb_vmExecute( pcode, symbols );
}

