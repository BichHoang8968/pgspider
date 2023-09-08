\set ECHO none
\ir sql/gitlab_fdw/parameters.conf
\set ECHO all
SET timezone TO 0;
SET datestyle TO ISO;
SET intervalstyle to "postgres";

--Testcase 1:
CREATE EXTENSION IF NOT EXISTS pgspider_core_fdw;

--Testcase 2:
CREATE SERVER pgspider_core_srv FOREIGN DATA WRAPPER pgspider_core_fdw OPTIONS (host '127.0.0.1', port '50849');
--Testcase 3:
CREATE USER mapping for public server pgspider_core_srv;
--Testcase 4:
CREATE EXTENSION gitlab_fdw;

--Testcase 5:
CREATE SERVER gitlab_svr1 FOREIGN DATA WRAPPER gitlab_fdw OPTIONS (endpoint :END_POINT_1, ssl_verifypeer 'false');
--Testcase 6:
CREATE USER MAPPING FOR public SERVER gitlab_svr1 OPTIONS (access_token :ACCESS_TOKEN_1);
--Testcase 7:
CREATE SERVER gitlab_svr2 FOREIGN DATA WRAPPER gitlab_fdw OPTIONS (endpoint :END_POINT_2, ssl_verifypeer 'false');
--Testcase 8:
CREATE USER MAPPING FOR public SERVER gitlab_svr2 OPTIONS (access_token :ACCESS_TOKEN_2);

--Testcase 9:
CREATE MULTI TENANT TABLE projects (id bigint, description text, name text, name_with_namespace text, "path" text, path_with_namespace text, created_at timestamp with time zone, default_branch text, ssh_url_to_repo text, http_url_to_repo text, web_url text, readme_url text, avatar_url text, forks_count bigint, star_count bigint, last_activity_at timestamp with time zone, __spd_url text) MULTI TENANT pgspider_core_srv;

--Testcase 10:
CREATE FOREIGN TABLE projects__gitlab_svr1__0 (id bigint, description text, name text, name_with_namespace text, "path" text, path_with_namespace text, created_at timestamp with time zone, default_branch text, ssh_url_to_repo text, http_url_to_repo text, web_url text, readme_url text, avatar_url text, forks_count bigint, star_count bigint, last_activity_at timestamp with time zone) SERVER gitlab_svr1 OPTIONS (resource_name 'projects');

--Testcase 11:
CREATE FOREIGN TABLE projects__gitlab_svr2__0 (id bigint, description text, name text, name_with_namespace text, "path" text, path_with_namespace text, created_at timestamp with time zone, default_branch text, ssh_url_to_repo text, http_url_to_repo text, web_url text, readme_url text, avatar_url text, forks_count bigint, star_count bigint, last_activity_at timestamp with time zone) SERVER gitlab_svr2 OPTIONS (resource_name 'projects');

-- SELECT column
--Testcase 12:
EXPLAIN VERBOSE SELECT id FROM projects ORDER BY id;
--Testcase 13:
SELECT id FROM projects ORDER BY id;

-- Select  columns of each resource with WHERE filter: single condition of column (=, <=, >=, like...), multi condition with AND, OR
--Testcase 14:
EXPLAIN VERBOSE SELECT description, name, name_with_namespace, default_branch, ssh_url_to_repo FROM projects WHERE description IS NOT NULL AND default_branch = 'master' ORDER BY 1, 2, 3, 4, 5;
--Testcase 15:
SELECT description, name, name_with_namespace, default_branch, ssh_url_to_repo FROM projects WHERE description IS NOT NULL AND default_branch = 'master' ORDER BY 1, 2, 3, 4, 5;
--Testcase 16:
EXPLAIN VERBOSE SELECT id, description, name, name_with_namespace, "path", path_with_namespace, created_at, default_branch, ssh_url_to_repo, http_url_to_repo, web_url, readme_url, avatar_url, forks_count, star_count, last_activity_at FROM projects ORDER BY id, description, name, name_with_namespace;
--Testcase 17:
SELECT id, description, name, name_with_namespace, "path", path_with_namespace, created_at, default_branch, ssh_url_to_repo, http_url_to_repo, web_url, readme_url, avatar_url, forks_count, star_count, last_activity_at FROM projects ORDER BY id, description, name, name_with_namespace;
--Testcase 18:
EXPLAIN VERBOSE SELECT * FROM projects WHERE default_branch != 'main' ORDER BY id, __spd_url;
--Testcase 19:
SELECT * FROM projects WHERE default_branch != 'main' ORDER BY id, __spd_url;
--Testcase 20:
EXPLAIN VERBOSE SELECT description, name, name_with_namespace, forks_count, star_count FROM projects WHERE description >= 'Test' AND name = 'test_project_gitlab_1' ORDER BY 1, 2, 3, 4, 5;
--Testcase 21:
SELECT description, name, name_with_namespace, forks_count, star_count FROM projects WHERE description >= 'Test' AND name = 'test_project_gitlab_1' ORDER BY 1, 2, 3, 4, 5;

-- SELECT columns with LIMIT/OFFSET/ORDER BY
--Testcase 22:
EXPLAIN VERBOSE SELECT name_with_namespace, default_branch, path_with_namespace FROM projects ORDER BY 1, 2, 3 LIMIT 5;
--Testcase 23:
SELECT name_with_namespace, default_branch, path_with_namespace FROM projects ORDER BY 1, 2, 3 LIMIT 5;
--Testcase 24:
EXPLAIN VERBOSE SELECT id, description, name, http_url_to_repo FROM projects ORDER BY id LIMIT 3 OFFSET 2;
--Testcase 25:
SELECT id, description, name, http_url_to_repo FROM projects ORDER BY id LIMIT 3 OFFSET 2;
--Testcase 26:
EXPLAIN VERBOSE SELECT star_count, forks_count, web_url FROM projects WHERE star_count > 0 AND forks_count >= 0 ORDER BY 1, 2, 3 LIMIT 10 OFFSET 1;
--Testcase 27:
SELECT star_count, forks_count, web_url FROM projects WHERE star_count > 0 AND forks_count >= 0 ORDER BY 1, 2, 3 LIMIT 10 OFFSET 1;
--Testcase 28:
EXPLAIN VERBOSE SELECT readme_url, name, "path" FROM projects WHERE star_count = 0 OR forks_count = 0 ORDER BY 1, 2, 3 LIMIT 10 OFFSET 3;
--Testcase 29:
SELECT readme_url, name, "path" FROM projects WHERE star_count = 0 OR forks_count = 0 ORDER BY 1, 2, 3 LIMIT 10 OFFSET 3;

-- select Aggregation function, group by, having and join
--Testcase 30:
EXPLAIN VERBOSE SELECT (SELECT max((SELECT i.id FROM projects i WHERE i.id = o.id LIMIT 1))) FROM projects o;
--Testcase 31:
SELECT (SELECT max((SELECT i.id FROM projects i WHERE i.id = o.id  LIMIT 1))) FROM projects o;
--Testcase 32:
EXPLAIN VERBOSE SELECT count(*) FROM projects;
--Testcase 33:
SELECT count(*) FROM projects;
--Testcase 34:
EXPLAIN VERBOSE SELECT avg(forks_count), sum(star_count) FROM projects;
--Testcase 35:
SELECT avg(forks_count), sum(star_count) FROM projects;
--Testcase 36:
EXPLAIN VERBOSE SELECT name, sum(forks_count) + sum(star_count) FROM projects GROUP BY name HAVING name >= 'test' ORDER BY name;
--Testcase 37:
SELECT name, sum(forks_count) + sum(star_count) FROM projects GROUP BY name HAVING name >= 'test' ORDER BY name;

-- select data with combine conditions
--Testcase 38:
EXPLAIN VERBOSE SELECT count(*)
FROM
  (SELECT t3.id AS x1
   FROM projects t1
   LEFT JOIN projects t2 ON t1.id = t2.id
   JOIN projects t3 ON t1.name = t3.name) ss,
  projects t4,
  projects t5
WHERE t4.name_with_namespace = t5.name_with_namespace AND ss.x1 = t4.id;
--Testcase 39:
SELECT count(*)
FROM
  (SELECT t3.id AS x1
   FROM projects t1
   LEFT JOIN projects t2 ON t1.id = t2.id
   JOIN projects t3 ON t1.name = t3.name) ss,
  projects t4,
  projects t5
WHERE t4.name_with_namespace = t5.name_with_namespace AND ss.x1 = t4.id;


--Testcase 40:
DROP EXTENSION gitlab_fdw CASCADE;
--Testcase 41:
DROP EXTENSION pgspider_core_fdw CASCADE;

