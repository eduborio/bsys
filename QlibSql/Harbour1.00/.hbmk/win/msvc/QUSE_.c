/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QUSE_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QUSE );
HB_FUNC_EXTERN( ALLTRIM );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( AT );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( RAT );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( FILE );
HB_FUNC_EXTERN( QMENSA );
HB_FUNC_EXTERN( DBSELECTAREA );
HB_FUNC_EXTERN( DBUSEAREA );
HB_FUNC_EXTERN( NETERR );
HB_FUNC_EXTERN( ORDLISTCLEAR );
HB_FUNC_EXTERN( ORDLISTADD );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( RTRIM );
HB_FUNC_EXTERN( DBSETORDER );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QUSE_ )
{ "QUSE", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QUSE )}, NULL },
{ "ALLTRIM", {HB_FS_PUBLIC}, {HB_FUNCNAME( ALLTRIM )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "AT", {HB_FS_PUBLIC}, {HB_FUNCNAME( AT )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "RAT", {HB_FS_PUBLIC}, {HB_FUNCNAME( RAT )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "FILE", {HB_FS_PUBLIC}, {HB_FUNCNAME( FILE )}, NULL },
{ "QMENSA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QMENSA )}, NULL },
{ "DBSELECTAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSELECTAREA )}, NULL },
{ "DBUSEAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBUSEAREA )}, NULL },
{ "NETERR", {HB_FS_PUBLIC}, {HB_FUNCNAME( NETERR )}, NULL },
{ "ORDLISTCLEAR", {HB_FS_PUBLIC}, {HB_FUNCNAME( ORDLISTCLEAR )}, NULL },
{ "ORDLISTADD", {HB_FS_PUBLIC}, {HB_FUNCNAME( ORDLISTADD )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "RTRIM", {HB_FS_PUBLIC}, {HB_FUNCNAME( RTRIM )}, NULL },
{ "DBSETORDER", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSETORDER )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QUSE_, "QUSE_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QUSE_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QUSE_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QUSE )
{
	static const HB_BYTE pcode[] =
	{
		13,2,7,36,7,0,106,7,68,66,70,67,68,88,
		0,80,9,36,11,0,95,6,106,5,81,82,68,68,
		0,8,28,93,36,13,0,95,2,100,69,28,14,36,
		14,0,176,1,0,95,2,12,1,80,2,36,17,0,
		95,7,100,8,31,11,176,2,0,95,7,12,1,28,
		27,36,18,0,106,15,115,101,108,101,99,116,32,42,
		32,102,114,111,109,32,0,95,2,72,80,7,36,21,
		0,95,5,100,69,28,14,36,22,0,176,1,0,95,
		5,12,1,80,5,36,23,0,26,20,4,36,29,0,
		176,1,0,95,1,12,1,80,1,36,30,0,176,1,
		0,95,2,12,1,80,2,36,32,0,176,2,0,95,
		4,12,1,28,7,106,1,0,80,4,36,35,0,176,
		2,0,95,5,12,1,28,6,95,2,80,5,36,37,
		0,95,3,100,8,28,7,4,0,0,80,3,36,39,
		0,176,3,0,106,2,46,0,95,5,12,2,165,80,
		8,121,69,28,18,36,40,0,176,4,0,95,5,95,
		8,122,49,12,2,80,5,36,43,0,176,5,0,106,
		2,92,0,95,5,12,2,165,80,8,121,69,28,18,
		36,44,0,176,6,0,95,5,95,8,122,72,12,2,
		80,5,36,47,0,176,1,0,95,5,12,1,80,5,
		36,49,0,176,7,0,95,1,95,2,72,106,5,46,
		68,66,70,0,72,12,1,31,57,36,50,0,176,8,
		0,106,9,97,114,113,117,105,118,111,32,0,95,2,
		72,106,19,32,110,132,111,32,101,110,99,111,110,116,
		114,97,100,111,46,46,46,0,72,106,3,76,66,0,
		20,2,36,51,0,9,110,7,36,54,0,176,9,0,
		106,2,48,0,20,1,36,57,0,106,2,69,0,95,
		4,24,28,23,36,58,0,176,10,0,9,100,95,1,
		95,2,72,95,5,9,9,20,6,25,54,36,59,0,
		106,2,82,0,95,4,24,28,23,36,60,0,176,10,
		0,9,100,95,1,95,2,72,95,5,100,120,20,6,
		25,21,36,63,0,176,10,0,9,100,95,1,95,2,
		72,95,5,100,9,20,6,36,66,0,176,11,0,12,
		0,28,57,36,67,0,176,8,0,106,24,110,132,111,
		32,102,111,105,32,112,111,115,115,105,118,101,108,32,
		97,98,114,105,114,32,0,95,2,72,106,4,46,46,
		46,0,72,106,3,76,66,0,20,2,36,68,0,9,
		110,7,36,73,0,95,9,106,7,83,73,88,78,84,
		88,0,8,29,129,0,36,75,0,122,165,80,8,25,
		103,36,76,0,176,7,0,95,1,95,3,95,8,1,
		72,106,5,46,78,84,88,0,72,12,1,28,20,36,
		77,0,176,13,0,95,1,95,3,95,8,1,72,20,
		1,25,53,36,79,0,176,8,0,106,8,105,110,100,
		105,99,101,32,0,95,3,95,8,1,72,106,19,32,
		110,132,111,32,101,110,99,111,110,116,114,97,100,111,
		46,46,46,0,72,106,3,76,66,0,20,2,36,75,
		0,175,8,0,176,14,0,95,3,12,1,15,28,147,
		36,81,0,26,244,1,36,84,0,95,9,106,4,83,
		68,70,0,8,29,129,0,36,85,0,122,165,80,8,
		25,103,36,86,0,176,7,0,95,1,95,3,95,8,
		1,72,106,5,46,78,84,88,0,72,12,1,28,20,
		36,87,0,176,13,0,95,1,95,3,95,8,1,72,
		20,1,25,53,36,89,0,176,8,0,106,8,105,110,
		100,105,99,101,32,0,95,3,95,8,1,72,106,19,
		32,110,132,111,32,101,110,99,111,110,116,114,97,100,
		111,46,46,46,0,72,106,3,76,66,0,20,2,36,
		85,0,175,8,0,176,14,0,95,3,12,1,15,28,
		147,36,91,0,26,103,1,36,93,0,95,9,106,7,
		68,66,70,78,84,88,0,8,29,129,0,36,94,0,
		122,165,80,8,25,103,36,95,0,176,7,0,95,1,
		95,3,95,8,1,72,106,5,46,78,84,88,0,72,
		12,1,28,20,36,96,0,176,13,0,95,1,95,3,
		95,8,1,72,20,1,25,53,36,98,0,176,8,0,
		106,8,105,110,100,105,99,101,32,0,95,3,95,8,
		1,72,106,19,32,110,132,111,32,101,110,99,111,110,
		116,114,97,100,111,46,46,46,0,72,106,3,76,66,
		0,20,2,36,94,0,175,8,0,176,14,0,95,3,
		12,1,15,28,147,36,100,0,26,215,0,36,103,0,
		95,9,106,7,83,73,88,67,68,88,0,8,28,50,
		36,105,0,176,7,0,95,1,95,2,72,106,5,46,
		67,68,88,0,72,12,1,29,174,0,36,106,0,176,
		12,0,20,0,176,13,0,95,1,95,2,72,20,1,
		36,107,0,26,150,0,36,109,0,95,9,106,7,68,
		66,70,67,68,88,0,8,28,60,36,111,0,176,15,
		0,95,2,12,1,80,2,36,112,0,176,7,0,95,
		1,95,2,72,106,5,46,67,68,88,0,72,12,1,
		28,97,36,113,0,176,12,0,20,0,176,13,0,95,
		1,95,2,72,20,1,36,114,0,25,74,36,117,0,
		95,9,106,7,83,73,88,78,83,88,0,8,28,57,
		36,119,0,176,7,0,95,1,95,2,72,106,5,46,
		78,83,88,0,72,12,1,28,34,36,120,0,176,12,
		0,20,0,176,13,0,95,1,95,2,72,20,1,36,
		121,0,85,95,2,74,176,16,0,122,20,1,74,36,
		129,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

