/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "seekc_sl.prg"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( SEEKC_SL );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( CHRSC_SL );
HB_FUNC_EXTERN( AADD );
HB_FUNC_INITSTATICS();


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_SEEKC_SL )
{ "SEEKC_SL", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( SEEKC_SL )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "NLIN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "NCOL", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "CHRSC_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHRSC_SL )}, NULL },
{ "AADD", {HB_FS_PUBLIC}, {HB_FUNCNAME( AADD )}, NULL },
{ "NCOLRET", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "NLINCOLRET", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "(_INITSTATICS00001)", {HB_FS_INITEXIT | HB_FS_LOCAL}, {hb_INITSTATICS}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_SEEKC_SL, "seekc_sl.prg", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_SEEKC_SL
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_SEEKC_SL )
   #include "hbiniseg.h"
#endif

HB_FUNC( SEEKC_SL )
{
	static const HB_BYTE pcode[] =
	{
		13,3,3,116,8,0,36,5,0,121,80,4,36,6,
		0,121,80,5,36,7,0,121,80,6,36,9,0,103,
		1,0,100,8,28,8,4,0,0,82,1,0,36,11,
		0,176,1,0,103,1,0,12,1,121,8,28,112,36,
		12,0,121,165,83,2,0,25,97,36,13,0,121,165,
		83,3,0,25,64,36,14,0,176,4,0,109,2,0,
		109,3,0,106,2,83,0,12,3,95,1,8,28,30,
		36,15,0,174,6,0,36,16,0,176,5,0,103,1,
		0,95,6,109,3,0,109,2,0,4,3,0,20,2,
		36,13,0,109,3,0,23,21,83,3,0,92,79,15,
		28,191,36,19,0,121,83,3,0,36,12,0,109,2,
		0,23,21,83,2,0,92,24,15,28,158,36,23,0,
		176,1,0,103,1,0,12,1,121,15,28,59,36,24,
		0,122,165,80,4,25,39,36,26,0,103,1,0,95,
		4,1,122,1,95,2,8,28,17,36,27,0,103,1,
		0,95,4,1,92,2,1,83,6,0,36,24,0,175,
		4,0,176,1,0,103,1,0,12,1,15,28,210,36,
		34,0,109,7,0,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_INITSTATICS()
{
	static const HB_BYTE pcode[] =
	{
		117,8,0,1,0,7
	};

	hb_vmExecute( pcode, symbols );
}

