/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QFLOCK_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QFLOCK );
HB_FUNC_EXTERN( FLOCK );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QFLOCK_ )
{ "QFLOCK", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QFLOCK )}, NULL },
{ "FLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( FLOCK )}, NULL },
{ "XTIMEF", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QFLOCK_, "QFLOCK_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QFLOCK_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QFLOCK_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QFLOCK )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,5,0,122,165,80,1,25,21,36,6,
		0,176,1,0,12,0,28,5,120,110,7,36,5,0,
		175,1,0,109,2,0,15,28,233,36,9,0,9,110,
		7
	};

	hb_vmExecute( pcode, symbols );
}

