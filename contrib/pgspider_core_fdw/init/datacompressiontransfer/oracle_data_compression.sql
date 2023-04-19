alter session set "_ORACLE_SCRIPT"=true;
drop user test1 CASCADE;
drop user test2 CASCADE;
drop user test3 CASCADE;

create user test1 identified by test1;
grant all privileges to test1;
create user test2 identified by test2;
grant all privileges to test2;
create user test3 identified by test3;
grant all privileges to test3;
GRANT SELECT ANY DICTIONARY TO test1;
GRANT SELECT ANY DICTIONARY TO test2;
GRANT SELECT ANY DICTIONARY TO test3;
