/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QDIVER.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( Q_MSG_ACESSO_USR );
HB_FUNC( Q_BACK_FIELD );
HB_FUNC_EXTERN( __KEYBOARD );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QDIVER )
{ "Q_MSG_ACESSO_USR", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( Q_MSG_ACESSO_USR )}, NULL },
{ "XUSRA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "Q_BACK_FIELD", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( Q_BACK_FIELD )}, NULL },
{ "XFLAG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "__KEYBOARD", {HB_FS_PUBLIC}, {HB_FUNCNAME( __KEYBOARD )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QDIVER, "QDIVER.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QDIVER
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QDIVER )
   #include "hbiniseg.h"
#endif

HB_FUNC( Q_MSG_ACESSO_USR )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,3,0,106,17,69,83,67,47,65,76,
		84,45,80,47,65,76,84,45,79,47,0,80,1,36,
		4,0,106,2,73,0,109,1,0,24,28,15,96,1,
		0,106,7,60,73,62,110,99,47,0,135,36,5,0,
		106,2,65,0,109,1,0,24,28,15,96,1,0,106,
		7,60,65,62,108,116,47,0,135,36,6,0,106,2,
		67,0,109,1,0,24,28,15,96,1,0,106,7,60,
		67,62,111,110,47,0,135,36,7,0,106,2,69,0,
		109,1,0,24,28,14,96,1,0,106,6,60,69,62,
		120,99,0,135,36,8,0,95,1,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( Q_BACK_FIELD )
{
	static const HB_BYTE pcode[] =
	{
		36,11,0,9,83,3,0,36,12,0,176,4,0,106,
		2,23,0,20,1,36,13,0,7
	};

	hb_vmExecute( pcode, symbols );
}

