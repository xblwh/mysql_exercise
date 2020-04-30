use firstMySQL;

# 3.9
drop view if exists sanjian_view;
create view sanjian_view as (
	select SNO,PNO,QTY from table_spj where JNO in (select JNO from table_j where JNAME='三建') );

select * from sanjian_view;

#(1)
select PNO,sum(QTY) from sanjian_view group by PNO;

#(2)
select PNO,QTY from sanjian_view where SNO='S1';
