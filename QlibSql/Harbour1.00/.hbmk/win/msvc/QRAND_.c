/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QRAND_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QRAND );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_INITSTATICS();


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QRAND_ )
{ "QRAND", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QRAND )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "(_INITSTATICS00002)", {HB_FS_INITEXIT | HB_FS_LOCAL}, {hb_INITSTATICS}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QRAND_, "QRAND_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QRAND_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QRAND_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QRAND )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,116,2,0,36,5,0,176,1,0,95,1,
		12,1,28,5,121,80,1,36,6,0,95,1,121,69,
		28,6,120,82,2,0,36,7,0,103,2,0,28,17,
		36,8,0,95,1,82,1,0,36,9,0,9,82,2,
		0,36,11,0,103,1,0,92,125,65,97,171,170,42,
		0,50,97,171,170,42,0,18,82,1,0,36,12,0,
		103,1,0,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_INITSTATICS()
{
	static const HB_BYTE pcode[] =
	{
		117,2,0,2,0,116,2,0,120,82,2,0,7
	};

	hb_vmExecute( pcode, symbols );
}

