/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QDIGITO_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QDIGITO );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( VAL );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( STR );
HB_FUNC_EXTERN( INT );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QDIGITO_ )
{ "QDIGITO", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QDIGITO )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "VAL", {HB_FS_PUBLIC}, {HB_FUNCNAME( VAL )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "STR", {HB_FS_PUBLIC}, {HB_FUNCNAME( STR )}, NULL },
{ "INT", {HB_FS_PUBLIC}, {HB_FUNCNAME( INT )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QDIGITO_, "QDIGITO_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QDIGITO_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QDIGITO_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QDIGITO )
{
	static const HB_BYTE pcode[] =
	{
		13,5,1,36,6,0,121,80,2,36,7,0,121,80,
		3,36,8,0,121,80,4,36,9,0,92,2,80,6,
		36,11,0,176,1,0,95,1,12,1,165,80,5,25,
		58,36,12,0,96,2,0,176,2,0,176,3,0,95,
		1,95,5,122,12,3,12,1,95,6,65,135,36,14,
		0,95,6,92,7,5,28,8,36,15,0,122,80,6,
		36,17,0,174,6,0,36,11,0,126,5,255,255,95,
		5,122,35,28,198,36,21,0,95,2,92,11,50,80,
		3,36,24,0,95,3,121,5,31,8,95,3,122,5,
		28,10,36,25,0,121,80,4,25,12,36,27,0,92,
		11,95,3,49,80,4,36,30,0,176,4,0,176,5,
		0,95,4,12,1,122,20,2,7
	};

	hb_vmExecute( pcode, symbols );
}

