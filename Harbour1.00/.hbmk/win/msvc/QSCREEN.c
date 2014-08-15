/*
 * Harbour 2.0.0 (Rev. 13372)
 * MinGW GNU C 4.4.1 (32-bit)
 * Generated C source from "QSCREEN.PRG"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( QSBLOC );
HB_FUNC_EXTERN( STRZERO );
HB_FUNC_EXTERN( SAVESCREEN );
HB_FUNC( QRBLOC );
HB_FUNC_EXTERN( VAL );
HB_FUNC_EXTERN( LEFT );
HB_FUNC_EXTERN( SUBSTR );
HB_FUNC_EXTERN( RESTSCREEN );
HB_FUNC_EXTERN( COLOR_SL );
HB_FUNC( QLBLOC );
HB_FUNC_EXTERN( SEEKB_SL );
HB_FUNC_EXTERN( VALTYPE );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( MEMOREAD );
HB_FUNC( QREADGLO );
HB_FUNC_EXTERN( FOPEN );
HB_FUNC_EXTERN( SPACE );
HB_FUNC_EXTERN( FREAD );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( PAD );
HB_FUNC_EXTERN( RIGHT );
HB_FUNC_EXTERN( FSEEK );
HB_FUNC_EXTERN( FCLOSE );
HB_FUNC_EXTERN( I_PROT_ADIC );
HB_FUNC( QINVERC );
HB_FUNC_EXTERN( INVERTWIN );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_QSCREEN )
{ "QSBLOC", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QSBLOC )}, NULL },
{ "STRZERO", {HB_FS_PUBLIC}, {HB_FUNCNAME( STRZERO )}, NULL },
{ "SAVESCREEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( SAVESCREEN )}, NULL },
{ "QRBLOC", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QRBLOC )}, NULL },
{ "VAL", {HB_FS_PUBLIC}, {HB_FUNCNAME( VAL )}, NULL },
{ "LEFT", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEFT )}, NULL },
{ "SUBSTR", {HB_FS_PUBLIC}, {HB_FUNCNAME( SUBSTR )}, NULL },
{ "RESTSCREEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( RESTSCREEN )}, NULL },
{ "COLOR_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( COLOR_SL )}, NULL },
{ "QLBLOC", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QLBLOC )}, NULL },
{ "SEEKB_SL", {HB_FS_PUBLIC}, {HB_FUNCNAME( SEEKB_SL )}, NULL },
{ "VALTYPE", {HB_FS_PUBLIC}, {HB_FUNCNAME( VALTYPE )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "MEMOREAD", {HB_FS_PUBLIC}, {HB_FUNCNAME( MEMOREAD )}, NULL },
{ "QREADGLO", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QREADGLO )}, NULL },
{ "NLENGHT", {HB_FS_PUBLIC | HB_FS_MEMVAR}, {NULL}, NULL },
{ "FOPEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( FOPEN )}, NULL },
{ "SPACE", {HB_FS_PUBLIC}, {HB_FUNCNAME( SPACE )}, NULL },
{ "FREAD", {HB_FS_PUBLIC}, {HB_FUNCNAME( FREAD )}, NULL },
{ "LEN", {HB_FS_PUBLIC}, {HB_FUNCNAME( LEN )}, NULL },
{ "PAD", {HB_FS_PUBLIC}, {HB_FUNCNAME( PAD )}, NULL },
{ "RIGHT", {HB_FS_PUBLIC}, {HB_FUNCNAME( RIGHT )}, NULL },
{ "FSEEK", {HB_FS_PUBLIC}, {HB_FUNCNAME( FSEEK )}, NULL },
{ "FCLOSE", {HB_FS_PUBLIC}, {HB_FUNCNAME( FCLOSE )}, NULL },
{ "I_PROT_ADIC", {HB_FS_PUBLIC}, {HB_FUNCNAME( I_PROT_ADIC )}, NULL },
{ "QINVERC", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( QINVERC )}, NULL },
{ "INVERTWIN", {HB_FS_PUBLIC}, {HB_FUNCNAME( INVERTWIN )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_QSCREEN, "QSCREEN.PRG", 0x0, 0x0002 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_QSCREEN
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_QSCREEN )
   #include "hbiniseg.h"
#endif

HB_FUNC( QSBLOC )
{
	static const HB_BYTE pcode[] =
	{
		13,1,4,36,3,0,106,1,0,80,5,36,4,0,
		96,5,0,176,1,0,95,3,95,1,49,92,2,12,
		2,135,36,5,0,96,5,0,176,1,0,95,4,95,
		2,49,92,3,12,2,135,36,6,0,96,5,0,176,
		2,0,95,1,95,2,95,3,95,4,12,4,135,36,
		7,0,95,5,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QRBLOC )
{
	static const HB_BYTE pcode[] =
	{
		13,6,4,36,11,0,95,1,176,4,0,176,5,0,
		95,3,92,2,12,2,12,1,72,80,9,36,12,0,
		95,2,176,4,0,176,6,0,95,3,92,3,92,3,
		12,3,12,1,72,80,10,36,14,0,176,7,0,95,
		1,95,2,95,9,95,10,176,6,0,95,3,92,6,
		12,2,20,5,36,16,0,95,4,100,8,28,5,121,
		80,4,36,17,0,95,4,122,8,29,180,0,36,18,
		0,95,1,176,4,0,176,5,0,95,3,92,2,12,
		2,12,1,72,122,72,80,5,36,19,0,95,2,92,
		2,72,80,7,36,20,0,95,5,80,6,36,21,0,
		95,2,176,4,0,176,6,0,95,3,92,3,92,3,
		12,3,12,1,72,92,2,72,80,8,36,22,0,176,
		8,0,95,5,95,7,95,6,95,8,92,7,106,2,
		83,0,20,6,36,23,0,175,1,0,80,5,36,24,
		0,95,2,176,4,0,176,6,0,95,3,92,3,92,
		3,12,3,12,1,72,122,72,80,7,36,25,0,95,
		1,176,4,0,176,5,0,95,3,92,2,12,2,12,
		1,72,80,6,36,26,0,95,7,122,72,80,8,36,
		27,0,176,8,0,95,5,95,7,95,6,95,8,92,
		7,106,2,83,0,20,6,36,29,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QLBLOC )
{
	static const HB_BYTE pcode[] =
	{
		13,1,5,36,32,0,106,1,0,80,6,36,34,0,
		176,10,0,106,2,76,0,20,1,36,36,0,176,11,
		0,95,1,12,1,106,2,78,0,8,28,35,176,12,
		0,95,4,12,1,28,26,36,37,0,176,3,0,95,
		1,95,2,176,13,0,95,3,12,1,95,5,20,4,
		26,134,0,36,38,0,176,11,0,95,1,12,1,106,
		2,78,0,8,28,36,176,12,0,95,4,12,1,31,
		27,36,39,0,176,3,0,95,1,95,2,176,14,0,
		95,3,95,4,12,2,95,5,20,4,25,82,36,40,
		0,176,11,0,95,1,12,1,106,2,67,0,8,28,
		25,176,12,0,95,2,12,1,28,16,36,41,0,176,
		13,0,95,1,12,1,80,6,25,42,36,42,0,176,
		11,0,95,1,12,1,106,2,67,0,8,28,25,176,
		12,0,95,2,12,1,31,16,36,43,0,176,14,0,
		95,1,95,2,12,2,80,6,36,45,0,95,6,110,
		7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QREADGLO )
{
	static const HB_BYTE pcode[] =
	{
		13,5,2,36,48,0,121,165,83,15,0,80,7,36,
		52,0,176,16,0,95,2,121,12,2,165,80,3,121,
		35,28,10,36,53,0,106,1,0,110,7,36,58,0,
		176,17,0,92,3,12,1,80,4,36,60,0,176,18,
		0,95,3,96,4,0,176,19,0,95,4,12,1,20,
		3,36,64,0,176,4,0,95,4,12,1,80,5,36,
		66,0,122,165,80,6,25,114,36,67,0,176,17,0,
		92,18,12,1,80,4,36,68,0,176,18,0,95,3,
		96,4,0,176,19,0,95,4,12,1,20,3,36,69,
		0,176,5,0,95,4,92,8,12,2,176,20,0,95,
		1,92,8,12,2,8,28,52,36,70,0,176,4,0,
		176,6,0,95,4,92,9,92,6,12,3,12,1,80,
		7,36,71,0,176,17,0,176,4,0,176,21,0,95,
		4,92,4,12,2,12,1,12,1,80,4,36,72,0,
		25,13,36,66,0,175,6,0,95,5,15,28,141,36,
		78,0,95,7,121,8,28,12,36,79,0,106,1,0,
		80,4,25,34,36,81,0,176,22,0,95,3,95,7,
		20,2,36,82,0,176,18,0,95,3,96,4,0,176,
		19,0,95,4,12,1,20,3,36,85,0,176,23,0,
		95,3,20,1,36,87,0,176,24,0,20,0,36,89,
		0,95,4,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QINVERC )
{
	static const HB_BYTE pcode[] =
	{
		13,0,4,36,100,0,176,26,0,95,1,95,2,95,
		3,95,4,20,4,36,104,0,7
	};

	hb_vmExecute( pcode, symbols );
}

