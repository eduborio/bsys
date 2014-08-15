/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "Q198.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( Q198 );
HB_FUNC_EXTERN( QUSE );
HB_FUNC_EXTERN( QVIEW );
HB_FUNC_EXTERN( DBCLOSEAREA );
HB_FUNC( C198A );
HB_FUNC_EXTERN( SETCURSOR );
HB_FUNC_EXTERN( UPPER );
HB_FUNC_EXTERN( CHR );
HB_FUNC_EXTERN( QLBLOC );
HB_FUNC_EXTERN( QMENSA );
HB_FUNC_EXTERN( QABREV );
HB_FUNC_STATIC( I_EDICAO );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( QRSAY );
HB_FUNC_EXTERN( QWAIT );
HB_FUNC_STATIC( I_EXCLUSAO );
HB_FUNC_EXTERN( AADD );
HB_FUNC_EXTERN( QGETX );
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
HB_FUNC_EXTERN( DBSEEK );
HB_FUNC_EXTERN( DBDELETE );
HB_FUNC_EXTERN( QM3 );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_Q198 )
{ "Q198", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( Q198 )}, NULL },
{ "QUSE", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUSE )}, NULL },
{ "XDRV_SH", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "CGM", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "QVIEW", {HB_FS_PUBLIC}, {HB_FUNCNAME( QVIEW )}, NULL },
{ "DBCLOSEAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBCLOSEAREA )}, NULL },
{ "C198A", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( C198A )}, NULL },
{ "SETCURSOR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETCURSOR )}, NULL },
{ "COPCAO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "UPPER", {HB_FS_PUBLIC}, {HB_FUNCNAME( UPPER )}, NULL },
{ "CHR", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHR )}, NULL },
{ "XUSRA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QLBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QLBLOC )}, NULL },
{ "QMENSA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QMENSA )}, NULL },
{ "QABREV", {HB_FS_PUBLIC}, {HB_FUNCNAME( QABREV )}, NULL },
{ "I_EDICAO", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_EDICAO )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "FCODIGO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XNIVEL", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XFLAG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QRSAY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRSAY )}, NULL },
{ "CODIGO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "MUNICIPIO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "ESTADO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "CEP", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DDD", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DISTANCIA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "COD_RAIS", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "COD_ICMS", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QWAIT", {HB_FS_PUBLIC}, {HB_FUNCNAME( QWAIT )}, NULL },
{ "I_EXCLUSAO", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_EXCLUSAO )}, NULL },
{ "AADD", {HB_FS_PUBLIC}, {HB_FUNCNAME( AADD )}, NULL },
{ "QGETX", {HB_FS_PUBLIC}, {HB_FUNCNAME( QGETX )}, NULL },
{ "FMUNICIPIO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "FESTADO", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "FCEP", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "FDDD", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "FDISTANCIA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "FCOD_RAIS", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "FCOD_ICMS", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
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
{ "DBSEEK", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSEEK )}, NULL },
{ "DBDELETE", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBDELETE )}, NULL },
{ "QM3", {HB_FS_PUBLIC}, {HB_FUNCNAME( QM3 )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_Q198, "Q198.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_Q198
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_Q198 )
   #include "hbiniseg.h"
#endif

HB_FUNC( Q198 )
{
	static const HB_BYTE pcode[] =
	{
		36,6,0,176,1,0,109,2,0,106,4,67,71,77,
		0,106,8,67,71,77,95,67,79,68,0,106,8,67,
		71,77,95,77,85,78,0,4,2,0,12,3,31,5,
		9,110,7,36,16,0,85,108,3,74,176,4,0,106,
		14,67,111,100,105,103,111,47,67,162,100,105,103,111,
		0,122,4,2,0,106,10,77,117,110,105,99,105,112,
		105,111,0,92,2,4,2,0,106,7,69,115,116,97,
		100,111,0,121,4,2,0,106,38,116,114,97,110,115,
		102,111,114,109,40,67,101,112,44,39,64,82,32,57,
		57,46,57,57,57,45,57,57,57,39,41,47,67,46,
		101,46,112,46,0,121,4,2,0,106,4,68,68,68,
		0,121,4,2,0,4,5,0,106,2,80,0,100,106,
		6,99,49,57,56,97,0,100,100,4,4,0,100,106,
		48,60,69,83,67,62,44,32,65,76,84,45,79,44,
		32,65,76,84,45,80,44,32,60,73,62,110,99,44,
		32,60,65,62,108,116,44,32,60,67,62,111,110,44,
		32,60,69,62,120,99,0,20,5,74,36,18,0,85,
		108,3,74,176,5,0,20,0,74,36,20,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( C198A )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,26,0,176,7,0,122,12,1,80,2,
		71,8,0,1,36,28,0,176,9,0,176,10,0,109,
		8,0,12,1,12,1,83,8,0,36,29,0,109,8,
		0,109,11,0,106,5,73,65,67,69,0,72,24,28,
		101,36,30,0,176,12,0,92,13,92,11,106,6,66,
		49,57,56,65,0,109,2,0,106,11,81,83,66,76,
		79,67,46,71,76,79,0,72,122,20,5,36,31,0,
		176,13,0,176,14,0,109,8,0,106,3,73,65,0,
		106,12,73,110,99,108,117,115,132,111,46,46,46,0,
		106,13,65,108,116,101,114,97,135,132,111,46,46,46,
		0,4,2,0,12,3,20,1,36,32,0,176,15,0,
		20,0,36,34,0,176,7,0,95,2,20,1,36,35,
		0,106,1,0,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_EDICAO )
{
	static const HB_BYTE pcode[] =
	{
		13,3,0,36,42,0,4,0,0,80,2,36,44,0,
		90,58,176,16,0,109,17,0,12,1,21,31,46,73,
		109,18,0,122,8,21,28,10,73,109,19,0,68,21,
		31,29,73,109,18,0,92,2,8,21,28,19,73,109,
		8,0,106,2,65,0,8,21,28,7,73,109,19,0,
		68,6,80,3,36,48,0,109,8,0,106,2,73,0,
		69,29,193,0,36,49,0,122,83,18,0,36,50,0,
		176,20,0,109,18,0,21,23,83,18,0,108,3,87,
		21,20,2,36,51,0,176,20,0,109,18,0,21,23,
		83,18,0,108,3,87,22,20,2,36,52,0,176,20,
		0,109,18,0,21,23,83,18,0,108,3,87,23,20,
		2,36,53,0,176,20,0,109,18,0,21,23,83,18,
		0,108,3,87,24,106,14,64,82,32,57,57,46,57,
		57,57,45,57,57,57,0,20,3,36,54,0,176,20,
		0,109,18,0,21,23,83,18,0,108,3,87,25,20,
		2,36,55,0,176,20,0,109,18,0,21,23,83,18,
		0,108,3,87,26,106,5,57,57,57,57,0,20,3,
		36,56,0,176,20,0,109,18,0,21,23,83,18,0,
		108,3,87,27,20,2,36,57,0,176,20,0,109,18,
		0,21,23,83,18,0,108,3,87,28,20,2,36,62,
		0,109,8,0,106,2,67,0,8,28,8,176,29,0,
		20,0,7,36,63,0,109,8,0,106,2,69,0,8,
		28,8,176,30,0,20,0,7,36,67,0,176,31,0,
		95,2,90,28,176,32,0,92,255,121,99,17,0,106,
		3,64,33,0,100,109,8,0,106,2,73,0,8,12,
		6,6,106,7,67,79,68,73,71,79,0,4,2,0,
		20,2,36,68,0,176,31,0,95,2,90,19,176,32,
		0,92,255,121,99,33,0,106,3,64,33,0,12,4,
		6,106,10,77,85,78,73,67,73,80,73,79,0,4,
		2,0,20,2,36,69,0,176,31,0,95,2,90,19,
		176,32,0,92,255,121,99,34,0,106,3,64,33,0,
		12,4,6,106,7,69,83,84,65,68,79,0,4,2,
		0,20,2,36,70,0,176,31,0,95,2,90,30,176,
		32,0,92,255,121,99,35,0,106,14,64,82,32,57,
		57,46,57,57,57,45,57,57,57,0,12,4,6,106,
		4,67,69,80,0,4,2,0,20,2,36,71,0,176,
		31,0,95,2,90,19,176,32,0,92,255,121,99,36,
		0,106,3,64,57,0,12,4,6,106,4,68,68,68,
		0,4,2,0,20,2,36,72,0,176,31,0,95,2,
		90,21,176,32,0,92,255,121,99,37,0,106,5,57,
		57,57,57,0,12,4,6,106,10,68,73,83,84,65,
		78,67,73,65,0,4,2,0,20,2,36,73,0,176,
		31,0,95,2,90,19,176,32,0,92,255,121,99,38,
		0,106,3,64,33,0,12,4,6,106,9,67,79,68,
		95,82,65,73,83,0,4,2,0,20,2,36,74,0,
		176,31,0,95,2,90,19,176,32,0,92,255,121,99,
		39,0,106,3,64,33,0,12,4,6,106,9,67,79,
		68,95,73,67,77,83,0,4,2,0,20,2,36,75,
		0,176,31,0,95,2,89,72,0,0,0,1,0,1,
		0,176,40,0,106,10,67,111,110,102,105,114,109,97,
		32,0,109,8,0,106,2,73,0,8,28,15,106,9,
		105,110,99,108,117,115,132,111,0,25,14,106,10,97,
		108,116,101,114,97,135,132,111,0,72,106,3,32,63,
		0,72,12,1,165,80,255,6,100,4,2,0,20,2,
		36,79,0,85,108,3,74,176,41,0,20,0,74,36,
		80,0,109,8,0,106,2,73,0,8,28,14,85,108,
		3,74,176,42,0,20,0,74,25,12,85,108,3,74,
		176,43,0,20,0,74,36,81,0,122,83,18,0,36,
		82,0,120,83,19,0,36,86,0,109,18,0,122,16,
		28,100,109,18,0,176,44,0,95,2,12,1,34,28,
		87,36,87,0,48,45,0,95,2,109,18,0,1,122,
		1,112,0,73,36,88,0,48,45,0,95,3,112,0,
		28,13,85,108,3,74,176,46,0,20,0,74,7,36,
		89,0,176,47,0,95,2,109,18,0,1,92,2,1,
		12,1,28,176,36,90,0,109,19,0,28,11,109,18,
		0,23,83,18,0,25,159,109,18,0,17,83,18,0,
		25,150,36,95,0,95,1,31,3,7,36,97,0,85,
		108,3,74,109,8,0,106,2,73,0,8,28,9,176,
		48,0,12,0,25,7,176,49,0,12,0,119,28,30,
		36,98,0,85,108,3,74,176,50,0,20,0,74,36,
		99,0,85,108,3,74,176,51,0,20,0,74,25,27,
		36,101,0,109,8,0,106,2,73,0,8,28,9,176,
		52,0,20,0,25,7,176,53,0,20,0,36,104,0,
		7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_CRITICA )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,110,0,95,1,100,8,28,7,106,1,
		0,80,1,36,112,0,95,1,106,7,67,79,68,73,
		71,79,0,8,28,73,109,8,0,106,2,73,0,8,
		28,63,36,113,0,85,108,3,74,176,54,0,109,17,
		0,12,1,119,28,45,36,114,0,176,13,0,106,23,
		67,162,100,105,103,111,32,106,160,32,99,97,100,97,
		115,116,114,97,100,111,32,33,0,106,2,66,0,20,
		2,36,115,0,9,110,7,36,118,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_EXCLUSAO )
{
	static const HB_BYTE pcode[] =
	{
		36,124,0,176,40,0,106,36,67,111,110,102,105,114,
		109,97,32,101,120,99,108,117,115,132,111,32,100,101,
		115,116,101,32,109,117,110,105,99,105,112,105,111,32,
		63,0,12,1,28,53,36,125,0,85,108,3,74,176,
		49,0,12,0,119,28,30,36,126,0,85,108,3,74,
		176,55,0,20,0,74,36,127,0,85,108,3,74,176,
		51,0,20,0,74,25,10,36,129,0,176,56,0,20,
		0,36,132,0,7
	};

	hb_vmExecute( pcode, symbols );
}

