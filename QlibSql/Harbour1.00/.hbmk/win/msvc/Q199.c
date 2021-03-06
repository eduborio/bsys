/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "Q199.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( Q199 );
HB_FUNC_EXTERN( QUSE );
HB_FUNC_EXTERN( QLBLOC );
HB_FUNC_EXTERN( QVIEW );
HB_FUNC_EXTERN( DBCLOSEAREA );
HB_FUNC( F199A );
HB_FUNC_EXTERN( __MVPRIVATE );
HB_FUNC_EXTERN( DBSEEK );
HB_FUNC_EXTERN( QSEEKN );
HB_FUNC( F199B );
HB_FUNC_EXTERN( SETCURSOR );
HB_FUNC_EXTERN( UPPER );
HB_FUNC_EXTERN( CHR );
HB_FUNC_EXTERN( QMENSA );
HB_FUNC_EXTERN( QABREV );
HB_FUNC_STATIC( I_EDICAO );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( QRSAY );
HB_FUNC_EXTERN( QWAIT );
HB_FUNC_STATIC( I_EXCLUSAO );
HB_FUNC_EXTERN( AADD );
HB_FUNC_EXTERN( QGETX );
HB_FUNC_EXTERN( QESCO );
HB_FUNC_EXTERN( QCONF );
HB_FUNC_EXTERN( QPUBLICFIELDS );
HB_FUNC_EXTERN( QINITFIELDS );
HB_FUNC_EXTERN( QCOPYFIELDS );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( QRELEASEFIELDS );
HB_FUNC_STATIC( I_CRITICA );
HB_FUNC_EXTERN( QAPPEND );
HB_FUNC_EXTERN( QRLOCK );
HB_FUNC_EXTERN( QREPLACEFIELDS );
HB_FUNC_EXTERN( QUNLOCK );
HB_FUNC_EXTERN( QM1 );
HB_FUNC_EXTERN( QM2 );
HB_FUNC_EXTERN( DBDELETE );
HB_FUNC_EXTERN( QM3 );
HB_FUNC( F199C );
HB_FUNC_EXTERN( ROW );
HB_FUNC_EXTERN( SCROLL );
HB_FUNC_INITSTATICS();


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_Q199 )
{ "Q199", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( Q199 )}, NULL },
{ "QUSE", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUSE )}, NULL },
{ "XDRV_SH", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QLBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QLBLOC )}, NULL },
{ "INDC", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "QVIEW", {HB_FS_PUBLIC}, {HB_FUNCNAME( QVIEW )}, NULL },
{ "DBCLOSEAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBCLOSEAREA )}, NULL },
{ "INDV", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "F199A", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( F199A )}, NULL },
{ "CIND", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "INDICE", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "__MVPRIVATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( __MVPRIVATE )}, NULL },
{ "DBSEEK", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSEEK )}, NULL },
{ "QSEEKN", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSEEKN )}, NULL },
{ "F199B", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( F199B )}, NULL },
{ "SETCURSOR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETCURSOR )}, NULL },
{ "COPCAO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "UPPER", {HB_FS_PUBLIC}, {HB_FUNCNAME( UPPER )}, NULL },
{ "CHR", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHR )}, NULL },
{ "QMENSA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QMENSA )}, NULL },
{ "QABREV", {HB_FS_PUBLIC}, {HB_FUNCNAME( QABREV )}, NULL },
{ "I_EDICAO", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_EDICAO )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "FINDICE", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XNIVEL", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XFLAG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QRSAY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRSAY )}, NULL },
{ "DESCRICAO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "PERIODO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "TIPO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QWAIT", {HB_FS_PUBLIC}, {HB_FUNCNAME( QWAIT )}, NULL },
{ "I_EXCLUSAO", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_EXCLUSAO )}, NULL },
{ "AADD", {HB_FS_PUBLIC}, {HB_FUNCNAME( AADD )}, NULL },
{ "QGETX", {HB_FS_PUBLIC}, {HB_FUNCNAME( QGETX )}, NULL },
{ "FDESCRICAO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QESCO", {HB_FS_PUBLIC}, {HB_FUNCNAME( QESCO )}, NULL },
{ "FPERIODO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "FTIPO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QCONF", {HB_FS_PUBLIC}, {HB_FUNCNAME( QCONF )}, NULL },
{ "QPUBLICFIELDS", {HB_FS_PUBLIC}, {HB_FUNCNAME( QPUBLICFIELDS )}, NULL },
{ "QINITFIELDS", {HB_FS_PUBLIC}, {HB_FUNCNAME( QINITFIELDS )}, NULL },
{ "QCOPYFIELDS", {HB_FS_PUBLIC}, {HB_FUNCNAME( QCOPYFIELDS )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "EVAL", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "QRELEASEFIELDS", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRELEASEFIELDS )}, NULL },
{ "I_CRITICA", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_CRITICA )}, NULL },
{ "QAPPEND", {HB_FS_PUBLIC}, {HB_FUNCNAME( QAPPEND )}, NULL },
{ "QRLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRLOCK )}, NULL },
{ "QREPLACEFIELDS", {HB_FS_PUBLIC}, {HB_FUNCNAME( QREPLACEFIELDS )}, NULL },
{ "QUNLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUNLOCK )}, NULL },
{ "QM1", {HB_FS_PUBLIC}, {HB_FUNCNAME( QM1 )}, NULL },
{ "QM2", {HB_FS_PUBLIC}, {HB_FUNCNAME( QM2 )}, NULL },
{ "DBDELETE", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBDELETE )}, NULL },
{ "QM3", {HB_FS_PUBLIC}, {HB_FUNCNAME( QM3 )}, NULL },
{ "F199C", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( F199C )}, NULL },
{ "ROW", {HB_FS_PUBLIC}, {HB_FUNCNAME( ROW )}, NULL },
{ "SCROLL", {HB_FS_PUBLIC}, {HB_FUNCNAME( SCROLL )}, NULL },
{ "DATA_REF", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "VALOR", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "(_INITSTATICS00001)", {HB_FS_INITEXIT | HB_FS_LOCAL}, {hb_INITSTATICS}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_Q199, "Q199.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_Q199
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_Q199 )
   #include "hbiniseg.h"
#endif

HB_FUNC( Q199 )
{
	static const HB_BYTE pcode[] =
	{
		116,59,0,36,7,0,176,1,0,109,2,0,106,5,
		73,78,68,67,0,106,9,73,67,95,73,78,68,73,
		67,0,106,9,73,67,95,68,69,83,67,82,0,4,
		2,0,12,3,31,3,7,36,8,0,176,1,0,109,
		2,0,106,5,73,78,68,86,0,106,9,73,86,95,
		73,78,68,73,67,0,4,1,0,12,3,31,3,7,
		36,10,0,176,3,0,92,5,121,106,6,66,49,57,
		57,65,0,109,2,0,106,11,81,83,66,76,79,67,
		46,71,76,79,0,72,20,4,36,17,0,85,108,4,
		74,176,5,0,106,20,68,101,115,99,114,105,99,97,
		111,47,68,101,115,99,114,105,135,132,111,0,92,2,
		4,2,0,106,12,73,110,100,105,99,101,47,67,162,
		100,46,0,122,4,2,0,106,11,80,101,114,105,111,
		100,111,47,80,46,0,121,4,2,0,106,8,84,105,
		112,111,47,84,46,0,121,4,2,0,4,4,0,106,
		9,48,53,48,48,50,51,52,52,0,106,6,102,49,
		57,57,97,0,106,6,102,49,57,57,98,0,100,100,
		4,4,0,20,3,74,36,19,0,85,108,4,74,176,
		6,0,20,0,74,36,20,0,85,108,7,74,176,6,
		0,20,0,74,36,22,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( F199A )
{
	static const HB_BYTE pcode[] =
	{
		36,28,0,108,4,87,10,176,11,0,108,9,20,1,
		81,9,0,36,29,0,85,108,7,74,176,12,0,109,
		9,0,20,1,74,36,36,0,85,108,7,74,176,5,
		0,106,14,68,97,116,97,95,114,101,102,47,68,97,
		116,97,0,122,4,2,0,106,45,116,114,97,110,115,
		102,111,114,109,40,86,97,108,111,114,44,39,64,69,
		32,57,57,57,44,57,57,57,44,57,57,57,46,57,
		57,57,57,39,41,47,86,97,108,111,114,0,121,4,
		2,0,4,2,0,106,9,48,53,52,53,50,51,55,
		57,0,100,106,6,102,49,57,57,99,0,100,100,4,
		4,0,106,13,73,110,100,105,99,101,61,61,99,73,
		78,68,0,90,11,176,12,0,109,9,0,12,1,6,
		90,11,176,13,0,109,9,0,12,1,6,4,3,0,
		106,48,65,76,84,45,80,32,47,32,60,73,62,110,
		99,108,117,105,114,32,47,32,60,65,62,108,116,101,
		114,97,114,32,47,32,60,69,62,120,99,108,117,105,
		114,32,47,32,69,83,67,0,20,5,74,36,37,0,
		106,1,0,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( F199B )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,43,0,176,15,0,122,12,1,80,2,
		71,16,0,1,36,45,0,176,17,0,176,18,0,109,
		16,0,12,1,12,1,83,16,0,36,47,0,176,3,
		0,92,15,92,10,106,6,66,49,57,57,66,0,109,
		2,0,106,11,81,83,66,76,79,67,46,71,76,79,
		0,72,122,20,5,36,48,0,176,19,0,176,20,0,
		109,16,0,106,3,73,65,0,106,12,73,110,99,108,
		117,115,132,111,46,46,46,0,106,13,65,108,116,101,
		114,97,135,132,111,46,46,46,0,4,2,0,12,3,
		20,1,36,49,0,176,21,0,20,0,36,51,0,176,
		15,0,95,2,20,1,36,52,0,106,1,0,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_EDICAO )
{
	static const HB_BYTE pcode[] =
	{
		13,5,0,36,59,0,4,0,0,80,2,36,60,0,
		176,3,0,106,6,66,49,57,57,67,0,109,2,0,
		106,11,81,83,66,76,79,67,46,71,76,79,0,72,
		12,2,80,3,36,61,0,176,3,0,106,6,66,49,
		57,57,68,0,109,2,0,106,11,81,83,66,76,79,
		67,46,71,76,79,0,72,12,2,80,4,36,63,0,
		90,58,176,22,0,109,23,0,12,1,21,31,46,73,
		109,24,0,122,8,21,28,10,73,109,25,0,68,21,
		31,29,73,109,24,0,92,2,8,21,28,19,73,109,
		16,0,106,2,65,0,8,21,28,7,73,109,25,0,
		68,6,80,5,36,67,0,109,16,0,106,2,73,0,
		69,29,149,0,36,68,0,122,83,24,0,36,69,0,
		176,26,0,109,24,0,21,23,83,24,0,108,4,87,
		10,20,2,36,70,0,176,26,0,109,24,0,21,23,
		83,24,0,108,4,87,27,20,2,36,71,0,176,26,
		0,109,24,0,21,23,83,24,0,176,20,0,108,4,
		87,28,106,3,77,68,0,106,7,77,69,78,83,65,
		76,0,106,7,68,73,65,82,73,79,0,4,2,0,
		12,3,20,2,36,72,0,176,26,0,109,24,0,21,
		23,83,24,0,176,20,0,108,4,87,29,106,3,70,
		84,0,106,6,70,65,84,79,82,0,106,5,84,65,
		88,65,0,4,2,0,12,3,20,2,36,77,0,109,
		16,0,106,2,67,0,8,28,8,176,30,0,20,0,
		7,36,78,0,109,16,0,106,2,69,0,8,28,8,
		176,31,0,20,0,7,36,82,0,176,32,0,95,2,
		90,28,176,33,0,92,255,121,99,23,0,106,3,64,
		33,0,100,109,16,0,106,2,73,0,8,12,6,6,
		106,7,73,78,68,73,67,69,0,4,2,0,20,2,
		36,83,0,176,32,0,95,2,90,19,176,33,0,92,
		255,121,99,34,0,106,3,64,33,0,12,4,6,106,
		10,68,69,83,67,82,73,67,65,79,0,4,2,0,
		20,2,36,84,0,176,32,0,95,2,89,23,0,0,
		0,1,0,3,0,176,35,0,92,255,121,99,36,0,
		95,255,12,4,6,106,8,80,69,82,73,79,68,79,
		0,4,2,0,20,2,36,85,0,176,32,0,95,2,
		89,23,0,0,0,1,0,4,0,176,35,0,92,255,
		121,99,37,0,95,255,12,4,6,106,5,84,73,80,
		79,0,4,2,0,20,2,36,86,0,176,32,0,95,
		2,89,72,0,0,0,1,0,1,0,176,38,0,106,
		10,67,111,110,102,105,114,109,97,32,0,109,16,0,
		106,2,73,0,8,28,15,106,9,105,110,99,108,117,
		115,132,111,0,25,14,106,10,97,108,116,101,114,97,
		135,132,111,0,72,106,3,32,63,0,72,12,1,165,
		80,255,6,100,4,2,0,20,2,36,90,0,85,108,
		4,74,176,39,0,20,0,74,36,91,0,109,16,0,
		106,2,73,0,8,28,14,85,108,4,74,176,40,0,
		20,0,74,25,12,85,108,4,74,176,41,0,20,0,
		74,36,92,0,122,83,24,0,36,93,0,120,83,25,
		0,36,97,0,109,24,0,122,16,28,100,109,24,0,
		176,42,0,95,2,12,1,34,28,87,36,98,0,48,
		43,0,95,2,109,24,0,1,122,1,112,0,73,36,
		99,0,48,43,0,95,5,112,0,28,13,85,108,4,
		74,176,44,0,20,0,74,7,36,100,0,176,45,0,
		95,2,109,24,0,1,92,2,1,12,1,28,176,36,
		101,0,109,25,0,28,11,109,24,0,23,83,24,0,
		25,159,109,24,0,17,83,24,0,25,150,36,106,0,
		95,1,31,3,7,36,108,0,85,108,4,74,109,16,
		0,106,2,73,0,8,28,9,176,46,0,12,0,25,
		7,176,47,0,12,0,119,28,30,36,109,0,85,108,
		4,74,176,48,0,20,0,74,36,110,0,85,108,4,
		74,176,49,0,20,0,74,25,27,36,112,0,109,16,
		0,106,2,73,0,8,28,9,176,50,0,20,0,25,
		7,176,51,0,20,0,36,115,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_CRITICA )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,121,0,95,1,100,8,28,7,106,1,
		0,80,1,36,123,0,95,1,106,7,73,78,68,73,
		67,69,0,8,28,74,109,16,0,106,2,73,0,8,
		28,64,36,124,0,85,108,4,74,176,12,0,109,23,
		0,12,1,119,29,200,0,36,125,0,176,19,0,106,
		23,67,162,100,105,103,111,32,106,160,32,99,97,100,
		97,115,116,114,97,100,111,32,33,0,106,2,66,0,
		20,2,36,126,0,9,110,7,36,128,0,95,1,106,
		8,80,69,82,73,79,68,79,0,8,28,65,36,129,
		0,176,22,0,109,36,0,12,1,28,5,9,110,7,
		36,130,0,176,26,0,109,24,0,176,20,0,109,36,
		0,106,3,77,68,0,106,7,77,69,78,83,65,76,
		0,106,7,68,73,65,82,73,79,0,4,2,0,12,
		3,20,2,25,75,36,131,0,95,1,106,5,84,73,
		80,79,0,8,28,60,36,132,0,176,22,0,109,37,
		0,12,1,28,5,9,110,7,36,133,0,176,26,0,
		109,24,0,176,20,0,109,37,0,106,3,70,84,0,
		106,6,70,65,84,79,82,0,106,5,84,65,88,65,
		0,4,2,0,12,3,20,2,36,135,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_EXCLUSAO )
{
	static const HB_BYTE pcode[] =
	{
		36,141,0,176,38,0,106,33,67,111,110,102,105,114,
		109,97,32,101,120,99,108,117,115,132,111,32,100,101,
		115,116,101,32,105,110,100,105,99,101,32,63,0,12,
		1,28,53,36,142,0,85,108,4,74,176,47,0,12,
		0,119,28,30,36,143,0,85,108,4,74,176,52,0,
		20,0,74,36,144,0,85,108,4,74,176,49,0,20,
		0,74,25,10,36,146,0,176,53,0,20,0,36,149,
		0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( F199C )
{
	static const HB_BYTE pcode[] =
	{
		13,4,1,36,155,0,176,15,0,122,12,1,80,2,
		36,156,0,176,55,0,12,0,80,5,71,16,0,1,
		36,158,0,176,17,0,176,18,0,109,16,0,12,1,
		12,1,83,16,0,36,161,0,109,16,0,106,2,73,
		0,8,29,181,0,36,162,0,176,56,0,92,8,92,
		47,92,22,92,77,122,20,5,36,163,0,134,0,0,
		0,0,80,3,36,164,0,121,80,4,36,165,0,176,
		33,0,92,22,92,50,96,3,0,20,3,36,166,0,
		176,33,0,92,22,92,59,96,4,0,106,20,64,69,
		32,57,57,57,44,57,57,57,44,57,57,57,46,57,
		57,57,57,0,20,4,36,167,0,176,38,0,106,20,
		67,111,110,102,105,114,109,97,32,105,110,99,108,117,
		115,132,111,32,63,0,12,1,29,55,1,85,108,7,
		74,176,46,0,12,0,119,29,42,1,36,168,0,109,
		9,0,108,7,76,10,36,169,0,95,3,108,7,76,
		57,36,170,0,95,4,108,7,76,58,36,171,0,85,
		108,7,74,176,49,0,20,0,74,36,172,0,26,251,
		0,36,173,0,109,16,0,106,2,65,0,8,29,154,
		0,36,174,0,108,7,87,57,80,3,36,175,0,108,
		7,87,58,80,4,36,176,0,176,33,0,95,5,92,
		50,96,3,0,20,3,36,177,0,176,33,0,95,5,
		92,59,96,4,0,106,20,64,69,32,57,57,57,44,
		57,57,57,44,57,57,57,46,57,57,57,57,0,20,
		4,36,178,0,176,38,0,106,20,67,111,110,102,105,
		114,109,97,32,105,110,99,108,117,115,132,111,32,63,
		0,12,1,29,134,0,85,108,7,74,176,47,0,12,
		0,119,28,121,36,179,0,95,3,108,7,76,57,36,
		180,0,95,4,108,7,76,58,36,181,0,85,108,7,
		74,176,49,0,20,0,74,36,182,0,25,85,36,183,
		0,109,16,0,106,2,69,0,8,28,72,36,184,0,
		176,38,0,106,20,67,111,110,102,105,114,109,97,32,
		101,120,99,108,117,115,132,111,32,63,0,12,1,28,
		40,85,108,7,74,176,47,0,12,0,119,28,28,36,
		185,0,85,108,7,74,176,52,0,20,0,74,36,186,
		0,85,108,7,74,176,49,0,20,0,74,36,190,0,
		176,15,0,95,2,20,1,36,191,0,106,1,0,110,
		7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_INITSTATICS()
{
	static const HB_BYTE pcode[] =
	{
		117,59,0,1,0,116,59,0,106,1,0,82,1,0,
		7
	};

	hb_vmExecute( pcode, symbols );
}

