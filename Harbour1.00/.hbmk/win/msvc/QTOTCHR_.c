/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QTOTCHR_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QTOTCHR );
HB_FUNC_EXTERN( UPPER );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( LEN );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QTOTCHR_ )
{ "QTOTCHR", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QTOTCHR )}, NULL },
{ "UPPER", {HB_FS_PUBLIC}, {HB_FUNCNAME( UPPER )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QTOTCHR_, "QTOTCHR_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QTOTCHR_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QTOTCHR_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QTOTCHR )
{
	static const HB_BYTE pcode[] =
	{
		13,2,3,36,3,0,121,80,5,36,4,0,95,3,
		100,8,28,5,9,80,3,36,5,0,95,3,28,26,
		36,6,0,176,1,0,95,1,12,1,80,1,36,7,
		0,176,1,0,95,2,12,1,80,2,36,9,0,122,
		165,80,4,25,29,36,10,0,176,2,0,95,2,95,
		4,122,12,3,95,1,8,28,5,174,5,0,36,9,
		0,175,4,0,176,3,0,95,2,12,1,15,28,221,
		36,12,0,95,5,110,7
	};

	hb_vmExecute( pcode, symbols );
}

