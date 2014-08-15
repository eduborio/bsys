/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QCRC_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QCRC );
HB_FUNC_EXTERN( CHECK_SL );
HB_FUNC_EXTERN( INT );
HB_FUNC_EXTERN( QRAND );
HB_FUNC_EXTERN( STRZERO );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QCRC_ )
{ "QCRC", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QCRC )}, NULL },
{ "CHECK_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHECK_SL )}, NULL },
{ "INT", {HB_FS_PUBLIC}, {HB_FUNCNAME( INT )}, NULL },
{ "QRAND", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRAND )}, NULL },
{ "STRZERO", {HB_FS_PUBLIC}, {HB_FUNCNAME( STRZERO )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QCRC_, "QCRC_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QCRC_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QCRC_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QCRC )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,3,0,176,1,0,95,1,12,1,80,
		2,36,4,0,95,2,121,35,28,8,96,2,0,92,
		255,137,36,5,0,176,2,0,176,3,0,95,2,12,
		1,128,0,228,11,84,2,0,0,0,65,12,1,80,
		2,36,6,0,176,4,0,95,2,92,10,20,2,7
	};

	hb_vmExecute( pcode, symbols );
}

