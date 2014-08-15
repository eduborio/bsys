/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QCLEAR_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QCLEAR );
HB_FUNC_EXTERN( CLEARWIN );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QCLEAR_ )
{ "QCLEAR", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QCLEAR )}, NULL },
{ "CLEARWIN", {HB_FS_PUBLIC}, {HB_FUNCNAME( CLEARWIN )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QCLEAR_, "QCLEAR_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QCLEAR_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QCLEAR_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QCLEAR )
{
	static const HB_BYTE pcode[] =
	{
		13,0,5,36,2,0,176,1,0,95,1,95,2,95,
		3,95,4,95,5,20,5,7
	};

	hb_vmExecute( pcode, symbols );
}

