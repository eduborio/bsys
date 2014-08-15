/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QINVER.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QINVER3 );
HB_FUNC_EXTERN( INVERTATTR );
HB_FUNC_EXTERN( SCREENATTR );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QINVER )
{ "QINVER3", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QINVER3 )}, NULL },
{ "INVERTATTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( INVERTATTR )}, NULL },
{ "SCREENATTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SCREENATTR )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QINVER, "QINVER.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QINVER
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QINVER )
   #include "hbiniseg.h"
#endif

HB_FUNC( QINVER3 )
{
	static const HB_BYTE pcode[] =
	{
		13,1,3,36,2,0,121,80,4,36,4,0,122,165,
		80,4,25,32,36,5,0,176,1,0,176,2,0,95,
		1,95,2,122,12,3,20,1,36,6,0,174,2,0,
		36,4,0,175,4,0,95,3,15,28,223,36,10,0,
		7
	};

	hb_vmExecute( pcode, symbols );
}

