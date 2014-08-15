/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "ATCSC_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( ATCSC_SL );
HB_FUNC_EXTERN( NTOCOLOR );
HB_FUNC_EXTERN( SCREENATTR );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_ATCSC_ )
{ "ATCSC_SL", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( ATCSC_SL )}, NULL },
{ "NTOCOLOR", {HB_FS_PUBLIC}, {HB_FUNCNAME( NTOCOLOR )}, NULL },
{ "SCREENATTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SCREENATTR )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_ATCSC_, "ATCSC_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_ATCSC_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_ATCSC_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( ATCSC_SL )
{
	static const HB_BYTE pcode[] =
	{
		13,0,2,36,2,0,176,1,0,176,2,0,95,1,
		95,2,12,2,20,1,7
	};

	hb_vmExecute( pcode, symbols );
}

