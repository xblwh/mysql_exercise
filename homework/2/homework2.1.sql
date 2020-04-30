use firstMySQL;

create table if not exists Student (
	SNO int unsigned not null,
    SNAME char(20) not null,
    age int unsigned not null,
    sex boolean not null,	 /* 1 means male, 0 means female */
    address char(50) not null,
    classno int unsigned not null,
    
    primary key(SNO),
    foreign key(classno) references Class(classno)
) ENGINE=innodb, character set utf8;


create table if not exists Class (
	classno int unsigned not null,
    CNAME char(20) not null,
    teacher char(20) not null,
    monitor char(20) not null,
    
    primary key(classno)
) ENGINE=innodb, character set utf8;