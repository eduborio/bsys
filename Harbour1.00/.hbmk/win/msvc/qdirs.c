/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "qdirs.prg"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QMDIR );
HB_FUNC_EXTERN( DIRMAKE );
HB_FUNC( QCDIR );
HB_FUNC_EXTERN( DIRCHANGE );
HB_FUNC( QRDIR );
HB_FUNC_EXTERN( DIRREMOVE );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QDIRS )
{ "QMDIR", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QMDIR )}, NULL },
{ "DIRMAKE", {HB_FS_PUBLIC}, {HB_FUNCNAME( DIRMAKE )}, NULL },
{ "QCDIR", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QCDIR )}, NULL },
{ "DIRCHANGE", {HB_FS_PUBLIC}, {HB_FUNCNAME( DIRCHANGE )}, NULL },
{ "QRDIR", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QRDIR )}, NULL },
{ "DIRREMOVE", {HB_FS_PUBLIC}, {HB_FUNCNAME( DIRREMOVE )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QDIRS, "qdirs.prg", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QDIRS
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QDIRS )
   #include "hbiniseg.h"
#endif

HB_FUNC( QMDIR )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,2,0,9,80,2,36,3,0,176,1,
		0,95,1,12,1,121,8,28,10,36,4,0,120,80,
		2,25,8,36,6,0,9,80,2,36,8,0,95,2,
		110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QCDIR )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,11,0,9,80,2,36,12,0,176,3,
		0,95,1,12,1,121,8,28,10,36,13,0,120,80,
		2,25,8,36,15,0,9,80,2,36,17,0,95,2,
		110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QRDIR )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,20,0,9,80,2,36,21,0,176,5,
		0,95,1,12,1,121,8,28,10,36,22,0,120,80,
		2,25,8,36,24,0,9,80,2,36,26,0,95,2,
		110,7
	};

	hb_vmExecute( pcode, symbols );
}

