CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '../../test.db');
CREATE FOREIGN TABLE department(department_id int OPTIONS (key 'true'), department_name text) SERVER sqlite_svr; 
CREATE FOREIGN TABLE employee(emp_id int OPTIONS (key 'true'), emp_name text, emp_dept_id int) SERVER sqlite_svr;
CREATE FOREIGN TABLE empdata(emp_id int OPTIONS (key 'true'), emp_dat bytea) SERVER sqlite_svr;
CREATE FOREIGN TABLE numbers(a int OPTIONS (key 'true'), b varchar(255)) SERVER sqlite_svr;
CREATE FOREIGN TABLE multiprimary(a int, b int OPTIONS (key 'true'), c int OPTIONS(key 'true')) SERVER sqlite_svr;

SELECT * FROM department LIMIT 10;
SELECT * FROM employee LIMIT 10;
SELECT * FROM empdata LIMIT 10;

INSERT INTO department VALUES(generate_series(1,100), 'dept - ' || generate_series(1,100));
INSERT INTO employee VALUES(generate_series(1,100), 'emp - ' || generate_series(1,100), generate_series(1,100));
INSERT INTO empdata  VALUES(1, decode ('01234567', 'hex'));

insert into numbers values(1, 'One');
insert into numbers values(2, 'Two');
insert into numbers values(3, 'Three');
insert into numbers values(4, 'Four');
insert into numbers values(5, 'Five');
insert into numbers values(6, 'Six');
insert into numbers values(7, 'Seven');
insert into numbers values(8, 'Eight');
insert into numbers values(9, 'Nine');

SELECT count(*) FROM department;
SELECT count(*) FROM employee;
SELECT count(*) FROM empdata;

EXPLAIN (COSTS FALSE) SELECT * FROM department d, employee e WHERE d.department_id = e.emp_dept_id LIMIT 10;

EXPLAIN (COSTS FALSE) SELECT * FROM department d, employee e WHERE d.department_id IN (SELECT department_id FROM department) LIMIT 10;

SELECT * FROM department d, employee e WHERE d.department_id = e.emp_dept_id LIMIT 10;
SELECT * FROM department d, employee e WHERE d.department_id IN (SELECT department_id FROM department) LIMIT 10;
SELECT * FROM empdata;

DELETE FROM employee WHERE emp_id = 10;

SELECT COUNT(*) FROM department LIMIT 10;
SELECT COUNT(*) FROM employee WHERE emp_id = 10;

UPDATE employee SET emp_name = 'Updated emp' WHERE emp_id = 20;
SELECT emp_id, emp_name FROM employee WHERE emp_name like 'Updated emp';

UPDATE empdata SET emp_dat = decode ('0123', 'hex');
SELECT * FROM empdata;

SELECT * FROM employee LIMIT 10;
SELECT * FROM employee WHERE emp_id IN (1);
SELECT * FROM employee WHERE emp_id IN (1,3,4,5);
SELECT * FROM employee WHERE emp_id IN (10000,1000);

SELECT * FROM employee WHERE emp_id NOT IN (1) LIMIT 5;
SELECT * FROM employee WHERE emp_id NOT IN (1,3,4,5) LIMIT 5;
SELECT * FROM employee WHERE emp_id NOT IN (10000,1000) LIMIT 5;

SELECT * FROM employee WHERE emp_id NOT IN (SELECT emp_id FROM employee WHERE emp_id IN (1,10));
SELECT * FROM employee WHERE emp_name NOT IN ('emp - 1', 'emp - 2') LIMIT 5;
SELECT * FROM employee WHERE emp_name NOT IN ('emp - 10') LIMIT 5;


create or replace function test_param_where() returns void as $$
DECLARE
  n varchar;
BEGIN
  FOR x IN 1..9 LOOP
    select b into n from numbers where a=x;
    raise notice 'Found number %', n;
  end loop;
  return;
END
$$ LANGUAGE plpgsql;
SELECT test_param_where();

select b from numbers where a=1;
EXPLAIN(COSTS OFF) select b from numbers where a=1;

SELECT a FROM numbers WHERE b = (SELECT NULL::text);


PREPARE stmt1 (int, int) AS
  SELECT * FROM numbers WHERE a=$1 or a=$2;
EXECUTE stmt1(1,2);
EXECUTE stmt1(2,2); 
EXECUTE stmt1(3,2); 
EXECUTE stmt1(4,2); 
EXECUTE stmt1(5,2); -- generic plan
EXECUTE stmt1(6,2); 
EXECUTE stmt1(7,2); 

DELETE FROM employee;
DELETE FROM department;
DELETE FROM empdata;
DELETE FROM numbers;

BEGIN;
insert into numbers values(1, 'One');
insert into numbers values(2, 'Two');
COMMIT;

select * from numbers;

BEGIN;
insert into numbers values(3, 'Three');
ROLLBACK;
select * from numbers;

BEGIN;
insert into numbers values(4, 'Four');
SAVEPOINT my_savepoint;
insert into numbers values(5, 'Five');
ROLLBACK TO SAVEPOINT my_savepoint;
insert into numbers values(6, 'Six');
COMMIT;

select * from numbers;

insert into numbers values(1, 'One');
delete from numbers;

BEGIN;
insert into numbers values(1, 'One');
insert into numbers values(2, 'Two');
COMMIT;

-- violate unique constraint
update numbers set b='Two' where a = 1; 
select * from numbers;

-- push down
explain (costs off) select * from numbers where  a = any(ARRAY[2,3,4,5]::int[]);
-- (1,2,3) is pushed down
explain (costs off) select * from numbers where a in (1,2,3) and (1,2) < (a,5);

-- not push down
explain (costs off) select * from numbers where a in (a+2*a,5);
explain (costs off) select * from numbers where  a = any(ARRAY[1,2,a]::int[]);

select * from numbers where  a = any(ARRAY[2,3,4,5]::int[]);
select * from numbers where  a = any(ARRAY[1,2,a]::int[]);

insert into multiprimary values(1,2,3);
insert into multiprimary values(1,2,4);
update multiprimary set b = 10 where c = 3;
select * from multiprimary;
update multiprimary set a = 10 where a = 1;
select * from multiprimary;
update multiprimary set a = 100, b=200, c=300 where a=10 and b=10;
select * from multiprimary;
update multiprimary set a = 1234;
select * from multiprimary;
update multiprimary set a = a+1, b=b+1 where b=200 and c=300;
select * from multiprimary;
delete from multiprimary where a = 1235;
select * from multiprimary;
delete from multiprimary where b = 2;
select * from multiprimary;

insert into multiprimary values(1,2,3);
insert into multiprimary values(1,2,4);
insert into multiprimary values(1,10,20);
insert into multiprimary values(2,20,40);

select count(distinct a) from multiprimary;
explain (costs off, verbose) select count(distinct a) from multiprimary;

select sum(b),max(b), min(b), avg(b) from multiprimary;
explain (costs off, verbose) select sum(b),max(b), min(b), avg(b) from multiprimary;

select sum(b)/2 from multiprimary group by b/2 order by b/2;
explain (costs off, verbose) select sum(b)/2 from multiprimary group by b/2 order by b/2;

select sum(a) from multiprimary group by b having sum(a) > 0 order by sum(a);
explain (costs off, verbose) select sum(a) from multiprimary group by b having sum(a) > 0;

select sum(a) A from multiprimary group by b having avg(abs(a)) > 0 and sum(a) > 0 order by A;
explain (costs off, verbose) select sum(a) from multiprimary group by b having avg(a^2) > 0 and sum(a) > 0;

select * from multiprimary, numbers where multiprimary.a=numbers.a;
explain (costs off, verbose) select * from multiprimary, numbers where multiprimary.a=numbers.a;

DROP FUNCTION test_param_where();
DROP FOREIGN TABLE numbers;
DROP FOREIGN TABLE department;
DROP FOREIGN TABLE employee;
DROP FOREIGN TABLE empdata;
DROP FOREIGN TABLE multiprimary;
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw CASCADE;

