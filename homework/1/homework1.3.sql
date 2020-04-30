use firstMySQL;
set global query_cache_size = 0;
set global query_cache_type = off;
#show variables like '%pro%';
set profiling=1;
RESET QUERY CACHE;


# 3.5
#(1)
select SNAME,CITY from table_s;

#(2)
select PNAME, COLOR, WEIGHT from table_p;

#(3)
select JNO from table_spj where SNO='S1';

#(4) 找出工程项目J2使用的各种零件的名称和数量（注意名称重复）
select PNAME,sum(QTY) from (select PNO,QTY from table_spj where JNO='J2') t1 join 
	(select PNO, PNAME from table_p) t2 on t1.PNO=t2.PNO group by PNAME;
    
#(5)
select distinct PNO from table_spj where SNO in (select SNO from table_s where CITY='上海');

#(6)找出使用上海产的零件的工程名称
select JNAME from table_j where JNO in 
	(select distinct JNO from table_spj where SNO in 
		(select SNO from table_s where CITY='上海'));

#(7) 找出没有使用天津产的零件的工程名称（不存在问题）
select distinct JNO from (select distinct JNO from table_spj) t1 where not exists(
		select * from table_spj t2 where t2.JNO=t1.JNO and t2.SNO in (select SNO from table_s where CITY='天津'));
select distinct JNO from table_spj where JNO not in (select distinct JNO from table_spj t1, table_s t2 where t1.SNO=t2.SNO and t2.CITY='天津');

#(8)
set sql_safe_updates=0;
update table_p set COLOR='蓝' where color='红';
select * from table_p;

#(9)
update table_spj set SNO='S3' where SNO='S4' and PNO='P6' and JNO='J4';

#(10)
delete from table_spj where SNO='S2';
delete from table_s where SNO='S2';

#(11)
insert into table_spj (SNO,JNO,PNO,QTY) values('S2','J6','P4',200);

