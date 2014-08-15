cd\borius\vendas\vendas\webContent\sqls

FOR %%f IN (*.sql) do (

    mysql -uroot -pborios < %%f

)

cd\qsys\qutil
