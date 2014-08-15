/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QTIRAPON.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QTIRAPONTO );
HB_FUNC_EXTERN( VALTYPE );
HB_FUNC_EXTERN( STRTRAN );
HB_FUNC_EXTERN( DTOC );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QTIRAPON )
{ "QTIRAPONTO", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QTIRAPONTO )}, NULL },
{ "VALTYPE", {HB_FS_PUBLIC}, {HB_FUNCNAME( VALTYPE )}, NULL },
{ "STRTRAN", {HB_FS_PUBLIC}, {HB_FUNCNAME( STRTRAN )}, NULL },
{ "DTOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( DTOC )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QTIRAPON, "QTIRAPON.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QTIRAPON
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QTIRAPON )
   #include "hbiniseg.h"
#endif

HB_FUNC( QTIRAPONTO )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,4,0,176,1,0,95,1,12,1,106,
		2,68,0,8,28,29,36,5,0,176,2,0,176,3,
		0,95,1,12,1,106,2,47,0,106,1,0,12,3,
		80,1,26,136,0,36,7,0,176,2,0,95,1,106,
		2,46,0,106,1,0,12,3,80,1,36,8,0,176,
		2,0,95,1,106,2,44,0,106,1,0,12,3,80,
		1,36,9,0,176,2,0,95,1,106,2,59,0,106,
		1,0,12,3,80,1,36,10,0,176,2,0,95,1,
		106,2,45,0,106,1,0,12,3,80,1,36,11,0,
		176,2,0,95,1,106,2,47,0,106,1,0,12,3,
		80,1,36,12,0,176,2,0,95,1,106,2,92,0,
		106,1,0,12,3,80,1,36,13,0,176,2,0,95,
		1,106,2,58,0,106,1,0,12,3,80,1,36,16,
		0,95,1,110,7
	};

	hb_vmExecute( pcode, symbols );
}

