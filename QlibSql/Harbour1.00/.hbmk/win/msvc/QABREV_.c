/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QABREV_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QABREV );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( SPACE );
HB_FUNC_EXTERN( AT );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QABREV_ )
{ "QABREV", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QABREV )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "SPACE", {HB_FS_PUBLIC}, {HB_FUNCNAME( SPACE )}, NULL },
{ "AT", {HB_FS_PUBLIC}, {HB_FUNCNAME( AT )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QABREV_, "QABREV_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QABREV_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QABREV_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QABREV )
{
	static const HB_BYTE pcode[] =
	{
		13,2,3,36,6,0,121,80,5,36,7,0,122,165,
		80,4,25,41,36,8,0,95,5,176,1,0,95,3,
		95,4,1,12,1,35,28,17,36,9,0,176,1,0,
		95,3,95,4,1,12,1,80,5,36,7,0,175,4,
		0,176,1,0,95,3,12,1,15,28,209,36,12,0,
		122,165,80,4,25,36,36,13,0,176,2,0,95,3,
		95,4,1,176,3,0,95,5,12,1,72,95,5,12,
		2,95,3,95,4,2,36,12,0,175,4,0,176,1,
		0,95,3,12,1,15,28,214,36,15,0,176,4,0,
		95,1,95,2,12,2,80,1,36,16,0,95,1,121,
		8,28,11,176,3,0,95,5,12,1,25,7,95,3,
		95,1,1,80,1,36,17,0,95,1,110,7
	};

	hb_vmExecute( pcode, symbols );
}

