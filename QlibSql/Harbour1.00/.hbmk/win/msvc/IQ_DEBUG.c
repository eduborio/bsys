/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "IQ_DEBUG.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( IQ_DEBUG );
HB_FUNC_EXTERN( __MVPRIVATE );
HB_FUNC_EXTERN( COPAC_SL );
HB_FUNC_EXTERN( SAVEV_SL );
HB_FUNC_EXTERN( CLEAR_SL );
HB_FUNC_EXTERN( SAYSC_SL );
HB_FUNC_EXTERN( REPLICATE );
HB_FUNC_EXTERN( SPACE );
HB_FUNC_EXTERN( SETPOS );
HB_FUNC_EXTERN( AADD );
HB_FUNC_EXTERN( __GET );
HB_FUNC_EXTERN( ATAIL );
HB_FUNC_EXTERN( READMODAL );
HB_FUNC_EXTERN( LASTKEY );
HB_FUNC_EXTERN( RESTV_SL );
HB_FUNC_EXTERN( DEPAC_SL );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( TYPE );
HB_FUNC_EXTERN( ALLTRIM );
HB_FUNC_EXTERN( STR );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( DTOC );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_IQ_DEBUG )
{ "IQ_DEBUG", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( IQ_DEBUG )}, NULL },
{ "M_VAR", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "M_RESULT", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "M_LEN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "__MVPRIVATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( __MVPRIVATE )}, NULL },
{ "COPAC_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( COPAC_SL )}, NULL },
{ "SAVEV_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( SAVEV_SL )}, NULL },
{ "CLEAR_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( CLEAR_SL )}, NULL },
{ "SAYSC_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( SAYSC_SL )}, NULL },
{ "REPLICATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( REPLICATE )}, NULL },
{ "SPACE", {HB_FS_PUBLIC}, {HB_FUNCNAME( SPACE )}, NULL },
{ "SETPOS", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETPOS )}, NULL },
{ "AADD", {HB_FS_PUBLIC}, {HB_FUNCNAME( AADD )}, NULL },
{ "__GET", {HB_FS_PUBLIC}, {HB_FUNCNAME( __GET )}, NULL },
{ "DISPLAY", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "ATAIL", {HB_FS_PUBLIC}, {HB_FUNCNAME( ATAIL )}, NULL },
{ "READMODAL", {HB_FS_PUBLIC}, {HB_FUNCNAME( READMODAL )}, NULL },
{ "LASTKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( LASTKEY )}, NULL },
{ "RESTV_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( RESTV_SL )}, NULL },
{ "DEPAC_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( DEPAC_SL )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "TYPE", {HB_FS_PUBLIC}, {HB_FUNCNAME( TYPE )}, NULL },
{ "ALLTRIM", {HB_FS_PUBLIC}, {HB_FUNCNAME( ALLTRIM )}, NULL },
{ "STR", {HB_FS_PUBLIC}, {HB_FUNCNAME( STR )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "DTOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( DTOC )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_IQ_DEBUG, "IQ_DEBUG.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_IQ_DEBUG
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_IQ_DEBUG )
   #include "hbiniseg.h"
#endif

HB_FUNC( IQ_DEBUG )
{
	static const HB_BYTE pcode[] =
	{
		13,4,0,36,2,0,4,0,0,80,4,36,3,0,
		176,4,0,108,1,108,2,108,3,20,3,36,5,0,
		176,5,0,176,6,0,12,0,12,1,80,2,36,7,
		0,176,7,0,121,121,92,3,92,79,20,4,36,8,
		0,176,8,0,121,121,176,9,0,106,2,196,0,92,
		80,12,2,92,7,20,4,36,9,0,176,8,0,92,
		3,121,176,9,0,106,2,196,0,92,80,12,2,92,
		7,20,4,36,13,0,176,10,0,92,77,12,1,83,
		1,0,36,14,0,9,80,3,36,16,0,176,11,0,
		122,92,2,20,2,176,12,0,95,4,176,13,0,100,
		106,6,77,95,86,65,82,0,100,100,100,12,5,20,
		2,48,14,0,176,15,0,95,4,12,1,112,0,73,
		36,17,0,176,16,0,95,4,100,100,100,100,100,100,
		20,7,4,0,0,80,4,36,19,0,176,17,0,12,
		0,92,27,8,28,21,36,20,0,176,18,0,176,19,
		0,95,2,12,1,20,1,36,21,0,7,36,24,0,
		176,7,0,121,121,92,3,92,79,20,4,36,25,0,
		176,8,0,121,121,176,9,0,106,2,196,0,92,80,
		12,2,92,7,20,4,36,26,0,176,8,0,92,3,
		121,176,9,0,106,2,196,0,92,80,12,2,92,7,
		20,4,36,28,0,109,1,0,106,2,46,0,5,28,
		24,36,29,0,120,80,3,36,30,0,176,20,0,109,
		1,0,92,2,12,2,83,1,0,36,33,0,106,1,
		0,83,3,0,36,34,0,176,21,0,106,8,38,77,
		95,86,65,82,46,0,47,12,1,80,1,36,36,0,
		106,2,85,0,95,1,24,28,52,95,3,31,48,36,
		37,0,176,8,0,92,2,92,2,106,24,118,97,114,
		105,97,118,101,108,32,110,132,111,32,100,101,102,105,
		110,105,100,97,32,33,0,92,7,20,4,36,38,0,
		26,207,254,36,40,0,109,1,0,40,11,83,2,0,
		36,44,0,95,1,106,2,67,0,8,28,28,36,45,
		0,176,22,0,176,23,0,176,24,0,109,2,0,12,
		1,12,1,12,1,83,3,0,25,123,36,46,0,95,
		1,106,2,78,0,8,28,18,36,47,0,176,23,0,
		109,2,0,12,1,83,2,0,25,95,36,48,0,95,
		1,106,2,68,0,8,28,18,36,49,0,176,25,0,
		109,2,0,12,1,83,2,0,25,67,36,50,0,95,
		1,106,2,76,0,8,28,29,36,51,0,109,2,0,
		28,10,106,4,46,84,46,0,25,8,106,4,46,70,
		46,0,83,2,0,25,28,36,52,0,95,1,106,2,
		65,0,8,28,16,36,53,0,106,6,123,46,46,46,
		125,0,83,2,0,36,56,0,176,8,0,92,2,92,
		2,95,1,106,2,47,0,72,109,3,0,72,106,2,
		47,0,72,109,2,0,72,92,7,20,4,26,0,254,
		7
	};

	hb_vmExecute( pcode, symbols );
}

