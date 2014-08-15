/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QINVER_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QINVER );
HB_FUNC_EXTERN( COLORWIN );
HB_FUNC_EXTERN( INVERTATTR );
HB_FUNC_EXTERN( SCREENATTR );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QINVER_ )
{ "QINVER", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QINVER )}, NULL },
{ "COLORWIN", {HB_FS_PUBLIC}, {HB_FUNCNAME( COLORWIN )}, NULL },
{ "INVERTATTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( INVERTATTR )}, NULL },
{ "SCREENATTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SCREENATTR )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QINVER_, "QINVER_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QINVER_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QINVER_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QINVER )
{
	static const HB_BYTE pcode[] =
	{
		13,1,3,36,2,0,121,80,4,36,5,0,176,1,
		0,95,1,95,2,95,1,95,2,95,3,72,122,49,
		176,2,0,176,3,0,95,1,95,2,12,2,12,1,
		20,5,36,9,0,7
	};

	hb_vmExecute( pcode, symbols );
}

