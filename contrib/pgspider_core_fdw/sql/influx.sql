--SET log_min_messages=debug1;
--SET client_min_messages=debug1;

SET datestyle = ISO;

-- timestamp with time zone differs based on this

SET timezone = 'UTC';

CREATE EXTENSION pgspider_core_fdw;

CREATE SERVER pgspider_svr FOREIGN DATA WRAPPER pgspider_core_fdw;

CREATE EXTENSION influxdb_fdw;

CREATE SERVER server1 FOREIGN DATA WRAPPER influxdb_fdw OPTIONS (
    dbname 'axhst',
    host 'http://133.113.27.101',
    port '8086'
);

--NO_PROXY=133.113.27.101 influx -host '133.113.27.101' -port '8086' -database 'axhst'

CREATE USER MAPPING FOR CURRENT_USER SERVER server1 OPTIONS (
    USER '',
    PASSWORD ''
);

IMPORT FOREIGN SCHEMA public
FROM
    SERVER server1 INTO public;

-- original influxdb query of PKB case1
-- SELECT LAST(v) AS v, LAST(q) AS q, LAST(vr) AS vr FROM hist WHERE (time >= '2016-01-01T00:00:00Z') AND (time <= '2016-01-01T00:00:00Z'+4h) AND (iid='JPNTSB_010101000000000000' OR iid='JPNTSB_010101000000000001' OR iid='JPNTSB_010201000000000002') GROUP BY influx_time(time, interval '1h', interval '1451606400000001u'),iid;

CREATE FOREIGN TABLE hist (
    time timestamp WITH time zone,
    iid text,
    q bigint,
    ts bigint,
    v float8,
    vr text,
    __spd_url text
) SERVER pgspider_svr;

CREATE FOREIGN TABLE hist__server1__0 (
    time timestamp WITH time zone,
    iid text,
    q bigint,
    ts bigint,
    v float8,
    vr text,
    __spd_url text
) SERVER server1 OPTIONS (
    TABLE 'hist'
);

--SELECT * FROM hist WHERE iid='JPNTSB_010101000000000000' OR iid='JPNTSB_010101000000000001' OR iid='JPNTSB_010201000000000002'
--GROUP BY iid ORDER BY time DESC LIMIT 2;
-- query rewritten for postgres

(SELECT * FROM hist WHERE iid='JPNTSB_010101000000000000' ORDER BY time DESC LIMIT 2)
UNION ALL
(SELECT * FROM hist WHERE iid= 'JPNTSB_010101000000000001' ORDER BY time DESC LIMIT 2)
UNION ALL
(SELECT * FROM hist WHERE iid= 'JPNTSB_010201000000000002' ORDER BY time DESC LIMIT 2)

EXPLAIN (VERBOSE
)
SELECT
    iid,
    influx_time (time,
        interval '1h',
        interval '1451606400.000001s') AS tm,
    LAST (time,
        v),
    LAST (time,
        q),
    LAST (time,
        vr)
FROM
    hist
WHERE (time >= '2016-01-01T00:00:00Z')
AND (time <= timestamp '2016-01-01T00:00:00Z' + interval '4h')
AND (iid = 'JPNTSB_010101000000000000'
    OR iid = 'JPNTSB_010101000000000001'
    OR iid = 'JPNTSB_010201000000000002')
GROUP BY
    tm,
    iid
ORDER BY
    iid,
    tm;

-- case 2: 90 minutes interval query rewritten for postgres

SELECT
    iid,
    influx_time (time,
        interval '90m',
        interval '1451606400.000001s') AS tm,
    LAST (time,
        v),
    LAST (time,
        q),
    LAST (time,
        vr)
FROM
    hist__server1__0
WHERE (time >= timestamp '2016-01-01T00:00:00Z')
AND (time <= timestamp '2016-01-01T00:00:00Z' + interval '4h')
AND (iid = 'JPNTSB_010101000000000000'
    OR iid = 'JPNTSB_010101000000000001'
    OR iid = 'JPNTSB_010201000000000002')
GROUP BY
    tm,
    iid
ORDER BY
    iid,
    tm;

--SELECT LAST(v) AS v, LAST(q) AS q, LAST(vr) AS vr FROM hist WHERE (time >= '2015-12-31T22:00:00Z') AND (time <= '2016-01-01T02:00:00Z') AND (iid='JPNTSB_010101000000000000' OR iid='JPNTSB_010101000000000001' OR iid='JPNTSB_010201000000000002') GROUP BY time(1h, 1451599200000000001ns),iid FILL(previous);

SELECT
    influx_time (time,
        interval '1h',
        '1451599200.000001') AS tm,
    LAST (time,
        v),
    LAST (time,
        q),
    LAST (time,
        vr)
FROM
    hist
WHERE (time >= timestamp '2015-12-31T22:00:00Z')
AND (time <= timestamp '2016-01-01T02:00:00Z')
AND iid = 'JPNTSB_010101000000000000'
GROUP BY
    tm;

--SELECT LAST(v) AS v, LAST(q) AS q, LAST(vr) AS vr FROM hist WHERE (time >= '2015-12-31T22:00:00Z') AND (time <= '2016-01-01T02:00:00Z') AND iid='JPNTSB_010101000000000001' GROUP BY time(1h, 1451599200000000001ns) FILL(previous);
--SELECT LAST(v) AS v, LAST(q) AS q, LAST(vr) AS vr FROM hist WHERE (time >= '2015-12-31T22:00:00Z') AND (time <= '2016-01-01T02:00:00Z') AND iid='JPNTSB_010201000000000002' GROUP BY time(1h, 1451599200000000001ns) FILL(previous);
