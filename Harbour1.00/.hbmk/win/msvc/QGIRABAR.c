/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QGIRABAR.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QGIRABARRA );
HB_FUNC_EXTERN( QSAY );
HB_FUNC_INITSTATICS();


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QGIRABAR )
{ "QGIRABARRA", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QGIRABARRA )}, NULL },
{ "QSAY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSAY )}, NULL },
{ "(_INITSTATICS00001)", {HB_FS_INITEXIT | HB_FS_LOCAL}, {hb_INITSTATICS}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QGIRABAR, "QGIRABAR.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QGIRABAR
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QGIRABAR )
   #include "hbiniseg.h"
#endif

HB_FUNC( QGIRABARRA )
{
	static const HB_BYTE pcode[] =
	{
		116,2,0,36,5,0,103,1,0,106,2,47,0,8,
		28,11,106,2,45,0,82,1,0,25,66,36,6,0,
		103,1,0,106,2,45,0,8,28,11,106,2,92,0,
		82,1,0,25,44,36,7,0,103,1,0,106,2,92,
		0,8,28,11,106,2,124,0,82,1,0,25,22,36,
		8,0,103,1,0,106,2,124,0,8,28,9,106,2,
		47,0,82,1,0,36,11,0,176,1,0,92,24,92,
		79,103,1,0,20,3,36,13,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_INITSTATICS()
{
	static const HB_BYTE pcode[] =
	{
		117,2,0,1,0,116,2,0,106,2,47,0,82,1,
		0,7
	};

	hb_vmExecute( pcode, symbols );
}

