/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "POSCU_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( POSCU_SL );
HB_FUNC_EXTERN( SETPOS );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_POSCU_ )
{ "POSCU_SL", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( POSCU_SL )}, NULL },
{ "SETPOS", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETPOS )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_POSCU_, "POSCU_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_POSCU_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_POSCU_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( POSCU_SL )
{
	static const HB_BYTE pcode[] =
	{
		13,0,2,36,2,0,176,1,0,95,1,95,2,20,
		2,7
	};

	hb_vmExecute( pcode, symbols );
}

