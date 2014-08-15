/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QBEEP_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QBEEP );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QBEEP_ )
{ "QBEEP", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QBEEP )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QBEEP_, "QBEEP_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QBEEP_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QBEEP_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QBEEP )
{
	static const HB_BYTE pcode[] =
	{
		36,7,0,7
	};

	hb_vmExecute( pcode, symbols );
}

