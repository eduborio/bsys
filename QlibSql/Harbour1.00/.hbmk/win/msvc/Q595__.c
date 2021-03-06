/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "Q595__.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( Q595__ );
HB_FUNC_EXTERN( __MVPRIVATE );
HB_FUNC_EXTERN( SET );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC( EDITA );
HB_FUNC_STATIC( I_LE_DIR );
HB_FUNC_EXTERN( QLBLOC );
HB_FUNC_EXTERN( SETCOLOR );
HB_FUNC_EXTERN( ATCSC_SL );
HB_FUNC_EXTERN( __KEYBOARD );
HB_FUNC_EXTERN( ACHOICE );
HB_FUNC( I_CTRL595 );
HB_FUNC_EXTERN( LASTKEY );
HB_FUNC_EXTERN( DBCREATE );
HB_FUNC_EXTERN( QUSE );
HB_FUNC_EXTERN( QMENSA );
HB_FUNC_EXTERN( __DBSDF );
HB_FUNC_STATIC( I_LEITURA_DE_LINHAS );
HB_FUNC_EXTERN( DBGOTOP );
HB_FUNC_EXTERN( TBROWSEDB );
HB_FUNC_EXTERN( TBCOLUMNNEW );
HB_FUNC_EXTERN( CBLOCK );
HB_FUNC_EXTERN( FBLOCK );
HB_FUNC_EXTERN( ROW );
HB_FUNC_EXTERN( QSAY );
HB_FUNC_EXTERN( STR );
HB_FUNC_EXTERN( QINKEY );
HB_FUNC_EXTERN( DBCLOSEAREA );
HB_FUNC_EXTERN( FERASE );
HB_FUNC_EXTERN( RECNO );
HB_FUNC( I_RET_PEDACO );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC( FAZ_HELP );
HB_FUNC_EXTERN( DIRECTORY );
HB_FUNC_EXTERN( AADD );
HB_FUNC_EXTERN( DTOC );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( PADC );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( ASORT );
HB_FUNC_STATIC( ATUALIZA_VETOR );
HB_FUNC_EXTERN( AT );
HB_FUNC_EXTERN( MEMORY );
HB_FUNC_INITSTATICS();


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_Q595__ )
{ "Q595__", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( Q595__ )}, NULL },
{ "CFILE_PRN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "NESCOLHA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "__MVPRIVATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( __MVPRIVATE )}, NULL },
{ "ANAMES", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "ASTRINGS", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "SET", {HB_FS_PUBLIC}, {HB_FUNCNAME( SET )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "EDITA", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( EDITA )}, NULL },
{ "I_LE_DIR", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_LE_DIR )}, NULL },
{ "QLBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QLBLOC )}, NULL },
{ "XDRV_SH", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "SETCOLOR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETCOLOR )}, NULL },
{ "ATCSC_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( ATCSC_SL )}, NULL },
{ "__KEYBOARD", {HB_FS_PUBLIC}, {HB_FUNCNAME( __KEYBOARD )}, NULL },
{ "ACHOICE", {HB_FS_PUBLIC}, {HB_FUNCNAME( ACHOICE )}, NULL },
{ "I_CTRL595", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_CTRL595 )}, NULL },
{ "LASTKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( LASTKEY )}, NULL },
{ "NMARGVIEW", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DBCREATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBCREATE )}, NULL },
{ "QUSE", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUSE )}, NULL },
{ "QMENSA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QMENSA )}, NULL },
{ "__DBSDF", {HB_FS_PUBLIC}, {HB_FUNCNAME( __DBSDF )}, NULL },
{ "I_LEITURA_DE_LINHAS", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_LEITURA_DE_LINHAS )}, NULL },
{ "PRN_TMP", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "DBGOTOP", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBGOTOP )}, NULL },
{ "TBROWSEDB", {HB_FS_PUBLIC}, {HB_FUNCNAME( TBROWSEDB )}, NULL },
{ "_HEADSEP", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "_COLSEP", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "ADDCOLUMN", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "TBCOLUMNNEW", {HB_FS_PUBLIC}, {HB_FUNCNAME( TBCOLUMNNEW )}, NULL },
{ "CBLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( CBLOCK )}, NULL },
{ "FBLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( FBLOCK )}, NULL },
{ "FORCESTABLE", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "ROW", {HB_FS_PUBLIC}, {HB_FUNCNAME( ROW )}, NULL },
{ "QSAY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSAY )}, NULL },
{ "STR", {HB_FS_PUBLIC}, {HB_FUNCNAME( STR )}, NULL },
{ "QINKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QINKEY )}, NULL },
{ "NTECLA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "UP", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "DOWN", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "PAGEUP", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "PAGEDOWN", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "GOTOP", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "GOBOTTOM", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "REFRESHALL", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "DBCLOSEAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBCLOSEAREA )}, NULL },
{ "FERASE", {HB_FS_PUBLIC}, {HB_FUNCNAME( FERASE )}, NULL },
{ "RECNO", {HB_FS_PUBLIC}, {HB_FUNCNAME( RECNO )}, NULL },
{ "I_RET_PEDACO", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_RET_PEDACO )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "LINHA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "FAZ_HELP", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( FAZ_HELP )}, NULL },
{ "XUSRNUM", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DIRECTORY", {HB_FS_PUBLIC}, {HB_FUNCNAME( DIRECTORY )}, NULL },
{ "AADD", {HB_FS_PUBLIC}, {HB_FUNCNAME( AADD )}, NULL },
{ "DTOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( DTOC )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "ZTMP", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "PADC", {HB_FS_PUBLIC}, {HB_FUNCNAME( PADC )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "ASORT", {HB_FS_PUBLIC}, {HB_FUNCNAME( ASORT )}, NULL },
{ "ATUALIZA_VETOR", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( ATUALIZA_VETOR )}, NULL },
{ "AT", {HB_FS_PUBLIC}, {HB_FUNCNAME( AT )}, NULL },
{ "MEMORY", {HB_FS_PUBLIC}, {HB_FUNCNAME( MEMORY )}, NULL },
{ "(_INITSTATICS00003)", {HB_FS_INITEXIT | HB_FS_LOCAL}, {hb_INITSTATICS}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_Q595__, "Q595__.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_Q595__
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_Q595__ )
   #include "hbiniseg.h"
#endif

HB_FUNC( Q595__ )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,71,1,0,1,36,13,0,122,176,3,0,
		108,2,20,1,81,2,0,36,14,0,4,0,0,176,
		3,0,108,4,20,1,81,4,0,36,15,0,4,0,
		0,176,3,0,108,5,20,1,81,5,0,36,17,0,
		109,1,0,100,8,28,8,106,1,0,83,1,0,36,
		19,0,176,6,0,92,24,106,1,0,20,2,36,21,
		0,176,7,0,109,1,0,12,1,31,21,36,22,0,
		176,8,0,109,1,0,109,1,0,9,20,3,36,23,
		0,7,36,27,0,4,0,0,83,4,0,36,28,0,
		4,0,0,83,5,0,36,29,0,176,9,0,109,4,
		0,109,5,0,20,2,36,30,0,176,10,0,92,5,
		121,106,6,66,53,57,53,65,0,109,11,0,106,11,
		81,83,66,76,79,67,46,71,76,79,0,72,20,4,
		36,31,0,176,12,0,176,13,0,92,6,122,12,2,
		20,1,36,32,0,176,14,0,106,2,255,0,20,1,
		36,34,0,176,15,0,92,8,122,92,14,92,78,109,
		5,0,12,5,165,83,2,0,121,8,28,6,36,35,
		0,7,36,37,0,176,8,0,98,4,0,109,2,0,
		1,98,5,0,109,2,0,1,9,20,3,26,107,255,
		7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( I_CTRL595 )
{
	static const HB_BYTE pcode[] =
	{
		13,1,3,116,65,0,36,46,0,92,2,80,4,36,
		50,0,103,1,0,95,3,69,28,6,120,82,2,0,
		36,56,0,176,17,0,12,0,92,27,8,28,7,121,
		80,4,25,85,36,60,0,176,17,0,12,0,92,13,
		8,28,7,122,80,4,25,67,36,64,0,176,17,0,
		12,0,122,8,28,23,36,65,0,176,14,0,106,2,
		31,0,20,1,36,66,0,92,2,80,4,25,34,36,
		70,0,176,17,0,12,0,92,6,8,28,21,36,71,
		0,176,14,0,106,2,30,0,20,1,36,72,0,92,
		2,80,4,36,76,0,95,4,92,2,8,28,50,36,
		77,0,176,8,0,98,4,0,95,3,1,98,5,0,
		95,3,1,120,20,3,36,78,0,103,2,0,28,21,
		36,79,0,9,82,2,0,36,80,0,176,14,0,106,
		2,255,0,20,1,36,84,0,95,4,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( EDITA )
{
	static const HB_BYTE pcode[] =
	{
		13,3,3,36,91,0,106,6,76,73,78,72,65,0,
		106,2,67,0,93,44,1,121,4,4,0,4,1,0,
		80,6,36,93,0,122,176,3,0,108,18,20,1,81,
		18,0,36,97,0,176,19,0,106,8,80,82,78,95,
		84,77,80,0,95,6,20,2,36,99,0,176,20,0,
		106,1,0,106,8,80,82,78,95,84,77,80,0,12,
		2,31,5,9,110,7,36,101,0,176,21,0,106,30,
		76,101,110,100,111,32,108,105,110,104,97,115,32,100,
		111,32,82,101,108,97,116,111,114,105,111,46,46,46,
		32,0,20,1,36,103,0,176,22,0,9,95,1,4,
		0,0,90,8,176,23,0,12,0,6,100,100,100,9,
		100,20,9,36,105,0,85,108,24,74,176,25,0,20,
		0,74,36,109,0,176,26,0,92,6,122,92,22,92,
		78,12,4,80,5,36,111,0,48,27,0,95,5,106,
		2,196,0,112,1,73,36,112,0,48,28,0,95,5,
		106,2,179,0,112,1,73,36,114,0,48,29,0,95,
		5,176,30,0,176,31,0,106,13,32,82,101,108,97,
		116,111,114,105,111,58,32,0,95,1,72,12,1,176,
		32,0,106,15,105,95,114,101,116,95,112,101,100,97,
		99,111,40,41,0,12,1,12,2,112,1,73,36,118,
		0,176,21,0,106,60,60,83,101,116,97,115,62,44,
		32,60,80,103,85,112,44,80,103,68,119,44,72,111,
		109,101,44,69,110,100,62,44,32,60,84,97,98,44,
		83,104,45,84,97,98,62,44,32,60,69,115,99,62,
		44,32,60,70,49,62,46,46,46,0,20,1,36,122,
		0,48,33,0,95,5,112,0,73,36,124,0,176,34,
		0,12,0,80,4,36,126,0,176,35,0,92,6,92,
		55,106,14,76,105,110,104,97,32,65,116,117,97,108,
		58,32,0,176,36,0,95,4,92,3,12,2,72,20,
		3,36,128,0,176,37,0,121,12,1,83,38,0,36,
		133,0,109,38,0,92,5,8,28,12,48,39,0,95,
		5,112,0,73,25,166,36,134,0,109,38,0,92,24,
		8,28,12,48,40,0,95,5,112,0,73,25,145,36,
		135,0,109,38,0,92,18,8,28,13,48,41,0,95,
		5,112,0,73,26,124,255,36,136,0,109,38,0,92,
		3,8,28,13,48,42,0,95,5,112,0,73,26,102,
		255,36,137,0,109,38,0,122,8,28,13,48,43,0,
		95,5,112,0,73,26,81,255,36,138,0,109,38,0,
		92,6,8,28,13,48,44,0,95,5,112,0,73,26,
		59,255,36,139,0,109,38,0,92,19,8,28,27,109,
		18,0,122,15,28,20,109,18,0,17,83,18,0,48,
		45,0,95,5,112,0,73,26,23,255,36,140,0,109,
		38,0,92,4,8,28,20,109,18,0,23,83,18,0,
		48,45,0,95,5,112,0,73,26,250,254,36,141,0,
		109,38,0,92,27,8,31,95,36,143,0,109,38,0,
		92,9,8,28,28,36,145,0,109,18,0,92,10,72,
		83,18,0,36,146,0,48,45,0,95,5,112,0,73,
		26,202,254,36,148,0,109,38,0,93,15,1,8,29,
		189,254,36,150,0,109,18,0,92,10,49,83,18,0,
		36,151,0,109,18,0,122,35,28,6,122,83,18,0,
		36,152,0,48,45,0,95,5,112,0,73,36,154,0,
		26,146,254,36,160,0,85,108,24,74,176,46,0,20,
		0,74,36,162,0,176,47,0,106,12,80,82,78,95,
		84,77,80,46,68,66,70,0,20,1,36,164,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_LEITURA_DE_LINHAS )
{
	static const HB_BYTE pcode[] =
	{
		36,167,0,176,35,0,92,24,92,40,176,36,0,85,
		108,24,74,176,48,0,12,0,119,92,5,12,2,20,
		3,36,168,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( I_RET_PEDACO )
{
	static const HB_BYTE pcode[] =
	{
		36,171,0,176,50,0,109,51,0,109,18,0,20,2,
		7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( FAZ_HELP )
{
	static const HB_BYTE pcode[] =
	{
		13,2,0,36,34,1,92,5,80,1,92,5,80,2,
		36,35,1,176,35,0,95,1,122,72,95,2,106,75,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,0,20,3,36,36,1,176,35,0,95,
		1,92,2,72,95,2,106,75,176,176,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,176,176,0,20,
		3,36,37,1,176,35,0,95,1,92,3,72,95,2,
		106,75,176,176,32,32,115,101,116,97,115,46,46,46,
		46,46,46,32,109,111,118,105,109,101,110,116,97,135,
		132,111,32,100,111,32,114,101,108,97,116,162,114,105,
		111,32,40,104,111,114,105,122,111,110,116,97,108,32,
		101,32,118,101,114,116,105,99,97,108,41,32,32,32,
		32,32,32,32,176,176,0,20,3,36,38,1,176,35,
		0,95,1,92,4,72,95,2,106,75,176,176,32,32,
		104,111,109,101,46,46,46,46,46,46,46,32,112,114,
		105,109,101,105,114,97,32,99,111,108,117,110,97,32,
		100,111,32,114,101,108,97,116,162,114,105,111,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,176,176,
		0,20,3,36,39,1,176,35,0,95,1,92,5,72,
		95,2,106,75,176,176,32,32,101,110,100,46,46,46,
		46,46,46,46,46,32,163,108,116,105,109,97,32,99,
		111,108,117,110,97,32,100,111,32,114,101,108,97,116,
		162,114,105,111,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,176,176,0,20,3,36,40,1,
		176,35,0,95,1,92,6,72,95,2,106,75,176,176,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		176,176,0,20,3,36,41,1,176,35,0,95,1,92,
		7,72,95,2,106,75,176,176,32,32,112,103,117,112,
		46,46,46,46,46,46,46,32,97,118,97,110,135,97,
		32,111,32,114,101,108,97,116,162,114,105,111,32,100,
		101,32,49,53,32,101,109,32,49,53,32,108,105,110,
		104,97,115,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,176,176,0,20,3,36,
		42,1,176,35,0,95,1,92,8,72,95,2,106,75,
		176,176,32,32,112,103,100,119,46,46,46,46,46,46,
		46,32,114,101,116,114,111,99,101,100,101,32,111,32,
		114,101,108,97,116,162,114,105,111,32,100,101,32,49,
		53,32,101,109,32,49,53,32,108,105,110,104,97,115,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,176,176,0,20,3,36,43,1,176,35,0,95,
		1,92,9,72,95,2,106,75,176,176,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,176,176,0,20,
		3,36,44,1,176,35,0,95,1,92,10,72,95,2,
		106,75,176,176,32,32,99,116,114,108,43,112,103,117,
		112,46,46,32,109,111,118,101,45,115,101,32,112,97,
		114,97,32,111,32,105,110,161,99,105,111,32,100,111,
		32,114,101,108,97,116,162,114,105,111,32,40,112,114,
		105,109,101,105,114,97,32,108,105,110,104,97,41,32,
		32,32,32,32,176,176,0,20,3,36,45,1,176,35,
		0,95,1,92,11,72,95,2,106,75,176,176,32,32,
		99,116,114,108,43,112,103,100,119,46,46,32,109,111,
		118,101,45,115,101,32,112,97,114,97,32,111,32,102,
		105,109,32,100,111,32,114,101,108,97,116,162,114,105,
		111,32,32,32,32,40,163,108,116,105,109,97,32,108,
		105,110,104,97,41,32,32,32,32,32,32,32,176,176,
		0,20,3,36,46,1,176,35,0,95,1,92,12,72,
		95,2,106,75,176,176,32,32,116,97,98,46,46,46,
		46,46,46,46,46,32,109,111,118,101,32,111,32,114,
		101,108,97,116,162,114,105,111,32,112,97,114,97,32,
		101,115,113,117,101,114,100,97,32,100,101,32,49,48,
		32,101,109,32,49,48,32,99,111,108,117,110,97,115,
		32,32,32,32,32,32,176,176,0,20,3,36,47,1,
		176,35,0,95,1,92,13,72,95,2,106,75,176,176,
		32,32,115,104,105,102,116,43,116,97,98,46,46,32,
		109,111,118,101,32,111,32,114,101,108,97,116,162,114,
		105,111,32,112,97,114,97,32,100,105,114,101,105,114,
		97,32,100,101,32,49,48,32,101,109,32,49,48,32,
		99,111,108,117,110,97,115,32,32,32,32,32,32,32,
		176,176,0,20,3,36,48,1,176,35,0,95,1,92,
		14,72,95,2,106,75,176,176,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,176,176,0,20,3,36,
		49,1,176,35,0,95,1,92,15,72,95,2,106,75,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,0,20,3,36,50,1,176,37,0,121,
		20,1,36,51,1,176,35,0,95,1,122,72,95,2,
		106,75,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,0,20,3,36,52,1,176,35,
		0,95,1,92,2,72,95,2,106,75,176,176,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,176,176,
		0,20,3,36,53,1,176,35,0,95,1,92,3,72,
		95,2,106,75,176,176,32,32,100,101,108,46,46,46,
		46,46,46,46,46,32,101,108,105,109,105,110,97,32,
		111,32,114,101,108,97,116,162,114,105,111,32,115,101,
		108,101,99,105,111,110,97,100,111,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,176,176,0,20,3,36,54,1,
		176,35,0,95,1,92,4,72,95,2,106,75,176,176,
		32,32,105,110,115,46,46,46,46,46,46,46,46,32,
		105,110,115,101,114,101,32,99,97,114,97,99,116,101,
		114,101,115,32,101,115,112,101,99,105,97,105,115,32,
		112,97,114,97,32,105,109,112,114,101,115,115,111,114,
		97,32,32,32,32,32,32,32,32,32,32,32,32,32,
		176,176,0,20,3,36,55,1,176,35,0,95,1,92,
		5,72,95,2,106,75,176,176,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,176,176,0,20,3,36,
		56,1,176,35,0,95,1,92,6,72,95,2,106,75,
		176,176,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,176,176,0,20,3,36,57,1,176,35,0,95,
		1,92,7,72,95,2,106,75,176,176,32,32,97,108,
		116,43,73,46,46,46,46,46,46,32,109,97,114,99,
		97,32,105,110,105,99,105,111,32,100,97,32,105,109,
		112,114,101,115,115,132,111,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,176,176,0,20,
		3,36,58,1,176,35,0,95,1,92,8,72,95,2,
		106,75,176,176,32,32,97,108,116,43,70,46,46,46,
		46,46,46,32,109,97,114,99,97,32,102,105,109,32,
		100,97,32,105,109,112,114,101,115,115,132,111,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,176,176,0,20,3,36,59,1,176,35,
		0,95,1,92,9,72,95,2,106,75,176,176,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,176,176,
		0,20,3,36,60,1,176,35,0,95,1,92,10,72,
		95,2,106,75,176,176,32,32,97,108,116,43,80,46,
		46,46,46,46,46,32,105,109,112,114,105,109,101,32,
		111,32,114,101,108,97,116,162,114,105,111,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,176,176,0,20,3,36,61,1,
		176,35,0,95,1,92,11,72,95,2,106,75,176,176,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		176,176,0,20,3,36,62,1,176,35,0,95,1,92,
		12,72,95,2,106,75,176,176,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,176,176,0,20,3,36,
		63,1,176,35,0,95,1,92,13,72,95,2,106,75,
		176,176,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,176,176,0,20,3,36,64,1,176,35,0,95,
		1,92,14,72,95,2,106,75,176,176,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,32,32,32,32,
		32,32,32,32,32,32,32,32,32,32,176,176,0,20,
		3,36,65,1,176,35,0,95,1,92,15,72,95,2,
		106,75,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,176,176,176,176,176,176,176,176,
		176,176,176,176,176,176,0,20,3,36,66,1,176,37,
		0,121,20,1,36,67,1,100,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_LE_DIR )
{
	static const HB_BYTE pcode[] =
	{
		13,3,2,36,75,1,106,2,82,0,109,53,0,106,
		4,48,48,48,0,8,28,10,106,4,63,63,63,0,
		25,5,109,53,0,72,106,8,63,63,63,46,80,82,
		78,0,72,80,5,36,77,1,176,54,0,95,5,12,
		1,80,3,36,79,1,122,165,80,4,26,135,0,36,
		80,1,176,55,0,95,1,95,3,95,4,1,122,1,
		20,2,36,84,1,95,3,95,4,1,122,1,106,7,
		32,32,32,32,32,32,0,72,176,36,0,95,3,95,
		4,1,92,2,1,92,6,12,2,72,106,7,32,32,
		32,32,32,32,0,72,176,56,0,95,3,95,4,1,
		92,3,1,12,1,72,106,7,32,32,32,32,32,32,
		0,72,176,57,0,95,3,95,4,1,92,4,1,92,
		5,12,2,72,83,58,0,36,85,1,176,55,0,95,
		2,176,59,0,109,58,0,92,78,12,2,20,2,36,
		79,1,175,4,0,176,60,0,95,3,12,1,15,29,
		116,255,36,92,1,176,61,0,95,1,100,100,89,13,
		0,2,0,0,0,95,1,95,2,15,6,20,4,36,
		93,1,176,61,0,95,2,100,100,89,13,0,2,0,
		0,0,95,1,95,2,15,6,20,4,36,94,1,100,
		110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( ATUALIZA_VETOR )
{
	static const HB_BYTE pcode[] =
	{
		13,1,3,116,65,0,36,103,1,176,7,0,95,1,
		12,1,28,8,106,1,0,82,3,0,36,105,1,104,
		3,0,95,2,135,36,108,1,95,3,31,40,176,35,
		0,92,8,122,106,15,76,105,110,104,97,115,32,108,
		105,100,97,115,58,32,0,176,36,0,176,60,0,95,
		1,12,1,12,1,72,20,3,36,110,1,176,63,0,
		106,2,13,0,103,3,0,12,2,165,80,4,121,8,
		31,121,36,112,1,176,55,0,95,1,176,50,0,103,
		3,0,122,95,4,122,49,12,3,20,2,36,114,1,
		176,50,0,103,3,0,95,4,122,72,122,12,3,106,
		2,10,0,8,28,23,36,115,1,176,50,0,103,3,
		0,95,4,92,2,72,12,2,82,3,0,25,20,36,
		117,1,176,50,0,103,3,0,95,4,122,72,12,2,
		82,3,0,36,120,1,176,64,0,121,12,1,92,5,
		35,31,16,176,60,0,95,1,12,1,93,0,16,8,
		29,79,255,36,121,1,9,110,7,36,125,1,120,110,
		7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_INITSTATICS()
{
	static const HB_BYTE pcode[] =
	{
		117,65,0,3,0,116,65,0,92,255,82,1,0,120,
		82,2,0,106,1,0,82,3,0,7
	};

	hb_vmExecute( pcode, symbols );
}

