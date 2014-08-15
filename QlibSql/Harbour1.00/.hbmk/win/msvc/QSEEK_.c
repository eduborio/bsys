/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QSEEK_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QSEEK );
HB_FUNC_EXTERN( DBSEEK );
HB_FUNC( QSEEKN );
HB_FUNC( QNEXTCHAR );
HB_FUNC_EXTERN( DBSKIP );
HB_FUNC_EXTERN( CHR );
HB_FUNC_EXTERN( ASC );
HB_FUNC_EXTERN( RIGHT );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( LEN );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QSEEK_ )
{ "QSEEK", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QSEEK )}, NULL },
{ "DBSEEK", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSEEK )}, NULL },
{ "QSEEKN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QSEEKN )}, NULL },
{ "QNEXTCHAR", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QNEXTCHAR )}, NULL },
{ "DBSKIP", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSKIP )}, NULL },
{ "CHR", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHR )}, NULL },
{ "ASC", {HB_FS_PUBLIC}, {HB_FUNCNAME( ASC )}, NULL },
{ "RIGHT", {HB_FS_PUBLIC}, {HB_FUNCNAME( RIGHT )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QSEEK_, "QSEEK_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QSEEK_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QSEEK_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QSEEK )
{
	static const HB_BYTE pcode[] =
	{
		13,0,2,36,7,0,176,1,0,95,1,95,2,20,
		2,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QSEEKN )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,10,0,176,1,0,176,3,0,95,1,
		12,1,120,20,2,36,11,0,176,4,0,92,255,20,
		1,36,12,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QNEXTCHAR )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,15,0,176,5,0,176,6,0,176,7,
		0,95,1,122,12,2,12,1,122,72,12,1,80,2,
		36,16,0,176,8,0,95,1,176,9,0,95,1,12,
		1,122,49,12,2,95,2,72,110,7
	};

	hb_vmExecute( pcode, symbols );
}

