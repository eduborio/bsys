/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "ATNSC_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( ATNSC_SL );
HB_FUNC_EXTERN( SCREENATTR );
HB_FUNC_EXTERN( NTOCOLOR );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_ATNSC_ )
{ "ATNSC_SL", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( ATNSC_SL )}, NULL },
{ "SCREENATTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SCREENATTR )}, NULL },
{ "NTOCOLOR", {HB_FS_PUBLIC}, {HB_FUNCNAME( NTOCOLOR )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_ATNSC_, "ATNSC_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_ATNSC_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_ATNSC_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( ATNSC_SL )
{
	static const HB_BYTE pcode[] =
	{
		13,2,2,36,3,0,106,1,0,80,3,36,4,0,
		121,80,4,36,7,0,176,1,0,95,1,95,2,12,
		2,80,4,36,10,0,176,2,0,95,4,12,1,80,
		3,36,12,0,95,3,110,7
	};

	hb_vmExecute( pcode, symbols );
}

