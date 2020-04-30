#已经创建了数据库firstMySQL : CREATE DATABASE firstMySQL;
USE firstMySQL;

drop table if exists table_spj;
drop table if exists table_j;
drop table if exists table_p;
drop table if exists table_s;

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

# 为了更好地测试性能，关闭mysql缓存
# set global query_cache_size = 0;
# set global query_cache_type = off;

#show variables like '%pro%';
#set profiling=1;
# 直接使用show profile来查看上一条SQL语句的开销信息
# 本来想看看实现同一功能的不同sql语句之间效率的区别，但是数据量太小，结果不稳定，不好比较。