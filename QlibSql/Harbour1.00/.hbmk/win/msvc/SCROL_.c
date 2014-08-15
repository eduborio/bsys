/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "SCROL_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( SCROL_SL );
HB_FUNC_EXTERN( QSBLOC );
HB_FUNC_EXTERN( SETCLEARA );
HB_FUNC_EXTERN( CLEAR_SL );
HB_FUNC_EXTERN( QRBLOC );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_SCROL_ )
{ "SCROL_SL", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( SCROL_SL )}, NULL },
{ "QSBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSBLOC )}, NULL },
{ "SETCLEARA", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETCLEARA )}, NULL },
{ "CLEAR_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( CLEAR_SL )}, NULL },
{ "QRBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRBLOC )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_SCROL_, "SCROL_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_SCROL_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_SCROL_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( SCROL_SL )
{
	static const HB_BYTE pcode[] =
	{
		13,1,6,36,3,0,176,1,0,95,1,95,5,72,
		95,2,95,3,95,4,12,4,80,7,36,5,0,176,
		2,0,95,6,20,1,36,6,0,176,3,0,92,7,
		92,14,92,21,92,65,20,4,36,9,0,176,4,0,
		95,1,95,2,95,7,20,3,7
	};

	hb_vmExecute( pcode, symbols );
}

