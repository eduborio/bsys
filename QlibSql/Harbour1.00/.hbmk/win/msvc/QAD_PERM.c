/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QAD_PERM.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QAD_PERM );
HB_FUNC_EXTERN( QLBLOC );
HB_FUNC_EXTERN( __MVPRIVATE );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( QACHOICE );
HB_FUNC_STATIC( QAD_PERM2 );
HB_FUNC_EXTERN( DBSELECTAREA );
HB_FUNC_EXTERN( QUSE );
HB_FUNC_EXTERN( ORDSETFOCUS );
HB_FUNC_EXTERN( DBGOTOP );
HB_FUNC_EXTERN( QVIEW );
HB_FUNC_EXTERN( DBCLOSEAREA );
HB_FUNC( YPERMX );
HB_FUNC_EXTERN( RECNO );
HB_FUNC_EXTERN( QMENSA );
HB_FUNC_EXTERN( QSAY );
HB_FUNC_EXTERN( SPACE );
HB_FUNC( YPERMIDT );
HB_FUNC_EXTERN( EOF );
HB_FUNC_EXTERN( QGIRABARRA );
HB_FUNC_EXTERN( DBSEEK );
HB_FUNC_EXTERN( QAPPEND );
HB_FUNC_EXTERN( QUNLOCK );
HB_FUNC_EXTERN( DBSKIP );
HB_FUNC_EXTERN( DBCLEARREL );
HB_FUNC_EXTERN( DBSETRELATION );
HB_FUNC_EXTERN( INDEXORD );
HB_FUNC( YPTOP );
HB_FUNC( YPBOT );
HB_FUNC_EXTERN( DBGOTO );
HB_FUNC_EXTERN( QDECRI );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( RIGHT );
HB_FUNC_EXTERN( QSEEKN );
HB_FUNC( YPX );
HB_FUNC_EXTERN( ALLTRIM );
HB_FUNC_EXTERN( UPPER );
HB_FUNC_EXTERN( CHR );
HB_FUNC( YPO );
HB_FUNC( YPERMDIAS );
HB_FUNC( YPH );
HB_FUNC_EXTERN( STRTRAN );
HB_FUNC_EXTERN( QRLOCK );
HB_FUNC_EXTERN( LASTKEY );
HB_FUNC_EXTERN( STR );
HB_FUNC_EXTERN( QSBLOC );
HB_FUNC_EXTERN( QGETX );
HB_FUNC_EXTERN( QRBLOC );
HB_FUNC( YPTOTAL );
HB_FUNC( YPCONFIG );
HB_FUNC_EXTERN( QCONF );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QAD_PERM )
{ "QAD_PERM", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QAD_PERM )}, NULL },
{ "QLBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QLBLOC )}, NULL },
{ "XDRV_SH", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "LUSER", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "__MVPRIVATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( __MVPRIVATE )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "QACHOICE", {HB_FS_PUBLIC}, {HB_FUNCNAME( QACHOICE )}, NULL },
{ "QAD_PERM2", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( QAD_PERM2 )}, NULL },
{ "DBSELECTAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSELECTAREA )}, NULL },
{ "QUSE", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUSE )}, NULL },
{ "QUSERS", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "ORDSETFOCUS", {HB_FS_PUBLIC}, {HB_FUNCNAME( ORDSETFOCUS )}, NULL },
{ "QACESS", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "DBGOTOP", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBGOTOP )}, NULL },
{ "QVIEW", {HB_FS_PUBLIC}, {HB_FUNCNAME( QVIEW )}, NULL },
{ "DBCLOSEAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBCLOSEAREA )}, NULL },
{ "QPROGS", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "YPERMX", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPERMX )}, NULL },
{ "RECNO", {HB_FS_PUBLIC}, {HB_FUNCNAME( RECNO )}, NULL },
{ "CUSRNUM", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "USRNUM", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "CPROG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "PROG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "CMACROLOOP", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QMENSA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QMENSA )}, NULL },
{ "QSAY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSAY )}, NULL },
{ "SPACE", {HB_FS_PUBLIC}, {HB_FUNCNAME( SPACE )}, NULL },
{ "YPERMIDT", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPERMIDT )}, NULL },
{ "DESCRICAO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "EOF", {HB_FS_PUBLIC}, {HB_FUNCNAME( EOF )}, NULL },
{ "QGIRABARRA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QGIRABARRA )}, NULL },
{ "DBSEEK", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSEEK )}, NULL },
{ "XEMPRESA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QAPPEND", {HB_FS_PUBLIC}, {HB_FUNCNAME( QAPPEND )}, NULL },
{ "EMPRESA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QUNLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUNLOCK )}, NULL },
{ "DBSKIP", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSKIP )}, NULL },
{ "DBCLEARREL", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBCLEARREL )}, NULL },
{ "DBSETRELATION", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSETRELATION )}, NULL },
{ "INDEXORD", {HB_FS_PUBLIC}, {HB_FUNCNAME( INDEXORD )}, NULL },
{ "YPTOP", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPTOP )}, NULL },
{ "YPBOT", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPBOT )}, NULL },
{ "DBGOTO", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBGOTO )}, NULL },
{ "QDECRI", {HB_FS_PUBLIC}, {HB_FUNCNAME( QDECRI )}, NULL },
{ "IDENTIFIC", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "RIGHT", {HB_FS_PUBLIC}, {HB_FUNCNAME( RIGHT )}, NULL },
{ "QSEEKN", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSEEKN )}, NULL },
{ "YPX", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPX )}, NULL },
{ "ALLTRIM", {HB_FS_PUBLIC}, {HB_FUNCNAME( ALLTRIM )}, NULL },
{ "ACESSO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DIAS", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "HORARIO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "UPPER", {HB_FS_PUBLIC}, {HB_FUNCNAME( UPPER )}, NULL },
{ "CHR", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHR )}, NULL },
{ "YPO", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPO )}, NULL },
{ "YPERMDIAS", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPERMDIAS )}, NULL },
{ "YPH", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPH )}, NULL },
{ "STRTRAN", {HB_FS_PUBLIC}, {HB_FUNCNAME( STRTRAN )}, NULL },
{ "QRLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRLOCK )}, NULL },
{ "LASTKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( LASTKEY )}, NULL },
{ "STR", {HB_FS_PUBLIC}, {HB_FUNCNAME( STR )}, NULL },
{ "QSBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSBLOC )}, NULL },
{ "QGETX", {HB_FS_PUBLIC}, {HB_FUNCNAME( QGETX )}, NULL },
{ "QRBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRBLOC )}, NULL },
{ "YPTOTAL", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPTOTAL )}, NULL },
{ "YPCONFIG", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YPCONFIG )}, NULL },
{ "QCONF", {HB_FS_PUBLIC}, {HB_FUNCNAME( QCONF )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QAD_PERM, "QAD_PERM.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QAD_PERM
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QAD_PERM )
   #include "hbiniseg.h"
#endif

HB_FUNC( QAD_PERM )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,7,0,176,1,0,106,9,80,87,95,
		77,69,78,85,80,0,109,2,0,106,11,81,83,66,
		76,79,67,46,71,76,79,0,72,12,2,80,1,36,
		8,0,176,4,0,108,3,20,1,36,10,0,176,5,
		0,176,6,0,92,7,92,68,95,1,12,3,165,83,
		3,0,12,1,28,3,7,36,12,0,109,3,0,106,
		2,85,0,8,28,8,120,83,3,0,25,6,9,83,
		3,0,36,14,0,176,7,0,20,0,36,15,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( QAD_PERM2 )
{
	static const HB_BYTE pcode[] =
	{
		36,22,0,176,8,0,106,7,81,85,83,69,82,83,
		0,20,1,36,24,0,176,9,0,106,1,0,106,7,
		81,80,82,79,71,83,0,106,7,81,80,82,79,71,
		83,0,4,1,0,12,3,31,5,9,110,7,36,25,
		0,176,9,0,106,1,0,106,7,81,65,67,69,83,
		83,0,106,8,81,65,67,69,83,83,49,0,106,8,
		81,65,67,69,83,83,50,0,4,2,0,12,3,31,
		5,9,110,7,36,27,0,85,108,10,74,176,11,0,
		109,3,0,28,5,122,25,4,92,2,20,1,74,36,
		28,0,85,108,12,74,176,11,0,109,3,0,28,5,
		122,25,4,92,2,20,1,74,36,30,0,109,3,0,
		29,153,0,36,31,0,176,8,0,106,7,81,85,83,
		69,82,83,0,20,1,36,32,0,176,13,0,20,0,
		36,35,0,176,14,0,106,39,115,117,98,115,40,113,
		100,101,99,114,105,40,73,100,101,110,116,105,102,105,
		99,41,44,49,49,44,49,48,41,47,73,100,101,110,
		116,105,102,46,0,122,4,2,0,106,42,114,105,103,
		104,116,40,113,100,101,99,114,105,40,73,100,101,110,
		116,105,102,105,99,41,44,51,48,41,47,78,111,109,
		101,32,67,111,109,112,108,101,116,111,0,121,4,2,
		0,4,2,0,106,2,67,0,106,7,121,112,101,114,
		109,120,0,100,100,100,4,4,0,20,3,25,94,36,
		37,0,176,8,0,106,7,81,80,82,79,71,83,0,
		20,1,36,38,0,176,13,0,20,0,36,41,0,176,
		14,0,106,5,80,114,111,103,0,122,4,2,0,106,
		20,68,101,115,99,114,105,99,97,111,47,68,101,115,
		99,114,105,135,132,111,0,121,4,2,0,4,2,0,
		106,2,67,0,106,7,121,112,101,114,109,120,0,100,
		100,100,4,4,0,20,3,36,44,0,85,108,12,74,
		176,15,0,20,0,74,36,45,0,85,108,16,74,176,
		15,0,20,0,74,36,47,0,176,8,0,106,7,81,
		85,83,69,82,83,0,20,1,36,48,0,176,11,0,
		106,10,73,68,69,78,84,73,70,73,67,0,20,1,
		36,50,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPERMX )
{
	static const HB_BYTE pcode[] =
	{
		13,4,0,36,57,0,109,3,0,28,14,85,108,10,
		74,176,18,0,12,0,119,25,12,85,108,16,74,176,
		18,0,12,0,119,80,4,36,59,0,108,10,87,20,
		176,4,0,108,19,20,1,81,19,0,36,60,0,108,
		16,87,22,176,4,0,108,21,20,1,81,21,0,36,
		63,0,109,3,0,28,52,106,46,88,69,77,80,82,
		69,83,65,61,61,69,109,112,114,101,115,97,46,97,
		110,100,46,81,65,67,69,83,83,45,62,85,115,114,
		110,117,109,61,61,99,85,83,82,78,85,77,0,25,
		46,106,42,88,69,77,80,82,69,83,65,61,61,69,
		109,112,114,101,115,97,46,97,110,100,46,81,65,67,
		69,83,83,45,62,80,114,111,103,61,61,99,80,82,
		79,71,0,176,4,0,108,23,20,1,81,23,0,36,
		65,0,176,24,0,106,45,65,103,117,97,114,100,101,
		44,32,118,101,114,105,102,105,99,97,110,100,111,32,
		112,101,114,109,105,115,115,148,101,115,32,100,101,32,
		97,99,101,115,115,111,46,46,46,0,20,1,36,67,
		0,176,25,0,92,5,121,176,26,0,92,54,12,1,
		20,3,36,68,0,176,25,0,92,6,121,176,26,0,
		92,54,12,1,20,3,36,69,0,176,25,0,92,7,
		121,176,26,0,92,54,12,1,20,3,36,70,0,176,
		25,0,92,5,122,106,27,80,69,82,77,73,83,83,
		153,69,83,32,68,69,32,65,67,69,83,83,79,32,
		80,65,82,65,58,0,20,3,36,71,0,176,25,0,
		92,6,122,109,3,0,28,9,176,27,0,12,0,25,
		15,109,21,0,106,2,47,0,72,108,16,87,28,72,
		20,3,36,73,0,109,3,0,29,146,0,36,74,0,
		85,108,16,74,176,13,0,20,0,74,36,75,0,85,
		108,16,74,176,29,0,12,0,119,31,111,36,76,0,
		176,30,0,20,0,36,77,0,85,108,12,74,176,31,
		0,109,32,0,109,19,0,72,108,16,87,22,72,12,
		1,119,31,61,36,78,0,85,108,12,74,176,33,0,
		12,0,119,28,46,36,79,0,109,32,0,108,12,76,
		34,36,80,0,109,19,0,108,12,76,20,36,81,0,
		108,16,87,22,108,12,76,22,36,82,0,85,108,12,
		74,176,35,0,20,0,74,36,85,0,85,108,16,74,
		176,36,0,20,0,74,25,134,36,86,0,26,143,0,
		36,88,0,85,108,10,74,176,13,0,20,0,74,36,
		89,0,85,108,10,74,176,29,0,12,0,119,31,111,
		36,90,0,176,30,0,20,0,36,91,0,85,108,12,
		74,176,31,0,109,32,0,109,21,0,72,108,10,87,
		20,72,12,1,119,31,61,36,92,0,85,108,12,74,
		176,33,0,12,0,119,28,46,36,93,0,109,32,0,
		108,12,76,34,36,94,0,108,10,87,20,108,12,76,
		20,36,95,0,109,21,0,108,12,76,22,36,96,0,
		85,108,12,74,176,35,0,20,0,74,36,99,0,85,
		108,10,74,176,36,0,20,0,74,25,134,36,103,0,
		85,108,12,74,176,37,0,20,0,74,36,104,0,109,
		3,0,29,168,0,36,105,0,85,108,12,74,176,38,
		0,106,7,81,80,82,79,71,83,0,90,6,109,22,
		0,6,106,5,80,114,111,103,0,20,3,74,36,106,
		0,85,108,12,74,176,31,0,109,32,0,109,19,0,
		72,20,1,74,36,107,0,106,9,80,114,111,103,47,
		79,112,99,0,80,1,36,108,0,106,37,108,101,102,
		116,40,81,80,82,79,71,83,45,62,68,101,115,99,
		114,105,99,97,111,44,52,52,41,47,68,101,115,99,
		114,105,135,132,111,0,80,2,36,109,0,106,40,88,
		69,77,80,82,69,83,65,61,61,69,109,112,114,101,
		115,97,32,46,97,110,100,46,32,99,85,83,82,78,
		85,77,61,61,85,115,114,110,117,109,0,80,3,26,
		153,0,36,111,0,85,108,12,74,176,38,0,106,7,
		81,85,83,69,82,83,0,90,6,109,20,0,6,106,
		7,85,115,114,110,117,109,0,20,3,74,36,112,0,
		85,108,12,74,176,31,0,109,32,0,109,21,0,72,
		20,1,74,36,113,0,106,11,85,115,114,110,117,109,
		47,85,115,114,0,80,1,36,114,0,106,25,121,112,
		101,114,109,105,100,116,40,41,47,73,100,101,110,116,
		105,102,105,99,97,135,132,111,0,80,2,36,115,0,
		106,36,88,69,77,80,82,69,83,65,61,61,69,109,
		112,114,101,115,97,32,46,97,110,100,46,32,99,80,
		82,79,71,61,61,80,114,111,103,0,80,3,36,126,
		0,85,108,12,74,176,14,0,95,1,85,108,12,74,
		176,39,0,12,0,119,4,2,0,95,2,121,4,2,
		0,106,7,65,99,101,115,115,111,0,121,4,2,0,
		106,5,68,105,97,115,0,121,4,2,0,106,8,72,
		111,114,97,114,105,111,0,121,4,2,0,4,5,0,
		106,2,67,0,100,106,4,121,112,120,0,100,100,4,
		4,0,95,3,90,8,176,40,0,12,0,6,90,8,
		176,41,0,12,0,6,4,3,0,106,64,65,99,101,
		115,115,111,115,58,32,88,44,73,44,65,44,67,44,
		69,44,49,126,55,32,47,32,60,72,62,111,114,97,
		114,105,111,32,60,76,62,105,98,101,114,97,32,60,
		66,62,108,111,113,117,101,105,97,32,60,79,62,117,
		116,114,111,115,0,20,5,74,36,128,0,85,108,12,
		74,176,37,0,20,0,74,36,129,0,109,3,0,28,
		16,85,108,10,74,176,42,0,95,4,20,1,74,25,
		14,85,108,16,74,176,42,0,95,4,20,1,74,36,
		131,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPERMIDT )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,137,0,176,43,0,108,10,87,44,12,
		1,80,1,36,138,0,176,45,0,95,1,92,11,92,
		10,12,3,106,2,47,0,72,176,46,0,95,1,92,
		30,12,2,72,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPTOP )
{
	static const HB_BYTE pcode[] =
	{
		36,144,0,109,3,0,28,24,36,145,0,85,108,12,
		74,176,31,0,109,32,0,109,19,0,72,20,1,74,
		25,22,36,147,0,85,108,12,74,176,31,0,109,32,
		0,109,21,0,72,20,1,74,36,149,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPBOT )
{
	static const HB_BYTE pcode[] =
	{
		36,155,0,109,3,0,28,24,36,156,0,85,108,12,
		74,176,47,0,109,32,0,109,19,0,72,20,1,74,
		25,22,36,158,0,85,108,12,74,176,47,0,109,32,
		0,109,21,0,72,20,1,74,36,160,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPX )
{
	static const HB_BYTE pcode[] =
	{
		13,3,1,36,166,0,176,49,0,108,12,87,50,12,
		1,80,2,36,167,0,176,49,0,108,12,87,51,12,
		1,80,3,36,168,0,108,12,87,52,80,4,36,170,
		0,176,53,0,176,54,0,95,1,12,1,12,1,80,
		1,36,172,0,95,1,106,2,79,0,8,28,14,36,
		173,0,176,55,0,20,0,36,174,0,7,36,178,0,
		95,1,106,8,49,50,51,52,53,54,55,0,24,28,
		14,176,56,0,95,3,12,1,80,3,26,210,1,36,
		179,0,95,1,106,2,72,0,8,28,14,176,57,0,
		95,4,12,1,80,4,26,186,1,36,180,0,95,1,
		106,2,88,0,8,28,22,106,2,88,0,95,2,24,
		31,13,96,2,0,106,2,88,0,135,26,154,1,36,
		181,0,95,1,106,2,73,0,8,28,22,106,2,73,
		0,95,2,24,31,13,96,2,0,106,2,73,0,135,
		26,122,1,36,182,0,95,1,106,2,65,0,8,28,
		22,106,2,65,0,95,2,24,31,13,96,2,0,106,
		2,65,0,135,26,90,1,36,183,0,95,1,106,2,
		67,0,8,28,22,106,2,67,0,95,2,24,31,13,
		96,2,0,106,2,67,0,135,26,58,1,36,184,0,
		95,1,106,2,69,0,8,28,22,106,2,69,0,95,
		2,24,31,13,96,2,0,106,2,69,0,135,26,26,
		1,36,185,0,95,1,106,2,88,0,8,28,30,106,
		2,88,0,95,2,24,28,21,176,58,0,95,2,106,
		2,88,0,106,1,0,12,3,80,2,26,242,0,36,
		186,0,95,1,106,2,73,0,8,28,30,106,2,73,
		0,95,2,24,28,21,176,58,0,95,2,106,2,73,
		0,106,1,0,12,3,80,2,26,202,0,36,187,0,
		95,1,106,2,65,0,8,28,30,106,2,65,0,95,
		2,24,28,21,176,58,0,95,2,106,2,65,0,106,
		1,0,12,3,80,2,26,162,0,36,188,0,95,1,
		106,2,67,0,8,28,29,106,2,67,0,95,2,24,
		28,20,176,58,0,95,2,106,2,67,0,106,1,0,
		12,3,80,2,25,122,36,189,0,95,1,106,2,69,
		0,8,28,29,106,2,69,0,95,2,24,28,20,176,
		58,0,95,2,106,2,69,0,106,1,0,12,3,80,
		2,25,83,36,190,0,95,1,106,2,76,0,8,28,
		45,36,191,0,106,6,88,73,65,67,69,0,80,2,
		36,192,0,106,8,49,50,51,52,53,54,55,0,80,
		3,36,193,0,106,6,48,48,126,50,52,0,80,4,
		25,28,36,194,0,95,1,106,2,66,0,8,28,16,
		36,195,0,106,1,0,165,80,4,165,80,3,80,2,
		36,197,0,85,108,12,74,176,59,0,12,0,119,28,
		42,36,198,0,95,2,108,12,76,50,36,199,0,95,
		3,108,12,76,51,36,200,0,95,4,108,12,76,52,
		36,201,0,85,108,12,74,176,35,0,20,0,74,36,
		203,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPERMDIAS )
{
	static const HB_BYTE pcode[] =
	{
		13,3,1,36,206,0,176,54,0,176,60,0,12,0,
		12,1,80,3,36,207,0,106,1,0,80,4,36,208,
		0,95,3,95,1,24,28,21,36,209,0,176,58,0,
		95,1,95,3,106,1,0,12,3,80,1,25,11,36,
		211,0,96,1,0,95,3,135,36,213,0,122,165,80,
		2,25,39,36,214,0,176,61,0,95,2,122,12,2,
		95,1,24,28,17,36,215,0,96,4,0,176,61,0,
		95,2,122,12,2,135,36,213,0,175,2,0,92,7,
		15,28,216,36,218,0,95,4,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPH )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,221,0,176,62,0,92,24,121,92,24,
		92,79,12,4,80,2,36,222,0,176,24,0,106,28,
		68,105,103,105,116,101,32,111,32,104,111,114,97,114,
		105,111,32,100,101,32,97,99,101,115,115,111,58,0,
		20,1,36,223,0,176,63,0,92,24,92,39,96,1,
		0,106,6,57,57,126,57,57,0,20,4,36,224,0,
		176,64,0,92,24,121,95,2,20,3,36,225,0,95,
		1,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPO )
{
	static const HB_BYTE pcode[] =
	{
		13,2,0,36,231,0,176,1,0,106,9,80,87,95,
		67,70,71,65,67,0,109,2,0,106,11,81,83,66,
		76,79,67,46,71,76,79,0,72,12,2,80,2,36,
		233,0,176,6,0,92,17,92,61,95,2,12,3,80,
		1,36,236,0,95,1,106,2,76,0,8,28,13,176,
		65,0,106,2,76,0,20,1,25,92,36,237,0,95,
		1,106,2,66,0,8,28,13,176,65,0,106,2,66,
		0,20,1,25,69,36,238,0,95,1,106,2,65,0,
		8,28,13,176,66,0,106,2,65,0,20,1,25,46,
		36,239,0,95,1,106,2,68,0,8,28,13,176,66,
		0,106,2,68,0,20,1,25,23,36,240,0,95,1,
		106,2,72,0,8,28,11,176,66,0,106,2,72,0,
		20,1,36,243,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPTOTAL )
{
	static const HB_BYTE pcode[] =
	{
		13,2,1,36,249,0,95,1,106,2,76,0,8,28,
		16,106,10,108,105,98,101,114,97,135,132,111,0,25,
		13,106,9,98,108,111,113,117,101,105,111,0,80,2,
		36,250,0,85,108,12,74,176,18,0,12,0,119,80,
		3,36,251,0,176,67,0,106,10,67,111,110,102,105,
		114,109,97,32,0,95,2,72,106,9,32,116,111,116,
		97,108,32,63,0,72,12,1,29,212,0,36,252,0,
		176,24,0,106,21,65,103,117,97,114,100,101,44,32,
		114,101,97,108,105,122,97,110,100,111,32,0,95,2,
		72,106,10,32,116,111,116,97,108,46,46,46,0,72,
		20,1,36,253,0,176,40,0,20,0,36,254,0,109,
		23,0,40,11,29,146,0,36,255,0,176,30,0,20,
		0,36,0,1,85,108,12,74,176,59,0,12,0,119,
		28,106,36,1,1,95,1,106,2,76,0,8,28,51,
		36,2,1,106,6,88,73,65,67,69,0,108,12,76,
		50,36,3,1,106,8,49,50,51,52,53,54,55,0,
		108,12,76,51,36,4,1,106,6,48,48,126,50,52,
		0,108,12,76,52,25,32,36,6,1,106,1,0,108,
		12,76,50,36,7,1,106,1,0,108,12,76,51,36,
		8,1,106,1,0,108,12,76,52,36,10,1,85,108,
		12,74,176,35,0,20,0,74,36,12,1,85,108,12,
		74,176,36,0,20,0,74,26,105,255,36,15,1,85,
		108,12,74,176,42,0,95,3,20,1,74,36,16,1,
		7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YPCONFIG )
{
	static const HB_BYTE pcode[] =
	{
		13,2,1,36,22,1,85,108,12,74,176,18,0,12,
		0,119,80,3,36,24,1,95,1,106,2,65,0,8,
		28,69,36,25,1,108,12,87,50,80,2,36,26,1,
		176,24,0,106,25,68,105,103,105,116,101,32,111,32,
		116,105,112,111,32,100,101,32,97,99,101,115,115,111,
		58,0,20,1,36,27,1,176,63,0,92,24,92,36,
		96,2,0,106,3,64,33,0,20,4,26,164,0,36,
		28,1,95,1,106,2,68,0,8,28,69,36,29,1,
		108,12,87,51,80,2,36,30,1,176,24,0,106,26,
		68,105,103,105,116,101,32,111,115,32,100,105,97,115,
		32,100,101,32,97,99,101,115,115,111,58,0,20,1,
		36,31,1,176,63,0,92,24,92,37,96,2,0,106,
		3,64,57,0,20,4,25,84,36,32,1,95,1,106,
		2,72,0,8,28,72,36,33,1,108,12,87,52,80,
		2,36,34,1,176,24,0,106,28,68,105,103,105,116,
		101,32,111,32,104,111,114,97,114,105,111,32,100,101,
		32,97,99,101,115,115,111,58,0,20,1,36,35,1,
		176,63,0,92,24,92,39,96,2,0,106,6,57,57,
		126,57,57,0,20,4,36,37,1,176,67,0,106,27,
		67,111,110,102,105,114,109,97,32,97,108,116,101,114,
		97,135,132,111,32,116,111,116,97,108,32,63,0,12,
		1,29,179,0,36,38,1,176,24,0,106,39,65,103,
		117,97,114,100,101,44,32,114,101,97,108,105,122,97,
		110,100,111,32,97,108,116,101,114,97,135,132,111,32,
		116,111,116,97,108,46,46,46,0,20,1,36,39,1,
		176,40,0,20,0,36,40,1,109,23,0,40,11,28,
		111,36,41,1,176,30,0,20,0,36,42,1,85,108,
		12,74,176,59,0,12,0,119,28,73,36,44,1,95,
		1,106,2,65,0,8,28,10,95,2,108,12,76,50,
		25,40,36,45,1,95,1,106,2,68,0,8,28,10,
		95,2,108,12,76,51,25,20,36,46,1,95,1,106,
		2,72,0,8,28,8,95,2,108,12,76,52,36,48,
		1,85,108,12,74,176,35,0,20,0,74,36,50,1,
		85,108,12,74,176,36,0,20,0,74,25,139,36,53,
		1,85,108,12,74,176,42,0,95,3,20,1,74,36,
		54,1,7
	};

	hb_vmExecute( pcode, symbols );
}

