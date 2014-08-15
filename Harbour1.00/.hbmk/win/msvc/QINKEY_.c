/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QINKEY_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QINKEY );
HB_FUNC_EXTERN( INKEY );
HB_FUNC_EXTERN( SETKEY );
HB_FUNC_EXTERN( PROCNAME );
HB_FUNC_EXTERN( PROCLINE );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QINKEY_ )
{ "QINKEY", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QINKEY )}, NULL },
{ "INKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( INKEY )}, NULL },
{ "SETKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETKEY )}, NULL },
{ "EVAL", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "PROCNAME", {HB_FS_PUBLIC}, {HB_FUNCNAME( PROCNAME )}, NULL },
{ "PROCLINE", {HB_FS_PUBLIC}, {HB_FUNCNAME( PROCLINE )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QINKEY_, "QINKEY_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QINKEY_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QINKEY_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QINKEY )
{
	static const HB_BYTE pcode[] =
	{
		13,2,1,36,7,0,95,1,100,8,28,15,101,123,
		20,174,71,225,122,132,63,10,2,80,1,36,9,0,
		176,1,0,95,1,12,1,80,2,36,11,0,176,2,
		0,95,2,12,1,165,80,3,100,69,28,27,36,12,
		0,48,3,0,95,3,176,4,0,92,2,12,1,176,
		5,0,92,2,12,1,112,2,73,36,15,0,95,2,
		110,7
	};

	hb_vmExecute( pcode, symbols );
}

