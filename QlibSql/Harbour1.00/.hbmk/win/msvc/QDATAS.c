/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QDATAS.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QFIMMES );
HB_FUNC_EXTERN( VALTYPE );
HB_FUNC_EXTERN( YEAR );
HB_FUNC_EXTERN( MONTH );
HB_FUNC_EXTERN( VAL );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( RIGHT );
HB_FUNC_EXTERN( STR );
HB_FUNC_EXTERN( CTOD );
HB_FUNC( QINIMES );
HB_FUNC_EXTERN( DAY );
HB_FUNC( QANOMES );
HB_FUNC_EXTERN( STRZERO );
HB_FUNC_EXTERN( ABS );
HB_FUNC( QDATAEXTEN );
HB_FUNC_EXTERN( ALLTRIM );
HB_FUNC_EXTERN( QNOMEMES );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QDATAS )
{ "QFIMMES", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QFIMMES )}, NULL },
{ "VALTYPE", {HB_FS_PUBLIC}, {HB_FUNCNAME( VALTYPE )}, NULL },
{ "YEAR", {HB_FS_PUBLIC}, {HB_FUNCNAME( YEAR )}, NULL },
{ "MONTH", {HB_FS_PUBLIC}, {HB_FUNCNAME( MONTH )}, NULL },
{ "VAL", {HB_FS_PUBLIC}, {HB_FUNCNAME( VAL )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "RIGHT", {HB_FS_PUBLIC}, {HB_FUNCNAME( RIGHT )}, NULL },
{ "STR", {HB_FS_PUBLIC}, {HB_FUNCNAME( STR )}, NULL },
{ "CTOD", {HB_FS_PUBLIC}, {HB_FUNCNAME( CTOD )}, NULL },
{ "QINIMES", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QINIMES )}, NULL },
{ "DAY", {HB_FS_PUBLIC}, {HB_FUNCNAME( DAY )}, NULL },
{ "QANOMES", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QANOMES )}, NULL },
{ "STRZERO", {HB_FS_PUBLIC}, {HB_FUNCNAME( STRZERO )}, NULL },
{ "ABS", {HB_FS_PUBLIC}, {HB_FUNCNAME( ABS )}, NULL },
{ "QDATAEXTEN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QDATAEXTEN )}, NULL },
{ "ALLTRIM", {HB_FS_PUBLIC}, {HB_FUNCNAME( ALLTRIM )}, NULL },
{ "QNOMEMES", {HB_FS_PUBLIC}, {HB_FUNCNAME( QNOMEMES )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QDATAS, "QDATAS.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QDATAS
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QDATAS )
   #include "hbiniseg.h"
#endif

HB_FUNC( QFIMMES )
{
	static const HB_BYTE pcode[] =
	{
		13,2,1,36,4,0,176,1,0,95,1,12,1,106,
		2,68,0,8,28,30,36,5,0,176,2,0,95,1,
		12,1,80,2,36,6,0,176,3,0,95,1,12,1,
		122,72,80,3,25,42,36,8,0,176,4,0,176,5,
		0,95,1,92,4,12,2,12,1,80,2,36,9,0,
		176,4,0,176,6,0,95,1,92,2,12,2,12,1,
		122,72,80,3,36,11,0,95,3,92,13,8,28,11,
		36,12,0,174,2,0,122,80,3,36,14,0,176,7,
		0,95,2,92,4,12,2,80,2,36,15,0,176,7,
		0,95,3,92,2,12,2,80,3,36,16,0,176,8,
		0,106,4,48,49,47,0,95,3,72,106,2,47,0,
		72,95,2,72,12,1,122,49,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QINIMES )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,20,0,176,1,0,95,1,12,1,106,
		2,68,0,8,28,21,36,21,0,95,1,176,10,0,
		95,1,12,1,49,122,72,80,2,25,43,36,23,0,
		176,8,0,106,4,48,49,47,0,176,6,0,95,1,
		92,2,12,2,72,106,2,47,0,72,176,5,0,95,
		1,92,4,12,2,72,12,1,80,2,36,25,0,95,
		2,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QANOMES )
{
	static const HB_BYTE pcode[] =
	{
		13,3,2,36,38,0,176,12,0,176,2,0,95,1,
		12,1,92,4,12,2,80,3,36,39,0,176,12,0,
		176,3,0,95,1,12,1,92,2,12,2,80,4,36,
		41,0,95,2,100,69,29,174,0,36,42,0,122,165,
		80,5,26,153,0,36,43,0,95,2,121,35,28,72,
		36,44,0,176,12,0,176,4,0,95,4,12,1,122,
		49,92,2,12,2,80,4,36,45,0,95,4,106,3,
		48,48,0,8,28,33,36,46,0,106,3,49,50,0,
		80,4,36,47,0,176,12,0,176,4,0,95,3,12,
		1,122,49,92,4,12,2,80,3,36,48,0,25,70,
		36,50,0,176,12,0,176,4,0,95,4,12,1,122,
		72,92,2,12,2,80,4,36,51,0,95,4,106,3,
		49,51,0,8,28,33,36,52,0,106,3,48,49,0,
		80,4,36,53,0,176,12,0,176,4,0,95,3,12,
		1,122,72,92,4,12,2,80,3,36,42,0,175,5,
		0,176,13,0,95,2,12,1,15,29,98,255,36,59,
		0,176,6,0,95,3,92,4,12,2,80,3,36,61,
		0,95,3,95,4,72,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QDATAEXTEN )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,64,0,176,12,0,176,10,0,95,1,
		12,1,92,2,12,2,106,5,32,100,101,32,0,72,
		176,15,0,176,16,0,95,1,12,1,12,1,72,106,
		5,32,100,101,32,0,72,176,12,0,176,2,0,95,
		1,12,1,92,4,12,2,72,110,7
	};

	hb_vmExecute( pcode, symbols );
}

