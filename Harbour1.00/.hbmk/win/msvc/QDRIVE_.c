/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QDRIVE_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QDRIVE );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QDRIVE_ )
{ "QDRIVE", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QDRIVE )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QDRIVE_, "QDRIVE_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QDRIVE_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QDRIVE_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QDRIVE )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,2,0,7
	};

	hb_vmExecute( pcode, symbols );
}

