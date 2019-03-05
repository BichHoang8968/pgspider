--SET log_min_messages=debug1;
--SET client_min_messages=debug1;
SET datestyle=ISO;
-- timestamp with time zone differs based on this
SET timezone='UTC';

CREATE EXTENSION influxdb_fdw;
CREATE SERVER server1 FOREIGN DATA WRAPPER influxdb_fdw OPTIONS
(dbname 'axhst', host 'http://133.113.27.101', port '8086') ;
CREATE USER MAPPING FOR CURRENT_USER SERVER server1 OPTIONS(user '', password '');

IMPORT FOREIGN SCHEMA public FROM SERVER server1 INTO public;

-- original influxdb query of PKB case1
-- SELECT LAST(v) AS v, LAST(q) AS q, LAST(vr) AS vr FROM hist WHERE (time >= '2016-01-01T00:00:00Z') AND (time <= '2016-01-01T00:00:00Z'+4h) AND (iid='JPNTSB_010101000000000000' OR iid='JPNTSB_010101000000000001' OR iid='JPNTSB_010201000000000002') GROUP BY influx_time(time, interval '1h', interval '1451606400000001u'),iid;

-- query rewritten for postgres
SELECT iid, LAST(time,v) AS v, LAST(time,q) AS q, LAST(time,vr) AS vr FROM hist WHERE
 (time >= '2016-01-01T00:00:00Z') AND (time <= timestamp '2016-01-01T00:00:00Z'+interval '4h') AND 
 (iid='JPNTSB_010101000000000000' OR iid='JPNTSB_010101000000000001' OR iid='JPNTSB_010201000000000002') 
 GROUP BY influx_time(time, interval '1h', interval '1451606400.000001s'),iid;