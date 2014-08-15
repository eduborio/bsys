/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QPRN.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QINITPRN );
HB_FUNC_EXTERN( QLBLOC );
HB_FUNC_EXTERN( ALIAS );
HB_FUNC_EXTERN( __MVPUBLIC );
HB_FUNC_EXTERN( VALTYPE );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( __KEYBOARD );
HB_FUNC_EXTERN( SET );
HB_FUNC_EXTERN( QUSE );
HB_FUNC_EXTERN( __DBLOCATE );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( DBCLOSEAREA );
HB_FUNC_EXTERN( DBSELECTAREA );
HB_FUNC_EXTERN( QSBLOC );
HB_FUNC_EXTERN( SETKEY );
HB_FUNC( QHELPPRN );
HB_FUNC_EXTERN( QRBLOC );
HB_FUNC_EXTERN( QSAY );
HB_FUNC_EXTERN( QINVERC );
HB_FUNC_EXTERN( QINKEY );
HB_FUNC_EXTERN( UPPER );
HB_FUNC_EXTERN( CHR );
HB_FUNC_EXTERN( __MVXRELEASE );
HB_FUNC_EXTERN( TIME );
HB_FUNC_STATIC( I_RET_NOME_PRN );
HB_FUNC_EXTERN( RTRIM );
HB_FUNC_STATIC( I_XLS );
HB_FUNC_STATIC( I_SPOOL );
HB_FUNC_STATIC( I_DOC );
HB_FUNC_STATIC( I_TXT );
HB_FUNC_EXTERN( STRZERO );
HB_FUNC( I_COD_PRN );
HB_FUNC_EXTERN( DEVPOS );
HB_FUNC_EXTERN( PROW );
HB_FUNC_EXTERN( PCOL );
HB_FUNC_EXTERN( DEVOUT );
HB_FUNC_EXTERN( SETPRC );
HB_FUNC_EXTERN( DIRECTORY );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( ASORT );
HB_FUNC_EXTERN( VAL );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( ISDIGIT );
HB_FUNC_EXTERN( AADD );
HB_FUNC( QPAGEPRN );
HB_FUNC_EXTERN( __EJECT );
HB_FUNC( QLINEPRN );
HB_FUNC_EXTERN( QDIFHORA );
HB_FUNC_EXTERN( ALERT );
HB_FUNC( QSTOPPRN );
HB_FUNC_EXTERN( QHELP );
HB_FUNC_EXTERN( Q595 );
HB_FUNC( QCONTPRN );
HB_FUNC( QCABECPRN );
HB_FUNC_EXTERN( DATE );
HB_FUNC_EXTERN( REPLICATE );
HB_FUNC_EXTERN( INT );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QPRN )
{ "QINITPRN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QINITPRN )}, NULL },
{ "QLBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QLBLOC )}, NULL },
{ "XDRV_SH", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "ALIAS", {HB_FS_PUBLIC}, {HB_FUNCNAME( ALIAS )}, NULL },
{ "XNOMEPRN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XBLOCTELA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XPAGINA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XLOCALIMP", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XTEMPO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XCONTPRN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XPRIPAG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "__MVPUBLIC", {HB_FS_PUBLIC}, {HB_FUNCNAME( __MVPUBLIC )}, NULL },
{ "VALTYPE", {HB_FS_PUBLIC}, {HB_FUNCNAME( VALTYPE )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "__KEYBOARD", {HB_FS_PUBLIC}, {HB_FUNCNAME( __KEYBOARD )}, NULL },
{ "SET", {HB_FS_PUBLIC}, {HB_FUNCNAME( SET )}, NULL },
{ "QUSE", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUSE )}, NULL },
{ "__DBLOCATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( __DBLOCATE )}, NULL },
{ "XCOD_PRN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QPRN", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "CODIGO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "DESCRICAO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DBCLOSEAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBCLOSEAREA )}, NULL },
{ "DBSELECTAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSELECTAREA )}, NULL },
{ "QSBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSBLOC )}, NULL },
{ "SETKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETKEY )}, NULL },
{ "QHELPPRN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QHELPPRN )}, NULL },
{ "QRBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRBLOC )}, NULL },
{ "QSAY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSAY )}, NULL },
{ "QINVERC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QINVERC )}, NULL },
{ "QINKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QINKEY )}, NULL },
{ "UPPER", {HB_FS_PUBLIC}, {HB_FUNCNAME( UPPER )}, NULL },
{ "CHR", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHR )}, NULL },
{ "__MVXRELEASE", {HB_FS_PUBLIC}, {HB_FUNCNAME( __MVXRELEASE )}, NULL },
{ "TIME", {HB_FS_PUBLIC}, {HB_FUNCNAME( TIME )}, NULL },
{ "I_RET_NOME_PRN", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_RET_NOME_PRN )}, NULL },
{ "RTRIM", {HB_FS_PUBLIC}, {HB_FUNCNAME( RTRIM )}, NULL },
{ "QOUT", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "OUTPUT", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "I_XLS", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_XLS )}, NULL },
{ "I_SPOOL", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_SPOOL )}, NULL },
{ "I_DOC", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_DOC )}, NULL },
{ "I_TXT", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_TXT )}, NULL },
{ "STRZERO", {HB_FS_PUBLIC}, {HB_FUNCNAME( STRZERO )}, NULL },
{ "I_COD_PRN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_COD_PRN )}, NULL },
{ "DEVPOS", {HB_FS_PUBLIC}, {HB_FUNCNAME( DEVPOS )}, NULL },
{ "PROW", {HB_FS_PUBLIC}, {HB_FUNCNAME( PROW )}, NULL },
{ "PCOL", {HB_FS_PUBLIC}, {HB_FUNCNAME( PCOL )}, NULL },
{ "DEVOUT", {HB_FS_PUBLIC}, {HB_FUNCNAME( DEVOUT )}, NULL },
{ "XRESET", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "SETPRC", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETPRC )}, NULL },
{ "DIRECTORY", {HB_FS_PUBLIC}, {HB_FUNCNAME( DIRECTORY )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "ASORT", {HB_FS_PUBLIC}, {HB_FUNCNAME( ASORT )}, NULL },
{ "VAL", {HB_FS_PUBLIC}, {HB_FUNCNAME( VAL )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "ISDIGIT", {HB_FS_PUBLIC}, {HB_FUNCNAME( ISDIGIT )}, NULL },
{ "AADD", {HB_FS_PUBLIC}, {HB_FUNCNAME( AADD )}, NULL },
{ "QPAGEPRN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QPAGEPRN )}, NULL },
{ "__EJECT", {HB_FS_PUBLIC}, {HB_FUNCNAME( __EJECT )}, NULL },
{ "QLINEPRN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QLINEPRN )}, NULL },
{ "QDIFHORA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QDIFHORA )}, NULL },
{ "ALERT", {HB_FS_PUBLIC}, {HB_FUNCNAME( ALERT )}, NULL },
{ "QSTOPPRN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QSTOPPRN )}, NULL },
{ "QHELP", {HB_FS_PUBLIC}, {HB_FUNCNAME( QHELP )}, NULL },
{ "Q595", {HB_FS_PUBLIC}, {HB_FUNCNAME( Q595 )}, NULL },
{ "QCONTPRN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QCONTPRN )}, NULL },
{ "QCABECPRN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QCABECPRN )}, NULL },
{ "DATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( DATE )}, NULL },
{ "XRAZAO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XPROG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "REPLICATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( REPLICATE )}, NULL },
{ "INT", {HB_FS_PUBLIC}, {HB_FUNCNAME( INT )}, NULL },
{ "RESET", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XQLINHA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QLINHA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XCOND0", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "COND0", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XCOND1", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "COND1", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XCOND2", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "COND2", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XAEXPAN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "AEXPAN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XDEXPAN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DEXPAN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XAITALI", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "AITALI", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XDITALI", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DITALI", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XASUBLI", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "ASUBLI", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XDSUBLI", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DSUBLI", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XAINDIC", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "AINDIC", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XDINDIC", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DINDIC", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XAEXPOE", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "AEXPOE", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XDEXPOE", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DEXPOE", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XACARTA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "ACARTA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XDCARTA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DCARTA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XAENFAT", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "AENFAT", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XDENFAT", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DENFAT", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QPRN, "QPRN.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QPRN
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QPRN )
   #include "hbiniseg.h"
#endif

HB_FUNC( QINITPRN )
{
	static const HB_BYTE pcode[] =
	{
		13,8,3,36,16,0,176,1,0,106,9,80,82,78,
		95,73,78,73,84,0,109,2,0,106,11,81,83,66,
		76,79,67,46,71,76,79,0,72,12,2,80,4,36,
		17,0,106,2,73,0,80,5,36,18,0,106,2,49,
		0,80,6,36,19,0,106,1,0,80,7,36,20,0,
		176,3,0,12,0,80,11,36,22,0,120,176,11,0,
		108,4,108,5,108,6,108,7,108,8,108,9,108,10,
		20,7,81,10,0,36,24,0,176,12,0,95,1,12,
		1,106,2,78,0,69,28,8,36,25,0,121,80,1,
		36,28,0,176,13,0,95,2,12,1,31,17,36,29,
		0,176,14,0,95,2,106,2,13,0,72,20,1,36,
		32,0,176,15,0,92,25,95,1,20,2,36,34,0,
		176,16,0,109,2,0,106,5,81,80,82,78,0,12,
		2,31,5,9,110,7,36,35,0,176,17,0,90,11,
		109,18,0,108,19,87,20,8,6,100,100,100,9,20,
		5,36,36,0,176,21,0,108,19,87,22,92,11,12,
		2,80,10,36,37,0,85,108,19,74,176,23,0,20,
		0,74,36,39,0,176,13,0,95,11,12,1,31,9,
		176,24,0,95,11,20,1,36,41,0,176,25,0,92,
		5,121,92,23,92,79,12,4,83,5,0,36,43,0,
		176,26,0,92,28,89,19,0,3,0,0,0,176,27,
		0,95,1,95,2,95,3,12,3,6,20,2,36,47,
		0,176,28,0,92,7,92,24,95,4,122,20,4,36,
		48,0,176,29,0,92,9,92,32,95,6,20,3,36,
		49,0,176,29,0,92,12,92,27,95,10,20,3,36,
		51,0,95,5,106,2,73,0,8,28,17,176,30,0,
		92,8,92,26,92,12,92,38,20,4,25,15,176,30,
		0,92,8,92,41,92,12,92,53,20,4,36,55,0,
		176,31,0,12,0,80,8,36,56,0,176,32,0,176,
		33,0,95,8,12,1,12,1,80,9,36,58,0,95,
		8,92,5,8,31,23,95,8,92,24,8,31,16,95,
		8,92,19,8,31,9,95,8,92,4,8,28,29,36,
		59,0,95,5,106,2,73,0,8,28,8,106,2,65,
		0,25,6,106,2,73,0,80,5,26,26,1,36,60,
		0,95,8,92,13,8,32,15,1,95,8,92,27,8,
		32,7,1,36,61,0,95,9,106,2,49,0,8,28,
		11,106,2,49,0,80,6,26,242,0,36,62,0,95,
		9,106,2,50,0,8,28,11,106,2,50,0,80,6,
		26,221,0,36,63,0,95,9,106,2,51,0,8,28,
		11,106,2,51,0,80,6,26,200,0,36,64,0,95,
		9,106,2,73,0,8,28,11,106,2,73,0,80,5,
		26,179,0,36,65,0,95,9,106,2,65,0,8,28,
		11,106,2,65,0,80,5,26,158,0,36,66,0,95,
		9,106,2,88,0,8,28,29,106,2,88,0,80,5,
		176,29,0,92,12,92,44,106,8,32,69,120,99,101,
		108,32,0,20,3,25,118,36,67,0,95,9,106,2,
		83,0,8,28,29,106,2,83,0,80,5,176,29,0,
		92,12,92,44,106,8,32,83,112,111,111,108,32,0,
		20,3,25,79,36,68,0,95,9,106,2,84,0,8,
		28,29,106,2,84,0,80,5,176,29,0,92,12,92,
		44,106,8,32,84,120,84,32,32,32,0,20,3,25,
		40,36,69,0,95,9,106,2,68,0,8,29,176,254,
		106,2,68,0,80,5,176,29,0,92,12,92,44,106,
		8,32,87,111,114,100,32,32,0,20,3,36,91,0,
		95,8,92,13,8,31,10,95,8,92,27,8,29,50,
		254,36,97,0,95,8,92,27,8,28,105,36,98,0,
		176,28,0,92,5,121,109,5,0,20,3,36,99,0,
		176,34,0,106,9,88,78,79,77,69,80,82,78,0,
		106,10,88,66,76,79,67,84,69,76,65,0,106,8,
		88,80,65,71,73,78,65,0,106,10,88,76,79,67,
		65,76,73,77,80,0,106,7,88,84,69,77,80,79,
		0,106,9,88,67,79,78,84,80,82,78,0,106,8,
		88,80,82,73,80,65,71,0,20,7,36,100,0,9,
		110,7,36,103,0,121,83,6,0,36,104,0,120,83,
		9,0,36,105,0,176,35,0,12,0,83,8,0,36,
		107,0,95,5,106,2,73,0,8,28,6,95,6,25,
		4,95,5,83,7,0,36,109,0,95,5,106,2,65,
		0,8,28,45,36,110,0,176,36,0,12,0,83,4,
		0,36,111,0,176,29,0,92,12,92,44,109,4,0,
		20,3,36,112,0,176,15,0,92,24,109,4,0,9,
		20,3,26,63,2,36,113,0,95,5,106,2,88,0,
		8,28,123,36,115,0,176,16,0,109,2,0,106,5,
		81,79,85,84,0,12,2,31,5,9,110,7,36,116,
		0,176,37,0,108,38,87,39,12,1,176,40,0,12,
		0,72,83,4,0,36,117,0,85,108,38,74,176,23,
		0,20,0,74,36,118,0,109,18,0,80,7,36,119,
		0,106,3,50,48,0,83,18,0,36,120,0,176,29,
		0,92,12,92,44,106,6,69,120,99,101,108,0,20,
		3,36,121,0,176,15,0,92,24,109,4,0,9,20,
		3,36,122,0,95,7,83,18,0,26,186,1,36,125,
		0,95,5,106,2,83,0,8,28,125,36,126,0,176,
		16,0,109,2,0,106,5,81,79,85,84,0,12,2,
		31,5,9,110,7,36,127,0,176,37,0,108,38,87,
		39,12,1,176,41,0,12,0,72,83,4,0,36,128,
		0,85,108,38,74,176,23,0,20,0,74,36,129,0,
		109,18,0,80,7,36,130,0,106,3,49,49,0,83,
		18,0,36,131,0,176,29,0,92,12,92,44,106,8,
		83,112,111,111,108,101,114,0,20,3,36,132,0,176,
		15,0,92,24,109,4,0,9,20,3,36,133,0,95,
		7,83,18,0,26,51,1,36,135,0,95,5,106,2,
		68,0,8,28,106,36,136,0,176,16,0,109,2,0,
		106,5,81,79,85,84,0,12,2,31,5,9,110,7,
		36,137,0,176,37,0,108,38,87,39,12,1,176,42,
		0,12,0,72,83,4,0,36,138,0,85,108,38,74,
		176,23,0,20,0,74,36,140,0,106,3,50,48,0,
		83,18,0,36,141,0,176,29,0,92,12,92,44,106,
		5,87,111,114,100,0,20,3,36,142,0,176,15,0,
		92,24,109,4,0,9,20,3,26,191,0,36,144,0,
		95,5,106,2,84,0,8,28,93,36,146,0,176,16,
		0,109,2,0,106,5,81,79,85,84,0,12,2,31,
		5,9,110,7,36,147,0,176,37,0,108,38,87,39,
		12,1,176,43,0,12,0,72,83,4,0,36,148,0,
		85,108,38,74,176,23,0,20,0,74,36,150,0,176,
		29,0,92,12,92,44,106,4,84,120,84,0,20,3,
		36,151,0,176,15,0,92,24,109,4,0,9,20,3,
		25,87,36,154,0,95,6,106,2,49,0,8,28,22,
		36,155,0,176,15,0,92,24,106,5,76,80,84,49,
		0,9,20,3,25,52,36,156,0,95,6,106,2,50,
		0,8,28,22,36,157,0,176,15,0,92,24,106,5,
		76,80,84,50,0,9,20,3,25,20,36,159,0,176,
		15,0,92,24,106,5,76,80,84,51,0,9,20,3,
		36,163,0,176,29,0,92,16,92,30,176,44,0,109,
		6,0,92,4,12,2,20,3,36,165,0,176,15,0,
		92,20,106,8,80,82,73,78,84,69,82,0,20,2,
		36,167,0,176,45,0,120,20,1,36,169,0,176,46,
		0,176,47,0,12,0,176,48,0,12,0,20,2,176,
		49,0,109,50,0,20,1,36,171,0,176,51,0,121,
		121,20,2,36,173,0,176,13,0,95,11,12,1,31,
		9,176,24,0,95,11,20,1,36,175,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_RET_NOME_PRN )
{
	static const HB_BYTE pcode[] =
	{
		13,3,0,36,183,0,176,52,0,106,9,82,63,63,
		63,46,80,82,78,0,12,1,80,1,36,184,0,176,
		13,0,95,1,12,1,28,24,36,185,0,106,9,82,
		48,48,48,46,80,82,78,0,4,1,0,4,1,0,
		80,1,36,187,0,122,165,80,2,25,23,36,188,0,
		95,1,95,2,1,122,1,95,1,95,2,2,36,187,
		0,175,2,0,176,53,0,95,1,12,1,15,28,227,
		36,190,0,176,54,0,95,1,12,1,80,1,36,192,
		0,106,2,82,0,176,44,0,176,55,0,176,56,0,
		95,1,176,53,0,95,1,12,1,1,92,2,92,3,
		12,3,12,1,122,72,92,3,12,2,72,106,5,46,
		80,82,78,0,72,80,3,36,193,0,95,3,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_SPOOL )
{
	static const HB_BYTE pcode[] =
	{
		13,7,0,36,198,0,4,0,0,80,4,121,80,5,
		36,199,0,106,1,0,80,6,36,200,0,9,80,7,
		36,202,0,176,37,0,108,38,87,39,12,1,80,6,
		36,205,0,176,52,0,95,6,106,9,82,63,63,63,
		46,80,82,78,0,72,100,12,2,80,1,36,208,0,
		176,13,0,95,1,12,1,28,24,36,209,0,106,9,
		82,48,48,48,46,80,82,78,0,4,1,0,4,1,
		0,80,1,36,212,0,122,165,80,2,25,103,36,213,
		0,92,2,165,80,5,25,52,36,214,0,176,57,0,
		176,56,0,95,1,95,2,1,122,1,95,5,122,12,
		3,12,1,28,10,36,215,0,120,80,7,25,13,36,
		217,0,9,80,7,36,218,0,25,13,36,213,0,175,
		5,0,92,4,15,28,203,36,222,0,95,7,28,19,
		36,223,0,176,58,0,95,4,95,1,95,2,1,122,
		1,20,2,36,226,0,9,80,7,36,212,0,175,2,
		0,176,53,0,95,1,12,1,15,28,147,36,228,0,
		176,54,0,95,4,12,1,80,4,36,230,0,106,2,
		82,0,176,44,0,176,55,0,176,56,0,95,4,176,
		53,0,95,4,12,1,1,92,2,92,3,12,3,12,
		1,122,72,92,3,12,2,72,106,5,46,80,82,78,
		0,72,80,3,36,232,0,95,3,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_TXT )
{
	static const HB_BYTE pcode[] =
	{
		13,7,0,36,237,0,4,0,0,80,4,121,80,5,
		36,238,0,106,1,0,80,6,36,239,0,9,80,7,
		36,241,0,176,37,0,108,38,87,39,12,1,80,6,
		36,244,0,176,52,0,95,6,106,9,82,63,63,63,
		46,84,88,84,0,72,100,12,2,80,1,36,247,0,
		176,13,0,95,1,12,1,28,24,36,248,0,106,9,
		82,48,48,48,46,84,88,84,0,4,1,0,4,1,
		0,80,1,36,251,0,122,165,80,2,25,103,36,252,
		0,92,2,165,80,5,25,52,36,253,0,176,57,0,
		176,56,0,95,1,95,2,1,122,1,95,5,122,12,
		3,12,1,28,10,36,254,0,120,80,7,25,13,36,
		0,1,9,80,7,36,1,1,25,13,36,252,0,175,
		5,0,92,4,15,28,203,36,5,1,95,7,28,19,
		36,6,1,176,58,0,95,4,95,1,95,2,1,122,
		1,20,2,36,9,1,9,80,7,36,251,0,175,2,
		0,176,53,0,95,1,12,1,15,28,147,36,11,1,
		176,54,0,95,4,12,1,80,4,36,13,1,106,2,
		82,0,176,44,0,176,55,0,176,56,0,95,4,176,
		53,0,95,4,12,1,1,92,2,92,3,12,3,12,
		1,122,72,92,3,12,2,72,106,5,46,84,88,84,
		0,72,80,3,36,15,1,95,3,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_DOC )
{
	static const HB_BYTE pcode[] =
	{
		13,7,0,36,20,1,4,0,0,80,4,121,80,5,
		36,21,1,106,1,0,80,6,36,22,1,9,80,7,
		36,24,1,176,37,0,108,38,87,39,12,1,80,6,
		36,27,1,176,52,0,95,6,106,9,82,63,63,63,
		46,68,79,67,0,72,100,12,2,80,1,36,30,1,
		176,13,0,95,1,12,1,28,24,36,31,1,106,9,
		82,48,48,48,46,68,79,67,0,4,1,0,4,1,
		0,80,1,36,34,1,122,165,80,2,25,103,36,35,
		1,92,2,165,80,5,25,52,36,36,1,176,57,0,
		176,56,0,95,1,95,2,1,122,1,95,5,122,12,
		3,12,1,28,10,36,37,1,120,80,7,25,13,36,
		39,1,9,80,7,36,40,1,25,13,36,35,1,175,
		5,0,92,4,15,28,203,36,44,1,95,7,28,19,
		36,45,1,176,58,0,95,4,95,1,95,2,1,122,
		1,20,2,36,48,1,9,80,7,36,34,1,175,2,
		0,176,53,0,95,1,12,1,15,28,147,36,50,1,
		176,54,0,95,4,12,1,80,4,36,52,1,106,2,
		82,0,176,44,0,176,55,0,176,56,0,95,4,176,
		53,0,95,4,12,1,1,92,2,92,3,12,3,12,
		1,122,72,92,3,12,2,72,106,5,46,68,79,67,
		0,72,80,3,36,54,1,95,3,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_XLS )
{
	static const HB_BYTE pcode[] =
	{
		13,7,0,36,61,1,4,0,0,80,4,121,80,5,
		36,62,1,106,1,0,80,6,36,63,1,9,80,7,
		36,65,1,176,37,0,108,38,87,39,12,1,80,6,
		36,68,1,176,52,0,95,6,106,9,82,63,63,63,
		46,88,76,83,0,72,100,12,2,80,1,36,71,1,
		176,13,0,95,1,12,1,28,24,36,72,1,106,9,
		82,48,48,48,46,88,76,83,0,4,1,0,4,1,
		0,80,1,36,75,1,122,165,80,2,25,103,36,76,
		1,92,2,165,80,5,25,52,36,77,1,176,57,0,
		176,56,0,95,1,95,2,1,122,1,95,5,122,12,
		3,12,1,28,10,36,78,1,120,80,7,25,13,36,
		80,1,9,80,7,36,81,1,25,13,36,76,1,175,
		5,0,92,4,15,28,203,36,85,1,95,7,28,19,
		36,86,1,176,58,0,95,4,95,1,95,2,1,122,
		1,20,2,36,89,1,9,80,7,36,75,1,175,2,
		0,176,53,0,95,1,12,1,15,28,147,36,91,1,
		176,54,0,95,4,12,1,80,4,36,93,1,106,2,
		82,0,176,44,0,176,55,0,176,56,0,95,4,176,
		53,0,95,4,12,1,1,92,2,92,3,12,3,12,
		1,122,72,92,3,12,2,72,106,5,46,88,76,83,
		0,72,80,3,36,95,1,95,3,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QPAGEPRN )
{
	static const HB_BYTE pcode[] =
	{
		36,106,1,109,10,0,28,11,36,107,1,9,83,10,
		0,25,10,36,109,1,176,60,0,20,0,36,112,1,
		176,29,0,92,16,92,30,176,44,0,109,6,0,23,
		21,83,6,0,92,4,12,2,20,3,36,114,1,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QLINEPRN )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,120,1,176,31,0,12,0,80,1,36,
		122,1,176,29,0,92,16,92,39,176,44,0,176,47,
		0,12,0,92,4,12,2,20,3,36,123,1,176,29,
		0,92,16,92,48,176,21,0,176,62,0,109,8,0,
		176,35,0,12,0,12,2,92,5,12,2,20,3,36,
		125,1,95,1,92,27,8,28,71,36,126,1,176,63,
		0,106,18,60,69,83,67,62,32,80,82,69,83,83,
		73,79,78,65,68,79,0,106,10,67,111,110,116,105,
		110,117,97,114,0,106,12,73,110,116,101,114,114,111,
		109,112,101,114,0,4,2,0,12,2,92,2,8,28,
		9,36,127,1,9,83,9,0,36,131,1,109,9,0,
		110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QSTOPPRN )
{
	static const HB_BYTE pcode[] =
	{
		13,0,2,36,137,1,176,26,0,92,28,89,19,0,
		3,0,0,0,176,65,0,95,1,95,2,95,3,12,
		3,6,20,2,36,139,1,95,1,100,8,28,5,120,
		80,1,36,141,1,95,2,100,8,28,5,120,80,2,
		36,143,1,95,1,28,7,176,60,0,20,0,36,145,
		1,109,7,0,106,2,65,0,8,28,27,36,146,1,
		176,46,0,176,47,0,12,0,122,72,121,20,2,176,
		49,0,106,2,26,0,20,1,36,149,1,176,15,0,
		92,25,121,20,2,36,150,1,176,15,0,92,24,106,
		1,0,20,2,36,151,1,176,15,0,92,20,106,7,
		83,67,82,69,69,78,0,20,2,36,153,1,109,7,
		0,106,2,65,0,8,28,14,95,2,28,10,176,66,
		0,109,4,0,20,1,36,155,1,176,28,0,92,5,
		121,109,5,0,20,3,36,157,1,176,34,0,106,9,
		88,78,79,77,69,80,82,78,0,106,10,88,66,76,
		79,67,84,69,76,65,0,106,8,88,80,65,71,73,
		78,65,0,106,10,88,76,79,67,65,76,73,77,80,
		0,106,7,88,84,69,77,80,79,0,106,9,88,67,
		79,78,84,80,82,78,0,106,8,88,80,82,73,80,
		65,71,0,20,7,36,159,1,176,45,0,9,20,1,
		36,160,1,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QCONTPRN )
{
	static const HB_BYTE pcode[] =
	{
		36,166,1,109,9,0,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QHELPPRN )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,172,1,176,25,0,121,121,92,24,92,
		79,12,4,80,1,36,173,1,176,26,0,92,28,100,
		20,2,36,174,1,176,1,0,121,121,106,9,80,82,
		78,72,69,76,80,49,0,109,2,0,106,11,81,83,
		66,76,79,67,46,71,76,79,0,72,20,4,36,175,
		1,176,1,0,121,92,58,106,9,80,82,78,72,69,
		76,80,50,0,109,2,0,106,11,81,83,66,76,79,
		67,46,71,76,79,0,72,20,4,36,176,1,176,1,
		0,92,18,121,106,9,80,82,78,72,69,76,80,51,
		0,109,2,0,106,11,81,83,66,76,79,67,46,71,
		76,79,0,72,20,4,36,177,1,176,31,0,121,20,
		1,36,178,1,176,28,0,121,121,95,1,20,3,36,
		179,1,176,26,0,92,28,89,19,0,3,0,0,0,
		176,27,0,95,1,95,2,95,3,12,3,6,20,2,
		36,180,1,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QCABECPRN )
{
	static const HB_BYTE pcode[] =
	{
		13,1,4,36,187,1,120,80,5,36,189,1,176,12,
		0,95,3,12,1,106,2,76,0,8,28,27,36,191,
		1,95,3,9,8,28,8,36,192,1,9,80,5,36,
		195,1,176,69,0,12,0,80,3,36,199,1,95,3,
		100,8,28,9,176,69,0,12,0,25,4,95,3,80,
		3,36,201,1,176,46,0,176,47,0,12,0,121,20,
		2,176,49,0,109,70,0,20,1,36,203,1,95,5,
		28,88,36,204,1,176,46,0,176,47,0,12,0,95,
		2,92,31,49,20,2,176,49,0,109,71,0,20,1,
		36,205,1,176,46,0,176,47,0,12,0,95,2,92,
		27,49,20,2,176,49,0,95,3,20,1,36,206,1,
		176,46,0,176,47,0,12,0,95,2,92,16,49,20,
		2,176,49,0,176,21,0,176,35,0,12,0,92,5,
		12,2,20,1,36,209,1,176,46,0,176,47,0,12,
		0,95,2,92,11,49,20,2,176,49,0,106,7,80,
		97,103,46,58,32,0,20,1,36,210,1,176,46,0,
		176,47,0,12,0,95,2,92,4,49,20,2,176,49,
		0,176,44,0,109,6,0,92,4,121,12,3,20,1,
		36,211,1,176,46,0,176,47,0,12,0,122,72,121,
		20,2,176,49,0,176,72,0,106,2,61,0,95,2,
		12,2,20,1,36,212,1,176,46,0,176,47,0,12,
		0,122,72,121,20,2,176,49,0,106,2,124,0,20,
		1,36,213,1,176,46,0,176,47,0,12,0,176,73,
		0,95,2,176,53,0,95,1,12,1,49,92,2,18,
		12,1,20,2,176,49,0,95,1,20,1,36,214,1,
		176,46,0,176,47,0,12,0,95,2,122,49,20,2,
		176,49,0,106,2,124,0,20,1,36,215,1,95,4,
		100,69,28,91,36,216,1,176,46,0,176,47,0,12,
		0,122,72,121,20,2,176,49,0,106,2,124,0,20,
		1,36,217,1,176,46,0,176,47,0,12,0,176,73,
		0,95,2,176,53,0,95,4,12,1,49,92,2,18,
		12,1,20,2,176,49,0,95,4,20,1,36,218,1,
		176,46,0,176,47,0,12,0,95,2,122,49,20,2,
		176,49,0,106,2,124,0,20,1,36,220,1,176,46,
		0,176,47,0,12,0,122,72,121,20,2,176,49,0,
		176,72,0,106,2,61,0,95,2,12,2,20,1,36,
		221,1,100,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( I_COD_PRN )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,227,1,95,1,29,218,2,36,228,1,
		176,16,0,109,2,0,106,5,81,80,82,78,0,12,
		2,31,5,9,110,7,36,229,1,176,17,0,90,11,
		109,18,0,108,19,87,20,8,6,100,100,100,9,20,
		5,36,230,1,176,13,0,108,19,87,74,12,1,28,
		7,106,1,0,25,8,108,19,87,74,40,11,176,11,
		0,108,50,20,1,81,50,0,36,231,1,176,13,0,
		108,19,87,76,12,1,28,7,106,1,0,25,8,108,
		19,87,76,40,11,176,11,0,108,75,20,1,81,75,
		0,36,232,1,176,13,0,108,19,87,78,12,1,28,
		7,106,1,0,25,8,108,19,87,78,40,11,176,11,
		0,108,77,20,1,81,77,0,36,233,1,176,13,0,
		108,19,87,80,12,1,28,7,106,1,0,25,8,108,
		19,87,80,40,11,176,11,0,108,79,20,1,81,79,
		0,36,234,1,176,13,0,108,19,87,82,12,1,28,
		7,106,1,0,25,8,108,19,87,82,40,11,176,11,
		0,108,81,20,1,81,81,0,36,235,1,176,13,0,
		108,19,87,84,12,1,28,7,106,1,0,25,8,108,
		19,87,84,40,11,176,11,0,108,83,20,1,81,83,
		0,36,236,1,176,13,0,108,19,87,86,12,1,28,
		7,106,1,0,25,8,108,19,87,86,40,11,176,11,
		0,108,85,20,1,81,85,0,36,237,1,176,13,0,
		108,19,87,88,12,1,28,7,106,1,0,25,8,108,
		19,87,88,40,11,176,11,0,108,87,20,1,81,87,
		0,36,238,1,176,13,0,108,19,87,90,12,1,28,
		7,106,1,0,25,8,108,19,87,90,40,11,176,11,
		0,108,89,20,1,81,89,0,36,239,1,176,13,0,
		108,19,87,92,12,1,28,7,106,1,0,25,8,108,
		19,87,92,40,11,176,11,0,108,91,20,1,81,91,
		0,36,240,1,176,13,0,108,19,87,94,12,1,28,
		7,106,1,0,25,8,108,19,87,94,40,11,176,11,
		0,108,93,20,1,81,93,0,36,241,1,176,13,0,
		108,19,87,96,12,1,28,7,106,1,0,25,8,108,
		19,87,96,40,11,176,11,0,108,95,20,1,81,95,
		0,36,242,1,176,13,0,108,19,87,98,12,1,28,
		7,106,1,0,25,8,108,19,87,98,40,11,176,11,
		0,108,97,20,1,81,97,0,36,243,1,176,13,0,
		108,19,87,100,12,1,28,7,106,1,0,25,8,108,
		19,87,100,40,11,176,11,0,108,99,20,1,81,99,
		0,36,244,1,176,13,0,108,19,87,102,12,1,28,
		7,106,1,0,25,8,108,19,87,102,40,11,176,11,
		0,108,101,20,1,81,101,0,36,245,1,176,13,0,
		108,19,87,104,12,1,28,7,106,1,0,25,8,108,
		19,87,104,40,11,176,11,0,108,103,20,1,81,103,
		0,36,246,1,176,13,0,108,19,87,106,12,1,28,
		7,106,1,0,25,8,108,19,87,106,40,11,176,11,
		0,108,105,20,1,81,105,0,36,247,1,176,13,0,
		108,19,87,108,12,1,28,7,106,1,0,25,8,108,
		19,87,108,40,11,176,11,0,108,107,20,1,81,107,
		0,36,248,1,176,13,0,108,19,87,110,12,1,28,
		7,106,1,0,25,8,108,19,87,110,40,11,176,11,
		0,108,109,20,1,81,109,0,36,249,1,85,108,19,
		74,176,23,0,20,0,74,26,221,0,36,251,1,176,
		34,0,106,7,88,82,69,83,69,84,0,106,8,88,
		81,76,73,78,72,65,0,106,7,88,67,79,78,68,
		48,0,106,7,88,67,79,78,68,49,0,106,7,88,
		67,79,78,68,50,0,20,5,36,252,1,176,34,0,
		106,8,88,65,69,88,80,65,78,0,106,8,88,68,
		69,88,80,65,78,0,106,8,88,65,73,84,65,76,
		73,0,106,8,88,68,73,84,65,76,73,0,106,8,
		88,65,67,65,82,84,65,0,106,8,88,68,67,65,
		82,84,65,0,20,6,36,253,1,176,34,0,106,8,
		88,65,83,85,66,76,73,0,106,8,88,68,83,85,
		66,76,73,0,106,8,88,65,73,78,68,73,67,0,
		106,8,88,68,73,78,68,73,67,0,106,8,88,65,
		69,88,80,79,69,0,106,8,88,68,69,88,80,79,
		69,0,20,6,36,254,1,176,34,0,106,8,88,65,
		69,78,70,65,84,0,106,8,88,68,69,78,70,65,
		84,0,20,2,36,0,2,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

