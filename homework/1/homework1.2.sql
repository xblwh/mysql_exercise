USE firstMySQL;
# 2.6
# （1）求供应工程J1零件的供应商号码SNO
select distinct SNO from table_spj where JNO = 'J1';
# select SNO from table_spj where JNO = 'J1' group by SNO;

# （2）求供应工程J1零件P1的供应商号码SNO
select distinct SNO from table_spj where JNO='J1' and PNO='P1';

# （3）求供应工程J1零件为红色的供应商号码SNO
# 子嵌套
select distinct table_spj.SNO from table_spj where  table_spj.JNO='J1' and table_spj.PNO in (
select table_p.PNO from table_p where table_p.COLOR='红');
# 联合
select distinct SNO from table_spj join table_p on table_spj.PNO = table_p.PNO where table_spj.JNO='J1' and table_p.COLOR='红';
#视图
create view red_PNO as (select PNO from table_p where COLOR='红');
select distinct SNO from table_spj, red_PNO where JNO='J1' and table_spj.PNO = red_PNO.PNO;
drop view red_PNO;

# （4）求没有使用天津供应商生产的红色零件的工程号JNO
create view tianjin_red as (
  select a.SNO, b.PNO from (
	select SNO from table_s where table_s.CITY='天津') a, (
    select PNO from table_p where table_p.COLOR='红') b
);
select distinct a.JNO from (select distinct JNO from table_spj) a where
	a.JNO not in (select distinct JNO from table_spj, tianjin_red where table_spj.SNO=tianjin_red.SNO and table_spj.PNO=tianjin_red.PNO);
drop view tianjin_red;

select distinct JNO from table_spj where JNO not in (
	select JNO from table_spj,table_s,table_p where table_spj.SNO=table_s.SNO and table_spj.PNO=table_p.PNO and
		table_s.CITY='天津' and table_p.COLOR='红');

# （5）求至少用了供应商S1所供应的全部零件的工程号JNO
select distinct PNO from table_spj where table_spj.SNO='S1';  #P1,P2
select distinct JNO from table_spj where PNO='P1' and JNO in (select JNO from table_spj where PNO = 'P2');



# 使用存储过程求解(非硬编码)
drop procedure if exists chooseJNO_all_s1;
delimiter //
create procedure chooseJNO_all_s1 ()
begin
	declare cur_pno varchar(10);
    declare cur_jno varchar(10);
    DECLARE done boolean default 0;
    -- 定义游标，遍历SPJ表
    declare cur cursor for 
		(select distinct PNO,JNO from table_spj);	-- 这里计算的是种类，所以使用distinct
    
    declare continue handler for not found set done=1;
    -- 建立项目的计数表（每使用一个S1提供的商品类型的商品，cnt计数加1）
    create temporary table if not exists cnt_table (
		id int unsigned not null auto_increment,
		cnt int unsigned not null default 0,
        primary key(id)
    ) as (
		select distinct JNO from table_spj
    );
    -- 建立供应商S1提供的所有商品种类表
    create temporary table if not exists all_s1_PNO as (
		select distinct PNO from table_spj where SNO='S1'
    );
    
    open cur;
    fetch cur into cur_pno, cur_jno;
    repeat
		-- 符合商品种类
		select @j_in_s1 := count(*) from all_s1_PNO where PNO=cur_pno;
		if @j_in_s1 then
			-- 计数加1
			update cnt_table set cnt=cnt+1 where JNO=cur_jno;
		end if;
		fetch cur into cur_pno, cur_jno;
    until done=1 end repeat;
    close cur;
    
    select @total_sum := count(*) from all_s1_PNO;
    select JNO from cnt_table where cnt = @total_sum;
    
    drop table cnt_table;    
	drop table all_s1_PNO;	
end //
delimiter ;
SET SQL_SAFE_UPDATES = 0;
call chooseJNO_all_s1();
SET SQL_SAFE_UPDATES = 1;
drop procedure if exists chooseJNO_all_s1;


# 解法3
select JNO from (select distinct JNO from table_spj) t1 where not exists
	(select * from (select distinct PNO from table_spj where SNO='S1') t2 where not exists
		(select  * from table_spj t3 where t3.JNO=t1.JNO and t3.PNO=t2.PNO ));