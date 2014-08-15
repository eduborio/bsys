/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QM.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QM1 );
HB_FUNC_EXTERN( QMENSA );
HB_FUNC( QM2 );
HB_FUNC( QM3 );
HB_FUNC( QM4 );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QM )
{ "QM1", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QM1 )}, NULL },
{ "QMENSA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QMENSA )}, NULL },
{ "QM2", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QM2 )}, NULL },
{ "QM3", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QM3 )}, NULL },
{ "QM4", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QM4 )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QM, "QM.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QM
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QM )
   #include "hbiniseg.h"
#endif

HB_FUNC( QM1 )
{
	static const HB_BYTE pcode[] =
	{
		36,3,0,176,1,0,106,58,78,97,111,32,102,111,
		105,32,112,111,115,115,105,118,101,108,32,99,111,109,
		112,108,101,116,97,114,32,97,32,105,110,99,108,117,
		115,132,111,33,32,84,101,110,116,101,32,110,111,118,
		97,109,101,110,116,101,46,46,46,0,106,2,66,0,
		20,2,36,4,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QM2 )
{
	static const HB_BYTE pcode[] =
	{
		36,7,0,176,1,0,106,59,78,132,111,32,102,111,
		105,32,112,111,115,115,105,118,101,108,32,99,111,109,
		112,108,101,116,97,114,32,97,32,97,108,116,101,114,
		97,135,132,111,33,32,84,101,110,116,101,32,110,111,
		118,97,109,101,110,116,101,46,46,46,0,106,2,66,
		0,20,2,36,8,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QM3 )
{
	static const HB_BYTE pcode[] =
	{
		36,11,0,176,1,0,106,58,78,132,111,32,102,111,
		105,32,112,111,115,115,105,118,101,108,32,99,111,109,
		112,108,101,116,97,114,32,97,32,101,120,99,108,117,
		115,132,111,33,32,84,101,110,116,101,32,110,111,118,
		97,109,101,110,116,101,46,46,46,0,106,2,66,0,
		20,2,36,12,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QM4 )
{
	static const HB_BYTE pcode[] =
	{
		36,15,0,176,1,0,106,35,67,162,100,105,103,111,
		32,106,160,32,117,116,105,108,105,122,97,100,111,44,
		32,116,101,110,116,101,32,111,117,116,114,111,32,33,
		0,106,2,66,0,20,2,36,16,0,7
	};

	hb_vmExecute( pcode, symbols );
}

