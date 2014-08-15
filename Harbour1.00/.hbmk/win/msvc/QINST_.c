/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QINST_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QINSTCRC );
HB_FUNC( J_RET_STRING );
HB_FUNC_EXTERN( QCRC );
HB_FUNC_EXTERN( STRZERO );
HB_FUNC_EXTERN( RECNO );
HB_FUNC_EXTERN( FIELDNAME );
HB_FUNC_EXTERN( FCOUNT );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QINST_ )
{ "QINSTCRC", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QINSTCRC )}, NULL },
{ "J_RET_STRING", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( J_RET_STRING )}, NULL },
{ "QCRC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QCRC )}, NULL },
{ "STRZERO", {HB_FS_PUBLIC}, {HB_FUNCNAME( STRZERO )}, NULL },
{ "QINST", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "RECNO", {HB_FS_PUBLIC}, {HB_FUNCNAME( RECNO )}, NULL },
{ "FIELDNAME", {HB_FS_PUBLIC}, {HB_FUNCNAME( FIELDNAME )}, NULL },
{ "FCOUNT", {HB_FS_PUBLIC}, {HB_FUNCNAME( FCOUNT )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QINST_, "QINST_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QINST_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QINST_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QINSTCRC )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,3,0,176,1,0,12,0,80,1,36,
		4,0,176,2,0,95,1,20,1,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( J_RET_STRING )
{
	static const HB_BYTE pcode[] =
	{
		13,2,0,36,7,0,176,3,0,85,108,4,74,176,
		5,0,12,0,119,92,4,12,2,80,2,36,9,0,
		92,2,165,80,1,25,86,36,10,0,176,6,0,95,
		1,12,1,106,30,69,77,80,82,69,83,65,95,82,
		65,90,65,79,95,69,78,68,69,82,69,67,79,95,
		67,71,67,67,80,70,0,24,31,19,106,5,68,82,
		86,95,0,176,6,0,95,1,12,1,24,28,18,36,
		11,0,96,2,0,176,6,0,95,1,12,1,40,11,
		135,36,9,0,175,1,0,176,7,0,12,0,15,28,
		166,36,14,0,95,2,110,7
	};

	hb_vmExecute( pcode, symbols );
}

