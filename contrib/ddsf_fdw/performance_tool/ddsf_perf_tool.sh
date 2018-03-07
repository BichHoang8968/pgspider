#!/bin/sh
#This script takes following arguments
#Number of Sub nodes in DDSF
#Simple aggregate query
#Number of records
if [ "$#" -ne 4 ];then
        echo "Usage: $0 Number_of_server Number_of_records_per_block Number_of_blocks QUERY_TYPE(SUM/COUNT/MAX/MIN/AVG)"
        exit 1
fi

PERF_FOLDER="/tmp/perf_dir"
DS_PREFIX="DATASRC"
DS_PORT_OFFSET=10000
ROOT="DATAROOT"
ROOT_PORT=9999
BIN_DIR="/usr/local/pgsql/bin"
rm -rf "$PERF_FOLDER"
pkill postgres
> /usr/local/pgsql/share/extension/ddsf_server_nodes.conf
mkdir -p "$PERF_FOLDER"

$BIN_DIR/initdb $PERF_FOLDER/$ROOT
sed -i "/#port = 5432/c\port=$ROOT_PORT" $PERF_FOLDER/$ROOT/postgresql.conf
$BIN_DIR/pg_ctl -D $PERF_FOLDER/$ROOT -l  $PERF_FOLDER/$ROOT.log start
#$BIN_DIR/psql -p $ROOT_PORT -c "create extension postgres_fdw"
#$BIN_DIR/psql -p $ROOT_PORT -c "create extension ddsf_fdw"
#$BIN_DIR/psql -p $ROOT_PORT -c "CREATE SERVER DDSF FOREIGN DATA WRAPPER ddsf_fdw OPTIONS(host '127.0.0.1')"

for((i=0; i < $1; i++))
do
	$BIN_DIR/initdb $PERF_FOLDER/$DS_PREFIX$i
	port=`expr $DS_PORT_OFFSET + $i `
	echo $port
	sed -i "/#port = 5432/c\port=$port" $PERF_FOLDER/$DS_PREFIX$i/postgresql.conf
	$BIN_DIR/pg_ctl -D $PERF_FOLDER/$DS_PREFIX$i -l  $PERF_FOLDER/$DS_PREFIX$i.log start
	
done

sleep 5

$BIN_DIR/psql -p $ROOT_PORT -c "create extension postgres_fdw"
$BIN_DIR/psql -p $ROOT_PORT -c "create extension ddsf_fdw"
$BIN_DIR/psql -p $ROOT_PORT -c "CREATE SERVER DDSF FOREIGN DATA WRAPPER ddsf_fdw OPTIONS(host '127.0.0.1', port '$ROOT_PORT')"
$BIN_DIR/psql -p $ROOT_PORT -c "create user mapping for public SERVER DDSF"
	

for((i=0; i < $1; i++))
do
	port=`expr $DS_PORT_OFFSET + $i `
	$BIN_DIR/psql -p $ROOT_PORT -c "CREATE SERVER DATASRC_$i FOREIGN DATA WRAPPER postgres_fdw OPTIONS(host '127.0.0.1', port '$port')"
	$BIN_DIR/psql -p $ROOT_PORT -c "create user mapping for public SERVER DATASRC_$i"
	echo datasrc_$i >> /usr/local/pgsql/share/extension/ddsf_server_nodes.conf	
	#$BIN_DIR/psql -p $port -c "create table dist_table(ID int)"	
	#$BIN_DIR/psql -p $port -c "insert into dist_table select generate_series(1,$2)"	
done
$BIN_DIR/psql -p $ROOT_PORT -c "create foreign table dist_table(ID int)SERVER DDSF options(table_name 'dist_table');"


for((j=1; j <= $3; j++))
do
	record_cnt=$(($2 * $j))
	echo $record_cnt
	for((i=0; i < $1; i++))
	do
		port=`expr $DS_PORT_OFFSET + $i `
		$BIN_DIR/psql -p $port -c "drop table if exists dist_table"	
		$BIN_DIR/psql -p $port -c "create table dist_table(ID int)"	
		#$BIN_DIR/psql -p $port -c "insert into dist_table select generate_series(1,$record_cnt)"	
		$BIN_DIR/psql -p $port -c "insert into dist_table select a.n from generate_series($i,$i) as a(n), generate_series(1,$record_cnt)"	
	done

case $4 in 
"COUNT")
$BIN_DIR/psql -p $ROOT_PORT  << EOF
\timing
SELECT COUNT(ID) from dist_table;
EOF
;;
"SUM")
$BIN_DIR/psql -p $ROOT_PORT  << EOF
\timing
SELECT SUM(ID) from dist_table;
EOF
;;
"MAX")
$BIN_DIR/psql -p $ROOT_PORT  << EOF
\timing
SELECT MAX(ID) from dist_table;
EOF
;;
"MIN")
$BIN_DIR/psql -p $ROOT_PORT  << EOF
\timing
SELECT MIN(ID) from dist_table;
EOF
;;
"AVG")
$BIN_DIR/psql -p $ROOT_PORT  << EOF
\timing
SELECT AVG(ID) from dist_table;
EOF
;;
esac
echo -----------is the time taken for $1 Data sources with each having $record_cnt records for $4 query-------------
done
