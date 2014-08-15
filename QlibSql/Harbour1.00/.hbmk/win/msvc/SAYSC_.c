/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "SAYSC_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( SAYSC_SL );
HB_FUNC_EXTERN( ROW );
HB_FUNC_EXTERN( COL );
HB_FUNC_EXTERN( REPLICATE );
HB_FUNC_EXTERN( CHR );
HB_FUNC_EXTERN( COLORTON );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( SCREENMIX );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_SAYSC_ )
{ "SAYSC_SL", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( SAYSC_SL )}, NULL },
{ "ROW", {HB_FS_PUBLIC}, {HB_FUNCNAME( ROW )}, NULL },
{ "COL", {HB_FS_PUBLIC}, {HB_FUNCNAME( COL )}, NULL },
{ "REPLICATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( REPLICATE )}, NULL },
{ "CHR", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHR )}, NULL },
{ "COLORTON", {HB_FS_PUBLIC}, {HB_FUNCNAME( COLORTON )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "SCREENMIX", {HB_FS_PUBLIC}, {HB_FUNCNAME( SCREENMIX )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_SAYSC_, "SAYSC_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_SAYSC_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_SAYSC_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( SAYSC_SL )
{
	static const HB_BYTE pcode[] =
	{
		13,4,4,36,2,0,106,1,0,80,5,36,3,0,
		121,80,7,36,4,0,106,1,0,80,8,36,5,0,
		176,1,0,12,0,80,6,36,6,0,176,2,0,12,
		0,80,7,36,7,0,176,3,0,176,4,0,176,5,
		0,95,4,12,1,12,1,176,6,0,95,3,12,1,
		12,2,80,5,36,8,0,176,7,0,95,3,95,5,
		95,1,95,2,12,4,80,8,36,12,0,95,8,110,
		7
	};

	hb_vmExecute( pcode, symbols );
}

