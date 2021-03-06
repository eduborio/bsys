/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QAD_MANU.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QAD_MANU );
HB_FUNC_EXTERN( DBSELECTAREA );
HB_FUNC_EXTERN( QVIEW );
HB_FUNC( YMANU1 );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( QDECRI );
HB_FUNC( YMANUW );
HB_FUNC_EXTERN( UPPER );
HB_FUNC_EXTERN( CHR );
HB_FUNC( YMANUB );
HB_FUNC( YMANUD );
HB_FUNC( YMANUI );
HB_FUNC( YMANUA );
HB_FUNC( YMANUE );
HB_FUNC_EXTERN( QLBLOC );
HB_FUNC_EXTERN( QSAY );
HB_FUNC_EXTERN( RIGHT );
HB_FUNC_EXTERN( QCONF );
HB_FUNC_EXTERN( QRLOCK );
HB_FUNC_EXTERN( DATE );
HB_FUNC_EXTERN( TIME );
HB_FUNC_EXTERN( QUNLOCK );
HB_FUNC_EXTERN( SPACE );
HB_FUNC_EXTERN( DBGOTO );
HB_FUNC_EXTERN( LASTREC );
HB_FUNC_EXTERN( STRZERO );
HB_FUNC_EXTERN( VAL );
HB_FUNC_EXTERN( QMENSA );
HB_FUNC_EXTERN( QGETX );
HB_FUNC_EXTERN( QAPPEND );
HB_FUNC_EXTERN( QENCRI );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( ALERT );
HB_FUNC_EXTERN( DBDELETE );
HB_FUNC( QAD_CHK_IDT );
HB_FUNC_EXTERN( RECNO );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( DBGOTOP );
HB_FUNC_EXTERN( __DBLOCATE );
HB_FUNC_EXTERN( EOF );
HB_FUNC( QAD_CHK_SEN );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QAD_MANU )
{ "QAD_MANU", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QAD_MANU )}, NULL },
{ "DBSELECTAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSELECTAREA )}, NULL },
{ "QVIEW", {HB_FS_PUBLIC}, {HB_FUNCNAME( QVIEW )}, NULL },
{ "YMANU1", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YMANU1 )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "QDECRI", {HB_FS_PUBLIC}, {HB_FUNCNAME( QDECRI )}, NULL },
{ "QUSERS", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "IDENTIFIC", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "YMANUW", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YMANUW )}, NULL },
{ "UPPER", {HB_FS_PUBLIC}, {HB_FUNCNAME( UPPER )}, NULL },
{ "CHR", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHR )}, NULL },
{ "YMANUB", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YMANUB )}, NULL },
{ "YMANUD", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YMANUD )}, NULL },
{ "YMANUI", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YMANUI )}, NULL },
{ "YMANUA", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YMANUA )}, NULL },
{ "YMANUE", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( YMANUE )}, NULL },
{ "QLBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QLBLOC )}, NULL },
{ "XDRV_SH", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QSAY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSAY )}, NULL },
{ "RIGHT", {HB_FS_PUBLIC}, {HB_FUNCNAME( RIGHT )}, NULL },
{ "QCONF", {HB_FS_PUBLIC}, {HB_FUNCNAME( QCONF )}, NULL },
{ "QRLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRLOCK )}, NULL },
{ "PROG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "EMPRESA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( DATE )}, NULL },
{ "DATALOG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "TIME", {HB_FS_PUBLIC}, {HB_FUNCNAME( TIME )}, NULL },
{ "INICIO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QUNLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUNLOCK )}, NULL },
{ "SPACE", {HB_FS_PUBLIC}, {HB_FUNCNAME( SPACE )}, NULL },
{ "DBGOTO", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBGOTO )}, NULL },
{ "LASTREC", {HB_FS_PUBLIC}, {HB_FUNCNAME( LASTREC )}, NULL },
{ "STRZERO", {HB_FS_PUBLIC}, {HB_FUNCNAME( STRZERO )}, NULL },
{ "VAL", {HB_FS_PUBLIC}, {HB_FUNCNAME( VAL )}, NULL },
{ "USRNUM", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QMENSA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QMENSA )}, NULL },
{ "QGETX", {HB_FS_PUBLIC}, {HB_FUNCNAME( QGETX )}, NULL },
{ "QAPPEND", {HB_FS_PUBLIC}, {HB_FUNCNAME( QAPPEND )}, NULL },
{ "QENCRI", {HB_FS_PUBLIC}, {HB_FUNCNAME( QENCRI )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "ALERT", {HB_FS_PUBLIC}, {HB_FUNCNAME( ALERT )}, NULL },
{ "DBDELETE", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBDELETE )}, NULL },
{ "QAD_CHK_IDT", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QAD_CHK_IDT )}, NULL },
{ "RECNO", {HB_FS_PUBLIC}, {HB_FUNCNAME( RECNO )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "DBGOTOP", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBGOTOP )}, NULL },
{ "__DBLOCATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( __DBLOCATE )}, NULL },
{ "EOF", {HB_FS_PUBLIC}, {HB_FUNCNAME( EOF )}, NULL },
{ "QAD_CHK_SEN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QAD_CHK_SEN )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QAD_MANU, "QAD_MANU.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QAD_MANU
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QAD_MANU )
   #include "hbiniseg.h"
#endif

HB_FUNC( QAD_MANU )
{
	static const HB_BYTE pcode[] =
	{
		36,7,0,176,1,0,106,7,81,85,83,69,82,83,
		0,20,1,36,18,0,176,2,0,106,18,121,109,97,
		110,117,49,40,41,47,73,100,101,110,116,105,102,46,
		0,122,4,2,0,106,10,85,115,114,110,117,109,47,
		78,167,0,92,2,4,2,0,106,15,65,109,98,95,
		79,114,105,103,47,79,114,105,103,46,0,121,4,2,
		0,106,15,65,109,98,95,84,114,97,98,47,84,114,
		97,98,46,0,121,4,2,0,106,15,80,114,111,103,
		47,67,162,100,46,80,114,111,103,46,0,121,4,2,
		0,106,12,69,109,112,114,101,115,97,47,69,109,112,
		0,121,4,2,0,106,13,68,97,116,97,108,111,103,
		47,68,97,116,97,0,121,4,2,0,106,20,73,110,
		105,99,105,111,47,73,110,105,99,105,111,32,65,116,
		105,118,46,0,121,4,2,0,4,8,0,106,2,67,
		0,100,106,7,121,109,97,110,117,119,0,100,100,4,
		4,0,100,106,59,60,66,62,108,111,113,117,101,105,
		111,44,32,60,68,62,101,115,98,108,111,113,117,101,
		105,111,44,32,60,73,62,110,99,108,117,105,114,44,
		32,60,65,62,108,116,101,114,97,114,44,32,60,69,
		62,120,99,108,117,105,114,0,20,5,36,20,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YMANU1 )
{
	static const HB_BYTE pcode[] =
	{
		36,23,0,176,4,0,176,5,0,108,6,87,7,12,
		1,92,11,92,10,20,3,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YMANUW )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,26,0,176,9,0,176,10,0,95,1,
		12,1,12,1,80,1,36,28,0,95,1,106,2,66,
		0,8,28,9,176,11,0,20,0,25,76,36,29,0,
		95,1,106,2,68,0,8,28,9,176,12,0,20,0,
		25,57,36,30,0,95,1,106,2,73,0,8,28,9,
		176,13,0,20,0,25,38,36,31,0,95,1,106,2,
		65,0,8,28,9,176,14,0,20,0,25,19,36,32,
		0,95,1,106,2,69,0,8,28,7,176,15,0,20,
		0,36,34,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YMANUB )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,37,0,176,5,0,108,6,87,7,12,
		1,80,1,36,38,0,176,16,0,92,19,121,106,8,
		80,87,95,85,83,69,82,0,109,17,0,106,11,81,
		83,66,76,79,67,46,71,76,79,0,72,20,4,36,
		39,0,176,18,0,92,20,92,17,176,4,0,95,1,
		92,11,92,10,12,3,20,3,36,40,0,176,18,0,
		92,22,92,17,176,19,0,95,1,92,30,12,2,20,
		3,36,41,0,176,20,0,106,34,67,111,110,102,105,
		114,109,97,32,98,108,111,113,117,101,105,111,32,100,
		101,115,116,101,32,117,115,117,97,114,105,111,32,63,
		0,12,1,28,77,36,42,0,85,108,6,74,176,21,
		0,12,0,119,28,62,36,43,0,106,4,65,68,77,
		0,108,6,76,22,36,44,0,106,1,0,108,6,76,
		23,36,45,0,176,24,0,12,0,108,6,76,25,36,
		46,0,176,26,0,12,0,108,6,76,27,36,47,0,
		85,108,6,74,176,28,0,20,0,74,36,50,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YMANUD )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,53,0,176,5,0,108,6,87,7,12,
		1,80,1,36,54,0,176,16,0,92,19,121,106,8,
		80,87,95,85,83,69,82,0,109,17,0,106,11,81,
		83,66,76,79,67,46,71,76,79,0,72,20,4,36,
		55,0,176,18,0,92,20,92,17,176,4,0,95,1,
		92,11,92,10,12,3,20,3,36,56,0,176,18,0,
		92,22,92,17,176,19,0,95,1,92,30,12,2,20,
		3,36,57,0,176,20,0,106,37,67,111,110,102,105,
		114,109,97,32,100,101,115,98,108,111,113,117,101,105,
		111,32,100,101,115,116,101,32,117,115,117,97,114,105,
		111,32,63,0,12,1,28,72,36,58,0,85,108,6,
		74,176,21,0,12,0,119,28,57,36,59,0,106,1,
		0,108,6,76,22,36,60,0,106,1,0,108,6,76,
		23,36,61,0,134,0,0,0,0,108,6,76,25,36,
		62,0,106,1,0,108,6,76,27,36,63,0,85,108,
		6,74,176,28,0,20,0,74,36,66,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YMANUI )
{
	static const HB_BYTE pcode[] =
	{
		13,4,0,36,69,0,176,29,0,92,10,12,1,80,
		1,36,70,0,176,29,0,92,10,12,1,80,2,36,
		71,0,176,29,0,92,30,12,1,80,3,36,73,0,
		85,108,6,74,176,30,0,176,31,0,12,0,20,1,
		74,36,74,0,176,32,0,176,33,0,108,6,87,34,
		12,1,122,72,92,3,12,2,80,4,36,75,0,176,
		16,0,92,19,121,106,8,80,87,95,85,83,69,82,
		0,109,17,0,106,11,81,83,66,76,79,67,46,71,
		76,79,0,72,20,4,36,76,0,176,35,0,106,43,
		69,110,116,114,101,32,99,111,109,32,111,115,32,100,
		97,100,111,115,32,112,97,114,97,32,105,110,99,108,
		117,105,114,32,117,115,117,97,114,105,111,46,46,46,
		0,20,1,36,77,0,176,36,0,92,20,92,17,96,
		1,0,106,3,64,33,0,106,17,113,97,100,95,99,
		104,107,95,105,100,116,40,64,44,48,41,0,20,5,
		36,78,0,176,36,0,92,21,92,17,96,2,0,106,
		3,64,33,0,106,17,113,97,100,95,99,104,107,95,
		115,101,110,40,64,44,48,41,0,20,5,36,79,0,
		176,36,0,92,22,92,17,96,3,0,106,3,64,33,
		0,106,10,33,101,109,112,116,121,40,64,41,0,20,
		5,36,80,0,176,20,0,106,34,67,111,110,102,105,
		114,109,97,32,105,110,99,108,117,115,132,111,32,100,
		101,115,116,101,32,117,115,117,97,114,105,111,32,63,
		0,12,1,28,59,36,81,0,85,108,6,74,176,37,
		0,12,0,119,28,44,36,82,0,176,38,0,95,2,
		95,1,72,95,3,72,12,1,108,6,76,7,36,83,
		0,95,4,108,6,76,34,36,84,0,85,108,6,74,
		176,28,0,20,0,74,36,87,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YMANUA )
{
	static const HB_BYTE pcode[] =
	{
		13,4,0,36,90,0,176,5,0,108,6,87,7,12,
		1,80,1,36,91,0,176,4,0,95,1,92,11,92,
		10,12,3,80,2,36,92,0,176,39,0,95,1,92,
		10,12,2,80,3,36,93,0,176,19,0,95,1,92,
		30,12,2,80,4,36,94,0,176,16,0,92,19,121,
		106,8,80,87,95,85,83,69,82,0,109,17,0,106,
		11,81,83,66,76,79,67,46,71,76,79,0,72,20,
		4,36,95,0,176,18,0,92,21,92,17,95,3,20,
		3,36,96,0,176,18,0,92,22,92,17,95,4,20,
		3,36,97,0,176,35,0,106,37,82,101,97,108,105,
		122,101,32,97,115,32,97,108,116,101,114,97,135,148,
		101,115,32,110,101,99,101,115,115,97,114,105,97,115,
		46,46,46,0,20,1,36,98,0,176,36,0,92,20,
		92,17,96,2,0,106,3,64,33,0,106,23,113,97,
		100,95,99,104,107,95,105,100,116,40,64,44,114,101,
		99,110,111,40,41,41,0,20,5,36,99,0,176,36,
		0,92,21,92,17,96,3,0,106,3,64,33,0,106,
		23,113,97,100,95,99,104,107,95,115,101,110,40,64,
		44,114,101,99,110,111,40,41,41,0,20,5,36,100,
		0,176,36,0,92,22,92,17,96,4,0,106,3,64,
		33,0,106,10,33,101,109,112,116,121,40,64,41,0,
		20,5,36,101,0,176,20,0,106,35,67,111,110,102,
		105,114,109,97,32,97,108,116,101,114,97,135,132,111,
		32,100,101,115,116,101,32,117,115,117,97,114,105,111,
		32,63,0,12,1,28,50,36,102,0,85,108,6,74,
		176,21,0,12,0,119,28,35,36,103,0,176,38,0,
		95,3,95,2,72,95,4,72,12,1,108,6,76,7,
		36,104,0,85,108,6,74,176,28,0,20,0,74,36,
		107,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( YMANUE )
{
	static const HB_BYTE pcode[] =
	{
		13,1,0,36,110,0,176,5,0,108,6,87,7,12,
		1,80,1,36,111,0,176,16,0,92,19,121,106,8,
		80,87,95,85,83,69,82,0,109,17,0,106,11,81,
		83,66,76,79,67,46,71,76,79,0,72,20,4,36,
		112,0,176,18,0,92,20,92,17,176,4,0,95,1,
		92,11,92,10,12,3,20,3,36,113,0,176,18,0,
		92,22,92,17,176,19,0,95,1,92,30,12,2,20,
		3,36,114,0,176,40,0,106,34,67,79,78,70,73,
		82,77,65,32,69,88,67,76,85,83,142,79,32,68,
		69,83,84,69,32,85,83,85,65,82,73,79,32,63,
		0,106,4,78,142,79,0,106,4,83,73,77,0,4,
		2,0,12,2,92,2,69,28,6,36,115,0,7,36,
		117,0,176,20,0,106,45,70,97,118,111,114,32,114,
		101,99,111,110,102,105,114,109,97,114,32,97,32,101,
		120,99,108,117,115,132,111,32,100,101,115,116,101,32,
		117,115,117,97,114,105,111,32,63,0,12,1,28,56,
		36,118,0,85,108,6,74,176,21,0,12,0,119,28,
		41,36,119,0,106,4,64,64,64,0,108,6,76,22,
		36,120,0,85,108,6,74,176,41,0,20,0,74,36,
		121,0,85,108,6,74,176,28,0,20,0,74,36,124,
		0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QAD_CHK_IDT )
{
	static const HB_BYTE pcode[] =
	{
		13,2,2,36,127,0,176,43,0,12,0,80,3,120,
		80,4,36,128,0,176,44,0,95,1,12,1,28,5,
		9,110,7,36,129,0,176,45,0,20,0,36,130,0,
		176,46,0,89,31,0,0,0,1,0,1,0,176,4,
		0,176,5,0,108,6,87,7,12,1,92,11,92,10,
		12,3,95,255,8,6,100,100,100,9,20,5,36,131,
		0,85,108,6,74,176,47,0,12,0,119,31,85,95,
		2,85,108,6,74,176,43,0,12,0,119,69,28,70,
		36,132,0,176,35,0,106,48,73,100,101,110,116,105,
		102,105,99,97,135,132,111,32,106,160,32,117,116,105,
		108,105,122,97,100,97,32,112,111,114,32,111,117,116,
		114,111,32,117,115,117,97,114,105,111,46,46,46,0,
		106,2,66,0,20,2,36,133,0,9,80,4,36,135,
		0,85,108,6,74,176,30,0,95,3,20,1,74,36,
		136,0,95,4,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QAD_CHK_SEN )
{
	static const HB_BYTE pcode[] =
	{
		13,2,2,36,139,0,176,43,0,12,0,80,3,120,
		80,4,36,140,0,176,44,0,95,1,12,1,28,5,
		9,110,7,36,141,0,176,45,0,20,0,36,142,0,
		176,46,0,89,29,0,0,0,1,0,1,0,176,39,
		0,176,5,0,108,6,87,7,12,1,92,10,12,2,
		95,255,8,6,100,100,100,9,20,5,36,143,0,85,
		108,6,74,176,47,0,12,0,119,31,77,95,2,85,
		108,6,74,176,43,0,12,0,119,69,28,62,36,144,
		0,176,35,0,106,40,83,101,110,104,97,32,106,160,
		32,117,116,105,108,105,122,97,100,97,32,112,111,114,
		32,111,117,116,114,111,32,117,115,117,97,114,105,111,
		46,46,46,0,106,2,66,0,20,2,36,145,0,9,
		80,4,36,147,0,85,108,6,74,176,30,0,95,3,
		20,1,74,36,148,0,95,4,110,7
	};

	hb_vmExecute( pcode, symbols );
}

