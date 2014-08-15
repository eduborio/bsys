/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QHELP_.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QHELP );
HB_FUNC_EXTERN( QSBLOC );
HB_FUNC_EXTERN( ROW );
HB_FUNC_EXTERN( COL );
HB_FUNC_EXTERN( SETKEY );
HB_FUNC_STATIC( I_HELP_BLOC );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_STATIC( I_HELP_PROG );
HB_FUNC_EXTERN( SETPOS );
HB_FUNC_EXTERN( QRBLOC );
HB_FUNC_EXTERN( QLBLOC );
HB_FUNC_EXTERN( TONE );
HB_FUNC_EXTERN( QWAIT );
HB_FUNC_EXTERN( ALIAS );
HB_FUNC_EXTERN( SETCOLOR );
HB_FUNC_EXTERN( SCROLL );
HB_FUNC_EXTERN( DISPBOX );
HB_FUNC_EXTERN( QUSE );
HB_FUNC_EXTERN( DBSEEK );
HB_FUNC_EXTERN( QAPPEND );
HB_FUNC_EXTERN( QMENSA );
HB_FUNC_EXTERN( QENCRI );
HB_FUNC_EXTERN( QUNLOCK );
HB_FUNC_EXTERN( GETENV );
HB_FUNC_EXTERN( QDECRI );
HB_FUNC_EXTERN( SETCURSOR );
HB_FUNC_EXTERN( MEMOEDIT );
HB_FUNC_EXTERN( QRLOCK );
HB_FUNC_EXTERN( ALLTRIM );
HB_FUNC_EXTERN( DBCLOSEAREA );
HB_FUNC_EXTERN( DBSELECTAREA );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QHELP_ )
{ "QHELP", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QHELP )}, NULL },
{ "QSBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QSBLOC )}, NULL },
{ "ROW", {HB_FS_PUBLIC}, {HB_FUNCNAME( ROW )}, NULL },
{ "COL", {HB_FS_PUBLIC}, {HB_FUNCNAME( COL )}, NULL },
{ "SETKEY", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETKEY )}, NULL },
{ "XHELP", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "I_HELP_BLOC", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_HELP_BLOC )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "XPROG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "I_HELP_PROG", {HB_FS_STATIC | HB_FS_LOCAL}, {HB_FUNCNAME( I_HELP_PROG )}, NULL },
{ "SETPOS", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETPOS )}, NULL },
{ "QRBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRBLOC )}, NULL },
{ "QLBLOC", {HB_FS_PUBLIC}, {HB_FUNCNAME( QLBLOC )}, NULL },
{ "XDRV_SH", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "TONE", {HB_FS_PUBLIC}, {HB_FUNCNAME( TONE )}, NULL },
{ "QWAIT", {HB_FS_PUBLIC}, {HB_FUNCNAME( QWAIT )}, NULL },
{ "ALIAS", {HB_FS_PUBLIC}, {HB_FUNCNAME( ALIAS )}, NULL },
{ "SETCOLOR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETCOLOR )}, NULL },
{ "SCROLL", {HB_FS_PUBLIC}, {HB_FUNCNAME( SCROLL )}, NULL },
{ "DISPBOX", {HB_FS_PUBLIC}, {HB_FUNCNAME( DISPBOX )}, NULL },
{ "QUSE", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUSE )}, NULL },
{ "QHELP", {HB_FS_PUBLIC}, {NULL}, NULL },
{ "DBSEEK", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSEEK )}, NULL },
{ "QAPPEND", {HB_FS_PUBLIC}, {HB_FUNCNAME( QAPPEND )}, NULL },
{ "QMENSA", {HB_FS_PUBLIC}, {HB_FUNCNAME( QMENSA )}, NULL },
{ "PROG", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QENCRI", {HB_FS_PUBLIC}, {HB_FUNCNAME( QENCRI )}, NULL },
{ "HELP", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "QUNLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QUNLOCK )}, NULL },
{ "GETENV", {HB_FS_PUBLIC}, {HB_FUNCNAME( GETENV )}, NULL },
{ "QDECRI", {HB_FS_PUBLIC}, {HB_FUNCNAME( QDECRI )}, NULL },
{ "SETCURSOR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SETCURSOR )}, NULL },
{ "MEMOEDIT", {HB_FS_PUBLIC}, {HB_FUNCNAME( MEMOEDIT )}, NULL },
{ "QRLOCK", {HB_FS_PUBLIC}, {HB_FUNCNAME( QRLOCK )}, NULL },
{ "ALLTRIM", {HB_FS_PUBLIC}, {HB_FUNCNAME( ALLTRIM )}, NULL },
{ "DBCLOSEAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBCLOSEAREA )}, NULL },
{ "DBSELECTAREA", {HB_FS_PUBLIC}, {HB_FUNCNAME( DBSELECTAREA )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QHELP_, "QHELP_.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QHELP_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QHELP_ )
   #include "hbiniseg.h"
#endif

HB_FUNC( QHELP )
{
	static const HB_BYTE pcode[] =
	{
		13,3,0,36,5,0,176,1,0,92,5,121,92,24,
		92,79,12,4,80,1,36,6,0,176,2,0,12,0,
		80,2,36,7,0,176,3,0,12,0,80,3,36,9,
		0,176,4,0,92,28,100,20,2,36,12,0,109,5,
		0,106,4,57,48,49,0,8,28,17,176,6,0,106,
		6,72,95,57,48,49,0,20,1,25,41,36,14,0,
		176,7,0,109,8,0,12,1,31,9,176,9,0,20,
		0,25,21,36,15,0,176,6,0,106,9,72,95,73,
		78,73,67,73,79,0,20,1,36,18,0,176,10,0,
		95,2,95,3,20,2,36,20,0,176,11,0,92,5,
		121,95,1,20,3,36,22,0,176,4,0,92,28,89,
		19,0,3,0,0,0,176,0,0,95,1,95,2,95,
		3,12,3,6,20,2,36,23,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_HELP_BLOC )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,26,0,176,12,0,92,5,121,95,1,
		109,13,0,106,11,81,83,66,76,79,67,46,71,76,
		79,0,72,20,4,36,27,0,176,14,0,93,184,11,
		101,0,0,0,0,0,0,224,63,10,1,20,2,176,
		15,0,121,20,1,36,28,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( I_HELP_PROG )
{
	static const HB_BYTE pcode[] =
	{
		13,4,0,36,31,0,176,16,0,12,0,80,1,36,
		32,0,176,17,0,106,4,87,47,78,0,12,1,80,
		2,36,33,0,106,1,0,80,3,36,36,0,176,18,
		0,92,5,121,92,23,92,79,20,4,176,10,0,92,
		5,121,20,2,36,37,0,176,19,0,92,5,121,92,
		23,92,79,92,2,20,5,36,39,0,176,20,0,106,
		1,0,106,6,81,72,69,76,80,0,106,6,81,72,
		69,76,80,0,4,1,0,12,3,31,5,9,110,7,
		36,41,0,85,108,21,74,176,22,0,109,8,0,12,
		1,119,32,167,0,36,42,0,85,108,21,74,176,23,
		0,12,0,119,31,55,36,43,0,176,24,0,106,33,
		69,114,114,111,32,97,111,32,108,101,114,32,97,114,
		113,117,105,118,111,32,100,101,32,104,101,108,112,39,
		115,46,46,46,0,106,2,66,0,20,2,36,44,0,
		9,110,7,36,46,0,109,8,0,108,21,76,25,36,
		47,0,176,26,0,106,59,72,69,76,80,32,65,73,
		78,68,65,32,78,65,79,32,68,73,83,80,79,78,
		73,86,69,76,32,80,65,82,65,32,69,83,84,65,
		32,79,80,67,65,79,44,32,68,69,83,67,85,76,
		80,69,45,78,79,83,46,46,46,0,12,1,108,21,
		76,27,36,48,0,85,108,21,74,176,28,0,20,0,
		74,36,52,0,176,24,0,106,37,60,69,83,67,62,
		32,114,101,116,111,114,110,97,44,32,60,83,101,116,
		97,115,44,80,103,85,112,44,80,103,68,119,44,101,
		116,99,62,0,20,1,36,54,0,176,29,0,106,9,
		65,84,85,65,72,69,76,80,0,12,1,106,2,83,
		0,8,28,110,36,55,0,176,30,0,108,21,87,27,
		12,1,80,3,36,56,0,176,31,0,122,12,1,80,
		4,36,57,0,176,32,0,95,3,92,6,92,2,92,
		22,92,77,120,12,6,80,3,36,58,0,176,31,0,
		95,4,20,1,36,59,0,85,108,21,74,176,33,0,
		12,0,119,28,65,36,60,0,176,26,0,176,34,0,
		95,3,12,1,12,1,108,21,76,27,36,61,0,85,
		108,21,74,176,28,0,20,0,74,36,62,0,25,28,
		36,64,0,176,32,0,176,30,0,108,21,87,27,12,
		1,92,6,92,2,92,22,92,77,9,20,6,36,67,
		0,85,108,21,74,176,35,0,20,0,74,36,68,0,
		176,17,0,95,2,20,1,36,69,0,176,36,0,95,
		1,20,1,36,70,0,7
	};

	hb_vmExecute( pcode, symbols );
}

