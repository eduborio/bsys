/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "seekl_sl.prg"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( SEEKL_SL );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( CHRSC_SL );
HB_FUNC_EXTERN( AADD );
HB_FUNC_INITSTATICS();


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_SEEKL_SL )
{ "SEEKL_SL", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( SEEKL_SL )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "NLIN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "NCOL", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "CHRSC_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHRSC_SL )}, NULL },
{ "AADD", {HB_FS_PUBLIC}, {HB_FUNCNAME( AADD )}, NULL },
{ "(_INITSTATICS00001)", {HB_FS_INITEXIT | HB_FS_LOCAL}, {hb_INITSTATICS}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_SEEKL_SL, "seekl_sl.prg", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_SEEKL_SL
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_SEEKL_SL )
   #include "hbiniseg.h"
#endif

HB_FUNC( SEEKL_SL )
{
	static const HB_BYTE pcode[] =
	{
		13,3,3,116,6,0,36,4,0,121,80,4,36,5,
		0,121,80,5,36,6,0,121,80,6,36,8,0,103,
		1,0,100,8,28,8,4,0,0,82,1,0,36,10,
		0,176,1,0,103,1,0,12,1,121,8,28,109,36,
		11,0,121,165,83,2,0,25,94,36,12,0,121,165,
		83,3,0,25,61,36,13,0,176,4,0,109,2,0,
		109,3,0,106,2,83,0,12,3,95,1,8,28,27,
		36,14,0,174,6,0,36,15,0,176,5,0,103,1,
		0,95,6,109,2,0,4,2,0,20,2,36,12,0,
		109,3,0,23,21,83,3,0,92,79,15,28,194,36,
		18,0,121,83,3,0,36,11,0,109,2,0,23,21,
		83,2,0,92,24,15,28,161,36,22,0,176,1,0,
		103,1,0,12,1,121,15,28,58,36,23,0,122,165,
		80,4,25,38,36,25,0,103,1,0,95,4,1,122,
		1,95,2,8,28,16,36,26,0,103,1,0,95,4,
		1,92,2,1,80,5,36,23,0,175,4,0,176,1,
		0,103,1,0,12,1,15,28,211,36,33,0,95,5,
		110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_INITSTATICS()
{
	static const HB_BYTE pcode[] =
	{
		117,6,0,1,0,7
	};

	hb_vmExecute( pcode, symbols );
}

