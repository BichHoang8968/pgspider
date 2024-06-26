\set ECHO none
\ir sql/redmine/parameters.conf
\set ECHO all

SET timezone TO 0;
SET datestyle TO ISO;
SET intervalstyle to "postgres";
DELETE FROM pg_spd_node_info;
--Testcase 1:
CREATE EXTENSION IF NOT EXISTS pgspider_core_fdw;

--Testcase 2:
CREATE SERVER pgspider_srv FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host :PGSPIDER_HOST, port :PGSPIDER_PORT);
--Testcase 3:
CREATE USER mapping for public server pgspider_srv OPTIONS (user :PGSPIDER_USER, password :PGSPIDER_PASS);
--Testcase 4:
CREATE EXTENSION redmine_fdw;
--Testcase 5:
CREATE SERVER redmine_svr_1 FOREIGN DATA WRAPPER redmine_fdw OPTIONS (endpoint :REDMINE_ENDPOINT_1);
--Testcase 6:
CREATE USER MAPPING FOR public SERVER redmine_svr_1 OPTIONS (user :USERNAME_1, password :PASSWORD_1);
--Testcase 7:
CREATE SERVER redmine_svr_2 FOREIGN DATA WRAPPER redmine_fdw OPTIONS (endpoint :REDMINE_ENDPOINT_2);
--Testcase 8:
CREATE USER MAPPING FOR public SERVER redmine_svr_2 OPTIONS (user :USERNAME_2, password :PASSWORD_2);

-- Create foreign table
--Testcase 9:
CREATE MULTI TENANT TABLE issues (id bigint, project id_name_type, tracker id_name_type, status id_name_type, priority id_name_type, author id_name_type, assigned_to id_name_type, parent_id bigint, subject text, description text, start_date date, due_date date, done_ratio bigint, is_private boolean, estimated_hours double precision, total_estimated_hours double precision, spent_hours double precision, total_spent_hours double precision, created_on timestamp with time zone, updated_on timestamp with time zone, closed_on timestamp with time zone, attachments attachment_type[], relations issue_relation_type[], children children_type[], watchers id_name_type[], __spd_url text) MULTI TENANT pgspider_srv;

-- Create foreign table for issue of server 1
--Testcase 10:
CREATE FOREIGN TABLE issues__redmine_svr_1__0 (id bigint, project id_name_type, tracker id_name_type, status id_name_type, priority id_name_type, author id_name_type, assigned_to id_name_type, parent_id bigint, subject text, description text, start_date date, due_date date, done_ratio bigint, is_private boolean, estimated_hours double precision, total_estimated_hours double precision, spent_hours double precision, total_spent_hours double precision, created_on timestamp with time zone, updated_on timestamp with time zone, closed_on timestamp with time zone, attachments attachment_type[], relations issue_relation_type[], children children_type[], watchers id_name_type[]) SERVER redmine_svr_1 OPTIONS (project_id :'PROJECT_ID_1', resource_name 'issues');

--Testcase 11:
CREATE FOREIGN TABLE issues__redmine_svr_1__1 (id bigint, project id_name_type, tracker id_name_type, status id_name_type, priority id_name_type, author id_name_type, assigned_to id_name_type, parent_id bigint, subject text, description text, start_date date, due_date date, done_ratio bigint, is_private boolean, estimated_hours double precision, total_estimated_hours double precision, spent_hours double precision, total_spent_hours double precision, created_on timestamp with time zone, updated_on timestamp with time zone, closed_on timestamp with time zone, attachments attachment_type[], relations issue_relation_type[], children children_type[], watchers id_name_type[]) SERVER redmine_svr_1 OPTIONS (project_id :'PROJECT_ID_2', resource_name 'issues');

--Testcase 12:
CREATE FOREIGN TABLE issues__redmine_svr_1__2 (id bigint, project id_name_type, tracker id_name_type, status id_name_type, priority id_name_type, author id_name_type, assigned_to id_name_type, parent_id bigint, subject text, description text, start_date date, due_date date, done_ratio bigint, is_private boolean, estimated_hours double precision, total_estimated_hours double precision, spent_hours double precision, total_spent_hours double precision, created_on timestamp with time zone, updated_on timestamp with time zone, closed_on timestamp with time zone, attachments attachment_type[], relations issue_relation_type[], children children_type[], watchers id_name_type[]) SERVER redmine_svr_1 OPTIONS (project_id :'PROJECT_ID_3', resource_name 'issues');

--Testcase 13:
EXPLAIN VERBOSE SELECT * FROM issues ORDER BY 1, 2, 3, 4, 5, __spd_url;
--Testcase 14:
SELECT * FROM issues ORDER BY 1, 2, 3, 4, 5, __spd_url;

-- Create foreign table for issue of server 2
--Testcase 15:
CREATE FOREIGN TABLE issues__redmine_svr_2__0 (id bigint, project id_name_type, tracker id_name_type, status id_name_type, priority id_name_type, author id_name_type, assigned_to id_name_type, parent_id bigint, subject text, description text, start_date date, due_date date, done_ratio bigint, is_private boolean, estimated_hours double precision, total_estimated_hours double precision, spent_hours double precision, total_spent_hours double precision, created_on timestamp with time zone, updated_on timestamp with time zone, closed_on timestamp with time zone, attachments attachment_type[], relations issue_relation_type[], children children_type[], watchers id_name_type[]) SERVER redmine_svr_2 OPTIONS (project_id :'PROJECT_ID_4', resource_name 'issues');

--Testcase 16:
CREATE FOREIGN TABLE issues__redmine_svr_2__1 (id bigint, project id_name_type, tracker id_name_type, status id_name_type, priority id_name_type, author id_name_type, assigned_to id_name_type, parent_id bigint, subject text, description text, start_date date, due_date date, done_ratio bigint, is_private boolean, estimated_hours double precision, total_estimated_hours double precision, spent_hours double precision, total_spent_hours double precision, created_on timestamp with time zone, updated_on timestamp with time zone, closed_on timestamp with time zone, attachments attachment_type[], relations issue_relation_type[], children children_type[], watchers id_name_type[]) SERVER redmine_svr_2 OPTIONS (project_id :'PROJECT_ID_5', resource_name 'issues');

--Testcase 17:
CREATE FOREIGN TABLE issues__redmine_svr_2__2 (id bigint, project id_name_type, tracker id_name_type, status id_name_type, priority id_name_type, author id_name_type, assigned_to id_name_type, parent_id bigint, subject text, description text, start_date date, due_date date, done_ratio bigint, is_private boolean, estimated_hours double precision, total_estimated_hours double precision, spent_hours double precision, total_spent_hours double precision, created_on timestamp with time zone, updated_on timestamp with time zone, closed_on timestamp with time zone, attachments attachment_type[], relations issue_relation_type[], children children_type[], watchers id_name_type[]) SERVER redmine_svr_2 OPTIONS (project_id :'PROJECT_ID_6', resource_name 'issues');

--Testcase 18:
EXPLAIN VERBOSE SELECT * FROM issues ORDER BY 1, 2, 3, 4, 5, __spd_url;
--Testcase 19:
SELECT * FROM issues ORDER BY 1, 2, 3, 4, 5, __spd_url;

-- SELECT queries
-- Select column of each resource
--Testcase 20:
EXPLAIN VERBOSE SELECT subject FROM issues ORDER BY subject;
--Testcase 21:
SELECT subject FROM issues ORDER BY subject;
--Testcase 22:
EXPLAIN VERBOSE SELECT subject, project, description FROM issues ORDER BY 1, 2, 3;
--Testcase 23:
SELECT subject, project, description FROM issues ORDER BY 1, 2, 3;
--Testcase 24:
EXPLAIN VERBOSE SELECT author, created_on, subject, relations, children FROM issues ORDER BY 1, 2, 3, 4, 5;
--Testcase 25:
SELECT author, created_on, subject, relations, children FROM issues ORDER BY 1, 2, 3, 4, 5;
--Testcase 26:
EXPLAIN VERBOSE SELECT id, project, tracker, status, priority, author, assigned_to, parent_id, subject, description, start_date, due_date, done_ratio, is_private, estimated_hours, total_estimated_hours, spent_hours, total_spent_hours, created_on, updated_on, closed_on, attachments, relations, children, watchers FROM issues ORDER BY 1, 2, 3;
--Testcase 27:
SELECT id, project, tracker, status, priority, author, assigned_to, parent_id, subject, description, start_date, due_date, done_ratio, is_private, estimated_hours, total_estimated_hours, spent_hours, total_spent_hours, created_on, updated_on, closed_on, attachments, relations, children, watchers FROM issues ORDER BY 1, 2, 3;
--Testcase 28:
EXPLAIN VERBOSE SELECT created_on, relations, id, children, priority FROM issues ORDER BY 1, 2, 3, 4;
--Testcase 29:
SELECT created_on, relations, id, children, priority FROM issues ORDER BY 1, 2, 3, 4;
-- Select column of resouce with filter id
--Testcase 30:
EXPLAIN VERBOSE SELECT id, subject, author FROM issues WHERE id = 2445;
--Testcase 31:
SELECT id, subject, author FROM issues WHERE id = 2445;
--Testcase 32:
EXPLAIN VERBOSE SELECT tracker, status, priority FROM issues WHERE id >= 1 ORDER BY tracker, status, priority;
--Testcase 33:
SELECT tracker, status, priority FROM issues WHERE id >= 1 ORDER BY tracker, status, priority;
--Testcase 34:
EXPLAIN VERBOSE SELECT * FROM issues WHERE id <= 16 AND id >= 1 ORDER BY 1, 2, 3, 4, 5;
--Testcase 35:
SELECT * FROM issues WHERE id <= 16 AND id >= 1 ORDER BY 1, 2, 3, 4, 5;
--Testcase 36:
EXPLAIN VERBOSE SELECT author, assigned_to, parent_id FROM issues WHERE subject >= '@!' AND id >= 1 AND description != '' ORDER BY author, assigned_to, parent_id;
--Testcase 37:
SELECT author, assigned_to, parent_id FROM issues WHERE subject >= '@!' AND id >= 1 AND description != '' ORDER BY author, assigned_to, parent_id;
--Testcase 38:
EXPLAIN VERBOSE SELECT id, project, tracker, status, priority, author, assigned_to, parent_id, subject, total_estimated_hours, start_date, due_date, done_ratio, is_private, estimated_hours, total_estimated_hours, spent_hours, total_spent_hours, created_on, updated_on, closed_on, attachments, relations, children, watchers FROM issues WHERE id IN (5545, 8799, 2545, 87854, 2255) OR spent_hours > 0 ORDER BY 1, 2, 3, 4, 5;
--Testcase 39:
SELECT id, project, tracker, status, priority, author, assigned_to, parent_id, subject, total_estimated_hours, start_date, due_date, done_ratio, is_private, estimated_hours, total_estimated_hours, spent_hours, total_spent_hours, created_on, updated_on, closed_on, attachments, relations, children, watchers FROM issues WHERE id IN (5545, 8799, 2545, 87854, 2255) OR spent_hours > 0 ORDER BY 1, 2, 3, 4, 5;
-- Select columns of each resource with WHERE filter: single condition of column (=, <=, >=, like...), multi condition with AND, OR, filter using string parameter.
--Testcase 40:
EXPLAIN VERBOSE SELECT author, assigned_to, subject FROM issues WHERE done_ratio >= 20 AND (status).name = 'In progress';
--Testcase 41:
SELECT author, assigned_to, subject FROM issues WHERE done_ratio >= 20 AND (status).name = 'In progress';
--Testcase 42:
EXPLAIN VERBOSE SELECT subject, description, start_date FROM issues WHERE estimated_hours <= 10.5 AND is_private = FALSE ORDER BY subject, description, start_date;
--Testcase 43:
SELECT subject, description, start_date FROM issues WHERE estimated_hours <= 10.5 AND is_private = FALSE ORDER BY subject, description, start_date;
--Testcase 44:
EXPLAIN VERBOSE SELECT due_date, done_ratio, is_private FROM issues WHERE (project).name != 'Project_1' ORDER BY due_date, done_ratio, is_private;
--Testcase 45:
SELECT due_date, done_ratio, is_private FROM issues WHERE (project).name != 'Project_1' ORDER BY due_date, done_ratio, is_private;
--Testcase 46:
EXPLAIN VERBOSE SELECT estimated_hours, total_estimated_hours, spent_hours, total_spent_hours FROM issues WHERE (project).name = 'Project_1' AND (status).name = 'In progress' AND (priority).name = 'Normal' AND (tracker).name = 'Task' ORDER BY estimated_hours, total_estimated_hours, spent_hours, total_spent_hours;
--Testcase 47:
SELECT estimated_hours, total_estimated_hours, spent_hours, total_spent_hours FROM issues WHERE (project).name = 'Project_1' AND (status).name = 'In progress' AND (priority).name = 'Normal' AND (tracker).name = 'Task' ORDER BY estimated_hours, total_estimated_hours, spent_hours, total_spent_hours;
--Testcase 48:
EXPLAIN VERBOSE SELECT created_on, updated_on, closed_on, attachments FROM issues WHERE (project).name != 'Project_1' AND (tracker).name != 'issue' ORDER BY created_on, updated_on, closed_on, attachments;
--Testcase 49:
SELECT created_on, updated_on, closed_on, attachments FROM issues WHERE (project).name != 'Project_1' AND (tracker).name != 'issue' ORDER BY created_on, updated_on, closed_on, attachments;
--Testcase 50:
EXPLAIN VERBOSE SELECT relations, children, watchers FROM issues WHERE description IS NOT NULL AND id < 4534 AND spent_hours > 0 AND estimated_hours >= 4 ORDER BY id;
--Testcase 51:
SELECT relations, children, watchers FROM issues WHERE description IS NOT NULL AND id < 4534 AND spent_hours > 0 AND estimated_hours >= 4 ORDER BY id;
-- Select columns of resources with LIMIT
--Testcase 52:
EXPLAIN VERBOSE SELECT id, project, tracker, status FROM issues WHERE id BETWEEN 10 AND 14 ORDER BY id, project, tracker LIMIT 5;
--Testcase 53:
SELECT id, project, tracker, status FROM issues WHERE id BETWEEN 10 AND 14 ORDER BY id, project, tracker LIMIT 5;
--Testcase 54:
EXPLAIN VERBOSE SELECT priority, author, assigned_to, parent_id FROM issues WHERE description IS NOT NULL AND subject != 'aewfW' ORDER BY priority, author, assigned_to, parent_id LIMIT 3;
--Testcase 55:
SELECT priority, author, assigned_to, parent_id FROM issues WHERE description IS NOT NULL AND subject != 'aewfW' ORDER BY priority, author, assigned_to, parent_id LIMIT 3;
--Testcase 56:
EXPLAIN VERBOSE SELECT subject, author, start_date, due_date FROM issues ORDER BY subject, author, start_date, due_date LIMIT 5;
--Testcase 57:
SELECT subject, author, start_date, due_date FROM issues ORDER BY subject, author, start_date, due_date LIMIT 5;
--Testcase 58:
EXPLAIN VERBOSE SELECT done_ratio, is_private, estimated_hours, total_estimated_hours FROM issues WHERE done_ratio <= 60 AND estimated_hours >= 2.0 ORDER BY done_ratio, is_private, estimated_hours, total_estimated_hours LIMIT 3;
--Testcase 59:
SELECT done_ratio, is_private, estimated_hours, total_estimated_hours FROM issues WHERE done_ratio <= 60 AND estimated_hours >= 2.0 ORDER BY done_ratio, is_private, estimated_hours, total_estimated_hours LIMIT 3;
--Testcase 60:
EXPLAIN VERBOSE SELECT spent_hours, total_spent_hours, created_on, updated_on, closed_on FROM issues WHERE closed_on - created_on >= '1' OR spent_hours >= 3.5 ORDER BY spent_hours, total_spent_hours, created_on, updated_on, closed_on LIMIT 10;
--Testcase 61:
SELECT spent_hours, total_spent_hours, created_on, updated_on, closed_on FROM issues WHERE closed_on - created_on >= '1' OR spent_hours >= 3.5 ORDER BY spent_hours, total_spent_hours, created_on, updated_on, closed_on LIMIT 10;
--Testcase 62:
EXPLAIN VERBOSE SELECT spent_hours, total_spent_hours, estimated_hours, subject FROM issues WHERE total_spent_hours >= spent_hours ORDER BY spent_hours, total_spent_hours, estimated_hours, subject LIMIT 3 OFFSET 1;
--Testcase 63:
SELECT spent_hours, total_spent_hours, estimated_hours, subject FROM issues WHERE total_spent_hours >= spent_hours ORDER BY spent_hours, total_spent_hours, estimated_hours, subject LIMIT 3 OFFSET 1;
-- Select resources with OFFSET, ORDER BY
--Testcase 64:
EXPLAIN VERBOSE SELECT parent_id, author, subject, priority, status FROM issues ORDER BY subject LIMIT 5 OFFSET 1;
--Testcase 65:
SELECT parent_id, author, subject, priority, status FROM issues ORDER BY subject LIMIT 5 OFFSET 1;
--Testcase 66:
EXPLAIN VERBOSE SELECT start_date, due_date, created_on, updated_on, closed_on FROM issues WHERE subject <= 'issue%' AND id > 2 AND parent_id >= 1 ORDER BY id LIMIT 3 OFFSET 3;
--Testcase 67:
SELECT start_date, due_date, created_on, updated_on, closed_on FROM issues WHERE subject > 'issue%' AND id > 2 AND parent_id >= 1 ORDER BY id LIMIT 3 OFFSET 3;
--Testcase 68:
EXPLAIN VERBOSE SELECT * FROM (SELECT subject, (watchers[1]).id, (watchers[1]).name, (watchers[2]).id, (watchers[2]).name FROM issues) AS t(s, id1, name1, id2, name2) WHERE t.id1 >= 1 AND t.id2 <= 23 ORDER BY t.s, t.id1, t.id2, t.name1, t.name2 LIMIT 1 OFFSET 1;
--Testcase 69:
SELECT * FROM (SELECT subject, (watchers[1]).id, (watchers[1]).name, (watchers[2]).id, (watchers[2]).name FROM issues) AS t(s, id1, name1, id2, name2) WHERE t.id1 >= 1 AND t.id2 <= 23 ORDER BY t.s, t.id1, t.id2, t.name1, t.name2 LIMIT 1 OFFSET 1;
--Testcase 70:
EXPLAIN VERBOSE SELECT is_private, id, (project).id AS pid, (project).name AS pname, subject FROM issues WHERE is_private = FALSE AND id >= 1 ORDER BY id LIMIT 10 OFFSET 1;
--Testcase 71:
SELECT is_private, id, (project).id AS pid, (project).name AS pname, subject FROM issues WHERE is_private = FALSE AND id >= 1 ORDER BY id LIMIT 10 OFFSET 1;
--Testcase 72:
EXPLAIN VERBOSE SELECT due_date, status, priority, author, assigned_to FROM issues WHERE description IS NOT NULL AND (priority).id >= 2 ORDER BY (status).id, priority, due_date, author, assigned_to LIMIT 5 OFFSET 1;
--Testcase 73:
SELECT due_date, status, priority, author, assigned_to FROM issues WHERE description IS NOT NULL AND (priority).id >= 2 ORDER BY (status).id, priority, due_date, author, assigned_to LIMIT 5 OFFSET 1;
--Testcase 74:
EXPLAIN VERBOSE SELECT total_estimated_hours, estimated_hours, spent_hours, total_spent_hours, estimated_hours - spent_hours FROM issues WHERE spent_hours > 1 ORDER BY spent_hours, estimated_hours LIMIT 3 OFFSET 1;
--Testcase 75:
SELECT total_estimated_hours, estimated_hours, spent_hours, total_spent_hours, estimated_hours - spent_hours FROM issues WHERE spent_hours > 1 ORDER BY spent_hours, estimated_hours LIMIT 3 OFFSET 1;


--Testcase 76:
DROP FOREIGN TABLE issues__redmine_svr_1__0;
--Testcase 77:
DROP FOREIGN TABLE issues__redmine_svr_1__1;
--Testcase 78:
DROP FOREIGN TABLE issues__redmine_svr_1__2;
--Testcase 79:
DROP FOREIGN TABLE issues__redmine_svr_2__0;
--Testcase 80:
DROP FOREIGN TABLE issues__redmine_svr_2__1;
--Testcase 81:
DROP FOREIGN TABLE issues__redmine_svr_2__2;
--Testcase 82:
DROP MULTI TENANT TABLE issues CASCADE;
--Testcase 83:
DROP EXTENSION redmine_fdw CASCADE;
--Testcase 84:
DROP EXTENSION pgspider_core_fdw CASCADE;

