-- 6 此处关于SML语法，而非mySQL语法
Student (SNO,SNAME,age,sex,address,classno,)
Class (classno,CNAME,teacher,monitor)

-- (1)
grant all priviliges on firstMySQL.Student to U1 with grant option;
grant all priviliges on firstMySQL.Class to U1 with grant option;

-- (2)
grant select on table Student to U2;

create view Student_address as (
	select address from Student);
grant update,delete on table Student_address to U2;

-- (3)
grant select on table Class to public;

-- (4)
create role 'R1';
grant select,update on table Student to R1;

-- (5)
grant R1 to U1 with admin option;



-- (7) (8)
employee(eno, name, age, job, salary, dno)
department(dno, name, manager, address, tele)
-- (1)
grant select on table employee, department to WangMing
revoke select on table employee, department from WangMing

-- (2)
grant insert,delete on table employee,department to LiYong
revoke insert,delete on table employee,department from LiYong

-- (3)
create view someTable as (
	select * from employee where name=someone
)
grant select on table someTable to someone
revoke select on table someTable from someone

-- (4)
grant select,update(salary) on table employee to LiuXing
revoke select,update(salary) on table employee from LiuXing

-- (5)
grant alter table on table employee, department to ZhangXin
revoke alter table on table employee, department from ZhangXin

-- (6)
grant all priviliges on table employee, department to ZhouPing with grant option
revoke all priviliges on table employee, department from ZhouPing

-- (7)
create view departmentSalary as (
	select D.name,avg(salary),max(salary),min(salary) from employee E,department D where
		E.dno=D.dno group by D.dno
)
grant select on departmentSalary to YangLan
revoke select on departmentSalary from YangLan









