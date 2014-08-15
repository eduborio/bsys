/*
 * SQL LIB
 * A SQL RDD & API framework
 * for Harbour
 *
 * Constants for Events into API
 * By Eduardo Borio
 *
 * 13-06-2009 - 12:30
 */

#ifndef _SQL_LIB_CH
#define _SQL_LIB_CH

#ifndef SQL_LIB_DEFs
#define SQL_LIB_DEFs

*     Translate Path
#translate tpFileName         => 00
#translate tpFullPath         => -1
#translate tpFullName         => -2 // 04/06/2009 -> v1.0d add
#translate tpFullNamePath     => -3 // 04/06/2009 -> v1.0d add

*     Translate Case
#translate tcNone             => 00
#translate tcUpperCase        => 01
#translate tcLowerCase        => 02
#endif

/*
 * Indica que n∆o deve exibir nenhum
 * erro ao tentar se conectar ao DB...
 */
#define SQL_NO_WARNING          01
#define SQL_NO_ERROR            00

#command USE <(SQL)>                                                    ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [INDEX <(index1)> [, <(indexn)>]]                          ;
             [CONNECTION <con>]                               ;
             [<new: NEW>]                                               ;
             [<ex: EXCLUSIVE>]                                          ;
             [<sh: SHARED>]                                             ;
             [<ro: READONLY>]                                           ;
                                                                        ;
      =>                                 ;
         dbUseArea(                                                     ;
                    <.new.>, <rdd>, <(SQL)> , <(a)>,                    ;
                    if(<.sh.> .or. <.ex.>, !<.ex.>, NIL), <.ro.>,,<con>   ;
                  )                                                     ;
                                                                        ;
      [; dbSetIndex( <(index1)> )]                                      ;
      [; dbSetIndex( <(indexn)> )]

* Voce pode abrir uma QUERY como ser fosse uma tabela no DB,
* com este comando (note que ele nao oferece suporte para a opcao INDEX
* utilizada normalmente pelo comando USE):
#command USE SQL <(SQL)>                                                ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [INTO <conn>]                                              ;
             [<new: NEW>]                                               ;
             [<ex: EXCLUSIVE>]                                          ;
             [<sh: SHARED>]                                             ;
             [<ro: READONLY>]                                           ;
                                                                        ;
      => [SQLSetConn( <conn>, .F. );]                                   ;
         [SQLSetQuery( <SQL>, .F. );]                                   ;
         dbUseArea(                                                     ;
                    <.new.>, iif(<.rdd.>,<rdd>,SQLGetRddName(<conn>)), "*", NextQueryAlias(<(a)>),         ;
                    if(<.sh.> .or. <.ex.>, !<.ex.>, NIL), <.ro.>        ;
                  )

* Mediator  * * * LIKE STYLE * * *
#command USE <(db)>                                                     ;
        AS <SQL>                                                        ;
             [INTO <conn>]                                              ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [<new: NEW>]                                               ;
        [<sh: SHARED>]                    ;
        [<ex: EXCLUSIVE>]                 ;
        [<ro: READONLY>]                  ;
        [<c1log: C1LOGICAL>]              ;
        [<ovr: OVERWRITE>]                ;
             [PRECISION <p>]              ;
        [<scr: SCROLLABLE>]               ;
        [<prmt: PERMANENT>]               ;
                                                                        ;
      => [SQLSetConn( <conn>, .F. );]                                   ;
         [SQLSetQuery( <SQL>, .F. );]                                   ;
         dbUseArea(                                                     ;
                    <.new.>, iif(<.rdd.>,<rdd>,SQLGetRddName(<conn>)), "*", NextQueryAlias(<(a)>),         ;
                    if(<.sh.> .or. <.ex.>, !<.ex.>, NIL), <.ro.>        ;
                  )

