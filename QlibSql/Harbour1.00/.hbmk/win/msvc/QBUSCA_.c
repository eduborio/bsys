/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QBUSCA_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QBUSCA_SUP );
HB_FUNC_EXTERN( SPACE );
HB_FUNC_EXTERN( RECNO );
HB_FUNC_EXTERN( DBSEEK );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( DBGOTO );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QBUSCA_ )
{ "QBUSCA_SUP", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QBUSCA_SUP )}, NULL },
{ "SPACE", {HB_FS_PUBLIC}, {HB_FUNCNAME( SPACE )}, NULL },
{ "RECNO", {HB_FS_PUBLIC}, {HB_FUNCNAME( RECNO )}, NULL },
{ "DBSEEK", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSEEK )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "DBGOTO", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBGOTO )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QBUSCA_, "QBUSCA_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QBUSCA_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QBUSCA_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QBUSCA_SUP )
{
	static const HB_BYTE pcode[] =
	{
		13,2,1,36,6,0,176,1,0,92,8,12,1,80,
		2,36,7,0,176,2,0,12,0,80,3,36,9,0,
		176,3,0,95,1,12,1,28,91,36,11,0,176,4,
		0,95,1,12,1,92,8,5,28,18,36,12,0,176,
		5,0,95,1,92,4,12,2,80,2,25,60,36,13,
		0,176,4,0,95,1,12,1,92,4,5,28,18,36,
		14,0,176,5,0,95,1,92,2,12,2,80,2,25,
		29,36,15,0,176,4,0,95,1,12,1,92,2,5,
		28,14,36,16,0,176,1,0,92,8,12,1,80,2,
		36,20,0,176,6,0,95,3,20,1,36,21,0,95,
		2,110,7
	};

	hb_vmExecute( pcode, symbols );
}

