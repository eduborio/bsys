/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QARRAY.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QARRAY );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QARRAY )
{ "QARRAY", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QARRAY )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QARRAY, "QARRAY.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QARRAY
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QARRAY )
   #include "hbiniseg.h"
#endif

HB_FUNC( QARRAY )
{
	static const HB_BYTE pcode[] =
	{
		36,3,0,7
	};

	hb_vmExecute( pcode, symbols );
}

