/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QMOUSE.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QMOUSEOK );
HB_FUNC_EXTERN( MOUOK_SL );
HB_FUNC( QMOUSEBO );
HB_FUNC_EXTERN( MOUBO_SL );
HB_FUNC( QMOUSECO );
HB_FUNC_EXTERN( MOUCO_SL );
HB_FUNC( QMOUSELI );
HB_FUNC_EXTERN( MOULI_SL );
HB_FUNC( QMOUSECU );
HB_FUNC_EXTERN( MOUCU_SL );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QMOUSE )
{ "QMOUSEOK", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QMOUSEOK )}, NULL },
{ "MOUOK_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( MOUOK_SL )}, NULL },
{ "QMOUSEBO", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QMOUSEBO )}, NULL },
{ "MOUBO_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( MOUBO_SL )}, NULL },
{ "QMOUSECO", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QMOUSECO )}, NULL },
{ "MOUCO_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( MOUCO_SL )}, NULL },
{ "QMOUSELI", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QMOUSELI )}, NULL },
{ "MOULI_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( MOULI_SL )}, NULL },
{ "QMOUSECU", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QMOUSECU )}, NULL },
{ "MOUCU_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( MOUCU_SL )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QMOUSE, "QMOUSE.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QMOUSE
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QMOUSE )
   #include "hbiniseg.h"
#endif

HB_FUNC( QMOUSEOK )
{
	static const HB_BYTE pcode[] =
	{
		36,5,0,176,1,0,20,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QMOUSEBO )
{
	static const HB_BYTE pcode[] =
	{
		36,8,0,176,3,0,20,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QMOUSECO )
{
	static const HB_BYTE pcode[] =
	{
		36,11,0,176,5,0,20,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QMOUSELI )
{
	static const HB_BYTE pcode[] =
	{
		36,14,0,176,7,0,20,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QMOUSECU )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,17,0,176,9,0,95,1,20,1,7
	};

	hb_vmExecute( pcode, symbols );
}

