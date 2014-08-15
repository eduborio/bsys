/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QINTCHR_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QINTCHR );
HB_FUNC_EXTERN( VALTYPE );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( LEFT );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QINTCHR_ )
{ "QINTCHR", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QINTCHR )}, NULL },
{ "VALTYPE", {HB_FS_PUBLIC}, {HB_FUNCNAME( VALTYPE )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QINTCHR_, "QINTCHR_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QINTCHR_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QINTCHR_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QINTCHR )
{
	static const HB_BYTE pcode[] =
	{
		13,2,2,36,3,0,106,1,0,80,4,36,5,0,
		176,1,0,95,2,12,1,106,2,67,0,69,28,11,
		36,6,0,106,2,32,0,80,2,36,9,0,122,165,
		80,3,25,28,36,10,0,96,4,0,176,2,0,95,
		1,95,3,122,12,3,95,2,72,135,36,9,0,175,
		3,0,176,3,0,95,1,12,1,15,28,222,36,13,
		0,176,4,0,95,4,176,3,0,95,4,12,1,122,
		49,20,2,7
	};

	hb_vmExecute( pcode, symbols );
}

