#!/bin/bash
#

PGSPIDER_BIN=/home/tsdv/pgspider_test/PGS4301/PGSpider/PGS1/bin
PGSPIDER1_PORT=4301
PGSPIDER1_DB=pgspider
PGSPIDER1_USER=tsdv
PGSPIDER1_PWD=123456

echo "Test results:" >> ./TestResults.txt
# Execute sql command and save output to results folder
# First parameter: name of input file
# Second parameter: name of output file
execute_test(){
  input=$1
  output=$2
  TEST_SQL="./sql/$input"
  TEST_EXPECTED="./expected/$output"
  mkdir -p ./results/ || true
  TEST_RESULT="./results/$output"
  echo "=== Execute test: [$input] output [$output] ==="
  $PGSPIDER_BIN/psql --echo-all "port=$PGSPIDER1_PORT dbname=$PGSPIDER1_DB user=$PGSPIDER1_USER password=$PGSPIDER1_PWD" < $TEST_SQL > $TEST_RESULT 2>&1
  echo "$PGSPIDER_BIN/psql --echo-all "port=$PGSPIDER1_PORT dbname=$PGSPIDER1_DB user=$PGSPIDER1_USER password=$PGSPIDER1_PWD" < $TEST_SQL > $TEST_RESULT 2>&1"
  result=$(diff --brief $TEST_EXPECTED $TEST_RESULT)
  if [ "$result" = "" ]
  then
    echo "SUCCESS"
    echo "test [$input]: SUCCESS" >> ./TestResults.txt
  else
    echo "FAILED: $result"
    echo "test [$input]: FAILED" >> ./TestResults.txt
  fi
}

# STATE 1: All node are alive.
rm -f ./TestResults.txt
rm -rf ./results
mkdir ./results
read -p "STATE 1: Start all data source then press Enter to execute test"
execute_test keep_alive.sql state_1.out
# STATE 2: Shutdown TinyBrace node server
read -p "STATE 2: Disconnect TinyBrace server (disconnect network) then press Enter to execute test"
execute_test keep_alive.sql state_2.out
# STATE 3: Shutdown Influx node server
read -p "STATE 3: Disconnect InfluxDB server (disconnect network) then press Enter to execute test"
execute_test keep_alive.sql state_3.out
# STATE 4: Shutdown PostgreSQL server
read -p "STATE 4: Disconnect PostgreSQL server (disconnect network) then press Enter to execute test"
execute_test keep_alive.sql state_4.out
# STATE 5: Shutdown MySQL server
read -p "STATE 5: Disconnect MySQL server (disconnect network) then press Enter to execute test"
execute_test keep_alive.sql state_5.out
# STATE 6: Start TinyBrace server
read -p "STATE 6: Start TinyBrace server then press Enter to execute test"
execute_test keep_alive.sql state_6.out
# STATE 7: Start InfluxDB server
read -p "STATE 7: Start InfluxDB server then press Enter to execute test"
execute_test keep_alive.sql state_7.out
# STATE 8: Start PostgreSQL server
read -p "STATE 8: Start PostgreSQL server then press Enter to execute test"
execute_test keep_alive.sql state_8.out
# STATE 9: Start MySQL server
read -p "STATE 9: Start MysqlSQL server then press Enter to execute test"
execute_test keep_alive.sql state_9.out
# STATE 10: Shutdown PGSpider2 node
read -p "STATE 10: Shutdown pgspider2 node then press Enter to execute test"
execute_test keep_alive.sql state_10.out
# STATE 11: Shutdown PGSpider3 node
read -p "STATE 11: Shutdown pgspider3 node then press Enter to execute test"
execute_test keep_alive.sql state_11.out
# STATE 12: Start PGSpider2 node
read -p "STATE 12: Start pgspider2 node then press Enter to execute test"
execute_test keep_alive.sql state_12.out
# STATE 13: Start PGSpider3 node
read -p "STATE 13: Start pgspider3 node then press Enter to execute test"
execute_test keep_alive.sql state_13.out

cat ./TestResults.txt
