#已经创建了数据库firstMySQL : CREATE DATABASE firstMySQL;
USE firstMySQL;

# S表
CREATE TABLE IF NOT EXISTS table_s(
	SNO    VARCHAR(10) NOT NULL,
    SNAME  VARCHAR(20) NOT NULL,
    STATUS INT NOT NULL,
    CITY   VARCHAR(20) NOT NULL,
    PRIMARY KEY(SNO)
)ENGINE=innodb, character set utf8;

INSERT IGNORE INTO table_s(SNO, SNAME, STATUS, CITY) 
VALUES(
	'S1', '精益',20,'天津'
),(
	'S2', '盛锡',10,'北京'
),(
	'S3', '东方红',30,'北京'
),(
	'S4', '丰泰盛',20,'天津'
),(
	'S5', '为民',30,'上海'
);


# P表
CREATE TABLE IF NOT EXISTS table_p(
	PNO    VARCHAR(10) NOT NULL,
    PNAME  VARCHAR(20) NOT NULL,
	COLOR  VARCHAR(10) NOT NULL,
    WEIGHT INT NOT NULL,
    PRIMARY KEY(PNO)
)ENGINE=innodb, character set utf8;

INSERT IGNORE INTO table_p(PNO, PNAME,COLOR, WEIGHT) 
VALUES(
	'P1', '螺母','红',12
),(
	'P2', '螺栓','绿',17
),(
	'P3', '螺丝刀','蓝',14
),(
	'P4', '螺丝刀','红',14
),(
	'P5', '凸轮','蓝',40
),(
	'P6', '齿轮','红',30
);


# J表
CREATE TABLE IF NOT EXISTS table_j(
	JNO    VARCHAR(10) NOT NULL,
    JNAME  VARCHAR(30) NOT NULL,
	CITY   VARCHAR(10) NOT NULL,
    PRIMARY KEY(JNO)
)ENGINE=innodb, character set utf8;

INSERT IGNORE INTO table_j(JNO, JNAME, CITY) 
VALUES(
	'J1', '三建','北京'
),(
	'J2', '一汽','长春'
),(
	'J3', '弹簧厂','天津'
),(
	'J4', '造船厂','天津'
),(
	'J5', '机车厂','唐山'
),(
	'J6', '无线电厂','常州'
),(
	'J7', '半导体厂','南京'
);


# SPJ表
CREATE TABLE IF NOT EXISTS table_spj(
	id	   int unsigned auto_increment not null,
	SNO    VARCHAR(10) NOT NULL,
    PNO    VARCHAR(10) NOT NULL,
	JNO    VARCHAR(10) NOT NULL,
    QTY	   int unsigned not null,
    
    PRIMARY KEY(id),
    FOREIGN KEY(SNO) REFERENCES table_s(SNO),
    FOREIGN KEY(JNO) REFERENCES table_j(JNO),
    FOREIGN KEY(PNO) REFERENCES table_p(PNO)
)ENGINE=innodb, character set utf8;

INSERT IGNORE INTO table_spj(id, SNO, PNO, JNO, QTY) 
VALUES(
	null, 'S1', 'P1', 'J1', 200
),(
	null, 'S1', 'P1', 'J3', 100
),(
	null, 'S1', 'P1', 'J4', 700
),(
	null, 'S1', 'P2', 'J2', 100
),(
	null, 'S2', 'P3', 'J1', 400
),(
	null, 'S2', 'P3', 'J2', 200
),(
	null, 'S2', 'P3', 'J4', 500
),(
	null, 'S2', 'P3', 'J5', 400
),(
	null, 'S2', 'P5', 'J1', 400
),(
	null, 'S2', 'P5', 'J2', 100
),(
	null, 'S3', 'P1', 'J1', 200
),(
	null, 'S3', 'P3', 'J1', 200
),(
	null, 'S4', 'P5', 'J1', 100
),(
	null, 'S4', 'P6', 'J3', 300
),(
	null, 'S4', 'P6', 'J4', 200
),(
	null, 'S5', 'P2', 'J4', 100
),(
	null, 'S5', 'P3', 'J1', 200
),(
	null, 'S5', 'P6', 'J2', 200
),(
	null, 'S5', 'P6', 'J4', 500
);


-- ---------------------------------------------------------
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

# （4）求没有使用天津供应商生产的红色零件的工程号JNO
# 方法1
create view tianjin_red as (
  select a.SNO, b.PNO from (
	select SNO from table_s where table_s.CITY='天津') a, (
    select PNO from table_p where table_p.COLOR='红') b
);
select distinct a.JNO from (select distinct JNO from table_spj) a where
	a.JNO not in (select distinct JNO from table_spj, tianjin_red where table_spj.SNO=tianjin_red.SNO and table_spj.PNO=tianjin_red.PNO);

#方法2
select distinct JNO from table_spj where JNO not in (
	select JNO from table_spj,table_s,table_p where table_spj.SNO=table_s.SNO and table_spj.PNO=table_p.PNO and
		table_s.CITY='天津' and table_p.COLOR='红');


# （5）求至少用了供应商S1所供应的全部零件的工程号JNO
select distinct PNO from table_spj where table_spj.SNO='S1';  #P1,P2
select distinct JNO from table_spj where PNO='P1' and JNO in (select JNO from table_spj where PNO = 'P2');


# 使用存储过程求解(非硬编码)
select JNO from (select distinct JNO from table_spj) t1 where not exists
	(select * from (select distinct PNO from table_spj where SNO='S1') t2 where not exists
		(select  * from table_spj t3 where t3.JNO=t1.JNO and t3.PNO=t2.PNO ));
        

-- -------------------------------------------------
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

#(7) 找出没有使用天津产的零件的工程名称
# 方法1
select distinct JNO from (select distinct JNO from table_spj) t1 where not exists(
		select * from table_spj t2 where t2.JNO=t1.JNO and t2.SNO in (select SNO from table_s where CITY='天津'));
# 方法2
select distinct JNO from table_spj where JNO not in (select distinct JNO from table_spj t1, table_s t2 where t1.SNO=t2.SNO and t2.CITY='天津');

#(8)
set sql_safe_updates=0;
update table_p set COLOR='蓝' where color='红';

#(9)
update table_spj set SNO='S3' where SNO='S4' and PNO='P6' and JNO='J4';

#(10)
delete from table_spj where SNO='S2';
delete from table_s where SNO='S2';

#(11)
insert into table_spj (SNO,JNO,PNO,QTY) values('S2','J6','P4',200);


-- ----------------------------------------
# 3.9
create view sanjian_view as (
	select SNO,PNO,QTY from table_spj where JNO in (select JNO from table_j where JNAME='三建') );

#(1)
select PNO,sum(QTY) from sanjian_view group by PNO;

#(2)
select PNO,QTY from sanjian_view where SNO='S1';