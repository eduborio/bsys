/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QKEYOFF.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QKEYOFF );
HB_FUNC_EXTERN( SETKEY );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QKEYOFF )
{ "QKEYOFF", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QKEYOFF )}, NULL },
{ "SETKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETKEY )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QKEYOFF, "QKEYOFF.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QKEYOFF
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QKEYOFF )
   #include "hbiniseg.h"
#endif

HB_FUNC( QKEYOFF )
{
	static const HB_BYTE pcode[] =
	{
		36,2,0,176,1,0,92,28,100,20,2,36,3,0,
		176,1,0,92,255,100,20,2,36,4,0,176,1,0,
		92,254,100,20,2,36,5,0,176,1,0,92,253,100,
		20,2,36,6,0,176,1,0,92,252,100,20,2,36,
		7,0,176,1,0,92,251,100,20,2,36,8,0,176,
		1,0,92,250,100,20,2,36,9,0,176,1,0,92,
		249,100,20,2,36,10,0,176,1,0,92,247,100,20,
		2,36,12,0,7
	};

	hb_vmExecute( pcode, symbols );
}

