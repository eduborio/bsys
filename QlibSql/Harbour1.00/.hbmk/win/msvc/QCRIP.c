/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QCRIP.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QENCRI );
HB_FUNC_EXTERN( MOD );
HB_FUNC_EXTERN( CHR );
HB_FUNC_EXTERN( NUMXOR );
HB_FUNC_EXTERN( ASC );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( LEN );
HB_FUNC( QDECRI );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QCRIP )
{ "QENCRI", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QENCRI )}, NULL },
{ "MOD", {HB_FS_PUBLIC}, {HB_FUNCNAME( MOD )}, NULL },
{ "CHR", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHR )}, NULL },
{ "NUMXOR", {HB_FS_PUBLIC}, {HB_FUNCNAME( NUMXOR )}, NULL },
{ "ASC", {HB_FS_PUBLIC}, {HB_FUNCNAME( ASC )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "QDECRI", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QDECRI )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QCRIP, "QCRIP.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QCRIP
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QCRIP )
   #include "hbiniseg.h"
#endif

HB_FUNC( QENCRI )
{
	static const HB_BYTE pcode[] =
	{
		13,2,1,36,2,0,121,80,2,36,3,0,106,1,
		0,80,3,36,7,0,122,165,80,2,25,99,36,9,
		0,176,1,0,95,2,92,2,12,2,121,8,28,42,
		36,10,0,96,3,0,176,2,0,176,3,0,176,4,
		0,176,5,0,95,1,95,2,122,12,3,12,1,92,
		2,72,93,255,0,12,2,12,1,135,25,37,36,12,
		0,96,3,0,176,2,0,176,3,0,176,4,0,176,
		5,0,95,1,95,2,122,12,3,12,1,93,255,0,
		12,2,12,1,135,36,7,0,175,2,0,176,6,0,
		95,1,12,1,15,28,151,36,17,0,95,3,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QDECRI )
{
	static const HB_BYTE pcode[] =
	{
		13,2,1,36,21,0,121,80,2,36,22,0,106,1,
		0,80,3,36,26,0,122,165,80,2,25,99,36,28,
		0,176,1,0,95,2,92,2,12,2,121,8,28,42,
		36,29,0,96,3,0,176,2,0,176,3,0,176,4,
		0,176,5,0,95,1,95,2,122,12,3,12,1,93,
		255,0,12,2,92,2,49,12,1,135,25,37,36,31,
		0,96,3,0,176,2,0,176,3,0,176,4,0,176,
		5,0,95,1,95,2,122,12,3,12,1,93,255,0,
		12,2,12,1,135,36,26,0,175,2,0,176,6,0,
		95,1,12,1,15,28,151,36,36,0,95,3,110,7
	};

	hb_vmExecute( pcode, symbols );
}

