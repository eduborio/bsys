/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "CHRSC_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( CHRSC_SL );
HB_FUNC_EXTERN( SPACE );
HB_FUNC_EXTERN( SCREENSTR );
HB_FUNC_EXTERN( LEFT );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_CHRSC_ )
{ "CHRSC_SL", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( CHRSC_SL )}, NULL },
{ "SPACE", {HB_FS_PUBLIC}, {HB_FUNCNAME( SPACE )}, NULL },
{ "SCREENSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SCREENSTR )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_CHRSC_, "CHRSC_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_CHRSC_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_CHRSC_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( CHRSC_SL )
{
	static const HB_BYTE pcode[] =
	{
		13,1,3,36,3,0,176,1,0,122,12,1,80,4,
		36,5,0,176,2,0,95,1,95,2,122,12,3,80,
		4,36,7,0,176,3,0,95,4,122,20,2,7
	};

	hb_vmExecute( pcode, symbols );
}

