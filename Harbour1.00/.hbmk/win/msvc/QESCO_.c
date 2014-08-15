/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QESCO_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QESCO );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( SEEKB_SL );
HB_FUNC_EXTERN( QSBLOC );
HB_FUNC_EXTERN( QACHOICE );
HB_FUNC_EXTERN( QRBLOC );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QESCO_ )
{ "QESCO", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QESCO )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "XFLAG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "SEEKB_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( SEEKB_SL )}, NULL },
{ "XNIVEL", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QSBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSBLOC )}, NULL },
{ "QACHOICE", {HB_FS_PUBLIC}, {HB_FUNCNAME( QACHOICE )}, NULL },
{ "QRBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRBLOC )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QESCO_, "QESCO_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QESCO_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QESCO_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QESCO )
{
	static const HB_BYTE pcode[] =
	{
		13,3,5,36,4,0,4,0,0,80,8,36,7,0,
		176,1,0,95,5,12,1,28,5,121,80,5,36,9,
		0,120,83,2,0,36,10,0,95,1,121,35,28,52,
		36,11,0,176,3,0,106,2,255,0,109,4,0,106,
		2,83,0,12,3,80,8,36,12,0,95,8,122,1,
		122,1,80,1,36,13,0,95,8,122,1,92,2,1,
		80,2,36,14,0,174,2,0,36,20,0,176,5,0,
		95,1,95,2,92,24,92,79,12,4,80,7,36,22,
		0,176,1,0,176,6,0,95,1,95,2,95,4,95,
		3,95,5,12,5,165,80,6,12,1,31,9,36,23,
		0,95,6,80,3,36,26,0,176,7,0,95,1,95,
		2,95,7,20,3,36,27,0,7
	};

	hb_vmExecute( pcode, symbols );
}

