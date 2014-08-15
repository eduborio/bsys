/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QLOGIN1.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QLOGIN );
HB_FUNC_EXTERN( SPACE );
HB_FUNC_EXTERN( QSBLOC );
HB_FUNC_EXTERN( ROW );
HB_FUNC_EXTERN( COL );
HB_FUNC_EXTERN( SETKEY );
HB_FUNC_EXTERN( QUSE );
HB_FUNC_EXTERN( QSAY );
HB_FUNC_EXTERN( QLBLOC );
HB_FUNC_EXTERN( SETPOS );
HB_FUNC_EXTERN( SETCOLOR );
HB_FUNC_EXTERN( ATCSC_SL );
HB_FUNC_EXTERN( UPPER );
HB_FUNC_EXTERN( CHR );
HB_FUNC_EXTERN( QINKEY );
HB_FUNC_EXTERN( LASTKEY );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( ASC );
HB_FUNC_EXTERN( QQOUT );
HB_FUNC_EXTERN( PAD );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_STATIC( I_LOGOUT );
HB_FUNC_STATIC( I_E_SENHA_ADMIN );
HB_FUNC_EXTERN( CTRL_ADMIN );
HB_FUNC_STATIC( I_CHECK_USER );
HB_FUNC_EXTERN( QRBLOC );
HB_FUNC_EXTERN( DBCLOSEAREA );
HB_FUNC_EXTERN( QRLOCK );
HB_FUNC_EXTERN( QMENSA );
HB_FUNC_EXTERN( QENCRI );
HB_FUNC_EXTERN( QUNLOCK );
HB_FUNC_EXTERN( QDECRI );
HB_FUNC_EXTERN( __DBLOCATE );
HB_FUNC_EXTERN( EOF );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( DBSEEK );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QLOGIN1 )
{ "QLOGIN", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QLOGIN )}, NULL },
{ "SPACE", {HB_FS_PUBLIC}, {HB_FUNCNAME( SPACE )}, NULL },
{ "QSBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSBLOC )}, NULL },
{ "ROW", {HB_FS_PUBLIC}, {HB_FUNCNAME( ROW )}, NULL },
{ "COL", {HB_FS_PUBLIC}, {HB_FUNCNAME( COL )}, NULL },
{ "XWAIT", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "SETKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETKEY )}, NULL },
{ "QUSE", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUSE )}, NULL },
{ "XDRV_SH", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QSAY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSAY )}, NULL },
{ "QLBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QLBLOC )}, NULL },
{ "SETPOS", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETPOS )}, NULL },
{ "SETCOLOR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETCOLOR )}, NULL },
{ "ATCSC_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( ATCSC_SL )}, NULL },
{ "UPPER", {HB_FS_PUBLIC}, {HB_FUNCNAME( UPPER )}, NULL },
{ "CHR", {HB_FS_PUBLIC}, {HB_FUNCNAME( CHR )}, NULL },
{ "QINKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( QINKEY )}, NULL },
{ "LASTKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( LASTKEY )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "ASC", {HB_FS_PUBLIC}, {HB_FUNCNAME( ASC )}, NULL },
{ "QQOUT", {HB_FS_PUBLIC}, {HB_FUNCNAME( QQOUT )}, NULL },
{ "PAD", {HB_FS_PUBLIC}, {HB_FUNCNAME( PAD )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "XUSRIDT", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "I_LOGOUT", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_LOGOUT )}, NULL },
{ "I_E_SENHA_ADMIN", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_E_SENHA_ADMIN )}, NULL },
{ "CTRL_ADMIN", {HB_FS_PUBLIC}, {HB_FUNCNAME( CTRL_ADMIN )}, NULL },
{ "I_CHECK_USER", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_CHECK_USER )}, NULL },
{ "QRBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRBLOC )}, NULL },
{ "QCONFIG", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "DBCLOSEAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBCLOSEAREA )}, NULL },
{ "QUSERS", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "ID_ADMIN", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QRLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRLOCK )}, NULL },
{ "QMENSA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QMENSA )}, NULL },
{ "QENCRI", {HB_FS_PUBLIC}, {HB_FUNCNAME( QENCRI )}, NULL },
{ "QUNLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUNLOCK )}, NULL },
{ "QDECRI", {HB_FS_PUBLIC}, {HB_FUNCNAME( QDECRI )}, NULL },
{ "__DBLOCATE", {HB_FS_PUBLIC}, {HB_FUNCNAME( __DBLOCATE )}, NULL },
{ "IDENTIFIC", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "EOF", {HB_FS_PUBLIC}, {HB_FUNCNAME( EOF )}, NULL },
{ "PROG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XTIPOSENHA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XEMPRESA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "EMPRESA", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "ZTMP", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "USRNUM", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "XUSRNUM", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "DBSEEK", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSEEK )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QLOGIN1, "QLOGIN1.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QLOGIN1
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QLOGIN1 )
   #include "hbiniseg.h"
#endif

HB_FUNC( QLOGIN )
{
	static const HB_BYTE pcode[] =
	{
		13,8,0,36,4,0,176,1,0,92,10,12,1,80,
		1,36,5,0,176,2,0,121,121,92,24,92,79,12,
		4,80,2,36,6,0,176,3,0,12,0,80,3,36,
		7,0,176,4,0,12,0,80,4,36,8,0,106,1,
		0,80,5,36,9,0,106,1,0,80,6,36,10,0,
		106,1,0,80,7,36,11,0,109,5,0,80,8,36,
		13,0,109,5,0,31,5,9,110,7,36,15,0,9,
		83,5,0,36,17,0,176,6,0,92,254,100,20,2,
		36,19,0,176,7,0,106,1,0,106,8,81,67,79,
		78,70,73,71,0,12,2,31,5,9,110,7,36,20,
		0,176,7,0,109,8,0,106,7,81,85,83,69,82,
		83,0,106,8,81,85,83,69,82,83,49,0,106,8,
		81,85,83,69,82,83,50,0,4,2,0,12,3,31,
		5,9,110,7,36,23,0,176,9,0,92,3,92,68,
		106,9,76,111,103,105,110,46,46,46,0,20,3,36,
		24,0,176,10,0,92,4,92,56,106,9,80,87,95,
		73,68,69,78,84,0,109,8,0,106,11,81,83,66,
		76,79,67,46,71,76,79,0,72,20,4,36,26,0,
		176,11,0,92,5,92,58,20,2,36,27,0,176,12,
		0,176,13,0,176,3,0,12,0,176,4,0,12,0,
		12,2,20,1,36,29,0,176,14,0,176,15,0,176,
		16,0,121,12,1,12,1,12,1,80,7,36,30,0,
		176,17,0,12,0,92,13,8,32,166,0,176,17,0,
		12,0,92,27,8,32,155,0,36,31,0,176,17,0,
		12,0,92,8,8,31,12,176,17,0,12,0,92,19,
		8,28,75,176,18,0,95,5,12,1,121,15,28,64,
		36,32,0,176,19,0,95,5,176,18,0,95,5,12,
		1,122,49,12,2,80,5,36,33,0,176,9,0,92,
		5,176,4,0,12,0,122,49,106,2,32,0,20,3,
		36,34,0,176,11,0,92,5,176,4,0,12,0,122,
		49,20,2,26,117,255,36,35,0,176,18,0,95,5,
		12,1,92,10,35,29,101,255,176,20,0,95,7,12,
		1,92,32,15,29,88,255,36,36,0,96,5,0,95,
		7,135,36,37,0,176,21,0,106,2,42,0,20,1,
		36,38,0,26,61,255,36,41,0,176,22,0,95,5,
		92,10,12,2,80,5,36,43,0,176,17,0,12,0,
		92,13,8,28,29,176,23,0,95,5,12,1,28,20,
		176,23,0,109,24,0,12,1,31,10,36,44,0,176,
		25,0,20,0,36,47,0,176,26,0,95,5,12,1,
		28,35,36,48,0,176,9,0,92,3,92,68,106,9,
		65,68,77,73,78,46,46,46,0,20,3,36,49,0,
		176,27,0,20,0,25,12,36,51,0,176,28,0,95,
		5,20,1,36,54,0,176,29,0,121,121,95,2,20,
		3,36,56,0,176,11,0,92,24,92,76,20,2,36,
		58,0,176,6,0,92,254,89,19,0,3,0,0,0,
		176,0,0,95,1,95,2,95,3,12,3,6,20,2,
		36,60,0,95,8,83,5,0,36,62,0,85,108,30,
		74,176,31,0,20,0,74,36,63,0,85,108,32,74,
		176,31,0,20,0,74,36,65,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_E_SENHA_ADMIN )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,72,0,176,19,0,108,30,87,33,122,
		12,2,106,2,68,0,8,28,104,36,73,0,85,108,
		30,74,176,34,0,12,0,119,31,51,36,74,0,176,
		35,0,106,29,69,114,114,111,32,110,111,32,99,111,
		110,116,114,111,108,101,32,100,111,32,65,68,77,73,
		78,46,46,46,0,106,2,66,0,20,2,36,75,0,
		9,110,7,36,77,0,176,36,0,106,11,81,83,89,
		83,32,32,32,32,32,32,0,12,1,108,30,76,33,
		36,78,0,85,108,30,74,176,37,0,20,0,74,36,
		82,0,95,1,176,38,0,108,30,87,33,12,1,8,
		28,5,120,110,7,36,83,0,9,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_CHECK_USER )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,100,0,176,39,0,89,29,0,0,0,
		1,0,1,0,176,19,0,176,38,0,108,32,87,40,
		12,1,92,10,12,2,95,255,8,6,100,100,100,9,
		20,5,36,101,0,176,41,0,12,0,32,197,0,36,
		102,0,176,23,0,108,32,87,42,12,1,31,73,109,
		43,0,106,2,84,0,8,28,63,36,103,0,176,35,
		0,106,41,85,115,117,97,114,105,111,32,106,160,32,
		101,115,116,160,32,97,116,105,118,111,32,101,109,32,
		111,117,116,114,97,32,101,115,116,97,135,132,111,32,
		33,0,106,2,66,0,20,2,36,104,0,9,110,7,
		36,106,0,85,108,32,74,176,34,0,12,0,119,28,
		96,36,107,0,106,4,76,79,71,0,108,32,76,42,
		36,108,0,109,44,0,108,32,76,45,36,109,0,85,
		108,32,74,176,37,0,20,0,74,36,110,0,176,38,
		0,108,32,87,40,12,1,83,46,0,36,112,0,109,
		46,0,83,24,0,36,113,0,176,47,0,109,24,0,
		92,11,92,10,12,3,83,24,0,36,114,0,108,32,
		87,48,83,49,0,36,115,0,120,110,7,36,118,0,
		9,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_LOGOUT )
{
	static const HB_BYTE pcode[] =
	{
		36,124,0,85,108,32,74,176,50,0,109,24,0,12,
		1,119,28,75,36,125,0,85,108,32,74,176,34,0,
		12,0,119,28,60,36,126,0,106,1,0,108,32,76,
		42,36,127,0,106,1,0,108,32,76,45,36,128,0,
		85,108,32,74,176,37,0,20,0,74,36,129,0,176,
		1,0,92,10,12,1,83,24,0,36,130,0,106,4,
		48,48,48,0,83,49,0,36,133,0,7
	};

	hb_vmExecute( pcode, symbols );
}

