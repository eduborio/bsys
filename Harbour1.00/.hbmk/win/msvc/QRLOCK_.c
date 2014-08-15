/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QRLOCK_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QRLOCK );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( DBRLOCK );
HB_FUNC( QUNLOCK );
HB_FUNC_EXTERN( DBRUNLOCK );
HB_FUNC_EXTERN( DBGOTO );
HB_FUNC_EXTERN( RECNO );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QRLOCK_ )
{ "QRLOCK", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QRLOCK )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "DBRLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBRLOCK )}, NULL },
{ "XTIMER", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QUNLOCK", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QUNLOCK )}, NULL },
{ "DBRUNLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBRUNLOCK )}, NULL },
{ "DBGOTO", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBGOTO )}, NULL },
{ "RECNO", {HB_FS_PUBLIC}, {HB_FUNCNAME( RECNO )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QRLOCK_, "QRLOCK_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QRLOCK_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QRLOCK_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QRLOCK )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,5,0,122,165,80,2,25,48,36,6,
		0,176,1,0,95,1,12,1,28,15,36,7,0,176,
		2,0,12,0,28,20,120,110,7,36,9,0,176,2,
		0,95,1,12,1,28,5,120,110,7,36,5,0,175,
		2,0,109,3,0,15,28,206,36,13,0,9,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QUNLOCK )
{
	static const HB_BYTE pcode[] =
	{
		36,16,0,176,5,0,20,0,36,17,0,176,6,0,
		176,7,0,12,0,20,1,36,18,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

